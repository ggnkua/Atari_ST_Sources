* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 320*200, 16 Farben, 60.0 Hz, 31470 Hz

        MOVE.L   #$170012,$FFFF8282.W
        MOVE.L   #$1020E,$FFFF8286.W
        MOVE.L   #$D0012,$FFFF828A.W
        MOVE.L   #$41903B9,$FFFF82A2.W
        MOVE.L   #$61008D,$FFFF82A6.W
        MOVE.L   #$3AD0415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.B   #$0,$FFFF8260.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$50,$FFFF8210.W
