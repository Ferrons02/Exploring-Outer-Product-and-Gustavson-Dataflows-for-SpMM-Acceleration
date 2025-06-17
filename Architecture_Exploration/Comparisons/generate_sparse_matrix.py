import random

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
        sparsity = 1
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
