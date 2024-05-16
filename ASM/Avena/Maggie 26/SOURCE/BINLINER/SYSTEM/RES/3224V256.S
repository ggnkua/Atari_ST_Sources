* ###########################################################################
* #                                                                         #
* #  'ScreensPain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 320x240 256 colour, VGA 60Hz

        MOVE.L   #$C6008D,$FFFF8282.W
        MOVE.L   #$15029A,$FFFF8286.W
        MOVE.L   #$7B0096,$FFFF828A.W
        MOVE.L   #$41903AF,$FFFF82A2.W
        MOVE.L   #$8F003D,$FFFF82A6.W
        MOVE.L   #$3FD0415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$10,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$A0,$FFFF8210.W
