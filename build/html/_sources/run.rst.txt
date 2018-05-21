.. _run:


`Github version <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/run.rst>`_ 

`Spinx version <https://kaizhangpnl.github.io/EAM_User_Guide/run.html>`_ 


Compiling and running the model
===============================

First of all, please read 

`E3SM Quick Start <https://e3sm.org/model/running-e3sm/e3sm-quick-start/>`_ 


Run Script
-----------
A `runscript <https://github.com/E3SM-Project/E3SM/blob/master/run_e3sm.template.csh>`_ 
is available in the E3SM model source code directory (parallel to "cime" and "compoment"). 


Creating a new case 
-----------------

A new case is often created for each simulation :: 

  ./create_newcase -case $temp_case_scripts_dir  \
                   -mach $newcase_machine        \
                   -compset $compset             \
                   -res $resolution              \
                   -project $project             \
                   -pecount $std_proc_configuration

Setting compsets
----------------

Available compsets for E3SM can be found in: 

   `cime/config/e3sm/allactive/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/allactive/config_compsets.xml>`_

Available compsets for EAM can be found in: 

   `components/cam/cime_config/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/cime_config/config_compsets.xml>`_

The most frequently used compsets are listed below: 

- **FC5AV1C-04P2**  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_av1c-04p2.xml>`_ 
 
  V1 atmosphere-only simulation with present-day external forcing. Tuning settings are for the ne30L72 resolution. 

  The present-day external forcing (so-called “year 2000”, mean of 1995-2005) will be used. 
  The anthropogenic aerosol emissions and greenhouse gas concentration are constant. 
  The atmosphere model is coupled with the ELM land model (similar to CLM4.5), and 
  driven by prescribed climatological SST / sea ice cover. 
  
- **F1850C5AV1C-04P2**  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/1850_cam5_av1c-04p2.xml>`_ 

  V1 atmosphere-only simulation with pre-industrial external forcing. Tuning settings are for the ne30L72 resolution. 
  
- **FC5**  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_cosp.xml>`_ 

  V0-like atmosphere-only simulation with present-day external forcing. Tuning settings are for the ne30L30 resolution. 
  Note that some tuning parameters need to be changed for version 0.3. 

- **F1850C5**  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/1850_cam5.xml>`_ 

  V0-like atmosphere-only simulation with pre-industrial external forcing. Tuning settings are for the ne30L30 resolution. 
  Note that some tuning parameters need to be changed for version 0.3.  

- **FC5AV1C-H01C** `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_av1c-h01c.xml>`_ 

  High-resolution (ne120L72) V1 atmosphere-only simulation with present-day external forcing. 

- **F1850C5AV1C-H01C** `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_av1c-h01c.xml>`_ 

  High-resolution (ne120L72) V1 atmosphere-only simulation with  pre-industrial external forcing. 

- **F20TRC5-CMIP6** `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/20TR_cam5_CMIP6.xml>`_ 

  V1 atmosphere-only simulation with time-varying 20th-century external forcing from CMIP6. 
  
  
  
Changing Spatial Resolutions
----------------------------

Technically, EAM can run with horizontal resolution from ne4 (about 750km) to ne120 (about 25km)
(with F1850C5AV1C-04P2 compset). To change the horizontal resolution, set :: 

  set resolution = ne30_ne30 (or ne4_ne4, ne11_ne11, ne16_ne16, ne120_ne120) 

before executing "create_newcase" 

The vertical resolution is L30 for V0 and L72 for V1.  
 
 
Debugging mode 
--------------

Before compiling the code ::

./xmlchange -file env_build.xml -id DEBUG -val "TRUE"
 
 
Sanity-check for state variables
--------------------------------

- Namelist change ::

     cat <<EOF >> user_nl_cam
       state_debug_checks = .true.
     EOF

The model will check if the state variables are within a plausible range 
(e.g. temperature above zero) when physics_upstate is called. 
Note that this sanity-check will be switched on automatically when the model is 
running in debugging mode. 
 
Switching on COSP Simulator
-------------------------


- Configuration ::

     ./xmlchange -append -file env_build.xml -id CAM_CONFIG_OPTS -val "-cosp"

- Namelist change ::

     cat <<EOF >> user_nl_cam
       docosp = .true. !!! needed for some versions of E3SM 
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

An introduction of nudging can be found in 
`Zhang et al. (2014) <https://www.atmos-chem-phys.net/14/8631/2014/>`_ and references therein. 

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


.. Switching on Satellite/Aircraft Sampler 
.. ---------------------------------------
.. 
.. under construction 
.. 
 
Switching on Aerosol Forcing Diagnostics
----------------------------------------

Namelist setup :: 

  cat <<EOF >> user_nl_cam
     rad_diag_1 = 'A:Q:H2O', 'N:O2:O2', 'N:CO2:CO2', 'A:O3:O3', 'N:N2O:N2O', 'N:CH4:CH4', 'N:CFC11:CFC11', 'N:CFC12:CFC12', 
  EOF

Then the radiative flux calculated without aerosols are diagnosed 
(with "_d1" appended to the original radiative flux name, e.g. "FSNT_d1"). 

The detailed diagnostic method can be found in `Ghan (2013) <https://www.atmos-chem-phys.net/13/9971/2013/>`_. 


Changing External Forcings
--------------------------

The following changes need to be made after executing "create_newcase". 

- Changing SST, e.g. :: 

  ./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val '$DIN_LOC_ROOT/atm/cam/sst/sst_HadOIBl_bc_1x1_clim_pi_c101029.nc' 
  ./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val '$DIN_LOC_ROOT/atm/cam/sst/sst_HadOIBl_bc_1x1_clim_pi_plus4K.nc'
  
- Changing aerosol emissions, e.g. :: 


Single column model (SCM) simulations
-------------------------------------

EAM can run in the single column mode. 
Some instructions on how to configure and run a single column model can be found 
`here <https://acme-climate.atlassian.net/wiki/spaces/Docs/pages/128294958/Running+the+ACME+Single+Column+Model>`_. 

A runscript template can be found `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/scm_runscript.rst>`_. 

IOP forcing data to drive the SCM can be found 
`here <https://acme-climate.atlassian.net/wiki/spaces/Docs/pages/127456636/ACME+Single-Column+Model+Case+Library>`_. 


Regionally-Refinement Model (RRM) simulations 
--------------------------------------------- 

Right now, resources are available internally: 

- `How to run RRM <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/11010268/How+to+run+the+regionally+refined+model+RRM>`_.
- `Regridding RRM simulations <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/27951986/Regridding+RRM+simulations>`_.
- `How to perform nudged simulations with RRM <https://acme-climate.atlassian.net/wiki/spaces/Docs/pages/20153276/How+to+perform+nudging+simulations+with+the+regional+refined+model+RRM>`_.


Frequently-used namelist options
--------------------------------

The following namelist options are frequently used for detailed diagnostics: 

- Switch for diagnostic output of the aerosol tendencies :: 

     history_aerosol = .true.

- Switch for diagnostic output of the aerosol optics :: 
 
     history_aero_optics = .true. 

- Produce output for the AMWG diagnostic package :: 

     history_amwg = .true. 
  
- Switch for water/heat budget analysis output :: 

     history_budget = .true. 
  
- Switch for the AMWG variability diagnostics output :: 

     history_vdiag = .true. 
  
- Switch for verbose (mostly aerosol-related) history output :: 

     history_verbose = .true. 




Other options
-------------

The complete namelist options are listed in: 

   `components/cam/bld/namelist_files/namelist_definition.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/namelist_definition.xml>`_


Reference 
----------

Documentation from `CAM5.3 <http://www.cesm.ucar.edu/models/cesm1.2/cam/docs/ug5_3/>`_. 





