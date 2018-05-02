.. _run:


Compiling and running the model
===============================

https://e3sm.org/model/running-e3sm/e3sm-quick-start/

Run Script
-----------
A runscript is available in the E3SM model source code directory (parallel to "cime" and "compoment"). 

An example is available here: 

https://e3sm.org/wp-content/uploads/2018/04/run_e3sm.DECKv1b_piControl.ne30_oEC.edison.csh_.txt

Compsets
------------------------

- Atmosphere-only simulation with present-day external forcing 

  FC5AV1C-04P2 

- Atmosphere-only simulation with pre-industrial external forcing 

  F1850C5AV1C-04P2 

Resolution
----------

Technically, EAM can run with horizontal resolution from ne4 (about 750km) to ne120 (about 25km)
(with F1850C5AV1C-04P2 compset). 

The vertical resolution is L30 for V0 and L72 for V1.  


Switching on COSP Simulator
-------------------------


- Configuration: 

  ./xmlchange -append -file env_build.xml -id CAM_CONFIG_OPTS -val "-cosp"

- Namelist change: 

cat <<EOF >> user_nl_cam
 cosp_lite = .true.
EOF

If cosp_lite = true, the COSP cloud simulators are run to produce 
select output for the AMWG diagnostics package.
sets cosp_ncolumns=10 and cosp_nradsteps=3 
(appropriate for COSP statistics derived from seasonal averages),
and runs MISR, ISCCP, MODIS, and CALIPSO lidar simulators 
(cosp_lmisr_sim=.true.,cosp_lisccp_sim=.true.,
cosp_lmodis_sim=.true.,cosp_llidar_sim=.true.).
This default logical is set in cospsimulator_intr.F90.


Switching on Nudging
--------------------

under construction 


Switching on Satellite/Aircraft Sampler 
---------------------------------------

under construction 

Switching on Aerosol Forcing Diagnostics
----------------------------------------

Namelist setup:  

cat <<EOF >> user_nl_cam
 rad_diag_1 = 'A:Q:H2O', 'N:O2:O2', 'N:CO2:CO2', 'A:O3:O3', 'N:N2O:N2O', 'N:CH4:CH4', 'N:CFC11:CFC11', 'N:CFC12:CFC12', 
EOF

Then the radiative flux calculated without aerosols are diagnosed 
(with "_d1" appended to the original radiative flux name, e.g. FSNT_d1). 

The detailed diagnostic method can be found in Ghan (2013, doi: 10.5194/acp-13-9971-2013). 

Changing External Forcings
--------------------------

under construction 


Changing Spatial Resolutions
----------------------------

under construction 


