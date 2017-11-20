N               equ 4096
F               equ 18
THRESHOLD       equ 2
NIL             equ $1000

                import  match_length
                import  last_mat
                import  printcou
                import  textsize
                import  code_buf
                import  text_buf
                import  infile
                import  outfile

                import  InitTree
                import  fgetc
                import  match_position
                import  fputc
                import  _StdOutF
                import  codesize

				import	dad
				import	lson
				import	rson
                export  Encode
                export  InsertONode
                export  DeleteONode
DeleteONode:    movem.l D0-A6,-(SP)
                lea     lson,A2
                lea     rson,A3
                move.w  D0,D5
                move.w  #2*NIL,D7
                lea     dad,A0
                add.w   D5,D5
; if dad[p] == NIL
                cmp.w   0(A0,D5.w),D7
                beq.b   DNode_9
; if rson[p] == NIL
                cmp.w   0(A3,D5.w),D7
                beq.b   DNodex1

; if lson[p] == NIL
DNode_1:        cmp.w   0(A2,D5.w),D7
                beq.b   DNodex2

DNode_2:        lea     0(A2,D5.w),A4   ; lson[p]
                lea     0(A3,D5.w),A5   ; rson[p]
                move.w  (A4),D1

                move.w  D1,D2
                cmp.w   0(A3,D2.w),D7
                beq.b   DNode_5
; do { q=rson[q] } while (rson[q] != NIL}

DNode_3:        move.w  0(A3,D2.w),D2
                cmp.w   D7,D2
                beq.b   DNode_4
                move.w  D2,D1
                bra.b   DNode_3

DNode_4:        move.w  D1,D2
                move.w  0(A0,D2.w),D3
                lea     0(A2,D2.w),A1   ; rson[q]
                move.w  (A1),0(A3,D3.w) ; lson[dad[q]] = rson[q]
                move.w  (A1),D3
                move.w  0(A0,D2.w),0(A0,D3.w) ; dad[rson[q]]=dad[q[
                move.w  (A4),D3
                move.w  D3,(A1)         ; rson[q]=rson[p]
                move.w  D1,0(A0,D3.w)
DNode_5:        move.w  (A5),D3
                move.w  D3,0(A3,D2.w)   ; rson[q] = rson[p]
                move.w  D1,0(A0,D3.w)   ; dad[rson[p]] = q
DNode_6:        move.w  0(A0,D5.w),0(A0,D1.w) ; dad[q]=dad[p]

                lea     0(A0,D5.w),A5   ; A5=*dad[p]
                move.w  (A5),D3         ; D3 = cardinal dad[p]
                cmp.w   0(A3,D3.w),D5
                bne.b   DNode_7         ; if rson[dad[p]]=p
; else ..
                move.w  D1,0(A3,D3.w)   ; rson[dad[p]]=q
                move.w  D7,(A5)
                movem.l (SP)+,D0-A6
                rts
; if ..
DNode_7:        move.w  D1,0(A2,D3.w)   ; lson[dad[p]]=q
; endif ..
DNode_8:        move.w  D7,(A5)         ; dad[p]=NIL
DNode_9:        movem.l (SP)+,D0-A6
                rts
DNodex2:        move.w  0(A3,D5.w),D1
                bra.b   DNode_6
DNodex1:        move.w  0(A2,D5.w),D1
                bra.b   DNode_6
; void InsertNode(int r);
; rester int i,p,cmp;
; unsigned char *key;
; unigned c;

; register D1 = cmp
; register D2 = p
; register A1 = *key
; register A2 = rson
; register A3 = lson

; D0 = cardinal p

; Ben”tigt: A0 = text_buf
;           A2 = lson
;           A3 = rson
;           A4 = dad

                lea     lson,A2
                lea     rson,A3
                lea     text_buf,a5
InsertONode:    movem.l D0-A6,-(SP)
                lea     lson,A2
                lea     rson,A3
                lea     text_buf,a5

                move.w  D0,D6
                moveq   #1,D1           ; cmp=1

                lea     0(A5,D6.w),A1   ; key=&text_buf[r]
                add.w   D6,D6

                moveq   #0,D2
                move.b  (A1),D2         ; key[0]
                add.w   #4097,D2        ; p= N+1+key[0]
                add.w   D2,D2           ; cardinal

                move.w  #2*NIL,D7       ; NIL
                move.w  D7,0(A2,D6.w)   ; rson[r] = NIL
                move.w  D7,0(A3,D6.w)   ; lson[r] = NIL

                clr.w   match_length    ; match_length=0
; for ...
                lea     dad,A4
I_Node1:        tst.w   D1              ; if (cmp > 0) {
                blt.b   I_Node4
                lea     0(A3,D2.w),A6   ; rson[p]
                cmp.w   (A6),D7         ; if rson[p] != NIL
                bne.b   I_Node5         ; p=rson[p] else

I_Node2:        move.w  D6,(A6)         ; rson[p] = r
                move.w  D2,0(A4,D6.w)   ; dad[r] = p
                bra     I_Node11

I_Node3:        move.w  D6,(A6)         ; lson[p] = r
                move.w  D2,0(A4,D6.w)   ; dad[r] = p
                bra     I_Node11

I_Node4:        lea     0(A2,D2.w),A6   ; d7=lson[p]
                cmp.w   (A6),D7         ; if lson[p] != NIL
                beq.b   I_Node3

; for (i=1; i<F; i++)
I_Node5:        move.w  (A6),D2
                moveq   #0,D1
                moveq   #F-2,D5
                lea     1(A1),A0        ; key[1]
                lsr.w   #1,D2
                lea     1(A5,D2.w),A6   ; text_buf[p+1]
                add.w   D2,D2
I_Node6:        cmpm.b  (A0)+,(A6)+
                dbne    D5,I_Node6

I_Node7:        moveq   #F-1,D3
                sub.w   D5,D3
                moveq   #0,D5
                move.b  -1(A0),D1
                move.b  -1(A6),D5
                sub.w   D5,D1           ; d1=key[i]-text_buf[p+i]

                lea     match_length,A6
                cmp.w   (A6),D3         ; if i>match_length
                ble.b   I_Node1

                move.w  D2,D4
                lsr.w   #1,D4
                move.w  D4,match_position

                move.w  D3,(A6)         ; match_length=i
                cmp.w   #F,D3           ; if i>=F
                blt.b   I_Node1         ; break

;  break
I_Node8:        move.w  0(A4,D2.w),0(A4,D6.w) ; dad[r] = dad[p]
                move.w  0(A2,D2.w),0(A2,D6.w) ; lson[r] = lson[p]
                move.w  0(A3,D2.w),0(A3,D6.w) ; rson[r] = rson[p[

                move.w  0(A2,D2.w),D4
                move.w  D6,0(A4,D4.w)   ; dad[lson[p]]=r

                move.w  0(A3,D2.w),D4
                move.w  D6,0(A4,D4.w)   ; dad[rson[p]]=r

                lea     0(A4,D2.w),A6
                move.w  (A6),D4         ; a6 = *dat[p]
                cmp.w   0(A3,D4.w),D2
                beq.b   I_Node12

I_Node9:        move.w  (A6),D3
                move.w  D6,0(A2,D3.w)   ; lson[dad[p]] = r

I_Node10:       move.w  D7,(A6)         ; dad[p] = NIL
I_Node11:       movem.l (SP)+,D0-A6
                rts

I_Node12:       move.w  D6,0(A3,D4.w)
                move.w  D7,(A6)         ; dad[p] = NIL
                movem.l (SP)+,D0-A6
                rts
                end
