* Routine de gestion de boutons Popup
* Par Fran‡ois GALEA

	RSRESET
arbre		rs.l	1
;nb_entr		rs.w	1
actuel		rs.w	1
;char_h		rs.w	1
sx		rs.w	1
sy		rs.w	1
sw		rs.w	1
sh		rs.w	1
POPUBLK		rs.w	1

	RSRESET
mn_tree		rs.l	1	;   - the object tree of the menu  
mn_menu		rs.w	1	;   - the parent object of the menu items 
mn_item		rs.w	1	;   - the starting menu item 
mn_scroll	rs.w	1	; - the scroll field status of the menu 
				; 0  - The menu will not scroll 
				;!0 - The menu will scroll if the number of menu 
				;items exceed the menu scroll height. The  
				;non-zero value is the object at which  
				;scrolling will begin.  This will allow one 
				;to have a menu in which the scrollable region 
				;is only a part of the whole menu.  The value 
				;must be a menu item in the menu. 

				;menu_settings can be used to change the menu 
				;scroll height.  
 
			;NOTE: If the scroll field status is !0, the menu 
				;items must consist entirely of G_STRINGS. 
mn_keystate	rs.w	1	; - The CTRL, ALT, SHIFT Key state at the time the
				;mouse button was pressed. 
MENU		rs.w	1	; Taille de la structure

