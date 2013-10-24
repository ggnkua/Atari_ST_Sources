* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 320*240, 16 Farben, 60.0 Hz, 31470 Hz

        MOVE.L   #$C6008D,$FFFF8282.W
        MOVE.L   #$15028A,$FFFF8286.W
        MOVE.L   #$6B0097,$FFFF828A.W
        MOVE.L   #$41903FF,$FFFF82A2.W
        MOVE.L   #$3F003D,$FFFF82A6.W
        MOVE.L   #$3FD0415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$0,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$50,$FFFF8210.W
