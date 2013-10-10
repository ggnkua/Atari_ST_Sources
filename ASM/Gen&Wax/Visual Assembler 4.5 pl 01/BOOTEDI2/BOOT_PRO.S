MOD_BOX=0
MOD_BOX2=0
MOD_HEXA=0
MOD_DECI=0
MOD_WIND=0
MOD_MENU=0
MOD_ACC=0

	include guw_mac3.s
	; boot-protector PASSWD
	output d:\assemble\sources.guw\boot_edi.2\boot_pro.bs

BOOT=1

code=$54cf
	
start_of_code:

l0000	equ	start_of_code-19
l0001	equ	start_of_code-18
l0002	equ	start_of_code-17
l0003	equ	start_of_code-16
l0004	equ	start_of_code-13
l0005	equ	start_of_code-12
l0006	equ	start_of_code-8

	bsr .loadshdriver
	bsr genuwax
	rts

.loadshdriver:
	moveq #$48,d3
	moveq #-1,d0
	move.l d0,-(a7)
	move.w d3,-(a7)
	trap #1

	move.l d0,d5
	move.l d0,2(a7)
	move.w d3,(a7)
	trap #1
	addq.w #6,a7

	tst.l d0
	beq.s l000b
	movea.l d0,a4
	move.b l0001(pc),d1
	ror.w #8,d1
	move.b l0000(pc),d1
	lsr.w #8,d1
	lsr.w #1,d1
	moveq #0,d2
	move.b l0005(pc),d2
	ror.w #8,d2
	move.b l0004(pc),d2
	move.w l0003(pc),d3
	ror.w #8,d3
	mulu d1,d3
	add.l d6,d3
	move.w l0006(pc),d6
	ror.w #8,d6
	mulu d1,d6
	add.l d6,d6
	add.l d3,d6
	lsr.l #4,d2
	add.l d6,d2
	movea.l d2,a1
	movem.l d5/d3/d0-d1,-(a7)
l0008:	moveq #1,d5
	movem.l a5/a1,-(a7)
	jsr (a3)

	movem.l (a7)+,a5/a1
	tst.w d0
	beq.s l000d
l0009:	add.l d5,d6
	cmp.l a1,d6
	bcs.s l0008
l000a:	move.w #$49,-(a7) 	;MFREE
	trap #1
	adda.w #$12,a7

l000b:	jmp (a5)		; fin


l000c:	dc.b 'SHDRIVERSYS',0

l000d:	movea.l a4,a0
	moveq #$f,d1
l000e:	moveq #$a,d0
l000f:	move.b 0(a0,d0.w),d3
	cmp.b l000c(pc,d0.w),d3
	beq.s l0010
	adda.w #$20,a0
	dbf d1,l000e
	bra.s l0009

l0010:	dbf d0,l000f
	move.l 28(a0),d5
	ror.w #8,d5
	swap d5
	ror.w #8,d5
	addi.l #$800,d5
	cmp.l 12(a7),d5
	bhi.s l000a
	movea.l a4,a2
	adda.l 12(a7),a4
	suba.w #$600,a4
	move.w 26(a0),d2
	ror.w #8,d2
	moveq #-1,d3
l0011:	moveq #0,d5
	move.b l0002(pc),d5
	mulu 6(a7),d5
	move.w d2,d6
	subq.w #2,d6
	mulu d5,d6
	add.l a1,d6
	exg a4,a2
	movem.l a5/a1-a2/d2,-(a7)
	jsr (a3)

	movem.l (a7)+,a5/a1-a2/d2
	tst.w d0
	bne.s l000a
	exg a4,a2
	lsl.l #8,d5
	add.l d5,d5
	adda.l d5,a2
	move.w d2,d6
	ext.l d6
	lsr.l #8,d6
	add.l 8(a7),d6
	cmp.l d3,d6
	beq.s l0012
	moveq #1,d5
	move.l d6,d3
	movem.l a5/a1-a2/d2,-(a7)
	jsr (a3)

	movem.l (a7)+,a5/a1-a2/d2
	tst.w d0
	bne l000a
l0012:	andi.w #$ff,d2
	add.w d2,d2
	move.w 0(a4,d2.w),d2
	ror.w #8,d2
	bpl.s l0011
	movea.l 0(a7),a2
	movea.l a2,a0
	cmpi.w #$601a,(a0)+
	bne l000a
	lea 28(a2),a1
	adda.l (a0)+,a1
	adda.l (a0)+,a1
	adda.l 4(a0),a1
	tst.l (a1)
	beq.s l0016
	lea 28(a2),a0
	move.l a0,d1
	moveq #0,d0
	adda.l (a1)+,a0
l0013:	add.l d1,(a0)
l0014:	move.b (a1)+,d0
	beq.s l0016
	cmp.b #1,d0
	bne.s l0015
	adda.w #$fe,a0
	bra.s l0014

l0015:	adda.w d0,a0
	bra.s l0013

l0016:	move.l 12(a7),d0
	adda.w #$10,a7
	jmp 32(a2)

genuwax:
	ifeq BOOT
	init_prg 1024
	endc

	save d0-a6

	write texte(pc)

	file_open read,name(pc)
	move d0,d7
	bmi.s .pas_fich

	lea load_fich(pc),a6
	file_read a6,#2+8,d7
	move.l d0,d6
	file_close d7
	cmp.l #2+8,d6
	bne.s .pas_fich

	cmp.w #code,(a6)+
	beq fin

	eor.l #$fd4e55c4,(a6)
	eor.l #$35524ce9,4(a6)
	bra.s .ok

.pas_fich:	
	lea basic(pc),a6
	; ask mot de passe
.ok:
.not_good:
	write pass(pc)
	lea enter(pc),a5

	move #8-1,d7
.redo:	wait
	move.b d0,(a5)+
	write espace(pc)
	dbf d7,.redo

	lea enter(pc),a5
	move.l a6,a4
	cmp.l (a5)+,(a4)+
	bne.s .not_good
	cmp.l (a5)+,(a4)+
	bne.s .not_good

	write ask_again(pc)
	wait
	cmp.b #'n',d0
	bne.s fin

	file_open write,name(pc)
	move d0,d7
	bmi.s fin

	lea troc(pc),a6
	eor.l #$fd4e55c4,2(a6)
	eor.l #$35524ce9,6(a6)

	file_write a6,#2+8,d7
	file_close d7

fin:	load d0-a6
	ifne BOOT
	rts
	endc

	ifeq BOOT
	restore_prg
	endc

	section DATA
midx=80/2
midy=25/2

enter:	dcb.b 8,'X'
name:	dc.b "c:\troc.boc",0
troc:	dc.w code
basic:	dc.b 'xenophon'

texte:	dc.b esc,'E',esc,'Y',32+midy-1,32+midx-24/2
	dc.b 'Genuwax Boot-protector !'
	dc.b 0
pass:	dc.b esc,'Y',32+midy+1,32+midx-26/2
	dc.b 'Enter password : XXXXXXXX.'
	dc.b esc,'Y',32+midy+1,32+midx-26/2+17
	dc.b 0
ask_again:	dc.b esc,'Y',32+midy+1+2,32+midx-19/2
	dc.b 'Ask next time (y/n)'
	dc.b 0

espace:	dc.b ' ',0

	section BSS
load_fich:	ds.b 10

	END
