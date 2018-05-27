#!/bin/csh 

setenv P1 /global/u2/k/kaizhang/TMP/TMP/kaizhangpnl.github.io
setenv P1 /Users/${USER}/tools/sphinx/kaizhangpnl.github.io

cp ${P1}/build/html/*       ${P1}/EAM_User_Guide/   
cp ${P1}/source/*.png       ${P1}/EAM_User_Guide/_images/
cp ${P1}/source/*.jpeg       ${P1}/EAM_User_Guide/_images/
cp -rf ${P1}/build/html/_s* ${P1}/EAM_User_Guide/
cd ${P1}

git add * 
git commit -m "update" 
git push origin master 


