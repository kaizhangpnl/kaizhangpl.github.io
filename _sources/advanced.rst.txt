.. _advanced:

.. `Here <>`_

Advanced configurations of EAM/E3SM 
==================================


`Github  <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/advanced.rst>`_ 
`Spinx  <https://kaizhangpnl.github.io/advanced.html>`_ 


Switching on nudging
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
More detailed information on how to setup a nudged simulation can be found in the 
source code `nudging.F90 <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/src/physics/cam/nudging.F90>`_. 

Note that the nudging file name `Nudge_File_Template` should not be longer than 80
characters. 

.. Switching on Satellite/Aircraft Sampler 
.. ---------------------------------------
.. 
.. under construction 
.. 
 
Switching on aerosol forcing diagnostics
----------------------------------------

Namelist setup :: 

  cat <<EOF >> user_nl_cam
     rad_diag_1 = 'A:Q:H2O', 'N:O2:O2', 'N:CO2:CO2', 'A:O3:O3', 'N:N2O:N2O', 'N:CH4:CH4', 'N:CFC11:CFC11', 'N:CFC12:CFC12', 
  EOF

Then the radiative flux calculated without aerosols are diagnosed 
(with "_d1" appended to the original radiative flux name, e.g. "FSNT_d1"). 

The detailed diagnostic method can be found in `Ghan (2013) <https://www.atmos-chem-phys.net/13/9971/2013/>`_. 

Some information about the AeroCom "Indirect forcing experiment" can be found `here <https://wiki.met.no/aerocom/indirect>`_.  

.. https://github.com/E3SM-Project/E3SM/pull/1400/files
.. https://github.com/E3SM-Project/E3SM/blob/master/components/cam/src/physics/cam/output_aerocom_aie.F90


Changing external forcings
--------------------------

The following changes need to be made after executing "create_newcase". 

- Changing SST, e.g. :: 

  ./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val '$DIN_LOC_ROOT/atm/cam/sst/sst_HadOIBl_bc_1x1_clim_pi_c101029.nc' 
  ./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val '$DIN_LOC_ROOT/atm/cam/sst/sst_HadOIBl_bc_1x1_clim_pi_plus4K.nc'
  
- Changing aerosol emissions, e.g. :: 


Regionally-Refinement Model (RRM) simulations 
--------------------------------------------- 

RRM can be configured by specifying the resolution (e.g. "conusx4v1_conusx4v1") ::

   ./create_newcase -case $MYCASE -project $MYPROJECT -compset FC5AV1C-04P2 -res conusx4v1_conusx4v1 -mach $MYMACH

Some resources are available internally within E3SM: 

- `How to run RRM <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/11010268/How+to+run+the+regionally+refined+model+RRM>`_
- `Regridding RRM simulations <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/27951986/Regridding+RRM+simulations>`_
- `How to perform nudged simulations with RRM <https://acme-climate.atlassian.net/wiki/spaces/Docs/pages/20153276/How+to+perform+nudging+simulations+with+the+regional+refined+model+RRM>`_


Creating ensembles 
--------------------------

In E3SM/EAM, ensembles can be created by perturbing the temperature field in the initial condition 
with a specified magnitude (e.g. ``1.e-14`` K). The implementation will call the random number 
generator (L'Ecuyer, 1996) and create random samples for each grid point: ::  

  cat <<EOF >> user_nl_cam
     pertlim = 1.e-14
     new_random = .true.
     seed_clock = .false.
     seed_custom = 1
  EOF
  
The user can change ``pertlim`` to change the perturbation magnitude and ``seed_custom`` 
to change the seed to the random number generator. 

.. reference 
.. https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/8781864/Ensemble+Simulations+performed+to+document+and+evaluate+the+V0.1-V03+model+configuration


Creating a new compset
----------------------

Following files need to be changed in order to create a new compset: 

- `components/cam/cime_config/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/cime_config/config_compsets.xml>`_ 
- `components/cam/cime_config/config_component.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/cime_config/config_component.xml>`_ 
- `cime/src/drivers/mct/cime_config/config_component_e3sm.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/src/drivers/mct/cime_config/config_component_e3sm.xml>`_ 
- `cime/config/e3sm/allactive/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/allactive/config_compsets.xml>`_ 
- `components/cam/bld/build-namelist <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/build-namelist>`_ 

The namelist configuration files need to be changed too, e.g. : 

- `components/cam/bld/namelist_files/use_cases/1850_cam5_av1c-04p2.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/use_cases/1850_cam5_av1c-04p2.xml>`_ 
- `components/cam/bld/namelist_files/namelist_defaults_cam.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/bld/namelist_files/namelist_defaults_cam.xml>`_ 


A detailed guide based on an older version of E3SM can be found 
`here <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/46891102/How+to+create+a+new+compset>`_. 
Note that some information on that page is obsolete. 


Adding a new parameterization
-----------------------------

Under construction 


Creating new initial condition files
-------------------------------------

Under construction 


Creating new emission files
-----------------------------

Under construction 



Configuration files
--------------------

- `cime/config/e3sm/machines/config_batch.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_batch.xml>`_
- `cime/config/e3sm/machines/config_compilers.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_compilers.xml>`_
- `cime/config/e3sm/allactive/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/allactive/config_compsets.xml>`_
- `components/cam/cime_config/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/cime_config/config_compsets.xml>`_
- `cime/config/e3sm/config_grids.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/config_grids.xml>`_
- `cime/config/e3sm/machines/config_machines.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_machines.xml>`_
- `cime/config/e3sm/allactive/config_pesall.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/allactive/config_pesall.xml>`_
- `cime/config/e3sm/machines/config_pio.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_pio.xml>`_
- `cime/config/e3sm/machines/template.case.run <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/template.case.run>`_

To find out more, search those items in http://esmci.github.io/cime/index.html 


Reference 
----------

Documentation from `CAM5.3 <http://www.cesm.ucar.edu/models/cesm1.2/cam/docs/ug5_3/>`_. 


