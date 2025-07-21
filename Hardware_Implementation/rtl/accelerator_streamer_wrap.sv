`include "hci_helpers.svh"

module accelerator_streamer_wrap
  import accelerator_package::*;
  import hwpe_ctrl_package::*;
  import hci_package::*;
#(
`ifndef SYNTHESIS
  parameter bit WAIVE_RQ3_ASSERT  = 1'b0,
  parameter bit WAIVE_RQ4_ASSERT  = 1'b0,
  parameter bit WAIVE_RSP3_ASSERT = 1'b0,
  parameter bit WAIVE_RSP5_ASSERT = 1'b0,
`endif
  parameter MP  = 4,

  parameter MISALIGNED_ACCESSES = 0,
  parameter META_CHUNK_SIZE     = 128,
  parameter X_ITEM_SIZE         = 32,
  parameter Y_ITEM_SIZE         = 32,
  parameter Z_ITEM_SIZE         = 64,
  parameter Y_BLOCK_SIZE        = 4,

  parameter Z_BW = Z_ITEM_SIZE * Y_BLOCK_SIZE
)
(
  // global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  clear_i,
  input  logic                                  test_mode_i,
  
  // tcdm master ports
  output logic [MP-1:0]                         tcdm_req,
  input  logic [MP-1:0]                         tcdm_gnt,
  output logic [MP-1:0][31:0]                   tcdm_add,
  output logic [MP-1:0]                         tcdm_wen,
  output logic [MP-1:0][3:0]                    tcdm_be,
  output logic [MP-1:0][31:0]                   tcdm_data,
  input  logic [MP-1:0][31:0]                   tcdm_r_data,
  input  logic [MP-1:0]                         tcdm_r_valid,
  
  //X data stream out
  output logic                                  x_valid_o,
  input  logic                                  x_ready_i,
  output logic [MP * 32 - 1 : 0]                     x_data_o,
  output logic [(MP * 32) / 8 - 1 : 0]                 x_strb_o,

  //Y data stream out
  output logic                                  y_valid_o,
  input  logic                                  y_ready_i,
  output logic [MP * 32 - 1 : 0]                     y_data_o,
  output logic [(MP * 32) / 8 - 1 : 0]                 y_strb_o,

  //Z data stream in
  input  logic                                  z_valid_i,
  output logic                                  z_ready_o,
  input  logic [Z_BW - 1 : 0]                   z_data_i,
  input  logic [Z_BW / 8 - 1 : 0]               z_strb_i,

  input  ctrl_streamer_t                        ctrl_i,
  input  params_schedulers_t                    params_schedulers_i

);

  localparam BW = MP * 32;

  localparam hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '{
    DW:  BW,
    AW:  DEFAULT_AW,
    BW:  32,
    UW:  DEFAULT_UW,
    IW:  DEFAULT_IW,
    EW:  DEFAULT_EW,
    EHW: DEFAULT_EHW
  };
  hci_core_intf #(
`ifndef SYNTHESIS
    .WAIVE_RQ3_ASSERT  ( WAIVE_RQ3_ASSERT  ),
    .WAIVE_RQ4_ASSERT  ( WAIVE_RQ4_ASSERT  ),
    .WAIVE_RSP3_ASSERT ( WAIVE_RSP3_ASSERT ),
    .WAIVE_RSP5_ASSERT ( WAIVE_RSP5_ASSERT ),
`endif
    .DW  ( BW          ),
    .AW  ( DEFAULT_AW  ),
    .BW  ( DEFAULT_BW  ),
    .UW  ( DEFAULT_UW  ),
    .IW  ( DEFAULT_IW  ),
    .EW  ( DEFAULT_EW  ),
    .EHW ( DEFAULT_EHW )
  ) tcdm (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(.DATA_WIDTH(BW)) dataX_o(.clk(clk_i));
  hwpe_stream_intf_stream #(.DATA_WIDTH(BW)) dataY_o(.clk(clk_i));
  hwpe_stream_intf_stream #(.DATA_WIDTH(Z_BW)) dataZ_i(.clk(clk_i));

  // bindings
  generate
    for(genvar ii=0; ii<MP; ii++) begin: tcdm_binding
      assign tcdm_req  [ii] = tcdm.req;
      assign tcdm_add  [ii] = tcdm.add + ii*4;
      assign tcdm_wen  [ii] = tcdm.wen;
      assign tcdm_be   [ii] = tcdm.be[3:0];
      assign tcdm_data [ii] = tcdm.data[(ii+1)*32-1:ii*32];
    end 
      assign tcdm.gnt      = &(tcdm_gnt);
      assign tcdm.r_data   = { >> {tcdm_r_data}};
      assign tcdm.r_valid  = &(tcdm_r_valid);
  endgenerate

  assign x_valid_o      = dataX_o.valid;
  assign dataX_o.ready  = x_ready_i;
  assign x_data_o       = dataX_o.data;
  assign x_strb_o       = dataX_o.strb;

  assign y_valid_o      = dataY_o.valid;
  assign dataY_o.ready  = y_ready_i;
  assign y_data_o       = dataY_o.data;
  assign y_strb_o       = dataY_o.strb;

  assign dataZ_i.valid  = z_valid_i;
  assign z_ready_o      = dataZ_i.ready;
  assign dataZ_i.data   = z_data_i;
  assign dataZ_i.strb   = z_strb_i;

  accelerator_streamer #(
    .BW                    (BW),
    .MISALIGNED_ACCESSES   (MISALIGNED_ACCESSES),
    .META_CHUNK_SIZE       (META_CHUNK_SIZE),
    .X_ITEM_SIZE           (X_ITEM_SIZE),
    .Y_ITEM_SIZE           (Y_ITEM_SIZE),
    .Z_ITEM_SIZE           (Z_ITEM_SIZE),
    .Y_BLOCK_SIZE          (Y_BLOCK_SIZE),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) )
  ) streamer_i (
    .clk_i                 (clk_i),
    .rst_ni                (rst_ni),
    .test_mode_i           (test_mode_i),
    .clear_i               (clear_i),
    .dataX_o               (dataX_o),
    .dataY_o               (dataY_o),
    .dataZ_i               (dataZ_i),
    .tcdm                  (tcdm.initiator),
    .params_schedulers_i   (params_schedulers_i),
    .ctrl_i                (ctrl_i)
  );

  localparam int unsigned DEBUG_DW  = `HCI_SIZE_GET_DW(tcdm);
  localparam int unsigned DEBUG_BW  = `HCI_SIZE_GET_BW(tcdm);
  localparam int unsigned DEBUG_AW  = `HCI_SIZE_GET_AW(tcdm);
  localparam int unsigned DEBUG_UW  = `HCI_SIZE_GET_UW(tcdm);
  localparam int unsigned DEBUG_IW  = `HCI_SIZE_GET_IW(tcdm);
  localparam int unsigned DEBUG_EW  = `HCI_SIZE_GET_EW(tcdm);
  localparam int unsigned DEBUG_EHW = `HCI_SIZE_GET_EHW(tcdm);

endmodule // accelerator_streamer_wrap