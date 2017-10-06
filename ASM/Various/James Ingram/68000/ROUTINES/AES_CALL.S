* Common AES call routines
*  by James Ingram, July 1993




	ifd	link_library
	MODULE	GET_PHYS_HAND
	XDEF	get_phys_scrn_hand
	XDEF	phys_handle,boxw,boxh,cellw,cellh

	XREF	aes
	endc

get_phys_scrn_hand:
	move.w	#get_the_physical_screen_handle,-(a7)
	bsr	aes

	move.l	#phys_handle,a0
	movem.w	d0-d4,(a0)	; store all the returned vars

	rts


	ifd	link_library
	section	bss
	endc

phys_handle:
	ds.w	1

cellw:
	ds.w	1
cellh:
	ds.w	1

boxw:
	ds.w	1
boxh:
	ds.w	1


	ifd	link_library
	MODULE	RSC_FILES
	XDEF	do_load_rsc
	XDEF	load_rsc,unload_rsc
	XDEF	get_rsc_addr,get_tree_addrs
	XDEF	centre_box,centre_all

	XDEF	tree_list,tree_coord_list

	XREF	aes,res_mem,put_name
	endc




centre_box:
*	d0 = tree number to centre

	move.l	tree_list,a0
	move.w	d0,d1
	lsl.w	#2,d0

	move.l	(a0,d0.w),a0	; get addr of tree to do
	move.w	#centre_the_dialog_box,-(a7)
	bsr	aes

	rts


centre_all:
* Centre all selected dialog boxes
* a0 points to a list of tree numbers, terminated with -1.W

	move.l	tree_coord_list,a5

do_centre_all:
	move.w	(a0),d0
	bmi.s	end_centre_all

	pea	(a0)
	bsr	centre_box

	move.l	(a7)+,a0
	move.w	(a0)+,d0	; get tree no again
	lsl.w	#3,d0		; x 8 for offset

	movem.w	d1-d4,(a5,d0.w)	; store co-ords of centred box

	bra.s	do_centre_all

end_centre_all:
	rts





do_load_rsc:
* do everything involving loading a RSC file
* no of trees passed in d7
* rsc name pointed to by a0
* list of tree nos to centre at a1 (terminate with -1.W)

* RETURNS d0 = error code (0 = ok)

	pea	(a1)
	move.w	d7,-(a7)

	bsr	load_rsc
	tst.w	d0
	bmi	rsc_rts

	move.w	(a7)+,d7
	bsr	get_tree_addrs

	move.l	(a7)+,a0
	bsr	centre_all
	moveq	#0,d0
	rts

rsc_rts:
	addq.l	#6,a7
	moveq	#-1,d0
	rts

load_rsc:
* load rsc file pointed to by a0

	pea	(a0)

	move.w	#load_a_resource,-(a7)
	bsr	aes

	tst.w	d0
	bne.s	load_rsc_ok

* rsc file failed!

	move.l	(a7)+,a0
	lea	rscname(pc),a1
	bsr	put_name

	alert	#1,rsc_fail
	moveq	#-1,d0
	rts

load_rsc_ok:
	move.l	(a7)+,a0
	moveq	#0,d0
	rts


unload_rsc:
	move.w	#unload_a_resource,-(a7)
	bsr	aes
	rts


get_rsc_addr:
*	d0 = type of structure
*	d1 = array index

	move.w	#get_address_of_resource_data,-(a7)
	bsr	aes
	rts


get_tree_addrs:
*	d7 = no of trees to do

	moveq	#0,d0
	move.w	d7,d0		; get no of trees
	
	move.l	d0,d1
	lsl.l	#2,d0		; length required for addr list

	lsl.l	#3,d1		; length required for co-ords
	move.l	d0,d6		; keep addr len safe

	add.l	d1,d0		; add co-ord len


	bsr	res_mem		; reserve memory for length of tree data

	tst.l	d0
	bmi.s	tree_addrs_mem_err
	beq.s	tree_addrs_mem_err

	move.l	d0,tree_list	; store addr of addrs
	move.l	d0,a5

	add.l	d6,d0		; add on len of addrs
	move.l	d0,tree_coord_list	; as start of coord list


	moveq	#0,d6

do_all_rsc_addrs:
	move.w	d6,-(a7)
	move.w	d7,-(a7)

	move.w	d6,d1		; tree no
	moveq	#0,d0		; type = tree
	bsr	get_rsc_addr	; get the address

	move.l	a0,(a5)+

	move.w	(a7)+,d7
	move.w	(a7)+,d6

	addq.w	#1,d6
	cmp.w	d6,d7
	bne.s	do_all_rsc_addrs


	moveq	#0,d0

	rts


tree_addrs_mem_err:
* memory error!
	alert	#1,tree_addrs_mem_mes
	moveq	#-1,d0
	rts





rsc_fail:
	stopp
	dc.b	"[Cannot find resource file|"
rscname:
	dc.b	"                          "
	dc.b	"]"
	dc.b	"[Cancel]",0

tree_addrs_mem_mes:
	exclam
	dc.b	"[Out of memory!]"
	dc.b	"[ Bah! ]",0

	even


	ifd	link_library
	section	bss
	endc

tree_list:
	ds.l	1

tree_coord_list:
	ds.l	1


	ifd	link_library
	MODULE	AES_MOUSE

	XDEF	mouse_arrow,mouse_bee

	XREF	aes
	endc

mouse_arrow:
	moveq	#0,d0
mouse_rej:
	move.w	#change_the_mouse_pointer,-(a7)
	bsr	aes
	rts

mouse_bee:
	moveq	#2,d0
	bra.s	mouse_rej


	ifd	link_library
	MODULE	AES_WAITS
	XDEF	wait_for_any_event
	XDEF	interpret_message
	XDEF	jump_window_routine
	XDEF	wait_for_message
	XDEF	go_sub

	XREF	aes,menu_number,menu_highlight_off
	XREF	to_lower
	endc

go_sub:
* go to the correct sub-routine
* call immeadiately after wait_for_any_event
* d0 holds type of event
* a3 holds pointer to list of events and routines

* structure of a3 list
*	.L	event type (eg "KEYB")
*	.L	address of list of events
*	.L	address of list of routines
*	.L	-1 (end of list)

* list of events structure:
* for MENU:
*	.W	menu item number
*	.W	-1

* for KEYB:
*	.W	shift key status required
*	.W	key value (lowercase)
*	.W	-1

* get the correct lists...

.search_list:
	tst.l	(a2)
	bpl.s	.not_end
* end of event list - can't process!
	rts

.not_end:
	cmp.l	(a2)+,d0
	beq.s	.this_list

* not this list
	addq.l	#8,a2
	bra.s	.search_list

.this_list:
* get list of events
	move.l	4(a2),a3
* and list of routines
	move.l	(a2),a2

	cmp.l	#"KEYB",d0
	bne.s	not_keyb

* we have a keyboard event.
* the key pressed is passed in a funny way by the AES
* so I now convert it into key and shift status

	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13		; get shift key status in d0
	addq.l	#4,a7

	lea	key_convert(pc),a0	; assume no shift keys pressed

* test shift keys...
	move.w	d0,d1
	and.b	#3,d1
	beq.s	.not_shift

* use shifted table
	lea	shift_convert(pc),a0
.not_shift:

* now get the key value
	lsr.w	#8,d5		; get key data value
	move.b	(a0,d5.w),d5	; look up in table


* now d5 holds key pressed
* d0 holds shift key status
* a2 is list of keys
* a3 is list of routines

	and.w	#$ff,d5		; keep only key value
	exg.l	d0,d5

* d0 = key value
* d5 = shift status
	bsr	to_lower	; ensure key is lowercase
	move.w	d0,d1

* d1 = key value

.key_search:
* get shift status from list
	tst.w	(a2)
	bpl.s	.not_end2
	rts

.not_end2:
	move.w	(a2)+,d0
	sub.w	d5,d0
	bne.s	.next_key

* match!
	move.w	(a2)+,d0	; get key in list
	bsr	to_lower	; make it lower case
	sub.w	d1,d0
	bne.s	.next_key2

* got a match!
	move.l	(a3),a3
	jmp	(a3)		; jump to correct routine

.next_key:
	addq.l	#2,a2		; skip key data
.next_key2:
	addq.l	#4,a3		; next routine
	bra.s	.key_search

not_keyb:
* not a keyboard event
	cmp.l	#"MENU",d0
	bne	not_menu

* it was a menu event!
* item number is in d1
* routines in a3
* list of items in a2

.test_list:
	move.w	(a2)+,d0
	bpl.s	.not_end
	rts

.not_end:
	sub.w	d1,d0
	beq.s	.got_item

	addq.l	#4,a3
	bra.s	.test_list

.got_item:
	move.l	(a3),a3
	jmp	(a3)



not_menu:
	rts

key_convert:
* unshifted key values
	dc.b	0,esc
	dc.b	"1234567890-=",backspace,tab
	dc.b	"qwertyuiop[]",enter,0
	dc.b	"asdfghjkl;'`",0,"#"
	dc.b	"zxcvbnm,./",0
	dc.b	0,0," ",0
	dc.b	f1,f2,f3,f4,f5,f6,f7,f8,f9,f10
	dc.b	0,0,clr_home,up_arr,0
	dc.b	"-",left_arr,0,right_arr,"+"
	dc.b	0,0,0,ins,del,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	"\",undo,help,"()/*7894561230.",enter

shift_convert:
* shifted key values
	dc.b	0,esc
	dc.b	'!"œ$%^&*()_+',backspace,tab
	dc.b	"QWERTYUIOP{}",enter,0
	dc.b	"ASDFGHJKL:@",0,"~"
	dc.b	"ZXCVBNM<>?",0
	dc.b	0,0," ",0
	dc.b	f1,f2,f3,f4,f5,f6,f7,f8,f9,f10
	dc.b	0,0,clr_home,up_arr,0
	dc.b	"-",left_arr,0,right_arr,"+"
	dc.b	0,0,0,ins,del,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0
	dc.b	"|",undo,help,"()/*7894561230.",enter

	even


wait_for_message:
* WAIT ONLY FOR MESSAGES!
	lea	message_buffer(pc),a0
	pea	(a0)
	move.w	#wait_for_message_event,-(a7)
	bsr	aes

	move.l	(a7)+,a0
	rts


wait_for_any_event:
* wait for keyboard, mouse button, or message event
* MOUSE LEFT BUTTON DOWN EVENT!
* NOT mouse rects or timer!!!

	move.w	#%010011,d0

	moveq	#1,d1		; no of clicks

	moveq	#1,d2
	moveq	#1,d3

	moveq	#0,d4		; mouse rect vars
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	clr.w	-(a7)
	clr.w	-(a7)
	clr.l	-(a7)
	clr.l	-(a7)

	clr.l	-(a7)		; timer vars

	lea	message_buffer,a0
	move.w	#wait_for_multiple_event,-(a7)
	bsr	aes

	bra	interpret_message


interpret_message:
	cmp.w	#1,d0		; is it keyboard?
	bne.s	mes_not_keyboard

	move.l	#"KEYB",d0
	rts

mes_not_keyboard:
	cmp.w	#2,d0
	bne.s	mes_not_mouse_button

	move.l	#"BUTT",d0
	rts


mes_not_mouse_button:
* must be a message event!
	lea	message_buffer,a4

	move.w	(a4)+,d0	; get message type
	cmp.w	#10,d0
	bne.s	not_menu_sel	; branch if not menu selected

	addq.l	#4,a4

	move.w	(a4)+,d1	; get obj no of menu title
	move.w	menu_number,d0	; get tree no of menu active
	bsr	menu_highlight_off

* return the obj no of selected menu item
	move.w	(a4)+,d1
	move.l	#"MENU",d0
	rts


not_menu_sel:
	sub.w	#20,d0
	cmp.w	#10,d0
	bhi.s	not_window_mes

* a window message was selected
	lsl.w	#2,d0
	lea	window_messages(pc),a0
	move.l	(a0,d0.w),d1		; get text for window message
	move.l	#"WIND",d1
	rts

not_window_mes:
	cmp.w	#20,d0
	bne.s	not_ac_open

	move.l	#"ACOP",d0
	rts

not_ac_open:
	move.l	#"APCL",d0
	rts

window_messages:
	dc.b	"DRAW","TOPP","CLOS","FULL","ARRO","HSLI","VSLI","SIZE","MOVE","NEWT"


jump_window_routine:
* pass list of routines in a0
* window message code in d1 (from wait_for_any_event)

	lea	window_messages(pc),a1

get_wind_rout:
	move.l	(a1)+,d0
	sub.l	d1,d0
	beq.s	got_wind_rout

	addq.l	#4,a0
	bra.s	get_wind_rout

got_wind_rout:
	move.l	(a0),a0
	jmp	(a0)




	ifd	link_library
	section	bss
	endc

message_buffer:
	ds.b	16




	ifd	link_library
	MODULE	MENUS
	XDEF	display_menu,erase_menu
	XDEF	display_tick,erase_tick
	XDEF	enable_menu_item,disable_menu_item
	XDEF	menu_highlight_on,menu_highlight_off
	XDEF	change_menu_text
	XDEF	add_to_desk_menu
	XDEF	menu_number

	XREF	aes,get_tree_data,ap_id
	endc


display_menu:
* tree no of menu passed in d0
	move.w	d0,menu_number

	bsr	get_tree_data

	moveq	#1,d0
do_dispera:
	move.w	#display_or_erase_menu_bar,-(a7)
	bsr	aes
	rts

erase_menu:
	move.w	menu_number,d0
	bsr	get_tree_data
	moveq	#0,d0
	bra.s	do_dispera


display_tick:
* d0 = tree no of menu
* d1 = obj no of menu item

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0
	moveq	#1,d1

	move.w	#display_or_erase_checkmark,-(a7)
	bsr	aes
	rts


erase_tick:
	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0
	moveq	#0,d1

	move.w	#display_or_erase_checkmark,-(a7)
	bsr	aes
	rts



enable_menu_item:
* tree no in d0
* obj no in d1

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0
	moveq	#1,d1

	move.w	#enable_or_disable_menu_item,-(a7)
	bsr	aes
	rts

disable_menu_item:
* tree no in d0
* obj no in d1

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0
	moveq	#0,d1

	move.w	#enable_or_disable_menu_item,-(a7)
	bsr	aes
	rts

menu_highlight_on:
* tree no in d0
* d1 = obj no of title

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0
	moveq	#0,d1

	move.w	#toggle_menu_title_highlight,-(a7)
	bsr	aes
	rts

menu_highlight_off:
	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0
	moveq	#1,d1

	move.w	#toggle_menu_title_highlight,-(a7)
	bsr	aes
	rts



change_menu_text:
* d0 = tree no
* d1 = obj no to change
* a0 = text to use

	move.w	d1,-(a7)
	pea	(a0)
	bsr	get_tree_data

	move.l	(a7)+,a1
	move.w	(a7)+,d0

	move.w	#change_menu_item_text,-(a7)
	bsr	aes
	rts


add_to_desk_menu:
* a0 = addr of menu text string

	move.w	ap_id,d0

	move.w	#add_item_to_desk_menu,-(a7)
	bsr	aes
	rts


	ifd	link_library
	section	bss
	endc

menu_number:
	ds.w	1


	ifd	link_library
	MODULE	AES_INIT_END
	XDEF	init_appl,clean_up_appl,ap_id

	XREF	aes
	endc

init_appl:
	move.w	#initialise_application,-(a7)
	bsr	aes
	move.w	d0,ap_id
	rts

clean_up_appl:
	move.w	#clean_up_application,-(a7)
	bsr	aes
	rts


	ifd	link_library
	section	bss
	endc

ap_id:
	ds.w	1
