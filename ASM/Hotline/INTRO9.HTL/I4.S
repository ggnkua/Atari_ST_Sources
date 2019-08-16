	OPT O+,OW-

	MOVE.L $4(A7),BASE

	DC.W $A00A

	PEA INTRO
	MOVE.W #$26,-(SP)
	TRAP #$E
	ADDQ.L #$6,SP 

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
	DC.W $A009
	JMP (A3)

BASE	DC.L $0

GAME	INCBIN FILE.PRG
EOF
;------------------------------
INTRO	dc.w $a00a	;mouse off
	move.b #$12,$fffc02

	move.w #4,-(sp)	;get old resolution
	trap   #14
	addq.l #2,sp
	move.w d0,oldrez

          move.l #$ff8240,a0	;save old palette
          move.l #oldpal,a1
          movem.l (a0),d0-d7
          movem.l d0-d7,(a1)

	pea colors
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp

          bsr prepare	;prepare screen
          
	lea	music,a0
	lea	$70000,a1
	lea	logo,a2
copymus	move.b	(a0)+,(a1)+
	cmp.l	a0,a2
	bne.s	copymus	

	moveq	#0,d0
	jsr	$70000
	
	bsr hblon		;switch hbl on
	         
waitkey   tst.b syn
          bne.s waitkey
	move.b #1,syn

	jsr $70008
	bsr bounce
	bsr starfield
	bsr logocop	;logo op scherm laten komen
	cmp.b #$39,$fffc02
          bne.s waitkey

          bsr	hbloff	;switch hbl off
	jsr	music+4

goon      move.l #oldpal,a0	;set palette
          move.l #$ff8240,a1
          movem.l (a0),d0-d7
          movem.l d0-d7,(a1)
          move.w #0,-(sp)	;set resolution
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          move.w #5,-(sp)
          trap   #14
          add.l  #12,sp

          dc.w $a009	;mouse on
          move.b #8,$fffc02
          rts

oldrez    dc.w 0
oldpal    ds.w 16
syn	dc.b 0
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

new4      clr.b $fffa1b
          move.b #2,$fffa21          ;set data register
          move.b #8,$fffa1b               ;start timer
          clr.w $ff8240
	move.w colors+2,$ff8242
	move.w colors+2,$ff8252
	move.l colors+4,$ff8244
	move.l colors+4,$ff8254
	move.l colors+8,$ff8248
	move.l colors+8,$ff8258
	move.l colors+12,$ff824c
	move.l colors+12,$ff825c
	move.w #$444,$ff8250
	clr.b syn
	clr.w pal
          move.l #newtb,$120.w
	rte

newkey    move.w #$2500,sr
newkey2   jmp    $000000

newtb     move.l a6,-(sp)
          lea starpal(pc),a6
          add.w pal(pc),a6
	move.w bouncepal-starpal(a6),$ff8240
          move.w (a6),$ff8250
	addq.w   #2,pal
          move.l (sp)+,a6
          cmp.w #77*2,pal
	beq.s nextb
	bclr    #0,$fffa0f              ;end of interrupt
          rte

nextb     clr.w  $ff8242
	move.l colors1+4,$ff8244
	move.l colors1+4,$ff8254
	move.l colors1+8,$ff8248
	move.l colors1+8,$ff8258
	move.l colors1+12,$ff824c
	move.l colors1+12,$ff825c
	clr.w pal
	move.b #1,$fffa21
	move.l #newtb1,$120.w	
	bclr #0,$fffa0f
	rte

newtb1    move.l a6,-(sp)
	lea backpal(pc),a6
	add.w pal(pc),a6
	move.w (a6),$ff8240
	move.w colpal-backpal(a6),$ff8252
	move.w (a6),$ff8250
	addq.w #2,pal
	move.l (sp)+,a6
	bclr #0,$fffa0f
	rte

contr     dc.b 21,4,15,06
pal       dc.w 0

starpal 	ds.w 78

starbuf 	dc.w $222,$333,$444,$555,$222,$555,$666,$333,$444,$333
	dc.w $333,$222,$555,$444,$333,$222,$333,$222,$555,$222
	dc.w $333,$444,$555,$555,$222,$666,$222,$666,$222,$333
	dc.w $666,$444,$333,$555,$222,$222,$222,$333,$444,$333
	dc.w $222,$222,$222,$333,$444,$666,$444,$222,$333,$333
	dc.w $222,$333,$444,$555,$555,$444,$333,$222,$666,$555
	dc.w $555,$444,$333,$222,$222,$333,$333,$444,$555,$111
	dc.w $222,$333,$666,$222,$444,$333,$555,$555,$555,$666
	dc.w $222,$444,$333,$333,$333,$666,$666,$666,$444,$444
	dc.w $222,$555,$444,$333,$666,$555,$333,$222,$666,$444

bouncepal	ds.w 80

backpal	dc.w $100,$200,$300,$400
	dc.w $500,$600,$700,$700,$711,$711
	dc.w $722,$722,$733,$733,$744,$744,$755,$755
	dc.w $766,$766,$777,$777,$777,$777
	dc.w $667,$667,$557,$557,$447,$447,$337,$337
	dc.w $227,$227,$117,$117,7,7,6,5,4,3,2,1,0

colpal	ds.w 13
	dc.w 0,5,6,7,6,5
	dc.w 0,$500,$600,$700,$600,$500
	dc.w 0,$50,$60,$70,$60,$50
	dc.w 0,0,0,0,0,0,0,0,0
;----------------------------
bind0	dc.w 0
bind1	dc.w 8
bind2	dc.w 16
bind3	dc.w 24
bind4	dc.w 32

balkcol	dc.w 0,1,2,3,3,2,1,0
	dc.w 1,2,3,4,4,3,2,1
	dc.w 2,3,4,5,5,4,3,2
	dc.w 3,4,5,6,6,5,4,3
	dc.w 4,5,6,7,7,6,5,4

bounce 	lea starpal(pc),a2
	lea starbuf(pc),a1
	lea bouncepal(pc),a0
	moveq #77,d0
clearpal	clr.w (a0)+
	move.w (a1)+,(a2)+
	dbf d0,clearpal
	
	lea balkcol(pc),a1
	lea bind0(pc),a3
	bsr.s copybalk
	bsr.s copybalk
	bsr.s copybalk
	bsr.s copybalk
	bsr.s copybalk
	rts

copybalk	lea bdata(pc),a0
bagain	move.w (a3),d0
	move.w (a0,d0.w),d1
	cmp.w #-1,d1
	bne.s newdata
	clr.w (a3)
	bra.s bagain
newdata	lsl.w #1,d1
	add.w d1,a2
	addq.w #2,(a3)
	lea bouncepal(pc),a2
	lea starpal(pc),a4
	add.w d1,a2
	add.w d1,a4
	moveq #7,d0
copycol	move.w (a1),(a2)+
	move.w (a1)+,(a4)+
	dbf d0,copycol
	addq.w #2,a3
	rts

bdata	dc.w 1,1,1,2,2,3,3,4,5,6
	dc.w 6,7,8,9,10,12,13,14,16,17
	dc.w 19,21,22,24,26,28,30,32,34,36
	dc.w 38,40,42,44,46,48,50,51,53,55
	dc.w 56,58,59,60,61,62,63,63,65,65
	dc.w 66,67,68,68,69,69,70,70,70,71
	dc.w 71,71,71,70,70,70,69,69,68,68
	dc.w 67,66,65,65,63,63,62,61,60,59
	dc.w 58,56,55,53,51,50,48,46,44,42
	dc.w 40,38,36,34,32,30,28,26,24,22
	dc.w 21,19,17,16,14,13,12,10,9,8
	dc.w 7,6,6,5,4,3,3,2,2,1
	dc.w 1,1,0,0,0,0
	dc.w -1
;-----------------------------
prepare  move.w #0,-(sp)                 ;set low res
         move.l #$78000,-(sp)
         move.l #$78000,-(sp)
         move.w #5,-(sp)
         trap   #14
         add.l  #12,sp
         rts

;-----------------------------
realscherm = $78000
aantstar   = 76

speedblok	dc.w 0,319,318,318,316,315

starfield	lea realscherm+6,a0
	lea starpos(pc),a1
	lea orblok(pc),a2
	lea speed(pc),a3
	lea speedblok(pc),a4

	moveq #aantstar-1,d7
starset	clr.l d0
	move.w (a1),d0
	bge.s groterze
	move.w (a3)+,d6
	lsl.w #1,d6
	move.w (a4,d6.w),(a1)+
	and.w #$7ff,(a0)
	add.w #320,a0
	dbf d7,starset
	rts

groterze	divu #16,d0
	lsl.w #3,d0
	move.w d0,d1
	swap d0
	asl.w #1,d0
	clr.w 8(a0,d1.w)
	move.w (a2,d0.w),(a0,d1.w)
	move.w (a3)+,d6
	sub.w d6,(a1)+
	add.w #320,a0
	dbf d7,starset
	rts

orblok	dc.w %1000000000000000
        	dc.w %0100000000000000
        	dc.w %0010000000000000
        	dc.w %0001000000000000
        	dc.w %0000100000000000
        	dc.w %0000010000000000
        	dc.w %0000001000000000
        	dc.w %0000000100000000
        	dc.w %0000000010000000
        	dc.w %0000000001000000
        	dc.w %0000000000100000
        	dc.w %0000000000010000
        	dc.w %0000000000001000
        	dc.w %0000000000000100
        	dc.w %0000000000000010
        	dc.w %0000000000000001

speed	dc.w 1,2,3,4,1,4,5,2,3,2
	dc.w 2,1,4,3,2,1,2,1,4,1
	dc.w 2,3,4,4,1,5,1,5,1,2
	dc.w 5,3,2,4,1,1,1,2,3,2
	dc.w 1,1,1,2,3,5,3,1,2,2
	dc.w 1,2,3,4,4,3,2,1,5,4
	dc.w 4,3,2,1,1,2,2,3,4,1
	dc.w 1,2,5,1,3,2,4,4,4,5
	dc.w 1,3,2,2,2,5,5,5,3,3
	dc.w 1,4,3,2,5,4,2,1,5,3
	
starpos	dc.w 100,200,150,244,302,40,144,133,20,100
	dc.w 190,122,301,20,106,189,160,80,103,300 
	dc.w 140,40,189,203,87,287,123,98,47,65
	dc.w 187,209,289,317,105,20,160,40,90,287
	dc.w 1,67,123,178,205,187,304,20,60,133
	dc.w 150,165,304,253,13,87,199,305,178,33
	dc.w 87,264,313,153,156,167,303,101,202,30	
	dc.w 76,150,203,303,50,67,111,198,204,310	
	dc.w 40,40,20,78,103,169,20,303,270,260	
	dc.w 101,202,303,170,40,270,310,60,44,102

regtel	dc.b 77         ;regelnr teller

savepo    dc.l logo,logo+155*160,realscherm+$20,realscherm+155*160+$20

logocop	tst.b regtel
	beq eindlog
	movem.l savepo(pc),a0-a3
	movem.w (a0),d0-d2
	movem.w d0-d2,(a2)
	movem.w 8(a0),d0-d2
	movem.w d0-d2,8(a2)
	movem.w 16(a0),d0-d2
	movem.w d0-d2,16(a2)
	movem.w 24(a0),d0-d3
	movem.w d0-d2,24(a2)
	movem.w 32(a0),d0-d2
	movem.w d0-d2,32(a2)
	movem.w 40(a0),d0-d2
	movem.w d0-d2,40(a2)
	movem.w 48(a0),d0-d2
	movem.w d0-d2,48(a2)
	movem.w 56(a0),d0-d2
	movem.w d0-d2,56(a2)
	movem.w 64(a0),d0-d2
	movem.w d0-d2,64(a2)
	movem.w 72(a0),d0-d2
	movem.w d0-d2,72(a2)
	movem.w 80(a0),d0-d2
	movem.w d0-d2,80(a2)
	movem.w 88(a0),d0-d2
	movem.w d0-d2,88(a2)
	movem.w (a1),d0-d2
	movem.w d0-d2,(a3) 
	movem.w 8(a1),d0-d2
	movem.w d0-d2,8(a3)
	movem.w 16(a1),d0-d2
	movem.w d0-d2,16(a3)
	movem.w 24(a1),d0-d2
	movem.w d0-d2,24(a3)
	movem.w 32(a1),d0-d2
	movem.w d0-d2,32(a3)
	movem.w 40(a1),d0-d2
	movem.w d0-d2,40(a3)
	movem.w 48(a1),d0-d2
	movem.w d0-d2,48(a3)
	movem.w 56(a1),d0-d2
	movem.w d0-d2,56(a3)
	movem.w 64(a1),d0-d2
	movem.w d0-d2,64(a3)
	movem.w 72(a1),d0-d2
	movem.w d0-d2,72(a3)
	movem.w 80(a1),d0-d2
	movem.w d0-d2,80(a3)
	movem.w 88(a1),d0-d2
	movem.w d0-d2,88(a3)
          add.l #320,savepo
	add.l #320,savepo+8
	sub.l #320,savepo+4	
	sub.l #320,savepo+12
	subq.b #1,regtel
	rts
eindlog 	jsr scrsoft
	rts

hoogte    =30

scherm0    ds.b 160+hoogte*160
scherm1    ds.b 160+hoogte*160
scherm2    ds.b 160+hoogte*160
scherm3    ds.b 160+hoogte*160
buffer     ds.b 160+hoogte*160

jumptabel dc.l sch1,sch2,sch3,zetdeel
          dc.l sch1,sch2,sch3,zetdeel1
nr        dc.w 0

karnr     dc.w 0
karblok   dc.l metalchr+32*160
	ds.l 6
	dc.l metalchr+128*160,metalchr+128*160+$10
	ds.l 3
	dc.l metalchr+128*160+$30
	dc.l metalchr+128*160+$20,metalchr+128*160+$50
          dc.l metalchr,metalchr+$10,metalchr+$20,metalchr+$30,metalchr+$40
          dc.l metalchr+$50,metalchr+$60,metalchr+$70,metalchr+$80
	dc.l metalchr+$90
	dc.l metalchr+32*160+$10
	ds.l 4
	dc.l metalchr+32*160+$20
	ds.l 1
	dc.l metalchr+32*160+$30,metalchr+32*160+$40,metalchr+32*160+$50
	dc.l metalchr+32*160+$60,metalchr+32*160+$70,metalchr+32*160+$80
	dc.l metalchr+32*160+$90
	dc.l metalchr+64*160,metalchr+64*160+$10,metalchr+64*160+$20
	dc.l metalchr+64*160+$30,metalchr+64*160+$40,metalchr+64*160+$50
	dc.l metalchr+64*160+$60,metalchr+64*160+$70,metalchr+64*160+$80
	dc.l metalchr+64*160+$90
	dc.l metalchr+96*160,metalchr+96*160+$10,metalchr+96*160+$20
	dc.l metalchr+96*160+$30,metalchr+96*160+$40,metalchr+96*160+$50
	dc.l metalchr+96*160+$60,metalchr+96*160+$70,metalchr+96*160+$80


teken     dc.l 0

scrsoft   move.w nr(pc),d0
          addq.w #1,nr
          lsl.w #2,d0
          lea jumptabel(pc),a0
          move.l (a0,d0.w),a1
          jmp (a1)

zetdeel   lea scherm3(pc),a0
          bsr schuif
          lea text(pc),a0
zoekeens  move.w karnr(pc),d0
          clr.w d1
          move.b (a0,d0.w),d1
          bne.s cont
          clr.w karnr
          bra.s zoekeens
          cont:
          addq.w #1,karnr
          sub.w #$21,d1
          bpl.s nospatie
          lea metalchr+96*160+$90,a0		;leeg blok voor space            
          bra.s spatie
nospatie  lsl.w #2,d1
          lea karblok(pc),a0
          move.l (a0,d1.w),a0
spatie    move.l a0,teken
copykars  lea buffer(pc),a1
          lea scherm3+$98(pc),a2
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
          add.w #160,a0
          add.w #160,a2
          dbf d7,copykar
          rts

zetdeel1  lea scherm3(pc),a0
          bsr.s schuif
          clr.w nr
          move.l teken(pc),a0
          addq.w #8,a0
          bra.s copykars

sch1      lea scherm0(pc),a0
          bra.s schuif
sch2      lea scherm1(pc),a0
          bra.s schuif
sch3      lea scherm2(pc),a0
schuif    lea buffer(pc),a1
          move.l a0,a3

          moveq #hoogte,d7
rollen    movem.l (a1),d0-d2
          lsl.l #4,d0
          lsl.l #4,d1
          lsl.l #4,d2
          movem.l d0-d2,(a1)
          swap d0
          swap d1
          swap d2
          or.w d0,$98(a0)
          or.w d1,$9a(a0)
          or.w d2,$9c(a0)
          add.w #160,a0
	add.w #16,a1
          dbf d7,rollen

          lea buffer(pc),a1
          lea realscherm+162*160,a2
	moveq #hoogte,d7
schuifzet movem.w (a3),d0-d2
          movem.w d0-d2,(a2)
	movem.w 8(a3),d0-d2
	movem.w d0-d2,8(a2)
	movem.w d0-d2,(a3)
	movem.w 16(a3),d0-d2
	movem.w d0-d2,16(a2)
	movem.w d0-d2,8(a3)
	movem.w 24(a3),d0-d2
	movem.w d0-d2,24(a2)
	movem.w d0-d2,16(a3)
	movem.w 32(a3),d0-d2
	movem.w d0-d2,32(a2)
	movem.w d0-d2,24(a3)
	movem.w 40(a3),d0-d2
	movem.w d0-d2,40(a2)
	movem.w d0-d2,32(a3)
	movem.w 48(a3),d0-d2
	movem.w d0-d2,48(a2)
	movem.w d0-d2,40(a3)
	movem.w 56(a3),d0-d2
	movem.w d0-d2,56(a2)
	movem.w d0-d2,48(a3)	
	movem.w 64(a3),d0-d2
	movem.w d0-d2,64(a2)
	movem.w d0-d2,56(a3)
	movem.w 72(a3),d0-d2
	movem.w d0-d2,72(a2)
	movem.w d0-d2,64(a3)
	movem.w 80(a3),d0-d2
	movem.w d0-d2,80(a2)
	movem.w d0-d2,72(a3)
	movem.w 88(a3),d0-d2
	movem.w d0-d2,88(a2)
	movem.w d0-d2,80(a3)
	movem.w 96(a3),d0-d2
	movem.w d0-d2,96(a2)
	movem.w d0-d2,88(a3)
	movem.w 104(a3),d0-d2
	movem.w d0-d2,104(a2)
	movem.w d0-d2,96(a3)
	movem.w 112(a3),d0-d2
	movem.w d0-d2,112(a2)
	movem.w d0-d2,104(a3)
	movem.w 120(a3),d0-d2
	movem.w d0-d2,120(a2)
	movem.w d0-d2,112(a3)
	movem.w 128(a3),d0-d2
	movem.w d0-d2,128(a2)
	movem.w d0-d2,120(a3)
	movem.w 136(a3),d0-d2
	movem.w d0-d2,136(a2)
	movem.w d0-d2,128(a3)
	movem.w 144(a3),d0-d2
	movem.w d0-d2,144(a2)
	movem.w d0-d2,136(a3)
	movem.w 152(a3),d0-d2
	movem.w d0-d2,152(a2)
	movem.w d0-d2,144(a3)
	move.w 2(a1),$98(a3)
          move.w 6(a1),$9a(a3)
          move.w 10(a1),$9c(a3)
          move.w 14(a1),$9e(a3)
          add.w #16,a1
          add.w #160,a3
          add.w #160,a2
          dbf d7,schuifzet

mus	tst.b	vudelay
	beq.s	nuvu
	subq.b	#1,vudelay
	rts
nuvu	move.b	#1,vudelay
	lea	realscherm+170*160+6,a1
	lea	$ff8800,a0

	move.b	#0,(a0)
	bsr.s	vumet
	add.w	#800,a1
	move.b	#2,(a0)
	bsr.s	vumet
	add.w	#800,a1
	move.b	#4,(a0)	

vumet	clr.l	d0
	move.b	(a0),d0
	divu	#16,d0
	move.w	d0,d7
	moveq	#17,d5
	sub.w	d7,d5
	swap	d0
	lsl.w	#1,d0
	lea	uitslag(pc),a2
	move.w	(a2,d0.w),d6
zetuit	move.w	#$ffff,(a1)
	move.w	#$ffff,480(a1)	
	move.w	#$ffff,320(a1)
	move.w	#$ffff,160(a1)
	move.w	#$ffff,640(a1)
	addq.w	#8,a1
	dbf	d7,zetuit
	move.w	d6,480(a1)
	move.w	d6,160(a1)
	move.w	d6,320(a1)
	move.w	d6,640(a1)
	move.w	d6,(a1)
	addq.w	#8,a1
clearuit	clr.w	160(a1)
	clr.w	320(a1)
	clr.w	480(a1)
	clr.w	640(a1)
	clr.w	(a1)
	addq.w	#8,a1
	dbf	d5,clearuit
	rts

vudelay	dc.b	3

uitslag	dc.w	0
	dc.w	%1000000000000000
	dc.w	%1100000000000000
	dc.w	%1110000000000000
	dc.w	%1111000000000000
	dc.w	%1111110000000000
	dc.w	%1111111000000000
	dc.w	%1111111100000000
	dc.w	%1111111110000000
	dc.w	%1111111111000000
	dc.w	%1111111111100000
	dc.w	%1111111111110000
	dc.w	%1111111111111000
	dc.w	%1111111111111100
	dc.w	%1111111111111110

;-----------------------------
;TEXT ALWAYS IN CAPITALS !!! ( NO KOMMA'S ! )
text      dc.b "THIS INTRO WAS CODED AND DESIGNED BY (( LAIR ))   .."
	DC.B "   MEGA-GRAPHIX BY -SENSE- !!                       "
	dc.b 0 
;-----------------------------

metalchr	incbin \intro9.htl\metal.pic
music	incbin \intro9.htl\music1.img
logo	incbin \intro9.htl\logo.pic
colors	incbin \intro9.htl\colors.img
colors1	incbin \intro9.htl\colors1.img	

