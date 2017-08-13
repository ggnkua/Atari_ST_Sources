;-------------------------------------------------------------------------------
music_timer_b_on:>PART

                move    #$2700,SR
                clr.b   $FFFFFA1B.w
                bclr    #0,$FFFFFA07.w  ;Timer B
                bclr    #0,$FFFFFA13.w  ;Timer B

                lea     patch_list(PC),A0
plistl2:
                lea     music,A1
                adda.l  (A0)+,A1
*   addq.l  #4,A0
*   move.l  (A0)+,D0
*   move.w  D0,(A1)
                move.l  (A0)+,D0        ; orig
                move.w  D0,(A1)
                addq.l  #4,A0

                cmpi.l  #-1,(A0)
                bne.s   plistl2

                lea     music,A0
                move.w  driver_length(PC),D7
                move.w  #$021B,D0
                move.w  #$0221,D1
                move.w  #$0220,D2
ptb_a2:
                move.w  (A0)+,D6
                cmp.w   D0,D6
                bne.s   n1b_a2
                move.w  #$FA1B,-2(A0)
                bra.s   tbn_a2
n1b_a2:
                cmp.w   D1,D6
                bne.s   n21_a2
                move.w  #$FA21,-2(A0)
                bra.s   tbn_a2
n21_a2:
                cmp.w   D2,D6
                bne.s   n120_a2
                move.w  #$0120,-2(A0)
n120_a2:
tbn_a2:
                dbra    D7,ptb_a2

                move.l  tb_music(PC),$00000120.w
                clr.b   $FFFFFA1B.w
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B

                move    #$2300,SR
                rts
                ENDPART
music_timer_b_off:>PART

                move    #$2700,SR
                clr.b   $FFFFFA1B.w
                bclr    #0,$FFFFFA07.w  ;Timer B
                bclr    #0,$FFFFFA13.w  ;Timer B

                move.l  $00000120.w,tb_music

                lea     patch_list(PC),A0
plistl:
                lea     music,A1
                adda.l  (A0)+,A1
                addq.l  #4,A0
                move.l  (A0)+,D0
                move.w  D0,(A1)
                cmpi.l  #-1,(A0)
                bne.s   plistl

                lea     music,A0
                move.w  driver_length(PC),D7
                move.w  #$FA1B,D0
                move.w  #$FA21,D1
                move.w  #$0120,D2
ptb_a:
                move.w  (A0)+,D6
                cmp.w   D0,D6
                bne.s   n1b_a
                move.w  #$021B,-2(A0)
                bra.s   tbn_a
n1b_a:
                cmp.w   D1,D6
                bne.s   n21_a
                move.w  #$0221,-2(A0)
                bra.s   tbn_a
n21_a:
                cmp.w   D2,D6
                bne.s   n120_a
                move.w  #$0220,-2(A0)
n120_a:
tbn_a:
                dbra    D7,ptb_a

                move    #$2300,SR
                rts
                ENDPART
                >PART ' music timer b patchlist '

driver_length:  DC.W $4600/2

tb_music:       DC.L 0

padr            EQU $00000200
patch_list:
                DC.L $0000189A,$000021C9,$00006016
                DC.L $00001F7C,$00000120,padr
                DC.L $00001F8A,$00000120,padr

                DC.L $000018F8,$0000FA13,padr
                DC.L $00001F36,$0000FA13,padr

                DC.L -1
                ENDPART
;-------------------------------------------------------------------------------

