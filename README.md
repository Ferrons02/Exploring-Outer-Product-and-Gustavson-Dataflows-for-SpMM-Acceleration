DENSE & SPARSE GOLDEN MODELS – OUTER PRODUCT AND GUSTAVSON
This repository contains Python golden models for matrix multiplication using the Outer Product and Gustavson algorithms.
Both algorithms are implemented in two versions:

-Dense
-Sparse with bitmap encoding

All models are designed for easy customization, analysis, and direct comparison.

1 – REPOSITORY STRUCTURE
The repo is organized as follows:

DENSE MODELS: Contains the dense golden models for Outer Product and Gustavson algorithms.
Each model is implemented under three data reuse policies: X-reuse, Y-reuse, and Z-reuse.
Every configuration has its own Jupyter notebook for a total of 6 notebooks.

SPARSE MODELS: Contains sparse versions of the models, implemented with bitmap encoding.
Both Outer Product and Gustavson variants are available.

COMPARISON: Contains a script that generates performance comparison plots.
The script benchmarks and visualizes how each version of the models performs against the others in terms of memory usage, reuse efficiency, and bandwidth.

2 – HOW TO USE THE MODELS
1) Choose a data reuse strategy
X-reuse
Y-reuse
Z-reuse

2) Open the corresponding Jupyter notebook
You can modify various parameters, such as:

-Bit width of input and output words
-Dimensions and sparsity of matrices X and Y
-Tile dimensions (X_elem_size and Y_elem_size)
-Metadata chunk size

3) Run the simulation and check the results

3 – PARAMETER INTERPRETATION
X_rows, X_columns, Y_rows, Y_columns
Refer to the software dimensions of the X and Y matrices

X_elem_size and Y_elem_size
Refer to the chunks of matrix data that the accelerator can process in a single cycle
Their meaning depends on the selected dataflow:

Outer Product
X_elem_size = number of elements in a column tile of X
Y_elem_size = number of elements in a row tile of Y

Gustavson
X_elem_size = number of elements in a row tile of X
Y_elem_size = number of columns in a block tile of Y resulting in a size X_elem_size rows by Y_elem_size columns

4 – MODEL OUTPUT
Each simulation provides the following:

-Cycle-by-cycle access graphs:
Visual representations of the elements of X, Y, and Z accessed on each clock cycle

-Figures of merit:
Input, output, and combined bandwidths
Average and peak values
Reuse distances for X, Y, and Z elements
Latency
Average % of utilization of the accelerator

-Final result of the computation
The resulting matrix product X * Y

5 – ASSUMPTIONS
-X and Z are stored in row-major order for dense models and Gustavson sparse, while for outer produc sparse X is stored in column-major order while Y is Always stored in column-major order

-Latency includes 2 additional cycles:
1 load-before-compute cycle
1 store-after-compute cycle

6 – QUICK USAGE
1 – Clone the repository and navigate into the folder
2 – Install required dependencies (numpy, matplotlib, etc)
3 – Open a notebook or run a script
4 – Analyze the output graphs and performance metrics