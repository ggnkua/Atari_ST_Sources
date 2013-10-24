* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 256*160, True Color, 60.0 Hz, 31470 Hz

        MOVE.L   #$C6008D,$FFFF8282.W
        MOVE.L   #$150004,$FFFF8286.W
        MOVE.L   #$6D0097,$FFFF828A.W
        MOVE.L   #$41903FF,$FFFF82A2.W
        MOVE.L   #$3F00DD,$FFFF82A6.W
        MOVE.L   #$35D0415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$100,$FFFF8210.W
