~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~   CPU_MOD   for ATARI Falcon 030    ~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        CPU_MOD is a *.MOD player for FALCON 030 ,
        yes , but NOT JUST ANOTHER *.MOD player ...  TRY IT !!!!

        I coded it because I haven't found ANY good player on ATARI
             (e.g.:
              PROTRACKER
              AUDIOSCULPTURE
              ESION
              PAULA
              DESK-TRACKER
              ULTIMATE TRACKER
              50KHZPLAY
              STARPLAY
              NA-TRACKER
              FALCPLAY
              DSP_MOD = VIBRAX = ANOTHER CRUDE PLAYER
              CRAZY MUSIC MACHINE
              DIGITAL030
              ... OUF )

        It sounds different (NORMALLY IN FACT !!!) because it's my own code
        entirely rethinked, and not a code ripped on Amiga and badly converted.

        Of course it has all the sound effects (CIA timing , E-commands ...) ,
        the routine core length is shorter than 7000 bytes long and
        needs 70,000 bytes free only. (You can use it in your programs)


        This directory contains:

        READ_ME.TXT     :This file.
        CPU_MOD.BIN     :The routine usable in yours programs.
        CPU_MODX.TTP    :A TTP-shell , parameter : modulename
                         you can install it with the menu option of the Desktop.

        CPU_MODX.S      :The source in ASM of CPU_MODX.TTP
                         See it for using CPU_MOD.BIN
                         (Even if you are not an assembly programmer you
                          can use the routine in BASIC , C , ... )

        CPU_MODA.ACC    :A ACC-Shell
                        :A PRG-Shell , if you rename it in CPU_MODA.PRG .
                        :A GTP-Shell , if you rename it in CPU_MODA.GTP and
                         install it with the menu option of the Desktop .

        CPU_MODA.RSC    :The ressource file for CPU_MODA.ACC

        SOUNDTRK.TXT    :A file info on module structure.


                         <<<<<<<<<>>>>>>>>>
                         <<< Some Hints >>>
                         <<<<<<<<<>>>>>>>>>


    _There are keyboard short-cuts for CPU_MODA.ACC:

        P       :POWER
        L       :LOAD
        Space   :Play
        -       :Stop
        (       :Song position Reverse Search
        )       :Song position Forward Search
        +       :Fast Forward mode OFF/ON
        .       :Repeat mode OFF/ON
        /       :8 bits/16 bits
        *       :Mono/Stereo
        0       :49170 Hz
        1       :32780 Hz
        2       :24585 Hz
        3       :19668 Hz
        4       :16390 Hz
        5       :12292 Hz
        6       : 9834 Hz
        7       : 8195 Hz
        Return  :Exit


    _The Fast Forward mode respects the construction of the module and read
     all the commands ,
     the Song position Reverse Search and Song position Forward Search : NO
     (It permits to "pass" the levels for Game-module)


    _When you use CPU_MODA.ACC , before changing the screen resolution
     you must be in "Stop" mode , or better in "Power OFF" mode
     to avoid problems.
     (Also for some programs , you will see ...)


    _If the screen displays "Incorrect Module" then
        _The module is packed ... (Depack it !)
        _The module is altered (ripped souce ?)
         Load it with PROTRACKER for example, save it with a DIFFERENT name and
         quit PROTRACKER .
         Take a look at the new length , you will see the amount of missing
         bytes.
         If this amount of bytes is too important (>8 bytes) the last sample(s)
         is (are) altered , Sorry , try to repair it (them) .


        If you are interested in exchange of MODs or Demos for ST(e),F030

        or if you have enjoyed this player you can contact me:


        Patrick RUIZ

        Quartier Le Clos

        13360 , ROQUEVAIRE

        FRANCE

    (other nice program made by myself: ESSAY the lightspeed text editor)

        INTERNET ADDRESS: kirstin@odin.u-3mrs.fr

