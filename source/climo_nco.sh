#!/bin/bash

# Purpose: Climatology script tailored to ACME guidelines for CAM/CLM output
# This script produces climatological monthly means, seasonal means, annual mean, and optionally regrids all these files

# Author: C. Zender
# Created: 20150526

# Source: https://github.com/ACME-Climate/PreAndPostProcessingScripts/blob/master/generate_climatologies/climo_nco.sh

# Prerequisites: Bash, NCO
# Script could use other shells, e.g., dash (Debian default) after rewriting function definition and looping constructs

# Additional Documentation:
# HowTo: https://acme-climate.atlassian.net/wiki/display/ATM/Generating+Climo+files
# ACME Climatology Requirements: https://acme-climate.atlassian.net/wiki/display/ATM/Climo+Files+-+v0.3+AMIP+runs

# Configure paths at High-Performance Computer Centers (HPCCs) based on ${HOSTNAME}
if [ -z "${HOSTNAME}" ]; then
    if [ -f /bin/hostname ] && [ -x /bin/hostname ]; then
	export HOSTNAME=`/bin/hostname`
    elif [ -f /usr/bin/hostname ] && [ -x /usr/bin/hostname ]; then
	export HOSTNAME=`/usr/bin/hostname`
    fi # !hostname
fi # HOSTNAME
# Default input and output directory is ${DATA}
if [ -z "${DATA}" ]; then
    case "${HOSTNAME}" in 
	cooley* | cc* | mira* ) DATA="/projects/HiRes_EarthSys/${USER}" ; ;; # ALCF cooley compute nodes named ccNNN, 384 GB/node 
	cori* | edison* ) DATA="${SCRATCH}" ; ;; # NERSC cori/edison compute nodes named nidNNNNN, edison 24|64 cores|GB/node; cori 32|128 cores|GB/node
	pileus* ) DATA="/lustre/atlas/world-shared/cli115/${USER}" ; ;; # OLCF CADES
	rhea* | titan* ) DATA="/lustre/atlas/world-shared/cli115/${USER}" ; ;; # OLCF rhea compute nodes named rheaNNN, 128 GB/node
	ys* ) DATA="/glade/p/work/${USER}" ; ;; # NCAR yellowstone compute nodes named ysNNN, 32 GB/node
	* ) DATA='/tmp' ; ;; # Other
    esac # !HOSTNAME
fi # DATA
# Ensure batch jobs access correct 'mpirun' (or, on cori/edison, 'srun') command, netCDF library, and NCO executables and library:
case "${HOSTNAME}" in 
    aims* )
	export PATH='/export/zender1/bin'\:${PATH}
        export LD_LIBRARY_PATH='/export/zender1/lib'\:${LD_LIBRARY_PATH} ; ;;
    cooley* | cc* | mira* )
	# http://www.mcs.anl.gov/hs/software/systems/softenv/softenv-intro.html
	soft add +mvapich2 
        export PBS_NUM_PPN=12 # Spoof PBS on Soft (which knows nothing about node capabilities)
	export PATH='/home/zender/bin'\:${PATH}
	export LD_LIBRARY_PATH='/home/zender/lib'\:${LD_LIBRARY_PATH} ; ;;
    # 20160407: Split cori from edison binary locations to allow for different system libraries
    cori* )
	# 20160420: module load gsl, udunits required for non-interactive batch submissions by Wuyin Lin
	# Not necessary for interactive, nor for CSZ non-interactive, batch submisssions
	# Must be due to home environment differences between CSZ and other users
	# Loading gsl and udunits seems to do no harm, so always do it
	# This is equivalent to LD_LIBRARY_PATH method used for netCDF and SZIP on rhea
	# Why do cori/edison and rhea require workarounds for different packages?
	module load gsl
	module load udunits
	# On cori, module load ncl installs ERWG in ${NCARG_ROOT}/../intel/bin
	if [ -n "${NCARG_ROOT}" ]; then
            export PATH="${NCARG_ROOT}/bin:${PATH}"
	fi # !NCARG_ROOT
	export PATH='/global/homes/z/zender/bin_cori'\:${PATH}
        export LD_LIBRARY_PATH='/global/homes/z/zender/lib_cori'\:${LD_LIBRARY_PATH} ; ;;
    edison* )
	module load gsl
	module load udunits
	export PATH='/global/homes/z/zender/bin_edison'\:${PATH}
        export LD_LIBRARY_PATH='/global/homes/z/zender/lib_edison'\:${LD_LIBRARY_PATH} ; ;;
    pileus* )
	export PATH='/home/zender/bin'\:${PATH}
	export LD_LIBRARY_PATH='/opt/ACME/uvcdat-2.2-build/install/Externals/lib:/home/zender/lib'\:${LD_LIBRARY_PATH} ; ;;
    rhea* )
	# 20151017: CSZ next three lines guarantee finding mpirun
	source ${MODULESHOME}/init/sh # 20150607: PMC Ensures find module commands will be found
	module unload PE-intel # Remove Intel-compiled mpirun environment
	module load PE-gnu # Provides GCC-compiled mpirun environment (CSZ uses GCC to build NCO on rhea)
	# 20160219: CSZ UVCDAT setup causes failures with mpirun, attempting a work-around
	if [ -n "${UVCDAT_SETUP_PATH}" ]; then
	    module unload python ompi paraview PE-intel PE-gnu
	    module load gcc
	    source /lustre/atlas1/cli900/world-shared/sw/rhea/uvcdat/latest_full/bin/setup_runtime.sh
	    export ${UVCDAT_SETUP_PATH}
	fi # !UVCDAT_SETUP_PATH
	# On rhea, module load ncl installs ERWG in ${NCL_DIR}/bin
	if [ -n "${NCL_DIR}" ]; then
            export PATH="${NCL_DIR}/bin:${PATH}"
	fi # !NCL_DIR
        export PATH='/ccs/home/zender/bin_rhea'\:${PATH}
	export LD_LIBRARY_PATH='/sw/redhat6/netcdf/4.3.3.1/rhel6.6_gcc4.8.2--with-dap+hdf4/lib:/sw/redhat6/szip/2.1/rhel6.6_gnu4.8.2/lib:/ccs/home/zender/lib_rhea'\:${LD_LIBRARY_PATH} ; ;;
    titan* )
	source ${MODULESHOME}/init/sh # 20150607: PMC Ensures find module commands will be found
	module load gcc
        export PATH='/ccs/home/zender/bin_titan'\:${PATH}
	export LD_LIBRARY_PATH='/opt/cray/netcdf/4.3.2/GNU/49/lib:/sw/xk6/udunits/2.1.24/sl_gcc4.5.3/lib:/ccs/home/zender/lib_titan'\:${LD_LIBRARY_PATH} ; ;;
    ys* )
	# 20151018: Yellowstone support not yet tested in batch mode
	# On yellowstone, module load ncl installs ERWG in /glade/apps/opt/ncl/6.3.0/intel/12.1.5/bin (not in ${NCARG_ROOT}/bin)
	if [ -n "${NCARG_ROOT}" ]; then
#            export PATH="${NCARG_ROOT}/bin:${PATH}"
            export PATH="${PATH}:/glade/apps/opt/ncl/6.3.0/intel/12.1.5/bin"
	fi # !NCARG_ROOT
        export PATH='/glade/u/home/zender/bin'\:${PATH}
        export LD_LIBRARY_PATH='/glade/apps/opt/netcdf/4.3.0/intel/12.1.5/lib:/glade/u/home/zender/lib'\:${LD_LIBRARY_PATH}
esac # !HOSTNAME

# Production usage:
# chmod a+x ~/PreAndPostProcessingScripts/generate_climatologies/climo_nco.sh
# climo_nco.sh -c famipc5_ne120_v0.3_00003 -s 1980 -e 1983 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne30_v0.3_00003-wget-test -o ${DATA}/ne30/clm
# climo_nco.sh -c famipc5_ne120_v0.3_00003 -s 1980 -e 1983 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne120_v0.3_00003-wget-test -o ${DATA}/ne120/clm
# climo_nco.sh -c B1850C5e1_ne30 -s 2 -e 199 -i /lustre/atlas1/cli115/world-shared/mbranst/B1850C5e1_ne30/atm/hist -o ${DATA}/ne30/clm

# Debugging and Benchmarking:
# climo_nco.sh > ~/climo_nco.out 2>&1 &
# climo_nco.sh -c B1850C5e1_ne30 -s 2 -e 199 > ~/climo_nco.out 2>&1 &
# climo_nco.sh -c ne30_gx1.B1850c5d -s 6 -e 7 > ~/climo_nco.out 2>&1 &
# climo_nco.sh -d 2 -v FSNT -m cam2 -c essgcm14 -s 1 -e 20 -i ${DATA}/essgcm14 -o ${DATA}/anl > ~/climo_nco.out 2>&1 &
# climo_nco.sh -d 2 -x Yes -v FSNT -m cam2 -c essgcm14 -s 1 -e 20 -i ${DATA}/essgcm14 -o ${DATA}/anl > ~/climo_nco.out 2>&1 &
# climo_nco.sh -c famipc5_ne30_v0.3_00003 -s 1980 -e 1983 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne30_v0.3_00003-wget-test -o ${DATA}/ne30/clm > ~/climo_nco.out 2>&1 &
# climo_nco.sh -c famipc5_ne120_v0.3_00003 -s 1980 -e 1983 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne120_v0.3_00003-wget-test -o ${DATA}/ne120/clm > ~/climo_nco.out 2>&1 &
# MPAS: Prior to running climo_nco.sh on MPAS output, annotate missing values of input with, e.g.,
# for fl in `ls hist.*` ; do
#  ncatted -O -t -a _FillValue,,o,d,-9.99999979021476795361e+33 ${fl}
# done
# climo_nco.sh -v temperature -c hist -s 2 -e 3 -m ocn -i /lustre/atlas1/cli112/proj-shared/golaz/ACME_simulations/20160121.A_B2000ATMMOD.ne30_oEC.titan.a00/run -r ${DATA}/maps/map_oEC60to30_to_t62_bilin.20160301.nc -o ${DATA}/mpas/clm > ~/climo_nco.out 2>&1 &
# climo_nco.sh -v iceAreaCell -c hist -s 2 -e 3 -m ice -i /lustre/atlas1/cli112/proj-shared/golaz/ACME_simulations/20160121.A_B2000ATMMOD.ne30_oEC.titan.a00/run -r ${DATA}/maps/map_oEC60to30_to_t62_bilin.20160301.nc -o ${DATA}/mpas/clm > ~/climo_nco.out 2>&1 &

# Best performance on resolutions finer than ne30 (~1x1 degree) requires a job scheduler/batch processor
# Cobalt (cooley), SLURM (cori,edison), Torque (a PBS-variant) (hopper), and PBS (rhea) schedulers allow both interactive and non-interactive (i.e., script) batch jobs
# ALCF Cobalt:
# http://www.alcf.anl.gov/user-guides/using-cobalt-cooley
# https://www.alcf.anl.gov/user-guides/cobalt-job-control
# NERSC SLURM:
# https://www.nersc.gov/users/computational-systems/cori/running-jobs/slurm-introduction
# https://www.nersc.gov/users/computational-systems/cori/running-jobs/for-edison-users/torque-moab-vs-slurm-comparisons
# NERSC Torque:
# https://www.nersc.gov/users/computational-systems/edison/running-jobs/batch-jobs
# https://www.nersc.gov/users/computational-systems/edison/running-jobs/aprun
# OLCF PBS: 
# https://www.olcf.ornl.gov/support/system-user-guides/rhea-user-guide/#903
# Interactive queue: a) Reserve nodes and acquire prompt on control node b) Execute climo_nco.sh command interactively
#   Cooley: qsub -I -A HiRes_EarthSys --nodecount=12 --time=00:30:00 --jobname=climo_nco
#   Cori:   salloc  -A acme --nodes=12 --partition=debug --time=00:30:00 --job-name=climo_nco # NB: 30 minute limit, Edison too
#   Hopper: qsub -I -A acme -V -l mppwidth=288 -l walltime=00:30:00 -q debug -N climo_nco # deprecated, old Edison
#   Rhea:   qsub -I -A CLI115 -V -l nodes=12 -l walltime=00:30:00 -N climo_nco # Bigmem: -l partition=gpu
#   Yellow: fxm # Bigmem: 
# Non-interactive batch procedure: a) Store climo_nco.sh command in climo_nco.[cobalt|pbs] b) qsub climo_nco.[cobalt|pbs]
# Non-interactive batch queue differences (besides argument syntax):
# 1. Cobalt requires an initial 'shebang' line to specify the shell interpreter (not required on PBS)
# 2. Cobalt appends stdout/stderr to existing output files, if any, whereas PBS overwrites existing files
# 3. Cobalt uses ${COBALT_NODEFILE} and (NA) whereas PBS uses ${PBS_NODEFILE} and ${PBS_NUM_PPN}, respectively, and SLURM uses ${SLURM_NODELIST} and ${SLURM_CPUS_ON_NODE}, respectively
# Differences 1 & 2 impose slightly different invocations; difference 3 requires abstracting environment variables
#   Cooley a): /bin/rm -f ~/climo_nco.err  ~/climo_nco.out
#              echo '#!/bin/bash' > ~/climo_nco.cobalt
#              echo "climo_nco.sh -d 1 -p mpi -c b1850c5_m2a -s 0055 -e 0058 -i /home/taylorm/scratch1.qtang/b1850c5_m2a/run -o ${DATA}/ne120/clm" >> ~/climo_nco.cobalt;chmod a+x ~/climo_nco.cobalt
#   Cori,Edison a): echo "climo_nco.sh -a scd -d 1 -p mpi -c AMIP_ACMEv02ce_FC5_ne30_ne30_COSP -s 2008 -e 2012 -i /scratch1/scratchdirs/wlin/archive/AMIP_ACMEv02ce_FC5_ne30_ne30_COSP/atm/hist -o ${DATA}/ne30/clm -r ${DATA}/maps/map_ne30np4_to_fv129x256_aave.20150901.nc" > ~/climo_nco.slurm;chmod a+x ~/climo_nco.slurm
#   Rhea a):   echo "climo_nco.sh -a scd -d 1 -p mpi -c famipc5_ne120_v0.3_00003 -s 1980 -e 1983 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne120_v0.3_00003-wget-test -o ${DATA}/ne120/clm -r ${DATA}/maps/map_ne120np4_to_fv257x512_aave.20150901.nc"  > ~/climo_nco.pbs;chmod a+x ~/climo_nco.pbs
#   Cooley b): qsub -A HiRes_EarthSys --nodecount=12 --time=00:30:00 --jobname climo_nco --error ~/climo_nco.err --output ~/climo_nco.out --notify zender@uci.edu ~/climo_nco.cobalt
#   Cori,Edison b): sbatch -A acme --nodes=12 --time=00:30:00 --partition=regular --job-name=climo_nco --mail-type=END --error=~/climo_nco.err --output=~/climo_nco.out ~/climo_nco.slurm
#   Hopper b): qsub -A acme -V -l mppwidth=288 -l walltime=00:30:00 -q regular -N climo_nco -j oe -m e -o ~/climo_nco.out ~/climo_nco.pbs
#   Rhea b):   qsub -A CLI115 -V -l nodes=12 -l walltime=00:30:00 -N climo_nco -j oe -m e -o ~/climo_nco.out ~/climo_nco.pbs

# Normal use: Set five "mandatory" inputs (caseid, yr_srt, yr_end, drc_in, drc_out), and possibly rgr_map, on command line
# caseid:  Simulation name (filenames must start with ${caseid})
# drc_in:  Input directory for raw data
#          Years outside yr_srt and yr_end are ignored
#          yr_srt should, and for SDD mode must, contain complete year of output
#          SCD mode ignores Jan-Nov of yr_srt
#          Dec of yr_end is excluded from the seasonal and monthly analysis in SCD mode
#          yr_end should, and for SDD mode must, contain complete year of output
# drc_out: Output directory for processed, climatological data ("climo files")
#          User needs write permission for ${drc_out}
# rgr_map: Regridding map, if non-NULL, invoke regridder with specified map on output datasets
#          Pass options intended exclusively for the NCO regridder as arguments to the -R switch
# yr_srt:  Year of first January to analyze
# yr_end:  Year of last  January to analyze

# Other options (often their default settings work well):
# clm_md:  Climatology mode, i.e., how to treat December. One of two options:
#          Seasonally-contiguous-december (SCD) mode (clm_md=scd) (default)
#          Seasonally-discontiguous-december (SDD) mode (clm_md=sdd)
#          Both modes use an integral multiple of 12 months, and _never alter any input files_
#          SCD climatologies begin in Dec of yr_srt-1, and end in Nov of yr_end
#          SDD climatologies begin in Jan of yr_srt,   and end in Dec of yr_end
#          SCD excludes Jan-Nov of yr_srt-1 and Dec of yr_end (i.e., SCD excludes 12 months of available data)
#          SDD uses all months of yr_srt through yr_end (i.e., SDD can use all available data)
#          SCD seasonal averages are inconsistent with (calendar-year-based) annual averages, but better capture seasonal the "natural" (not calendar-year-based) climate year
#          SDD seasonal averages are fully consistent with (calendar-year-based) annual averages
# drc_rgr: Regridding directory---store regridded files, if any, in drc_rgr rather than drc_out
# lnk_flg: Link ACME-climo to AMWG-climo filenames
#          AMWG omits the YYYYMM components of climo filenames, resulting in shorter names
#          This switch (on by default) symbolically links the full (ACME) filename to the shorter (AMWG) name
#          AMWG diagnostics scripts can produce plots directly from these linked filenames
# par_typ: Parallelism type---all values _except_ exact matches to "bck" and "mpi" are interpreted as "nil" (and invoke serial mode)
#          bck = Background: Spawn children (basic blocks) as background processes on control node then wait()
#                Works best when available RAM > 12*4*sizeof(monthly input file), otherwise jobs swap-to-disk
#          mpi = MPI: Spawn children (basic blocks) as MPI processes (one per node in batch environment) then wait()
#                Requires batch system with PBS and MPI. Use when available RAM/node < 12*2.5*sizeof(monthly input file).
#                Optimized for batch with 12 nodes. Factors thereof (6, 4, 3, 2 nodes) should also work.
#                Remember to request 12 nodes if possible!
#          nil = None: Execute script in serial mode on single node
#                Works best when available RAM < 12*4*sizeof(monthly input file), otherwise jobs swap-to-disk
# var_lst: Variables to include, or, with nco_opt='-x', to exclude, in comma-separated list format, e.g.,
#          'FSNT,AODVIS'. Regular expressions work, too: 'AODDUST.?'

# Infrequently used options:
# bnd_nm:  Name of bounds dimension (examples include 'nbnd' (default), 'tbnd' (CAM2, CAM3), 'hist_interval' (CLM2)
# dbg_lvl: 0 = Quiet, print basic status during evaluation
#          1 = Print configuration, full commands, and status to output during evaluation
#          2 = As in dbg_lvl=1, but do not evaluate commands
#          3 = As in dbg_lvl=2, with additional information (mainly for batch queues)
# fml_nm:  Family name (nickname) of output files referring to $fml_nm character sequence used in output climo file names:
#          fml_nm_XX_YYYYMM_YYYYMM.nc (examples include '' (default), 'control', 'experiment')
#          By default, fml_nm=$caseid. Use fml_nm instead of $caseid to simplify long names, avoid overlap, etc.
# hst_nm:  History volume name referring to the $hst_nm character sequence used in history tape names:
#          caseid.mdl_nm.hst_nm.YYYY-MM.nc (examples include 'h0' (default, works for cam, clm), 'h1', 'h' (for cism))
# mdl_nm:  Model name referring to the character sequence $mdl_nm used in history tape names:
#          caseid.mdl_nm.h0.YYYY-MM.nc (examples include 'cam' (default), 'clm2', 'cam2', 'cism', 'pop')
# nco_opt: String of options to pass-through to NCO, e.g.,
#          '-D 2 -7 -L 1' for NCO debugging level 2, netCDF4-classic output, compression level 1
#          '--no_tmp_fl -x' to skip temporary files, turn extraction into exclusion list
# rgr_opt: String of options (besides thread-number) to pass-through exclusively to NCO regridder, e.g., 
#          climo_nco.sh -m clm2 ... -R col_nm=lndgrid -r map.nc ...
# thr_nbr: Thread number to use in NCO regridder, '-t 1' for one thread, '-t 2' for two threads...

# Set script name and run directory
drc_pwd=`pwd` # [sng] Run directory
nco_version=$(ncks --version 2>&1 >/dev/null | grep NCO | awk '{print $5}')
spt_nm=`basename ${0}` # [sng] Script name
spt_pid=$$ # [nbr] Script PID (process ID)

# When running in a terminal window (not in a non-interactive batch queue)...
if [ -n "${TERM}" ]; then
    # Set fonts for legibility
    fnt_nrm=`tput sgr0` # Normal
    fnt_bld=`tput bold` # Bold
    fnt_rvr=`tput smso` # Reverse
fi # !TERM
    
# Defaults for command-line options and some derived variables
# Modify these defaults to save typing later
bnd_nm='nbnd' # [sng] Bounds dimension name (e.g., 'nbnd', 'tbnd')
clm_md='sdd' # [sng] Climatology mode ('scd' or 'sdd' as per above)
caseid='' # [sng] Case ID
caseid_xmp='famipc5_ne30_v0.3_00003' # [sng] Case ID for examples
cf_flg='No' # [sng] Produce CF climatology attribute?
lnk_flg='Yes' # [sng] Link ACME-climo to AMWG-climo filenames
dbg_lvl=0 # [nbr] Debugging level
drc_in='' # [sng] Input file directory
drc_in_xmp="${DATA}/ne30/raw" # [sng] Input file directory for examples
drc_in_mps="${DATA}/mpas/raw" # [sng] Input file directory for MPAS examples
drc_out='' # [sng] Output file directory
drc_out_xmp="${DATA}/ne30/clm" # [sng] Output file directory for examples
drc_out_mps="${DATA}/mpas/clm" # [sng] Output file directory for MPAS examples
drc_rgr='' # [sng] Regridded file directory
drc_rgr_xmp="${DATA}/ne30/rgr" # [sng] Regrid file directory for examples
fml_nm='' # [sng] Family name (i.e., nickname, e.g., 'amip', 'control', 'experiment')
gaa_sng="--gaa climo_script=${spt_nm} --gaa climo_hostname=${HOSTNAME} --gaa climo_version=${nco_version}" # [sng] Global attributes to add
hdr_pad='1000' # [B] Pad at end of header section
hst_nm='h0' # [sng] History volume (e.g., 'h0', 'h1', 'h')
mdl_nm='cam' # [sng] Model name (e.g., 'cam', 'cam2', 'cice', 'cism', 'clm', 'clm2', 'ocn')
mdl_typ='cesm' # [sng] Model type ('cesm' or 'mpas') (for filenames and regridding)
mpi_flg='No' # [sng] Parallelize over nodes
nco_opt='--no_tmp_fl' # [sng] NCO options (e.g., '-7 -D 1 -L 1')
nd_nbr=1 # [nbr] Number of nodes
par_opt='' # [sng] Parallel options to shell
par_typ='nil' # [sng] Parallelism type
rgr_map='' # [sng] Regridding map
#rgr_map="${DATA}/maps/map_ne30np4_to_fv129x256_aave.20150901.nc"
#rgr_map="${DATA}/maps/map_ne30np4_to_fv257x512_bilin.20150901.nc"
#rgr_map="${DATA}/maps/map_ne120np4_to_fv257x512_aave.20150901.nc"
#rgr_map="${DATA}/maps/map_ne120np4_to_fv801x1600_bilin.20150901.nc"
rgr_opt='' # [sng] Regridding options (e.g., '--rgr col_nm=lndgrid', '--rgr col_nm=nCells')
thr_nbr=2 # [nbr] Thread number for regridder
#var_lst='FSNT,AODVIS' # [sng] Variables to process (empty means all)
var_lst='' # [sng] Variables to process (empty means all)
yr_srt='1980' # [yr] Start year
yr_end='1983' # [yr] End year

function fnc_usg_prn { # NB: dash supports fnc_nm (){} syntax, not function fnc_nm{} syntax
    # Print usage
    printf "\nQuick documentation for ${fnt_bld}${spt_nm}${fnt_nrm} (read script for more thorough explanations)\n\n"
    printf "${fnt_rvr}Basic usage:${fnt_nrm} ${fnt_bld}$spt_nm -c caseid -s yr_srt -e yr_end -i drc_in -o drc_out -r rgr_map${fnt_nrm}\n\n"
    echo "Command-line options:"
    echo "${fnt_rvr}-a${fnt_nrm} ${fnt_bld}clm_md${fnt_nrm}   Annual climatology mode (default ${fnt_bld}${clm_md}${fnt_nrm})"
    echo "${fnt_rvr}-b${fnt_nrm} ${fnt_bld}bnd_nm${fnt_nrm}   Bounds dimension name (default ${fnt_bld}${bnd_nm}${fnt_nrm})"
    echo "${fnt_rvr}-c${fnt_nrm} ${fnt_bld}caseid${fnt_nrm}   Case ID string (default ${fnt_bld}${caseid}${fnt_nrm})"
    echo "${fnt_rvr}-d${fnt_nrm} ${fnt_bld}dbg_lvl${fnt_nrm}  Debugging level (default ${fnt_bld}${dbg_lvl}${fnt_nrm})"
    echo "${fnt_rvr}-e${fnt_nrm} ${fnt_bld}yr_end${fnt_nrm}   Ending year (default ${fnt_bld}${yr_end}${fnt_nrm})"
    echo "${fnt_rvr}-f${fnt_nrm} ${fnt_bld}fml_nm${fnt_nrm}   Family name (nickname) (empty means none) (default ${fnt_bld}${fml_nm}${fnt_nrm})"
    echo "${fnt_rvr}-h${fnt_nrm} ${fnt_bld}hst_nm${fnt_nrm}   History volume name (default ${fnt_bld}${hst_nm}${fnt_nrm})"
    echo "${fnt_rvr}-i${fnt_nrm} ${fnt_bld}drc_in${fnt_nrm}   Input directory (default ${fnt_bld}${drc_in}${fnt_nrm})"
    echo "${fnt_rvr}-l${fnt_nrm} ${fnt_bld}lnk_flg${fnt_nrm}  Link ACME-climo to AMWG-climo filenames (default ${fnt_bld}${lnk_flg}${fnt_nrm})"
    echo "${fnt_rvr}-m${fnt_nrm} ${fnt_bld}mdl_nm${fnt_nrm}   Model name (default ${fnt_bld}${mdl_nm}${fnt_nrm})"
    echo "${fnt_rvr}-n${fnt_nrm} ${fnt_bld}nco_opt${fnt_nrm}  NCO options (empty means none) (default ${fnt_bld}${nco_opt}${fnt_nrm})"
    echo "${fnt_rvr}-O${fnt_nrm} ${fnt_bld}drc_rgr${fnt_nrm}  Regridded directory (default ${fnt_bld}${drc_rgr}${fnt_nrm})"
    echo "${fnt_rvr}-o${fnt_nrm} ${fnt_bld}drc_out${fnt_nrm}  Output directory (default ${fnt_bld}${drc_out}${fnt_nrm})"
    echo "${fnt_rvr}-p${fnt_nrm} ${fnt_bld}par_typ${fnt_nrm}  Parallelism type (default ${fnt_bld}${par_typ}${fnt_nrm})"
    echo "${fnt_rvr}-r${fnt_nrm} ${fnt_bld}rgr_map${fnt_nrm}  Regridding map (empty means none) (default ${fnt_bld}${rgr_map}${fnt_nrm})"
    echo "${fnt_rvr}-R${fnt_nrm} ${fnt_bld}rgr_opt${fnt_nrm}  Regridding options (empty means none) (default ${fnt_bld}${rgr_opt}${fnt_nrm})"
    echo "${fnt_rvr}-t${fnt_nrm} ${fnt_bld}thr_nbr${fnt_nrm}  Thread number for regridder (default ${fnt_bld}${thr_nbr}${fnt_nrm})"
    echo "${fnt_rvr}-s${fnt_nrm} ${fnt_bld}yr_srt${fnt_nrm}   Starting year (default ${fnt_bld}${yr_srt}${fnt_nrm})"
    echo "${fnt_rvr}-v${fnt_nrm} ${fnt_bld}var_lst${fnt_nrm}  Variable list (empty means all) (default ${fnt_bld}${var_lst}${fnt_nrm})"
    echo "${fnt_rvr}-x${fnt_nrm} ${fnt_bld}cf_flg${fnt_nrm}   Xperimental switch (for developers) (default ${fnt_bld}${cf_flg}${fnt_nrm})"
    printf "\n"
    printf "Examples: ${fnt_bld}$spt_nm -c ${caseid_xmp} -s ${yr_srt} -e ${yr_end} -i ${drc_in_xmp} -o ${drc_out_xmp} ${fnt_nrm}\n"
    printf "          ${fnt_bld}$spt_nm -c ${caseid_xmp} -s ${yr_srt} -e ${yr_end} -i ${drc_in_xmp} -o ${drc_out_xmp} -r ~zender/data/maps/map_ne30np4_to_fv129x256_aave.20150901.nc ${fnt_nrm}\n"
    printf "          ${fnt_bld}$spt_nm -c control -m clm2 -s ${yr_srt} -e ${yr_end} -i ${drc_in_xmp} -o ${drc_out_xmp} -r ~zender/data/maps/map_ne30np4_to_fv129x256_aave.20150901.nc ${fnt_nrm}\n"
    printf "          ${fnt_bld}$spt_nm -c hist    -m ice  -s ${yr_srt} -e ${yr_end} -i ${drc_in_mps} -o ${drc_out_mps} -r ~zender/data/maps/map_oEC60to30_to_t62_bilin.20160301.nc ${fnt_nrm}\n"
    printf "          ${fnt_bld}$spt_nm -c hist    -m ocn -p mpi -s 1 -e 5 -i ${drc_in_mps} -o ${drc_out_mps} -r ~zender/data/maps/map_oEC60to30_to_t62_bilin.20160301.nc ${fnt_nrm}\n\n"
    printf "Interactive batch queues on ...\n"
    printf "cooley: qsub -I -A HiRes_EarthSys --nodecount=1 --time=00:30:00 --jobname=climo_nco\n"
    printf "cori  : salloc  -A acme --nodes=1 --time=00:30:00 --partition=debug --job-name=climo_nco\n"
    printf "edison: salloc  -A acme --nodes=1 --time=00:30:00 --partition=debug --job-name=climo_nco\n"
    printf "rhea  : qsub -I -A CLI115 -V -l nodes=1 -l walltime=00:30:00 -N climo_nco\n"
    printf "rhea  : qsub -I -A CLI115 -V -l nodes=1 -l walltime=00:30:00 -lpartition=gpu -N climo_nco # Bigmem\n\n"
#    echo "3-yrs  ne30: climo_nco.sh -c famipc5_ne30_v0.3_00003 -s 1980 -e 1982 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne30_v0.3_00003-wget-test -o ${DATA}/ne30/clm -r ~zender/data/maps/map_ne30np4_to_fv129x256_aave.20150901.nc > ~/climo_nco.out 2>&1 &"
#    printf "3-yrs ne120: climo_nco.sh -p mpi -c famipc5_ne120_v0.3_00003 -s 1980 -e 1982 -i /lustre/atlas1/cli115/world-shared/mbranst/famipc5_ne120_v0.3_00003-wget-test -o ${DATA}/ne120/clm -r ~zender/data/maps/map_ne120np4_to_fv257x512_aave.20150901.nc > ~/climo_nco.out 2>&1 &\n\n"
    exit 1
} # end fnc_usg_prn()

function trim_leading_zeros {
    # Purpose: Trim leading zeros from string representing an integer
    # Why, you ask? Because Bash treats zero-padded integers as octal!
    # This is surprisingly hard to workaround
    # My workaround is to remove leading zeros prior to arithmetic
    # Usage: trim_leading zeros ${sng}
    sng_trm=${1} # [sng] Trimmed string
    # Use Bash 2.X pattern matching to remove up to three leading zeros, one at a time
    sng_trm=${sng_trm##0} # NeR98 p. 99
    sng_trm=${sng_trm##0}
    sng_trm=${sng_trm##0}
    # If all zeros removed, replace with single zero
    if [ ${sng_trm} = '' ]; then 
	sng_trm='0'
    fi # endif
} # end trim_leading_zeros()

function cf_clm_att_inq {
    # Is file suitable for adding CF-compliant climatology attribute?
    fl=${1}
    # Does file have "time" dimension+variable=coordinate?
    # Does that coordinate have "time_bnds" (or any time bounds) variable?
    # Does that variable have "nbnd" (or, for clm2, "tbnd") dimension of size 2?
    flg='Yes'
    #flg='No'
} # end cf_clm_att_inq()

function cf_clm_att_put {
    # Annotate with CF-compliant climatology attribute
    bnd_nm=${1}
    fl_srt=${2}
    fl_end=${3}
    fl=${4}
    # NB: time boundary dimension is model-dependent: 'nbnd' for ACME, 'tbnd' for CAM3, 'hist_interval' for CLM2, ...
    # fxm: Generalize name of time bounds variable: 'time_bnds' for ACME, 'time_bounds' for CAM3+CLM2, ...
    time_srt=`ncks -C -H -s %g -v time_bnds -d ${bnd_nm},0 -d time,0 ${fl_srt}`
    time_end=`ncks -C -H -s %g -v time_bnds -d ${bnd_nm},0 -d time,0 ${fl_end}`
    echo "cf time_srt = ${time_srt}"
    echo "cf time_end = ${time_end}"
    ncap2 -O -s "time@climatology=\"climatology_bnds\";climatology_bnds[\$time,\$${bnd_nm}]=0;climatology_bnds(0,0)=${time_srt};climatology_bnds(0,1)=${time_end};time@cell_methods=\"time: mean within years time: mean over years\"" ${fl} ${fl}
    ncatted -O -a bounds,time,d,,, ${fl}
    ncks -O -C -x -v time_bnds ${fl} ${fl}
} # end cf_clm_att_put()

get_spt_drc () {
# SMB (20150814):
# Get calling script location to call other utilities in the PreAndPostProcessingScripts package
# Resolve symlinks in case script is linked elsewhere with technique from
# http://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script
    spt_src="${BASH_SOURCE[0]}"
    # If ${spt_src} is a symlink, resolve it
    while [ -h "${spt_src}" ]; do
	spt_drc="$(cd -P "$(dirname "${spt_src}")" && pwd)"
        spt_src="$(readlink "${spt_src}")"
        # Resolve relative symlinks (no initial "/") against symlink base directory
        [[ ${spt_src} != /* ]] && spt_src="${spt_drc}/${spt_src}"
    done
    spt_drc="$(cd -P "$(dirname "${spt_src}")" && pwd)"
    echo ${spt_drc}
} # end get_spt_drc()

# Check argument number and complain accordingly
arg_nbr=$#
#printf "\ndbg: Number of arguments: ${arg_nbr}"
if [ ${arg_nbr} -eq 0 ]; then
  fnc_usg_prn
fi # !arg_nbr

# Parse command-line options:
# http://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options
# http://tuxtweaks.com/2014/05/bash-getopts
cmd_ln="${spt_nm} ${@}"
while getopts :a:b:c:d:e:f:h:i:l:m:n:O:o:p:R:r:s:t:v:x: OPT; do
    case ${OPT} in
	a) clm_md=${OPTARG} ;; # Climatology mode
	b) bnd_nm=${OPTARG} ;; # Bounds dimension name
	c) caseid=${OPTARG} ;; # CASEID
	d) dbg_lvl=${OPTARG} ;; # Debugging level
	e) yr_end=${OPTARG} ;; # End year
	f) fml_nm=${OPTARG} ;; # Family name
	h) hst_nm=${OPTARG} ;; # History tape name
	i) drc_in=${OPTARG} ;; # Input directory
	l) lnk_flg=${OPTARG} ;; # Link ACME to AMWG name
	m) mdl_nm=${OPTARG} ;; # Model name
	n) nco_opt=${OPTARG} ;; # NCO options
	o) drc_out_usr=${OPTARG} ;; # Output directory
	O) drc_rgr_usr=${OPTARG} ;; # Regridded directory
	p) par_typ=${OPTARG} ;; # Parallelism type
	R) rgr_opt=${OPTARG} ;; # Regridding options
	r) rgr_map=${OPTARG} ;; # Regridding map
	s) yr_srt=${OPTARG} ;; # Start year
	t) thr_usr=${OPTARG} ;; # Thread number
	v) var_lst=${OPTARG} ;; # Variables
	x) cf_flg=${OPTARG} ;; # CF annotation
	\?) # Unrecognized option
	    printf "\nERROR: Option ${fnt_bld}-$OPTARG${fnt_nrm} not allowed"
	    fnc_usg_prn ;;
    esac
done
shift $((OPTIND-1)) # Advance one argument

# Derived variable
if [ -n "${drc_out_usr}" ]; then
    # Fancy %/ syntax removes trailing slash (e.g., from $TMPDIR)
    drc_out="${drc_out_usr%/}"
fi # !drc_out_usr
if [ -n "${drc_rgr_usr}" ]; then 
    drc_rgr="${drc_rgr_usr%/}"
else 
    drc_rgr="${drc_out%/}"
fi # !drc_rgr_usr

# Determine first full year
trim_leading_zeros ${yr_srt}
yr_srt_rth=${sng_trm}
yyyy_srt=`printf "%04d" ${yr_srt_rth}`
let yr_srtm1=${yr_srt_rth}-1
trim_leading_zeros ${yr_end}
yr_end_rth=${sng_trm}
yyyy_end=`printf "%04d" ${yr_end_rth}`
let yr_endm1=${yr_end_rth}-1
let yr_nbr=${yr_end_rth}-${yr_srt_rth}+1

# Derived variables
out_nm=${caseid}
if [ "${caseid}" = 'hist' ]; then
    mdl_typ='mpas'
fi # !caseid
if [ "${mdl_typ}" = 'mpas' ]; then
    out_nm="mpas_${mdl_nm}"
fi # !mdl_typ
if [ -n "${fml_nm}" ]; then 
    out_nm="${fml_nm}"
fi # !fml_nm
if [ "${mdl_nm}" = 'cam2' ]; then
    bnd_nm='tbnd'
fi # !caseid

if [ -n "${gaa_sng}" ]; then
    if [ "${yr_nbr}" -gt 1 ] ; then
	yrs_avg_sng="${yr_srt}-${yr_end}"
    else
	yrs_avg_sng="${yr_srt}"
    fi # !yr_nbr
    gaa_sng="${gaa_sng} --gaa yrs_averaged=${yrs_avg_sng}"
    nco_opt="${nco_opt} ${gaa_sng}"
fi # !var_lst
if [ -n "${var_lst}" ]; then
    nco_opt="${nco_opt} -v ${var_lst}"
fi # !var_lst
if [ -n "${hdr_pad}" ]; then
    nco_opt="${nco_opt} --hdr_pad=${hdr_pad}"
fi # !hdr_pad
if [ "${par_typ}" = 'bck' ]; then 
    par_opt=' &'
    par_opt_cf=''
elif [ "${par_typ}" = 'mpi' ]; then 
    mpi_flg='Yes'
    par_opt=' &'
    par_opt_cf=''
    if [ -n "${UVCDAT_SETUP_PATH}" ]; then
	printf "${spt_nm}: UVCDAT has been initialized in the shell running this job, and MPI-mode parallelization of ${spt_nm} is requested. Unfortunately UVCDAT's environment and the MPI-mode of ${spt_nm} do not play well together. The Workflow group is working toward a solution. The current workarounds are 1) do not use MPI-mode when UVCDAT is loaded or 2) do not initialize UVCDAT when invoking MPI-mode.\n"
    fi # !UVCDAT_SETUP_PATH
fi # !par_typ
if [ -n "${rgr_map}" ]; then 
    if [ ! -e "${rgr_map}" ]; then
	echo "ERROR: Unable to find specified regrid map ${rgr_map}"
	echo "HINT: Supply the full path-name for the regridding map"
	exit 1
    fi # ! -e
    rgr_opt="${rgr_opt} --map ${rgr_map}"
fi # !rgr_map
if [ -n "${thr_usr}" ]; then 
    thr_nbr="${thr_usr}"
fi # !thr_usr
yyyy_clm_srt=${yyyy_srt}
yyyy_clm_end=${yyyy_end}
yyyy_clm_srt_dec=${yyyy_srt}
yyyy_clm_end_dec=${yyyy_end}
mm_ann_srt='01' # [idx] First month used in annual climatology
mm_ann_end='12' # [idx] Last  month used in annual climatology
mm_djf_srt='01' # [idx] First month used in DJF climatology
mm_djf_end='12' # [idx] Last  month used in DJF climatology
yr_cln=${yr_nbr} # [nbr] Calendar years in climatology
if [ ${clm_md} = 'scd' ]; then 
    yyyy_clm_srt_dec=`printf "%04d" ${yr_srtm1}`
    yyyy_clm_end_dec=`printf "%04d" ${yr_endm1}`
    mm_ann_srt='12'
    mm_ann_end='11'
    mm_djf_srt='12'
    mm_djf_end='02'
    let yr_cln=${yr_cln}+1
fi # !scd

# Perform CF annotation?
if [ "${cf_flg}" = 'Yes' ]; then
    # cf_clm_att_inq() overrides user preference
    cf_clm_att_inq ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_srt}-01.nc
    cf_flg=${flg}
fi # !cf

if [ "${mpi_flg}" = 'Yes' ]; then
    if [ -n "${COBALT_NODEFILE}" ]; then 
	nd_fl="${COBALT_NODEFILE}"
    elif [ -n "${PBS_NODEFILE}" ]; then 
	nd_fl="${PBS_NODEFILE}"
    elif [ -n "${SLURM_NODELIST}" ]; then 
	nd_fl="${SLURM_NODELIST}"
    fi # !PBS
    if [ -n "${nd_fl}" ]; then 
	# NB: nodes are 0-based, e.g., [0..11]
	nd_idx=0
	for nd in `cat ${nd_fl} | uniq` ; do
	    nd_nm[${nd_idx}]=${nd}
	    let nd_idx=${nd_idx}+1
	done # !nd
	nd_nbr=${#nd_nm[@]}
	for ((clm_idx=1;clm_idx<=17;clm_idx++)); do
	    case "${HOSTNAME}" in 
		cori* | edison* )
		    # NB: NERSC staff says srun automatically assigns to unique nodes even without "-L $node" argument?
		    cmd_mpi[${clm_idx}]="srun -L ${nd_nm[$(((${clm_idx}-1) % ${nd_nbr}))]} -n 1" ; ;; # NERSC
		hopper* )
		    # NB: NERSC migrated from aprun to srun in 201601. Hopper commands will soon be deprecated.
		    cmd_mpi[${clm_idx}]="aprun -L ${nd_nm[$(((${clm_idx}-1) % ${nd_nbr}))]} -n 1" ; ;; # NERSC
		* )
		    cmd_mpi[${clm_idx}]="mpirun -H ${nd_nm[$(((${clm_idx}-1) % ${nd_nbr}))]} -npernode 1 -n 1" ; ;; # Other
	    esac # !HOSTNAME
	done # !clm_idx
    else # ! pbs
	mpi_flg='No'
	for ((clm_idx=1;clm_idx<=17;clm_idx++)); do
	    cmd_mpi[${clm_idx}]=""
	done # !clm_idx
    fi # !pbs
    if [ -z "${thr_usr}" ]; then 
	if [ -n "${PBS_NUM_PPN}" ]; then
#	NB: use export OMP_NUM_THREADS when thr_nbr > 8
#	thr_nbr=${PBS_NUM_PPN}
	    thr_nbr=$((PBS_NUM_PPN > 8 ? 8 : PBS_NUM_PPN))
	fi # !pbs
    fi # !thr_usr
fi # !mpi

# Print initial state
if [ ${dbg_lvl} -ge 1 ]; then
    printf "dbg: bnd_nm   = ${bnd_nm}\n"
    printf "dbg: caseid   = ${caseid}\n"
    printf "dbg: cf_flg   = ${cf_flg}\n"
    printf "dbg: clm_md   = ${clm_md}\n"
    printf "dbg: dbg_lvl  = ${dbg_lvl}\n"
    printf "dbg: drc_in   = ${drc_in}\n"
    printf "dbg: drc_out  = ${drc_out}\n"
    printf "dbg: drc_pwd  = ${drc_pwd}\n"
    printf "dbg: drc_rgr  = ${drc_rgr}\n"
    printf "dbg: fml_nm   = ${fml_nm}\n"
    printf "dbg: gaa_sng  = ${gaa_sng}\n"
    printf "dbg: hdr_pad  = ${hdr_pad}\n"
    printf "dbg: hst_nm   = ${hst_nm}\n"
    printf "dbg: lnk_flg  = ${lnk_flg}\n"
    printf "dbg: mdl_nm   = ${mdl_nm}\n"
    printf "dbg: mpi_flg  = ${mpi_flg}\n"
    printf "dbg: nco_opt  = ${nco_opt}\n"
    printf "dbg: nd_nbr   = ${nd_nbr}\n"
    printf "dbg: par_typ  = ${par_typ}\n"
    printf "dbg: rgr_map  = ${rgr_map}\n"
    printf "dbg: rgr_sfx  = ${rgr_sfx}\n"
    printf "dbg: thr_nbr  = ${thr_nbr}\n"
    printf "dbg: var_lst  = ${var_lst}\n"
    printf "dbg: yyyy_end = ${yyyy_end}\n"
    printf "dbg: yyyy_srt = ${yyyy_srt}\n"
fi # !dbg
if [ ${dbg_lvl} -ge 2 ]; then
    printf "dbg: yyyy_srt   = ${yyyy_srt}\n"
    printf "dbg: yr_srt_rth = ${yr_srt_rth}\n"
    printf "dbg: yr_srtm1   = ${yr_srtm1}\n"
    printf "dbg: yr_endm1   = ${yr_endm1}\n"
    if [ ${mpi_flg} = 'Yes' ]; then
	for ((nd_idx=0;nd_idx<${nd_nbr};nd_idx++)); do
	    printf "dbg: nd_nm[${nd_idx}] = ${nd_nm[${nd_idx}]}\n"
	done # !nd
    fi # !mpi
fi # !dbg

# Create output directory
mkdir -p ${drc_out}
mkdir -p ${drc_rgr}

# Human-readable summary
date_srt=$(date +"%s")
if [ ${dbg_lvl} -ge 0 ]; then
    printf "Climatology generation invoked with command:\n"
    echo "${cmd_ln}"
fi # !dbg
printf "Started climatology generation for model-run ${caseid} at `date`.\n"
printf "Climatology from ${yr_nbr} years of contiguous data crossing ${yr_cln} calendar years from YYYYMM = ${yyyy_clm_srt_dec}${mm_ann_srt} to ${yyyy_end}${mm_ann_end}.\n"
if [ ${clm_md} = 'scd' ]; then 
    printf "Winter statistics based on seasonally contiguous December (scd-mode): DJF sequences are consecutive months that cross calendar-year boundaries.\n"
else
    printf "Winter statistics based on seasonally discontiguous December (sdd-mode): DJF sequences comprise three months from the same calendar year.\n"
fi # !scd
if [ ${cf_flg} = 'Yes' ]; then 
    printf "Annotation for the CF climatology attribute and climatology_bnds variable will be performed.\n"
else
    printf "Annotation for the CF climatology attribute and climatology_bnds variable will not be performed.\n"
fi # !cf
if [ -n "${rgr_map}" ]; then 
    printf "This climatology will be regridded.\n"
else
    printf "This climatology will not be regridded.\n"
fi # !rgr
printf "NCO version is ${nco_version}\n"

# Block 1: Climatological monthly means
# Block 1 Loop 1: Generate, check, and store (but do not yet execute) monthly commands
printf "Generating climatology...\n"
clm_idx=0
for mth in {01..12}; do
    let clm_idx=${clm_idx}+1
    MM=`printf "%02d" ${clm_idx}`
    yr_fl=''
    for yr in `seq ${yyyy_srt} ${yyyy_end}`; do
	YYYY=`printf "%04d" ${yr}`
	if [ ${mdl_typ} = 'cesm' ]; then
	    yr_fl="${yr_fl} ${caseid}.${mdl_nm}.${hst_nm}.${YYYY}-${MM}.nc"
	else # Use MPAS not CESM conventions
	    yr_fl="${yr_fl} ${caseid}.${mdl_nm}.${YYYY}-${MM}-01_00.00.00.nc"
	fi # !cesm
    done # !yr
    if [ ${clm_md} = 'scd' ] && [ ${MM} = '12' ]; then 
	yr_fl=''
	for yr in `seq ${yr_srtm1} ${yr_endm1}`; do
	    YYYY=`printf "%04d" ${yr}`
	    if [ ${mdl_typ} = 'cesm' ]; then
		yr_fl="${yr_fl} ${caseid}.${mdl_nm}.${hst_nm}.${YYYY}-${MM}.nc"
	    else # Use MPAS not CESM conventions
		yr_fl="${yr_fl} ${caseid}.${mdl_nm}.${YYYY}-${MM}-01_00.00.00.nc"
	    fi # !cesm
	done # !yr
	yyyy_clm_srt=${yyyy_clm_srt_dec}
	yyyy_clm_end=${yyyy_clm_end_dec}
    fi # !scd
    for fl_in in ${yr_fl} ; do
	if [ ! -e "${drc_in}/${fl_in}" ]; then
	    echo "ERROR: Unable to find required input file ${drc_in}/${fl_in}"
	    echo "HINT: All files implied to exist by the climatology bounds (start/end year/month) must be in ${drc_in} before ${spt_nm} will proceed"
	    exit 1
	fi # ! -e
    done # !fl_in
    fl_out[${clm_idx}]="${drc_out}/${out_nm}_${MM}_${yyyy_clm_srt}${MM}_${yyyy_clm_end}${MM}_climo.nc"
    cmd_clm[${clm_idx}]="${cmd_mpi[${clm_idx}]} ncra -O ${nco_opt} -p ${drc_in} ${yr_fl} ${fl_out[${clm_idx}]}"
    cmd_cf[${clm_idx}]="cf_clm_att_put ${bnd_nm} ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_clm_srt}-${MM}.nc ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_clm_end}-${MM}.nc ${fl_out[${clm_idx}]} ${par_opt_cf}"
done # !mth

# Monthly output filenames constructed above; specify remaining (seasonal, annual) output names
fl_out[13]="${drc_out}/${out_nm}_MAM_${yyyy_srt}03_${yyyy_end}05_climo.nc"
fl_out[14]="${drc_out}/${out_nm}_JJA_${yyyy_srt}06_${yyyy_end}08_climo.nc"
fl_out[15]="${drc_out}/${out_nm}_SON_${yyyy_srt}09_${yyyy_end}11_climo.nc"
fl_out[16]="${drc_out}/${out_nm}_DJF_${yyyy_clm_srt_dec}${mm_djf_srt}_${yyyy_end}${mm_djf_end}_climo.nc"
fl_out[17]="${drc_out}/${out_nm}_ANN_${yyyy_clm_srt_dec}${mm_ann_srt}_${yyyy_end}${mm_ann_end}_climo.nc"
# Derive all seventeen regridded and AMWG names from output names
for ((clm_idx=1;clm_idx<=17;clm_idx++)); do
    fl_amwg[${clm_idx}]=`expr match "${fl_out[${clm_idx}]}" '\(.*\)_.*_.*_climo.nc'` # Prune _YYYYYMM_YYYYMM_climo.nc
    fl_amwg[${clm_idx}]="${fl_amwg[${clm_idx}]}_climo.nc" # Replace with _climo.nc
    fl_amwg[${clm_idx}]="${fl_amwg[${clm_idx}]/${drc_out}\//}" # Delete prepended path to ease symlinking
    if [ -n "${rgr_map}" ]; then
	fl_rgr[${clm_idx}]="${fl_out[${clm_idx}]/${drc_out}/${drc_rgr}}"
	if [ "${drc_out}" = "${drc_rgr}" ]; then 
	    # Append geometry suffix to regridded files in same directory as native climo
	    # http://tldp.org/LDP/abs/html/string-manipulation.html
	    dfl_sfx='rgr'
	    rgr_sfx=`expr match "${rgr_map}" '.*_to_\(.*\).nc'`
	    if [ "${#rgr_sfx}" -eq  0 ]; then
		printf "${spt_nm}: WARNING Unable to extract geometric suffix from mapfile, will suffix regridded files with \"${dfl_sfx}\" instead\n"
		rgr_sfx=${dfl_sfx}
	    else
		yyyymmdd_sng=`expr match "${rgr_sfx}" '.*\(\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)'` # Find YYYYYMMDD
		if [ "${#yyyymmdd_sng}" -ne  0 ]; then
		    rgr_sfx=${rgr_sfx%%${yyyymmdd_sng}} # Delete YYYYYMMDD
		fi # !strlen
	    fi # !strlen
	    #    rgr_sfx=`expr match "${rgr_sfx}" '\(.*\)\.[0-9][0-9][0-9][0-9][0-9][0-9]'` # 
	    fl_rgr[${clm_idx}]="${fl_rgr[${clm_idx}]/.nc/_${rgr_sfx}.nc}"
	fi # !drc_rgr
    fi # !rgr_map
done # !clm_idx
    
# Block 1 Loop 2: Execute and/or echo monthly climatology commands
for ((clm_idx=1;clm_idx<=12;clm_idx++)); do
    printf "Climatological monthly mean for month ${clm_idx} ...\n"
    if [ ${dbg_lvl} -ge 1 ]; then
	echo ${cmd_clm[${clm_idx}]}
    fi # !dbg
    if [ ${dbg_lvl} -le 1 ]; then
	if [ -z "${par_opt}" ]; then
	    eval ${cmd_clm[${clm_idx}]}
	    if [ $? -ne 0 ]; then
		printf "${spt_nm}: ERROR monthly climo cmd_clm[${clm_idx}] failed. Debug this:\n${cmd_clm[${clm_idx}]}\n"
		exit 1
	    fi # !err
	else # !par_opt
	    eval ${cmd_clm[${clm_idx}]} ${par_opt} # eval always returns 0 on backgrounded processes
	    clm_pid[${clm_idx}]=$!
	    # Potential alternatives to eval:
#	eval "${cmd_clm[${clm_idx}]}" # borken
#       ${cmd_clm[${clm_idx}]} # borken
#       "${cmd_clm[${clm_idx}]}" # borken
#	exec "${cmd_clm[${clm_idx}]}" # borken
#	$(${cmd_clm[${clm_idx}]}) # borken
#	$("${cmd_clm[${clm_idx}]}") # works (when & inside cmd quotes)
	fi # !par_opt
    fi # !dbg
done # !clm_idx
if [ -n "${par_opt}" ]; then
    for ((clm_idx=1;clm_idx<=12;clm_idx++)); do
	wait ${clm_pid[${clm_idx}]}
	if [ $? -ne 0 ]; then
	    printf "${spt_nm}: ERROR monthly climo cmd_clm[${clm_idx}] failed. Debug this:\n${cmd_clm[${clm_idx}]}\n"
	    exit 1
	fi # !err
    done # !clm_idx
fi # !par_opt

# Block 1 Loop 3: Execute and/or echo monthly CF commands
if [ ${cf_flg} = 'Yes' ]; then
    for ((clm_idx=1;clm_idx<=12;clm_idx++)); do
	if [ ${dbg_lvl} -ge 1 ]; then
	    echo ${cmd_cf[${clm_idx}]}
	fi # !dbg
	if [ ${dbg_lvl} -le 1 ]; then
	    ${cmd_cf[${clm_idx}]}
	fi # !dbg
    done # !clm_idx
fi # !cf_flg
wait

# Block 1: Loop 4: Regrid first twelve files. Load-balance by using idle nodes (nodes not used for seasonal climatologies).
if [ -n "${rgr_map}" ]; then 
    printf "Regrid monthly data...\n"
    for ((clm_idx=1;clm_idx<=12;clm_idx++)); do
	# NB: Months, seasons, files are 1-based ([1..12], [13..16], [1..17]), nodes are 0-based ([0..11])
	let nd_idx=$(((clm_idx-1+4) % nd_nbr))
	if [ ${nd_idx} -lt 4 ]; then
	    let nd_idx=${nd_idx}+4
	fi # !nd
	cmd_rgr[${clm_idx}]="${cmd_mpi[${nd_idx}]} ncks -t ${thr_nbr} -O ${nco_opt} ${rgr_opt} ${fl_out[${clm_idx}]} ${fl_rgr[${clm_idx}]}"
	if [ "${mdl_typ}" = 'mpas' ]; then
	    cmd_rgr[${clm_idx}]="${cmd_mpi[${nd_idx}]} ncremap -C -u .pid${spt_pid}.climo.${clm_idx}.tmp -P mpas -t ${thr_nbr} -m ${rgr_map} -i ${fl_out[${clm_idx}]} -o ${fl_rgr[${clm_idx}]}"
	fi # !mdl_typ
	if [ ${dbg_lvl} -ge 1 ]; then
	    echo ${cmd_rgr[${clm_idx}]}
	fi # !dbg
	if [ ${dbg_lvl} -le 1 ]; then
	    if [ -z "${par_opt}" ]; then
		eval ${cmd_rgr[${clm_idx}]}
		if [ $? -ne 0 ]; then
		    printf "${spt_nm}: ERROR monthly regrid cmd_rgr[${clm_idx}] failed. Debug this:\n${cmd_rgr[${clm_idx}]}\n"
		    exit 1
		fi # !err
	    else # !par_opt
		eval ${cmd_rgr[${clm_idx}]} ${par_opt}
		rgr_pid[${clm_idx}]=$!
	    fi # !par_opt
	fi # !dbg
    done 
    # Start seasonal means first, then wait() for monthly regridding to finish
fi # !rgr_map

# Block 2: Climatological seasonal means
# Block 2 Loop 1: Generate seasonal commands
printf "Climatological seasonal means...\n"
cmd_clm[13]="${cmd_mpi[13]} ncra -O -w 31,30,31 ${nco_opt} ${fl_out[3]} ${fl_out[4]} ${fl_out[5]} ${fl_out[13]}"
cmd_clm[14]="${cmd_mpi[14]} ncra -O -w 30,31,31 ${nco_opt} ${fl_out[6]} ${fl_out[7]} ${fl_out[8]} ${fl_out[14]}"
cmd_clm[15]="${cmd_mpi[15]} ncra -O -w 30,31,30 ${nco_opt} ${fl_out[9]} ${fl_out[10]} ${fl_out[11]} ${fl_out[15]}"
cmd_clm[16]="${cmd_mpi[16]} ncra -O -w 31,31,28 ${nco_opt} ${fl_out[12]} ${fl_out[1]} ${fl_out[2]} ${fl_out[16]}"

# PMC: next line hacks code to use AMWG weights instead of NCO weights
#printf "MAJOR KLUDGE: FORCING USE OF AMWG WTS!!!"
#cmd_clm[13]="${cmd_mpi[13]} ncra -O --no_nrm -w 0.3369565308094025,0.3260869681835175,0.3369565308094025 ${nco_opt} ${fl_out[3]} ${fl_out[4]} ${fl_out[5]} ${fl_out[13]}"
#cmd_clm[14]="${cmd_mpi[14]} ncra -O --no_nrm -w 0.3260869681835175,0.3369565308094025,0.3369565308094025 ${nco_opt} ${fl_out[6]} ${fl_out[7]} ${fl_out[8]} ${fl_out[14]}"
#cmd_clm[15]="${cmd_mpi[15]} ncra -O --no_nrm -w 0.32967033,0.34065934,0.32967033 ${nco_opt} ${fl_out[9]} ${fl_out[10]} ${fl_out[11]} ${fl_out[15]}"
#cmd_clm[16]="${cmd_mpi[16]} ncra -O --no_nrm -w 0.3444444537162781,0.3444444537162781,0.3111111223697662 ${nco_opt} ${fl_out[12]} ${fl_out[1]} ${fl_out[2]} ${fl_out[16]}"

# Block 2 Loop 2: Execute and/or echo seasonal climatology commands
for ((clm_idx=13;clm_idx<=16;clm_idx++)); do
    if [ ${dbg_lvl} -ge 1 ]; then
	echo ${cmd_clm[${clm_idx}]}
    fi # !dbg
    if [ ${dbg_lvl} -le 1 ]; then
	if [ -z "${par_opt}" ]; then
	    eval ${cmd_clm[${clm_idx}]}
	    if [ $? -ne 0 ]; then
		printf "${spt_nm}: ERROR seasonal climo cmd_clm[${clm_idx}] failed. Debug this:\n${cmd_clm[${clm_idx}]}\n"
		exit 1
	    fi # !err
	else # !par_opt
	    eval ${cmd_clm[${clm_idx}]} ${par_opt}
	    clm_pid[${clm_idx}]=$!
	fi # !par_opt
    fi # !dbg
done # !clm_idx
# wait() for monthly regridding, if any, to finish
if [ -n "${rgr_map}" ]; then 
    if [ -n "${par_opt}" ]; then
	for ((clm_idx=1;clm_idx<=12;clm_idx++)); do
	    wait ${rgr_pid[${clm_idx}]}
	    if [ $? -ne 0 ]; then
		printf "${spt_nm}: ERROR monthly regrid cmd_rgr[${clm_idx}] failed. Debug this:\n${cmd_rgr[${clm_idx}]}\n"
		exit 1
	    fi # !err
	done # !clm_idx
    fi # !par_opt
fi # !rgr_map
# wait() for seasonal climatologies to finish
if [ -n "${par_opt}" ]; then
    for ((clm_idx=13;clm_idx<=16;clm_idx++)); do
	wait ${clm_pid[${clm_idx}]}
	if [ $? -ne 0 ]; then
	    printf "${spt_nm}: ERROR seasonal climo cmd_clm[${clm_idx}] failed. Debug this:\n${cmd_clm[${clm_idx}]}\n"
	    exit 1
	fi # !err
    done # !clm_idx
fi # !par_opt

# Block 2 Loop 3: Execute and/or echo seasonal CF commands
if [ ${cf_flg} = 'Yes' ]; then
    cmd_cf[13]="cf_clm_att_put ${bnd_nm} ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_srt}-03.nc ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_end}-05.nc ${fl_out[13]} ${par_opt_cf}"
    cmd_cf[14]="cf_clm_att_put ${bnd_nm} ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_srt}-06.nc ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_end}-08.nc ${fl_out[14]} ${par_opt_cf}"
    cmd_cf[15]="cf_clm_att_put ${bnd_nm} ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_srt}-09.nc ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_end}-11.nc ${fl_out[15]} ${par_opt_cf}"
    cmd_cf[16]="cf_clm_att_put ${bnd_nm} ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_clm_srt_dec}-${mm_djf_srt}.nc ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_end}-${mm_djf_end}.nc ${fl_out[16]} ${par_opt_cf}"
    for ((clm_idx=13;clm_idx<=16;clm_idx++)); do
	if [ ${dbg_lvl} -ge 1 ]; then
	    echo ${cmd_cf[${clm_idx}]}
	fi # !dbg
	if [ ${dbg_lvl} -le 1 ]; then
	    ${cmd_cf[${clm_idx}]}
	fi # !dbg
    done # !clm_idx    
fi # !cf_flg
wait

# Block 2: Loop 4: Regrid seasonal files. Load-balance by using idle nodes (nodes not used for annual mean).
if [ -n "${rgr_map}" ]; then 
    printf "Regrid seasonal data...\n"
    for ((clm_idx=13;clm_idx<=16;clm_idx++)); do
	let nd_idx=$(((clm_idx-1+4) % nd_nbr))
	if [ ${nd_idx} -lt 4 ]; then
	    let nd_idx=${nd_idx}+4
	fi # !nd
	cmd_rgr[${clm_idx}]="${cmd_mpi[${nd_idx}]} ncks -t ${thr_nbr} -O ${nco_opt} ${rgr_opt} ${fl_out[${clm_idx}]} ${fl_rgr[${clm_idx}]}"
	if [ "${mdl_typ}" = 'mpas' ]; then
	    cmd_rgr[${clm_idx}]="${cmd_mpi[${nd_idx}]} ncremap -C -u .pid${spt_pid}.climo.${clm_idx}.tmp -P mpas -t ${thr_nbr} -m ${rgr_map} -i ${fl_out[${clm_idx}]} -o ${fl_rgr[${clm_idx}]}"
	fi # !mdl_typ
	if [ ${dbg_lvl} -ge 1 ]; then
	    echo ${cmd_rgr[${clm_idx}]}
	fi # !dbg
	if [ ${dbg_lvl} -le 1 ]; then
	    if [ -z "${par_opt}" ]; then
		eval ${cmd_rgr[${clm_idx}]}
		if [ $? -ne 0 ]; then
		    printf "${spt_nm}: ERROR seasonal regrid cmd_rgr[${clm_idx}] failed. Debug this:\n${cmd_rgr[${clm_idx}]}\n"
		    exit 1
		fi # !err
	    else # !par_opt
		eval ${cmd_rgr[${clm_idx}]} ${par_opt}
		rgr_pid[${clm_idx}]=$!
	    fi # !par_opt
	fi # !dbg
    done 
    # Start annual mean first, then wait() for seasonal regridding to finish
fi # !rgr_map

# Block 3: Climatological annual mean (seventeenth file)
printf "Climatological annual mean...\n"
cmd_clm[17]="${cmd_mpi[17]} ncra -O -w 92,92,91,90 ${nco_opt} ${fl_out[13]} ${fl_out[14]} ${fl_out[15]} ${fl_out[16]} ${fl_out[17]}"
if [ ${dbg_lvl} -ge 1 ]; then
    echo ${cmd_clm[17]}
fi # !dbg
if [ ${dbg_lvl} -le 1 ]; then
    if [ -z "${par_opt}" ]; then
	eval ${cmd_clm[17]}
	if [ $? -ne 0 ]; then
	    printf "${spt_nm}: ERROR annual climo cmd_clm[17] failed. Debug this:\n${cmd_clm[17]}\n"
	    exit 1
	fi # !err
    else # !par_opt
	eval ${cmd_clm[17]} ${par_opt}
	clm_pid[17]=$!
    fi # !par_opt
fi # !dbg
# wait() for seasonal regridding, if any, to finish
if [ -n "${rgr_map}" ]; then 
    if [ -n "${par_opt}" ]; then
	for ((clm_idx=13;clm_idx<=16;clm_idx++)); do
	    wait ${rgr_pid[${clm_idx}]}
	    if [ $? -ne 0 ]; then
		printf "${spt_nm}: ERROR seasonal regrid cmd_rgr[${clm_idx}] failed. Debug this:\n${cmd_rgr[${clm_idx}]}\n"
		exit 1
	    fi # !err
	done # !clm_idx
    fi # !par_opt
fi # !rgr_map
# wait() for annual climatology to finish
if [ -n "${par_opt}" ]; then
    wait ${clm_pid[17]}
    if [ $? -ne 0 ]; then
	printf "${spt_nm}: ERROR annual climo cmd_clm[17] failed. Debug this:\n${cmd_clm[17]}\n"
	exit 1
    fi # !err
fi # !par_opt

if [ ${cf_flg} = 'Yes' ]; then
    cmd_cf[17]="cf_clm_att_put ${bnd_nm} ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_clm_srt_dec}-${mm_ann_srt}.nc ${drc_in}/${caseid}.${mdl_nm}.${hst_nm}.${yyyy_end}-${mm_ann_end}.nc ${fl_out[17]} ${par_opt_cf}"
    if [ ${dbg_lvl} -ge 1 ]; then
	echo ${cmd_cf[17]}
    fi # !dbg
    if [ ${dbg_lvl} -le 1 ]; then
	${cmd_cf[17]}
    fi # !dbg
fi # !cf_flg
wait

# Block 5: Regrid climatological annual mean
if [ -n "${rgr_map}" ]; then 
    printf "Regrid annual data...\n"
    for ((clm_idx=17;clm_idx<=17;clm_idx++)); do
	cmd_rgr[${clm_idx}]="${cmd_mpi[${clm_idx}]} ncks -t ${thr_nbr} -O ${nco_opt} ${rgr_opt} ${fl_out[${clm_idx}]} ${fl_rgr[${clm_idx}]}"
	if [ "${mdl_typ}" = 'mpas' ]; then
	    cmd_rgr[${clm_idx}]="${cmd_mpi[${clm_idx}]} ncremap -C -u .pid${spt_pid}.climo.${clm_idx}.tmp -P mpas -t ${thr_nbr} -m ${rgr_map} -i ${fl_out[${clm_idx}]} -o ${fl_rgr[${clm_idx}]}"
	fi # !mdl_typ
	if [ ${dbg_lvl} -ge 1 ]; then
	    echo ${cmd_rgr[${clm_idx}]}
	fi # !dbg
	if [ ${dbg_lvl} -le 1 ]; then
	    # NB: Do not background climatological mean regridding
	    eval ${cmd_rgr[${clm_idx}]}
	    if [ $? -ne 0 ]; then
		printf "${spt_nm}: ERROR annual regrid cmd_rgr[${clm_idx}] failed. Debug this:\n${cmd_rgr[${clm_idx}]}\n"
		exit 1
	    fi # !err
	fi # !dbg
    done 
fi # !rgr_map

# Link ACME-climo to AMWG-climo filenames
# drc_pwd is always fully qualified path but drc_out and drc_rgr may be relative paths
# Strategy: Start in drc_pwd, cd to drc_rgr, then link so return code comes from ln not cd
if [ ${lnk_flg} = 'Yes' ]; then
    printf "Link ACME-climo to AMWG-climo filenames...\n"
    for ((clm_idx=1;clm_idx<=17;clm_idx++)); do
	if [ -n "${rgr_map}" ]; then 
	    cmd_lnk[${clm_idx}]="cd ${drc_pwd};cd ${drc_rgr};ln -s -f ${fl_rgr[${clm_idx}]/${drc_rgr}\//} ${fl_amwg[${clm_idx}]/${drc_rgr}\//}"
	else
	    cmd_lnk[${clm_idx}]="cd ${drc_pwd};cd ${drc_out};ln -s -f ${fl_out[${clm_idx}]/${drc_out}\//} ${fl_amwg[${clm_idx}]/${drc_out}\//}"
	fi # !rgr_map
	if [ ${dbg_lvl} -ge 1 ]; then
	    echo ${cmd_lnk[${clm_idx}]}
	fi # !dbg
	if [ ${dbg_lvl} -le 1 ]; then
	    eval ${cmd_lnk[${clm_idx}]}
	    if [ $? -ne 0 ]; then
		printf "${spt_nm}: ERROR linking ACME to AMWG filename cmd_lnk[${clm_idx}] failed. Debug this:\n${cmd_lnk[${clm_idx}]}\n"
		exit 1
	    fi # !err
	fi # !dbg
    done # !clm_idx
    cd ${drc_pwd}
fi # !lnk_flg
    
date_end=$(date +"%s")
printf "Completed climatology generation for model-run ${caseid} at `date`.\n"
date_dff=$((date_end-date_srt))
if [ -n "${rgr_map}" ]; then 
    echo "Quick plots of regridded climatological annual mean: ncview ${fl_rgr[17]} &"
else
    echo "Quick plots of climatological annual mean: ncview ${fl_out[17]} &"
fi # !rgr_map    
echo "Elapsed time $((date_dff/60))m$((date_dff % 60))s"

# PMC: add SMB's Git (SHA1) hash info to climo files
# Assumes utility to add Git hash resides in ../utils/add_git_hash_to_netcdf_metadata
for ((clm_idx=1;clm_idx<=17;clm_idx++)); do
    fl_out_lst="${fl_out_lst} ${fl_out[${clm_idx}]}"
done
spt_drc=$(get_spt_drc)
if [ ${dbg_lvl} -ge 1 ]; then
    echo "Script is in directory: ${spt_drc}"
fi # !dbg
# CSZ: 20150826 disable until less fragile (than relative path) solution is found 
#cd ${spt_drc}
# ../utils/add_git_hash_to_netcdf_metadata ${fl_out_lst}

exit 0





