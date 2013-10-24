***************************************************************************
*                    MASTER SOUND demo packer utility                     *
*                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                     *
*                                                                         *
*                             Written by                                  *
*                                                                         *
*                            MAC SYS DATA                                 *
*                                of                                       *
*                      PERSISTENCE OF VISION                              *
*                                                                         *
*                             22/12/90                                    *
*                                                                         *
*              Assemble with GENST2 version 2.08 or higher                *
*                                                                         *
***************************************************************************

	move.l	sp,a5
	move.l	#stack_end,sp
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	beq.s	restart
	clr.w	-(sp)
	trap	#1


restart
	lea	warning_message,a0
	bsr	print_string
	bsr	press_key
	lea	cls,a0
	bsr	print_string

	bsr	get_rez
	bsr	set_med_rez
	bsr	set_super	;supervisor mode
menu
	bsr	initialise
main_loop
	bsr	get_key
	cmp.b	#27,d0
	beq.s	exit

	cmp.b	#"7",d0
	beq.s	exit

	cmp.b	#"1",d0
	beq.s	option_1

	cmp.b	#"2",d0
	beq	option_2

	cmp.b	#"3",d0
	beq	option_3

	cmp.b	#"4",d0
	beq	option_4

	cmp.b	#"5",d0
	beq	option_5

	cmp.b	#"6",d0
	beq	option_6

	bra.s	main_loop

exit
	bsr	set_org_rez
	move.w	#$4c,-(sp)	;exit to previous process
	trap	#1

***************
* Subroutines *
***************

********* Option 1 - split pic ********
option_1
	lea	clear_menu,a0
	bsr	print_string
	lea	check_pic,a0
	bsr	print_string
	lea	filename_pic,a0
	bsr	file_search
	tst.l	d0
	bmi	.no_pic
	lea	split_pic_mess,a0
	bsr	print_string
	lea	filename_pic,a0
	bsr	file_open
	tst.l	d0
	bmi	.access_er
	move.w	d0,handle
	lea	file_buffer,a0
	move.l	#32066,d0
	bsr	file_read
	tst.l	d0
	bmi	.access_er
	bsr	file_close
	tst.l	d0
	bne	.access_er
	lea	pal_temp,a0		;write PAL.DAT file
	bsr	file_create
	tst.l	d0
	bmi	.create_error
	move.w	d0,handle
	lea	file_buffer,a0
	move.l	#34,d0
	bsr	file_write
	tst.l	d0
	bmi	.write_error
	cmp.l	#34,d0
	bne	.write_error
	bsr	file_close
	tst.l	d0
	bne	.close_error
	lea	data_temp,a0		;write DATA.DAT file
	bsr	file_create
	tst.l	d0
	bmi	.create_error
	lea	file_buffer+34,a0
	move.w	d0,handle
	move.l	#32000,d0
	bsr	file_write
	tst.l	d0
	bmi	.write_error
	cmp.l	#32000,d0
	bne	.write_error
	bsr	file_close
	tst.l	d0
	bne	.close_error
	lea	filename_pic,a0
	bsr	file_delete
	tst.l	d0
	bne	.delete_error	
	bsr	press_key
	bra	menu
.no_pic	lea	file_error,a0
	bsr	print_string
	lea	no_pic_mess,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.access_er
	lea	file_error,a0
	bsr	print_string
	lea	error_pic_access,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.create_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_create,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.write_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_write,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.close_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_close,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.delete_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pic_delete,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu


******** Option 2 - split sample ********
option_2
	lea	clear_menu,a0
	bsr	print_string
	lea	check_seq,a0
	bsr	print_string
	lea	filename_seq,a0
	bsr	file_search
	tst.l	d0
	bmi	.no_seq
	lea	split_seq_mess,a0
	bsr	print_string
	lea	filename_seq,a0
	bsr	file_open
	tst.l	d0
	bmi	.access_er
	move.w	d0,handle
	lea	file_buffer,a0
	move.l	#$ffffff,d0
	bsr	file_read
	tst.l	d0
	bmi	.access_er
	move.l	d0,seq_length
	bsr	file_close
	tst.l	d0
	bne	.access_er
	lea	seq_temp,a0		;write DATA.SEQ file
	bsr	file_create
	tst.l	d0
	bmi	.create_error
	move.w	d0,handle
	lea	file_buffer+4,a0
	move.l	seq_length,d0
	sub.l	#4,d0
	move.l	d0,d7
	bsr	file_write
	tst.l	d0
	bmi	.write_error
	cmp.l	d7,d0
	bne	.write_error
	bsr	file_close
	tst.l	d0
	bne	.close_error
	lea	filename_seq,a0
	bsr	file_delete
	tst.l	d0
	bne	.delete_error	
	bsr	press_key
	bra	menu
.no_seq	lea	file_error,a0
	bsr	print_string
	lea	no_seq_mess,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.access_er
	lea	file_error,a0
	bsr	print_string
	lea	error_pic_access,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.create_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_create,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.write_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_write,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.close_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_close,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.delete_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pic_delete,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu


******** Option 3 - run packer ********
option_3
	lea	clear_menu,a0
	bsr	print_string
	lea	running_packer,a0
	bsr	print_string
	pea	enviroment
	pea	laddr
	pea	filename_pack
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	tst.l	d0
	bmi.s	.error_running_packer
	bra	menu
.error_running_packer
	lea	file_error,a0
	bsr	print_string
	lea	error_running_packer,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu



********************* OPTION 4 - JOIN PIC ****************
option_4
	lea	clear_menu,a0
	bsr	print_string
	lea	joining_pic,a0
	bsr	print_string
	lea	pal_temp,a0
	bsr	file_open
	tst.l	d0
	bmi	.error_opening_pal
	move.w	d0,handle
	lea	file_buffer,a0
	move.l	#34,d0
	bsr	file_read
	tst.l	d0
	bmi	.error_reading_pal
	bsr	file_close
	tst.l	d0
	bne	.error_closing_pal
	lea	data_temp,a0
	bsr	file_open
	tst.l	d0
	bmi	.error_opening_data
	move.w	d0,handle
	lea	file_buffer+34,a0
	move.l	#32000,d0
	bsr	file_read
	tst.l	d0
	bmi	.error_reading_data
	move.l	d0,d7
	bsr	file_close
	tst.l	d0
	bne	.error_closing_data
	add.w	#34,d7		;length of packed file + pal
	lea	filename_pic,a0		;write PAL.DAT file
	bsr	file_create
	tst.l	d0
	bmi	.create_error
	move.w	d0,handle
	lea	file_buffer,a0
	move.l	d7,d0
	bsr	file_write
	tst.l	d0
	bmi	.write_error
	bsr	file_close
	tst.l	d0
	bne	.close_error
	lea	pal_temp,a0
	bsr	file_delete
	tst.l	d0
	bne	.delete_error	
	lea	data_temp,a0
	bsr	file_delete
	tst.l	d0
	bne	.delete_error	
	bsr	press_key
	bra	menu

.error_opening_pal
	lea	file_error,a0
	bsr	print_string
	lea	error_open_pal,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.error_reading_pal
	lea	file_error,a0
	bsr	print_string
	lea	error_read_pal,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu

.error_closing_pal
	lea	file_error,a0
	bsr	print_string
	lea	error_close_pal,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.error_opening_data
	lea	file_error,a0
	bsr	print_string
	lea	error_open_data,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.error_reading_data
	lea	file_error,a0
	bsr	print_string
	lea	error_read_data,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.error_closing_data
	lea	file_error,a0
	bsr	print_string
	lea	error_close_data,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu

.create_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_create,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.write_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_write,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.close_error
	lea	file_error,a0
	bsr	print_string
	lea	error_pal_close,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.delete_error
	lea	file_error,a0
	bsr	print_string
	lea	error_temp_delete,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu


********* option 5 ********
option_5
	lea	clear_menu,a0
	bsr	print_string
	lea	joining_seq,a0
	bsr	print_string
	lea	seq_temp,a0
	bsr	file_open
	tst.l	d0
	bmi	.error_opening_seq
	move.w	d0,handle
	lea	file_buffer+4,a0
	move.l	#$ffffff,d0
	bsr	file_read
	tst.l	d0
	bmi	.error_reading_seq
	move.l	d0,d7
	bsr	file_close
	tst.l	d0
	bne	.error_closing_seq

	lea	file_buffer+4,a0
	cmp.l	#"Ice!",(a0)
	beq.s	.file_valid

.ask	lea	seq_not_packed,a0
	bsr	print_string
	lea	seq_question,a0
	bsr	print_string
	bsr	get_key
	cmp.b	#"Y",d0
	beq.s	.file_valid
	cmp.b	#"y",d0
	beq.s	.file_valid
	cmp.b	#"N",d0
	beq.s	.new_seq_opts
	cmp.b	#"n",d0
	beq.s	.new_seq_opts
	bra.s	.ask

.new_seq_opts
	lea	seq_opts,a0
	bsr	print_string
	bsr	press_key
	bra	menu

.file_valid
	lea	filename_seq,a0
	bsr	file_create
	tst.l	d0
	bmi	.create_error
	move.w	d0,handle
	lea	file_buffer,a0
	move.l	#"sequ",(a0)
	move.l	d7,d0
	add.l	#4,d0
	bsr	file_write
	tst.l	d0
	bmi	.write_error
	bsr	file_close
	tst.l	d0
	bne	.close_error
	lea	seq_temp,a0
	bsr	file_delete
	tst.l	d0
	bne	.delete_error	
	bsr	press_key
	bra	menu

.error_opening_seq
	lea	file_error,a0
	bsr	print_string
	lea	error_open_seq,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.error_reading_seq
	lea	file_error,a0
	bsr	print_string
	lea	error_read_seq,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu

.error_closing_seq
	lea	file_error,a0
	bsr	print_string
	lea	error_close_seq,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu

.create_error
	lea	file_error,a0
	bsr	print_string
	lea	error_seq_create,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.write_error
	lea	file_error,a0
	bsr	print_string
	lea	error_seq_write,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.close_error
	lea	file_error,a0
	bsr	print_string
	lea	error_seq_close,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu
.delete_error
	lea	file_error,a0
	bsr	print_string
	lea	error_temp_delete,a0
	bsr	print_string
	bsr	flash_colour0
	bsr	press_key
	bra	menu

	
*******************************
option_6
	lea	clear_menu,a0
	bsr	print_string
	lea	which_drive,a0
	bsr	print_string
	bsr	get_key
	cmp.b	#"A",d0
	blt.s	option_6
	cmp.b	#"P",d0
	bgt.s	option_6
	move.b	d0,filename_pic
	move.b	d0,filename_font
	move.b	d0,filename_seq
	move.b	d0,filename_txt
	move.b	d0,pal_temp
	move.b	d0,data_temp
	move.b	d0,seq_temp
	move.b	d0,filename_pack
	bra	menu

****************** common routines ************
rename_file
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$56,-(sp)
	trap	#1
	add.l	#12,sp
	rts

file_search
	move.w	#-1,-(sp)
	move.l	a0,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	rts

file_create
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	rts

file_open
	move.w	#2,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	rts

file_read
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	rts

file_write
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

file_close
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

file_delete
	move.l	a0,-(sp)
	move.w	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

print_string
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$a00a
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$a009
	movem.l	(sp)+,d0-d7/a0-a6
	rts

press_key
	lea	press_key_mess,a0
	bsr	print_string

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

v_sync	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

flash_colour0
	move.w	$ffff8240.w,d7
	move.w	#10-1,d0
.loop	eor.w	#$700,$ffff8240.w
	bsr	v_sync
	dbf	d0,.loop
	move.w	d7,$ffff8240.w
	rts

set_super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stack
	rts

set_user
	move.l	old_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stack
	rts

initialise
	lea	cls,a0
	bsr	print_string
	lea	menu_mess,a0
	bsr	print_string
	rts


get_rez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_rez
	rts

set_org_rez
	move.w	org_rez,d0
	bra.s	set_rez
set_low_rez
	move.w	#0,d0
	bra.s	set_rez
set_med_rez
	move.w	#1,d0
set_rez
	move.w	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

********************************
	SECTION	DATA

cls		dc.b	27,'E',0,0
menu_mess
 dc.b	27,'Y',32+0,32+24,"Master sound demo packer utility"
 dc.b	27,'Y',32+1,32+24,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
 dc.b	27,'Y',32+4,32+31,"1 - Split picture"
 dc.b	27,'Y',32+6,32+31,"2 - Split sample"
 dc.b	27,'Y',32+8,32+31,"3 - Run packer"
 dc.b	27,'Y',32+10,32+31,"4 - Join picture"
 dc.b	27,'Y',32+12,32+31,"5 - Join sample"
 dc.b	27,'Y',32+14,32+31,"6 - Set drive"
 dc.b	27,'Y',32+16,32+31,"7 - Exit"
 dc.b	27,'Y',32+24,32+30,"(c) MAC SYS DATA 1990"
 dc.b	0

clear_menu
 dc.b	27,'Y',32+0,32+24,"Master sound demo packer utility"
 dc.b	27,'Y',32+1,32+24,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
 dc.b	27,'Y',32+4,32+31,"                 "
 dc.b	27,'Y',32+6,32+31,"                 "
 dc.b	27,'Y',32+8,32+31,"                 "
 dc.b	27,'Y',32+10,32+31,"                 "
 dc.b	27,'Y',32+12,32+31,"                 "
 dc.b	27,'Y',32+14,32+31,"                 "
 dc.b	27,'Y',32+16,32+31,"                 "
 dc.b	27,'Y',32+24,32+30,"                     "
 dc.b	0


check_pic
 dc.b	27,'Y',32+10,32+24,"CHECKING FOR VALID PICTURE FILE"
 dc.b	0
split_pic_mess
 dc.b	27,'Y',32+12,32+31,"SPLITTING PICTURE"
 dc.b	0
running_packer
 dc.b	27,'Y',32+12,32+26,"PLEASE WAIT..LOADING PACKER",0
file_error
 dc.b	27,'Y',32+10,32+24,"       *** FILE ERROR ***       ",0
no_pic_mess
 dc.b	27,'Y',32+12,32+27,"FILE MASTER.PI1 NOT FOUND",0
error_pic_access
 dc.b	27,'Y',32+12,32+27,"ERROR ACCESSING MASTER.PI1",0
error_pic_delete
 dc.b	27,'Y',32+12,32+27," ERROR DELETING MASTER.PI1",0
error_pal_create
 dc.b	27,'Y',32+12,32+27,"  ERROR CREATING PAL.DAT  ",0
error_pal_write
 dc.b	27,'Y',32+12,32+27,"   ERROR WRITING PAL.DAT  ",0
error_pal_close
 dc.b	27,'Y',32+12,32+27,"   ERROR CLOSING PAL.DAT  ",0
error_running_packer
 dc.b	27,'Y',32+12,32+26," ERROR RUNNING ICE_2_1.PRG ",0



********** option 2 messages **********
check_seq
 dc.b	27,'Y',32+10,32+24,"CHECKING FOR VALID SEQUENCE FILE"
 dc.b	0
split_seq_mess
 dc.b	27,'Y',32+12,32+31,"SPLITTING SEQUENCE"
 dc.b	0
no_seq_mess
 dc.b	27,'Y',32+12,32+27,"FILE MASTER.SEQ NOT FOUND",0

********** option 6 messgaes **********
press_key_mess
 dc.b	27,'Y',32+20,32+28,"Press a key to continue.",0
which_drive
 dc.b	27,'Y',32+12,32+30,"Drive letter (A-P) > ",0


joining_pic
 dc.b	27,'Y',32+12,32+25,"Please wait...joining picture",0
error_open_pal
 dc.b	27,'Y',32+14,32+27,"Error opening PAL.DAT file",0
error_read_pal
 dc.b	27,'Y',32+14,32+27,"Error reading PAL.DAT file",0
error_close_pal
 dc.b	27,'Y',32+14,32+27,"Error closing PAL.DAT file",0
error_open_data
 dc.b	27,'Y',32+14,32+27,"Error opening DATA.DAT file",0
error_read_data
 dc.b	27,'Y',32+14,32+27,"Error reading DATA.DAT file",0
error_close_data
 dc.b	27,'Y',32+14,32+27,"Error closing DATA.DAT file",0
error_temp_delete
 dc.b	27,'Y',32+14,32+27,"Error deleting a temp file",0

************* option 5 messages ***********
joining_seq
 dc.b	27,'Y',32+12,32+25,"Please wait...joining sequence",0
error_open_seq
 dc.b	27,'Y',32+14,32+27,"Error opening DATA.SEQ file",0
error_read_seq
 dc.b	27,'Y',32+14,32+27,"Error reading DATA.SEQ file",0
error_close_seq
 dc.b	27,'Y',32+14,32+27,"Error closing DATA.SEQ file",0
error_seq_create
 dc.b	27,'Y',32+12,32+27,"  ERROR CREATING PAL.DAT  ",0
error_seq_write
 dc.b	27,'Y',32+12,32+27,"   ERROR WRITING PAL.DAT  ",0
error_seq_close
 dc.b	27,'Y',32+12,32+27,"   ERROR CLOSING PAL.DAT  ",0
seq_not_packed
 dc.b	27,'Y',32+10,32+27,"WARNING DATA.SEQ HAS NOT PACKED",0
seq_question
 dc.b	27,'Y',32+12,32+25,"  Do you wish to continue (Y/N)",0
seq_opts
 dc.b	27,'Y',32+10,32+24,"MASTER.SEQ is either unpackable"
 dc.b	27,'Y',32+12,32+24,"or the disc is full. If you wish"
 dc.b	27,'Y',32+14,32+24,"to try again, copy MASTER.SEQ to"
 dc.b	27,'Y',32+16,32+27,"this disc and start again.",0

warning_message
 dc.b	27,'E'
 dc.b	27,'Y',32+6,32+28,"MASTER SOUND DEMO PACKER"
 dc.b	27,'Y',32+7,32+28,"------------------------"
 dc.b	27,'Y',32+9,32+31,"**** WARNING ****"
 dc.b	27,'Y',32+11,32+20,"This is a test copy and may corrupt your"
 dc.b	27,'Y',32+12,32+20,"discs so ALWAYS use a backup and follow"
 dc.b	27,'Y',32+13,32+29,"the prompts carefully."
 dc.b	27,'Y',32+15,32+17,"If you find a bug, please report to me A.S.A.P"
 dc.b	27,'Y',32+17,32+26,"Signed MAC SYS DATA 23/12/90",0
	even
filename_pic	dc.b	"A:\MASTER.PI1",0
filename_font	dc.b	"A:\FONT.PI1",0
filename_seq	dc.b	"A:\MASTER.SEQ",0
filename_txt	dc.b	"A:\MASTER.txt",0
pal_temp	dc.b	"A:\PAL.DAT",0
data_temp	dc.b	"A:\DATA.DAT",0
seq_temp	dc.b	"A:\DATA.SEQ",0
filename_pack	dc.b	"A:\ICE_2_1.PRG",0

	even
enviroment	dc.l	0
laddr		dc.l	0
	SECTION BSS
old_stack	ds.l	1
org_rez		ds.w	1
seq_length	ds.l	1
handle		ds.w	1
	ds.l	500
stack_end	ds.l	1
file_buffer	ds.l	1

