	comment HEAD=1
;	opt xdebug
	opt p=68030
	output .prg

debug_level:	= 1
use_printf:	= 0
tos_program	= 0 ;Set to non-zero if no VDI/AES is to be used

a6_bss	= 1	;Certain modules need the structure part covering the aes/vdi pb

	include	header\system\av_proto.h
	;include	header\system\olga.h
	;include	header\system\fntproto.h

	include	header\mine\a6_bss.h
	include	header\mine\edit_equ.h
	;include	header\mine\as_proto.h
	include	header\mine\structs.h
	include	header\mine\popup.h
	include	header\mine\winflags.h
	include	header\mine\appflags.h
	include	header\mine\txtframe.h

	include	header\system\aes.h
	include	header\system\vdi.h
	include	header\system\gemdos.h
	include	header\system\dragdrop.h

	;include the appropriate .RSC file object names definitions here
	include	gemdem.i

mc030	= 1
fpu	= 0

*** These are for the "TXTWNUPD.S" file..
rout_scrolltop	= 0	;Disable this to not assemble the scrolltop- routs.
;		;Only the scroll/page routines are assembled in this case
;
txtwin_updslds	= 0	;Disable this if the routines sroll_up, scroll_down,
;		;scroll_left, scroll_right, page_up, page_down, pageupdown
;		;page_flip and page_udflip are to be used in Dialog boxes only.
;		;Then the the calls to set the sliders and kbd flush are not assembled
;		;along with the routines themselves.


child_asm	= 0 ;To use either child_asm or module_asm, plugin_asm MUST also be enabled.
module_asm	= 0 ;This one is used to generate "plug-in-modules". Not yet finished
plugin_asm	= 0
lib_asm		= 0

;=======================================================================
;==== If using the textframes, TF_editor enables full editor frames ====
;==== while TF_edline enables the editable lines                    ====
;=======================================================================
TF_editor	= 0
TF_edline	= 1

use_tf_getinfo		= 1
use_tf_find		= 1
use_tf_fglocate		= 0
use_tf_edit		= 1
use_tf_openline		= 0
use_tf_deleteline	= 0
use_tf_navigate		= 1
use_tf_realtimescroll	= 0
use_tf_mmark		= 1
use_tf_markwrd		= 0
use_tf_markline		= 1
use_tf_unmark		= 1
use_tf_clrtext		= 1
use_tf_newtext		= 1
use_tf_replacetext	= 0
use_tf_inserttext	= 1
use_tf_fntchange	= 1
use_tf_setfont		= 1
use_tf_setbkgcol	= 0
use_tf_cursorinstall	= 1
use_tf_cursormove	= 1
use_tf_cursorpos	= 1
use_tf_cursorupdate	= 0
use_tf_sliderupd	= 0
use_tf_upd_slids	= 0
use_tf_redraw		= 1
use_tf_moved		= 1

;================================================
;==== Stack size the application should have ====
;================================================
stack_size	= 1024*4
alloc_size	= 1024*4
chunks_block	= 100

subroutine_call	= 0

Get_gemdos_v	= 1
Get_freemem	= 0
Get_screenbase	= 1
Get_gdos_v	= 1
Get_OS_cookie	= 1
Get_TOS_v	= 0
Get_AES_info	= 1
Get_startpath	= 1

Open_VDI	= 1
Get_screeninfo	= 1

;=========================================================================
;=== If use_aslb_lrsc is turend off, make sure you set num_rsc_objects ===
;=== to the number of objects contained in the resource file we use.   ===
;=========================================================================
use_aslb	= 1	;Use my own object drawing lib
use_aslb_lrsc	= 0	;Use my own rsrc_load function
aslb_bfnt_size	= 0	;Set this to make the rsrc_load routine alsways
			;calculate rsc with fontheight = 16, width = 8
use_aslb_edit	= 0	;Use my own implementation of editable objects
use_aslb_edl:	= 0
use_aslb_txt:	= 0

	IFEQ use_aslb_lrsc
num_rsc_objects	= 200
	ENDC
	
use_mint_domain	= 1
use_filebuffers	= 1

use_dialfolders	= 0

; Switches for routines in W_DIALOG.S
use_change_objflag	= 1
use_change_objstat	= 1
use_toggle_objstat	= 1
use_toggle_objflag	= 1
use_obj_radio		= 1 ;get_objstat, change_objstat
use_obj_radio_bord	= 1 ;get_objstat, obj_setborder
use_obj_setborder	= 1
use_get_objetype	= 0
use_get_objtype		= 0
use_get_objcolwrd	= 1
use_set_objcolwrd	= 1
use_justdraw_object	= 1
use_set_menu_text	= 1
use_set_tetxt_obj	= 1
use_get_tetxt_obj	= 0
use_set_obj_wh		= 0
use_set_obj_w		= 0
use_set_obj_h		= 0
use_get_objstat		= 1
use_get_objflag		= 0
use_obj_border_calc	= 1 ;get_objborder
use_get_objborder	= 1
use_get_objcliprect	= 1 ;obj_screenxy, obj_getobjoffset
use_get_objoffset	= 1 ;get_objborder
use_obj_screenxy	= 1 ;Always set
use_obj_scrn_wrkxy	= 1 ;obj_screenxy
use_obj_relativxy	= 1 ;obj_screenxy, get_objoffset
use_obj_rel_wrkxy	= 1 ;obj_relativxy
use_set_dialogbox	= 1
use_prepare_object	= 1 ;get_objcliprect
use_check_objevnt	= 1 ;get_objcliprect
use_chk_for_upd		= 1 
use_count_childs	= 1 ;tree_walk
use_copy_tree		= 1
use_tree_walk		= 1
;create_dialwind	= 1 ;get_objoffset

; Switches for routines in DWINDOW.S, OWINDOW.S and WIN_COMM.S
use_win_elements	= 1
use_menu_we		= 0
use_dialog_we		= 0

use_owin_stack		= 1
use_dwin_stack		= 0

; switches for routines in "aesmesag.s"
use_send_wm_moved	= 1
use_send_wm_redraw	= 1
use_send_wm_xredraw	= 1
use_send_wm_closed	= 1 ;Used by GEMSHELL.S if use_mu_keybd is set (ctrl+u closes top wind)
use_send_wm_fulled	= 1
use_send_wm_iconfy	= 0

use_olga		= 0

		IFNE	use_olga
olga_mode		= (1<<OL_CLIENT)
be_olga_client		= 1
be_olga_server		= 0

use_send_olga_update		= 0
use_send_olga_opendoc		= 1
use_send_olga_closedoc		= 1
use_send_olga_link		= 1
use_send_olga_unlink		= 1
use_send_olga_linkrenamed	= 0
use_send_olga_start		= 0

olga_txt_groupid	= 10
		ENDC	;use_olga

; Switches for routines in AV_MESAG.S
use_vaserver		= 1	;Uncomment this to lookfor and use a VASERVER
use_vadragaccwind 	= 0	;Uncomment this to support vadragaccwind
use_vastart		= 0	;Uncommnet this to use VA_START
use_send_vastart	= 0
use_send_avsndkey	= 0
use_send_avpathupd	= 0

;=======================================================================
;==== Switches determining what routines should be assembled or not ====
;=======================================================================
;---- window types ----
dial_winds	= 1	;Uncomment this to use dialog windows
size_winds	= 1	;Uncomment this to use sizable widnows
text_winds	= 0	;Uncomment this to use text windows (requires size_winds)
ed_routs	= 0	;Uncomment this to use the text/editor scrolling routines.

;---- Drag&Drop protocol ----
use_dragdrop	= 0	;Uncommnet this to use Drag&Drop

use_rsc	= 1	;Uncomment this to load and use a RSC file (requires dial_winds)
use_vdi	= 1	;Uncomment this to use common vdi routines
use_menubar	= 1	;Uncomment this to use the menu routines.
use_xmenubar	= 0	;Uncomment this to use the extended menu routines, which are one of my window element routines
use_sliders	= 0	;Uncomment this to use the slider routines for use with dialog-windows, etc.
use_unknown_msg	= 0	;Uncomment this to use the "unknown_msg" routine that is called when the message is not recognized.
use_cmdline	= 0	;Uncommnet this to use the command line.

use_aesmsgs	= 1	;Uncomment this to assemble the aes message handling
use_selafile	= 1	;Uncomment this to use the "select_a_file" routine
use_mu_timer	= 1
use_mu_keybd	= 1
use_mu_button	= 1
use_mu_m1	= 1
use_mu_m2	= 0
use_win_msgs	= 1

use_dial_mods	= 1	;If this is enabled, a table of dialog module routines,
			;called "dial_mods" must be present.

kids_routines	= 0	;If this is enabled, all the routines concerning creating child
			;processes and it's BSS's are assembled.

thread_routines = 0	;If this is enabled, routines dealing with setting up baspages
			;and dealing with creating theads are assembled.

create_kids	= 0	;This is a flag for the setting the use_kids flag or not.
create_threads	= 0
create_routtab	= 0	;If this is enabled, a table of routines are prepared.

quit_on_nowinds = 0	;Uncomment this to quit on no open windows

;====================================================================================
;==== Variables telling how many windows and shuch the application should handle ====
;====================================================================================
	IFNE	dial_winds
max_dialwinds	= 6	;Number of dialog windows this application should handle
dwin_kind	= (1<<NAME)+(1<<MOVER)+(1<<CLOSER)+(1<<SMALLER)+(1<<FULLER)    ;Default dialog window gadgets
def_dwflags	= (1<<(w_botm_f+8))+(1<<(w_topp_f+8))+(1<<(w_drag_f+8))+(1<<(w_ntop_f+8))	;+(1<<(w_uicn_f+8))
	ENDC	;dial_winds
	
	IFNE	size_winds
max_owindows	= 10	;Number of sizable windows this application should handle
owin_kind	= (1<<NAME)+(1<<MOVER)+(1<<CLOSER)+(1<<SMALLER)+(1<<FULLER)    ;Default sizable window gadgets
def_owflags	= (1<<(w_botm_f+8))+(1<<(w_topp_f+8))+(1<<(w_drag_f+8))+(1<<(w_uicn_f+8))
	ENDC	;size_winds
	
max_kids	= 20

;max_edits	= 5

;==================================
;==== Diverse buffer size defs ====
;==================================
aespb_size	= 24	;Size of the buffer to contain the AES parameter block
vdipb_size	= 20	;Size of the buffer to contain the VDI parameter block
miscbuff_size	= 400	;Size of misc buffers
aesinmsg_size	= 40	;Size of the aes message in buffer
aesoutmsg_size	= 40	;Size of the aes message out buffer
strtpathbuff_size = 400	;Size of buffer to hold the start-path
fmaskbuff_size	= 8	;Size of buffer to hold the filemask
pathnbuff_size	= 400	;Size of buffer to hold pathnames
filenbuff_size	= 68	;Size of buffer to hold filenames
pathfile_size	= pathnbuff_size+filenbuff_size ;Size of buffer to hold the full path/file-name
dta_size	= 100	;Size of the DTA buffer


;===============================================================================================
;==== Bit mask, as defined in by the AV protocol, of which AV messages application supports ====
;===============================================================================================
av_supported	= %110 	;We support va_start and av_started

;====================================================================
;==== This file contains the project dependant lable definitions ====
;====================================================================
	include	demo_bss.h
	include	gemdemo.h

numberof_demoes	= 10
max_demoes	= 10

	;include the appropriate .RSC file object names definitions here
	include	gemshell.s
	
