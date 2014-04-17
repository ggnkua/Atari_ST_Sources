* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: RGB/TV
* 320*200, 16 Farben, 59.5 Hz, 15594 Hz

        MOVE.L   #$3E0032,$FFFF8282.W
        MOVE.L   #$A0004,$FFFF8286.W
        MOVE.L   #$1D0036,$FFFF828A.W
        MOVE.L   #$20D0201,$FFFF82A2.W
        MOVE.L   #$170043,$FFFF82A6.W
        MOVE.L   #$1D30207,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$183,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.B   #$0,$FFFF8260.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$50,$FFFF8210.W
