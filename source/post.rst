.. _run:



Post-processing 
===================

`Github  <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/post.rst>`_ 
`Spinx  <https://kaizhangpnl.github.io/post.html>`_  




Here lists the diagnostic tools for some quick analysis of the EAM output. More comprehensive 
diagnostics tools are available `here <https://kaizhangpnl.github.io/EAM_User_Guide/diag.html>`_

NCO 
----

See details `here <https://e3sm.org/resources/tools/analysis-tools/nco/>`_

- `NCO on github <https://github.com/nco/nco>`_ 

- `NCO on zenodo <https://zenodo.org/record/1214267#.WxOGloIh1E4>`_ 

- `NCO documentation <http://nco.sf.net/nco.pdf>`_

- `NCO guide by Todd Mitchell <http://research.jisao.washington.edu/data/nco/>`_ 

- Reference: Zender, C. S. (2008), Analysis of self-describing gridded geoscience data with 
             netCDF operators (NCO), Environ. Modell. Softw., 23(10), 1338-1342.  
             `DOI: https://doi.org/10.1016/j.envsoft.2008.03.004 <https://doi.org/10.1016/j.envsoft.2008.03.004>`_

Regridding from SE grid to lat-lon grid  
---------------------------------------

Example: :: 

   $ ncremap -i input.nc -m map_ne30np4_to_fv129x256_aave.20150901.nc -o output.nc 

See details `here <https://acme-climate.atlassian.net/wiki/spaces/SIM/pages/31129737/Generate+Regrid+and+Split+Climatologies+climo+files+with+ncclimo+and+ncremap>`_ (internal) 
   

Making `climo` files 
-----------------------

A script is available 
`here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/make_climo.csh>`_, 
which calls `climo_nco.sh <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/climo_nco.sh>`_ 
to make climo files for E3SM output. 


Bit-Grooming 
------------

Bit-Grooming can reduce EAM output file size by a factor of 2 or more. 
Users can specify the Number of Significant Digits (NSD) to retain, for example: :: 

   % time ncks -7 --ppc default=3 TEST_eos_FC5AV1C-04P_ne120_ne120_20161005_EXP05A.cam.h1.0001-01-02-00000.nc  O1.nc 

   52.26s 


   % time ncks -7 --ppc default=4 TEST_eos_FC5AV1C-04P_ne120_ne120_20161005_EXP05A.cam.h1.0001-01-02-00000.nc  O2.nc 

   1min 1.04s

Note that it's better to do averaging or similar computations before Bit-Grooming. If BG is 
done first, the averaging (or other operations) process could be very slow. 

See details `here <https://acme-climate.atlassian.net/wiki/spaces/ATM/pages/107709358/Compress+and+Bit+Groom+ACME+data>`_ (internal) 


NCL resources 
----------------

- `Examples <https://www.ncl.ucar.edu/Applications/>`_

- `Color table <https://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml>`_ 

- `Font table <https://www.ncl.ucar.edu/Document/Graphics/font_tables.shtml>`_ 

- `Dash pattern <https://www.ncl.ucar.edu/Document/Graphics/Images/dashpatterns.png>`_

- `Marker table <https://www.ncl.ucar.edu/Document/Graphics/Images/markers.png>`_  


CDO resources 
----------------

- `CDO documentation <https://code.mpimet.mpg.de/projects/cdo/embedded/index.html>`_  

- `CDO tutorial <https://code.mpimet.mpg.de/projects/cdo/wiki/Tutorial>`_  

- `CDO FAQ <https://code.mpimet.mpg.de/projects/cdo/wiki/FAQ>`_   


Zstash for archiving 
---------------------

Zstash is a Python-based tool to effectively archive E3SM data on HPSS. 

Zstash documentation is available `here <https://e3sm-project.github.io/zstash/docs/html/index.html>`_. 


