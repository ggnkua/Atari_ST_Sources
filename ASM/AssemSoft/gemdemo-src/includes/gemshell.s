 IFEQ	tos_program
	IFNE	dial_winds+size_winds

use_windows	= 1
	
	ELSEIF	;dial_winds+size_winds
use_windows	= 0

	ENDC	;dial_winds+size_winds
 ENDC	;tos_program

	include	macros\oddmacro.i 

 IFEQ tos_program
	include	macros\aesmacro.i
 ENDC ;tos_program
	
	include	header\system\keys.h
	include	header\system\atari.h
	include	header\system\errno.h
	;include	header\system\mintdefs.h
	
 IFEQ tos_program
	include	header\mine\winelmnt.h
	include	header\mine\wind_bss.h
 ENDC tos_program


 ;IFNE	debug_level
 	include	macros\debug.i
 	include	macros\printf.i
 ;ENDC	;debug_level

	text

	;Clear the memory area used by AES/VDI parameter passing and so on..
begin_prg
	IFNE	debug_level
		move.w	#(debug_level<<8)|debug_level,__debuglevel
	ENDC

	IFEQ	subroutine_call

		lea	gemdos,a6
		move.w	#(avd_bss_size/2)-1,d0
		movea.l	a6,a1
.clr_avd	clr.w	(a1)+
		dbra	d0,.clr_avd

	ELSEIF	;subroutine_call

	;Get the Gemdos version..
		move.w	#$30,-(sp)
		trap	#1
		addq.l	#2,sp
		move.l	d0,d3

	;Gemdos function number MALLOC in low word and stack adjust in upper.
		move.l	#$60048,d4

	;Check the GEMDOS version and use MXALLOC if possible
		cmp.w	#$1900,d3		;GEMDOS above 0.19 ?
		blo.s	.memold			;No
		move.w	#3,-(sp)		;TT-ram preferred, but any accepted
		move.l	#$80044,d4		;GEMDOS MXALLOC function and stack fix

.memold		move.l	#avd_bss_size,-(sp)	;Number of bytes to allocate
		move.w	d4,-(sp)		;GEMDOS funcktion
		trap	#1			;ALLOCATE

	;Get stack repair into low word and fix stack
		clr.w	d4
		swap	d4
		add.l	d4,sp
		move.l	d0,return_code
		beq	quit
				
	;Zero the BSS memory...
		move.l	d0,a6
		move.l	#avd_bss_size,d2
		lsr.w	#1,d2
		subq.w	#1,d2
		movea.l	a6,a1
.clr_avd	clr.w	(a1)+
		dbra	d2,.clr_avd

	ENDC	;subroutine_call

	;If A0=NULL -> .prg else it's an ACC
	;If A0 is not 0 you're an ACC, A0 is then pointing to the uncomplete filled basepage.
	;TPA is sized and you have to build your own stack.
		include	startup\startup.s

	;	DEBUG_OPEN	<'test.txt'>

	;Init our program with the VDI, AES, load the RSC, get the current directory and
	;get as much info as possible about the system.
thread_enter:	include	startup\gem_init.s	

*************************************************************************************************
 IFEQ tos_program
**** Try to load our RSC file
	;Load the rsc file and do the necessary things related
	IFNE	use_rsc
	 IFNE	use_aslb
		jsr	init_cobject
		bcc	terminate
	 ENDC	;use_aslb
load_RSC
		cmp.w	#400,screen_y(a6)
		blo.s	.small_rsc
		move.w	ae_bfont_pnt(a6),d0
		beq.s	.big_rsc
		cmp.w	#9,d0
		bls.s	.small_rsc
.big_rsc	lea	big_rsc,a0
		bra.s	.load_rsc
.small_rsc	lea	small_rsc,a0
.load_rsc
	IFNE	use_aslb_lrsc
		jsr	load_resource
	ELSEIF	;use_aslb_lrsc
		RSRC_LOAD	a0
	ENDC	;use_aslb_lrsc

		beq	no_RSC

	ENDC ; use_rsc
 ENDC ;tos_program
*************************************************************************************************
 IFEQ tos_program
**** Check if there is an AVSERVER present
	IFNE	use_vaserver

		include	startup\getavsrv.s

	ELSEIF	; use_vaserver

		move.w	#-1,av_serverid(a6)

	ENDC	; use_vaserver
	
*************************************************************************************************

	IFNE	use_olga
		include	startup\olga.s
	ENDC	;use_olga
	
 ENDC ;tos_program
*************************************************************************************************
**** Allocate "global" memory needed by the application

	;Allocate memory for buffers the application needs.
		bsr	alloc_aplmem
		bcs.s	start
		bsr	memory_problems
		bra	quit


	;This file contains the main wait-code, which is just a call
	;to EVNT_MULTI, specific for the current project
 IFEQ tos_program
	IFNE	use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs
		include	mainevnt.s
	ENDC	;use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs

	;In startup.prj, the stuff like setting up the BSS, checking the command line
	;are done before entering the main event loop.
 ENDC ;tos_program

start
		printf	<'STARTING!!!\r\n'>

 IFEQ tos_program
		include	startup.prj
 ELSEIF ;tos_program
 		include body.prj
 ENDC ;tos_program

***** MAIN LOOP *********
		move.l	sp,flat_stack(a6)

 IFEQ tos_program ; This IF takes out the complete main loop!!

	IFNE	use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs
	
		move.l	#check_events,event_loop(a6)
ventmere:	DEBUG_INIT	<'GemShell: '>
.main_loop:	tst.b	acc_flag(a6)		;Are we an ACC?
	IFEQ	debug_level
		bne.s	.acc_wait		;Yes, then don't quit on no open windows
	ELSEIF
		bne	.acc_wait
	ENDC
		btst	#now_term,global_flags+2(a6)
		beq.s	.acc_wait
		tst.w	open_windows(a6)	;Any more open windows?
		bne.s	.acc_wait		;No, all windows closed, exit
		DEBUG	1,<'Terminating program - no more open windows...\r\n'>
		DEBUG_EXIT

	;Send ap_term to ourselves to terminate
		move.w	apl_id(a6),d0
		jsr	send_ap_term
		;bra	quit

.acc_wait:	DEBUG	3,<'Waiting for events...\r\n'>
		bsr	wait_event		;Wait for user to do something
		DEBUG	3,<'Event - %b\r\n'>,w,d0
		move.w	d0,evnts(a6)		;Store the events that happened
		bsr.s	check_events
		bra	.main_loop		;ventmere
	
	ELSEIF	;use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs
		bra	quit
	ENDC	;use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs

check_events

	IFNE	use_aesmsgs

		btst	#4,evnts+1(a6)
		beq.s	.chk_kbd

	IFEQ	debug_level
		bsr.s	aes_messages
	ELSEIF
		bsr	aes_messages
	ENDC

	ENDC	;use_aesmsgs

.chk_kbd
	IFNE	use_mu_keybd

		btst	#0,evnts+1(a6)
		beq.s	.chk_m1
		bsr	evnt_kbd		;Check the key sent.
		;bcc.s	.chk_m1			;If we used it, don't pass it to the AVSERVER
	
	;Pass the pressed key to the AVSERVER, if we know it.
	 IFNE	use_vaserver
	  IFNE	use_send_avsndkey
		bcc.s	.chk_m1			;If we used it, don't pass it to the AVSERVER
		bsr	send_avsndkey
	  ENDC	;use_send_avsndkey
	 ENDC	;use_vaserver
	 
	ENDC	;use_mu_keybd
	
.chk_m1
	IFNE	use_mu_m1

		btst	#2,evnts+1(a6)
		beq.s	.chk_m2
		move.l	mu_m1_r(a6),d0
		beq.s	.chk_m2
		move.l	d0,a4
		jsr	(a4)

	ENDC	;use_mu_m1
.chk_m2
	IFNE	use_mu_m2

		btst	#3,evnts+2(a6)
		beq.s	.chk_button
		move.l	mu_m2_r(a6),d0
		beq.s	.chk_button
		move.l	d0,a4
		jsr	(a4)

	ENDC	;use_mu_m2

.chk_button
	IFNE	use_mu_button
		btst	#1,evnts+1(a6)		;envt_button?
		beq.s	.chk_timer		;No
		bsr	event_button		;Do the button
	ENDC	;use_mu_button
.chk_timer
	IFNE	use_mu_timer
		btst	#5,evnts+1(a6)
		beq.s	.exit
		move.l	aestimr_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		DEBUG	4,<'Executing timer routine %lx\r\n'>,l,a4
		jsr	(a4)
	;Only the last message check is to jump back.
.exit		rts

	ELSEIF	;use_mu_timer
	IFNE	use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs
		rts
	ENDC	;use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs
	ENDC	;use_mu_timer
	
	IFNE	use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs
aes_messages	move.l	aesin_msg(a6),a3
		DEBUG	4,<'AESmsg %x\r\n'>,w,(a3)
	IFNE	use_win_msgs

		move.w	6(a3),d0		;Get handle of window in question
	IFNE	dial_winds
	;Seach my dialog-window table for this window
		bsr	find_dialwind
		bcs.s	.oki			;Ok, dialog-window found
	ENDC	;dial_winds

	IFNE	size_winds
	;Search my sizable-window table for this window
		bsr	find_owindow
		bcs.s	.oki			;Ok, sizable window found
	ENDC	;size_winds
		bra	.no_win_msg
.oki
		cmp.w	#wm_hslid,(a3)
		beq	hslid

.aes_m1
		cmp.w	#wm_redraw,(a3)
		beq	redraw
		cmp.w	#wm_xredraw,(a3)
		beq	redraw
	IFNE	use_win_elements
		cmp.w	#wm_weupdate,(a3)
		beq	update_all_we
	ENDC	;use_win_elements
		cmp.w	#wm_vslid,(a3)
		beq	vslid
		cmp.w	#wm_arrowed,(a3)
		beq	arrowed
		cmp.w	#wm_moved,(a3)
		beq	moved
		cmp.w	#wm_topped,(a3)
		beq	topped
		cmp.w	#wm_closed,(a3)
		beq	closed
	 	cmp.w	#wm_fulled,(a3)
 		beq	fulled
 		cmp.w	#wm_bottom,(a3)
		beq	bottom
		cmp.w	#wm_untopped,(a3)
		beq	untopped
		cmp.w	#wm_ontop,(a3)
		beq	ontop
		cmp.w	#wm_iconfy,(a3)
		beq	iconfy
		cmp.w	#wm_uniconfy,(a3)
		beq	uniconfy
		cmp.w	#wm_sized,(a3)
		beq	sized

	IFNE	use_dragdrop
		cmp.w	#ap_dragdrop,(a3)
		beq	dragdroped
	ENDC	;use_dragdrop

	IFNE	use_vadragaccwind
		cmp.w	#VA_DRAGACCWIND,(a3)
		beq	va_dragwindow
	ENDC	;use_vadragaccwind
		bra.s	.got_window

	ENDC	;use_win_msgs
	
	;msg's not related to a specific window calls the different
	;routines with A5 = NULL
.no_win_msg	suba.l	a5,a5
	
	IFNE	use_dragdrop
		cmp.w	#ap_dragdrop,(a3)
		beq	dragdroped
	ENDC	;use_dragdrop

.got_window
	IFNE	use_vastart
		cmp.w	#VA_START,(a3)
		beq	va_started
		cmp.w	#AV_STARTED,(a3)
		beq	av_started
		
	ENDC	;use_vastart
	
		cmp.w	#ac_open,(a3)
		beq	open_acc
		cmp.w	#ac_close,(a3)
		beq	close_acc
		cmp.w	#ap_term,(a3)
		beq	app_terminate
	
	IFNE	use_menubar
		cmp.w	#mn_selected,(a3)
		beq	mnu_select
	ENDC	;use_menubar

	IFNE	use_xmenubar
		cmp.w	#mn_xselected,(a3)
		beq	mnu_select
	ENDC	;use_xmenubar
	
	IFNE	create_kids
		cmp.w	#ch_exit,(a3)
		beq	child_exited
	ENDC	;create_kids
	
	IFNE	use_olga
		cmp.w	#OLGA_INIT,(a3)
		beq	olga_init
	
	ENDC	;use_olga

		move.l	unk_msg_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		rts

	;The user wanted to open the ACC
open_acc	btst	#applmem,global_flags+3(a6)
		bne.s	.ok
		bsr	alloc_aplmem
		bcs.s	.ok
		bsr	memory_problems
		move.l	flat_stack(a6),sp
		bra	quit
.ok		move.l	acopen_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		rts

	;Close the ACC
close_acc	move.l	acclose_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		bset	#acclose,global_flags+3(a6)
		jsr	(a4)
	;	bsr	free_aplmem
		bclr	#acclose,global_flags+3(a6)
.exit		rts
	
app_terminate	tst.b	acc_flag(a6)
		beq.s	.real_apterm

	IFNE	use_windows
		moveq	#0,d0
		bsr	close_allwin
	ENDC	;use_windows
		rts
		
.real_apterm:	bset	#apterm,global_flags+3(a6)
		move.l	aplterm_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
		btst	#waitkids,global_flags+3(a6)
		beq.s	.exit
		rts
.exit:		move.l	flat_stack(a6),sp
		DEBUG	1,<'Terminating app...\r\n'>
		DEBUG_EXIT
		bra	quit			;Quittin

	ENDC	;use_aesmsgs+use_mu_timer+use_mu_keybd+use_mu_button+use_mu_m1+use_mu_m2+use_win_msgs

	IFNE	use_win_msgs

****	WM_CLOSED
	;Close and delete a window
closed		move.l	win_close(a5),d0
		beq.s	.no_clean
		move.l	d0,a4
		jsr	(a4)
.no_clean
	IFNE	use_win_elements
		move.w	#wes_close,d0
		bsr	execute_elements
	ENDC	;use_win_elements
		bsr	delete_window
		rts
	
****	WM_TOPPED
	;Top a window
topped	
	IFNE	dial_winds
		btst	#w_dial_f,win_flags+3(a5)	;Window requested topped a dialog-window?
		beq.s	.top_it				;No
		bsr	topped_dwin			;Check for buttons clicked inside window
		rts
	ENDC ; dial_winds

.top_it		bsr	win_set_topped

****	WM_ONTOP
	;One of my windows have been topped
ontop		move.l	a5,on_top(a6)
		rts
	
****	WM_BOTTOM
	;Send the window to the bottom
bottom		bsr	win_set_bottom
****	WM_UNTOPPED
	;Untop a window
untopped	cmpa.l	on_top(a6),a5
		bne.s	.exit
		clr.l	on_top(a6)
.exit		rts
	
******	WM_REDRAW
	;Redraw a window
redraw		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list	
.no_bef		move.l	win_redraw(a5),d0
		beq.s	.exit
		move.l	d0,a4
		bsr	redraw_window
.exit		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts

******	WM_ICONIFY
iconfy
	IFNE	dial_winds
		btst	#w_dial_f,win_flags+3(a5)
		beq.s	.no_dialwin
		bsr	iconfy_dw
		rts
	ENDC 	;dial_winds

.no_dialwin
	IFNE	size_winds
		bsr	iconfy_win
	ENDC	;size_winds

.exit		rts

******	WM_UNICONIFY
uniconfy
	IFNE	dial_winds
		btst	#w_dial_f,win_flags+3(a5)
		beq.s	.no_dialwin
		bsr	uniconfy_dw
		rts
	ENDC	;dial_winds

.no_dialwin
	IFNE	size_winds
		bsr	uniconfy_win
	ENDC	;size_winds

.exit		rts

******	WM_MOVED
moved		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list	
.no_bef		move.l	win_moved(a5),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)

	IFNE	use_dial_mods
		btst	#w_dial_f,win_flags+3(a5)
		beq.s	.exit
		move.l	#$a0000000,d0
		move.w	(a3),d0
		bsr	set_dialogbox
	ENDC	;use_dial_mods

.exit
	IFNE	use_win_elements
		move.w	#wes_move,d0
		bsr	execute_elements
	ENDC	;use_win_elements
		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts

a_rts		rts

******	WM_SIZED
sized		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		move.l	win_sized(a5),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit
	IFNE	use_win_elements
		move.w	#wes_size,d0
		bsr	execute_elements
	ENDC	;use_win_elements
		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts

******	WM_FULLED
fulled		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		move.l	win_fulled(a5),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit
	IFNE	use_win_elements
		move.w	#wes_full,d0
		bsr	execute_elements
	ENDC	;use_win_elements
		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft	rts

******	WM_ARROWED
arrowed		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		move.l	win_arrow(a5),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list	
.no_aft	rts
	
******	WM_HSLID
hslid		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		move.l	win_hslid(a5),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts

******	WM_VSLID
vslid		move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		move.l	win_vslid(a5),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts

	ENDC	;use_win_msgs
	
	
	IFNE	use_menubar
mnu_select	move.l	menu_sel_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		rts
	ELSEIF	;use_menubar

	IFNE	use_xmenubar
mnu_select	move.l	menu_sel_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit		rts
	ENDC	;use_xmenubar

	ENDC	;use_menubar


	IFNE	use_dragdrop
dragdroped:	move.l	dragdrop_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit:		rts
	ENDC	;use_dragdrop

	
               
******	VA_START received
	IFNE	use_vastart
va_started:	DEBUG	4,<'VA_STARTING %s received from apl_id %i\r\n'>,l,6(a3),w,2(a3)
		move.l	vastart_r(a6),d0
		beq.s	.exit
		move.l	6(a3),d0	;Pointer to the argument string
		bne.s	.no_empty
	IFNE	use_selafile
		bsr	select_a_file
		bcs.s	.fsel
		bra.s	.exit
	ELSEIF	;use_selafile
		bra.s	.exit
	ENDC	;use_selafile
.no_empty:	move.l	d0,a1
.fsel:		move.l	vastart_r(a6),a4
		jsr	(a4)	
.exit:		DEBUG	4,<'Done VA_START...\r\n'>
		rts
****** AV_STARTED received
	;Just call to release the memory
av_started:	DEBUG_INIT	<'av_started: '>
		move.l	6(a3),d1
		jsr	freeup_memory
		DEBUG_EXIT
		rts	
	ENDC	;use_vastart


	IFNE	use_win_msgs
	IFNE	use_vadragaccwind
****	VA_DRAGACCWIND reveived
va_dragwindow:	move.l	vadawind_r(a6),d0
		beq.s	.exit
		move.l	d0,a4
		jsr	(a4)
.exit:		rts
	ENDC	;use_vadragaccwind
	ENDC	;use_win_msgs
	
;----------------  olga stuff  -------------------------------------------
	IFNE	use_olga
olga_init	DEBUG	4,<'Doing OLGA Init...\r\n'>
		move.l	olga_info(a6),d0
	IFEQ	debug_level
		beq.s	.no_olga
	ELSEIF
		bne	.no_olga
	ENDC
		move.l	d0,a4
		tst.w	14(a3)		;Error?
		beq.s	.init_err
		move.w	6(a3),ol_man_info(a4)
		move.w	8(a3),ol_prot_level(a4)
		or.w	#1<<olga_available,olga_flags(a4)
		DEBUG	4,<'OLGA_INIT successful\r\n'>
		rts
.init_err	DEBUG	1,<'Error while processing OLGA_INIT!\r\n'>
		and.w	#(-1<<olga_available)-1,olga_flags(a4)
.no_olga	rts
	ENDC	;use_olga
	
	IFNE	use_aesmsgs
	IFNE	kids_routines
child_exited	move.w	6(a3),d0
		jsr	find_child
		bcc.s	.exit
		clr.l	kidtab_access(a2)
		subq.w	#1,born_kids(a6)
		bne.s	.exit
		btst	#apterm,global_flags+3(a6)
		beq.s	.exit
	;	addq.l	#8,sp
		move.l	flat_stack(a6),sp
		bra	quit
.exit		rts
	ELSEIF	;kids_routines
		rts
	ENDC	;kids_routines
	ENDC	;use_aesmsgs
	
	IFNE	use_windows
	 IFNE	use_win_elements
	;Send wes_update to all window elements of all windows
update_all_we	move.w	#wes_update,d0
		lea	execute_elements,a4
		bsr.s	execute_allwin
		rts
	 ENDC	;use_win_elements
	ENDC	;use_windows

;--------------------------------------------
	IFNE	use_windows
close_allwin
	IFNE	dial_winds
		bsr	close_alldwin
	ENDC	;dial_winds

	IFNE	size_winds
		bsr	close_allowin
	ENDC	;size_winds
		rts

	ENDC	;use_windows

;--------------------------------------------
	;Execute a routine, pointed to by A4, for all windows used by this app
	IFNE	use_windows
execute_allwin
	IFNE	dial_winds
		bsr	execute_alldwin
	ENDC	;dial_winds
	IFNE	size_winds
		bsr	execute_allowin
	ENDC	;size_winds
		rts
	ENDC	;dial_winds


;------------------------------------------
	;JSR to all routines listed in a table passed here in D0
execute_list	movem.l	d0-a6,-(sp)

		move.l	d0,a3

.next		move.l	(a3)+,d0
		beq.s	.done
		move.l	d0,a4
		jsr	(a4)
		bra.s	.next

.done		movem.l	(sp)+,d0-a6
		rts
		ifne 0
*********************
**	The key pressed if first passed to the routine installed in mn_kbd_r(a6), in which
**	all the menu-shortcuts should be processed. If the key pressed is not processed in this
**	routine, the register D7 must be intact and the carry cleared. Then, if the key was not processed,
**	the routine installed at the topped windows win_keybd entry is called. The rules for this routine
**	is the same as for for the above.

** The routine that is called must clear the carry if the key was used.
** Otherwize it must set the carry and leave D7 intact upon return so that the key
** can be passed to the AVSERVER, if it exists.
** D7 contains the SCANCODE in upper word and ASCII code in lower word of the pressed
** key upon entry to the keyboard routine
		endc 0
	IFNE	use_mu_keybd
evnt_kbd	move.l	int_out+8(a6),d7	;Get key and scancode in D7
		cmp.b	#$11,d7			;Ctrl+q is quit app..
		beq.s	.kbd_quit
	
	;This part is where we deal with global keypresses, and keys that
	;we want to pass back to the avserver
	IFNE	use_windows
		cmp.b	#Asc_ctrl_w,d7		;Ctrl+w is global window cycling..
		beq.s	.not_used		;..pass on to the avserver

	 IFNE	use_send_wm_closed
		cmp.b	#Asc_ctrl_u,d7		;Ctrl+u is close topped window..
		beq.s	.kbd_closecurnt
	;Here we can check for more global keys...

		bra.s	.nu1			;Done checking for system-keypresses
	
.kbd_closecurnt	bsr	get_toppedwin
		bcc.s	.used
		bsr	send_wm_closed
		bra.s	.used
	 ENDC	;use_send_wm_closed
	ENDC	;use_windows
	
	;From here on, applicaion specific keys are considered.
.nu1
	IFNE	use_windows
	;1st, pass the key to the kbd routine for the topped window
	;If no topped window, or if the kbd rout for the topped didn't use
	;the key, pass it on to the menu_keys routine
		bsr	get_toppedwin
		bcc.s	.nu2
		move.l	win_keybd(a5),d0
		beq.s	.menu_keys		;not_used
		move.l	d0,a4
		jsr	(a4)
		bcc.s	.used			;not_used
	ENDC	;use_windows

.nu2
	;This is where the menu entry kbd equvivalents are processed.. 
	;Get address of the "menu" keyboard routine and execute it.
.menu_keys	move.l	mn_kbd_r(a6),d0
		beq.s	.not_used
		move.l	d0,a4
		jsr	(a4)
		bcc.s	.used
	
.not_used	move.l	d7,int_out+8(a6)
		or.b	#1,ccr
		rts
	
.used		and.b	#-2,ccr
		rts

.kbd_quit	bra	app_terminate
	ENDC	;use_mu_keybd
	
	

***************************************************************************************************
	IFNE	use_mu_button
	
event_button	move.l	int_out+2(a6),d1	;Get mouse X&Y
		move.l	int_out+6(a6),d2	;Get buttons used in high word,  Keyboard Shift status in low word
		move.w	int_out+12(a6),d3	;Get number or clicks
	
		printf	<'buttons %lx, clicks %x\r\n'>,l,d2,w,d3

	;Get handle of window under mouse when it was clicked, if any
		WIND_FIND	<l>,d1
		bne.s	evnt_butt_wh
		rts
	
	;D0 = Handle of window clicked, if any
	;D1 = X and Y pos of mouse.
	;D2 = High word - mouse buttons, low word - Keyboard shif status
evnt_butt_wh	
	IFNE	dial_winds
		bsr	find_dialwind		;Search our stack of dialog windows
		bcc.s	.sizew			;Not found
		bsr.s	evntb_dialw		;Process the click within this dialog window
	IFNE	size_winds
		bra.s	.exit
	ENDC	;size_winds
	ENDC	;dial_winds
	
	;Reset the A5 pointer to the current window on top and exit
.sizew
	IFNE	size_winds
		bsr	find_owindow
		bcc.s	.exit
		bsr	evntb_owind
	ENDC	;size_winds
	
.exit		tst.l	on_top(a6)
		beq.s	.non_ontop
		move.l	on_top(a6),a5
.non_ontop	rts

*****************************************************************************************************
************* Dialog window underneath the mouse at click
	IFNE	dial_winds
evntb_dialw	move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		btst	#w_icon_f,win_flags+3(a5)
		bne.s	.dw_icon		;This dialog window is iconfied
		bsr	dodialog		;Check if there are any object under the mouse
		bcs.s	.exit			;A object was in fact clicked.

	;No object was located under the mouse
		move.l	win_button(a5),d0
		beq.s	.dw_icon
		move.l	d0,a4
		jsr	(a4)
		bcs.s	.exit

	;Nothing installed in win_button either, now try win_elements
	IFNE	use_win_elements
		move.w	#wes_bclick,d0
		bsr	execute_elements
		bcs.s	.exit
	ENDC	;use_win_elements
	
.dw_icon	lea	dummy_rts(pc),a4	;Jump to this routine if a double click.
		bsr	no_objects		;Check if we should top or untop the window if clicked outside objects
.exit		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts
	ENDC	;dial_winds

*********** Sizable window underneath the mosue at click
	IFNE	size_winds
evntb_owind	move.l	win_before(a5),d0
		beq.s	.no_bef
		bsr	execute_list
.no_bef		btst	#w_icon_f,win_flags+3(a5)
		bne.s	.do_more
		move.l	win_button(a5),d0
		beq.s	.do_more
		move.l	d0,a4
		jsr	(a4)
		bcs.s	.exit

	;Nothing installed in win_button either, now try win_elements
	IFNE	use_win_elements
		move.w	#wes_bclick,d0
		bsr	execute_elements
		bcs.s	.exit
	ENDC	;use_win_elements
	
.do_more	lea	dummy_rts(pc),a4
		bsr	no_objects
.exit		move.l	win_after(a5),d0
		beq.s	.no_aft
		bsr	execute_list
.no_aft		rts
	ENDC	;size_winds

***************
dummy_rts	rts
		ifne 0
********************************************************************************************************************
*dodialog													   *
*	This routine is called by the event_button routine when a click has occurred within a dialog window	   *
*	The address of the window's BSS, containing the dialog, is passed in A5, and the address of the		   *
*	root object is passed in A0. The X and Y of mouse at which it was clicked is passed in D1 and the	   *
*	mouse button state is passed in the high word, keyboard status in low word of D2. Address of the	   *
*	users "formdo" routine is passed in A1 and is "jsr" to if nothing else is to be done (i.e. no		   *
*	slider objects clicked, etc.)										   *
**************** FOR THIS TO WORK, THE OBJECT CANT BE "SELECTABLE" CAUSE THEN THE AES REDRAWS			   *
**************** THE OBJECT OVER OTHER THINGS IF IT'S HALF COVERED.						   *
*														   *
*	 D1 = X coord in upper and Y coord in lower word of the mouse						   *
*	 D2 = high word - mouse state, low word - Keyboard status						   *
*	 D3 = Number of clicks											   *
*														   *
*	 A0 = Address of the root object tree									   *
*	 A1 = Address of the users "formdo" routine								   *
*	 A5 = BSS address of the window containing the object.							   *
*	 A6 = Pointer to our big table										   *
********************************************************************************************************************
		endc 0
dodialog	move.l	obj_addr(a5),a2			;Get address of the dialog control block
		OBJC_FIND	a0,<l>,#7,<l>,d1 	;Check under mouse for a clickable object
		move.w	int_out(a6),d4			;Any clickable objects?
		bmi.s	.no				;No
		FORM_BUTTON	,d4,#1			;Let the AES deal with the click
		tst.w	int_out(a6)			;An EXITABLE object?
		bne.s	.no				;No.

		moveq	#0,d0				;Make sure the upper word is cleared
		move.w	d4,d0				;Then put the object's index in the low word
		ifne 0
* When we get here, we start looking at the dialog control block for, f.e., dialog slider funtions.
* 	 D0 = Object index
*	 D1 = X and Y of mouse
*	 D2 = high word - mouse button state, low word - Keyboard status
*	 D3 = Number or mouse clicks
*	 A0 = Address of root object
*	* A1 = Address of a misc buffer to hold a rectangle list for screen updates of the object tree
*	       (This is not initialized yet, but will be. That's why I set it up here)
*	 A2 = Address of the dialog control block.
*	 A5 = BSS address of window containing the dialog object
*	 A6 = Address of our big table
		endc 0

	; check if the clicked object has a formdo routine attached
		jsr	object_formdo
		bcs.s	.ok

	;Check if the object is a member of a Folder Structure...
	IFNE	use_dialfolders
		bsr	do_folder
		bcs.s	.ok
	ENDC	;use_dialfolders

	IFNE	use_aslb_edit
		jsr	do_editable
		bcs.s	.ok
	ENDC	;use_aslb_edit

;	IFNE	use_sliders
;		jsr	do_slider
;		bcs.s	.ok
;	ENDC	;use_sliders

;		tst.l	Dcb_structs(a2)		;Any dialog control sturctures in the control block?
;		beq.s	.user_object		;A NULL pointer terminates the control block.

	;We've got a dialog structure, jsr through the list of
	;dialog modules until a routine deals with the control structure.
;		move.l	dialog_modules(a6),d4	;Address of a table containing dialog handline modules
;		beq.s	.user_object		;No modules, just use the users "formdo"
;		move.l	d4,a3			;Address of table in A3
;.nxt_mod	move.l	(a3)+,d4		;Get address of routine
;		beq.s	.user_object		;A NULL terminates the modules table
;		move.l	d4,a4			;Use A4
;		jsr	(a4)			;Execute the module routine.
;		bcs.s	.ok			;the routine sets the carry if it recognised this control structure and acted upon it.
;		bra.s	.nxt_mod		;check next entry in the modules table.

	; D0 = object index
	; D1 = X and Y of mouse
	; D2 = button state, keyboard status
	; D3 = Number of clicks
.user_object	cmpa.l	#0,a1
		beq.s	.ok
		jsr	(a1)
.ok		or.b	#1,ccr
		rts
.no		and.b	#-2,ccr
		rts
	
	IFNE	dial_winds+size_winds
		include	aes\no_objs.s
	ENDC	;dial_winds+size_winds

	ENDC	;use_mu_button

	IFNE	use_dialfolders
		include	dialogs\dialfldr.s
	ENDC	;use_dialfolders
	
	IFNE	use_selafile
;********************************************************************************************************************
;*select_a_file	This routine is called upon to let the user select a file. (oh, really?) If a file was selected,   *
;*	the full path to the selected file is returned in "path_file", whose address is returned in A1.		   *
;*	"pathname" will contain the pathname and "filename" will contain the filename separately. If the	   *
;*	user pressed cancel, the carry will be cleared to indicate this and A1 and "path_file" is not		   *
;*	valid. Otherwise carry is set.										   *
;*														   *
;*	 A6 Pointer to our big table										   *
;*														   *
;*	 A1 = Pointer to "path_file" containing the selected file.						   *
;*														   *
;*subs:	makepathfile	(files.s)										   *
;*	select_file	(files.s)										   *
;*	getpathstr	(files.s)										   *
;********************************************************************************************************************
selafile	reg d0-a0/a2-3
select_a_file	movem.l	selafile,-(sp)

		move.l	pathname_buff(a6),a0
		move.l	a0,a2
		jsr	paths_unx2gmd
		move.l	filemask_buff(a6),a1
		move.w	#'*'<<8,(a1)
		move.l	a0,a2
		jsr	paths_unx2gmd
		move.l	pathfile_buff(a6),a2
		jsr	paths_unx2gmd

		jsr	makepathfile		;Merge the pathname and the mask into path_file
		movea.l	a2,a0			;Use the pathname with attacted mask as path to fsel

		move.l	filename_buff(a6),a1	;Initial filename (if a file selected, it's name will be returned in here)
		move.l	selfile_msg(a6),a2	;Message that is displayed by the fileselector if supported
	
		jsr	select_file
		beq.s	.cancel
		move.l	pathname_buff(a6),a0	;Put the resluting path here (if you want the fsel to open in this directory the next time)
		move.l	pathfile_buff(a6),a2	;the fsel put the reslting path+mask here
		jsr	getpathstr		;Strip off the mask from pathname
		jsr	makepathfile		;Then append the filename to the pathname

	;Now, the full path+fname is contained in "path_file"
		move.l	pathfile_buff(a6),a1
		
		or.b	#1,ccr
.exit		movem.l	(sp)+,selafile
		rts
.cancel		and.b	#-2,ccr
		bra.s	.exit

		include	gemdos\selfile.s
		include	gemdos\fstrings.s

	ENDC	;use_selafile

 ENDC ;tos_program ** this ones IF is at the start of the main loop, "ventmere"
******************************************
quit
 IFEQ tos_program
		move.l	quit_r(a6),d0
		beq.s	.no_quitr
		move.l	d0,a4
		jsr	(a4)
 ENDC ;tos_program
.no_quitr
 IFEQ tos_program
	IFNE	use_olga
		move.l	olga_info(a6),d0
		beq.s	.no_olga
		move.l	d0,a4
		move.w	olga_id(a4),d0
		move.l	aesout_msg(a6),a0
		move.w	#OLE_EXIT,(a0)
		move.w	apl_id(a6),2(a0)
		clr.l	4(a0)
		clr.l	8(a0)
		clr.l	12(a0)
		jsr	send_msg
.no_olga
	ENDC	;use_olga
	
	IFNE	use_vaserver
		move.w	av_serverid(a6),d0
		bmi.s	.no_av
		move.l	aesout_msg(a6),a0
		move.w	#AV_EXIT,(a0)+
		move.w	apl_id(a6),(a0)+
		clr.w	(a0)+
		move.w	apl_id(a6),(a0)
		jsr	send_msg
	ENDC	;use_vaserver
.no_av
	IFNE	use_rsc
	 IFNE	use_aslb
		;jsr	free_resource
		jsr	delete_cobject
	 ELSEIF	;use_aslb
		RSRC_FREE
	 ENDC	;use_aslb
		bra.s	no_RSC_nomsg
	
no_RSC		FORM_ALERT	#1,#no_RSC_alert
no_RSC_nomsg
	ENDC	;use_rsc
		APPL_EXIT
	
	IFNE	Open_VDI
		move.l	#$650000,contrl(a6)
		clr.w	contrl+6(a6)
		move.w	work_handle(a6),contrl+12(a6)
		jsr	vdi
	ENDC	;Open_VDI
 ENDC ;tos_program
		bsr	free_aplmem
		
terminate
	IFNE	use_filebuffers
	;	move.l	startpath_buff(a6),d1
	;	beq.s	.no_filebuff
	;	jsr	mem_free
.no_filebuff
	ENDC	;use_filebuffers

 IFEQ tos_program
	IFNE	dial_winds
	;	move.l	dwin_bss(a6),d1
	;	beq.s	.no_dwin
	;	jsr	mem_free
.no_dwin	
	ENDC	;dial_winds
	
	IFNE	size_winds
	;	move.l	owin_bss(a6),d1
	;	beq.s	.no_owin
	;	jsr	mem_free
.no_owin
	ENDC	;size_winds

	;	move.l	aespb(a6),d1	;Address of memory containing aes/vdi parameter blocks and the aes in/out message buffers
	;	beq.s	.no_aespb
	;	jsr	mem_free
.no_aespb	
 ENDC ;tos_program
 
	IFEQ	subroutine_call
		clr.w	-(sp)
		move.w	#$4c,-(sp)
		trap	#1
	ELSEIF	;subroutine_call
		move.l	a6,d1
		jsr	mem_free
		move.l	return_code,d0
		rts
	ENDC	;subroutine_call

 IFEQ tos_program
		data
;shit		dc.b "[x][123456789012345678901234567890|123
	IFNE use_rsc
no_RSC_alert	dc.b "[3][ Where is my RESOURCE file? ][ Oisann! ]",0
	ENDC ;use_rsc
	
	IFNE	dial_winds
		include	dialogs\w_dialog.s
	ENDC	;dial_winds

	IFNE	use_sliders
	 IFNE	use_aslb+use_rsc
	 	include	dialogs\slides.s
	 ENDC	;use_aslb+use_rsc
		include	aes\sliders.s
	ENDC	;use_sliders

	IFNE	use_vdi
		include	vdi\vdi.s
	ENDC	;use_vdi
 ENDC ;tos_program	

** Free "global" memory used.
free_aplmem	bsr	free_miscbuffs
		bclr	#applmem,global_flags+3(a6)
		rts

** Allocate "global" memory and set up buffer addresses
alloc_aplmem	btst	#applmem,global_flags+3(a6)
		bne.s	.ok_exit
		bsr	alloc_miscbuffs
		bcc	.error
		bset	#applmem,global_flags+3(a6)
.ok_exit	or.b	#1,ccr
		bra.s	.exit
.error		and.b	#-2,ccr
.exit		rts

memory_problems	rts

***
*	Free the memory allocated for "misc_buff1" and "misc_buff2"
free_miscbuffs	move.l	d1,-(sp)
		move.l	misc_buff1(a6),d1
		beq.s	.exit
		jsr	freeup_memory
		clr.l	misc_buff1(a6)
		clr.l	misc_buff2(a6)
.exit		move.l	(sp)+,d1
		rts

	;Allocate memory for the two misc buffers
alloc_miscbuffs	movem.l	d0-2,-(sp)
		tst.l	misc_buff1(a6)
		bne.s	.ok_exit
		moveq	#0,d0
		move.w	misc_buffsize(a6),d0
		move.l	d0,d2
		lsl.l	#1,d0
		moveq	#3,d1
		jsr	get_memory
		beq.s	.terminate	;.no_memory
		move.l	d0,misc_buff1(a6)
		add.l	d2,d0
		move.l	d0,misc_buff2(a6)
.ok_exit	or.b	#1,ccr
.exit		movem.l	(sp)+,d0-2
		rts
.terminate	and.b	#-2,ccr
		bra.s	.exit

 IFEQ tos_program
	IFNE	dial_winds
clr_dwbss	move.l	dwin_bss(a6),d0
		beq.s	.exit
		move.l	d0,a5
		moveq	#0,d0
		move.w	dwin_bsssize(a6),d0
		mulu	dwin_slots(a6),d0
		lsr.w	#1,d0
		subq.w	#1,d0
.clr		clr.w	(a5)+
		dbra	d0,.clr

		move.l	dwin_stack(a6),d0
		beq.s	.exit
		move.l	d0,a5
		move.w	dwin_slots(a6),d0
		subq.w	#1,d0
.clr_stack	clr.w	(a5)+
		dbra	d0,.clr_stack
		clr.w	(a5)
.exit		rts
	ENDC	;dial_winds

	IFNE	size_winds
clr_owbss	move.l	owin_bss(a6),d0
		beq.s	.exit
		move.l	d0,a5
		moveq	#0,d0
		move.w	owin_bsssize(a6),d0
		mulu	owin_slots(a6),d0
		lsr.w	#1,d0
		subq.w	#1,d0
.clr		clr.w	(a5)+
		dbra	d0,.clr

		move.l	owin_stack(a6),d0
		beq.s	.exit
		move.l	d0,a5
		move.w	owin_slots(a6),d0
		subq.w	#1,d0
.clr_stack	clr.w	(a5)+
		dbra	d0,.clr_stack
		clr.w	(a5)
.exit		rts
	ENDC	;size_winds
 ENDC ;tos_program	

		include	includes.prj
	
		include	gemdos\cpu_mode.s
		include	system\fndcooki.s
		include	aes\threads.s


	IFEQ	tos_program
		include	aes\aesmesag.s
		include	system\oddgemnw.s
	ENDC	;tos_program

		data
	
* DATA.S contains the data area of the program, containing default settings and and so on.
		include	data.s
	IFNE	use_printf
		include	system\printf.s
	ENDC	;use_printf

	IFNE	debug_level
		include	system\debug.s
		include	system\syserror.s
	ENDC	;debug_level

 IFEQ tos_program
	IFNE use_dragdrop
		data
		even
ddfname		dc.b "U:\PIPE\DRAGDROP.XX",0 ;bytes 17 and 18 access the externder

		even
ddsupport	dc.l "ARGS"
		dc.l 0
		dc.l 0
		dc.l 0

		bss
dd_buffer	ds.b	1024
	ENDC	;use_dragdrop



	IFNE	use_vdi
		data
		even

dst_md		dc.l 0
		dcb.w 10,0

src_md		dc.l 0
fd_width	dc.w 0
fd_height	dc.w 0
fd_wdwidth	dc.w 0
fd_stand	dc.w 0
fd_planes	dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0

	ENDC	;use_vdi
 ENDC ;tos_program

		bss
		even
****************************************************************************************************
*	WORKSTATION INFORMATION BSS				   *
****************************************************************************************************

	IFNE	subroutine_call
return_code	ds.l 1
	ENDC
	
	IFEQ	subroutine_call
		bss
gemdos		ds.b	avd_bss_size

		even
		ds.b	stack_size
our_stack	ds.l	1

	ENDC	subroutine_call
;		end

