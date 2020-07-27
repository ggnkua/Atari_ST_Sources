/	
/	Gulam routines in MWC assembler
/
	.globl	cpymem_, lineA_, mouseregular_
	.shri

/* Copy n bytes from s to d; these are either disjoint areas, or d is < s.
/*
/cpymem(d, s, n)
/register char	*d, *s;
/register int	n;
/{
/	if (d && s && (n > 0))  while (n--) *d++ = *s++;

cpymem_:
	link	a6, $-12
	movem.l	$12416, (a7)
	movea.l	8(a6), a5
	movea.l	12(a6), a4
	move	16(a6), d7
	move.l	a5, d0
	beq.s	L1
	move.l	a4, d0
	beq.s	L1
	tst	d7
	ble.s	L1
	subq.w	$1, d7
L4:
	move.b	(a4)+, (a5)+
	dbf	d7, L4
L1:
	movem.l	-12(a6), $12416
	unlk	a6
	rts

/int	*line()

lineA_:	.word	0xa000
	rts

/ Make hi rez screen bios handle 50 lines of 8x8 characters.  Adapted
/ from origional asm posting.

/hi50()

	.globl hi50_

hi50_:
	.word	0xA000		  / get the important pointers (line A init)
	movea.l	4(a1),a1	  / a1 -> 8x8 font header
	move.l  72(a1),-0x0A(a0)  / v_off_ad <- 8x8 offset table addr
	move.l  76(a1),-0x16(a0)  / v_fnt_ad <- 8x8 font data addr
	move    $8,  -0x2E(a0)	  / v_cel_ht <- 8    8x8 cell height
/	move    $39, -0x2A(a0)	  / hi40
/	move    $800,-0x28(a0)    /
	move    $49, -0x2A(a0)	  / v_cel_my <- 49   maximum cell "Y"
	move    $640,-0x28(a0)    / v_cel_wr <- 640  offset to cell Y+1
	rts			  / and return
   
/ Make hi rez screen bios handle 40 lines of 8x8 characters.  Adapted
/ from origional asm posting.

/hi40()

	.globl hi40_


/
/  make 8x8 font into 8x10 font
/
hi40_:
	clr.l	d0
	move.l	$639, d1		/ 639 = size of 8x10 fnt; longs
	movea.l	$fnt_8x10, a0

clr_loop:	
	move.l	d0, (a0)+; 		/clear font data
	dbf	d1, clr_loop

	.word	0xA000			/ line A call to get base address

	movea.l	4(a1), a1		/ a1 -> 8x8 font header
	movea.l	76(a1), a2		/ a2 -> 8x8 font data
	lea	fnt_8x10+256, a3	/ a3 -> 2nd line of font buffer
	move	$511, d0		/ d0 <- size of 8x8 fnt data/

fnt_loop:	
	move.l	(a2)+, (a3)+
	dbf	d0, fnt_loop

	.word	0xA000			/ line A call to get base address
	movea.l	0x4(a1), a1		/ a1 -> 8x8 font header
	move.l	0x48(a1), -0xa(a0)	/ v_off_ad <- 8x10 offset table addr
	move.l	$fnt_8x10, -0x16(a0)	/v_fnt_ad <- 8x10 font data adr
	move	$10, -0x2e(a0)		/ v_cel_ht <- 10   8x10 cell height
	move	$39, -0x2a(a0)		/ v_cel_my <- 39   maximum cell "Y"
	move	$800, -0x28(a0)		/ v_cel_wr <- 800  offset to cell Y+1
	rts			  	/ and return
   


/ Make hi rez screen bios handle 25 lines of 8x16 characters
/
/hi25()

	.globl hi25_

hi25_:				  / Switch to 25 lines
	.word   0xA000		  / get the important pointers
	movea.l	8(a1),a1	  / a1 -> 8x16 font header
	move.l  72(a1),-0x0A(a0)  / v_off_ad <- 8x16 offset table addr
	move.l  76(a1),-0x16(a0)  / v_fnt_ad <- 8x16 font data addr
	move    $16,  -0x2E(a0)	  / v_cel_ht <- 16    8x16 cell height
	move    $24,  -0x2A(a0)	  / v_cel_my <- 24    maximum cell "Y"
	move    $1280,-0x28(a0)	  /  v_cel_wr <- 1280  vertical byte offset
	rts			  / bye


/mouseon()		/* show/activate the mouse		*/
	.globl	mouseon_
	.shri
mouseon_:
	.word	0xA000		/* line A call to get base address */
	movea.l	4(a0), a1	/* a1 = CNTRL		*/
	move.l	a1, d0
	beq	ret
	clr.w	2(a1)		/* CONTRL[1] = 0	*/
	move.w	$1, 6(a1)	/* CONTRL[3] = 1	*/
	movea.l	8(a0), a1	/* a1 = INTIN		*/
	clr.w	(a1)		/* INTIN[0] = 0;	*/
	.word	0xA009		/* show mouse lineA call	*/
	jsr	mouseregular_
ret:	rts

/mouseoff()
	.globl	mouseoff_
	.globl	mousecursor_
mouseoff_:
	.word	0xA00A			/* hide mouse lineA call	*/
	jsr	mousecursor_
	rts

/ getnrow() -- get number of rows.

	.globl	getnrow_

getnrow_:	
	.word	0xa000
	move	-42(a0), d0
	addq	$1, d0
	ext.l	d0
	rts

/ getncol() -- get number of columns.

	.globl	getncol_
getncol_:	
	.word	0xa000
	move	-44(a0), d0
	addq	$1, d0
	ext.l	d0
	rts

/ call Gulam related entries
/
	.globl	getlineviaue_
	.globl	callgulam_
	.globl	togulam_
	.long	0x86420135		/ our magic number
	jmp	getlineviaue_
togulam_:
	jmp	callgulam_


/ Revector trap 1 and 13 to do stdout capture into Gulam buffer
/
/	.prvd
/savea7:	.long	0
/
/	.shri
/	.globl	gconout_, gcconws_, gfwrite_, oldp1_, oldp13_
/	.globl	mytrap1_, mytrap13_
/
// revector trap 13 to our own to handle Bconout(2, x)
//
/mytrap13_:
/	move.l	a7,savea7
/	move.l	usp, a7
/        move.w	(a7)+, d0	/ Bconout(2, c) == trap13(3, 2, c)
/	cmpi.w	$3,d0
/	bne	1f
/3:	move.w	(a7)+,d0
/	cmpi.w	$2, d0
/	bne	1f
/	jsr	gconout_	/ c is still on stack
/ 	movea.l	savea7,a7
/	rte
/1:	movea.l	savea7,a7
/	movea.l	oldp13_,a0
/ 	jmp	(a0)
/
// Revector trap 1 to handle Cconout, Cconws, and Fwrite(1,..) calls
//
/mytrap1_:
/	move.l	a7,savea7
/	move.l	usp, a7
/        move.w	(a7)+, d0
/	cmpi.w	$2,d0		/ Cconout(c) == trap1(0x2, c)
/	beq	2f
/	cmpi.w	$9,d0		/ Cconws(s) == trap1(0x9, s)
/	beq	9f
/	cmpi.w	$0x40,d0	/ Fwrite(1, ll, bf) == trap1(0x40, 1, ll, bf)
/ 	beq	4f
/1:	movea.l	savea7,a7
/	movea.l	oldp1_,a0
/	jmp	(a0)
/9:	jsr	gcconws_	/ s is still on stack
/	bra	0f
/4:	move.w	(a7)+,d0	/ d0 == 1 ?
/	cmpi.w	$1,d0
/	bne	1b
/	jsr	gfwrite_	/ gfwrite(ll, bf) long ll; char *bf;
/	bra	0f
/2:	jsr	gconout_
/0: 	movea.l	savea7,a7
/	rte
/

/ Extension by AKP: "set font 8" now means "use the 8x8 font"
/ and RETURNS whatever number of lines that yields (for setting nrows)
/
/ "set font 16" means "use the 8x16 font," and "set font 10" means
/ "use the 8x8 font with two extra blank lines."
/ Again, these return the actual number of rows you get.
/

/font8()

	.globl font8_

font8_:
	.word	0xA000		  / get the important pointers (line A init)
	movea.l	4(a1),a1	  / a1 -> 8x8 font header
	move.l  0x48(a1),-0x0A(a0)  / v_off_ad <- 8x8 offset table addr
	move.l  0x4c(a1),-0x16(a0)  / v_fnt_ad <- 8x8 font data addr
	move    $8,  -0x2E(a0)	  / v_cel_ht <- 8    8x8 cell height

/ new v_cel_wr (byte disp to next vertical alpha cell) = bytes_lin * v_cel_ht
	move.w	-2(a0),d0		/ get bytes_lin
	asl.w	$3,d0			/ *8 (v_cel_ht)
	move.w	d0,-40(a0)		/ set v_cel_wr

/ new v_cel_mx = (bytes_lin / nplanes) - 1
	moveq.l	$0,d0			/ prepare d0,d1 as unsigned longs
	moveq.l	$0,d1
	move	-2(a0),d0		/ get bytes_lin
	move	(a0),d1			/ get nplanes
	divs	d1,d0			/ divide
	subq	$1,d0			/ -1
	move	d0,-44(a0)		/ set v_cel_mx

/ new v_cel_my = (v_rez_vt / 8) - 1

	move	-4(a0),d0		/ get v_rez_vt
	asr	$3,d0			/ /8
	subq	$1,d0			/ -1
	move	d0,-42(a0)		/ set v_cel_my
	addq	$1,d0			/ return new nrows
	rts

/font10()

	.globl font10_


/
/  make 8x8 font into 8x10 font and make it current; return new nrows
/
font10_:
	clr.l	d0
	move.l	$639, d1		/ 639 = size of 8x10 fnt; longs
	movea.l	$fnt_8x10, a0

f10_clr_loop:	
	move.l	d0, (a0)+; 		/clear font data
	dbf	d1, f10_clr_loop

	.word	0xA000			/ line A call to get base address

	movea.l	4(a1), a1		/ a1 -> 8x8 font header
	movea.l	76(a1), a2		/ a2 -> 8x8 font data
	lea	fnt_8x10+256, a3	/ a3 -> 2nd line of font buffer
	move	$511, d0		/ d0 <- size of 8x8 fnt data/

f10_fnt_loop:	
	move.l	(a2)+, (a3)+
	dbf	d0, f10_fnt_loop

	.word	0xA000			/ line A call to get base address
	movea.l	0x4(a1), a1		/ a1 -> 8x8 font header
	move.l	0x48(a1), -0xa(a0)	/ v_off_ad <- 8x10 offset table addr
	move.l	$fnt_8x10, -0x16(a0)	/v_fnt_ad <- 8x10 font data adr
	move	$10, -0x2e(a0)		/ v_cel_ht <- 10   8x10 cell height

/ new v_cel_wr (byte disp to next vertical alpha cell) = bytes_lin * v_cel_ht
	move.w	-2(a0),d0		/ get bytes_lin
	muls.w	$10,d0			/ *10 (v_cel_ht)
	move.w	d0,-40(a0)		/ set v_cel_wr

/ new v_cel_mx = (bytes_lin / nplanes) - 1
	moveq.l	$0,d0			/ prepare d0,d1 as unsigned longs
	moveq.l	$0,d1
	move	-2(a0),d0		/ get bytes_lin
	move	(a0),d1			/ get nplanes
	divs	d1,d0			/ divide
	subq	$1,d0			/ -1
	move	d0,-44(a0)		/ set v_cel_mx

/ new v_cel_my = (v_rez_vt / 10) - 1

	move.l	$0,d0			/ pre-clear before load & divide
	move	-4(a0),d0		/ get v_rez_vt
	divs	$10,d0			/ /10
	subq	$1,d0			/ -1
	move	d0,-42(a0)		/ set v_cel_my
	addq	$1,d0			/ return new nrows
	rts

/font16()

	.globl font16_

font16_:			  / Switch to 8x16 font and return new nrows
	.word   0xA000		  / get the important pointers
	movea.l	8(a1),a1	  / a1 -> 8x16 font header
	move.l  72(a1),-0x0A(a0)  / v_off_ad <- 8x16 offset table addr
	move.l  76(a1),-0x16(a0)  / v_fnt_ad <- 8x16 font data addr
	move    $16,  -0x2E(a0)	  / v_cel_ht <- 16    8x16 cell height

/ new v_cel_wr (byte disp to next vertical alpha cell) = bytes_lin * v_cel_ht
	move.w	-2(a0),d0		/ get bytes_lin
	asl.w	$4,d0			/ *16 (v_cel_ht)
	move.w	d0,-40(a0)		/ set v_cel_wr

/ new v_cel_mx = (bytes_lin / nplanes) - 1
	moveq.l	$0,d0			/ prepare d0,d1 as unsigned longs
	moveq.l	$0,d1
	move	-2(a0),d0		/ get bytes_lin
	move	(a0),d1			/ get nplanes
	divs	d1,d0			/ divide
	subq	$1,d0			/ -1
	move	d0,-44(a0)		/ set v_cel_mx

/ new v_cel_my = (v_rez_vt / 16) - 1

	move.l	$0,d0			/ pre-clear before load & divide
	move	-4(a0),d0		/ get v_rez_vt
	asr.w	$4,d0			/ /16
	subq	$1,d0			/ -1
	move	d0,-42(a0)		/ set v_cel_my
	addq	$1,d0			/ return new nrows
	rts

/	-eof-

		.bssd
fnt_8x10:	.blkl	0x280
