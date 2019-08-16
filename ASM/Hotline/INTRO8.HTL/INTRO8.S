          opt o+,ow-
realscherm = $78000
 
	move.l 4(a7),base
	
	pea x
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	
	MOVE.L BASE(PC),A5
	LEA GAME(PC),A3
	MOVE.L $2(A3),A0
	ADD.L $6(A3),A0
	LEA $1C(A0),A0
	ADD.L A3,A0
	MOVE.L $8(A5),D0
	LEA GAME+$1C(PC),A1
	TST.L (A0)
	BEQ.s QUIT
	ADD.L (A0)+,A1
NEXT1	ADD.L D0,(A1)
NEXT2	CLR.L D1
	MOVE.B (A0)+,D1
	TST.W D1
	BEQ.s QUIT
	CMP.B #$1,D1
	BNE.s NEXT3
	LEA $FE(A1),A1
	BRA.s NEXT2

NEXT3	ADD.L D1,A1
	BRA.s NEXT1

QUIT	MOVE.L $2(A3),$C(A5)
	MOVE.L $6(A3),$14(A5)
	MOVE.L $A(A3),$1C(A5)
	MOVE.L $8(A5),D0
	MOVE.L $C(A5),D1
	ADD.L D0,D1
	MOVE.L D1,$10(A5)
	MOVE.L $14(A5),D0
	ADD.L D0,D1
	MOVE.L D1,$18(A5)

	LEA COPY(PC),A0
	LEA $7FF00,A1
	MOVEQ #$30,D0
COPY_SET	MOVE.B (A0)+,(A1)+
	DBF D0,COPY_SET

	LEA GAME+$1C(PC),A0
	MOVE.L BASE(PC),A1
	LEA $100(A1),A1
	MOVE.L A1,A3
	MOVE.L #EOF,A2
	JMP $7FF00

COPY	MOVE.L (A0)+,(A1)+
	CMP.L A2,A0
	BLT.s COPY

CLEAR	CLR.L (A1)+
	CMP.L A2,A1
	BLT.s CLEAR
	JMP (A3)

BASE	DC.L $0

GAME	INCBIN filename.prg:hier executable filename
eof

x         dc.w $a00a              ;mouse off
	move.b #$12,$fffc02

          move.w #4,-(sp)         ;get old resolution
          trap   #14
          addq.l #2,sp
          move.w d0,oldrez

          move.l #$ff8240,a0      ;save old palette
          move.l #oldpal,a1
          movem.l (a0),d0-d7
          movem.l d0-d7,(a1)

          pea colors
          move.w #6,-(sp)
          trap #14
          addq.l #6,sp
         
	bsr prepare

	moveq #0,d0
          jsr music+$556
          move.w #1,$4ee
          bsr    hblon            ;switch hbl on
          
waitkey   tst.b syn
          beq.s waitkey
          clr.b syn
          jsr scrsoft
          jsr scrsofta
          cmp.b #$39,$fffc02
          bne.s waitkey

          bsr    hbloff           ;switch hbl off

goon      move.l #oldpal,a0       ;set palette
          move.l #$ff8240,a1
          movem.l (a0),d0-d7
          movem.l d0-d7,(a1)
          move.w #0,-(sp)     ;set resolution
          move.l #$78000,-(sp)
          move.l #$78000,-(sp)
          move.w #5,-(sp)
          trap   #14
          add.l  #12,sp

          dc.w $a009               ;mouse on
          move.b #8,$fffc02
          rts

oldrez    dc.w 0
oldpal    ds.w 16

;-----------------------------
hblon     move.l $120.w,oldtb             ;save all registers
          move.l $118.w,oldkey
          move.l $118.w,newkey2+2
          move.l $70.w,old4
          move.b $fffa07,old07
          move.b $fffa09,old09
          move.b $fffa0b,old0b
          move.b $fffa0d,old0d
          move.b $fffa0f,old0f
          move.b $fffa11,old11
          move.b $fffa13,old13
          move.b $fffa15,old15
          move.b $fffa1b,old1b
          move.b $fffa21,old21

          move.l #contr,a0
          and.b  #$df,$fffa09
          and.b  #$fe,$fffa07
          move.b (a0)+,d0
          cmp.b  #21,d0
          bne    noinst
          move.l #newtb,$120.w            ;install new vectors
          move.l #new4,$70.w
          move.l #newkey,$118.w
          or.b   #1,$fffa07               ;allow timer b interrupt
          or.b   #1,$fffa13
noinst    rts

hbloff    move.w sr,-(sp)
          move.w #$2700,sr
          move.b contr+1,d0
          cmp.b  #4,d0
          bne    noex
          move.b old07,$fffa07            ;restore all registers
          move.b old09,$fffa09
          move.b old0b,$fffa0b
          move.b old0d,$fffa0d
          move.b old0f,$fffa0f
          move.b old11,$fffa11
          move.b old13,$fffa13
          move.b old15,$fffa15
          move.b old1b,$fffa1b
          move.b old21,$fffa21

          move.l oldtb,$120.w             ;restore vectors
          move.l oldkey,$118.w
          move.l old4,$70.w
noex      move.w (sp)+,sr
          rts

old4      dc.l 0
oldtb     dc.l 0
oldkey    dc.l 0
old07     dc.b 0
old09     dc.b 0
old0b     dc.b 0
old0d     dc.b 0
old0f     dc.b 0
old11     dc.b 0
old13     dc.b 0
old15     dc.b 0
old1b     dc.b 0
old21     dc.b 0
syn       dc.b 0

new4      move.b #1,$fffa21        
          move.b #8,$fffa1b        
          move.l #newtb,$120.w
          move.b #8,$fffa1b
          move.w #$777,$ff8244
          jsr music+$2e
          clr.w $ff8246
          clr.w pal
          bclr #0,$fffa0f 
      	rte

newkey    move.w #$2500,sr
newkey2   jmp    $000000

newtb     move.l a6,-(sp)
          lea palette(pc),a6
          add.w pal,a6
          move.w  (a6),$ff8240
          move.w mintcol-palette(a6),$ff8242
          addq.w #2,pal
          move.l (sp)+,a6
          cmp.w #218,pal
          beq.s raster1a
          bclr    #0,$fffa0f              ;end of interrupt
          rte

raster1a  move.w colors+6,$ff8246
          move.l colors+2,$ff8242
          clr.w $ff8240
          move.b #91,$fffa21
          move.l #raster1,$120.w
          move.b #1,syn
          bclr #0,$fffa0f
          rte

raster1   bclr #0,$fffa0f
          rte

contr     dc.b 21,4,15,06
pal       dc.w 0
  
palette   DC.W $0101,$0000,$0101,$0101,$0212,$0101,$0212,$0212 ; LILA
	DC.W $0323,$0212,$0323,$0323,$0434,$0323,$0434,$0434 ; L.LILA
	DC.W $0545,$0434,$0545,$0545,$0656,$0545,$0656,$0656 ; LILA
	DC.W $0767,$0656,$0767,$0767,$0656,$0767	   ; + INTERVAL
	DC.W $0656,$0656,$0545,$0656,$0545,$0545,$0434,$0545 ; #56
	DC.W $0434,$0434,$0323,$0434,$0323,$0323,$0212,$0323
	DC.W $0212,$0212,$0101,$0212,$0101,$0101,$0000,$0101

          DC.W $0101,$0000,$0101,$0101,$0212,$0101,$0212,$0212 ; LILA
	DC.W $0323,$0212,$0323,$0323,$0434,$0323,$0434,$0434 ; L.LILA
	DC.W $0545,$0434,$0545,$0545,$0656,$0545,$0656,$0656 ; LILA
	DC.W $0767,$0656,$0767,$0767,$0656,$0767	   ; + INTERVAL
	DC.W $0656,$0656,$0545,$0656,$0545,$0545,$0434,$0545 ; #56
	DC.W $0434,$0434,$0323,$0434,$0323,$0323,$0212,$0323
	dc.w $0212,$0212,$0101,$0212,$0101,$0101,$0000,$0101
          ds.w 92
          
mintcol   ds.w 27
          dc.w $0010,$0000,$0010,$0010,$0121,$0010,$0121,$0121 ; MINT
	DC.W $0232,$0121,$0232,$0232,$0343,$0232,$0343,$0343 ; L.MINT
	DC.W $0454,$0343,$0454,$0454,$0565,$0454,$0565,$0565 ; MINT
	DC.W $0676,$0565,$0676,$0676,$0565,$0676	   ; + INTERVAL
	DC.W $0565,$0565,$0454,$0565,$0454,$0454,$0343,$0454 ; #56
	DC.W $0343,$0343,$0232,$0343,$0232,$0232,$0121,$0232
	DC.W $0121,$0121,$0010,$0121,$0010,$0010,$0000,$0010
	DC.W $0000,$0000
          ds.w 120
;-----------------------------
prepare  move.w #0,-(sp)                 ;set low res
         move.l #$78000,-(sp)
         move.l #$78000,-(sp)
         move.w #5,-(sp)
         trap   #14
         add.l  #12,sp
         
         lea logo,a0
         lea realscherm+28*160+16,a1
         move.w #$2200/4,d0
copylog  move.l (a0)+,(a1)+
         dbf d0,copylog
         rts

hoogte    =26

scherm0    ds.b 160+hoogte*160
scherm1    ds.b 160+hoogte*160
scherm2    ds.b 160+hoogte*160
scherm3    ds.b 160+hoogte*160
buffer     ds.b 160+hoogte*160

jumptabel dc.l sch1,sch2,sch3,zetdeel
          dc.l sch1,sch2,sch3,zetdeel1
nr        dc.w 0

karnr     dc.w 0
karblok   dc.l chblok+480+$10
          ds.l $c
          dc.l chblok,0
          dc.l chblok+480+$20,chblok+480+$30,chblok+480+$40
          dc.l chblok+480+$50,chblok+480+$60,chblok+480+$70
          dc.l chblok+480+$80,chblok+480+$90,chblok+29*160
          dc.l chblok+30*160+$10,chblok+30*160+$20
          ds.l $6
          dc.l chblok+$1350,chblok+57*160,chblok+57*160+$10
          dc.l chblok+57*160+$20,chblok+57*160+$30
          dc.l chblok+57*160+$40,chblok+57*160+$50
          dc.l chblok+57*160+$60,chblok+57*160+$70
          dc.l chblok+57*160+$80,chblok+57*160+$90
          dc.l chblok+84*160,chblok+84*160+$10,chblok+84*160+$20
          dc.l chblok+84*160+$30,chblok+84*160+$40
          dc.l chblok+84*160+$50,chblok+84*160+$60
          dc.l chblok+84*160+$70,chblok+84*160+$80
          dc.l chblok+84*160+$90,chblok+111*160,chblok+111*160+$10
          dc.l chblok+111*160+$20,chblok+111*160+$30
          dc.l chblok+111*160+$40
          
teken     dc.l 0

;text altijd n HOOFDLETTERS

scrsoft   move.w nr,d0
          addq.w #1,nr
          lsl.w #2,d0
          lea jumptabel,a0
          move.l (a0,d0.w),a1
          jmp (a1)

zetdeel   lea scherm3,a0
          bsr schuif
          lea text,a0
zoekeens  move.w karnr,d0
          clr.w d1
          move.b (a0,d0.w),d1
          bne.s cont
          clr.w karnr
          bra.s zoekeens
          cont:
          addq.w #1,karnr
          sub.w #$21,d1
          bpl.s nospatie
          lea chblok+30*160+$30,a0              ;leeg blok voor space            
          bra.s spatie
nospatie  lsl.w #2,d1
          lea karblok,a0
          move.l (a0,d1.w),a0
spatie    move.l a0,teken
copykars  lea buffer,a1
          lea scherm3+$98,a2
          moveq #hoogte,d7
copykar   movem.w (a0),d0-d3
          clr.w (a1)+
          move.w d0,(a1)+
          clr.w (a1)+
          move.w d1,(a1)+
          clr.w (a1)+
          move.w d2,(a1)+
          clr.w (a1)+
          move.w d3,(a1)+
          movem.w d0-d3,(a2)
          add.l #160,a0
          add.l #160,a2
          dbf d7,copykar
          rts

zetdeel1  lea scherm3,a0
          bsr.s schuif
          clr.w nr
          move.l teken,a0
          addq.w #8,a0
          bra.s copykars

sch1      lea scherm0,a0
          bra.s schuif
sch2      lea scherm1,a0
          bra.s schuif
sch3      lea scherm2,a0
          bra.s schuif
sch4      lea scherm3,a0

schuif    lea buffer,a1
          move.l a0,a3

          moveq #hoogte,d7
rollen    movem.l (a1)+,d0-d3
          lsl.l #4,d0
          lsl.l #4,d1
          lsl.l #4,d2
          lsl.l #4,d3
          movem.l d0-d3,-16(a1)
          swap d0
          swap d1
          swap d2
          swap d3
          or.w d0,$98(a0)
          or.w d1,$9a(a0)
          or.w d2,$9c(a0)
          or.w d3,$9e(a0)
          add.w #160,a0
          dbf d7,rollen

          lea buffer,a1
          lea realscherm+170*160,a2
          moveq #hoogte,d7
schuifzet movem.l (a3),d0-d6
          movem.l d0-d6,(a2)
          movem.l d2-d6,(a3)
          movem.l 28(a3),d0-d6
          movem.l d0-d6,28(a2)
          movem.l d0-d6,20(a3)
          movem.l 56(a3),d0-d6
          movem.l d0-d6,56(a2)
          movem.l d0-d6,48(a3)
          movem.l 84(a3),d0-d6
          movem.l d0-d6,84(a2)
          movem.l d0-d6,76(a3)
          movem.l 112(a3),d0-d6
          movem.l d0-d6,112(a2)
          movem.l d0-d6,104(a3)
          movem.l 140(a3),d0-d4
          movem.l d0-d4,140(a2)
          movem.l d0-d4,132(a3)
          move.w 2(a1),$98(a3)
          move.w 6(a1),$9a(a3)
          move.w 10(a1),$9c(a3)
          move.w 14(a1),$9e(a3)
          add.w #16,a1
          add.w #160,a3
          add.w #160,a2
          dbf d7,schuifzet
          rts
;----------------------------
scherm0a    ds.b 160+hoogte*160
scherm1a    ds.b 160+hoogte*160
scherm2a    ds.b 160+hoogte*160
scherm3a    ds.b 160+hoogte*160
scherm4a    ds.b 160+hoogte*160
scherm5a    ds.b 160+hoogte*160
scherm6a    ds.b 160+hoogte*160
scherm7a    ds.b 160+hoogte*160
buffera     ds.b 160+hoogte*160

jumptabela dc.l sch1a,sch2a,sch3a,sch4a,sch5a,sch6a,sch7a,zetdeela
           dc.l sch1a,sch2a,sch3a,sch4a,sch5a,sch6a,sch7a,zetdeel1a
           dc.l stopscr

nra        dc.w 16

karnra     dc.w 0
       
tekena     dc.l 0

;text altijd in HOOFDLETTERS
texta     dc.b "          ",0
          
scrsofta   move.w nra,d0
          addq.w #1,nra
          lsl.w #2,d0
          lea jumptabela(pc),a0
          move.l (a0,d0.w),a1
          jmp (a1)

zetdeela   lea scherm7a,a0
          bsr schuifa
          lea texta,a0
zoekeensa  move.w karnra,d0
          clr.w d1
          move.b (a0,d0.w),d1
          bne.s conta
           move.w #16,nra
          rts
          conta:
          addq.w #1,karnra
          sub.w #$21,d1
          bpl.s nospatiea
          lea chblok+30*160+$30,a0              ;leeg blok voor space            
          bra.s spatiea
nospatiea  lsl.w #2,d1
          lea karblok,a0
          move.l (a0,d1.w),a0
spatiea    move.l a0,tekena
copykarsa  lea buffera,a1
          lea scherm7a+$98,a2
          moveq #hoogte,d7
copykara   movem.w (a0),d0-d3
          clr.w (a1)+
          move.w d0,(a1)+
          clr.w (a1)+
          move.w d1,(a1)+
          clr.w (a1)+
          move.w d2,(a1)+
          clr.w (a1)+
          move.w d3,(a1)+
          movem.w d0-d3,(a2)
          add.l #160,a0
          add.l #160,a2
          dbf d7,copykara
          rts

zetdeel1a  lea scherm7a,a0
          bsr.s schuifa
          clr.w nra
          move.l tekena,a0
          addq.w #8,a0
          bra.s copykarsa

sch1a     lea scherm0a,a0
          bra.s schuifa
sch2a     lea scherm1a,a0
          bra.s schuifa
sch3a      lea scherm2a,a0
          bra.s schuifa
sch4a      lea scherm3a,a0
          bra.s schuifa
sch5a      lea scherm4a,a0
          bra.s schuifa
sch6a      lea scherm5a,a0
          bra.s schuifa
sch7a      lea scherm6a,a0
schuifa    lea buffera,a1
          move.l a0,a3

          moveq #hoogte,d7
rollena    movem.l (a1)+,d0-d3
          lsl.l #2,d0
          lsl.l #2,d1
          lsl.l #2,d2
          lsl.l #2,d3
          movem.l d0-d3,-16(a1)
          swap d0
          swap d1
          swap d2
          swap d3
          or.w d0,$98(a0)
          or.w d1,$9a(a0)
          or.w d2,$9c(a0)
          or.w d3,$9e(a0)
          add.w #160,a0
          dbf d7,rollena

          lea buffera,a1
          lea realscherm+124*160,a2
          moveq #hoogte,d7
schuifzeta movem.l (a3),d0-d6
          movem.l d0-d6,(a2)
          movem.l d2-d6,(a3)
          movem.l 28(a3),d0-d6
          movem.l d0-d6,28(a2)
          movem.l d0-d6,20(a3)
          movem.l 56(a3),d0-d6
          movem.l d0-d6,56(a2)
          movem.l d0-d6,48(a3)
          movem.l 84(a3),d0-d6
          movem.l d0-d6,84(a2)
          movem.l d0-d6,76(a3)
          movem.l 112(a3),d0-d6
          movem.l d0-d6,112(a2)
          movem.l d0-d6,104(a3)
          movem.l 140(a3),d0-d4
          movem.l d0-d4,140(a2)
          movem.l d0-d4,132(a3)
          move.w 2(a1),$98(a3)
          move.w 6(a1),$9a(a3)
          move.w 10(a1),$9c(a3)
          move.w 14(a1),$9e(a3)
          add.w #16,a1
          add.w #160,a3
          add.w #160,a2
          dbf d7,schuifzeta
          rts
regnr     dc.w 0
delay     dc.b 0
spmod     dc.b 0
  
stopscr   tst.b delay  
          bne.s stopdec
          move.b #40,delay
          clr.w karnra
          clr.w nra
          bchg #0,spmod
          tst.b spmod
          bne.s nospaces
          lea texta,a0
          move.w #$2020,(a0)+
          move.w #$2020,(a0)+
          move.w #$2020,(a0)+
          move.w #$2020,(a0)+
          move.w #$2020,(a0)
          rts
nospaces  move.w regnr,d0
          addq.w #1,regnr
          move.w d0,d1
          lsl.w #3,d0
          lsl.w #1,d1
          add.w d1,d0
          lea textregel,a0
          lea texta,a1
          cmp.w #-1,(a0,d0.w)
          bne.s contin
          clr.w regnr
          clr.w d0 
contin    add.w d0,a0
          move.w (a0)+,(a1)+
          move.w (a0)+,(a1)+
          move.w (a0)+,(a1)+
          move.w (a0)+,(a1)+
          move.w (a0),(a1) 
          rts

stopdec   subq.b #1,delay
          move.w #16,nra
          rts

textregel dc.b " HOTLINE! "
          dc.b " PRESENTS "
          dc.b "INTRO 3.0!"
          dc.b "  BY LAIR "
          dc.w -1

;alle letter in HOOFDLETTERS
text      dc.b "THIS INTRO IS CODED BY LAIR OF HOTLINE IN 1989"
          DC.B " ... A HELLO TO ALL MEMBERS TO HOTLINE! ..... "
          DC.B "                                           ",0

music   incbin \intro8.htl\overland.mus
colors  incbin \intro8.htl\color.*
chblok  incbin \intro8.htl\chars.pic
logo    incbin \intro8.htl\logo.pic
;-----------------------------
