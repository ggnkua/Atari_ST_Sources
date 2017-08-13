
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
timer_output:   >PART

                addq.l  #1,total_time.w

*    bra.s   to_do           ;-------------

                move.b  $FFFFFC02.w,D0
                cmp.b   #$61,D0         ; UNDO
                beq.s   to_do
                cmp.b   #$003B+9,D0     ; F10
                bne.s   to_no_break
                DC.L $4AFC4E71
to_no_break:
                rts
to_do:
                move    SR,-(SP)
                move    #$2700,SR
; movem.l D0-A6,-(SP)
                lea     $FFFF8240.w,A0
                move.l  (A0),-(SP)      ; save color0,1

                move.l  #$00000777,(A0) ; set display colors

                ENDPART
;----------------------------------------------------
to_display:     >PART

; get screen address
                moveq   #0,D0
                lea     $FFFF8201.w,A2
                movep.w 0(A2),D0
                lsl.l   #8,D0
                movea.l D0,A2           ; screen
;----------------------------------------------------
                lea     (A2),A1         ; screen
                moveq   #1,D6           ; reset x_inc
;----------------------------------------------------
; print min:sec:vbl

                move.l  total_time.w,D0
                divu    #50,D0

                move.l  D0,-(SP)        ; save t/50

                ext.l   D0

                divu    #60,D0
                move.l  D0,-(SP)
; D0...minutes
                bsr.s   display_num2    ; display minutes

                move.l  (SP)+,D0
                swap    D0              ; seconds
; D0...seconds
                bsr.s   display_num2    ; display seconds

                move.l  (SP)+,D0        ; t/50
                swap    D0              ; vbl_ticks
                bsr.s   display_num2    ; display vbl_ticks

;----------------------------------------------------
; print total_time ticks

                lea     1*8*160(A2),A1  ; screen
                moveq   #1,D6           ; reset x_inc

                move.l  total_time.w,D2 ; value
                moveq   #PRINT_HEX8,D3
                bsr.s   print_hex       ; hex8
;----------------------------------------------------
; print music position

                lea     2*8*160(A2),A1  ; screen
                moveq   #1,D6           ; reset x_inc

                move.l  D0,D2           ; play_position

                moveq   #PRINT_HEX2,D3
***   bsr.s   print_hex       ; hex2
;----------------------------------------------------
                ENDPART
;----------------------------------------------------
to_wait_cont:   >PART
                eori.w  #$0112,$FFFF8240.w
                cmpi.b  #$3B,$FFFFFC02.w ; F1
                bne.s   to_wait_cont

                move.l  (SP)+,$FFFF8240.w ; restore color0,1
; movem.l (SP)+,D0-A6
                move    (SP)+,SR
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; D6...x_inc
; A1...screem
display_num2:   >PART           ; D0,D1, D6,A0,A1

                ext.l   D0
                divu    #10,D0
                bsr.s   display_num1
                swap    D0
                bsr.s   display_num1

; --> separator is following!

                ENDPART
separator:      >PART           ; D0,D1, D6,A1

                lea     (A1),A3         ; screen_pos
                moveq   #8-1,D0
s_y:
                moveq   #%00011100,D1   ; bit pattern
                bsr.s   output_d1_movepl
                dbra    D0,s_y
                bra.s   advance_cursor_x

                ENDPART
display_num1:   >PART           ; D0,D1, D6,A0,A1

                move.l  D0,-(SP)

                mulu    #7,D0
                lea     nums_gfx(PC,D0.w),A0

                lea     (A1),A3         ; screen_pos
                moveq   #7-1,D0         ; 7 lines!
dnt_y:
                moveq   #0,D1
                move.b  (A0)+,D1
                bsr.s   output_d1_movepl
                dbra    D0,dnt_y

                moveq   #0,D1
                bsr.s   output_d1_movepl ; line 8

                move.l  (SP)+,D0
advance_cursor_x:
                adda.w  D6,A1
                eori.w  #6,D6
                rts

                ENDPART
; D1.b, A3 screen
output_d1_movepl:>PART
                ror.l   #8,D1
                movep.l D1,0(A3)
                lea     160(A3),A3
                rts
                ENDPART
;-----------------------------------------------
; D2...digit
; D3...PRINT_HEXx (0...$1C)
;
print_hex:      >PART

                rol.l   D3,D2           ; shift to msb
phl:
                rol.l   #4,D2
                moveq   #$0F,D0
                and.w   D2,D0
                bsr.s   display_num1

                addq.w  #4,D3
                cmp.w   #$0020,D3
                bne.s   phl

                rts

                ENDPART
;-----------------------------------------------
                PATH 'C:\0NEW\TDOME\0FILES\KERNEL\'
nums_gfx:       IBYTES 'NUMS_7.GFX'
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


