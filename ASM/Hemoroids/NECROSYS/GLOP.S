DMA	=	$ffff8900
Master_Volume	=	%0000010011000000   0 -> 40	40
Left_Volume	=	%0000010101000000   0 -> 20	20
Right_Volume	=	%0000010100000000   0 -> 20	20
Treble	=	%0000010010000000   0 -> 24	6
Bass	=	%0000010001000000   0 -> 24	4
Mixing	=	%0000010000000000   00 = -12 Db
			  ; 01 = Mix Sample & YM
			  ; 10 = Sample Only ( <- /!\ )
			  ; 11 = Reserved
Sound_Lenght	=	186000

Prg_Add	=	$2000
Vbl_Flag	=	Prg_Add-10
Vbl_Flag2	=	Prg_Add-12

Mask	=	$07ff

	Section TEXT

*	Supervisor mode for... Well... For supervisor calls

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.b	$484.w

*	Memory shrink for AES calls

	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$500,d0
	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1
	move.l	d1,a7

	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)	Mshrink
	trap	#1

	lea	Haha(pc),a7

*	Application initialisation

	move	#10,control	APPL_INIT
	clr	control+2
	move	#1,control+4
	clr.l	control+6
	bsr	AES

*	Give a new address for File buffer

	pea	New_DTA(pc)	New DTA address
	move	#$1a,-(sp)	FSETDTA
	trap	#1
	addq.l	#6,sp

*	Switch to low resolution

	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move	d0,Old_Resol+2	   Save current resolution

	clr	-(sp)
	move.l	#($100000-Sound_Lenght-32000)&$ffff00,-(sp)
	move.l	(sp),Old_Screen
	move.l	(sp),-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *
*	       Load giga-mighty-wonder-music!	          *
* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *

	clr	-(sp)	Normal access
	pea	Default(pc)	File to search
	move	#$4e,-(sp)
	trap	#1	Hop hop!
	addq.l	#8,sp

	tst	d0
	beq.s	No_Problem	Music found !!! Great!!

	pea	No_Music(pc)
	move	#9,-(sp)
	trap	#1	Bouuuuuhhhh! No music...
	addq.l	#6,sp

	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	bra	Quit_Prog

No_Problem	move.l	#$100000-Sound_Lenght,a0
	move.l	a0,-(sp)
	bsr	FileOpen

	clr.l	Default
	clr.l	Default+4
	clr.l	Default+8
	clr.l	Default+12

*	Relocate music

	move.l	(sp)+,a0
	bsr	Relocate

*	Warning

	pea	Boring_Music(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

*	Interruption & vectors initialisation

	move	#$2700,sr

	move.l	$70.w,__Old_VBL+2

	lea	$fffffa00.w,a1
	lea	__Old_MFP(pc),a0

	move.l	$06(a1),2(a0)
	move.l	$12(a1),10(a0)
	move	$16(a1),18(a0)
	move	$1a(a1),24(a0)
	move	$20(a1),30(a0)

	clr	Vbl_Flag.w
	clr	Vbl_Flag2.w
	clr.l	$6c.w
	clr.l	$74.w

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,Old_Colors

*	Set DMA-Chip to good values

	move	#Mask,(DMA+$24).w  Set Mask

	move	#Master_Volume+1,d0
	bsr	Send_CMD
	move	#Treble+6,d0
	bsr	Send_CMD
	move	#Bass+4,d0
	bsr	Send_CMD
	move	#Left_Volume+20,d0
	bsr	Send_CMD
	move	#Right_Volume+20,d0
	bsr	Send_CMD
	move	#Mixing+2,d0
	bsr	Send_CMD

	move	#Master_Volume+40,d0
	bsr	Send_CMD	Master Volume -> Max
	move	#$0003,DMA.w

	move.l	#$100000-Sound_Lenght,a0
	jsr	(a0)	Install Vbl-Replay

* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *
*	                Main loop		          *
* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *

*	Change palette

__Hop	movem.l	New_Colors(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	Old_Screen(pc),d0
	move	d0,-(sp)
	move.b	(sp)+,d0
	move.l	d0,$ffff8200.w

	move	#$2700,sr

__Old_VBL	move.l	#0,$74.w

	lea	$fffffa00.w,a0
__Old_MFP	move.l	#0,$06(a0)
	move.l	#0,$12(a0)
	move	#0,$16(a0)
	move	#0,$1a(a0)
	move	#0,$20(a0)

	move	#-1,Vbl_Flag2.w

	move	#$2300,sr

	bsr	Fileselect

*	Test if HELP key has been hit

	tst	Keyboard
	beq.s	.Released

	btst.s	#$7,$fffffc02.w
	beq.s	.Pushed
	clr	Keyboard

.Released	cmpi.b	#$62,$fffffc02.w
	bne.s	.Pushed

	move	#-1,Keyboard
	eori	#$0003,DMA.w
.Pushed

*	Verify user answer

	tst	int_out+2
	beq	Quit_Prog0	Branch if cancel selected

* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *
*	         Load selected .PIF file	          *
* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *

	clr	-(sp)	Normal access
	pea	Default(pc)	File to search
	move	#$4e,-(sp)
	trap	#1	Hop hop!
	addq.l	#8,sp

	tst	d0
	bne	__Hop	File not found !!! 

	lea	Haha(pc),a0	Buffer address
	move.l	#$100000-Sound_Lenght,a1
	suba.l	a0,a1
	move.l	a1,d7
	lsr.l	#2,d7

	moveq	#0,d0
.Loop_Clear	move.l	d0,(a0)+
	subq.l	#1,d7
	bne.s	.Loop_Clear

	lea	Haha(pc),a0	Buffer address
	bsr	FileOpen

*	Get rid of interrupts

	clr	Vbl_Flag2.w
	clr.l	$fffffa12.w

*	Depack program

	lea	Haha(pc),a0	Address of packed program
	cmpi.l	#'TP10',(a0)
	beq.s	.Good_File

	pea	Bad_File(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	bra	__Hop

.Good_File	move.l	a0,d0
	add.l	New_DTA+26(pc),d0
	andi.l	#$00fffffe,d0
	addq.l	#2,d0
	move.l	d0,a1
	move.l	a1,-(sp)
	bsr	Depack

*	Relocate program

	movea.l	(sp),a0
	bsr	Relocate

*	Run it...

	movea.l	(sp)+,a0
	jsr	(a0)

	clr	Vbl_Flag.w
	clr	Vbl_Flag2.w

	bra	__Hop

* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *
*	                Exit part		          *
* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *

Quit_Prog0	move.b	#$ff,$484.w

Old_Resol	move	#0,-(sp)
	move.l	Old_Screen(pc),-(sp)
	move.l	(sp),-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

	clr	DMA.w

	movem.l	Old_Colors(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
Quit_Prog

*	Close AES Application

	move	#19,control	APPL_EXIT
	clr	control+2
	move	#1,control+4
	clr.l	control+6
	bsr	AES

*	Back to user mode

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

*	Babaillle !!

	clr	-(sp)
	trap	#1

*	Input: A0 = Address of Program to Relocate

Relocate	lea	28(a0),a1	Start Of Real Prg
	move.l	a1,d0	Save Address

	addq.l	#2,a0
	move.l	(a0)+,d1	Size of TEXT Section
	add.l	(a0)+,d1	+ Size of DATA Section
	move.l	(a0)+,d7	Skip size of BSS Section
	add.l	(a0)+,d1	+ Size of Labels Section (Shouldn't Exist!!)
	lea	(a1,d1.l),a0	Relocation Table Address
	move.l	a0,-(sp)

	move.l	(a0)+,d1	1st Offset on .L
	beq.s	.End_Reloc	No Relocation Needed
	adda.l	d1,a1	Else Add to Current Pointer
	add.l	d0,(a1)	Relocate

	moveq	#0,d1
.Loop_Relocate	move.b	(a0)+,d1	Get Next Offset on .B
	beq.s	.End_Reloc	End Relocation Now
	cmpi.b	#1,d1	Compare to Special value
	bne.s	.Dont_Add_Byte
	lea	$fe(a1),a1	Add Special Value
	bra.s	.Loop_Relocate
.Dont_Add_Byte	adda	d1,a1	Add Normal Value
	add.l	d0,(a1)	Relocate
	bra.s	.Loop_Relocate

.End_Reloc	move.l	(sp)+,a0
	lsr.l	#2,d7
	moveq	#0,d0

.Clear_BSS	move.l	d0,(a0)+
	subq.l	#1,d7
	bpl.s	.Clear_BSS

	rts

* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *
*          Depack source code for Tetrapack 1.0 (AXEL/HMD 1994)	          *
*                A0 = Start of packed data		          *
*                A1 = Address where to put depacked data	          *
*				          *
* Warning: the routine uses quite an important work area on stack so make *
*                 sure that stack size is at least 5kb.	          *
* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *

Work_Space	=	18+4084+98+74			; workspace

Depack	movem.l	d0-a5,-(a7)

	cmp.l	#'TP10',(a0)+
	bne	Exit

	link	a6,#-Work_Space
	move.l	a7,a6

	add.l	(a0)+,a1
	move.l	(a0)+,d0
	lea	(a0,d0.l),a2
	move.b	-(a2),d7

	moveq	#18,d2
	bsr	Testbit
	bcc.s	.skip
	moveq	#8,d4
	bsr	Readtree

.skip	move.w	d2,(a6)
	lea	Table1(pc),a4

Block	move.w	#18,2(a6)
	move.w	(a6),d2
	bsr	Testbit
	bcs.s	.next
	moveq	#8,d4
	bsr	Readtree
	move.w	d3,2(a6)

.next	moveq	#3,d4
	bsr	Readtree
	move.w	d3,4(a6)
	bsr	Readtree
	move.w	d3,6(a6)
	
	clr.b	8(a6)
	
	bsr	Testbit
	bcc.s	.length
	
	not.b	8(a6)
	moveq	#0,d0
	bsr	Readbits
	move.b	d1,9(a6)
	moveq	#2,d0
	bsr	Readbits
	move.b	9(a6),d0
	add.b	d1,d1
	add.b	d0,d1
	moveq	#0,d2
	moveq	#14,d3
	add.b	d0,d3

.make	cmp.b	d0,d1
	bne.s	.norm
	move.b	d3,10(a6,d2.w)
	bra.s	.cont

.norm	move.b	d0,10(a6,d2.w)

.cont	addq.b	#2,d0
	addq.b	#1,d2
	cmp.b	#7,d2
	bne.s	.make
	move.b	d1,17(a6)
	bchg	#0,9(a6)

.length	moveq	#14,d0
	bsr	Readbits
	move.l	a1,a3
	sub.w	d1,a3

Decrunch	move.w	2(a6),d1
	bsr	Readcode
	btst	#8,d0
	bne.s	String
	move.b	d0,-(a1)

Test	cmp.l	a1,a3
	bne.s	Decrunch
	cmp.l	a0,a2
	beq	Done
	bra	Block

String	move.w	4(a6),d1
	bsr	Readcode
	move.w	d0,d2
	add.w	d2,d2
	move.w	(a4,d2.w),d2
	subq.w	#1,d0
	bpl.s	.bigger
	bsr	Testbit
	bcc.s	.offset
	subq.w	#1,d2
	bra.s	.offset

.bigger	bsr.s	Readbits
	add.w	d1,d2

.offset	move.w	6(a6),d1
	bsr.s	Readcode
	move.w	d0,d3
	add.w	d3,d3
	move.w	Table2-Table1(a4,d3.w),d3
	
	tst.b	8(a6)
	beq.s	.normal
	
	moveq	#0,d4
	subq.w	#1,d0
	bmi.s	.skip
	bsr.s	Readbits
	lsl.w	#4,d1
	move.w	d1,d4

.skip	moveq	#2,d0
	bsr.s	Readbits
	cmp.b	#7,d1
	beq.s	.special
	move.b	10(a6,d1.w),d1
	bra.s	.add

.special	bsr.s	Testbit
	bcs.s	.more
	move.b	17(a6),d1
	bra.s	.add

.more	moveq	#2,d0
	bsr.s	Readbits
	add.b	d1,d1
	add.b	9(a6),d1

.add	add.w	d4,d1
	bra.s	.string

.normal	addq.w	#3,d0
	bsr.s	Readbits

.string	add.w	d3,d1
	lea	1(a1,d1.w),a5

.copy	move.b	-(a5),-(a1)
	dbra	d2,.copy
	bra	Test

Done	lea	Work_Space(a6),a6
	unlk	a6

Exit	movem.l	(a7)+,d0-a5

	rts

Readbits	moveq	#0,d1

.read	add.b	d7,d7
	bne.s	.skip
	move.b	-(a2),d7
	addx.b	d7,d7

.skip	addx.w	d1,d1
	dbra	d0,.read

	rts
	
Testbit	add.b	d7,d7
	bne.s	ret
	move.b	-(a2),d7
	addx.b	d7,d7

ret	rts	

Readcode	move.w	(a6,d1.w),d0
	bpl.s	ret
	bsr.s	Testbit
	bcs.s	.right
	move.w	2(a6,d1.w),d1
	bra.s	Readcode

.right	move.w	4(a6,d1.w),d1
	bra.s	Readcode
	
Readtree	bsr.s	Testbit
	bcs.s	.node
	move.w	d4,d0
	bsr.s	Readbits
	move.w	d2,d3
	addq.w	#2,d2
	move.w	d1,(a6,d3.w)
	rts

.node	move.w	d2,d3
	addq.w	#6,d2
	move.w	#-1,(a6,d3.w)
	move.w	d3,-(sp)
	bsr.s	Readtree
	move.w	(sp),d0
	move.w	d3,2(a6,d0.w)
	bsr.s	Readtree
	move.w	(sp)+,d0
	move.w	d3,4(a6,d0.w)
	move.w	d0,d3
	rts

Table1	dc.w	2,2+1,2+1+2,2+1+2+4,2+1+2+4+8,2+1+2+4+8+16,2+1+2+4+8+16+32
	dc.w	2+1+2+4+8+16+32+64,2+1+2+4+8+16+32+64+128,2+1+2+4+8+16+32+64+128+256
	dc.w	2+1+2+4+8+16+32+64+128+256+512,2+1+2+4+8+16+32+64+128+256+512+1024
	dc.w	2+1+2+4+8+16+32+64+128+256+512+1024+2048

Table2	dc.w	0,16,16+32,16+32+64,16+32+64+128,16+32+64+128+256
	dc.w	16+32+64+128+256+512,16+32+64+128+256+512+1024
	dc.w	16+32+64+128+256+512+1024+2048
	dc.w	16+32+64+128+256+512+1024+2048+4096
	EVEN
End_Unpacker

FileOpen	move	#2,-(sp)
	pea	Default(pc)	File to load
	move	#$3d,-(sp)	Fopen
	trap	#1
	addq.l	#8,sp

	move.l	d0,d7	Save Handle
	bmi.s	.Quit_Read

	move.l	a0,-(sp)	File address
	move.l	New_DTA+26(pc),-(sp)	Lenght
	move	d7,-(sp)	Handle
	move	#$3f,-(sp)	Fread
	trap	#1
	add.l	#12,sp
	bmi.s	.Quit_Read

	move	d7,-(sp)	Handle
	move	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

.Quit_Read	rts

Fileselect	move	#90,control	FSEL_INPUT
	move	#0,control+2
	move	#2,control+4
	move	#2,control+6
	move	#0,control+8
	move.l	#Path,addr_in
	move.l	#Default,addr_in+4
	bsr	AES

	rts

AES	move.l	#Params,d1
	move	#$c8,d0
	trap	#2
	rts

Send_CMD	cmpi	#Mask,(DMA+$24).w
	bne.s	*-6
	move	d0,(DMA+$22).w

	rts

	Section DATA

Keyboard	dc.w	0
Old_Screen	dc.l	0

New_Colors	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000357
Old_Colors	ds.l	8

No_Music	dc.b	$1b,"ESorry!! No music file found!",0
Boring_Music	dc.b	$1b,"EGlop! If the music upsets you,push HELP! ",0
Bad_File	dc.b	$1b,"ENot a .PAF File!! (You dumb ass!)",0
	EVEN

Path	dc.b	"a:\*.PIF"
	dcb.l	18,0
Default	dc.b	"zikeumuh.zik",0,0,0,0

Params	dc.l	control,global,int_in,int_out
	dc.l	addr_in,addr_out
global	ds.l	8
control	ds.l	5
int_in
int_out	dc.w	0
	dc.w	0
addr_in	ds.l	64
addr_out	ds.l	64

New_DTA	ds.l	11

	Section BSS

	ds.b	6*1024
Haha	END