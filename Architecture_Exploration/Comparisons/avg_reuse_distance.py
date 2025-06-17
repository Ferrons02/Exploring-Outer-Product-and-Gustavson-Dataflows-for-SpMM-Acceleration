from collections import defaultdict
import itertools

def avg_reuse_distance(list_of_lists):
    # Check if there are enough sublists to process (at least 3 to exclude first and last)
    if len(list_of_lists) < 3:
        return "Inf"

    # Create a dictionary to store the indices of each identical non-empty sublist
    index_map = defaultdict(list)

    # Populate the dictionary, skipping empty sublists
    for i in range(1, len(list_of_lists) - 1):
        if list_of_lists[i]:  # skip empty sublists
            key = tuple(list_of_lists[i])
            index_map[key].append(i)

    # List to store all distances between pairs of indices
    distances = []

    # For each group of identical sublists
    for indices in index_map.values():
        if len(indices) > 1:
            for pair in itertools.combinations(indices, 2):
                distances.append(abs(pair[1] - pair[0]))

    if not distances:
        return -1
    else:
        return sum(distances) / len(distances) - 1
