def input_accesses_calculation(cycles):
    """
    cycles: list of sublists, each representing the elements (addresses)
            held by the accelerator at the end of one cycle.
    Returns a list of sublists `stores`, where stores[i] contains exactly
    those elements from cycles[i] that must be written back to memory
    in cycle i under a “first‐occurrence” policy:
      - an element is stored in the first cycle where it appears (or re‐appears
        after having been absent), and then not stored again until it vanishes
        and re‐appears in a later cycle.
    """
    n = len(cycles)
    stores = [[] for _ in range(n)]
    prev_set = set()  # nothing in buffer before cycle 0

    for i, curr in enumerate(cycles):
        curr_set = set(curr)
        # for each element in this cycle...
        for x in curr:
            # ...store it only if it was not already present in the previous cycle
            if x not in prev_set:
                stores[i].append(x)
        # update prev_set to the contents of this cycle
        prev_set = curr_set

    return stores

def output_accesses_calculation(cycles):
    """
    cycles: list of sublists, each representing the elements (addresses)
            held by the accelerator at the end of one cycle.
    Returns a list of sublists `stores`, where stores[i] contains exactly
    those elements from cycles[i] that must be written back to memory
    in cycle i. An element is stored in cycle i if and only if:
      - it appears in cycles[i], and
      - it does NOT appear in cycles[i+1] (or i == last cycle).
    This automatically keeps only the *last* occurrence of each element
    within any run of consecutive cycles where it is preserved, and if
    the same element appears again later, it will be stored again at the
    end of that new run.
    """
    n = len(cycles)
    stores = [[] for _ in range(n)]
    for i, curr in enumerate(cycles):
        next_set = set(cycles[i+1]) if i < n-1 else set()
        # for each element in this cycle...
        for x in curr:
            # ...store it only if it won't appear in the very next cycle
            if x not in next_set:
                stores[i].append(x)
    return stores



