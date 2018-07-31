#!/bin/csh
date

set echo verbose


set fetch_code    = 0   # 0 = No, >0 = Yes
set compile_model = 1   # 0 = No, >0 = Yes
set run_model     = 0   # 0 = No, >0 = Yes

####################################################################
# First, you should checkout the E3SM code following instructions
# here: 
#    https://kaizhangpnl.github.io/start.html#quick-start-guide
####################################################################
setenv CCSMTAG E3SM
setenv CCSMROOT $HOME/model/$CCSMTAG

####################################################################
# Machine, compset, PE layout etc.
####################################################################

setenv COMPSET FC5AV1C-04P2
setenv RESOLUTION ne30_ne30
setenv MACH      constance
setenv PTMP      /pic/scratch/$user/bld

setenv ntasks 960
setenv nthrds 1

setenv CASESRC   nothing
setenv MYSRC     ${CCSMROOT}/mods_$CASESRC

setenv CASE     TEST_${MACH}_${COMPSET}_${RESOLUTION}_${CCSMTAG}_960p
setenv COMCASE  TEST_${MACH}_${COMPSET}_${RESOLUTION}_${CCSMTAG}_960p

setenv CASEROOT  ${CCSMROOT}/cases/$CASE
setenv RUNDIR    /pic/scratch/$user/csmruns/$CASE

####################################################################
# Compile model
####################################################################
if ($compile_model > 0) then

   rm -rf $CASEROOT
   cd  $CCSMROOT/cime/scripts

   ./create_newcase --case $CASEROOT --mach $MACH --project UQ_CLIMATE \
                    --res $RESOLUTION --compset $COMPSET

#====================================================================
# set up case
#====================================================================

   ###./create_newcase -list grids

   cd $CASEROOT

   ./xmlchange -file env_run.xml   -id RUNDIR  -val $RUNDIR
   ./xmlchange -file env_build.xml -id EXEROOT -val $PTMP/$COMCASE/bld/

   ./xmlchange -file env_mach_pes.xml -id NTASKS_ATM -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_ATM -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_ATM -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_LND -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_LND -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_LND -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_ROF -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_ROF -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_ROF -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_ICE -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_ICE -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_ICE -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_OCN -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_OCN -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_OCN -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_GLC -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_GLC -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_GLC -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_WAV -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_WAV -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_WAV -val '0'

   ./xmlchange -file env_mach_pes.xml -id NTASKS_CPL -val $ntasks
   ./xmlchange -file env_mach_pes.xml -id NTHRDS_CPL -val $nthrds
   ./xmlchange -file env_mach_pes.xml -id ROOTPE_CPL -val '0'

   ./case.setup

#====================================================================
# my mods of source code
#====================================================================
cd $CASEROOT

ln -s ${MYSRC}/* SourceMods/src.cam    # put your mods in here



./xmlchange -file env_build.xml -id CAM_CONFIG_OPTS -append -val ' -cosp'

   # Build the model

   cd $CASEROOT

   ./case.build

###  ./xmlchange -file env_build.xml -id BUILD_COMPLETE  -val 'TRUE'

endif

#####################################################################
# Conduct simulation
#####################################################################
if ($run_model > 0) then

#------------------
## set environment
#------------------

cd $CASEROOT

./xmlchange  -file env_run.xml  -id  RUN_STARTDATE   -val '0000-01-01'
./xmlchange  -file env_run.xml  -id  RESUBMIT        -val '0'
##./xmlchange  -file env_run.xml  -id  CONTINUE_RUN    -val 'TRUE'
./xmlchange  -file env_run.xml  -id  STOP_N          -val '1'
./xmlchange  -file env_run.xml  -id  STOP_OPTION     -val 'ndays'
./xmlchange  -file env_run.xml  -id  REST_N          -val '1'
./xmlchange  -file env_run.xml  -id  REST_OPTION     -val 'ndays'
./xmlchange  -file env_run.xml  -id  DOUT_S          -val 'FALSE'

cat <<EOF >! user_nl_cam
&camexp
!!inithist = 'DAILY'
nhtfrq  = 0,-3 !!,-3
mfilt   = 1,1   !!,1
fincl2  = 'PS',
          'U',
          'V',
          'T',
          'Q',
          'QFLX',
          'PRECC',
          'PRECL',
          'PRECSC',
          'PRECSL',
          'LHFLX',
          'SHFLX',
          'FLNT',
          'FSNT',
          'FLNS',
          'FSNS',
          'SST',
          'TS',
avgflag_pertape(2) = 'A'
/
EOF

./$CASE.submit

endif

