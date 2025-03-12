		even

		rsset	0

	IFEQ tos_program
aespb		rs.l	1
vdipb		rs.l	1

***************VDI arrays
contrl		rs.w	12
intin		rs.w	128
ptsin		rs.w	256
intout		rs.w	128
ptsout		rs.w	12

********* AES Arrays
control		rs.w	0
opcode		rs.w	1
sintin		rs.w	1
sintout		rs.w	1
saddrin		rs.w	1
saddrout	rs.w	1

global		rs.w	0
ap_version	rs.w	2
ap_count	rs.w	2
ap_id		rs.w	2
ap_private	rs.w	4
ap_ptree	rs.w	4
ap_1resv	rs.w	4
ap_2resv	rs.w	4
ap_3resv	rs.w	4
ap_4resv	rs.w	4

int_in		rs.w	128
int_out		rs.w	128
addrin		rs.l	5
addrout		rs.l	5

end_aesvdipb	rs.w	0
	ENDC	;tos_program

global_flags	rs.l	1 ;Global flags	;See the "appflags.h" for a description of the flags..

base_page	rs.l	1	;Address of base page
flat_stack	rs.l	1	;Position of stack out of all routines
free_mem	rs.l	1
mem_block	rs.l	1	;Address of the first block of memory
prg_size	rs.l	1	;Size of the program
phys_screen	rs.l	1
logi_screen	rs.l	1
iorecb		rs.l	1	;Address of the iorec buffer
gemdos_v	rs.l	1
tos_v		rs.w	1

**** Multitasking kernel info ****
	IFEQ	tos_program
mtask		rs.w	1	;Number of processes that can run concurrently.
	ENDC	;tos_program
mtask_type	rs.l	1	;Bit mask, see the "appflags" for description..
				;0 = No multitasking. 1 = MiNT, 2 = MagiC
				;(mint_f = 0, magx_f = 1 ... so if both cookies found, the value vill be 3! )

old_dta		rs.l	1	;Address of the original DTA buffer
my_dta		rs.l	1	;Address of my DTA buffer

startpath_buff	rs.l	1	;Address of the pathname string where the program started. Taken from  ARGV(0) if used.
selfile_msg	rs.l	1	;Pointer to a string that is passed to the fileselector when opening it.
filemask_buff	rs.l	1	;Address of file mask string
pathname_buff	rs.l	1	;Address of filename string (last selected)
filename_buff	rs.l	1	;Address of pathname string (last selected)
pathfile_buff	rs.l	1	;Address of full path/filename of last selected file



	IFEQ	tos_program
*************	WORKSTATION INFORMATION
gdos_v		rs.l	1
apl_id		rs.l	1	;AES application ID
appl_name	rs.l	1	;Pointer to the applications name (used when running as ACC or under a m.tasking system)
aplf_name	rs.l	1	;Pointer to the applicatiosn name used with APPL_FIND (space-padded 8-char name)
graf_handle	rs.w	1	;AES vdi handle
work_handle	rs.w	1	;Our vdi handle
fonts_loaded	rs.w	1	;Number of fonts loaded with vst_load_fonts
screen_x	rs.w	1	;Screen X size
screen_y	rs.w	1	;Screen Y size
planes		rs.w	1	;Planes
bpg		rs.w	1	;Bytes per group
scanlenght	rs.w	1	;scanlengh

**************	STANDAR ROUTINES ARE INSTALLED HERE
event_loop	rs.l	1	;Address of the main event determination routine.
acopen_r	rs.l	1	;Address of routine to execute when AC_OPEN message is received.
acclose_r	rs.l	1	;Address of routine to execute when AC_CLOSE message is received.
aestimr_r	rs.l	1	;Address of routine to execute on MU_TIMER events.
mu_m1_r		rs.l	1	;Address of routine to execute on MU_M1 events
mu_m2_r		rs.l	1	;Address of rouitne to execute on MU_M2 events
menu_sel_r	rs.l	1	;Address of routine to execute on MN_SELECTED messages
mn_kbd_r	rs.l	1	;Address of routine to exectue on MU_KBD events
aplterm_r	rs.l	1	;Adderss of routine to execute when AP_TERM message is received.
dragdrop_r	rs.l	1	;Address of routine to execute when AP_DRAGDROP message is received.
vastart_r	rs.l	1	;Address of routine to execute when VA_START message is received.
vadawind_r	rs.l	1	;Address of routine to execute when VA_DRAGACCWIND message is received.
unk_msg_r	rs.l	1	;Address of routine to execute when the message received is not supported
quit_r		rs.l	1	;Address of last routine to execute before quitting
***
dialog_modules	rs.l	1	;Pointer to a table containing routine addresses to deal with dialog contol structures (i.e. dialog slider controls)
***
**************	THREADING VARIABLES
thread_1	rs.l	1
threadin	rs.w	1
;aes_busy	rs.b	1
;vdi_busy	rs.b	1
;mbuff1_busy	rs.b	1
;mbuff2_busy	rs.b	1
;fbuffs_busy	rs.b	1
;dta_busy	rs.b	1

**************	SOME DEFAULT VALUES
dwin_bss	rs.l	1	;Address of the first Dialog window's BSS
dwin_stack	rs.l	1
dwin_bsssize	rs.w	1	;Size of a window's BSS
dwin_slots	rs.w	1	;Number of slots in this BSS table

owin_bss	rs.l	1	;Address of the first Sizable window's BSS
owin_stack	rs.l	1	;
owin_bsssize	rs.w	1	;Size of a window's BSS
owin_slots	rs.w	1	;Number of slots in this BSS table

dwin_gadgets	rs.w	1	;Dialog window gadgets
dwin_flags	rs.w	1	;Dialog window default flags
owin_gadgets	rs.w	1	;Sizable window gadgets
owin_flags	rs.w	1	;Sizable window default flags
twin_gadgets	rs.w	1	;Toolbar window gadgets
twin_flags	rs.w	1	;Toolbar window default flags

on_top		rs.l	1	;Address of the current topped window's bss (0 if none)
open_windows	rs.w	1	;Number of open windows by this application
	ENDC 	;tos_program
misc_buffsize	rs.w	1	;Size of each of the misc_buffers
misc_buff1	rs.l	1	;Address of a 400 byte misc buffer (f.e. used to hold rectangle lists)
misc_buff2	rs.l	1	;Address of a 400 byte misc buffer 
child_buffsiz	rs.l	1	;The size of the DATA area that held the routines.
child_buffer	rs.l	1	;This is the DATA area that contained the routine table. This table is moved and this area can then be used as a buffer for starting children
	IFEQ	tos_program
aesin_msg	rs.l	1	;Address of the AES message buffer
aesout_msg	rs.l	1	;Address of buffer used to send AES messages

src_mfdb	rs.l	1	;Address of the current MFDB used with all VRO_CPYFM calls
dst_mfdb	rs.l	1	;Address of the current MFDB used with all VRO_CPYFM calls

child_inherits	rs.l	0


**************
av_server	rs.l	3	;The name of the AV_SERVER application
av_serverid	rs.w	1	;Id of the AV_SERVER application
av_support	rs.l	4	;AV_PROTOCOL flag the server supports
av_isupport	rs.l	2	;AV_PROTOCOL tlag that I support
av_proto_gmem:	rs.l	1	;Pointer to global mem used in AV_PROTOCOL/VA_PROTOSTATUS
*************
olga_info	rs.l	1	;Pointer to a block of olga information (see olga.h)

*************	AES INFORMATION
aes_v		rs.w	1

;Info about the aes bigfont
ae_bfont_pnt	rs.w	1
ae_bfont_id	rs.w	1
ae_bfont_type	rs.w	1

;Info about the aes smallfont
ae_sfont_pnt	rs.w	1
ae_sfont_id	rs.w	1
ae_sfont_type	rs.w	1

;AES color informations
ae_res_code	rs.w	1
ae_objcols	rs.w	1
ae_cicons	rs.w	1
ae_ext_rsc	rs.w	1 ;extended rsc support flag

;AES language
language	rs.w	1 ;AES language code

;AES Multitasking info
ae_process	rs.w 	1	;0 = Non pre-emptive mtasking - 1 = Pre-emtive mtasking
ae_mintaes_id	rs.w	1	;0 = APPL_FIND can't convert between MiNT and AES id's - 1 = it can.
ae_appl_serch	rs.w	1	;0 = APPL_SEARCH not implemented - 1 = APPL_SEARCH is implemented
ae_rsrc_rcfix	rs.w	1	;0 = RSRC_RCFIX not implemented  - 1 = RSRC_RCFIX is implemented

;AES PC GEM support
ae_objc_xfind	rs.w	1	;0 = OBJC_XFIND not implemented or 1 if it is
ae_menu_click	rs.w	1	;0 = MENU_CLICK not implemented or 1 if it is
ae_shel_xdef	rs.w	1	;0 = SHEL_RDEF & SHEL_WDEF not implemented or 1 if they are

;AES Inquire support
ae_appl_read	rs.w	1	;0 = -1 not a valid AP_ID or 1 if it is
ae_shel_get	rs.w	1	;0 = -1 not a valid lenght parameter to SHEL_GET or 1 if it is
ae_menu_bar	rs.w	1	;0 = -1 not a valid mode parameter to MENU_BAR or 1 if it is
ae_mb_INSTL	rs.w	1	;0 = MENU_INSTL not a valid mode parameter to MENU_BAR or 1 if it is

;AES Mouse support
ae_graf_mouse	rs.w	1	;0 = Mode parameters of 258 - 260 not supported by GRAF_MOUSE or 1 if they are
ae_mouse_form	rs.w	1	;0 = Application has control over the mouse form or 1 , it's maintained by AES on a per-application basis

;AES menu support
ae_sub_menus	rs.w	1	;0 = Sub menus not supported or 1 if MultiTOS style sub menus are
ae_popup	rs.w	1	;0 = Popup menus not supported or 1 if MultiTOS style popups are
ae_scroll_menu	rs.w	1	;0 = Scrollable menus not supported or 1 if MultiTOS style scrollable are
ae_mn_select	rs.w	1	;0 = MN_SELECTED msg doesn't contain object tree info or 1 if it does

;AES SHEL_WRITE support
ae_sw_himode	rs.w	1	;LSBtye = Highest legal value for mode parameter and MSByte = supported extended mode bits
ae_sw_0mode	rs.w	1	;0 = Mode param of 0 launches an app or 1 if it cancels the previous SHEL_WRITE
ae_sw_1mode	rs.w	1	;0 = Mode param of 1 launches an app immediately or 1 if it takes effect when the current app exits
ae_sw_argv	rs.w	1	;0 = ARGV parameter passing not supported or 1 if it is.

;AES window support
wf_support	rs.w	1
wg_support	rs.w	1

;AES message support
wm_support	rs.w	1
wm_behaves	rs.w	1

;AES object support
ae_3d_objs	rs.w	1	;0 = 3D objects not supported or 1 if they are
ae_objc_sysvar	rs.w	1	;0 = not present
				;1 = MultiTOS v1.01 OBJC_SYSVAR present
				;2 = Extended OBJC_SYSVAR present
ae_gdos_fonts	rs.w	1 	;0 = Only the system font supported or 1 if GDOS fonts are supported.

;AES form support
ae_flyingdial	rs.w	1	;0 = Flying dialogs not supported or 1 if they are
ae_kbdtable	rs.w	1	;0 = keyboard tables not supported of 1 if they are
ae_curspos	rs.w	1	;0 = Last cursor position not returned or 1 if it is
child_inherits_end rs.l	0

;endof_ae
	
		;IFNE	use_menubar
menu_addr	rs.l	1 ;Address of menu
		;ENDC

		;IFNE	dial_winds
****
dialog_flags	rs.w	1
		;ENDC

		;IFNE	use_sliders
slider_flags	rs.w	1

	;These bits are used by drag_slider.
	* low byte	Bit 0 - 0 = Slider not at bottom | 1 = Slider at bottom
	* 	Bit 1 - 0 = Slider not at top | 1 = Slider at top.
	*	Bit 2 - 0 = No mouse control | 1 = mouse control called, undo it when mouse button released.
	
	;These bits are user presets - See "appflags.h"

	*** Real Time Slider Dragging flag
	* high byte	Bit 0 - 0 = No realtime slider action, "drag_slider" exits only when the mouse button is released with relative position.
	*	        1 = Realtime action, "drag_slider" exits with the relative position and carry set to indicate that mouse is still pressed, carry clear = mouse released, end of session.

	*** Fast Slider Update, loop mode flag.
	*	Bit 1 - 0 = After each slider setting, evnt_multi is called.
	*	        1 = The slider is continuesly updated until mouse button is released
	
	*** Real time update of slider in loop mode. (only effective if Fast Slider Update is selected)
	*	Bit 2 - 0 = The sliders are updated when a change in it's position occurs
	*                       1 = The sliders are not updated until the mouse button is released.

lst_slidmx	rs.w	1 ;This holds the last mouse pos when using "real-time" sliders with "drag_slider"
lst_slidmy	rs.w	1
		;ENDC
		
	ENDC	tos_program
	
***** Diverse flags
acc_flag	rs.b	1	;Set on startup if ACC, cleared if prog
argv_valid	rs.b	1	;set on startup if commands are passed via ARGV
arguments	rs.w	1	;Total number of arguments
num_args	rs.b	1	;Flag used by "getone_arg" routine. Set = arguments are space delimitted, 0 = args no space delimitted
		rs.b	1

	IFEQ	tos_program
skip		rs.b	1
flag3		rs.b	1
child_start	rs.b	1
i_a_kid		rs.b	1
a6flg_res	rs.b	1
		rs.b	1
***************
evnts		rs.w	1
***************

*************** Drag&Drop Protocol transfers
;dragdrop_mem
;dd_msg		rs.w 1	;Used when sending DD messages
;dd_fname	rs.l 1	;Pointer to the filename to open (U:\PIPE\DRAGDROP.XX)
;dd_headsize	rs.w 1	;Size of the header store here
;dd_type		rs.l 1	;If successful, this contains the data type
;dd_support	rs.l 1	;Pointer to support table
;dd_header	rs.l 1	;Pointer to a buffer to store header
;dd_data		rs.l 1	;Pointer to a buffer to store data

parent_bss	rs.l 1	;Address of the parent BSS
child_bss	rs.l 1	;Address of the child BSS
kids		rs.l 1	;Address of a table containing child ID's (only for the server)
kid_slotsiz	rs.w 1	;Size of each slot in the child table
kid_slots	rs.w 1	;Number of slots in the child table
born_kids	rs.w 1	;Number of childern currently alive
	ENDC	;tos_program	

env_addr	rs.l 1	;Address of table of environment entry addresses
argv_addr	rs.l 1	;Address of table of argument entry addresses
argv_value	rs.l 1	;Pointer to the value of ARGV= if argv_valid flag set.

n_routs		rs.w 1	;Number of addresses

avd_bss_size	= __RS

		;ds.b	__RS

;avd_bss_size	= __RS

