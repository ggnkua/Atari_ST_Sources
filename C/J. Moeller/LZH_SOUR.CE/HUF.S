N               equ 4096                ;Buffer size
F               equ 60                  ;lookahead buffer size
THRESHOLD       equ 2
N_CHAR          equ 256-THRESHOLD+F     ;kinds of characters (0..N_CHAR-1)
T               equ N_CHAR*2-1          ;size of table

; -----------------------------------------------------------------------
;               putCode
; -----------------------------------------------------------------------
 
; void Putcode(register int l, register int c)

; d7 = putlen 
; register a2 = putlen
;        -2(a2)=putbuf
                macro   putcode
                local PutCode1
                local PutCode2
                movem.w D3-D4,-(SP)
                move.w  D0,D4
                move.w  D1,D3
                move.b  d7,D2           ; d2=putlen
                lsr.w   D2,D1
                or.w    D1,d6           ; putbuf != c >> putlen
 
                add.b   D0,d7           ; putlen+=l
                cmpi.b  #8,d7           ; putlen
                bcs     PutCode2
 
                move.w  d6,D0           ; putbuf
                lsr.w   #8,D0
                fputc   d0              ; putc(putbuf,outfile)
; if ((putlen -= 8) >=8)
                subq.b  #8,d7           ; putlen
                cmpi.b  #8,d7           ; putlen
                bcs.b   PutCode1
 
                fputc   d6              ; putc(putbuf,outfile)
                addq.l  #2,codesize     ; codesize+=2
                subq.b  #8,d7           ;putlen-=8
 
                move.w  D3,D0
                move.b  D4,D1
                sub.b   d7,D1           ; putlen
                lsl.w   D1,D0
                move.w  D0,d6           ; putbuf = c << (l-putlen)
                bra.b   PutCode2
 
PutCode1:       move.w  d6,D0           ; putbuf
                lsl.w   #8,D0
                move.w  D0,d6           ; putbuf <<=8
                addq.l  #1,codesize     ; codesize++
PutCode2:       movem.w (SP)+,D3-D4
                endm

; -----------------------------------------------------------------------
;               update
; -----------------------------------------------------------------------
 
 
; void update(int c);
; register int i,j,k,l;
; register D3 = c
; register D1 = k
; register D2 = l
; register A1 = son
 
; register D5 = cardinal c
; a4 = freq[c]

;uses: d0,d1,d2,d5
;      a0,a1,a2,a3,a4,a6
; expects:   a2 = freq          d2 = 2*T
;            a4 = son
                macro   update
                local   upd_1
                local   upd_2
                local   upd_2a
                local   upd_2b
                local   upd_3
                local   upd_4
                local   upd_5
                local   upd_6
                local   updx
                local   updx1
                local   updrecon

                tst.w   R*2(A2)  ; if freq[R] == MAX_FREQ
                bmi     updrecon
 
upd_1:          lea     prnt-freq(a2),A0         ; A0 = prnt

                move.w  0(a0,d0.w),d0
; do {
                lea     0(A2,d0.w),A1   ; A1 = freq[c]
                addq.w  #1,(A1)         ; freq[c]++
 
; Ab hier: l=d5
; if the order is disturbed, exchange nodes
                cmpm.w  (A1)+,(a1)+     ; if k>freq[l=c+1])
                bcs.b   upd_2b

upd_2a:         move.w  0(a0,d0.w),d0
                beq.b   updx
; do {
upd_2:          lea     0(A2,d0.w),A1   ; A1 = freq[c]
                addq.w  #1,(A1)         ; freq[c]++
 
; Ab hier: l=d5
; if the order is disturbed, exchange nodes
                cmpm.w  (A1)+,(a1)+     ; if k>freq[l=c+1])
                bcc.b   upd_2a

; while k > freq[++l]
upd_2b:         subq.w  #1,-4(a1)
                move.w  -4(a1),d1
upd_3:          cmp.w   (a1)+,D1
                beq.b   upd_3           ; while (k>freq[++l]);
                subq.l  #4,a1
                addq.w  #1,(a1)

                sub.l   A2,a1
 
                move.w  0(a4,d0.w),d4   ; i=son[c]
                move.w  a1,(a0,d4.w)    ;prnt[i]=l
 
                cmp.w   d2,d4         ; if i<T
                bge.b   upd_4
                move.w  a1,2(A0,d4.w)   ; prnt[i+1]=l
 
upd_4:          move.w  0(A4,a1.w),D1         ; j=son[l]
                move.w  d4,0(A4,a1.w)       ; son[l]=j
 
                move.w  d0,(A0,d1.w)    ; prnt[j] = c
 
                cmp.w   d2,D1         ; if j<T
                bge.b   upd_5
                move.w  d0,2(A0,d1.w)   ; prnt[j+1]=c
 
upd_5:          move.w  D1,0(a4,d0.w)   ; son[c]=j
                move.w  a1,d0
upd_6:          move.w  0(a0,d0.w),d0
                beq.b   updx1
; do {
                lea     0(A2,d0.w),A1   ; A1 = freq[c]
                addq.w  #1,(A1)         ; freq[c]++
;                move.w  (A1)+,D1         ; k=freq[c]
 
; Ab hier: l=d5
; if the order is disturbed, exchange nodes
                cmp.w   (A1)+,(a1)+     ; if k>freq[l=c+1])
                bcc.b   upd_6 
                bra.b   upd_2b
; while k > freq[++l]
updrecon:       bsr     reconst
                bra     upd_1
updx1:          
updx:           
                endm

; void EncodeChar(unsigned c);
; register unsigned i;
; register int j,k;
; D5 = c
; D3 = i
; d4 = j
; d0 = k
                macro   EncodeCh
                local   Enchar1
                local   Enchar2
                local   Enchar3
                local   Enchar4
                local   Enchar5
                local   Enchar6
                move.w  d5,-(SP)
                move.w  #2*R,d2
                move.w  D0,D5           ; c
                moveq   #0,D1           ;i=0
                move.l  d1,a1           ;j=0
                moveq   #0,d4           ;shift=0
                lea     prnt-rson(a3),A0
                add.w   #T,D0           ; T
                add.w   D0,D0
                move.w  0(A0,D0.w),D0   ; k=prnt[c+T]
; while
; if (k & 1) i +=0x8000
Enchar1:        addq.w  #1,d4
                btst    #1,D0
                beq.b   Enchar2
                lsr.w   d4,d1
                add.w   d4,a1
                moveq   #0,d4
                add.w   #$8000,d1
Enchar2:        move.w  0(A0,D0.w),D0   ; k=prnt[k]
                cmp.w   d2,D0         ; R
                bne.b   Enchar1

; putcode(j,i)
Enchar5:        add.w   d4,a1
                move.w  a1,D0
                lsr.w   d4,d1
                lea     freq-rson(a3),a2
                putcode
; update(c)
                move.w  D5,D0
                add.w   D0,D0
                lea     freq-rson(a3),a2
                lea     son-rson(a3),a4
                move.w  #2*T,D2
                add.w   d2,d0
                update         
                move.w  (SP)+,D5
                endm 


freq:           ds.w    T+1
prnt:           ds.w    T+N_CHAR
son:            ds.w    T

