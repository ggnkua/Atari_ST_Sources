
	rsset 0
tfi_handle	rs.w	1	;Handle of the group
tfi_framenum	rs.w	1	;The number of the frame
tfi_type	rs.w	1
tfi_flags	rs.w	1
tfi_otree	rs.l	1	;Object tree containing the object to which this frame is linked
tfi_oindex	rs.w	1	;Index of the object
tfi_x		rs.w	1	;X
tfi_y		rs.w	1
tfi_width	rs.w	1
tfi_height	rs.w	1
tfi_winbss	rs.l	1
tfi_init	rs.l	1	;Pointer some initial data, depending on the type
tfi_ssize	= __RS

;Specific for editor frames
	rsset tfi_ssize
tfi_hslide	rs.l	1
tfi_vslide	rs.l	1
tfi_edl_ssize	= __RS

;Specific for edline frames
	rsset tfi_ssize
tfi_linelen	rs.l	1
tfi_vdih_inv	rs.w	1
tfi_vdih_norm	rs.w	1
tfi_ed_ssize	= __RS

;------------------------------------------------------------------------------------------
tf_e_invnof	= -1	;Invalid number of frames (Can't have 0 frames in a FrameGroup, i.e)
tf_e_notused	= -2	;A General error. Like when passing a key to textframe_navigate, and the key wasn't one to use for navigation
tf_e_invh	= -3	;Invalid frame handle (does not exist)
tf_e_invfn	= -4	;Invalid frame number (Not that many frames in this group)
tf_e_fnused	= -5	;This frame is already installed.
tf_e_fnunused	= -6	;This frame slot is empty
tf_e_nomem	= -7	;Could not allocate memory
tf_e_nofdata	= -8	;There's no pointer to a text/editor bss..
tf_e_notfound	= -9	;Frame not found
tf_e_cinstld	= -10	;A cursor is already installed in this FrameGroup.
tf_e_coutofb	= -11	;The cursor could not be installed, cause the coords are not within the specified frame
tf_e_cnotinf	= -12	;The cursor is not in this frame atm.
tf_e_nocurs	= -13	;No cursor installed for this FrameGroup
tf_e_unedit	= -14	;Frame can't be edited
tf_e_notimp	= -20	;This function is not implemented.
tf_e_fgnotfnd	= -21	;FrameGroup not found (at coordinates)

tf_t_editor	= 1
tf_t_line	= 2

tf_c_install	= 0
tf_c_move	= 1

;=== Edit Flags ===
tf_edf_cprep	= 0	;Coords at which to edit are prepared with a call to textframe_find()
tf_edf_noeold	= 1	;Don't delete EOL's (Backspace/delete stops at end of line)
tf_edf_unix	= 2	;Use only LF's for EOL's
tf_edf_noeols	= 3	;Don't use CR (don't put in EOL in text)

;=== Upate Flags === 
tf_updf_redraw	= 0	;Set to redraw changes.

;=== Key flags ===
tf_key_tabnxt	= 0	;A TAB causes the cursor to move to the next frame
tf_key_ctrly	= 1	;CTRL+Y deletes line.
tf_key_escclr	= 2	;ESC clears all text.. only valid with edline types (tf_t_line)
tf_key_audnxt	= 3	;Arrow up/down causes the cursor to move to the next frame. Only with edline types (tf_t_line)

;Flags returned by edit.
tf_edr_supd	= 0	;Sliders needs to be updated (if used)
tf_edr_deol	= 1	;A EOL was DELedted (Deleted)
tf_edr_beol	= 2	;A EOL was BACKSPACEd (Deleted)
tf_edr_ceol	= 3	;This is set upon exit if tf_edf_noeols is set and char passed was a CR

tf_opn_line	= 0	;0 = Open line by butting a EOL at start of line
		;1 = Open line by putting a EOL at end of line

m_req_redraw	= 1

;Flags for the frame.
tf_frm_editable	= 0	;Setting this makes the frame editable

;Flags for the group itself, ie, flags global to all frames within a group
		;low word, lsb - textf_flags+3
tf_grp_mac	= 0	;Setting this will make the editables behave like on a mac (only effective on types tf_t_line)

tf_max_fprg	= 100	;Max Frames per FrameGroup.

	rsset 0
textf_winbss	rs.l 1	;BSS address of the window containing this group of frames
textf_flags	rs.l 1	;Flags
textf_num	rs.w 1	;Number of frames in this group
textf_handle	rs.w 1	;Frame group handle
textf_winh	rs.w 1	;Window handle in which these frames belong
textf_cursh	rs.w 1	;Cursor handle
textf_cursnum	rs.w 1	;Number of frame in which the cursor is atm
textf_cursor	rs.l 1	;Address of frame in which the cursor is atm
textf_ssize	= __RS	;Size of this structure

	rsset 0
tframe_type	rs.w 1
tframe_flags	rs.w 1
tframe_edbss	rs.l 1
tframe_vs	rs.l 1
tframe_hs	rs.l 1
tframe_x	rs.w 1	;Relative to the window
tframe_y	rs.w 1	;..
tframe_w	rs.w 1
tframe_h	rs.w 1

tframe_ssize	= __RS
	
