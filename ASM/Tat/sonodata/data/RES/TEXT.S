* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: RGB/TV
* 384*150, 4 Farben, 50.0 Hz, 15625 Hz

        MOVE.L   #$3E0033,$FFFF8282.W
        MOVE.L   #$A0235,$FFFF8286.W
        MOVE.L   #$1E0036,$FFFF828A.W
        MOVE.L   #$2710265,$FFFF82A2.W
        MOVE.L   #$2F00B3,$FFFF82A6.W
        MOVE.L   #$1DF026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$181,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.B   #$1,$FFFF8260.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$30,$FFFF8210.W
