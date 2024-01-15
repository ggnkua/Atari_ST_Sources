********************* ed_bss_init ********
** Editor default table. When opening a new text-editor window, a pointer to such a structure
** is passed to the "new_textwin" routine.
		rsset 0
ed_bssdefs	rs.l 1 ;Address of table containing default values for the Editor
ed_defseps	rs.l 1 ;Address of a NULL terminated string containing word separators (Used when a word is clicked)
ed_dsepsiz	rs.w 1 ;Size of word separator string
ed_dvdi		rs.l 1 ;Address of the ed_v_settings structure
ed_bssinit_ssize = __RS

;===================================================================
;==== The two following are only used when attached to a window ====
;===================================================================
ed_winrdefs	rs.l 1 ;Address of table containing routines to install into a editor window's BSS
ed_dwinrsiz	rs.w 1 ;Number of routines to install

****************************** ed_bssdefs **********************
;This is how the structure of the ed_bssdefs looks
		rsset 0
ed_d_linebuff	rs.l 1 ;Address of a buffer that will be used during updates. If NULL, a buffer will be allocated
ed_d_textblksiz	rs.l 1 ;Size of the text-block used for this editor
ed_d_tablsize	rs.w 1 ;Default tab-stop size
ed_d_maxlinlen	rs.w 1 ;Default maximul linelenght
ed_d_loffset	rs.w 1 ;Default left offset
ed_d_roffset	rs.w 1 ;Default right offset
ed_d_uoffset	rs.w 1 ;Default upper offset
ed_d_boffset	rs.w 1 ;Default bottom offset
ed_d_flags	rs.w 1 ;Default flags
ed_d_eolchr	rs.w 1 ;ASCII value of the eol character to show when selected
ed_d_ssize	= __RS

****************************** ed_dvdi *********************
;This is a structure describing the VDI settings when opening a workstation for a Editor

		rsset 0
ed_v_fntid	rs.w 1	;Font ID
ed_v_fntpnts	rs.w 1	;Font size/height
ed_v_fntcolor	rs.w 1	;Font color
ed_v_fnteffect	rs.w 1	;Font effects

ed_v_fntsload	rs.w 1	;Number of fonts loaded
ed_v_fntname	rs.w 18	;Font name
ed_v_fnttype	rs.w 1	;Font flags

ed_v_filcolor	rs.w 1	;Fill color (background)
ed_v_filinter	rs.w 1	;Fill interior
ed_v_filstyle	rs.w 1	;Fill style
ed_v_vswrmode	rs.w 1	;Writing mode

ed_v_vdiflags	rs.w 1	;Flags (my own)

ed_dvdi_ssize	= __RS
	
;=== Flags definition for ed_v_fntflags
ed_v_lf_f	= 0	;0 = vst_load_fonts not necessary, 1 = vst_laod_fonts must be done
ed_v_pnts	= 1	;0 = ed_v_fntpnts contains the Font height in pixels, 1 = Font size in points
******************************* ed_winrdefs ****************
;This is a structure containing the routines to install for a text-editor window
	rsset 0
ed_r_apterm	rs.l 1	;Pointer to routine called when terminating
ed_r_aclose	rs.l 1	;Pointer to routine called on AC_CLOSE AES message
ed_r_redraw	rs.l 1	;Pointer to routine called on WM_REDRAW messages
ed_r_arrow	rs.l 1	;Pointer to routine called when windows arrows are clicked
ed_r_vslid	rs.l 1	;Pointer to routine called when WM_VSLID
ed_r_hslid	rs.l 1	;Pointer to routine called on WM_HSLID
ed_r_moved	rs.l 1	;Pointer to routine called when window is moved
ed_r_sized	rs.l 1	;Pointer to routine called when window resized
ed_r_fulled	rs.l 1	;Pointer to routine called when window fulled
ed_r_close	rs.l 1	;Pointer to routine called when window is closed
ed_r_iconfy	rs.l 1	;Pointer to routine called when window iconfied.
ed_r_barify	rs.l 1	;Pointer to routine called when window shadowed
ed_r_button	rs.l 1	;Poitner to routine called when mouse click detected within window
ed_r_keybd	rs.l 1	;Pointer to routine called on keyboard events
ed_r_ddhandler	rs.l 1	;Pointer to the Drag&Drop handler
ed_r_ddprocess	rs.l 1	;Pointer to the Drag&Drop processing routine.

**** Definition of the Dialog Control block
** The obj_addr element in a dailog-window's bss area points to such a structure.
		rsset 0
;Dcb_rootadr	rs.l 1 ;Address of the root object
;Dcb_rootind	rs.w 1 ;Index number of the root object
;Dcb_rsvd0	rs.w 1 ;Reserved must be cleared
;Dcb_rsvd1	rs.w 1 ;Reserved must be cleared
;Dcb_rsvd2	rs.w 1 ;Reserved must be cleared
;Dcb_structs	rs.l 1 ;Here starts a table of structure addresses..
;Dcb_ssize	= __RS
*	...

************************ Dialog Structures *******
*
*These are the different requests
Ddm_req_update	= 0

*These definitions are common to all Dialog module structures.
		rsset 0
Ddm_type	rs.w 1
Ddm_root	rs.l 1

** This is the structure that the "Dialog-Sliders" module uses.
D_dw_slids	= 1 ;Implements slider controls within dialog objects

		rsset 0
;Ddws_type
		rs.w 1 ;Type of Structure (dialog_sliders)
;Ddws_root
		rs.l 1 ;Index of the root object this structure is intended for.

Ddws_parnt	rs.w 1 ;Parent object
Ddws_child	rs.w 1 ;Child object
Ddws_aup	rs.w 1 ;Arrow up/left
Ddws_adown	rs.w 1 ;Arrow down/right
Ddws_orint	rs.w 1 ;orientation
Ddws_relpos	rs.w 1 ;The following four words are used by the slider routines to hold..
Ddws_relsiz	rs.w 1 ;..the current size so that the sliders are not redrawn if they have the same size.

Ddws_slidr	rs.l 1 ;Pointer to a slider routine - This gets the relative pos of slider in D2
Ddws_pager	rs.l 1 ;Pointer to a "page-up/left" routine This gets 0 in D2 of a page up or 1 if page down.
Ddws_arowr	rs.l 1 ;Pointer to the arrow up/down routine This get 0 in D2 for arrow up and 1 for arrow down
Ddws_ser	rs.l 1 ;Pointer to a routine called to set the top/bottom or start/end position. This gets a 0 in D2 = top, 1 = bottom
Ddws_upd	rs.l 1 ;Pointer to a routine that the module calls on "update the sliders" calls.
Ddws_exit	rs.l 1 ;Pointer to a routine that is called before exiting the slider actions (fixing cursors, for example)

;If Ddws_stype = 1	The The Text in the Editor bss pointed to by Ddws_bss is processed
*			IF there is NOT a  null pointer  in the Ddws_link, it is assumed to be pointers
*			to other Editor BSS'es to process.

** This is the structure that the "Dialog-TextFrames" module uses	   
;D_dw_textf	= 2 ;Implements text-frames within dialog objects

		rsset 0
		rs.w 1 ;type
		rs.l 1 ;Root object ind

Ddwt_obj	rs.w 1 ;Object index of the object
Ddwt_rsv0	rs.w 1 ;Reserved
Ddwt_bss	rs.l 1 ;address of the Editor BSS to use (See below for info on the Editor structure.)

	include	header\mine\edline.h
;=;;=;=;=;=

	include	header\mine\editor.h
	
	include	header\mine\memmanag.h
	
*************** Edit line module
;		rsset 0
;edlin_flags	rs.w 1	;Flags
;
;	;LSB, LSW
;edl_valid	= 0	;0 = The info in this structure is valid.
;			;1 = The info in this structure in not valid.
;
;edl_paste	= 1	;0 = The info in this structure is updated (i.e. it's been pasted into the text)
			;1 = The info in this structure is not updated into the text (Not pasted into text)

;edlin_bss	rs.l 1	;Address of the editor bss
;edlin_edbuff	rs.l 1	;Address of a buffer to use during edititing
;edlin_offset	rs.w 1	;Cursor position in memory (The next char goes here)
;edlin_linlen	rs.w 1	;Lenght of the line currently in edline_linebuff

*************** Keyboard navigation
;		rsset 0
;objed_rootadr	rs.l 1	;Root tree
;objed_obj	rs.w 1	;Index of the current object
;objed_index	rs.w 1	;Index of the cursor into the string
;objed_ssize	= __RS

	include header\mine\cursor.h
	