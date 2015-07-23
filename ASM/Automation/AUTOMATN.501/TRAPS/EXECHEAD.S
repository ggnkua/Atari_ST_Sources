* EXEC HEADER FOR EXEC FILES PACKED WITH AUTOMATION v5.01
* -------------------------------------------------------
*
* Main code: Pompey Pirates (from Pompey Packer v1.9a)
*
* Additional code: I Wonder Who Wrote This Trash Industries, 1991
*
* Instructions
* ------------
*
* Pack your main program file as a data file, alter this source to your
* own requirements (text etc.) and assemble it to disk.
*
* Clearbss can be turned off using NO to save a couple of bytes if your
* packed program has no BSS area.

no	equ	0
yes	equ	1

low_res	equ	no	; Force Low Resolution 
text_on	equ	no	; Print Text
wait_on	equ	no	; Wait for key
pre_reg	equ	no	; Preserve registers
clr_bss	equ	no	; Clear BSS segment (see above)
flash	equ	no	; Flash depack colours
fade_on	equ	no	; Fade Colours In/Out (Low res)

	opt	o+

	bra.s	start
	dc.b	"A MUG U.Kø (of The Source) pack in 1992 !!"
	even

start
	ifne	pre_reg
	movem.l	d0-d7/a0-a6,start-128
	endc
	move.l	4(sp),a5		base page address
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)

	ifne	low_res		; Low resolution
	clr.w	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endc

	ifne	fade_on
	move.w	#$666,d6		Fade background to black
.loop1	move.w	d6,$ffff8240.w
	bsr	delay
	sub.w	#$111,d6
	bpl.s	.loop1
	endc

	ifne	text_on		; Print text
	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifne	fade_on
	move.w	#$111,d6		Fade text to white
.loop2	move.w	d6,$ffff825e.w
	bsr	delay
	add.w	#$111,d6
	cmp.w	#$888,d6
	bne.s	.loop2
	endc

wait	ifne	wait_on		; Wait for keypress
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

	lea	packedfile,a0

;-------------------------------------------------------------
;Automation v5.01 - 'A0 -> A0 depacker'
;-------------------------------------------------------------
depack
AU5_decrunch_2:
	link	a3,#-120
	ifne	flash
	move.w	$ff8240,-(sp)
	endc
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	
	move.l	a4,a6		
	bsr.s	.getinfo
	cmpi.l	#'AU5!',d0
	bne.s	.not_packed
	bsr.s	.getinfo	
	lea.l	-8(a0,d0.l),a5	
	bsr.s	.getinfo	
	move.l	d0,(sp)		
	adda.l	d0,a6		
	move.l	a6,a1

	moveq	#119,d0		
.save:	move.b	-(a1),-(a3)	
	dbf	d0,.save
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr.s	.normal_bytes
	move.l	a3,a5		

	bsr	.get_1_bit	
	bcc.s	.no_picture	
	move.w	#$0f9f,d7 	
.AU5_00:
	moveq	#3,d6	
.AU5_01:
	move.w	-(a3),d4
	moveq	#3,d5		
.AU5_02:
	add.w	d4,d4	
	addx.w	d0,d0		
	add.w	d4,d4		
	addx.w	d1,d1		
	add.w	d4,d4		
	addx.w	d2,d2		
	add.w	d4,d4		
	addx.w	d3,d3		
	dbra	d5,.AU5_02	
	dbra	d6,.AU5_01	
	movem.w	d0-d3,(a3)	
	dbra	d7,.AU5_00	
.no_picture
	movem.l	(sp),d0-a3	

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		
.rest	move.b	-(a3),-(a5)	
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	ifne	flash
	move.w	(sp)+,$ff8240
	endc
	unlk	a3
	bra	sort_it_out

.getinfo: 
	moveq	#3,d1		
.getbytes:
	lsl.l	#8,d0	
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	
	moveq.l	#0,d1		
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:
	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		
	dbne	d3,.nextgb	
.no_more: 
	add.l	20(a1),d1 	
.copy_direkt:	
	move.b	-(a5),-(a6)	

	ifne	flash		; flash colours if required !!
;	move.w	d0,$ffff8240.w	; Standard Auto v5.01 flash
	move.w	d7,$ffff8240.w	; Greenies (not the nasal variety !!)
;	not.w	$ffff8240.w	; Black & White Minstrels !!
;	move.b	(a6),$ffff8240.w	; Medway Boys F/X
;	eori.w	#$201,$ffff8240.w	; Dream Warriors F/X
	endc
	
	dbf	d1,.copy_direkt	
.test_if_end:	
	cmpa.l	a4,a6		
	bgt.s	.strings	
	rts	

.get_1_bit:
	add.b	d7,d7		
	bne.s	.bitfound 	
	move.b	-(a5),d7	
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		
.hole_bit_loop:	
	add.b	d7,d7		
	bne.s	.on_d0		
	move.b	-(a5),d7	
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		
	dbf	d0,.hole_bit_loop	
	rts	

.strings: 
	lea.l	.length_tab(pc),a1	
	moveq.l	#3,d2		
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4		
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bmi.s	.no_Åber	
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4	
	beq.s	.get_offset_2	

	lea.l	.more_offset(pc),a1 
	moveq.l	#1,d2
.getoffs: 
	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bsr.s	.get_d0_bits
	add.w	d2,d2		
	add.w	6(a1,d2.w),d1	
	bpl.s	.depack_bytes	
	sub.w	d4,d1		
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		
	moveq.l	#5,d0		
	moveq.l	#-1,d2		
	bsr.s	.get_1_bit
	bcc.s	.less_40	
	moveq.l	#8,d0		
	moveq.l	#$3f,d2		
.less_40: 
	bsr.s	.get_d0_bits
	add.w	d2,d1		

.depack_bytes:			
	lea.l	2(a6,d4.w),a1	
	adda.w	d1,a1		
	move.b	-(a1),-(a6)	
.dep_b:	move.b	-(a1),-(a6)	
	dbf	d4,.dep_b 	
	bra	.normal_bytes	


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	
	dc.l 270-1,15-1,8-1,5-1,2-1	

.length_tab:
	dc.b 9,1,0,-1,-1	
	dc.b 8,4,2,1,0		

.more_offset:
	dc.b	  11,   4,   7,  0	
	dc.w	$11f,  -1, $1f	

ende_AU5_decrunch_2:
;----------------------------------------------------
sort_it_out

	trap	#1		; user mode
	addq.l	#6,sp

	lea	packedfile,a3	; start of packed file in a3

* a3 is pointing to start of depacked program

	move.l	2(a3),a0		text segment
	add.l	6(a3),a0		+ data segment
	add.l	14(a3),a0		+ symbol table
	lea	28(a0),a0		+ header
	add.l	a3,a0		+ start of program
* a0 now points to relocation table
	move.l	8(a5),d0		d0 points to TEXT
	lea	28(a3),a3		a3 points to program
	move.l	a3,a6
	tst.l	(a0)		zero 1st relocation?
	beq.s	done_reloc

	moveq	#0,d1
	add.l	(a0)+,a3		+ offset
relocate	add.l	d0,(a3)		relocate it
add_no_reloc	move.b	(a0)+,d1		next byte
	beq.s	done_reloc		zero is end
	cmp.b	#1,d1		1 is add 254, but
	bne.s	not1		don't relocate
	lea	254(a3),a3
	bra.s	add_no_reloc
not1	add.l	d1,a3		+ offset
	bra.s	relocate

done_reloc	lea	packedfile+2(pc),a2	past $601a
	move.l	(a2),12(a5)		write real TEXT len
	add.l	(a2),d0		TEXT len + TEXT addr
	move.l	d0,16(a5)		write real DATA addr
	move.l	4(a2),20(a5)		write real DATA len
	add.l	4(a2),d0		+ DATA len
	move.l	d0,24(a5)		write real BSS addr
	move.l	8(a2),28(a5)		write real BSS len

* now move code somewhere safe
	move.l	sp,a0
	lea	-256(a0),a0
	pea	(a0)
	lea	mover(pc),a1
	moveq	#(endofmover-mover)/2-1,d0
copy_mover	move.w	(a1)+,(a0)+
	dbf	d0,copy_mover
	rts

* move the program down to the correct address
mover	move.l	12(a5),d0		TEXT len
	add.l	20(a5),d0		+ DATA len
	lsr.l	#1,d0		divide by 2
	addq.l	#1,d0		one for luck
	move.l	8(a5),a4		pointer to TEXT addr
	pea	(a4)		run address
copydown	move.w	(a6)+,(a4)+
	subq.l	#1,d0
	bne.s	copydown

	ifne	clr_bss
* clear the BSS
	move.l	28(a5),d1
	add.l	#(packedfile-start)+28,d1
	lsr.l	#2,d1		bug fixed...!
	addq.l	#1,d1
clrbss	move.l	d0,(a4)+
	subq.l	#1,d1
	bne.s	clrbss
	endc

	ifne	pre_reg
	movem.l	start-128,d0-d7/a0-a6
	movem.l	d0-d7/a0-a6,-(sp)
	lea	start-128,a0
	moveq	#15-1,d0
clregs	clr.l	(a0)+
	dbf	d0,clregs
	movem.l	(sp)+,d0-d7/a0-a6
	endc

	rts			run the program
endofmover
	
	ifne	fade_on
delay	moveq	#7,d7		Delay used in fading colours
.1	move.w	#$25,-(a7)	Wait for VBL
	trap	#14
	addq.l	#2,a7
	dbf	d7,.1
	rts
	endc
;
; Text Message goes here
;

	ifne	text_on
text	dc.b	27,"E"	; CLS
	dc.b	27,"f"	; Hide cursor
	;	 0123456789012345678901234567890123456789 ; 40 chars

	dc.b	"+--------------------------------------+",13,10
	dc.b	"| Revenge Of The Mutant Camels by YAK! |",13,10
	dc.b	"|                                      |",13,10
	dc.b	"| Packed by: MUG U.Kø (of The Source) !|",13,10
	dc.b	"+--------------------------------------+",13,10
	dc.b	0
	endc
;
; the packed exec file goes here
;
packedfile	incbin	"e:\mega_3d.tos"
endoffile