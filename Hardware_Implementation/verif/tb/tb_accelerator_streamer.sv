`include "hci_helpers.svh"

module tb_accelerator_streamer;

  timeunit 1ps;
  timeprecision 1ps;

  import accelerator_package::*;
  import tb_package::*;  // definitions for TCP, TA, TT, MEMORY_SIZE, etc.
  import hwpe_stream_package::*;
  import hwpe_ctrl_package::*;
  import hci_package::*;

  //----------------------------------------------------------------------
  // Parameters & file paths
  //----------------------------------------------------------------------
  parameter PROB_STALL      = 0.1;
  parameter BASE_ADDR       = 0;

  parameter TCDM_FIFO_DEPTH = 0;
  parameter bit MISALIGNED_ACCESSES  = 1;

  parameter int MP                   = `MP;                   // number of TCDM channels
  parameter int META_CHUNK_SIZE      = `META_CHUNK_SIZE;
  parameter int X_ITEM_SIZE          = `X_ITEM_SIZE;
  parameter int Y_ITEM_SIZE          = `Y_ITEM_SIZE;
  parameter int Z_ITEM_SIZE          = `Z_ITEM_SIZE;
  parameter int Y_BLOCK_SIZE         = `Y_BLOCK_SIZE;
  parameter logic [31:0] X_BASE_ADDRESS = `X_BASE_ADDRESS;
  parameter logic [31:0] Y_BASE_ADDRESS = `Y_BASE_ADDRESS;
  parameter logic [31:0] Z_BASE_ADDRESS = `Z_BASE_ADDRESS;
  parameter int X_COLUMNS            = `X_COLUMNS;
  parameter int Y_COLUMNS            = `Y_COLUMNS;
  parameter int X_ROWS               = `X_ROWS;
  parameter int Y_ROWS               = `Y_ROWS;
  parameter int X_TOTAL_LOADS        = `X_TOTAL_LOADS;
  parameter int Y_TOTAL_LOADS        = `Y_TOTAL_LOADS;

  parameter BW = MP * 32;             // total tcdm bw

  parameter int X_ITEM_SIZE_BYTES    = X_ITEM_SIZE / 8;
  parameter int Y_ITEM_SIZE_BYTES    = Y_ITEM_SIZE / 8;
  parameter int X_ITEMS_CYCLE        = $floor(BW / X_ITEM_SIZE);
  parameter int X_BITS_CYCLE         = X_ITEMS_CYCLE * X_ITEM_SIZE;
  parameter int Y_BITS_CYCLE         = Y_BLOCK_SIZE * Y_ITEM_SIZE;
  parameter int Z_TOTAL_ENTRIES      = X_ROWS * Y_COLUMNS;
  parameter int STREAM_BW_OUTGOING   = Z_ITEM_SIZE * Y_BLOCK_SIZE;

  string INITIAL_MEMORY_CONTENT_PATH = `INITIAL_MEMORY_CONTENT_PATH;
  string X_GOLDEN_PATH = `X_GOLDEN_PATH;
  string Y_GOLDEN_PATH = `Y_GOLDEN_PATH;
  string Z_GOLDEN_PATH = `Z_GOLDEN_PATH;

  //----------------------------------------------------------------------
  // Global signals
  //----------------------------------------------------------------------
  logic                   clk_i        = 1'b0;
  logic                   rst_ni       = 1'b1;
  logic                   test_mode_i  = 1'b0;
  logic                   clear_i      = 1'b0;
  logic                   enable_i     = 1'b1;
  logic                   busy         = 1'b0;

  //----------------------------------------------------------------------
  // TCDM memory model
  //----------------------------------------------------------------------
  localparam hci_size_parameter_t `HCI_SIZE_PARAM(tcdm_streamer) = '{
    DW:  BW,
    AW:  DEFAULT_AW,
    BW:  32,
    UW:  DEFAULT_UW,
    IW:  DEFAULT_IW,
    EW:  DEFAULT_EW,
    EHW: DEFAULT_EHW
  };

  hci_core_intf #(
    .DW  ( BW          ),
    .AW  ( DEFAULT_AW  ),
    .BW  ( 32          ),
    .UW  ( DEFAULT_UW  ),
    .IW  ( DEFAULT_IW  ),
    .EW  ( DEFAULT_EW  ),
    .EHW ( DEFAULT_EHW )
  ) tcdm_streamer (.clk(clk_i));
  hwpe_stream_intf_tcdm tcdm_mem [MP-1:0] (.clk(clk_i));
  logic [MP-1:0]       tcdm_signal_req, tcdm_signal_gnt;
  logic [MP-1:0][31:0] tcdm_signal_add;
  logic [MP-1:0]       tcdm_signal_wen;
  logic [MP-1:0][3:0]  tcdm_signal_be;
  logic [MP-1:0][31:0] tcdm_signal_data;
  logic [MP-1:0][31:0] tcdm_signal_r_data;
  logic [MP-1:0]       tcdm_signal_r_valid;

  // bindings
  generate
    for(genvar ii=0; ii<MP; ii++) begin: tcdm_streamer_binding
      assign tcdm_signal_req  [ii] = tcdm_streamer.req;
      assign tcdm_signal_add  [ii] = tcdm_streamer.add + ii*4;
      assign tcdm_signal_wen  [ii] = tcdm_streamer.wen;
      assign tcdm_signal_be   [ii] = tcdm_streamer.be[3:0];
      assign tcdm_signal_data [ii] = tcdm_streamer.data[(ii+1)*32-1:ii*32];
    end 
      assign tcdm_streamer.gnt      = &(tcdm_signal_gnt);
      assign tcdm_streamer.r_data   = { >> {tcdm_signal_r_data}};
      assign tcdm_streamer.r_valid  = &(tcdm_signal_r_valid);
  endgenerate

  generate
    for(genvar ii=0; ii<MP; ii++) begin : tcdm_mem_binding
      assign tcdm_mem[ii].req       = tcdm_signal_req [ii];
      assign tcdm_mem[ii].add       = {8'b0, tcdm_signal_add[ii][23:0]};
      assign tcdm_mem[ii].wen       = tcdm_signal_wen [ii];
      assign tcdm_mem[ii].be        = tcdm_signal_be  [ii];
      assign tcdm_mem[ii].data      = tcdm_signal_data[ii];
      assign tcdm_signal_gnt    [ii]   = tcdm_mem[ii].gnt;
      assign tcdm_signal_r_data [ii]   = tcdm_mem[ii].r_data;
      assign tcdm_signal_r_valid[ii]   = tcdm_mem[ii].r_valid;
    end
  endgenerate

  //----------------------------------------------------------------------
  // Stream interfaces
  //----------------------------------------------------------------------
  hwpe_stream_intf_stream #(.DATA_WIDTH(BW)) dataX_o(.clk(clk_i));
  hwpe_stream_intf_stream #(.DATA_WIDTH(BW)) dataY_o(.clk(clk_i));
  hwpe_stream_intf_stream #(.DATA_WIDTH(STREAM_BW_OUTGOING)) dataZ_i(.clk(clk_i));

  //----------------------------------------------------------------------
  // Scheduler params and control
  //----------------------------------------------------------------------
  params_schedulers_t     params_schedulers_i;
  ctrl_streamer_t         ctrl_i;

  //----------------------------------------------------------------------
  // Capture buffers & counters for X/Y streams
  //----------------------------------------------------------------------
  logic [X_BITS_CYCLE-1:0] captured_X [0:X_TOTAL_LOADS-1];
  logic [Y_BITS_CYCLE-1:0] captured_Y [0:Y_TOTAL_LOADS-1];
  logic [X_BITS_CYCLE-1:0] golden_X [0:X_TOTAL_LOADS-1];
  logic [Y_BITS_CYCLE-1:0] golden_Y [0:Y_TOTAL_LOADS-1];
  logic [Z_ITEM_SIZE-1:0] golden_Z [0:Z_TOTAL_ENTRIES-1];
  integer x_cnt = 0, y_cnt = 0;

  //----------------------------------------------------------------------
  // Clock tasks
  //----------------------------------------------------------------------

  always #(TCP/2) clk_i = ~clk_i;

  //----------------------------------------------------------------------
  // Instantiate DUT
  //----------------------------------------------------------------------
  accelerator_streamer #(
    .BW                    (BW),
    .MISALIGNED_ACCESSES   (MISALIGNED_ACCESSES),
    .META_CHUNK_SIZE       (META_CHUNK_SIZE),
    .X_ITEM_SIZE           (X_ITEM_SIZE),
    .Y_ITEM_SIZE           (Y_ITEM_SIZE),
    .Z_ITEM_SIZE           (Z_ITEM_SIZE),
    .Y_BLOCK_SIZE          (Y_BLOCK_SIZE),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm_streamer) )
  ) streamer_i (
    .clk_i                 (clk_i),
    .rst_ni                (rst_ni),
    .test_mode_i           (test_mode_i),
    .clear_i               (clear_i),
    .dataX_o               (dataX_o),
    .dataY_o               (dataY_o),
    .dataZ_i               (dataZ_i),
    .tcdm                  (tcdm_streamer.initiator),
    .params_schedulers_i   (params_schedulers_i),
    .ctrl_i                (ctrl_i)
  );

  //----------------------------------------------------------------------
  // Dummy memory
  //----------------------------------------------------------------------
  tb_dummy_memory #(
    .MP          (MP),
    .MEMORY_SIZE (MEMORY_SIZE),
    .BASE_ADDR   (BASE_ADDR),
    .PROB_STALL  (PROB_STALL),
    .TCP         (TCP),
    .TA          (TA),
    .TT          (TT)
  ) i_dummy_memory (
    .clk_i       (clk_i),
    .randomize_i (1'b0),
    .enable_i    (enable_i),
    .stallable_i (busy),
    .tcdm        (tcdm_mem)
  );

  //----------------------------------------------------------------------
  // Engine-side X/Y ready and capture logic
  //----------------------------------------------------------------------
  initial begin
    dataX_o.ready = 1;
    dataY_o.ready = 1;
  end

  always_ff @(posedge clk_i) begin
    if (dataX_o.valid && dataX_o.ready) begin
      for (int lane = 0; lane < X_ITEMS_CYCLE; lane++) begin
        if (lane < $bits(dataX_o.strb) && dataX_o.strb[lane])
          captured_X[x_cnt][lane*X_ITEM_SIZE +: X_ITEM_SIZE] <=
            dataX_o.data[lane*X_ITEM_SIZE +: X_ITEM_SIZE];
        else
          captured_X[x_cnt][lane*X_ITEM_SIZE +: X_ITEM_SIZE] <= '0;
      end
      if (x_cnt + 1 == X_TOTAL_LOADS)
        dataX_o.ready <= 0;
      x_cnt <= x_cnt + 1;
    end
  end

  always_ff @(posedge clk_i) begin
    if (dataY_o.valid && dataY_o.ready) begin
      for (int lane = 0; lane < Y_BLOCK_SIZE; lane++) begin
        if (lane < $bits(dataY_o.strb) && dataY_o.strb[lane])
          captured_Y[y_cnt][lane*Y_ITEM_SIZE +: Y_ITEM_SIZE] <=
            dataY_o.data[lane*Y_ITEM_SIZE +: Y_ITEM_SIZE];
        else
          captured_Y[y_cnt][lane*Y_ITEM_SIZE +: Y_ITEM_SIZE] <= '0;
      end
      if (y_cnt + 1 == Y_TOTAL_LOADS)
        dataY_o.ready <= 0;
      y_cnt <= y_cnt + 1;
    end
  end

  //----------------------------------------------------------------------
  // Z stream generation
  //----------------------------------------------------------------------
  integer z_count;
  initial begin
    integer total_z = params_schedulers_i.X_sched_params.x_rows * params_schedulers_i.X_sched_params.y_row_iters;
    z_count = 0;
    dataZ_i.valid = 0;
    dataZ_i.data  = '0;
    while (z_count < total_z) begin
      repeat($urandom_range(5,10)) @(posedge clk_i);
      dataZ_i.valid = 1;
      dataZ_i.data  = '0;
      for (int j = 0; j < Y_BLOCK_SIZE; j++) begin
        if (j == 0 || j == Y_BLOCK_SIZE-1)
          dataZ_i.data[(j+1)*Z_ITEM_SIZE-1 -: Z_ITEM_SIZE] = z_count + 1;
        else
          dataZ_i.data[(j+1)*Z_ITEM_SIZE-1 -: Z_ITEM_SIZE] = {{Z_ITEM_SIZE{1'b1}}};
      end
      @(posedge clk_i);
      dataZ_i.valid = 0;
      z_count++;
    end
  end

  //----------------------------------------------------------------------
  // Test and checks
  //----------------------------------------------------------------------
  initial begin
    integer error = 0;
    int i;
    int b;
    logic [Z_ITEM_SIZE-1:0] mem_word;

    // load stimuli
    $readmemb(INITIAL_MEMORY_CONTENT_PATH, i_dummy_memory.memory);

    // load golden outputs
    $readmemb(X_GOLDEN_PATH, golden_X);
    $readmemb(Y_GOLDEN_PATH, golden_Y);
    $readmemb(Z_GOLDEN_PATH, golden_Z);

    ctrl_i.acc_working = 1;
    ctrl_i.acc_done    = 0;

    // set scheduler params
    params_schedulers_i.X_sched_params = '{ base_address: X_BASE_ADDRESS,
                                            y_row_iters:   (Y_COLUMNS + Y_BLOCK_SIZE - 1)/Y_BLOCK_SIZE,
                                            x_columns:     X_COLUMNS,
                                            x_columns_log: $clog2(X_COLUMNS),
                                            x_rows:        X_ROWS };
    params_schedulers_i.Y_sched_params = '{ base_address: Y_BASE_ADDRESS,
                                            y_columns: Y_COLUMNS,
                                            y_row_iters:   (Y_COLUMNS + Y_BLOCK_SIZE - 1)/Y_BLOCK_SIZE,
                                            y_rows:        Y_ROWS,
                                            y_rows_log:    $clog2(Y_ROWS),
                                            x_rows:        X_ROWS };
    params_schedulers_i.Z_sched_params = '{ base_address: Z_BASE_ADDRESS,
                                            y_columns:     Y_COLUMNS,
                                            y_row_iters:   (Y_COLUMNS + Y_BLOCK_SIZE - 1)/Y_BLOCK_SIZE,
                                            x_rows:        X_ROWS };

    // reset
    rst_ni = 0;
    @(posedge clk_i);
    @(posedge clk_i);
    rst_ni = 1;

    // wait for X/Y streaming to complete
    wait (x_cnt == X_TOTAL_LOADS && y_cnt == Y_TOTAL_LOADS);

    // Compare X
    for (i = 0; i < X_TOTAL_LOADS; i++) begin
      if (captured_X[i] !== golden_X[i]) begin
        $error("Stream X mismatch at %0d: got %h, expected %h",
              i, captured_X[i], golden_X[i]);
        error = 1;
      end
    end

    // Compare Y
    for (i = 0; i < Y_TOTAL_LOADS; i++) begin
      if (captured_Y[i] !== golden_Y[i]) begin
        $error("Stream Y mismatch at %0d: got %h, expected %h",
              i, captured_Y[i], golden_Y[i]);
        error = 1;
      end
    end

    // Compare Z
    for (i = 0; i < X_ROWS*Y_ROWS; i++) begin
      mem_word = '0;
      for (b = 0; b < 4; b++) begin
        mem_word[8*(3-b) +: 8] = i_dummy_memory.memory[
          params_schedulers_i.Z_sched_params.base_address + i*4 + b
        ];
      end
      if (mem_word !== golden_Z[i]) begin
        $error("Memory Z mismatch at %0d: got %h, expected %h",
              i, mem_word, golden_Z[i]);
        error = 1;
      end
    end

    // wait for Z stream to complete and finalize
    wait (z_count == params_schedulers_i.X_sched_params.x_rows * params_schedulers_i.X_sched_params.y_row_iters && dataZ_i.valid == 0);
    @(posedge clk_i);
    ctrl_i.acc_done = 1;

    $display(error?"[TEST FAILED]" : "[TEST PASSED] Streamer X/Y order correct.");
    $finish;
  end
endmodule
