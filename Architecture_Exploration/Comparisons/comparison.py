from gustavson_sparse_golden import gustavson_sparse_golden
from outer_product_sparse_golden import outer_product_sparse_golden
from gustavson_dense_golden import gustavson_dense_golden
from outer_product_dense_golden import outer_product_dense_golden
import matplotlib.pyplot as plt
import numpy as np

def sweep_and_plot(X_elem_range, Y_elem_range, Sparsity_range, X_columns_range, X_rows_range, Y_columns_range):

    X_elem_size = 4
    Y_elem_size = 4
    Sparsity = 0.5
    X_rows = 10
    X_columns = 10
    Y_rows = 10
    Y_columns = 10

    # prepare empty storage for sparse
    S_avg = [[] for _ in range(6)]
    S_usage = [[] for _ in range(6)]
    S_lat = [[] for _ in range(6)]

    # sweep X_elem_size
    start, stop, step = X_elem_range
    param_range = list(range(start, stop + step, step))

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping X_elem_size for sparse dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson sparse X, Y, Z
            a0, p0, l0 = gustavson_sparse_golden("X", sweep_var, Y_elem_size, Sparsity,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_sparse_golden("Y", sweep_var, Y_elem_size, Sparsity,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_sparse_golden("Z", sweep_var, Y_elem_size, Sparsity,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            # OuterProd sparse X, Y, Z
            a3, p3, l3 = outer_product_sparse_golden("X", sweep_var, Y_elem_size, Sparsity,
                                                     X_rows, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_sparse_golden("Y", sweep_var, Y_elem_size, Sparsity,
                                                     X_rows, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_sparse_golden("Z", sweep_var, Y_elem_size, Sparsity,
                                                     X_rows, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        # media su 10 run
        for i in range(6):
            S_avg[i].append(temp_avg[i] / 10)
            S_usage[i].append(temp_usage[i] / 10)
            S_lat[i].append(temp_lat[i] / 10)

    # --- DENSE STORAGE per 6 dataflow ---
    D_avg = [[] for _ in range(6)]
    D_usage = [[] for _ in range(6)]
    D_lat = [[] for _ in range(6)]

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping X_elem_size for dense dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson dense X, Y, Z
            a0, p0, l0 = gustavson_dense_golden("X", sweep_var, Y_elem_size,
                                                X_rows, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_dense_golden("Y", sweep_var, Y_elem_size,
                                                X_rows, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_dense_golden("Z", sweep_var, Y_elem_size,
                                                X_rows, X_columns, Y_rows, Y_columns)
            # OuterProd dense X, Y, Z
            a3, p3, l3 = outer_product_dense_golden("X", sweep_var, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_dense_golden("Y", sweep_var, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_dense_golden("Z", sweep_var, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        for i in range(6):
            D_avg[i].append(temp_avg[i] / 10)
            D_usage[i].append(temp_usage[i] / 10)
            D_lat[i].append(temp_lat[i] / 10)

    # --- PLOTTING ---
    titles = ['Avg BW', 'Avg Utilization', 'Latency']
    ylabels = ['Average BW (bytes)', 'Avg Utilization (%)', 'Latency (cycles)']
    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']
    labels_S = [
        'S Gustavson X', 'S Gustavson Y', 'S Gustavson Z',
        'S OuterProd X', 'S OuterProd Y', 'S OuterProd Z'
    ]
    labels_D = [
        'D Gustavson X', 'D Gustavson Y', 'D Gustavson Z',
        'D OuterProd X', 'D OuterProd Y', 'D OuterProd Z'
    ]

    for i, (S_list, D_list, title, ylabel) in enumerate(zip(
            [S_avg, S_usage, S_lat],
            [D_avg, D_usage, D_lat],
            titles, ylabels)):

        plt.figure()
        x = np.array(param_range)
        # sparse (dashed)
        for j in range(6):
            plt.plot(x, S_list[j], color=colors[j],
                     linestyle='--', label=labels_S[j])
        # dense (solid)
        for j in range(6):
            plt.plot(x, D_list[j], color=colors[j],
                     linestyle='-', label=labels_D[j])

        plt.title(title)
        plt.xlabel('Size of the tile of X')
        plt.ylabel(ylabel)
        plt.legend()
        plt.grid(True)
        plt.xticks(np.arange(min(x), max(x) + 1, step*2))
        plt.xlim(min(x), max(x))

        filename = f"X_elem_size_{title.replace(' ', '_')}.png"
        plt.savefig(filename, transparent=True, bbox_inches='tight', dpi=300)
        plt.close()

    # prepare empty storage for sparse
    S_avg = [[] for _ in range(6)]
    S_usage = [[] for _ in range(6)]
    S_lat = [[] for _ in range(6)]

    start, stop, step = Y_elem_range
    param_range = list(range(start, stop + step, step))

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping Y_elem_size for sparse dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson sparse X, Y, Z
            a0, p0, l0 = gustavson_sparse_golden("X", X_elem_size, sweep_var, Sparsity,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_sparse_golden("Y", X_elem_size, sweep_var, Sparsity,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_sparse_golden("Z", X_elem_size, sweep_var, Sparsity,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            # OuterProd sparse X, Y, Z
            a3, p3, l3 = outer_product_sparse_golden("X", X_elem_size, sweep_var, Sparsity,
                                                     X_rows, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_sparse_golden("Y", X_elem_size, sweep_var, Sparsity,
                                                     X_rows, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_sparse_golden("Z", X_elem_size, sweep_var, Sparsity,
                                                     X_rows, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        # media su 10 run
        for i in range(6):
            S_avg[i].append(temp_avg[i] / 10)
            S_usage[i].append(temp_usage[i] / 10)
            S_lat[i].append(temp_lat[i] / 10)

    # --- DENSE STORAGE per 6 dataflow ---
    D_avg = [[] for _ in range(6)]
    D_usage = [[] for _ in range(6)]
    D_lat = [[] for _ in range(6)]

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping Y_elem_size for dense dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson dense X, Y, Z
            a0, p0, l0 = gustavson_dense_golden("X", X_elem_size, sweep_var,
                                                X_rows, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_dense_golden("Y", X_elem_size, sweep_var,
                                                X_rows, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_dense_golden("Z", X_elem_size, sweep_var,
                                                X_rows, X_columns, Y_rows, Y_columns)
            # OuterProd dense X, Y, Z
            a3, p3, l3 = outer_product_dense_golden("X", X_elem_size, sweep_var,
                                                    X_rows, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_dense_golden("Y", X_elem_size, sweep_var,
                                                    X_rows, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_dense_golden("Z", X_elem_size, sweep_var,
                                                    X_rows, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        for i in range(6):
            D_avg[i].append(temp_avg[i] / 10)
            D_usage[i].append(temp_usage[i] / 10)
            D_lat[i].append(temp_lat[i] / 10)

    # --- PLOTTING ---
    titles = ['Avg BW', 'Avg Utilization', 'Latency']
    ylabels = ['Average BW (bytes)', 'Avg Utilization (%)', 'Latency (cycles)']
    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']
    labels_S = [
        'S Gustavson X', 'S Gustavson Y', 'S Gustavson Z',
        'S OuterProd X', 'S OuterProd Y', 'S OuterProd Z'
    ]
    labels_D = [
        'D Gustavson X', 'D Gustavson Y', 'D Gustavson Z',
        'D OuterProd X', 'D OuterProd Y', 'D OuterProd Z'
    ]

    for i, (S_list, D_list, title, ylabel) in enumerate(zip(
            [S_avg, S_usage, S_lat],
            [D_avg, D_usage, D_lat],
            titles, ylabels)):

        plt.figure()
        x = np.array(param_range)
        # sparse (dashed)
        for j in range(6):
            plt.plot(x, S_list[j], color=colors[j],
                     linestyle='--', label=labels_S[j])
        # dense (solid)
        for j in range(6):
            plt.plot(x, D_list[j], color=colors[j],
                     linestyle='-', label=labels_D[j])

        plt.title(title)
        plt.xlabel('Size of the tile of Y')
        plt.ylabel(ylabel)
        plt.legend()
        plt.grid(True)
        plt.xticks(np.arange(min(x), max(x) + 1, step*2))
        plt.xlim(min(x), max(x))

        filename = f"Y_elem_size_{title.replace(' ', '_')}.png"
        plt.savefig(filename, transparent=True, bbox_inches='tight', dpi=300)
        plt.close()

    # prepare empty storage for sparse
    S_avg = [[] for _ in range(6)]
    S_usage = [[] for _ in range(6)]
    S_lat = [[] for _ in range(6)]

    # sweep Sparsity
    start, stop, step = Sparsity_range
    param_range = np.arange(start, stop + 1e-9, step)

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping Sparsity for sparse dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson sparse X, Y, Z
            a0, p0, l0 = gustavson_sparse_golden("X", X_elem_size, Y_elem_size, sweep_var,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_sparse_golden("Y", X_elem_size, Y_elem_size, sweep_var,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_sparse_golden("Z", X_elem_size, Y_elem_size, sweep_var,
                                                 X_rows, X_columns, Y_rows, Y_columns)
            # OuterProd sparse X, Y, Z
            a3, p3, l3 = outer_product_sparse_golden("X", X_elem_size, Y_elem_size, sweep_var,
                                                     X_rows, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_sparse_golden("Y", X_elem_size, Y_elem_size, sweep_var,
                                                     X_rows, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_sparse_golden("Z", X_elem_size, Y_elem_size, sweep_var,
                                                     X_rows, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        # media su 10 run
        for i in range(6):
            S_avg[i].append(temp_avg[i] / 10)
            S_usage[i].append(temp_usage[i] / 10)
            S_lat[i].append(temp_lat[i] / 10)

    # --- DENSE STORAGE per 6 dataflow ---
    D_avg = [[] for _ in range(6)]
    D_usage = [[] for _ in range(6)]
    D_lat = [[] for _ in range(6)]

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping Sparsity for dense dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson dense X, Y, Z
            a0, p0, l0 = gustavson_dense_golden("X", X_elem_size, Y_elem_size,
                                                X_rows, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_dense_golden("Y", X_elem_size, Y_elem_size,
                                                X_rows, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_dense_golden("Z", X_elem_size, Y_elem_size,
                                                X_rows, X_columns, Y_rows, Y_columns)
            # OuterProd dense X, Y, Z
            a3, p3, l3 = outer_product_dense_golden("X", X_elem_size, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_dense_golden("Y", X_elem_size, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_dense_golden("Z", X_elem_size, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        for i in range(6):
            D_avg[i].append(temp_avg[i] / 10)
            D_usage[i].append(temp_usage[i] / 10)
            D_lat[i].append(temp_lat[i] / 10)

    # --- PLOTTING ---
    titles = ['Avg BW', 'Avg Utilization', 'Latency']
    ylabels = ['Average BW (bytes)', 'Avg Utilization (%)', 'Latency (cycles)']
    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']
    labels_S = [
        'S Gustavson X', 'S Gustavson Y', 'S Gustavson Z',
        'S OuterProd X', 'S OuterProd Y', 'S OuterProd Z'
    ]
    labels_D = [
        'D Gustavson X', 'D Gustavson Y', 'D Gustavson Z',
        'D OuterProd X', 'D OuterProd Y', 'D OuterProd Z'
    ]

    for i, (S_list, D_list, title, ylabel) in enumerate(zip(
            [S_avg, S_usage, S_lat],
            [D_avg, D_usage, D_lat],
            titles, ylabels)):

        plt.figure()
        x = np.array(param_range)
        # sparse (dashed)
        for j in range(6):
            plt.plot(x, S_list[j], color=colors[j],
                     linestyle='--', label=labels_S[j])
        # dense (solid)
        for j in range(6):
            plt.plot(x, D_list[j], color=colors[j],
                     linestyle='-', label=labels_D[j])

        plt.title(title)
        plt.xlabel('Sparsity')
        plt.ylabel(ylabel)
        plt.legend()
        plt.grid(True)
        plt.xticks(np.arange(min(x), max(x) + 1, step*2))
        plt.xlim(min(x), max(x))

        filename = f"Sparsity_{title.replace(' ', '_')}.png"
        plt.savefig(filename, transparent=True, bbox_inches='tight', dpi=300)
        plt.close()

    # prepare empty storage for sparse
    S_avg = [[] for _ in range(6)]
    S_usage = [[] for _ in range(6)]
    S_lat = [[] for _ in range(6)]

    # Sweeping X_columns
    start, stop, step = X_columns_range
    param_range = list(range(start, stop + step, step))

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping X_columns for sparse dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson sparse X, Y, Z
            a0, p0, l0 = gustavson_sparse_golden("X", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, sweep_var, sweep_var, Y_columns)
            a1, p1, l1 = gustavson_sparse_golden("Y", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, sweep_var, sweep_var, Y_columns)
            a2, p2, l2 = gustavson_sparse_golden("Z", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, sweep_var, sweep_var, Y_columns)
            # OuterProd sparse X, Y, Z
            a3, p3, l3 = outer_product_sparse_golden("X", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, sweep_var, sweep_var, Y_columns)
            a4, p4, l4 = outer_product_sparse_golden("Y", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, sweep_var, sweep_var, Y_columns)
            a5, p5, l5 = outer_product_sparse_golden("Z", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, sweep_var, sweep_var, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        # media su 10 run
        for i in range(6):
            S_avg[i].append(temp_avg[i] / 10)
            S_usage[i].append(temp_usage[i] / 10)
            S_lat[i].append(temp_lat[i] / 10)

    # --- DENSE STORAGE per 6 dataflow ---
    D_avg = [[] for _ in range(6)]
    D_usage = [[] for _ in range(6)]
    D_lat = [[] for _ in range(6)]

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping X_columns for dense dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson dense X, Y, Z
            a0, p0, l0 = gustavson_dense_golden("X", X_elem_size, Y_elem_size,
                                                X_rows, sweep_var, sweep_var, Y_columns)
            a1, p1, l1 = gustavson_dense_golden("Y", X_elem_size, Y_elem_size,
                                                X_rows, sweep_var, sweep_var, Y_columns)
            a2, p2, l2 = gustavson_dense_golden("Z", X_elem_size, Y_elem_size,
                                                X_rows, sweep_var, sweep_var, Y_columns)
            # OuterProd dense X, Y, Z
            a3, p3, l3 = outer_product_dense_golden("X", X_elem_size, Y_elem_size,
                                                X_rows, sweep_var, sweep_var, Y_columns)
            a4, p4, l4 = outer_product_dense_golden("Y", X_elem_size, Y_elem_size,
                                                X_rows, sweep_var, sweep_var, Y_columns)
            a5, p5, l5 = outer_product_dense_golden("Z", X_elem_size, Y_elem_size,
                                                X_rows, sweep_var, sweep_var, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        for i in range(6):
            D_avg[i].append(temp_avg[i] / 10)
            D_usage[i].append(temp_usage[i] / 10)
            D_lat[i].append(temp_lat[i] / 10)

    # --- PLOTTING ---
    titles = ['Avg BW', 'Avg Utilization', 'Latency']
    ylabels = ['Average BW (bytes)', 'Avg Utilization (%)', 'Latency (cycles)']
    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']
    labels_S = [
        'S Gustavson X', 'S Gustavson Y', 'S Gustavson Z',
        'S OuterProd X', 'S OuterProd Y', 'S OuterProd Z'
    ]
    labels_D = [
        'D Gustavson X', 'D Gustavson Y', 'D Gustavson Z',
        'D OuterProd X', 'D OuterProd Y', 'D OuterProd Z'
    ]

    for i, (S_list, D_list, title, ylabel) in enumerate(zip(
            [S_avg, S_usage, S_lat],
            [D_avg, D_usage, D_lat],
            titles, ylabels)):

        plt.figure()
        x = np.array(param_range)
        # sparse (dashed)
        for j in range(6):
            plt.plot(x, S_list[j], color=colors[j],
                     linestyle='--', label=labels_S[j])
        # dense (solid)
        for j in range(6):
            plt.plot(x, D_list[j], color=colors[j],
                     linestyle='-', label=labels_D[j])

        plt.title(title)
        plt.xlabel('Number of columns of X')
        plt.ylabel(ylabel)
        plt.legend()
        plt.grid(True)
        plt.xticks(np.arange(min(x), max(x) + 1, step*2))
        plt.xlim(min(x), max(x))

        filename = f"X_columns_{title.replace(' ', '_')}.png"
        plt.savefig(filename, transparent=True, bbox_inches='tight', dpi=300)
        plt.close()

    # prepare empty storage for sparse
    S_avg = [[] for _ in range(6)]
    S_usage = [[] for _ in range(6)]
    S_lat = [[] for _ in range(6)]

    # Sweeping X_rows
    start, stop, step = X_rows_range
    param_range = list(range(start, stop + step, step))

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping X_rows for sparse dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson sparse X, Y, Z
            a0, p0, l0 = gustavson_sparse_golden("X", X_elem_size, Y_elem_size, Sparsity,
                                                 sweep_var, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_sparse_golden("Y", X_elem_size, Y_elem_size, Sparsity,
                                                 sweep_var, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_sparse_golden("Z", X_elem_size, Y_elem_size, Sparsity,
                                                 sweep_var, X_columns, Y_rows, Y_columns)
            # OuterProd sparse X, Y, Z
            a3, p3, l3 = outer_product_sparse_golden("X", X_elem_size, Y_elem_size, Sparsity,
                                                     sweep_var, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_sparse_golden("Y", X_elem_size, Y_elem_size, Sparsity,
                                                     sweep_var, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_sparse_golden("Z", X_elem_size, Y_elem_size, Sparsity,
                                                     sweep_var, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        # media su 10 run
        for i in range(6):
            S_avg[i].append(temp_avg[i] / 10)
            S_usage[i].append(temp_usage[i] / 10)
            S_lat[i].append(temp_lat[i] / 10)

    # --- DENSE STORAGE per 6 dataflow ---
    D_avg = [[] for _ in range(6)]
    D_usage = [[] for _ in range(6)]
    D_lat = [[] for _ in range(6)]

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping X_rows for dense dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson dense X, Y, Z
            a0, p0, l0 = gustavson_dense_golden("X", X_elem_size, Y_elem_size,
                                                sweep_var, X_columns, Y_rows, Y_columns)
            a1, p1, l1 = gustavson_dense_golden("Y", X_elem_size, Y_elem_size,
                                                sweep_var, X_columns, Y_rows, Y_columns)
            a2, p2, l2 = gustavson_dense_golden("Z", X_elem_size, Y_elem_size,
                                                sweep_var, X_columns, Y_rows, Y_columns)
            # OuterProd dense X, Y, Z
            a3, p3, l3 = outer_product_dense_golden("X", X_elem_size, Y_elem_size,
                                                    sweep_var, X_columns, Y_rows, Y_columns)
            a4, p4, l4 = outer_product_dense_golden("Y", X_elem_size, Y_elem_size,
                                                    sweep_var, X_columns, Y_rows, Y_columns)
            a5, p5, l5 = outer_product_dense_golden("Z", X_elem_size, Y_elem_size,
                                                    sweep_var, X_columns, Y_rows, Y_columns)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        for i in range(6):
            D_avg[i].append(temp_avg[i] / 10)
            D_usage[i].append(temp_usage[i] / 10)
            D_lat[i].append(temp_lat[i] / 10)

    # --- PLOTTING ---
    titles = ['Avg BW', 'Avg Utilization', 'Latency']
    ylabels = ['Average BW (bytes)', 'Avg Utilization (%)', 'Latency (cycles)']
    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']
    labels_S = [
        'S Gustavson X', 'S Gustavson Y', 'S Gustavson Z',
        'S OuterProd X', 'S OuterProd Y', 'S OuterProd Z'
    ]
    labels_D = [
        'D Gustavson X', 'D Gustavson Y', 'D Gustavson Z',
        'D OuterProd X', 'D OuterProd Y', 'D OuterProd Z'
    ]

    for i, (S_list, D_list, title, ylabel) in enumerate(zip(
            [S_avg, S_usage, S_lat],
            [D_avg, D_usage, D_lat],
            titles, ylabels)):

        plt.figure()
        x = np.array(param_range)
        # sparse (dashed)
        for j in range(6):
            plt.plot(x, S_list[j], color=colors[j],
                     linestyle='--', label=labels_S[j])
        # dense (solid)
        for j in range(6):
            plt.plot(x, D_list[j], color=colors[j],
                     linestyle='-', label=labels_D[j])

        plt.title(title)
        plt.xlabel('Number of rows of X')
        plt.ylabel(ylabel)
        plt.legend()
        plt.grid(True)
        plt.xticks(np.arange(min(x), max(x) + 1, step*2))
        plt.xlim(min(x), max(x))

        filename = f"X_rows_{title.replace(' ', '_')}.png"
        plt.savefig(filename, transparent=True, bbox_inches='tight', dpi=300)
        plt.close()

    # prepare empty storage for sparse
    S_avg = [[] for _ in range(6)]
    S_usage = [[] for _ in range(6)]
    S_lat = [[] for _ in range(6)]

    # Sweeping Y_columns
    start, stop, step = Y_columns_range
    param_range = list(range(start, stop + step, step))

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping Y_columns for sparse dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson sparse X, Y, Z
            a0, p0, l0 = gustavson_sparse_golden("X", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, X_columns, Y_rows, sweep_var)
            a1, p1, l1 = gustavson_sparse_golden("Y", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, X_columns, Y_rows, sweep_var)
            a2, p2, l2 = gustavson_sparse_golden("Z", X_elem_size, Y_elem_size, Sparsity,
                                                 X_rows, X_columns, Y_rows, sweep_var)
            # OuterProd sparse X, Y, Z
            a3, p3, l3 = outer_product_sparse_golden("X", X_elem_size, Y_elem_size, Sparsity,
                                                     X_rows, X_columns, Y_rows, sweep_var)
            a4, p4, l4 = outer_product_sparse_golden("Y", X_elem_size, Y_elem_size, Sparsity,
                                                     X_rows, X_columns, Y_rows, sweep_var)
            a5, p5, l5 = outer_product_sparse_golden("Z", X_elem_size, Y_elem_size, Sparsity,
                                                     X_rows, X_columns, Y_rows, sweep_var)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        # media su 10 run
        for i in range(6):
            S_avg[i].append(temp_avg[i] / 10)
            S_usage[i].append(temp_usage[i] / 10)
            S_lat[i].append(temp_lat[i] / 10)

    # --- DENSE STORAGE per 6 dataflow ---
    D_avg = [[] for _ in range(6)]
    D_usage = [[] for _ in range(6)]
    D_lat = [[] for _ in range(6)]

    for sweep_var in param_range:
        temp_avg = [0] * 6
        temp_usage = [0] * 6
        temp_lat = [0] * 6

        print(f"Sweeping Y_columns for dense dataflows: {sweep_var}")
        for _ in range(10):
            # Gustavson dense X, Y, Z
            a0, p0, l0 = gustavson_dense_golden("X", X_elem_size, Y_elem_size,
                                                X_rows, X_columns, Y_rows, sweep_var)
            a1, p1, l1 = gustavson_dense_golden("Y", X_elem_size, Y_elem_size,
                                                X_rows, X_columns, Y_rows, sweep_var)
            a2, p2, l2 = gustavson_dense_golden("Z", X_elem_size, Y_elem_size,
                                                X_rows, X_columns, Y_rows, sweep_var)
            # OuterProd dense X, Y, Z
            a3, p3, l3 = outer_product_dense_golden("X", X_elem_size, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, sweep_var)
            a4, p4, l4 = outer_product_dense_golden("Y", X_elem_size, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, sweep_var)
            a5, p5, l5 = outer_product_dense_golden("Z", X_elem_size, Y_elem_size,
                                                    X_rows, X_columns, Y_rows, sweep_var)

            for i, (a, p, l) in enumerate([(a0, p0, l0), (a1, p1, l1), (a2, p2, l2),
                                           (a3, p3, l3), (a4, p4, l4), (a5, p5, l5)]):
                temp_avg[i] += a
                temp_usage[i] += p
                temp_lat[i] += l

        for i in range(6):
            D_avg[i].append(temp_avg[i] / 10)
            D_usage[i].append(temp_usage[i] / 10)
            D_lat[i].append(temp_lat[i] / 10)

    # --- PLOTTING ---
    titles = ['Avg BW', 'Avg Utilization', 'Latency']
    ylabels = ['Average BW (bytes)', 'Avg Utilization (%)', 'Latency (cycles)']
    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']
    labels_S = [
        'S Gustavson X', 'S Gustavson Y', 'S Gustavson Z',
        'S OuterProd X', 'S OuterProd Y', 'S OuterProd Z'
    ]
    labels_D = [
        'D Gustavson X', 'D Gustavson Y', 'D Gustavson Z',
        'D OuterProd X', 'D OuterProd Y', 'D OuterProd Z'
    ]

    for i, (S_list, D_list, title, ylabel) in enumerate(zip(
            [S_avg, S_usage, S_lat],
            [D_avg, D_usage, D_lat],
            titles, ylabels)):

        plt.figure()
        x = np.array(param_range)
        # sparse (dashed)
        for j in range(6):
            plt.plot(x, S_list[j], color=colors[j],
                     linestyle='--', label=labels_S[j])
        # dense (solid)
        for j in range(6):
            plt.plot(x, D_list[j], color=colors[j],
                     linestyle='-', label=labels_D[j])

        plt.title(title)
        plt.xlabel('Number of columns of Y')
        plt.ylabel(ylabel)
        plt.legend()
        plt.grid(True)
        plt.xticks(np.arange(min(x), max(x) + 1, step*2))
        plt.xlim(min(x), max(x))

        filename = f"Y_columns_{title.replace(' ', '_')}.png"
        plt.savefig(filename, transparent=True, bbox_inches='tight', dpi=300)
        plt.close()

sweep_and_plot(
    X_elem_range=[1, 10, 1],
    Y_elem_range=[1, 10, 1],
    Sparsity_range=[0, 1, 0.05],
    X_columns_range=[4, 20, 2],
    X_rows_range=[4, 20, 2],
    Y_columns_range=[4, 20, 2]
)