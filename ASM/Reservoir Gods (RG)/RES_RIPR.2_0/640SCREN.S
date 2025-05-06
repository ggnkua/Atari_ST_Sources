* ###########################################################################
* #                                                                         #
* #  'ScreensPain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: RGB/TV
* 

        MOVE.L   #$1FE0128,$FFFF8282.W
        MOVE.L   #$A803F5,$FFFF8286.W
        MOVE.L   #$A601C5,$FFFF828A.W
        MOVE.L   #$24501DF,$FFFF82A2.W
        MOVE.L   #$4F004F,$FFFF82A6.W
        MOVE.L   #$1DF0237,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$400,$FFFF8266.W
        MOVE.W   #$4,$FFFF82C2.W
        MOVE.W   #$28,$FFFF8210.W
