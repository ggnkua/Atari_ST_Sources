;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
make_feedback_code:>PART

*     DC.L $4AFC4E71

*  bsr     check_table

                bsr     get_offsets

                lea     x_offsets_delta,A0
                addq.l  #2,A0

                lea     x_code,A6

*    DC.L $4AFC4E71

                bsr     make_xO         ; overlay left

                move.l  #$00070001,D5   ; x_offset inc
                move.w  #160/4-1,D6
mfc_x:
                lea     code_x_inc(PC),A1 ;  inc4
                move.w  (A0)+,D0        ;    offset
                beq.s   mfc_0
                subq.w  #4,D0
                beq.s   mfc_4
                subq.w  #4,D0
                beq.s   mfc_8
mfc_ILL:
                DC.L $4AFC4E71
mfc_8:
                lea     code_x_inc2(PC),A1 ; inc8
                bra.s   mfc_done
mfc_0:
                DC.L $4AFC4E71
mfc_4:

mfc_done:
                bsr     copy_code
                add.w   D5,2+mfc_outscreen1 ; inc x screen
                add.w   D5,2+mfc_outscreen2 ; inc x screen
                swap    D5

                addq.w  #1,c

                dbra    D6,mfc_x

                bsr     make_xO         ; overlay right

*   DC.L $4AFC4E71

                move.w  #$4E75,(A6)+

                lea     x_code(PC),A0
                movea.l A6,A1
                move.l  A1,D0
                sub.l   A0,D0
                rts

c:              DC.W 0
                ENDPART
;------------------------------------------------------
make_xO:        >PART
                moveq   #80/4-1,D6      ; overlay size
mfc_xO:
                lea     code_xO_inc(PC),A1 ; inc4
                move.w  (A0)+,D0        ;    offset
                beq.s   mfc_0O
                subq.w  #4,D0
                beq.s   mfc_4O
                subq.w  #4,D0
                beq.s   mfc_8O
mfc_ILL_o:
                DC.L $4AFC4E71
mfc_8O:
                lea     code_xO_inc2(PC),A1 ; inc8
                bra.s   mfc_doneO
mfc_0O:
                DC.L $4AFC4E71
mfc_4O:

mfc_doneO:
                bsr     copy_code

                addq.w  #1,c

                dbra    D6,mfc_xO
                rts
                ENDPART
;------------------------------------------------------
copy_code:      >PART           ; A1-->A6
                move.w  (A1)+,(A6)+
                tst.l   (A1)
                bne.s   copy_code
                rts
                ENDPART
;------------------------------------------------------
; A1...xp,yp
; A2...chunkyOut
; A3...uv
; A6...screen
;------------------------------------------------------
code_xO_inc:    >PART
                move.l  (A3)+,D6        ; fetch

* moveq   #0,D6

                add.l   (A1)+,D6
                beq.s   pix_empty2
                lsr.l   #1,D6           ; /2
                move.l  D6,D3           ;
                lsr.l   #4,D3           ; /2/16
                and.l   D4,D3
;----------------------------
                sub.l   D3,D6           ;
                and.l   D5,D6
pix_empty2:
                move.l  D6,(A2)+
;----------------------------
code_xO_fetch_e:
                DC.L 0
                ENDPART
code_xO_inc2:   >PART
                addq.l  #4,A3           ; inc
                move.l  (A3)+,D6        ; fetch

* moveq   #0,D6

                add.l   (A1)+,D6
                beq.s   pix_empty3
                lsr.l   #1,D6           ; /2
                move.l  D6,D3           ;
                lsr.l   #4,D3           ; /2/16
                and.l   D4,D3
;----------------------------
                sub.l   D3,D6           ;
                and.l   D5,D6
pix_empty3:
                move.l  D6,(A2)+
;----------------------------
code_x0_nofetch_e:
                DC.L 0
                ENDPART
;------------------------------------------------------
code_x_inc:     >PART
                move.l  (A3)+,D6        ; fetch

*  moveq   #0,D6

                add.l   (A1)+,D6
                beq.s   pix_empty4
                lsr.l   #1,D6           ; /2
                move.l  D6,D3           ;
                lsr.l   #4,D3           ; /2/16
                and.l   D4,D3
;----------------------------
                sub.l   D3,D6           ;
                and.l   D5,D6
                move.l  D6,(A2)+        ; ChunkyOut
;----------------------------
                move.w  D6,D1
                swap    D6
                move.w  D6,D0
                movea.l D0,A4
                move.l  (A4),D6
                movea.l D1,A4
                or.l    (A4),D6
                bra.s   mfc_outscreen1
pix_empty4:
                move.l  D6,(A2)+        ; ChunkyOut

mfc_outscreen1: movep.l D6,0(A6)
code_x_fetch_e:
                DC.L 0
                ENDPART
code_x_inc2:    >PART
                addq.l  #4,A3           ; inc
                move.l  (A3)+,D6        ; fetch

*  moveq   #0,D6

                add.l   (A1)+,D6
                beq.s   pix_empty5
                lsr.l   #1,D6           ; /2
                move.l  D6,D3           ;
                lsr.l   #4,D3           ; /2/16
                and.l   D4,D3
;----------------------------
                sub.l   D3,D6           ;
                and.l   D5,D6
                move.l  D6,(A2)+        ; ChunkyOut
;----------------------------
                move.w  D6,D1
                swap    D6
                move.w  D6,D0
                movea.l D0,A4
                move.l  (A4),D6
                movea.l D1,A4
                or.l    (A4),D6
                bra.s   mfc_outscreen2
pix_empty5:
                move.l  D6,(A2)+        ; ChunkyOut
mfc_outscreen2: movep.l D6,0(A6)
code_x_nofetch_e:
                DC.L 0
                ENDPART
;------------------------------------------------------
check_table:    >PART
*   DC.L $4AFC4E71

                lea     uv_map,A0
                move.w  #UV_X-1,D6
ct_x:
                lea     (A0),A1
                move.w  (A0),D0
                move.w  #UV_Y-1,D7
ct_y:
                cmp.w   (A1),D0
                beq.s   ct_ok
                DC.L $4AFC4E71
ct_ok:
                lea     UV_X*4(A1),A1
                dbra    D7,ct_y
                addq.l  #4,A0
                dbra    D6,ct_x
                rts
                ENDPART
;------------------------------------------------------
get_offsets:    >PART
*  DC.L $4AFC4E71

                bsr     get_x_offsets
                bsr     get_y_offsets
                rts
                ENDPART
;------------------------------------------------------
get_x_offsets:  >PART

*     DC.L $4AFC4E71

                lea     uv_map,A0
                lea     x_offsets(PC),A1
                lea     x_offsets_delta(PC),A2

                moveq   #0,D1           ; prev

                moveq   #-4,D6
                move.w  #UV_X/4-1,D7
go_x:
                move.w  (A0),D0
                and.w   D6,D0

                move.w  D0,(A1)+        ; x_offsets

                sub.w   D1,D0           ;-prev

                move.w  D0,(A2)+        ; x_offsets_delta

                add.w   D0,D1           ; prev

*    addq.l  #4,A0
                adda.w  #4*4,A0         ; skip 4 pixel
                dbra    D7,go_x

                move.w  #4,(A2)+        ; x_offsets_delta END

                lea     x_offsets_delta(PC),A0

                rts
                ENDPART
get_y_offsets:  >PART

                lea     uv_map+2,A0
                lea     y_offsets(PC),A1

                move.w  #UV_Y-1,D7
go_y:
                move.w  (A0),D0
                mulu    #XW,D0
                move.l  D0,(A1)+
                lea     UV_X*4(A0),A0
                dbra    D7,go_y

                lea     y_offsets(PC),A0

                rts
                ENDPART
;------------------------------------------------------
x:
x_offsets:      DS.W UV_X+16
xd:
x_offsets_delta:DS.W UV_X+16

y_offsets:      DS.L UV_Y+16
;------------------------------------------------------
x_code:         DS.B 4096
;------------------------------------------------------
;-------------------------------------------------------------------------------

colram_ptrs:
                DC.L colorram0
                DC.L colorram1

jitter_x:       DC.L 0
jitter_y:       DC.L 0

swap_colram_ptrs:>PART
                movem.l colram_ptrs(PC),A0-A1
                exg     A0,A1
                movem.l A0-A1,colram_ptrs
                rts
                ENDPART

Q:
FEEDBACK_TEST:  >PART

*   DC.L $4AFC4E71

                bsr     swap_colram_ptrs

                bsr     set_text

;-------------------------------------------------------------
                movea.l colram_ptrs(PC),A0 ; v,u    SRC
                movea.l colram_ptrs(PC),A1 ; yp,xp  SRC
                movea.l colram_ptrs+4(PC),A2 ; yp,xp  DEST

                movea.l screen1(PC),A6
;-------------------------------------------------------------

; center input!
xo              SET -10         ; -16         ;-80-16      ; -24
yo              SET -4          ; -23
center_map      SET xo+yo*XW

                adda.l  #center_map,A0

*   adda.l  jitter_x(PC),A0
*   adda.l  jitter_y(PC),A0
                eori.l  #2,jitter_x
                eori.l  #XW,jitter_y

*    bra     no_jitter

                movea.l jpos,A5
                cmpi.w  #-1,(A5)
                bne.s   jm
                lea     jlist,A5
jm:
                adda.w  (A5)+,A0        ;j_x
                adda.w  (A5)+,A0        ;j_y
                move.l  A5,jpos

no_jitter:
                movem.l c2p_adr(PC),D0-D1

                move.l  #$0F0F0F0F,D4
                move.l  mb_mask(PC),D5

*    DC.L $4AFC4E71

                lea     y_offsets(PC),A5

                moveq   #100-1,D7
feedback_lines:
                lea     (A0),A3
                adda.l  (A5)+,A3        ; y_pos

; A0-->A3
; A1...xp,yp
; A2...chunkyOut
; A3...uv(A0)
; A5   y_offsets
; A6...screen
                bsr     x_code


                lea     XW-UV_X(A1),A1  ; chunkyBuffer
                lea     XW-UV_X(A2),A2  ; chunkyBuffer

                lea     2*160(A6),A6    ; screen_y++
                dbra    D7,feedback_lines

                rts
                ENDPART

                >PART ' debug '
                pea     (A1)
                pea     (A2)

                bsr     x_code

                move.l  A2,D6
                sub.l   (SP),D6
                cmp.l   #UV_X,D6
                beq.s   ok0
                DC.L $4AFC4E71
ok0:
                move.l  A1,D6
                sub.l   4(SP),D6
                cmp.l   #UV_X,D6
                beq.s   ok1
                DC.L $4AFC4E71
ok1:

                movea.l (SP)+,A2
                movea.l (SP)+,A1
                adda.w  #XW,A1
                adda.w  #XW,A2
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

