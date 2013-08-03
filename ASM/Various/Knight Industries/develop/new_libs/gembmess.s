	SECTION	text

generalMessageHandler

	lea	messageBuffer,a0

	cmpi.w	#mn_selected,(a0)
	beq	generalMenuHandler
	
	cmpi.w	#ap_term,(a0)
	beq	quitRoutine

	cmpi.w	#wm_moved,(a0)
	beq	moveWindowHandler

	cmpi.w	#wm_closed,(a0)
	beq	closeWindowHandler

	cmpi.w	#wm_topped,(a0)
	beq	topWindowHandler

	cmpi.w	#wm_newtop,(a0)
	beq	topWindowHandler
		
	cmpi.w	#wm_ontop,(a0)
	beq	topWindowHandler

	cmpi.w	#wm_iconify,(a0)
	beq	iconiseHandler

	cmpi.w	#wm_uniconify,(a0)
	beq	uniconiseHandler

	cmpi.w	#wm_redraw,(a0)
	beq	redrawWindowHandler

	cmpi.w	#va_start,(a0)
	beq	programVaStart

	rts

	include	d:\develop\new_libs\windows.s
	include	d:\develop\new_libs\form_do.s
	include	d:\develop\new_libs\keyboard.s

generalMenuHandler

	move.w	8(a0),d0

	rsrc_gaddr	#0,#MENUBAR
	menu_tnormal	6(a0),#true,addrout

	cmpi.w	#ABOUT,d0
	beq	showProgramInfo

	cmpi.w	#QUIT,d0
	beq	quitRoutine

	cmpi.w	#ICONIFYWIND,d0
	beq	iconifyTop

	bra	programMenuHandler