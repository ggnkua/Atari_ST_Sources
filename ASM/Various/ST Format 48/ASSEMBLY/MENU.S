*If you are running Devpac2, you may need to rename gemmacro.i
*to gemmacro.s, or alter the include  gemmacro.i directive below
*The IFD __G2 directive will assemble everything following it
*until an ELSE or ENDC if you are using Devpac, otherwise
*everything between ELSE and ENDC is assembled 
*make sure your compiler knows where to find the include files
*if in doubt, put everything in the root of A:\, and run
*your compiler from the root of A:\

_sysbase	equ	$4f2
type_string	equ	5
R_TREE equ 0
stacksize equ 1000

	opt	XDEBUG

	

	include	gmdosmac.i
	include	xbiosmac.i
	include	menu.i

	IFD	__G2	*this tells us if we are running Devpac
	include	gemmacro.i
	ENDC

	move.l	4(a7),a3
	move.l	#ourstack+(stacksize*2),a7	
	bsr	initialise_program	
*We need to find which version of TOS we have for the file selector
	Supexec	#which_tos	
	IFD	__G2
	appl_init
	ELSE
	move.w	#10,control	appl_init
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#0,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	move.w	d0,ap_id		
	IFD	__G2
	rsrc_load	#rsc_file
	ELSE
	move.w	#110,control	rsrc_load
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	move.l	#rsc_file,addr_in
	bsr	call_aes
	ENDC
	beq	cant_find_it
	IFD	__G2
	graf_mouse	#0	
	ELSE
	move.w	#78,control	graf_mouse
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	clr.w	control+8
	move.w	#0,int_in
	bsr	call_aes
	ENDC
	IFD	__G2
	rsrc_gaddr	#R_TREE,#menu1
	ELSE
	move.w	#R_TREE,int_in
	move.w	#menu1,int_in+2
	move.w	#112,control	rsrc_gaddr
	move.w	#2,control+2
	move.w	#1,control+4
	move.w	#0,control+6
	move.w	#1,control+8
	bsr	call_aes
	ENDC
	move.l	addr_out,menu_tree
	IFD	__G2
	menu_bar	menu_tree,#1
	ELSE
	move.l	menu_tree,addr_in
	move.w	#1,int_in
	move.w	#30,control	menu_bar
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bset	#0,enable+1	this instruction sets bit #0 of address
				*enable+1. We will cange this bit
				*whenever the file selector menu is
				*enabled/disabled

main_loop
MU_KEYBD equ %1
MU_MESAG equ %10000	binary for decimal 16
	IFD	__G2
	evnt_multi	#%10001,,,,,,,,,,,,,,#message_buffer

	ELSE

	move.w	#25,control	evnt_multi
	move.w	#%10001,int_in
	move.l	#message_buffer,addr_in
	move.w	#16,control+2
	move.w	#7,control+4
	move.w	#1,control+6
	clr.w	control+8
	bsr	call_aes
	ENDC
	cmp.w	#MU_KEYBD,d0
	bne	try_menu
alt_q equ $1000	this is the key code for <Alternate> <q>
	move.w	int_out+10,d0	this is the keycode for the key pressed
	cmp.w	#alt_q,d0	was it alternate q?
*if you want to check the keycodes for other keys, set a breakpoint
*here in your debugger, run the program, and the value in d0 
*is the hex key code for the key you pressed
	bne	main_loop	no - next message
	bra	finished	yes - quit
try_menu
	lea	message_buffer,a0
	move.w	(a0),d0
MN_SELECTED	equ	10
	cmp.w	#MN_SELECTED,d0
	beq	handle_menu

	bra	main_loop

handle_menu
	move.w	8(a0),d1
	move.w	6(a0),d2
	cmp.w	#mymessage,d1
	bne	.notmymessage
	IFD	__G2
	form_alert	#1,#about_dialog
	ELSE
	move.l	#about_dialog,addr_in
	move.w	#1,int_in
	move.w	#52,control	form_alert
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bra	.back_to_loop
	
.notmymessage
	cmp.w	#quit,d1
	bne	.notquit
	bra	finished
.notquit
	cmp.w	#select,d1
	bne	.notselect
	Dgetdrv		fetch current drive
	add.w	#'A',d0		0=drive A, 1=B etc
	move.b	d0,path
	move.b	#':',path+1
	Dgetpath	#0,#file
	move.l	#path+2,a3
	move.l	#file,a4
.move_char
	move.b	(a4)+,(a3)+
	bne	.move_char
	move.b	#'\',-1(a3)
	move.b	#'*',(a3)+
	move.b	#'.',(a3)+
	move.b	#'*',(a3)+
	move.b	#0,(a3)+
	move.w	#0,file
	cmp.w	#$0104,tos	TOS 1.4 or greater?
	bge	.tos104
	IFD	__G2
	fsel_input	#path,#file
	ELSE
	move.l	#path,addr_in
	move.l	#file,addr_in+4
	move.w	#90,control	fsel_input
	move.w	#0,control+2
	move.w	#2,control+4
	move.w	#2,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bra	.not104
.tos104
	IFD	__G2
	fsel_exinput	#path,#file,#label
	ELSE
	move.l	#path,addr_in
	move.l	#file,addr_in+4
	move.l	#label,addr_in+8
	move.w	#91,control	fsel_exinput
	move.w	#0,control+2
	move.w	#2,control+4
	move.w	#3,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
.not104
*after the fsel_ call, path and file will be updated
	move.w	int_out+2,button 
*button now contains 0 if user selects Cancel, 1 for OK or Return
	bra	.back_to_loop
.notselect
	cmp.w	#checkmark,d1
	bne	.notcheck
	bchg	#0,check+1	an easy way to remember if the check
				*is on or off
	IFD	__G2
	menu_icheck	menu_tree,#checkmark,check
	ELSE
	move.l	menu_tree,addr_in
	move.w	#checkmark,int_in
	move.w	check,int_in+2
	move.w	#31,control	menu_icheck
	move.w	#2,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bra	.back_to_loop
.notcheck
	cmp.w	#onoff,d1
	bne	.notonoff
	bchg	#0,enable+1
	move.l	#toggle_string,a3
	move.w	enable,d1
	asl.w	#2,d1	
	move.l	0(a3,d1.w),a3	
	IFD	__G2
	menu_ienable	menu_tree,#select,enable
	menu_text	menu_tree,#onoff,a3
	ELSE
	move.l	menu_tree,addr_in
	move.w	#select,int_in
	move.w	enable,int_in+2
	move.w	#32,control	menu_ienable
	move.w	#2,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes

	move.w	#onoff,int_in
	move.l	menu_tree,addr_in
	move.l	a3,addr_in+4
	move.w	#34,control	menu_text
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#2,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bra	.back_to_loop
	
.notonoff
.back_to_loop	
	IFD	__G2
	menu_tnormal	menu_tree,d2,#1
	ELSE
	move.l	menu_tree,addr_in
	move.w	d2,int_in
	move.w	#1,int_in+2
	move.w	#33,control	menu_tnormal
	move.w	#2,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bra	main_loop
	
	
cant_find_it
	IFD	__G2
	form_alert	#1,#rsc_load_error
	ELSE
	move.l	#rsc_load_error,addr_in
	move.w	#1,int_in
	move.w	#52,control	form_alert
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	bra	stop

initialise_program	
	move.l	$c(a3),d0	*length of text
	add.l	$14(a3),d0	*length of data
	add.l	$1c(a3),d0	*length of BSS
	add.l	#$100,d0	*length of basepage
	Mshrink	d0,a3		*Macro to return unwanted memory
	rts

which_tos
	move.l	_sysbase,a0
	move.w	2(a0),tos	this stores our version of TOS
	rts

finished
	IFD	__G2
	menu_bar	menu_tree,#0
	rsrc_free
	ELSE
	move.l	menu_tree,addr_in
	move.w	#0,int_in
	move.w	#30,control	menu_bar
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,control+8
	bsr	call_aes

	move.w	#111,control	rsrc_free
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#0,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
stop	
	IFD	__G2
	appl_exit	tell the AES we're finished
	ELSE
	move.w	#19,control	appl_exit
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#0,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	Pterm	#0	and quit
		
	IFND	__G2
call_aes
	move.l	#aes_params,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out,d0
	rts

	DATA
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out
	ENDC
	DATA

rsc_file	dc.b	'MENU.RSC',0
rsc_load_error	dc.b	'[3][Could not find Resource file][Bye]',0
about_dialog	dc.b	'[3][St Formats Example Menu][OK]',0
label		dc.b	'Select a File',0
menu_string1	dc.b	' Enable Select ',0	
menu_string2	dc.b	' Disable Select ',0
**********
*keep these two together
toggle_string	dc.l	menu_string1
		dc.l	menu_string2
**********
	BSS
menu_tree	ds.l	1
ap_id		ds.w	1
message_buffer	ds.b	16
savessp		ds.l	1
tos		ds.w	1
check		ds.w	1
enable		ds.w	1
path		ds.b	128
file		ds.b	128
button		ds.b	1
ourstack	ds.w	stacksize
	IFD	__G2
	include	aeslib.s
	ELSE
	
*the AES parameters
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1

	ENDC

