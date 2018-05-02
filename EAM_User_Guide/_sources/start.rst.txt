.. _start:


Getting Started
===============

Quick start guide: 
------------------

https://e3sm.org/model/running-e3sm/e3sm-quick-start/

To checkout code from github, you need to add your public SSH key (on the machine your use) to your GitHub account first.  
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

You might check if your ssh public key for your machine is associated with github
https://github.com/settings/keys

Checkout the code::

  Check out the V1 release: 
    $ git clone -b maint-1.0 git@github.com:E3SM-Project/E3SM.git

  Or check out the current master: 
    $ git clone git@github.com:E3SM-Project/E3SM.git
    
    
    $ cd E3SM

  Update the sub-modules: 
    $ git submodule update –init

  Create a new branch:
    $ git checkout -b username/component/name

Development guide: 

https://e3sm.org/model/running-e3sm/developing-e3sm/

Flow Chart
-----------------

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
   See Zhang et al. (2018) for more details. 
   
   