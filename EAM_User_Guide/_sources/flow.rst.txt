.. _flow:


`Github version <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/flow.rst>`_ 

`Spinx version <https://kaizhangpnl.github.io/EAM_User_Guide/flow.html>`_ 

Flow Chart
===========

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
   
   
