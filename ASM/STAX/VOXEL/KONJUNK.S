********** Source: Umsetzen des Junk Puffers in den ST Bildschirmspeicher ***********


scanner:        

                movea.l screen_adr(PC),A0		; Bildschirmspeicheradresse

                lea     mammut_table,A1		; Konvertierungstabelle Adresse

                lea     junk_puffer(PC),A2		; Junk Puffer Adresse

                move.w  #highs-1,D0			; wieviele Zeilen im Junk Puffer

copy_lines:     movea.w D0,A3

                moveq   #0,D0
                moveq   #0,D2
                moveq   #0,D4
                moveq   #0,D6
                move.w  (A2)+,D0			; Wort mit 4 Voxel Farben holen
                move.w  (A2)+,D2
                move.w  (A2)+,D4
                move.w  (A2)+,D6
                lsl.l   #3,D0				; 4 Plane Wörter = 8 Byte
                lsl.l   #3,D2
                lsl.l   #3,D4
                lsl.l   #3,D6

                movem.l 0(A1,D0.l),D0-D1		; Konvertierte Wörter holen
                movem.l 0(A1,D2.l),D2-D3
                movem.l 0(A1,D4.l),D4-D5
                movem.l 0(A1,D6.l),D6-D7
                movem.l D0-D7,(A0)      		* 64 Pixel schreiben
                movem.l D0-D7,160(A0)		* Zeile verdoppeln (y double pix)

off             SET 16*4/2
                REPT 3

                moveq   #0,D0
                moveq   #0,D2
                moveq   #0,D4
                moveq   #0,D6
                move.w  (A2)+,D0
                move.w  (A2)+,D2
                move.w  (A2)+,D4
                move.w  (A2)+,D6
                lsl.l   #3,D0
                lsl.l   #3,D2
                lsl.l   #3,D4
                lsl.l   #3,D6

                movem.l 0(A1,D0.l),D0-D1
                movem.l 0(A1,D2.l),D2-D3
                movem.l 0(A1,D4.l),D4-D5
                movem.l 0(A1,D6.l),D6-D7
                movem.l D0-D7,off(A0)   * 64 pixel
                movem.l D0-D7,off+160(A0)
off             SET off+16*4/2
                ENDR

                lea     320(A0),A0
                move.w  A3,D0
                dbra    D0,copy_lines
                rts
