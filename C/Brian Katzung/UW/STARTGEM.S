/
/	STARTGEM.S	6-MAR-1987	by GHOST-Soft
/
/	This program is used to start GEM programs from within the AUTO folder.
/
/	The code is probably highly nonportable, as it heavily depends on the
/	internal organisation of code in TOS/GEM.
/	As this program works with ROM- as well as all disk-based versions
/	of German TOS, I'm pretty sure that this program works with foreign
/	versions of TOS, too.
/	All addresses given in square brackets apply to the German ROM-TOS.
/
/	Assemble with Mark Williams assembler:
/		as -o startgem.o startgem.s
/		gemfix startgem.o startgem.prg
/		strip startgem.prg
/			_or_
/		as -o startgem.o startgem.s
/		ld -o startgem.prg -s startgem.o
/

linef=		0x2c
vbllist1=	0x4d2

gemdos=		1
  cconws=	0x9
  fsetdta=	0x1a
  super=	0x20
  ptermres=	0x31
  fsfirst=	0x4e
xbios=		14
  vsync=	0x25

	.shri
start:
	lea	basepage(pc),a0
	move.l	4(a7),(a0)	/ get basepage address

	pea	msg(pc)
	move.w	$cconws,-(a7)	/ print line
	trap	$gemdos
	addq.w	$6,a7

	moveq	$70,d2		/ wait 1 second = 71 vblanks
1:	move.w	$vsync,-(a7)	/ wait for vertical blank
	trap	$xbios
	addq.w	$2,a7
	dbra	d2,1b

	clr.l	-(a7)
	move.w	$super,-(a7)	/ enter super mode
	trap	$gemdos
	addq.w	$6,a7		/ keep old super sp in d0

	moveq	$-1,d2
	move.l	d2,linef	/ set line-f emulator trap
	lea	vblank(pc),a2
	move.l	a2,vbllist1	/ set vblank vector #1  {0..7}

	move.l	d0,-(a7)
	move.w	$super,-(a7)	/ exit super mode
	trap	$gemdos
	addq.w	$6,a7

	lea	basepage(pc),a0	/ compute number of bytes to keep
	suba.l	basepage(pc),a0
	clr.w	-(a7)		/ 0 = no error
	move.l	a0,-(a7)
	move.w	$ptermres,-(a7)	/ terminate and stay resident
	trap	$gemdos		/ this call never returns

vblank:
	moveq	$-1,d0
	cmp.l	linef,d0
	beq.s	1f
	clr.l	vbllist1	/ clear vblank vector #1
	movea.l	linef,a0
	lea	old_lf(pc),a1
	move.l	a0,(a1)		/ save old line-f vector (usually in low RAM)
	lea	new_lf(pc),a1
	move.l	a1,linef	/ install new one

	/ find the address of the buffer that GEM uses for the
	/ name of the program that it is going to execute
	movea.l	0x16(a0),a0	/ get start of line-f table from instruction
	/ [a0 = fee8bc]		move.l $0xfee8bc,a0
	movea.l	0x7c8(a0),a0	/ get address of routine 'f7c8' from table
	/ [a0 = fd8fc4]
	movea.l	0xa(a0),a2	/ get address from instruction
	/ [a2 = 73e4]		move.l $0x73e4,a5
	adda.w	0x10(a0),a2	/ add offset 0x1f56 from instruction
	/ [a2 = 933a]		lea 0x1f56,a0
	lea	pointer(pc),a1
	move.l	a2,(a1)		/ save buffer address
1:	rts

new_lf:
	movea.l	2(a7),a0	/ get addr. of instr. that caused exception
	cmpi.w	$0xf08c,(a0)	/ 'f08c' is the line-f instr. we're looking for
	bne.w	exit
	move.l	old_lf(pc),linef	/ restore old line-f vector

	movea.l	pointer(pc),a0
	lea	filename(pc),a1
1:	move.b	(a1)+,(a0)+	/ copy filename into GEM buffer space
	bne.s	1b

	pea	dta
	move.w	$fsetdta,-(a7)	/ set DTA
	trap	$gemdos
	addq.l	$6,a7
	move.w	$0x27,-(a7)	/ don't look at volumes and directories
	pea	filename(pc)
	move.w	$fsfirst,-(a7)	/ search first
	trap	$gemdos
	addq.l	$8,a7
	tst	d0		/ status != 0 indicates error
	bne.s	exit

	movea.l	2(a7),a0	/ get addr. of instr. that caused exception
	/ [a0 = fed188]
2:	cmpi.w	$0xf4b8,(a0)	/ look for line-f instruction 'f4b8'
	beq.s	doload
	addq.l	$2,a0
	cmpa.l	$0xfefffe,a0	/ test for ROM end
	beq.s	exit
	cmpa.l	$0x078000,a0	/ test for RAM end (on 512K machine)
	bne.s	2b		/ {RAM-TOS usually loads much lower}

exit:
	movea.l	old_lf(pc),a0	/ resume execution of regular line-f handler
	jmp	(a0)

doload:
	/ [a0 = fe1de2]
	move.w	(a7)+,d2	/ pop status word
	addq.w	$4,a7		/ destroy addr. of instr. 'f08c'
	move.w	d2,sr		/ restore status register
	adda.w	$56,a7		/ destroy parameters of instr. 'f08c'
	jmp	(a0)		/ jump to instruction 'f4b8'

	.prvd
dta:
	.blkb	44
old_lf:
	.blkl	1
pointer:
	.blkl	1

msg:
	.ascii	"\033\105Autostart of "
filename:
	.ascii	"a:\\bin\\UW.PRG"
nulls:
	.blkb	20		/ these nulls allow easy patching of code file

	.even
basepage:
	.ascii	"EOPA"		/ magic number indicates End Of Patch Area
