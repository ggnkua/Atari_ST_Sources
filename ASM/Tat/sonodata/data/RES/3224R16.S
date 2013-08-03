* ###########################################################################
* #                                                                         #
* #  'ScreensPain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: RGB/TV
* 320*240, 16 Farben, 50.0 Hz, 15625 Hz

        MOVE.L   #$FE00CC,$FFFF8282.W
        MOVE.L   #$280017,$FFFF8286.W
        MOVE.L   #$7800D9,$FFFF828A.W
        MOVE.L   #$2710265,$FFFF82A2.W
        MOVE.L   #$590059,$FFFF82A6.W
        MOVE.L   #$239026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$181,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$0,$FFFF8266.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$50,$FFFF8210.W
