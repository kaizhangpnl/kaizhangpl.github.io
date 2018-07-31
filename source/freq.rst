.. _run:


Frequently asked questions
===================


`Github  <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/freq.rst>`_ 
`Spinx  <https://kaizhangpnl.github.io/freq.html>`_ 


Please direct your questions or comments to us by raising an issue 
`here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/issues>`_
and we will try to address them. 


- Problem:

  After a recent rebase with the E3SM V1, the following error occurred in a SCM simulation: :: 
 
     ERROR:
     ice_open_nc: Cannot open /project/projectdirs/acme/inputdata//share/domains/UNS
     ET
 
  Answer: 
  
  The namelist setting for the input data is not correctly configured. 

  #. Check ice_in in the run directory and see if grid_file, kmt_file, and 
     stream_fldfilename are correctly set.
 
  #. SCM is running at T42 originally, so check your cime/config/e3sm/config_grids.xml 
     and/or components/cam/bld/namelist_files/namelist_defaults_cam.xml  
     to see if they have the domain and SST file correctly set.  
 




