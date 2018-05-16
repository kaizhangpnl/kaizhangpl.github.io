.. _advanced:


Advanced configurations of EAM/E3SM 
==================================

Creating a new compset
----------------------

Under construction 


Adding a new parameterization
-----------------------------

Under construction 


Create new initial condition files
----------------------------------

Under construction 


Create new emission files
-------------------------

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


Under construction 


Configurations files
--------------------

- config_batch.xml    
   
     `cime/config/e3sm/machines/config_batch.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_batch.xml>`_
   
- config_compilers.xml
   
     `cime/config/e3sm/machines/config_compilers.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_compilers.xml>`_
   
- config_compsets.xml
   
     `cime/config/e3sm/allactive/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/allactive/config_compsets.xml>`_
     `components/cam/cime_config/config_compsets.xml <https://github.com/E3SM-Project/E3SM/blob/master/components/cam/cime_config/config_compsets.xml>`_
   
- config_grids.xml

     `cime/config/e3sm/config_grids.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/config_grids.xml>`_

- config_machines.xml 
   
     `cime/config/e3sm/machines/config_machines.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_machines.xml>`_
   
- config_pesall.xml 
   
     `cime/config/e3sm/allactive/config_pesall.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/allactive/config_pesall.xml>`_
   
- config_pio.xml 
   
     `cime/config/e3sm/machines/config_pio.xml <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/config_pio.xml>`_

- template.case.run 
   
     `cime/config/e3sm/machines/template.case.run <https://github.com/E3SM-Project/E3SM/blob/master/cime/config/e3sm/machines/template.case.run>`_

To find out more, search those items in http://esmci.github.io/cime/index.html 


