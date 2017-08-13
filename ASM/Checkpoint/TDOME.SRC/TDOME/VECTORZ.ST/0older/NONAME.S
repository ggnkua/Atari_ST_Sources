;-------------------------------------------------------------------------------
;
; 0FINAL_3.SRC ... D7/A4/A5/A6 FREE!
;
; 0FINAL.SRC   ... 8bit signed input
;
;-------------------------------------------------------------------------------
TEST            EQU 1
colors_ptr      EQU $00000200
;-------------------------------------------------------------------------------
NEXT_X          SET 200*2
;-------------------------------------------------------------------------------

Init_Vectorz:   >PART

                bsr     make_linecode
                bsr     make_linecode2

                rts

                ENDPART
;------------------------------------------------------------

Do_Vectorz:
                clr.l   colors_ptr.w
                bsr     init_colors_plane_effec
loop:
*  bra.s   no_swap_l
                bsr     swap_screens
no_swap_l:
                bsr.s   interlace_effect ; cycle & set colorsptr for vbl!

                bsr     wait_vbl

                bsr     Clear_y_field


;  bsr     output_current_frame_8b
; DRAW LINES

                bsr     Output_y_field


fsync:          move.l  $00000466.w,D0
                cmp.l   max_frame_sync(PC),D0
; blt.s   fsync


*   move.w  #$0007,$FFFF8240.w

                IFNE TEST
                move.b  $FFFFFC02.w,D0
                cmp.b   #$62,D0
                bne.s   n62
                move.w  #$0007,$FFFF8240.w
n62:
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                ENDC

                bra.s   loop

max_frame_sync: DC.L 3

;-------------------------------------------------------------------------------
interlace_effect:PART

                not.w   ilf
                beq.s   no_il
                addq.w  #1,il_frame
                andi.w  #3,il_frame
                addq.w  #2,il_bitplane
                andi.w  #3*2,il_bitplane
no_il:

                lea     colors_plane_effect(PC),A0

                move.w  il_frame(PC),D0
                subq.w  #3,D0           ; adjust frame->color index
                and.w   #3,D0           ; wrap

                mulu    #16*2,D0
                adda.w  D0,A0

                movea.l curr_colorsPtr(PC),A1

                move.l  A1,colors_ptr.w

;   movem.l (A1),D0-D6/A1
;   movem.l D0-D6/A1,$FFFF8240.w

                move.l  A0,curr_colorsPtr

                rts

curr_colorsPtr: DC.L black

                ENDPART
ilf:            DC.W 0
il_frame:       DC.W 0
il_bitplane:    DC.W 0
;-------------------------------------------------------------------------------

rte:            rte
rts:            rts

;-------------------------------------------------------------------------------
                movem.w (A0),D0-D3
                bsr     draw_line_eor_d0_d3_SD

;-------------------------------------------------------------------------------
swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

screen0:        DC.L 0
screen1:        DC.L 0

                ENDPART
vbl:            PART

                movem.l D0-A6,-(SP)

*  bra     no_colors

                move.l  colors_ptr.w,D0
                beq.s   no_colors
                movea.l D0,A1
                movem.l (A1),D0-D6/A1
                movem.l D0-D6/A1,$FFFF8240.w
*  clr.l   colors_ptr.w
no_colors:

;   movea.l music_vbl.w,A0
;   jsr     (A0)

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte
                ENDPART
cnt_vbl:        >PART
                addq.l  #1,$00000466.w
                rte
                ENDPART
wait_vbl:       >PART
                clr.l   $00000466.w
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

x0:             DC.W 0
y0:             DC.W 0
x1:             DC.W 0
y1:             DC.W 0

xs:             DC.W 0
ys:             DC.W 0

; subdiv
draw_line_eor_d0_d3_SD:PART     ; subdivided

                movem.w D0-D3,x0

                add.w   D0,D2
                add.w   D1,D3
                asr.w   #1,D2
                asr.w   #1,D3
                movem.w D2-D3,xs

                bsr.s   draw_line_eor_d0_d3

                movem.w xs(PC),D0-D1
                movem.w x1(PC),D2-D3

                bsr.s   draw_line_eor_d0_d3

                rts

                ENDPART

;-----------------------------------------------------------
draw_line_eor_d0_d3:
output_line_d0_d3:>PART

                cmp.w   D0,D2
                beq     senkrecht
                bge.s   links_rechts
                exg     D0,D2
                exg     D1,D3
links_rechts:
                sub.w   D0,D2           ; dx

                moveq   #2,D5           ;Offset Y Pos/Neg

                sub.w   D1,D3           ; dy
                bpl.s   dy_positiv
                neg.w   D3
                neg.w   D5
dy_positiv:
                movea.w D5,A2           ;šbertrag Y Offset
                ext.l   D3              ; and.l   #$0000FFFF,D3

                divu    D2,D3           ; dy/dx
                muls    D3,D5           ; * Offset_Y   Y_Offset Increment

                clr.w   D3
                divu    D2,D3           ;fractional part
                movea.w D3,A3           ;Fractional Increment
                swap    D3              ;Rest
                add.w   #$8000,D3       ;+0.5
                move.w  D3,D6           ;Fractional


; A0 Buffer
; A2 šbertrag Y Offset
; A3 Fractional Increment

; D6 Fractional
; D5 Y_Offset Increment   was: D7

                lea     y_field,A0
                add.w   D1,D1
                adda.w  D1,A0           ; + Y_START

                move.w  D0,D1
                lsr.w   #4,D1           ;/16
                bcc.s   even_start
                addq.l  #1,A0
even_start:
                muls    #200*2,D1       ;Offset next 16Pix
                adda.w  D1,A0           ; + X_OFFSET

                and.w   #15,D0          ; X Shift
                add.w   D0,D0
                add.w   D0,D0

                tst.w   D5
                beq.s   Y_STG_LESS_1

                lea     linecode_offset(PC),A1
                adda.w  D0,A1           ;X Start

                add.w   D2,D2
                add.w   D2,D2           ;dx*4
                move.l  (A1),line_start1+2

                movea.l 0(A1,D2.w),A1
                move.w  (A1),-(SP)
                move.w  #$4E75,(A1)

                moveq   #1,D0
                moveq   #4,D1
                moveq   #3,D2
                moveq   #5,D3
                moveq   #6,D4

line_start1:    jsr     0

                move.w  (SP)+,(A1)
                rts
                ENDPART
;-------------------------
Y_STG_LESS_1:   >PART

                lea     linecode_offset2(PC),A1
                adda.w  D0,A1           ;X Start

                add.w   D2,D2
                add.w   D2,D2           ;dx*4

                move.l  (A1),line_start2+2
                movea.l 0(A1,D2.w),A1   ; end of line
                move.w  (A1),-(SP)
                move.w  #$4E75,(A1)

                moveq   #1,D0
                moveq   #4,D1
                moveq   #3,D2
                moveq   #5,D3
                moveq   #6,D4
* moveq   #$80,D5

                moveq   #0,D5           ;Clear Plotbits!

line_start2:    jsr     0

                eor.b   D5,(A0)

                move.w  (SP)+,(A1)
                rts
senkrecht:
;D0 XS   D1 YS
;D2 XE   D3 YE
                cmp.w   D1,D3
                bne.s   d1_not_d3
                rts                     ;P1 = P2 !
d1_not_d3:
                lea     y_field,A0
                add.w   D1,D1
                adda.w  D1,A0           ; + Y_START

                move.w  D0,D1           ;X_START
                and.w   #$000F,D0
                add.w   D0,D0
                move.w  bits(PC,D0.w),D0 ;bits

                lsr.w   #4,D1           ;/16
                muls    #200*2,D1
                adda.w  D1,A0           ; + X_OFFSET

                eor.w   D0,(A0)         ;XS;YS

                lea     y_field,A0
                add.w   D3,D3
                adda.w  D3,A0           ; + Y_END
                adda.w  D1,A0           ; + X_OFFSET
                eor.w   D0,(A0)         ;XE;YE

                rts

                OPT W-
bits:
b               SET $8000
                REPT 16
                DC.W b
b               SET b>>1
                ENDR

                OPT W+

                ENDPART
;-----------------------------------------------------------
linecode_offset:DS.L 640
linecode_offset2:DS.L 640
;-------------------------------------------------------------------------------
Output_y_field: >PART

                lea     y_field,A0

                movea.l screen1(PC),A1
                adda.w  il_bitplane(PC),A1

                move.w  #320/16-1,-(SP)
Oyf_lines:

o               SET 0

                movem.w (A0)+,D0-D6     ; 7 lines

                move.w  D0,(A1)
o               SET o+160
                eor.w   D1,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D2,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D3,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D4,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D5,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D6,D0
                move.w  D0,o(A1)
o               SET o+160

; 200 - 7 = 193
; 193 / 6 = 32, rest: 1 !
                REPT 32

                movem.w (A0)+,D1-D6     ; 6 lines
                eor.w   D1,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D2,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D3,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D4,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D5,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D6,D0
                move.w  D0,o(A1)
o               SET o+160

                ENDR

                move.w  (A0)+,D1
                eor.w   D1,D0
                move.w  D0,o(A1)
o               SET o+160

                addq.l  #8,A1           ; next 16 pix screen

                subq.w  #1,(SP)
                bpl     Oyf_lines
                addq.l  #2,SP
                rts

                ENDPART
Clear_y_field:  >PART

                move.l  #super_trap0,$00000080.w
                move    #$0300,SR

                lea     y_field+8000,SP

*  movem.l zero,D0-A6      ; 60 bytes
; 2*200 * 20 = 8000 bytes / 60 = 133, rest 20

                movem.l zero(PC),D0-D6/A0-A3 ; 44 bytes
; 8000/44 = 181, rest 36

                REPT 181
                movem.l D0-D6/A0-A3,-(SP)
                ENDR

                movem.l D0-D6/A0-A1,-(SP)

                trap    #0
                rts
                ENDPART
super_trap0:
                move.b  #$23,(SP)
                rte
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

make_linecode:  >PART
;--- LINIENCODE FOR STEIGUNG >= 1

*        DC.L $4AFC4E71

                lea     linecode_offset(PC),A5
                lea     linecode,A6

                lea     ml_setpix(PC),A4
                moveq   #0,D5           ;Flag Even/Odd Offset Inc.
                moveq   #7-1,D6         ;Bitrun

                move.w  #320+16,D7
ml_build:
                move.l  A6,(A5)+        ;Offset

                move.w  (A4)+,(A6)+     ; pixset
                bne.s   ml_nz0
                subq.l  #2,A6
                move.l  ml_setpix7(PC),(A6)+ ; pixset
ml_nz0:

                lea     ml_y(PC),A0
                bsr     ml_write_ycode

                dbra    D6,ml_morepix

                not.w   D5
                beq.s   ml_eveninc

                move.l  A6,(A5)+        ;Offset
                move.w  ml_lastpix_inc1(PC),(A6)+ ;         eor.b d0,(a5)+
                lea     ml_y(PC),A0
                bsr     ml_write_ycode

                bra.s   ml_incdone
ml_eveninc:
                move.l  A6,(A5)+        ;Offset
                move.w  (A4)+,(A6)+     ;eor.b d0,(a5)
                lea     ml_y(PC),A0
                bsr     ml_write_ycode
                move.l  ml_lastpix_inc2(PC),(A6)+ ;         lea NEXT_O(a5),a5
ml_incdone:
                subq.w  #1,D7
                bmi.s   ml_build_end

                moveq   #7-1,D6         ;Bitrun
                lea     ml_setpix(PC),A4
ml_morepix:
                dbra    D7,ml_build
ml_build_end:
                move.l  A5,D0
                sub.l   #linecode_offset,D0
                lsr.l   #2,D0

*     DC.L $4AFC4E71

                lea     (A6),A0
                suba.l  #linecode,A0
                rts

; D0 = 1   0001      --> Bit 0,1
; D1 = 4   0100      --> Bit 2,4
; D2 = 3   0011      --> Bit 3
; D3 = 5                 Bit 5
; D4 = 6                 Bit 6
;                                     D5 = $80               Bit 7

ml_setpix7:
                eori.b  #$80,(A0)       ;Bit 7

ml_setpix:
                DC.W 0          ;  eor.b   D5,(A0)         ;Bit 7
                bchg    D4,(A0)         ;Bit 6
                bchg    D3,(A0)         ;Bit 5
                bchg    D1,(A0)         ;Bit 4
                bchg    D2,(A0)         ;Bit 3
                eor.b   D1,(A0)         ;Bit 2
                bchg    D0,(A0)         ;Bit 1
                eor.b   D0,(A0)         ;Bit 0

ml_lastpix_inc1:eor.b   D0,(A0)+
ml_lastpix_inc2:lea     NEXT_X-1(A0),A0

ml_y:
                DC.W (ml_ye-ml_y-2)/2-1
                add.w   A3,D6
                bcc.s   *+2
                adda.w  A2,A0           ;šbertrag Y
                adda.w  D5,A0           ;Normaler Anstieg Y   was: D7
ml_ye:
                ENDPART

make_linecode2: >PART
;--- LINIENCODE FOR STEIGUNG < 1

*    DC.L $4AFC4E71

                lea     linecode_offset2(PC),A5
                lea     linecode2,A6

                lea     ml_setpix2(PC),A4
                moveq   #0,D5           ;Flag Even/Odd Offset Inc.
                moveq   #7-1,D6         ;Bitrun

                move.w  #320+16,D7
ml_build2:
                move.l  A6,(A5)+        ;Offset

                move.w  (A4)+,(A6)+
                lea     ml_y2(PC),A0
                bsr.s   ml_write_ycode

                dbra    D6,ml_morepix2
                not.w   D5
                beq.s   ml_eveninc2

                move.l  A6,(A5)+        ;Offset
                move.w  (A4)+,(A6)+     ;              or.b d0,d7
                move.w  ml_lastpix_inc1_2(PC),(A6)+ ;         eor.b d7,(a5)+
                bra.s   ml_incdone2
ml_eveninc2:
                move.l  A6,(A5)+        ;Offset
                move.w  (A4)+,(A6)+     ;              or.b d0,d7
                move.w  ml_lastpix_inc2_2(PC),(A6)+ ;         eor.b d7,(a5)
                move.l  ml_lastpix_inc2_2+2(PC),(A6)+ ;         lea NEXT_O(a5),a5
ml_incdone2:
                lea     ml_y2_nowrite(PC),A0
                bsr.s   ml_write_ycode

                moveq   #7-1,D6         ;Bitrun
                lea     ml_setpix2(PC),A4
                subq.w  #1,D7
                bmi.s   ml_build_end2
ml_morepix2:
                dbra    D7,ml_build2
ml_build_end2:

*    DC.L $4AFC4E71

                lea     (A6),A0
                suba.l  #linecode2,A0
                rts

ml_setpix2:
                moveq   #$80,D5         ; * move.b  D5,D7           ;Bit 7
                bset    D4,D5           ;Bit 6
                bset    D3,D5           ;Bit 5
                bset    D1,D5           ;Bit 4
                bset    D2,D5           ;Bit 3
                or.b    D1,D5           ;Bit 2
                bset    D0,D5           ;Bit 1
                or.b    D0,D5           ;Bit 0

ml_lastpix_inc1_2:
                eor.b   D5,(A0)+        ;2b

ml_lastpix_inc2_2:
                eor.b   D5,(A0)         ;2b
                lea     NEXT_X-1(A0),A0 ;4b

ml_y2:
                DC.W (ml_ye2-ml_y2-2)/2-1

                add.w   A3,D6
                bcc.s   ml_ye2
                eor.b   D5,(A0)
                moveq   #0,D5
                adda.w  A2,A0           ;šbertrag Y
ml_ye2:

ml_y2_nowrite:
                DC.W (ml_ye2_nowrite-ml_y2_nowrite-2)/2-1
                moveq   #0,D5           ;<-- MUSS!!  sonst eor nach Verlassen!
; Oder evtl. eine Logik ...

                add.w   A3,D6
                bcc.s   ml_ye2_nowrite
                adda.w  A2,A0           ;šbertrag Y
ml_ye2_nowrite:
                ENDPART

ml_write_ycode: >PART
                move.w  (A0)+,D0
ml_ycode:       move.w  (A0)+,(A6)+
                dbra    D0,ml_ycode
                rts
                ENDPART

;-------------------------------------------------------------------------------


vt_vertices:    DC.W 0


; A0...frame
output_frame_test:PART

*  DC.L $4AFC4E71

                move.w  (A0)+,D6
                move.w  D6,vt_vertices
                ENDPART
oft_main:       >PART

                move.w  vt_vertices(PC),D6

                move.w  D6,D0
                lsl.w   #2,D0
                lea     0(A0,D0.w),A1

                move.l  (A1),-(SP)      ;; SAVE
                pea     (A1)            ;;

                move.l  (A0),(A1)       ; first --> last

                subq.w  #1,D6
oft_l:
                movem.l D6/A0,-(SP)

                movem.w (A0),D0-D3

* movem.w D0-D3,x0        *** DEBUG

                bsr     draw_line_eor_d0_d3

                movem.l (SP)+,D6/A0
                addq.l  #2*2,A0
                dbra    D6,oft_l

                movea.l (SP)+,A1        ;; RESTORE
                move.l  (SP)+,(A1)      ;;

                rts

                ENDPART

; A0
oft_main_clipping:
*  DC.L $4AFC4E71

                move.w  vt_vertices(PC),D6
                bsr     draw_polygon_clipped
                rts


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
VERTICE_SWAP_FLAG EQU $00000140

x_clip_min:     DC.W 0
x_clip_max:     DC.W 319        ; 319

y_clip_min:     DC.W 0
y_clip_max:     DC.W 199

; A0...polygon, D7...num_verts
clip_2d_fast_check:>PART

                move.w  x_clip_max(PC),D0
                move.w  y_clip_max(PC),D1

                lea     (A0),A1

                moveq   #8,D2
                sub.w   D7,D2
                lsl.w   #3,D2
                jmp     c2d_fc(PC,D2.w)
c2d_fc:
                REPT 8
                cmp.w   (A1)+,D0        ; x
                bls.s   c2d_clip_needed
                cmp.w   (A1)+,D1        ; y
                bls.s   c2d_clip_needed
                ENDR
; no clipping
                move.l  (A0),(A1)+      ; last point --> first
                move.w  D7,D0           ; amount vertices
                rts
c2d_clip_needed:
                moveq   #-1,D0
                rts
                ENDPART
;------------------------------------------------------

; A0...p0   A1...p1   A3...y_clip_min
clip_top_NEW:   >PART

                move.w  2(A0),D1        ; y0
                move.w  2(A1),D3        ; y1

                cmp.w   D3,D1
                sgt     VERTICE_SWAP_FLAG.w
                ble.s   cymin0
                exg     D1,D3
                exg     A0,A1
cymin0:
                move.w  (A0),D0         ; x0
                move.w  (A1),D2         ; x1
; if(y0<y_clip_min)
                cmp.w   A3,D1
                bge.s   nymin1
; if(y1<y_clip_min)
                cmp.w   A3,D3
                bge.s   ny1_clip
                rts
ny1_clip:

; #P0 #P1
; xs = x0 + ((y_top-y0) * (x1-x0)/(y1-y0);
; ys = y_top

                move.w  D3,D4           ; y1
                sub.w   D1,D4           ; y1-y0
                beq.s   ny_dy_zero

                neg.w   D1              ; -y0
                add.w   A3,D1           ; y_top-y0

                move.w  D2,D5           ; x1
                sub.w   D0,D5           ; x1-x0

                muls    D5,D1           ; (y_top-y0)*(x1-x0)
                divs    D4,D1           ; /(y1-y0)

                add.w   D1,D0           ; +x0   XS

; if(swap) // P0 #P1 --> S
                tst.b   VERTICE_SWAP_FLAG.w
                beq.s   no_swap_y
; out: S
                move.w  D0,(A2)+        ; x
                move.w  A3,(A2)+        ; y = y_top
                rts
no_swap_y:
; #P0 P1 --> S, v(i+1)--A1
; S
                move.w  D0,(A2)+        ; x
                move.w  A3,(A2)+        ; y = y_top
; v(i+1)
                move.l  (A1),(A2)+
                rts
nymin1:
; P0 P1 --> v(i+1)
                tst.b   VERTICE_SWAP_FLAG.w
                beq.s   no_swap_y2
                move.l  (A0),(A2)+
                rts
no_swap_y2:
                move.l  (A1),(A2)+
ny_dy_zero:
                rts

                ENDPART

; A0...p0   A1...p1   A3...y_clip_max
clip_bottom_NEW:>PART           ; *****

                move.w  2(A0),D1        ; y0
                move.w  2(A1),D3        ; y1

; if (y0>y1) swap
                cmp.w   D3,D1
                sgt     VERTICE_SWAP_FLAG.w
                ble.s   cymax0
                exg     D1,D3
                exg     A0,A1
cymax0:
                move.w  (A0),D0         ; x0
                move.w  (A1),D2         ; x1

; if(y1>y_clip_max)
                cmp.w   A3,D3
                ble.s   nymax1
; if(y0<y_clip_max)
                cmp.w   A3,D1
                ble.s   nymax_clip
                rts
nymax_clip:
; xs = x1 + ((y_bottom-y1)*(x1-x0)/(y1-y0)
; ys = y_bottom
                move.w  A3,D4           ; y_bottom
                sub.w   D3,D4           ; y_bottom-y1

                sub.w   D1,D3           ; y1-y0
                beq.s   nymax_dy_zero

                neg.w   D0              ; -x0
                add.w   D2,D0           ; x1-x0

                muls    D4,D0
                divs    D3,D0

                add.w   D0,D2           ; +x1  XS

; if(swap) // P0 #P1 --> S
                tst.b   VERTICE_SWAP_FLAG.w
                bne.s   swap_y3
; out: S
                move.w  D2,(A2)+        ; xs
                move.w  A3,(A2)+        ; ys = y_bottom
                rts
swap_y3:
; #P0 P1 --> S, v(i+1)--A1
; S
                move.w  D2,(A2)+        ; xs
                move.w  A3,(A2)+        ; ys = y_bottom
; v(i+1)
                move.l  (A0),(A2)+
                rts
nymax1:
; P0 P1 --> v(i+1)
                tst.b   VERTICE_SWAP_FLAG.w
                beq.s   no_swap_y4
                move.l  (A0),(A2)+
                rts
no_swap_y4:
                move.l  (A1),(A2)+
                rts
nymax_dy_zero:
                rts
                ENDPART

; A0...p0   A1...p1   A3...x_clip_min
clip_left_NEW:  >PART

                move.w  (A0),D0         ; x0
                move.w  (A1),D2         ; x1

; if (x0>x1) swap
                cmp.w   D2,D0
                sgt     VERTICE_SWAP_FLAG.w
                ble.s   cxmin0
                exg     D0,D2
                exg     A0,A1
cxmin0:
                move.w  2(A0),D1        ; y0
                move.w  2(A1),D3        ; y1

; if(x0<x_clip_min)
                cmp.w   A3,D0
                bge.s   nxmin1
; if(x1<x_clip_min)
                cmp.w   A3,D2
                bge.s   nxmin_clip
                rts
nxmin_clip:
; ys = y0 + ((x_left-x0)*(y1-y0)/(x1-x0)
; xs = x_left
                sub.w   D0,D2           ; x1-x0
                beq.s   nx_dx_zero

                neg.w   D0
                add.w   A3,D0           ; x_left-x0

                sub.w   D1,D3           ; y1-y0

                muls    D0,D3           ; (x_left-x0)*(y1-y0)
                divs    D2,D3

                add.w   D3,D1           ; +y0  YS

; if(swap) // P0 #P1 --> S
                tst.b   VERTICE_SWAP_FLAG.w
                beq.s   no_swap_x3
; out: S
                move.w  A3,(A2)+        ; xs = x_left
                move.w  D1,(A2)+        ; ys
                rts
no_swap_x3:
; #P0 P1 --> S, v(i+1)--A1
; S
                move.w  A3,(A2)+        ; xs = x_left
                move.w  D1,(A2)+        ; ys
; v(i+1)
                move.l  (A1),(A2)+
                rts
nxmin1:
; P0 P1 --> v(i+1)
                tst.b   VERTICE_SWAP_FLAG.w
                beq.s   no_swap_x4
                move.l  (A0),(A2)+
                rts
no_swap_x4:
                move.l  (A1),(A2)+
                rts
nx_dx_zero:
                rts

                ENDPART

; A0...p0   A1...p1   A3...x_clip_min
clip_right_NEW: >PART

                move.w  (A0),D0         ; x0
                move.w  (A1),D2         ; x1

; if (x0>x1) swap
                cmp.w   D2,D0
                sgt     VERTICE_SWAP_FLAG.w
                ble.s   cxmax0
                exg     D0,D2
                exg     A0,A1
cxmax0:
                move.w  2(A0),D1        ; y0
                move.w  2(A1),D3        ; y1

; if(x1>x_right)
                cmp.w   A3,D2
                ble.s   nxmax1
; if(x0>x_right)
                cmp.w   A3,D0
                ble.s   nxmax_clip
                rts
nxmax_clip:
; ys = y1 + (x_right-x1)*(y1-y0)/(x1-x0)
; xs = x_right

                move.w  A3,D4           ; x_right
                sub.w   D2,D4           ; x_right-x1

                sub.w   D0,D2           ; x1-x0
                beq.s   nxmax_dx_zero

                neg.w   D1              ; -y0
                add.w   D3,D1           ;  y1-y0

                muls    D4,D1           ;
                divs    D2,D1

                add.w   D1,D3           ; +y1  YS

; if(swap) // P0 #P1 --> S
                tst.b   VERTICE_SWAP_FLAG.w
                bne.s   swap_x5
; out: S
                move.w  A3,(A2)+        ; xs = x_right
                move.w  D3,(A2)+        ; ys
                rts
swap_x5:
; #P0 P1 --> S, v(i+1)--A1
; S
                move.w  A3,(A2)+        ; xs = x_right
                move.w  D3,(A2)+        ; ys
; v(i+1)
                move.l  (A0),(A2)+
                rts
nxmax1:
; P0 P1 --> v(i+1)
                tst.b   VERTICE_SWAP_FLAG.w
                beq.s   no_swap_x6
                move.l  (A0),(A2)+
                rts
no_swap_x6:
                move.l  (A1),(A2)+
                rts

nxmax_dx_zero:
                rts
                ENDPART



; A0...input
clip_polygon_NEW:>PART

*  DC.L $4AFC4E71

;---------------------------------------------------------
; clip top
                movea.w y_clip_min(PC),A3

* lea     polygon_in(PC),A0 ;  p0

                lea     1*4(A0),A1      ;    p1
                lea     polygon_out,A2  ; output

                move.w  count_out(PC),D6
                subq.w  #1,D6
clip_top_loop:
                movem.l A0-A1,-(SP)     **************
                bsr     clip_top_NEW
                movem.l (SP)+,A0-A1     **************
                addq.l  #4,A0           ; p0++
                addq.l  #4,A1           ; p1++
                dbra    D6,clip_top_loop

                move.l  A2,D6
                sub.l   #polygon_out,D6
                lsr.w   #2,D6
                subq.w  #1,D6
                bmi     clip_NEW_degenerated
;---------------------------------------------------------
; clip bottom
                movea.w y_clip_max(PC),A3
                lea     polygon_out,A0  ; p0
                lea     1*4(A0),A1      ;    p1

                move.l  (A0),(A2)+      ;    first->last point

                lea     polygon_in,A2   ;  output

*   DC.L $4AFC4E71

clip_bottom_loop:
                movem.l A0-A1,-(SP)     **************
                bsr     clip_bottom_NEW
                movem.l (SP)+,A0-A1     **************
                addq.l  #4,A0           ; p0++
                addq.l  #4,A1           ; p1++
                dbra    D6,clip_bottom_loop

                move.l  A2,D6
                sub.l   #polygon_in,D6
                lsr.w   #2,D6
                subq.w  #1,D6
                bmi.s   clip_NEW_degenerated
;---------------------------------------------------------
; clip left
                movea.w x_clip_min(PC),A3
                lea     polygon_in,A0   ;  p0
                lea     1*4(A0),A1      ;    p1

                move.l  (A0),(A2)+      ;    first->last point

                lea     polygon_out,A2  ; output

*    DC.L $4AFC4E71
clip_left_loop:
                movem.l A0-A1,-(SP)     **************
                bsr     clip_left_NEW
                movem.l (SP)+,A0-A1     **************
                addq.l  #4,A0           ; p0++
                addq.l  #4,A1           ; p1++
                dbra    D6,clip_left_loop

                move.l  A2,D6
                sub.l   #polygon_out,D6
                lsr.w   #2,D6
                subq.w  #1,D6
                bmi.s   clip_NEW_degenerated
;---------------------------------------------------------
; clip right
                movea.w x_clip_max(PC),A3

                lea     polygon_out,A0  ; p0
                lea     1*4(A0),A1      ;    p1

                move.l  (A0),(A2)+      ;    first->last point

                lea     poly_clipped,A2 ; output

*    DC.L $4AFC4E71

clip_right_loop:
                movem.l A0-A1,-(SP)     **************
                bsr     clip_right_NEW
                movem.l (SP)+,A0-A1     **************
                addq.l  #4,A0           ; p0++
                addq.l  #4,A1           ; p1++
                dbra    D6,clip_right_loop

*   DC.L $4AFC4E71

                move.l  A2,D0
                sub.l   #poly_clipped,D0
                lsr.w   #2,D0
                cmp.w   #3,D0
                blt.s   clip_NEW_degenerated

                rts

clip_NEW_degenerated:
                moveq   #0,D0
                rts
                ENDPART

; A0
; D6...vertices
draw_polygon_clipped:>PART


                move.w  D6,count_out

no_z_clipping:
                move.w  count_out(PC),D6
clipping_needed:
;-------------------------------------------------------
                move.w  D6,D0
                add.w   D0,D0
                add.w   D0,D0
                move.l  (A0),0(A0,D0.w) ; last point

                bsr     clip_polygon_NEW

                tst.w   D0
                bne.s   poly_in_window
                moveq   #-1,D0
                rts
nicht_sichtbar2:
                moveq   #-3,D0
                rts

poly_degenerated_z_clip:
                moveq   #-2,D0
                rts

poly_in_window:

; A2...output end
; D0...num_vertices clipped

                lea     poly_clipped,A0
                move.l  (A0),(A2)+      ; last vertice = 1st: x,y

draw_polygon_a0_d0:

                move.w  D0,D6           ; num vertices
                subq.w  #1,D6

*  DC.L $4AFC4E71

draw_lines_loop:
                movem.l D6/A0,-(SP)
                movem.w (A0),D0-D3

* movem.w D0-D3,x0        *** DEBUG

                bsr     draw_line_eor_d0_d3

                movem.l (SP)+,D6/A0
                addq.l  #2*2,A0
                dbra    D6,draw_lines_loop

                rts

                ENDPART

count_out:      DC.W 0

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

init_colors_plane_effec:>PART

; icpe_new:

*   DC.L $4AFC4E71

                lea     colors_plane_effect(PC),A0

                lea     icpe_list(PC),A1

                moveq   #4-1,D5
icpe_frames_new:
                moveq   #16-1,D6
icpe_l_new:
                lea     (A1),A2
                moveq   #16-1,D0
                sub.w   D6,D0
                beq.s   icpe_n_zero

                clr.w   red
                clr.w   green
                clr.w   blue

                moveq   #0,D2

                REPT 4
                lsr.b   #1,D0
                bcc.s   *+4
                addq.b  #1,D2
                bsr.s   mix_color_a2

                addq.l  #2,A2
                ENDR

                movem.w red(PC),D0-D2

*   lsr.w   #4,D0           ; /16
*   lsr.w   #4,D1           ; /16
*   lsr.w   #4,D2           ; /16

                moveq   #7,D3
                cmp.w   D3,D0
                ble.s   *+2
                move.w  D3,D0
                cmp.w   D3,D1
                ble.s   *+2
                move.w  D3,D1
                cmp.w   D3,D2
                ble.s   *+2
                move.w  D3,D2


                lsl.w   #4,D0
                or.w    D1,D0
                lsl.w   #4,D0
                or.w    D2,D0

                move.w  D0,(A0)+

                bra.s   icpe_n_next
;-----------------------------------------------
                cmp.b   #1,D2
                bne.s   more_bitplanes

                move.w  (A2),(A0)+
                bra.s   icpe_n_next
icpe_n_zero:
                move.w  #$0000,(A0)+
                bra.s   icpe_n_next
more_bitplanes:
                move.w  #$0777,(A0)+
icpe_n_next:
                dbra    D6,icpe_l_new

                addq.l  #4*2,A1

                dbra    D5,icpe_frames_new
                rts

red:            DC.W 0
green:          DC.W 0
blue:           DC.W 0

mix_color_a2:
                movem.l D0-D1,-(SP)

                move.w  (A2),D0
                moveq   #7,D1           ; blue
                and.w   D0,D1
                add.w   D1,blue

                lsr.w   #4,D0
                moveq   #7,D1           ; green
                and.w   D0,D1
                add.w   D1,green

                lsr.w   #4,D0
                and.w   #7,D0           ; red
                add.w   D0,red

                movem.l (SP)+,D0-D1

                rts

                ENDPART

C3              SET $0432
C2              SET $0321
C1              SET $0210
C0              SET $0100

icpe_list:
                DC.W C0,C1,C2,C3
                DC.W C3,C0,C1,C2
                DC.W C2,C3,C0,C1
                DC.W C1,C2,C3,C0

                DATA
black:
zero:           DS.L 16

;-------------------------------------------------------------------------------
colors:         >PART
                DC.W $0000
                DC.W $0777      ;0

                DC.W $0000      ; 1

                DC.W $0777      ;01
                DC.W $0777      ;  2
                DC.W $0777      ;0 2
                DC.W $0777      ; 12
                DC.W $0777      ;012
                DC.W $0777      ;   3
                DC.W $0777      ;0  3
                DC.W $0777      ; 1 3
                DC.W $0777      ;01 3
                DC.W $0777      ;  23
                DC.W $0777      ;0 23
                DC.W $0777      ; 123
                DC.W $0777      ;0123
                ENDPART
colors00:       >PART
                DC.W $0000
                DC.W C0         ;0

                DC.W C1         ; 1

                DC.W $0777      ;01
                DC.W C2         ;  2
                DC.W $0777      ;0 2
                DC.W $0777      ; 12
                DC.W $0777      ;012
                DC.W C3         ;   3
                DC.W $0777      ;0  3
                DC.W $0777      ; 1 3
                DC.W $0777      ;01 3
                DC.W $0777      ;  23
                DC.W $0777      ;0 23
                DC.W $0777      ; 123
                DC.W $0777      ;0123
                ENDPART
;-------------------------------------------------------------------------------

colors_plane_effect:
                DS.W 4*16

                BSS

polygon_in:     DS.W 512*2
polygon_out:    DS.W 512*2

poly_clipped:   DS.W 512*2

_3d_result:     DS.W 4096

linecode:       DS.B $0E00
linecode2:      DS.B $1100

y_field:        DS.B 200*40     ; 320x200, 1 plane

;----------------------------------------------------
                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

                DS.B 512
stack:          DS.B 2
;----------------------------------------------------

                END
