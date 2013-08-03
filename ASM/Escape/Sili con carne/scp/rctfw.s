* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 640*400, 16 Farben, 50.0 Hz (interl.), 15625 Hz

        MOVE.L   #$1FE0000,$FFFF8282.W
        MOVE.L   #$1FF005B,$FFFF8286.W
        MOVE.L   #$10C01B3,$FFFF828A.W
        MOVE.L   #$2700139,$FFFF82A2.W
        MOVE.L   #$1370074,$FFFF82A6.W
        MOVE.L   #$204026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$183,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$0,$FFFF8266.W
        MOVE.W   #$6,$FFFF82C2.W
        MOVE.W   #$A0,$FFFF8210.W
