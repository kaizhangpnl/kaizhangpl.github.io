.. _run:



Model output
========================


`Github  <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/output.rst>`_ 
`Spinx  <https://kaizhangpnl.github.io/EAM_User_Guide/output.html>`_ 


.. Example from CAM5: 
.. 
.. http://www.cesm.ucar.edu/models/cesm1.2/cam/docs/ug5_3/hist_flds_fv_cam5.html


Size of h0 (monthly mean) files
--------------------------------

The storage needed for a single level global field is about 0.2M (single precision) for ne30 
and 3M for ne120. 

Below is a list of h0 files sizes for different model component: :: 

   6.1G  *.cam.h0.2010-01.nc
    56M  *.clm2.h0.2010-01.nc
     4M  *.rtm.h0.2010-01.nc


Size of restart files
--------------------------------

Below is a list of restart files sizes for different model component: :: 

   6.3G  *.cam.r.2010-01-01-00000.nc
    13M  *.cice.r.2010-01-01-00000.nc
   751M  *.clm2.r.2010-01-01-00000.nc
   401K  *.clm2.rh0.2010-01-01-00000.nc
    96M  *.cpl.r.2010-01-01-00000.nc
    11K  *.docn.rs1.2010-01-01-00000.bin
    16M  *.rtm.r.2010-01-01-00000.nc
   109K  *.rtm.rh0.2010-01-01-00000.nc
 
Storage needed for a one-year simulation
-----------------------------------------
Based on the sizes of h0 files and restart files, the estimated storage cost for a 
one-year simulation is about 14G. 


Variables in the default h0 file
--------------------------------

The list of variables in the default h0 file can be found `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/output_h0.csv>`_. 

.. The list below can be changed by modifying the csv table and recompile the doc 
.. (https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/output_h0.csv). 
..
.. .. csv-table:: 
..    :widths: 5 15 12 5 40
..    :header: "Index", "Name", "Unit", "Dimension", "Longname & Notes"
..    :file: output_h0.csv

Variables on the master list 
---------------------------- 

under construction 

Variables lists for special diagnostics  
--------------------------------------

under construction 


NetCDF header from DECK simulations 
----------------------------

The NetCDF header of the h0 file from the DECK simulations can be found `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/info_h0>`_. 

.. .. literalinclude:: info_h0

Aerosol mass concentration output
-----------------------------------

EAMv1 output the total mass concentration (sum of mass in different modes) 
of different compositions (both interstitial and cloud-borne masses are included): ::  

    Mass_bc  = bc_a1  + bc_c1  + bc_a3  + bc_c3  + bc_a4  + bc_c4
    Mass_pom = pom_a1 + pom_c1 + pom_a3 + pom_c3 + pom_a4 + pom_c4
    Mass_mom = mom_a1 + mom_c1 + mom_a2 + mom_c2 + mom_a3 + mom_c3 + mom_a4 + mom_c4
    Mass_ncl = ncl_a1 + ncl_c1 + ncl_a2 + ncl_c2 + ncl_a3 + ncl_c3
    Mass_soa = soa_a1 + soa_c1 + soa_a2 + soa_c2 + soa_a3 + soa_c3
    Mass_so4 = so4_a1 + so4_c1 + so4_a2 + so4_c2 + so4_a3 + so4_c3
    Mass_dst = dst_a1 + dst_c1 + dst_a3 + dst_c3 


Reference 
----------

Documentation from `CAM5.3 <http://www.cesm.ucar.edu/models/cesm1.2/cam/docs/ug5_3/>`_. 

