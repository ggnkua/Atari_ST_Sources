*Ganz ohne Systemaufrufe geht es nicht

BIOS = 13
KBSHIFT = 11

XBIOS = 14
DMAREAD = 42


*Einige Systemvariablen

_bootdev = $446
_hz_200 = $4ba
_drvbits = $4c2
_sysbase = $4f2
pun_ptr = $516
_p_cookies = $5a0


*Hardware-Register, von Atari
*nicht dokumentierte IDE-Register :-)

gpip = $fffffa01

idedr = $fff00000	;Data Register (R/W)
idesc = $fff00009	;Sector Count (R/W)
idesn = $fff0000d	;Sector Number (R/W)
idecl = $fff00011	;Cylinder Low (R/W)
idech = $fff00015	;Cylinder High (R/W)
idesdh = $fff00019	;Drive/Head (R/W)
idecr = $fff0001d	;Command Register (W)
idesr = $fff0001d	;Status Register (R)
idedor = $fff00039	;Device Control (W)
ideasr = $fff00039	;Alternate Status (R)


*Rootprogramm fÅr Booten von IDE-Bus

	globl start,end,idepars

start:
	bra.s .srstart
	bra .srread

.srstart:clr.l pun_ptr
	bclr #2,_drvbits+3
	movem.l d3/d5,-(sp)
	move #-1,-(sp)
	move #KBSHIFT,-(sp)
	trap #BIOS
	addq.l #4,sp
	btst #3,d0
	bne.s .srexit
	btst #0,d0		;Shift rechts?
	beq.s .noshift		;nein-
	tst.b d5
	beq.s .noshift		;keine PrÑferenz
	eor.b #$c0,d5		;Maske wechseln
.noshift:moveq #3,d0
	moveq #-$08,d1
	lea start+$1c6(pc),a0
   	cmp.l #"DMAr",d3	;Booten von SCSI/IDE-Bus?
	beq.s .dma		;ja-
	moveq #-$80,d2		;PrÑferenz TOS
	bra.s .test1
.dma:	move.b d5,d2
	beq.s .test2
.test1:	btst #0,(a0)		;Booten mit PrÑferenz
	beq.s .noval1
	and.b d1,(a0)
	cmp.b (a0),d2
	beq.s .srtos
.noval1:lea 12(a0),a0
	dbra d0,.test1
	bra.s .srexit
.test2:	btst #0,(a0)		;Booten ohne PrÑferenz
	beq.s .noval2
	and.b d1,(a0)
	bne.s .srtos
.noval2:lea 12(a0),a0
	dbra d0,.test2
.srexit:movem.l (sp)+,d3/d5
.tostest:clr _bootdev
	move.l _sysbase,a0
	move.l $18(a0),d0
	swap d0
	cmp.l #$19870422,d0	;altes TOS?
	bcc.s .srret		;nein-
	move #$e0,d7
.srret:	rts
.srtos:	move.l 4(a0),d6
	moveq #1,d5
	lea start+512(pc),a4
	bsr.s .srread
	tst d0
	bne .srexit
	move.l a4,a0
	move.w #$ff,d1
	moveq #0,d0
.srchk:	add (a0)+,d0
	dbra d1,.srchk
	cmp #$1234,d0
	bne .srexit		;nicht ausfÅhrbar-
	lea .srread(pc),a3
	lea .tostest(pc),a5
	movem.l (sp)+,d3/d5
	jmp (a4)		;Bootprogramm ausfÅhren
.srread:btst #4,d4
	bne.s .sride		;Booten von IDE-Bus-
	move d4,-(sp)
	pea (a4)
	move d5,-(sp)
	move.l d6,-(sp)
	move #DMAREAD,-(sp)
	trap #XBIOS
	lea 14(sp),sp
	rts

*Die folgenden Routinen entstanden in
*Anlehnung an Ideen von Jens Fellmuth

.sride:	lea idepars(pc),a6
	tst.b (a6)
	bne.s .pars		;IDE-Parameter sind vorhanden-
	move.b d4,d0
	and.b #1,d0
	asl.b #4,d0
	or.b #$a0,d0
	move.b d0,idesdh
	move.l a4,a0
	moveq #0,d1
	move.b #0,idedor
	move.b #$ec,idecr	;IDENTIFY DRIVE
	bsr.s .w4int
	bne.s .err
	move.b 7(a4),(a6)	;Kîpfe
	move.b 13(a4),1(a6)	;Sektoren pro Spur
.pars:	move.l d6,d1
	moveq #0,d0
	move.b 1(a6),d0
	moveq #0,d2
	move.b (a6),d2
	mulu d0,d2
	divu d2,d1
	move.b d1,idecl		;Cylinder low
	lsr.l #8,d1
	move.b d1,idech		;Cylinder high
	lsr.l #8,d1
	divu d0,d1		;Head
	move.b d4,d0
	and.b #1,d0
	asl.b #4,d0
	or.b d0,d1
	or.b #$a0,d1		;Drive 0 (Master)
	move.b d1,idesdh
	swap d1
	addq #1,d1
	move.b d1,idesn		;Sector number
	move.l a4,a0
	move.b d5,idesc		;Sector count
	move d5,d1
	subq #1,d1
	move.b #0,idedor
	move.b #$20,idecr	;READ SECTOR
.w4int:	move.l #$7d0,d0
	add.l _hz_200,d0
.wait:	btst #5,gpip
	beq.s .cont
	cmp.l _hz_200,d0
	bhi.s .wait
.err:	moveq #-1,d0
	rts
.cont:	move.b idesr,d0
	btst #0,d0
	bne.s .err
	btst #3,d0
	beq.s .err
	moveq #63,d0
	lea idedr,a1
.loop:	move.l (a1),(a0)+
	move.l (a1),(a0)+
	dbra d0,.loop
	dbra d1,.w4int
	moveq #0,d0
	rts
idepars:dcb.b 2,0
end:	dc.b 0


	even

	globl testide,identify

*Auf IDE-Hardware testen

testide:
	pea (a2)
	sub.l a2,a2
	move.l _p_cookies,d0
	beq.s nocook

	move.l d0,a0
cook:	movem.l (a0)+,d0-d1
	tst.l d0
	beq.s nocook
	cmp.l #"_CPU",d0
	bne.s cook
	cmp #10,d1
	bcs.s nocook
	movec vbr,a2

nocook:
	moveq #0,d0
	move sr,-(sp)
	ori #$0700,sr
	move.l sp,a1
	move.l $08(a2),a0
	move.l #nide,$08(a2)
	tst.b idecl
	moveq #-1,d0
nide:	move.l a0,$08(a2)
	move.l a1,sp
	move (sp)+,sr

	move.l (sp)+,a2
	rts

identify:
	pea (a2)
	move.l a0,a1
	move.b #$a0,idesdh
	moveq #-1,d0
	tst.b idedor
	ble.s idret
	move.b #0,idedor
	move.b #$ec,idecr		;IDENTIFY DRIVE
	move.l #500,d0
	bsr wait2
	bmi.s idret
	btst #3,d0
	beq.s idret
	bsr.s readbuf
	moveq #0,d0
idret:	move.l (sp)+,a2
	rts

*Daten von IDE-Bus abholen

readbuf:
	move.l a1,a0
	move #255,d0
	lea idedr,a2
rloop:	move (a2),(a1)+
	dbra d0,rloop
	move.l a0,a1
	rts

*IDE-Interrupt abwarten

w4int:
	move.l #$7d0,d0
wait2:	add.l _hz_200,d0
wide:	btst #5,gpip
	beq.s wcont
	cmp.l _hz_200,d0
	bhi.s wide
	moveq #-1,d0
	rts
wcont:	moveq #0,d0
	move.b idesr,d0
wret:	rts
