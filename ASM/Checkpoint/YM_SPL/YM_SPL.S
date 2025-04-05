;-------------------------------------------------------------------------------
;
; YM2149 4 bit sound experiment                        (w)2011/defjam/checkpoint
;                                                      defjam_cp at gmx dot net
; 1 channel, 4 bit PCM madness
;
;-------------------------------------------------------------------------------
TEST            EQU 0
                OPT D-
;-------------------------------------------------------------------------------
                IFNE TEST
                OPT D+
                ENDC
;-------------------------------------------------------------------------------
                clr.l   -(SP)
                move.w  #$0020,-(SP)    ; supervisor
                trap    #1
                clr.l   $FFFFFA06.w     ; disable mfp irqs

                pea     hbl(PC)
                move.l  (SP)+,$00000068.w

                move.l  #$0700FF00,$FFFF8800.w ; noise off, tone off

                move    #$2100,SR
loop:
                IFNE TEST
                cmpi.b  #$39,$FFFFFC02.w
                bne.s   loop
end:
                DC.L $4AFC4E71
                ENDC
                bra.s   loop
hbl:
;-------------------------------------------------------------
; "sequencer"
;
; in: D7.l ... t
;
; out:
;   t * ( 1 + ( (((t>>4)&%0000010110000000)>>7 )  |  ( (t>>6)>>( (t>>16)&7+7)&%0000000000010111 )  ))

; don't you think the assembly code looks much nicer than the C-equivalent ? :)

                move.w  D7,D6
                lsr.w   #4,D6
;                         7654321076543210
                and.w   #%0000010110000000,D6
                lsr.w   #7,D6

                move.l  D7,D1
                lsr.l   #6,D1

                move.l  D7,D2
                swap    D2              ; t>>16
                and.w   #7,D2
                addq.w  #7,D2

                lsr.w   D2,D1           ; octave shift (orig.: 3)

;                         7654321076543210
                and.w   #%0000000000010111,D1
                or.w    D1,D6

                addq.w  #1,D6           ; f++
                mulu    D7,D6           ; t*f
;-------------------------------------------------------------
; "SID"
; out = ( (t>>7)&1 ) * ((t*254)>>(7+8)&1) ) * amplitude
;-------------------------------------------------------------
; in: D6 ... t*f
;
                move.w  D6,D0           ; t
                lsr.w   #7,D0           ; t>>7       signal_a (rect_wave_a)

                mulu    #254*2,D6       ; *254   SID phase_shift
                swap    D6              ; >> (7+8)   signal_b (rect_wave_b)

                and.w   D6,D0           ; binary convolution signal_a*signal_b
                lsr.b   #1,D0           ; test bit 0
                scs     D0              ; set if not zero  ... amplitude
                lsr.b   #4,D0           ; bits0...3  (0/15)    = 15
out:
                move.b  #8,$FFFF8800.w  ; psg volume select Chan A
                move.b  D0,$FFFF8802.w

                addq.l  #1,D7           ; t++
                rte
;-------------------------------------------------------------
;-------------------------------------------------------------
                END
;-------------------------------------------------------------
;-------------------------------------------------------------
                END
