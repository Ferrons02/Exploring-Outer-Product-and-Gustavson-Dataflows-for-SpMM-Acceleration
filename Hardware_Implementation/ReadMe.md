# Project Build and Simulation Guide

This ReadMe provides instructions on how to set up and run the standalone simulation using `make` commands.

## Available Make Commands

### 0. Put the desired parameters inside the makefile:
Choose the sizes of the matrices and their sparsity inside the makefile (lower sparsity factor means an X matrix more dense). The number of columns of X and columns of Y must be powers of 2, while the size of the metadata chunk should be a multiple of 32 and a power of 2.

### 1. To clone the dependencies, run:
```sh
make bender
```

### 2. Generate Stimuli and Golden Files
To generate the stimuli and golden reference using a Python script, run:
```sh
make stimuli
```

### 3. Create Compilation Script
To create a compilation script for compiling the hardware, run:
```sh
make sim-script
```

### 4. Simulate the Design
To simulate the RTL, execute:
```sh
make sim
```

## Test Results
If the tests pass successfully, you should see the following message displayed at the end:
```
TEST PASSED! :)
```

## Contributors
- Francesco Conti, University of Bologna (*f.conti@unibo.it*)
- Arpan Suravi Prasad, ETH Zurich (*prasadar@iis.ee.ethz.ch*)
- Marco Ferroni, ETH Zurich (*mferroni@ethz.ch*)

## NOTE
There might be minor changes in the future

## License
This repository makes use of two licenses:
- for all *software*: Apache License Version 2.0
- for all *hardware*: Solderpad Hardware License Version 0.51
 
For further information have a look at the license files: `LICENSE.hw`, `LICENSE.sw`