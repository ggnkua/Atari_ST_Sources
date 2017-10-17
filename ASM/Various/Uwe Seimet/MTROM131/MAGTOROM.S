*******************************************
*                                         *
* MAGTOROM V1.31                          *
*                                         *
* Write protection for MagiC 2.0 or newer *
* for Ataris with MC68030.                *
*                                         *
* The sources are compatible with         *
* the Easy Rider assembler.               *
*                                         *
* (C) 1994-2012 Uwe Seimet                *
*                                         *
*******************************************

GEMDOS	= 1
CCONWS	= 9
SUPER	= 32
PTERMRES	= 49
MALLOC	= 72
MSHRINK	= 74
PTERM	= 76

_____md	= $49e
_sysbase	= $4f2
_p_cookies= $5a0


	mc68030
	loadfast
	ttram
	ttmem
	locoff


	text

	move.l 4(sp),a0
	lea stack+400,sp
	move.l 12(a0),a1
	add.l 20(a0),a1
	add.l 28(a0),a1
	lea $100(a1),a1
	move.l a1,d5
	pea (a1)
	pea (a0)
	clr -(sp)
	move #MSHRINK,-(sp)
	trap #GEMDOS
	lea 12(sp),sp

	clr.l -(sp)
	move #SUPER,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l d0,d7

	move.l _sysbase,a0
	move.l $08(a0),a0
	move $1c(a0),d2
	lsr #1,d2
	bsr setc

	move.l #"_AKP",d0
	bsr get_cookie
	beq.s .noakp

	lsr #8,d2	;Isolate language code
	bsr setc

.noakp:	move.l #"_CPU",d0
	bsr get_cookie
	lea cpuerr,a6

*_CPU cookie present? If it is, check for 68030

	beq error
	cmp #30,d2
	bne error

*Is MagiC actually installed?

	move.l #"MagX",d0
	bsr get_cookie
	lea magerr,a6
	beq error

*Is the PMMU already in use?

	move.l #"PMMU",d0
	bsr get_cookie
	lea mmuerr,a6
	bne error

*A maximum of 16 table and 512 page descriptors is needed.
*The tables have to be longword-aligned.

	move.l #desc,d6
	add.l #15,d6
	and #$fff0,d6

*Start of the table descriptors

	move.l d6,a5

*Start of the page descriptors

	lea 64(a5),a4

*Find the operating system's start page

	move.l _sysbase,a0
	move.l 8(a0),d1
	add.l #$7fff,d1
	and #$8000,d1
	move.l d1,a1
	move.l d1,a3
	cmp.l #$01000000,a1
	bcc.s .ttram
	move.l 20(a0),a2
	cmp.l #$87654321,(a2)+
	beq.s .magaes
	lea 12(a0),a2
.magaes:	move.l (a2),a2
	bra.s .stram
.ttram:	move.l _____md,a2
.stram:

*Size of system area

	move.l a2,d2
	sub.l a1,d2

*Find decriptor pointing to system start base address

	ptestr #2,(a3),#3,a0

*Set up early termination descriptors

	move.l (a0),d1
	and #$8000,d1
	or #$0001,d1
	moveq #15,d0
setterm:	move.l d1,(a5)+
	add.l #$00100000,d1
	dbra d0,setterm

*Do not cache hardware area

	cmp.l #$01000001,d1
	bne.s nostram
	or.l #$00000040,-4(a5)

*Set up table descriptors

nostram:	move.l d2,d0
	divu.l #$01000000,d0
	move.l d6,a1
	move.l a4,d1
	or #$0002,d1
.settab:	move.l d1,(a1)+
	add.l #128,d1
	dbra d0,.settab

*Set up page descriptors

	move.l (a0),d1
	and #$8000,d1
	or #$0001,d1
	move #511,d0
setpage:	move.l d1,(a5)+
	add.l #$00008000,d1
	dbra d0,setpage

*Extend original table

	ptestr #7,(a3),#2,a0
	or #$0002,d6
	move.l d6,(a0)

*Re-initialize PMMU, no transparent translation

	pflusha
	pmove tt0reg,tt0

*Write protect MagiC pages

	move.l _sysbase,a0
	move.l 8(a0),d1
	add.l #$7fff,d1
	and #$8000,d1
	ptestr #7,(d1.l),#7,a4
	divu #$8000,d2
	bra.s protnxt
prot:	or.l #$0004,(a4)+
protnxt:	dbra d2,prot
	pflusha

*Add PMMU cookie

	bsr add_cookie

	move.l d7,-(sp)
	move #SUPER,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	lea message,a0
	bsr cconws
	clr -(sp)
	move.l d5,-(sp)
	move #PTERMRES,-(sp)
	trap #GEMDOS

error:
	move.l d7,-(sp)
	move #SUPER,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	bsr.s cconws0
	lea notinst,a6
	bsr.s cconws0
	move #PTERM,-(sp)
	trap #GEMDOS

cconws0:
	move country,d0
	move.l (a6,d0),a0
cconws:	movem.l a1-a3/d1-d3,-(sp)
	pea (a0)
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	movem.l (sp)+,a1-a3/d1-d3
	rts

*Get cookie if present

get_cookie:
	move.l _p_cookies,d1
	beq.s .end
	move.l d1,a0
.loop:	movem.l (a0)+,d1-d2
	tst.l d1
	beq.s .end
	cmp.l d0,d1
	bne .loop
	moveq #-1,d0
.end:	rts

*Extend cookie jar if required

add_cookie:
	move.l _p_cookies,a0
	moveq #0,d2	;cookie count
.loop:	addq.l #1,d2
	movem.l (a0)+,d0-d1
	tst.l d0
	bne .loop

*A new cookie is required
	addq.l #1,d2

*Cookie jar exhausted?

	cmp.l d1,d2
	bcs.s nofull

*If yes add 8 additional cookies

	addq.l #8,d2
	asl.l #3,d2
	move.l d2,-(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l d0,d2
	beq.s adderr
	move.l d0,a0
	move.l _p_cookies,a1
.copy:	movem.l (a1)+,d0-d1
	movem.l d0-d1,(a0)
	addq.l #8,a0
	tst.l d0
	bne .copy
	addq.l #8,d1	;8 additional entries
	move.l d2,_p_cookies

*Create PMMU cookie

nofull:	subq.l #8,a0
	move.l #"PMMU",(a0)+
	clr.l (a0)+
	movem.l d0-d1,(a0)
adderr:	rts

setc:
	cmp #8,d2	;SWG?
	bne *+2
	moveq #1,d2	;FRG
	cmp #1,d2
	beq *+2
	clr d2	;USA otherwise
	asl #2,d2
	move d2,country
	rts


	data

notinst:	dc.l notinst1,notinst2
cpuerr:	dc.l cpuerr1,cpuerr2
magerr:	dc.l magerr1,magerr2
mmuerr:	dc.l mmuerr1,mmuerr2

message:	dc.b $0d,$0a,$1b,"pMAGTOROM V1.31",$1b,"q",$0d,$0a
	dc.b "½ 1994-2012 Uwe Seimet",$0d,$0a,0

notinst1:dc.b $0d,$0a,"MAGTOROM was not installed!",$0d,$0a,0
notinst2:dc.b $0d,$0a,"MAGTOROM wurde nicht installiert!",$0d,$0a,0

cpuerr1:	dc.b $0d,$0a,"MAGTOROM requires a 68030 processor!",0
cpuerr2:	dc.b $0d,$0a,"MAGTOROM erfordert einen 68030 Prozessor!",0

magerr1:	dc.b $0d,$0a,"MagiC is not installed!",0
magerr2:	dc.b $0d,$0a,"MagiC ist nicht installiert!",0

mmuerr1:	dc.b $0d,$0a,"Another program is already using the PMMU!",0
mmuerr2:	dc.b $0d,$0a,"Die PMMU wird bereits durch ein anderes Programm benutzt!",0


	bss

stack:	ds.l 100

tt0reg:	ds.l 1

country:	ds.w 1

*There is a maximum of 16 table and 512 page descriptors

desc:	ds.b 4*(16+512)+15