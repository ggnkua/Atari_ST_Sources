;Orientation bit settings
puo_center:	= 0
puo_top:	= 1
puo_bottom:	= 2
puo_left:	= 3
puo_right:	= 4
puo_hcenter:	= 5
puo_vcenter:	= 6
puo_currenty:	= 7
puo_currentx:	= 8

puo_topmenu:	= 9
puo_bottommenu:	= 10
puo_leftmenu:	= 11
puo_rightmenu:	= 12


puo_objcoord:	= 15

;Type bit settings
put_select:	= 0
put_border:	= 1
put_menu:	= 2
put_nmodal:	= 3

;Flags
puf_tree:	= 0	;If set, the elememnts pu_tree and pu_rootind is used to store the address of the
			;object tree to use

	rsset 0
pu_tree:	rs.w 1	;high word of tree address if puf_tree bit set in pu_flags
pu_rootind:	rs.w 1	;low word of tree address if puf_tree bit set in pu_flags, or Index of the popup tree, used to get its tree address
pu_index:	rs.w 1	;Index of the object to use for popup
pu_firstobj:	rs.w 1	;Index of the 1st object to pay attention to
pu_lastobj:	rs.w 1	;INdex of the last object to pay attention to
pu_type:	rs.w 1	;Type - 0 = Toggle selected, 1 = Border
pu_flags:	rs.w 1	;Flags
pu_orient:	rs.w 1	;Orientation. (see puo_xx )
pu_param:	rs.l 1	;Parameter to pass to the relevant obj_radio_xx routine
pu_x:		rs.w 1	;Screen X
pu_y:		rs.w 1	;Screen Y
	;If popup-type bit "put_menu" is set, these coordinates are used to check if the mouse
	;have moved off the current menu-title, in which case the popup is closed and a "no selection"
	;return is done
pu_mx:		rs.w 1
pu_my:		rs.w 1
pu_mw:		rs.w 1
pu_mh:		rs.w 1
pu_px:		rs.w 1
pu_py:		rs.w 1
pu_pw:		rs.w 1
pu_ph:		rs.w 1
pu_current:	rs.w 1	;Index of the object
pu_retreason:	rs.w 1	;
pu_returnobj:	rs.w 1	;Object index returned..
pu_returnadr:	rs.l 1	;Address of the popup tree returned
pu_mousemode:	rs.l 1	;This will contain the 1st two words of MU_BUTTON mode used by the popup routine.
pu_ssize:	= __RS

;DropDown structure.
; A Dropdown-object is constructed as follows. A parent box whose index is found in
; "drpd_index". The rood index of the tree containing this Dropdown-object is found
; in drpd_root.
; The Dropdown-object consist of the parent object (drpd_index) which is a G_BOX type
; and this box contains two child objects. Its first child is the "text" selector, and
; it is when clicking this object the dropdown routine brings up an attached popup. This
; "text" selector is the object showing the current selection. It's index is always 
; "drpd_index"+1. The second child is the "selector" object, and it always has the index
; "drpd_index"+2.

		rsset 0
drpd_root:	rs.w 1	;Index of the tree containing the dropdown object
drpd_index:	rs.w 1	;Index of the dropdown (parent)
drpd_popup:	rs.l 1	;Address of a popup structure
drpd_current:	rs.w 1	;Index of the object in popup currenly selected (Used to cycle the throught the objects in the popup)
drpd_x:		rs.w 1	;Mouse X coord
drpd_y:		rs.w 1	;Mouse Y coord
drpd_returnobj:	rs.w 1	;Index of the object selected from the popup
drpd_returnadr:	rs.l 1	;Address of the tree containing the popup

drpd_ssize:	= __RS


;=== menu
		rsset 0
menu_root:	rs.l 1	;Root index of the tree containing menu
menu_rootind:	rs.w 1	;Root index of the tree containing menu
menu_parnt:	rs.w 1	;Parent object (root, so to speak) of the menu line
menu_startpop:	rs.w 1	;Index of the popup belonging to the first menu-entry
menu_popmem:	rs.l 1	;Address of a popup structure to use

menu_firstobj:	rs.w 1	;Index of the 1st menu entry
menu_lastobj:	rs.w 1	;Index of the last menu entry
menu_ssize:	= __RS


***************************************
;This structure is set up by the "init_dialfolder"
		rsset 0
;dfldr_next:	rs.l 1
;dfldr_prev:	rs.l 1
;dfldr_tree:	rs.l 1	;Address of tree containing these folders
;dfldr_folders:	rs.w 1	;Number of folders..

;dfldr_headsize:	= __RS

		rsset 0
dfldr_tree:		rs.l 1
dfldr_parent:		rs.w 1	;Folder index
dfldr_titles:		rs.w 1	;Number of folder titles - this is how many entries there are in the list
			;starting at dfldr_entries
dfldr_entries:		rs.w 0	;here follows a list of indexes (words), each representing a folder entry. 1st word = index of 1st folder entry
dfldr_ssize:	= __RS

