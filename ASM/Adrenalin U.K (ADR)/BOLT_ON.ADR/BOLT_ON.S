*************************************************************************
*			ADRENALIN BOLT ON TO GAME INTRO			*
*			------------------------------- 		*
*									*
* Written by:	SPACEMAN SPIFF						*
*									*
* Date:		2/6/93							*
*									*
*									*
*									*
*									*
*									*
*************************************************************************
*
* This is just like ADR 35 v2 except instead of P_EXECing a game you
* include the packed game in here (exec packed as data using ATOMIC 3.5)
*
* I have used a DIGI-DRUM tune here BUT because I knock out the top
* border I had to disable the digi-drum tune in the lower border.
* The results is a slightly wavy digi-drum. If you have a keen ear you
* will notice it straight away otherwise it's ok.
*
* You can bolt a normal tune in if you wish or replace the present digi-drum
* tune with another digi one. The present tune uses timerd ($110) as it's
* drum driver and uses A6 all the time so don't use A6 in your program.
* Any mad max tunes should simply bolt in.
*
* SPACEMAN SPIFF 2/6/93
*
*

yes=1
YES=yes
no=0
NO=no



FINAL		equ	no		;put to YES for disc version

RASTER_COLOUR	equ	$ffff8242	;colour coloured by rasters

DISPLAY_TIME	equ	200		;time text is held on screen
					;Increase this to allow user
					;to read text

STARS		equ	130		;number of stars to stick on screen
					;you can INCREASE this until it goes
					;into 2 frames if you want!

start		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.w	#2,d0
clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		bsr	sort_text
		bsr	make_yp_tab	; make up a table of Y coordinates

		bsr	setup

main_loop	bsr	flip_screen
		bsr	vsync
;		move.w	#$123,$ffff8240.w
		bsr	clear_stars	;clear the star field
		bsr	starfield	;move, calculate and print starfield.
		bsr	print_text
		jsr	music+4
;		move.w	hertz_toggle,$ffff8240.w

		moveq	#0,d0
		move.b	key,d0

		cmp.b	#1,d0
		beq.s	stop

		cmp.b	#11,d0		;0 keyboard
		beq	zero

		cmp.b	#$70,d0		;0 keypad
		beq	zero

		cmp.b	#$53,d0		;DEL=RESET!
		beq	reset

		cmp.b	#$39,d0
		bne	main_loop

;okay space was pressed so run prog

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50		bra	run_bolt_on
stop
		bsr	reset_isr
		move.b	#8,$fffffc02.w
		bsr	set_user
		clr.w	-(sp)
		trap	#1


run_bolt_on
		bsr	reset_isr
		move.b	#8,$fffffc02.w

		bsr	set_user


* EXEC HEADER FOR EXEC FILES PACKED WITH ATOMIC PACKER v3.5
* ---------------------------------------------------------
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
* Add your own code alterations from label marked 'alter_me' onwards
* (eg. trainer mode).
*
* Clearbss can be turned off using NO to save a couple of bytes if your
* packed program has no BSS area.


low_res		equ	no	; Force Low Resolution 
ascii_text_on	equ	no	; Print Text
wait_on		equ	no	; Wait for key
delay_on	equ	no	; Delay to before clearing text.
pre_reg		equ	no	; Preserve registers
clr_bss		equ	yes	; Clear BSS segment (see above)
flash		equ	yes	; Flash depack colours
fade_on		equ	no	; Fade Colours In/Out (Low res)


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

	ifne	ascii_text_on		; Print text
	pea	ascii_text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ELSE
	ifne	delay_on
	move.w	#20000,d7
.delay	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.yea
	dbf	d7,.delay
	bra.s	.no
.yea	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
.no	endc
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

	ifne	flash		; Store border colour
	lea	store(pc),a0
	move.w	$ffff8240.w,(a0)
	endc

	lea	packedfile,a0	; go past ATOM header
;----------------------------------------------------	
;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

MODE:	EQU	1
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5

	ifne	flash		; Store border colour
	move.w	d4,$ffff8240.w	;d2 or d4=flash blue
				;d7 flash green like automation!
	endc

.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
	bra	sort_it_out
 
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc
;----------------------------------------------------
sort_it_out

	ifne	flash
	move.w	store(pc),$ffff8240.w
	endc

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

done_reloc	lea	packedfile+2,a2	past $601a
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
* if you wish to modify part of your program file, but don't wish to repack
* it, you can put a piece of code like this at this point:
*	move.l	8(a5),a5	a5 now points to TEXT area of prog.
* now you can carry out modifications off (a5), etc. such as:
*	move.w	#$4e71,20(a5)
* or whatever you want!
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
	ifne	flash
store	ds.w	1
	endc

	ifne	ascii_text_on
ascii_text	dc.b	27,"E"	; CLS
	dc.b	27,'Y',32+6,32+15,"Packed by"
	dc.b	27,'Y',32+8,32+14,"MAC SYS DATA"
	dc.b	27,'Y',32+10,32+19,"of"
	dc.b	27,'Y',32+12,32+9,"Persistence Of Vision"
	dc.b	27,'Y',32+14,32+13,"1 Meg ram only"
	dc.b	0
	endc
	even
	


zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$020,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts



*-----------------------------------------------------------------------*
*				3D STARFIELD PRINT			*
*-----------------------------------------------------------------------*

starfield

.move_stars			; this moves the stars around!
	lea	XRAND(pc),a0	; get bank of random x-coords
	lea	YRAND(pc),a1	;  "   "   "    "    y-coords
	lea	ZRAND(pc),a2	;  "   "   "    "    z-coords
	move.w	xi(pc),d0	; xi = X increment, in d0
	move.w	yi(pc),d1	; yi = Y increment, in d1
	move.w	zi(pc),d2	; zi = Z increment, in d2
	move.w	#127,d3		; x/y max limit of stars in space
	move.w	#511,d4		; z max limit of stars in space
	move.w	#STARS,d7	; number of stars to do in d7
.lp	move.w	(a0),d6		; get star x-coord
	add.w	d0,d6		; change x-coord by amount in (xi)
	and.w	d3,d6		; if x<0 then x=127 : if x>127 then x=0
	move.w	d6,(a0)+	; put x-coord back in buffer

	move.w	(a1),d6		; get star y-coord
	add.w	d1,d6		; change y-coord by amount in (yi)
	and.w	d3,d6		; if y<0 then y=127 : if y>127 then y=0
	move.w	d6,(a1)+	; put y-coord back in buffer

	move.w	(a2),d6		; get star z-coord
	add.w	d2,d6		; change z-coord by amount in (zi)
	and.w	d4,d6		; if z<0 then z=511 : if z>511 then z=0
	move.w	d6,(a2)+	; put z-coord back in buffer

	dbra	d7,.lp		; do next star in buffer.



.print_stars			; this sticks the stars on screen
	lea	Y_PLOT,a5	; get list of y-coords on screen
	move.l	a5,d7
	lea	.plot(pc),a5	; list of plot routs. (colours)
	lea	XRAND(pc),a1	; get coords of stars
	lea	YRAND(pc),a2
	lea	ZRAND(pc),a3
	move.w	#STARS,d0	; number of stars to do in d0
	moveq	#7,d2		; use this later (shift left of 7 = * 128)
.loop	move.w	(a3)+,d1	; z-coord
	move.w	d1,d3		; save for colour (0-511)
	neg.w	d1		;
	move.w	d1,d4		;
	add.w	#511,d1		;
 	ext.l	d4
	lsl.l	d2,d4		;shift left by 7 places = * 128
	divs	d1,d4
	move.w	(a1)+,d1	;get x coords
	sub.w	#64,d1
	move.w	d1,d5
	neg.w	d1
	muls	d4,d1
	lsr.l	d2,d1		;div by 128
	add.w	d1,d5
	move.w	(a2)+,d1
	add.w	#160,d5		; touch this and it will crash!!!
	bmi.s	.end		;
	sub.w	#64,d1
	move.w	d1,d6
	neg.w	d1
	muls	d1,d4
	lsr.l	d2,d4		;div by 128
	add.w	d4,d6
	neg.w	d6
	add.w	#100,d6		; touch this and it will crash!!!
	bmi.s	.end		;
	cmp.w	#320-1,d5	; (limits of screen coordinates)
	bgt.s	.end		;	low res - 320*200
	cmp.w	#200-1,d6	;
	bgt.s	.end		;

.log	move.l	present_base,a4	;get present screen address
	add.w	#160*30,a4
	add.w	d6,d6		;add y coords to y coords
	move.l	a5,-(sp)
	move.l	d7,a5
	add.w	(a5,d6),a4	;add x to y and get real pos
	move.l	(sp)+,a5
	move.w	d5,d6
	and.w	#$FF0,d6
	lsr.w	d6  		;div 2
	add.w	d6,a4
	and.b	#$F,d5		;make on 16 byte boundary
	move.w	#%1000000000000000,d6
	lsr.w	d5,d6		;shift to star position
	lsr.w	#3,d3		;div colour by 8
	and.w	#%11111100,d3	;mask by 4
	move.l	(a5,d3),a0

***************
	movem.l	a4/a5,-(sp)	;bit for new clear_stars routine by MAC SYS DATA
	move.l	old_stars_pos,a5
	sub.l	present_base,a4
	move.l	a4,(a5)+
	move.l	a5,old_stars_pos
	movem.l	(sp)+,a4/a5
**************
	jmp	(a0)

.end	dbra	d0,.loop
	bra.s	.control_stars

.P0	dbra	d0,.loop	; these routines plot pixels in 7 colours
	bra.s	.control_stars
.P2	or.w	d6,4(a4)	
	dbra	d0,.loop

*-------------------------------*

.control_stars		; this makes the stars change direction
	subq.w	#1,STARTIME
	bne.s	.ok

	move.l	star_time_table_pos,a0
	tst.w	(a0)
	bpl.s	.yes
	lea	star_time_table,a0
.yes	move.w	(a0)+,STARTIME
	move.l	a0,star_time_table_pos

	addq	#1,STARDIR
	and.w	#$1F,STARDIR
.ok	addq	#1,FRAME
	and.w	#7,FRAME
	bne.s	.n3	
	lea	DIR_TAB(pc),a0
	move.w	STARDIR(pc),d0
	mulu	#6,d0
	move.w	0(a0,d0),d1
	move.w	2(a0,d0),d2
	move.w	4(a0,d0),d3
	cmp.w	xi(pc),d1
	beq.s	.n1
	bgt.s	.g1
	subq	#1,xi
	bra.s	.n1
.g1	addq	#1,xi
.n1	cmp.w	yi(pc),d2
	beq.s	.n2
	bgt.s	.g2
	subq	#1,yi
	bra.s	.n2
.g2	addq	#1,yi
.n2	cmp.w	zi(pc),d3
	beq.s	.n3
	bgt.s	.g3
	subq	#2,zi
	bra.s	.n3
.g3	addq	#2,zi
.n3	rts

.plot	dc.l	.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2	; list of colour
	dc.l	.P2,.P2,.P2,.P2,.P2,.P0			; plot routs.

*-------------------------------*

make_yp_tab	; make Y-POS > SCREEN conversion table
		lea	Y_PLOT+400,a0
		move.w	#200-1,d0
.lp		move.w	d0,d1
		mulu	#160,d1
		move.w	d1,-(a0)
		dbra	d0,.lp
		rts


;*******************************************************
; New clear_stars routine
; coded by MAC SYS DATA 'cos the old one was shit slow
;*******************************************************
clear_stars	lea	old_stars,a0
		moveq	#0,d0
	 	move.l	last_base,d2
		REPT	STARS
		move.l	(a0)+,a1
		move.w	d0,4(a1,d2.l)
		ENDR
		rts







print_text	tst.w	disc_clear_enable
		bne	.do_clear
		tst.w	disc_enable
		beq.s	.do_stuff
		rts
.do_stuff	move.l	text_pos,a1
		move.l	present_base,a0
		move.l	last_base,a3
.restart	moveq	#0,d1
		move.b	(a1)+,d1
		move.l	a1,text_pos
		cmp.b	#-1,d1
		bne.s	.no_reset
		move.l	#middle_text,a1
		bra.s	.restart
.no_reset	cmp.b	#"^",d1		;termintor
		bne.s	.do_text
		cmp.b	#13,(a1)
		bne.s	.notcr_here	;if CR is here then take for granted CR,LF
		add.l	#2,text_pos
.notcr_here	move.w	#-1,disc_clear_enable
		move.w	#-1,disc_enable
		move.w	#17*16,lines_to_do
		move.w	#DISPLAY_TIME,do_clear_delay
		clr.b	xpos
		clr.b	ypos
		rts
.do_text	cmp.b	#13,d1
		bne.s	.notcr
		clr.b	xpos
		bra	.restart
.notcr		cmp.b	#10,d1
		bne.s	.notlf
		addq.b	#1,ypos
		bra	.restart
.notlf		cmp.b	#9,d1		;HORIZONTAL TAB
		bne.s	.notab		;routine added 11/2/92 for print speed
;calc TAB by getting MOD 8.
		moveq	#0,d5
		move.b	xpos,d5
		and.w	#%111,d5	;mod 8
		move.w	#8,d4
		sub.w	d5,d4		;sub MOD 8
		add.b	d4,xpos		;add to XPOS so now we are in correct word
		bra	.restart
.notab		sub.b	#32,d1
		mulu	#32,d1
		lea	font,a2
		add.w	d1,a2
		moveq	#0,d0
		move.b	ypos,d0
		mulu	#160*16,d0	;drop down 16 pixels...
		add.l	d0,a0
		add.l	d0,a3
		move.b	xpos,d0
		and.l	#$ff,d0
		lsl.l	#3,d0	;*8	;bytes across screen
		add.l	d0,a0
		add.l	d0,a3
		addq.b	#1,xpos
LINE_OFFSET	set	0
		rept	16
		move.w	(a2),LINE_OFFSET(a0)
		move.w	(a2)+,LINE_OFFSET(a3)
LINE_OFFSET	set	LINE_OFFSET+160
		endr
		rts
.do_clear	tst.w	do_clear_delay
		beq.s	.yeah
		sub.w	#1,do_clear_delay
		rts
.yeah		tst.w	lines_to_do
		beq	.stop
		sub.w	#1,lines_to_do
		move.l	present_base,a0
		move.l	last_base,a3
		add.l	clear_line_offset,a0
		add.l	clear_line_offset,a3
		moveq	#0,d0
OFF	set	0
		rept	40
		move.w	d0,OFF(a0)
		move.w	d0,OFF(a3)
OFF	set	OFF+8
		endr
		add.l	#160,clear_line_offset
		rts
.stop		clr.w	disc_clear_enable
		move.w	#1,disc_enable
		clr.l	clear_line_offset
		rts

sort_text	lea	middle_text,a0
		lea	disc_start_table,a1
		move.l	a0,(a1)+	;poke start of disc into lookup table
.loop		cmp.b	#$ff,(a0)	;is end of list???
		beq.s	.quit
		move.b	(a0)+,d0
		cmp.b	#'^',d0
		bne.s	.loop
		move.b	(a0)+,d0	;cr
		move.b	(a0)+,d0	;lf
		move.l	a0,(a1)+
		bra.s	.loop
.quit		rts













setup
		clr.l	-(sp)			;Set super
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.b	#$12,$fffffc02.w	;no mouse

		move.l	$44e.w,old_base

		movem.l	$ffff8240.w,d0-d7	;save old pal
		movem.l	d0-d7,old_pal

		move.b	$ffff8260.w,old_rez	;save rez

; IF USING A PICTURE THEN UNREMARK THE FOLLOWING 2 LINES
;;		movem.l	pic+2,d0-d7		;set new pal
;;		movem.l	d0-d7,$ffff8240.w

		clr.w	$ffff8240.w
		move.w	#-1,$ffff8248.w	;stars

		clr.b	$ffff8260.w		;low rez

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,present_base
		move.l	d0,screen_1
		add.l	#49152,d0
		move.l	d0,screen_2

		move.l	screen_1,a0		;new screen base
		bsr	set_screen
		bsr	flip_screen

;; IF USING A PICTURE UNREMARK THE FOLLOWING 2 LINES
;;		lea	pic+34,a0
;;		move.l	screen_1,a1
;;		move.l	screen_2,a2
;;		move.w	#(160*60)/4-1,d0
;;.show		move.l	(a0),(a1)+
;;		move.l	(a0)+,(a2)+
;;		dbf	d0,.show
		
		lea	storage,a0		;store old MFP
		move.l	$120.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$70.w,(a0)+
		move.b	$fffffa11.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa0f.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa25.w,(a0)+

		move.w	#$2700,sr
		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		move.l	#border_timerb,$120.w
		move.l	#new70,$70.w
		move.l	#new118,$118.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto isr ena

		moveq	#1,d0
		jsr	music

		move.w	#$2300,sr
		rts





reset_isr	moveq	#0,d0
		jsr	music

		move.w	#$2700,sr
		lea	storage,a0		;store old MFP
		move.l	(a0)+,$120.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$70.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa21.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa25.w
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	old_base,a0
		bsr	set_screen

		move.b	old_rez,$ffff8260.w
		rts

;******* timerb code ****************************************************


timerb_part1	clr.b	$fffffa1b.w
		move.l	a0,-(sp)
		move.l	colour_pos,a0
		move.w	(a0)+,RASTER_COLOUR.w
		move.l	a0,colour_pos
		move.l	(sp)+,a0
		sub.w	#1,raster_counter
		beq.s	.setup_border_timerb
		move.b	#16,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte
.setup_border_timerb
		move.l	#border_timerb,$120.w
		move.b	#3,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte

border_timerb	or.w	#$700,sr
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
.wait		cmp.b	#$80,$ffff8209.w
		blo.s	.wait
		dbt	d0,*
		dbt	d0,*
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$80,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	88
		nop
		ENDR
		dbt	d0,*
		dbt	d0,*
		clr.b	$ffff820a.w
		nop
		movem.l	(sp)+,d0/a0
		move.b	#2,$ffff820a.w

		bclr	#4,$fffffa15.w	;Disable digi-drum

		rte

;********* new vbl ******************************************************
new70		move.w	#$2700,sr

; IF YOU USE A PICTURE + RASTERS YOU WILL HAVE TO PUT THE PICTURE COLOURS
; BACK SO UN-REMARK THE FOLLOWING 4 LINES AND REMOVE THE +26 FROM THE
; LINE	move.w #$57e+26.d0
;
;		movem.l	d0-d7,-(sp)
;		movem.l	pic+2,d0-d7
;		movem.l	d0-d7,$ffff8240.w
;		movem.l	(sp)+,d0-d7

		move.w	d0,-(sp)
		move.w	#$57e+26,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w

		bset	#4,$fffffa15.w		;enable digi-drum

		move.w	colours,RASTER_COLOUR.w
		move.w	(sp)+,d0
		move.w	hertz_toggle,$ffff8240.w
		move.l	#old_stars,old_stars_pos
		move.l	#colours,colour_pos
		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.w	#15,raster_counter
		move.l	#timerb_part1,$120.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		tst.w	disc_enable
		bne.s	.dec
		tst.w	hertz_delay
		beq.s	.no_hz_dec
		sub.w	#1,hertz_delay
.no_hz_dec	rte
.dec		sub.w	#1,disc_enable
		tst.w	hertz_delay
		beq.s	.no_hz_dec
		sub.w	#1,hertz_delay
		rte

new118		move.w	#$2500,sr
		move.b	$fffffc02.w,key
		bclr	#6,$fffffa11.w
		rte



***********************
* SUBROUTINES SECTION *
***********************
set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp
		rts



vsync		move.w	#-1,vsync_flag	;custom routine to wait
.vs		tst.w	vsync_flag		;for screen refresh
		bne.s	.vs
		rts

flip_screen	;flip between 2 screens to stop flickering
		move.l	present_base,last_base
		move.l	screen_1,a0
		move.w	screen_number,d0
		beq	.1
		move.l	screen_2,a0
.1		move.l	a0,present_base
		eor.w	#-1,screen_number

set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts

***************************
	SECTION DATA
***************************

colours		dc.w	$300,$400,$500,$600,$700,$702,$703,$704,$705,$706
		dc.w	$707,$607,$507,$407,$307

xi		ds.w		1
yi		ds.w		1
zi		ds.w		1
FRAME		ds.w		1
STARDIR		ds.w		1
STARTIME	dc.w		200
XRAND		incbin	rnd_x.dat
YRAND		incbin	rnd_y.dat
ZRAND		incbin	rnd_z.dat

DIR_TAB		dc.w	00,00,10	; lists of x,y and z directions for stars
		dc.w	00,-2,10
		dc.w	00,-3,00
		dc.w	00,03,-10
		dc.w	-3,03,00
		dc.w	03,03,10
		dc.w	00,03,00
		dc.w	-3,-3,-10
		dc.w	03,00,10
		dc.w	00,-3,00
		dc.w	00,00,10
		dc.w	01,01,00
		dc.w	-2,01,00
		dc.w	-2,01,10
		dc.w	00,00,10
		dc.w	03,00,00
		dc.w	-3,03,10
		dc.w	00,00,-10
		dc.w	03,03,10
		dc.w	-3,00,00
		dc.w	-3,-3,00

		dc.w	00,00,-10
		dc.w	00,00,10
		dc.w	00,03,10
		dc.w	-3,03,00
		dc.w	00,03,-10
		dc.w	00,00,-10
		dc.w	-3,-3,-10
		dc.w	03,-3,00
		dc.w	00,-3,10
		dc.w	00,00,10
		dc.w	00,00,-20

*-------------------------------------------------------------------------*
; Another MSD adaption!
;this table will appear to give some randomness to the stars movement
;as the stars will not move in the same direction for the same length
;of time.
star_time_table_pos	dc.l	star_time_table
star_time_table		dc.w	127,127,127,64,64,64,64,64,64,64,64,64,64
			dc.w	32,16,127,127,64,127,127,127
			dc.w	-1		;end of table
;-----------------------------------------------------------------


old_stars_pos	dc.l	old_stars

******************* isr details *******
key	dc.w	0

;;NO PICTURE IN THIS MENU BUT YOU CAN USE ONE BY UNREMARKING THE FOLLOWING LINE
;;pic	incbin	pic.pi1


; Music by Donald Fakk Of S.O.T.E.
music	incbin	"sote.mus"	


text_pos		dc.l	middle_text
middle_text		incbin	ascii.s
			dc.b	$ff
			even
font			incbin	oz_font.dat
			even


demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"cuddly.ro",0
	even
exec2	dc.b	"fuzion.189",0
	even
exec3	dc.b	"F_A_L_L.prg",0
	even
exec4	dc.b	"UNT.13",0
	even
exec5	dc.b	"NIRVANA.U",0
	even
exec6	dc.b	"copier.pov",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even


;
; the packed exec file goes here
;
packedfile	incbin	"test.msd"
endoffile
	even

****************************
	SECTION BSS
****************************


bss_start

disc_start_table	ds.l	50	;1 long word for each page
colour_pos		ds.l	1
present_base		ds.l	1
last_base		ds.l	1
screen_1		ds.l	1
screen_2		ds.l	1
stack_save		ds.l	1
old_base		ds.l	1
clear_line_offset	ds.l	1
old_pal			ds.w	16
vsync_flag		ds.w	1
lines_to_do		ds.w	1
do_clear_delay		ds.w	1
disc_clear_enable	ds.w	1
disc_enable		ds.w	1
screen_number		ds.w	1
hertz_toggle		ds.w	1
hertz_delay		ds.w	1
raster_counter		ds.w	1
storage			ds.b	22
old_rez			ds.b	1
xpos			ds.b	1
ypos			ds.b	1
		even
Y_PLOT			ds.w	200

old_stars		REPT	STARS
			ds.l	1
			ENDR
			ds.b	256
screens			ds.b	49152*2
bss_end

