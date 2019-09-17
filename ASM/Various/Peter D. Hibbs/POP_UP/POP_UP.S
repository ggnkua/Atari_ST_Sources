
;MACRO definitions (move these to start of source code)

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

;------------------ Sub-routine -------------------

REG	equ	9*4	9 registers saved
hide	equ	256	hide mouse code
show	equ	257	show mouse code

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

	
	SECTION	bss	(Move these to BSS section)

;++++++ Pop up stores +++++++++++

width	ds.w	1	form width (pix)
height	ds.w	1	form height (pix)
objc_width	ds.w	1	objc width
objc_height	ds.w	1	objc height
pop_x	ds.w	1	mouse x co-ord
pop_y	ds.w	1	mouse y co-ord
source_x	ds.w	1	x co-ord of box
source_y	ds.w	1	y co-ord of box
old_x	ds.w	1	old x co-ord
old_y	ds.w	1	old y co-ord
tree_id	ds.w	1	tree ident
pop_objc	ds.w	1	current object
ram_buffer	ds.l	1	addr of RAM buff
srce_mfdb	ds.b	20	vro_cpyfm stores
dest_mfdb	ds.w	20	    "        "
