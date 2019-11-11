**************************************************************************
*                                                                        *
*  MOUSE-KA-MANIA!                                                       *
*                                                                        *
*  by Charles F. Johnson                                                 *
*                                                                        *
*  Copyright 1987 Charles F. Johnson & Little Green Footballs Software.  *
*  All rights reserved.                                                  *
*                                                                        *
*  This source code is for the MADMAC assembler.                         *
*                                                                        *
**************************************************************************

* -----------------------------------
*  Last revision: 08/27/87  13:14:48
* -----------------------------------

	.include	"C:\\AS68\\OBJECT.S"

* Object index equates

savebt	=	22
loadbt	=	29
clrmbt	=	30
clrdbt	=	23
invdbt	=	24
invmbt	=	31
upbt	=	11
leftbt	=	12
downbt	=	18
ritebt	=	13
mirdbt	=	25
mirmbt	=	32
exitbt	=	26
instbt	=	5
remvbt	=	6
undobt	=	27
rotbt	=	28
cdowbt	=	8
cupbt	=	10
colval	=	9
colttl	=	7
frmttl	=	14
frdown	=	15
frup	=	17
frmval	=	16
anonof	=	21

loinst	=	3
loremv	=	7
loexit	=	11
locolr	=	10
lodown	=	12
locval	=	13
loup	=	14
losvbt	=	5

* Guaranteed memory locations

ipl_vec		=	$70	; System vertical blank vector
sshiftmod	=	$44C	; System resolution variable

* These locations are undocumented, and are not guaranteed to remain the same
* in future versions of TOS.  However, they are referenced by negative
* offsets from the Line A variable areas, and they do work with the version
* of TOS in the Mega ST.

ignore		=	-$153	; Negative offset to mouse packet ignore flag
but_stat	=	-$15C	; Offset to mouse button status variable
mouse_x		=	-$25A	; Mouse X location (pokeable)

	.text

	move.l	#ustack,a7	; Accessory initialization

	dc.w	$A000		; Line A init
	move.l	a0,line_a

	move.l	#ap1rsv,a5
	clr.l	(a5)		; appl_init
	clr.l	4(a5)
	clr.l	8(a5)
	clr.l	12(a5)
	move.l	#a_init,aespb
	bsr	aes

	move.l	#m_reg,aespb	; menu_register
	move	intout,intin
	move.l	#accmsg,addrin
	bsr	aes
	move	intout,menuid	; Save menu ID number

	move.l	#g_hand,aespb	; graph_handle
	bsr	aes
	move	intout,ghandl

	move.l	#e_timr,aespb	; Call evnt_timer to let GEM finish doing
	clr.l	intin		; whatever the heck it does to initialize
	bsr	aes		; (Wait for _zero_ milliseconds)

	move.l	#g_mous,aespb	; Set arrow cursor so we can search for it
	clr.w	intin
	bsr	aes

	move.l	#$2000,a5	; Start searching for the mouse definition
sm_1:	move.l	#arrow_data,a4	; Pointer to my arrow data
	move	#31,d5		; 32 words to check
sm_2:	move.w	(a5),d0		; Get a word
	cmp.w	(a4),d0		; Match first word of arrow definition?
	beq.s	sm_3		; Yes, check the rest
	addq	#2,a5		; Increment pointer
	bra	sm_2
sm_3:	move.l	a5,a0		; Save address of first match
sm_4:	cmp.w	(a5)+,(a4)+	; See if we have the whole mouse here
	bne	sm_1
	dbf	d5,sm_4
	move.l	a0,sprtad	; Found it! Save mouse sprite buffer address

	move.l	#r_obfx,aespb	; Adjust coordinates in editor object tree
	move.l	#editbx,addrin
	move	#objnum,d5
fxedt:	move	d5,intin
	bsr	aes
	dbf	d5,fxedt

	move.l	#lowbox,addrin	; Now adjust the low res object tree
	move	#lo_num,d5
fxlow:	move	d5,intin
	bsr	aes
	dbf	d5,fxlow

	move	#4,-(sp)	; Get resolution
	trap	#14
	addq	#2,sp

	cmp.w	#2,d0		; Hi res?
	bne.s	ckmed1		; No, skip
	move.l	#hi_val,valsav	; Save address of color translation table
	bra.s	savres		; based on the current resolution
ckmed1:	cmp.w	#1,d0
	bne.s	cklow1
	move.l	#med_val,valsav
	bra.s	savres
cklow1:	move.l	#low_val,valsav
savres:	move	d0,o_res	; Save boot resolution

	cmp.w	#2,d0		; High res?
	beq.s	hi1		; Yes, skip
	move.l	#y_off,a0	; Adjust the Y coordinate variables
	move	#4,d5		; 5 of these
adjres:	lsr.w	(a0)+		; Divide by 2
	dbf	d5,adjres
	move.w	#160,y_scr

hi1:	subq.w	#4,upco		; Adjust the positions of a few objects
	subq.w	#4,leftco
	subq.w	#4,riteco
	subq.w	#4,downco
	addq.w	#2,datco
	addq.w	#2,mskco
	cmp.w	#2,d0		; d0 still holds resolution (right?)
	bne.s	med1		; Not hi res, skip
	addq.w	#3,cop_co+2
	subq.w	#3,footco+2	; Shuffle them objects!
	subq.w	#6,leftco+2
	subq.w	#6,riteco+2
	sub.w	#12,downco+2
	bra.s	fsel_search
med1:	subq.w	#3,leftco+2	; Have to move 'em by different amounts
	subq.w	#3,riteco+2	; in medium res
	subq.w	#6,downco+2
	move	#4,filhot	; Set medium res hot spot fill style
	move	#4,fillst	; Set mask fill style
	move	#4,celsiz	; Editing grid cell size
	move	#2,planes	; Number of color planes

fsel_search:
	clr.w	fsflag		; Clear "search failed" flag
	move.l	#$A000,a5	; Start searching at $A000
s_1:	move.l	#itmtxt,a4	; Get pointer to search string ("ITEM SELECTOR")
	move	#12,d5		; Get number of bytes to search for
s_2:	move.b	(a5),d0		; Get a character
	cmp.b	(a4),d0		; Is it "I"?
	beq.s	s_3		; Yes, check for rest of string
	addq	#1,a5		; Increment the pointer
	cmp.l	#$40000,a5
	bne	s_2
	bra.s	s_6		; Keep searching
s_3:	move.l	a5,a0		; Save address of first match
s_4:	cmp.b	(a5)+,(a4)+	; See if we have the whole string
	bne	s_1		; No, go search more
	dbf	d5,s_4		; Count down and loop
	tst.b	13(a0)		; There should be a zero after it
	bne	s_1

s4_2:	move.l	a0,d0		; Found it! Save address of text in d0
	move.l	a0,iasav
	move.l	a0,d1		; Move address to d1 so we can manipulate it
	bclr	#0,d1		; Clear odd bit
	move.l	d1,a0		; Back to a0
s_5:	subq	#2,a0		; Decrement the pointer to memory
	cmp.l	#$A000,a0	; Back at the start already?
	beq.s	s_6		; Yes, skip ahead
	move.l	(a0),d1		; Get a longword
	cmp.l	d1,d0		; Is this the pointer to "ITEM SELECTOR"?
	bne	s_5		; No, search more
	move.l	a0,itmadr	; Save address of pointer
	move	8(a0),ilensv	; Save original string length
	bra.s	search

s_6:	move	#1,fsflag	; Set flag to indicate search failure

search:
	clr.w	lowflg
	cmp.w	#2,o_res	; High res?
	beq	getdrv		; Yes, skip this
	move.l	#$A000,a5
sr_1:	move.l	#restxt,a4	; Find object spec of "Low" button in the
	move	#14,d5		; "Set Preferences" desktop dialog box
sr_2:	move.b	(a5),d0
	cmp.b	(a4),d0
	beq.s	sr_3
	addq	#1,a5
	cmp.l	#$40000,a5
	beq.s	sr_6
	bra	sr_2
sr_3:	move.l	a5,a0
sr_4:	cmp.b	(a5)+,(a4)+
	bne	sr_1
	dbf	d5,sr_4
	tst.b	15(a0)		; Once again, there has to be a zero after it
	bne	sr_1

	move.l	a0,d0
	move.l	a0,d1
	bclr	#0,d1
	move.l	d1,a0
sr_5:	subq	#2,a0
	cmp.l	#$A000,a0
	beq.s	sr_6
	move.l	(a0),d1
	cmp.l	d1,d0
	bne	sr_5
	subq	#2,a0		; Point to status word of "Low" button
	move.l	a0,d0
	sub.l	#96,d0		; Get pointer to status word of "OK" button
	move.l	d0,res_okptr
	cmp.w	#2,o_res
	beq.s	set_lo
	tst.w	o_res
	beq.s	set_me
set_lo:	clr.l	d0
	bra.s	mult24
set_me:	move.l	#1,d0
mult24:	mulu	#24,d0		; Compute the index to the button that
	add.l	d0,a0		; should NOT be selected
	move.l	a0,res_optr	; Save pointer to its status word
	bra.s	getdrv

sr_6:	move	#1,lowflg

getdrv:	move	#$19,-(sp)	; Get current drive
	trap	#1
	addq	#2,sp
	add.b	#65,d0		; Convert to ASCII
	move.l	#savdir,a4
	move.l	#svadir,a2
	move.l	#loddir,a5
	move.l	#loadir,a3
	move.b	d0,(a2)+
	move.b	d0,(a3)+
	move.b	d0,(a4)+
	move.b	d0,(a5)+
	move.l	#datext,a0
	move.l	#aniext,a1
	move	#7,d5
cpydir:	move.b	(a0),(a4)+	; Move in the rest of the directory lines
	move.b	(a0)+,(a5)+
	move.b	(a1),(a2)+
	move.b	(a1)+,(a3)+
	dbf	d5,cpydir

	clr.w	colflg		; Clear color change flag
	clr.w	insflg		; Clear installed flag
	clr.w	antflg		; Clear animation title flag
	clr.w	onoff		; Clear animation on/off flag
	clr.w	franum		; Clear frame number
	clr.w	moucnt
	clr.w	vbi_on
	clr.w	diflag
	move.w	#1,nframs	; Set number of frames in loop

	tst.w	o_res		; Are we in low res?
	bne.s	rdef1		; No, skip
	move.l	#lowdef,a5	; Set address of default mouse filename
	bra.s	rdef3		; based on current res
rdef1:	cmp.w	#1,o_res
	bne.s	rdef2
	move.l	#meddef,a5
	bra.s	rdef3
rdef2:	move.l	#hidef,a5
rdef3:	move.l	a5,filadr
	bsr	sav_exist
	bmi	no_def
	cmp.l	#74,dta+26	; Is it a data file? (74 bytes)
	beq	rdef4		; Yes, skip
	bsr	open_file	; Open the file
	bmi	no_def		; Error, bail
	move	d0,fhandl
	move.l	#mouse_array,a5	; Set address of mouse animation array
	move.l	#74*32,d5	; Length of data
	bsr	read_file
	bmi	no_def
	move.l	#nframs,a5	; Now read number of frames
	move.l	#2,d5
	bsr	read_file
	move.l	#delval,a5	; And delay value
	bsr	read_file
	bsr	clos_file
	cmp.w	#32,nframs	; # of frames greater than 32?
	bhi.s	rdef3_0		; Yes, exit
	cmp.w	#99,delval
	bhi.s	rdef3_0
	move.l	#mouse_array,a0
	move	#31,d0
ckdanf:	cmp.w	#15,(a0)	; Check all hotspot positions
	bhi.s	rdef3_0		; and color values
	cmp.w	#15,2(a0)
	bhi.s	rdef3_0
	cmp.w	#15,6(a0)
	bhi.s	rdef3_0
	cmp.w	#15,8(a0)
	bhi.s	rdef3_0
	add.l	#74,a0
	dbf	d0,ckdanf
	bra.s	rdef3_1

rdef3_0:
	bsr	clear_array
	bra.s	no_def

rdef3_1:
	bsr	arr_2_frm	; Copy first frame to editing area
	bsr	init_nfrm	; Initialize frame number box
	move.l	#anonms,tinf5	; Set "Animation ON" message
	move.w	delval,vbtimr	; Set the vertical blank timer
	clr.w	moucnt		; Clear the frame counter
	move	#1,onoff	; Now set the animation flag
	bra.s	rdef5

rdef4:	bsr	open_file	; Try to open default mouse file
	bmi.s	no_def		; Error, assume file not found
	move	d0,fhandl	; Save handle
	move.l	#mouse_form,a5	; Read mouse data from file
	move.l	#74,d5
	bsr	read_file
	bsr	clos_file	; Close it

rdef5:	bsr	cpy_inst	; Copy it to the "installed" area
	bsr	frm_2_arr

	bsr	init_col	; Initialize the color indicators
	move	#1,insflg	; Set installed flag

no_def:	bsr	copy_mouse	; Initialize the undo buffer

	pea	save_vbv
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp

	tst.w	insflg		; Mouse installed?
	beq.s	evntms		; No, skip

	move	#1,vbi_on	; Turn on the vertical blank interrupt

evntms:	move.l	#e_mesg,aespb	; Wait for GEM to send us a message
	move.l	#mspipe,addrin
	bsr	aes

	cmp.w	#40,mspipe	; Is this an AC_OPEN message?
	bne	evntms		; No, go back
	move	mspipe+8,d0	; Is it for this accessory?
	cmp.w	menuid,d0
	bne	evntms		; No, go back

	move.l	#w_updt,aespb	; Call wind_update to block user actions
	move	#1,intin
	bsr	aes

	move	#2,-(sp)	; Get address of screen RAM
	trap	#14
	addq	#2,sp
	move.l	d0,screen	; Save it

	move	#$19,-(sp)	; Get current drive
	trap	#1
	addq	#2,sp
	move	d0,curdrv	; Save it

	clr.w	-(sp)		; Get current pathname
	move.l	#curpth,-(sp)
	move	#$47,-(sp)
	trap	#1
	addq	#8,sp

	move	#4,-(sp)	; Get current resolution
	trap	#14
	addq	#2,sp
	move.w	d0,res

	tst.w	d0		; Low res?
	bne	continue	; No, forge ahead

	bsr	open_window

	tst	d0
	bmi	alrtx1

	tst	onoff		; Animation on?
	bne.s	arroff		; Yes, turn off color change box
	tst.w	insflg		; Is a mouse installed?
	bne.s	arr_on		; Yes, skip ahead

arroff:	move	#DISABLED,locstt ; Disable the color change box
	move	#DISABLED,lodstt
	move	#DISABLED,loustt
	move	#DISABLED,losstt
	move.l	#blnkms,lovadr
	bra.s	dolbox		; And continue
arr_on:	move	#NORMAL,locstt	; Enable the color change box
	move	#NORMAL,lodstt
	move	#NORMAL,loustt
	move	#NORMAL,losstt
	tst	colflg
	bne.s	ao_1
	move.l	#dvalms,lovadr
	bra.s	dolbox
ao_1:	move.l	#mvalms,lovadr

dolbox:	move.l	#lowbox,addrin	; Draw the low res dialog box
	bsr	drawbx
	move	#1,diflag
loinpt:	bsr	formdo		; Get user input

	bclr	#7,intout	; Clear high bit in case of double-click
	cmp.w	#loinst,intout	; 'Install' button selected?
	bne	alrt0		; No, skip

	move	#NORMAL,loistt	; De-select it

	clr.w	adflag
	move.l	#dat_or_ani,a5	; Show alert box
	clr	d5
	bsr	alert
	cmp.w	#1,intout	; Animation file?
	bne.s	l_lo1
	move	#1,adflag
	bsr	fsl_aload
	bra.s	l_lo2
l_lo1:	bsr	fsl_dload	; Set up fsel strings
l_lo2:	bsr	fsel		; Go call the dreaded File Selector

	move.l	filadr,a0
	tst.b	(a0)		; Got a filename?
	beq	dolbox		; No, exit
	cmp.w	#1,intout+2	; OK button?
	bne	dolbox		; No, exit

	bsr	set_path	; Set drive and path

	move.l	filadr,a5	; Load the mouse cursor file
	bsr	open_file
	bmi	alrtx		; Error, bail out-ski
	move	d0,fhandl	; Save file handle

	tst	adflag
	beq.s	l_lo3
	bsr	chk_anfile
	tst.w	a_good
	beq.s	lo_a0
	move.l	#notani,a5
	move	#1,d5
	bsr	alert
	bsr	clos_file
	bra	alrtx
lo_a0:	moveq	#0,d0
	bsr	lseek	
	move.l	#mouse_array,a5
	move.l	#74*32,d5
	bsr	read_file
	move.l	#nframs,a5
	move.l	#2,d5
	bsr	read_file
	move.l	#delval,a5
	bsr	read_file
	bsr	clos_file
	move.w	#1,insflg
	move.w	#1,onoff
	move	#1,vbi_on	; Turn on the vertical blank interrupt
	bra	arroff
	
l_lo3:	move.l	#mouse_form,a5	; Read in the mouse
	move.l	#74,d5
	bsr	read_file
	bmi	alrtx
	bsr	clos_file	; Close the file

	bsr	cpy_inst	; Move it to 'installed' area
	bsr	chg_mouse	; Go change the mouse

	bsr	init_col	; Initialize the color counters
	move	#1,insflg	; Set installed flag
	clr.w	onoff

	move	#1,vbi_on	; Turn on the vertical blank interrupt
	bra	arr_on

alrt0:	cmp.w	#losvbt,intout	; Save?
	bne	alrt1

	move	#NORMAL,losstt	; De-select the button

	tst	onoff		; Animation on?
	beq.s	al0_0
	move	#losvbt,intin
	move.l	#lowbox,addrin
	bsr	objoff
	bra	loinpt

al0_0:	bsr	fsl_dsave	; Set up fsel text strings
	bsr	fsel

	tst.b	savfil		; Filename present?
	beq	dolbox		; Nope, exit
	cmp.w	#1,intout+2	; OK button?
	bne	dolbox		; No, must be 'Cancel'

	bsr	set_path	; Set the pathname from fsel's output
	move.l	#datext+3,a1
	bsr	chk_extension	; Add the .DAT extension (if none exists)

	bsr	sav_exist	; See if the file already exists
	bne.s	locrea		; It doesn't, skip ahead
	bsr	set_exist	; Move the filename to the alert box
lo_sho:	move.l	#exist,a5	; Show alert box
	move	#1,d5
	bsr	alert
	cmp.w	#1,intout	; Overwrite the file?
	bne	dolbox		; No, split
	move.l	#savfil,a0
	bsr	delete_file

locrea:	clr.w	-(sp)		; Create the data file
	pea	savfil
	move	#$3C,-(sp)
	trap	#1
	addq	#8,sp
	tst.w	d0
	bmi	dolbox
	move	d0,fhandl

	move.l	#m_form2,-(sp)	; Write the mouse buffer to the file
	move.l	#74,-(sp)
	move	fhandl,-(sp)
	move	#$40,-(sp)
	trap	#1
	add	#12,sp

	cmp.l	#74,d0
	beq.s	locr_1
	move.l	#dskful,a5
	move	#1,d5
	bsr	alert
	move.l	#savfil,a0
	bsr	delete_file

locr_1:	bsr	clos_file	; Close it
	bra	dolbox

alrt1:	cmp.w	#loremv,intout	; Remove?
	bne.s	alrt2		; No, skip
	clr	vbi_on		; Remove the vertical blank interrupt
	move.l	#g_mous,aespb	; And turn on the arrow
	clr.w	intin
	bsr	aes
	clr.w	insflg
	clr.w	onoff
	move	#NORMAL,lorstt	; De-select the button
	bra	alrtx

alrt2:	cmp.w	#lodown,intout	; Color down button?
	bne.s	alrt3		; No, hop over this code
	tst	insflg		; Installed?
	beq	loinpt		; No, go back
	tst	onoff
	bne	loinpt
	tst.w	colflg		; Which color are we changing?
	bne.s	lcd_1		; Must be the mask
	tst.w	m_form2+8	; Is this color zero already?
	beq	loinpt		; Yes, exit
	subq.w	#1,m_form2+8	; Decrement the color register value
	move.l	#dvalms,a5	; Address of data color text
	bra.s	lcd_2		; Skip over
lcd_1:	tst.w	m_form2+6	; Is it zero?
	beq	loinpt		; Yes, let's just forget about this
	subq.w	#1,m_form2+6	; Decrement it
	move.l	#mvalms,a5	; Address of mask color text
lcd_2:	move.l	#1,d5		; Two characters
	add.l	d5,a5		; Set pointer to 2nd character
ldloop:	cmp.b	#'0',(a5)	; Is it ASCII zero?
	bne.s	ldl2		; No, skip ahead
	move.b	#'9',(a5)	; Wrap it around to 9
	bra.s	ldl3
ldl2:	subq.b	#1,(a5)		; Decrement the letter
	bra.s	lodrw1
ldl3:	subq	#1,a5		; Set pointer to next place
	dbf	d5,ldloop	; Do the 2nd letter
	bra.s	lodrw1		; Go draw the text object

alrt3:	cmp.w	#loup,intout	; Color up button?
	bne	alrt4		; No, get out!
	tst	insflg		; Installed?
	beq	loinpt
	tst	onoff
	bne	loinpt
	tst.w	colflg		; The rest of this code is identical to
	bne.s	lcu_1		; the above section, except that it handles
	cmp.w	#15,m_form2+8	; incrementing the color value
	beq	loinpt
	addq.w	#1,m_form2+8
	move.l	#dvalms,a5
	bra.s	lcu_2
lcu_1:	cmp.w	#15,m_form2+6
	beq	loinpt
	addq.w	#1,m_form2+6
	move.l	#mvalms,a5
lcu_2:	move.l	#1,d5
	add.l	d5,a5
luloop:	cmp.b	#'9',(a5)
	bne.s	lul2
	move.b	#'0',(a5)
	bra.s	lul3
lul2:	addq.b	#1,(a5)
	bra.s	lodrw1
lul3:	subq	#1,a5
	dbf	d5,luloop
lodrw1:	bsr	chg_mouse	; Go change the mouse's color
lodraw:	move	#locval,intin	; Index of object to draw
	move.l	#lowbox,addrin	; Address of object tree
	bsr	objoff		; Go draw it
	bra	loinpt

alrt4:	cmp.w	#locolr,intout	; Data/Mask toggle?
	bne.s	alrtx		; No, skip
	tst	insflg
	beq	loinpt
	tst	onoff
	bne	loinpt
	eor.w	#1,colflg	; Toggle the flag
	tst.w	colflg		; Which one is it?
	beq.s	lsw_1		; It's data, skip ahead
	move.l	#mcolms,tinf10	; Set pointers to text in object tree
	move.l	#mvalms,lovadr
	bra.s	lsw_2
lsw_1:	move.l	#dcolms,tinf10
	move.l	#dvalms,lovadr
lsw_2:	move	#locolr,intin
	move.l	#lowbox,addrin
	bsr	objoff		; Go draw the object
	bra	lodraw

alrtx:	bsr	res_dpath	; Reset the drive and pathnames

	move	#NORMAL,loestt

	move	#3,intin
	bsr	dial

	move.l	#w_clos,aespb	; Close window so the application gets a
	move	whandl,intin	; redraw message
	bsr	aes
	move.l	#w_del,aespb	; Now delete the window
	bsr	aes

alrtx1:	move.l	#w_updt,aespb	; Allow user actions again
	clr.w	intin		; (Hah! Were they ever disabled???)
	bsr	aes

	clr.w	diflag

	bra	evntms		; Wait patiently for another message

* Subroutines for low-res dialog box (strange place for them, I know)

chg_mouse:
	move.l	#g_mous,aespb	; Change that mousey!
	move	#255,intin
	move.l	#m_form2,addrin
	bra	aes

fsl_dload:
	move.l	#i_load,txtadr	; Set up the 'Load' fsel text strings
	move	#il_len,itmlen
	move.l	#loddir,diradr
	move.l	#lodfil,filadr
	rts

fsl_aload:
	move.l	#i_aloa,txtadr
	move	#iallen,itmlen
	move.l	#loadir,diradr
	move.l	#loafil,filadr
	rts

fsl_dsave:
	move.l	#i_save,txtadr	; The 'Save' fsel text strings
	move	#is_len,itmlen
	move.l	#savdir,diradr
	move.l	#savfil,filadr
	rts

fsl_asave:
	move.l	#i_asav,txtadr
	move	#iaslen,itmlen
	move.l	#svadir,diradr
	move.l	#svafil,filadr
	rts

sav_exist:
	pea	dta		; Set DTA address
	move	#$1A,-(sp)
	trap	#1
	addq	#6,sp
	clr.w	-(sp)
	move.l	filadr,-(sp)
	move	#$4E,-(sp)	; Check to see if the file already exists
	trap	#1
	addq	#8,sp
	tst	d0		; Does it?
	rts

cpy_inst:
	move.l	#mouse_form,a0	; Copy mouse data to "installed" area
	move.l	#m_form2,a1
	move	#36,d5
cpyi1:	move	(a0)+,(a1)+
	dbf	d5,cpyi1
	rts

set_exist:
	move.l	#exname,a4	; Clear filename space in alert box
	move	#11,d5
sete1:	move.b	#' ',(a4)+
	dbf	d5,sete1
	move.l	filadr,a5	; Move filename into alert box
	move.l	#exname,a4
	move	#12,d5
sete2:	tst.b	(a5)
	beq.s	sete3
	move.b	(a5)+,(a4)+
	dbf	d5,sete2
sete3:	rts


* Here's where the editor code begins

continue:
	move.l	#contrl,a5
	move	#100,(a5)	; v_opnvwk (Open Virtual Workstation)
	clr.w	2(a5)
	move	#11,6(a5)
	move	ghandl,12(a5)	; Pass handle returned from graph_handle
	move.l	#intin,a4
	move.l	#9,d5
vwrklp:	move	#1,(a4)+
	dbf	d5,vwrklp
	move	#2,(a4)
	bsr	vdi1

	move	12(a5),vhandl	; Save VDI handle

	move	#35,(a5)	; Inquire current polyline attributes
	clr.w	2(a5)		; vql_attributes
	clr.w	6(a5)
	bsr	vdi

	move.l	#intout,a0
	move	(a0)+,l_type	; Save 'em
	move	(a0)+,l_colr
	move	(a0)+,d_mode
	move	(a0)+,l_strt
	move	(a0)+,l_end
	move	ptsout,l_wid

	move	#37,(a5)	; Inquire current fill attributes
	clr.w	2(a5)		; vqf_attributes
	clr.w	6(a5)
	bsr	vdi

	move.l	#intout,a0
	move	(a0)+,f_type	; Save these attributes too
	move	(a0)+,f_colr
	move	(a0)+,f_patt

	bsr	exch_button	; Set the button routine to an rts

*	move.l	#intout,a5
*	move.l	2(a5),wx	; Dialog box centered coordinates
*	move.l	6(a5),ww
*	subq.w	#2,wx		; Compensate for the shadow
*	subq.w	#2,wy
*	addq.w	#4,ww
*	addq.w	#4,wh

	bsr	open_window

	tst	d0
	beq.s	box	
	move.l	#w_updt,aespb
	clr.w	intin
	bsr	aes
	bra	ex2

box:	move.l	#editbx,addrin
	bsr	drawbx		; Draw the dialog box
	move	#1,diflag

	dc.w	$A00A		; Hide mouse

	move	#1,intin	; Replace
	bsr	write_mode

	move	#1,intin	; Black lines
	bsr	poly_color

	move	#1,intin	; Ordinary straight lines
	bsr	poly_type

	move	#1,ptsin	; One pixel wide
	clr.w	ptsin+2
	bsr	poly_width

	clr.l	intin		; Normal, squared ends
	bsr	poly_ends

	move	#2,intin	; Set fill style to dots
	bsr	vsf_interior

	move	#16,d4		; Loop counter
	move.l	#ptsin,a4	; Keep address of ptsin array in a4
	move	#2,pt_num	; Just two points

grid1:	move	#50,(a4)	; Draw the editing grids
	move	d4,d0
	mulu	y_div,d0
	add.w	y_off,d0
	move	d0,2(a4)
	move	#210,4(a4)
	move	d4,d0
	mulu	y_div,d0
	add.w	y_off,d0
	move	d0,6(a4)
	bsr	polyline

	move	#250,(a4)
	move	d4,d0
	mulu	y_div,d0
	add.w	y_off,d0
	move	d0,2(a4)
	move	#410,4(a4)
	move	d4,d0
	mulu	y_div,d0
	add.w	y_off,d0
	move	d0,6(a4)
	bsr	polyline

	move	d4,d0
	mulu	#10,d0
	add.w	#50,d0
	move	d0,(a4)
	move	y_off,2(a4)
	move	d4,d0
	mulu	#10,d0
	add.w	#50,d0
	move	d0,4(a4)
	move	y_bot,6(a4)
	bsr	polyline

	move	d4,d0
	mulu	#10,d0
	add.w	#250,d0
	move	d0,(a4)
	move	y_off,2(a4)
	move	d4,d0
	mulu	#10,d0
	add.w	#250,d0
	move	d0,4(a4)
	move	y_bot,6(a4)
	bsr	polyline

	dbf	d4,grid1

	move	#434,(a4)	; Draw the mouse-change rectangle
	move	y_off,2(a4)
	move	#516,4(a4)
	move	y_off,6(a4)
	move	#516,8(a4)
	move	chang1,10(a4)
	move	#434,12(a4)
	move	chang1,14(a4)
	move	#434,16(a4)
	move	y_off,18(a4)
	move	#5,pt_num
	bsr	polyline

	move	#1,intin
	bsr	vsf_color
	move	#8,intin
	bsr	vsf_style

	move.l	#contrl,a5
	move	#114,(a5)
	move	#2,2(a5)
	clr.w	6(a5)
	move	#434,ptsin	; Fill the top half of the mouse-change
	move	y_off,ptsin+2	; rectangle
	move	#516,ptsin+4
	move	chang2,ptsin+6
	bsr	vdi

	bsr	show_mouse	; Oh, there's that little mousey!

	clr.w	m_flag		; Clear mouse-change flag
	bsr	map_grid	; Go map the shape
	clr.w	d_flag		; Clear the drawing flag

the_big_loop:
	bsr	sample_mouse	; Let's see what's happening

	move.b	intout+1,butsav	; Save button status
	move.l	ptsout,mousex	; and X and Y coordinates

	move.l	#o_cfnd,aespb	; objc_find --- get the index number of the
	move.l	#intin,a0	; object under the mouse cursor
	move.l	#$00000005,(a0)+
	move.l	mousex,(a0)+
	move.l	#editbx,addrin
	bsr	aes

	move	intout,d5
	move.l	#ob_inx,a0
	sub.w	d0,d0
ck_obs:	cmp.w	(a0)+,d5	; Compare it with the active object list
	beq.s	gotobj		; Got one!
	addq.w	#1,d0		; Increment counter
	cmp.w	#oi_len,d0	; Done?
	bne	ck_obs		; No, do the rest
	bra	ckchng		; If we get here, we're not over an active object

gotobj:	move	d0,numrtn	; Save index into routines
	move	d5,o_indx	; Save object index
	move.l	#o_coff,aespb	; Get coordinates of object we're over
	move	d5,intin
	move.l	#editbx,addrin
	bsr	aes
	move.l	intout+2,x_obj1	; Save X and Y coordinates
	move	intout+2,d0
	move	intout+4,d1
	moveq	#0,d4
	move	o_indx,d4
	mulu	#24,d4
	add.l	#editbx,d4
	move.l	d4,a0		; a0 -> address of object in tree

	move.l	d4,o_asav
	add.w	20(a0),d0	; Compute diagonal opposite point of the box
	add.w	22(a0),d1	; by adding the width and height to the
	move	d0,x_obj2	; X and Y
	move	d1,y_obj2
	move.l	20(a0),w_obj	; Save width and height

	move	#0,butflg	; Clear button flag

ob_loop:
	bsr	sample_mouse	; Where am I? (said the amnesia victim)
	move	ptsout,d0	; Get current X coordinate
	cmp.w	x_obj1,d0	; Check to see if we're still over the
	blt	ortn_exit	; same object; if not, exit
	cmp.w	x_obj2,d0
	bgt	ortn_exit
	move	ptsout+2,d0
	cmp.w	y_obj1,d0
	blt	ortn_exit
	cmp.w	y_obj2,d0
	bgt	ortn_exit

	btst	#0,intout+1	; Pressing the left button?
	bne.s	ol1_2		; Yes, go ahead
	btst	#1,intout+1	; Right button?
	beq	ob_loop		; No, go back

ol1_2:	move	#1,butflg	; Yes, set the button flag

	move.w	o_indx,d0
	cmp.w	#cdowbt,d0
	beq.s	oloop2
	cmp.w	#cupbt,d0
	beq.s	oloop2
	cmp.w	#colttl,d0
	beq.s	oloop2
	cmp.w	#frmttl,d0
	beq.s	oloop2
	cmp.w	#frdown,d0
	beq.s	oloop2
	cmp.w	#frup,d0
	beq.s	oloop2
	cmp.w	#anonof,d0
	beq.s	oloop2
	move.l	o_asav,a0	; Address of object in tree
	or.w	#SELECTED,10(a0) ; Turn it on, dead man
	bsr	obdraw		; And draw it

oloop2:	bsr	sample_mouse	; Where am I now?

	move.w	o_indx,d0
	cmp.w	#frdown,d0
	beq.s	ol2_2
	cmp.w	#frup,d0
	beq.s	ol2_2

	btst	#0,intout+1	; Still pressing the button?
	bne	oloop2		; Yes, loop
	btst	#1,intout+1
	bne	oloop2
ol2_2:	move	ptsout,d0	; OK, we let go of the button. Now let's
	cmp.w	x_obj1,d0	; check to see whether we're still over
	blt.s	go_oex		; the same object; if not, exit
	cmp.w	x_obj2,d0
	bgt.s	go_oex
	move	ptsout+2,d0
	cmp.w	y_obj1,d0
	blt.s	go_oex
	cmp.w	y_obj2,d0
	ble.s	oloop3
go_oex:	move	#-1,numrtn
	bra	ortn_exit

oloop3:	moveq	#0,d0
	move	numrtn,d0	; Get index into address table
	lsl.w	#2,d0		; Multiply by 4 (to adjust for longwords)
	add.l	#rtn_table,d0	; Add start of table
	move.l	d0,a5		; Move it to a place where it can do some good
	move.l	(a5),a5		; Get routine address into a5
	jmp	(a5)		; And jump to it!

* Object-related routines

save:
	clr.w	adflag
	bsr	repl_button
	move.l	#dat_or_ani,a5	; Show alert box
	clr	d5
	bsr	alert
	bsr	exch_button
	cmp.w	#1,intout	; Animation file?
	bne.s	sv1
	move	#1,adflag	; Set flag
	bsr	fsl_asave
	bra.s	sv2

sv1:	bsr	fsl_dsave	; Set fsel parameters
sv2:	bsr	repl_button	; Restore the button vector
	bsr	fsel		; Call the dreaded File Selector
	bsr	exch_button	; Point button vector to an RTS again

	move.l	filadr,a0
	tst.b	(a0)		; Got a filename?
	beq	ortn_exit
	cmp.w	#1,intout+2	; OK button?
	bne	ortn_exit

	bsr	set_path	; Set pathname
	tst	adflag
	beq.s	sv3
	move.l	#aniext+3,a1
	bra.s	sv4
sv3:	move.l	#datext+3,a1
sv4:	bsr	chk_extension	; Check for extension

	bsr	sav_exist	; Does the file already exist?
	bne.s	create		; No, continue

	bsr	set_exist	; Copy the name into the alert box

sho_al:	bsr	repl_button	; Replace the system button routine vector

	move.l	#exist,a5	; Show alert box
	move	#1,d5
	bsr	alert

	bsr	exch_button	; Turn off the button routine again

	cmp.w	#1,intout	; Yes button?
	bne	sav_x		; No, exit

	move.l	filadr,a0
	bsr	delete_file

create:	clr.w	-(sp)		; Create the data file
	move.l	filadr,-(sp)
	move	#$3C,-(sp)
	trap	#1
	addq	#8,sp
	tst.w	d0
	bmi	sav_x
	move	d0,fhandl

	tst	adflag
	beq.s	sv5
	move.l	#mouse_array,-(sp)
	move.l	#74*32,d5
	bra.s	sv6
sv5:	move.l	#mouse_form,-(sp) ; Write the mouse data to the file
	move.l	#74,d5
sv6:	move.l	d5,-(sp)
	move	fhandl,-(sp)
	move	#$40,-(sp)
	trap	#1
	add	#12,sp

	cmp.l	d5,d0
	beq.s	sv7
full:	bsr	repl_button
	move.l	#dskful,a5
	move	#1,d5
	bsr	alert
	bsr	exch_button
	move.l	filadr,a0
	bsr	delete_file
	bra.s	sv8

sv7:	tst	adflag		; Data or animation?
	beq.s	sv8		; Data, skip
	move.l	#nframs,-(sp)	; Save number of frames and delay value
	move.l	#2,-(sp)
	move	fhandl,-(sp)
	move	#$40,-(sp)
	trap	#1
	add	#12,sp
	cmp.l	#2,d0
	bne	full

	move.l	#delval,-(sp)
	move.l	#2,-(sp)
	move	fhandl,-(sp)
	move	#$40,-(sp)
	trap	#1
	add	#12,sp
	cmp.l	#2,d0
	bne	full

sv8:	bsr	clos_file	; Close it nice and tight
sav_x:	bra	ortn_exit

load:
	clr.w	adflag
	bsr	repl_button
	move.l	#dat_or_ani,a5	; Show alert box
	clr	d5
	bsr	alert
	bsr	exch_button
	cmp.w	#1,intout	; Animation file?
	bne.s	lo1
	move	#1,adflag
	bsr	fsl_aload
	bra.s	lo2

lo1:	bsr	fsl_dload	; Same old fsel stuff as everywhere else
lo2:	bsr	repl_button
	bsr	fsel
	bsr	exch_button

	move.l	filadr,a0
	tst.b	(a0)		; Filename?
	beq	ortn_exit
	cmp.w	#1,intout+2	; OK button?
	bne	ortn_exit

	bsr	set_path

	move.l	filadr,a5
	bsr	open_file
	bmi	lod_x2
	move	d0,fhandl

	tst	adflag
	beq.s	lo3

	bsr	chk_anfile
	tst.w	a_good
	beq.s	lo2_2

lo2_1:	bsr	repl_button
	move.l	#notani,a5
	move	#1,d5
	bsr	alert
	bsr	exch_button
	bra.s	lod_x

lo2_2:	moveq	#0,d0
	bsr.s	lseek	
	move.l	#mouse_array,a5
	move.l	#74*32,d5
	bsr	read_file
	bmi.s	lod_x
	move.l	#nframs,a5
	move.l	#2,d5
	bsr	read_file
	move.l	#delval,a5
	bsr	read_file
	bsr	clos_file
	clr.w	franum
	move.b	#'0',frvlms
	move.b	#'1',frvlms+1
	bsr	arr_2_frm
	bsr	init_nfrm
	bra.s	lo4

lo3:	move.l	#mouse_form,a5	; Read in the mouse data
	move.l	#74,d5
	bsr	read_file
	bmi.s	lod_x

lo4:	bsr	copy_mouse	; Copy to undo buffer
	bsr	init_col	; Initialize color indicators

lod_x:	bsr	clos_file
lod_x2:	bra	ortn_exit

lseek:	move	#0,-(sp)
	move.w	fhandl,-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add	#10,sp
	tst.l	d0
	rts

clr_mask:
	bsr	copy_mouse	; Save in undo buffer
	move.l	#m_mask,a5	; Address of mask
	bra.s	clr2

clr_data:
	bsr	copy_mouse	; Save mouse
	move.l	#m_image,a5	; Address of data
clr2:	move	#7,d5		; 8 longwords (16 words)
clrd1:	clr.l	(a5)+		; Clear that mouse!
	dbf	d5,clrd1
	bsr	map_grid	; Draw it on the grid
	bra	ortn_exit

inv_data:
	bsr	copy_mouse
	move.l	#m_image,a5
	bra.s	inv2

inv_mask:
	bsr	copy_mouse
	move.l	#m_mask,a5
inv2:	move	#15,d5		; 16 words
invm1:	eor.w	#$FFFF,(a5)+	; Invert every bit in each word
	dbf	d5,invm1
	bsr	map_grid	; Draw it on the grid
	bra	ortn_exit

mir_data:
	bsr	copy_mouse
	move.l	#m_image,a5
	bra.s	mir2

mir_mask:
	bsr	copy_mouse
	move.l	#m_mask,a5
mir2:	move	#15,d5		; 16 words of mouse data
mir3:	move	#15,d4		; 16 bits in each word
	clr.w	d1		; Clear work register
	move	(a5),d0		; Get the word
mirm1:	lsl	d0		; Shift a bit left
	roxr	d1		; Roll it right into the work register
	dbf	d4,mirm1	; Do all 16 bits
	move	d1,(a5)+	; Put it back
	dbf	d5,mir3		; Do all 16 words
	bsr	map_grid	; Draw the grid
	bra	ortn_exit

rotate:
	bsr	copy_mouse	; Save in undo buffer
	move.l	#m_rotate,a5	; Address of rotation buffer
	move	#15,d5
r_clr:	clr.l	(a5)+		; First, clear out the rotation buffer
	dbf	d5,r_clr
	move.l	#m_mask+30,a4	; Start at end of data
	move.l	#m_rotate,a5
r_lp1:	move	#15,d4		; 16 words
wordlp:	move	(a4),d2		; Get a word
	move	#15,d5		; 16 bits per word
bitloo:	move	d5,d3		; Get bit number
	lsl	d3		; Multiply by 2 (for word offset)
	move	0(a5,d3),d1	; Get word from rotation buffer
	lsr	d2		; Shift a bit right
	roxl	d1		; Roll it left into d1
	move	d1,0(a5,d3)	; Put this new word back
	dbf	d5,bitloo	; Do all 16 bits
	subq.w	#2,a4		; Point to next data word
	dbf	d4,wordlp	; Do all 16 words
	cmp.l	#m_mask-2,a4	; We're rotating both mask and data together
	bne.s	r_cpy1		; All done, skip ahead
	move.l	#m_mask+62,a4	; Set address of mask
	move.l	#m_rotate+32,a5
	bra	r_lp1		; Go finish the job

r_cpy1:	move.l	#m_mask,a4
	move.l	#m_rotate,a5
	move	#15,d5
r_cpy:	move.l	(a5)+,(a4)+	; Move the mouse data from the rotation buffer
	dbf	d5,r_cpy
	bsr	map_grid	; Draw the grid
	bra	ortn_exit

up:
	bsr	copy_mouse	; Scroll mouse image up
	move.l	#m_image,a5	; First, the data
	move	(a5),temp	; Save top word
	move	#14,d5
up1:	move	2(a5),(a5)+	; Move 'em up
	dbf	d5,up1
	move	temp,(a5)	; Put the top line in at the bottom
	move.l	#m_mask,a5	; Now do the mask
	move	(a5),temp
	move	#14,d5
up2:	move	2(a5),(a5)+	; Get on up!
	dbf	d5,up2
	move	temp,(a5)
	bsr	map_grid	; Draw the grid
	bra	ortn_exit

left:
	bsr	copy_mouse	; Scroll mouse form left
	move.l	#m_mask,a5
	move	#31,d5
left1:	lsl	(a5)+		; Shift a bit left
	bcc.s	left2		; This bit wasn't set, skip ahead
	or.w	#1,-2(a5)	; Set rightmost bit
left2:	dbf	d5,left1
	bsr	map_grid
	bra	ortn_exit

down:
	bsr	copy_mouse	; Scroll mouse shape down
	move.l	#m_image+30,a5	; First, the data
	move	(a5),temp	; Save bottom word
	move	#14,d5
down1:	move	-2(a5),(a5)	; Get down!
	subq	#2,a5
	dbf	d5,down1
	move	temp,(a5)	; Put bottom word at the top
	move.l	#m_mask+30,a5	; Now do the same for the mask
	move	(a5),temp
	move	#14,d5
down2:	move	-2(a5),(a5)
	subq	#2,a5
	dbf	d5,down2
	move	temp,(a5)
	bsr	map_grid
	bra	ortn_exit

right:
	bsr	copy_mouse	; Scroll mouse image right
	move.l	#m_mask,a5
	move	#31,d5
right1:	lsr	(a5)+		; Shift a bit
	bcc.s	right2		; It wasn't set, skip
	or.w	#$8000,-2(a5)	; Set leftmost bit in this word
right2:	dbf	d5,right1
	bsr	map_grid
	bra	ortn_exit

install:
	move.l	#m_mask,a5	; Don't let 'em install a blank mouse!
	move	#15,d5
ck_i1:	tst.l	(a5)+
	bne.s	inst1
	dbf	d5,ck_i1
	bra.s	instx
inst1:	bsr	cpy_inst	; Copy mouse to 'Installed' area
	move.l	#g_mous,aespb	; AES graf_mouse call to set the new image
	move	#255,intin
	move.l	#m_form2,addrin
	bsr	aes
	move	#1,insflg	; Set installed flag
	move	#1,vbi_on	; Turn on the vertical blank interrupt
instx:	bra	ortn_exit

remove:
	clr.w	insflg		; Clear installed flag
	clr.w	vbi_on		; Remove vertical blank routine

	move.l	#g_mous,aespb	; Set the arrow cursor
	clr.w	intin
	bsr	aes
	bra	ortn_exit

undo:
	bsr	res_mouse	; Restore mouse data from the undo buffer
	bsr	map_grid	; Draw it on the grid
	bra	ortn_exit

colr_down:
	tst.w	colflg		; Which color? Data or mask?
	bne.s	cd_1		; Must be the mask color, skip ahead
	tst.w	bg_col		; Is it zero already?
	beq	ortn_exit	; Yes, bail
	subq.w	#1,bg_col	; Decrement it
	move.l	#dvalms,a5	; Address of color value text
	bra.s	cd_2		; Skip
cd_1:	tst.w	fg_col		; Zero already?
	beq	ortn_exit	; Yes, forget it
	subq.w	#1,fg_col	; Decrement it
	move.l	#mvalms,a5	; Address of color value text
cd_2:	move.l	#1,d5		; Two digits
	add.l	d5,a5		; Set pointer 2nd digit (ones place)
dnloop:	cmp.b	#'0',(a5)	; Is it ASCII zero?
	bne.s	dnl2		; No, skip ahead
	move.b	#'9',(a5)	; Put a '9' here
	bra.s	dnl3
dnl2:	subq.b	#1,(a5)		; Decrement the ASCII number
	bra.s	valdrw		; Go draw it
dnl3:	subq	#1,a5		; Move pointer to tens digit
	dbf	d5,dnloop
	bra.s	valdrw

colr_up:
	tst.w	colflg		; This code does the same thing as the section
	bne.s	cu_1		; above, but for color-up adjustments
	cmp.w	#15,bg_col
	beq	ortn_exit
	addq.w	#1,bg_col
	move.l	#dvalms,a5
	bra.s	cu_2
cu_1:	cmp.w	#15,fg_col
	beq	ortn_exit
	addq.w	#1,fg_col
	move.l	#mvalms,a5
cu_2:	move.l	#1,d5
	add.l	d5,a5
uploop:	cmp.b	#'9',(a5)
	bne.s	upl2
	move.b	#'0',(a5)
	bra.s	upl3
upl2:	addq.b	#1,(a5)
	bra.s	valdrw
upl3:	subq	#1,a5
	dbf	d5,uploop
valdrw:	move	#colval,intin	; Object index of the color value text
	move.l	#editbx,addrin	; Address of object tree
	bsr	objoff		; Go draw this text object
	bra	ortn_exit

sw_fgbg:
	eor.w	#1,colflg	; Toggle color flag
	tst.w	colflg		; Which color, mask or data?
	beq.s	sw_1		; 0=data, 1=mask
	move.l	#mcolms,tinf3	; Set pointers to text strings
	move.l	#mvalms,valadr
	bra.s	sw_2
sw_1:	move.l	#dcolms,tinf3
	move.l	#dvalms,valadr
sw_2:	move	#colttl,intin	; And go draw the object
	move.l	#editbx,addrin
	bsr	objoff
	bra	valdrw

sw_anttl:
	addq.w	#1,antflg	; Increment flag
	move.w	antflg,d0
	cmp.w	#3,d0		; Greater than 2?
	bne.s	swa_1
	sub.w	d0,d0		; Back to zero
	move.w	d0,antflg
swa_1:	tst	d0		; 0=Frame, 1=# of Frames, 2=Speed
	bne.s	swa_2
	move.l	#framms,tinf4
	move.l	#frvlms,anival
	bra.s	swa_4
swa_2:	cmp.w	#1,d0
	bne.s	swa_3
	move.l	#frmnms,tinf4
	move.l	#fnvlms,anival
	bra.s	swa_4
swa_3:	move.l	#speems,tinf4
	move.l	#spvlms,anival
swa_4:	move.w	#frmttl,intin
	move.l	#editbx,addrin
	bsr	objoff
	move.w	#frmval,intin
	move.l	#editbx,addrin
	bsr	objoff
	bra	ortn_exit

ani_down:
	tst	antflg		; Are we changing the frame?
	bne.s	anid_2		; No, skip ahead
	bsr	chk_shift
	bsr	frm_2_arr	; Copy current frame to sequence array
	tst	franum		; Is it zero already?
	bne.s	d_fnum
	move.b	#'3',frvlms
	move.b	#'2',frvlms+1
	move.w	#31,franum
	bra	fvaldr
d_fnum:	subq.w	#1,franum
	move.l	#frvlms,a5
	bra.s	ad_1
anid_2:	cmp.w	#1,antflg	; Changing # of Frames?
	bne.s	anid_3
	cmp.w	#1,nframs
	bne.s	d_nfrm
	move.b	#'3',fnvlms
	move.b	#'2',fnvlms+1
	move.w	#32,nframs
	bra.s	fvaldr
d_nfrm:	subq.w	#1,nframs
	move.l	#fnvlms,a5
	bra.s	ad_1
anid_3:	tst	delval		; Must be changing the delay value
	bne.s	d_delv
	move.b	#'9',spvlms
	move.b	#'9',spvlms+1
	move.w	#99,delval
	bra.s	fvaldr
d_delv:	subq.w	#1,delval
	move.l	#spvlms,a5
ad_1:	move.l	#1,d5
	add.l	d5,a5
adloop:	cmp.b	#'0',(a5)	; Is it ASCII zero?
	bne.s	adl2
	move.b	#'9',(a5)
	bra.s	adl3
adl2:	subq.b	#1,(a5)		; Decrement the ASCII number
	bra.s	fvaldr
adl3:	subq	#1,a5		; Move pointer to tens digit
	dbf	d5,adloop
fvaldr:	move.w	#frmval,intin
	move.l	#editbx,addrin
	bsr	objoff
	tst	antflg		; Changing current frame?
	beq.s	fvald1		; Yes, skip
	move	#7,d5
waitnd:	move.w	#37,-(sp)	; Wait 6 vertical blanks
	trap	#14		; (in case button is being held)
	addq	#2,sp
	dbf	d5,waitnd
	bra	ortn_exit
fvald1:	tst	shfflg		; Were we holding shift (copying)?
	beq.s	fvald2		; No, skip
	bsr	frm_2_arr	; Copy mouse form to new array position
fvald2:	bsr	arr_2_frm	; Copy it back (dumb)
	bsr	init_col
	move.w	#colval,intin
	move.l	#editbx,addrin
	bsr	objoff
	bsr	map_grid
fvex:	bra	ortn_exit

ani_up:
	tst	antflg
	bne.s	aniu_2
	bsr	chk_shift
	bsr	frm_2_arr
	cmp.w	#31,franum
	bne.s	i_fnum
	move.b	#'0',frvlms
	move.b	#'1',frvlms+1
	clr.w	franum
	bra	fvaldr
i_fnum:	addq.w	#1,franum
	move.l	#frvlms,a5
	bra.s	au_1
aniu_2:	cmp.w	#1,antflg
	bne.s	aniu_3
	cmp.w	#32,nframs
	bne.s	i_nfrm
	move.b	#'0',fnvlms
	move.b	#'1',fnvlms+1
	move.w	#1,nframs
	bra	fvaldr
i_nfrm:	addq.w	#1,nframs
	move.l	#fnvlms,a5
	bra.s	au_1
aniu_3:	cmp.w	#99,delval
	bne.s	i_delv
	move.b	#'0',spvlms
	move.b	#'0',spvlms+1
	clr.w	delval
	bra	fvaldr
i_delv:	addq.w	#1,delval
	move.l	#spvlms,a5
au_1:	move.l	#1,d5
	add.l	d5,a5
auloop:	cmp.b	#'9',(a5)
	bne.s	aul2
	move.b	#'0',(a5)
	bra.s	aul3
aul2:	addq.b	#1,(a5)
	bra	fvaldr
aul3:	subq	#1,a5
	dbf	d5,auloop
	bra	fvaldr

* Subroutines for ani_up and ani_down

chk_shift:
	clr.w	shfflg
	move.w	#-1,-(sp)	; Get Alt/Shift/Control status
	move.w	#11,-(sp)
	trap	#13
	addq	#4,sp
	btst	#0,d0		; Right shift key?
	bne.s	shift1
	btst	#1,d0		; Left shift key?
	beq.s	shift2
shift1:	move	#1,shfflg
shift2:	rts

frm_2_arr:
	bsr.s	set_faadr
cpyfr1:	move.l	(a1)+,(a0)+
	dbf	d0,cpyfr1
	move.w	(a1),(a0)	; Move last word to make it 74
	rts

arr_2_frm:
	bsr.s	set_faadr
cpyar1:	move.l	(a0)+,(a1)+
	dbf	d0,cpyar1
	move.w	(a0),(a1)
	bra	copy_mouse

set_faadr:
	move.l	#mouse_array,a0	; Address of animation array
	moveq	#0,d0		; Clear work register
	move.w	franum,d0	; Get current frame number
	mulu	#74,d0		; Multiply by 74 (74 bytes per mouse)
	add.l	d0,a0		; Add index to pointer
	move.w	#17,d0
	move.l	#mouse_form,a1
	rts

clear_array:
	move.l	#mouse_array,a0
	move	#591,d0
cla_1:	clr.l	(a0)+
	dbf	d0,cla_1
	rts

ani_onoff:
	tst	onoff		; Is animation on or off?
	bne.s	anio_2		; It's on, skip ahead
	bsr	frm_2_arr	; Copy current frame to animation buffer
	move.l	#anonms,tinf5	; Set "Animation ON" message
	move.w	delval,vbtimr	; Set the vertical blank timer
	clr.w	moucnt		; Clear the frame counter
	move	#1,onoff	; Now set the animation flag
	bra.s	anio_3
anio_2:	move.l	#anofms,tinf5	; Set "Animation OFF" message
	clr.w	moucnt		; Clear the frame counter
	clr.w	onoff		; Clear the animation flag
	tst	insflg		; Are we installed?
	beq.s	anio_3		; No, skip ahead
	move.l	#g_mous,aespb	; Set mouse form back to installed shape
	move	#255,intin
	move.l	#m_form2,addrin
	bsr	aes

anio_3:	move.w	#anonof,intin	; Re-draw the ON/OFF message box
	move.l	#editbx,addrin
	bsr	objoff
*	bra.s	ortn_exit

* All object routines exit through here

ortn_exit:
	tst.w	butflg
	beq	the_big_loop

	move.w	o_indx,d0
	cmp.w	#cdowbt,d0	; If it was 'down', 'up', or color selection,
	beq	the_big_loop	; loop back right away
	cmp.w	#cupbt,d0
	beq	the_big_loop
	cmp.w	#colttl,d0
	beq	the_big_loop
	cmp.w	#frmttl,d0
	beq	the_big_loop
	cmp.w	#frdown,d0
	beq	the_big_loop
	cmp.w	#frup,d0
	beq	the_big_loop
	cmp.w	#anonof,d0
	beq	the_big_loop

	move.l	o_asav,a0	; Get address of object that was selected
	and.w	#$FFFE,10(a0)	; De-select it
	tst.w	numrtn		; If it was 'Save' or 'Load', go back to
	beq	box		; the dialog box drawing code
	cmp.w	#1,numrtn
	beq	box
	bsr	obdraw		; Go re-draw the object
	bra	the_big_loop	; Back to the top of the loop

ckchng:	cmp.w	#434,mousex	; Check to see if we're inside the
	blt.s	ckbutt		; mouse-change rectangle
	cmp.w	#515,mousex
	bgt.s	ckbutt
	move	mousey,d0
	cmp.w	y_off,d0
	blt.s	ckbutt
	cmp.w	chang1,d0
	bgt.s	ckbutt
	tst.w	m_flag		; Were we already in here?
	bne	the_big_loop	; Yes! Go back
	move.l	#m_mask,a0
	move	#15,d0
ck_img:	tst.l	(a0)+		; If the mouse data is all zeros, don't
	bne.s	setmou		; change it
	dbf	d0,ck_img
	bra	the_big_loop
setmou:	clr.w	vbi_on		; Turn off the interrupt while we're here
	move	#1,m_flag	; Set the flag
	move.l	#g_mous,aespb	; Change the mouse form
	move	#255,intin
	move.l	#mouse_form,addrin
	bsr	aes
	bra	the_big_loop

ckbutt:	tst.w	m_flag		; Just leaving the mouse-change rectangle?
	beq.s	ckb2		; No, skip
	move.l	#g_mous,aespb
	move	#255,intin
	tst.w	insflg		; Mouse form installed?
	bne.s	ckbu1		; Yes, skip
	clr.w	intin
	bra.s	arr2
ckbu1:	move	#1,vbi_on
	tst	onoff
	beq.s	ckbu2
	bsr	which_mouse
	move.l	a3,addrin
	bra.s	arr2
ckbu2:	move.l	#m_form2,addrin
arr2:	bsr	aes
	clr.w	m_flag

ckb2:	btst	#0,butsav	; Left button pressed?
	bne.s	ckpos		; Yes, go check position
	btst	#1,butsav	; Right button?
	bne.s	ckpos
	tst.w	d_flag		; Were we just drawing?
	beq	the_big_loop	; No, forget it
	clr.w	d_flag		; Clear the flag
	bra	the_big_loop

ckpos:	tst.w	d_flag		; OK, we're drawing - is the draw flag set?
	bne.s	ckp1		; Yes, so skip ahead
	bsr	copy_mouse	; Copy mouse shape to undo buffer
	move	#1,d_flag	; Set draw flag
ckp1:	move	mousey,d0	; Get Y position
	cmp.w	y_off,d0	; Is mouse Y >= 100/50?
	blt	the_big_loop
	cmp.w	y_bot,d0	; Is it < 260/130?
	bge	the_big_loop

	bsr	inquire		; Go see which grid is being drawn on
	bra	the_big_loop	; And back to the top

exit:	move	d_mode,intin	; Reset all the polyline and fill
	bsr	write_mode	; attributes
	move	l_colr,intin
	bsr	poly_color
	move	l_type,intin
	bsr	poly_type
	move	l_wid,ptsin
	clr.w	ptsin+2
	bsr	poly_width
	move	l_strt,intin
	move	l_end,intin+2
	bsr	poly_ends
	move	f_type,intin
	bsr	vsf_interior
	move	f_colr,intin
	bsr	vsf_color
	move	f_patt,intin
	bsr	vsf_style

	move	#3,intin	; Release dialog box memory
	bsr	dial

	move.l	#w_clos,aespb	; Close window so the application gets a
	move	whandl,intin	; redraw message
	bsr	aes
	move.l	#w_del,aespb	; Now delete the window
	bsr	aes

	move.l	#w_updt,aespb	; Allow messages again
	clr.w	intin
	bsr	aes

ex2:	bsr	repl_button	; Replace the system button vector

	move	#101,(a5)	; v_clsvwk (Close Virtual Workstation)
	clr.w	2(a5)
	clr.w	6(a5)
	bsr	vdi

	bsr	res_dpath	; Reset drive and pathname

	and.w	#$FFFE,extstt	; Reset EXIT button

	clr	diflag

	bra	evntms		; Go back and wait for another message!


* Subroutines

inquire:
	move	#0,hotflg	; Clear hotspot flag

	cmp.w	#50,mousex	; Are we inside the data grid?
	blt	inq_return	; No, exit
	cmp.w	#209,mousex
	bge	inq_2		; Go check to see if we're over the mask grid

	moveq	#0,d0		; Clear work register
	move	mousex,d0	; Get mouse X position
	sub.w	#50,d0		; The data grid starts 50 pixels from the left
	divu	#10,d0		; Divide by 10 to get cell X
	bvc.s	storx		; No overflow, skip
	sub.w	d0,d0		; Set it to zero
storx:	move	d0,x		; Set X array index
	moveq	#0,d0		; Clear register
	move	mousey,d0	; Get mouse Y position
	sub.w	y_off,d0	; Subtract res-dependent offset value
	divu	y_div,d0	; Divide by res-dependent Y divisor
	bvc.s	story		; No overflow, skip
	sub.w	d0,d0		; Clear it
story:	move	d0,y		; Set Y array index

	btst	#0,butsav	; Was the left button pressed?
	beq.s	eras_1		; No, go to the erase routine
	btst	#1,butsav	; Right button?
	beq.s	inq1_1		; No, skip
do_hot:	bsr	sample_mouse	; Read mouse status
	btst	#0,intout+1	; Still pressing the left button?
	bne	do_hot		; Yes, loop
	btst	#1,intout+1	; Still pressing right?
	bne	do_hot		; Yes, loop
	move.l	x,temp		; Save current x index
	move.l	x_hot,x		; Set x index to hotspot position
	move	#1,hotflg	; Set hotspot flag
	dc.w	$A00A		; Hide the mouse
	bsr	draw_pixel	; Go draw the hotspot
	bsr	show_mouse	; Show the mouse
	move.l	temp,x_hot	; Replace x position
	bsr	set_hotspot
	rts

inq1_1:	move.w	#-1,-(sp)
	move.w	#11,-(sp)
	trap	#13
	addq	#4,sp
	btst	#2,d0		; Control key pressed?
	bne	do_hot		; Yes, do the hot spot
	bsr	get_iptr	; Get pointer to element of data array
	bne.s	inq_return	; Return if not zero
	bset	d0,d1		; Set this bit
	move	d1,(a0)		; And store it into the mouse shape area
	bra.s	godraw

eras_1:	btst	#1,butsav	; Right button?
	beq.s	godraw		; No, skip

	bsr	get_iptr	; Get pointer to data element
	beq.s	inq_return	; Zero, exit
	bclr	d0,d1		; Clear this bit
	move	d1,(a0)		; And store the word

godraw:	dc.w	$A00A		; Hide the mouse
	bsr	draw_pixel	; Go draw the pixel on the data grid
	bsr	show_mouse	; Show the mouse again
inq_return:
	rts

inq_2:
	cmp.w	#250,mousex	; Are we inside the mask grid?
	blt	inq_return
	cmp.w	#409,mousex
	bge	inq_return

	moveq	#0,d0		; Clear the work register
	move	mousex,d0	; Get X position
	sub.w	#250,d0		; Mask grid starts 250 pixels from the left
	divu	#10,d0		; Each cell is 10 pixels wide
	bvc.s	storx2		; No overflow, skip
	sub.w	d0,d0		; Clear it
storx2:	move	d0,x		; Save X index to array
	moveq	#0,d0		; Clear register
	move	mousey,d0	; Get Y position
	sub.w	y_off,d0	; Subtract res-dependent offset value
	divu	y_div,d0	; Divide by res-dependent Y divisor
	bvc.s	story2		; No overflow, skip
	sub.w	d0,d0		; Clear y index
story2:	move	d0,y		; Save Y array index

	btst	#0,butsav	; Left button?
	beq.s	eras_2		; No, go erase

	bsr	get_mptr	; Get pointer to mask bit
	bne	inq_return	; Already set, exit
	bset	d0,d1		; Set this bit in the mouse mask
	move	d1,(a0)		; And save it
	bra	godraw

eras_2:	btst	#1,butsav	; Right button?
	beq	godraw		; No, bail

	bsr	get_mptr	; Find the bit and clear it
	beq	inq_return	; (if it isn't already zero)
	bclr	d0,d1
	move	d1,(a0)
	bra	godraw

map_grid:
	dc.w	$A00A		; Hide mouse
	move	#1,hotflg	; Set hotspot flag
	move	#15,d5		; Draw both grids
map1:	move	#15,d4
map2:	move	d5,x
	move	d4,y
	bsr.s	draw_pixel
	dbf	d4,map2
	dbf	d5,map1
	bsr	set_hotspot	; Draw the hotspot
	bsr	show_mouse	; Show the mouse again
	rts

copy_mouse:
	move.l	x_hot,hotsav	; Copy the mouse shape to the undo buffer
	move.l	#m_mask,a0
	move.l	#mouse_save,a1
	move	#15,d0
cpym2:	move.l	(a0)+,(a1)+
	dbf	d0,cpym2
	rts

res_mouse:
	move.l	hotsav,x_hot	; Restore the mouse shape from the undo buffer
	move.l	#m_mask,a0
	move.l	#mouse_save,a1
	move	#15,d0
resm2:	move.l	(a1)+,(a0)+
	dbf	d0,resm2
	rts

draw_pixel:
	bsr	get_iptr	; Is this data bit set?
	bne.s	solid		; Yes, skip ahead

	bsr	get_mptr	; Is this mask bit set?
	bne.s	blank2		; Yes, skip ahead

	move.l	#empty,filptr
	bsr.s	d_int1		; Draw the data cell
	bsr	d_int2		; Draw the mask cell

	bra.s	draw_exit

blank2:	move.l	#dots,filptr
	bsr.s	d_int1		; Draw the data cell
	bsr	d_int2		; Draw the mask cell

	bra.s	draw_exit

solid:	bsr	get_mptr	; Is this mask bit set?
	bne.s	solid2		; Yes, skip

	move.l	#black,filptr

	bsr.s	d_int1		; Draw the data cell
	bsr	d_int2		; Draw the mask cell

	bra.s	draw_exit

solid2:	move.l	#black,filptr
	bsr.s	d_int1		; Draw the data cell
	move.l	#dots,filptr
	bsr	d_int2		; Draw the mask cell

draw_exit:
	tst.w	hotflg		; Time to draw the hotspot?
	bne.s	d_ex2		; No, skip
	bsr	set_hotspot	; Draw that hotspot
d_ex2:	rts

d_int1:
	move.l	screen,a0	; Get address of screen memory
	moveq	#0,d0
	move	y,d0
	mulu	y_div,d0
	add.w	y_off,d0
	addq.w	#1,d0
	mulu	y_scr,d0
	add.l	d0,a0		; Set pointer to proper scan line
	moveq	#0,d0
	move.w	x,d0
	mulu	#10,d0
	add.w	#51,d0
di1_0:	divu	#16,d0
	cmp.w	#2,res		; High res?
	bne.s	col_di
	lsl.w	d0
	move.l	d0,d1
	swap	d1		; Get remainder to lower word
	ext.l	d1
	move.l	filptr,a1
	move	#8,d3		; Use d3 as counter (9 scan lines)

di1_1:	moveq	#0,d2		; Clear d2
	move.w	(a1),d2		; Get first line of fill pattern
	swap	d2
	move.l	#$007FFFFF,d7	; Mask to d7
	lsr.l	d1,d2
	or	#16,ccr
	roxr.l	d1,d7
	and.l	d7,0(a0,d0)
	or.l	d2,0(a0,d0)
	add.l	#80,a0
	subq.w	#1,d3
	bmi.s	di1ex
	moveq	#0,d2
	move.w	2(a1),d2	; Second line of fill pattern
	swap	d2
	move.l	#$007FFFFF,d7	; Mask to d7
	lsr.l	d1,d2
	or	#16,ccr
	roxr.l	d1,d7
	and.l	d7,0(a0,d0)
	or.l	d2,0(a0,d0)
	add.l	#80,a0
	dbf	d3,di1_1
di1ex:	rts

col_di:
	lsl.w	#2,d0
	move.l	d0,d1
	swap	d1
	ext.l	d1
	move.l	filptr,a1
	move	#3,d3

col1_1:	moveq	#0,d2
	move.w	4(a1),d2
	swap	d2
	move.l	#$007FFFFF,d7
	lsr.l	d1,d2
	or	#16,ccr
	roxr.l	d1,d7
	and.w	d7,4(a0,d0)
	and.w	d7,6(a0,d0)
	swap	d7
	and.w	d7,0(a0,d0)
	and.w	d7,2(a0,d0)
	or.w	d2,4(a0,d0)
	swap	d2
	or.w	d2,0(a0,d0)
	moveq	#0,d2
	move.w	6(a1),d2
	swap	d2
	lsr.l	d1,d2
	or.w	d2,6(a0,d0)
	swap	d2
	or.w	d2,2(a0,d0)
	add.l	#160,a0
	dbf	d3,col1_1
	rts

d_int2:
	move.l	screen,a0	; Get address of screen memory
	moveq	#0,d0
	move	y,d0
	mulu	y_div,d0
	add.w	y_off,d0
	addq.w	#1,d0
	mulu	y_scr,d0
	add.l	d0,a0		; Set pointer to proper scan line
	moveq	#0,d0
	move.w	x,d0
	mulu	#10,d0
	add.w	#251,d0		; Now we're drawing on the Mask grid
	bra	di1_0

set_hotspot:
	dc.w	$A00A		; Hide mouse
	move	x_hot,x		; Get hotspot coordinates
	move	y_hot,y
	move.l	#hotpat,filptr
	bsr	d_int1		; Draw it
	bsr	show_mouse	; Show the mouse
	rts

get_iptr:
	moveq	#0,d0
	move	y,d0
	add.w	d0,d0
	add.l	#m_image,d0
	bra.s	btest

get_mptr:
	moveq	#0,d0
	move	y,d0
	add.w	d0,d0
	add.l	#m_mask,d0
*	bra.s	btest

btest:	move.l	d0,a0
	move	(a0),d1
	move	#15,d0
	sub.w	x,d0
	btst	d0,d1
	rts

init_col:
	move.b	#'0',dvalms
	move.b	#'0',mvalms
	move.b	#'0',dvalms+1
	move.b	#'0',mvalms+1
	move.l	#mvalms,a5
	moveq	#0,d0
	move	fg_col,d0
	bsr.s	setdec
	move.l	#dvalms,a5
	moveq	#0,d0
	move	bg_col,d0
	bsr.s	setdec
	rts

init_nfrm:
	move.b	#'0',fnvlms
	move.b	#'0',fnvlms+1
	move.b	#'0',spvlms
	move.b	#'0',spvlms+1
	move.l	#fnvlms,a5
	moveq	#0,d0
	move	nframs,d0
	bsr.s	setdec
	move.l	#spvlms,a5
	moveq	#0,d0
	move	delval,d0
	bsr.s	setdec
	rts

setdec:	addq.l	#1,a5
setd1:	subq.w	#1,d0
	bmi.s	setd2
	addq.b	#1,(a5)
	cmp.b	#':',(a5)
	bne	setd1
	move.b	#'0',(a5)
	addq.b	#1,-1(a5)
	bra	setd1
setd2:	rts

show_mouse:
	dc.w	$A000
	move.l	8(a0),a0
	move	#0,(a0)
	dc.w	$A009
	rts

open_file:
	clr.w	-(sp)
	move.l	a5,-(sp)
	move	#$3D,-(sp)
	trap	#1
	addq	#8,sp
	tst.w	d0
	rts

read_file:
	move.l	a5,-(sp)
	move.l	d5,-(sp)
	move	fhandl,-(sp)
	move	#$3F,-(sp)
	trap	#1
	add	#12,sp
	tst.l	d0
	rts

clos_file:
	move	fhandl,-(sp)
	move	#$3E,-(sp)
	trap	#1
	addq	#4,sp
	rts

delete_file:
	move.l	a0,-(sp)
	move.w	#$41,-(sp)
	trap	#1
	addq	#6,sp
	rts

chk_anfile:
	clr.w	a_good
	moveq	#0,d7
	move	#31,d6
chkan1:	move.l	d7,d0
	bsr	lseek
	bmi.s	chkan2
	move.l	#nfrtst,a5
	move.l	#4,d5
	bsr	read_file
	bmi.s	chkan2
	cmp.w	#15,(a5)
	bhi.s	chkan2
	cmp.w	#15,2(a5)
	bhi.s	chkan2
	addq.l	#6,d7
	move.l	d7,d0
	bsr	lseek
	bmi.s	chkan2
	bsr	read_file
	bmi.s	chkan2
	cmp.w	#15,(a5)
	bhi.s	chkan2
	cmp.w	#15,2(a5)
	bhi.s	chkan2
	add.l	#68,d7
	dbf	d6,chkan1

	move.l	#2368,d0
	bsr	lseek
	bmi.s	chkan2
	move.l	#nfrtst,a5
	move.l	#4,d5
	bsr	read_file
	bmi.s	chkan2
	cmp.w	#32,(a5)
	bhi.s	chkan2
	cmp.w	#99,2(a5)
	bhi.s	chkan2
	rts
chkan2:	move.w	#-1,a_good
	rts

write_mode:
	move.l	#contrl,a5
	move	#32,(a5)	; Set writing mode
	move	#0,2(a5)
	move	#1,6(a5)
	bra	vdi

poly_color:
	move.l	#contrl,a5
	move	#17,(a5)	; vsl_color (Set Polyline Color)
	move	#0,2(a5)
	move	#1,6(a5)
	bra	vdi

poly_type:
	move.l	#contrl,a5
	move	#15,(a5)	; vsl_type (Set Polyline Type)
	move	#0,2(a5)
	move	#1,6(a5)
	bra	vdi

poly_width:
	move.l	#contrl,a5
	move	#16,(a5)	; vsl_width (Set Polyline Width)
	move	#1,2(a5)
	move	#0,6(a5)
	bra	vdi

poly_ends:
	move.l	#contrl,a5
	move	#108,(a5)	; vsl_ends (Set Polyline End Styles)
	move	#0,2(a5)
	move	#2,6(a5)
	bra	vdi

polyline:
	move.l	#contrl,a5
	move	#6,(a5)
	move	pt_num,2(a5)
	move	#0,6(a5)
	bra	vdi

vsf_color:
	move.l	#contrl,a5
	move	#25,(a5)
	move	#0,2(a5)
	move	#1,6(a5)
	bra	vdi

vsf_interior:
	move.l	#contrl,a5
	move	#23,(a5)
	move	#0,2(a5)
	move	#1,6(a5)
	bra	vdi

vsf_style:
	move.l	#contrl,a5
	move	#24,(a5)
	move	#0,2(a5)
	move	#1,6(a5)
	bra	vdi

exch_button:
	move.l	#contrl,a5	; Point the mouse button routine
	move	#125,(a5)	; to an RTS to prevent the AES from
	clr.w	2(a5)		; buffering button presses
	clr.w	6(a5)
	move.l	#butrts,14(a5)
	bsr	vdi
	move.l	18(a5),badsav
	rts

repl_button:
	move.l	#contrl,a5
	move	#125,(a5)	; Reset button vector so we can use the
	clr.w	2(a5)		; AES again
	clr.w	6(a5)
	move.l	badsav,14(a5)
	bra	vdi

sample_mouse:
	move.l	#contrl,a5
	move	#124,(a5)
	move	#0,2(a5)
	move	#0,6(a5)
	bra	vdi

open_window:
	move.l	#w_get,aespb
	move.l	#intin,a5
	clr.w	(a5)
	move.w	#4,2(a5)
	bsr	aes
	move.l	intout+2,wx
	move.l	intout+6,ww

	move.l	#intin,a5
	move.l	#w_crea,aespb	; Create a full-screen window
	clr.w	(a5)
	move.l	wx,2(a5)
	move.l	ww,6(a5)
	bsr	aes
	tst.w	intout		; Error? (Probably too many windows open)
	bpl.s	openwi		; No, continue
	move.w	#-1,d0
	rts
openwi:	move	intout,whandl
	move.l	#w_open,aespb	; Open the window!
	move	whandl,(a5)	; a5 is still pointing to intin
	move.l	wx,2(a5)
	move.l	ww,6(a5)
	bsr	aes
	moveq	#0,d0
	rts

fsel:	tst	fsflag
	bne.s	fsel1

	move.l	itmadr,a0	; Change the "ITEM SELECTOR" text to something
	move.l	txtadr,(a0)	; a bit more meaningful
	move	itmlen,8(a0)
	or.w	#1,-2(a0)

fsel1:	move.l	#f_sel,aespb	; Let's call fsel_input with opcode 90
	move.l	diradr,addrin
	move.l	filadr,addrin+4
	bsr	aes

	tst	fsflag
	bne.s	fsel2

	move.l	itmadr,a0	; Restore the fsel text line
	move.l	iasav,(a0)
	and.w	#$FE,-2(a0)
	move	ilensv,8(a0)

fsel2:	rts

set_path:
	clr.w	d0		; Set current drive from output of
	move.l	diradr,a0	; fsel routine
	move.b	(a0),d0
	sub.b	#65,d0
	move	d0,-(sp)
	move	#$0E,-(sp)
	trap	#1
	addq	#4,sp
	move.l	diradr,a0	; Also set pathname from fsel
	addq.l	#2,a0
	move.l	#pathnm,a1
	move.l	#63,d5
pathlp:	tst.b	(a0)
	beq.s	plx1
	move.b	(a0)+,(a1)+
	dbf	d5,pathlp
plx1:	move.l	#63,d5
plp2:	cmp.b	#"\\",-(a1)
	beq.s	plx2
	dbf	d5,plp2
plx2:	clr.b	1(a1)
	pea	pathnm
	move	#$3B,-(sp)
	trap	#1
	addq	#6,sp
	rts

chk_extension:
	move.l	filadr,a0	; Check to see if the chosen filename has
chke_1:	tst.b	(a0)		; an extension. If not, add the proper one.
	beq.s	setext		; If so, leave it alone
	cmp.b	#".",(a0)+
	beq.s	nosete
	bra	chke_1
setext:	move	#4,d0
setx1:	move.b	(a1)+,(a0)+
	dbf	d0,setx1
nosete:	rts

res_dpath:
	move	curdrv,-(sp)	; Reset current drive and pathname
	move	#$0E,-(sp)
	trap	#1
	addq	#4,sp
	move.l	#curpth,-(sp)
	move	#$3B,-(sp)
	trap	#1
	addq	#6,sp
	rts

* form_alert
* Enter with a5= address of definition string
*	     d5= number of default box

alert:	move.l	a5,addrin	; Set address of string
	move	d5,intin	; Set default box
	move.l	#f_alrt,aespb	; Display alert box
	bra	aes

* Dialog box drawing routine

drawbx:	move.l	#f_cntr,aespb	; First, let's call form_center
	bsr	aes

	move.l	#intout,a0
	move.l	2(a0),cx
	move.l	6(a0),cw
	subq.w	#2,cx
	subq.w	#2,cy
	addq.w	#6,cw
	addq.w	#6,ch

	tst	diflag
	bne.s	draw_1

	clr.w	intin
	bsr.s	dial

draw_1:	move.l	#intin,a5
	move.l	#o_cdrw,aespb	; Objc_draw
	move	#0,(a5)		; Root object gets drawn first
	move	#5,2(a5)	; Up to 5 levels of subordinate objects
	move.l	cx,4(a5)	; (dial subroutine sets a5->intin)
	move.l	cw,8(a5)
	bra	aes

dial:	move.l	#f_dial,aespb	; Form_dial
	move.l	#intin,a5
	clr.l	2(a5)		; No growing/shrinking boxes, so just
	clr.l	6(a5)		; zero out the start coordinates
	move.l	cx,10(a5)
	move.l	cw,14(a5)
	bra	aes

obdraw:	move.l	#o_cdrw,aespb
	move.l	#intin,a0
	move	o_indx,(a0)
	move	#1,2(a0)
	move.l	x_obj1,4(a0)
	move.l	w_obj,8(a0)
	move.l	#editbx,addrin
	bra.s	aes

formdo:	move.l	#f_do,aespb	; Call form_do to get user input
	clr.w	intin		; No editable text field
	bra.s	aes		; Do it!

objoff:	move.l	#o_coff,aespb	; Calculate clipping rectangle and re-draw
	bsr.s	aes		; an object. intin must be set to the index
	move.l	#o_cdrw,aespb	; of the object to be drawn, addrin to the
	move.l	#intin+2,a5	; address of the parent object tree
	move	#0,(a5)+
	move	intout+2,(a5)
	addq.w	#1,(a5)+
	move	intout+4,(a5)
	addq.w	#1,(a5)+
	moveq	#0,d0
	move	intin,d0
	mulu	#24,d0
	add.l	addrin,d0
	move.l	d0,a0
	move	20(a0),(a5)
	subq.w	#2,(a5)+
	move	22(a0),(a5)
	subq.w	#2,(a5)+
	bra.s	aes

* VDI and AES subroutines

vdi:	move	vhandl,12(a5)
vdi1:	move.l	#vdipb,d1
	move.l	#$73,d0
	trap	#2
butrts:	rts

aes:	move.l	#aespb,d1
	move.l	#$C8,d0
	trap	#2
	rts


my_vblank:
	movem.l	d0/a0-a3,-(sp)	; Save registers
	cmp.b	#2,sshiftmod	; High res?
	beq.s	vbl1		; Yes, skip the res check
	tst	lowflg		; Did we find the Set Preferences dialog?
	bne.s	vbl1
	move.l	res_optr,a0
	btst	#0,1(a0)	; SELECTED? (Changing resolution?)
	beq.s	vbl1		; No, continue
	move.l	res_okptr,a0	; Now check the "OK" button
	btst	#0,1(a0)	; SELECTED? (_really_ changing?)
	beq.s	vbl1		; Not yet!
	move.l	line_a,a0
	btst	#0,but_stat(a0)	; Let go of the left button yet???
	bne.s	vbl1		; The suspense is killing me!

	move.l	sysvc1,$70	; Remove the vertical blank interrupt
	clr	insflg		; Clear installed flag
	move.l	$502,a0
	cmp.l	#$ABADBABE,2(a0)
	bne	fall_thru
	move.l	22(a0),$B4	; The infamous kludge for ALT.ACC
	bra	fall_thru	; And bail

vbl1:	tst	vbi_on		; Are we interrupting?
	beq	fall_thru	; Nope!
	move.l	line_a,a0
	tst.b	ignore(a0)	; Ignore the mouse?
	bne.s	fall_thru	; Do so

ckarrw:	move.l	sprtad,a0	; The address of the mouse sprite definition
	move.l	a0,a2
	move.l	#arrow_data,a1
	move	#15,d0		; 16 longwords
vbl2:	cmp.l	(a0)+,(a1)+	; Did somebody put an arrow in here???
	bne.s	vbl4		; No, I guess not
	dbf	d0,vbl2

	tst	onoff
	bne.s	vbl2a
	move.l	#m_form2,a3
	bra.s	vbl2b
vbl2a:	bsr	which_mouse
vbl2b:	bsr.s	stuff_it
	bsr	force_it	; Force the OS to show the mouse

vbl4:
	tst	onoff		; Animation on?
	beq.s	fall_thru	; Nope, bail
	subq.w	#1,vbtimr	; Decrement animation timer
	bpl.s	fall_thru	; Not time yet, bail
	move.w	delval,vbtimr	; Reset timer
	move.w	nframs,d0	; Get number of frames in the loop
	subq.w	#1,d0
	cmp.w	moucnt,d0	; Are we at the last frame?
	bhi.s	vbl5		; No, skip ahead
	clr.w	moucnt		; Clear the frame counter
	bra.s	vbl6
vbl5:	addq.w	#1,moucnt	; Increment frame counter
vbl6:	bsr.s	which_mouse	; Get pointer to mouse data
	move.l	sprtad,a2
	bsr.s	stuff_it
	bsr.s	force_it

fall_thru:
	movem.l	(sp)+,d0/a0-a3	; Restore them registers, pal
sysj1:	jmp	$DEADBEEF	; Jump to system VBI routine
sysvc1	=	sysj1+2

stuff_it:
	move.l	(a3),-10(a2)	; Caught you red-handed! Set the hot spot
	moveq	#0,d0
	move	6(a3),d0	; Get mask color
	bsr.s	vb_color	; Go adjust the color
	move	d0,-4(a2)	; Set the color
	move	8(a3),d0	; Get data color
	bsr.s	vb_color	; Adjust it
	move	d0,-2(a2)	; Set it
	move.l	a3,a0
	add.l	#10,a0		; The data is stored in sprite format
	move.l	a3,a1
	add.l	#42,a1		; --- alternating words of data and mask
	move	#15,d0
stuff2:	move	(a0)+,(a2)+	; Take that!
	move	(a1)+,(a2)+	; The mouse thief strikes!
	dbf	d0,stuff2
	rts

which_mouse:
	moveq	#0,d0
	move.w	moucnt,d0
	mulu	#74,d0
	add.l	#mouse_array,d0
	move.l	d0,a3
	rts

vb_color:
	move.l	valsav,a0
	add.l	d0,a0		; Add color value to start of table
	move.b	(a0),d0		; Get adjusted color
	rts

force_it:
	bsr.s	pac_butt
	tst	mouse_x(a0)	; Are we at the left edge of the screen?
	bne.s	force1		; No, skip over
	addq	#1,mouse_x(a0)	; Move it right
	move.b	#$FF,anipac+1	; Move it back left
	bra.s	pac_send
force1:	subq	#1,mouse_x(a0)	; Move it left
	move.b	#$01,anipac+1	; Move it back right
force2:	bra.s	pac_send

pac_butt:
	move.b	#$F8,anipac
	move.l	line_a,a0
	btst.b	#0,but_stat(a0)
	beq.s	pacb2
	bset.b	#1,anipac
pacb2:	btst.b	#1,but_stat(a0)
	beq.s	pacb3
	bset.b	#0,anipac
pacb3:	rts

pac_send:
	move.l	#anipac,a0
	move.w	sr,srsave
	or.w	#$700,sr
j_add2:	jsr	$DEADBEEF
sysvc2	=	j_add2+2
	move.w	srsave,sr
	rts


save_vbv:
	move.l	ipl_vec,sysvc1
	move.l	#my_vblank,ipl_vec

	move.l	$502,a0
	cmp.l	#$ABADBABE,2(a0)
	bne.s	getmsv
	move.l	18(a0),a0
	bra.s	getms1
getmsv:	move.w	#34,-(sp)	; Xbios kbdvbase
	trap	#14
	addq	#2,sp
	move.l	d0,a0
	move.l	16(a0),a0	; Save mouse interrupt vector
getms1:	move.l	a0,sysvc2
	rts


	.data
	.even

vdipb:	dc.l	contrl,intin,ptsin,intout,ptsout
aespb:	dc.l	contrl,global,intin,intout,addrin,addrout

a_init:	dc.w	10,0,1,0,0
e_mesg:	dc.w	23,0,1,1,0
e_timr:	dc.w	24,2,1,0,0
m_reg:	dc.w	35,1,1,1,0
g_hand:	dc.w	77,0,5,0,0
g_mous:	dc.w	78,1,1,1,0
r_obfx:	dc.w	114,1,1,1,0
f_dial:	dc.w	51,9,1,1,0
f_alrt:	dc.w	52,1,1,1,0
f_cntr:	dc.w	54,0,5,1,0
f_do:	dc.w	50,1,2,1,0
o_cdrw:	dc.w	42,6,1,1,0
o_cfnd:	dc.w	43,4,1,1,0
o_coff:	dc.w	44,1,3,1,0
f_sel:	dc.w	90,0,2,2,0
w_crea:	dc.w	100,5,1,0,0
w_open:	dc.w	101,5,5,0,0
w_clos:	dc.w	102,1,1,0,0
w_del:	dc.w	103,1,1,0,0
w_get:	dc.w	104,2,5,0,0
w_updt:	dc.w	107,1,1,0,0

ob_inx:	dc.w	savebt,loadbt,clrmbt,clrdbt,invdbt,invmbt
	dc.w	upbt,leftbt,downbt,ritebt,mirdbt,mirmbt,rotbt
	dc.w	exitbt,instbt,remvbt,undobt,cdowbt,cupbt,colttl
	dc.w	frmttl,frdown,frup,anonof
o_dum:	dc.w	0
oi_len	=	(o_dum-ob_inx)/2

rtn_table:
	dc.l	save,load,clr_mask,clr_data,inv_data,inv_mask
	dc.l	up,left,down,right,mir_data,mir_mask,rotate
	dc.l	exit,install,remove,undo,colr_down,colr_up,sw_fgbg
	dc.l	sw_anttl,ani_down,ani_up,ani_onoff

low_val:
	dc.b	0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
med_val:
	dc.b	0,15,1,2,15,15,15,15,15,15,15,15,15,15,15,15
hi_val:
	dc.b	0,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15

y_off:	dc.w	100
y_bot:	dc.w	260

chang1:	dc.w	180
chang2:	dc.w	140

y_div:	dc.w	10

y_scr:	dc.w	80

celsiz:	dc.w	9

fillst:	dc.w	2

filhot:	dc.w	5

empty:	dc.w	$0000,$0000
mempty:	dc.w	$0000,$0000

dots:	dc.w	$AA80,$0000
mdots:	dc.w	$0000,$FF80

black:	dc.w	$FF80,$FF80
mblack:	dc.w	$FF80,$FF80

hotpat:	dc.w	$5500,$FF80
mhotpt:	dc.w	$FF80,$0000

mouse_form:
x_hot:	dc.w	0
y_hot:	dc.w	0
planes:	dc.w	1
fg_col:	dc.w	0
bg_col:	dc.w	1
m_mask:
	dc.w	$C000,$E000,$F000,$F800
	dc.w	$FC00,$FE00,$FF00,$FF80
	dc.w	$FFC0,$FFE0,$FE00,$EF00
	dc.w	$CF00,$8780,$0780,$0380
m_image:
	dc.w	$0000,$4000,$6000,$7000
	dc.w	$7800,$7C00,$7E00,$7F00
	dc.w	$7F80,$7C00,$6C00,$4600
	dc.w	$0600,$0300,$0300,$0000

arrow_data:
	dc.w	$C000,$0000,$E000,$4000	; Data for arrow cursor in sprite
	dc.w	$F000,$6000,$F800,$7000	; format (alternating words of mask
	dc.w	$FC00,$7800,$FE00,$7C00	; and data)
	dc.w	$FF00,$7E00,$FF80,$7F00

	dc.w	$FFC0,$7F80,$FFE0,$7C00
	dc.w	$FE00,$6C00,$EF00,$4600
	dc.w	$CF00,$0600,$8780,$0300
	dc.w	$0780,$0300,$0380,$0000

* TEDINFO structures

tinf0:	dc.l	stlog,dummy,dummy	; ST-Log Presents
	dc.w	5,6,1,$1000,0,-1,17,1
tinf1:	dc.l	copyrt,dummy,dummy	; Copyright 1987
	dc.w	5,6,2,$1000,0,-1,15,1
tinf2:	dc.l	footbl,dummy,dummy	; Little Green Footballs
	dc.w	5,6,2,$1000,0,-1,23,1
tinf3:	dc.l	dcolms,dummy,dummy	; Data/Mask color message
	dc.w	5,6,2,$1180,0,-1,11,1
tinf4:	dc.l	framms,dummy,dummy	; Frame/#/Speed message
	dc.w	5,6,2,$1180,0,-1,6,1
tinf5:	dc.l	anofms,dummy,dummy	; Animation ON/OFF message
	dc.w	5,6,2,$1180,0,-1,14,1

tinf10:	dc.l	dcolms,dummy,dummy	; Low res Data/Mask message
	dc.w	5,6,2,$1180,0,-1,11,1

* Editor dialog box

editbx:	dc.w	-1,1,32,G_BOX,NONE,SHADOWED
	dc.l	$FF1100
	dc.w	0,0,76,20

	dc.w	5,2,4,G_STRING,NONE,SELECTED
	dc.l	mousms
	dc.w	0,0,76,2

	dc.w	3,-1,-1,G_TEXT,NONE,NORMAL
	dc.l	tinf0
	dc.w	1,0,13,2

	dc.w	4,-1,-1,G_TEXT,NONE,NORMAL
	dc.l	tinf1
cop_co:	dc.w	57,0,17,1

	dc.w	1,-1,-1,G_TEXT,NONE,NORMAL
	dc.l	tinf2
footco:	dc.w	57,1,17,1

	dc.w	6,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	instms
	dc.w	66,3,8,1

	dc.w	7,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	remvms
	dc.w	66,5,8,1

	dc.w	8,-1,-1,G_BOXTEXT,NONE,NORMAL
	dc.l	tinf3
	dc.w	65,7,10,1

	dc.w	9,-1,-1,G_BOXCHAR,NONE,NORMAL
	dc.l	$2FF1100
	dc.w	65,8,3,2

	dc.w	10,-1,-1,G_BUTTON,SELECTABLE,NORMAL
valadr:	dc.l	dvalms
col_co:	dc.w	68,8,4,2

	dc.w	11,-1,-1,G_BOXCHAR,NONE,NORMAL
	dc.l	$1FF1100
	dc.w	72,8,3,2

	dc.w	12,-1,-1,G_BOXCHAR,NONE,SHADOWED
	dc.l	$1FF1100
upco:	dc.w	57,9,2,1

	dc.w	13,-1,-1,G_BOXCHAR,NONE,SHADOWED
	dc.l	$4FF1100
leftco:	dc.w	53,11,2,1

	dc.w	14,-1,-1,G_BOXCHAR,NONE,SHADOWED
	dc.l	$3FF1100
riteco:	dc.w	61,11,2,1

	dc.w	15,-1,-1,G_BOXTEXT,NONE,NORMAL
	dc.l	tinf4
	dc.w	65,11,10,1

	dc.w	16,-1,-1,G_BOXCHAR,NONE,NORMAL
	dc.l	$2FF1100
	dc.w	65,12,3,2

	dc.w	17,-1,-1,G_BUTTON,SELECTABLE,NORMAL
anival:	dc.l	frvlms
	dc.w	68,12,4,2

	dc.w	18,-1,-1,G_BOXCHAR,NONE,NORMAL
	dc.l	$1FF1100
	dc.w	72,12,3,2

	dc.w	19,-1,-1,G_BOXCHAR,NONE,SHADOWED
	dc.l	$2FF1100
downco:	dc.w	57,13,2,1

	dc.w	20,-1,-1,G_STRING,NONE,SELECTED
	dc.l	dat_ms
datco:	dc.w	11,14,6,1

	dc.w	21,-1,-1,G_STRING,NONE,SELECTED
	dc.l	maskms
mskco:	dc.w	36,14,6,1

	dc.w	22,-1,-1,G_BOXTEXT,NONE
anistt:	dc.w	NORMAL
	dc.l	tinf5
	dc.w	65,14,10,1

	dc.w	23,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	savems
	dc.w	2,16,7,1

	dc.w	24,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	clrdms
	dc.w	11,16,12,1

	dc.w	25,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	invdms
	dc.w	24,16,12,1

	dc.w	26,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	mirdms
	dc.w	37,16,12,1

	dc.w	27,-1,-1,G_BUTTON,SELECTABLE
extstt:	dc.w	SHADOWED
	dc.l	exitms
	dc.w	67,16,7,3

	dc.w	28,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	undoms
	dc.w	58,16,7,3

	dc.w	29,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	rotms
	dc.w	50,16,7,3

	dc.w	30,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	loadms
	dc.w	2,18,7,1

	dc.w	31,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	clrmms
	dc.w	11,18,12,1

	dc.w	32,-1,-1,G_BUTTON,SELECTABLE,SHADOWED
	dc.l	invmms
	dc.w	24,18,12,1

	dc.w	0,-1,-1,G_BUTTON,$21,SHADOWED
	dc.l	mirmms
	dc.w	37,18,12,1

ed_adr:	dc.l	editbx

objnum	=	(ed_adr-editbx)/24-1

* Low-res dialog box

lowbox:	dc.w	-1,1,14,G_BOX,NONE,SHADOWED
	dc.l	$FF1100
	dc.w	0,0,38,14

	dc.w	2,-1,-1,G_STRING,NONE,SELECTED
	dc.l	lttlms
	dc.w	0,0,38,2

	dc.w	3,-1,-1,G_STRING,NONE,NORMAL
	dc.l	lms1
	dc.w	1,3,23,1

	dc.w	4,-1,-1,G_BUTTON,$5
loistt:	dc.w	NORMAL
	dc.l	loadms
	dc.w	26,3,10,1

	dc.w	5,-1,-1,G_STRING,NONE,NORMAL
	dc.l	lms2
	dc.w	1,4,18,1

	dc.w	6,-1,-1,G_BUTTON,$5
losstt:	dc.w	NORMAL
	dc.l	savems
	dc.w	26,5,10,1

	dc.w	7,-1,-1,G_STRING,NONE,NORMAL
	dc.l	lms3
	dc.w	1,6,22,1

	dc.w	8,-1,-1,G_BUTTON,$5
lorstt:	dc.w	NORMAL
	dc.l	remvms
	dc.w	26,7,10,1

	dc.w	9,-1,-1,G_STRING,NONE,NORMAL
	dc.l	lms4
	dc.w	1,7,19,1

	dc.w	10,-1,-1,G_STRING,NONE,NORMAL
	dc.l	lms5
	dc.w	1,8,20,1

	dc.w	11,-1,-1,G_BOXTEXT,TOUCHEXIT
locstt:	dc.w	NORMAL
	dc.l	tinf10
	dc.w	7,10,10,1

	dc.w	12,-1,-1,G_BUTTON,$7
loestt:	dc.w	NORMAL
	dc.l	exitms
	dc.w	26,10,10,2

	dc.w	13,-1,-1,G_BOXCHAR,TOUCHEXIT
lodstt:	dc.w	NORMAL
	dc.l	$2FF1100
	dc.w	7,11,3,2

	dc.w	14,-1,-1,G_BUTTON,NONE,NORMAL
lovadr:	dc.l	dvalms
	dc.w	10,11,4,2

	dc.w	0,-1,-1,G_BOXCHAR,$60
loustt:	dc.w	NORMAL
	dc.l	$1FF1100
	dc.w	14,11,3,2

lo_adr:	dc.l	lowbox

lo_num	=	(lo_adr-lowbox)/24-1


* Text for dialog objects

stlog:	dc.b	'ST-Log Presents:',0
copyrt:	dc.b	'Copyright 1987',0
footbl:	dc.b	'Little Green Footballs'
dummy:	dc.b	0

mousms:	dc.b	'                 MOUSE-KA-MANIA! by Charles F. Johnson',0
instms:	dc.b	'Install',0
remvms:	dc.b	'Remove',0
savems:	dc.b	'Save',0
loadms:	dc.b	'Load',0
clrdms:	dc.b	'Clear Data',0
clrmms:	dc.b	'Clear Mask',0
invdms:	dc.b	'Invert Data',0
invmms:	dc.b	'Invert Mask',0
mirdms:	dc.b	'Mirror Data',0
mirmms:	dc.b	'Mirror Mask',0
rotms:	dc.b	'Rotate',0
exitms:	dc.b	'EXIT',0
undoms:	dc.b	'UNDO',0
dat_ms:	dc.b	' DATA',0
maskms:	dc.b	' MASK',0
dvalms:	dc.b	'01',0
mvalms:	dc.b	'00',0
frvlms:	dc.b	'01',0
fnvlms:	dc.b	'01',0
spvlms:	dc.b	'00',0
blnkms:	dc.b	'  ',0

dcolms:	dc.b	'Data Color',0
mcolms:	dc.b	'Mask Color',0
framms:	dc.b	'Current Frame',0
frmnms:	dc.b	'# of Frames',0
speems:	dc.b	'Delay',0
anonms:	dc.b	'Animation ON',0
anofms:	dc.b	'Animation OFF',0

lttlms:	dc.b	" Mouse-Ka-Mania by Charles F. Johnson ",0
lms1:	dc.b	"The Editor doesn't work",0
lms2:	dc.b	"in low resolution.",0
lms3:	dc.b	"However, you may still",0
lms4:	dc.b	"install or remove a",0
lms5:	dc.b	"custom mouse cursor!",0

	.even

itmtxt:	dc.b	'ITEM SELECTOR'

restxt:	dc.b	'Low',0,'Medium',0,'High'

datext:	dc.b	':\\*.DAT',0
aniext:	dc.b	':\\*.MKM',0

i_save:	dc.b	' Save Mouse Data to which File? '
is_dum:	dc.b	0
is_len	=	(is_dum-i_save)*8

i_asav:	dc.b	' Save Animation to which File? '
ia_dum:	dc.b	0
iaslen	=	(ia_dum-i_asav)*8

i_load:	dc.b	' Load Mouse Data from which File? '
il_dum:	dc.b	0
il_len	=	(il_dum-i_load)*8

i_aloa:	dc.b	' Load Animation from which File? '
ial_du:	dc.b	0
iallen	=	(ial_du-i_aloa)*8

dat_or_ani:
	dc.b	'[2][   Which type of file?       | ]'
	dc.b	'[Animation|Single Frame]'

notani:
	dc.b	'[3][ This is not a Mouse-Ka-Mania |'
	dc.b	' animation file. | ]'
	dc.b	'[ Oops! ]'

exist:
	dc.b	'[3][ The file '
exname:	dc.b	'             | already exists! | |'
	dc.b	' Over-write it?| ]'
	dc.b	'[ Yes | No ]'

dskful:	dc.b	'[3][ This disk is full! | ][ Oops! ]'

accmsg:	dc.b	'  Mouse-ka-Mania!',0

lowdef:	dc.b	'\\MOUSELOW.DEF',0
meddef:	dc.b	'\\MOUSEMED.DEF',0
hidef:	dc.b	'\\MOUSEHI.DEF',0

anipac:	dc.b	0,0,0,0

	.bss
	.even

line_a:	ds.l	1
valsav:	ds.l	1
temp:	ds.l	1
o_asav:	ds.l	1
itmadr:	ds.l	1
iasav:	ds.l	1
txtadr:	ds.l	1
diradr:	ds.l	1
filadr:	ds.l	1
badsav:	ds.l	1
sprtad:	ds.l	1
screen:	ds.l	1
filptr:	ds.l	1
nfrtst:	ds.l	1
res_optr:
	ds.l	1
res_okptr:
	ds.l	1

scncnt:	ds.w	1
srsave:	ds.w	1
fsflag:	ds.w	1
lowflg:	ds.w	1
o_res:	ds.w	1
res:	ds.w	1
menuid:	ds.w	1
curdrv:	ds.w	1
colflg:	ds.w	1
adflag:	ds.w	1
antflg:	ds.w	1
shfflg:	ds.w	1
onoff:	ds.w	1
vbi_on:	ds.w	1
vbtimr:	ds.w	1
moucnt:	ds.w	1
franum:	ds.w	1
nframs:	ds.w	1
delval:	ds.w	1

diflag:	ds.w	1
insflg:	ds.w	1
itmlen:	ds.w	1
ilensv:	ds.w	1
numrtn:	ds.w	1
butflg:	ds.w	1
o_indx:	ds.w	1
hotflg:	ds.w	1
m_flag:	ds.w	1
d_flag:	ds.w	1
a_good:	ds.w	1
pt_num:	ds.w	1
ghandl:	ds.w	1
vhandl:	ds.w	1
whandl:	ds.w	1
fhandl:	ds.w	1
butsav:	ds.w	1
mousex:	ds.w	1
mousey:	ds.w	1
x:	ds.w	1
y:	ds.w	1
cx:	ds.w	1
cy:	ds.w	1
cw:	ds.w	1
ch:	ds.w	1
wx:	ds.w	1
wy:	ds.w	1
ww:	ds.w	1
wh:	ds.w	1
x_obj1:	ds.w	1
y_obj1:	ds.w	1
x_obj2:	ds.w	1
y_obj2:	ds.w	1
w_obj:	ds.w	1
h_obj:	ds.w	1

l_type:	ds.w	1
l_colr:	ds.w	1
d_mode:	ds.w	1
l_strt:	ds.w	1
l_end:	ds.w	1
l_wid:	ds.w	1
f_type:	ds.w	1
f_colr:	ds.w	1
f_patt:	ds.w	1

* GEM arrays

contrl:	ds.w	12
intin:	ds.w	128
ptsin:	ds.w	128
intout:	ds.w	128
ptsout:	ds.w	128
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

addrin:	ds.w	128
addrout:ds.w	128

m_form2:
	ds.b	74		; The installed mouse form

hotsav:
	ds.l	1		; Hot spot undo

mouse_save:
	ds.w	32		; Undo buffer

m_rotate:
	ds.w	32		; Rotation buffer

mouse_array:
	ds.b	74*32		; Animation array

savfil:	ds.b	16
svafil:	ds.b	16
lodfil:	ds.b	16
loafil:	ds.b	16

savdir:	ds.b	64
svadir:	ds.b	64
loddir:	ds.b	64
loadir:	ds.b	64

pathnm:	ds.b	64
curpth:	ds.b	64

mspipe:	ds.b	32

dta:	ds.b	44

	ds.l	300		; Reserve 1200 bytes for stack
ustack:	ds.l	1
	ds.w	10
