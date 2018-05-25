.. _advanced:


`Github version <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/advanced.rst>`_ 

`Spinx version <https://kaizhangpnl.github.io/EAM_User_Guide/advanced.html>`_ 


Advanced configurations of EAM/E3SM 
==================================

Creating a new compset
----------------------

Under construction 


Adding a new parameterization
-----------------------------

Under construction 


Creating new initial condition files
-------------------------------------

Under construction 


Creating new emission files
-----------------------------

Under construction 


List of tuning parameters 
-------------------------

Below is a list of parameters that are often tuned in EAM. 
Note that only V1 has CLUBB-related parameters.
The csv file is available `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tuning_parameters.csv>`_. 

.. csv-table:: 
   :widths: 15 30 10 10
   :header: "Parameter", "Description", "EAM V0", "EAM V1"
   :file: tuning_parameters.csv


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


