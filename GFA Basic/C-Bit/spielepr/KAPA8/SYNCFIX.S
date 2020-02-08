***********************************
*  SYNCFIX                        *
*  setzt das Bit fÅr die Externe  *
*  Syncronisation des TT per      *
*  TT - MFP Timer A auf 0         *
*                                 *
*  kann auch zur Verzîgerung des  *
*  TT genutzt werden              *
*                                 *
***********************************


;               Superexec
                pea     test(PC)
                move.w  #38,-(SP)
                trap    #14
                addq.l  #6,SP
                clr.w   -(SP)
;               Quit and Stay resident
                move.l  #500,-(SP)
                move.w  #$31,-(SP)
                trap    #1


test:
                move.l  #newmfp,372     ;eintragen des neuen Vektors in die
;                                        Timer A Vektor Tabelle
;               Timer A des TT - MFP zulassen !
                move.b  #2,$FFFFFA99.w
                move.b  #6,$FFFFFA9F.w
                bset    #5,$FFFFFA87.w
                bset    #5,$FFFFFA93.w

                rts


newmfp:

                bset    #0,$FFFF820A.w  ;Syncmode Register zurÅcksetzen
                bclr    #5,$FFFFFA8F.w  ;Timer A In Service Bit Lîschen
                rte

                END
