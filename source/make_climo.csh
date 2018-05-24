#!/bin/csh
#PBS  -V 
#PBS  -N make_climo
#PBS  -r n 
#PBS  -j oe 
#PBS  -m ae 
#PBS  -S /bin/bash 
#PBS -q acme
#PBS -l nodes=1:ppn=16
#PBS -l walltime=01:59:00

set echo

cd $work 

setenv cs TEST_anvil_FC5AV1C-04P2_ACME_EXP01

setenv W1 $proj/$user/mapping_files
setenv P1 $proj/$user/run/${cs}
setenv P2 $proj/$user/diag_climo/${cs}

setenv M1 ${W1}/map_ne30np4_to_fv129x256_aave.20150901.nc

sh climo_nco.sh -c ${cs} -s 0001 -e 0010 -r ${M1} -i ${P1} -o ${P2}

