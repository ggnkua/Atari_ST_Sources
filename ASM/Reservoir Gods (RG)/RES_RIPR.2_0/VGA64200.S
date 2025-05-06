* ###########################################################################
* #                                                                         #
* #  'ScreensPain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 

        MOVE.L   #$C6008E,$FFFF8282.W
        MOVE.L   #$160274,$FFFF8286.W
        MOVE.L   #$4D0096,$FFFF828A.W
        MOVE.L   #$41903B9,$FFFF82A2.W
        MOVE.L   #$990099,$FFFF82A6.W
        MOVE.L   #$3B90415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$400,$FFFF8266.W
        MOVE.W   #$9,$FFFF82C2.W
        MOVE.W   #$28,$FFFF8210.W
