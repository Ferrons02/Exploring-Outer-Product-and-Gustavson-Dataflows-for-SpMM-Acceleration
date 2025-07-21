import os
import math
import random
import argparse

def generate_sparse_matrix(height: int, width: int, sparsity: float, data_size: int) -> list[list[str]]:
    """
    Generates a sparse matrix of dimensions height x width, with the specified sparsity,
    containing random integers stored in binary encoding of length data_size.

    :param height: number of rows of the matrix
    :param width: number of columns of the matrix
    :param sparsity: fraction of elements that should be zero (between 0 and 1)
    :param data_size: number of bits for the binary representation of each value
    :return: matrix (list of lists) of binary strings
    """
    # Basic validations
    if not (0.0 <= sparsity <= 1.0):
        raise ValueError("sparsity must be a number between 0 and 1")
    if height <= 0 or width <= 0:
        raise ValueError("height and width must be positive integers")
    if data_size <= 0:
        raise ValueError("data_size must be a positive integer")

    total_elements = height * width
    # Number of zero elements to place
    zero_count = int(total_elements * sparsity)

    # Generate all possible positions and sample those to be zeroed
    all_positions = [(r, c) for r in range(height) for c in range(width)]
    zero_positions = set(random.sample(all_positions, zero_count))

    # Maximum value representable with data_size bits
    max_value = (1 << data_size) - 1

    matrix: list[list[str]] = []
    for r in range(height):
        row: list[str] = []
        for c in range(width):
            if (r, c) in zero_positions:
                # zero element: string of zeros of the specified length
                row.append('0' * data_size)
            else:
                # generate a random integer between 1 and max_value and encode it in binary with data_size bits
                val = random.randint(1, max_value)
                binary_str = format(val, f'0{data_size}b')
                row.append(binary_str)
        matrix.append(row)

    return matrix

def bitmap_encode_row_major(matrix: list[list[str]]) -> tuple[list[str], list[int]]:
    """
    Encodes a sparse matrix in bitmap format.

    :param matrix: 2D list of binary-encoded strings
    :return: tuple containing:
             - list of contiguous non-zero elements (binary strings)
             - list of mask bits (0 for zero entries, 1 for non-zero) in row-major order
    """
    values = []
    mask = []
    zero_pattern = None
    # Determine zero pattern length from first element
    if matrix and matrix[0]:
        zero_pattern = '0' * len(matrix[0][0])
    for row in matrix:
        for elem in row:
            if elem == zero_pattern:
                mask.append(0)
            else:
                mask.append(1)
                values.append(elem)
    return values, mask

def bitmap_encode_column_major(matrix: list[list[str]]) -> tuple[list[str], list[int]]:
    """
    Encodes a sparse matrix in bitmap format (column-major order).

    :param matrix: 2D list of binary-encoded strings
    :return: tuple containing:
             - list of contiguous non-zero elements (binary strings)
             - list of mask bits (0 for zero entries, 1 for non-zero) in column-major order
    """
    if not matrix or not matrix[0]:
        return [], []

    rows = len(matrix)
    cols = len(matrix[0])
    zero_pattern = '0' * len(matrix[0][0])

    values = []
    mask = []

    for col in range(cols):
        for row in range(rows):
            elem = matrix[row][col]
            if elem == zero_pattern:
                mask.append(0)
            else:
                mask.append(1)
                values.append(elem)

    return values, mask

def generate_stimuli_streamer(
    mp: str,
    meta_chunk_size: int,
    x_item_size: int,
    y_item_size: int,
    z_item_size: int,
    y_block_size: int,
    x_base_address: int,
    y_base_address: int,
    z_base_address: int,
    x_columns: int,
    y_columns: int,
    x_rows: int,
    y_rows: int,
    x_sparsity : float,
    output_dir: str
):
    
    bw = int(mp) * 32
    x_elems_per_cycle = math.floor(bw / x_item_size)

    z_count = 0

    x_item_size_bytes = x_item_size / 8
    y_item_size_bytes = y_item_size / 8

    initial_memory = [0] * 20000000
    x_total_tcdm_loads = 0
    x_total_loads = 0
    y_total_loads = 0

    y_sparsity = 0

    X = generate_sparse_matrix(x_rows, x_columns, x_sparsity, x_item_size)
    Y = generate_sparse_matrix(y_rows, y_columns, y_sparsity, y_item_size)

    # Conversion of X matrix into Bitmap representation
    X_nonzero_values, X_mask = bitmap_encode_row_major(X)

    # Initialization of lists of data usage
    X_elems_list = []
    Y_elems_list = []
    Z_elems_list = []

    # build a vector as long as the mask where each nonzero element has been substituted by its position in the dense vector
    X_value_indices = []
    val_idx = 0
    for bit in X_mask:
        if bit == 1:
            X_value_indices.append(val_idx)
            val_idx += 1
        else:
            X_value_indices.append(None)

    # Number of tiles for Y
    Y_column_blocks = math.ceil(y_columns / y_block_size)

    for X_row in range(x_rows):

        for Y_column_block in range(Y_column_blocks):

            start_Y = Y_column_block * y_block_size
            end_Y = min(start_Y + y_block_size, y_columns)

            # Load metadata chunk

            meta_iters = math.ceil(x_columns / meta_chunk_size)

            for meta_chunk in range(meta_iters):

                # Load a metadata chunk and compute global k indices where X_mask[k] == 1 inside this row of X
                start_meta = X_row * x_columns + meta_chunk_size * meta_chunk
                end_meta = min(start_meta + meta_chunk_size, (
                        X_row + 1) * x_columns)  # only load the metadata chunk elements if they are from the same row
                X_meta_positions = [k for k in range(start_meta, end_meta) if
                                    X_mask[
                                        k] == 1]  # Keeps the row major indices of the nonzero X elements of X in the metadata block

                k_iters = math.ceil(len(X_meta_positions) / x_elems_per_cycle)

                # At each iteration of the inner loops I append to X and Y enough data to complete x_elems_per_cycle multiplication cycles
                for tile in range(k_iters):

                    start_X = tile * x_elems_per_cycle
                    end_X = min(start_X + x_elems_per_cycle, len(X_meta_positions))

                    # Take a slice of the meta positions
                    X_row_positions_tile = X_meta_positions[
                                           start_X:end_X]  # Keeps the indices of the nonzero elements of the row tile of X

                    # This will be loaded at once
                    X_tile = [X_nonzero_values[X_value_indices[k]] for k in X_row_positions_tile]
                    X_elems_list.append(X_tile)

                    # This will be loaded in multiple cycles (n rows to load means n cycles)
                    for k in X_row_positions_tile:
                        Y_elems_list.append([Y[k - X_row * x_columns][start_Y:end_Y]])

                    x_total_tcdm_loads += 1
                    x_total_loads += end_X - start_X 
                    y_total_loads += end_X - start_X

            # Store back
            for j in range(y_block_size):
                if j == 0 or j == y_block_size - 1:
                    Z_elems_list.append(format(z_count + 1, f'0{z_item_size}b'))
                else:
                    Z_elems_list.append('1' * z_item_size)
            z_count += 1

    # INITIAL MEMORY CREATION

    # Padding to meta
    if len(X_mask) % 32 != 0:
        padding_len = 32 - (len(X_mask) % 32)
        X_mask += [0] * padding_len

    num_meta_bytes = len(X_mask) // 8
    for byte_idx in range(num_meta_bytes):
        # collect 8 bits into a string
        bits = ''.join(
            str(X_mask[byte_idx * 8 + bit_offset])
            for bit_offset in range(8)
        )
        # convert the "01011011" into an integer and store it
        initial_memory[x_base_address + byte_idx] = int(bits, 2)
        
    # load X data (only non-zero values)
    x_data_start = x_base_address + num_meta_bytes
    for idx, val_bits in enumerate(X_nonzero_values):
        val_int    = int(val_bits, 2)
        byte_len   = int(x_item_size_bytes)
        byte_seq   = val_int.to_bytes(byte_len, 'big')
        base       = x_data_start + idx * byte_len
        for offset, b in enumerate(byte_seq):
            initial_memory[base + offset] = b

    # load Y data (dense row-major)
    for r in range(y_rows):
        for c in range(y_columns):
            val_bits = Y[r][c]
            val_int = int(val_bits, 2)
            byte_len = int(y_item_size_bytes)
            byte_seq = val_int.to_bytes(byte_len, 'big')
            addr = y_base_address + ((r * y_columns + c) * byte_len)
            for offset, b in enumerate(byte_seq):
                initial_memory[addr + offset] = b

    # DATA CONSTANTS OUTPUT
    constants_path = os.path.join(output_dir, "data_constants.txt")
    with open(constants_path, "w") as f:
        f.write(f"{x_total_loads} {y_total_loads} {x_total_tcdm_loads}")

    # INITIAL MEMORY OUTPUT
    mem_path = os.path.join(output_dir, "initial_memory.txt")
    with open(mem_path, "w") as mf:
        for idx, byte in enumerate(initial_memory):
            mf.write(f"{byte:08b}")
            if (idx + 1) % 4 == 0:
                mf.write(" ")

    # X ORDER OUTPUT
    path = os.path.join(output_dir, "x_order.txt")
    with open(path, "w") as f:
        zero_str = "0" * x_item_size
        for row in X_elems_list:
            elems = (row[:x_elems_per_cycle] + [0] * (x_elems_per_cycle - len(row)))[::-1]
            word_strs = [
                f"{(int(e, 2) if isinstance(e, str) else e):0{x_item_size}b}"
                for e in elems
            ]
            for word in reversed(word_strs):
                if word != zero_str:
                    f.write(word + "\n")

    # Y ORDER OUTPUT
    path = os.path.join(output_dir, "y_order.txt")
    with open(path, "w") as f:
        for row in Y_elems_list:
            for sub in row:
                elems = (sub[:y_block_size] + [0] * (y_block_size - len(sub)))[::-1]
                word_strs = [f"{(int(e, 2) if isinstance(e, str) else e):0{y_item_size}b}" for e in elems]
                f.write("".join(word_strs) + "\n")

    # Z ORDER OUTPUT
    path = os.path.join(output_dir, "z_order.txt")
    with open(path, "w") as f:
        for i in range(0, len(Z_elems_list), y_block_size):
            group = Z_elems_list[i:i + y_block_size]
            line = ""
            for item in group:
                bitstr = item.zfill(z_item_size) if isinstance(item, str) else format(item, f'0{z_item_size}b')
                line += bitstr
            f.write(line + "\n")


    return X, Y

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="generate_stimuli_streamer",
        description="Generate stimulus files for the streamer."
    )
    parser.add_argument("--mp",                type=int,   required=True)
    parser.add_argument("--meta_chunk_size",   type=int,   required=True)
    parser.add_argument("--x_item_size",       type=int,   required=True)
    parser.add_argument("--y_item_size",       type=int,   required=True)
    parser.add_argument("--z_item_size",       type=int,   required=True)
    parser.add_argument("--y_block_size",      type=int,   required=True)
    # For base addresses, accept either hexadecimal (0x...) or decimal notation
    parser.add_argument("--x_base_address",    type=lambda s: int(s, 0), required=True)
    parser.add_argument("--y_base_address",    type=lambda s: int(s, 0), required=True)
    parser.add_argument("--z_base_address",    type=lambda s: int(s, 0), required=True)
    parser.add_argument("--x_columns",         type=int,   required=True)
    parser.add_argument("--y_columns",         type=int,   required=True)
    parser.add_argument("--x_rows",            type=int,   required=True)
    parser.add_argument("--y_rows",            type=int,   required=True)
    parser.add_argument("--x_sparsity",        type=float, required=True)
    parser.add_argument("--output_dir",        type=str,   required=True)
    return parser.parse_args()

def main():
    args = parse_args()
    X, Y = generate_stimuli_streamer(
        mp               = args.mp,
        meta_chunk_size  = args.meta_chunk_size,
        x_item_size      = args.x_item_size,
        y_item_size      = args.y_item_size,
        z_item_size      = args.z_item_size,
        y_block_size     = args.y_block_size,
        x_base_address   = args.x_base_address,
        y_base_address   = args.y_base_address,
        z_base_address   = args.z_base_address,
        x_columns        = args.x_columns,
        y_columns        = args.y_columns,
        x_rows           = args.x_rows,
        y_rows           = args.y_rows,
        x_sparsity       = args.x_sparsity,      
        output_dir       = args.output_dir
    )

if __name__ == "__main__":
    main()