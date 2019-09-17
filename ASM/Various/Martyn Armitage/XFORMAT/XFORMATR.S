*****************************************************************
*								*
*	Disk Formatter, allows user to select format		*
*	Also the disk is immunised against virus'		*
* ============================================================= *
*								*
*	Programmer : Martyn Armitage				*
*	Started	   : 22/07/1989					*
*	Finished   :						*
*	Updated    :						*
* ============================================================= *
*	Language   : Assembler					*
*	Assembler  : Hisoft Devpac 2				*
*								*
*****************************************************************
		opt	o+,p+,w-	optimise,posn ind,no warnings

stack_len	equ	2048		stack length

		include	xformatr.i	resource file equates

* the first variable, DO NOT REMOVE OR PLACE RS.x's BEFORE IT!!!
first_var	rs.w	1	
ap_id		rs.w	1	application id
ghandle		rs.w	1	graphics handle
scr_res		rs.w	1	screen resolution
scrn_addr	rs.l	1	address of screen
device		rs.w	1	device id
ws_handle	rs.w	1	workstation handle
stack_ptr	rs.l	1	temp storage for return address

*---------------
program		bra	the_beginning	branch to program start

* the GEM & VDI include files

		include	vdiinc.s
		include	geminc.s

*---------------
the_beginning	move.l	4(a7),a5	get address of BASEPAGE
		move.l	24(a5),a6	start of BSS section
		move.l	a6,sp		copy BSS start to SP
		add.l	28(a5),sp	add BSS len - SP points to end of BSS
		move.l	12(a5),d0	get length of TEXT area
		add.l	20(a5),d0	add length of DATA area
		add.l	28(a5),d0	add length of BSS area
		add.l	#$100,d0	add length of BASE PAGE
		move.l	d0,-(sp)	length of memory to keep
		move.l	a5,-(sp)	start address of mem to keep
		clr.w	-(sp)		filler
		move.w	#$4a,-(sp)	MSHRINK
		trap	#1
		lea	12(sp),sp
		tst.l	d0		error
		bpl.s	memory_ok1	no
		pea	no_mem_mssg(pc)
		bsr	print_mssg
		bsr	get_key
		bra	terminate_prog		quit

memory_ok1	bsr	set_vdi_p		init vdi arrays etc
		bsr	set_gem_p		init vdi arrays etc

* initialise application
		gem	APPL_INIT		get application id
		move.w	d0,ap_id(a6)		save it

* get graphics handle
		gem	GRAF_HANDLE		get graphics handle
		move.w	d0,ghandle(a6)		save it
		bsr	hide_mouse		hide mouse
		move.w	#4,-(sp)		get res
		trap	#14
		addq.l	#2,sp
		move.w	d0,scr_res(a6)		save screen resolution
		bne.s	res_ok			not lo res
		lea	res_error(pc),a0	message
		move.w	#1,d0			first button default
		bsr	alert_box
		bra.s	quit_program		quit

		SECTION	DATA
res_error	dc.b	'[2][This program can not|'
		dc.b	'operate in Low Res!|'
		dc.b	' |Sorry ][ Ok ]',0
		SECTION	TEXT

* get the address of the screen
res_ok		move.w	#2,-(sp)		Physbase
		trap	#14
		addq.l	#2,sp
		move.l	d0,scrn_addr(a6)	save address

* open a workstation
		moveq	#9,d0			init counter
		lea	intin(a6),a0		addr of array
open_wkst	move.w	#1,(a0)+
		dbra	d0,open_wkst		loop till done
		move.w	#2,intin+20(a6)		use raster coords
		clr.w	contrl+2(a6)		length of ptsin
 		move.w	#11,contrl+6(a6)	length of intin
		clr.w	contrl+12(a6)		device number
		vdi	V_OPNVWK		open virtual workstation
		move.w	contrl+12(a6),d0	get device handle
		move.w	d0,ws_handle(a6)	save handle
		move.w	d0,device(a6)		save device id

* now run the users program
		bsr	user_prog		execute the program

* now close the workstation
		move.w	#3,d0			init counter
		lea	contrl(a6),a0		array address
		move.w	#101,(a0)+		opcode
close_wkst	clr.w	(a0)+
		dbra	d0,close_wkst		loop till done
		move.w	ws_handle(a6),contrl+12(a6)	device id
		vdi	V_CLSVWK		close it
quit_program	gem	APPL_EXIT		exit

* return to the DESKTOP or calling program
terminate_prog	clr.w	-(sp)			two byte message
		move.w	#$4c,-(sp)		PTERM
		trap	#1			return to caller

* get a key press
get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

* print a message to screen
* put message address on stack before calling
print_mssg	move.l	(sp)+,stack_ptr(a6)	save return address
		move.w	#9,-(sp)		opcode
		trap	#1
		addq.l	#2,sp
		move.l	stack_ptr(a6),-(sp)	return address
		rts

		SECTION	DATA
no_mem_mssg	dc.b	27,'EThere is insuffiecient memory',10,13
		dc.b	'for this application.',10,13
		dc.b	'Press any key to quit',0
		even
		SECTION	TEXT

* include the library files
		include	window.s	window handling file
		include	cls.s		clear screen
		include	rdr_evnt.s	redraw code
		include	w_event.s	wait events
		include	mouse.s		mouse code
		include	dialog.s	dialog box code
		include	objcstat.s	object status code
		include	lhex_asc.s	binary to ascii

* display an alert box
alert_box	move.w	d0,int_in(a6)		default button
		move.l	a0,addr_in(a6)		address of alert string
		gem	FORM_ALERT		display it
		rts

		DATA
resource_name	dc.b	'XFORMATR.RSC',0
		even
program_name	dc.b	' Disk Formatter V1.1 (C)1991 Martyn Armitage ',0
		even
		TEXT

fbar_addr	rs.l	1		address of object
fslider_addr	rs.l	1		ditto

*---------------
user_prog	bsr	init_variables		initialise preset vars

* load the resource file
		lea	resource_name(pc),a0	file name
		move.l	a0,addr_in(a6)
		gem	RSRC_LOAD
		bne.s	rsc_loaded		no error

* error loading rsc file
		lea	rsc_msg(pc),a0
		move.w	#1,d0
		bsr.s	alert_box
		rts

		DATA
rsc_msg		dc.b	'[2][There seems to be a|'
		dc.b	'problem with the|'
		dc.b	'Resource File.|'
		dc.b	'Cant continue without it!]'
		dc.b	'[ Abort ]',0

format_addr	dc.l	format_dial
formatting_addr	dc.l	formatting_dial
diskname_addr	dc.l	diskname_str
		TEXT

* get the address' of the menubar and 2 dialog boxes
rsc_loaded	lea	format_addr(pc),a5	table address
		moveq	#1,d7			init count
get_address	clr.w	int_in(a6)		tree
		move.l	(a5),d0			get index
		move.w	d0,int_in+2(a6)		pass index
		gem	RSRC_GADDR		get address
		move.l	addr_out(a6),(a5)+	store address
		dbra	d7,get_address

* get the address of the diskname string
		move.l	format_addr(pc),a0	tree address
		clr.w	d0			address passed
		move.w	#diskname_str,d1	index
		bsr	objc_status		get status
		move.l	(a1),a1			get string address
		move.l	a1,(a5)			save address
		clr.b	(a1)			null the name

* get the address of the bars in the formatting dialog
		move.l	formatting_addr(pc),a0	tree address
		move.w	#fbar,d1		object index
		clr.w	d0			address passed
		bsr	objc_status		get status etc
		move.l	a0,fbar_addr(a6)	save address
		move.l	formatting_addr(pc),a0	tree address
		move.w	#fslider,d1		object index
		clr.w	d0			address passed
		bsr	objc_status		get status etc
		move.l	a0,fslider_addr(a6)	save address
		move.w	#NAME,d0
		lea	program_name(pc),a0	name of window
		sub.l	a1,a1			no information line
		moveq	#0,d1			full size
		moveq	#0,d2			window please
		bsr	build_window		build it
		move.w	d0,window_one(a6)	save handle
		bsr	open_wind		open window
		bsr.s	wait_redraw
		bsr	arrow_mouse
		bsr	show_mouse
program_loop	move.l	format_addr(pc),a0	tree address
		move.w	#diskname_str,d0	editable index
		bsr	dialog_box		do the box
		cmp.w	#exit_button,d0		exit pressed ?
		beq	all_done		yes
		bsr.s	get_drive		get drive
		bsr.s	get_tracks		get number of tracks
		bsr	get_sectors		get number of sectors
		bsr	get_sides		get number of sides
		bsr	get_immunise		get immunise flag
		bsr	get_verify		get verify flag
		bsr	get_name		get disk name
		bsr	get_skew		get the skew flag
		bsr	format_disk		do the format
		bpl.s	finish_format		formatted ok, continue
		bsr	arrow_mouse		back to arrow
		bsr	close_dialog		close the box
		bra.s	program_loop		to the main loop
finish_format	bsr	track_zero		write boot sector etc
		bsr	save_disk_name		do the name
		bsr	prepare_fat		write the FAT to disk
		bsr	arrow_mouse		back to arrow
		bsr	close_dialog		close the dialog
		bsr	format_complete		formatting done
		bra.s	program_loop		back to main dialog

* wait for a redraw event
wait_redraw	bsr	wait_event		wait for event
display		bsr	cls			clear the window
		rts

* get the drive to format
get_drive	clr.w	f_drive(a6)		use drive A
		move.l	format_addr(pc),a0	tree address
		clr.w	d0			address passed
		move.w	#drivea,d1		object index
		bsr	objc_status		get status
		btst	#0,d0			selected ?
		bne.s	drive_got		yes
		move.w	#1,f_drive(a6)		use drive B:
drive_got	rts

* get the number of tracks to format
get_tracks	move.w	#80,w_tracks(a6)	format 80 tracks
		move.w	#eighty,w_object(a6)	object index
get_tracks_lp	move.l	format_addr(pc),a0	tree address
		clr.w	d0			tree address passed
		move.w	w_object(a6),d1		object index
		bsr	objc_status		get status
		btst	#0,d0			selected ?
		bne.s	tracks_got		yes
		addq.w	#1,w_object(a6)		next object index
		addq.w	#1,w_tracks(a6)		inc tracks
		bra.s	get_tracks_lp		loop till found
tracks_got	rts

* get the number of sectors to format
get_sectors	move.w	#nine,w_object(a6)	object index
		move.w	#9,w_sectors(a6)	9 sectors
get_sectors_lp	move.l	format_addr(pc),a0	tree address
		clr.w	d0			tree address passed
		move.w	w_object(a6),d1		object index
		bsr	objc_status		get status
		btst	#0,d0			selected ?
		bne.s	sectors_got		yes
		addq.w	#1,w_object(a6)		next object
		addq.w	#1,w_sectors(a6)	inc sectors
		bra.s	get_sectors_lp		loop
sectors_got	move.w	w_sectors(a6),d0	get sectors required
		rts

* get the number of sides
get_sides	clr.w	w_sides(a6)		one side
		move.l	format_addr(pc),a0	tree address
		clr.w	d0			address passed
		move.w	#single,d1		object index
		bsr	objc_status		get status
		btst	#0,d0			selected ?
		bne.s	sides_got		yes
		move.w	#1,w_sides(a6)		two sides
sides_got	rts

* get immunise
get_immunise	move.w	#1,f_immun(a6)		immunise on
		move.l	format_addr(pc),a0	tree address
		clr.w	d0			address passed
		move.w	#immunise_on,d1		object index
		bsr	objc_status		get status
		btst	#0,d0			selected ?
		bne.s	immunise_got		yes
		clr.w	f_immun(a6)		dont immunise
immunise_got	rts

f_immun		rs.w	1		immunise flag

* get the verify flag
get_verify	move.w	#1,f_verify(a6)		verify on
		move.l	format_addr(pc),a0	tree address
		clr.w	d0			address passed
		move.w	#verify_on,d1		object index
		bsr	objc_status		get status
		btst	#0,d0			selected ?
		bne.s	verify_got		yes
		clr.w	f_verify(a6)		no, dont verify
verify_got	rts

f_verify	rs.w	1		verify flag

* get the skew factor
get_skew	move.w	#1,f_skew(a6)		skew on
		move.w	w_sectors(a6),d0	get sec/track
		addq.w	#3,d0			adjust start
		move.w	d0,skew_start(a6)	start sector number
		move.l	format_addr(pc),a0	tree address
		moveq	#0,d0			address passed
		move.w	#skew_on,d1		objec index
		bsr	objc_status		get status
		btst	#0,d0			selected?
		bne.s	skew_got		yes
		clr.w	f_skew(a6)		turn off
		move.w	#1,skew_start(a6)	start sector #
skew_got	rts

* get the disk name if present
get_name	clr.w	f_disk_name(a6)		no name yet
		move.l	diskname_addr(pc),a0	string address
		tst.b	(a0)			string present ?
		beq.s	name_got		no
		move.w	#1,f_disk_name(a6)	name present
name_got	rts

f_disk_name	rs.w	1		disk name present
w_tracks	rs.w	1
w_sectors	rs.w	1		number of sectors to format
w_inter		rs.w	1
w_sides		rs.w	1
w_object	rs.w	1
start_sector	rs.w	1		sector # of first sector

format_disk	bsr	init_f_dialog		initialise the dialog
		move.l	formatting_addr(pc),a0	tree address
		clr.w	d0			no edit text
		bsr	do_dialog		display the dialog
		bsr	bee_mouse		busy bee
		lea	gap1(a6),a0		gap size data block
		cmp.w	#11,w_sectors(a6)	eleven sectors ?
		blo.s	format_t_disk		no, init params for 9/10

* set parameters for 11 sectors			gap 1 size
		move.w	#4,(a0)+		4
		move.w	#3,(a0)+		3
		move.w	#22,(a0)+		22
		clr.w	(a0)			0
		bra.s	f_params_set		all set

* standard TOS format 9/10 sectors		gap 1 size
format_t_disk	move.w	#60,(a0)+		60
		move.w	#12,(a0)+		12
		move.w	#22,(a0)+		22
		move.w	#40,(a0)		40

f_params_set	move.w	w_sectors(a6),f_spt(a6)	sectors to format
		moveq	#0,d0			start track (1)
		move.w	d0,f_side(a6)		format side 1
		move.w	d0,virgin(a6)		virgin data
	lea	sector_list(a6),a0	space for bad sector list
		move.l	a0,sector_list_a(a6)	save address

*---------------
* the format loop
s_next_track	tst.w	w_sides(a6)		double sided?
		beq.s	s_s_virgin		no
		lea	new_virgin(pc),a5	return address
		bra.s	virgin_ok		for d/sided formatting

* first two track of single sided disk formatted to 0's
* single sided format returns to here
s_s_virgin	lea	s_s_virgin1(pc),a5	return address
s_s_virgin1	cmp.w	#2,d0			track 2?
		blo.s	virgin_ok		less than, keep virgin data
new_virgin	move.w	#$e5e5,virgin(a6)	new virgin data
		lea	virgin_ok(pc),a5	new loop address

virgin_ok	move.w	d0,f_track(a6)		track to format
		bsr	super			supervisor mode
		bsr	set_skew		set up skewing
		bsr	format_track		format the track
		bpl.s	side_one_ok		formatted ok

* deal with error
		cmp.w	#-16,d0			bad sectors ?
		bne.s	s_format_error		no
		bsr.s	save_bad_secs		save bad sectors

side_one_ok	move.w	w_sides(a6),d0		get number of sides
		beq.s	s_frmt_one_side		single sided

* format side 2
		bsr	set_skew		set skew for side 2
		move.w	#1,f_side(a6)		format side 2
		bsr.s	format_track		format it
		bpl.s	side_two_ok		side 2 formatted ok

* deal with error
		cmp.w	#-16,d0			bad sectors ?
		bne.s	s_format_error		no
		bsr.s	save_bad_secs		yes, save to list

side_two_ok	clr.w	f_side(a6)		back to side 1
s_frmt_one_side	bsr	user			user mode
		bsr	update_f_dial		update dialog
		move.w	f_track(a6),d0		get track
		addq.w	#1,d0			inc count
		cmp.w	w_tracks(a6),d0		tracks done ?
		beq.s	trks_done		yes
		jmp	(a5)			no, loop

trks_done	move.l	sector_list_a(a6),a0	list pointer
		move.w	#-1,(a0)+		end of table
		moveq	#0,d0			no error
		rts

s_format_error	bsr	user
		bsr	reset_drive		reset drive light etc
		bsr	arrow_mouse		back to arrow
		bsr	close_dialog		close the dialog
		lea	format_err(pc),a0	alert string
		move.w	#1,d0			first buton
		bsr	alert_box		do box
		move.w	#-1,d0			error
		rts

		SECTION	DATA
format_err	dc.b	'[3][An error has occurred|'
		dc.b	'whilst formatting the|'
		dc.b	'disk!][ Ok ]',0
		SECTION	TEXT

* save the list of bad sectors
save_bad_secs	move.l	sector_list_a(a6),a0	list pointer
		lea	bad_sector_list(a6),a1	list for this track
		move.w	f_side(a6),(a0)+	save side id
		move.w	f_track(a6),(a0)+	save track id
next_b_sec	move.w	(a1)+,(a0)+		get sector number
		bne.s	next_b_sec		loop till null found
		move.l	a0,sector_list_a(a6)	save pointer
		rts

* FLOPFMT, FORMAT A TRACK
format_track	MOVEM.L	D3-D7/A3-A6,reg_save(a6)	save registers
		LEA	$FFFF8606.w,A5		fdc address
		move.w	#-1,disk_error(a6)	default error
		move.w	#1,$43E.w		disable floppy vbl
		move.w	#2,retry(a6)		retry count
		bsr	sel_drive_side		select drive and side
		bsr	set_dma			set buffer address
		bsr	hseek			seek track
		bne	floppy_fail		error, not found
		move.w	#-10,disk_error(a6)	write error
		bsr	init_buffer		initialise the buffer
		bsr	set_dma			set dma address
		bsr.s	write_track
		bne	floppy_fail		command failed

* track formatted ok, so verify it
		move.w	f_spt(a6),v_count(a6)	SPT AS COUNT
		move.w	#1,v_sector(a6)		START AT SECTOR 1
		bsr	verify_track		verify the track
		lea	bad_sector_list(a6),a2	BAD SECTOR LIST
		tst.w	(a2)			BAD SECTOR ?
		beq	floppy_ok		NO, FLOPOK
		move.w	#-16,disk_error(a6)	BAD SECTORS
		bra	floppy_fail		FLOPFAIL ERROR

*---------------
* format the track
write_track	move.w	#$190,(a5)	{ clear
		move.w	#$90,(a5)	{ dma
		move.w	#$190,(a5)	{ status
		move.w	#$1F,D7		SECTOR COUNT TO 31
		bsr	write_d7_fdc	WRITE TO 1772
		move.w	#$180,(a5)	SELECT 1772
		move.w	#$F0,D7		FORMAT TRACK COMMAND
		bsr	write_d7_fdc	WRITE TO 1772
		MOVE.L	#$40000,D7	TIME OUT COUNTER
format_wait	BTST	#5,$FFFFFA01.w	1772 DONE ?
		BEQ.S	read_dma_status	YES
		SUBQ.L	#1,D7		DEC TIME OUT
		BNE.S	format_wait	SOME TIME LEFT
		bsr	reset_fdc	timeout, RESET & TERMINATE
format_done	MOVEQ	#1,D7		CLEAR Z-BIT
		RTS			DONE

read_dma_status	move.w	#$190,(a5)	SELECT DMA STATUS
		move.w	(a5),D0		READ STATUS
		BTST	#0,D0		DMA ERROR ?
		BEQ.S	format_done	YES
		move.w	#$180,(a5)	SELECT 1772 STATUS REG
		bsr	read_d0_fdc	READ REGISTER
		bsr	calc_err_num	CALC ERROR NUMBER
		AND.B	#$44,D0		TEST WRITE PROTECT, LOST DATA
		rts

*---------------
* initialise the buffer ready for writing to the disk
init_buffer	move.l	dma_buffer(a6),a2	track buffer
		move.w	skew_start(a6),d4	first sector number

* initialise the track data
		move.w	gap1(a6),d0		gap length
		move.b	#$4e,d7			value to write
		bsr	write_to_buff		to buffer
		move.w	f_spt(a6),d6		get sector count
		subq.w	#1,d6			adjust	
makt1		move.w	gap2(a6),d0		length to write
		clr.w	d7			nulls
		bsr.s	write_to_buff		to buffer
		move.w	#3,d0			three sync bytes
		move.w	#$f5,d7			$f5's
		bsr.s	write_to_buff		to buffer
		move.b	#$fe,(a2)+		index address mark
		move.b	f_track+1(a6),(a2)+	track number to buffer
		move.b	f_side+1(a6),(a2)+	side number to buffer
		move.b	d4,(a2)+		sector number to buffer
		move.b	#2,(a2)+		sector size (512)
		move.b	#$f7,(a2)+		write CRC
		move.w	gap3(a6),d0		(22) gap size
		move.w	#$4e,d7			value to write
		bsr.s	write_to_buff		to buffer
		move.w	#12,d0			gap size
		clr.w	d7			value to write
		bsr.s	write_to_buff		to buffer
		move.w	#3,d0			3 sync bytes to write
		move.w	#$f5,d7			value to write
		bsr.s	write_to_buff		to buffer
		move.b	#$fb,(a2)+		data mark to buffer
		move.w	#512,d0			count (sector length)
		move.b	virgin(a6),d7		value to write
		bsr.s	write_to_buff		to buffer
		move.b	#$f7,(a2)+		CRC to buffer
		move.w	gap4(a6),d0		length of gap 4
		move.w	#$4e,d7			value to write
		bsr.s	write_to_buff		write to buffer

* loop till all sectors written
		addq.w	#1,d4			inc sector number
		cmp.w	f_spt(a6),d4		used last sector number?
		bls.s	sector_num_ok		not yet
		moveq	#1,d4			reset sector number
sector_num_ok	dbra	d6,makt1
		move.l	dma_buff_end(a6),d0	calc gap 5 length
		sub.l	a2,d0			get distance to end
		move.w	#$4e,d7			value
		bsr.s	write_to_buff		write it
		rts

first_sector	rs.w	1	number of first sector to write

*---------------
* write the byte in 'D7' to the track buffer 'D0' times
write_to_buff1	move.b	d7,(a2)+
write_to_buff	dbra	d0,write_to_buff1
		rts

*---------------
* set up skewing
set_skew	tst.w	f_skew(a6)		skewing?
		beq.s	no_skewing		no
		move.w	skew_start(a6),d0	get start sector
		subq.w	#3,d0			adjust
		bgt.s	sec_skew_ok		not -ve or 0
		move.w	f_spt(a6),d0		get # sectors
sec_skew_ok	move.w	d0,skew_start(a6)	save sector #
no_skewing	rts

skew_start	rs.w	1	start sector # for skewing

*---------------
* CALCULATE ERROR NUMBER
calc_err_num	MOVEQ	#-$D,D1
		BTST	#6,D0
		BNE.S	save_err_num
		MOVEQ	#-8,D1
		BTST	#4,D0
		BNE.S	save_err_num
		MOVEQ	#-4,D1
		BTST	#3,D0
		BNE.S	save_err_num
		move.w	#-1,D1
save_err_num	move.w	D1,disk_error(a6)
		RTS

* write the disk name to disk
save_disk_name	tst.w	f_disk_name(a6)		name present ?
		beq.s	no_name			no
		move.w	f_drive(a6),-(sp)	get drive number
		move.w	#$e,-(sp)		set it
		trap	#1
		addq.l	#4,sp
		move.l	diskname_addr(pc),a0	string address
		lea	name_buff(a6),a1	dest addr
		move.l	a1,a2			copy address
		move.w	#7,d7			loop count	
cop_name	move.b	(a0)+,d0		get char
		beq.s	end_fnd			end found
		cmp.b	#' ',d0			space ?
		beq.s	spc_fnd1		yes
		move.b	d0,(a1)+		copy char
		dbra	d7,cop_name		copy
		bra.s	cop_ext
spc_fnd		addq.l	#1,a0
spc_fnd1	dbra	d7,spc_fnd
cop_ext		move.b	#'.',(a1)+		period
		move.w	#2,d7
cop_ext1	move.b	(a0)+,(a1)+
		dbeq	d7,cop_ext1
end_fnd		move.w	#8,-(sp)		disk name
		move.l	a2,-(sp)		address of filename
		move.w	#$3c,-(sp)		opcode
		trap	#1
		addq.l	#8,sp
		tst.w	d0			error
		bmi.s	name_error		yes
		move.w	d0,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		rts

name_buff	rs.b	14

name_error	lea	name_err(pc),a0
		move.w	#1,d0
		bsr	alert_box
no_name		rts

		DATA
name_err	dc.b	'[3][There may be a problem with|'
		dc.b	'the disk just formatted.|'
		dc.b	'It is not possible to write|'
		dc.b	'the diskname you specified.|'
		dc.b	'The disk has not been named.]'
		dc.b	'[ Ok ]',0
		TEXT

* VERIFY DISK SECTORS
verify_track	lea	bad_sector_list(a6),a2	baad sector list
		tst.w	f_verify(a6)		verify track ?
		bne.s	do_verify		yes
		clr.w	(a2)			no error
		rts

do_verify	move.w	#-11,disk_error(a6)	READ ERROR
verify_sector	move.w	#2,retry(a6)		RETRY COUNT
		move.w	#$84,(a5)		SELECT SECTOR REG
		move.w	v_sector(a6),D7		SECTOR NUMBER
		bsr	write_d7_fdc		WRITE TO 1772
retry_s_verify	bsr	set_dma			set dma address
		move.w	#$90,(a5)		{ CLEAR
		move.w	#$190,(a5)		{ DMA
		move.w	#$90,(a5)		{ STATUS
		move.w	#1,D7			SECTOR COUNT TO 1
		bsr	write_d7_fdc		WRITE TO 1772
		move.w	#$80,(a5)		1772 COMMAND REG
		move.w	#$80,D7			READ SECTOR
		bsr	write_d7_fdc		WRITE TO 1772
		MOVE.L	#$40000,D7		TIMEOUT COUNTER
wait_sectr_read	BTST	#5,$FFFFFA01.w		1772 DONE ?
		BEQ.S	sector_read_ok		YES
		SUBQ.L	#1,D7			DEC TIME OUT COUNTER
		BNE.S	wait_sectr_read		STILL SOME TIME LEFT
		bsr	reset_fdc		RESET 1772, TERMINATE
		BRA.S	v_try_again		NEXT TRY

sector_read_ok	move.w	#$90,(a5)		DMA STATUS REG
		move.w	(a5),D0			READ IT
		BTST	#0,D0			DMA ERROR ?
		BEQ.S	v_try_again		YES, TRY AGAIN
		move.w	#$80,(a5)		1772 STATUS REG
		bsr	read_d0_fdc		READ IT
		bsr	calc_err_num		CALC ERROR NUMBER
		AND.B	#$1C,D0			TEST RNF, CRC, LOST DATA
		BNE.S	v_try_again		ERROR, NEXT TRY

verify_n_sect	ADDQ.W	#1,v_sector(a6)		NEXT SECTOR
		SUBQ.W	#1,v_count(a6)		DEC SECTOR COUNT
		BNE.s	verify_sector		ANOTHER SECTOR ?
		CLR.W	(A2)			TERMINATE BAD SECTOR LIST
		RTS				DONE

v_try_again	nop	
do_retry	SUBQ.W	#1,retry(a6)		DEC RETRY COUNT
		BPL.s	retry_s_verify		ANOTHER TRY
		move.w	v_sector(a6),(A2)+	SECTOR NUMBER TO SECTOR LIST
		BRA.S	verify_n_sect		NEXT SECTOR

* FLOPFAIL
floppy_fail	move.w	disk_error(a6),D0	get error number
		EXT.L	D0			sign extend
		BRA.S	floppy_ok1

* FLOPOK
floppy_ok	CLR.L	D0			no error
floppy_ok1	MOVE.L	D0,-(sp)		save error number
		move.w	#$86,(a5)		select 1772		
		move.w	f_track(a6),D7		get track number
		bsr	write_d7_fdc
		move.w	#$10,D6			seek command
		bsr.s	flop_cmds
		MOVE.L	(sp)+,D0		get error number
		MOVEM.L	reg_save(a6),D3-D7/A3-A6
		CLR.W	$43E.w			release floppy vbl
		tst.l	d0			error ?
		RTS

* FIND TRACK ZERO
seek_track_zero	CLR.W	D6		seek track zero command
		bsr.s	flop_cmds	write to fdc
		BNE.S	s_t_z_error	error
		BTST	#2,D7		test track 0 bit
		EORI.B	#4,CCR		invert z-flag
s_t_z_error	RTS

* HSEEK, FIND TRACK
* find the track passed in 'F_TRACK'
hseek		move.w	#-6,disk_error(a6)	error number
		move.w	f_track(a6),D7		track number
		move.w	#$86,(a5)		data reg
		bsr	write_d7_fdc		write d7 to fdc
		move.w	#$10,D6			seek command

* FLOPCMDS
flop_cmds	move.w	seek_rate(a6),D0	disk seek rate
		AND.B	#3,D0			keep bits 0-1
		OR.B	D0,D6			or onto command
		MOVE.L	#$40000,D7		time out value
		move.w	#$80,(a5)		select 1772
		bsr	read_d0_fdc		read fdc status		
		BTST	#7,D0			motor on ?
		BNE.S	delay_ok		yes
		MOVE.L	#$60000,D7		longer delay, for motor
delay_ok	bsr	write_d6_fdc		write command
cmds_wait	SUBQ.L	#1,D7			dec time out
		BEQ.S	cmds_error		zero reached then error
		BTST	#5,$FFFFFA01.w		fdc done ?
		BNE.S	cmds_wait		no
		bsr	read_d7_fdc		read fdc
		CLR.W	D6			no error
		RTS

cmds_error	bsr.s	reset_fdc		reset fdc
		MOVEQ	#1,D6			error
		RTS

* RESET 1772, RESET FLOPPY CONTROLLER
reset_fdc	move.w	#$80,(a5)
		move.w	#$D0,D7
		bsr.s	write_d7_fdc
		move.w	#$F,D7
reset_delay	DBF	D7,reset_delay
		bsr.s	read_d7_fdc
		RTS

* reset the drive and side
reset_drive	bsr	super			supervisor mode
		lea	$ffff8606.w,A5		fdc address

* wait for the motor to stop
wait_motor	move.w	#$80,(a5)		select 1772
		bsr.s	read_d0_fdc		read fdc status		
		BTST	#7,D0			motor on ?
		BNE.S	wait_motor		yes
		move.w	#7,d0			set bits for active low
		bsr.s	dsel_drive_side		deselect
		bsr	user			user mode
		rts				done

* SELECT DRIVE AND SIDE
sel_drive_side	move.w	f_drive(a6),d0		get drive id
		ADDQ.B	#1,D0			adjust number
		LSL.B	#1,D0			move left
		OR.W	f_side(a6),d0		include side id
		EORI.B	#7,D0			invert bits for act_low
		AND.B	#7,D0			keep bits 0-2

* SET PORT A, SELECT DRIVE AND SIDE
dsel_drive_side	MOVE	SR,-(sp)
		ORI.W	#$700,SR
		MOVE.B	#$E,$FFFF8800.w
		MOVE.B	$FFFF8800.w,D1
		AND.B	#$F8,D1
		OR.B	D0,D1
		MOVE.B	D1,$FFFF8802.w
		move.w	(sp)+,SR
		RTS

* set the buffer address in the dma
set_dma		MOVE.B	dma_buffer+3(a6),$FFFF860D.w
		MOVE.B	dma_buffer+2(a6),$FFFF860B.w
		MOVE.B	dma_buffer+1(a6),$FFFF8609.w
		RTS

* WRITE 'D6' TO FDC
write_d6_fdc	bsr.s	fdc_delay
		move.w	D6,$FFFF8604.w
		BRA.S	fdc_delay

* WRITE 'D7' TO FDC
write_d7_fdc	bsr.s	fdc_delay
		move.w	D7,$FFFF8604.w
		BRA.S	fdc_delay

* READ FDC TO 'D7'
read_d7_fdc	bsr.s	fdc_delay
		move.w	$FFFF8604.w,D7
		BRA.S	fdc_delay

* READ FDC TO 'D0'
read_d0_fdc	bsr.s	fdc_delay
		move.w	$FFFF8604.w,D0

* DO A DELAY FOR THE FDC
fdc_delay	MOVE	SR,-(sp)
		move.w	D7,-(sp)
		move.w	#$20,D7
fdc_delay1	DBF	D7,fdc_delay1
		move.w	(sp)+,D7
		move.w	(sp)+,SR
		RTS

* start and end address of the dma buffer (format)
dma_buffer	rs.l	1
dma_buff_end	rs.l	1

* space for the sizes of the gaps
gap1		rs.w	1
gap2		rs.w	1
gap3		rs.w	1
gap4		rs.w	1
seek_rate	rs.w	1	seek rate
virgin		rs.w	1	virgin data for format
f_drive		rs.w	1	drive to format
f_track		rs.w	1	track to format
f_side		rs.w	1	side to format
f_spt		rs.w	1	sectors per track to format
f_inter		rs.w	1	interleave to use
f_skew		rs.w	1	skew flag
v_sector	rs.w	1	sector to verify
v_count		rs.w	1	number of sectors to verify
disk_error	rs.w	1	error number
retry		rs.w	1	retry count
sector_list_a	rs.l	1	address of disk list
bad_sector_list	rs.w	20	space for list of bad sectors
reg_save	rs.l	16	space for saving registers

* initialise the formatting dialog
init_f_dialog	move.w	w_tracks(a6),d0		number of tracks
		move.w	d0,d1			copy value
		mulu	#3,d0			three pixels per track
		addq.w	#2,d0			one pixel border
		move.l	fbar_addr(a6),a0	tree address
		move.l	fslider_addr(a6),a1	tree address
		move.w	d0,20(a0)		width of bar
		move.w	#1,20(a1)		width of slider
		bset	#7,9(a1)		hide tree
		move.w	#$11a3,14(a1)		green
		cmp.w	#80,d1			80 tracks
		beq.s	colour_set		yes
		move.w	#$11a2,14(a1)		red
colour_set	rts

* update the formatting dialog box
update_f_dial	move.l	fslider_addr(a6),a4	tree address
		bclr	#7,9(a4)
		addq.w	#3,20(a4)		inc width
		move.w	#fslider,d0		object
		move.w	d0,d1			depth
		bsr	draw_object		draw the object
		rts

* initialise track 0
* create a boot sector etc
track_zero	clr.w	-(sp)			not executable
		move.w	w_sides(a6),d0		get sides formatted
		addq.w	#2,d0			convert to disk type
		move.w	d0,-(sp)		pass disk type
		move.l	#$1000000,-(sp)		random disk number
	pea	format_buffer(a6)	buffer address
		move.w	#18,-(sp)		opcode
		trap	#14
		lea	14(sp),sp

* pass number of sectors to boot sector
	lea	format_buffer(a6),a0	buffer address
		move.w	w_sides(a6),d0		get number of sides
		addq.w	#1,d0			adjust side count
		mulu	w_tracks(a6),d0		get total no. tracks
		mulu	f_spt(a6),d0		calc total sectors
		move.b	d0,19(a0)		low byte first
		lsr.w	#8,d0			move a byte right
		move.b	d0,20(a0)		high byte

* pass number of sectors per track
		move.w	f_spt(a6),d0		get sectors formatted
		move.b	d0,24(a0)		low byte
		lsr.w	#8,d0
		move.b	d0,25(a0)		high byte
		move.b	#3,22(a0)		3 sectors per fat

* immunise the disk if required
		tst.w	f_immun(a6)		immunise the disk ?
		beq.s	dont_immun		no
		move.w	#$601c,(a0)		bra.s + 30 bytes
		move.w	#$4e75,30(a0)		rts 

* calc magic for executing boot sector
		moveq	#0,d0			clear counter
		move.w	#254,d7			loop counter
calc_loop	add.w	(a0)+,d0
		dbra	d7,calc_loop
		move.w	#$1234,d1
		sub.w	d0,d1
		move.w	d1,(a0)			value to add for magic

* write the boot sector
dont_immun	move.w	#1,-(sp)		one sector
		clr.w	-(sp)			side 0
		clr.w	-(sp)			track 0
		move.w	#1,-(sp)		sector 1
		move.w	f_drive(a6),-(sp)	drive
		clr.l	-(sp)
	pea	format_buffer(a6)
		move.w	#9,-(sp)
		trap	#14
		lea	20(sp),sp
		tst.w	d0
		rts

* format done display dialog box etc
format_complete	move.w	f_drive(a6),d0		current drive
		addq.w	#1,d0
		move.w	d0,-(sp)		drive id
		pea	free_buff(a6)		buffer address
		move.w	#$36,-(sp)
		trap	#1
		addq.l	#8,sp
		lea	free_buff(a6),a0	buffer address
		move.l	(a0),d0			get free clusters
		move.l	8(a0),d1		get bytes per sector
		move.l	12(a0),d2		get sectors per cluster
		mulu	d1,d2			calc bytes per cluster
		mulu	d2,d0			calc bytes free
		bsr	lhex_asc		convert to ascii string
		lea	num_buffer(a6),a0	buffer address
		lea	bytes_free(pc),a1	dest addr
		moveq	#8,d7			14 digits (inc BYTES )
copy_bytes_f	move.b	(a0)+,(a1)+
		beq.s	null_cpid		end found
		subq.w	#1,d7			dec counter
		bra.s	copy_bytes_f
null_cpid	move.b	#' ',-1(a1)		conv to space
		subq.w	#1,d7			dec counter
		move.b	#'b',(a1)+
		move.b	#'y',(a1)+
		move.b	#'t',(a1)+
		move.b	#'e',(a1)+
		move.b	#'s',(a1)+
copy_spcs	move.b	#' ',(a1)+
		dbra	d7,copy_spcs
		lea	disk_space(pc),a0
		move.w	#1,d0
		bsr	alert_box
		rts

free_buff	rs.b	16

		DATA
disk_space	dc.b	'[1][This disk has '
bytes_free	dc.b	'9999999 bytes |'
		dc.b	'available to the user.][ Ok ]',0
		TEXT

* write the FAT to the disk marking any sectors that may be bad
* the FAT is always at SIDE 0, TRACK 0, SECTOR 2; ACCORDING TO THE BOOK
prepare_fat	moveq	#0,d0			clea reg
		move.w	#3,-(sp)		3 sectors
		move.l	d0,-(sp)		side 0 track 0
		move.w	#2,-(sp)		sector 2
		move.w	f_drive(a6),-(sp)	drive
		move.l	d0,-(sp)		filler
	pea	format_buffer(a6)	buffer address
		move.w	#8,-(sp)		opcode
		trap	#14			read the fat
		lea	20(sp),sp
	lea	format_buffer(a6),a0	point to buffer
		move.w	#$f7ff,(a0)		to buffer } 1st 3 bytes
		move.b	#$ff,2(a0)		to buffer } always $7FFFFF

	lea	sector_list(a6),a1	address of bad list
next_f_sec	move.w	(a1)+,d0		get entry
		cmp.w	#-1,d0			last entry ?
		beq.s	write_fat		yes, all done
		move.w	(a1)+,d1		get side number
		move.w	(a1)+,d2		get track number
get_f_sec	move.w	(a1)+,d3		get sector number
		beq.s	next_f_sec		null, get next entry
		bsr.s	busy_fat_entry		make this sector busy
		bra.s	get_f_sec		get next faulty sector

* now write the fat back to the disk
write_fat	moveq	#0,d0			clea reg
		move.w	#3,-(sp)		3 sectors
		move.l	d0,-(sp)		side 0 track 0
		move.w	#2,-(sp)		sector 2
		move.w	f_drive(a6),-(sp)	drive
		move.l	d0,-(sp)		filler
	pea	format_buffer(a6)	buffer address
		move.w	#9,-(sp)		opcode
		trap	#14			write the fat
		lea	20(sp),sp
		rts

* make the fat entry busy
* the details of the faulty sector are in:
* D1 = side number (0 or 1)
* D2 = track number (0 to ??)
* D3 = sector number (1 to ??)
* A0 points to the start of the FAT data
* A1 points to the faulty sector data
* A0 and A1 must be preserved
busy_fat_entry	nop

		rts

* goto supervisor mode if not already in it
super		move.l	#1,-(sp)		get mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.w	d0			supervisor ?
		bne.s	super1			yes
		clr.l	-(sp)			set mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,user_stack(a6)	save user stack
super1		rts

* goto user mode if not already in it
user		move.l	#1,-(sp)		get mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.w	d0			in user ?
		beq.s	user1			yes
		move.l	user_stack(a6),-(sp)	set usermode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
user1		rts

all_done	gem	RSRC_FREE		remove the resource file
		move.w	window_one(a6),d0	handle
		bsr	close_wind		close the window
		move.w	window_one(a6),d0	handle
		bsr	delete_wind		delete it
		rts				back and quit program

window_one	rs.w	1	handle of first window

* initialise all of the required variables
init_variables	move.l	#99,start_ob(a6)	init start/depth
		move.w	#MU_MESAG,event_type(a6)
		move.w	#1,f_inter(a6)		interleave
		move.w	#1,seek_rate(a6)	seek rate 3ms
		clr.w	f_drive(a6)		drive a
	lea	format_buffer(a6),a0	format buffer
		move.l	a0,dma_buffer(a6)	save buffer address
		lea	8000(a0),a0		buffer end address
		move.l	a0,dma_buff_end(a6)	save address
		rts

*---------------
user_stack	rs.l	1	storage address of user stack
format_buffer	rs.w	4000	space for format buffer
sector_list	rs.w	2400	space for bad sector list
stack_space	rs.b	stack_len		2k should do

* the very last RS variable DO NOT REMOVE OR PLACE RS.x's AFTER IT!!!
vars_end	rs.w	1

		SECTION BSS
reserved_space	ds.b	vars_end-first_var
		SECTION TEXT
	