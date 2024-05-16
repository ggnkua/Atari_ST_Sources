* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 320*100, True Color, 99.0 Hz, 31470 Hz

        MOVE.L   #$FC00B4,$FFFF8282.W
        MOVE.L   #$1A0014,$FFFF8286.W
        MOVE.L   #$8700C0,$FFFF828A.W
        MOVE.L   #$27B0211,$FFFF82A2.W
        MOVE.L   #$8F0085,$FFFF82A6.W
        MOVE.L   #$2150277,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$182,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W
