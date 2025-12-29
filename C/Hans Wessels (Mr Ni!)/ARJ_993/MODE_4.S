;
; ARJ mode4 decode function
; Size optimized
; (c) 1993 Mr Ni! (the Great) of the TOS-crew
;
; void decode_f(ulong origsize, char* depack_space, char* packed_data)
; CALL:
; D0 = origsize (long)
; A0 = ptr to depack space
; A1 = ptr to packed data
;
; Register usage:
; d0: temporary register
; d1: temporary register
; d2: temporary register, pointer offset
; d3: bytes to do counter
; d4: #bytes to copy
; d5: klad
; d6: bitbuf,subbitbuf
; d7: #bits in subbitbuf
; a0: depack space
; a1: rbuf_current
; a2: source adres for byte copy
; a3: temporary register
; a4: not used
; a5: not used
; a6: not used
decode_f:
     movem.l D3-D7/A2-A3,-(SP) ; save registers
     move.l  D0,D3           ; origsize
     moveq   #0,D7           ; bitcount = 0
     move.w  A1,D0           ; for checking rbuf_current
     btst    D7,D0           ; does readbuf_current point to an even address?
     beq.s   .cont           ; yes
     move.b  (A1)+,D6        ; pop eight  bits
     moveq   #8,D7           ; 8 bits in subbitbuf
     lsl.w   #8,D6           ;
.cont:
     moveq   #$10,D4         ; push 16 (8) bits into bitbuf
     sub.w   D7,D4           ; subtract still available bits from  d5
     lsl.l   D7,D6           ;
     move.w  (A1)+,D6        ; word in subbitbuf
     lsl.l   D4,D6           ; fill bitbuf
.count_loop:                 ; main depack loop
     move.l  D6,D1           ; evaluate most significant bit bitbuf
     bmi.s   .start_sld      ; =1 -> sliding dictionary
     moveq   #9,D0           ; pop bits from bitbuf for literal
     bsr.s   .getbits        ;
     move.b  D2,(A0)+        ; push byte in buffer
.eval_loop:
     subq.l  #1,D3           ;
     bne.s   .count_loop     ;
     movem.l (SP)+,D3-D7/A2-A3 ;
     rts                     ;

.start_sld:                  ; start decode len
     movea.w #8,A3           ;
     moveq   #0,D2           ; max power
     bsr.s   .get_them       ;
     add.w   D2,D5           ; length
     move.w  D5,D4           ;
     move.l  D6,D1           ; bitbuf
     subq.w  #3,A3           ; move.w  #5,a3
     moveq   #9,D2           ; minimum getbits
     bsr.s   .get_them       ;
     ror.w   #7,D5           ;
     addq.w  #1,D4           ; increment len by one
     add.w   D5,D2           ; calc pointer
     neg.w   D2              ; pointer offset negatief
     lea     -1(A0,D2.w),A2  ; pointer in dictionary
     sub.l   D4,D3           ; sub 'bytes to copy' from 'bytes to do' (d4 is 1 too less!)
.copy_loop_0:
     move.b  (A2)+,(A0)+     ;
     dbra    D4,.copy_loop_0 ;
     bra.s   .eval_loop      ;

.get_them:
     moveq   #1,D0           ; minimum fillbits
     moveq   #0,D5           ; value
.loop:
     add.l   D1,D1           ; shift bit outside
     bcc.s   .einde          ; if '1' end decode
     addx.w  D5,D5           ; value *2+1
     addq.w  #1,D0           ; extra fill
     addq.w  #1,D2           ; extra get
     cmp.w   A3,D0           ; max bits
     bne.s   .loop           ; nog mal
     subq.w  #1,D0           ; 1 bit less to trash
.einde:                      ;
     bsr.s   .fillbits       ; trash bits
     move.w  D2,D0           ; bits to get
     bsr.s   .getbits        ; get bits
     rts                     ;

.getbits:
     move.l  D6,D2           ;
     clr.w   D2              ;
     rol.l   D0,D2           ;
.fillbits:
     sub.b   D0,D7           ; decrease subbitbuf count
     bcs.s   .fill_subbitbuf ; not enough
     rol.l   D0,D6           ; bits to pop from buffer
     rts                     ;

.fill_subbitbuf:             ;
     move.b  D7,D1           ;
     add.b   D0,D1           ;
     sub.b   D1,D0           ;
     rol.l   D1,D6           ;
     move.w  (A1)+,D6        ;
     rol.l   D0,D6           ;
     add.b   #16,D7          ; bits in subbitbuf
     rts

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
********************************************************************************

     END
