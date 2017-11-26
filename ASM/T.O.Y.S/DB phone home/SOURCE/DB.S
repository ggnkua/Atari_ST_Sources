 	opt	a+,x+
*
*	4K hoppa skutta spel!
*


DEBUG	equ 0
FLERA	equ 0
EXIT	equ 0


ant_n„sor	equ 25

	SECTION TEXT

*--[ Fixxa till fiendeobjekt ]--*
	rsreset
e_type	rs.w	1
e_x	rs.w	1
e_y	rs.w	1
e_dx	rs.w	1
e_size:	rs.b	1



*--[ 
START:
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	IFNE	EXIT
	addq.l	#6,sp
	move.l	d0,-(sp)
	ENDC

	IFEQ	DEBUG
	IFNE	EXIT
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	D0,-(sp)
	move.l	#$58ffff,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	D0,-(sp)
	ENDC

*--[ Set VGA 320*200 TC ]--*
	lea	VGA(pc),a6
	move.w	#$59,-(a7)
	trap	#14
	addq.l	#2,a7
	cmp.b	#2,d0
	beq.s	.vga
	lea	VGA(pc),a6
.vga:
	lea	$ffff8282.w,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)
	lea	$ffff82a2.w,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.w	#$200,$ffff820a.w
	move.w	(a6)+,$ffff82c0.w
	clr.w	$ffff8266.w
	bset.b	#0,$ffff8266.w
	move.w	(a6)+,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	ENDC


	IFNE	EXIT
	move.l	$118.w,-(sp)
	ENDC
	IFEQ	DEBUG
	move.l	#Min_KeyVec,$118.w
	ENDC




*--[ Nolla alla variabler ]--*
NyttSpel:
*---------------------------------------------------------------*
*	InitieraSpel						*
*---------------------------------------------------------------*
	lea	BSS_START(pc),a0
	move.w	#(BSS_SLUT-BSS_START)/4/4-1,d0
.rensa:
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,.rensa	

	move.w	#ant_n„sor,N„sor
	lea	SpriteData(pc),a0
	lea	18(a0),a1
	lea	gfx_ET(pc),a2
	moveq	#5,d7
InitieraSpelLoop:
	bsr	ExpanderaBlock
	dbra	d7,InitieraSpelLoop
	move.w	#3,Liv
	IFNE	FLERA
	clr.w	Level
	ENDC
*--[ Packa upp banblocken ]--*
	lea	BlockData(pc),a0
	lea	BlockData+32(pc),a1
	lea	BanBlock(pc),a2
	moveq.l	#15,d7
.loop:
	bsr	ExpanderaBlock
	dbra	d7,.loop
*--[ Fixxa till en DB ]--*
	lea	gfx_ET(pc),a0
	lea	BanBlock+512*3(pc),a1
	move.w	#254,d0
.maska:
	move.w	(a0)+,d1
	beq.s	.skutt
	move.w	d1,(a1)
.skutt:
	addq.w	#2,a1
	dbra	d0,.maska
	
*---------------------------------------------------------------*
*	InitieraLevel						*
*---------------------------------------------------------------*
InitieraLevel:
*--[ Rensa alla objekt ]--*
	lea	Fiender(pc),a0
	move.l	a0,a1
	moveq.l	#e_size*32/4-1,d0
.rensa:
	clr.l	(a1)+
	dbra	d0,.rensa
	IFNE	FLERA
	move.w	Level(pc),d0
*--[ Klura ut vilken bana ]--*
	lea	BanLista(pc),a1
	move.l	(a1,d0.w*4),a1
	ELSE
	lea	BanData1(pc),a1
	ENDC
	lea	Bana(pc),a2
	move.w	#399,d0
	moveq.l	#-16,d1
.exp_bana:
	move.b	(a1)+,d2
	move.b	d2,d3
	asl.b	#4,d3
	and.b	d1,d2
	move.b	d2,(a2)+
	move.b	d3,(a2)+
	dbra	d0,.exp_bana
	move.w	(a1)+,Telefonkort
*--[ Kopiera in objekt data ]--*
.loop:
	move.l	(a1)+,d0
	beq.s	.done
	move.l	d0,(a0)+
	move.l	(a1)+,(a0)+
	bra.s	.loop
.done:
	move.l	Fiender+e_x(pc),SparadPos

*--[ S„tt upp nytt spel ]--*
NyttF”rs”k:
	clr.l	RedigDX
	clr.w	Hopp
	move.w	#1,Energi
	move.w	#-1,Klarat
	move.l	SparadPos(pc),Fiender+e_x


*****************************************************************
*---------------------------------------------------------------*
*	HŽR B™RJAR SPELET!					*
*---------------------------------------------------------------*
*****************************************************************

*--[ Huvud loopen ]--*
MainLoop:
*--[ Flytta fiender och s†nt ]--*
	bsr	UppdateraAI
	bsr	KollaKrockar

	move.w	Fiender+e_x(pc),d0
	sub.w	#136,d0
	bge.s	.inte_neg
	moveq	#0,d0
.inte_neg:
	cmp.w	#992,d0
	blt.s	.inte_ovs
	move.w	#991,d0
.inte_ovs:
	move.w	d0,ScreenX

	IFNE	EXIT
*--[ L„s av tangentbordet ]--*
	tst.b	KeyBuf+1(pc)
	beq.s	.inte_ESC
	clr.l	Liv
.inte_ESC:
	ENDC

*--[ Vill ET hoppa? ]--*
	tst.w	IVatten(pc)
	bge.s	.inte_Hopp
	tst.b	KeyBuf+42(pc)
	beq.s	.inte_Hopp
	tst.w	Hopp(pc)
	beq.s	.inte_Hopp
	bgt.s	.skuttar
	move.w	#10,Hopp
.skuttar:
	move.w	#$fffc,RedigDY
.inte_Hopp:

	lea	MaxFart(pc),a0
	move.w	#3,(a0)
*--[ Springa fort? ]--*
	tst.b	KeyBuf+56(pc)
	beq.s	.inte_Fort
	move.w	#5,(a0)
.inte_Fort:

	move.w	(a0),d0
	moveq.l	#0,d1
*--[ Vill ET v„nster? ]--*
	tst.b	KeyBuf+75(pc)
	beq.s	.inte_V„nster
	neg.w	d0
	move.w	d0,d1
.inte_V„nster:
*--[ Vill ET h”ger ]--*
	tst.b	KeyBuf+77(pc)
	beq.s	.inte_H”ger
	move.w	d0,d1
.inte_H”ger:

*--[ Om i vatten ska vi simma runt ]--*
	move.l	RedigDY(pc),d7
	lea	$4000.w,a0
	tst.w	IVatten(pc)
	blt.s	.inte_Simma
	tst.b	KeyBuf+72(pc)
	beq.s	.inte_Upp
	sub.l	a0,d7
.inte_Upp:
	tst.b	KeyBuf+80(pc)
	beq.s	.inte_Simma
	add.l	a0,d7
.inte_Simma:
	swap	d7
	cmp.w	#14,d7
	blt.s	.skutt1
	move.w	#6,d7
.skutt1:
	cmp.w	#-4,d7
	bgt.s	.skutt2
	move.w	#-4,d7
.skutt2:
	swap	d7
	move.l	d7,RedigDY

*--[ R„kna ut korrekt hastighet ]--*
	swap	d1
	move.l	RedigDX(pc),d0
	sub.l	d0,d1
	asr.l	#2,d1
	add.l	d1,d0
	add.l	#$1000,d0
	move.l	d0,RedigDX		
	swap	d0
	move.w	d0,Fiender+e_dx


*--[ Swappa sk„rmar ]--*
	movem.l	ScreenReal(pc),d0-3
	exg.l	d0,d2
	exg.l	d1,d3
	movem.l	d0-3,ScreenReal
*--[ Och s„tt sk„rmarna ]--*
	move.w	#-1,-(sp)
	move.l	ScreenReal(pc),-(sp)
	pea	$ffffffff.w
	move.w	#5,-(sp)
	trap	#14
*--[ Och v„nta VBL ]--*
	move.w	#37,-(sp)
	trap	#14
	lea	14(sp),sp

*--[ S† ritar vi ut bakgrunden ]--*
	bsr	RitaSpelplan

*--[ Jaha d† ritar vi d† ]--*
	bsr	RitaSpritar
	
*--[ Och s† skickar vi ut lite info ]--*
	bsr	RitaStatusbar

*--[ Avsluta om noll liv ]--*
	tst.w	Klarat(pc)
	bne.s	.ej_klarat
	IFNE 	FLERA
	addq.w	#1,Level(pc)
	bra	NyttF”rs”k
	ELSEIF
	bra.s	.slut
	ENDC
.ej_klarat:
	tst.w	Energi(pc)
	bgt	MainLoop
	subq.w	#1,Liv
	bgt	NyttF”rs”k


.slut
	IFNE	EXIT
	IFEQ	DEBUG
	move.l	(sp)+,$118.w

	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	#-1,4(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp		
	ENDC


	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	pea	Seger(pc)
	tst.w	Klarat(pc)
	beq.s	.skutt
	pea	F”rlust(pc)
.skutt:
	move.w	#9,-(sp)
	trap	#1
	
	move.w	#200,d7
.llop
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	dbra	d7,.llop
	
	clr.w	-(sp)
	trap	#1
	ELSEIF
	bra	NyttSpel
	ENDC

*---------------------------------------------------------------*
*	Keyboard vector						*
*---------------------------------------------------------------*
Min_KeyVec:
	move.w	#$2500,sr		;set ipl level
	movem.l	d0-a6,-(sp)
	moveq	#0,d0
	move.b	$fffffc00.w,d0
	btst	#7,d0
	beq.s	.hopp
	bra.s	.skutt2
.loop:
	move.b	$fffffc02.w,d0
	IFNE 	EXIT
	move.w	d0,-(sp)
	lea	$f96.w,a0
	jsr	([$1132.w])
	move.w	(sp)+,d0
	ENDC
	lea	KeyBuf(pc),a0
	bclr	#7,d0
	beq.s	.inte_satt
	clr.b	(a0,d0.w)
	bra.s	.skutt
.inte_satt:
	st.b	(a0,d0.w)
.skutt:
	move.b	$fffffc00.w,d0
.skutt2:
	btst	#0,d0
	bne.s	.loop
.hopp:
	movem.l	(sp)+,d0-a6
	bclr	#6,$fffffa11.w	;signal end of ikbd interrupt
	rte


*---------------------------------------------------------------*
*	UppdateraAI						*
*---------------------------------------------------------------*
UppdateraAI:
	subq.w	#1,Od”dlig
	tst.w	Hopp(pc)
	ble.s	.skutt
	subq.w	#1,Hopp
.skutt:
	lea	Fiender(pc),a0
	lea	Bana(pc),a1
	lea	15.w,a5			; a5 „r 15
	moveq.l	#63,d7
AI_Loop:
	lea	KollaBlock(pc),a6
	move.w	e_type(a0),d0
	beq	AI_Klar
	movem.w	e_x(a0),d1-3
*--[ Krock med v„gg ? ]--*
	move.w	d1,d4
	move.w	d2,d5
	add.w	a5,d5
	add.w	d3,d4
	tst.s	d3
	beq.s	AI_InteV„gg
	blt.s	.neg
	add.w	a5,d4
.neg:
	move.b	#5*16,KollaV„rde
	move.w	d4,a4
	jsr	(a6)
	bge.s	AI_V„gg
	move.w	a4,d4
	move.w	d2,d5
	jsr	(a6)
	blt.s	AI_InteV„gg
AI_V„gg
	cmp.w	#1,d0
	beq.s	.„r_ET
	neg.w	d3
	bra.s	AI_InteV„gg
.„r_ET:
	tst.w	d3
	blt.s	.done
	add.w	a5,d1
.done:
	and.w	#$fff0,d1
	moveq.l	#0,d3
	move.l	d3,RedigDX
AI_InteV„gg:
	move.w	d1,d4
	add.w	d3,d4
	blt.s	AI_V„gg
	cmp.w	#16*79,d4
	bge.s	AI_V„gg
	move.w	d4,d1
*--[ Kolla om han har mark under f”tterna ]--*
	moveq.l	#0,d6
	move.w	d1,d4
	move.w	d2,d5
	add.w	#16,d5
	jsr	(a6)
	blt.s	.ickeV
	bset	#0,d6
.ickeV:
	move.w	d1,d4
	move.w	d2,d5
	add.w	a5,d4
	add.w	#16,d5
	jsr	(a6)
	blt.s	.ickeH
	bset	#1,d6
.ickeH:
	cmp.w	#1,d0
	beq.s	Žr_ET	
	cmp.b	#%11,d6
	beq	AI_Klar
	cmp.w	#3,d0
	beq	AI_Klar
	neg.w	d3
	jmp	AI_Klar
Žr_ET:
*--[ Fixxa till ett skutt ]--*
	tst.w	Hopp(pc)
	blt	ET_SkuttarEj
	move.l	RedigDY(pc),d4
	tst.w	IVatten(pc)
	bge.s	.simmar
	add.l	#$8000,d4
	bra.s	.skutt
.simmar:
	add.l	#$1000,d4
.skutt
	move.l	d4,RedigDY
	swap	d4
	tst.w	d4
	beq	ET_Klar
	bgt.s	ET_faller
ET_Hoppar:
	move.b	#6*16,KollaV„rde
	move.w	d4,a4
	move.w	d1,d4
	move.w	d2,d5
	add.w	a4,d5
	jsr	(a6)
	bge.s	.dunk
	move.w	d1,d4
	add.w	a5,d4
	move.w	d2,d5
	add.w	a4,d5
	jsr	(a6)
	bge.s	.dunk
*--[ ET hoppar faktiskt ]--*
	add.w	a4,d2
	bra.s	ET_Klar
.dunk:
	clr.l	RedigDY
	clr.w	Hopp
	and.w	#$fff0,d2
	bra.s	ET_Klar
ET_faller:
	move.b	#5*16,KollaV„rde
	move.w	d4,a4
	move.w	d1,d4
	move.w	d2,d5
	add.w	a4,d5
	add.w	a5,d5
	jsr	(a6)
	bge.s	.dunk
	move.w	d1,d4
	add.w	a5,d4
	move.w	d2,d5
	add.w	a4,d5
	add.w	a5,d5
	jsr	(a6)
	bge.s	.dunk
*--[ ET faller faktiskt ]--*
	add.w	a4,d2
	bra.s	ET_Klar
.dunk:
	clr.l	RedigDY
	move.w	#-1,Hopp
	add.w	a5,d2
	and.w	#$fff0,d2
	bra.s	ET_Klar
ET_SkuttarEj:
	tst.w	d6
	bne.s	ET_Klar
	clr.w	Hopp
	clr.l	RedigDY
ET_Klar:	
	lea	KollaBonus(pc),a6
	move.w	#-1,IVatten
	move.w	d1,d4
	move.w	d2,d5
	jsr	(a6)
	move.w	d1,d4
	add.w	a5,d4
	move.w	d2,d5
	jsr	(a6)
	move.w	d1,d4
	move.w	d2,d5
	add.w	a5,d5
	jsr	(a6)
	move.w	d1,d4
	add.w	a5,d4
	move.w	d2,d5
	add.w	a5,d5
	jsr	(a6)	
AI_Klar:
	movem.w	d1-3,e_x(a0)
	addq.l	#e_size,a0
	dbra	d7,AI_Loop
	rts

*	d4,d5 „r X,Y och a0 „r bandatan
KollaBlock:
	move.l	a1,a2
	asr.w	#4,d4
	asr.w	#4,d5
	muls	#80,d5
	add.w	d5,a2
	move.b	(a2,d4.w),d4
	cmp.b	KollaV„rde(pc),d4
	rts
KollaV„rde:
	dc.b	0
	even

KollaBonus:
	move.l	a1,a2
	asr.w	#4,d4
	asr.w	#4,d5
	muls	#80,d5
	add.w	d5,a2
	move.b	(a2,d4.w),d5
	bge	.klar
	cmp.b	#-7*16,d5
	bgt.s	.inte_Exit
	tst.w	Telefonkort(pc)
	bgt.s	.klar
	clr.w	Klarat
	bra.s	.klar
.inte_Exit:
	cmp.b	#-6*16,d5
	bne.s	.inte_VattenYta
	move.w	#1,IVatten
	clr.w	Hopp
	bra.s	.klar
.inte_VattenYta:
	cmp.b	#-5*16,d5
	bne.s	.inte_Vatten
	clr.w	IVatten
	clr.w	Hopp
	bra.s	.klar
.inte_Vatten:	
	cmp.b	#-4*16,d5
	bne.s	.inte_Kort
	subq.w	#1,Telefonkort
	bra.s	.tabort
.inte_Kort:
	cmp.b	#-3*16,d5
	bne.s	.inte_Bl†
	addq.w	#1,Energi
	bra.s	.tabort
.inte_Bl†:
	cmp.b	#-2*16,d5
	bne.s	.inte_N„sa
	subq.w	#1,N„sor
	bne.s	.tabort
	move.w	#ant_n„sor,N„sor
	addq.w	#1,Liv
	bra.s	.tabort
.inte_N„sa:
	bsr.s	TaStryk2
	move.w	#$fffc,RedigDY
	bra.s	.klar
.tabort:
	clr.b	(a2,d4.w)
.klar:
	rts
	



TaStryk:
	clr.w	Hopp
	clr.w	e_type(a0)
TaStryk2:
	tst.w	Od”dlig(pc)
	bgt.s	.skutt
	subq.w	#1,Energi
	move.w	#20,Od”dlig
.skutt
	rts



*---------------------------------------------------------------*
*	KollaKrockar						*
*---------------------------------------------------------------*
KollaKrockar:
	lea	Fiender(pc),a0
	movem.w	e_x(a0),d0-1	; Ja h„r „r ETs position!
	moveq	#63,d7
	moveq.l	#-15,d5
	moveq.l	#15,d6
.loop
	addq.l	#e_size,a0
	move.w	e_type(a0),d4	; Žr det krockbart?
	beq.s	.inte_en_suck
	movem.w	e_x(a0),d2-3	; jajamen, h„mta koordinater
	sub.w	d0,d2
	cmp.w	d5,d2
	blt.s	.inte_en_suck
	cmp.w	d6,d2
	bgt.s	.inte_en_suck
	sub.w	d1,d3
	cmp.w	d5,d3
	blt.s	.inte_en_suck
	cmp.w	d6,d3
	bgt.s	.inte_en_suck
*--[ Det „r en fiende krock! ]--*
	cmp.w	#3,d4
	bge.s	.ET_loose
	tst.w	Hopp(pc)
	bne.s	.ET_loose
*--[ ET har d”dat det! ]--*
	clr.w	e_type(a0)
	bra.s	.skutt
.ET_loose:
*--[ ET f†r stryk ]--*
	bsr.s	TaStryk
.skutt:
	move.w	#$fffe,RedigDY
.inte_en_suck:
	dbra	d7,.loop
	rts
	
	

*---------------------------------------------------------------*
*	RitaSpritar						*
*---------------------------------------------------------------*
RitaSpritar:
	lea	Fiender(pc),a0
	moveq	#63,d7
.loop:
	move.w	e_type(a0),d1
	beq.s	.inget_att_rita
	movem.w	e_x(a0),d2-3
	sub.w	ScreenX(pc),d2
	cmp.w	#-16,d2
	ble.s	.inget_att_rita
	cmp.w	#320-32,d2
	bge.s	.inget_att_rita
	lea	gfxlista(pc),a1
	move.l	(a1,d1.w*4),a1
*--[ Žr det ET? ]--*
	cmp.w	#1,d1
	bne.s	.inte_ET
	move.w	Od”dlig(pc),d1
	ble.s	.norm
	btst	#0,d1
	beq.s	.inget_att_rita
.norm:
	tst.w	Hopp(pc)
	bge.s	.hoppar
	move.w	e_x(a0),d1
	and.w	#%100,d1
	bra.s	.rita
.hoppar:
	moveq	#8,d1
	bra.s	.rita
.inte_ET:
*--[ Det „r en fi! ]--*
	moveq	#0,d1
.rita:
	asl.w	#7,d1
	add.w	d1,a1
	move.l	Screen(pc),a2
	muls	#640,d3
	asl.w	#1,d2
	add.l	d3,a2
	add.w	d2,a2
	moveq.l	#15,d0
	tst.w	e_dx(a0)
	blt.s	.v„nster
	bsr.s	RitaSprite
	bra.s	.inget_att_rita
.v„nster
	bsr.s	RitaSpriteV„nd
.inget_att_rita:
	addq.l	#e_size,a0
	dbra	d7,.loop
	rts
	
RitaSprite:
.y:
	moveq	#15,d1
.x:
	move.w	(a1)+,d2
	beq.s	.nope
	move.w	d2,(a2)
.nope:
	addq.l	#2,a2
	dbra	d1,.x
	lea	640-32(a2),a2
	dbra	d0,.y
	rts
RitaSpriteV„nd:
	lea	32(a2),a2
.y:
	moveq	#15,d1
.x:
	subq.l	#2,a2
	move.w	(a1)+,d2
	beq.s	.nope
	move.w	d2,(a2)
.nope:
	dbra	d1,.x
	lea	640+32(a2),a2
	dbra	d0,.y
	rts


*---------------------------------------------------------------*
*	ExpanderaBlock						*
*		a0=Palette pointer				*
*		a1=16 f„rgers					*
*		a2=destblock 16*16 pixlar			*
*---------------------------------------------------------------*
ExpanderaBlock:
	moveq	#127,d0
	moveq	#0,d1
	moveq	#$f,d2
.loop:
	move.b	(a1)+,d3
	move.b	d3,d4
	rol.b	#4,d3
	and.l	d2,d3
	and.l	d2,d4
	move.w	(a0,d3.l*2),(a2)+
	move.w	(a0,d4.l*2),(a2)+
	dbra	d0,.loop
	rts

*---------------------------------------------------------------*
*	RitaStatusbar	(Och klippa spritar)			*
*---------------------------------------------------------------*
RitaStatusbar:
	move.l	ScreenReal2(pc),a0
	move.w	#(640*16-32)/4-1,d0
.tjo
	clr.l	(a0)+
	dbra	d0,.tjo
	move.w	#160,d1
.lpy	moveq.l	#15,d2
.lpx	clr.l	(a0)+
	dbra	d2,.lpx
	lea	576(a0),a0
	dbra	d1,.lpy
		

	lea	StatBlock(pc),a1
	moveq.l	#17,d0
.rensa:
	clr.b	(a1)+
	dbra	d0,.rensa
	move.w	Energi(pc),d0
	subq.w	#1,d0
	blt.s	.neg_energi
	bra.s	.skutt1
.energi:
	move.b	#-3*16,-(a1)
.skutt1:
	dbra	d0,.energi
.neg_energi:
	lea	StatBlock(pc),a1
	move.w	Liv(pc),d0
	bra.s	.skutt2
.liv:
	move.b	#3*16,(a1)+
.skutt2:
	dbra	d0,.liv
	
	moveq.l	#0,d7
	moveq.l	#17,d6
	lea	StatBlock(pc),a1
	lea	64(a0),a2
	bra.s	Xloop
	
	rts


*---------------------------------------------------------------*
*	RitaSpelplan						*
*---------------------------------------------------------------*
RitaSpelplan:
	move.l	Screen(pc),a0
	move.w	ScreenX(pc),d0
	lea	Bana(pc),a1
	move.w	d0,d1
	and.w	#$f,d1		; d1=shift
	moveq	#0,d2
	sub.w	d1,d2
	lea	(a0,d2.w*2),a0	; a0 Sk„rm till adress
	asr.w	#4,d0
	add.w	d0,a1		; a1=Bandatan
	moveq	#9,d7
Yloop:
	move.l	a0,a2
	moveq	#9,d6
	sub.w	d7,d6
	muls	#640*16,d6
	add.l	d6,a2		; a2=Denna rads adress
	moveq.l	#18,d6
Xloop:
	moveq.l	#0,d5
	move.b	(a1)+,d5
	asl.w	#4,d5
	lea	BanBlock(pc,d5.l*2),a3	; a3=Grafikblocket
	moveq	#15,d5
Sloop:
	movem.l	(a3)+,d0-4/a4-6
	movem.l	d0-4/a4-6,(a2)
	lea	640(a2),a2
	dbra	d5,Sloop
	lea	32-640*16(a2),a2
	dbra	d6,Xloop
	lea	80-19(a1),a1
	dbra	d7,Yloop
	rts


	SECTION DATA

*--[ Plocklista f”r banorna 1-5 ]--*
BanBlock:
	ds.b	512*16
	ds.b	80*10
Bana:
	ds.b	80*10+16
	dcb.b	4,-1*16


	IFNE	FLERA
BanLista:
	dc.l	BanData1
;	dc.l	BanData2
;	dc.l	BanData3
;	dc.l	BanData4
;	dc.l	BanData5
;	dc.l	0
	ENDC


*--[ Plocklista f”r spritar -5 - 4 ]--*
gfxlista:
	dc.l	gfx_Null
	dc.l	gfx_ET
	dc.l	gfx_Snigel
	dc.l	gfx_Bajs
	dc.l	gfx_Igelkott
	
BanData1:
	incbin	level.dbd
	dc.l	0
	even
	IFNE	FLERA
;BanData2:
;	incbin	level2.dbd
	even
;BanData3:
;	incbin	level3.dbd
	even
;BanData4:
;	incbin	level4.dbd
	even
;BanData5:
;	incbin	level5.dbd
	even
	ENDC

SpriteData:
	incbin	sprites.dat
	even
	
BlockData:
	incbin	blocks.dat
	even

ScreenReal:
	dc.l	ScreenBuf
Screen:
	dc.l	ScreenBuf2+640*16+32
ScreenReal2:
	dc.l	ScreenBuf2
Screen2:
	dc.l	ScreenBuf+640*16+32
	even

	IFNE	EXIT
Seger:	dc.b	27,"EAnd DB lived hapily ever after!",0
F”rlust:dc.b	27,"EGAME OVER!",0
	even
	ENDC

VGA:
	dc.l	$c6008d
	dc.l	$1502ac
	dc.l	$8d0096
	dc.l	$4eb04d1
	dc.l	$3f00f5
	dc.l	$41504e7
;	dc.w	$200
	dc.w	$186
	dc.w	$5
;	dc.w	$140
RGB:
	dc.l   $fe00cc
	dc.l   $280039
	dc.l   $9a00d9
	dc.l   $2710265
	dc.l   $2f0081
	dc.l   $211026b
;	dc.w   $200
	dc.w   $182
	dc.w   $0
;	dc.w   $140



	SECTION BSS
BSS_START:

StatBlock:
	ds.b	18

gfx_Null:
	ds.l	128
gfx_ET:
	ds.l	128*3
gfx_Snigel:
	ds.l	128
gfx_Bajs:
	ds.l	128
gfx_Igelkott:
	ds.l	128


Od”dlig:
	ds.w	1	; Om > 0 so tar vi ingen skada!
RedigDX:
	ds.l	1
RedigDY:
	ds.l	1
MaxFart:
	ds.w	1
IVatten:
	ds.w	1
ScreenX:
	ds.w	1	; Hur mycket scrollat!
Liv:
	ds.w	1	; Ska vi sluta?
Energi:
	ds.w	1	; Hur mycket mer stryk ET t†l
	IFNE	FLERA
Level:
	ds.w	1	; Vilken bana „r vi p†?
	ENDC
Hopp:
	ds.w	1	; Om > 0 s† ska vi hoppa, 0 s† faller vi
Telefonkort:
	ds.w	1	; N„r det n†r noll kan man avsluta banan
N„sor:
	ds.w	1
Klarat:
	ds.w	1	; om = 0 s† har vi klarat banan!
SparadPos:
	ds.l	1
Fiender:
	ds.b	e_size*64
	
KeyBuf:
	ds.b	128
safety:
	ds.b	640*200
ScreenBuf:
	ds.b	640*202
	ds.b	640*200
ScreenBuf2:
	ds.b	640*202
BSS_SLUT: