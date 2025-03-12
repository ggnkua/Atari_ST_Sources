* Window flag definitions..

	;low word, LSB (bits 0-7)
w_icon_f	= 0		;Bit 0	0 = Window not iconfied | 1 = Window iconfied
w_bari_f	= 1		;Bit 1	0 = Window not "barified" | 1 = Window is "barified"
w_dial_f	= 2		;Bit 2	0 = Ordinary window | 1 = Dialog Window
w_tool_f	= 3		;Bit 3	0 = Toolbar not attached | 1 = Toolbar attached
w_text_f	= 4		;Bit 4	0 = Not text window | 1 = Text window (point_bss = editor BSS)
w_full_f	= 5		;Bit 5	0 = Window at ordinary coords - 1 = window at fulled coordinates
w_open_f	= 7		;Bit 7	0 = Window not open | 1 = Window is open.

	;low word, MSB (bits 8-15)
	;These bits contain the user settings.
w_botm_f	= 0		;Bit 0	0 = Don't bottom window if no clickable objects are clicked within it. | 1 = Bottom it.
w_topp_f	= 1		;Bit 1	0 = Don't top window if no clickable objects are clicked within it. | 1 = Top it.
w_drag_f	= 2		;Bit 2	0 = Don't drag window if clicked outside clicable objects | 1 = Drag window if clicked outside clickable objects 
w_ntop_f	= 3		;Bit 3	0 = Just top on wm_topped | 1 = Check if there were any objects clicked, if not top window
w_prot_f	= 4		;Bit 4  0 = Not protected. window will be reused in situations where opening new files in the same window | 1 = Protected.

	;high word, LSB (bits 16-23) This byte is "static". 
w_uicn_f	= 0		;Bit 0	0 = Don't use icon for iconfy, 1 = use icon for iconfy

	;high word, MSB (bits 24-31)
	;These bits are used as parameters for the window-open routines
w_open_p	= 7		;Bit 7	0 = Open the window | 1 = Just create and prep the coords, don't open.

;Window size flags... indicating which coordinate got larger/smaller

w_xless_f	= 0	;If X coordinate of window is set to less than it was before, this is set
w_yless_f	= 1	;If Y coordinate of window is set to less than it was before, this is set
w_wless_f	= 2	;If Width of window is 
w_hless_f	= 3

