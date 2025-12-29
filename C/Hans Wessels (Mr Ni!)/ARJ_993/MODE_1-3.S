
;
; ARJ Mode 1-3 decode functions
; Size optimized
; (c) 1993 Mr Ni! (the Great) of the TOS-crew
;
; This function uses a BIG amount of stack space!
; It uses about 16kB!
; You can reduce this amount with 13320 bytes
; by suppyling A3 with a pointer to a 13320 bytes big
; workspace and removing the stack allocation and
; deallocation code at the right places in the source
; text. (total is 3 lines, 2 at the start, 1 at main rts)
;
;void decode(ulong origsize, char* depack_space, char* packed_data)
;
; CALL:
; D0 = Origsize
; A0 = ptr to depack space
; A1 = ptr to packed data
;
; RETURN
; depacked data in depack space
;

workspacesize   EQU 13320
pointer         EQU 0
rbuf_current    EQU 4
c_table         EQU 8
c_len           EQU 8200
avail           EQU 8710
left            EQU 8712
right           EQU 10750
pt_len          EQU 12788
pt_table        EQU 12808


; register usage:
; D0 =
; D1 =
; D2 = temporary usage
; D3 = byte count
; D4 = command tri-nibble
; D5 = const:  #$100
; D6 = bitbuf, subbitbuf
; D7 = .H: command count, .B: bits in subbitbuf
;
; A0 = klad
; A1 = rbuf_current
; A2 = c_table
; A3 = workspace_ptr
; A4 = text_pointer
; A5 = c_len
; A6 = copy_pointer
; A7 = Stack pointer
decode:
     movem.l D3-D7/A2-A6,-(SP) ;
     lea     -workspacesize(SP),SP ; or supply your own workspace here
     lea     (SP),A3         ; remove if alternative workspace supplied
     movea.l A0,A4           ; depack space
     move.l  D0,D3           ; origsize
     moveq   #0,D7           ; bitcount = 0
     move.w  A1,D0           ; for checking rbuf_current
     btst    D7,D0           ; does readbuf_current point to an even address?
     beq.s   .cont           ; yes
     move.b  (A1)+,D6        ; pop eight  bits
     moveq   #8,D7           ; 8 bits in subbitbuf
     lsl.w   #8,D6
.cont:
     moveq   #$10,D4         ; push 16 (8) bits into bitbuf
     sub.w   D7,D4           ; subtract still available bits from  d5
     lsl.l   D7,D6
     move.w  (A1)+,D6        ; word in subbitbuf
     lsl.l   D4,D6           ; fill bitbuf
     swap    D6
     lea     c_len-pointer(A3),A5 ;
     lea     c_table-c_len(A5),A2
     lea     pt_table-c_len(A5),A0 ;
.count_loop:
     move.w  D6,D2           ; bitbuf in d2
     swap    D7              ; size of Hufmann-block
     dbra    D7,.bnz_cont    ; Hufmann block size > 0?

.blocksize_zero:             ; load a new Hufmann table
     movem.l D3/A0/A2/A4,-(SP)
     move.w  D2,D7           ; blocksize
     subq.w  #1,D7           ; adapt blocksize for dbra
     swap    D7              ; bitcount to LSW
     moveq   #$10,D0         ; pop 16 bits
     bsr     fillbits
     moveq   #$03,D2         ; call-values for read_pt_len()
     moveq   #$05,D1         ;
     moveq   #$13,D0         ;
     bsr     read_pt_len     ; call read_pt_len
     movea.l rbuf_current-c_len(A5),A1
;void read_c_len(void)       ;
     bsr.s   .get_them2
     move.w  D2,D0
     bne.s   .n_niet_nul     ;
     bsr.s   .get_them2
     lea     (A5),A0         ;
     moveq   #$7F,D1         ;
.loop_1:
     clr.l   (A0)+           ; clear table
     dbra    D1,.loop_1
     lea     c_table-pointer(A3),A0
     move.w  #$0FFF,D1
.loop_2:
     move.w  D2,(A0)+
     dbra    D1,.loop_2
     bra     .einde

.get_them2:
     moveq   #9,D0           ;
     move.w  D6,D2           ; bitbuf
     lsr.w   #7,D2           ; shift 'old' bits
     bra     fillbits

.n_niet_nul:                 ; *******************************
;
; Register usage:
;
; d0
; d1
; d2
; d3
; d4
; d5 = $13
; d6 = .l (sub) bitbuf
; d7 = .b bits in bitbuf
;
; a0 = temporary usage
; a1 = rbuf_current
; a2 = right
; a3 = rbuf_tail
; a4 = pt_table
; a5 = c_len
; a6 = left
; a7 = sp
;
     lea     pt_table-c_len(A5),A4 ; pt_table
     lea     right-c_len(A5),A2 ; right
     lea     left-c_len(A5),A6 ; left
     move.w  D0,D3           ; count
     moveq   #0,D4           ;
     moveq   #$13,D5         ;
     moveq   #0,D0           ;
.loop_3:
     move.w  D6,D0           ; sub bitbuf
     lsr.w   #8,D0           ; upper 8 bits
     add.w   D0,D0           ;
     move.w  0(A4,D0.w),D2   ; check pt_table
     bge.s   .c_kleiner_NT   ;
     neg.w   D2
     moveq   #7,D0           ;
     move.w  D6,D1           ; bitbuf
.loop_4:                     ;
     add.w   D2,D2           ;
     btst    D0,D1           ;
     beq.s   .links          ;
     move.w  0(A2,D2.w),D2   ;
     cmp.w   D5,D2           ;
     dbcs    D0,.loop_4      ;
     bra.s   .c_kleiner_NT   ;
.links:                      ;
     move.w  0(A6,D2.w),D2   ;
     cmp.w   D5,D2           ;
     dbcs    D0,.loop_4      ;

.c_kleiner_NT:               ;
     move.b  pt_len-pt_table(A4,D2.w),D0 ;
     bsr     fillbits
     cmp.w   #2,D2           ;
     bgt.s   .c_groter_2     ;
     beq.s   .c_niet_1       ;
     tst.w   D2              ;
     beq.s   .loop_5_init    ;
     moveq   #4,D0
     bsr     getbits
     addq.w  #2,D2           ;
     bra.s   .loop_5_init    ;
.c_niet_1:
     bsr.s   .get_them2
     add.w   D5,D2           ;
.loop_5_init:
     moveq   #0,D0           ;
     lea     0(A5,D4.w),A0   ;
     add.w   D2,D4           ;
.loop_5:
     move.b  D0,(A0)+        ;
     dbra    D2,.loop_5      ;
     bra.s   .loop_3_test    ;
.c_groter_2:
     moveq   #0,D0           ;
     subq.w  #2,D2           ;
     move.b  D2,0(A5,D4.w)   ;
.loop_3_test:
     addq.w  #1,D4           ;
     cmp.w   D4,D3           ;
     bgt.s   .loop_3         ;
     move.w  #$01FE,D1       ;
     sub.w   D4,D1           ;
     lea     0(A5,D4.w),A0   ;
     bra.s   .loop_6_test    ;
.loop_6:
     move.b  D0,(A0)+        ;
.loop_6_test:
     dbra    D1,.loop_6      ;
     move.l  A1,rbuf_current-c_len(A5)
     lea     c_table-c_len(A5),A1 ;
     moveq   #$0C,D1         ;
     movea.l A5,A0           ;
     move.w  #$01FE,D0       ;
     bsr     make_table      ;
     movea.l rbuf_current-c_len(A5),A1
.einde:
     moveq   #-1,D2          ;
     moveq   #$05,D1         ;
     moveq   #$11,D0         ;
     bsr     read_pt_len     ;
     movea.l rbuf_current-c_len(A5),A1
     movem.l (SP)+,D3/A0/A2/A4
     move.w  #$0100,D5       ; constant
     swap    D7              ; blocksize to LSW
     move.w  D6,D2

;***********************
;
; Register usage:
;
; d0 = temporary usage
; d1 = temporary usage
; d2 = temporary usage
; d3 = loopcount
; d4 = command byte
; d5 = const: $100
; d6 = (sub)bitbuf
; d7 = .h: command count, .b byte count
;
; a0 = pt_table
; a1 = rbuf_current
; a2 = c_table
; a3 = rbuf_tail
; a4 = text
; a5 = c_len
; a6 = source pointer
; a7 = (sp)

.bnz_cont:
     swap    D7              ; bitcount in LSW d7
     lsr.w   #4,D2           ; charactertable is 4096 bytes (=12 bits)
     add.w   D2,D2
     move.w  0(A2,D2.w),D2   ; pop character
     bmi.s   .j_grotergelijk_nc
.decode_c_cont:              ;
     move.b  0(A5,D2.w),D0   ; pop 'charactersize' bits from buffer
     bsr     fillbits
     sub.w   D5,D2           ;
     bcc.s   .sliding_dic    ;
     move.b  D2,(A4)+        ; push character into buffer
     subq.l  #1,D3
     bne     .count_loop
.decode_einde:
     lea     workspacesize(SP),SP; remove if alternative workspace supplied
     movem.l (SP)+,D3-D7/A2-A6 ;
     rts                     ;

.j_grotergelijk_nc:
     moveq   #$03,D1         ;
     move.w  #$01FE,D0
     bsr.s   .fidel_no
     bra.s   .decode_c_cont  ;

.p_j_grotergelijk_np:
     moveq   #$07,D1         ;
     moveq   #$11,D0
     bsr.s   .fidel_no
     bra.s   .p_cont         ;

.fidel_no:
     neg.w   D2
     lea     left-c_len(A5),A0 ;
     lea     right-left(A0),A6 ;
.mask_loop:
     add.w   D2,D2           ;
     btst    D1,D6           ;
     bne.s   .bitbuf_en_mask ;
     move.w  0(A0,D2.w),D2   ;
     cmp.w   D0,D2           ;
     dbcs    D1,.mask_loop   ;
     lea     pt_table-c_len(A5),A0 ;
     rts
.bitbuf_en_mask:
     move.w  0(A6,D2.w),D2   ;
     cmp.w   D0,D2           ;
     dbcs    D1,.mask_loop   ;
     lea     pt_table-c_len(A5),A0 ;
     rts

.sliding_dic:
     move.w  D2,D4
     addq.w  #2,D4           ;
     move.w  D6,D2           ;
     lsr.w   #8,D2           ;
     add.w   D2,D2           ;
     move.w  0(A0,D2.w),D2   ;
     bmi.s   .p_j_grotergelijk_np ;
.p_cont:
     move.b  pt_len-pt_table(A0,D2.w),D0 ;
     bsr.s   fillbits
     move.w  D2,D0           ;
     beq.s   .p_einde        ;
     subq.w  #1,D0           ;
     move.w  D6,D2           ; subbitbuf
     swap    D2
     move.w  #1,D2           ;
     rol.l   D0,D2           ; shift 'old' bits
     bsr.s   fillbits
.p_einde:
     neg.w   D2              ; pointer offset negatief
     lea     -1(A4,D2.w),A6  ; pointer in dictionary
     sub.l   D4,D3           ; sub 'bytes to copy' from 'bytes to do' (d4 is 1 too less!)
.copy_loop_0:
     move.b  (A6)+,(A4)+     ;
     dbra    D4,.copy_loop_0
     subq.l  #1,D3
     bne     .count_loop
     bra     .decode_einde

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
********************************************************************************

getbits:
     move.l  D6,D2
     swap    D2
     clr.w   D2
     rol.l   D0,D2
fillbits:
     sub.b   D0,D7
     bcs.s   .fill_subbitbuf
     rol.l   D0,D6
     rts
.fill_subbitbuf:
     move.b  D7,D1
     add.b   D0,D1
     sub.b   D1,D0
     rol.l   D1,D6
     swap    D6
     move.w  (A1)+,D6
     swap    D6
     rol.l   D0,D6
     add.b   #16,D7
     rts

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
*******************************************************************************

read_pt_len:
     move.w  D0,D5
     move.w  D1,D3
     move.w  D2,-(SP)
     move.w  D1,D0
     bsr.s   getbits
     lea     pt_len-c_len(A5),A0
     lea     pt_table-pt_len(A0),A2
     move.w  D2,D4
     bne.s   .n_niet_nula
     move.w  D3,D0
     bsr.s   getbits
     subq.w  #1,D5
._11:
     clr.b   (A0)+
     dbra    D5,._11
     moveq   #$7F,D0
.loop_2a:
     move.w  D2,(A2)+
     move.w  D2,(A2)+
     dbra    D0,.loop_2a
     addq.l  #2,SP
     move.l  A1,rbuf_current-c_len(A5)
     rts
.n_niet_nula:
     clr.w   D3
.loop_3a:
     move.l  D6,D2
     swap    D2
     clr.w   D2
     rol.l   #3,D2
     cmp.w   #7,D2
     bne.s   .c_niet_7
     moveq   #12,D0
     bra.s   .loop_4a_test
.loop_4a:
     addq.w  #1,D2
.loop_4a_test:
     btst    D0,D6
     dbeq    D0,.loop_4a
.c_niet_7:
     moveq   #3,D0
     cmp.w   #7,D2
     bcs.s   .endif
     moveq   #-3,D0
     add.w   D2,D0
.endif:
     move.b  D2,0(A0,D3.w)
     bsr.s   fillbits
     addq.w  #1,D3
     cmp.w   (SP),D3
     bne.s   .loop_3a_test
     moveq   #2,D0
     bsr     getbits
     moveq   #0,D0
     lea     0(A0,D3.w),A6
     add.w   D2,D3
     bra.s   .loop_5a_test
.loop_5a:
     move.b  D0,(A6)+
.loop_5a_test:
     dbra    D2,.loop_5a
.loop_3a_test:
     cmp.w   D3,D4
     bgt.s   .loop_3a
     moveq   #0,D0
     lea     0(A0,D3.w),A6
     bra.s   .loop_6a_test
.loop_6a:
     move.b  D0,(A6)+
     addq.w  #1,D3
.loop_6a_test:
     cmp.w   D3,D5
     bgt.s   .loop_6a
     move.w  D5,D0
     move.l  A1,rbuf_current-c_len(A5)
     movea.l A2,A1
     moveq   #8,D1
     addq.l  #2,SP
make_table:
     movem.l D6-D7/A3/A5,-(SP)
     lea     -$6C(SP),SP
     movea.w D0,A6
     movea.l A0,A2
     move.w  D1,D4
     add.w   D4,D4
     move.w  D1,D3
     movea.l A1,A4
     lea     $48(SP),A1
     movea.l A1,A0
     moveq   #7,D0
.j_loop_0:
     clr.l   (A0)+
     dbra    D0,.j_loop_0
     movea.l A2,A0
     move.w  A6,D0
     subq.w  #1,D0
.loop_0:
     clr.w   D1
     move.b  (A0)+,D1
     add.w   D1,D1
     addq.w  #1,-2(A1,D1.w)
     dbra    D0,.loop_0
     lea     2(SP),A0
     moveq   #0,D1
     move.w  D1,(A0)+
     moveq   #15,D2
.j_loop_1:
     move.w  (A1)+,D0
     lsl.w   D2,D0
     add.w   D0,D1
     move.w  D1,(A0)+
     dbra    D2,.j_loop_1
     moveq   #$10,D0
     sub.w   D3,D0
     lea     2(SP),A1
     lea     $26(SP),A0
     moveq   #1,D1
     moveq   #-1,D2
     add.b   D3,D2
     lsl.w   D2,D1
.loop_1a:
     move.w  (A1),D2
     lsr.w   D0,D2
     move.w  D2,(A1)+
     move.w  D1,(A0)+
     lsr.w   #1,D1
     bne.s   .loop_1a
     moveq   #1,D1
     moveq   #-1,D2
     add.w   D0,D2
     lsl.w   D2,D1
.loop_2b:
     move.w  D1,(A0)+
     lsr.w   #1,D1
     bne.s   .loop_2b
     move.w  2(SP,D4.w),D2
     lsr.w   D0,D2
     beq.s   .endif0
     moveq   #1,D5
     lsl.w   D3,D5
     sub.w   D2,D5
     subq.w  #1,D5
     add.w   D2,D2
     lea     0(A4,D2.w),A0
.loop_3b:
     move.w  D1,(A0)+
     dbra    D5,.loop_3b
.endif0:
     moveq   #1,D1
     moveq   #-1,D2
     add.b   D0,D2
     lsl.w   D2,D1
     lea     avail-c_len(A5),A1
     lea     right-avail(A1),A3
     lea     $6A(SP),A5
     move.w  A6,(A1)
     moveq   #0,D5
.loop_4b:
     clr.w   D3
     move.b  0(A2,D5.w),D3
     beq.s   .loop_4b_inc_0
     add.w   D3,D3
     lea     0(SP,D3.w),A0
     move.w  (A0),D2
     move.w  D2,D6
     add.w   $24(A0),D6
     move.w  D6,(A0)
     cmp.w   D3,D4
     blt.s   .len_groter_tablebits_j
     sub.w   D2,D6
     add.w   D2,D2
     lea     0(A4,D2.w),A0
     subq.w  #1,D6
.j_loop_2:
     move.w  D5,(A0)+
     dbra    D6,.j_loop_2
.loop_4b_inc_0:
     addq.w  #1,D5
     cmp.w   A6,D5
     blt.s   .loop_4b
     bra.s   .loop_4b_end
.len_groter_tablebits_j:
     move.w  D2,D7
     lsr.w   D0,D7
     add.w   D7,D7
     lea     0(A4,D7.w),A0
     move.l  A0,pointer-avail(A1)
     neg.w   (A0)
     move.w  D3,D6
     sub.w   D4,D6
     beq.s   .loop_6b_end
     move.w  D6,(A5)
.loop_6b:
     move.w  (A0),D7
     add.w   D7,D7
     bne.s   .p_is_niet_nul
     move.w  (A1),D6
     move.w  D6,(A0)
     add.w   D6,D6
     move.w  D7,2(A1,D6.w)
     move.w  D7,0(A3,D6.w)
     addq.w  #1,(A1)
     move.w  D6,D7
.p_is_niet_nul:
     lea     2(A1,D7.w),A0
     move.w  D2,D6
     and.w   D1,D6
     beq.s   .left
     lea     right-left(A0),A0
.left:
     add.w   D2,D2
     subq.w  #2,(A5)
     bhi.s   .loop_6b
.loop_6b_end:
     move.w  D5,(A0)
     movea.l pointer-avail(A1),A0
     neg.w   (A0)
.loop_4b_inc:
     addq.w  #1,D5
     cmp.w   A6,D5
     blt     .loop_4b
.loop_4b_end:
     lea     $6C(SP),SP
     movem.l (SP)+,D6-D7/A3/A5
     rts

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
********************************************************************************

     END
