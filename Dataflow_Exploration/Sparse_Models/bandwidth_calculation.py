import math

def input_bandwidth_calculation(
        X_offsets: list[list[int]],
        Y_offsets: list[list[int]],
        Z_offsets: list[list[int]],
        input_data_size: int,
        output_data_size : int,
        bitmap_chunk_size: int,
        bitmap_max_address: int
) -> tuple[float, int]:
    """
    Given two equally‐long lists of integer‐lists (X_offsets, Y_offsets),
    plus three scalars:
      - input_data_size: weight for Y and (conditionally) for X
      - bitmap_chunk_size: alternate weight for X when no X element exceeds bitmap_max_address
      - bitmap_max_address: threshold for choosing X's weight

    For each index i compute:
      wX = input_data_size if any(x > bitmap_max_address for x in X_offsets[i])
           else bitmap_chunk_size
      weighted_sum_i = (number_of_elements_in_X_i) * wX
                     + (number_of_elements_in_Y_i) * input_data_size

    Returns:
      (mean_weighted_bytes_per_cycle, max_weighted_bytes_per_cycle)
      (each value divided by 8 to convert bits→bytes)
    """

    weighted_sums = []
    n = len(X_offsets)

    for i in range(n):
        X_i = X_offsets[i]
        Y_i = Y_offsets[i]
        Z_i = Z_offsets[i]

        # Computing wX
        if not X_i:
            wX = 0
        else:
            if any(x >= bitmap_max_address for x in X_i):
                wX = input_data_size
            else:
                wX_bit = min(max(X_i) + bitmap_chunk_size, bitmap_max_address) - max(X_i)
                wX = wX_bit * 8

        # Compute weighted contributions by count of elements
        total_bits = (
                len(X_i) * wX
                + len(Y_i) * input_data_size
                + len(Z_i) * output_data_size
        )
        weighted_sums.append(total_bits)

    # Convert to bytes/cycle
    if n-2 == 0:
        mean_bytes = 0
    else:
        mean_bytes = (sum(weighted_sums) / (n - 2)) / 8 if n > 0 else 0.0
    max_bytes = (max(weighted_sums) / 8) if weighted_sums else 0

    return mean_bytes, max_bytes

def output_bandwidth_calculation(
    Z_offsets: list[list[int]],
    output_data_size: int
) -> tuple[float, float]:
    """
    Given a list of lists Z_offsets and a scalar weight output_data_size,
    computes for each sublist Z_i:
        weighted_i = len(Z_i) * output_data_size

    Returns:
        (mean_weighted, max_weighted)
    where:
        mean_weighted = average of all weighted_i values
        max_weighted  = maximum of all weighted_i values
    """
    n = len(Z_offsets) - 2
    if n == 0:
        return 0.0, 0

    # Compute weighted totals per sublist
    weighted = [len(sub) * output_data_size for sub in Z_offsets]

    mean_weighted = sum(weighted) / (8 * n)
    max_weighted  = max(weighted) / 8

    return mean_weighted, max_weighted


