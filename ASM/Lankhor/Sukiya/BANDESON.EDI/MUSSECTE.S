aa:
	move    #52,nummor
	jsr	main
	illegal
bb:
	jsr	cc
	illegal

        ORG     $2a0000		;1024*2048
        LOAD    $2a0000		;1024*2048
debut:
nummor: dc.w    0
modivo: dc.w    0
durmor: dc.w    1
        bra.l   main
        bra.l   suri
        bra.l   prio
        bra.l   couto
cc:
        move.w  #-1,finmor
        move.l  #ttvbl,-(sp)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp
        rts
ttvbl:  move.l  #routima,d0
yyy:    cmp.l   $70,d0
        beq.s   yyy
        rts

nomech: dc.b    "e:\bandeson.edi\echant.img",0
nomson: dc.b    "e:\bandeson.edi\tabson.img",0
nommor: dc.b    "e:\bandeson.edi\m"
numer:  dc.b    "000.",0
        even
;  relecture sampler 1 a 4 voix sur st
ttcod:  add.w   d4,d1
        sub.w   d4,d1
modvol: add.w   #9,d0
        bge.s   sssss
        clr.w   d0
sssss:  cmp.w   #12,d0
        ble.s   zzzzz
        move.w  #12,d0
zzzzz:  mulu    #12,d1         
        move.l  ptech(pc),a1
        add.w   d1,a1
        lea.l   tecrec,a5
        lsl.w   #2,d0
        add.w   d0,a5
        moveq   #0,d5
        moveq   #0,d6
        move.b  1(a5),d5
        move.w  ttcod(pc,d5.w),codad
        move.b  (a5),d5
        move.b  2(a5),d6
        move.w  #2,d2
bchvec: move.l  4(a1),d3
        and.l   #$ffffff,d3
        move.l  (a1)+,d4
        and.l   #$ffffff,d4
        sub.l   d4,d3
        subq.l  #3,d3
        blt.s   sbchve
        move.l  d4,a0
        add.l   echan(pc),a0
bmovoe: clr.w   d4
        move.b  (a0)+,d4
        bchg    #7,d4
        ext.w   d4
        move.w  d4,d1
        asr.w   d5,d1
        asr.w   d6,d4
codad:  add.w   d4,d1
        add.w   #128,d1
        bgt.s   pbok
        move.w  #1,d1
        bra.s   dbok
pbok:   cmp.w   #255,d1
        ble.s   dbok
        move.w  #255,d1
dbok:   move.b  d1,-1(a0)
        dbf     d3,bmovoe
sbchve: dbf     d2,bchvec
        rts
tecrec: dc.b    3,2,4,0,4,0,5,0,2,2,3,0,3,0,4,0
        dc.b    1,2,2,0,2,0,4,0,1,2,4,0,1,0,4,0
        dc.b    0,2,2,0,1,0,1,0,0,0,2,0,0,0,1,0,0,0,0,0
        
; appel d une surimp
suri:   tst.b   texe
        beq.s   coupt2
        tst.b   texe+32
        bne.s   pcoupt2
coupt2:  bsr     couto
pcoupt2:
        move.l  #morc1,a6
        bsr     prseq
        lea.l   texe+32(pc),a3
        move.l  #morc1,a6
        lea.l   patsur(pc),a4
        bsr     meppat
        bra     rrcc

; appel d une prior
prio:   tst.b   texe
        beq.s   coupt
        tst.b   texe+32
        bne.s   pcoupt
coupt:  bsr     couto
pcoupt:
        move.l  #morc3,a6
        bsr     prseq
        lea.l   texe(pc),a3
        move.l  #morc3,a6
        lea.l   patpri(pc),a4
        bsr     meppat
        bra     rrcc
; appel coup feu
feu:    
        move.b  #0,valeu+1
        move.b  #1,nbpatb
        move.l  #patfeu,a0
        move.l  #adpatt,a5
        bsr     rececv
        lea.l   texfeu,a0
        move.w  #1,14(a0)
        move.l  #patvi,6(a0)
        move.l  #patvi,10(a0)
        move.l  #patfeu,2(a0)
        clr.w   (a0)
        addq.b  #1,nbamb
        bra     rrcc
; appel caisse enreg
fri:    
        move.b  #0,valeu+1
        move.b  #1,nbpatb
        move.l  #patfri,a0
        move.l  #adpatt,a5
        bsr     rececv
        lea.l   texfri,a0
        move.w  #1,14(a0)
        move.l  #patvi,6(a0)
        move.l  #patvi,10(a0)
        move.l  #patfri,2(a0)
        clr.w   (a0)
        addq.b  #1,nbamb
        bra     rrcc
;appel syncro anim
anim:   
        lea.l   morc2,a6
        bsr     prseq
        lea.l   texe+48(pc),a3
        lea.l   adpatt(pc),a5
        lea.l   patani(pc),a4
banim:  move.l  (a5)+,d0
        beq.s   fanim
        move.l  a4,6(a3)
        move.l  d0,(a4)+
        move.l  a4,10(a3)
        clr.l   (a4)+
        move.l  d0,2(a3)
        move.w  #$100,(a3)
        lea.l   16(a3),a3
        bra.s   banim
fanim:  bra     rrcc
; ********* coupure
couto:  move.b  #1,texe
        move.b  #1,texe+32
        move.l  #pretim,-(sp)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp
        rts        
etami: 
        move.l  iormid(pc),a0
        move.w  #-1,d0
        move.w  6(a0),d1
        cmp.w   8(a0),d1
        bne.s   carec
        moveq #0,d0
carec:  rts
carmi: 
        bsr     etami
        tst.w   d0
        beq.s   carmi
        moveq   #0,d0
        move.w  6(a0),d1
        addq.w  #1,d1
        cmp.w   4(a0),d1
        bcs.s   tampn
        moveq   #0,d1
tampn:  move.l  (a0),a1
        move.b  0(a1,d1.w),d0
        move.w  d1,6(a0)
        rts
iormid: dc.l    0

;appel ambiance generale
premfo: dc.w    0
main:   tst.w   premfo
        bne     ssmain
        move.w  #1,premfo
        move.w  #2,-(sp)
        move.w  #14,-(sp)
        trap    #14
        addq.l  #4,sp
        move.l  d0,iormid
        move.l  #tabsob,tabson
        move.l  #tapreb,tapres
        move.l  #ptechb,ptech
        move.l  #echanb,echan
        move.l  #tafreb,tafreq
        clr.w   -(sp)
        move.l  #nomech,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        tst.w   d0
        bmi     error
        move.w  d0,handle
        move.l  #fiech,-(sp)
        move.l  #600000,-(sp)
        move.w  handle(pc),-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        tst.l   d0
        bmi     error
        move.w  handle(pc),-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.w   d0
        bge     oerror
error:  illegal
oerror: move.l  #fiech,a0
        move.l  a0,a1
        add.l   #600000,a1
        move.l  #150000,d0
becc:   move.l  (a0)+,(a1)+
        subq.l  #1,d0
        bgt.s   becc
        clr.w   -(sp)
        move.l  #nomson,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        tst.w   d0
        bmi     error
        move.w  d0,handle
        move.l  #tabsob,-(sp)
        move.l  #26000,-(sp)
        move.w  handle(pc),-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        tst.l   d0
        bmi     error
        move.w  handle(pc),-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
ssmain:
        bsr     initg
        lea.l   soncan,a3
        move.l  tapres(pc),a2
        lea.l   canmid,a1
        move.w  #15,d0
bef4:   clr.w   d1
        move.b  (a1)+,d1
        mulu    #90,d1
        move.l  a2,(a3)
        add.l   d1,(a3)+
        dbf     d0,bef4

        move.l  #morceau,a6
        bsr     prseq
        clr.w   finmor

        lea.l   texe+16(pc),a6
        lea.l   adpatt(pc),a0
        lea.l   patamb(pc),a1
bamb:   move.l  (a0)+,d0
        beq.s   famb
        move.l  d0,(a1)+
        clr.l   (a1)+
        bra.s   bamb
famb:   moveq   #0,d0
        move.b  nhamb(pc),ahamb
        move.b  nhamb(pc),d0
        lea.l   patamb(pc),a1
        lsl.w   #3,d0
        add.w   d0,a1
        move.l  a1,6(a6)
        move.l  (a1)+,2(a6)
        move.l  a1,10(a6)
        move.w  #999,14(a6)
        clr.w   (a6)

        clr.w   nbambco
        move.b  #1,-16(a6)
        move.w  #7,d0
        lea.l   16(a6),a6
bbee:   move.b  #1,(a6)
        lea.l   16(a6),a6
        dbf     d0,bbee

        move.l  #trgen,-(sp)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp
rrcc: 
        rts
valeu:  dc.w    0
meppat: lea.l   adpatt,a5
        move.l  a4,a2
        clr.w   d7
        move.b  (a6)+,d7
        beq.s   papat
        subq.w  #2,d7
        moveq   #0,d0
bmeppa: move.b  (a6)+,d0
        move.l  0(a5,d0.w),(a4)+
        dbf     d7,bmeppa
        clr.l   (a4)
        move.b  (a6),d0
        move.l  (a2),2(a3)
        move.l  a2,6(a3)
        add.l   d0,6(a3)
        move.l  a2,10(a3)
        addq.l  #4,10(a3)
        move.w  durmor(pc),14(a3)
        clr.w   (a3)
        move.w  #1,durmor
        rts  
papat:  move.l  (a5),(a4)+
        clr.l   (a4)
        move.l  (a2),2(a3)
        move.l  a2,6(a3)
        move.l  a4,10(a3)
        move.w  durmor(pc),14(a3)
        clr.w   (a3)
        move.w  #1,durmor
        rts  
chmorc:
        move.w  nummor(pc),d0
        lea.l   numer+3(pc),a0
        moveq   #2,d7
bdig:   ext.l   d0
        divu    #10,d0
        swap    d0
        add.w   #"0",d0
        move.b  d0,-(a0)
        swap    d0
        dbf     d7,bdig
        
        clr.w   -(sp)
        move.l  #nommor,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        tst.w   d0
        bmi     error
        move.w  d0,handle
        move.l  4(a7),d0
        move.l  d0,-(sp)
        move.l  #5000,-(sp)
        move.w  handle(pc),-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        tst.l   d0
        bmi     error
        move.w  handle(pc),-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.w   d0
        bmi     error
        rts
prseq:  move.l  a6,-(sp)
        bsr     chmorc
        move.l  (sp)+,a6
        lea.l   teson(pc),a0
        move.w  #37,d7
befts1: move.l  #$80808080,(a0)+
        dbf     d7,befts1
        clr.w   d7
        move.b  (a6)+,d7
        add.w   d7,a6
        move.l  a6,a2
        move.b  (a6)+,d7
        lsl.b   #1,d7
        add.w   d7,a6
        move.b  (a6)+,valeu+1
        move.b  modivo+1(pc),d0
        add.b   d0,valeu+1
        clr.w   modivo
        move.b  (a6)+,nbpatb
        move.l  a6,a0
        move.l  #adpatt,a5
        bsr     rececv
        lea.l   teson,a0
        clr.w   d7
        move.b  (a2)+,d7
        beq.s   padiec
        subq.w  #1,d7
bdiec:  clr.w   d1
        move.b  (a2)+,d1
        cmp.b   #$80,0(a0,d1.w)
        bne.s   ecpres
        lea.l   1(a2),a2
        bra.s   fmmoo2
ecpres: move.b  (a2)+,d0
        add.b   d0,0(a0,d1.w)
fmmoo2: dbf     d7,bdiec
padiec: clr.w   d7
        move.l  a0,a3
bdiec3: cmp.b   #$80,0(a3,d7.w)
        beq.s   padvl
        move.w  d7,d1
        mulu    #12,d1         
        move.l  ptech(pc),a1
        add.w   d1,a1
        move.l  12(a1),d3
        and.l   #$ffffff,d3
        move.l  (a1),d4
        and.l   #$ffffff,d4
        sub.l   d4,d3
        subq.l  #3,d3
        blt.s   padvl
        move.l  d4,a1
        add.l   echan(pc),a1
        move.l  a1,a5
        add.l   #600000,a5
bttk:   move.b  (a5)+,(a1)+
        dbf     d3,bttk
        move.w  d7,d1
        move.b  0(a3,d7.w),d0
        beq.s   padvl
        ext.w   d0
        bsr     modvol
padvl:  addq.w  #1,d7
        cmp.w   #151,d7
        ble.s   bdiec3
        rts
fonccan:
        move.w  nbcan,d4
        lea.l   tabf(pc),a1
        subq.w  #1,d4
        ble.s   unsec0
        mulu    #128,d4
        subq.w  #1,d4
        move.l  #$08000000,d0
        move.l  #$09000000,d1
        move.l  #$0a000000,d2
        moveq   #0,d3
b1conv: move.l  d0,(a1)+
        move.l  d1,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        dbf     d4,b1conv
unsec0: lea.l   tab1,a2
        lea.l   tab2,a3
        lea.l   tab3,a4
        move.w  #255,d4
b0conv: move.w  #$0800,(a1)+
        move.b  (a2)+,(a1)+
        clr.b   (a1)+
        move.w  #$0900,(a1)+
        move.b  (a3)+,(a1)+
        clr.b   (a1)+
        move.w  #$0a00,(a1)+
        move.b  (a4)+,(a1)+
        clr.b   (a1)+
        clr.l   (a1)+
        dbf     d4,b0conv
        move.w  nbcan,d4
        subq.w  #1,d4
        ble.s   unsec1
        mulu    #128,d4
        subq.w  #1,d4
        move.l  #$08000e00,d0
        move.l  #$09000800,d1
        move.l  #$0a000000,d2
b2conv: move.l  d0,(a1)+
        move.l  d1,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        dbf     d4,b2conv
unsec1: move.w  nbcan,d4
        subq.w  #1,d4
        lsl.w   #2,d4
        jmp     mcan(pc,d4.w)
mcan:   bra.l   mo1ca
        bra.l   mo2ca
        bra.l   mo3ca
        bra.l   mo4ca
mo1ca:  lea.l   modcaa+1(pc),a1
        move.b  #$56+12,(a1)
        move.l  #$00800000,$8c.w
        move.l  #$00000000,$90.w
        rts
mo2ca:  lea.l   modcaa+1(pc),a1
        move.b  #$56+8,(a1)
        lea.l   modcad+1(pc),a1
        move.b  #$3a+8,(a1)
        move.l  #$00800080,$8c.w
        move.l  #$00000000,$90.w
        rts
mo3ca:  lea.l   modcaa+1(pc),a1
        move.b  #$56+4,(a1)
        lea.l   modcad+1(pc),a1
        move.b  #$3a+4,(a1)
        lea.l   modcac+1(pc),a1
        move.b  #$20+4,(a1)
        move.l  #$00800080,$8c.w
        move.l  #$00800000,$90.w
        rts
mo4ca:  lea.l   modcaa+1(pc),a1
        move.b  #$56,(a1)
        lea.l   modcad+1(pc),a1
        move.b  #$3a,(a1)
        lea.l   modcac+1(pc),a1
        move.b  #$20,(a1)
        move.l  #$00800080,$8c.w
        move.l  #$00800080,$90.w
        rts

trgen:  move.l  tafreq(pc),a1
        move.w  #37,d0
        move.w  #213,d1
        move.w  #85,d2
        or.w    #$100,d1
        or.w    #$200,d2
bcalf:  move.w  d1,(a1)+
        subq.b  #1,d1
        move.w  d2,(a1)+
        subq.b  #2,d2
        move.w  d1,(a1)+
        subq.b  #1,d1
        move.w  d1,(a1)+
        subq.b  #1,d1
        move.w  d1,(a1)+
        subq.b  #1,d1
        move.w  d1,(a1)+
        subq.b  #1,d1
        dbf     d0,bcalf

afgen:  
        bsr     pretim
        bsr     fonccan
        clr.w   nbinvi
        tst.l   savvbl
        bne.s   zer
        move.l  $70,savvbl
        move.l  $114,savtic
        move.l  $70,jpvbl+2
zer:    move.l  #-1,tvita
        move.l  #-1,tvita+4
        move.w  #-1,ancplr
        bclr    #3,$fffffa17.w
        move.b  #7,$ffff8800.w
        move.b  #$ff,$ffff8802.w
        clr.l   $94
        and.b   #$fa,$484
        move.l  #routima,$70
        rts
; ******* modif du pourc pour son
modpourc: 
        move.w  pourc,d3
        mulu    #40000,d3
        lsl.l   #1,d3
        move.l  d3,nbcycl
        illegal


initg:  move.l  tabson(pc),a3
        move.w  #255,d0
bef1:   clr.l   88(a3)
        clr.l   92(a3)
        clr.l   96(a3)
        clr.l   68(a3)
        add.l   #100,a3
        dbf     d0,bef1

        move.l  tapres(pc),a1
        move.w  #39,d0
bini1:  move.w  #21,d1
bini1b: 
        move.l  #-1,(a1)+
        dbf     d1,bini1b
        clr.w   (a1)+
        dbf     d0,bini1

        move.l  tabson(pc),a2
        add.l   #25500,a2
        move.w  #255,d2
bini2:  clr.l   d0
        move.b  24(a2),d0
        beq.s   sinipre
        move.l  tapres(pc),a1
        subq.w  #1,d0
        mulu    #90,d0
        add.l   d0,a1
        clr.w   d0
        move.b  27(a2),d0
        add.l   d0,a1
        move.b  28(a2),d0
        sub.b   27(a2),d0
s2toct: move.b  d2,(a1)+
        dbf     d0,s2toct
sinipre:
        lea.l   -100(a2),a2
        dbf     d2,bini2

        lea.l   canal,a3
        move.w  #79,d0
bef2:   clr.l   (a3)+
        dbf     d0,bef2
        lea.l   prior,a3
        clr.l   (a3)
        clr.l   4(a3)
        clr.l   8(a3)
        clr.l   12(a3)
        move.b  #3,2(a3)
        move.b  #2,6(a3)
        move.b  #1,10(a3)
        lea.l   arpeg1,a3
        move.w  #1,d0
bef3:   clr.w   (a3)
        move.l  #$7f7f7f7f,2(a3)
        move.l  #$7f7f7f00,6(a3)
        clr.l   10(a3)
        clr.w   14(a3)
        add.l   #16,a3
        dbf     d0,bef3
        clr.l   tenue
        clr.w   veloc
        lea.l   adcan,a3
        move.l  #canal,(a3)
        move.l  #canal2,4(a3)
        move.l  #canal3,8(a3)
        move.l  #canal4,12(a3)
        rts
rececv:
        move.l  a0,sava6
        lea.l   teson,a0
rtmid2: move.l  sava6(pc),(a5)+
etmid2: bsr     carmid2
        move.b  d0,nocan2
        and.b   #$0f,nocan2
        btst    #7,d0
        bne.s   infomi
        cmp.b   #127,d0
        beq     finmo
        bra.s   etmid2
infomi: and.b   #$f0,d0
        cmp.b   #$90,d0
        beq.s   noton2
        cmp.b   #$c0,d0
        beq.s   chprg2
        cmp.b   #$80,d0
        beq.s   rele
        cmp.b   #$b0,d0
        beq.s   rele
        cmp.b   #$e0,d0
        beq.s   rele
        bra.s   etmid2
rele:   bsr     carmid2
        bra.s   etmid2
chprg2: bsr     carmid2
        lea.l   soncan,a3
        clr.w   d3
        move.b  nocan2,d3
        lsl.w   #2,d3
        move.l  tapres(pc),a1
        mulu    #90,d0
        add.l   d0,a1
        move.l  a1,0(a3,d3.w)
        bra     etmid2
noton2: bsr     carmid2
        move.b  d0,notmid2
        lea.l   soncan,a3
        clr.w   d3
        move.b  nocan2(pc),d3
        lsl.w   #2,d3
        move.l  0(a3,d3.w),a3
        move.b  notmid2(pc),d3
        move.b  0(a3,d3.w),d3
        mulu    #100,d3
        move.l  tabson(pc),a3
        add.l   d3,a3
        move.b  25(a3),d0
        tst.b   32(a3)
        beq.s   noton3
        bsr     carmid2
        cmp.b   32(a3),d0
        bge.s   precha
        move.b  31(a3),d0
        bra.s   noton3
precha: move.b  25(a3),d0                
noton3: move.b  valeu+1(pc),0(a0,d0.w)
        bra     etmid2
finmo:  subq.b  #1,nbpatb
        bgt     rtmid2
        clr.l   (a5)
        rts
carmid2:
        clr.w   d0
        move.l  sava6,a6
        move.b  (a6)+,d0
        move.l  a6,sava6
        rts
routima:
        clr.w   $b2.w
        addq.l  #1,$4ba.w
        movem.l a0-a6/d0-d7,-(a7)
        tst.w   finmor
        beq.s   morco
coutot: bsr     pretim
        bsr     rinitc
        move.l  savvbl,$70
        move.w  #1,finmor
        movem.l (a7)+,a0-a6/d0-d7
        rte
morco:  
morcob: 
;trt midi anim
;        bsr     etami
;        tst.w   d0
;        beq.s   smorcob
        bra.s   smorcob

        bsr     carmi
        lea.l   texe+48(pc),a0
        cmp.w   #6,d0
        blt.s   paanbc
        bgt.s   coanbc
        tst.b   (a0)
        beq.s   morcob
        addq.b  #1,nbamb
        move.w  #9999,14(a0)
        move.l  6(a0),a1
        move.l  (a1),2(a0)
        clr.w   (a0)
        bra.s   morcob
coanbc: 
        tst.b   (a0)
        bne.s   morcob
        move.w  #$100,(a0)
        lea.l   16(a0),a0
        move.w  #1,14(a0)
        move.l  6(a0),a1
        move.l  (a1),2(a0)
        clr.w   (a0)
        bra.s   morcob
paanbc: 
        lsl.w   #4,d0
        add.w   d0,a0
        tst.b   (a0)
        beq.s   morcob
        addq.b  #1,nbamb
        move.w  #1,14(a0)
        move.l  6(a0),a1
        move.l  (a1),2(a0)
        clr.w   (a0)
        bra.s   morcob
smorcob:
;changt ambiance jour nuit
        moveq   #0,d0
        move.b  nhamb(pc),d0
        cmp.b   ahamb(pc),d0
        beq.s   s1morco
        move.b  d0,ahamb
        lea.l   patamb(pc),a1
        lsl.w   #3,d0
        add.w   d0,a1
        lea.l   texe+16(pc),a6
        move.l  a1,6(a6)
        move.l  a1,10(a6)
        move.w  #999,14(a6)
s1morco:
        lea.l   tvitn(pc),a1
        move.l  #-1,(a1)+
        move.l  #-1,(a1)+
        lea.l   canal(pc),a1
        move.l  #$94,a2
        move.l  (a2),tferm
        move.w  #3,d0
        moveq   #0,d1
bferm:  tst.b   (a2)+
        beq.s   sbferm
        clr.b   -1(a2)
        move.l  12(a1),a3
        bsr     fermet
sbferm: lea.l   80(a1),a1
        addq.w  #1,d1
        dbf     d0,bferm

; trt du morc prio
        lea.l   texe(pc),a6
        move.b  -1(a6),-2(a6)
        tst.b   (a6)
        bne.s   pamopi
        bsr     trmidi
        nop
        lea.l   32(a6),a6
        bra.s   transy
; trt ambiance gener
pamopi: lea.l   16(a6),a6
        bsr     trmidi
        nop
tramsu: lea.l   16(a6),a6
        tst.b   (a6)
        bne.s   transy
        bsr     trmidi
        nop
transy: move.b  #-1,typri
        tst.b   nbambco
        beq.s   fmidi
btrasy: lea.l   16(a6),a6
        tst.b   (a6)
        bne.s   btrasy
        bsr     trmidi
        bra.s   strasy
        subq.b  #1,nbamb
strasy: subq.b  #1,nbambco
        bgt.s   btrasy
fmidi:  clr.b   typri
        lea.l   arpeg1(pc),a5
        tst.b   (a5)
        beq.s   trarp2
        clr.w   d2
        move.b  1(a5),d2
        subq.w  #1,d2
        move.b  d2,1(a5)
        tst.w   d2
        bgt.s   trarp2
        bsr     trcarp
trarp2: lea.l   arpeg2(pc),a5
        tst.b   (a5)
        beq.s   ftrarp
        clr.w   d2
        move.b  1(a5),d2
        subq.w  #1,d2
        move.b  d2,1(a5)
        tst.w   d2
        bgt.s   ftrarp
        bsr     trcarp
ftrarp: 
        lea.l   canal(pc),a1
        tst.b   (a1)
        beq.s   can1fe
        move.l  12(a1),a3
        move.w  #0,d1
        move.b  37(a1),35(a1)
        clr.b   34(a1)
        clr.w   76(a1)
        bsr     tcanb
can1fe: lea.l   canal2(pc),a1
        tst.b   (a1)
        beq.s   can2fe
        move.l  12(a1),a3
        move.w  #1,d1
        move.b  37(a1),35(a1)
        clr.b   34(a1)
        clr.w   76(a1)
        bsr     tcanb
can2fe: lea.l   canal3(pc),a1
        tst.b   (a1)
        beq.s   can3fe
        move.l  12(a1),a3
        move.w  #2,d1
        move.b  37(a1),35(a1)
        clr.b   34(a1)
        clr.w   76(a1)
        bsr     tcanb
can3fe: lea.l   canal4(pc),a1
        tst.b   (a1)
        beq.s   can4fe
        move.l  12(a1),a3
        move.w  #3,d1
        move.b  37(a1),35(a1)
        clr.b   34(a1)
        clr.w   76(a1)
        bsr     tcanb
can4fe: 
; ****** recherche du + rapide et calc vites

        lea.l   tatem(pc),a0
        move.w  nbcan(pc),d1
        subq.w  #1,d1
        lsl.w   #3,d1
        add.w   d1,a0
        lea.l   nadd(pc),a2
        move.l  tafreq(pc),a6
        lea.l   convit(pc),a3
        clr.l   (a2)
        lea.l   tvitn(pc),a5
reprdep:
        clr.w   d1
        move.w  (a5)+,d3
        move.w  #1,d2
bplra:  cmp.w   (a5)+,d3
        bgt.s   splra
        blt.s   s1plra
        cmp.w   ancplr(pc),d2
        bne.s   splra
s1plra: move.w  -2(a5),d3
        move.w  d2,d1
splra:  addq.w  #1,d2
        cmp.w   nbcan(pc),d2
        blt.s   bplra
        tst.w   d3
        bge.s   exca
        move.w  ancplr(pc),d0
        blt.s   spatr
        lea.l   bracoup(pc),a6
        lsl.w   #2,d0
        jsr     0(a6,d0.w)
        move.w  #-1,ancplr
spatr:  move.l  #-1,tvita
        move.l  #-1,tvita+4
        bra     fir50
exca:   lea.l   tvitn(pc),a5
        move.w  nbcan(pc),d2
        subq.w  #1,d2
        moveq   #0,d3
bexca:  move.w  d2,d7
        lsl.w   #1,d7
        move.w  0(a5,d7.w),d4
        blt.s   vineg
        lsl.w   #1,d4
        clr.w   d5
        clr.w   d6
        move.b  0(a6,d4.w),d5
        move.b  1(a6,d4.w),d6
        move.b  0(a3,d5.w),d5
        mulu    d6,d5
        move.l  #640000*4,d6
        divu    d5,d6
        cmp.w   d2,d1
        bne.s   leclen
        move.w  0(a0,d7.w),d5
        bra.s   slecle
leclen: move.w  vroutl(pc),d5
slecle: mulu    d5,d6
        add.l   d6,d3
vineg:  dbf     d2,bexca
        cmp.l   nbcycl(pc),d3
        ble     parepr
        tst.b   0(a2,d1.w)
        beq.s   onsorp
        lea.l   bracoup(pc),a6
        move.w  nbcan(pc),d0
        subq.w  #1,d0
bplant: move.w  d0,d1
        lsl.w   #2,d1
        jsr     0(a6,d1.w)
        dbf     d0,bplant
        clr.b   canal
        clr.b   canal2
        clr.b   canal3
        clr.b   canal4
        move.l  #-1,tvita
        move.l  #-1,tvita+4
        move.w  #-1,ancplr
        clr.l   $94
        bra     fir50
onsorp: move.b  #1,0(a2,d1.w)
        lea.l   canal(pc),a1
        move.w  d1,d5
        mulu    #80,d5
        add.l   d5,a1  
        lea.l   rap14(pc),a4
        move.w  74(a1),d6
        sub.w   #24,d6
        bge.s   sup72b
        clr.w   d6
        bra.s   inf72b
sup72b: cmp.w   #72,d6
        ble.s   inf72b
        move.w  #72,d6
inf72b: move.b  0(a4,d6.w),d6
        add.w   76(a1),d6
        add.w   78(a1),d6
        bge.s   sup25
        clr.w   d6
        bra.s   fsup25
sup25:  cmp.w   #225,d6
        ble.s   fsup25
        move.w  #225,d6
fsup25: move.w  d1,d2
        lsl.w   #1,d2
        move.w  d6,0(a5,d2.w)
        bra     reprdep
parepr:
        lea.l   tvitn(pc),a1
        lea.l   bracoup(pc),a6
        lea.l   padetr(pc),a5
        clr.l   (a5)
        move.b  #1,0(a5,d1.w)
        cmp.w   ancplr(pc),d1
        beq     crearap
        move.w  ancplr(pc),d2
        blt     scrrap
        lea.l   tferm(pc),a3
        cmp.b   #3,0(a3,d1.w)
        bne.s   pacrpr
        move.w  #-1,d0
        bsr     crecan
        bra.s   tranpr
pacrpr: move.w  d1,d3
        lsl.w   #1,d3
        move.w  0(a1,d3.w),d2
        lsl.w   #1,d2
        lsl.w   #1,d3
        move.w  ancplr(pc),d0
        lsl.w   #2,d0
        jsr     0(a6,d0.w)
        move.l  #$fffffa01,a4
        move.l  tafreq(pc),a3
        jsr     80(a6,d3.w)
tranpr: move.w  ancplr(pc),d2
        move.b  #1,0(a5,d2.w)
        move.l  #$94,a4
        tst.b   0(a4,d2.w)
        beq.s   pcouan
        move.b  #1,0(a4,d2.w)
        bra.s   crepet
pcouan: lea.l   tferm(pc),a3
        cmp.b   #2,0(a3,d2.w)
        blt.s   modan
        beq.s   crepet
        move.w  d1,ancplr
        move.w  d2,d1
        clr.w   d0
        bsr     crecan
        bra.s   screp
modan:  move.w  d2,d3
        lsl.w   #1,d3
        move.w  0(a1,d3.w),d2
        lsl.w   #1,d2
        lsl.w   #1,d3
        move.l  #$fffffa01,a4
        move.l  tafreq(pc),a3
        jsr     64(a6,d3.w)
        bra.s   crepet
crearap:
        lea.l   tferm(pc),a3
        cmp.b   #3,0(a3,d1.w)
        beq.s   scrrap
        bsr     moduca
        bra.s   crepet
scrrap: move.w  #1,d0
        bsr     crecan
crepet: move.w  d1,ancplr
screp:  move.w  nbcan(pc),d1
        subq.w  #1,d1
bcrept: tst.b   0(a5,d1.w)
        bne.s   scrept
        move.w  d1,d2
        lsl.w   #1,d2
        tst.w   0(a1,d2.w)
        blt.s   scrept
        lea.l   tferm(pc),a3
        cmp.b   #3,0(a3,d1.w)
        beq.s   scrle
        bsr     moduca
        bra.s  scrept
scrle:  clr.w   d0
        bsr     crecan
scrept: dbf     d1,bcrept
        move.l  (a1),8(a1)
        move.l  4(a1),12(a1)
        move.l  nadd(pc),aadd

        move.w  $b2.w,d1
        beq     fir50
        move.l  #$fffffa01,a4
        subq.w  #1,d1
        clr.w   d0
        lea.l   anter(pc),a0
        move.l  #$230,a5
bant:   move.b  (a0)+,d2
        move.b  (a0)+,d3
        move.w  (a0)+,d4
        move.l  etfad(pc,d4.w),a2
        or.w    #$700,sr
        move.b  $b0.w,d0
        beq.s   dirant
        move.b  tant(pc,d0.w),d0
        move.l  0(a5,d0.w),a1
        move.l  (a1),d7
        and.w   #$f5ff,sr
battt:  cmp.l   (a1),d7
        beq.s   battt
        move.w  #45,d7
abattt: dbf     d7,abattt
dirant: jsr     (a2)
        dbf     d1,bant
        bra     fir50
tant:   dc.b    0,0,4,4,8,8,8,8,12,12,12,12,12,12,12,12
etfad:  dc.l    fad35
        dc.l    fad38
        dc.l    fad37
        dc.l    fad36
fad35:  or.w    #$700,sr 
        move.b  #0,24(a4)
        move.b  d3,30(a4)
        move.b  d2,24(a4)
        and.w   #$f5ff,sr
        bset    #0,$b0.w
        rts
fad38:  or.w    #$700,sr 
        and.b   #$f0,28(a4)
        move.b  d3,36(a4)
        or.b    d2,28(a4)
        and.w   #$f5ff,sr
        bset    #1,$b0.w
        rts
fad37:  or.w    #$700,sr 
        and.b   #$f,28(a4)
        move.b  d3,34(a4)
        lsl.b   #4,d2
        or.b    d2,28(a4)
        and.w   #$f5ff,sr
        bset    #2,$b0.w
        rts
fad36:  or.w    #$700,sr 
        move.b  #0,26(a4)
        move.b  d3,32(a4)
        move.b  d2,26(a4)
        and.w   #$f5ff,sr
        bset    #3,$b0.w
        rts

fir50:  movem.l (a7)+,a0-a6/d0-d7
;        rte
jpvbl:  jmp     $12345678

anter:  dc.l    0,0,0,0
; *********** creation canal
crecan: move.w  d1,d3
        mulu    #80,d3
        lea.l   canal,a3
        add.l   d3,a3
        move.l  12(a3),a3
        move.w  d1,d3
        lsl.w   #2,d3
        jsr     0(a6,d3.w)
        lsl.w   #1,d3
        move.l  #$94,a0
        clr.b   0(a0,d1.w)

        move.b  32(a3),d2
        cmp.b   6(a3,d1.w),d2
        ble.s   trnor
        move.l  ptech(pc),a0
        clr.w   d2
        move.b  31(a3),d2
        mulu    #12,d2
        add.l   d2,a0
        lea.l   forme(pc),a2
        btst    #0,33(a3)
        beq.s   pabclb
        addq.l  #4,a2
pabclb: clr.w   d2
        move.b  34(a3),d2
        lsl.w   #3,d2
        add.w   d2,a2
        bra.s   strnor   
trnor:  move.l  ptech(pc),a0
        clr.w   d2
        move.b  25(a3),d2
        mulu    #12,d2
        add.l   d2,a0
        lea.l   forme(pc),a2
        btst    #0,29(a3)
        beq.s   pabcl
        addq.l  #4,a2
pabcl:  clr.w   d2
        move.b  30(a3),d2
        lsl.w   #3,d2
        add.w   d2,a2
strnor: clr.w   d2
        move.b  (a2)+,d2
        lsl.w   #2,d2
        tst.b   d0
        beq.s   petro1
        move.l  100(a6,d3.w),a4
        move.l  0(a0,d2.w),(a4)
        clr.b   (a4)
        add.l  #echanb,(a4)
;        move.l  echan(pc),d2
;        add.l   d2,(a4)
        bra.s   spetro
petro1: move.l  96(a6,d3.w),a4
        move.l  0(a0,d2.w),(a4)
        clr.b   (a4)
        add.l  #echanb,(a4)
;        move.l  echan(pc),d2
;        add.l   d2,(a4)
spetro: move.l  #$200,a4
        move.w  d3,d2
        lsr.w   #1,d2
        add.w   d3,d2
        add.w   d2,a4
        move.w  #2,d3
bpvec:  clr.w   d2
        move.b  (a2)+,d2
        blt.s   fbpve
        lsl.w   #2,d2
        move.l  0(a0,d2.w),(a4)
        clr.b   (a4)
        add.l  #echanb,(a4)+
;        move.l  echan(pc),d2
;        add.l   d2,(a4)
        dbf     d3,bpvec
        bra.s   spove
fbpve:  clr.l   (a4)
spove:  
        move.l  tafreq(pc),a3
        move.w  d1,d3
        lsl.w   #1,d3
        move.w  0(a1,d3.w),d2
        lsl.w   #1,d2
        lsl.w   #1,d3
        lea.l   $fffffa01,a4
        tst.b   d0
        beq.s   petro2
        bgt.s   couanc
        move.w  ancplr(pc),d0
        lsl.w   #2,d0
        jsr     0(a6,d0.w)
couanc: jmp     32(a6,d3.w)
petro2: jmp     16(a6,d3.w)
; ********* modulation canal
moduca: move.w  d1,d3
        lsl.w   #1,d3
        move.w  0(a1,d3.w),d2
        cmp.w   8(a1,d3.w),d2
        bne.s   smodu
        rts
smodu:  lsl.w   #1,d2
        lsl.w   #1,d3
        move.l  tafreq(pc),a3
        lea.l   $fffffa01,a4
        jmp     48(a6,d3.w)

bracoup:
        bra.l   coupa
        bra.l   coupd
        bra.l   coupc
        bra.l   coupb
        bra.l   creap
        bra.l   credp
        bra.l   crecp
        bra.l   crebp
        bra.l   creag
        bra.l   credg
        bra.l   crecg
        bra.l   crebg
        bra.l   modua
        bra.l   modud
        bra.l   moduc
        bra.l   modub
        bra.l   modua1
        bra.l   modud1
        bra.l   moduc1
        bra.l   modub1
        bra.l   modua2
        bra.l   modud2
        bra.l   moduc2
        bra.l   modub2
        dc.l    routiap+2
        dc.l    routiag+6
        dc.l    routidp+2
        dc.l    routidg+6
        dc.l    routicp+2
        dc.l    routicg+6
        dc.l    routibp+2
        dc.l    routibg+6
 
trcarp: move.l  tabson(pc),a3
        clr.w   d3
        move.b  11(a5),d3
        mulu    #100,d3
        add.l   d3,a3
        move.b  (a5),1(a5)
        clr.w   d2
        move.b  10(a5),d2
        tst.b   9(a5)
        bne.s   ardesc
        addq.b  #1,d2
        cmp.b   12(a5),d2
        blt.s   genson
        btst    #3,42(a3)
        beq.s   padesc
        move.b  #1,9(a5)
        subq.b  #2,d2
        bge.s   genson
padesc: clr.b   d2
        bra.s   genson
ardesc: subq.b  #1,d2
        bge.s   genson
        btst    #2,42(a3)
        beq.s   pamont
        clr.b   9(a5)
        addq.b  #2,d2
        cmp.b   12(a5),d2
        blt.s   genson
        clr.b   d2
        bra.s   genson
pamont: move.b  12(a5),d2
        subq.b  #1,d2
genson: move.b  d2,10(a5)
        move.b  2(a5,d2.w),notmid
        move.b  13(a5),veloc1
        move.b  14(a5),nocan
        move.b  11(a5),nosonb
        bsr     trainot
        rts
chprg:  bsr     carmid
        lea.l   soncan(pc),a3
        clr.w   d3
        move.b  nocan,d3
        lsl.w   #2,d3
        move.l  0(a3,d3.w),a1
        move.l  tapres(pc),a1
        mulu    #90,d0
        add.l   d0,a1
        move.l  a1,0(a3,d3.w)
        bra     etmid
contno: bsr     carmid
        lea.l   soncan(pc),a3
        clr.w   d3
        move.b  nocan,d3
        lsl.w   #2,d3
        move.l  0(a3,d3.w),a3
        move.b  d0,89(a3)
        bra     etmid
pitch:  bsr     carmid
        lea.l   soncan(pc),a3
        clr.w   d3
        move.b  nocan,d3
        lsl.w   #2,d3
        move.l  0(a3,d3.w),a3
        move.b  d0,88(a3)
        bra     etmid
noton:  bsr     carmid
        move.b  d0,notmid
        lea.l   soncan(pc),a3
        clr.w   d3
        move.b  nocan(pc),d3
        lsl.w   #2,d3
        move.l  0(a3,d3.w),a3
        move.b  notmid(pc),d3
        move.b  0(a3,d3.w),d3
        cmp.b   #-1,d3
        beq     etmid
papian: move.b  d3,nosonb
        mulu    #100,d3
        move.l  tabson(pc),a3
        add.l   d3,a3
        tst.b   32(a3)
        beq.s   pvelm
        bsr     carmid
        move.b  d0,veloc1
pvelm:  addq.b  #1,70(a3)
        btst    #4,42(a3)
        bne.s   tarpeg
        bsr     trainot
        bra     etmid
tarpeg: cmp.b   #1,47(a3)
        beq.s   arp1
        bgt.s   arp2
        tst.b   arpeg1
        bne.s   carp2
        move.b  #1,47(a3)
        lea.l   arpeg1(pc),a5
carp1:  move.b  43(a3),(a5)
        move.b  #1,1(a5)
        clr.b   10(a5)
        move.b  #1,9(a5)
        move.b  nocan,14(a5)
        move.b  nosonb,11(a5)
        move.b  #1,12(a5)
        move.b  notmid,2(a5)
        move.b  veloc1,13(a5)
        bra     etmid
carp2:  tst.b   arpeg2
        bne     etmid
        move.b  #2,47(a3)
        lea.l   arpeg2(pc),a5
        bra.s   carp1
arp2:   lea.l   arpeg2(pc),a5
        bra.s   arpc
arp1:   lea.l   arpeg1(pc),a5
arpc:   addq.b  #1,12(a5)
        move.b  veloc1,13(a5)
        cmp.b   #7,12(a5)
        ble.s   mnat
        move.b  #7,12(a5)
        btst    #7,38(a3)
        beq.s   arptri
        move.b  3(a5),2(a5)
        move.b  4(a5),3(a5)
        move.b  5(a5),4(a5)
        move.b  6(a5),5(a5)
        move.b  7(a5),6(a5)
        move.b  8(a5),7(a5)
        move.b  notmid,8(a5)
        subq.b  #1,10(a5)
        bra     etmid
arptri: move.b  notmid,d2
        move.w  #6,d3
btriar: cmp.b   2(a5,d3.w),d2
        bgt.s   platro
        dbf     d3,btriar
        move.b  d2,2(a5)
        bra     etmid
platro: move.b  d2,2(a5,d3.w)
        bra     etmid
mnat:   btst    #7,38(a3)
        beq.s   arptri1
        clr.w   d2
        move.b  12(a5),d2
        move.b  notmid,1(a5,d2.w)
        bra.s   etmid
arptri1:
        move.b  notmid,d2
        clr.w   d3
        move.b  12(a5),d3
        subq.w  #2,d3
btria1: cmp.b   2(a5,d3.w),d2
        bgt.s   platro1
        move.b  2(a5,d3.w),3(a5,d3.w)
        dbf     d3,btria1
        move.b  d2,2(a5)
        addq.b  #1,10(a5)
        bra.s   etmid
platro1:
        move.b  d2,3(a5,d3.w)
        cmp.b   10(a5),d3
        bge     etmid
        addq.b  #1,10(a5)
        bra.s   etmid
trmidi: tst.b   1(a6)
        beq.s   etmid
        subq.b  #1,1(a6)
        rts
etmid:  bsr     carmid
        btst    #7,d0
        beq.s   pinfmi
        move.b  d0,nocan
        and.b   #$0f,nocan
        and.b   #$f0,d0
        cmp.b   #$80,d0
        beq     notof1
        cmp.b   #$90,d0
        beq     noton
        cmp.b   #$c0,d0
        beq     chprg
        cmp.b   #$b0,d0
        beq     contno
        cmp.b   #$e0,d0
        beq     pitch
        bra.s   etmid
pinfmi: cmp.b   #127,d0
        beq.s   fipatt
        move.b  d0,1(a6)
        rts
fipatt: move.l  10(a6),a5
        move.l  (a5)+,2(a6)
        beq.s   fidepa
        move.l  a5,10(a6)
        bra.s   etmid
fidepa: subq.w  #1,14(a6)
        ble.s   fmor
        move.l  6(a6),10(a6)
        bra.s   fipatt
fmor:   move.b  #1,(a6)
        addq.l  #2,(a7)
        rts
carmid: clr.w   d0
        move.l  2(a6),a5
        move.b  (a5)+,d0
        move.l  a5,2(a6)
        rts

tcanb:  lea.l   rcab(pc),a2
        clr.w   d0
        move.b  16(a1),d0
        jmp     0(a2,d0.w)
tcane:  lea.l   rcae(pc),a2
        clr.w   d0
        move.b  53(a1),d0
        jmp     0(a2,d0.w)
porta:  tst.b   68(a1)
        beq.s   affcan
        move.w  70(a1),d2
        add.w   d2,34(a1)
        subq.b  #1,69(a1)
        bgt.s   affcan
        move.b  84(a3),69(a1)
        move.w  72(a1),d2
        add.w   d2,70(a1)
        bne.s   affcan
        clr.b   68(a1)
affcan: btst    #6,37(a3)
        beq.s   pitch1
        move.l  tapres(pc),a5
        clr.w   d2
        move.b  24(a3),d2
        subq.w  #1,d2
        mulu    #90,d2
        move.b  88(a5,d2.w),d2
        ext.w   d2
        add.w   d2,34(a1)
pitch1: 
        move.w  34(a1),d2
        clr.w   d3
        move.b  26(a3),d3
        lsl.w   #1,d3
        sub.w   d3,d2
        move.l  ptech(pc),a5
        clr.w   d3
        move.b  25(a3),d3
        move.b  32(a3),d4
        cmp.b   6(a3,d1.w),d4
        ble.s   trnorx
        move.b  31(a3),d3
trnorx: 
        mulu    #12,d3
        clr.w   d4
        move.b  4(a5,d3.w),d4
        add.w   d4,d2
        bge.s   sup72
        clr.w   d2
        bra.s   fsup72
sup72:  cmp.w   #72,d2
        ble.s   fsup72
        move.w  #72,d2
fsup72: lea.l   rap14(pc),a5
        move.w  d2,74(a1)
        move.b  0(a5,d2.w),d2
        add.w   76(a1),d2
        add.w   78(a1),d2
        bge.s   sup225
        clr.w   d2
        bra.s   fsup225
sup225: cmp.w   #225,d2
        ble.s   fsup225
        move.w  #225,d2
fsup225:
        lea.l   tvitn(pc),a5
        lsl.w   #1,d1
        move.w  d2,0(a5,d1.w)
        rts
rcab:   bra     tcane
        bra     att_b
        bra     dec_b
        bra     sub_b
        bra     are_b
        bra     rel_b
rcae:   bra     porta
        bra     del_e
        bra     pen_e
        bra     nor_e
        bra     mol_e
fermet: move.b  11(a1),d7
        lsl.w   #8,d7
        move.b  d1,d7
        clr.b   (a1)
        cmp.w   68(a3),d7
        beq.s   ferm4
        cmp.w   94(a3),d7
        beq.s   ferm3
        cmp.w   92(a3),d7
        beq.s   ferm2
        move.w  92(a3),90(a3)
ferm2:  move.w  94(a3),92(a3)
ferm3:  move.w  68(a3),94(a3)
ferm4:  clr.w   68(a3)
        lea.l   prior(pc),a5
        cmp.b   14(a5),d1
        beq.s   ferp4
        cmp.b   10(a5),d1
        beq.s   ferp3
        cmp.b   6(a5),d1
        beq.s   ferp2
        move.l  4(a5),(a5)
ferp2:  move.l  8(a5),4(a5)
ferp3:  move.l  12(a5),8(a5)
ferp4:  clr.l   12(a5)
        move.b  d1,14(a5)
        rts
att_b:  move.b  17(a1),d7
        ext.w   d7
        add.w   d7,34(a1)
        subq.w  #1,20(a1)
        bne     tcane               
        move.w  18(a1),20(a1)
        move.b  22(a1),d2
        add.b   d2,17(a1)
        move.b  17(a1),d3
        ext.w   d3
        cmp.b   23(a1),d3
        bne     tcane
        move.b  #8,16(a1)
        move.b  #1,22(a1)
        move.b  15(a3),d2
        ext.w   d2
        asl.w   #1,d2
        add.w   d2,d3
        move.b  d3,23(a1)
        tst.w   d2
        bgt.s   atb0
        beq.s   atb1
        move.b  #-1,22(a1)
        neg.w   d2
atb0:   cmp.w   16(a3),d2
        bgt.s   atb2
        clr.l   d3
        move.w  16(a3),d3
        divu    d2,d3
        move.w  d3,18(a1)
        move.w  d3,20(a1)
        bra     tcane
atb1:   clr.b   22(a1)
        move.w  16(a3),18(a1)
        move.w  16(a3),20(a1)
        bra     tcane
atb2:   move.l  #$00010001,18(a1)
        ext.l   d2
        tst.w   16(a3)
        beq.s   atb3
        divu    16(a3),d2
        tst.b   22(a1)
        blt.s   atb4
        move.b  d2,22(a1)
        swap    d2
        clr.w   d3
        move.b  17(a1),d3
        add.w   d2,d3
        move.b  d3,17(a1)
        bra     tcane
atb3:   move.b  23(a1),17(a1)
        clr.b   22(a1)
        bra     tcane
atb4:   neg.b   d2
        move.b  d2,22(a1)
        swap    d2
        clr.w   d3
        move.b  17(a1),d3
        sub.w   d2,d3
        move.b  d3,17(a1)
        bra     tcane
are_b:  move.b  17(a1),d7
        ext.w   d7
        add.w   d7,34(a1)
        bra     tcane               
dec_b:  move.b  17(a1),d7
        ext.w   d7
        add.w   d7,34(a1)
        subq.w  #1,20(a1)
        bne     tcane               
        move.w  18(a1),20(a1)
        move.b  22(a1),d2
        add.b   d2,17(a1)
        move.b  17(a1),d3
        ext.w   d3
        cmp.b   23(a1),d3
        bne     tcane
soncot: move.b  #12,16(a1)
        move.b  #1,22(a1)
        move.b  20(a3),d2
        ext.w   d2
        asl.w   #1,d2
        add.w   d2,d3
        move.b  d3,23(a1)
        tst.w   d2
        bgt.s   deb0
        beq.s   deb1
        move.b  #-1,22(a1)
        neg.w   d2
deb0:   cmp.w   18(a3),d2
        bgt.s   deb2
        clr.l   d3
        move.w  18(a3),d3
        divu    d2,d3
        move.w  d3,18(a1)
        move.w  d3,20(a1)
        bra     tcane
deb1:   clr.b   22(a1)
        move.w  18(a3),18(a1)
        move.w  18(a3),20(a1)
        bra     tcane
deb2:   move.l  #$00010001,18(a1)
        ext.l   d2
        divu    18(a3),d2
        tst.b   22(a1)
        blt.s   deb4
        move.b  d2,22(a1)
        swap    d2
        clr.w   d3
        move.b  17(a1),d3
        add.w   d2,d3
        move.b  d3,17(a1)
        bra     tcane
deb4:   neg.b   d2
        move.b  d2,22(a1)
        swap    d2
        clr.w   d3
        move.b  17(a1),d3
        sub.w   d2,d3
        move.b  d3,17(a1)
        bra     tcane
sub_b:  move.b  17(a1),d7
        ext.w   d7
        add.w   d7,34(a1)
        subq.w  #1,20(a1)
        bne     tcane               
        move.w  18(a1),20(a1)
        move.b  22(a1),d2
        add.b   d2,17(a1)
        move.b  17(a1),d3
        cmp.b   23(a1),d3
        bne     tcane
        move.b  #16,16(a1)
        bra     tcane
rel_b:  move.b  17(a1),d7
        ext.w   d7
        add.w   d7,34(a1)
        subq.w  #1,20(a1)
        bne     tcane               
        move.w  18(a1),20(a1)
        move.b  22(a1),d2
        add.b   d2,17(a1)
        move.b  17(a1),d3
        cmp.b   23(a1),d3
        bne     tcane
        move.b  #16,16(a1)
        bra     tcane
del_e:  subq.w  #1,48(a1)
        bgt     porta
        move.w  64(a3),48(a1)
        move.b  66(a3),52(a1)
        move.b  #-1,56(a1)
        move.b  58(a3),50(a1)
        beq.s   dele0
        move.b  #8,53(a1)
        move.b  #1,54(a1)
        move.b  #1,51(a1)
        move.b  #0,57(a1)
        bra     porta
dele0:  move.b  #12,53(a1)
        move.b  60(a3),54(a1)
        clr.w   d2
        move.b  60(a3),d2
        ror.w   #1,d2
        move.b  d2,51(a1)
        move.b  d2,57(a1)
        tst.w   d2
        bge.s   paraj6
        addq.b  #1,51(a1)
paraj6: neg.b   57(a1)
        bra     porta
pen_e:  clr.w   d2
        move.b  50(a1),d2
        subq.w  #1,d2
        move.b  d2,50(a1)
        tst.w   d2
        bgt.s   nor_e
        move.b  58(a3),50(a1)
        addq.b  #1,54(a1)
        move.b  54(a1),d2
        cmp.b   60(a3),d2
        bne.s   nor_e
        move.b  #12,53(a1)
nor_e:  move.b  51(a1),d2
        ext.w   d2
        move.w  d2,76(a1)
        subq.w  #1,48(a1)
        ble.s   nore0
        subq.b  #1,52(a1)
        bgt     porta
        move.b  66(a3),52(a1)
        move.b  51(a1),d2
        cmp.b   57(a1),d2
        beq     porta
        move.b  56(a1),d2
        add.b   d2,51(a1)
        bra     porta
nore0:  clr.w   d2
        move.b  54(a1),d2
        ror.w   #1,d2
        move.b  d2,51(a1)
        move.b  d2,57(a1)
        neg.b   56(a1)
        bgt.s   nore1
        move.w  64(a3),48(a1)
        tst.w   d2
        bge.s   paraj7
        addq.b  #1,51(a1)
paraj7: neg.b   57(a1)
        bra     porta
nore1:  move.w  62(a3),48(a1)
        tst.w   d2
        bge.s   paraj8
        addq.b  #1,57(a1)
paraj8: neg.b   51(a1)
        bra     porta
mol_e:  move.l  tapres(pc),a2
        clr.w   d2
        move.b  24(a3),d2
        subq.w  #1,d2
        mulu    #90,d2
        move.b  89(a2,d2.w),d2
        beq.s   mole0
        lsr.b   #3,d2
        move.b  d2,54(a1)
        bra     nor_e
mole0:  clr.l   48(a1)
        bra     porta

aoub:   lea.l   prior(pc),a5
        tst.b   12(a5)
        beq     pasdel
        lea.l   prior+12(pc),a4
        move.w  nbcan(pc),d0
        subq.w  #1,d0
baoub:  tst.b   3(a4)
        bge.s   saoub
        lea.l   -4(a4),a4
        dbf     d0,baoub
        tst.b   typri
        bne.s   s1aoub
        rts
saoub:  move.l  12(a5),d0
        move.l  (a4),12(a5)
        move.l  d0,(a4)
s1aoub: moveq   #0,d0
        move.b  13(a5),d0
        mulu    #100,d0
        move.l  tabson(pc),a4
        add.l   d0,a4
        move.b  14(a5),d1
        cmp.b   91(a4),d1
        beq.s   ferm1b
        cmp.b   93(a4),d1
        beq.s   ferm2b
        cmp.b   95(a4),d1
        beq.s   ferm3b
        bra.s   ferm4b
ferm1b: move.w  92(a4),90(a4)
ferm2b: move.w  94(a4),92(a4)
ferm3b: move.w  68(a4),94(a4)
ferm4b: clr.w   68(a4)
;  ************* modif
pasdel: 
        move.b  14(a5),d1
        move.w  nbcan(pc),d0
        cmp.w   #1,d0
        beq.s   spadel
        move.l  8(a5),12(a5)
        cmp.w   #2,d0
        beq.s   spadel
        move.l  4(a5),8(a5)
        cmp.w   #3,d0
        beq.s   spadel
        move.l  (a5),4(a5)
spadel: subq.w  #1,d0
        eor.w   #$3,d0
        lsl.w   #2,d0
        move.b  d1,2(a5,d0.w)
        move.b  notmid,0(a5,d0.w)
        move.b  nosonb,1(a5,d0.w)
        move.b  typri(pc),3(a5,d0.w)
        bsr     creanot
        rts
trainot:
        move.b  notmid,d0
        lsl.b   #1,d0
        move.b  d0,note
        clr.b   tenue

        lea.l   prior(pc),a5
        move.w  nbcan(pc),d1
        move.w  #4,d0
        sub.w   d1,d0
        lsl.w   #2,d0
        add.w   d0,a5
        subq.w  #1,d1
        move.b  nosonb,d0
breten: tst.b   (a5)
        beq.s   ptenu
        tst.b   3(a5)
        bgt.s   ptenu
        cmp.b   1(a5),d0
        bne.s   sreten
        move.b  2(a5),d0
        lsl.b   #2,d0
        lea.l   adcan(pc),a2
        move.l  0(a2,d0.w),a2
        move.b  #1,tenue
        bra.s   ptenu
sreten: lea.l   4(a5),a5
        dbf     d1,breten
ptenu:  clr.w   d1
        cmp.b   #1,39(a3)
        bgt.L   tmono
        beq.s   tduo
        bsr     aoub
        rts
tduo:   tst.b   92(a3)
        beq     aoub1
        move.b  93(a3),d1
        bsr     mulvo
        clr.w   92(a3)
        bsr     creanot
        rts
mulvo:  lea.l   prior(pc),a5
        move.w  nbcan(pc),d0
        cmp.b   2(a5),d1
        beq.s   pcan
        cmp.b   6(a5),d1
        beq.s   dcan
        cmp.b   10(a5),d1
        beq.s   tcan
        cmp.w   #1,d0
        beq.s   pcan
        move.l  8(a5),12(a5)
tcan:   cmp.w   #2,d0
        beq.s   pcan
        move.l  4(a5),8(a5)
dcan:   cmp.w   #3,d0
        beq.s   pcan
        move.l  (a5),4(a5)
pcan:   subq.w  #1,d0
        eor.w   #$3,d0
        lsl.w   #2,d0
        move.b  d1,2(a5,d0.w)
        move.b  notmid,0(a5,d0.w)
        move.b  nosonb,1(a5,d0.w)
        move.b  typri(pc),3(a5,d0.w)
        rts
tmono:  cmp.b   #3,39(a3)
        beq.s   mono2
        bgt     mono3
        tst.b   90(a3)
        beq     aoub1
        move.b  91(a3),d1
        bsr     mulvo
        clr.w   90(a3)
        bsr     creanot
        rts
mono2:  tst.b   92(a3)
        beq     tunvoi
        move.b  93(a3),d1
        bsr     mulvo
        clr.w   92(a3)
        clr.w   d2
        move.b  note,d2
        move.b  note,noteb
        clr.w   d3
        move.b  40(a3),d3
        add.w   d3,d2
        move.b  d2,note
        bsr     creanot
        move.b  noteb,note
        move.b  86(a3),d2
        ext.w   d2
        move.w  d2,78(a1)
        move.b  93(a3),d1
        bsr     mulvo
        clr.w   92(a3)
        bsr     creanot
        rts
tunvoi: tst.b   90(a3)
        beq     paunvo
        move.b  91(a3),d1
        bsr     mulvo
        clr.w   90(a3)
        clr.w   d2
        move.b  note,d2
        move.b  note,noteb
        clr.w   d3
        move.b  40(a3),d3
        add.w   d3,d2
        move.b  d2,note
        bsr     creanot
        move.b  noteb,note
        move.b  86(a3),d2
        ext.w   d2
        move.w  d2,78(a1)
        bsr     aoub
        rts
paunvo: clr.w   d2
        move.b  note,d2
        move.b  note,noteb
        clr.w   d3
        move.b  40(a3),d3
        add.w   d3,d2
        move.b  d2,note
        bsr     aoub
        move.b  noteb,note
        move.b  86(a3),d2
        ext.w   d2
        move.w  d2,78(a1)
        bsr     aoub
        rts
mono3:  clr.w   d2
        move.b  note,d2
        move.b  note,noteb
        clr.w   d3
        move.b  41(a3),d3
        add.w   d3,d2
        move.b  d2,note
        bsr     aoub
        move.b  noteb,note
        move.b  87(a3),d2
        ext.w   d2
        move.w  d2,78(a1)
        clr.w   d2
        move.b  note,d2
        move.b  note,noteb
        clr.w   d3
        move.b  40(a3),d3
        add.w   d3,d2
        move.b  d2,note
        bsr     aoub
        move.b  noteb,note
        move.b  86(a3),d2
        ext.w   d2
        move.w  d2,78(a1)
        bsr     aoub
        rts
aoub1:  bsr     aoub
        rts
creanot:
        clr.w   d0
        move.b  d1,d0
        move.b  veloc1(pc),6(a3,d0.w)
        lsl.w   #2,d0
        lea.l   adcan(pc),a1
        move.l  0(a1,d0.w),a1
        move.b  #1,(a1)
s1crea: move.l  a3,12(a1)
        move.b  notmid,11(a1)
        move.b  note,37(a1)
        btst    #1,38(a3)
        bne.s   freac
        clr.b   16(a1)
        bra     tmovo
freac:  btst    #1,37(a3)
        beq.s   ptenu1
        tst.b   tenue
        beq.s   ptenu1
        move.l  16(a2),16(a1)
        move.l  20(a2),20(a1)
        bra     tmovo
ptenu1: move.b  #4,16(a1)
        clr.b   17(a1)
        move.b  #1,22(a1)
        move.b  14(a3),d2
        ext.w   d2
        asl.w   #1,d2
        move.b  d2,23(a1)
        bgt.s   afb0
        beq.s   afb1
        move.b  #-1,22(a1)
        neg.w   d2
afb0:   cmp.w   12(a3),d2
        bgt.s   afb2
        clr.l   d3
        move.w  12(a3),d3
        divu    d2,d3
        move.w  d3,18(a1)
        move.w  d3,20(a1)
        bra.s   tmovo
afb1:   clr.b   22(a1)
        move.w  12(a3),18(a1)
        move.w  12(a3),20(a1)
        bra.s   tmovo
afb2:   move.l  #$00010001,18(a1)
        ext.l   d2
        tst.w   12(a3)
        beq.s   afb3
        divu    12(a3),d2
        tst.b   22(a1)
        blt.s   afb4
        move.b  d2,22(a1)
        swap    d2
        move.b  d2,17(a1)
        bra.s   tmovo
afb3:   move.b  23(a1),17(a1)
        clr.b   22(a1)
        bra.s   tmovo
afb4:   neg.b   d2
        move.b  d2,22(a1)
        swap    d2
        move.b  d2,17(a1)
tmovo:  btst    #4,38(a3)
        bne.s   mofra
        clr.b   53(a1)
        bra.s   s2crea
mofra:  btst    #4,37(a3)
        beq.s   ptenu4
        tst.b   tenue
        beq.s   ptenu4
        move.l  48(a2),48(a1)
        move.l  52(a2),52(a1)
        move.w  56(a2),56(a1)
        bra.s   s2crea
ptenu4: tst.b   61(a3)
        bne.s   mole1
        move.w  56(a3),48(a1)
        move.b  #4,53(a1)
        bra.s   s2crea
mole1:  clr.l   48(a1)
        move.b  #16,53(a1)
        move.b  #1,56(a1)
s2crea: 
        clr.b   68(a1)
        tst.b   55(a3)
        beq     paport
        btst    #7,42(a3)
        beq.s   poratt
        clr.w   d2
        move.b  nocan,d2
        lsl.w   #2,d2
        lea.l   soncan(pc),a5
        move.l  0(a5,d2.w),a5
        tst.b   89(a5)        
        beq     paport
        bra.s   afport
poratt: cmp.b   #1,70(a3)
        bgt.s   porten
        btst    #5,42(a3)
        beq     paport
        bra.s   afport
porten: btst    #6,42(a3)
        beq     paport
afport: move.b  84(a3),69(a1)
        clr.l   d2
        move.b  39(a3),d2
        subq.b  #2,d2
        bge.s   mono2b
        neg.b   d2
        cmp.b   #2,d2
        bne.s   mono2b
        move.b  #3,d2
mono2b: clr.l   70(a1)
        move.b  96(a3,d2.w),71(a1)
        bne.s   portco
        move.b  note(pc),71(a1)
        sub.b   #12,71(a1)
        bge.s   portco
        clr.b   71(a1)
portco: move.b  note,d2
        sub.w   70(a1),d2
        beq     paport
        blt.s   desport
        move.w  d2,70(a1)
        move.b  85(a3),73(a1)
        clr.l   d3
        move.b  85(a3),d3
        divu    d3,d2
        tst.w   d2
        beq.s   paport
        swap    d2
        sub.w   d2,70(a1)
        move.b  #1,68(a1)
        neg.w   70(a1)
        bra.s   paport
desport:
        neg.w   d2
        move.w  d2,70(a1)
        move.b  85(a3),73(a1)
        clr.l   d3
        move.b  85(a3),d3
        divu    d3,d2
        tst.w   d2
        beq.s   paport
        swap    d2
        sub.w   d2,70(a1)
        move.b  #1,68(a1)
        neg.w   72(a1)
paport: clr.l   74(a1)
        clr.w   78(a1)
        move.b  98(a3),99(a3)
        move.b  97(a3),98(a3)
        move.b  96(a3),97(a3)
        move.b  note,96(a3)
        move.w  94(a3),68(a3)
        move.w  92(a3),94(a3)
        move.w  90(a3),92(a3)
        move.b  notmid,90(a3)
        move.b  d1,91(a3)
; ******* 
        lea.l   tferm(pc),a4
        move.b  #3,0(a4,d1.w)
        rts

notof1: bsr     carmid
        move.b  d0,notmid
        lea.l   soncan(pc),a3
        clr.w   d2
        move.b  nocan,d2
        lsl.w   #2,d2
        move.l  0(a3,d2.w),a3
        move.b  notmid,d2
        move.b  0(a3,d2.w),d2
        cmp.b   #-1,d2
        beq     etmid
papia2: mulu    #100,d2
        move.l  tabson(pc),a3
        add.l   d2,a3
        subq.b  #1,70(a3)
        btst    #4,42(a3)
        beq     notnorm
        lea.l   arpeg1(pc),a5
        cmp.b   #2,47(a3)
        bne.s   bienpo
        lea.l   arpeg2(pc),a5
bienpo: move.b  notmid,d2
        lea.l   2(a5),a1
        clr.w   d3
        move.b  12(a5),d3
        ble     etmid
        subq.b  #1,d3
        move.b  d3,d1
befno:  cmp.b   (a1)+,d2
        bne.s   nopatr
        sub.b   d3,d1
        cmp.b   10(a5),d1
        bge.s   notrou1
        subq.b  #1,10(a5)
        bra.s   notrou1
nopatr: dbf     d3,befno
        bra     etmid
notrou: move.b  (a1),-1(a1)
        addq.l  #1,a1
notrou1:
        dbf     d3,notrou
        move.b  #127,-1(a1)
        subq.b  #1,12(a5)
        bgt     etmid
        clr.b   (a5)
        clr.b   47(a3)
        bra     etmid
notnorm:
        move.b  notmid,d5
        cmp.b   90(a3),d5
        bne.s   noex1
        move.b  91(a3),d1
        bsr     arelea
noex1:  cmp.b   92(a3),d5
        bne.s   noex2
        move.b  93(a3),d1
        bsr     arelea
noex2:  cmp.b   94(a3),d5
        bne.s   noex3
        move.b  95(a3),d1
        bsr     arelea
noex3:  cmp.b   68(a3),d5
        bne     etmid
        move.b  69(a3),d1
        bsr     arelea
        bra     etmid
arelea: 
        lea.l   prior(pc),a5
        move.w  #2,d2
bcld2:  cmp.b   2(a5),d1
        bne.s   sbcld2
        move.b  #1,3(a5)
        move.l  (a5),d3
        lea.l   4(a5),a5
        bra.s   s2bcld2
sbcld2: lea.l   4(a5),a5
        dbf     d2,bcld2
        bra.s   fbcld2
s2bcld2:
        tst.w   (a5)
        beq.s   s3bcld2
        tst.b   3(a5)
        bgt.s   s3bcld2
        move.l  (a5),-4(a5)
        lea.l   4(a5),a5
        dbf     d2,s2bcld2
s3bcld2:
        move.l  d3,-4(a5)
fbcld2:
        ext.w   d1
        move.w  d1,d2
        lsl.b   #2,d2
        lea.l   adcan(pc),a1
        move.l  0(a1,d2.w),a1
sub_bb: tst.b   16(a1)
        beq     sub_cb
arnd1:  move.b  #20,16(a1)
        move.b  #1,22(a1)
        move.b  21(a3),d2
        move.b  17(a1),d3
        ext.w   d2
        ext.w   d3
        asl.w   #1,d2
        add.w   d2,d3
        move.b  d3,23(a1)
        tst.w   d2
        bgt.s   sb0b
        beq.s   sb1b
        move.b  #-1,22(a1)
        neg.w   d2
sb0b:   cmp.w   22(a3),d2
        bgt.s   sb2b
        clr.l   d3
        move.w  22(a3),d3
        divu    d2,d3
        move.w  d3,18(a1)
        move.w  d3,20(a1)
        bra     sub_cb
sb1b:   clr.b   22(a1)
        move.w  22(a3),18(a1)
        move.w  22(a3),20(a1)
        bra     sub_cb
sb2b:   move.l  #$00010001,18(a1)
        ext.l   d2
        tst.w   22(a3)
        beq.s   sb3b
        divu    22(a3),d2
        tst.b   22(a1)
        blt.s   sb4b
        move.b  d2,22(a1)
        swap    d2
        clr.w   d3
        move.b  17(a1),d3
        add.w   d2,d3
        move.b  d3,17(a1)
        bra.s   sub_cb
sb3b:   move.b  23(a1),17(a1)
        clr.b   22(a1)
        bra.s   sub_cb
sb4b:   neg.b   d2
        move.b  d2,22(a1)
        swap    d2
        clr.w   d3
        move.b  17(a1),d3
        sub.w   d2,d3
        move.b  d3,17(a1)
sub_cb: 
        cmp.b   #4,29(a3)
        bne.s   ofnor
        move.l  #$200,a4
        move.w  d1,d3
        mulu    #12,d3
        add.w   d3,a4
        move.l  ptech(pc),a0
        clr.w   d2
        move.b  25(a3),d2
        mulu    #12,d2
        add.l   d2,a0
        or.w    #$700,sr
        move.l  (a4),d2
        beq.s   fisub2
        sub.l   echan(pc),d2
        cmp.l   8(a0),d2
        blt.s   notopp
        move.l  20(a0),(a4)
        add.l  #echanb,(a4)
;        move.l  echan(pc),d2
;        add.l   d2,(a4)
        bra.s   fisub2
notopp: 
        move.l  16(a0),d2
        add.l   echan(pc),d2
        and.l   #$ffffff,d2
        move.l  d2,(a4)
        move.l  20(a0),4(a4)
        add.l  #echanb,4(a4)
;        move.l  echan(pc),d2
;        add.l   d2,4(a4)
fisub2: and.w   #$f5ff,sr
        rts
ofnor:  move.b  6(a3,d1.w),d2
        cmp.b   32(a3),d2
        blt     deuech
        move.l  ptech(pc),a0
        clr.w   d2
        move.b  25(a3),d2
        mulu    #12,d2
        add.l   d2,a0
        cmp.b   #1,29(a3)
        beq.s   subcl
        blt.s   fisub
        move.l  #$200,a4
        move.w  d1,d3
        mulu    #12,d3
        clr.l   0(a4,d3.w)
fisub:  rts
subcl:  lea.l   bform(pc),a2
        move.l  #$200,a4
        move.w  d1,d3
        mulu    #12,d3
        add.l   d3,a4
        clr.w   d2
        move.b  30(a3),d2
        lsl.w   #1,d2
        add.w   d2,a2
        clr.w   d2
        move.b  (a2)+,d2
        blt.s   fsubc
        lsl.w   #2,d2
        move.l  0(a0,d2.w),d3
        and.l   #$ffffff,d3
        add.l   echan(pc),d3
        or.w    #$700,sr
        move.l  d3,(a4)+
fsubc:  clr.l   (a4)
        and.w   #$f5ff,sr
        rts
deuech: move.l  ptech(pc),a0
        clr.w   d2
        move.b  31(a3),d2
        mulu    #12,d2
        add.l   d2,a0
        cmp.b   #1,33(a3)
        beq.s   subcl2
        blt.s   fisub3
        move.l  #$200,a4
        move.w  d1,d3
        mulu    #12,d3
        clr.l   0(a4,d3.w)
fisub3: rts
subcl2: lea.l   bform(pc),a2
        move.l  #$200,a4
        move.w  d1,d3
        mulu    #12,d3
        add.l   d3,a4
        clr.w   d2
        move.b  34(a3),d2
        lsl.w   #1,d2
        add.w   d2,a2
        clr.w   d2
        move.b  (a2)+,d2
        blt.s   fsubc2
        lsl.w   #2,d2
        move.l  0(a0,d2.w),d3
        and.l   #$ffffff,d3
        add.l   echan(pc),d3
        or.w    #$700,sr
        move.l  d3,(a4)+
fsubc2: clr.l   (a4)
        and.w   #$f5ff,sr
        rts
; ***********  prepa timer
pretim: lea.l   $fffffa01.w,a4
        or.w    #$700,sr
        move.l  tabson(pc),a3
        move.w  #255,d0
bef1w:   clr.l   88(a3)
        clr.l   92(a3)
        clr.l   96(a3)
        clr.l   68(a3)
        lea.l   100(a3),a3
        dbf     d0,bef1w

        lea.l   prior,a3
        clr.l   (a3)
        clr.l   4(a3)
        clr.l   8(a3)
        clr.l   12(a3)
        move.b  #3,2(a3)
        move.b  #2,6(a3)
        move.b  #1,10(a3)
        move.l  #-1,tvita
        move.l  #-1,tvita+4
        move.w  #-1,ancplr
        clr.l   $94
        lea.l   canal,a3
        move.w  #19,d0
bef2w:   clr.l   (a3)+
        clr.l   (a3)+
        clr.l   (a3)+
        clr.l   (a3)+
        dbf     d0,bef2w
        cmp.w   #3,nbcan
        beq.s   p3c
        bgt.s   p4c
        cmp.w   #1,nbcan
        bgt.s   p2c
        bra.s   p1c
p4c:    clr.b   26(a4)
        bset    #0,6(a4)
        bset    #0,18(a4)
p3c:    and.b   #$f,28(a4)
        bset    #5,8(a4)
        bset    #5,20(a4)
p2c:    and.b   #$f0,28(a4)
        bset    #4,8(a4)
        bset    #4,20(a4)
p1c:    clr.b   24(a4)
        bset    #5,6(a4)
        bset    #5,18(a4)
        and.w   #$f3ff,sr
        clr.l   $b0.w
        rts
; ****************  mep timer + lecture

creag:  move.l  #routiag,$134.w
        move.l  #routiag+6,$230.w
        move.b  nadd(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addag
        bra.s   crea
creap:  move.l  #routiap,$134.w
        move.l  #routiap+2,$230.w
        move.b  nadd(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addap 
crea:   cmp.w   #$166,d2
        bne.s   pad31
        tst.b   $b0.w
        bne.s   exd31
        bset    #0,$b0.w
        bra.s   pad31
exd31:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        clr.w   2(a4,d3.w)
        rts
pad31:  or.w    #$700,sr
        move.b  #0,24(a4)
        move.b  1(a3,d2.w),30(a4)
        move.b  0(a3,d2.w),24(a4)
        and.w   #$f5ff,sr
        rts
crebg:  move.l  #routibg,$120.w
        move.l  #routibg+6,$23c.w
        move.b  nadd+3(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addbg 
        bra.s   creb
crebp:  move.l  #routibp,$120.w
        move.l  #routibp+2,$23c.w
        move.b  nadd+3(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addbp  
creb:   cmp.w   #$166,d2
        bne.s   pad32
        tst.b   $b0.w
        bne.s   exd32
        bset    #3,$b0.w
        bra.s   pad32
exd32:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        move.w  #12,2(a4,d3.w)
        rts
pad32:  or.w    #$700,sr
        move.b  #0,26(a4)
        move.b  1(a3,d2.w),32(a4)
        move.b  0(a3,d2.w),26(a4)
        and.w   #$f5ff,sr
        rts
crecg:  move.l  #routicg,$114.w
        move.l  #routicg+6,$238.w
        move.b  nadd+2(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addcg 
        bra.s   crec
crecp:  move.l  #routicp,$114.w
        move.l  #routicp+2,$238.w
        move.b  nadd+2(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addcp  
crec:   cmp.w   #$166,d2
        bne.s   pad33
        tst.b   $b0.w
        bne.s   exd33
        bset    #2,$b0.w
        bra.s   pad33
exd33:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        move.w  #8,2(a4,d3.w)
        rts
pad33:  move.b  0(a3,d2.w),d3
        lsl.b   #4,d3
        or.w    #$700,sr
        and.b   #$f,28(a4)
        move.b  1(a3,d2.w),34(a4)
        or.b    d3,28(a4)
        and.w   #$f5ff,sr
        rts
credg:  move.l  #routidg,$110.w
        move.l  #routidg+6,$234.w
        move.b  nadd+1(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,adddg 
        bra.s   cred
credp:  move.l  #routidp,$110.w
        move.l  #routidp+2,$234.w
        move.b  nadd+1(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,adddp  
cred:   cmp.w   #$166,d2
        bne.s   pad34
        tst.b   $b0.w
        bne.s   exd34
        bset    #1,$b0.w
        bra.s   pad34
exd34:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        move.w  #4,2(a4,d3.w)
        rts
pad34:  or.w    #$700,sr
        and.b   #$f0,28(a4)
        move.b  1(a3,d2.w),36(a4)
        move.b  0(a3,d2.w),d2
        or.b    d2,28(a4)
        and.w   #$f5ff,sr
        rts
modua: 
        move.b  nadd(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addap
        move.b  d3,addag
        move.w  0(a3,d2.w),$a8.w
        move.l  $134.w,$98.w
        move.l  #imoda,$134.w
        rts
modub:  
        move.b  nadd+3(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addbp
        move.b  d3,addbg
        move.w  0(a3,d2.w),$aa.w
        move.l  $120.w,$9c.w
        move.l  #imodb,$120.w
        rts 
moduc:  
        move.b  nadd+2(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addcp
        move.b  d3,addcg
        move.b  1(a3,d2.w),$ad.w
        move.b  0(a3,d2.w),d3
        lsl.b   #4,d3
        move.b  d3,$ac.w
        move.l  $114.w,$a0.w
        move.l  #imodc,$114.w
        rts
modud: 
        move.b  nadd+1(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,adddp
        move.b  d3,adddg
        move.w  0(a3,d2.w),$ae.w
        move.l  $110.w,$a4.w
        move.l  #imodd,$110.w
        rts
modua1: 
        move.b  nadd(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addap
        move.l  routiag+6(pc),routiap+2
        move.l  #routiap+2,$230.w
        move.l  #routiap,$134.w
        cmp.w   #$166,d2
        bne.s   pad35
        tst.b   $b0.w
        bne.s   exd35
        bset    #0,$b0.w
        bra.s   pad35
exd35:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        clr.w   2(a4,d3.w)
        rts
pad35:  or.w    #$700,sr 
        move.b  #0,24(a4)
        move.b  1(a3,d2.w),30(a4)
        move.b  0(a3,d2.w),24(a4)
        and.w   #$f5ff,sr
        rts
modub1: 
        move.b  nadd+3(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addbp
        move.l  routibg+6(pc),routibp+2
        move.l  #routibp+2,$23c.w
        move.l  #routibp,$120.w
        cmp.w   #$166,d2
        bne.s   pad36
        tst.b   $b0.w
        bne.s   exd36
        bset    #3,$b0.w
        bra.s   pad36
exd36:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        move.w  #12,2(a4,d3.w)
        rts
pad36:  or.w    #$700,sr 
        move.b  #0,26(a4)
        move.b  1(a3,d2.w),32(a4)
        move.b  0(a3,d2.w),26(a4)
        and.w   #$f5ff,sr
        rts 
moduc1: 
        move.b  nadd+2(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addcp
        move.l  routicg+6(pc),routicp+2
        move.l  #routicp+2,$238.w
        move.l  #routicp,$114.w
        cmp.w   #$166,d2
        bne.s   pad37
        tst.b   $b0.w
        bne.s   exd37
        bset    #2,$b0.w
        bra.s   pad37
exd37:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        move.w  #8,2(a4,d3.w)
        rts
pad37:  or.w    #$700,sr 
        and.b   #$f,28(a4)
        move.b  1(a3,d2.w),34(a4)
        move.b  0(a3,d2.w),d2
        lsl.b   #4,d2
        or.b    d2,28(a4)
        and.w   #$f5ff,sr
        rts
modud1: 
        move.b  nadd+1(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,adddp
        move.l  routidg+6(pc),routidp+2
        move.l  #routidp+2,$234.w
        move.l  #routidp,$110.w
        cmp.w   #$166,d2
        bne.s   pad38
        tst.b   $b0.w
        bne.s   exd38
        bset    #1,$b0.w
        bra.s   pad38
exd38:  move.w  $b2.w,d3
        addq.w  #1,$b2.w
        lsl.w   #2,d3
        lea.l   anter(pc),a4
        move.w  0(a3,d2.w),0(a4,d3.w)
        move.w  #4,2(a4,d3.w)
        rts
pad38:  or.w    #$700,sr 
        and.b   #$f0,28(a4)
        move.b  1(a3,d2.w),36(a4)
        move.b  0(a3,d2.w),d2
        or.b    d2,28(a4)
        and.w   #$f5ff,sr
        rts
modua2: 
        move.b  nadd(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addag
        move.l  #$94,a2
        or.w    #$700,sr
        tst.b   0(a2,d1.w)
        beq.s   smoda1
        move.l  #routiat,$98.w
        move.b  #2,0(a2,d1.w)
        bra.s   rmodua
smoda1: move.l  routiap+2(pc),routiag+6
        move.l  #routiag,$98.w
        move.l  #routiag+6,$230.w
rmodua: move.w  0(a3,d2.w),$a8.w
        move.l  #imoda,$134.w
        and.w   #$f5ff,sr
        rts
modub2: 
        move.b  nadd+3(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addbg
        move.l  #$94,a2
        or.w    #$700,sr
        tst.b   0(a2,d1.w)
        beq.s   smodb1
        move.l  #routibt,$9c.w
        move.b  #2,0(a2,d1.w)
        bra.s   rmodub
smodb1: move.l  routibp+2(pc),routibg+6
        move.l  #routibg,$9c.w
        move.l  #routibg+6,$23c.w
rmodub: move.w  0(a3,d2.w),$aa.w
        move.l  #imodb,$120.w
        and.w   #$f5ff,sr
        rts 
moduc2: 
        move.b  nadd+2(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,addcg
        move.l  #$94,a2
        or.w    #$700,sr
        tst.b   0(a2,d1.w)
        beq.s   smodc1
        move.l  #routict,$a0.w
        move.b  #2,0(a2,d1.w)
        bra.s   rmoduc
smodc1: move.l  routicp+2(pc),routicg+6
        move.l  #routicg,$a0.w
        move.l  #routicg+6,$238.w
rmoduc: move.b  1(a3,d2.w),$ad.w
        move.b  0(a3,d2.w),d3
        lsl.b   #4,d3
        move.b  d3,$ac.w
        move.l  #imodc,$114.w
        and.w   #$f5ff,sr
        rts
modud2: 
        move.b  nadd+1(pc),d3
        lsl.b   #1,d3
        add.b   #$52,d3
        move.b  d3,adddg
        move.l  #$94,a2
        or.w    #$700,sr
        tst.b   0(a2,d1.w)
        beq.s   smodd1
        move.l  #routidt,$a4.w
        move.b  #2,0(a2,d1.w)
        bra.s   rmodud
smodd1: move.l  routidp+2(pc),routidg+6
        move.l  #routidg,$a4.w
        move.l  #routidg+6,$234.w
rmodud: move.w  0(a3,d2.w),$ae.w
        move.l  #imodd,$110.w
        and.w   #$f5ff,sr
        rts

imoda:  clr.b   $fffffa19.w
        move.b  $a9.w,$fffffa1f.w
        move.b  $a8.w,$fffffa19.w
        move.l  $98.w,$134.w
        move.l  $98.w,-(a7)
        rts
imodb:  clr.b   $fffffa1b.w
        move.b  $ab.w,$fffffa21.w
        move.b  $aa.w,$fffffa1b.w
        move.l  $9c.w,$120.w
        move.l  $9c.w,-(a7)
        rts
imodc:  and.b   #$f,$fffffa1d.w
        move.b  $ad.w,$fffffa23.w
        move.b  $ac.w,imodce+3
        move.l  $a0.w,$114.w
        move.l  $a0.w,-(a7)
imodce: or.b    #$0000,$fffffa1d.w
        rts
imodd:  and.b   #$f0,$fffffa1d.w
        move.b  $af.w,$fffffa25.w
        move.b  $ae.w,imodde+3
        move.l  $a4.w,$110.w
        move.l  $a4.w,-(a7)
imodde: or.b    #$0000,$fffffa1d.w
        rts
rinitc: lea.l   $fffffa01,a4
        or.w    #$700,sr
        and.b   #$f,28(a4)
        move.l  savtic(pc),$114 
        move.b  #200,34(a4)
        or.b    #$50,28(a4)
        and.w   #$f3ff,sr
        rts
coupa:  
        move.w  sr,savsr
        or.w    #$700,sr
        clr.b   $fffffa19.w
        move.w  #$80,$8c.w
        move.w  savsr(pc),sr
        bclr    #0,$b0.w
        rts
coupb:  
        move.w  sr,savsr
        or.w    #$700,sr
        clr.b   $fffffa1b.w
        move.w  #$80,$92.w
        move.w  savsr(pc),sr
        bclr    #3,$b0.w
        rts
coupc:  
        move.w  sr,savsr
        move.w  #$80,$90.w
        or.w    #$700,sr
        and.b   #$f,$fffffa1d.w
        move.w  savsr(pc),sr
        bclr    #2,$b0.w
        rts
coupd:  
        move.w  sr,savsr
        or.w    #$700,sr
        and.b   #$f0,$fffffa1d.w
        move.w  #$80,$8e.w
        move.w  savsr(pc),sr
        bclr    #1,$b0.w
        rts
savsr:  dc.w    0
; ****************
routiap:
        move.b  $12345678,$8d.w
        beq.s   remtap
addap:  addq.l  #1,routiap+2
        rte
remtap: move.b  #$80,$8d.w
        move.l  $200.w,routiap+2
        beq.s   frouap
        and.w   #$f5ff,sr
        move.l  $204.w,$200.w
        move.l  $208.w,$204.w
        bra.s   routiap
        rte
frouap: 
        clr.b   $fffffa19.w
        move.b  #1,$94.w
        bclr    #0,$b0.w
        rte
routibp:
        move.b  $12345678,$93.w
        beq.s   remtbp
addbp:  addq.l  #1,routibp+2
        rte
remtbp: move.b  #$80,$93.w
        move.l  $224.w,routibp+2
        beq.s   froubp
        and.w   #$f5ff,sr
        move.l  $228.w,$224.w
        move.l  $22c.w,$228.w
        bra.s   routibp
        rte
froubp: 
        clr.b   $fffffa1b.w
        move.b  #1,$97.w
        bclr    #3,$b0.w
        rte
routicp:
        move.b  $12345678,$91.w
        beq.s   remtcp
addcp:  addq.l  #1,routicp+2
        rte
remtcp: move.b  #$80,$91.w
        move.l  $218.w,routicp+2
        beq.s   froucp
        and.w   #$f5ff,sr
        move.l  $21c.w,$218.w
        move.l  $220.w,$21c.w
        bra.s   routicp
        rte
froucp: 
        and.b   #$f,$fffffa1d
        move.b  #1,$96.w
        bclr    #2,$b0.w
        rte
routidp:
        move.b  $12345678,$8f.w
        beq.s   remtdp
adddp:  addq.l  #1,routidp+2
        rte
remtdp: move.b  #$80,$8f.w
        move.l  $20c.w,routidp+2
        beq.s   froudp
        and.w   #$f5ff,sr
        move.l  $210.w,$20c.w
        move.l  $214.w,$210.w
        bra.s   routidp
        rte
froudp: 
        and.b   #$f0,$fffffa1d
        move.b  #1,$95.w
        bclr    #1,$b0.w
        rte
; *******************
routibt:
        move.w  d0,-(sp)
        move.w  $8c.w,d0
        add.w   #$80,d0
        add.w   $8e.w,d0
        add.w   $90.w,d0
        bra     repcom
routict:
        move.w  d0,-(sp)
        move.w  $8c.w,d0
        add.w   #$80,d0
        add.w   $8e.w,d0
        add.w   $92.w,d0
        bra     repcom
routidt:
        move.w  d0,-(sp)
        move.w  $8c.w,d0
        add.w   #$80,d0
        add.w   $90.w,d0
        add.w   $92.w,d0
        bra     repcom
routiat:
        move.w  d0,-(sp)
        move.w  $8e.w,d0
        add.w   #$80,d0
        add.w   $90.w,d0
        add.w   $92.w,d0
        bra     repcom
; *******
routibg:
        move.w  d0,-(sp)
        clr.w   d0
srb:    move.b  $12345678,d0
        beq.s   remtbg
addbg:  addq.l  #1,routibg+6
        add.w   $8c.w,d0
        add.w   $8e.w,d0
        add.w   $90.w,d0
        bra     repcom
remtbg: and.w   #$f5ff,sr
        move.l  $224.w,routibg+6
        beq.s   froubg
        move.l  $228.w,$224.w
        move.l  $22c.w,$228.w
        bra.s   srb
;        move.w  (sp)+,d0
;        rte
froubg: move.b  #2,$97.w
        move.b  #$80,$93.w
        move.l  #routibt,$120.w
        bclr    #3,$b0.w
        move.w  (sp)+,d0
        rte

remtcg: and.w   #$f5ff,sr
        move.l  $218.w,routicg+6
        beq.s   froucg
        addq.l  #1,routicg+6
        move.l  $21c.w,$218.w
        move.l  $220.w,$21c.w
        bra     src
;        move.w  (sp)+,d0
;        rte
froucg: move.b  #2,$96.w
        move.b  #$80,$91.w
        move.l  #routict,$114.w
        bclr    #2,$b0.w
        move.w  (sp)+,d0
        rte

froudg: move.b  #2,$95.w
        move.b  #$80,$8f.w
        move.l  #routidt,$110.w
        bclr    #1,$b0.w
        move.w  (sp)+,d0
        rte
remtdg: and.w   #$f5ff,sr
        move.l  $20c.w,routidg+6
        beq.s   froudg
        move.l  $210.w,$20c.w
        move.l  $214.w,$210.w
        bra.s   srd
;        move.w  (sp)+,d0
;        rte

frouag: move.b  #2,$94.w
        move.b  #$80,$8d.w
        move.l  #routiat,$134.w
        bclr    #0,$b0.w
        move.w  (sp)+,d0
        rte
remtag: and.w   #$f5ff,sr
        move.l  $200.w,routiag+6
        beq.s   frouag
        move.l  $204.w,$200.w
        move.l  $208.w,$204.w
        bra.s   sra
;        move.w  (sp)+,d0
;        rte

routicg:
        move.w  d0,-(sp)
        clr.w   d0
src:    move.b  $12345678,d0
modcac: bne.s   srtcg
        bra     remtcg
routidg:
        move.w  d0,-(sp)
        clr.w   d0
srd:    move.b  $12345678,d0
modcad: bne.s   srtdg
        bra.s   remtdg
; *** attention changer deplac dans maupiti
routiag:
        move.w  d0,-(sp)
        clr.w   d0
sra:    move.b  $12345678,d0
modcaa: bne.s   srtag
        bra.s   remtag

srtcg:  add.w   $92.w,d0
        add.w   $8e.w,d0
        add.w   $8c.w,d0
addcg:  addq.l  #1,routicg+6
        lsl.w   #4,d0
        move.l tabf(pc,d0.w),$ffff8800.w
        move.l tabf+4(pc,d0.w),$ffff8800.w
        move.l tabf+8(pc,d0.w),$ffff8800.w
        move.w  (sp)+,d0
        rte

srtdg:  add.w   $92.w,d0
        add.w   $90.w,d0
        add.w   $8c.w,d0   
adddg:  addq.l  #1,routidg+6
        lsl.w   #4,d0
        move.l tabf(pc,d0.w),$ffff8800.w
        move.l tabf+4(pc,d0.w),$ffff8800.w
        move.l tabf+8(pc,d0.w),$ffff8800.w
        move.w  (sp)+,d0
        rte

srtag:  add.w   $92.w,d0
        add.w   $90.w,d0
        add.w   $8e.w,d0
addag:  addq.l  #1,routiag+6
repcom: lsl.w   #4,d0
        move.l tabf(pc,d0.w),$ffff8800.w
        move.l tabf+4(pc,d0.w),$ffff8800.w
        move.l tabf+8(pc,d0.w),$ffff8800.w
        move.w  (sp)+,d0
        rte
tabf:
        blk.l   128*12,0
tabf1:
        blk.l   256*4,0
fitcon: 
        blk.l   128*12,0

tab1: dc.l $00010201,$02010203,$04050505,$05060605
      dc.l $06070606,$06060606,$06060606,$07070707
      dc.l $07070707,$07070808,$08080808,$08080909
      dc.l $09090909,$09090909,$090A0A0A,$0A0A0A0A
      dc.l $0A0A0A0A,$0A0A090A,$0A0A0A0B,$0B0B0B0B
      dc.l $0B0B0B0B,$0B0B0B0B,$0B0B0B0B,$0B0B0B0B
      dc.l $0B0B0B0B,$0B0B0B0B,$0B0C0C0C,$0C0C0C0C
      dc.l $0C0C0C0C,$0C0C0C0C,$0C0C0C0C,$0C0C0C0C
      dc.l $0C0C0C0C,$0C0C0C0C,$0C0C0C0B,$0C0C0C0C
      dc.l $0C0C0C0C,$0C0C0D0D,$0D0D0D0D,$0D0D0D0D
      dc.l $0D0D0D0D,$0D0D0D0D,$0D0D0D0D,$0D0D0D0D   
      dc.l $0D0D0D0D,$0D0B0D0D,$0C0D0D0D,$0D0D0D0D
      dc.l $0D0D0D0C,$0C0C0C0C,$0C0C0D0D,$0D0D0D0D
      dc.l $0D0D0D0D,$0C0C0D0D,$0D0D0D0D,$0D0C0C0D
      dc.l $0D0D0D0D,$0D0D0D0D,$0D0D0D0D,$0D0D0D0D
      dc.l $0D0D0D0E,$0E0E0E0E,$0E0E0E0E,$0E0E0E0E

tab2: dc.l $00000001,$01010201,$01000102,$01000102
      dc.l $01000304,$04030505,$05060606,$05050606
      dc.l $06060707,$07070606,$06060707,$07070606
      dc.l $06060607,$07070702,$04040304,$05050606
      dc.l $06060707,$07070907,$06080804,$03050505
      dc.l $06060606,$06050707,$07070608,$08080808
      dc.l $08080909,$09090909,$09000102,$03020304
      dc.l $04040506,$06060606,$07070706,$06070808
      dc.l $08080808,$08090909,$0909090B,$09090808
      dc.l $09090A0A,$0A0A0001,$01020203,$03040405
      dc.l $05060706,$06070707,$08080708,$07080909
      dc.l $09090809,$090B0908,$0B09090A,$0A0A0A0A
      dc.l $0A0A0A0C,$0C0C0C0C,$0C0C0B0B,$0B0B0B0B
      dc.l $0B0B0B0B,$0C0C0B0B,$0B0B0B0B,$0B0C0C0B
      dc.l $0B0B0B0B,$0B0B0B0B,$0B0C0C0C,$0C0C0C0C
      dc.l $0C0C0C00,$00000104,$05060507,$07070708

tab3: dc.l $00000000,$00010001,$00000000,$01000002
      dc.l $01000100,$01030102,$02000102,$02030001
      dc.l $02030001,$02030101,$02030001,$02030001
      dc.l $01020300,$01020301,$00010302,$01020001
      dc.l $02030001,$02030304,$06000100,$02000102
      dc.l $00000102,$03050102,$03040600,$01020304
      dc.l $04040000,$00010203,$04000000,$00020201
      dc.l $02030200,$01020304,$02030406,$06050102
      dc.l $03040405,$05000102,$03040506,$06060808
      dc.l $07070001,$02030000,$01010202,$03030403
      dc.l $04030004,$05030405,$00010604,$07050000
      dc.l $01020704,$050B0608,$09070700,$00020304
      dc.l $05060601,$02040505,$06060000,$01020304
      dc.l $05060607,$09090808,$08080909,$090A0A0A
      dc.l $0A0A0A0A,$0A0A0A0A,$0A000003,$05060707
      dc.l $07070700,$00000000,$00000500,$02050600

canmid: dc.b    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
prior:  dc.l    $00000300,$00000200,$00000100,0
arpeg1: dc.b    0,0,127,127,127,127,127,127,127,0,0,0,0,0,0,0
arpeg2: dc.b    0,0,127,127,127,127,127,127,127,0,0,0,0,0,0,0
adecr:  dc.l    0
finmor: dc.w    0
admor:  dc.l    0
svmor:  dc.l    0
tvitn:  blk.w   4,0
tvita:  blk.w   4,0
ancplr: dc.w    0
tatem:  dc.w    238,0,0,0
        dc.w    250,250,0,0
        dc.w    262,262,262,0
        dc.w    274,274,274,282
vroutl: dc.w    120
nadd:   blk.b   4,0
aadd:   blk.b   4,0

tafreq: dc.l    0
ptech:  dc.l    0
echan:  dc.l    0
tapres: dc.l    0
tabson: dc.l    0
padetr: dc.l    0
nosonb: dc.w    0
tenue:  dc.w    0
note:   dc.b    0
notmid: dc.b    0
veloc:  dc.b    0
veloc1: dc.b    0
canal:  blk.l   20,0
canal2: blk.l   20,0
canal3: blk.l   20,0
canal4: blk.l   20,0
typri:  dc.b    0,0
savvbl: dc.l    0
savtic: dc.l    0
nocan:  dc.w    0
soncan: blk.l   16,0
adcan:  dc.l    0,0,0,0
noteb:  dc.w    0
nbinvi: dc.w    0
sava6:  dc.l    0
nbpatb: dc.w    0
nocan2: dc.b    0
notmid2: dc.b   0
teson:  blk.b   256,0
texson: blk.b   256,0
pourc : dc.w    75
nbcycl: dc.l    6560000
nbcan:  dc.w    3
nbpatt: dc.w    1
nbpat1: dc.w    0
tferm:  dc.l    0
forme:  dc.b    0,1,2,-1,0,1,1,1
        dc.b    0,1,-1,0,0,1,1,1
        dc.b    0,2,-1,0,0,2,2,2
        dc.b    1,2,-1,0,1,1,1,1
        dc.b    0,-1,0,0,0,0,0,0
        dc.b    1,-1,0,0,1,1,1,1
        dc.b    2,-1,0,0,2,2,2,2

bform:  dc.b    2,-1,-1,0,-1,0,2,-1,-1,0,-1,0,-1,0
rap14:  dc.b    6,14,21,27,34,40,46,52,58,64,69,75,80,84,89,94,99
        dc.b    103,107,112,116,120,124,128,131,135,138,142,145,148
        dc.b    151,154,157,160,162,165,167,171,173,175,177,179,182
        dc.b    184,186,188,190,191,194,195,197,199,201,202,203,205
        dc.b    207,208,209,210,212,213,214,215,216,218,219,220,221
        dc.b    222,223,224,225,225
convit: dc.b    4,4,10,10
nhamb:  dc.b    0
ahamb:  dc.b    0
nbambco: dc.b   0
nbamb:  dc.b    0
texe:   blk.l   32,$01010101
texfeu: blk.l   4,$01010101
texfri: blk.l   4,$01010101
patvi:  dc.l    0
patfeu: dc.b    $9e,26,80,30,$8e,26,$9e,26,80,13,$8e,26
        dc.b    $9e,26,80,25,$8e,26,$7f
patfri: dc.b    $9e,34,80,40,$8e,34,$7f
patpri: blk.l   16,0
patamb: blk.l   10,0
patsur: blk.l   7,0
patani: blk.l   14,0
adpatt: blk.l   12,0
handle: dc.l    0
tafreb: blk.w   228,0
tapreb: blk.l   900
tabsob: blk.l   6400,0
morceau: blk.l  700,0
morc1:   blk.l  500,0
morc2:   blk.l  500,0
morc3:   blk.l  2000,0
fiech:  dc.w    0
fin:
ptechb: blk.l   769,0
echanb: blk.l   5000,0
