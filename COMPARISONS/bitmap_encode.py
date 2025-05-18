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
