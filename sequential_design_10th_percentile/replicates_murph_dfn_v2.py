#"""
#   :synopsis: Driver run file for TPL example, evaluated over a simulation of values
#   :version: 2.0
#   :maintainer: Jeffrey Hyman & Alexander Murph
#.. moduleauthor:: Jeffrey Hyman <jhyman@lanl.gov>, Alexander Murph <murph@lanl.gov>
#"""

from pydfnworks import *
import os, sys
import networkx as nx 
from scipy.stats.qmc import LatinHypercube
import shutil
import random
import pandas as pd

# Set to work for either murph's or jeffrey's file structures.
i_am_jeffrey = False

# Get the input info:
ijob = int(sys.argv[1])
input_num = int(sys.argv[2])
input_file = "new_inputs/new_input_parameters_" + str(input_num) + "_.csv"

# Set the min and max values for the parameters we wish to investigate.
global min_p32
global max_p32
global min_alpha_TPL_exp
global max_alpha_TPL_exp
global min_alpha_semicorr
global max_alpha_semicorr
global min_beta_semicorr
global max_beta_semicorr
global min_sigma_semicorr
global max_sigma_semicorr

# Values chosen based on SKB report 10-52 Table 6.75
# TODO: Confirm with Jeffrey that this table is for Crystalline rock.
min_alpha_semicorr = 1*10**-10
max_alpha_semicorr = 1*10**-8
min_beta_semicorr  = 0.1
max_beta_semicorr  = 1.2
min_sigma_semicorr = 0.5
max_sigma_semicorr = 1.0
min_alpha_TPL_exp  = 2.25
max_alpha_TPL_exp  = 3.5
min_p32            = 5e-02
max_p32            = 0.2

if i_am_jeffrey:
    base_dir = "/home/jhyman/projects/phil-dr/UQ/dfnworks_variability/dfnworks_drivers"
    jobname = f"/lclscratch/jhyman/output_{ijob}"
    inputrecord = jobname+'/SA_params.txt'
else:
    base_dir = "/home/murph/dfnworks_variability/sequential_design_10th_percentile"
    jobname = f"/lclscratch/murph/output_{ijob}"
    inputrecord = jobname+'/SA_params.txt'

os.chdir(base_dir)

# Set the seed (in case scipy sets it for the whole file)
random.seed(ijob)

dfnFlow_file = os.getcwd() + '/dfn_steady.in'
dfnTrans_file = os.getcwd() + '/PTDFN_control.dat'

# Grab parameter values for this experiment:

new_inputs          = pd.read_csv(input_file,header=None)
print(new_inputs)
print("-----")
print(new_inputs.info())
print("-----")
print(new_inputs.head())
print("-----")
print(new_inputs[0][0])
print("-----")
print(new_inputs[0][1])
print("-----")
print(new_inputs[1][0])
print("----")
print("printing actual values")
print(new_inputs[0][1])
print(new_inputs[1][1])
print(new_inputs[2][1])
print(new_inputs[3][1])
print(new_inputs[4][1])
print(new_inputs[5][1])

curr_alpha_semicorr = float(new_inputs[1][1])*(max_alpha_semicorr - min_alpha_semicorr) + min_alpha_semicorr
curr_beta_semicorr  = float(new_inputs[2][1])*(max_beta_semicorr - min_beta_semicorr) + min_beta_semicorr
curr_sigma_semicorr = float(new_inputs[3][1])*(max_sigma_semicorr - min_sigma_semicorr) + min_sigma_semicorr
curr_alpha_TPL_exp  = float(new_inputs[4][1])*(max_alpha_TPL_exp - min_alpha_TPL_exp) + min_alpha_TPL_exp
curr_p32            = float(new_inputs[5][1])*(max_p32 - min_p32) + min_p32

print("printing raw input parameters")
print(curr_alpha_semicorr)
print(curr_beta_semicorr)
print(curr_sigma_semicorr)
print(curr_alpha_TPL_exp)
print(curr_p32)

DFN = DFNWORKS(jobname,
            dfnFlow_file=dfnFlow_file,
            dfnTrans_file=dfnTrans_file,
            ncpu=11)

DFN.params['domainSize']['value'] = [200, 200, 200]
DFN.params['h']['value'] = 1
DFN.params['seed']['value'] = ijob
DFN.params['boundaryFaces']['value'] = [0, 0, 0, 0, 1, 1]
DFN.params['orientationOption']['value'] = 1

print("about to add fracture families")

# from table 6-75 and SKB report 10-52
# in zone -300m to -400meters
# Family name NE
DFN.add_fracture_family(shape="ell",
                        distribution="tpl",
                        alpha=curr_alpha_TPL_exp,
                        min_radius=10.0,
                        max_radius=50.0, #I am upping this based on the conversation with Jeffrey H. 8/3/23
                        trend=329,
                        plunge=2,
                        kappa=14.3,
                        aspect=1,
                        p32=curr_p32,
                        hy_variable='transmissivity',
                        hy_function='semi-correlated',
                        hy_params={
                            "alpha": curr_alpha_semicorr,
                            "beta": curr_beta_semicorr,
                            "sigma": curr_sigma_semicorr
                        })

# Family name NW
DFN.add_fracture_family(shape="ell",
                        distribution="tpl",
                        alpha=curr_alpha_TPL_exp,
                        min_radius=10.0,
                        max_radius=50.0,
                        trend=60,
                        plunge=6,
                        kappa=12.9,
                        aspect=1,
                        p32=curr_p32,
                        hy_variable='transmissivity',
                        hy_function='semi-correlated',
                        hy_params={
                            "alpha": curr_alpha_semicorr,
                            "beta": curr_beta_semicorr,
                            "sigma": curr_sigma_semicorr
                        })
                       
# Family name HZ
DFN.add_fracture_family(shape="ell",
                        distribution="tpl",
                        alpha=curr_alpha_TPL_exp,
                        min_radius=10.0,
                        max_radius=50.0, #I am upping this based on the conversation with Jeffrey H. 8/3/23
                        trend=5,
                        plunge=86,
                        kappa=15.2,
                        aspect=1,
                        p32=curr_p32,
                        hy_variable='transmissivity',
                        hy_function='semi-correlated',
                        hy_params={
                            "alpha": curr_alpha_semicorr,
                            "beta": curr_beta_semicorr,
                            "sigma": curr_sigma_semicorr
                        })

DFN.visual_mode = True
DFN.make_working_directory(delete = True)
DFN.check_input()
DFN.create_network()
DFN.mesh_network()

print("about to simulate flow")

DFN.dfn_flow()

inflow_pressure = 1.1e6
outflow_pressure = 1e6
boundary_file = "pboundary_bottom.ex"
direction = "z"
#DFN.effective_perm(inflow_pressure, outflow_pressure, boundary_file, direction)

print("about to start graph flow.")

Gflow = DFN.run_graph_flow('bottom', 'top', inflow_pressure, outflow_pressure)
p32, dq, Q = DFN.compute_dQ(Gflow)
print(f"Flow Channeling Ratio : {dq/p32}")

number_of_particles = 10**5
p = DFN.run_graph_transport(Gflow,number_of_particles,
    f"partime","graph_frac_sequence",
    format = "ascii", initial_positions = 'flux')

print("about to save parameters")

with open('SA_params.txt', 'w') as f:
    param_names = "alpha_semicorr, beta_semicorr, sigma_semicorr, alpha_radius, p32\n"
    f.write(param_names)
    params = '{:.15f}'.format(curr_alpha_semicorr) + ", " + '{:.15f}'.format(curr_beta_semicorr) + ", " + '{:.15f}'.format(curr_sigma_semicorr) + ", " + '{:.15f}'.format(curr_alpha_TPL_exp) + ", " + '{:.15f}'.format(curr_p32) + "\n"
    f.write(params)
DFN.dump_hydraulic_values(format = "fehm")
DFN.dfn_trans()



