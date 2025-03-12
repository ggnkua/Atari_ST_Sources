		;bare minimum joystick handler for gfabasic + mint
		;by Lonny Pursell

		;designed for INLINE use with GFABASIC via the C:() function
		;mimics the gfa joystick commands
		;  STICK 1	-> @stick(1)
		;  d&=STICK(1)	-> d&=@stick(1)
		;  b!=STRIG(1)	-> b!=@strig(1)
		;  only stick(1) is supported, the parmeter is ignored
		;this code does not need $C+, registers a3-a6 are not touched
		;does not auto install like gfa if you call stick() or strig()
		;  you must call stick 1 to turn it on
		;must call stick 0 before the app exits, or its fatal
		;  if the handler is not removed, the system will crash

		;devpac options
		comment HEAD=-1		;tell gbe to strip prg header
		opt	p=68000		;processor type
		opt	c+		;case matters
		opt	chkpc		;force position independent
		opt	o+		;optimize all
		output	asm.inl

		include	i:\include\_bios.s
		include	i:\include\_xbios.s
		include	i:\include\_gemdos.s

		text

		;entry points for gfa
call_table:	bra.s	stick			;+0
		bra.s	fn_stick		;+2
		bra.s	fn_strig		;+4

install_flag:	dc.w	0			;0=off/1=on
stick_data:	dc.w	0			;stick 1 only
mouse_data:	dc.w	0			;mouse buttons

		;no paramters
fn_stick:	move.b	stick_data(pc),d0
		moveq	#%00001111,d1		;mask
		and.l	d1,d0
		rts

		;no parameters
fn_strig:	move.b	mouse_data(pc),d0
		moveq	#%00000001,d1		;mask for button #2
		and.b	d1,d0
		sne	d0			;bit 1?
		ext.w	d0
		ext.l	d0
		rts

		;stick n  (0=off, 1=on)
stick:		tst.w	4(sp)			;mode parameter
		beq.s	.uninstall
		;install
		move.b	install_flag(pc),d0
		bne.s	.no_install		;<>0? already installed...
		bsr.s	kbdvbase		;->d3=kbdvbase table
		bsr.s	sup_on_int_off		;->d7=stack
		;
		move.l	d3,a1			;d3<-kbdvbase table
		lea	@joyvec(a1),a1		;offset to stick vector
		lea	old_stick_vec(pc),a0
		move.l	(a1),(a0)		;save old stick handler
		lea	stick_handler(pc),a0
		move.l	a0,(a1)			;new stick handler
		;
		move.l	d3,a1
		lea	@mousevec(a1),a1	;offset to mouse vector
		lea	old_mouse_vec(pc),a0
		move.l	(a1),(a0)		;save old mouse handler
		lea	mouse_handler(pc),a0
		move.l	a0,(a1)			;new mouse handler
		;
		bsr.s	int_on_sup_off		;<-d7=stack
		lea	install_flag(pc),a0
		st	(a0)			;set installed flag
.no_install:	rts

.uninstall:	move.b	install_flag(pc),d0
		beq.s	.no_uninstall		;a0=0? not installed...
		bsr.s	kbdvbase
		bsr.s	sup_on_int_off
		;
		move.l	d3,a1
		lea	@joyvec(a1),a1		;offset to stick vector
		move.l	old_stick_vec(pc),(a1)	;restore old stick handler
		;
		move.l	d3,a1
		lea	@mousevec(a1),a1	;offset to mouse vector
		move.l	old_mouse_vec(pc),(a1)	;restore old mouse handler
		;
		bsr.s	int_on_sup_off
		lea	install_flag(pc),a0
		sf	(a0)
.no_uninstall	rts

		;output: d3 (won't get clobbered)
kbdvbase:	move.w	#@kbdvbase,-(a7)
		trap	#@xbios
		addq.l	#2,a7			;fix stack
		move.l	d0,d3			;save it
		rts

		;output: d7 (won't get clobbered)
sup_on_int_off:	clr.l	-(a7)			;sup_set
		move.w 	#@super,-(a7)
		trap	#@gemdos
		addq.l	#6,a7			;fix stack
		move.l	d0,d7			;save it
		move.w	#$2700,sr		;interrupts off
		rts

		;input: d7
int_on_sup_off:	move.w	#$2300,sr 		;interrupts on
		move.l	d7,-(a7)		;restore stack
		move.w 	#@super,-(a7)
		trap	#@gemdos
		addq.l	#6,a7			;fix stack
		rts

		dc.l	'XBRA','GFA3'
old_stick_vec:	dc.l	0

		;new joystick handler, copy stick #1 data, and get out
stick_handler:	move.l	a1,-(sp)
		lea	stick_data(pc),a1	;stick 1
		move.b	2(a0),(a1)		;f...rldu
		move.l	(sp)+,a1
		move.l	old_stick_vec(pc),-(sp)	;jump thru old vector
		rts

		dc.l	'XBRA','GFA3'
old_mouse_vec:	dc.l	0

		;new mouse handler, only interested in mouse button #2
mouse_handler:	move.l	a1,-(sp)
		lea	mouse_data(pc),a1	;buttons 12
		move.b	(a0),(a1)		;0000000011 (bits)
		move.l	(sp)+,a1
		move.l	old_mouse_vec(pc),-(sp)
		rts

		end
