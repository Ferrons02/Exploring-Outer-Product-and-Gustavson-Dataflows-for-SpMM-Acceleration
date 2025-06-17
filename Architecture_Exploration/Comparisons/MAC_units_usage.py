from typing import List


def MAC_units_usage_gust(
        Y_offset_addr: List[List[int]],
        MACs_number: int,
) -> float:
    """
    Calculates the average usage percentage of MAC units, ignoring metadata addresses.

    Args:
        Y_offset_addr: list of lists; each sublist contains Y offsets.
        MACs_number: total number of available MAC units.
    Returns:
        avg_MAC_usage: float value (0–100) representing the average percentage
                       of MAC usage across batches.
    """

    usage_counts: List[int] = []

    for y_list in Y_offset_addr:

        # Total active elements for this batch
        usage_counts.append(len(y_list))

    # Compute average count per batch
    avg_count = sum(usage_counts) / (len(usage_counts)-2)

    # Scale by number of MAC units and convert to percentage
    avg_MAC_usage = (avg_count / MACs_number) * 100
    return avg_MAC_usage

def MAC_units_usage_outer(
        X_offset_addr: List[List[int]],
        Y_offset_addr: List[List[int]],
        MACs_number: int,
        metadata_max_addr: int
) -> float:
    """
    Calculates the average usage percentage of MAC units, ignoring metadata addresses.

    Args:
        X_offset_addr: list of lists; each sublist contains X offsets.
        Y_offset_addr: list of lists; each sublist contains Y offsets.
        MACs_number: total number of available MAC units.
        metadata_max_addr: any X offsets <= this value are considered metadata
                           and do not consume accelerator resources.

    Returns:
        avg_MAC_usage: float value (0–100) representing the average percentage
                       of MAC usage across batches.
    """
    # Ensure input lists have the same length and are not empty
    if len(X_offset_addr) != len(Y_offset_addr):
        raise ValueError("X_offset_addr and Y_offset_addr must have the same length")
    if not X_offset_addr:
        raise ValueError("Input lists cannot be empty")

    usage_counts: List[int] = []

    for x_list, y_list in zip(X_offset_addr, Y_offset_addr):
        # Filter out metadata addresses in X
        real_x = [x for x in x_list if x >= metadata_max_addr]
        # All Y offsets always count
        real_y = y_list

        # Total active elements for this batch
        usage_counts.append(len(real_y) * len(real_x))

    # Compute average count per batch
    avg_count = sum(usage_counts) / (len(usage_counts)-2)

    # Scale by number of MAC units and convert to percentage
    avg_MAC_usage = (avg_count / MACs_number) * 100
    return avg_MAC_usage

