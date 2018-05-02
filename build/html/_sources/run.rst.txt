.. _run:


Compiling and running the model
===============================

https://e3sm.org/model/running-e3sm/e3sm-quick-start/

Run Script
-----------
A runscript is available in the E3SM model source code directory (parallel to "cime" and "compoment"). 


Create a new case 
-----------------

A new case is often created for each simulation :: 

  ./create_newcase -case $temp_case_scripts_dir  \
                   -mach $newcase_machine        \
                   -compset $compset             \
                   -res $resolution              \
                   -project $project             \
                   -pecount $std_proc_configuration

Compsets
--------

- Atmosphere-only simulation with present-day external forcing :: 

  FC5AV1C-04P2 

- Atmosphere-only simulation with pre-industrial external forcing :: 

  F1850C5AV1C-04P2 


Changing Spatial Resolutions
----------------------------

Technically, EAM can run with horizontal resolution from ne4 (about 750km) to ne120 (about 25km)
(with F1850C5AV1C-04P2 compset). To change the horizontal resolution, set :: 

  set resolution = ne30_ne30 (or ne4_ne4, ne11_ne11, ne16_ne16, ne120_ne120) 

before executing "create_newcase" 

The vertical resolution is L30 for V0 and L72 for V1.  


Switching on COSP Simulator
-------------------------


- Configuration ::

     ./xmlchange -append -file env_build.xml -id CAM_CONFIG_OPTS -val "-cosp"

- Namelist change ::

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

The following variables need to be modified to activate nudging. 
The example shown below allows nudging for horizontal winds :: 

 cat <<EOF >> user_nl_cam
  !.......................................................
  ! nudging
  !.......................................................
   Nudge_Model = .True.
   Nudge_Path  = '${INPUT_NUDGING}/ne30/'
   Nudge_File_Template = 'ACME.cam.h2.%y-%m-%d-00000.nc'
   Nudge_Times_Per_Day = 4  !! nudging input data frequency 
   Model_Times_Per_Day = 48 !! should not be larger than 48 if dtime = 1800s 
   Nudge_Uprof = 1
   Nudge_Ucoef = 1.
   Nudge_Vprof = 1
   Nudge_Vcoef = 1.
   Nudge_Tprof = 0
   Nudge_Tcoef = 0.
   Nudge_Qprof = 0
   Nudge_Qcoef = 0.
   Nudge_PSprof = 0
   Nudge_PScoef = 0.
   Nudge_Beg_Year = 0000
   Nudge_Beg_Month = 1
   Nudge_Beg_Day = 1
   Nudge_End_Year = 9999
   Nudge_End_Month = 1
   Nudge_End_Day = 1
  EOF

This setup will nudge the model towards a baseline simulation. The nudging data were 
created from the baseline simulation by archiving the 6-hourly meteorological fields. 
Only the horizontal winds are nudged, with a relaxation time scale of 6h. 

Switching on Satellite/Aircraft Sampler 
---------------------------------------

under construction 

Switching on Aerosol Forcing Diagnostics
----------------------------------------

Namelist setup :: 

  cat <<EOF >> user_nl_cam
     rad_diag_1 = 'A:Q:H2O', 'N:O2:O2', 'N:CO2:CO2', 'A:O3:O3', 'N:N2O:N2O', 'N:CH4:CH4', 'N:CFC11:CFC11', 'N:CFC12:CFC12', 
  EOF

Then the radiative flux calculated without aerosols are diagnosed 
(with "_d1" appended to the original radiative flux name, e.g. "FSNT_d1"). 

The detailed diagnostic method can be found in Ghan (2013, doi: 10.5194/acp-13-9971-2013). 

Changing External Forcings
--------------------------

The following changes need to be made before executing "create_newcase". 

- Changing SST, e.g. :: 

  ./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val '$DIN_LOC_ROOT/atm/cam/sst/sst_HadOIBl_bc_1x1_clim_pi_c101029.nc' 
  ./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val '$DIN_LOC_ROOT/atm/cam/sst/sst_HadOIBl_bc_1x1_clim_pi_plus4K.nc'
  
- Changing aerosol emissions, e.g. :: 






