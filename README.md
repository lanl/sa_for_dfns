# Code for Experiment in Publication “Sensitivity Analysis in the Presence of Intrinsic Stochasticity for Discrete Fracture Network Simulations”

All code used to perform the experiment in the cited publication.  For questions, issues, or clarifications please reach out to Murph: <murph@lanl.gov>.

This repository is organized according to the different directories needed to perform the experiment in the paper.  These directories are:

* dfnworks_drivers: code to perform the DFN simulations to create the data used in the experiment;

* sequential_design_10th_percentile: code to perform the Sequential Design described in the paper;

* test_data: code mostly identical to the code in dfnworks_drivers.  Used to created a separate testing data set for validation of the methods;

* eda: scripts to create data visualizations on the data created in dfnworks_drivers, sequential_design_10th_percentile, and test_data;

* gp_analysis: code to analyze the Gaussian Process (GP) fit during the Sequential Design in sequential_design_10th_percentile;

* sobol_indices: code to estimate Sobol’ Indices using the GP fit during the Sequential Design in sequential_design_10th_percentile.


## Software Required
To create underground particle transport simulation data, one will need access to the dfnWorks simulation suite, available for download [here](https://dfnworks.lanl.gov/).

## Citation
Alexander C. Murph, Justin D. Strait, Kelly R. Moran, Jeffrey D. Hyman, Hari S. Viswanathan, & Philip H. Stauffer. (2023). Sensitivity Analysis in the Presence of Intrinsic Stochasticity for Discrete Fracture Network Simulations.  _In Review._ [Preprint.](https://arxiv.org/abs/2312.04722)

## Release

This software has been approved for open source release and has been assigned **O4712** 

## Copyright

© 2023. Triad National Security, LLC. All rights reserved.
This program was produced under U.S. Government contract 89233218CNA000001 for Los Alamos National Laboratory (LANL), which is operated by Triad National Security, LLC for the U.S. Department of Energy/National Nuclear Security Administration. All rights in the program are reserved by Triad National Security, LLC, and the U.S. Department of Energy/National Nuclear Security Administration. The Government is granted for itself and others acting on its behalf a nonexclusive, paid-up, irrevocable worldwide license in this material to reproduce, prepare derivative works, distribute copies to the public, perform publicly and display publicly, and to permit others to do so.

## License

This code repository is distributed under a MIT License:

Copyright 2023
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

