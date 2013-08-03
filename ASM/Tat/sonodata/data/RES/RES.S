* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: RGB/TV
* 192*120, True Color, 50.0 Hz, 15625 Hz

        MOVE.L   #$C700A0,$FFFF8282.W
        MOVE.L   #$1F0033,$FFFF8286.W
        MOVE.L   #$5B00AB,$FFFF828A.W
        MOVE.L   #$2710265,$FFFF82A2.W
        MOVE.L   #$2F0059,$FFFF82A6.W
        MOVE.L   #$239026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$85,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$1,$FFFF82C2.W
        MOVE.W   #$C0,$FFFF8210.W
