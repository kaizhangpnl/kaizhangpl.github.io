.. _run:



Compiling and running the model
===============================

`Github  <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/run.rst>`_ 
`Spinx  <https://kaizhangpnl.github.io/run.html>`_ 

First of all, please read 

`E3SM Quick Start <https://e3sm.org/model/running-e3sm/e3sm-quick-start/>`_ 

Since EAMv1 is a descendant of CAM5, they share a lot of functionalities. Users are 
encouraged to read the `CAM5.3 user's guide <http://www.cesm.ucar.edu/models/cesm1.2/cam/docs/ug5_3/>`_ 
to obtain more useful information. 


Run script
-----------
A `runscript <https://github.com/E3SM-Project/E3SM/blob/master/run_e3sm.template.csh>`_ 
is available in the E3SM model source code directory (parallel to "cime" and "compoment"). 
For E3SM project members, more example scripts can be found `here (internal) <https://github.com/E3SM-Project/SimulationScripts/>`_. 

It takes several minutes to compile and a dozen of minutes (or more) to run and generate 
log files, so it's good time to grab a coffee and read an abstract!  

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

- ``FC5AV1C-04P2``  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_av1c-04p2.xml>`_ 
 
  V1 atmosphere-only simulation with present-day external forcing. Tuning settings are for the ne30L72 resolution. 

  The present-day external forcing (so-called “year 2000”, mean of 1995-2005) will be used. 
  The anthropogenic aerosol emissions and greenhouse gas concentration are constant. 
  The atmosphere model is coupled with the ELM land model (similar to CLM4.5), and 
  driven by prescribed climatological SST / sea ice cover. 
 
  Note that the tuning setting is slightly different from that used in the DECK simulations. See `List of tuning parameters <https://kaizhangpnl.github.io/flow.html#list-of-tuning-parameters>`_ for details. 

- ``F1850C5AV1C-04P2``  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/1850_cam5_av1c-04p2.xml>`_ 

  V1 atmosphere-only simulation with pre-industrial external forcing. Tuning settings are for the ne30L72 resolution. 
  
- ``FC5``  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_cosp.xml>`_ 

  V0-like atmosphere-only simulation with present-day external forcing. Tuning settings are for the ``ne30L30`` resolution. 
  Note that some tuning parameters need to be changed for version 0.3. 

- ``F1850C5``  `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/1850_cam5.xml>`_ 

  V0-like atmosphere-only simulation with pre-industrial external forcing. Tuning settings are for the ``ne30L30`` resolution. 
  Note that some tuning parameters need to be changed for version 0.3.  

- ``FC5AV1C-H01C`` `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_av1c-h01c.xml>`_ 

  High-resolution (ne120L72) V1 atmosphere-only simulation with present-day external forcing. 

- ``F1850C5AV1C-H01C`` `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/2000_cam5_av1c-h01c.xml>`_ 

  High-resolution (ne120L72) V1 atmosphere-only simulation with  pre-industrial external forcing. 

- ``F20TRC5-CMIP6`` `namelist setup <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/20TR_cam5_CMIP6.xml>`_ 

  V1 atmosphere-only simulation with time-varying 20th-century external forcing from CMIP6. 
  
More information on the DECK compsets is available `here <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/110100741/DECK+compsets>`_. 


Changing spatial resolutions
----------------------------

To change the horizontal resolution, set :: 

  set resolution = ne30_ne30 (or ne4_ne4, ne11_ne11, ne16_ne16, ne120_ne120) 

before executing "create_newcase" 

 
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
 
Switching on COSP simulator
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

More detailed information on how to configure the COSP output can be found in the 
source code `cospsimulator_intr.F90 <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/src/physics/cam/cospsimulator_intr.F90>`_. 

Single column model (SCM) simulations
-------------------------------------

EAM can run in the single column mode. 
Some instructions on how to configure and run a single column model can be found 
`here <https://acme-climate.atlassian.net/wiki/spaces/Docs/pages/128294958/Running+the+ACME+Single+Column+Model>`_. (internal) 

A runscript template can be found `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/scm_runscript.rst>`_. 

IOP forcing data to drive the SCM can be found 
`here <https://acme-climate.atlassian.net/wiki/spaces/Docs/pages/127456636/ACME+Single-Column+Model+Case+Library>`_. (internal) or 
from the E3SM input data server `here <https://acme-svn2.ornl.gov/acme-repo/acme/inputdata/atm/cam/scam/iop/>`_. 


Output data in specified regions
------------------------------------

This functionality is inherited from CESM: 

"List of columns or contiguous columns at which the fincl1 fields will be
output. Individual columns are specified as a string using a longitude
degree (greater or equal to 0.) followed by a single character
(e)ast/(w)est identifer, an underscore '_' , and a latitude degree followed
by a single character (n)orth/(s)outh identifier.  For example, '10e_20n'
would pick the model column closest to 10 degrees east longitude by 20
degrees north latitude.  A group of contiguous columns can be specified
using bounding latitudes and longitudes separated by a colon.  For example,
'10e:20e_15n:20n' would select the model columns which fall with in the
longitude range from 10 east to 20 east and the latitude range from 15
north to 20 north." 


Namelist change: ::

     cat <<EOF >> user_nl_cam
        fincl2 = 'U','V','T','Q','PS' 
        fincl2lonlat = '210e:330e_15n:65n'  ! CONUS 
     EOF
      
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


Specific setup for Constance (PNNL) 
------------------------------------

Add the following to your .cshrc file: :: 

  limit coredumpsize unlimited
  limit stacksize unlimited
  module load python/2.7.8
  module load intel/15.0.1
  module load mvapich2/2.1
  module load netcdf/4.3.2
  module load mkl/15.0.1
  setenv MKL_PATH $MLIB_LIB
  setenv NETCDF_HOME /share/apps/netcdf/4.3.2/intel/15.0.1

A script to configure and make the model on constance is available 
`here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/tree/master/source/make_e3sm_atm.csh>`_.

And contact Balwinder Singh for accessing the E3SM input file directory on Constance. 


Reference 
----------

Documentation from `CAM5.3 <http://www.cesm.ucar.edu/models/cesm1.2/cam/docs/ug5_3/>`_. 





