                EXPORT  appl_init, aes, _GemParBlk, contrl, global
                EXPORT  intin, intout, ptsout, addrin, addrout, ptsin

appl_init:      move.l  #$0A000100,D0           ;ACHTUNG, fÑllt durch!

***************************************************************************
* AES-Aufruf, Original von Markus Fritze, bearbeitet von Marcel Waldvogel *
*                                                                         *
* D0=Die ersten 4 EintrÑge im contrl-Array (Bytebreite!)                  *
*    Bit 24-31 = Der Opcode bzw. die Funktionsnummer                      *
*    Bit 16-23 = Anzahl der EintrÑge in int_in                            *
*    Bit 8-15  = Anzahl der EintrÑge in int_out                           *
*    Bit 0-7   = Anzahl der EintrÑge in addr_in                           *
* Die Anzahl der EintrÑge in addr_out ist stets 0.                        *
* Ausnahme:Bei rsrc_gaddr() dort sollte dort eine 1 stehen (Atari hÑlt    *
*          sich allerdings selbst nicht dran)                             *
***************************************************************************
aes:            lea     contrl,A0
                clr.l   (A0)+
                clr.l   (A0)+           ;contrl-Array lîschen
                clr.w	(A0)
                movep.l D0,-7(A0)       ;und die neuen Daten eintragen
                lea     aespb(PC),A0
                move.l  A0,D1
                move.w  #$C8,D0
                trap    #2              ;AES aufrufen
                moveq   #0,D0
                lea     intout,A0
                move.w  (A0)+,D0        ;D0 und A0 zurÅckgeben
                rts

*               DATA

aespb:          DC.L    contrl, global, intin, intout, addrin, addrout

                BSS

                EVEN
_GemParBlk:				;FÅr KompatibilitÑt mit TCGEMLIB.
contrl:         DS.W    15		;Einfacher, kompatibler und weniger
global:         DS.W    80		;fehleranfÑllig, falls das AES von
intin:          DS.W    128		;Assemblerroutinen her angesprungen
intout:         DS.W    45		;wird.
ptsout:         DS.W    128
addrin:         DS.L    128
addrout:        DS.L    6
ptsin:          DS.W    128


