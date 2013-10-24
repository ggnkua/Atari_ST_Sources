                import flg_n                ; <> 0, wenn kein Output

                import output_pos
                import output_mask
                import bufsiz
                import send_block
                import buf
                import c_freq
                import p_freq

                import avail
                import next
                export childcount
                import prev
                import parent
                import level
                import position
                import pos
                export text
                import remainder
                import infile
                import _StdErrF
                import _StdOutF
                import unpackable
                import origsize
                import compsize

                import memmove
                import memcpy
                import fread_crc
                import fputc
                import putc
                import make_crctable
                import allocate_memory
                import start_huf
                import end_huf
                import allocate_memory
                import init_slide
                import start_huf

                export split
                export insert_node
                export delete_node
                export get_next_match
                export encode5
                export init_encode5
                export output5


init_slide:
                move.l  A2,-(SP)
                move.w  #$2000,D0
                lea     level,A0
                lea     position,A1
                bra.b   islide2
islide1:        movea.l (A0),A2
                move.b  #1,0(A2,D0.w)
                move.w  D0,D1
                ext.l   D1
                add.l   D1,D1
                movea.l (A1),A2
                clr.w   0(A2,D1.l)
                addq.w  #1,D0
islide2:
                cmp.w   #$20FF,D0
                ble.b   islide1
                move.w  #$2000,D0
                lea     parent,A1
                bra.b   islide4
islide3:
                move.w  D0,D1
                ext.l   D1
                add.l   D1,D1
                movea.l (A1),A0
                clr.w   0(A0,D1.l)
                addq.w  #1,D0
islide4:
                cmp.w   #$4000,D0
                blt.b   islide3
                move.w  #1,avail
                moveq   #1,D0
                lea     next,A1
                bra.b   islide6
islide5:
                moveq   #1,D1
                add.w   D0,D1
                move.w  D0,D2
                ext.l   D2
                add.l   D2,D2
                movea.l (A1),A0
                move.w  D1,0(A0,D2.l)
                addq.w  #1,D0
islide6:
                cmp.w   #$1FFF,D0
                blt.b   islide5
                movea.l (A1),A0
                clr.w   $3FFE(A0)
                move.w  #$4000,D0
                bra.b   islide8
islide7:
                move.w  D0,D1
                ext.l   D1
                add.l   D1,D1
                movea.l (A1),A0
                clr.w   0(A0,D1.l)
                addq.w  #1,D0
islide8:
                cmp.w   #$70EF,D0
                ble.b   islide7
                movea.l (SP)+,A2
                rts

; --------------------------------------; beg child
slide:          moveq   #0,D2           ;
                move.b  D1,D2           ;
                lsl.w   #4,D2           ;
                add.w   D0,D2           ;
                add.w   #$4000,D2       ; h=HASH(q,c)
                ext.l   d2              ; h
                add.l   D2,D2           ; 2*h
                move.w  D0,(A2)         ; parent[NIL]=q
child1:         move.w  0(A4,D2.l),D1   ; r=next[r]
                move.w  D1,D2           ; r
                ext.l   D2              ; r
                add.l   D2,D2           ; 2*r
                cmp.w   0(A2,D2.l),D0   ; while (parent[r] != NIL)
                bne.b   child1          ;
                move.w  D1,D0           ; return r
                rts                     ; end child
; --------------------------------------;
makechild:      movem.l D3/d4,-(SP)
                moveq   #0,D4
                move.b  D1,D4
                lsl.w   #4,D4           ; c<<DICBIT-9
                add.w   D0,D4           ; p+c
                add.w   #$4000,D4       ; ((p)+((c)<<(DICBIT-9))+(DICSIZ*2)
                move.w  D4,D1           ; h
                ext.l   D4              ; h
                add.l   D4,D4           ; 2*h
                move.w  0(A4,D4.l),D3   ; t=next[h]
                move.w  D2,0(A4,D4.l)   ; next[h]=r
                move.w  D2,D4           ; r
                ext.l   D4              ; r
                add.l   D4,D4           ; 2*r
                move.w  D3,0(A4,D4.l)   ; next[r]=t
                ext.l   D3              ; t
                add.l   D3,D3           ; 2*t
                move.w  D2,0(A3,D3.l)   ; prev[t]=r
                move.w  D1,0(A3,D4.l)   ; prev[r]=h
                move.w  D0,0(A2,D4.l)   ; parent[r]=q
                movea.l childcount-pos(a6),A0   ;
                addq.b  #1,0(A0,D0.w)   ; childcount[q]++
                movem.l (SP)+,d3/d4
                rts


;¯.MODULE LOCAL

; --------------------------------------;
insert_node:                            ;
                cmp.w   #4,d7           ; if (matchl >= 4)
                blt     inode7          ;
                subq.w  #1,d7           ; matchl--
                moveq   #1,D4           ;
                add.w   d6,D4           ;
                or.w    #$2000,D4       ; r=(matchpos+1)|DICSIZ
; --------------------------------------;

; --------------------------------------;
                bra.b   inode2          ; while ((q=parent[r]==NIL) {
inode1:         move.w  0(A4,D0.l),D4   ;   r=next[r]
inode2:         move.w  D4,D0           ;   r
                ext.l   D0              ;   r
                add.l   D0,D0           ;   r * 2
                move.w  0(A2,D0.l),D5   ;   q=parent[r]
                beq.b   inode1          ; }
; --------------------------------------;

; --------------------------------------;
                movea.l level,A0        ;
                bra.b   inode4          ; while (level[q] >= matchl) {
inode3:         move.w  D5,D4           ;   r = q
;               ext.l   D5              ;   q
                add.l   D5,D5           ;   q * 2
                move.w  0(A2,D5.w),D5   ;   q=parent[q]
inode4:         moveq   #0,D0           ;
                move.b  0(A0,D5.w),D0   ;   level[q]
                cmp.w   D0,d7           ; }
                ble.b   inode3          ;
; --------------------------------------;

; --------------------------------------;
                move.w  D5,D0           ; t = q
                movea.l position-pos(a6),A0     ; while (position[t] < 0) {
                bra.b   inode6          ;
inode5:         move.w  (A6),0(A0,D0.l) ;   position[t] = pos
                move.w  0(A2,D0.l),D0   ;   t=parent[t]
inode6:     ;   ext.l   D0              ;   t
                add.l   D0,D0           ;   t * 2
                move.w  0(A0,D0.l),D1   ;   position[t]
                blt.b   inode5          ; }
;    end while  ----------------------- ;
                cmp.w   #$4000,D0       ; if (t < DICSIZ) {
                bge     inode9          ;
                move.w  (A6),D2         ;   pos
                or.w    #$8000,D2       ;   pos | PERC_FLAG
                move.w  D2,0(A0,D0.l)   ;   position[t] = pos | PERC_FLAG
                bra     inode9          ;
; --------------------------------------:
inode7:         move.w  (A6),D0         ; pos
                movea.l text-pos(a6),A0         ;
                moveq   #0,d5           ;
                move.b  0(A0,D0.w),D5   ; q = text[pos]
                add.w   #$2000,D5       ; + DICSIZE
                move.b  1(A0,D0.w),d7   ; c = text[pos+1]
                move.b  d7,D1           ; c
; --------------------------------------; beg child
                moveq   #0,D2           ;
                move.b  D1,D2           ;
                lsl.w   #4,D2           ;
                add.w   D5,D2           ;
                add.w   #$4000,D2       ; h=HASH(q,c)
                ext.l   d2              ; h
                add.l   D2,D2           ; 2*h
                move.w  D5,(A2)         ; parent[NIL]=q
nchild1:        move.w  0(A4,D2.l),D1   ; r=next[r]
                move.w  D1,D2           ; r
                ext.l   D2              ; r
                add.l   D2,D2           ; 2*r
                cmp.w   0(A2,D2.l),D5   ; while (parent[r] != NIL)
                bne.b   nchild1         ;
                move.w  D1,D0           ; return r
; --------------------------------------;
                move.w  D0,D4           ; r = child(q,c)
                bne.b   inode8          ; if ((r=child(q,c)) == NIL)
; --------------------------------------;

; ++++++++++++++++++++++++++++++++++++++;
                move.w  (A6),D2         ; pos
                moveq   #0,d4
                move.b  d7,D4           ; c
; --------------------------------------; makechild
                lsl.w   #4,D4           ; c<<DICBIT-9
                add.w   d5,D4           ; p+c
                add.w   #$4000,D4       ; ((p)+((c)<<(DICBIT-9))+(DICSIZ*2)
                move.w  D4,D1           ; h
                ext.l   D4              ; h
                add.l   D4,D4           ; 2*h
                move.w  0(A4,D4.l),D3   ; t=next[h]
                move.w  D2,0(A4,D4.l)   ; next[h]=r
                move.w  D2,D4           ; r
                ext.l   D4              ; r
                add.l   D4,D4           ; 2*r
                move.w  D3,0(A4,D4.l)   ; next[r]=t
                ext.l   D3              ; t
                add.l   D3,D3           ; 2*t
                move.w  D2,0(A3,D3.l)   ; prev[t]=r
                move.w  D1,0(A3,D4.l)   ; prev[r]=h
                move.w  d5,0(A2,D4.l)   ; parent[r]=q
                movea.l childcount-pos(a6),A0   ;
                addq.b  #1,0(A0,d5.w)   ; childcount[q]++
; --------------------------------------; makechild
                move.w  #1,d7           ; matchl=1
                rts                     ; return
; ++++++++++++++++++++++++++++++++++++++;

; --------------------------------------;
inode8:         moveq   #2,d7           ; matchl=2
inode9:         cmp.w   #$2000,D4       ; if (r>DICSIZ)
                blt.b   inode10         ;
                move.w  #$0100,d2       ; j = MAXMATCH
                move.w  D4,d6           ; matchpos=r
                bra.b   inode11         ;
inode10:        movea.l level,A0        ;
                clr.w   d2              ;
                move.b  0(A0,D4.w),d2   ; r=level[r]
                move.w  D4,D0           ; r
;               ext.l   D0              ; r
                add.l   D0,D0           ; r*2
                movea.l position-pos(a6),A1     ;
                move.w  0(A1,D0.l),D1   ; position[r]
                and.w   #$7FFF,D1       ; position[r] & ~PERC_FLAG
                move.w  D1,d6           ; matchpos=position[r] & ~ PERC_FLAG
inode11:        move.w  d6,D0           ; pos
                cmp.w   (A6),D0         ; matchpos
                blt.b   inode12         ; if (matchpos>=pos)
                subi.w  #$2000,d6       ; matchpos-=DICSIZE
; --------------------------------------;
inode12:        move.w  (A6),D0         ; pos
                add.w   d7,D0           ; pos+matchl
                movea.l text-pos(a6),A0 ; text
                lea     0(a0,d0.w),a5
                move.w  d6,D1           ; matchpos
                add.w   d7,D1           ; matchpos+matchl
                lea     0(a0,d1.l),a0   ; t2=text[matchpos+matchl]
itest:          move.w  d2,d0
                sub.w   d7,d0
                beq     inode14
                subq.w  #1,d0
inode13:        cmpm.b  (A5)+,(A0)+     ;
inode15:        dbne    d0,inode13      ; matchl<j
                bne     in_split
                neg.w   d0
                add.w   d2,d0
                subq.w  #1,d0
                move.w  d0,d7
; --------------------------------------;
inode14:        cmp.w   #$0100,d7       ; if matchl>MAXMATCH
                bge     inode17         ; break
; --------------------------------------;

; ++++++++++++++++++++++++++++++++++++++;
                move.w  D4,D0           ; r
                ext.l   D0              ;
                add.l   D0,D0           ; 2*r
                movea.l position-pos(a6),A0     ;
                move.w  (A6),0(A0,D0.l) ; position[r]=pos
                move.w  D4,D5           ; q=r
                moveq   #0,d2
                move.b  (A5),D2         ; *t1
; --------------------------------------; beg child
                lsl.w   #4,D2           ;
                add.w   D5,D2           ;
                add.w   #$4000,D2       ; h=HASH(q,c)
                ext.l   d2              ; h
                add.l   D2,D2           ; 2*h
                move.w  D5,(A2)         ; parent[NIL]=q
nchild2:        move.w  0(A4,D2.l),D1   ; r=next[r]
                move.w  D1,D2           ; r
                ext.l   D2              ; r
                add.l   D2,D2           ; 2*r
                cmp.w   0(A2,D2.l),D5   ; while (parent[r] != NIL)
                bne.b   nchild2         ;
                move.w  D1,D0           ; return r
; --------------------------------------; end child
                move.w  D0,D4           ; r=child(q,*t1)
                bne.b   inode16         ; if ((r=child(q,*t1)) != NIL) {
                move.w  (A6),D2         ;   pos
                moveq   #0,d4
                move.b  (A5),D4         ;   *t1
; --------------------------------------; makechild
                lsl.w   #4,D4           ; c<<DICBIT-9
                add.w   d5,D4           ; p+c
                add.w   #$4000,D4       ; ((p)+((c)<<(DICBIT-9))+(DICSIZ*2)
                move.w  D4,D1           ; h
                ext.l   D4              ; h
                add.l   D4,D4           ; 2*h
                move.w  0(A4,D4.l),D3   ; t=next[h]
                move.w  D2,0(A4,D4.l)   ; next[h]=r
                move.w  D2,D4           ; r
                ext.l   D4              ; r
                add.l   D4,D4           ; 2*r
                move.w  D3,0(A4,D4.l)   ; next[r]=t
                ext.l   D3              ; t
                add.l   D3,D3           ; 2*t
                move.w  D2,0(A3,D3.l)   ; prev[t]=r
                move.w  D1,0(A3,D4.l)   ; prev[r]=h
                move.w  d5,0(A2,D4.l)   ; parent[r]=q
                movea.l childcount-pos(a6),A0   ;
                addq.b  #1,0(A0,d5.w)   ; childcount[q]++
; --------------------------------------; makechild
                rts                     ;   return
; ++++++++++++++++++++++++++++++++++++++;

; --------------------------------------;
inode16:        addq.w  #1,d7           ; matchl++
                bra     inode9          ; } /* for */
; --------------------------------------;
inode17:        move.w  (a6),d3
                move.w  D4,D0           ; r
                ext.l   D0              ; r
                add.l   D0,D0           ; 2*r
                move.w  0(A3,D0.l),D1   ; t = prev[r]
                move.w  d3,D2           ; pos
                ext.l   D2              ; pos
                add.l   D2,D2           ; 2*pos
                move.w  D1,0(a3,D2.l)   ; prev[pos]=t
                ext.l   D1              ; t
                add.l   D1,D1           ; 2*t
                move.w  d3,0(A4,D1.l)   ; next[r] = pos
                move.w  0(A4,D0.l),D1   ; t=next[r]
                move.w  D1,0(A4,D2.l)   ; next[pos]=t
                ext.l   D1              ; t
                add.l   D1,D1           ; 2*t
                move.w  d3,0(a3,D1.l)   ; prev[t] = pos
                move.w  D5,0(A2,D2.l)   ; parent[pos]=q
                clr.w   0(A2,D0.l)      ; parent[r] = NIL
                move.w  d3,0(A4,D0.l)   ; next[r]=pos
inode18:        rts                     ;
; ++++++++++++++++++++++++++++++++++++++;

; --------------------------------------;
in_split:
                neg.w   d0
                add.w   d2,d0
                subq.w  #1,d0
                move.w  d0,d7
                move.w  D4,D0           ;   split(r)
; --------------------------------------; split
split:          move.w  avail-pos(a6),D3; new=avail
                move.w  D3,D2           ; new
                ext.l   D2              ; new
                add.l   D2,D2           ; new * 2
                move.w  0(A4,D2.l),avail-pos(a6) ; avail=next[new]
                movea.l childcount-pos(a6),A1
                clr.b   0(A1,D3.w)      ; childcount[new] = 0
                move.w  d0,d1
                ext.l   D1              ; old
                add.l   D1,D1           ; old * 2
                move.w  0(A3,D1.l),D0   ; t = prev[old]
                move.w  D0,0(A3,D2.l)   ; prev[new] = t
                ext.l   D0              ; t
                add.l   D0,D0           ; t * 2
                move.w  D3,0(A4,D0.l)   ; next[t] = new
                move.w  0(A4,D1.l),D0   ; t=next[old]
                move.w  D0,0(A4,D2.l)   ; next[new] = t
                ext.l   D0              ; t
                add.l   D0,D0           ; t * 2
                move.w  D3,0(A3,D0.l)   ; prev[t] = new
                move.w  0(A2,D1.l),0(A2,D2.l) ; parent[new] = parent[old]
                movea.l level,A0        ;
                move.b  d7,0(A0,D3.w)   ; level[new]=matchlen
                movea.l position-pos(a6),A0
                move.w  (a6),0(A0,D2.l) ; positon[new]=pos
; makechil(new,text[matchpos+matchlen],old)
                move.w  d6,D1           ;
                add.w   d7,D1           ;
                movea.l text-pos(a6),A0 ;
                move.w  d4,d2           ;
                moveq   #0,d4           ;
                move.b  0(A0,D1.w),D4   ;
; --------------------------------------;
                lsl.w   #4,D4           ; c<<DICBIT-9
                add.w   D3,D4           ; p+c
                add.w   #$4000,D4       ; ((p)+((c)<<(DICBIT-9))+(DICSIZ*2)
                move.w  D4,D1           ; h
                ext.l   D4              ; h
                add.l   D4,D4           ; 2*h
                move.w  0(A4,D4.l),d5   ; t=next[h]
                move.w  D2,0(A4,D4.l)   ; next[h]=r
                move.w  D2,D4           ; r
                ext.l   D4              ; r
                add.l   D4,D4           ; 2*r
                move.w  d5,0(A4,D4.l)   ; next[r]=t
                ext.l   d5              ; t
                add.l   d5,d5           ; 2*t
                move.w  D2,0(A3,d5.l)   ; prev[t]=r
                move.w  D1,0(A3,D4.l)   ; prev[r]=h
                move.w  D3,0(A2,D4.l)   ; parent[r]=q
                movea.l childcount-pos(a6),A1   ;
                addq.b  #1,0(A1,D3.w)   ; childcount[q]++
; --------------------------------------;
; makechild(new,text[pos+matchlen],pos)
                move.w  pos,D2
                move.w  d2,D0
                add.w   d7,D0
                moveq   #0,d4
                move.b  0(A0,D0.w),D4   ; text[pos+matchlen]
; --------------------------------------; makechild
                lsl.w   #4,D4           ; c<<DICBIT-9
                add.w   D3,D4           ; p+c
                add.w   #$4000,D4       ; ((p)+((c)<<(DICBIT-9))+(DICSIZ*2)
                move.w  D4,D1           ; h
                ext.l   D4              ; h
                add.l   D4,D4           ; 2*h
                move.w  0(A4,D4.l),D0   ; t=next[h]
                move.w  D2,0(A4,D4.l)   ; next[h]=r
                move.w  D2,D4           ; r
                ext.l   D4              ; r
                add.l   D4,D4           ; 2*r
                move.w  d0,0(A4,D4.l)   ; next[r]=t
                ext.l   d0              ; t
                add.l   d0,d0           ; 2*t
                move.w  D2,0(A3,d0.l)   ; prev[t]=r
                move.w  D1,0(A3,D4.l)   ; prev[r]=h
                move.w  D3,0(A2,D4.l)   ; parent[r]=q
                movea.l childcount-pos(a6),A0   ;
                addq.b  #1,0(A0,D3.w)   ; childcount[q]++
; --------------------------------------;
                rts


; **************************************************************************


get_next_match: subq.w  #1,remainder-pos(a6)
                addq.w  #1,(a6)
                cmpi.w  #$4000,(a6)
                bne.b   gnext1
                move.l  #$2100,D0
                movea.l text-pos(a6),A0
                lea     $2000(A0),A1
                bsr     memcpy
                movea.l infile,A1
                move.w  #$2000,D0
                movea.l text-pos(a6),A0
                lea     $2100(A0),A0
                bsr     fread_crc
                add.w   D0,remainder
                move.w  #$2000,pos
                move.b  flg_n,d0
                bne.b   gnext1
                lea     _StdOutF,A0
                moveq   #$2A,D0
                bsr     putc
gnext1:         movem.l D3-d5/A2-A4,-(sp)
                movea.l parent-pos(a6),a2
                movea.l next-pos(a6),a4
                movea.l prev-pos(a6),a3

delete_node:    move.w  (a6),d2         ; d2=pos
                move.w  d2,D1           ; pos
                ext.l   D1              ; pos
                add.l   D1,D1           ; 2*pos
                move.w  0(A2,D1.l),D0   ; if (parent[pos] == NIL)
                beq     dnode9          ;    return
                move.w  0(A3,D1.l),D3   ; r = prev[pos]
                move.w  0(A4,D1.l),D4   ; s = next[pos]
                move.w  D3,D0           ; r
                ext.l   D0              ; r
                add.l   D0,D0           ; 2 * r
                move.w  D4,0(A4,D0.l)   ; next[r]=s
                move.w  D4,D0           ; s
                ext.l   D0              ; s
                add.l   D0,D0           ; s * 2
                move.w  D3,0(A3,D0.l)   ; prev[s] = r
                move.w  0(A2,D1.l),D3   ; r = parent[pos]
                clr.w   0(A2,D1.l)      ; parent[pos] = NIL
                cmp.w   #$2000,D3       ; if (r >= DICSIZ)
                bge     dnode9          ;
                movea.l childcount-pos(a6),A1   ;   ||
                subq.b  #1,0(A1,D3.w)   ;   --childcount[r]
                cmpi.b  #1,0(A1,D3.w)   ;   > 1)
                bhi     dnode9          ;     return
                movea.l position-pos(a6),A1     ; position
                move.w  D3,D1           ; r
                ext.l   D1              ; r
                add.l   D1,D1           ; r * 2
                move.w  0(A1,D1.l),D5   ; t=position[r]
                and.w   #$7FFF,D5       ;      & ~PERC_FLAG
                cmp.w   d2,D5           ; if (t>=pos)
                blt.b   dnode1          ;
                sub.w   #$2000,D5       ;   t-=DICSIZ
;---------------------------------------;
dnode1:         move.w  D5,D4           ; s = t
                move.w  d5,a0
                move.w  0(A2,D1.l),D0   ; q = parent[r]
                ext.l   d0              ; q
                add.l   d0,d0           ; q*2
                bra.b   dnode5          ; while ((u=position[q] & PERC_FLAG) {
dnode2:         and.w   #$7FFF,d5       ;   u &= ~PERC_FLAG
                cmp.w   d2,d5           ;   if (u>=pos)
                blt.b   dnode3          ;
                sub.w   #$2000,d5       ;       u-=DICSIZ
dnode3:         cmp.w   d5,D4           ;   if (u>=s)
                bge.b   dnode4          ;
                move.w  d5,D4           ;       s=u
dnode4:         move.w  D4,D1           ;   s
                or.w    #$2000,D1       ;   |DICSIZ
                move.w  D1,0(A1,D0.l)   ;   position[q] = s | DICSIZ
                move.w  0(A2,D0.l),D0   ;   q=parent[q]
;               ext.l   d0              ;   q
                add.l   d0,d0           ;   q*2
dnode5:         move.w  0(A1,D0.l),d5   ;   u=position[q]
                move.w  d5,D1           ;   u
                and.w   #$8000,D1       ;   parent[r] & PERC_FLAG
                bne.b   dnode2          ; }
;   end_while   ------------------------;
                cmp.w   #$4000,D0       ; if (q<DICISZ}
                bge.b   dnode8          ; {
                cmp.w   d2,d5           ;   if (u>=pos)
                blt.b   dnode6          ;
                sub.w   #$2000,d5       ;      u-=DICSIZ
dnode6:         cmp.w   d5,D4           ;   if (u>s)
                bge.b   dnode7          ;
                move.w  d5,D4           ;     s=u
dnode7:         move.w  D4,D1           ;   s
                or.w    #$A000,D1       ;   s|DICSIZ|PERC_FLAG
                move.w  D1,0(A1,D0.l)   ;   position[q]=s|DICSIZ|PERC_FLAG
;---------------------------------------;
dnode8:         movea.l level,A1        ; level
                clr.w   D0              ;
                move.b  0(A1,D3.w),D0   ; level[r]
                add.w   a0,D0           ; level[r]+t
                movea.l text-pos(a6),A1 ; text
                moveq   #0,d2
                move.b  0(A1,D0.w),D2   ; text[level[r]+t]
; --------------------------------------; beg child
                lsl.w   #4,D2           ;
                add.w   D3,D2           ;
                add.w   #$4000,D2       ; h=HASH(q,c)
                ext.l   d2              ; h
                add.l   D2,D2           ; 2*h
                move.w  D3,(A2)         ; parent[NIL]=q
dchild1:        move.w  0(A4,D2.l),D1   ; r=next[r]
                move.w  D1,D2           ; r
                ext.l   D2              ; r
                add.l   D2,D2           ; 2*r
                cmp.w   0(A2,D2.l),D3   ; while (parent[r] != NIL)
                bne.b   dchild1         ;
                move.w  D1,D0           ; return r
; --------------------------------------; end child
                move.w  D0,D4           ; s
                ext.l   D0              ; s
                add.l   D0,D0           ; s*2
                move.w  0(A3,D0.l),D5   ; t=prev[s]
                move.w  0(A4,D0.l),D2   ; u=next[s]
                move.w  D5,D1           ; t
                ext.l   D1              ; 2*t
                add.l   D1,D1           ; t * 2
                move.w  D2,0(A4,D1.l)   ; next[t] = u
                ext.l   D2              ; u
                add.l   D2,D2           ; u * 2
                move.w  D5,0(A3,D2.l)   ; prev[u] = t
                move.w  D3,D2           ; r
                ext.l   D2              ; r
                add.l   D2,D2           ; r * 2
                move.w  0(A3,D2.l),D5   ; t = prev[r]
                move.w  D5,D1           ; t
                ext.l   D1              ; t
                add.l   D1,D1           ; t * 2
                move.w  D4,0(A4,D1.l)   ; next[t] = s
                move.w  D5,0(A3,D0.l)   ; prev[s] = t
                move.w  0(A4,D2.l),D5   ; t=next[r]
                move.w  D5,D1           ; t
                ext.l   D1              ; t
                add.l   D1,D1           ; t * 2
                move.w  D4,0(A3,D1.l)   ; prev[t]=s
                move.w  D5,0(A4,D0.l)   ; next[s]=t
                move.w  0(A2,D2.l),0(A2,D0.l) ; parent[s]=parent[r]
                clr.w   0(A2,D2.l)      ; parent[r]=NIL
                move.w  avail-pos(a6),0(A4,D2.l); next[r]=avail
                move.w  D3,avail-pos(a6); avail=r
dnode9:
; **************************************************************************
                bsr     insert_node
                movem.l (sp)+,d3-d5/a2-a4
                rts

encode5:        movem.l D3-D5/A2-A6,-(SP)
                move.l  D0,D3
                clr.w   unpackable      ; unpackable=0
                bsr     make_crctable   ; make_crctable()
                move.l  D3,origsize     ; origsize=orgsize
                clr.l   compsize        ; compsize=0
                lea     text,A2
                lea     remainder,A3
                movea.l infile,A1       ; infile
                move.w  #$2100,D0       ; DICSIZ+MAXMATCH
                movea.l (A2),A0         ; text
                lea     $2000(A0),A0    ; text[DICSIZE]
                jsr     fread_crc(PC)   ; fread_crc
                move.w  D0,(A3)         ; remainder=fread_crcx
                move.b  flg_n,d0
                bne.b   enc51
                lea     _StdOutF,A0     ; stderr
                moveq   #$2A,D0         ; '*'
                jsr     putc(PC)        ; putc('*',stderr)
enc51:          moveq   #0,d7           ; matchlen=0
                lea     pos,A6          ; pos
                move.w  #$2000,(A6)     ; pos=DICSIZ
                movem.l D3-d5/A2-A4,-(SP)
                movea.l parent-pos(a6),a2
                movea.l next-pos(a6),a4
                movea.l prev-pos(a6),a3
                bsr     insert_node      ; insert_node
                movem.l (sp)+,D3-d5/A2-A4
; --------------------------------------;
                bra.b   encod7          ; while
encod1:         move.w  d7,D4           ; lastmatchlen=matchlen
                move.w  d6,D5           ; lastmatchpos=matchpos
                bsr     get_next_match  ; get_next_match
                cmp.w   (A3),D7         ; if (matchlen>remainder)
                ble.b   encod2
                move.w  (A3),d7         ;   matchlen=remainder
encod2:         cmp.w   d7,D4           ; if (matchlen>lastmatchlen
                blt.b   encod3          ; ||
                cmp.w   #3,D4           ; lastmatchlen<THRESHOLD)
                bge.b   encod4
encod3:         clr.w   D1              ; 0
                move.w  (A6),D0         ; pos
                movea.l (A2),A0         ; text
                clr.w   D2              ;
                move.b  -1(A0,D0.w),D2  ; text[pos-1]
                move.w  D2,D0           ;
                bsr     output5         ; output5(..)
                bra.b   encod8
; --------------------------------------;
encod4:         move.w  (A6),D1         ; pos
                sub.w   D5,D1           ; pos-lastmatchpos
                subq.w  #2,D1           ; pos-lastmatchpos-2
                and.w   #$1FFF,D1       ; (pos-lastmatchpos-2)&(UCHAR_MAX+1-THRESHOLD)
                move.w  D4,D0           ; lastmatchlen
                add.w   #$FD,D0         ; lastmatchlen+UCHAR_MAX+1-THRESHOLD
                bsr     output5         ; output5
; --------------------------------------;
                bra.b   encod6          ; while (--lastmatchlen>0)
encod5:         bsr     get_next_match  ;  get_next_match
encod6:         subq.w  #1,D4           ;
                bgt.b   encod5          ;
; --------------------------------------;
encod7:         cmp.w   (A3),D7         ; if (matchlen>remainder)
                ble.b   encod8          ;
                move.w  (A3),d7         ;   matchlen=remainder
; --------------------------------------;
encod8:         move.w  (A3),D0         ; remainder
                ble.b   encod9          ; <0
                move.w  unpackable,D1   ; !unpackable
                beq.b   encod1          ;
; --------------------------------------;
encod9:         bsr     end_huf         ; end_huf
                move.w  unpackable,D0   ; if (unpackable)
                beq.b   encod10
                moveq   #1,D1           ; 1
                add.l   D3,D1           ; orgsize+1
                move.l  D1,compsize     ; compsize=orgsize+1
encod10:        move.l  compsize,D0     ; return compsize
                movem.l (SP)+,D3-D5/A2-A6
                rts


init_encode5:
                jsr     allocate_memory(PC)
                jsr     init_slide(PC)
                jsr     start_huf(PC)
                rts


output5:        movem.l D3-D4/A2-A3,-(SP)
                move.w  D0,D3
                move.w  D1,D4
                lea     output_pos,A2
                lea     buf,A3
                lsr.w   output_mask         ; output_mask >> 1
                move.w  output_mask,D2      ; if {output_mask = 0) {
                bne.b   out5_2
                move.w  #$80,output_mask    ; output_mask=1U <<(CHAR_BIT-1)
                moveq   #-$18,D2            ; -3*CHAR_BIT
                add.w   bufsiz,D2           ; -3*CHAR_BIT+bufsize
                movea.w (A2),A0             ; output_pos
                cmpa.w  D2,A0               ; if (output_pos>=buf...) {
                bcs.b   out5_1
                bsr     send_block          ; send_block
                move.w  unpackable,D0       ; if (unpackable)
                bne     out5_5              ;   return
                clr.w   (A2)                ; output_pos=0
out5_1:         move.w  (A2),cpos           ; cpos=output_pos
                addq.w  #1,(A2)             ; output_pos++
                moveq   #0,D0               ; 0
                move.w  cpos,D0             ; cpos
                movea.l (A3),A0             ; buf
                clr.b   0(A0,D0.l)          ; buf[cpos]=0
out5_2:         moveq   #0,D0
                move.w  (A2),D0             ; output_pos
                movea.l (A3),A0             ; buf
                move.b  D3,0(A0,D0.l)       ; buf[output_pos]=c
                addq.w  #1,(A2)             ; output_pos++
                move.w  D3,D0               ; c
                add.w   D0,D0               ; c*2
                lea     c_freq,A0           ; c_freq
                addq.w  #1,0(A0,D0.w)       ; c_freq[c]++
                cmp.w   #$0100,D3           ; if (c>=(1U<<CHAR_BIT)
                bcs.b   out5_5              ;
                move.b  output_mask+1,D1    ; output_mask
                moveq   #0,D2               ;
                move.w  cpos,D2             ; cpos
                movea.l (A3),A1             ; buf
                or.b    D1,0(A1,D2.l)       ; buf[cpos] != output_mask
                move.w  D4,D1               ; p
                lsr.w   #8,D1               ; p>>CHAR_BIT
                moveq   #0,D2               ;
                move.w  (A2),D2             ; output_pos
                movea.l (A3),A1             ; buf
                move.b  D1,0(A1,D2.l)       ; buf[output_pos]=p>>CHAR_BIT
                addq.w  #1,(A2)             ; output_pos++
                moveq   #0,D2               ;
                move.w  (A2),D2             ; output_pos
                movea.l (A3),A1             ; buf
                move.b  D4,0(A1,D2.l)       ; buf[output_pos]=p
                addq.w  #1,(A2)             ; output_pos++
                clr.w   D3                  ; c=0
; ------------------------------------------;
                bra.b   out5_4              ; while (p) {
out5_3:         lsr.w   #1,D4               ;    p>>=1
                addq.w  #1,D3               ;    c++
out5_4:         tst.w   D4                  ; }
                bne.b   out5_3              ;
; ------------------------------------------;
                move.w  D3,D0               ; c
                add.w   D0,D0               ; 2*2
                lea     p_freq,A0           ; p_freq
                addq.w  #1,0(A0,D0.w)       ; p_freq[c]++
out5_5:         movem.l (SP)+,D3-D4/A2-A3   ; return
                rts

position:       dc.l    0
next:           dc.l    0
prev:           dc.l    0
parent:         dc.l    0
pos:            dc.l    0
avail:          dc.l    0
remainder:      dc.l    0
cpos:           dc.w    0
text:           dc.l    0
childcount:     dc.l    0
unpackable:     dc.l    0

                END
