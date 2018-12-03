.. _flow:


Technical overview of EAM 
=========================


`Github  <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/flow.rst>`_ 
`Spinx  <https://kaizhangpnl.github.io/flow.html>`_ 



CIME in E3SM
-----------------

E3SM uses CIME (Common Infrastructure for Modeling the Earth), which contains the support 
scripts (configure, build, run, test), data models, essential utility libraries, a “main” 
and other tools that are needed to build a single-executable coupled Earth System Model. 

CIME documentation is available `here <http://esmci.github.io/cime/>`_. 



Flow chart
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
   See `Zhang et al. (2018) <https://www.geosci-model-dev.net/11/1971/2018/gmd-11-1971-2018.html>`_ for more details. 
   
   
Spatial resolution
----------------

Technically, EAM can run with horizontal resolution from ``ne4`` (about 750km) to ``ne120`` (about 25km)
(with F1850C5AV1C-04P2 compset): 

#. ``ne4_ne4 (~750km)``
#. ``ne11_ne11 (~280km)`` 
#. ``ne16_ne16 (~190km)`` 
#. ``ne30_ne30 (~100km)`` 
#. ``ne120_ne120 (~25km)`` 


The vertical resolution is L30 (`lev <./L30.html>`_) for V0 and L72  (`lev <./L72.html>`_) for V1. 
Detailed information about the vertical coordinate in EAMv1 can be found 
`here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/levels.txt>`_ : :: 

  ID    hyai      hyam      hybi      hybm      P_int     P_full 
  --    ------    ------    ------    ------    ------    ------
  1     0.1000              0.0000              0.1000                    <--- layer interface 
                  0.1238              0.0000              0.1238          <--- layer center
  2     0.1477              0.0000              0.1477          
                  0.1828              0.0000              0.1828
  3     0.2180              0.0000              0.2180
                  0.2699              0.0000              0.2699
  4     0.3219              0.0000              0.3219
                  0.3986              0.0000              0.3986
  5     0.4753              0.0000              0.4753
                  0.5885              0.0000              0.5885
  6     0.7017              0.0000              0.7017
                  0.8689              0.0000              0.8689
  7     1.0361              0.0000              1.0361
                  1.2830              0.0000              1.2830
  8     1.5299              0.0000              1.5299
                  1.8944              0.0000              1.8944
  9     2.2588              0.0000              2.2588
                  2.7970              0.0000              2.7970
  10    3.3352              0.0000              3.3352
                  4.1298              0.0000              4.1298
  11    4.9245              0.0000              4.9245
                  5.9684              0.0000              5.9684
  12    7.0124              0.0000              7.0124
                  8.3774              0.0000              8.3774
  13    9.7424              0.0000              9.7424
                 11.4738              0.0000             11.4738
  14   13.2052              0.0000             13.2052
                 15.3339              0.0000             15.3339
  15   17.4627              0.0000             17.4627
                 19.9963              0.0000             19.9963
  16   22.5300              0.0000             22.5300
                 25.4447              0.0000             25.4447
  17   28.3594              0.0000             28.3594
                 31.5933              0.0000             31.5933
  18   34.8271              0.0000             34.8271
                 38.3663              0.0000             38.3663
  19   41.9055              0.0000             41.9055
                 45.6712              0.0000             45.6712
  20   49.4369              0.0000             49.4369
                 53.3096              0.0000             53.3096
  21   57.1822              0.0000             57.1822
                 61.0152              0.0000             61.0152
  22   64.8482              0.0000             64.8482
                 68.4764              0.0000             68.4764
  23   72.1046              0.0000             72.1046
                 75.3553              0.0000             75.3553
  24   78.6061              0.0000             78.6061
                 81.9463              0.0000             81.9463
  25   85.2865              0.0000             85.2865
                 88.9105              0.0000             88.9105
  26   92.5346              0.0000             92.5346
                 96.4667              0.0000             96.4667
  27  100.3987              0.0000            100.3987
                104.6650              0.0000            104.6650
  28  108.9312              0.0000            108.9312
                113.5600              0.0000            113.5600
  29  118.1888              0.0000            118.1888
                123.2110              0.0000            123.2110
  30  128.2332              0.0000            128.2332
                133.6822              0.0000            133.6822
  31  139.1312              0.0000            139.1312
                145.0433              0.0000            145.0433
  32  150.9554              0.0000            150.9554
                157.3699              0.0000            157.3699
  33  163.7844              0.0000            163.7844
                170.7441              0.0000            170.7441
  34  177.7038              0.0000            177.7038
                178.5448              6.7101            185.2549
  35  179.3858             13.4202            192.8061
                177.5309             23.4681            200.9989
  36  175.6759             33.5159            209.1918
                173.6633             44.4177            218.0810
  37  171.6507             55.3194            226.9702
                169.4671             67.1477            236.6148
  38  167.2835             78.9759            246.2594
                164.9142             91.8094            256.7237
  39  162.5450            104.6429            267.1880
                159.9745            118.5671            278.5416
  40  157.4039            132.4913            289.8952
                154.6149            147.5988            302.2136
  41  151.8259            162.7063            314.5321
                148.7998            179.0977            327.8975
  42  145.7738            195.4891            341.2629
                142.4905            213.2736            355.7641
  43  139.2073            231.0581            370.2654
                135.6451            250.3540            385.9990
  44  132.0828            269.6499            401.7327
                128.2178            290.5857            418.8035
  45  124.3528            311.5214            435.8743
                120.1594            334.2364            454.3958
  46  115.9659            356.9515            472.9174
                111.5393            380.9292            492.4686
  47  107.1127            404.9070            512.0198
                102.6706            428.9689            531.6395
  48   98.2285            453.0308            551.2593
                 93.8440            476.7809            570.6249
  49   89.4594            500.5311            589.9905
                 85.2361            523.4077            608.6438
  50   81.0128            546.2842            627.2970
                 76.9323            568.3877            645.3200
  51   72.8517            590.4912            663.3429
                 68.9676            611.5304            680.4980
  52   65.0835            632.5697            697.6532
                 61.4493            652.2553            713.7046
  53   57.8151            671.9410            729.7561
                 54.4827            689.9922            744.4748
  54   51.1502            708.0434            759.1936
                 48.1685            724.1943            772.3628
  55   45.1869            740.3452            785.5321
                 42.6011            754.3516            796.9527
  56   40.0154            768.3580            808.3734
                 37.8655            780.0033            817.8688
  57   35.7157            791.6486            827.3643
                 33.9653            801.1299            835.0952
  58   32.2149            810.6111            842.8261
                 30.6674            818.9938            849.6612
  59   29.1199            827.3766            856.4964
                 27.6074            835.5690            863.1764
  60   26.0950            843.7614            869.8564
                 24.6201            851.7505            876.3706
  61   23.1453            859.7396            882.8849
                 21.7103            867.5124            889.2227
  62   20.2754            875.2853            895.5606
                 18.8827            882.8292            901.7118
  63   17.4900            890.3731            907.8631
                 16.1418            897.6757            913.8175
  64   14.7937            904.9783            919.7720
                 13.4923            912.0274            925.5197
  65   12.1910            919.0766            931.2675
                 10.9386            925.8604            936.7990
  66    9.6862            932.6442            942.3305
                  8.4849            939.1512            947.6362
  67    7.2837            945.6582            952.9419
                  6.1356            951.8772            958.0128
  68    4.9875            958.0962            963.0837
                  3.8945            964.0166            967.9111
  69    2.8015            969.9370            972.7385
                  1.7656            975.5485            977.3141
  70    0.7296            981.1600            981.8896
                  0.3648            985.8405            986.2053
  71    0.0000            990.5210            990.5210
                  0.0000            993.7570            993.7570
  72    0.0000            996.9929            996.9929
                  0.0000            998.4964            998.4964
  73    0.0000           1000.0000           1000.0000


Temporal resolution 
--------------------

The table below shows the model time step used in the default EAMv1 
(FC5AV1C-04P2 compset for ne11, ne16, and ne30; FC5AV1C-H01C compset for ne120) 
at different model resolutions. 
Modified from `Zhang et al. (2018) <https://www.geosci-model-dev.net/11/1971/2018/gmd-11-1971-2018.html>`_.  

.. figure:: timestepping.jpeg
   :scale: 40%
   :alt: Time stepping in EAMv1. 
   :align: center

Time stepping 
--------------------

A hybrid method is used to couple the physics and dynamics. 
For the fluid dynamics variables (temperature, winds, and surface pressure), 
physics tendencies are applied as a constant source term for dynamics 
in each of the dynamical (se_nsplit) sub-steps. 
For ne30/ne120, the coupling frequency is 900s/225s. 
For water vapor, liquid- and ice-phase condensate, and all other advected tracers, 
the hard adjustment is used and the coupling frequency is 30min/15min for ne30/ne120.
 
Radiation is called every hour for both ne30 and ne120. The radiation 
tendency (calculated hourly) is re-used at each model time step (e.g. 30min for ne30).
 
CLUBB and MG2 are substepped together with 5min time step. 
There is no internal CLUBB sub-cycle if dt_clubb_mg2 <= 5min. 
There is no internal MG2 subcycle either (except for sedimentation part, 
which is dynamically substepped). The CLUBB-MG2 loop is coupled with the 
host model at each model physics time step (e.g. 30min for ne30). 
CLUBB/MG2 doesn’t update the state variable directly (physics_update is used). 
If CLUBB/MG2 internal subcycles exist, the output tendency is the time-averaged tendency.
 
In the atmosphere-only simulation, the surface fields are updated at each 
atm-physics time step (30min for ne30) through the coupler. The land model 
uses the same time step.
 
In the coupled model, the coupling frequency is the same for the atmosphere 
and land model. For the ocean model, the coupling frequency is 30min for ne30 
and 30min or 1h for ne120 (depending on grid setup - oRRS15to5 versus oRRS18to6) 
in the current version. 
 
   
   
List of advective tracers 
-------------------------

- `List of advective tracers in EAMv1 <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tracers_adv.txt>`_ : :: 

         Name      Description                                   Type
         ------    ----------------------------------------      ----- 
     1   Q         Specific humidity                             wet
     2   CLDLIQ    Grid box averaged cloud liquid amount         wet
     3   CLDICE    Grid box averaged cloud ice amount            wet
     4   NUMLIQ    Grid box averaged cloud liquid number         wet
     5   NUMICE    Grid box averaged cloud ice number            wet
     6   RAINQM    Grid box averaged rain amount                 wet
     7   SNOWQM    Grid box averaged snow amount                 wet
     8   NUMRAI    Grid box averaged rain number                 wet
     9   NUMSNO    Grid box averaged snow number                 wet
     10  O3        O3                                            dry
     11  H2O2      H2O2                                          dry
     12  H2SO4     H2SO4                                         dry
     13  SO2       SO2                                           dry
     14  DMS       DMS                                           dry
     15  SOAG      SOAG                                          dry
     16  so4_a1    so4_a1                                        dry
     17  pom_a1    pom_a1                                        dry
     18  soa_a1    soa_a1                                        dry
     19  bc_a1     bc_a1                                         dry
     20  dst_a1    dst_a1                                        dry
     21  ncl_a1    ncl_a1                                        dry
     22  mom_a1    mom_a1                                        dry
     23  num_a1    num_a1                                        dry
     24  so4_a2    so4_a2                                        dry
     25  soa_a2    soa_a2                                        dry
     26  ncl_a2    ncl_a2                                        dry
     27  mom_a2    mom_a2                                        dry
     28  num_a2    num_a2                                        dry
     29  dst_a3    dst_a3                                        dry
     30  ncl_a3    ncl_a3                                        dry
     31  so4_a3    so4_a3                                        dry
     32  bc_a3     bc_a3                                         dry
     33  pom_a3    pom_a3                                        dry
     34  soa_a3    soa_a3                                        dry
     35  mom_a3    mom_a3                                        dry
     36  num_a3    num_a3                                        dry
     37  pom_a4    pom_a4                                        dry
     38  bc_a4     bc_a4                                         dry
     39  mom_a4    mom_a4                                        dry
     40  num_a4    num_a4                                        dry


- `List of advective tracers in EAMv0 <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tracers_adv_EAMv0.txt>`_ : :: 


         Name      Description                                   Type
         ------    ----------------------------------------      ----- 
     1   Q         Specific humidity                             wet
     2   CLDLIQ    Grid box averaged cloud liquid amount         wet
     3   CLDICE    Grid box averaged cloud ice amount            wet
     4   NUMLIQ    Grid box averaged cloud liquid number         wet
     5   NUMICE    Grid box averaged cloud ice number            wet
     6   H2O2      H2O2                                          dry
     7   H2SO4     H2SO4                                         dry
     8   SO2       SO2                                           dry
     9   DMS       DMS                                           dry
     10  SOAG      SOAG                                          dry
     11  so4_a1    so4_a1                                        dry
     12  pom_a1    pom_a1                                        dry
     13  soa_a1    soa_a1                                        dry
     14  bc_a1     bc_a1                                         dry
     15  dst_a1    dst_a1                                        dry
     16  ncl_a1    ncl_a1                                        dry
     17  num_a1    num_a1                                        dry
     18  so4_a2    so4_a2                                        dry
     19  soa_a2    soa_a2                                        dry
     20  ncl_a2    ncl_a2                                        dry
     21  num_a2    num_a2                                        dry
     22  dst_a3    dst_a3                                        dry
     23  ncl_a3    ncl_a3                                        dry
     24  so4_a3    so4_a3                                        dry
     25  num_a3    num_a3                                        dry




List of tuning parameters 
-------------------------

Below is a list of parameters that are often tuned in EAM V0 (FC5), 
V1 default (FC5AV1C-04P2 or FC5AV1C-L), and V1 with the DECK tuning for AMIP simulations. 
Note that only V1 has CLUBB-related parameters.
The csv file is available `here <https://github.com/kaizhangpnl/kaizhangpnl.github.io/blob/master/source/tuning_parameters.csv>`_. 

.. csv-table:: 
   :widths: 15 30 10 10 10 
   :header: "Parameter", "Description", "EAM V0", "EAM V1", "EAM V1 (DECK)"
   :file: tuning_parameters.csv

