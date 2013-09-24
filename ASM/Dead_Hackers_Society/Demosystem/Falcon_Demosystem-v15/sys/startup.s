; Falcon demoshell
; February 5, 2000
;
; Anders Eriksson
; ae@dhs.nu
;
; Startup menu
; GEM / Text versions
;
; startup.s

gem_object_size:	equ	24

gem_vga60:		equ	5*gem_object_size+10
gem_vga100:		equ	6*gem_object_size+10
gem_rgb50:		equ	7*gem_object_size+10
gem_lowdetail:		equ	17*gem_object_size+10
gem_vga60_default:	equ	5
gem_vga100_default:	equ	6
gem_rgb50_default:	equ	7
gem_rgb60_default:	equ	8
gem_highdetail_default:	equ	16
gem_lowdetail_default:	equ	17

; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------

startup:	move.l	#.app,d0				;*.app
		bsr.s	.search					;
		tst.l	d0					;
		beq.w	gem_startup				;

		move.l	#.prg,d0				;*.prg
		bsr.s	.search					;
		tst.l	d0					;
		beq.w	gem_startup				;

		move.l	#.gtp,d0				;*.gtp
		bsr.s	.search					;
		tst.l	d0					;
		beq.w	gem_startup				;

		bra.w	tos_startup
		rts

.search:	move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	d0,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		rts

.app:		dc.b	'*.app',0				;app
		even						
.prg:		dc.b	'*.prg',0				;prg
		even
.gtp:		dc.b	'*.gtp',0				;gtp
		even





; ------------- GEM MENU ---------------------------------------

gem_startup:	bsr.w	appl_init				;init aes 
		bsr.w	graf_handle				;

		clr.w	int_in					;graf_mouse()
		bsr.w	graf_mouse				;set arrow pointer

		move.l	#rsc_filename,addr_in			;rsrc_load() 
		bsr.w	rsrc_load				;load resource
		move.l	#alert_rsrcload,addr_in			;
		tst.w	int_out					;
		beq.w	.gem_error				;rsc not found/loaded

		clr.w	int_in+2				;rsrc_gaddr()
		bsr.w	rsrc_gaddr				;get address to resource
		move.l	#alert_rsrcgaddr,addr_in		;
		tst.w	int_out					;
		beq.w	.gem_error				;failed

		move.l	rsrc_address,addr_in			;form_center()
		bsr.w	form_center				;center rsc form
		move.l	#alert_formcenter,addr_in		;and get coords
		tst.w	int_out					;
		beq.w	.gem_error				;failed

		move.w	#0,int_in				;form_dial()
		bsr.w	form_dial				;reserve screenspace for rsc form
		move.l	#alert_formdial,addr_in			;
		tst.w	int_out					;
		beq.w	.gem_error				;failed

		tst.w	monitor					;monitor?
		beq.s	.vga					;
.rgb:		cmp.w	#60,rgb_freq				;rgb 60?
		beq.s	.r60
.r50:		move.w	#gem_rgb50_default,int_in		;set rgb50 default 
		move.w	#1,int_in+12				;object new status
		clr.w	int_in+14				;0=no redraw 1=redraw
		move.l	rsrc_address,addr_in			;address to object tree
		bsr.w	objc_change				;objc_change()
		bra.s	.detail
.r60:		move.w	#gem_rgb60_default,int_in		;set rgb60 default 
		move.w	#1,int_in+12				;object new status
		clr.w	int_in+14				;0=no redraw 1=redraw
		move.l	rsrc_address,addr_in			;address to object tree
		bsr.w	objc_change				;objc_change()
		bra.s	.detail
.vga:		cmp.w	#100,vga_freq				;vga 100?
		beq.s	.v100
.v60:		move.w	#gem_vga60_default,int_in		;set vga60 default 
		move.w	#1,int_in+12				;object new status
		clr.w	int_in+14				;0=no redraw 1=redraw
		move.l	rsrc_address,addr_in			;address to object tree
		bsr.w	objc_change				;objc_change()
		bra.s	.detail
.v100:		move.w	#gem_vga100_default,int_in		;set vga100 default 
		move.w	#1,int_in+12				;object new status
		clr.w	int_in+14				;0=no redraw 1=redraw
		move.l	rsrc_address,addr_in			;address to object tree
		bsr.w	objc_change				;objc_change()

.detail:	tst.w	detail					;detail?
		beq.s	.low					
.high:		move.w	#gem_highdetail_default,int_in		;set high detail default 
		move.w	#1,int_in+12				;object new status
		clr.w	int_in+14				;0=no redraw 1=redraw
		move.l	rsrc_address,addr_in			;address to object tree
		bsr.w	objc_change				;objc_change()
		bra.s	.flagsdone
.low:		move.w	#gem_lowdetail_default,int_in		;set low detail default 
		move.w	#1,int_in+12				;object new status
		clr.w	int_in+14				;0=no redraw 1=redraw
		move.l	rsrc_address,addr_in			;address to object tree
		bsr.w	objc_change				;objc_change()


.flagsdone:	move.l	rsrc_address,addr_in			;objc_draw()
		move.w	#0,int_in				;draw the form to screen
		bsr.w	objc_draw				;
		move.l	#alert_objcdraw,addr_in			;
		tst.w	int_out					;
		beq.w	.gem_error				;failed

		move.l	rsrc_address,addr_in			;form_do()
		bsr.w	form_do					;take care of users form inputs
		move.l	#alert_formdo,addr_in			;
		tst.w	int_out					;
		beq.w	.gem_error				;failed


;-------------- Read what the user has selected ----------------

		cmp.w	#21,int_out				;21=start button
		bne.w	.exit_demo				;if not start, exit


		move.l	rsrc_address,a6				;address to rsctree

.vga60:		move.w	gem_vga60(a6),d0			;vga 60 check
		btst	#0,d0					;
		beq.s	.vga100					;try 100
		clr.w	monitor					;set vga
		move.w	#60,vga_freq				;set 60 Hz
		bra.s	.detailmode				;check detail

.vga100:	move.w	gem_vga100(a6),d0			;vga 100 check
		btst	#0,d0					;
		beq.s	.rgb50					;try rgb
		clr.w	 monitor				;set vga
		move.w	#100,vga_freq				;set 100 Hz
		bra.s	.detailmode				;check detail

.rgb50:		move.w	gem_rgb50(a6),d0			;rgb 50 check
		btst	#0,d0					;
		beq.s	.rgb60					;try 60
		move.w	#1,monitor				;set rgb
		move.w	#50,rgb_freq				;set 50 Hz
		bra.s	.detailmode				;check detail

.rgb60:		move.w	#1,monitor				;set rgb
		move.w	#60,rgb_freq				;set 60 Hz


.detailmode:	move.w	gem_lowdetail(a6),d0			;check detail
		btst	#0,d0					;
		bne.s	.mklow					;set low
		move.w	#1,detail				;set high
		bra.s	.close					;
.mklow:		clr.w	detail					;


;-------------- exit the gem menu ------------------------------
		
.close:		move.w	#3,int_in				;form_dial()
		bsr.w	form_dial				;close rsc
		move.l	#alert_formdial,addr_in			;
		tst.w	int_out					;
		beq.s	.gem_error				;failed

.gem_quit:	bsr.w	rsrc_free				;free used rsc ram
		bsr.w	appl_exit				;exit aes
		rts

.gem_error:	move.w	#1,int_in				;show error alert and quit program
		bsr.w	form_alert				;form_alert()
		bsr.s	.gem_quit				;
		bra.w	exit					;exit demo

.exit_demo:	bsr.s	.close					;exit demo button
		bra.w	exit					;
		

; ==============================================================
;		gem subroutines
; ==============================================================

aes:		move.l	#aes_pb,d1				;call aes
		move.w	#200,d0					;
		trap	#2					;
		rts

; --------------------------------------------------------------
; 		appl_init() | #10 | #$0a
; --------------------------------------------------------------
appl_init:	lea.l	control,a0				;aes control structure
		move.w	#$a,(a0)+				;+0 appl_init()
		clr.w	(a0)+					;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out parameter
		clr.w	(a0)+					;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out paramters
		bsr.w	aes					;call aes
		move.w	int_out,appl_init_ap_id			;application id
		rts

; --------------------------------------------------------------
;		appl_exit() | #19 | #$13
; --------------------------------------------------------------
appl_exit:	lea.l	control,a0				;aes control structure
		move.w	#$13,(a0)+				;+0 appl_exit()
		clr.w	(a0)+					;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out parameters
		clr.w	(a0)+					;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes					;call aes
		rts

; --------------------------------------------------------------
; 		obct_draw() | #42 | #$2a
; --------------------------------------------------------------

; INPUT:
;	long	addr_in		+0 address to objecttree
;	word	int_in		+0 number of the object to draw
;
; OUTPUT
;	word	int_out		+0 if 0 = error
;
; EXAMPLE IN:	move.l	rsrc_address,addr_in
;		move.w	#0,int_in
;		bsr.w	objc_draw


objc_draw:	move.l	rsrc_address,addr_in			;object tree address
		lea.l	int_in+2,a0				;in_in+2
		move.w	#7,(a0)+				;all layers
		movem.l	form_xpos,d0-d1				;xpos, ypos, xwidth, yheight
		movem.l	d0-d1,(a0)				;
		lea.l	control,a0				;aes control structure
		move.w	#$2a,(a0)+				;+0 objc_draw()
		move.w	#6,(a0)+				;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out parameters
		move.w	#1,(a0)+				;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes					;call aes
		rts

; --------------------------------------------------------------
; 		objc_change() | #47 | #$2f
; --------------------------------------------------------------

; INPUT:
;	word	int_in		+0 objectid number
;	word	int_in		+2 reserved should be zero
;	word	int_in		+4 xpos
;	word	int_in		+6 ypos
;	word	int_in		+8 xsize
;	word	int_in		+10 ysize
;	word	int_in		+12 new object status
;	word	int_in		+14 0=no redraw 1=redraw
;	long	addr_in		+0 address to objecttree
;
; OUTPUT:
;	word	int_out		+0 0=error otherwise ok
;
; EXAMPLE IN:	move.w	#1,int_in				;object number
;		move.w	#1,int_in+12				;object new status
;		move.w	#1,int_in+14				;0=no redraw 1=redraw
;		move.l	rsrc_address,addr_in			;address to object tree
;		bsr.w	objc_change				;objc_change()


objc_change:	lea.l	control,a0				;aes control structure
		move.w	#$2f,(a0)+				;+0 objc_change()
		move.w	#8,(a0)+				;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out parameters
		move.w	#1,(a0)+				;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		clr.w	int_in+2				;reserved should be zero
		move.l	form_xpos,int_in+4			;coords
		move.l	form_xwidth,int_in+8			;
		bsr.w	aes
		rts

; --------------------------------------------------------------
; 		form_do() | #50 | #$32
; --------------------------------------------------------------

; INPUT:
;	long	addr_in		+0 address to objecttree
;
; OUTPUT:
;	word	int_out		+0 idnumber of ending object
;
; EXAMPLE IN:	move.l	#addrtoobjecttree,addr_in
;		bsr.w	form_do

form_do:	lea.l	control,a0				;aes control structure
		move.w	#$32,(a0)+				;+0 form_do()
		move.w	#1,(a0)+				;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out parameters	;ozk says #2 here
		move.w	#1,(a0)+				;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		clr.w	int_in					;0=no editable objects
		bsr.w	aes					;call aes
		rts
		
; --------------------------------------------------------------
;		form_dial() | #51 | #$33
; --------------------------------------------------------------

; INPUT:
;	word	int_in		+0 0=reservescreen 1=nouse 2=nouse 3=give back screenmem and redraw
;
; OUTPUT:
;	word	int_out		+0 0=error anyother=success
;
; EXAMPLE IN:	move.w	#0,int_in
;		bsr.w	form_dial

form_dial:	movem.l	form_xpos,d0-d1				;get values from form_center()
		movem.l	d0-d1,int_in+2				;max size
		movem.l	d0-d1,int_in+10				;min size
		lea.l	control,a0				;aes control structure
		move.w	#$33,(a0)+				;+0 form_dial()
		move.w	#9,(a0)+				;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out parameters
		clr.w	(a0)+					;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes					;call aes
		rts

; --------------------------------------------------------------
; 		form_alert() | #52 | #$34
; --------------------------------------------------------------

; INPUT:
; 	long	addr_in		+0 address to alertstruct
;
;	word	int_in		+0 prefered button to enter
;		  		0=none 1=leftmost 2=middle 3=rightmost
;
; OUTPUT:
;	word	int_out		+0 choosed button
;				1=left button 2=middlebutton 3=rightbutton
;
;
; EXAMPLE IN:	move.l	#myalertstruct,addr_in
;		move.w	#1,int_in
;		bsr.w	form_alert
;
;
; Alertstruct format:
;
; dc.b '[2][Messagetext][leftbutton | middlebutton | rightbutton]',0
;        

form_alert:	lea.l	control,a0				;aes control structure
		move.w	#$34,(a0)+				;+0 form_alert()
		move.w	#1,(a0)+				;+2 
		move.w	#1,(a0)+				;+4
		move.w	#1,(a0)+				;+6
		clr.w	(a0)					;+8
		;clr.w	int_in					;prefered button for enter (0=none 1=leftmost 2=middle 3=rightmost)
		;move.l	#junk,addr_in				;address to alert structure
		bsr.w	aes					;call aes
		rts

; --------------------------------------------------------------
; 		form_center() | #54 | #$36
; --------------------------------------------------------------

; INPUT:
;	long	addr_in		+0 address to objecttree
;
; OUTPUT:
;	word	int_out		+0 idnumber of ending object
;
; EXAMPLE IN:	move.l	#addrtoobjecttree,addr_in
;		bsr.w	form_center

form_center:	lea.l	control,a0				;aes control structure
		move.w	#$36,(a0)+				;+0 form_center()
		clr.w	(a0)+					;+2 int_in parameters
		move.w	#5,(a0)+				;+4 int_out parameters
		move.w	#1,(a0)+				;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes					;call aes
		movem.l	int_out+2,d0-d1				;store position and size
		movem.l	d0-d1,form_xpos				;
		rts

; --------------------------------------------------------------
; 		graf_handle() | #77 | #$4d
; --------------------------------------------------------------
		
graf_handle:	lea.l	control,a0				;aes control structure
		move.w	#$4d,(a0)+				;+0 graf_handle()
		clr.w	(a0)+					;+2 int_in parameters
		move.w	#5,(a0)+				;+4 int_out parameters
		clr.w	(a0)+					;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes					;call aes
		lea.l	int_out,a0				;aes output
		move.w	(a0)+,gr_h_screen			;+0 save screens id_number
		move.w	(a0)+,gr_h_fontwidth			;+2 fontwidth
		move.w	(a0)+,gr_h_fontheight			;+4 fontheight
		move.w	(a0)+,gr_h_boxwidth			;+6 boxwidth to hold a char
		move.w	(a0),gr_h_boxheight			;+8 boxheight to hold a char
		rts

; --------------------------------------------------------------
; 		graf_mouse() | #78 | #$4e
; --------------------------------------------------------------

; INPUT:
;	word	int_in		+0 0=arrow 1=textcursor 2=busybee 3=pointinghand 
;				4=openhand 5=thinplus 6=thickplus 7=outlineplus
; OUTPUT:
;	word	int_out		+0 0=error
;
; EXAMPLE IN:	move.w	#1,int_in
;		bsr.w	graf_mouse

graf_mouse:	lea.l	control,a0				;aes control structure
		move.w	#$4e,(a0)+				;+0 graf_mouse()
		moveq.l	#1,d0					;common value
		move.w	d0,(a0)+				;+2 int_in parameters
		move.w	d0,(a0)+				;+4 int_out parameters
		move.w	d0,(a0)+				;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes					;call aes
		rts

; --------------------------------------------------------------
;		rsrc_load() | #110 | #$6e
; --------------------------------------------------------------

; INPUT:
;	long	addr_in		+0 address to rscfilename
;
; OUTPUT:
;	word	int_out		+0 0=error other_value=ok
;
; EXAMPLE IN:	move.l	#filenameaddress,addr_in
;		bsr.w	aes
;
; FILENAME:
;		dc.b	'myrsc.rsc',0


rsrc_load:	lea.l	control,a0				;aes control structure
		move.w	#$6e,(a0)+				;+0 rsrc_load()
		clr.w	(a0)+					;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out paramters
		move.w	#1,(a0)+				;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes
		rts

; --------------------------------------------------------------
;		rsrc_free() | #111 | #$6f
; --------------------------------------------------------------

rsrc_free:	lea.l	control,a0				;aes control structure
		move.w	#$6f,(a0)+				;+0 rsrc_free()
		clr.w	(a0)+					;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out paramters
		clr.w	(a0)+					;+6 addr_in parameters
		clr.w	(a0)					;+8 addr_out parameters
		bsr.w	aes
		rts

; --------------------------------------------------------------
;		rsrc_gaddr() | #112 | #$70
; --------------------------------------------------------------

; INPUT:
;	word	int_in		+2 id number of object
;
; OUTPUT:
;	word	int_out		+0 0=error otherwise ok
;	long	addr_out	+0 address to objecttree
;
; EXAMPLE IN:	move.w	#0,int_in+2
;		bsr.w	rsrc_gaddr

rsrc_gaddr:	lea.l	control,a0				;aes control structure
		move.w	#$70,(a0)+				;+0 rsrc_gaddr()
		move.w	#2,(a0)+				;+2 int_in parameters
		move.w	#1,(a0)+				;+4 int_out paramters
		clr.w	(a0)+					;+6 addr_in parameters
		move.w	#1,(a0)					;+8 addr_out parameters
		clr.w	int_in					;+0 objecttree
		bsr.w	aes
		move.l	addr_out,rsrc_address			;store address
		rts



; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even

alert_rsrcload:	dc.b	'[1][rsrc_load() failed.][Okie]',0	;aes error rsrc_load() 
		even
alert_rsrcgaddr:dc.b	'[1][rsrc_gaddr() failed.][Okie]',0	;aes error rsrc_gaddr()
		even
alert_formcenter:dc.b	'[1][form_center() failed.][Okie]',0	;aes error form_center()
		even
alert_formdial:	dc.b	'[1][form_dial() failed.][Okie]',0	;aes error form_dial()
		even
alert_objcdraw:	dc.b	'[1][objc_draw() failed.][Okie]',0	;aes error objc_draw()
		even
alert_formdo:	dc.b	'[1][form_do() failed.][Okie]',0	;aes error form_do()
		even


aes_pb:		dc.l	control,global,int_in,int_out,addr_in,addr_out
		even

rsc_filename:	dc.b	'menu.rsc',0				;resource filename
		even
		
; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

global:		ds.w	7
		ds.l	4


control:	ds.w	12					;aes control structure
int_in:		ds.w	30					;aes in parameters
int_out:	ds.w	45					;aes out parameters
addr_in:	ds.l	2					;aes address input
addr_out:	ds.l	1					;aes address output


appl_init_ap_id:ds.w	1					;appl_init() application id

gr_h_screen:	ds.w	1					;graf_handle() screen id number		
gr_h_fontwidth:	ds.w	1					;graf_handle() fontwidth
gr_h_fontheight:ds.w	1					;graf_handle() fontheight
gr_h_boxwidth:	ds.w	1					;graf_handle() boxwidth to hold a char
gr_h_boxheight:	ds.w	1					;graf_handle() boxheight to hold a char


form_xpos:	ds.w	1					;form x-position
form_ypos:	ds.w	1					;form y-position
form_xwidth:	ds.w	1					;form x-width
form_yheight:	ds.w	1					;form y-height

obj_xpos:	ds.w	1
obj_ypos:	ds.w	1

rsrc_address:	ds.l	1					;rsrc_gaddr	



; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------



;-------------- TOS MENU ---------------------------------------

tos_startup:
		lea.l	tos_defaults,a6

		tst.w	monitor					;monitor?
		beq.s	.vga

.rgb:		cmp.w	#60,rgb_freq				;rgb 60?
		beq.s	.r60					;
.r50:		bsr.w	.key3					;set rgb50
		bra.s	.detail					;
.r60:		bsr.w	.key4					;set rgb60
		bra.s	.detail					;

.vga:		cmp.w	#100,vga_freq				;vga 100?
		beq.s	.vga100					;
.vga60:		bsr.w	.key1					;set vga60
		bra.s	.detail					;
.vga100:	bsr.w	.key2					;set vga100

.detail:	tst.w	detail					;detail?
		beq.s	.low					;
.high:		bsr.w	.keya					;set high
		bra.s	.print					;
.low:		bsr.w	.keyb					;set low


.print:		move.l	#tos_select_text,d0
		bsr.w	cconws

.keywait:	bsr.w	crawcin

		cmp.b	#$1b,d0					;escape
		beq.w	exit					;
		
		cmp.b	#$20,d0					;space
		beq.w	.go					;


.tst1:		cmp.b	#$31,d0					;1
		bne.s	.tst2					;
		bsr.w	.key1					;
		bra.s	.print					;

.tst2:		cmp.b	#$32,d0					;2
		bne.s	.tst3					;
		bsr.w	.key2					;
		bra.s	.print					;

.tst3:		cmp.b	#$33,d0					;3
		bne.s	.tst4					;
		bsr.w	.key3					;
		bra.s	.print					;

.tst4:		cmp.b	#$34,d0					;4
		bne.s	.tsta					;
		bsr.w	.key4					;
		bra.s	.print					;

.tsta:		cmp.b	#$61,d0					;a
		bne.s	.tstaa					;
		bsr.w	.keya					;
		bra.s	.print					;

.tstaa:		cmp.b	#$41,d0					;A
		bne.s	.tstb					;
		bsr.w	.keya					;
		bra.s	.print					;

.tstb:		cmp.b	#$62,d0					;b
		bne.s	.tstbb					;
		bsr.w	.keyb					;
		bra.s	.print					;

.tstbb:		cmp.b	#$42,d0					;B
		bne.s	.nothing				;
		bsr.w	.keyb					;
		bra.s	.print					;

.nothing:	bra.s	.keywait


.key1:		bsr.w	.clear_video_text			;set vga60
		move.b	#"*",40*2+3(a6)				;
		clr.w	monitor					;
		move.w	#60,vga_freq				;
		rts						;

.key2:		bsr.w	.clear_video_text			;set vga100
		move.b	#"*",40*3+3(a6)				;
		clr.w	monitor					;
		move.w	#100,vga_freq				;
		rts						;

.key3:		bsr.w	.clear_video_text			;set rgb50
		move.b	#"*",40*5+3(a6)				;
		move.w	#1,monitor				;
		move.w	#50,rgb_freq				;
		rts						;

.key4:		bsr.w	.clear_video_text			;set rgb60
		move.b	#"*",40*6+3(a6)				;
		move.w	#1,monitor				;
		move.w	#60,rgb_freq				;
		rts						;

.keya:		bsr.w	.clear_detail_text			;set high detail
		move.b	#"*",40*2+24(a6)			;
		move.w	#1,detail				;
		rts

.keyb:		bsr.w	.clear_detail_text			;set low detail
		move.b	#"*",40*3+24(a6)			;
		clr.w	detail					;
.go:		rts



.clear_video_text:	
		move.b	#" ",40*2+3(a6)
		move.b	#" ",40*3+3(a6)
		move.b	#" ",40*5+3(a6)
		move.b	#" ",40*6+3(a6)
		rts

.clear_detail_text:	
		move.b	#" ",40*2+24(a6)
		move.b	#" ",40*3+24(a6)
		rts


; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

tos_select_text:
		dc.b	27,'E'
		dc.b	'            - CREWNAME -              ',13,10
		dc.b	'         Production name v1.0         ',13,10,13,10

tos_defaults:	dc.b	'Video mode:          Detail mode:     ',13,10
		dc.b	'--------------------------------------',13,10
		dc.b	'1 ( )VGA 60 Hz       A ( ) High detail',13,10
		dc.b	'2 ( )VGA 100 Hz      B ( ) Low detail ',13,10
		dc.b	'                                      ',13,10
		dc.b	'3 ( )RGB 50 Hz                        ',13,10
		dc.b	'4 ( )RGB 60 Hz                        ',13,10,13,10

		dc.b	'SPACE to start demo, ESCAPE to exit.  ',13,10
		dc.b	0

; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------



; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------
