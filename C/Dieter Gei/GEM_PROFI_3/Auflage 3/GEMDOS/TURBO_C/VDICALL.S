*      VDICALL.S
*
*      for vdicalls


*>>>>>> Export references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .EXPORT vdi

*>>>>>> Import references <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .IMPORT contrl
        .IMPORT intin
        .IMPORT ptsin
        .IMPORT intout
        .IMPORT ptsout

*>>>>>> Data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .BSS

*>>>>>>> Initialized data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .DATA

pblock: .DC.L contrl
        .DC.L intin
        .DC.L ptsin
        .DC.L intout
        .DC.L ptsout

*>>>>>>> Code segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .CODE

******** VDI ************************************************************

vdi:     MOVE.L #pblock,D1
         MOVE.W #$73,D0
         TRAP   #2
         RTS

******** Module end *****************************************************

        .END

