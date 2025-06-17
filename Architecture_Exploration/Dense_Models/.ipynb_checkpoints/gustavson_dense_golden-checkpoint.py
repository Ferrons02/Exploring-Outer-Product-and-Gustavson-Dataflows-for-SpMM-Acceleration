from generate_sparse_matrix import generate_sparse_matrix
from accesses_calculation import input_accesses_calculation
from accesses_calculation import output_accesses_calculation
from bandwidth_calculation import input_bandwidth_calculation
from bandwidth_calculation import output_bandwidth_calculation
from avg_reuse_distance import avg_reuse_distance
import math
import matplotlib.pyplot as plt
import numpy as np

def gustavson_dense_golden(reuse_policy, X_elem_size, Y_elem_size):
    # Matrix generation
    In_data_size = 8  # has to be a multiple of 8 such that the memory locations are not segmented
    Out_data_size = 24  # has to be a multiple of 8 such that the memory locations are not segmented

    X_rows, X_columns, X_sparsity = 8, 8, 0.1  # X_columns = Y_rows
    Y_rows, Y_columns, Y_sparsity = 8, 8, 0.1

    X = generate_sparse_matrix(X_rows, X_columns, X_sparsity, In_data_size)
    Y = generate_sparse_matrix(Y_rows, Y_columns, Y_sparsity, In_data_size)
    Z = [['0' * Out_data_size for _ in range(Y_columns)] for _ in range(X_rows)]

    # initialization of vectors of data usage
    X_offset_addr = []
    Y_offset_addr = []
    Z_offset_addr = []

    latency = 0

    # Number of tiles for X and Y
    k_iters = math.ceil(X_columns / X_elem_size)
    Y_column_blocks = math.ceil(Y_columns / Y_elem_size)

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

                        #region COMPUTING THE RESULT FOR THE SPECIFIC CYCLE

                        # Multiply-accumulate
                        for x_idx, x_bin in enumerate(X_tile):
                            x_val = int(x_bin, 2)
                            for y_idx in range(end_Y - start_Y):
                                y_val = int(Y_tile[x_idx][y_idx], 2)
                                acc = int(out_buffer[y_idx], 2)
                                acc += x_val * y_val
                                acc &= (1 << Out_data_size) - 1
                                out_buffer[y_idx] = format(acc, f'0{Out_data_size}b')

                        #endregion

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

        Input_avg_bandwidth, Input_peak_bandwidth = input_bandwidth_calculation(X_offset_addr, Y_offset_addr, Z_offset_addr_fetch,
                                                                                In_data_size, Out_data_size, 1,
                                                                                -1)
        Output_avg_bandwidth, Output_peak_bandwidth = output_bandwidth_calculation(Z_offset_addr_store, Out_data_size)

        Combined_avg_bandwidth = Input_avg_bandwidth + Output_avg_bandwidth
        Combined_peak_bandwidth = Input_peak_bandwidth + Output_peak_bandwidth

        # REUSE DISTANCE CALCULATION

        X_reuse_distance = 0
        Y_reuse_distance = avg_reuse_distance(Y_offset_addr)
        Z_reuse_distance = avg_reuse_distance(Z_offset_addr_store)

        #region PRINTING AND DATA ITEMS PLOT

        print("Reuse policy: X\n")
        print(f"Latency: {latency:.1f} cycles")
        print(f"Average Input bandwidth: {Input_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Input bandwidth: {Input_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"Average Output bandwidth: {Output_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Output bandwidth: {Output_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"Average Combined bandwidth: {Combined_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Combined bandwidth: {Combined_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"X Reuse Distance (cycles): {X_reuse_distance:.1f}")
        print(f"Y Reuse Distance (cycles): {Y_reuse_distance:.1f}")
        print(f"Z Reuse Distance (cycles): {Z_reuse_distance:.1f}\n")

        indices = [(X_offset_addr, 'Offset address', 'X elements fetching', 'blue', 'o', X_elem_size,
                    X_elem_size * (In_data_size / 8)),
                    (Y_offset_addr, 'Offset address', 'Y elements fetching', 'green', 'o', Y_elem_size,
                    (Y_rows * (In_data_size / 8))),
                    (Z_offset_addr_store, 'Offset address', 'Z elements storing', 'red', 'o', X_elem_size,
                    X_elem_size * (Out_data_size / 8))]

        for vals, y_label, label, color, marker, x_spacing, y_spacing in indices:
            plt.figure(figsize=(6, 4))

            # Calculate x values based on the number of cycles (use the range of indices for x-axis)
            x = np.arange(1, len(vals) + 2)  # x will range from 1 to the number of cycles in vals

            for i, cycle in enumerate(vals):
                plt.plot([i + 1] * len(cycle), cycle, color=color, marker=marker, linestyle='None')

            plt.xlabel('Cycle')
            plt.ylabel(y_label)
            plt.title(f'{label}')

            # Set tick positions with customized offset and spacing for x-axis
            plt.xticks(np.arange(min(x), max(x) + 1, x_spacing))

            # Set tick positions for y-axis with custom offset and spacing
            flattened_vals = [item for sublist in vals for item in sublist]
            plt.yticks(np.arange(int(min(flattened_vals)), int(max(flattened_vals)) + 1, y_spacing))

            plt.grid(True)
            plt.show()

        #endregion

    elif reuse_policy == "Y":

        for Y_column_block in range(Y_column_blocks):
            for tile in range(k_iters):

                start_Y = Y_column_block * Y_elem_size
                end_Y = min(start_Y + Y_elem_size, Y_columns)
                start_X = tile * X_elem_size
                end_X = min(start_X + X_elem_size, X_columns)

                #Load tile of Y
                Y_tile = [Y[k][start_Y:end_Y] for k in range(start_X, end_X)]

                for X_row in range(X_rows):

                    # Load tile of X
                    X_tile = X[X_row][start_X:end_X]

                    #Load output buffer content
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

                    #endregion

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

        # region PRINTING AND DATA ITEMS PLOT

        print("Reuse policy: Y\n")
        print(f"Latency: {latency:.1f} cycles")
        print(f"Average Input bandwidth: {Input_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Input bandwidth: {Input_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"Average Output bandwidth: {Output_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Output bandwidth: {Output_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"Average Combined bandwidth: {Combined_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Combined bandwidth: {Combined_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"X Reuse Distance (cycles): {X_reuse_distance:.1f}")
        print(f"Y Reuse Distance (cycles): {Y_reuse_distance:.1f}")
        print(f"Z Reuse Distance (cycles): {Z_reuse_distance:.1f}\n")

        indices = [(X_offset_addr, 'Offset address', 'X elements fetching', 'blue', 'o', X_elem_size,
                    X_elem_size * (In_data_size / 8)),
                   (Y_offset_addr, 'Offset address', 'Y elements fetching', 'green', 'o', Y_elem_size,
                    (Y_rows * (In_data_size / 8))),
                   (Z_offset_addr_store, 'Offset address', 'Z elements storing', 'red', 'o', X_elem_size,
                    X_elem_size * (Out_data_size / 8))]

        for vals, y_label, label, color, marker, x_spacing, y_spacing in indices:
            plt.figure(figsize=(6, 4))

            # Calculate x values based on the number of cycles (use the range of indices for x-axis)
            x = np.arange(1, len(vals) + 2)  # x will range from 1 to the number of cycles in vals

            for i, cycle in enumerate(vals):
                plt.plot([i + 1] * len(cycle), cycle, color=color, marker=marker, linestyle='None')

            plt.xlabel('Cycle')
            plt.ylabel(y_label)
            plt.title(f'{label}')

            # Set tick positions with customized offset and spacing for x-axis
            plt.xticks(np.arange(min(x), max(x) + 1, x_spacing))

            # Set tick positions for y-axis with custom offset and spacing
            flattened_vals = [item for sublist in vals for item in sublist]
            plt.yticks(np.arange(int(min(flattened_vals)), int(max(flattened_vals)) + 1, y_spacing))

            plt.grid(True)
            plt.show()

        # endregion

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

                    #region COMPUTING THE RESULT FOR THE SPECIFIC CYCLE
                    
                    for x_idx, x_bin in enumerate(X_tile):
                        x_val = int(x_bin, 2)
                        for y_idx in range(end_Y - start_Y):
                            y_val = int(Y_tile[x_idx][y_idx], 2)
                            acc = int(out_buffer[y_idx], 2)
                            acc += x_val * y_val
                            acc &= (1 << Out_data_size) - 1
                            out_buffer[y_idx] = format(acc, f'0{Out_data_size}b')

                    #endregion

                    Z[X_row][start_Y:end_Y] = out_buffer

                    #region APPENDING DATA ITEMS INFORMATION

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

        # region PRINTING AND DATA ITEMS PLOT

        print("Reuse policy: Z\n")
        print(f"Latency: {latency:.1f} cycles")
        print(f"Average Input bandwidth: {Input_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Input bandwidth: {Input_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"Average Output bandwidth: {Output_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Output bandwidth: {Output_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"Average Combined bandwidth: {Combined_avg_bandwidth:.1f} Bytes/ cycle")
        print(f"Peak Combined bandwidth: {Combined_peak_bandwidth:.1f} Bytes/ cycle")
        print(f"X Reuse Distance (cycles): {X_reuse_distance:.1f}")
        print(f"Y Reuse Distance (cycles): {Y_reuse_distance:.1f}")
        print(f"Z Reuse Distance (cycles): {Z_reuse_distance:.1f}\n")

        indices = [(X_offset_addr, 'Offset address', 'X elements fetching', 'blue', 'o', X_elem_size,
                    X_elem_size * (In_data_size / 8)),
                   (Y_offset_addr, 'Offset address', 'Y elements fetching', 'green', 'o', Y_elem_size,
                    (Y_rows * (In_data_size / 8))),
                   (Z_offset_addr_store, 'Offset address', 'Z elements storing', 'red', 'o', X_elem_size,
                    X_elem_size * (Out_data_size / 8))]

        for vals, y_label, label, color, marker, x_spacing, y_spacing in indices:
            plt.figure(figsize=(6, 4))

            # Calculate x values based on the number of cycles (use the range of indices for x-axis)
            x = np.arange(1, len(vals) + 2)  # x will range from 1 to the number of cycles in vals

            for i, cycle in enumerate(vals):
                plt.plot([i + 1] * len(cycle), cycle, color=color, marker=marker, linestyle='None')

            plt.xlabel('Cycle')
            plt.ylabel(y_label)
            plt.title(f'{label}')

            # Set tick positions with customized offset and spacing for x-axis
            plt.xticks(np.arange(min(x), max(x) + 1, x_spacing))

            # Set tick positions for y-axis with custom offset and spacing
            flattened_vals = [item for sublist in vals for item in sublist]
            plt.yticks(np.arange(int(min(flattened_vals)), int(max(flattened_vals)) + 1, y_spacing))

            plt.grid(True)
            plt.show()

        # endregion

    else:
        raise ValueError(f"Unknown reuse policy: {reuse_policy}")

    return X, Y, Z

# FUNCTION INVOKING

# Parameters and execution
reuse_policy = "X"
X_elem_size = 8
Y_elem_size = 8

X_mat, Y_mat, Z_result = gustavson_dense_golden(reuse_policy, X_elem_size, Y_elem_size)

# Output

print("Matrix X:")
for row in X_mat:
    print(row)

print("\nMatrix Y:")
for row in Y_mat:
    print(row)

print("\nResult Z:")
for row in Z_result:
    print(row)