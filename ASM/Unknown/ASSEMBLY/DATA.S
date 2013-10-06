
	include	'biosmac.i'
	include	'xbiosmac.i'
	include	'gmdosmac.i'
screen_width	equ	80
screen_height	equ	24
max_item	equ	70
max_num_items	equ	10
max_entries	equ	200	maximum no. of records, alter if you need more

*************************
*To set up your own records, replace the following
*with the name and size (eg 20 characters) of your own fields.
*change num_fields and len_entry appropriately. 
*An example of address records is included. Delete the
*asterisks and replace them in front of the book record fields.
*You will need to alter the data at the following labels found below:-
*title_ref
*reference_list
*fields
*input_strings


len_book_title	equ	30	1st field is 30 characters
len_author	equ	20	2nd field is 20 characters
len_ISBN	equ	15	3rd field is 15 characters
len_cost	equ	8	4th field is 8 characters
num_fields	equ	4	The number of fields
len_entry	equ	len_book_title+len_author+len_ISBN+len_cost+num_fields
*len_entry = sum of field labels +num_fields
*don't forget to include num_fields in len_entry total

*len_name_string	equ	20
*len_address_string	equ	20	we use three of these
*len_postcode_string	equ	10
*len_phone_string	equ	20
*num_fields	equ	6
*len_entry	equ	len_name_string+len_address_string*3+len_postcode_string+len_phone_string+num_fields
*************************
len_file_buff	equ	256
keyboard	equ	2
stacksize	equ	1000
	move.l	4(a7),a3
	move.l	#ourstack+(stacksize*2),a7	
	bsr	initialise_program	
	Getrez
	move.w	d0,our_res
	bsr	set_adjustments		routine that adjusts for current
					*screen resolution
	bsr	find_file		routine sets zero flag if
					*new file
	beq	close_file		if zero flag set, no records to load
	bsr	load_records		else load records from file
close_file
	Fclose	file_handle		Macro to close file opened in find_file
main_loop
	Cconws	#cursor_off		Macro to print a null terminated 
					*string - see cursor_off in the data
					*section for examples of these strings
	move.l	#menu_items,a0
	move.b	#-1,d0
	bsr	menu			routine to draw menus - see menu_items
					*in the data section
	move.b	#0+32,x
	move.b	#1+32,y
	Cconws	#position_cursor
	Cconws	#pick_a_num		print more strings
another_key
	Bconin	#2			Macro - waits for a keypress
	cmpi.w	#'1',d0			d0 contains ASCII code of key pressed
	bne	try_2	
	bsr	add_a_record
	bra	main_loop		jump back to main loop
try_2	cmpi.w	#'2',d0
	bne	try_3
	bsr	show_records
	bra	main_loop
try_3	cmpi.w	#'3',d0
	bne	another_key
	bsr	ask_save
	bsr	save_these_records
	Pterm	#0
	
find_file
	Fopen	#0,#filename	We need to open our file
	move.w	d0,file_handle	and save the file handle
	cmpi.w	#0,d0		was there an error
	bpl	.opened_ok	
	Cconws	#no_file	yes, print no_file message
	Bconin	#2		wait for keypress
	andi.w	#%1011111,d0	convert to upper case
	cmpi.w	#'Y',d0
	beq	.create_file	try creating a file
	Pterm	#0
.create_file
	Fcreate	#0,#filename
	move.w	d0,file_handle
	cmpi.w	#0,d0
	bmi	.not_created
	move.w	#0,file_record_count
	Fwrite	#file_record_count,#2,file_handle	start of with 
							*a count of zero
	bra	.opened_ok
.not_created
	move.l	#file_error,a1
	bra	print_error

.opened_ok
	Fread	#file_record_count,#2,file_handle	read in number of 
							*records
	move.w	file_record_count,d0		check if there are any
	rts
	
load_records
	move.w	d0,last_record	
	Fread	#file_buffer,#len_file_buff,file_handle	*Read from our file
	cmp.w	#len_file_buff,d0	d0 contains len_file_buff (see equ's)
					*if end of file not yet reached
	beq	.keep_going
	move.b	#1,last_time
.keep_going
	move.l	#file_buffer,a6
	move.l	d0,d3
	move.w	#0,d4
.next_record
	move.w	d4,loading_this_record
	cmp.w	last_record,d4
	beq	.done
	mulu.w	#len_entry,d4
	move.l	#main_storage,a1
	move.l	#reference_list,a4
	move.w	#num_fields-1,d7
.move_next
	move.b	(a4)+,d5
	add.w	d5,d4	
	lea	0(a1,d4),a3
	sub.w	d5,d4	restore it's old value	
	move.l	a3,a5
.find_zero
	subq.w	#1,d3	do we need to load more from the file?
	bne	.more_buffer	no
	cmp.b	#1,last_time
	beq	.done
	Fread	#file_buffer,#len_file_buff,file_handle
	move.l	#file_buffer,a6
	
.more_buffer
	move.b	(a6)+,(a3)+
	bne	.find_zero
	dbra	d7,.move_next
	move.w	loading_this_record,d4
	addq.w	#1,d4
	bra	.next_record
.done
	move.b	#0,(a3)	
	rts

add_a_record
	move.w	last_record,d2
	cmpi.w	#max_entries,d2		room for another?
	bne	.add_another			yes
	move.b	#0+32,x				else display message
	move.b	#0+32,y
	Cconws	#position_cursor
	Cconws	#no_more_room
	Bconin	#2
	rts					and return
.add_another
	Cconws	#cls
	move.l	#fields,a0
	
left_margin	equ	8
	move.w	#left_margin,d0
	ext.l	d0
	divu.w	x_adjust,d0
	bsr	menu
	move.w	#left_margin,d4
	ext.l	d0
	divu.w	x_adjust,d4
	add.w	d0,d4
	move.w	d6,d5	y_coordinate as returned by menu
	subi.w	#32,d5
	move.w	d7,d3	no. of strings, as returned by menu
	move.l	#input_strings,a3
	Cconws	#cursor_on
	bsr	input_str
	move.l	#input_strings,a0
	bsr	was_there_an_entry
	beq	.done
	bsr	store_entry
.done
	rts
	
was_there_an_entry
*	Routine to check if any data was input
*	a0 contains array of TOS Cconin call style strings
	movem.l	d1-3/a0,-(sp)
	clr.l	d2
	move.w	d7,d3
	subq.w	#1,d3
.try_next
	lea	(a0,d2),a0
	move.b	(a0),d2
	addq.w	#2,d2		ignore the 1st 2 bytes of each string
	move.b	1(a0),d1
	dbne	d3,.try_next
	movem.l	(sp)+,d1-3/a0
	rts

store_entry
	movem.l	d0-1/d3/a0-4,-(sp)
	move.w	d7,d3
	subq.w	#1,d3
	move.l	#input_strings,a0
	move.w	last_record,d0
	mulu.w	#len_entry,d0
	move.l	#main_storage,a1
	move.l	#reference_list,a4
.move_next
	move.b	(a4)+,d1	move the rs directive (stored at reference_list)
	add.w	d1,d0		add it to number of new entry
	lea	0(a1,d0),a3	load it into a3
	sub.w	d1,d0	restore it's old value	
	bsr	move_entry
	dbra	d3,.move_next

	move.w	last_record,d0
	addq.w	#1,d0			update count of records
	move.w	d0,last_record
	movem.l	(sp)+,d0-1/d3/a0-4

	rts
	
move_entry
	move.l	a0,a2
	addq.l	#1,a2
	move.b	(a2)+,d1
	beq	.no_entry
	ext.w	d1	just in case
	subq.w	#1,d1
.move_name
	move.b	(a2)+,(a3)+
	dbra	d1,.move_name
.no_entry
	move.b	#0,(a3)	null terminate it
	clr.l	d1
	move.b	(a0),d1
	add.l	d1,a0
	addq.l	#2,a0

	rts

show_records
	move.w	#0,this_record	*display first record
	move.w	last_record,d1	sets the zero flag if no records entered yet
	bne	display_next		display them if zero clear
	move.b	#1+32,x			else display message
	move.b	#1+32,y
	Cconws	#position_cursor
	Cconws	#no_records
	Bconin	#2
	rts

display_next
*	displays the record number stored in this_record
*	this record number must exist or unpredictable
*	results will occur
	move.w	this_record,d0
	bsr	move_record
	bsr	display_record
	Bconin	#2	
	swap.w	d0	this swaps the high and low word of d0
	move.b	d0,d1
	swap.w	d0
	cmpi.b	#$31,d1			was <n> pressed?
	bne	.not_alternate_n		no
	cmpi.b	#0,d0			yes - was it alternate n
	bne	.not_alternate_n
	move.w	this_record,d0
	addq.w	#1,d0			next record number
	move.w	last_record,d1
	cmp.w	d1,d0			any more records?
	beq	.no_more		no - stay with this one
	move.w	d0,this_record
.no_more
	bra	display_next
.not_alternate_n
	cmpi.b	#$19,d1			was <p> pressed?
	bne	.not_alternate_p		no
	cmpi.b	#0,d0			yes - was it alternate p
	bne	.not_alternate_p
	move.w	this_record,d0
	beq	.dont_move_back
	subq.w	#1,d0
	move.w	d0,this_record
.dont_move_back	
	bra	display_next
.not_alternate_p
	cmpi.w	#$1b,d0			was Esc pressed?
	bne	display_next			no - next key press
	rts					yes - back to menu
	
display_record
	move.l	#display_strings,a0
	move.b	#-1,d0
	bsr	menu
	move.b	#0+32,x
	move.b	#0+32,y
	Cconws	#position_cursor
	Cconws	#display_key1
	move.b	#1+32,y
	Cconws	#position_cursor
	Cconws	#display_key2
	move.b	#2+32,y
	Cconws	#position_cursor
	Cconws	#display_key3
rts

move_record
*	displays the record number found in d0
*	this record number must exist
	movem.l	d0-2/a0-3,-(sp)
	mulu.w	#len_entry,d0
	move.l	#main_storage,a0
	add.w	d0,a0
	move.l	a0,a3
	move.l	#display_strings,a1
	move.w	#num_fields-1,d1
	clr.l	d2
	move.l	#reference_list,a2
.move_next
	move.b	(a2)+,d2
	lea	0(a3,d2),a0
	move.b	(a0),d0		check that there is a string
	beq	.no_string
.move_it
	move.b	(a0)+,(a1)+
	bne	.move_it
.no_string
	dbra	d1,.move_next
	move.b	#0,(a1)		add the final zero
	moveq.b	#1,d0		clear the zero flag
.done	
	movem.l	(sp)+,d0-2/a0-3
	rts

ask_save
	move.b	#0+32,x
	move.b	#0+32,y
.unknown_key
	Cconws	#position_cursor
	Cconws	#wanna_save
	Bconin	#2
	andi.w	#%1011111,d0	convert to upper case
	cmpi.w	#'Y',d0
	beq	.save_first
	cmpi.w	#'N',d0
	bne	.unknown_key
	Pterm	#0	
.save_first	
	rts

save_these_records
	Fopen	#1,#filename
	move.w	d0,file_handle
	cmpi.w	#0,d0
	bpl	.opened_ok
	Cconws	#no_file
	Bconin	#2
	andi.w	#%1011111,d0	convert to upper case
	cmpi.w	#'Y',d0
	beq	.create_file
	rts
.create_file
	Fcreate	#0,#filename
	move.w	d0,file_handle
	cmpi.w	#0,d0
	bpl	.opened_ok
	Cconws	#cls
	Cconws	#file_error
	Bconin	#2
	rts
.opened_ok
	Fwrite	#last_record,#2,file_handle	save number of records
	move.w	last_record,d3
	subq.w	#1,d3	for dbra
	move.w	#0,d4
.next_record
	move.w	d4,saving_this_record
	cmp.w	last_record,d4
	beq	.done
	mulu.w	#len_entry,d4
	move.l	#main_storage,a1
	move.l	#reference_list,a4
	move.w	#num_fields-1,d7
.move_next
	move.b	(a4)+,d5
	add.w	d5,d4	
	lea	0(a1,d4),a3
	move.l	a3,a5
	sub.w	d5,d4	restore it's old value	
	clr.w	d6	count the characters in each field
.find_zero
	addq.w	#1,d6
	move.b	(a3)+,d5
	bne	.find_zero
	Fwrite	a5,d6,file_handle	save a field
	dbra	d7,.move_next
	move.w	saving_this_record,d4
	addq.w	#1,d4
	bra	.next_record

	
.done	
	Fclose	file_handle
	rts

initialise_program	
	move.l	$c(a3),d0	*length of text
	add.l	$14(a3),d0	*length of data
	add.l	$1c(a3),d0	*length of BSS
	add.l	#$100,d0	*length of basepage
	Mshrink	d0,a3		*Macro to return unwanted memory
	rts
menu
*	on entry
*	a0.l	address of 1st string array
*	d0.b	-1 to centre menu
*		or x coordinate for menu
*
*	returns	d0.w=length in characters of longest menu item
*	returns	d6.w= y-coordinate+32 of 1st menu entry
*	returns	d7.w= number of menu items 
	addi.b	#32,d0
	move.b	d0,x
	movem.l	d1-5/a1/a3,-(sp)
	bsr	.calc_left_margin
	cmp.b	#31,x
	bne	.not_centered
	move.b	d0,x	
.not_centered
	move.l	a0,a3
	move.w	#screen_height,d3
	sub.w	d5,d3
	ext.l	d0
	divu	#2,d3
	addi.b	#32,d3	for 27+Y
	move.w	d3,d6
	clr.w	d7	count number of menu items
	Cconws	#cls
.print_item
	addq.w	#1,d7
	move.b	d3,y
	Cconws	#position_cursor
	Cconws	a3
.find_string
	move.b	(a3)+,d2
	bne	.find_string
	addq.w	#1,d3
	move.b	(a3),d2
	bne	.print_item
	move.w	d4,d0	return the longest string output
	movem.l	(sp)+,d1-5/a1/a3
	rts

.calc_left_margin	
	move.l	a0,a1
	move.w	#max_item,d1
	ext.l	d0
	divu.w	x_adjust,d1
	move.w	d1,d2
	move.w	d1,d3
	clr.w	d4
	clr.w	d5
.find_zero
	move.b	(a1)+,d0
	dbeq	d1,.find_zero
	cmpi.w	#0,d1
	bge	.got_it
	move.l	#menu_sz_error,a1
	bra	print_error
.got_it	sub.w	d1,d3	length of string
	cmp.w	d3,d4	which is max
	bhi	.next_item
	move.w	d3,d4
.next_item	
	addq.w	#1,d5	count no. of menu items

	move.b	(a1),d0	double null term?
	beq	.all_done
	move.w	d2,d3
	move.w	d2,d1
	bra	.find_zero
.all_done
	move.w	#screen_width,d0
	ext.l	d0
	divu	x_adjust,d0
	sub.w	d4,d0
	divu	#2,d0
	addi.w	#32,d0	VT52 cursor position has 32,32 as top left
	rts
	
	
	
	
***************************************
*
*	routine to return a series
*	of user input strings
*	on entry
*	d3.w	contains no. of strings
*	d4.b	contains x coordinate to echo 1st string
*	d5.b	contains y coordinate to echo strings
*	a3  	contains address of consecutive buffers
*		for the strings
*
*	the buffers for the strings should be as for TOS Cconin call
*
******************************************
input_str	
	subq.w	#1,d3
	move.l	a4,-(sp)
	addi.b	#32,d4
	move.b	d4,x
	addi.b	#32,d5
.next_string
	move.b	d5,y
	lea	2(a3),a4
	move.b	(a3),d4	get max length of input string
	clr.b	d6
	Cconws	#position_cursor

.get_key_loop
	Bconin	#2
	cmpi.w	#32,d0
	bge	.store_it
	cmpi.w	#8,d0	*was it a backspace
	bne	.carriage_return	No,try a CR
	cmpi.b	#0,d6		is this the first character?
	beq	.carriage_return	yes, ignore it
	Bconout	#8,#2	otherwise print a backspace
	Bconout	#32,#2	print a space
	Bconout	#8,#2	followed by a backspace
	subq.l	#1,a4	
	subq.b	#1,d6	
	bra	.carriage_return
			
.store_it
	cmp.b	d6,d4	have we had maximum characters
	beq	.carriage_return	unless it's a CR,ignore it
	addq.b	#1,d6	count how many characters
	move.b	d0,(a4)+
.print_it
	Bconout	d0,#2
.carriage_return
	cmpi.w	#13,d0
	bne	.get_key_loop
	move.b	d6,1(a3)	save actual length input
	addq.b	#1,d5	next y position
	move.b	(a3),d4
	ext.w	d4
	lea	2(a3,d4),a3
	dbra	d3,.next_string
	
	move.l	(sp)+,a4
	rts
	
	

set_adjustments
	cmpi.w	#2,d0
	bne	med_res
	move.w	#1,x_adjust	
	move.w	#1,y_adjust	
	rts
med_res	cmpi.w	#1,d0
	bne	lo_res
	move.w	#1,x_adjust	
	move.w	#2,y_adjust	
	rts
lo_res	cmpi.w	#0,d0
	bne	what_res
	move.w	#2,x_adjust	
	move.w	#2,y_adjust	
	rts
what_res
	move.l	#res_error,a1		
	bra	print_error
	rts

print_error
	move.w	d0,error_number
	Cconws	a1		
	Bconin	#keyboard	
	Pterm	error_number	





	data
	
	even
*********************************
*memory to store data when input
*replace when setting up your own fields, an example is given
*for address fields
input_strings	
title	dc.b	len_book_title,0
	dcb.b	len_book_title		*declares a block of data len_book_title bytes long
author	dc.b	len_author,0
	dcb.b	len_author
ISBN	dc.b	len_ISBN,0
	dcb.b	len_ISBN
cost	dc.b	len_cost,0
	dcb.b	len_cost

*name	dc.b	len_name_string,0
*	dcb.b	len_name_string
*address1	dc.b	len_address_string,0
*	dcb.b	len_address_string
*address2	dc.b	len_address_string,0
*	dcb.b	len_address_string
*address3	dc.b	len_address_string,0
*	dcb.b	len_address_string
*post_code	dc.b	len_postcode_string,0
*	dcb.b	len_postcode_string
*telephone	dc.b	len_phone_string,0
*	dcb.b	len_phone_string

cls	dc.b	27,'E',0

*******These must stay together
position_cursor	dc.b	27,'Y'
y	dc.b	' '
x	dc.b	' ',0
*******************************
cursor_on	dc.b	27,'e',0
cursor_off	dc.b	27,'f',0
menu_items
	dc.b	'1..Add An Entry',0
	dc.b	'2..Display Entries',0
	dc.b	'3..Quit',0
	dc.b	0	Make sure this line is always present at the end


*add your own fields here, examples below for address records
fields
	dc.b	'Title........',0
	dc.b	'Author.......',0
	dc.b	'ISBN.........',0
	dc.b	'Cost.........',0
	dc.b	0	Make sure this line is always present at the end

*	dc.b	'Name.........',0
*	dc.b	'Address......',0
*	dc.b	'       ......',0
*	dc.b	'       ......',0
*	dc.b	'Post Code....',0
*	dc.b	'Telephone....',0
*	dc.b	0	Make sure this line is always present at the end

res_error	dc.b	'I dont know that resolution',0
menu_sz_error	dc.b	'Menu too large for this resolution',0
no_file		dc.b	'Could not open data.dbf',13,10
		dc.b	'OK to create a file   y/n',0
file_error	dc.b	'Could not create/open file',0
display_key1	dc.b	'alternate n - next record',0
display_key2	dc.b	'alternate p - previous record',0
display_key3	dc.b	'Esc to return to main menu',0
wanna_save	dc.b	'Save this file? y/n',0
no_records	dc.b	'No records to find',0
pick_a_num	dc.b	'Pick a Number',0
no_more_room	dc.b	'Sorry, too many records',13,11
		dc.b	'Press any key',0
filename	dc.b	'data.dbf',0

*********************************	
*This is our reference list for the rs section
*alter this if you alter the fields
*example for the address book is included in comments

reference_list	dc.b	title_ref,author_ref,ISBN_ref,cost_ref
*reference_list	dc.b	name_ref,address1_ref,address2_ref,address3_ref,post_code_ref,phone_ref
*****************************
	bss

*********************************	
*This is our rs section for our fields
*alter this if you alter the fields
*examples for the address book are included in comments
	even
	rsreset


title_ref	rs.b	len_book_title+1
author_ref	rs.b	len_author+1
ISBN_ref	rs.b	len_ISBN+1
cost_ref	rs.b	len_cost+1

*name_ref	rs.b	len_name_string+1
*address1_ref	rs.b	len_address_string+1
*address2_ref	rs.b	len_address_string+1
*address3_ref	rs.b	len_address_string+1
*post_code_ref	rs.b	len_postcode_string+1
*phone_ref	rs.b	len_phone_string+1
*****************************


	even
saving_this_record	ds.w	1
loading_this_record	ds.w	1
file_handle	ds.w	1
file_record_count	ds.w	1
last_record	ds.w	1
this_record	ds.w	1
x_adjust	ds.w	1
y_adjust	ds.w	1
our_res	ds.w	1
error_number	ds.w	1
ourstack	ds.w	stacksize
file_buffer	ds.b	len_file_buff
last_time	ds.b	1
	even
main_storage	ds.b	max_entries*len_entry
	even
display_strings	ds.b	len_entry+1	*+1 for final null term
