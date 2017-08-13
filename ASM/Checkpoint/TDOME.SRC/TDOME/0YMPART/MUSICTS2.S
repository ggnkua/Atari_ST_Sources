
                jsr     save_mfp
                jsr     restore_mfp
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
init_music:     >PART

                move    #$2700,SR

                clr.l   $000005A0.w     ; cookie jar   WICHTIG!!!!

                move.l  #trap_0,$00000080.w
                lea     (SP),A6
                move.l  #"CPT!",-(SP)
                trap    #0
                illegal
trap_0:
get_id:
                addq.w  #2,stackframe_size
                addq.l  #2,SP
                cmpi.l  #"CPT!",(SP)
                bne.s   get_id
                lea     (A6),SP

                move.l  #trap1,$00000084.w

                lea     rte(PC),A0
                move.l  A0,$00000060.w  ; NMI

                bclr    #3,$FFFFFA17.w  ; auto eoi

                moveq   #1,D0
                jsr     music_syd

                move    #$2700,SR

                andi.b  #$0F,$FFFFFA1D.w ; stop timer c
                move.l  #music_replay_timer,$00000114.w

                bset    #5,$FFFFFA09.w  ; enable timer c
                bset    #5,$FFFFFA15.w  ; enable timer c


                move.l  #69,D0          ; 69 Hz
                bsr     set_music_speed_hz

                move    #$2300,SR
                rts
trap1:
*   DC.L $4AFC4E71
*   lea     (SP),A0
*   adda.w  stackframe_size(PC),A0
                move.l  #music_syd_bss,D0
                rte

stackframe_size:DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
; D0.hz long
set_music_speed_hz:>PART

                cmp.w   old_music_hz(PC),D0
                beq.s   same_hz
                move.w  D0,old_music_hz
; Timer C
                bsr.s   Hertz_to_MFP

                lea     $FFFFFA1D.w,A0
                lea     $FFFFFA23.w,A1

                move    #$2700,SR

                move.b  (A0),D2
                and.b   #$0F,D2
                lsl.b   #4,D0
                or.b    D2,D0

                move.b  D1,(A1)         ; c data
                move.b  D0,(A0)         ; cd ctrl

                move    #$2300,SR
same_hz:
                rts
old_music_hz:   DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
; IN:    D0.l frequency in Hertz
; OUT:   D0.b timer prediv set
;        D1.b timer data
Hertz_to_MFP:   >PART


                lsl.l   #2,D0


; MFP frequency:   2.4576 MHz  =  2457600 Hz
;
; MFP prediv
; 1:4                              614400 Hz      (614.4 KHz)

                pea     (A0)
                lea     mfp_prediv_table(PC),A0
                lea     -12+4(A0),A0
mfp_get_min:
                lea     12(A0),A0
                cmp.l   (A0),D0
                blt.s   mfp_get_min
                move.l  -(A0),D1        ; MFP_freq * prediv
                divu    D0,D1           ; timer data
                move.l  8(A0),D0        ; timer prediv set
                movea.l (SP)+,A0
                rts

mfp_prediv_table:
; .l  MFP_freq * prediv       ( = max freq.)
; .l  MIN freq
; .l  MFP bits
                DC.L 614400,2409+1,%0000000000000001 ; 1:4
                DC.L 245760,963+1,%0000000000000010 ; 1:10
                DC.L 153600,602+1,%0000000000000011 ; 1:16
                DC.L 49152,192+1,%0000000000000100 ;  1:50
                DC.L 38400,150+1,%0000000000000101 ;  1:64
                DC.L 24576,96+1,%0000000000000110 ;  1:100
                DC.L 12288,48+1,%0000000000000111 ;  1:200
                ENDPART
;-------------------------------------------------------------------------------
mrt_speed:      DC.W 3
mrt_delay:      DC.W 0
music_replay_timer:>PART

                move    #$2300,SR
                subq.w  #1,mrt_delay
                bpl.s   not_yet
                move.w  mrt_speed(PC),mrt_delay

*    not.w   $FFFF8240.w


                movem.l D0-A6,-(SP)
                jsr     music_syd+8
                movem.l (SP)+,D0-A6

*   not.w   $FFFF8240.w

not_yet:

                rte
                ENDPART
;-------------------------------------------------------------------------------
music_syd:
                IBYTES 'DNB8.SND'
music_syd_bss:  DS.B 512
                EVEN
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
save_mfp:       >PART
                move    #$2700,SR
                lea     mfp_regslist(PC),A0
                lea     mfp_save(PC),A1
sml:
                move.w  (A0)+,D0
                beq.s   smle
                movea.w D0,A2
                move.b  (A2),(A1)+
                bra.s   sml
smle:
                move    #$2300,SR
                rts
                ENDPART
restore_mfp:    >PART
                move    #$2700,SR

                lea     rte,A0
                move.l  A0,$00000110.w
                move.l  A0,$00000114.w
                move.l  A0,$00000134.w

                lea     mfp_regslist(PC),A0
                lea     mfp_save(PC),A1
rml:
                move.w  (A0)+,D0
                beq.s   rmle
                movea.w D0,A2
                move.b  (A1)+,(A2)
                bra.s   rml
rmle:
                move.b  #$C0,$FFFFFA23.w ; timer c data

                clr.b   $FFFFFA0F.w
                clr.b   $FFFFFA11.w
                move    #$2300,SR
                rts

mfp_save:       DS.B 16

mfp_regslist:
                DC.W $FA1F      ; td a
                DC.W $FA21      ; td b
                DC.W $FA23      ; td c
                DC.W $FA25      ; td d

                DC.W $FA19      ; tc a
                DC.W $FA1B      ; tc b
                DC.W $FA1D      ; tc cd

                DC.W $FA07
                DC.W $FA09
                DC.W $FA13
                DC.W $FA15
                DC.W $FA17

                DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


