#!/bin/csh 

setenv P1 /global/u2/k/${USER}/TMP/TMP/kaizhangpnl.github.io
setenv P1 /Users/${USER}/tools/sphinx/kaizhangpnl.github.io
setenv P2 /Users/${USER}/tools/sphinx/kaizhangpnl.github.io/EAM_User_Guide

cp ${P1}/build/html/*       ${P1}/
cp ${P1}/source/*.png       ${P1}/_images/
cp ${P1}/source/*.jpeg      ${P1}/_images/
cp -rf ${P1}/build/html/_s* ${P1}/
cd ${P1}

git add * 

cp ${P1}/build/html/*       ${P2}/
cp ${P1}/source/*.png       ${P2}/_images/
cp ${P1}/source/*.jpeg      ${P2}/_images/
cp -rf ${P1}/build/html/_s* ${P2}/
cd ${P2}

git add * 

git commit -m "copy stuff to root directory" 
git push origin master 


