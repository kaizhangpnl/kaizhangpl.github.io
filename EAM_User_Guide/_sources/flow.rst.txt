.. _flow:


`Github version <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/flow.rst>`_ 

`Spinx version <https://kaizhangpnl.github.io/EAM_User_Guide/flow.html>`_ 


Technical overview of EAM 
=========================


Flow Chart
----------

.. figure:: flow_chart.png
   :scale: 20 %
   :alt: Flow Chart 
   :align: center

   Diagrams showing the sequence of calculation (i.e., the time integration loop) in EAM. 
   The blue stadium shapes refer to the resolved-scale dynamics and transport, and 
   the diamonds refer to the exchange of mass and energy with other model components 
   (e.g., land and ocean) through the coupler. The rectangular cells are parts of the 
   physics package that describe the subgrid-scale physical and chemical processes. 
   The colored boxes indicate parts of EAM that affect the concentrations of water 
   species; these include the numerical fixers, deep and shallow convection, 
   turbulent transport, and stratiform cloud macro- and microphysics. 
   See `Zhang et al. (2018) <https://www.geosci-model-dev-discuss.net/gmd-2017-293/>`_ for more details. 
   
   
Spatial resolution
----------------

Technically, EAM can run with horizontal resolution from ne4 (about 750km) to ne120 (about 25km)
(with F1850C5AV1C-04P2 compset).

The vertical resolution is L30 (`lev <./L30.html>`_) for V0 and L72  (`lev <./L72.html>`_) for V1. 
Detailed information about the vertical coordinate in EAMv1 can be found 
`here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/levels.txt>`_ 

   
List of advective tracers 
-------------------------

- `List of advective tracers in EAMv1 <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tracers_adv.txt>`_
 
- `List of advective tracers in EAMv0 <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tracers_adv_EAMv0.txt>`_

List of tuning parameters 
-------------------------

Below is a list of parameters that are often tuned in EAM. 
Note that only V1 has CLUBB-related parameters.
The csv file is available `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tuning_parameters.csv>`_. 

.. csv-table:: 
   :widths: 15 30 10 10
   :header: "Parameter", "Description", "EAM V0", "EAM V1"
   :file: tuning_parameters.csv

