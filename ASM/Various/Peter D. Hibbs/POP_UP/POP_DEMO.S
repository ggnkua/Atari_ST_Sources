
	ttl	'Pop-up menu demonstration'

	include	gemmacro.i
	include	tosmacro.s
	include	pop_ups.i
	include	keytable.s
		
hide	equ	256
show	equ	257

;MACRO definitions

;Locate form/object data block
;Sets a3 to start of form data
;Sets a0 to start of object data

objc_locate	MACRO		tree,object
	movem.l	d0-d2/a1-a2,-(sp)
	rsrc_gaddr	#0,\1		
	move.l	addr_out,a3	fetch ob addr
	movem.l	(sp)+,d0-d2/a1-a2	
	move.l	d0,-(sp)
	move	\2,d0
	mulu	#24,d0
	lea	0(a3,d0),a0	load a0 with object addr
	move.l	(sp)+,d0
	ENDM

;Display pop-up menu
;ENTRY Form ident value
;      X co-ord for top left corner of form
;      Y co-ord for top left corner of form
;      16 byte buffer address for returned data
;EXIT  d0=0 no error, d0=-1 insufficient RAM
;      Buffer holds info

pop_up_menu	MACRO		form_id, xposn, yposn, buffer_addr
	move.l	\4,-(sp)	locate return buffer
	move	\3,-(sp)	set y co-ord
	move	\2,-(sp)	set x co-ord
	move	\1,-(sp) 	set form No
	bsr	pop_up	display menu
	add	#10,sp	tidy stack
	tst.l	d0	chk for error ?
	ENDM

;The program

start_of_pgm	move.l	4(sp),a3	base page
	move.l	#stack,sp	move SP
	move.l	12(a3),d0	text len
	add.l	20(a3),d0	data len
	add.l	28(a3),d0	BSS len
	add.l	#256,d0	basepage

	move.l	d0,-(sp)	shrink memory
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	appl_init		initialise application
	move	d0,ap_id	and store the app ident
	graf_handle		fetch graf handle code
	move	d0,current_handle  and store VDI handle

	lea	intin,a0	initialise intin array
	moveq	#10-1,d0	
shell1	move	#1,(a0)+	most params are 1
	dbra	d0,shell1
	move	#2,(a0)+	use RC system
	v_opnvwk		open work station
	move	intout,scr_width	set screen width
	add	#1,scr_width
	move	intout+2,scr_height	set screen height (mono)
	add	#1,scr_height

	graf_mouse	#hide	display main form
	v_clrwk		clr screen
	graf_mouse	#show
	vs_clip	#1,#0,#0,#639,#399
	vsl_color	#1

	rsrc_load	#rsc_file	load resource file (if reqd)
	bne	shell2	branch if OK
	graf_mouse	#show	show mouse

	form_alert	#1,#badrsc	can't find .RSC file ?
	bra	shell3

shell2	bsr	main	run main program

	rsrc_free		free RSC memory (if reqd)

shell3	v_clsvwk		close workstation
	appl_exit		close application

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm

rsc_file	dc.b	'POP_UPS.RSC',0	
badrsc	dc.b	'[3][Resource file error][Quit]',0
	even

;--------------------- Main program sub-routine ------------------------

main	
	move	#IMAGE_1,current_img
	move	#COLOUR_1,current_objc
	
	objc_locate	#MENU1,#0
	menu_bar	a3,#1

	wind_create	#0,#0,#0,scr_width,scr_height
	move	d0,w_handle

	wind_open	w_handle,#0,#18,scr_width,scr_height

	graf_mouse	#hide	display main form
	objc_locate	#FORM_MAIN,#0
	form_center	a3
	objc_draw	a3,#0,#2,int_out+2,int_out+4,int_out+6,int_out+8
	graf_mouse	#0
	graf_mouse	#show


main1	evnt_multi	#32+16+2+1,#1,#1,#1,,,,,,,,,,,#m_buffer,#0
	
	move	int_out,d0	fetch message

	btst	#4,d0	message event (16) ?
	bne	message_evnt	yes so jump

	btst	#0,d0	key event (1) ?
	bne	key_evnt	yes so jump

	btst	#1,d0	button event (2) ?
	bne	button_evnt	yes so jump

	btst	#5,d0	timer event (32)?
	bne	timer_evnt	yes so jump

	bra	main1
	
;           *********--- Message events ---*********

message_evnt	
	move	m_buffer,d0	check message type
	cmp	#10,d0
	beq	opt_menu	menu selection
	bra	main1

opt_menu	objc_locate	#MENU1,#0
	menu_tnormal	a3,m_buffer+6,#1  reset title
	move	m_buffer+8,d0	  fetch menu item No
	bsr	compare
	dc.w	1
	dc.w	MENU_QUIT	quit
	dc.l	exit	
	bra	main1
	
;          *********--- Timer events ---*********

timer_evnt	rsrc_gaddr	#0,#MENU1
	objc_find	addr_out,#0,#9,int_out+2,int_out+4
	move	int_out,d7
	cmp	#-1,d7
	beq	main1

	objc_locate	#MENU1,d7	chk if menu item selected
	btst	#0,11(a0)
	beq	main1	loop if not

	move.l	#mu_table,-(sp)	define look up table
	move	d7,-(sp)	define menu item id
	bsr	sub_menu	sub-menu activated ?
	add	#6,sp	
	
	bra	main1		

mu_table	dc.w	MENU_OPT1,FORM_OPT1
	dc.w	MENU_OPT2,FORM_OPT2
	dc.w	-1
	
;          *********--- Button events ---*********

button_evnt	move	int_out+2,d0	x co-ord
	move	int_out+4,d1	y co-ord
	
	objc_locate	#FORM_MAIN,#0	
	objc_find	a3,#0,#2,d0,d1
	cmp	#COLOUR_SELECT,int_out
	beq	main_colours
	cmp	#IMAGE,int_out
	beq	main_image
	bra	main1
	
main_colours	objc_offset	a3,#COLOUR_SELECT
	move	int_out+2,d6	    set x co-ord	
	move	int_out+4,d7	    set y co-ord
	objc_locate	#FORM_COLOURS,current_objc
	sub	16(a0),d6
	sub	18(a0),d7

	pop_up_menu	#FORM_COLOURS,d6,d7,#pop_buff
	cmp	#-1,pop_buff	    chk return objc
	beq	main1	    loop if no selection

	move	pop_buff,current_objc   update objc store

	objc_locate	#FORM_MAIN,#0	a3=tree addr
	move.l	pop_buff+4,a4
	move	#COLOUR_SELECT,d3
	bsr	set_tedinfo
	
	objc_offset	a3,#COLOUR_SELECT
	objc_locate	#FORM_MAIN,#COLOUR_SELECT
	
	move	pop_buff+10,d0	fetch string length
	lsl	#3,d0	*8
	move	d0,20(a0)	set width
	objc_draw	a3,#0,#5,int_out+2,int_out+4,#110,#20
	
	bra	main1

main_image	objc_offset	a3,#IMAGE_SELECT
	move	int_out+2,d6	    set x co-ord	
	move	int_out+4,d7	    set y co-ord
	objc_locate	#FORM_IMG,current_img
	sub	16(a0),d6
	sub	18(a0),d7

	pop_up_menu	#FORM_IMG,d6,d7,#pop_buff
	cmp	#-1,pop_buff	    chk return objc
	beq	main1	    loop if no selection

	move	pop_buff,current_img   update objc store

	objc_locate	#FORM_MAIN,#IMAGE	
	move.l	12(a0),a0	locate bitblk table
	move.l	(a0),a0	locate dest image data
	move.l	pop_buff+4,a1	locate source data
	move	pop_buff+10,d0	fetch width (bytes)
	mulu	pop_buff+12,d0	mul by height
	sub	#1,d0
main_image1	move.b	(a1)+,(a0)+	copy image to objc
	dbra	d0,main_image1

	objc_offset	a3,#IMAGE_SELECT
	move	int_out+2,d6
	move	int_out+4,d7
	objc_draw	a3,#0,#5,d6,d7,#32,#32

	bra	main1

;	button events here....

	bra	main1
	
;          ********* ---Keyboard events--- *********

key_evnt	move	int_out+10,d0	fetch key code
	bsr	compare
	dc.w	1
	dc.w	alt_key_Q
	dc.l	exit

	bra	main1

;Exit program (ALT Q)
	
exit	menu_bar	#MENU1,#0	erase menu
	rts	exit program

;             -------------- Program Sub-Routines -----------

	
REG	equ	9*4	9 registers saved

;Display pop-up menu form
;ENTRY (sp+REG+4)=Pop-up form ident
;      (sp+REG+6)=x co-ord of form
;      (sp+REG+8)=y co-ord of form
;      (sp+REG+10)=addr of return buffer
;EXIT  (Return buffer) holds info
;      d0=0 if OK,  =-1 for error

pop_up	movem.l	d1-d4/a0-a4,-(sp)

	move	REG+4(sp),d3	fetch form id
	move	REG+6(sp),source_x
	move	REG+8(sp),source_y
	move.l	REG+10(sp),a4	locate return buffer

	wind_update	#1	lock out AES
	move	d3,2(a4)	store form id in O/P buff
	move	d3,tree_id	save id
		
	rsrc_gaddr	#0,d3		
	move.l	addr_out,a3	fetch form addr
	
	move	20(a3),d0	fetch width
	add	#4,d0	extra for shadow
	move	d0,width	save width
	lsr	#3,d0	conv to bytes
	move	22(a3),d1	fetch height
	add	#4,d1
	move	d1,height	save height
	mulu	d1,d0	calc RAM size
	
	m_alloc	d0	grab some RAM
	beq	pop_up5
	move.l	d0,ram_buffer	& save addr

	graf_mouse	#hide	mouse off

	clr.l	srce_mfdb	source=screen
	move	source_x,ptsin
	move	source_y,ptsin+2
	move	source_x,d0
	add	width,d0
	sub	#1,d0
	move	d0,ptsin+4
	move	source_y,d0
	add	height,d0
	sub	#1,d0
	move	d0,ptsin+6
	
	clr	ptsin+8
	clr	ptsin+10
	move	width,ptsin+12
	sub	#1,ptsin+12
	move	height,ptsin+14
	sub	#1,ptsin+14
	
	move.l	ram_buffer,dest_mfdb
	move	width,dest_mfdb+4
	move	height,dest_mfdb+6
	move	width,d0
	lsr	#4,d0
	add	#1,d0
	move	d0,dest_mfdb+8
	clr	dest_mfdb+10
	move	#1,dest_mfdb+12
	clr	dest_mfdb+14
	clr	dest_mfdb+16
	clr	dest_mfdb+18
	vro_cpyfm	#3,#srce_mfdb,#dest_mfdb

	objc_locate	tree_id,#0
	move	source_x,16(a0)
	move	source_y,18(a0)
	move	20(a0),d0
	add	#5,d0
	move	22(a0),d1
	add	#5,d1
	objc_draw	a3,#0,#5,source_x,source_y,d0,d1
	graf_mouse	#show
	
pop_up1	graf_mkstate		fetch mouse data
	move	int_out+2,pop_x
	move	int_out+4,pop_y
	
	objc_find	a3,#0,#2,pop_x,pop_y
	move	int_out,pop_objc
	cmp	#-1,pop_objc
	beq	pop_up2	skip if no objc
	
	move	pop_objc,d3	obj disabled ?
	objc_locate	tree_id,d3	find objc data
	btst	#3,11(a0)
	bne	pop_up2	skip if objc disabled

	move	20(a0),objc_width
	move	22(a0),objc_height
	
	objc_offset	a3,pop_objc
	objc_change	a3,pop_objc,int_out+2,int_out+4,objc_width,objc_height,#1,#1	inverse video
		
pop_up2	graf_mkstate
	move	int_out+2,d0	fetch x co-ord
	move	int_out+4,d1	fetch y co-ord
	tst	int_out+6	chk button
	beq	pop_up3	bra if yes
	cmp	old_x,d0
	bne	pop_up4
	cmp	old_y,d1
	beq	pop_up2
pop_up4	move	d0,old_x	update co-ords
	move	d1,old_y

	objc_find	a3,#0,#2,d0,d1	check if same objc No
	move	int_out,d0
	cmp	pop_objc,d0
	beq	pop_up2	
	
	move	pop_objc,d3	obj disabled ?
	objc_locate	tree_id,d3	find objc data
	btst	#3,11(a0)
	bne	pop_up1
	move	20(a0),objc_width
	move	22(a0),objc_height
	
	objc_offset	a3,pop_objc
	objc_change	a3,pop_objc,int_out+2,int_out+4,objc_width,objc_height,#0,#1	normal video

	bra	pop_up1	repeat
	
pop_up3	vq_key_s		any keys pressed ?
	move	intout,8(a4)	save key status

	move	#-1,(a4)	preset objc id
	clr.l	4(a4)	clr addr pointer
	clr	10(a4)	clr strg length or img width	
	clr	12(a4)	clr height

	objc_find	a3,#0,#2,pop_x,pop_y   find objc selected
	move	int_out,d3	save objc id
	cmp	#-1,d3	skip if no objc selctd
	beq	pop_up7
	
	objc_locate	tree_id,d3	find objc data
	bclr	#0,11(a0)	clr 'selected' flag
	btst	#3,11(a0)	chk 'disabled' flag
	bne	pop_up7	skip if objc disabled

	move	d3,(a4)	update O/P buffer
	cmp.b	#28,7(a0)	chk if g_string type
	bne	pop_up10	skip if not
	move.l	12(a0),4(a4)	fetch & store string addr
	
	move.l	12(a0),a0	a0=string addr
	move	#1,d0	set byte count
pop_up8	add	#1,d0
	tst.b	(a0)+	find end of string
	bne	pop_up8
	sub	#1,a0	back one
pop_up9	sub	#1,a0	back another one
	sub	#1,d0
	cmp.b	#' ',(a0)	skip spaces
	beq	pop_up9
	move	d0,10(a4)	save string length

pop_up7	graf_mouse	#hide	mouse off

	clr	ptsin	copy image to scrn
	clr	ptsin+2
	move	width,ptsin+4
	sub	#1,ptsin+4
	move	height,ptsin+6
	sub	#1,ptsin+6

	move	source_x,ptsin+8
	move	source_y,ptsin+10
	move	source_x,d0
	add	width,d0
	sub	#1,d0
	move	d0,ptsin+12
	move	source_y,d0
	add	height,d0
	sub	#1,d0
	move	d0,ptsin+14
	
	clr.l	dest_mfdb	dest=screen
	move.l	ram_buffer,srce_mfdb
	move	width,srce_mfdb+4
	move	height,srce_mfdb+6
	move	width,d0
	lsr	#4,d0
	add	#1,d0
	move	d0,srce_mfdb+8
	clr	srce_mfdb+10
	move	#1,srce_mfdb+12
	clr	srce_mfdb+14
	clr	srce_mfdb+16
	clr	srce_mfdb+18
	vro_cpyfm	#3,#srce_mfdb,#dest_mfdb

	graf_mouse	#show	mouse on

	m_free	ram_buffer	release RAM
	clr.l	d0	no error
	bra	pop_up6	& exit

pop_up10	cmp.b	#23,7(a0)	skip if not g_image
	bne	pop_up7
	move.l	12(a0),a0	a0=bitblk table
	move	4(a0),10(a4)	save image width
	move	6(a0),12(a4)	save image height
	move.l	(a0),4(a4)	save image data addr
	bra	pop_up7
		
pop_up5	move.l	#-1,d0	RAM error
pop_up6	move.l	d0,-(sp)	release AES
	wind_update	#0
	move.l	(sp)+,d0
	movem.l	(sp)+,d1-d4/a0-a4
	rts

;Display sub-menu form
;ENTRY (sp+REG+4)=Menu item ident
;      (sp+REG+6)=Addr of look-up table
;EXIT  (Return buffer) holds info
;      d0=0 if OK,  =-1 for error

sub_menu	movem.l	d1-d4/a0-a4,-(sp)

	clr.l	d0	no error
	move	REG+4(sp),d1	fetch menu item id
	move.l	REG+6(sp),a0	locate table
sub_menu0	cmp	#-1,(a0)	end of table ?
	beq	sub_menu6	exit
	cmp	(a0),d1	menu item in table ?
	beq	sub_menu12	yes
	add	#4,a0	next entry
	bra	sub_menu0	repeat

sub_menu12	move	2(a0),tree_id	fetch and save form id

	objc_locate	#MENU1,d1	locate form data
	move	20(a0),d4	fetch width
	sub	#8,d4	less 8 pix
	objc_offset	a3,d1	find menu item co-ords	
	move	int_out+2,source_x
	move	int_out+4,source_y
	sub	#1,source_y	calc y co-ord
	add	d4,source_x	calc x co-ord
			
	rsrc_gaddr	#0,tree_id	locate form data
	move.l	addr_out,a3	fetch form addr
	move	20(a3),d0	fetch width
	add	#4,d0	extra for shadow ???
	move	d0,width	save width
	lsr	#3,d0	conv to bytes
	move	22(a3),d1	fetch height
	add	#4,d1		 ???
	move	d1,height	save height
	mulu	d1,d0	calc RAM size
	
	m_alloc	d0	grab some RAM
	beq	sub_menu5
	move.l	d0,ram_buffer	& save addr

	graf_mouse	#hide	mouse off

	clr.l	srce_mfdb	source=screen
	move	source_x,ptsin
	move	source_y,ptsin+2
	move	source_x,d0
	add	width,d0
	sub	#1,d0
	move	d0,ptsin+4
	move	source_y,d0
	add	height,d0
	sub	#1,d0
	move	d0,ptsin+6
	
	clr	ptsin+8
	clr	ptsin+10
	move	width,ptsin+12
	sub	#1,ptsin+12
	move	height,ptsin+14
	sub	#1,ptsin+14
	
	move.l	ram_buffer,dest_mfdb
	move	width,dest_mfdb+4
	move	height,dest_mfdb+6
	move	width,d0
	lsr	#4,d0
	add	#1,d0
	move	d0,dest_mfdb+8
	clr	dest_mfdb+10
	move	#1,dest_mfdb+12
	clr	dest_mfdb+14
	clr	dest_mfdb+16
	clr	dest_mfdb+18
	vro_cpyfm	#3,#srce_mfdb,#dest_mfdb

	objc_locate	tree_id,#0
	move	source_x,16(a0)
	move	source_y,18(a0)
	move	20(a0),d0
	add	#5,d0
	move	22(a0),d1
	add	#5,d1
	objc_draw	a3,#0,#5,source_x,source_y,d0,d1
	graf_mouse	#show

	move	#-1,old_x
	move	#-1,pop_objc
		
sub_menu1	graf_mkstate
	tst	int_out+6
	bne	sub_menu3	bra if button down

	move	int_out+2,d0
	move	int_out+4,d1
	
	cmp	old_x,d0	are they different ?
	bne	sub_menu4
	cmp	old_y,d1
	beq	sub_menu1	loop if no
sub_menu4	move	d0,old_x	update xy co-ords
	move	d1,old_y

	objc_find	a3,#0,#2,old_x,old_y	check if same objc No
	move	int_out,d3
	cmp	pop_objc,d3
	beq	sub_menu1	loop if same
	move	d3,d4
	cmp	#-1,pop_objc	skip if no obj
	beq	sub_menu2

	objc_locate	tree_id,pop_objc	find new objc data
	btst	#3,11(a0)
	bne	sub_menu2	loop if disabled
	move	20(a0),objc_width
	move	22(a0),objc_height
	
	objc_offset	a3,pop_objc	
	objc_change	a3,pop_objc,int_out+2,int_out+4,objc_width,objc_height,#0,#1	normal video

sub_menu2	move	d3,pop_objc

	cmp	#-1,pop_objc
	beq	sub_menu1

	objc_locate	tree_id,pop_objc	find objc data
	btst	#3,11(a0)
	bne	sub_menu1	skip if objc disabled

	move	20(a0),objc_width
	move	22(a0),objc_height
	objc_offset	a3,pop_objc
	objc_change	a3,pop_objc,int_out+2,int_out+4,objc_width,objc_height,#1,#1	inverse video
	cmp	#-1,d4
	bne	sub_menu1	repeat or exit
	
sub_menu3	objc_find	a3,#0,#2,old_x,old_y   find objc selected
	move	int_out,d3	save objc id
	cmp	#-1,d3	skip if no objc selctd
	beq	sub_menu7
	
	objc_locate	tree_id,d3	find objc data
	bclr	#0,11(a0)	clr 'selected' flag
	btst	#3,11(a0)	chk 'disabled' flag
	beq	sub_menu7	skip if objc enabled
	move	#-1,d3	return -1 if disabled
sub_menu7	graf_mouse	#hide	mouse off

	clr	ptsin	copy image to scrn
	clr	ptsin+2
	move	width,ptsin+4
	sub	#1,ptsin+4
	move	height,ptsin+6
	sub	#1,ptsin+6

	move	source_x,ptsin+8
	move	source_y,ptsin+10
	move	source_x,d0
	add	width,d0
	sub	#1,d0
	move	d0,ptsin+12
	move	source_y,d0
	add	height,d0
	sub	#1,d0
	move	d0,ptsin+14
	
	clr.l	dest_mfdb	dest=screen
	move.l	ram_buffer,srce_mfdb
	move	width,srce_mfdb+4
	move	height,srce_mfdb+6
	move	width,d0
	lsr	#4,d0
	add	#1,d0
	move	d0,srce_mfdb+8
	clr	srce_mfdb+10
	move	#1,srce_mfdb+12
	clr	srce_mfdb+14
	clr	srce_mfdb+16
	clr	srce_mfdb+18
	vro_cpyfm	#3,#srce_mfdb,#dest_mfdb

	graf_mouse	#show	mouse on

	m_free	ram_buffer	release RAM
	move	d3,d0	d0=menu item
	bra	sub_menu6	& exit

sub_menu5	move.l	#-1,d0	RAM error
sub_menu6	movem.l	(sp)+,d1-d4/a0-a4
	rts
	
;             -------------- Library Sub-Routines -----------

;Set up a message in a text object form
;ENTRY a3=address of object
;      d3=object index
;      a4=source string
;EXIT  text copied to form

set_tedinfo	movem.l	a0/a4/d0/d2,-(sp)
	move	d3,d0
	mulu	#24,d0
	lea	0(a3,d0),a0	load a0 with object addr
	move.l	12(a0),a0	fetch text addr
	move	24(a0),d2
	sub	#1,d2
	move.l	(a0),a0
set_tedinfo1	move.b	(a4)+,d0
	beq	set_tedinfo2
	move.b	d0,(a0)+
	dbra	d2,set_tedinfo1
set_tedinfo3	movem.l	(sp)+,a0/a4/d0/d2
	rts

set_tedinfo2	clr.b	(a0)
	bra	set_tedinfo3

;compare routine
;ENTRY d0.w=value to compare
;      in-line data=no of words to test
;                  =first word
;                  =first address
;                  =etc
;EXIT  program jumps to new address or
;      continues

compare	movem.l	a0/d1,-(sp)
	move.l	8(sp),a0
	move	(a0)+,d1
	subq	#1,d1
compar1	cmp	(a0)+,d0
	beq	compar3
	addq.l	#4,a0
	dbra	d1,compar1
compar2	move.l	a0,8(sp)
	movem.l	(sp)+,a0/d1
	rts
	
compar3	move.l	(a0),a0
	bra	compar2

	include	text.s
		
	SECTION	data	global constants

;Fixed data (look-up tables, messages, etc) go in here
	
	SECTION	bss	temporary data

;++++++ Pop up stores +++++++++++

width	ds.w	1	form width (pix)
height	ds.w	1	form height (pix)
objc_width	ds.w	1	objc width
objc_height	ds.w	1
pop_x	ds.w	1	mouse x co-ord
pop_y	ds.w	1	mouse y co-ord
source_x	ds.w	1	x co-ord of box
source_y	ds.w	1	y co-ord of box
old_x	ds.w	1	old x co-ord
old_y	ds.w	1	old y co-ord
tree_id	ds.w	1	tree ident
pop_objc	ds.w	1	current object
ram_buffer	ds.l	1	addr of RAM buff
srce_mfdb	ds.b	20
dest_mfdb	ds.w	20

;++++++++++++++++++++++++++++++++

pop_buff	ds.b	16	return buffer
current_objc	ds.w	1
current_img	ds.w	1
scr_width	ds.w	1
scr_height	ds.w	1

ap_id	ds.w 	1	application ident
w_handle	ds.w 	1	main window handle
m_buffer	ds.b	30

	ds.l	100	stack space (400 bytes)
stack	ds.w	1	(stacks go backwards)

	include	aeslib.s
	include	vdilib.s
