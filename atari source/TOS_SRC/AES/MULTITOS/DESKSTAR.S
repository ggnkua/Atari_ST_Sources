*	DESKSTART.S		5/1/91		D.Mui		*


*	Set the DESK_PROGRAM (DESKPRG) flag to compile this file for a
*	replacement Desktop. Clear it for making GEM.SYS
*       DESK_PROGRAM (DESKPRG) must also be set/cleared in
*	      SOFTLOAD.H
*	See the Defines in the makegem/makedesk files.



	.globl	_crystal
	.globl	_ctrl_cnts
	.globl	_desk_vdi
.iff DESKPRG
	.globl	_desktop
.endif
	.globl	_iconaddr


*	For GEMAES calls from AESBIND.ARC or cryslib.o
*


.iff DESKPRG
_desktop:
	move.l	#bottom,a7
	clr.l	_iconaddr
	jsr	_deskmain
	rts	
.endif




_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts


_desk_vdi:
	move.l	4(a7),d1
	move.w	#115,d0
	trap	#2
	rts


	.bss

top:	.ds.l	600
bottom:	.ds.l	1

	.data

    	.even
_ctrl_cnts:			 	* Application Manager
	.dc.b	0, 1, 0			* func 010	Appl_init	
    	.dc.b	2, 1, 1			* func 011	Appl_read	
    	.dc.b	2, 1, 1 		* func 012	Appl_write	
	.dc.b	0, 1, 1			* func 013	Appl_find	
	.dc.b	2, 1, 1			* func 014	Appl_tplay	
	.dc.b	1, 1, 1			* func 015	Appl_trecord	
	.dc.b	0, 0, 0			* func 016		
	.dc.b	1, 1, 0			* func 017	Appl_term		
	.dc.b	1, 3, 1			* func 018	Appl_search	
	.dc.b	0, 1, 0			* func 019		

*	 						Event Manager
	.dc.b	0, 1, 0			* func 020	evnt_keybd	
	.dc.b	3, 5, 0			* func 021	evnt_button	
	.dc.b	5, 5, 0			* func 022	evnt_mouse	
	.dc.b	0, 1, 1			* func 023	evnt_messag	
	.dc.b	2, 1, 0			* func 024	evnt_timer	
	.dc.b	16, 7, 1 		* func 025	evnt_multi	
	.dc.b	2, 1, 0			* func 026	evnt_dclick	
	.dc.b	0, 0, 0			* func 027		
	.dc.b	0, 0, 0			* func 028		
	.dc.b	0, 0, 0			* func 009		
*							 Menu Manager
	.dc.b	1, 1, 1			* func 030	menu_bar	
	.dc.b	2, 1, 1			* func 031	menu_icheck	
	.dc.b	2, 1, 1			* func 032	menu_ienable	
	.dc.b	2, 1, 1			* func 033	menu_tnormal	
	.dc.b	1, 1, 2			* func 034	menu_text	
	.dc.b	1, 1, 1			* func 035	menu_register	
	.dc.b	2, 1, 2			* func 036	menu_popup	
	.dc.b	2, 1, 2			* func 037	menu_attach	
	.dc.b	3, 1, 1			* func 038	menu_istart	
	.dc.b	1, 1, 1			* func 039	menu_setting	
*							 Object Manager
	.dc.b	2, 1, 1			* func 040	objc_add		
	.dc.b	1, 1, 1			* func 041	objc_delete	
  	.dc.b	6, 1, 1			* func 042	objc_draw	
	.dc.b	4, 1, 1			* func 043	objc_find	
	.dc.b	1, 3, 1			* func 044	objc_offset	
	.dc.b	2, 1, 1			* func 045	objc_order	
	.dc.b	4, 2, 1			* func 046	objc_edit	
	.dc.b	8, 1, 1			* func 047	objc_change	
	.dc.b	0, 0, 0			* func 048		
	.dc.b	0, 0, 0			* func 049		
*							 Form Manager
	.dc.b	1, 1, 1			* func 050	form_do	
	.dc.b	9, 1, 0			* func 051	form_dial	
	.dc.b	1, 1, 1			* func 052	form_alert	
	.dc.b	1, 1, 0			* func 053	form_error		
	.dc.b	0, 5, 1			* func 054	form_center	
	.dc.b	3, 3, 1			* func 055	form_keybd		
	.dc.b	2, 2, 1			* func 056	form_button	
	.dc.b	0, 0, 0			* func 057		
	.dc.b	0, 0, 0			* func 058		
	.dc.b	0, 0, 0			* func 059		
*							 Dialog Manager
	.dc.b	0, 0, 0			* func 060		
	.dc.b	0, 0, 0			* func 061		
	.dc.b	0, 0, 0			* func 062		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							Graphics Manager
	.dc.b	4, 3, 0			* func 070	graf_rubberbox	
	.dc.b	8, 3, 0			* func 071	graf_dragbox	
	.dc.b	6, 1, 0			* func 072	graf_movebox	
	.dc.b	8, 1, 0			* func 073	graf_growbox	
	.dc.b	8, 1, 0			* func 074	graf_shrinkbox	
	.dc.b	4, 1, 1			* func 075	graf_watchbox	
	.dc.b	3, 1, 1			* func 076	graf_slidebox	
	.dc.b	0, 5, 0			* func 077	graf_handle	
	.dc.b	1, 1, 1			* func 078	graf_mouse	
	.dc.b	0, 5, 0			* func 009	graf_mkstate	
*							Scrap Manager
	.dc.b	0, 1, 1			* func 080	scrp_read	
	.dc.b	0, 1, 1			* func 081	scrp_write	
	.dc.b	0, 0, 0			* func 082		
	.dc.b	0, 0, 0			* func 083		
	.dc.b	0, 0, 0			* func 084		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							fseler Manager
	.dc.b	0, 2, 2			* func 090	fsel_input	
	.dc.b	0, 2, 3			* func 091	fsel_exinput	
	.dc.b	0, 0, 0			* func 092		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0 		* func 009		
*							Window Manager
	.dc.b	5, 1, 0			* func 100	wind_create	
	.dc.b	5, 1, 0			* func 101	wind_open	
	.dc.b	1, 1, 0			* func 102	wind_close	
	.dc.b	1, 1, 0			* func 103	wind_delete	
	.dc.b	5, 5, 0			* func 104	wind_get	
	.dc.b	6, 1, 0			* func 105	wind_set	
	.dc.b	2, 1, 0			* func 106	wind_find	
	.dc.b	1, 1, 0			* func 107	wind_update	
	.dc.b	6, 5, 0			* func 108	wind_calc	
	.dc.b	0, 0, 0 		* func 109	wind_new	
*							Resource Manger
	.dc.b	0, 1, 1			* func 110	rsrc_load	
	.dc.b	0, 1, 0			* func 111	rsrc_free	
	.dc.b	2, 1, 0			* func 112	rsrc_gaddr	
	.dc.b	2, 1, 1			* func 113	rsrc_saddr	
	.dc.b	1, 1, 1			* func 114	rsrc_obfix
	.dc.b	0, 1, 1			* func 115	rsrc_rcfix		
	.dc.b	0, 0, 0			* func 116	
	.dc.b	0, 0, 0			* func 117
	.dc.b	0, 0, 0			* func 118
	.dc.b	0, 0, 0			* func 119
*							Shell Manager
	.dc.b	0, 1, 2			* func 120	shel_read
	.dc.b	3, 1, 2			* func 121	shel_write
	.dc.b	1, 1, 1			* func 122	shel_get
	.dc.b	1, 1, 1			* func 123	shel_put
	.dc.b	0, 1, 1			* func 124	shel_find
	.dc.b	0, 1, 2			* func 125	shel_envrn
	.dc.b	1, 1, 1			* func 126	
	.dc.b	0, 1, 1			* func 127
	.dc.b	1, 1, 1			* func 128
	.dc.b	0, 1, 1			* func 129

	.dc.b	0, 0, 0			* func 130		
	.dc.b	0, 1, 0			* func 131		
	.dc.b	2, 1, 0			* func 132
	.dc.b	2, 1, 0			* func 133
	.dc.b	2, 1, 1			* func 134		
	.dc.b	1, 1, 1			* func 135		
	.dc.b	0, 0, 0			* func 136		
	.dc.b	0, 0, 0			* func 137
	.dc.b	0, 0, 0			* func 138
	.dc.b	0, 0, 0			* func 139


	.dc.b	0, 1, 0			* func 140		
	.dc.b	0, 1, 0			* func 141		
	.dc.b	5, 5, 0			* func 142		
	.dc.b	0, 1, 1			* func 143		
	.dc.b	1, 1, 0			* func 144		
	.dc.b	1, 1, 0			* func 145		
	.dc.b	12, 8, 1		* func 146
	.dc.b	0, 0, 0			* func 147
	.dc.b	0, 0, 0			* func 148
	.dc.b	0, 0, 0			* func 149

	.end
