from generate_sparse_matrix import generate_sparse_matrix
from accesses_calculation import input_accesses_calculation
from accesses_calculation import output_accesses_calculation
from bandwidth_calculation import input_bandwidth_calculation
from bandwidth_calculation import output_bandwidth_calculation
from avg_reuse_distance import avg_reuse_distance
import math

def gustavson_dense_golden(reuse_policy, X_elem_size, Y_elem_size, X_rows, X_columns, Y_rows, Y_columns):
    # Matrix generation
    In_data_size = 8  # has to be a multiple of 8 such that the memory locations are not segmented
    Out_data_size = 24  # has to be a multiple of 8 such that the memory locations are not segmented

    X_sparsity = 0.5
    Y_sparsity = 0.5

    X = generate_sparse_matrix(X_rows, X_columns, X_sparsity, In_data_size)
    Y = generate_sparse_matrix(Y_rows, Y_columns, Y_sparsity, In_data_size)
    Z = [['0' * Out_data_size for _ in range(Y_columns)] for _ in range(X_rows)]

    # initialization of vectors of data usage
    X_offset_addr = []
    Y_offset_addr = []
    Z_offset_addr = []

    # Number of tiles for X and Y
    k_iters = math.ceil(X_columns / X_elem_size)
    Y_column_blocks = math.ceil(Y_columns / Y_elem_size)

    latency = 0

    if reuse_policy == "X":

        for X_row in range(X_rows):
            for tile in range(k_iters):

                start_X = tile * X_elem_size
                end_X = min(start_X + X_elem_size, X_columns)

                # Load tile of X
                X_tile = X[X_row][start_X:end_X]

                for Y_column_block in range(Y_column_blocks):

                    start_Y = Y_column_block * Y_elem_size
                    end_Y = min(start_Y + Y_elem_size, Y_columns)

                    # Load tile of Y
                    Y_tile = [Y[k][start_Y:end_Y] for k in range(start_X, end_X)]

                    # Initialize output buffer
                    out_buffer = Z[X_row][start_Y:end_Y]

                    # region COMPUTING THE RESULT FOR THE SPECIFIC CYCLE

                    # Multiply-accumulate
                    for x_idx, x_bin in enumerate(X_tile):
                        x_val = int(x_bin, 2)
                        for y_idx in range(end_Y - start_Y):
                            y_val = int(Y_tile[x_idx][y_idx], 2)
                            acc = int(out_buffer[y_idx], 2)
                            acc += x_val * y_val
                            acc &= (1 << Out_data_size) - 1
                            out_buffer[y_idx] = format(acc, f'0{Out_data_size}b')

                    # endregion

                    # Store in Z
                    Z[X_row][start_Y:end_Y] = out_buffer

                    # region APPENDING DATA ITEMS INFORMATION

                    # Offset addresses for the current cycle
                    X_start_addr = (X_row * X_columns + tile * X_elem_size) * (In_data_size / 8)
                    Y_start_addr = (Y_column_block * Y_elem_size * Y_rows + tile * X_elem_size) * (In_data_size / 8)
                    Z_start_addr = (X_row * Y_columns + Y_column_block * Y_elem_size) * (Out_data_size / 8)

                    # Load the addresses of the accessed elements of each matrix for this cycle
                    cycle_X = [X_start_addr + i * (In_data_size / 8) for i in range(end_X - start_X)]
                    cycle_Y = []
                    for step in range(end_Y - start_Y):
                        base_offset = step * (Y_rows * (In_data_size / 8))
                        for offset in range(end_X - start_X):
                            cycle_Y.append(Y_start_addr + base_offset + offset * (In_data_size / 8))
                    cycle_Z = [Z_start_addr + i * (Out_data_size / 8) for i in range(end_Y - start_Y)]

                    # Add the cycle address information to the list
                    X_offset_addr.append(cycle_X)
                    Y_offset_addr.append(cycle_Y)
                    Z_offset_addr.append(cycle_Z)

                    latency += 1

                    # endregion

        # At the end as final step I add a stall for the first load cycle and the last store cycle where no computation is done

        X_offset_addr = X_offset_addr + [[]] + [[]]
        Y_offset_addr = Y_offset_addr + [[]] + [[]]
        Z_offset_addr_fetch = Z_offset_addr + [[]] + [[]]
        Z_offset_addr_store = [[]] + [[]] + Z_offset_addr

        # Now I turn the list into the actual accesses to memory using a function

        X_offset_addr = input_accesses_calculation(X_offset_addr)
        Y_offset_addr = input_accesses_calculation(Y_offset_addr)
        Z_offset_addr_fetch = input_accesses_calculation(Z_offset_addr_fetch)
        Z_offset_addr_store = output_accesses_calculation(Z_offset_addr_store)

        # FINAL LATENCY CALCULATION

        latency = latency + 2

        # BANDWIDTH CALCULATION

        Input_avg_bandwidth, Input_peak_bandwidth = input_bandwidth_calculation(X_offset_addr, Y_offset_addr,
                                                                                Z_offset_addr_fetch,
                                                                                In_data_size, Out_data_size, 1,
                                                                                -1)
        Output_avg_bandwidth, Output_peak_bandwidth = output_bandwidth_calculation(Z_offset_addr_store, Out_data_size)

        Combined_avg_bandwidth = Input_avg_bandwidth + Output_avg_bandwidth
        Combined_peak_bandwidth = Input_peak_bandwidth + Output_peak_bandwidth

        # REUSE DISTANCE CALCULATION

        X_reuse_distance = 0
        Y_reuse_distance = avg_reuse_distance(Y_offset_addr)
        Z_reuse_distance = avg_reuse_distance(Z_offset_addr_store)

    elif reuse_policy == "Y":

        for Y_column_block in range(Y_column_blocks):
            for tile in range(k_iters):

                start_Y = Y_column_block * Y_elem_size
                end_Y = min(start_Y + Y_elem_size, Y_columns)
                start_X = tile * X_elem_size
                end_X = min(start_X + X_elem_size, X_columns)

                # Load tile of Y
                Y_tile = [Y[k][start_Y:end_Y] for k in range(start_X, end_X)]

                for X_row in range(X_rows):

                    # Load tile of X
                    X_tile = X[X_row][start_X:end_X]

                    # Load output buffer content
                    out_buffer = Z[X_row][start_Y:end_Y]

                    # region COMPUTING THE RESULT FOR THE SPECIFIC CYCLE

                    for x_idx, x_bin in enumerate(X_tile):
                        x_val = int(x_bin, 2)
                        for y_idx in range(end_Y - start_Y):
                            y_val = int(Y_tile[x_idx][y_idx], 2)
                            acc = int(out_buffer[y_idx], 2)
                            acc += x_val * y_val
                            acc &= (1 << Out_data_size) - 1
                            out_buffer[y_idx] = format(acc, f'0{Out_data_size}b')

                    # endregion

                    Z[X_row][start_Y:end_Y] = out_buffer

                    # region APPENDING DATA ITEMS INFORMATION

                    # Offset addresses for the current cycle
                    X_start_addr = (X_row * X_columns + tile * X_elem_size) * (In_data_size / 8)
                    Y_start_addr = (Y_column_block * Y_elem_size * Y_rows + tile * X_elem_size) * (In_data_size / 8)
                    Z_start_addr = (X_row * Y_columns + Y_column_block * Y_elem_size) * (Out_data_size / 8)

                    # Load the addresses of the accessed elements of each matrix for this cycle
                    cycle_X = [X_start_addr + i * (In_data_size / 8) for i in range(end_X - start_X)]
                    cycle_Y = []
                    for step in range(end_Y - start_Y):
                        base_offset = step * (Y_rows * (In_data_size / 8))
                        for offset in range(end_X - start_X):
                            cycle_Y.append(Y_start_addr + base_offset + offset * (In_data_size / 8))
                    cycle_Z = [Z_start_addr + i * (Out_data_size / 8) for i in range(end_Y - start_Y)]

                    # Add the cycle address information to the list
                    X_offset_addr.append(cycle_X)
                    Y_offset_addr.append(cycle_Y)
                    Z_offset_addr.append(cycle_Z)

                    latency += 1

                    # endregion

        # At the end as final step I add a stall for the first load cycle and the last store cycle where no computation is done

        X_offset_addr = X_offset_addr + [[]] + [[]]
        Y_offset_addr = Y_offset_addr + [[]] + [[]]
        Z_offset_addr_fetch = Z_offset_addr + [[]] + [[]]
        Z_offset_addr_store = [[]] + [[]] + Z_offset_addr

        # Now I turn the list into the actual accesses to memory using a function

        X_offset_addr = input_accesses_calculation(X_offset_addr)
        Y_offset_addr = input_accesses_calculation(Y_offset_addr)
        Z_offset_addr_fetch = input_accesses_calculation(Z_offset_addr_fetch)
        Z_offset_addr_store = output_accesses_calculation(Z_offset_addr_store)

        # FINAL LATENCY CALCULATION

        latency = latency + 2

        # BANDWIDTH CALCULATION

        Input_avg_bandwidth, Input_peak_bandwidth = input_bandwidth_calculation(X_offset_addr,
                                                                                Y_offset_addr,
                                                                                Z_offset_addr_fetch,
                                                                                In_data_size, Out_data_size,
                                                                                1,
                                                                                -1)
        Output_avg_bandwidth, Output_peak_bandwidth = output_bandwidth_calculation(Z_offset_addr_store,
                                                                                   Out_data_size)

        Combined_avg_bandwidth = Input_avg_bandwidth + Output_avg_bandwidth
        Combined_peak_bandwidth = Input_peak_bandwidth + Output_peak_bandwidth

        # REUSE DISTANCE CALCULATION

        X_reuse_distance = avg_reuse_distance(X_offset_addr)
        Y_reuse_distance = 0
        Z_reuse_distance = avg_reuse_distance(Z_offset_addr_store)

    elif reuse_policy == "Z":

        for X_row in range(X_rows):
            for Y_column_block in range(Y_column_blocks):

                start_Y = Y_column_block * Y_elem_size
                end_Y = min(start_Y + Y_elem_size, Y_columns)

                # Initialize output buffer
                out_buffer = ['0'] * (end_Y - start_Y)  # no need to reload accumulator!

                for tile in range(k_iters):

                    start_X = tile * X_elem_size
                    end_X = min(start_X + X_elem_size, X_columns)

                    # Load tile of X
                    X_tile = X[X_row][start_X:end_X]

                    # Load tile of Y
                    Y_tile = [Y[k][start_Y:end_Y] for k in range(start_X, end_X)]

                    # region COMPUTING THE RESULT FOR THE SPECIFIC CYCLE

                    for x_idx, x_bin in enumerate(X_tile):
                        x_val = int(x_bin, 2)
                        for y_idx in range(end_Y - start_Y):
                            y_val = int(Y_tile[x_idx][y_idx], 2)
                            acc = int(out_buffer[y_idx], 2)
                            acc += x_val * y_val
                            acc &= (1 << Out_data_size) - 1
                            out_buffer[y_idx] = format(acc, f'0{Out_data_size}b')

                    # endregion

                    Z[X_row][start_Y:end_Y] = out_buffer

                    # region APPENDING DATA ITEMS INFORMATION

                    # Offset addresses for the current cycle
                    X_start_addr = (X_row * X_columns + tile * X_elem_size) * (In_data_size / 8)
                    Y_start_addr = (Y_column_block * Y_elem_size * Y_rows + tile * X_elem_size) * (In_data_size / 8)
                    Z_start_addr = (X_row * Y_columns + Y_column_block * Y_elem_size) * (Out_data_size / 8)

                    # Load the addresses of the accessed elements of each matrix for this cycle
                    cycle_X = [X_start_addr + i * (In_data_size / 8) for i in range(end_X - start_X)]
                    cycle_Y = []
                    for step in range(end_Y - start_Y):
                        base_offset = step * (Y_rows * (In_data_size / 8))
                        for offset in range(end_X - start_X):
                            cycle_Y.append(Y_start_addr + base_offset + offset * (In_data_size / 8))
                    cycle_Z = [Z_start_addr + i * (Out_data_size / 8) for i in range(end_Y - start_Y)]

                    # Add the cycle address information to the list
                    X_offset_addr.append(cycle_X)
                    Y_offset_addr.append(cycle_Y)
                    Z_offset_addr.append(cycle_Z)

                    latency += 1

                    # endregion

        # At the end as final step I add a stall for the first load cycle and the last store cycle where no computation is done

        X_offset_addr = X_offset_addr + [[]] + [[]]
        Y_offset_addr = Y_offset_addr + [[]] + [[]]
        Z_offset_addr_fetch = [[] for _ in range(len(X_offset_addr))]
        Z_offset_addr_store = [[]] + [[]] + Z_offset_addr

        # Now I turn the list into the actual accesses to memory using a function

        X_offset_addr = input_accesses_calculation(X_offset_addr)
        Y_offset_addr = input_accesses_calculation(Y_offset_addr)
        Z_offset_addr_fetch = input_accesses_calculation(Z_offset_addr_fetch)
        Z_offset_addr_store = output_accesses_calculation(Z_offset_addr_store)

        # FINAL LATENCY CALCULATION

        latency = latency + 2

        # BANDWIDTH CALCULATION

        Input_avg_bandwidth, Input_peak_bandwidth = input_bandwidth_calculation(X_offset_addr,
                                                                                Y_offset_addr,
                                                                                Z_offset_addr_fetch,
                                                                                In_data_size, Out_data_size,
                                                                                1,
                                                                                -1)
        Output_avg_bandwidth, Output_peak_bandwidth = output_bandwidth_calculation(Z_offset_addr_store,
                                                                                   Out_data_size)

        Combined_avg_bandwidth = Input_avg_bandwidth + Output_avg_bandwidth
        Combined_peak_bandwidth = Input_peak_bandwidth + Output_peak_bandwidth

        # REUSE DISTANCE CALCULATION

        X_reuse_distance = avg_reuse_distance(X_offset_addr)
        Y_reuse_distance = avg_reuse_distance(Y_offset_addr)
        Z_reuse_distance = 0

    else:
        raise ValueError(f"Unknown reuse policy: {reuse_policy}")

    return Combined_avg_bandwidth, 100, latency