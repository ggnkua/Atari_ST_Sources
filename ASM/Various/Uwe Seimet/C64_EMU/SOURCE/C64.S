********************************************************************************
*                                                                              *
*                              C64-Emulator V3.0                               *
*                             Ω 1987 by Uwe Seimet                             *
*                             Buchenlochstraûe 29                              *
*                             6750 Kaiserslautern                              *
*                                                                              *
*                       Linkreihenfolge: C64.O,VC.O,EMULATOR.O                 *
*                                                                              *
********************************************************************************


GEMDOS  =  1
XBIOS   = 14

AUXIN   = $03
AUXOUT  = $04
PRLINE  = $09
AUXINST = $12
SETDTA  = $1A
OPEN    = $3D
CLOSE   = $3E
READ    = $3F
SETBLOCK= $4A

GETREZ  =  4
SSCREEN =  5
SETPALET=  6
SETCOLOR=  7
RSCONF  = 15
IKBDWS  = 25
XBTIMER = 31
SUPEXEC = 38


        globl print
        globl ret64
        globl jmp64
        globl itscr
        globl graph
        globl grbss
        globl opage
        globl its


        text

        move.l sp,a5
        lea stack,sp
        move.l 4(a5),a5
        move.l 12(a5),d0
        add.l 20(a5),d0
        add.l 28(a5),d0
        add.l #$100,d0
        move.l d0,-(sp)
        move.l a5,-(sp)
        clr -(sp)
        move #SETBLOCK,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bne error
        pea msg(pc)
        move #PRLINE,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        moveq #2,d2
        lea fileadr(pc),a2
        lea loadadr(pc),a3
lloop:  clr -(sp)
        move.l (a2)+,-(sp)
        move #OPEN,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        move d0,d7
        bmi error
        move.l (a3)+,-(sp)
        pea $2000
        move d7,-(sp)
        move #READ,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi error
        move d7,-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        tst d0
        bmi error
        dbf d2,lloop
        lea ops,a0
        move.l a0,d0
        add.l #$8000,d0
        move.l d0,opage
        lea op,a1
        clr d2
        move #255,d0
inemu2: move (a1,d2),d1
        lea (a1,d1),a2
        moveq #16,d1
inemu1: move.l (a2)+,(a0)+
        dbf d1,inemu1
        addq #2,d2
        add.l #188,a0
        dbf d0,inemu2
        move #GETREZ,-(sp)
        trap #XBIOS
        addq.l #2,sp
        move d0,rez
        lea prfont,a0
        lea set,a1
        move #511,d4
        cmp #2,d0
        beq conv3
        move #$4e71,colcod
        move #$4e71,colco
        st rezflg
conv3:  moveq #7,d3
conv2:  moveq #7,d2
        move.b (a0)+,d0
        move.b d0,d1
conv1:  tst.b rezflg
        bne conv4
        add.b d1,d1
        roxl (a1)
conv4:  add.b d0,d0
        roxl (a1)+
        dbf d2,conv1
        sub.l #16,a1
        dbf d3,conv2
        add.l #16,a1
        dbf d4,conv3
        tst.b rezflg
        beq conv5
        lea set,a0
        move #4095,d0
conv6:  move.b 1(a0),(a0)
        addq.l #2,a0
        dbf d0,conv6
conv5:  lea sctab,a0
        clr d1
        moveq #24,d0
tabl:   move d1,(a0)+
        add #1280,d1
        dbf d0,tabl
        lea grtab+510,a0
        move #255,d3
bit1:   moveq #7,d2
        move.b d3,d0
        move.b d3,d1
bit0:   add.b d0,d0
        roxl (a0)
        add.b d1,d1
        roxl (a0)
        dbf d2,bit0
        subq.l #2,a0
        dbf d3,bit1
        lea oldcol+32,a3
        moveq #15,d3
savcol: move #-1,-(sp)
        move d3,-(sp)
        move #SETCOLOR,-(sp)
        trap #XBIOS
        addq.l #6,sp
        move d0,-(a3)
        dbf d3,savcol
        pea newcol(pc)
        move #SETPALET,-(sp)
        trap #XBIOS
        addq.l #6,sp
        move.b #$06,c64+$d021
        pea moff(pc)            *Maus abschalten
        clr -(sp)
        move #IKBDWS,-(sp)
        trap #XBIOS
        addq.l #8,sp
        pea base(pc)
        move #SUPEXEC,-(sp)
        trap #XBIOS
        addq.l #6,sp
        cmp #1,rez
        bne rezok
        clr -(sp)
        pea -1
        pea -1
        move #SSCREEN,-(sp)
        trap #XBIOS
        add.l #12,sp
rezok:  pea int(pc)
        move #$cc,-(sp)
        move #7,-(sp)
        clr -(sp)
        move #XBTIMER,-(sp)
        trap #XBIOS
        add.l #12,sp
        pea dta
        move #SETDTA,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        lea c64,a6
        movem.l (a6),d2-d7              *Register lîschen
        bset #31,d4
        move.l #$55390d00,file          *Floppy-Reset
        bsr vc1541
        lea area,a2
        move.l opage(pc),a3
        lea c64+$fce2,a5
        moveq #$10,d1
        move.b (a5)+,start+2
start:  jmp 0(a3)                       *ersten Befehl ausfÅhren

jmp64:
        move.l d2,d0
        sub #$ff81,d0
        divu #3,d0
        add d0,d0
        add d0,d0
        lea kadr(pc),a0
        move.l (a0,d0),d0
        beq emul
        move.l d0,a0
        jsr (a0)
        lea area,a2
        moveq #$10,d1
        jmp $6000(a3)                   *zum RTS-Opcode
emul:   lea (a6,d2.l),a5
        move.b (a5)+,emu+2
emu:    jmp 0(a3)

newcol: dc $000,$777,$600,$067,$707,$040,$003,$770
        dc $740,$420,$721,$444,$333,$373,$457,$222

int:
        move.l d0,-(sp)
        move.b c64+$d021,d0
        and #$0f,d0
        add.b d0,d0
        move newcol(pc,d0),$ff8240
        move.b c64+$0286,d0
        cmp.b c0286(pc),d0
        beq noc0
        movem.l a0/d1-d2,-(sp)
        bsr colf1
        movem.l (sp)+,a0/d1-d2
noc0:   tst.l d4                        *Interrupts erlaubt?
        bmi inte                        *nein-
        movem.l d2/d7/a0-a1/a6,-(sp)
        lea c64,a6
        bsr udtim
        tst.b $cc(a6)
        bne int0
        subq.b #1,$cd(a6)
        bne int0
        move.b #$14,$cd(a6)
        clr d7
        move.b $d3(a6),d7
        clr.l d0
        move.b $d2(a6),d0
        asl #8,d0
        move.b $d1(a6),d0
        add d7,d0
        move.b (a6,d0),d7
        move.b $cf(a6),d2
        clr.b $cf(a6)
        tst.b d2
        bne int1
        addq.b #1,$cf(a6)
        move.b d7,$ce(a6)
int1:   move.b $0288(a6),d2
        asl #8,d2
        sub d2,d0
        divu #40,d0
        move d0,d2
        add d2,d2
        swap d0
        ext.l d0
        move d0,d7
colco:  add d0,d0
        move.l scbase(pc),a0
        lea sctab,a1
        add (a1,d2),d0
        add.l d0,a0
        tst.b rezflg
        beq cur0
        and #$fe,d7
        lea coltab(pc),a1
        add (a1,d7),a0
        moveq #7,d0
intc:   move.l plane(pc),d2
        movep.l 0(a0),d7
        not.l d7
        move.l d7,-(sp)
        eor.l d2,d7
        and.l (sp)+,d7
        movep.l d7,0(a0)
        add.l #160,a0
        dbf d0,intc
        bra int0
cur0:   moveq #15,d0
int2:   not (a0)
        add.l #80,a0
        dbf d0,int2
int0:   bsr scn
        movem.l (sp)+,d2/d7/a0-a1/a6
inte:   move.l (sp)+,d0
        bclr #5,$fffa0f
        rte

scan:
        trap #0
        rts

scn:
        cmp.b #$40,$cb(a6)
        beq scrt
        move.b $cb(a6),d0
        cmp.b $c5(a6),d0
        beq rp
        move.b #$10,$028c(a6)
        bra rep
rp:     tst.b $028a(a6)
        bmi rp1
        btst #6,$028a(a6)
        bne scrt
        move.b stcode(pc),d0
        and #$7f,d0
        cmp.b #$7f,d0
        beq rep
        cmp.b #$14,d0
        beq rp1
        cmp.b #" ",d0
        beq rp1
        cmp.b #$1d,d0
        beq rp1
        cmp.b #$11,d0
        bne scrt
rp1:    tst.b $028c(a6)
        beq rp0
        subq.b #1,$028c(a6)
        bne srt
rp0:    subq.b #1,$028b(a6)
        bne srt
        move.b #$04,$028b(a6)
        cmp.b #$01,$c6(a6)
        bgt srt
rep:    btst #0,$484
        beq nocl
        move.l #click,$e44
        clr.b $e48
nocl:   move.b $c6(a6),d0
        cmp.b $0289(a6),d0
        bge scrt
        ext d0
        lea $0277(a6),a0
        move.b stcode(pc),(a0,d0)
        addq.b #1,$c6(a6)
scrt:   move.b $cb(a6),$c5(a6)
        move.b $028d(a6),$028e(a6)
srt:    rts

keyscn:
        tst.b $fffc00
        beq noint
        movem.l a0/a6/d0,-(sp)
        lea c64,a6
        move.b $fffc02,d0
        btst #13,12(sp)                 *Aufruf aus Supervisor-Modus?
        bne nof10                       *ja-        
        cmp.b #$61,d0                   *UNDO-Taste?
        bne undo                        *nein-
        cmp #$47fe,$0318(a6)
        bne tnmi
        cmp.b #$7f,$91(a6)
        bne scon3
        move.l #rs,14(sp)
        bra scon3
tnmi:   move.l #nmi,14(sp)
        bra scon3        
undo:   cmp.b #$62,d0                   *HELP-Taste?
        bne help                        *nein-
        pea msg(pc)
        move #PRLINE,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        bra scon3
help:   cmp.b #$3f,d0                   *F5?
        bne nof5                        *nein-
        addq.b #1,c64+$d021
        and.b #$0f,c64+$d021
        bra scon3
nof5:   cmp.b #$40,d0                   *F6?
        bne nof6                        *nein-
        addq.b #1,c64+$0286
        and.b #$0f,c64+$0286
        bra scon3
nof6:   cmp.b #$41,d0                   *F7?
        bne nof7                        *nein-
        addq #1,$4ee
        bra scon3
nof7:   cmp.b #$42,d0                   *F8?
        bne nof8                        *nein-
        bsr swhi
        cmp.b #"-",ff8
        beq swi0
        move.b #"-",ff8
        bra scon3
swi0:   move.b #"+",ff8
        bra scon3
nof8:   cmp.b #$43,d0                   *F9?
        bne nof9                        *nein-
        bsr swlo
        cmp.b #"-",ff9
        beq swi
        move.b #"-",ff9
        bra scon3
swi:    move.b #"+",ff9
        bra scon3
nof9:   cmp.b #$44,d0                   *F10?
        bne nof10                       *nein-
        move.l #exit,14(sp)
        bra scon3
nof10:  move.b #$40,$cb(a6)
        cmp.b #$2a,d0
        beq key1
        cmp.b #$36,d0
        bne key2
key1:   bset #0,$028d(a6)
        lea c64+$ebc2,a0
        bra scon5
key2:   cmp.b #$aa,d0
        beq key3
        cmp.b #$b6,d0
        bne key4
key3:   bclr #0,$028d(a6)
        lea c64+$eb81,a0
        bra scon5
key4:   cmp.b #$1d,d0
        bne ctrl1
        bset #2,$028d(a6)
        lea c64+$ec78,a0
        bra scon5
ctrl1:  cmp.b #$9d,d0
        bne ctrl2
        bclr #2,$028d(a6)
        lea c64+$eb81,a0
        bra scon5
ctrl2:  cmp.b #$38,d0
        bne alt1
        bset #1,$028d(a6)
        lea c64+$ec03,a0
        bra scon5
alt1:   cmp.b #$b8,d0
        bne alt2
        bclr #1,$028d(a6)
        lea c64+$eb81,a0
        bra scon5
alt2:   cmp.b #$4b,d0
        bne nol
        move.b #$02,$cb(a6)
        move.b #$9d,d0
        bra scon4
nol:    cmp.b #$48,d0
        bne nou
        move.b #$07,$cb(a6)
        move.b #$91,d0
        bra scon4
nou:    cmp.b #$52,d0
        bne noi
        clr.b $cb(a6)
        move.b #$94,d0
        bra scon4
noi:    cmp.b #$63,d0
        bne noo
        move.b #$1b,$cb(a6)
        moveq #$28,d0
        bra scon4
noo:    cmp.b #$64,d0
        bne scon
        move.b #$20,$cb(a6)
        moveq #$29,d0
        bra scon4
scon5:  move.l a0,tab
scon:   ext d0
        bmi scon2
        lea key(pc),a0
        move.b (a0,d0),d0
        move.b d0,$cb(a6)
        move.l tab(pc),a0
        move.b (a0,d0),d0
        cmp.b #$ff,d0
        beq scon2
scon4:  move.b d0,stcode
scon2:  move.b $028d(a6),d0
        cmp.b #$03,d0
        bne scon3
        cmp.b $028e(a6),d0
        beq scon3
        tst.b $0291(a6)
        bmi scon3
        eor.b #$02,c64+$d018
scon3:  movem.l (sp)+,a0/a6/d0
noint:  bclr #6,$fffa11
        rte

nmi:
        clr.l d4
        bset #31,d4
        lea area,a2
        move.l opage(pc),a3
        lea c64,a6
        clr.l d2
        clr.l d3
        clr.l d5
        clr.l d6
        clr.l d7
        moveq #$10,d1
        sub.l a6,a5
        move a5,-(a2)
        move.b (a2)+,(a4)
        move.b (a2)+,-(a4)
        move.b d4,-(a4)
        tst.b -(a4)
        lea c64+$fe44,a5
        bra start

rs:
        clr.l d4
        bset #31,d4
        lea area,a2
        move.l opage(pc),a3
        lea c64,a6
        clr.l d2
        clr.l d3
        clr.l d5
        clr.l d6
        clr.l d7
        moveq #$10,d1
        sub.l a6,a5
        move a5,-(a2)
        move.b (a2)+,(a4)
        move.b (a2)+,-(a4)
        move.b d4,-(a4)
        move.b d5,-(a4)
        move.b d6,-(a4)
        move.b d7,-(a4)
        tst.b -(a4)
        lea c64+$fe66,a5
        bra start

init:
        moveq #$0e,d0
        bsr colf
cls:
        move.b $0288(a6),d7
        or.b #$80,d7
        clr.b d5
        clr.b d6 
        lea $d9(a6),a0
clr0:   move.b d7,(a0,d6)
        add.b #$28,d5
        bcc clr1
        addq.b #1,d7
clr1:   addq.b #1,d6
        cmp.b #$1a,d6
        bne clr0
        st (a0,d6)
        moveq #$18,d6
clr2:   bsr clrline
        subq.b #1,d6
        bpl clr2
        move.l scbase(pc),a1
        move #7999,d0
ccl:    clr.l (a1)+
        dbf d0,ccl
home:
        clr.b $d3(a6)
        clr.b $d6(a6)
curpos:
        move.b $d6(a6),d6
curp1:  lea $d9(a6),a0
cp1:    tst.b (a0,d6)
        bmi cp0
        add.b #$28,$d3(a6)
        subq.b #1,d6
        bpl cp1
cp0:    move.b (a0,d6),d5
        and.b #$03,d5
        or.b $0288(a6),d5
        move.b d5,$d2(a6)
        lea c64+$ecf0,a1
        move.b (a1,d6),$d1(a6)
        moveq #$27,d5
        addq.b #1,d6
cp3:    tst.b (a0,d6)
        bmi cp2
        add.b #$28,d5
        addq.b #1,d6
        bpl cp3
cp2:    move.b d5,$d5(a6)
        rts

getchar:
        lea $0277(a6),a0
        move.b (a0),d5
        clr d0
gc:     move.b 1(a0),(a0)+
        addq.b #1,d0
        cmp.b $c6(a6),d0
        bne gc
        subq.b #1,$c6(a6)
        bclr #31,d4
        and.b #$ee,d4
        rts

wait:
        bsr bssc
bsin:   move.b $c6(a6),d5
        move.b d5,$cc(a6)
        move.b d5,$0292(a6)
        beq bsin
        bset #31,d4
        tst.b $cf(a6)
        beq bs0
        clr.b $cf(a6)
        move.b $ce(a6),d5
        bsr output
bs0:    bsr getchar
        cmp.b #$83,d5
        bne bs4
        moveq #$09,d6
        bset #31,d4
        move.b d6,$c6(a6)
        lea c64+$ece6,a0
        lea $0276(a6),a1
ldrn:   move.b (a0,d6),(a1,d6)
        subq.b #1,d6
        bne ldrn
        bra bsin
bs4:    cmp.b #$0d,d5
        bne wait
        move.b $d5(a6),d7
        move.b d7,$d0(a6)
        move.b $d2(a6),d2
        asl #8,d2
        move.b $d1(a6),d2
        lea (a6,d2.l),a0
bs2:    move.b (a0,d7),d5
        cmp.b #" ",d5
        bne bs1
        subq.b #1,d7
        bne bs2
bs1:    addq.b #1,d7
        move.b d7,$c8(a6)
        clr.b $0292(a6)
        clr.b $d3(a6)
        clr.b $d4(a6)
        tst.b $c9(a6)
        bmi bs3
        move.b $d6(a6),d6
        lea $d9(a6),a0
bs7:    tst.b (a0,d6)
        bmi bs6
        subq.b #1,d6
        bne bs7
bs6:    bsr vram
        cmp.b $c9(a6),d6
        bne bs3
        move.b $ca(a6),d5
        move.b d5,$d3(a6)
        cmp.b $c8(a6),d5
        blt bs3
        bra bs8

basn:
        movem d6-d7,-(sp)
        tst.b $d0(a6)
        beq bsin
bs3:    move.b $d3(a6),d7
        move.b $d2(a6),d0
        asl #8,d0
        move.b $d1(a6),d0
        add d7,d0
        move.b (a6,d0),d5
        move.b d5,d0
        and.b #$3f,d5
        btst #6,d0
        beq bas0
        or.b #$80,d5
bas0:   tst.b d0
        bpl bas1
        tst.b $d4(a6)
        bne bas2
bas1:   btst #5,d0
        bne bas2
        or.b #$40,d5
bas2:   addq.b #1,$d3(a6)
        cmp.b #$22,d5
        bne bas3
        eor.b #$01,$d4(a6)
bas3:   cmp.b $c8(a6),d7
        bne bas4
bs8:    clr.b $d0(a6)
        moveq #$0d,d5
        cmp.b #$03,$99(a6)
        beq bas6
        cmp.b #$03,$9a(a6)
        beq bas4
bas6:   bsr bssc
bas4:   move.b d5,$d7(a6)
        movem (sp)+,d6-d7
        cmp.b #$de,d5
        bne bas5
        st d5
bas5:   and.b #$ee,d4
        rts

chrout:
        or.b #$40,d5
chrout1:
        tst.b $c7(a6)
        beq norv
chrout2:
        or.b #$80,d5
norv:   tst.b $d8(a6)
        beq noin
        subq.b #1,$d8(a6)
noin:   bsr output
        bsr msb
lin:    movem (sp)+,d5-d7
        tst.b $d8(a6)
        beq non
        clr.b $d4(a6)
non:    bclr #31,d4
        tst.b d5
        move sr,d4
        rts

msb:    bsr msb0
        addq.b #1,$d3(a6)
        move.b $d5(a6),d5
        cmp.b $d3(a6),d5
        bge msb9
        cmp.b #$4f,d5
        beq msb4
        tst.b $0292(a6)
        bne insl
        move.b $d6(a6),d6
        cmp.b #$19,d6
        blt msb5
        bsr scroll
        subq.b #1,$d6(a6)
        move.b $d6(a6),d6
msb5:   lea $d9(a6),a0
        and.b #$7f,(a0,d6)
        or.b #$80,1(a0,d6)
        add.b #$28,$d5(a6)
mb6:    tst.b (a0,d6)
        bmi vram
        subq.b #1,d6
        bne mb6
        bra vram
msb4:   subq.b #1,$d6(a6)
        bsr msb8
        clr.b $d3(a6)
msb9:   rts

back:
        move.b $d6(a6),d6
        bne bck0
        move.b d6,$d3(a6)
        addq.l #4,sp
        bra lin
bck0:   subq.b #1,d6
        move.b d6,$d6(a6)
        bsr curp1
        move.b $d5(a6),$d3(a6)
        rts

bsout:
        cmp.b #$03,$9a(a6)
        beq bssc
        bgt iecout
        cmp.b #$02,$9a(a6)
        beq rsout
        and.b #$ee,d4
        rts
bssc:   movem d5-d7,-(sp)
        clr.b $d0(a6)
        move.b $d3(a6),d7
        move.b d5,$d7(a6)
        bmi grcode
        cmp.b #$0d,d5
        beq carret
        cmp.b #" ",d5
        blt cd
        cmp.b #$60,d5
        blt gr1
        and.b #$df,d5
        bra gr4
gr1:    and.b #$3f,d5
gr4:    cmp.b #$22,d5
        bne chrout1
        eor.b #$01,$d4(a6)
        bra chrout1
cd:     tst.b $d8(a6)
        bne chrout2
        cmp.b #$14,d5
        bne delc
        tst.b d7
        bne del0
        bsr back
        bra del1
del0:   bsr msb7
        subq.b #1,d7
        move.b d7,$d3(a6)
        move.b $d2(a6),d2
        asl #8,d2
        move.b $d1(a6),d2
        lea (a6,d2.l),a1
del2:   move.b 1(a1,d7),d5
        bsr prscr
        addq.b #1,d7
        cmp.b $d5(a6),d7
        bne del2
        moveq #$20,d5
        bsr prscr
        bra lin
del1:   move.b #" ",(a0,d7)
        bra lin
delc:   tst.b $d4(a6)
        bne chrout2
        cmp.b #$12,d5
        bne revc
        move.b d5,$c7(a6)
revc:   cmp.b #$13,d5
        bne homc
        bsr home
homc:   cmp.b #$1d,d5
        bne rgtc
        addq.b #1,d7
        bsr msb0
        move.b d7,$d3(a6)
        subq.b #1,d7
        cmp.b $d5(a6),d7
        blt lin
        subq.b #1,$d6(a6)
        bsr msb8
        clr.b $d3(a6)
        bra lin
rgtc:   cmp.b #$11,d5
        bne dwnc
        move.b d7,d5
        add.b #$28,d5
        move.b d5,d7
        addq.b #1,$d6(a6)
        cmp.b $d5(a6),d5
        bgt dw0
        move.b d7,$d3(a6)
        bra lin
dw0:    subq.b #1,$d6(a6)
dw2:    sub.b #$28,d5
        blt dw1
        move.b d5,$d3(a6)
        bne dw2
dw1:    bsr msb8
        bra lin
dwnc:   bsr tstcol
        cmp.b #$0e,d5
        bne nsml
        or.b #$02,c64+$d018
        bra lin
nsml:   cmp.b #$08,d5
        bne nlck
        or.b #$80,$0291(a6)
        bra lin
nlck:   cmp.b #$09,d5
        bne lin
        and.b #$7f,$0291(a6)
        bra lin

grcode:
        and.b #$7f,d5
        cmp.b #$7f,d5
        bne nopi
        moveq #$5e,d5
nopi:   cmp.b #" ",d5
        bge chrout
        cmp.b #$0d,d5
        beq carret
        tst.b $d4(a6)
        beq grc1
cup:    or.b #$40,d5
        bra chrout2
grc1:   cmp.b #$14,d5
        bne noins
        move.b $d5(a6),d7
        move.b $d2(a6),d2
        asl #8,d2
        move.b $d1(a6),d2
        lea (a6,d2.l),a1
        cmp.b #" ",(a1,d7)
        bne ins1
        cmp.b $d3(a6),d7
        bne ins2
ins1:   cmp.b #$4f,d7
        beq lin
        move.l a1,-(sp)
        bsr insline
        sub #40,d2
        move.l (sp)+,a1
ins2:   move.b $d5(a6),d7
ins3:   move.b -1(a1,d7),d5
        bsr prscr
        subq.b #1,d7
        cmp.b $d3(a6),d7
        bne ins3
        moveq #$20,d5
        bsr prscr
        addq.b #1,$d8(a6)
        bra lin
noins:  tst.b $d8(a6)
        bne cup
        cmp.b #$11,d5
        bne upc
        tst.b $d6(a6)
        beq lin
        subq.b #1,$d6(a6)
        move.b $d3(a6),d5
        sub.b #$28,d5
        blt cp
        move.b d5,$d3(a6)
        bpl lin
cp:     bsr curpos
        bra lin
upc:    cmp.b #$12,d5
        bne rvcd
        clr.b $c7(a6)
rvcd:   cmp.b #$1d,d5
        bne lftc
        tst.b d7
        bne lft0
        bsr back
        bra lin
lft0:   bsr msb7
        subq.b #1,d7
        move.b d7,$d3(a6)
        bra lin
lftc:   cmp.b #$13,d5
        bne clcd
        bsr cls
        bra lin
clcd:   or.b #$80,d5
        bsr tstcol
        cmp.b #$8e,d5
        bne lin
        bclr #1,c64+$d018
        bra lin

tstcol:
        lea c64+$e8da,a0
        moveq #15,d0
fcol:   cmp.b (a0,d0),d5
        beq colf
        dbf d0,fcol
        rts
colf:   move.b d0,$0286(a6)
colf1:  add d0,d0
        add d0,d0
        move.l pencol(pc,d0),plane
        rts

pencol: dc.l $ffff0000,$00ffffff,$ff00ffff,$0000ffff
        dc.l $ffff00ff,$00ff00ff,$ff0000ff,$ffffffff
        dc.l $ff00ffff,$00ffff00,$ff00ff00,$0000ff00
        dc.l $000000ff,$00ff0000,$ff000000,$00ff0000

prscr:
        move.b d5,(a1,d7)
        move.l a1,-(sp)
        move.l d7,d0
        add d2,d0
        bsr toscr
        move.l (sp)+,a1
        rts

carret:
        clr.b $d8(a6)
        clr.b $c7(a6)
        clr.b $d4(a6)
        clr.b $d3(a6)
        bsr msb8
        bra lin
msb8:   clr.b $c9(a6)
        move.b $d6(a6),d6
n0d2:   addq.b #1,d6
        cmp.b #$19,d6
        bne n0d1
        bsr scroll
n0d1:   lea $d9(a6),a0
        tst.b (a0,d6)
        bpl n0d2
        move.b d6,$d6(a6)
        bra curpos

msb7:
        moveq #$02,d6
        clr.b d5
ms0:    cmp.b $d3(a6),d5
        beq ms1
        add.b #$28,d5
        subq.b #1,d6
        bne ms0
        rts
ms1:    subq.b #1,$d6(a6)
        rts

msb0:
        moveq #$02,d6
        moveq #$27,d5
mb8:    cmp.b $d3(a6),d5
        beq mb9
        add.b #$28,d5
        subq.b #1,d6
        bne mb8
        rts
mb9:    move.b $d6(a6),d6
        cmp.b #$19,d6
        beq mb7
        addq.b #1,$d6(a6)
mb7:    rts

scroll:
        move.l $ac(a6),-(sp)
ll5:    st d6
        subq.b #1,$d6(a6)
        subq.b #1,$c9(a6)
        subq.b #1,$02a5(a6)
ll1:    addq.b #1,d6
        bsr vram
        cmp.b #$18,d6
        bge ll0
        lea c64+$ecf1,a0
        move.b (a0,d6),$ac(a6)
        lea $da(a6),a0
        move.b (a0,d6),d5
        bsr moveup
        bra ll1
ll0:    bsr clrline
        clr.b d6
        lea $d9(a6),a0
ll4:    move.b (a0,d6),d5
        and.b #$7f,d5
        move.b 1(a0,d6),d7
        bpl ll3
        or.b #$80,d5
ll3:    move.b d5,(a0,d6)
        addq.b #1,d6
        cmp.b #$18,d6
        bne ll4
        or.b #$80,$f1(a6)
        tst.b $d9(a6)
        bpl ll5
        addq.b #1,$d6(a6)
        addq.b #1,$02a5(a6)
        btst #2,$028d(a6)
        beq ll7
        moveq #-1,d0
ll8:    nop
        dbf d0,ll8
ll7:    btst #1,$028d(a6)
        bne ll7
        move.b $d6(a6),d6
        move.l (sp)+,$ac(a6)
        rts

insline:
        move.b $d6(a6),d6
insl:   lea $d9(a6),a0
il0:    addq.b #1,d6
        tst.b (a0,d6)
        bpl il0
        move.b d6,$02a5(a6)
        cmp.b #$18,d6
        ble inslin
        bsr scroll
        move.b $02a5(a6),d6
        subq.b #1,d6
        subq.b #1,$d6(a6)
        bra msb5

inslin:
        move.l $ac(a6),-(sp)
        moveq #$19,d6
insl1:  subq.b #1,d6
        bsr vram
        cmp.b $02a5(a6),d6
        ble inl0
        lea $d8(a6),a0
        lea c64+$ecef,a1
        move.b (a1,d6),$ac(a6)
        move.b (a0,d6),d5
        st mflg
        bsr moveup
        bra insl1
inl0:   bsr clrline
        moveq #$17,d6
ins6:   cmp.b $02a5(a6),d6
        blt ins8
        move.b 2(a0,d6),d5
        and.b #$7f,d5
        tst.b 1(a0,d6)
        bpl ins7
        or.b #$80,d5
ins7:   move.b d5,2(a0,d6)
        subq.b #1,d6
        bne ins6
ins8:   move.b $02a5(a6),d6
        bsr msb5
        move.l (sp)+,$ac(a6)
        rts

moveup:
        and.b #$03,d5
        or.b $0288(a6),d5
        move.b d5,$ad(a6)
        moveq #$27,d7
        move.b $ad(a6),d2
        asl #8,d2
        move.b $ac(a6),d2
        lea (a6,d2.l),a0
        move.b $d2(a6),d2
        asl #8,d2
        move.b $d1(a6),d2
        lea (a6,d2.l),a1
movu:   move.b (a0,d7),(a1,d7)
        subq.b #1,d7
        bpl movu
        clr.l d0
        move.b d6,d0                    *Nummer der Bildschirmzeile
        mulu #1280,d0
        move.l scbase(pc),a0
        add.l d0,a0
        move.l a0,a1
        add.l #1280,a1
        move #319,d0
        tst.b mflg
        beq movu1
        clr.b mflg
        sub.l #1280,a0
        sub.l #1280,a1
        exg.l a0,a1
movu1:  move.l (a1)+,(a0)+
        dbf d0,movu1
        rts

vram:
        lea $d9(a6),a0
        lea c64+$ecf0,a1
        move.b (a1,d6),$d1(a6)
        move.b (a0,d6),d5
        and.b #$03,d5
        or.b $0288(a6),d5
        move.b d5,$d2(a6)
        rts

clrline:
        clr.l d0
        move.b d6,d0                    *Nummer der Bildschirmzeile
        mulu #1280,d0
        move.l scbase(pc),a0
        add.l d0,a0
        move #319,d0
cll1:   clr.l (a0)+
        dbf d0,cll1
        moveq #$27,d7
        bsr vram
        move.b $d2(a6),d2
        asl #8,d2
        move.b $d1(a6),d2
        lea (a6,d2.l),a0
clln:   move.b #" ",(a0,d7)
        subq.b #1,d7
        bpl clln
        rts

rsin:
        move #AUXIN,-(sp)
        trap #GEMDOS
        addq.l #2,sp
        move.b d0,d5
        bra rt

rsout:
        move d5,-(sp)
        move #AUXOUT,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        bra rt

talk:
        bra rt

lstn:
        cmp.b #$04,d5                   *Drucker?
        beq rt                          *ja-
        move.l #file,compnt
rt:     and.b #$ee,d4
        rts

seclstn:
        move.b d5,$b9(a6)
        rts

sectalk:
        move.b d5,$b9(a6)
        rts

iecout:
        cmp.b #$04,$ba(a6)              *Drucker?
        bne vcwrite                     *nein-
        bsr printer
        bra rt

untalk:
        bra rt

unlstn:
        cmp.b #$04,$ba(a6)              *Drucker?
        beq rt                          *ja-
        move.l compnt,a0
        clr.b (a0)
        bra vc1541

iecin:
        cmp.b #$04,$ba(a6)              *Drucker?
        beq rt                          *ja-
        bra vcread

open:
        move #$f70a,d0                  *"NOT INPUT FILE"
        move.b $b8(a6),d6
        beq ret64
        move #$f6fe,d0                  *"FILE OPEN"
        bsr slog                        *logische Filenummer suchen
        beq ret64
        move #$f6fb,d0                  *"TOO MANY FILES"
        move.b $98(a6),d6
        cmp.b #10,d6
        bcc ret64
        addq.b #1,$98(a6)
        lea $0259(a6),a0
        move.b $b8(a6),(a0,d6)          *logische Filenummer
        or.b #$60,$b9(a6)
        move.b $b9(a6),20(a0,d6)        *SekundÑradresse
        move.b $ba(a6),10(a0,d6)        *GerÑteadresse
        beq opsc                        *Bildschirmfile-
        cmp.b #$02,$ba(a6)              *RS232?
        beq rsopen                      *ja-
        move.b $b9(a6),d0
        and.b #$0f,d0
        cmp.b #$0f,d0                   *Kommandokanal?
        beq comcan                      *ja-
        move.b $b8(a6),d0               *logische Filenummer
        bsr vcopen
opsc:   bra rt
comcan: move.b $b7(a6),d7
        beq rt                          *kein Kommandostring-
        move.b $ba(a6),d5
        bsr lstn
        move.b $bc(a6),d2
        asl #8,d2
        move.b $bb(a6),d2
copcom: move.b (a6,d2.l),d5
        bsr iecout                      *String an Floppy senden
        addq #1,d2
        subq.b #1,d7
        bne copcom
        bra unlstn

rsopen:
        clr.b $0297(a6)                 *RS232 Status lîschen
        tst.b $b7(a6)
        beq norsn
        clr.l d1
        move.b $bc(a6),d1
        asl #8,d1
        move.b $bb(a6),d1
        add #3,d1
        lea $0293(a6),a0
        moveq #3,d0
coprs:  move.b (a6,d1.l),(a0,d0)
        subq #1,d1
        dbf d0,coprs
norsn:  move.b (a0),d5
        and.b #$0f,d5                   *Bits fÅr Baud-Rate
        move d5,d0
        add d0,d0
        moveq #-1,d1
        move d1,-(sp)
        move d1,-(sp)
        move d1,-(sp)
        move #%10001000,-(sp)
        clr -(sp)
        move baud(pc,d0),-(sp)              *Baud-Rate
        move #RSCONF,-(sp)
        trap #XBIOS
        add.l #14,sp
        bra rt

baud:   dc -1,15,14,13,12,11,9,8,7,6,4,3,2,-1,1,0

close:
        bsr sloga                       *logische Filenummer suchen
        bne clrts                       *nicht gefunden-
        bsr sfpar                       *Fileparameter setzen
        cmp.b #$03,$ba(a6)
        bcs clos                        *kein IEC-File-
        move.b $b9(a6),d0
        and.b #$0f,d0
        cmp.b #$0f,d0                   *Kommandokanal?
        beq clos                        *ja-
        move.b $b8(a6),d0               *logische Filenummer
        bsr vcclose
clos:   subq.b #1,$98(a6)
        cmp.b $98(a6),d6
        beq clrts
        lea $0259(a6),a0
        move.b $98(a6),d7
        move.b (a0,d7),(a0,d6)
        move.b 10(a0,d7),10(a0,d6)
        move.b 20(a0,d7),20(a0,d6)
clrts:  bra rt

chkin:
        move #$f701,d0                  *"FILE NOT OPEN"
        bsr slog                        *logische Filenummer suchen
        bne ret64
        bsr sfpar                       *Fileparameter setzen
        move.b $ba(a6),d5
        cmp.b #$08,d5                   *Floppy?
        blt chkscr                      *nein-
        move.b $b8(a6),d0               *logische Filenummer
        bsr vcchkin
chkscr: move.b d5,$99(a6)
        bra rt

ckout:
        move #$f701,d0                  *"FILE NOT OPEN"
        bsr slog                        *logische Filenummer suchen
        bne ret64
        bsr sfpar
        move #$f70d,d0                  *"NOT OUTPUT FILE"
        move.b $ba(a6),d5
        beq ret64
        cmp.b #$08,d5                   *Floppy?
        blt ckout2                      *nein-
        move.b $b8(a6),d0
        bsr vckout
ckout2: move.b d5,$9a(a6)
        bra rt

sfpar:
        lea $0259(a6),a0
        move.b (a0,d6),$b8(a6)          *logische Filenummer
        move.b 10(a0,d6),$ba(a6)        *GerÑteadresse
        move.b 20(a0,d6),$b9(a6)        *SekundÑradresse
        rts

slog:
        clr.b $90(a6)
        move.b d6,d5
sloga:  lea $0259(a6),a0
        move.b $98(a6),d6
slog0:  subq.b #1,d6
        bmi slog1
        cmp.b (a0,d6),d5
        bne slog0
slog1:  rts

output:
        clr.l d0
        move.b #$02,$cd(a6)
        move.b $d2(a6),d0
        asl #8,d0
        move.b $d1(a6),d0
        move.b $d3(a6),d7
        add d7,d0
        move.b d5,(a6,d0)
toscr:  move.b $0288(a6),d1
        asl #8,d1
        sub d1,d0
itscr:  divu #40,d0
        move d0,d1
        add d1,d1
        swap d0
        ext.l d0
        move.b d0,d3
colcod: add d0,d0
        move.l scbase(pc),a0
        lea sctab,a1
        add (a1,d1),d0
        add.l d0,a0
        move d5,d0
        asl #4,d0
        btst #1,c64+$d018
        beq big
        add.l #$1000,d0
big:    lea set,a1
        add.l d0,a1
        moveq #7,d0
        tst.b rezflg
        bne chr1
chr:    move (a1),(a0)
        move (a1)+,80(a0)
        add.l #160,a0
        dbf d0,chr
        rts
chr1:   and #$fe,d3
        add coltab(pc,d3),a0
chr2:   move (a1),d1
        swap d1
        move (a1)+,d1
        move.l d1,-(sp)
        move.l plane(pc),d3
        eor.l d3,d1
        and.l (sp)+,d1
        movep.l d1,0(a0)
        add.l #160,a0
        dbf d0,chr2
        clr.l d3
        rts
        
coltab: dc 0,6,12,18,24,30,36,42,48,54
        dc 60,66,72,78,84,90,96,102,108,114

its:    bsr itscr
        jmp itret

graph:
        divu #320,d2            *Bildschirmzeile
        move d2,d0
        tst.b rezflg
        bne colgr
        asl #4,d0               *grobe Pixelzeile
        clr d2
        swap d2
        divu #8,d2
        move d2,d1              *Bildschirmspalte
        swap d2                 *feine Pixelzeile
        add d2,d0               *y-Koordinate
        add d2,d0
        add d1,d1               *grobe Pixelspalte
        mulu #80,d0
        move.l scbase(pc),a0
        add.l d0,a0
        add d1,a0
        lea grtab,a1
        add d5,d5
        move (a1,d5),(a0)
        move (a1,d5),80(a0)
        clr.l d2
        jmp itret
colgr:  asl #3,d0               *grobe Pixelzeile
        clr d2
        swap d2
        divu #8,d2
        move d2,d1              *Bildschirmspalte
        swap d2                 *feine Pixelzeile
        add d2,d0               *y-Koordinate
        mulu #160,d0
        add d1,d0
        and #$fe,d1
        lea coltab(pc),a0
        add (a0,d1),d0
        move.l scbase(pc),a0
        add.l d0,a0
        move.b d5,d0
        asl #8,d0
        move.b d5,d0
        move d0,d5
        swap d5
        move d0,d5
        movep.l d5,0(a0)
        clr.l d5
        clr.l d2
        jmp itret

get:
        move.b $99(a6),d5
        bne get9
        tst.b $c6(a6)
        beq grt
        bset #31,d4
        bra getchar
get9:   cmp.b #$02,d5
        bne get0
        move #AUXINST,-(sp)
        trap #GEMDOS
        addq.l #2,sp
        tst d0
        beq nochr
        and.b #$f7,$0297(a6)
        move #AUXIN,-(sp)
        trap #GEMDOS
        addq.l #2,sp
        move.b d0,d5
        rts
nochr:  or.b #$08,$0297(a6)
        clr.b d5
        rts
grt:    move sr,d4
        bra rt
        
basin:
        move.b $99(a6),d5
        bne get0
        move.b $d3(a6),$ca(a6)
        move.b $d6(a6),$c9(a6)
        bra basn
get0:   cmp.b #$03,d5
        bne get1
        move.b d5,$d0(a6)
        move.b $d5(a6),$c8(a6)
        bra basn
get1:   cmp.b #$02,d5
        beq rsin
        tst.b $90(a6)
        beq iecin
        moveq #$0d,d5
        bra rt

udtim:
        addq.b #1,$a2(a6)
        bne ti
        addq.b #1,$a1(a6)
        bne ti
        addq.b #1,$a0(a6)
ti:     move.b $a2(a6),d2
        subq.b #1,d2
        move.b $a1(a6),d2
        moveq #$1a,d0
        subx.b d0,d2
        move.b $a0(a6),d2
        moveq #$4f,d0
        subx.b d0,d2
        blt ud
        clr $a0(a6)
        clr.b $a2(a6)
ud:     clr.b $91(a6)
        cmp.b #$3f,$cb(a6)
        bne udr
        btst #0,$028d(a6)
        bne udr
        move.b #$7f,$91(a6)
udr:    rts

print:
        tst.b $9d(a6)
        bpl pri
        movem d5-d7,-(sp)
sys:    move.b (a2)+,d5
        beq prg
        bmi epr
        bsr bsout
        bra sys
epr:    and.b #$7f,d5
        bsr bsout
prg:    movem (sp)+,d5-d7
pri:    rts

base:
        sub.l a0,a0
        move.l $44e(a0),scbase
        move.l #scn,$80(a0)
        move.l $118(a0),keysav
        move.l #keyscn,$118(a0)
        move.l $400(a0),evntsav
        move.l $404(a0),critsav
        move.l #crit,$400(a0)
        move.l #crit,$404(a0)
        clr $454(a0)
crit:   rts

con:    sub.l a0,a0
        move.l keysav,$118(a0)
        move.l evntsav,$400(a0)
        move.l critsav,$404(a0)
        move #$08,$454(a0)
        rts

ret64:
        subq #1,d0
        move.b d0,-1(a4)
        lsr #8,d0
        move.b d0,(a4)
        subq.l #2,a4
        rts

exit:
        clr.l -(sp)
        clr -(sp)
        clr -(sp)
        clr -(sp)
        move #XBTIMER,-(sp)
        trap #XBIOS
        add.l #12,sp
        pea con(pc)
        move #SUPEXEC,-(sp)
        trap #XBIOS
        addq.l #6,sp
        pea mon(pc)             *Maus einschalten
        move #1,-(sp)
        move #IKBDWS,-(sp)
        trap #XBIOS
        addq.l #8,sp
        move rez(pc),-(sp)
        pea -1
        pea -1
        move #SSCREEN,-(sp)
        trap #XBIOS
        add.l #12,sp
        pea oldcol
        move #SETPALET,-(sp)
        trap #XBIOS
        addq.l #6,sp
error:  clr -(sp)
        trap #GEMDOS


kadr:
        ds.l 6
        dc.l seclstn,sectalk
        ds.l 2
        dc.l scan
        ds.l 1
        dc.l iecin,iecout
        dc.l untalk,unlstn
        dc.l lstn,talk
        ds.l 3
        dc.l open,close
        dc.l chkin,ckout
        ds.l 1
        dc.l basin,bsout
        dc.l fload,fsave
        ds.l 3
        dc.l get
        ds.l 1
        dc.l udtim
        ds.l 3
        dc.l init

key:
        dc.b $40,$39,$38,$3b,$08,$0b,$10,$13,$18,$1b,$20,$23,$28,$2b,$00,$3f
        dc.b $3e,$09,$0e,$11,$16,$0c,$1e,$21,$26,$29,$2e,$31,$01,$40,$0a,$0d
        dc.b $12,$15,$1a,$1d,$22,$25,$2a,$2d,$32,$36,$40,$40,$19,$17,$14,$1f
        dc.b $1c,$27,$24,$2f,$2c,$37,$40,$40,$40,$3c,$40,$04,$05,$06,$03,$40
        dc.b $40,$40,$40,$40,$40,$40,$40,$33,$40,$40,$2b,$40,$40,$02,$28,$40
        dc.b $07,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
        dc.b $40,$40,$40,$40,$40,$37,$31,$18,$1b,$20,$0b,$10,$13,$38,$3b,$08
        dc.b $23,$2c,$01,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40

basic:  dc.b "c64\_basic.c64",0

kernal: dc.b "c64\_kernal.c64",0

font:   dc.b "c64\_font.c64",0

fileadr:dc.l basic,kernal,font

loadadr:dc.l c64+$a000,c64+$e000,prfont

opage:  ds.l 1

moff:   dc.b $12

mon:    dc.b $80,$01

scbase: ds.l 1

plane:  ds.b 4

click:  dc.b 0,$3b,1,0,2,0,3,0,4,0,5,0,6,0,7,$fe,8,16,13,3,11,$80,12,1,$ff,0

stcode: dc.b 0

c0286:  ds.b 1

tab:    dc.l c64+$eb81          *Default-Tastaturtabelle

rez:    ds 1

msg:    dc.b $1b,"E",$1b,"fC64-Emulator V3.00",$0d,$0a,$0a
        dc.b " Ω 1987 by",$0d,$0a
        dc.b " Uwe Seimet",$0d,$0a
        dc.b " Buchenlochstraûe 29",$0d,$0a
        dc.b " 6750 Kaiserslautern",$0d,$0a
        dc.b " Telefon: 0631/21237",$0d,$0a,$0a,$0a
        dc.b "    Belegung der Sondertasten:",$0d,$0a,$0a
        dc.b "Help: System-Informationen",$0d,$0a
        dc.b "CTRL: Scrolling verlangsamen",$0d,$0a
        dc.b " ALT: Scrolling anhalten",$0d,$0a
        dc.b " Tab: RUN/STOP",$0d,$0a
        dc.b "Undo: Restore",$0d,$0a
        dc.b "  F5: Bildschirmfarbe Ñndern",$0d,$0a
        dc.b "  F6: Zeichenfarbe Ñndern",$0d,$0a
        dc.b "  F7: Hardcopy",$0d,$0a
        dc.b "  F8: Bitmap Åberwachen: "
ff8:    dc.b "+",$0d,$0a
        dc.b "  F9: Bildschirmspeicher Åberwachen: "
ff9:    dc.b "+",$0d,$0a
        dc.b " F10: Emulator verlassen",0


        bss

oldcol: ds 16

sctab:  ds 25

grtab:  ds 256

keysav: ds.l 1

evntsav:ds.l 1

critsav:ds.l 1

set:    ds.b 8192

grbss:  ds.b 4096*3

rezflg: ds.b 1

mflg:   ds.b 1

        ds.l 100
stack:  ds 1
