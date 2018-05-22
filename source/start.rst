.. _start:



`Github version <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/start.rst>`_ 

`Spinx version <https://kaizhangpnl.github.io/EAM_User_Guide/start.html>`_ 

Getting Started
===============

Quick start guide
------------------

First of all, please read: 

`E3SM Quick Start Guide <https://e3sm.org/model/running-e3sm/e3sm-quick-start/>`_

To checkout code from github, you need to add your public SSH key (on the machine your use) to your GitHub account first. 
See details `here <https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/>`_

You might check if your ssh public key for your machine is associated with github. 
See details `here <https://github.com/settings/keys>`_

Checkout the code::

  Check out the V1 release: 
  
    $ git clone -b maint-1.0 git@github.com:E3SM-Project/E3SM.git

  Or check out the current master:
  
    $ git clone git@github.com:E3SM-Project/E3SM.git
    

  Update the sub-modules:
  
    $ cd E3SM
    $ git submodule update –init

  Create a new branch:
  
    $ git checkout -b username/component/name

Development guide: 

See details `here <https://e3sm.org/model/running-e3sm/developing-e3sm/>`_

.. Flow Chart
.. -----------------
.. 
.. .. figure:: flow_chart.png
..    :scale: 20 %
..    :alt: Flow Chart 
..    :align: center
.. 
..    Diagrams showing the sequence of calculation (i.e., the time integration loop) in EAM. 
..    The blue stadium shapes refer to the resolved-scale dynamics and transport, and 
..    the diamonds refer to the exchange of mass and energy with other model components 
..    (e.g., land and ocean) through the coupler. The rectangular cells are parts of the 
..    physics package that describe the subgrid-scale physical and chemical processes. 
..    The colored boxes indicate parts of EAM that affect the concentrations of water 
..    species; these include the numerical fixers, deep and shallow convection, 
..    turbulent transport, and stratiform cloud macro- and microphysics. 
..    See `Zhang et al. (2018) <https://www.geosci-model-dev-discuss.net/gmd-2017-293/>`_ for more details. 
   
   
