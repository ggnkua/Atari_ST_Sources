* ss5.asm
*
* 30-01-88 (old version...very old)
* 10-07-88 

                org     $30000

COLORS          equ     $ff8240         * adress of color palette
picture:        equ     $43200
alphabet:       equ     $4b200
textdata:       equ     $53200

begin:          clr.l   -(sp)           * supervisor mode
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  d0,save_usp

display:        move.l  #palet2,-(sp)     * set palette
                move.w  #6,-(sp)
                trap    #14
                addq.l  #6,sp

                move.w  #-1,-(sp)
                move.l  #picture,-(sp)
                move.l  #picture,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                move.l  #$fc0000,$42a   * reset vector
                move.w  #$50,$40112     * HZ
                clr.w   $40114          * transpose value

                jsr     $40102          * music on

                bclr    #0,$484         * keyclick off
                move.w  #$02,$4ee       * alt-help off
                clr.w   pcount
                move.w  #2,padd

                move.w  #1483,d0
                move.l  #buffer,a0
empty           clr.l   (a0)+
                dbra    d0,empty

                move.l  #buffer,a6      * buffer for letter
                move.l  #textdata,a3    * pointer to text
                clr.b   d3              * scrollcounter
sc1:            tst.b   scflag
                bne.s   sc3
                move.l  #pulse,a0
                move.w  pcount,d0
                move.w  0(a0,d0.w),$ff824a
                bsr     do_scroll
                bsr     do_scroll
                bsr     do_scroll
                bsr     do_scroll
                move.w  #37,-(sp)       * VSYNC
                trap    #14
                addq.l  #2,sp
                move.w  padd,d0
                add.w   d0,pcount
                cmp.w   #42,pcount
                beq.s   sc1a
                tst.w   pcount
                bne.s   sc1b
sc1a:           neg.w   padd
sc1b:           dbra    d3,sc1
                move.b  (a3)+,d7
                cmp.b   #$ff,d7
                bne.s   sc2
                move.l  #textdata,a3
                move.b  (a3)+,d7
sc2:            move.l  #prop,a1
                and.w   #$00ff,d7
                move.b  0(a1,d7.w),d3
                and.w   #$00ff,d3
                bsr     letter
sc3:            move.w  #$ff,-(sp)
                move.w  #06,-(sp)
                trap    #1
                addq.l  #4,sp
                move.l  d0,d1
                swap    d1
                and.l   #$ff,d0
                and.l   #$ff,d1
        
                cmp.b   #32,d0
                bne.s   sc4
                eor.b   #1,scflag
                bra     sc1
sc4:            cmp.b   #$31,d0
                bcs.s   sc5
                cmp.b   #$36,d0
                bcs.s   otherpall
sc5:            cmp.b   #$2b,d0
                beq.s   sc6
                cmp.b   #$3d,d0
                bne.s   sc7
sc6:            cmp.w   #$20,$40114
                beq     sc1
                addq.w  #1,$40114
                bra     sc1
sc7:            cmp.b   #$2d,d0
                bne     sc8
                tst.w   $40114
                beq     sc1
                subq.w  #1,$40114
                bra     sc1

sc8:            cmp.b   #59,d1
                bcs     sc1
                cmp.b   #69,d1
                bcc     sc1
                sub.b   #58,d1
                move.w  d1,$4010e
                bra     sc1     

otherpall:      sub.b   #$31,d0
                lsl.w   #5,d0
                move.l  #palet1,a0
                add.w   d0,a0
                move.l  a0,-(sp)
                move.w  #6,-(sp)
                trap    #14
                addq.l  #6,sp
                bra     sc1

do_scroll:      move.l  #picture,a0
                add.l   #16000,a0
                move.l  a6,a1
                move.w  #37,d0
dos1:           lsl.w   14(a1)
                roxl.w  6(a1)
                roxl.w  158(a0)
                roxl.w  150(a0)
                roxl.w  142(a0)
                roxl.w  134(a0)
                roxl.w  126(a0)
                roxl.w  118(a0)
                roxl.w  110(a0)
                roxl.w  102(a0)
                roxl.w  94(a0)
                roxl.w  86(a0)
                roxl.w  78(a0)
                roxl.w  70(a0)
                roxl.w  62(a0)
                roxl.w  54(a0)
                roxl.w  46(a0)
                roxl.w  38(a0)
                roxl.w  30(a0)
                roxl.w  22(a0)
                roxl.w  14(a0)
                roxl.w  6(a0)
                move.l  #160,d1
                add.l   d1,a1
                add.l   d1,a0
                dbra    d0,dos1
                rts

letter:         cmp.b   #50,d7          * space?
                bne.s   let1
                move.w  #7,d3
                rts
let1:           move.l  d7,d1
                divu    #10,d1          * divide by 10
                move.w  d1,d2           * row # in d2
                swap    d1
                and.l   #$0000ffff,d1   * column # in d1
                mulu    #5920,d2        * row * 160 * 37
                lsl     #4,d1           * column * 16
                move.l  #alphabet,a1
                add.l   d2,a1
                add.l   d1,a1           * adress of letter in a1
                move.w  #37,d1          * 37 lines in a letter
                move.l  a6,a5
letter1:        move.w  6(a1),d0
                or.w    d0,6(a5)
                move.w  14(a1),d0
                or.w    d0,14(a5)
                add.l   #160,a5
                add.l   #160,a1
                dbra    d1,letter1      * next row
                rts

palet1:         dc.w    $000,$005,$004,$003,$002,$400,$555,$211
                dc.w    $400,$400,$400,$400,$400,$770,$050,$400
palet2:         dc.w    $000,$005,$004,$003,$002,$400,$555,$211
                dc.w    $400,$005,$004,$003,$002,$770,$050,$400
palet3:         dc.w    $000,$005,$004,$003,$002,$400,$555,$211
                dc.w    $400,$005,$004,$003,$002,$770,$050,$211
palet4:         dc.w    $000,$005,$004,$003,$002,$400,$555,$211
                dc.w    $400,$305,$304,$303,$302,$770,$050,$311
palet5:         dc.w    $000,$005,$004,$003,$002,$400,$555,$211
                dc.w    $400,$005,$004,$003,$002,$770,$050,$311

prop:           dc.b    8,7,7,8,6,6,7,7,3,4
                dc.b    7,6,8,7,7,6,7,6,6,6
                dc.b    7,8,8,7,7,6,2,4,5,5
                dc.b    8,2,3,3,2,2,2,2,4,5
                dc.b    5,3,5,5,5,5,5,5,5,5

pulse:          dc.w    $700,$600,$610,$611,$511,$521,$522,$422
                dc.w    $432,$433,$333,$343,$344,$244,$254,$255
                dc.w    $155,$165,$166,$066,$076,$077

pcount          ds.w    1
padd            ds.w    1

buffer          ds.l    1483    * buffer for letter
save_usp        ds.l    1
scflag          dc.b    0
                even

                END
