******************************************************************************
*                                                                            *
*  The START Selector                                                        *
*                                                                            *
*  A replacement for the dreaded GEM file selector                           *
*                                                                            *
*  by Charles F. Johnson.                                                    *
*                                                                            *
*  Copyright 1988 Antic Publishing                                           *
*  All Rights Reserved.                                                      *
*                                                                            *
******************************************************************************

* -----------------------------------
*  Last revision: 02/29/88  17:48:08
* -----------------------------------

max_files	=	300	; Maximum number of displayable filenames

* File array structure

	.abs

name:	ds.b	16
date:	ds.w	1
time:	ds.w	1
size:	ds.l	1

* MFDB structure

	.abs

memadr:	ds.l	1
width:	ds.w	1
height:	ds.w	1
wid_16:	ds.w	1
format:	ds.w	1
planes:	ds.w	1
res_1:	ds.w	1
res_2:	ds.w	1
res_3:	ds.w	1

	.text

	move.l	#not_auto,addrin
	move	#1,intin
	move.l	#f_alrt,aespb
	move.l	#aespb,d1
	move	#$C8,d0
	trap	#2
	tst	intout
	beq.s	start

	cmp.w	#1,intout
	beq.s	.0

	clr.w	-(sp)
	trap	#1

.0:	pea	prg_start
	move	#38,-(sp)
	trap	#14
	addq	#6,sp

	move	#1,prgflg

start:	move.l	#prog_end,d6	; Get address of end of this program
	sub.l	4(sp),d6	; Subtract start of basepage - save in d6

	tst	prgflg
	bne.s	.0

	pea	title
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

.0:	dc.w	$A000		; Don't you just love Line A?
	move.l	a0,line_a

	pea	set_trap	; Appropriate the Trap 13 vector
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)		; Terminate and Stay Resident
	move.l	d6,-(sp)	; Number of bytes to keep
	move	#$31,-(sp)	; That's all folks!
	trap	#1		; We are now happily resident in RAM

prg_start:
	move.l	$88,t2_vec
	move.l	$88,aesvec
	move.l	#my_trap2,$88
	rts

set_trap:
	move.l	$B4,t13adr
	move.l	#my_t13,$B4
	rts

* Replacement for the Trap #13 vector.

my_t13:
	btst	#5,(sp)		; Super or user mode?
	beq.s	t13_ex		; User, skip ahead
	cmp.w	#5,6(sp)	; Setexec call?
	bne.s	t13_ex
	cmp.w	#$101,8(sp)	; Setting critical error vector?
	bne.s	t13_ex
	cmp.l	#my_trap2,$88
	beq.s	t13_ex

	tst	vecset		; Already set the vectors in my code?
	bne.s	t13_1		; Yes, skip

	move	#1,vecset
	move.l	$88,t2_vec	; Ha! Caught the AES trying to take back
	move.l	$88,aesvec	; the Trap #2 vector!
*	move.l	$88,vdivec
t13_1:	move.l	#my_trap2,$88	; Here's where I thumb my nose at GEM
t13_ex:	jmp	$DEADBEEF
t13adr	=	t13_ex+2

* Keyboard interrupt routine
*
* Used to buffer keypresses while the main dialog box is being drawn.
* (Otherwise the AES steals 'em.)

my_keybd:
	btst.b	#7,$FFFC04	; Keyboard or MIDI?
	bne.s	kb_j1		; MIDI - fall thru
	move	(sp)+,kmsav1
	move.l	(sp)+,kmsav2
	pea	kb_0
	move	sr,-(sp)
kb_j1:	jmp	$DEADBEEF
kb_jmp	=	kb_j1+2

kb_0:	movem.l	a0-a1/d0-d1,km_rsav
	move.l	keybuf,a0
	move	8(a0),d0
	cmp	6(a0),d0	; Is there a key here?
	beq.s	kb_3

	move.l	6(a0),d1
	cmp.l	sav_ht,d1
	beq.s	kb_3

	move.l	d1,sav_ht
	move.l	(a0),a0
	lea	k_buff,a1
	move	index,d1
	cmp.w	#15,d1
	beq.s	kb_3

	lsl	#2,d1		; Longwords
	move.l	(a0,d0),(a1,d1)	; Save this key
	addq	#1,index

kb_3:	movem.l	km_rsav,a0-a1/d0-d1
	move.l	kmsav2,-(sp)
	move	kmsav1,-(sp)
	rte

* Replacement for the Trap #2 vector.  Watches for the fsel_input call.

my_trap2:
	cmp	#$C8,d0		; AES call?
	bne	t2_ex		; No, exit stage right
	tst	aesflg
	bne	t2_ex

	movem.l	a0-a7/d0-d7,aes_rsav ; Save registers

	move.l	d1,a0		; Get address of aes parameter block
	move.l	(a0),a1		; Get address of contrl array
	cmp	#90,(a1)	; Is it fsel_input?
	bne	t2_reg		; Nope, bail

	move	(sp),sr_t2
	move.l	2(sp),ret_t2

	move.l	a7,t2_sp
	move.l	#my_stack,sp

	move.l	a0,aesadr	; Save aespb address

	move	#1,-(sp)
	move	#14,-(sp)
	trap	#14
	addq	#4,sp
	move.l	d0,keybuf

	clr	index		; No keys waiting
	clr.l	sav_ht
	move	#1,intflg

	move.l	$118,kb_jmp	; Install my keyboard interrupt
	move	sr,-(sp)
	or.w	#$700,sr
	move.l	#my_keybd,$118
	move	(sp)+,sr

	moveq	#0,d0		; Get current resolution
	move.b	$44C,d0
	move.w	d0,res		; Save it

	tst	fixed
	beq.s	fix

	cmp.b	ressav,d0	; Still the same res?
	beq	clrpth

fix:	move.b	d0,ressav	; Save the res
	move	#1,fixed

	cmp.w	#2,res		; High res?
	beq.s	cent1

	lea	color_yh,a0
	lea	tfsel+18,a1
	move	#yh_len,d0
fix_co:	move.w	(a0),(a1)
	move.w	2(a0),4(a1)
	addq	#4,a0
	add	#24,a1
	dbf	d0,fix_co
	move.l	#$21172,tfsel+12
	move	#$21,otitlbx+10
	move	#$6D,otitlbx+20

*fixem:	move.l	#r_obfx,aespb
*	move.l	#tfsel,addrin
*	move	#num_obs-1,d5
*fx_obs:	move	d5,intin
*	bsr	aes
*	dbf	d5,fx_obs

cent1:	move.l	#f_cntr,aespb	; Call form_center
	move.l	#tfsel,addrin	; (Only need to do this once)
	bsr	aes
	move.l	intout+2,cx
	move.l	intout+6,cw

	move.l	#o_coff,aespb
	move	#track,intin
	bsr	aes
	move.l	intout+2,tr_co

	move	#pathln,intin
	bsr	aes
	move	intout+2,path_x	; Save screen X coordinate of path string

	move	#file1str,intin	; Get screen coordinates of top filename
	bsr	aes

	lea	h_block,a4	; Compute the two rectangles for the
	lea	l_block,a5	; Line A Copy Raster call
	move.l	intout+2,(a4)	; (the top and bottom 15 files)
	move	intout+2,d0
	move	intout+4,d1
	add	ofile1str+20,d0
	cmp.w	#2,res
	bne.s	.skip
	add	#15*16,d1	; They're 16 pixels high in monochrome
	bra.s	.skip1
.skip:	add	#15*8,d1	; 8 pixels high in color
.skip1:	subq	#1,d1
	move	d0,4(a4)
	move	d1,6(a4)
	
	move.l	(a4),(a5)
	move.l	4(a4),4(a5)
	cmp.w	#2,res
	bne.s	.skip2
	add	#16,2(a5)
	add	#16,6(a5)
	bra.s	.skip3
.skip2:	add	#8,2(a5)
	add	#8,6(a5)

.skip3:	lea	smfdb,a4	; Set up the Memory Form Definition blocks
	lea	dmfdb,a5
	clr.l	memadr(a4)
	clr.l	memadr(a5)
	clr.w	format(a4)
	clr.w	format(a5)
	clr.l	res_1(a4)
	clr.l	res_1(a5)
	clr.w	res_3(a4)
	clr.w	res_3(a5)

	cmp.w	#2,res
	bne.s	ckmed
	move	#640,width(a4)
	move	#640,width(a5)
	move	#400,height(a4)
	move	#400,height(a5)
	move	#40,wid_16(a4)
	move	#40,wid_16(a5)
	move	#1,planes(a4)
	move	#1,planes(a5)
	bra.s	clrpth
ckmed:	cmp.w	#1,res
	bne.s	cklo
	move	#640,width(a4)
	move	#640,width(a5)
	move	#200,height(a4)
	move	#200,height(a5)
	move	#40,wid_16(a4)
	move	#40,wid_16(a5)
	move	#2,planes(a4)
	move	#2,planes(a5)
	bra.s	clrpth
cklo:	move	#320,width(a4)
	move	#320,width(a5)
	move	#200,height(a4)
	move	#200,height(a5)
	move	#20,wid_16(a4)
	move	#20,wid_16(a5)
	move	#4,planes(a4)
	move	#4,planes(a5)

clrpth:	bsr	all_clear

	move	$4C4,d0		; Get drive status into d0

	lea	odrvabt+10,a5	; Point to drive A status word
	move	#15,d5
	moveq	#0,d1
drvlp1:	btst	d1,d0
	beq.s	drvlp2
	move	#NORMAL,(a5)
	bset.b	#6,-1(a5)
	bra.s	drvlp3
drvlp2:	move	#DISABLED,(a5)	; Disable non-active drive buttons
	bclr.b	#6,-1(a5)	; Turn off TOUCHEXIT flag
drvlp3:	addq	#1,d1
	add	#24,a5
	dbf	d5,drvlp1

	cmp.w	#2,$4A6		; Do we really have two drives?
	beq.s	bscool
	move	#DISABLED,odrvbbt+10 ; Only one drive online, disable the
	bclr.b	#6,odrvbbt+9	; drive B button

bscool:	move.l	aesadr,a0
	move.l	16(a0),a0	; a0 --> addrin array of calling app
	move.l	(a0),dir_spec	; a1 --> directory spec
	move.l	4(a0),file_spec	; a0 --> filename

	move.l	(a0),a0		; Get pointer to initial directory line
	cmp.b	#'\\',(a0)
	beq.s	defalt
	moveq	#0,d0
	move.b	(a0),d0
	and.b	#$DF,d0
	move.l	d0,d1
	cmp.b	#'A',d0
	blo.s	.0
	cmp.b	#'P',d0
	bhi.s	.0
	sub.b	#'A',d1
	lea	odrvabt+11,a5
	mulu	#24,d1
	btst.b	#3,(a5,d1)	; Is this drive enabled?
	beq.s	.1
.0:	move.b	#'A',d0
	move.b	#'A',(a0)
.1:	sub.b	#'A',d0
	move	d0,defdrv
	mulu	#128,d0
	lea	path_array,a1
	add	d0,a1
	move	#124,d5
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	cmp.b	#'\\',(a0)
	beq.s	path1
	move.b	#'\\',(a1)+
path1:	move.b	(a0)+,(a1)+
	beq.s	path2
	dbf	d5,path1
	clr.b	(a1)
path2:	bra.s	start1

defalt:	move.l	a0,a5
	move	#$19,-(sp)	; Get current drive and set fsel_input
	trap	#1		; directory area
	addq.l	#2,sp
	move	d0,defdrv
	move	d0,d1
	add.b	#'A',d1
	mulu	#128,d0
	lea	path_array,a1
	add	d0,a1
	move.b	d1,(a1)+
	move.b	#':',(a1)+
	move.l	a5,a0
	tst.b	(a0)
	bne.s	.0
	move.b	#'\\',(a1)+
	lea	spec,a0
.0:	move	#124,d5
path3:	move.b	(a0)+,(a1)+
	beq.s	start1
	dbf	d5,path3
	clr.b	(a1)

start1:	move.l	aesadr,a0
	move.l	(a0),a1		; Pointer to contrl array
	cmp.w	#4,6(a1)	; 4 parameters in addrin? (Title lines)
	beq.s	st_1a
	move.l	#title1,etext1
	move.l	#title2,etext2
	bra.s	st_1b

st_1a:	move.l	16(a0),a0	; Pointer to addrin array
	move.l	8(a0),a1	; Pointer to first title string
	lea	user_1,a2
	move	#12,d0
u_1:	move.b	(a1)+,(a2)+
	beq.s	u_2
	dbf	d0,u_1
	clr.b	(a2)
u_2:	move.l	12(a0),a1
	lea	user_2,a2
	move	#12,d0
u_3:	move.b	(a1)+,(a2)+
	beq.s	u_4
	dbf	d0,u_3
	clr.b	(a2)
u_4:	move.l	#user_1,etext1
	move.l	#user_2,etext2

st_1b:	move	defdrv,d0
	bsr	do_path

start2:	move	defdrv,d0
	lea	odrvabt+10,a0
	mulu	#24,d0
	move	#SELECTED,(a0,d0)

	move.l	file_spec,a0
	lea	snameln,a1
	move	#7,d5
fspec1:	cmp.b	#'.',(a0)
	beq.s	fspec2
	tst.b	(a0)
	beq.s	dotrak
	move.b	(a0)+,(a1)+
	dbf	d5,fspec1
	tst.b	(a0)+
	bra.s	fspec3
fspec2:	move.b	#' ',(a1)+
	dbf	d5,fspec2
	tst.b	(a0)+
fspec3:	move	#2,d5
fspec4:	tst.b	(a0)
	beq.s	dotrak
	move.b	(a0)+,(a1)+
	dbf	d5,fspec4

dotrak:	clr.b	(a1)

*	move	otrack+22,oslider+22 ; Make slider same height as track
*	clr.w	oslider+18	; Y position at zero

	bsr	get_path
	bsr	find_last
	lea	sspecln,a0
	move.b	#' ',(a0)+
	move	#11,d0
.1:	move.b	(a1)+,(a0)+
	beq.s	.2
	dbf	d0,.1
	clr.b	(a0)+
.2:	move.b	#' ',-1(a0)
	clr.b	(a0)

	lea	spec,a1		; extension box
	lea	sdskutl,a2
	move	#2,d0
c_1:	move.b	(a1)+,(a2)+
	dbf	d0,c_1
	clr.b	(a2)

	bsr	arrow

	clr	infoco		; Make sure we're displaying filenames
	clr.b	sinfobt
	move.l	#sinfobt,einfobt
	bsr	clear_names

	move.l	#w_updt,aespb	; beg_mcntrl
	move.w	#3,intin
	bsr	aes

	lea	ofile1str+9,a0	; Filename object flags
	move	#15,d0
hide:	bset.b	#7,(a0)		; Hide 'em the first time
	add	#24,a0
	dbf	d0,hide
	bset.b	#7,oslider+9	; Also hide the slider

	move	#nameln,field	; Start edit cursor in "Selection" field
	move.l	#tfsel,addrin
	bsr	drawbx		; Draw it

	lea	ofile1str+9,a0
	move	#15,d0
reveal:	bclr.b	#7,(a0)		; Un-hide these names
	add	#24,a0
	dbf	d0,reveal
	bclr.b	#7,oslider+9

startf:	clr	field		; Entry point for reading/re-reading
	bsr	build_arrays	; a directory
	clr	errflg
	bsr	clear_stat
	cmp	#1,name_count	; Got more than one name?
	ble.s	stf_2		; No, skip the sort

	move	name_count,d0
	subq	#1,d0
	move	d0,-(sp)
	move	#0,-(sp)
	pea	pointers
	bsr	quick_sort

stf_2:	clr	top_name	; Start displaying at the top
	bsr	copy_names	; Copy names into TEDINFO strings
	bsr	draw_names	; Draw the puppies

box1:	tst	intflg
	beq.s	box2

	clr	intflg
	move	sr,-(sp)
	or.w	#$700,sr
	move.l	kb_jmp,$118	; Restore keyboard interrupt
	move	(sp)+,sr

	move	index,d0
	tst	d0		; Got keys?
	beq.s	box2

	clr	index
	move.l	keybuf,a0
	move	d0,d1
	move	#$FC,6(a0)	; Set head index
	lsl	#2,d1
	subq	#4,d1
	move	d1,8(a0)	; Set tail index
	move.l	(a0),a0
	lea	k_buff,a1
	subq	#1,d0
k_loop:	move.l	(a1)+,(a0)+	; Cram these keys down the system's throat
	dbf	d0,k_loop

box2:	bsr	formdo		; Ah, good ol' form_do

	move	selobj,d0	; Get selected object to d0
	bclr	#15,d0		; Clear the high bit (double-click flag)

* -----------------------------------
*  Title strings (copyright message)
* -----------------------------------

	cmp.w	#text1,d0
	beq.s	title_1
	cmp.w	#text2,d0
	bne.s	ckpath

title_1:
	move.l	line_a,a0

t_2:	btst.b	#0,-$15C(a0)	; Left button still pressed?
	bne	t_2

	move.l	#f_alrt,aespb	; Copyright message in a form_alert
	move	#1,intin
	move.l	#copyright,addrin
	bsr	aes

	bra	box1

* ---------------
*  Pathname line
* ---------------

ckpath:	cmp.w	#pathbx,d0
	beq.s	p_1
	cmp.w	#pthttl,d0
	beq.s	p_1
	cmp.w	#pathln,d0
	bne	ckmain

p_0:	btst.b	#7,selobj
	bne.s	double
p_1:	move	#pathln,field
	bra	box1

double:	move.l	line_a,a0
	move	-$25A(a0),d2	; Get mouse X position
	sub	path_x,d2	; Subtract X of path string's left border

	lsr	#3,d2		; Divide by 8 to get character offset
	
	bsr	get_path
	move.l	a1,a6

	bsr	find_last

	move.l	a1,a5
	lea	specsv,a4
	move	#11,d5
savspc:	move.b	(a5)+,(a4)+
	beq.s	savs1
	dbf	d5,savspc
	clr.b	(a4)

savs1:	move.l	a6,d4
	move.l	a1,d5
	subq	#1,d5
	sub	d4,d5
	cmp.w	d5,d2
	bhi.s	p_1
	lea	(a6,d2),a0
	move	#32,d5
slash:	cmp.b	#'\\',(a0)+
	beq.s	slash2
	dbf	d5,slash
	bra	p_1
slash2:	lea	specsv,a1
	move	#11,d5
slash3:	move.b	(a1)+,(a0)+
	beq.s	slash4
	dbf	d5,slash3
	clr.b	(a0)
slash4:	bsr	copy_path

	move	#pathln,intin
	move	#1,intin+2
	bsr	drawob
*	clr.b	snameln
*	move	#nameln,intin
*	bsr	drawob

	bra	startf

* -------------------
*  Main filename box
* -------------------

ckmain:	cmp.w	#filebox,d0
	bne.s	ckrl

	bsr	check_dir
	bmi	startf

	clr	field
	bra	box1

* ---------------------------------
*  Info box right and left buttons
* ---------------------------------

ckrl:	cmp.w	#right,d0
	bne.s	ckleft

	bsr	check_dir
	bmi	startf

	cmp.w	#3,infoco
	bne.s	incinf
	clr	infoco
	bra.s	do_inf
incinf:	addq	#1,infoco
	bra.s	do_inf

ckleft:	cmp.w	#left,d0
	bne.s	ckslid

	bsr	check_dir
	bmi	startf

	tst	infoco
	bne.s	decinf
	move	#3,infoco
	bra.s	do_inf
decinf:	subq	#1,infoco
do_inf:	move	infoco,d0
	lsl	#2,d0
	lea	info_tbl,a0
	move.l	(a0,d0),einfobt
	bsr	draw_info

	bsr	copy_names
	bsr	draw_names

	bra	box1

* --------
*  Slider
* --------

ckslid:	cmp.w	#slider,d0
	bne	cktrak

	bsr	check_dir
	bmi	startf

	cmp.w	#17,name_count
	blo	box1

	move.l	#o_coff,aespb
	move	#slider,intin
	move.l	#tfsel,addrin
	bsr	aes
	move	intout+4,d7	; Save current Y position

	move.l	#g_drag,aespb
	lea	intin,a0
	move.l	oslider+20,(a0)
	move.l	intout+2,4(a0)
	move.l	tr_co,8(a0)
	move.l	otrack+20,12(a0)
	bsr	aes

	move	intout+4,d0	; Has it really moved?
	cmp.w	d7,d0
	beq	box1

	move	intout+4,d0	; Get new Y coordinate
	cmp.w	tr_co+2,d0
	bne.s	sett1

	clr	d0
	bra.s	settop

sett1:	sub	tr_co+2,d0
	addq	#1,d0
	move	name_count,d1
	mulu	d1,d0
	divu	otrack+22,d0

	sub	#16,d1
	cmp.w	d1,d0
	ble.s	settop
	move	d1,d0

settop:	move	d0,top_name	

	bsr	new_top
	bsr	clear_stat

*	clr.b	snameln
*	move	#nameln,intin
*	move	#1,intin+2
*	bsr	drawob

	bsr	copy_names
	bsr	draw_names

	clr	field
	bra	box1

* -------
*  Track
* -------

cktrak:	cmp.w	#track,d0
	bne	ckfile

	bsr	check_dir
	bmi	startf

	cmp.w	#17,name_count
	blo	box1

	move.l	line_a,a0
	move	-$258(a0),d5	; Mouse Y position

	move.l	#o_coff,aespb
	move	#slider,intin
	move.l	#tfsel,addrin
	bsr	aes

	move	intout+4,d2	; Slider Y
	move	d2,d3
	add	oslider+22,d3	; Get bottom

	cmp	d2,d5
	blo.s	pageup
	cmp	d3,d5
	blo	box1

	move	top_name,d0
	add	#16,d0
	move	name_count,d1
	sub	#16,d1
	cmp.w	d1,d0
	ble.s	topsli
	move	d1,d0
	bra.s	topsli

pageup:	move	top_name,d0
	sub	#16,d0
	bpl.s	topsli
	clr	d0

topsli:	move	d0,top_name

	bsr	clear_stat

*	clr.b	snameln
*	move	#nameln,intin
*	move	#1,intin+2
*	bsr	drawob

	bsr	copy_names
	bsr	new_top
	bsr	draw_names

	clr	field
	bra	box1

* -----------
*  Filenames
* -----------

ckfile:	cmp.w	#file1str,d0
	blo	ckclos
	cmp.w	#file16st,d0
	bhi	ckclos

	move	d0,d7
	bsr	check_dir
	bmi	startf

	move	d7,d0
	sub	#file1str,d0
	move	d0,curr_name
	lsl	#2,d0
	lea	string_table,a0
	move.l	(a0,d0),a0
	cmp.b	#7,(a0)
	bne.s	cpnam0

	move	curr_name,d0
	add	top_name,d0
	lsl	#2,d0		; Index into pointer array
	lea	pointers,a0
	move.l	(a0,d0),a0	; a0 --> name of subdirectory
	addq	#2,a0

	bsr	get_path
*	move.l	a1,a5		; Save pointer to path start

	bsr	find_last

	move.l	a1,a3		; Save pointer to last backslash+1
	move	#11,d5
	lea	specsv,a2
newfo5:	move.b	(a1)+,(a2)+	; Save current search spec
	beq.s	newfo6
	dbf	d5,newfo5
	clr.b	(a2)
newfo6:	move	#11,d5
newfo7:	tst.b	(a0)
	beq.s	newfo8
	move.b	(a0)+,(a3)+
	dbf	d5,newfo7
newfo8:	move.b	#'\\',(a3)+
	lea	specsv,a2
	move	#11,d5
newfo9:	move.b	(a2)+,(a3)+
	beq.s	newf10
	dbf	d5,newfo9
	clr.b	(a3)
newf10:	bsr	copy_path

	move	#1,intin+2
	move	#pathln,intin
	bsr	drawob

*	clr.b	snameln
*	move	#nameln,intin
*	bsr	drawob

	bra	startf

cpnam0:	move	curr_name,d0
	lea	name_flags,a0
	tst.b	(a0,d0)
	bne.s	cpnam1
	clr.b	snameln
	bra.s	dr_nam

cpnam1:	add	top_name,d0
	lsl	#2,d0
	lea	pointers,a0
	move.l	(a0,d0),a0
	addq	#2,a0
	lea	snameln,a1
	move	#7,d5
cpnam2:	cmp.b	#'.',(a0)
	beq.s	cpnam3
	tst.b	(a0)
	beq.s	dr_nam
	move.b	(a0)+,(a1)+
	dbf	d5,cpnam2
	tst.b	(a0)+
	bra.s	cpnam4
cpnam3:	move.b	#' ',(a1)+
	dbf	d5,cpnam3
	tst.b	(a0)+
cpnam4:	move	#2,d5
cpnam5:	tst.b	(a0)
	beq.s	dr_nam
	move.b	(a0)+,(a1)+
	dbf	d5,cpnam5

dr_nam: clr.b	(a1)
	move	#1,intin+2
	move	#nameln,intin
	bsr	drawob

	clr	field
	btst.b	#7,selobj	; Double-click?
	beq	box1

	bset.b	#0,ookbt+11
	move	#okbt,intin
	move	#1,intin+2
	bsr	drawob
	move	#okbt,selobj
	bra	exit1

* -----------
*  Close box
* -----------

ckclos:	cmp.w	#closbx,d0
	bne	ckwtop

	bsr	check_dir
	bmi	startf

	bsr	get_path

	moveq	#0,d5		; d5 counts backslashes
clos1:	tst.b	(a1)
	beq.s	clos3
	cmp.b	#'\\',(a1)
	bne.s	clos2
	addq	#1,d5
clos2:	addq	#1,a1
	bra	clos1
clos3:	cmp.w	#1,d5
	ble	box1
clos4:	cmp.b	#'\\',-(a1)
	bne	clos4
clos5:	move.l	a1,a3
	tst.b	(a1)+
	move	#11,d5
	lea	specsv,a5
clos6:	move.b	(a1)+,(a5)+
	beq.s	clos7
	dbf	d5,clos6
	clr.b	(a5)
clos7:	cmp.b	#'\\',-(a3)
	bne	clos7
	tst.b	(a3)+
	lea	specsv,a5
	move	#11,d5
clos8:	move.b	(a5)+,(a3)+
	beq.s	clos9
	dbf	d5,clos8
	clr.b	(a3)
clos9:	bsr	copy_path

	move	#1,intin+2
	move	#pathln,intin
	bsr	drawob

*	clr.b	snameln
*	move	#nameln,intin
*	bsr	drawob

	bra	startf

* ------------------------------
*  Top window bar (search spec)
* ------------------------------

ckwtop:	cmp.w	#specln,d0
	bne.s	ckdriv

	bsr	check_dir
	bmi	startf

	bra	box1

* ---------------
*  Drive buttons
* ---------------

ckdriv:	cmp.w	#drvabt,d0
	blo	ckdown
	cmp.w	#drvpbt,d0
	bhi	ckdown

	btst.b	#7,selobj
	beq	dchng1

	move	d0,d7

	bsr	bee

	move	d7,d0
	move	d0,d1
	sub	#drvabt,d1
	add.b	#'A',d1
	move.b	d1,dfdrv

	sub	#drvabt-1,d0
	lea	d_buff,a0
	clr.l	(a0)
	clr.l	4(a0)
	clr.l	8(a0)
	clr.l	12(a0)

	move	d0,-(sp)	; Dfree
	pea	d_buff
	move	#$36,-(sp)
	trap	#1
	addq	#8,sp

	move.l	d_buff+12,d2	; Physical sectors/cluster
	move.l	d_buff,d3	; Free clusters

	mulu	d2,d3
	move.l	d_buff+8,d2	; Bytes/physical sector
	bsr.s	multiply
	move.l	d1,d5		; d5 holds # of free bytes

*	move.l	d_buff+12,d2
*	move.l	d_buff+4,d3	; Get total # of clusters
*	mulu	d2,d3
*	move.l	d_buff+8,d2
*	bsr	multiply
*	move.l	d1,d6
*	sub.l	d5,d6		; d6 holds # of bytes used

*	move.l	d6,d0
*	lea	deciml,a2
*	bsr	bindec32
*	lea	usems1,a1
*	bsr	do_free

	move.l	d5,d0
	lea	deciml,a2
	bsr	bindec32
	lea	frems1,a1
	bsr.s	do_free

	bsr	arrow

	move.l	#f_alrt,aespb
	move	#1,intin
	move.l	#dfree,addrin
	bsr	aes

	sub	#drvabt,d7
	lea	odrvabt+10,a0
	mulu	#24,d7
	move	#NORMAL,(a0,d7)
	move	defdrv,d0
	mulu	#24,d0
	move	#SELECTED,(a0,d0)
	move	#drvbox,intin
	move	#2,intin+2
	bsr	drawob
	bra	box1

multiply:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#31,d4
shift:	add.l	d1,d1
	addx.l	d0,d0
	lsl.l	#1,d3
	bcc.s	.check
	add.l	d2,d1
	bcc.s	.check
	addq.l	#1,d0
.check:	dbf	d4,shift
	rts

do_free:
	move.l	a1,-(sp)
	move	#7,d0
.loop0:	move.b	#' ',(a1)+
	dbf	d0,.loop0
	move.l	(sp)+,a1
	lea	deciml,a0
	move	#7,d0
.loop1:	cmp.b	#'0',(a0)+
	bne.s	.loop2
	dbf	d0,.loop1
	move.b	#'0',(a1)
	rts
.loop2:	subq	#1,a0
.loop3:	move.b	(a0)+,(a1)+
	dbf	d0,.loop3
	rts

dchng1:	move	d0,d7

	bsr	get_path
	bsr	find_last
	move.l	a1,a6

	move	d7,d0
	sub	#drvabt,d0
	move	d0,defdrv
	move	d0,d1
	mulu	#24,d1
	lea	odrvabt,a0
	btst.b	#3,11(a0,d1)
	bne	box1

	bsr	do_path
	bsr	get_path
	bsr	find_last
	move	#11,d5
dchng2:	move.b	(a6)+,(a1)+
	beq.s	dchng3
	dbf	d5,dchng2
	clr.b	(a1)

dchng3:	bsr	copy_path
	bsr	copy_spec
	move	#1,intin+2
	move	#pathln,intin
	bsr	drawob

	bra	startf

* ---------------------
*  Up and down buttons
* ---------------------

ckdown:	cmp.w	#down,d0
	bne	ck_up

	bsr	check_dir
	bmi	startf

	cmp.w	#16,name_count
	ble.s	out

down1:	move	top_name,d0
	add	#16,d0
	cmp.w	name_count,d0
	blo.s	bump_top

out:	move.l	#e_butt,aespb	; Wait for AES to notice the button release
	move	#1,intin
	move	#1,intin+2
	clr	intin+4
	bsr	aes
	bra	box1

bump_top:
	addq	#1,top_name
	bsr	clear_stat

	bsr	copy_names
	bsr	new_top

	move.l	l_block,-(sp)
	move.l	l_block+4,-(sp)
	move.l	h_block,-(sp)
	move.l	h_block+4,-(sp)
	bsr	copy_raster
	add	#16,sp

	move	#file16st,intin
	move	#1,intin+2
	bsr	drawob

d_r_1:	dc.w	$A000
	btst.b	#0,-$15C(a0)	; Left button still pressed?
	bne	down1

ud_ret:	clr	field
	bra	box1

* -----------
*  Up button
* -----------

ck_up:	cmp.w	#up,d0
	bne.s	ckast

	bsr	check_dir
	bmi	startf

up1:	tst	top_name
	beq	out

	subq	#1,top_name
	bsr	clear_stat

ck_up1:	bsr	copy_names
	bsr	new_top

	move.l	h_block,-(sp)
	move.l	h_block+4,-(sp)
	move.l	l_block,-(sp)
	move.l	l_block+4,-(sp)
	bsr	copy_raster
	add	#16,sp

	move	#file1str,intin
	move	#1,intin+2
	bsr	drawob

u_r_1:	dc.w	$A000
	btst.b	#0,-$15C(a0)	; Left button still pressed?
	bne	up1

	bra	ud_ret

* ------------------------
*  Set search spec to *.*
* ------------------------

ckast:	cmp.w	#dskutl,d0
	bne	ckexit

	bsr	get_path
	bsr	find_last
	move.l	a1,a5
	lea	temp_spec,a0
	move	#11,d0
ckast0:	move.b	(a5)+,(a0)+
	beq.s	.1
	dbf	d0,ckast0
	clr.b	(a0)
.1:	move.l	a1,a5
	lea	sdskutl,a0
	move	#11,d0
ckast1:	move.b	(a0)+,(a5)+
	beq.s	.1
	dbf	d0,ckast1
	clr.b	(a5)
.1:	lea	temp_spec,a0
	lea	sdskutl,a1
	move	#11,d0
ckast2:	move.b	(a0)+,(a1)+
	beq.s	.1
	dbf	d0,ckast2
	clr.b	(a1)

.1:	bsr	copy_path
	bsr	copy_spec
	move	#pathln,intin
	move	#1,intin+2
	bsr	drawob

	clr.l	intin+12
	bsr	o_change
	move	#dskutl,intin
	move	#1,intin+2
	bsr	drawob

	bra	startf

* --------------
*  Bail routine
* --------------

ckexit:	cmp.w	#cancbt,selobj
	beq.s	exit1
	cmp.w	#okbt,selobj
	bne	box1

exit1:	clr.l	intin+12
	bsr	o_change
	bsr	close_box

exit2:
	move.l	#w_updt,aespb
	move	#2,intin
	bsr	aes

	bsr	get_path
	move.l	a1,a0
	move.l	dir_spec,a1
exit3:	move.b	(a0)+,(a1)+
	bne	exit3
exit4:	lea	snameln,a0
	move.l	file_spec,a1
	move	#7,d5
exit5:	cmp.b	#' ',(a0)
	beq.s	exit6
	tst.b	(a0)
	beq.s	exit8
	move.b	(a0)+,(a1)+
	dbf	d5,exit5
	move.b	#'.',(a1)+
	bra.s	exit7
exit6:	move.b	#'.',(a1)+
exit6a:	tst.b	(a0)+
	dbf	d5,exit6a
exit7:	move	#2,d5
exit7a:	move.b	(a0)+,(a1)+
	beq.s	exit9
	dbf	d5,exit7a
exit8:	clr.b	(a1)
exit9:	move	selobj,d0
	bclr	#15,d0
	move.l	aesadr,a0
	move.l	12(a0),a0	; a0 --> intout array
	move	#1,(a0)		; No error
	cmp.w	#cancbt,d0
	bne.s	exit10
	clr	2(a0)		; Return CANCEL button (0)
	bra.s	exit11
exit10:	move	#1,2(a0)	; Return OK button
exit11:	movem.l	aes_rsav,a0-a7/d0-d7 ; Restore registers
	move.l	ret_t2,2(sp)
	move	sr_t2,(sp)
	rte

t2_reg:	movem.l	aes_rsav,a0-a7/d0-d7
t2_ex:	jmp	$DEADBEEF
t2_vec	=	t2_ex+2

* -------------
*  Subroutines
* -------------

draw_info:
	move	#infobt,intin
	move	#1,depth
	move.l	#$00010001,x_off
	move.l	#$00020002,w_off
	bra	obdraw

do_path:
	lea	path_array,a0
	move	d0,d1
	mulu	#128,d1
	tst.b	(a0,d1)
	beq.s	do_p1

	add	d1,a0
	lea	spathln,a1
	move	#37,d5
do_p0:	move.b	(a0)+,(a1)+
	beq.s	.done
	dbf	d5,do_p0
.done:	rts
do_p1:	add	d1,a0
	move.l	a0,a5
	add.b	#65,d0
	move.b	d0,(a0)+
	move.b	#':',(a0)+

	sub.b	#64,d0
	move	d0,-(sp)	; Get current pathname
	move.l	a0,-(sp)
	move	#$47,-(sp)
	trap	#1
	addq.l	#8,sp
	move	d0,errflg

	move.l	a5,a0
findz0:	tst.b	(a5)+
	bne.s	findz0
	move.b	#'\\',-1(a5)
	lea	spec,a4
	move	#3,d5
cpspec:	move.b	(a4)+,(a5)+
	dbf	d5,cpspec

	lea	spathln,a1
	move	#37,d5
cspath:	move.b	(a0)+,(a1)+
	beq.s	csp1
	dbf	d5,cspath
csp1:	rts

find_last:
	tst.b	(a1)+
	bne	find_last
findl2:	cmp.b	#'\\',-(a1)
	bne	findl2
	tst.b	(a1)+
	rts

copy_path:
	bsr	get_path
	lea	spathln,a0
	move	#37,d0
copyp1:	move.b	(a1)+,(a0)+
	beq.s	copyp2
	dbf	d0,copyp1
copyp2:	rts

copy_spec:
	bsr	get_path
	bsr	find_last
	lea	sspecln,a0
	move.b	#' ',(a0)+
	move	#11,d0
cpspe5:	move.b	(a1)+,(a0)+
	beq.s	cpspe6
	dbf	d0,cpspe5
	clr.b	(a0)+
cpspe6:	move.b	#' ',-1(a0)
	clr.b	(a0)
	move	#specln,intin
	move	#1,depth
	move.l	#$00010001,x_off
	move.l	#$00020002,w_off
	bra	obdraw

check_dir:
	cmp.b	#'\\',spathln	; Does path start with backslash?
	beq	cd_1		; Yes, skip drive letter check

	move	defdrv,d0	; Get our current drive
	move	d0,d5		; Save in d5
	add	#'A',d0		; Make it ASCII
	cmp.b	spathln,d0	; Has the user changed this?
	beq	cd_1		; No, skip

	moveq	#0,d0
	move.b	spathln,d0
	sub.b	#'A',d0
	mulu	#24,d0
	lea	odrvabt+11,a0
	btst.b	#3,(a0,d0)	; Is this drive active?
	beq.s	do_drv		; Yes, go change it
	bsr	copy_path	; Reset path
	bsr	copy_spec
	move	#pathln,intin
	move	#1,intin+2
	bsr	drawob
	move	#-1,d0
	rts
do_drv:	move	d5,d4
	mulu	#24,d5		; Get index to current drive object
	lea	odrvabt+11,a5
	bclr.b	#0,(a5,d5)	; Clear SELECTED bit
	add	#drvabt,d4
	move	d4,intin
	move	#1,intin+2
	bsr	drawob		; Redraw it

	moveq	#0,d0
	move.b	spathln,d0
	sub.b	#'A',d0
	move	d0,defdrv	; Set new current drive
	move	d0,d4
	mulu	#24,d0
	bset.b	#0,(a5,d0)	; Set SELECTED bit in new drive button
	add	#drvabt,d4
	move	d4,intin
	move	#1,intin+2
	bsr	drawob

	bsr	get_path
	move.l	a1,a0
	lea	spathln,a1
	move	#37,d0
p2arr:	move.b	(a1)+,(a0)+
	beq.s	p2arr1
	dbf	d0,p2arr
	clr.b	(a0)
p2arr1:	bsr	copy_spec
	move	#-1,d0
	rts

cd_1:	bsr	get_path
	move.l	a1,a0
	move.l	a0,a5
	lea	spathln,a1
	move	#37,d0
comp_1:	tst.b	(a0)
	bne.s	comp_2
	tst.b	(a1)
	bne.s	diff_p
	bra.s	nochng
comp_2:	tst.b	(a1)
	beq.s	diff_p
	cmp.b	(a0)+,(a1)+
	bne.s	diff_p
	dbf	d0,comp_1
nochng:	move	#0,d0
	rts

diff_p:	lea	spathln,a0
	move	#37,d0
diff_1:	move.b	(a0)+,(a5)+
	beq.s	diff_2
	dbf	d0,diff_1
	clr.b	(a5)
diff_2:	bsr	copy_spec
	move	#-1,d0
	rts

build_arrays:
	clr	name_count

	move	#(24*max_files)/4-1,d0
	lea	name_array,a0
clrnam:	clr.l	(a0)+
	dbf	d0,clrnam

	move	#(4*max_files)/4-1,d0
	lea	pointers,a0
.2:	clr.l	(a0)+
	dbf	d0,.2

	bsr	bee

	bsr	get_path
	move.l	a1,a0
	lea	pathname,a1
arr_1:	move.b	(a0)+,(a1)+
	bne	arr_1

	tst	errflg
	bne	buildx

	lea	pathname,a1

	bsr	find_last

	move.l	a1,a0
	lea	spec,a2
	move	#3,d0
ckspec:	cmp.b	(a1)+,(a2)+
	bne.s	nowild
	dbf	d0,ckspec

	move	#$10,attrib
	bsr	get_path
	move.l	a1,a5
	bsr	readn_1
	bne	buildx

	cmp.b	#'.',dta+30
	beq.s	wild1

	bsr	stuff_em
	addq	#1,name_count
	cmp.w	#max_files,name_count
	beq	buildx

wild1:	bsr	readn_2
	bne	buildx

	cmp.b	#'.',dta+30
	beq	wild1

	bsr	stuff_em
	addq	#1,name_count

	cmp.w	#max_files,name_count
	blo	wild1

	bra	buildx

nowild:	lea	spec,a1
	move	#3,d0
arr_7:	move.b	(a1)+,(a0)+
	dbf	d0,arr_7

	clr	critfl
	move.l	$404,critvc
	move.l	#my_crit,$404

	move	#$10,attrib
	lea	pathname,a5
	bsr	readn_1
	move.l	critvc,$404
	tst	critfl
	bne	buildx
	tst	d0
	bne.s	do_fil

	cmp.b	#'.',dta+30
	beq.s	arr_8

	cmp.b	#$10,dta+21
	bne.s	arr_8

	bsr	stuff_em
	addq	#1,name_count

arr_8:	bsr	readn_2
	bne.s	do_fil

	cmp.b	#'.',dta+30
	beq.s	arr_8
	cmp.b	#$10,dta+21
	bne.s	arr_8

	bsr	stuff_em
	addq	#1,name_count

	cmp.w	#max_files,name_count
	blo	arr_8

do_fil:	move	#0,attrib
	bsr	get_path
	move.l	a1,a5
	bsr	readn_1
	bne.s	buildx

	cmp.b	#'.',dta+30
	beq.s	build0

	bsr	stuff_em
	addq	#1,name_count
	cmp.w	#max_files,name_count
	beq.s	buildx

build0:	bsr	readn_2
	bne.s	buildx

	cmp.b	#'.',dta+30
	beq.s	build0

	bsr	stuff_em
	addq	#1,name_count

build1:	cmp.w	#max_files,name_count
	blo	build0

buildx:	bsr	arrow

	cmp.w	#16,name_count
	bhi.s	bx_1

	move	otrack+22,oslider+22
	clr.l	oslider+16

	bra.s	bx_2

bx_1:	moveq	#0,d0
	move	otrack+22,d0
	lsl	#4,d0
	divu	name_count,d0
	move	d0,oslider+22
	clr.l	oslider+16
bx_2:	move	#track,intin
	move	#2,depth
	clr.l	x_off
	clr.l	w_off
	bsr	obdraw

	lea	sinfobt,a0
	moveq	#0,d0
	move	name_count,d0
	cmp.w	#1,d0
	bhi.s	bx_2a

	add.b	#'0',d0
	move.b	d0,(a0)+
	cmp.b	#'0',d0
	bne.s	.1
	move	#5,d0
	bra.s	cpyfms
.1:	move	#4,d0
	bra.s	cpyfms

bx_2a:	lea	deciml,a2
	bsr	bindec32
	lea	deciml+5,a1
	move	#2,d0
bx_3:	cmp.b	#'0',(a1)
	bne.s	bx_4
	tst.b	(a1)+
	dbf	d0,bx_3
bx_4:	move.b	(a1)+,(a0)+
	dbf	d0,bx_4

	move	#5,d0

cpyfms:	lea	filems,a1
cpyfm1:	move.b	(a1)+,(a0)+
	dbf	d0,cpyfm1
	clr.b	(a0)

	clr	infoco
	move.l	#sinfobt,einfobt
	bsr	draw_info
	rts

my_crit:
	move	#1,critfl
j_crit:	jmp	$12345678
critvc	=	j_crit+2

readn_1:
	pea	dta
	move	#$1A,-(sp)
	trap	#1
	addq	#6,sp

	move	attrib,-(sp)
	move.l	a5,-(sp)	; a5 --> path spec
	move	#$4E,-(sp)
	trap	#1
	addq	#8,sp
	tst	d0
	rts

readn_2:
	move	#$4F,-(sp)
	trap	#1
	addq	#2,sp
	tst	d0
	rts

stuff_em:
	move	name_count,d0

	move	d0,d1
	lsl	#2,d1
	mulu	#24,d0
	lea	name_array,a0
	add	d0,a0
	move.l	a0,a2		; Save pointer to this element in a2
	lea	pointers,a1
	move.l	a0,(a1,d1)

	cmp.b	#$10,dta+21	; Folder?
	beq.s	do_fol
	move.b	#' ',(a0)+
	bra.s	stuff1
do_fol:	move.b	#7,(a0)+
stuff1:	move.b	#' ',(a0)+

	lea	dta+30,a1
	move	#12,d0
stuff2:	move.b	(a1)+,(a0)+
	beq.s	stuff3
	dbf	d0,stuff2

stuff3:	move	dta+24,date(a2)
	move	dta+22,time(a2)
	move.l	dta+26,size(a2)
	rts

get_path:
	move	defdrv,d0
	mulu	#128,d0
	lea	path_array,a1
	add	d0,a1
	rts

* Quicksort routine
*
* Sorts an array of 32-bit pointers to ASCII strings
*
* Enter with:	move	#start,-(sp)	; Usually zero
*		move	#end,-(sp)	; # of elements in array -1
*		move.l	#array,-(sp)	; Address of pointer array
*		bsr	quick_sort

low		=	-2
high		=	-4
list_sep	=	-8

array_adr	=	8
a_start		=	12
a_end		=	14

str_length	=	16

quick_sort:
	link	a6,#-8		; 8 bytes of local storage

	move	a_start(a6),-2(a6) ; low=start
	move	a_end(a6),-4(a6)   ; high=end
	moveq	#0,d0
	move	a_start(a6),d0
	add	a_end(a6),d0
	lsr	#1,d0
	lsl	#2,d0
	move.l	array_adr(a6),a0
	move.l	(a0,d0),list_sep(a6) ; list_separator = array[(start+end)/2]
	bra.s	l5

l6:	addq	#1,low(a6)	; Increment low

l5:	move	low(a6),d0	; Low
	lsl	#2,d0
	move.l	array_adr(a6),a0   ; Add to start of array
	move.l	(a0,d0),-(sp)	   ; Push this pointer on the stack
	move.l	list_sep(a6),-(sp) ; list_separator
	bsr	comp_ascen
	addq	#8,sp
	tst	d0		; While array[low] < list_separator
	bne	l6
	bra.s	l8

l9:	subq	#1,high(a6)	; Decrement high

l8:	move.l	list_sep(a6),-(sp)
	move	high(a6),d0
	lsl	#2,d0
	move.l	array_adr(a6),a0
	move.l	(a0,d0),-(sp)
	bsr	comp_ascen
	addq	#8,sp
	tst	d0		; While array[high] > list_separator
	bne	l9

	move	low(a6),d0	; If low < high
	cmp	high(a6),d0
	bge.s	l11
	move	high(a6),d0	; Get pointers to pointer array
	subq	#1,-4(a6)	; Decrement high
	lsl	#2,d0
	move.l	array_adr(a6),a0
	add	d0,a0		; Pointer to first element

	move	low(a6),d0
	addq	#1,low(a6)	; Increment low
	lsl	#2,d0
	move.l	array_adr(a6),a1
	add	d0,a1		; Pointer to second element

	move.l	(a0),d2		; Exchange these longwords
	move.l	(a1),(a0)
	move.l	d2,(a1)

	bra.s	l12

l11:	move	low(a6),d0	; If low = high then increment low
	cmp	high(a6),d0
	bne.s	l12
	addq	#1,low(a6)

l12:	move	low(a6),d0	; While low <= high
	cmp	high(a6),d0
	ble	l5

l4:	move	a_start(a6),d0	; If start < high
	cmp	high(a6),d0
	bge.s	l14
	move	high(a6),-(sp)	; quick_sort (array, start, high)
	move	a_start(a6),-(sp)
	move.l	array_adr(a6),-(sp)
	bsr	quick_sort	; Recursive call
	addq	#8,sp

l14:	move	low(a6),d0	; If low < end
	cmp	a_end(a6),d0
	bge.s	l15
	move	a_end(a6),-(sp)	; quick_sort (array, low, end)
	move	low(a6),-(sp)
	move.l	array_adr(a6),-(sp)
	bsr	quick_sort	; Another recursive call
	addq	#8,sp

l15:	unlk	a6
	rts

comp_ascen:
	move.l	4(sp),a0
	move.l	8(sp),a1
	move	#str_length-1,d0
compa1:	cmp.b	(a0)+,(a1)+
	blo.s	true
	bhi.s	false
	dbf	d0,compa1
false:	moveq	#0,d0
	rts
true:	moveq	#1,d0
	rts

clear_names:
	lea	string_table,a0	; Table of addresses of tedinfo strings
	tst	infoco
	bne.s	clnm_1
	lea	blank1,a1
	lea	s_tem1,a3
	bra.s	clnm_2
clnm_1:	lea	blank2,a1
	lea	s_tem2,a3
clnm_2:	lea	name_flags,a5
	move	#15,d0		; 16 lines to do
copy0:	move.l	(a0)+,a2
	move	#12,d1
copy01:	move.b	(a1)+,(a2)+	; Initialize 'em
	dbf	d1,copy01
	clr.b	(a2)
	clr.b	(a5)+
	sub	#13,a1
	dbf	d0,copy0
	lea	s_temp,a0
	move	#15,d0
copy0a:	move.b	(a3)+,(a0)+
	dbf	d0,copy0a
	rts

copy_names:
	bsr	clear_names

	move	top_name,d1
	tst	infoco
	bne	cpy_1

	lsl	#2,d1		; Index into pointer array
	lea	pointers,a4
	add	d1,a4		; Save address in a4
	move.l	(a4),a1		; Get pointer to name

	lea	name_flags,a5
	lea	string_table,a0	; Table of addresses of tedinfo strings
	cmp.w	#16,name_count	; More than 16 names?
	bge.s	c_0
	tst	name_count
	beq.s	copy_exit
	move	name_count,d0
	subq	#1,d0
	bra.s	copy1
c_0:	move	#15,d0		; 16 lines to do
copy1:	move.l	(a0)+,a2	; Pointer to tedinfo string
	move.b	(a1)+,(a2)+
	move.b	(a1)+,(a2)+

	move	#7,d2
copy2:	cmp.b	#'.',(a1)	; Period before extension?
	beq.s	copy3
	tst.b	(a1)		; Null at end?
	beq.s	cpynxt
	move.b	(a1)+,(a2)+
	dbf	d2,copy2
	tst.b	(a1)+
	bra.s	do_ext

copy3:	move.b	#' ',(a2)+
	dbf	d2,copy3
	tst.b	(a1)+

do_ext:	move	#2,d2
do_ex1:	tst.b	(a1)
	beq.s	cpynxt
	move.b	(a1)+,(a2)+
	dbf	d2,do_ex1
cpynxt:	clr.b	(a2)
	move.b	#1,(a5)+	; Set this flag
	addq	#4,a4
	move.l	(a4),a1
	dbf	d0,copy1
copy_exit:
	rts

cpy_1:	cmp.w	#1,infoco
	beq	cpy_2

	lea	name_flags,a5
	lea	string_table,a1

	lea	pointers,a4
	move	top_name,d0
	lsl	#2,d0
	add	d0,a4
	move.l	(a4),a0		; Get pointer to name
	cmp.w	#16,name_count
	bge.s	.1
	tst	name_count
	beq	copy_exit
	move	name_count,d6
	subq	#1,d6
	bra.s	td_0
.1:	move	#15,d6

td_0:	cmp.w	#2,infoco
	bne.s	.1

	add	#date,a0
	move.b	#"/",d7
	bra.s	.2
.1:	add	#time,a0
	move.b	#":",d7
.2:
td_1:	move.l	(a1)+,a2	; Get address of string
	move.l	(a4),a3
	cmp.b	#7,(a3)		; Folder?
	bne.s	td_1a
	move.b	#7,(a2)+
	bsr	spc_2
	bra.s	td_1b
td_1a:	bsr	spc_1

td_1b:	move	(a0),d5		; Get date/time
	cmp.w	#2,infoco
	bne.s	td_2

	move	d5,d0
	and	#%111100000,d0	; Mask for month
	lsr	#5,d0
	bsr	do_val

	move.b	d7,(a2)+
	move	d5,d0
	and	#%11111,d0
	bsr	do_val
	move.b	d7,(a2)+
	move	d5,d0
	and	#%1111111000000000,d0 ; Year -80
	lsr	#8,d0
	lsr	#1,d0
	add	#80,d0
	bsr	do_val
	clr.b	(a2)
	bra.s	td_3

td_2:	move	d5,d0
	and.w	#%1111100000000000,d0
	lsr.w	#8,d0
	lsr.w	#3,d0
	bsr	do_val
	move.b	d7,(a2)+
	move	d5,d0
	and.w	#%11111100000,d0
	lsr.w	#5,d0
	bsr	do_val
	move.b	d7,(a2)+
	move	d5,d0
	and.w	#%11111,d0
	lsl	d0
	bsr	do_val
	clr.b	(a2)
td_3:	move.b	#1,(a5)+
	addq	#4,a4
	move.l	(a4),a0
	dbf	d6,td_0
	rts

cpy_2:	lsl	#2,d1		; top_name * 4
	lea	pointers,a6
	add	d1,a6
	move.l	(a6),a0
	add	#size,a0
	lea	string_table,a1

	lea	name_flags,a5
	cmp.w	#16,name_count
	bge.s	.1
	tst	name_count
	beq	copy_exit
	move	name_count,d6
	subq	#1,d6
	bra.s	size_1

.1:	move	#15,d6

size_1:	move.l	(a1),a2		; Pointer to string
	move.l	(a6),a3		; Pointer to name
	cmp.b	#7,(a3)		; Folder?
	bne.s	size_3

	move	#13,d2
fol_1:	move.b	#' ',(a2)+
	dbf	d2,fol_1
	sub	#14,a2
	move.l	a2,a4
	move	#9,d2
fol_1a:	cmp.b	#'.',(a3)
	beq.s	folext
	move.b	(a3)+,(a2)+
	beq.s	fol_2
	dbf	d2,fol_1a
folext:	add	#10,a4		; Point to extension field
	move	#4,d2
fole_1:	move.b	(a3)+,(a4)+
	beq.s	fol_2
	dbf	d2,fole_1

fol_2:	bra.s	stripx

size_3:	bsr.s	spc_1

	move.l	(a0),d0
	bsr.s	bindec32
	clr.b	(a2)
	move.l	(a1),a2
	addq	#6,a2
	move	#6,d3
strip:	cmp.b	#'0',(a2)
	bne.s	stripx
	move.b	#'_',(a2)
	addq	#1,a2
	dbf	d3,strip
stripx:	move.b	#1,(a5)+
	addq	#4,a1
	addq	#4,a6
	move.l	(a6),a0
	add	#size,a0
	dbf	d6,size_1
	rts

spc_1:	move.b	#' ',(a2)+
spc_2:	move.b	#' ',(a2)+
	move.b	#' ',(a2)+
	move.b	#' ',(a2)+
	move.b	#' ',(a2)+
	move.b	#' ',(a2)+
	rts

* Binary longword to decimal ASCII conversion
*
* Enter with: a2 -> ASCII string area
*	      d0 =  number to convert (long)

bindec32:
	move.l	a4,-(sp)
	lea	dectbl,a4
	move	#6,d2
bdl0:	move.b	#'0',(a2)
bdl1:	cmp.l	(a4),d0
	blo.s	bdl2
	sub.l	(a4),d0
	addq.b	#1,(a2)
	bra	bdl1
bdl2:	addq	#4,a4
	addq	#1,a2
bdl3:	dbf	d2,bdl0
	add.b	#'0',d0
	move.b	d0,(a2)+
	move.l	(sp)+,a4
	rts

do_val:	move.l	a2,-(sp)
	lea	deciml,a2
	and.l	#$FFFF,d0
	bsr	bindec32
	lea	deciml+6,a0
	move.l	(sp)+,a2
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts

new_top:
	moveq	#0,d0
	moveq	#0,d1

	move	top_name,d0
	move	otrack+22,d1
	mulu	d1,d0
	divu	name_count,d0
	move.l	d0,d2
	swap	d2
	tst	d2
	beq.s	new_t1
	addq	#1,d0

new_t1:	move	d0,d5

	move	tr_co,d0
	move	d0,x_clip
	add	otrack+20,d0
	move	d0,w_clip
	subq	#1,w_clip

	move	oslider+18,d2	; Get current Y pos to d2
	add	tr_co+2,d2
	move	d5,d3
	add	tr_co+2,d3

	cmp.w	d2,d3		; Which one's lower?
	blo.s	newhi		; The new Y pos is
	move	d2,y_clip	; Start clipping at old Y pos
	bra.s	do_hi
newhi:	move	d3,y_clip	; Start clipping at new Y pos
do_hi:	subq	#1,y_clip
	sub	d3,d2		; Get the difference
	bpl.s	do_hi1		; Positive, skip
	neg	d2		; Complement it
do_hi1:	add	oslider+22,d2	; Add height to difference
	addq	#2,d2
	move	d2,h_clip

	move	d5,oslider+18
	lea	intin,a0
	move	#track,(a0)
	move	#2,2(a0)
	move.l	x_clip,4(a0)
	move.l	w_clip,8(a0)
	move.l	#o_cdrw,aespb
	bra	aes

all_clear:
	lea	ofile1str+11,a0
	lea	path_array,a1
	move	#15,d0
all_1:	bclr.b	#0,(a0)
	clr.b	(a1)
	add	#24,a0
	add	#128,a1
	dbf	d0,all_1
	rts

clear_stat:
	lea	ofile1str+11,a0
	move	#15,d0
	move	#file1str,d1
clrst1:	btst.b	#0,(a0)
	beq.s	clrst2
	bclr.b	#0,(a0)
	move	d1,intin
	move	#1,intin+2
	bsr	drawob
	rts
clrst2:	addq	#1,d1
	add	#24,a0
	dbf	d0,clrst1
	rts

copy_raster:
	dc.w	$A00A		; Hide the mouse
	bsr.s	set_clip	; set_clip leaves the line A address in a5
	move.l	4(a5),a1	; Pointer to contrl
	move.l	#smfdb,14(a1)	; Set addresses of MFDBs
	move.l	#dmfdb,18(a1)
	move.l	8(a5),a1	; Pointer to intin
	move	#3,(a1)		; Replace mode
	move.l	12(a5),a1	; Pointer to ptsin
	move.l	16(sp),(a1)	; Get parameters from stack
	move.l	12(sp),4(a1)
	move.l	8(sp),8(a1)
	move.l	4(sp),12(a1)
	clr.w	116(a5)		; Set COPYTRAN to opaque copy
	dc.w	$A00E		; Line A COPY RASTER
	dc.w	$A009
	rts

set_clip:
	move.l	line_a,a5
	move	#1,54(a5)	; Set Line A clipping rectangle
	clr.l	56(a5)		; Basically, we're setting the clipping
	move.l	smfdb+4,60(a5)	; rectangle to the screen coordinates
	rts

arrow:	clr	intin
	bra.s	maus
bee:	move	#2,intin
maus:	move.l	#g_mous,aespb
	bra	aes

draw_names:
	move	#filebox,intin
	move	#2,depth
	move.l	#$00010001,x_off
	move.l	#$00020002,w_off
	bra.s	obdraw

* Dialog box drawing routine
* Enter with: addrin = address of tree

drawbx:
	clr.w	intin		; Reserve screen buffer memory
	bsr	dial		; dial: leaves address of intin in a5

	move.l	#o_cdrw,aespb	; Now, let's call objc_draw
	clr.w	(a5)		; Root object gets drawn first
	move	#8,2(a5)	; # of subordinate levels
	move.l	cx,4(a5)
	move.l	cw,8(a5)	; The call to form_dial has already put
	bra	aes		; the address of tfsel in addrin

formdo:	move.l	#f_do,aespb	; Gimme dat ol' AES input
	move	field,intin	; Position of edit cursor
	move.l	#tfsel,addrin
	bsr	aes
	move.w	intout,selobj
	rts

obdraw:	move.l	#o_coff,aespb
	move.l	#tfsel,addrin
	bsr	aes
	lea	intin,a4
	lea	intout,a5
	move.l	2(a5),4(a4)
	move.l	x_off,d0
	add	d0,6(a4)
	swap	d0
	add	d0,4(a4)
	move.l	addrin,a0
	moveq	#0,d5
	move	(a4),d5
	mulu	#24,d5
	add.l	d5,a0
	move.l	20(a0),8(a4)
	move.l	w_off,d0
	sub	d0,10(a4)
	swap	d0
	sub	d0,8(a4)
	move.l	#o_cdrw,aespb
	move	depth,2(a4)
	bra	aes

drawob:	move.l	#o_cdrw,aespb
	lea	intin,a0
	move.l	cx,4(a0)
	move.l	cw,8(a0)
	move.l	#tfsel,addrin
	bra.s	aes

close_box:
	move	#3,intin

* form_dial

dial:	move.l	#f_dial,aespb
	lea	intin,a5
	clr.l	2(a5)		; intin has already been set
	clr.l	6(a5)
	move.l	cx,10(a5)
	move.l	cw,14(a5)
	move.l	#tfsel,addrin
	bra.s	aes

* objc_change

o_change:
	move.l	#o_chng,aespb	; Resets a selected object after exiting dialog
	lea	intin,a0
	move.w	selobj,(a0)
	bclr	#7,(a0)
	clr.w	2(a0)
	move.l	cx,4(a0)	; Enter with state in intin+12 and
	move.l	cw,8(a0)	; redraw flag in intin+14
	move.l	#tfsel,addrin
*	bra.s	aes

* AES subroutine

aes:	move	#1,aesflg
	move.l	#aespb,d1
	move.l	#$C8,d0
	move.l	sp,savesp
	move.l	t2_sp,sp
	move.l	#aes_2,2(sp)
	move	sr,(sp)
aes_1:	jmp	$DEADBEEF
aesvec	=	aes_1+2

aes_2:	clr	aesflg
	move.l	savesp,sp
	rts


	.data

e_butt:	dc.w	21,3,5,0,0
g_drag:	dc.w	71,8,3,0,0
g_mous:	dc.w	78,1,1,1,0
w_updt:	dc.w	107,1,1,0,0
f_alrt:	dc.w	52,1,1,1,0
f_cntr:	dc.w	54,0,5,1,0
f_do:	dc.w	50,1,2,1,0
f_dial:	dc.w	51,9,1,1,0
o_cdrw:	dc.w	42,6,1,1,0
o_chng:	dc.w	47,8,1,1,0
o_coff:	dc.w	44,1,3,1,0

aespb:	dc.l	contrl,global,intin,intout,addrin,addrout

* Thanks, John!  Following code courtesy RSC_ASM.PRG

* ---------- Source code conversion from FSEL.RSC ----------

* ---------- Equates --------------------

fsel	=	0	; tree
closbx	=	2	; object in fsel tree
up	=	3	; object in fsel tree
down	=	23	; object in fsel tree
text1	=	25	; object in fsel tree
text2	=	26	; object in fsel tree
nameln	=	28	; object in fsel tree
okbt	=	30	; object in fsel tree
cancbt	=	31	; object in fsel tree
specln	=	1	; object in fsel tree
dskutl	=	52	; object in fsel tree
drvbox	=	32	; object in fsel tree
drvabt	=	33	; object in fsel tree
drvbbt	=	34	; object in fsel tree
drvcbt	=	35	; object in fsel tree
drvdbt	=	36	; object in fsel tree
drvebt	=	37	; object in fsel tree
drvfbt	=	38	; object in fsel tree
drvgbt	=	39	; object in fsel tree
drvhbt	=	40	; object in fsel tree
drvibt	=	41	; object in fsel tree
drvjbt	=	42	; object in fsel tree
drvkbt	=	43	; object in fsel tree
drvlbt	=	44	; object in fsel tree
drvmbt	=	45	; object in fsel tree
drvnbt	=	46	; object in fsel tree
drvobt	=	47	; object in fsel tree
drvpbt	=	48	; object in fsel tree
file1str=	7	; object in fsel tree
file3str=	9	; object in fsel tree
file4str=	10	; object in fsel tree
file5str=	11	; object in fsel tree
file6str=	12	; object in fsel tree
file7str=	13	; object in fsel tree
file8str=	14	; object in fsel tree
file9str=	15	; object in fsel tree
file10st=	16	; object in fsel tree
file11st=	17	; object in fsel tree
file12st=	18	; object in fsel tree
slider	=	5	; object in fsel tree
track	=	4	; object in fsel tree
file13st=	19	; object in fsel tree
file14st=	20	; object in fsel tree
file15st=	21	; object in fsel tree
pathbx	=	53	; object in fsel tree
pathln	=	54	; object in fsel tree
pthttl	=	55	; object in fsel tree
file2str=	8	; object in fsel tree
file16st=	22	; object in fsel tree
left	=	49	; object in fsel tree
infobt	=	50	; object in fsel tree
right	=	51	; object in fsel tree
filebox	=	6	; object in fsel tree

G_BOX      =  20
G_TEXT     =  21
G_BOXTEXT  =  22
G_IMAGE    =  23
G_PROGDEF  =  24
G_IBOX     =  25
G_BUTTON   =  26
G_BOXCHAR  =  27
G_STRING   =  28
G_FTEXT    =  29
G_FBOXTEXT =  30
G_ICON     =  31
G_TITLE    =  32

NONE       =  %000000000
SELECTABLE =  %000000001
DEFAULT    =  %000000010
EXIT       =  %000000100
EDITABLE   =  %000001000
RBUTTON    =  %000010000
LASTOB     =  %000100000
TOUCHEXIT  =  %001000000
HIDETREE   =  %010000000
INDIRECT   =  %100000000

NORMAL     =  %000000
SELECTED   =  %000001
CROSSED    =  %000010
CHECKED    =  %000100
DISABLED   =  %001000
OUTLINED   =  %010000
SHADOWED   =  %100000

	.even

* ---------- Ted Info Structures --------------------

especln:
	dc.l	str0, null, null
	dc.w	3,6,2,$11A1,0,1,16,1
efile1str:
	dc.l	str3, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile2str:
	dc.l	str6, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile3str:
	dc.l	str9, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile4str:
	dc.l	str12, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile5str:
	dc.l	str15, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile6str:
	dc.l	str18, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile7str:
	dc.l	str21, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile8str:
	dc.l	str24, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile9str:
	dc.l	str27, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile10st:
	dc.l	str30, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile11st:
	dc.l	str33, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile12st:
	dc.l	str36, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile13st:
	dc.l	str39, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile14st:
	dc.l	str42, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile15st:
	dc.l	str45, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
efile16st:
	dc.l	str48, s_temp, s_vald
	dc.w	3,6,0,$1180,0,-1,14,16
etext1:
	dc.l	title1, null, null
	dc.w	3,6,2,$1000,0,-1,14,1
etext2:
	dc.l	title2, null, null
	dc.w	3,6,2,$1000,0,-1,14,1
enameln:
	dc.l	str53, str54, str55
	dc.w	3,6,2,$1180,0,-1,12,13
ted18:
	dc.l	str56, null, null
	dc.w	5,6,2,$1180,0,-1,10,1
edrvabt:
	dc.l	str61, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvbbt:
	dc.l	str64, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvcbt:
	dc.l	str67, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvdbt:
	dc.l	str70, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvebt:
	dc.l	str73, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvfbt:
	dc.l	str76, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvgbt:
	dc.l	str79, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvhbt:
	dc.l	str82, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvibt:
	dc.l	str85, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvjbt:
	dc.l	str88, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvkbt:
	dc.l	str91, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvlbt:
	dc.l	str94, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvmbt:
	dc.l	str97, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvnbt:
	dc.l	str100, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvobt:
	dc.l	str103, null, null
	dc.w	5,6,2,$1180,0,1,2,1
edrvpbt:
	dc.l	str106, null, null
	dc.w	5,6,2,$1180,0,1,2,1
einfobt:
	dc.l	str109, null, null
	dc.w	3,6,2,$1180,0,-1,9,1
epathln:
	dc.l	str113, str114, str115
	dc.w	3,6,2,$1180,0,-1,39,39
ted37:
	dc.l	str116, null, null
	dc.w	5,6,2,$1180,0,-1,19,1

* ---------- Object Trees --------------------

tfsel:					; (tree 0)
obj0:
	dc.w	-1,1,53,G_BOX,NONE,OUTLINED
	dc.l	$21152
	dc.w	$60,$26,$140,$16E
ospecln:
	dc.w	2,-1,-1,G_BOXTEXT,TOUCHEXIT,SHADOWED
	dc.l	especln
	dc.w	$1C,$0C,$A1,$14
oclosbx:
	dc.w	3,-1,-1,G_BOXCHAR,TOUCHEXIT,NORMAL
	dc.l	$5FF1100
	dc.w	$0C,$0D,$10,$12
oup:
	dc.w	4,-1,-1,G_BOXCHAR,TOUCHEXIT,SHADOWED
	dc.l	$1FF1100
	dc.w	$A4,$20,$18,$20
otrack:
	dc.w	6,5,5,G_BOX,TOUCHEXIT,SHADOWED
	dc.l	$FF1111
	dc.w	$A4,$41,$18,$D0
oslider:
	dc.w	4,-1,-1,G_BOX,TOUCHEXIT,NORMAL
	dc.l	$FF1100
	dc.w	$00,$01,$18,$19
ofilebox:
	dc.w	23,7,22,G_BOXCHAR,TOUCHEXIT,NORMAL
	dc.l	$FF1100
	dc.w	$0C,$20,$97,$111
ofile1str:
	dc.w	8,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile1str
	dc.w	$10,$08,$78,$10
ofile2str:
	dc.w	9,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile2str
	dc.w	$10,$18,$78,$10
ofile3str:
	dc.w	10,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile3str
	dc.w	$10,$28,$78,$10
ofile4str:
	dc.w	11,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile4str
	dc.w	$10,$38,$78,$10
ofile5str:
	dc.w	12,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile5str
	dc.w	$10,$48,$78,$10
ofile6str:
	dc.w	13,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile6str
	dc.w	$10,$58,$78,$10
ofile7str:
	dc.w	14,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile7str
	dc.w	$10,$68,$78,$10
ofile8str:
	dc.w	15,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile8str
	dc.w	$10,$78,$78,$10
ofile9str:
	dc.w	16,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile9str
	dc.w	$10,$88,$78,$10
ofile10st:
	dc.w	17,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile10st
	dc.w	$10,$98,$78,$10
ofile11st:
	dc.w	18,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile11st
	dc.w	$10,$A8,$78,$10
ofile12st:
	dc.w	19,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile12st
	dc.w	$10,$B8,$78,$10
ofile13st:
	dc.w	20,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile13st
	dc.w	$10,$C8,$78,$10
ofile14st:
	dc.w	21,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile14st
	dc.w	$10,$D8,$78,$10
ofile15st:
	dc.w	22,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile15st
	dc.w	$10,$E8,$78,$10
ofile16st:
	dc.w	6,-1,-1,G_FTEXT,$51,NORMAL
	dc.l	efile16st
	dc.w	$10,$F8,$78,$10
odown:
	dc.w	24,-1,-1,G_BOXCHAR,TOUCHEXIT,SHADOWED
	dc.l	$2FF1100
	dc.w	$A4,$112,$18,$1F
otitlbx:
	dc.w	27,25,26,G_BOX,NONE,$31
	dc.l	$FF1100
	dc.w	$C8,$0F,$6E,$20
otext1:
	dc.w	26,-1,-1,G_TEXT,TOUCHEXIT,NORMAL
	dc.l	etext1
	dc.w	$00,$00,$6D,$10
otext2:
	dc.w	24,-1,-1,G_TEXT,TOUCHEXIT,NORMAL
	dc.l	etext2
	dc.w	$00,$10,$6D,$10
obj27:
	dc.w	30,28,29,G_BOX,NONE,SHADOWED
	dc.l	$FF1100
	dc.w	$C8,$39,$6D,$25
onameln:
	dc.w	29,-1,-1,G_FTEXT,EDITABLE,NORMAL
	dc.l	enameln
	dc.w	$00,$07,$6D,$10
obj29:
	dc.w	27,-1,-1,G_TEXT,NONE,NORMAL
	dc.l	ted18
	dc.w	$00,$18,$6D,$0C
ookbt:
	dc.w	31,-1,-1,G_BUTTON,$7,NORMAL
	dc.l	str59
	dc.w	$D7,$6D,$50,$10
ocancbt:
	dc.w	32,-1,-1,G_BUTTON,$5,NORMAL
	dc.l	str60
	dc.w	$D7,$8A,$50,$10
obj32:
	dc.w	49,33,48,G_IBOX,NONE,NORMAL
	dc.l	$FF1100
	dc.w	$D7,$A7,$50,$80
odrvabt:
	dc.w	34,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvabt
	dc.w	$00,$00,$28,$10
odrvbbt:
	dc.w	35,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvbbt
	dc.w	$00,$10,$28,$10
odrvcbt:
	dc.w	36,-1,-1,G_BOXTEXT,$51,SELECTED
	dc.l	edrvcbt
	dc.w	$00,$20,$28,$10
odrvdbt:
	dc.w	37,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvdbt
	dc.w	$00,$30,$28,$10
odrvebt:
	dc.w	38,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvebt
	dc.w	$00,$40,$28,$10
odrvfbt:
	dc.w	39,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvfbt
	dc.w	$00,$50,$28,$10
odrvgbt:
	dc.w	40,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvgbt
	dc.w	$00,$60,$28,$10
odrvhbt:
	dc.w	41,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvhbt
	dc.w	$00,$70,$28,$10
odrvibt:
	dc.w	42,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvibt
	dc.w	$28,$00,$28,$10
odrvjbt:
	dc.w	43,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvjbt
	dc.w	$28,$10,$28,$10
odrvkbt:
	dc.w	44,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvkbt
	dc.w	$28,$20,$28,$10
odrvlbt:
	dc.w	45,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvlbt
	dc.w	$28,$30,$28,$10
odrvmbt:
	dc.w	46,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvmbt
	dc.w	$28,$40,$28,$10
odrvnbt:
	dc.w	47,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvnbt
	dc.w	$28,$50,$28,$10
odrvobt:
	dc.w	48,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvobt
	dc.w	$28,$60,$28,$10
odrvpbt:
	dc.w	32,-1,-1,G_BOXTEXT,$51,NORMAL
	dc.l	edrvpbt
	dc.w	$28,$70,$28,$10
oleft:
	dc.w	50,-1,-1,G_BOXCHAR,TOUCHEXIT,SHADOWED
	dc.l	$4FF1100
	dc.w	$0C,$132,$17,$14
oinfobt:
	dc.w	51,-1,-1,G_BOXTEXT,NONE,SHADOWED
	dc.l	einfobt
	dc.w	$24,$132,$7F,$14
oright:
	dc.w	52,-1,-1,G_BOXCHAR,TOUCHEXIT,SHADOWED
	dc.l	$3FF1100
	dc.w	$A4,$132,$18,$14
odskutl:
	dc.w	53,-1,-1,G_BUTTON,$5,NORMAL
	dc.l	str112
	dc.w	$CF,$134,$60,$10
opathbx:
	dc.w	0,54,55,G_BOX,TOUCHEXIT,NORMAL
	dc.l	$FE1100
	dc.w	$02,$14F,$13C,$1D
opathln:
	dc.w	55,-1,-1,G_FTEXT,$48,NORMAL
	dc.l	epathln
	dc.w	$06,$02,$130,$10
opthttl:
	dc.w	53,-1,-1,G_TEXT,TOUCHEXIT | LASTOB,NORMAL
	dc.l	ted37
	dc.w	$00,$12,$13C,$0A

.t_end:	dc.w	0

num_obs	=	(.t_end-tfsel)/24

* ---------- Strings --------------------

null:	dc.b	0
sspecln:
str0:	dc.b	"               ",0
sfile1str:
str3:	dc.b	"  ___________",0,0,0
sfile2str:
str6:	dc.b	"  ___________",0,0,0
sfile3str:
str9:	dc.b	"  ___________",0,0,0
sfile4str:
str12:	dc.b	"  ___________",0,0,0
sfile5str:
str15:	dc.b	"  ___________",0,0,0
sfile6str:
str18:	dc.b	"  ___________",0,0,0
sfile7str:
str21:	dc.b	"  ___________",0,0,0
sfile8str:
str24:	dc.b	"  ___________",0,0,0
sfile9str:
str27:	dc.b	"  ___________",0,0,0
sfile10st:
str30:	dc.b	"  ___________",0,0,0
sfile11st:
str33:	dc.b	"  ___________",0,0,0
sfile12st:
str36:	dc.b	"  ___________",0,0,0
sfile13st:
str39:	dc.b	"  ___________",0,0,0
sfile14st:
str42:	dc.b	"  ___________",0,0,0
sfile15st:
str45:	dc.b	"  ___________",0,0,0
sfile16st:
str48:	dc.b	"  ___________",0,0,0

snameln:
str53:	dc.b	"___________",0,0,0
str54:	dc.b	"________.___",0
str55:	dc.b	"FFFFFFFFFFF",0
str56:	dc.b	"Selection",0
sokbt:
str59:	dc.b	"OK",0
scancbt:
str60:	dc.b	"CANCEL",0
sdrvabt:
str61:	dc.b	"A",0
sdrvbbt:
str64:	dc.b	"B",0
sdrvcbt:
str67:	dc.b	"C",0
sdrvdbt:
str70:	dc.b	"D",0
sdrvebt:
str73:	dc.b	"E",0
sdrvfbt:
str76:	dc.b	"F",0
sdrvgbt:
str79:	dc.b	"G",0
sdrvhbt:
str82:	dc.b	"H",0
sdrvibt:
str85:	dc.b	"I",0
sdrvjbt:
str88:	dc.b	"J",0
sdrvkbt:
str91:	dc.b	"K",0
sdrvlbt:
str94:	dc.b	"L",0
sdrvmbt:
str97:	dc.b	"M",0
sdrvnbt:
str100:	dc.b	"N",0
sdrvobt:
str103:	dc.b	"O",0
sdrvpbt:
str106:	dc.b	"P",0
sinfobt:
str109:	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
sdskutl:
str112:	dc.b	"*.*",0,0,0,0,0,0,0,0,0,0,0,0,0 ; Let's leave plenty of space
spathln:
str113:	dc.b	"______________________________________",0
str114:	dc.b	"______________________________________",0
str115:	dc.b	"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",0
str116:	dc.b	"Path Specification",0

	.even

color_yh:
	dc.w	$7E7,$B6
	dc.w	$04,$0C
	dc.w	$05,$0A
	dc.w	$10,$0F
	dc.w	$20,$62
	dc.w	$01,$11
	dc.w	$10,$82
	dc.w	$01,$08
	dc.w	$09,$08
	dc.w	$11,$08
	dc.w	$19,$08
	dc.w	$21,$08
	dc.w	$29,$08
	dc.w	$31,$08
	dc.w	$39,$08
	dc.w	$41,$08
	dc.w	$49,$08
	dc.w	$51,$08
	dc.w	$59,$08
	dc.w	$61,$08
	dc.w	$69,$08
	dc.w	$71,$08
	dc.w	$79,$08
	dc.w	$83,$0F
	dc.w	$05,$10
	dc.w	$00,$08
	dc.w	$08,$08
	dc.w	$16,$15
	dc.w	$03,$08
	dc.w	$0D,$08
	dc.w	$33,$08
	dc.w	$42,$08
	dc.w	$50,$40
	dc.w	$00,$08
	dc.w	$08,$08
	dc.w	$10,$08
	dc.w	$18,$08
	dc.w	$20,$08
	dc.w	$28,$08
	dc.w	$30,$08
	dc.w	$38,$08
	dc.w	$00,$08
	dc.w	$08,$08
	dc.w	$10,$08
	dc.w	$18,$08
	dc.w	$20,$08
	dc.w	$28,$08
	dc.w	$30,$08
	dc.w	$38,$08
	dc.w	$93,$0A
	dc.w	$93,$0A
	dc.w	$93,$0A
	dc.w	$96,$08
	dc.w	$A4,$10
	dc.w	$01,$08
	dc.w	$09,$07
yh_end:
	dc.w	0

yh_len	=	(yh_end - color_yh) / 4 - 1

info_tbl:
	dc.l	sinfobt,sizems,datems,timems

string_table:
	dc.l	sfile1str,sfile2str,sfile3str,sfile4str
	dc.l	sfile5str,sfile6str,sfile7str,sfile8str
	dc.l	sfile9str,sfile10st,sfile11st,sfile12st
	dc.l	sfile13st,sfile14st,sfile15st,sfile16st

dectbl:	dc.l	10000000,1000000,100000,10000,1000,100,10

datems:	dc.b	"Date",0
timems:	dc.b	"Time",0
sizems:	dc.b	"Size",0

filems:	dc.b	' Files',0

title1:	dc.b	"START",0
title2:	dc.b	"SELECTOR",0

user_1:	dcb.b	16,0
user_2:	dcb.b	16,0

* ---------- Alerts ---------------------

not_auto:
	dc.b	'[0][    The START SELECTOR!| |'
	dc.b	'   By Charles F. Johnson|'
	dc.b	'  ',$BD,' 1988 Antic Publishing   | ]'
	dc.b	'[ Install |Forget it]',0

copyright:
	dc.b	'[0][    The START SELECTOR!| |'
	dc.b	'   By Charles F. Johnson|'
	dc.b	'  ',$BD,' 1988 Antic Publishing    | ]'
	dc.b	'[ Click Me ]',0

dfree:
	dc.b	'[0][       Drive: '
dfdrv:	dc.b	'  | |'
	dc.b	'  Bytes free: '
frems1:	dc.b	'           | ]'
	dc.b	'[  OK  ]',0

blank1:	dc.b	"  ___________",0,0
blank2:	dc.b	"      ________",0

s_temp:	dc.b	"__________.___ ",0
s_vald:	dc.b	"FFFFFFFFFFFFF",0

s_tem1:	dc.b	"__________.___ ",0

s_tem2:	dc.b	"______________ ",0

spec:	dc.b	'*.*',0

title:	dc.b	27,'E',13,10,' ',27,'p The START SELECTOR ',27,'q'
	dc.b	13,10,10,' By Charles F. Johnson'
	dc.b	13,10,' ',$BD,' 1988 Antic Publishing'
	dc.b	13,10,10
	dc.b	0

	.even

	.bss

line_a:
	ds.l	1
aesadr:
	ds.l	1
dir_spec:
	ds.l	1
file_spec:
	ds.l	1

tr_co:	ds.l	1

sav_ht:	ds.l	1
sr_t2:	ds.w	1
ret_t2:	ds.l	1
t2_sp:	ds.l	1
savesp:	ds.l	1
keybuf:	ds.l	1
kmsav1:	ds.w	1
kmsav2:	ds.l	1

prgflg:	ds.w	1
critfl:	ds.w	1
errflg:	ds.w	1
intflg:	ds.w	1
index:	ds.w	1
vecset:	ds.w	1
aesflg:	ds.w	1
defdrv:	ds.w	1
res:	ds.w	1
ressav:	ds.w	1
depth:	ds.w	1
selobj:	ds.w	1
cx:	ds.w	1
cy:	ds.w	1
cw:	ds.w	1
ch:	ds.w	1
x_off:	ds.w	1
y_off:	ds.w	1
w_off:	ds.w	1
h_off:	ds.w	1
x_clip:	ds.w	1
y_clip:	ds.w	1
w_clip:	ds.w	1
h_clip:	ds.w	1
path_x:	ds.w	1

infoco:	ds.w	1

fixed:	ds.w	1
attrib:	ds.w	1
field:	ds.w	1

name_count:
	ds.w	1
top_name:
	ds.w	1
curr_name:
	ds.w	1

contrl:	ds.w	6
intin:	ds.w	16
intout:	ds.w	16
global:
apvrsn:	ds.w	1
apcont:	ds.w	1
apid:	ds.w	1
apprvt:	ds.l	1
apptre:	ds.l	1
ap1rsv:	ds.l	1
ap2rsv:	ds.l	1
ap3rsv:	ds.l	1
ap4rsv:	ds.l	1
addrin:	ds.l	8
addrout:ds.l	8

deciml:
	ds.b	16

name_flags:
	ds.b	16

specsv:
	ds.b	16

temp_spec:
	ds.b	16

pathname:
	ds.b	80

dta:	ds.b	44

name_array:
	ds.b	24 * max_files + 24

pointers:
	ds.l	max_files

path_array:
	ds.b	128 * 16

h_block:
	ds.w	4
l_block:
	ds.w	4

smfdb:	ds.w	10
dmfdb:	ds.w	10

aes_rsav:
	ds.l	16

km_rsav:
	ds.l	16

d_buff:	ds.l	4

k_buff:	ds.l	16

	ds.b	2560		; 2.5K worth of stack
my_stack:
	ds.l	1
	ds.w	10


prog_end:
	ds.w	0

	.end
