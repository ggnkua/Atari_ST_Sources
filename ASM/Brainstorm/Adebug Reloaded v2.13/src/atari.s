;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

;  #[ Screen functions:
	; #[ put_1280_960:
put_1280_960:
	moveq	#%110,d0
	move.l	#$009f003b,d1
	bra.s	put_xxx_xxx
	; #] put_1280_960:
	; #[ put_640_400:
put_640_400:
	moveq	#%010,d0
	move.l	#$004f0018,d1
	bra.s	put_xxx_xxx
	; #] put_640_400:
	; #[ put_640_200:
put_640_200:
	moveq	#%001,d0
	move.l	#$004f0018,d1
	bra.s	put_xxx_xxx
	; #] put_640_200:
	; #[ put_320_200:
put_320_200:
	moveq	#%000,d0
	move.l	#$00270018,d1
;	bra.s	put_xxx_xxx
	; #] put_320_200:
	; #[ put_xxx_xxx:
put_xxx_xxx:
	move.l	d1,big_window_coords+4(a6)
	move.l	d7,-(sp)
	move.w	d0,d7
	tst.b	screen0_flag(a6)
	beq.s	.nopoke
	bsr	wait_vbl
	move.w	machine_type(a6),d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.nopoke-.tab		;stbook
.fa:	move.w	d7,d0
	bsr	vsetimode
	lea	internal_video(a6),a0
	bsr	vsetvid
	bra.s	.nopoke
.tt:	lea	$ff8262,a0
	bra.s	.poke
.ste:
.st:	lea	$ffff8260.w,a0
.poke:	move.b	d7,(a0)
.nopoke:	tst.b	low_rez(a6)
	beq.s	.not_in_low
	tst.b	d7
	beq.s	.switched
	jsr	switch_windows
	bra.s	.switched
.not_in_low:
	tst.b	d7
	bne.s	.switched
	jsr	switch_windows
.switched:
	move.w	d7,d0
	bsr	torezflag
	lea	rez_parameters_table(pc),a0
	mulu	#10,d7

	add.w	d7,a0
	move.w	(a0)+,screen_size_y(a6)
	move.w	(a0)+,line_size(a6)
	move.w	(a0)+,line_len(a6)
	move.w	(a0)+,column_len(a6)
	move.w	(a0),d0
	move.l	(a6,d0.w),font_addr(a6)
	bsr	clear_screen
.end:	move.l	(sp)+,d7
	rts
	; #] put_xxx_xxx:
	; #[ vsetimode:	Falcon only
	_20

;In: d0=(0,1,2)
vsetimode:
	; Dump (once for all) video registers for internal video mode
	; if no memory to allocate internal screen, then current screen
	; is used (has to be larger, but this should be ok)
	tst.w	internal_rez(a6)
	beq.s	.1st
	rts
.1st:	movem.l	d3-d4,-(sp)
	move.w	.mode(pc,d0.w*2),d0
	or.w	monmask(a6),d0		;VGA+PAL
	move.w	d0,internal_rez(a6)
	bsr	vgetmode			;get cur mode
	move.w	d0,d3
	move.w	internal_rez(a6),-(sp)
	move.w	#$5b,-(sp)
	trap	#14			;vgetsize
	addq.w	#4,sp
	add.l	#1024,d0
	moveq	#-1,d1			;no clear
	moveq	#0,d2			;slow ram
	bsr.l	reserve_memory
	move.l	d0,d4
	bne.s	.okmem
	move.l	$44e.w,d0
	bra.s	.do
.okmem:	add.l	#1024,d0
	clr.b	d0
.do:	move.l	$44e.w,-(sp)		;save old $44e
	move.l	d0,$44e.w

	move.w	internal_rez(a6),d0
	bsr	_vsetmode			;get my mode
	lea	internal_video(a6),a0
	bsr	vgetvid		; dump video registers for internal video mode
	move.w	d3,d0
	bsr	_vsetmode			;reset cur mode

	move.l	(sp)+,$44e.w		;restore $44e
	move.l	d4,d0
	beq.s	.nofree
	bsr.l	free_memory
.nofree:	movem.l	(sp)+,d3-d4
	rts

.mode:	dc.w	%10000010	;S----4
	dc.w	%10001001	;S---82
	dc.w	%10001000	;S---81

	; #] setmymode:
	; #[ vsetmode:		Falcon only
;	move.l	line_a_basepage(a6),a0
;	lea	$7e(a0),a0
;	move.l	(a0),oldvptr(a6)
;	lea	.rout(pc),a1
;	move.l	a1,(a0)
;	bsr.s	_vsetmode
;	move.l	line_a_basepage(a6),a0
;	move.w	newplan(a6),(a0)
;	move.l	oldvptr(a6),$7e(a0)
;	rts
;.rout:	SWITCHA6
;	move.l	$a6(a1),a0
;	move.w	6(a0),newplan(a6)
;	clr.w	6(a0)
;	RESTOREA6
;	rts

;vsetmode:
;	tst.w	montype(a6)
;	bne.s	_vsetmode
;	rts

vgetmode:	moveq	#-1,d0
_vsetmode:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	move.w	#$58,-(sp)
	trap	#14
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

;vsetrgb:	moveq	#$5d,d1
;	bra.s	_rgb
;vgetrgb:	moveq	#$5e,d1
;_rgb:	move.l	a2,-(sp)
;	move.l	a0,-(sp)
;	move.w	d0,-(sp)
;	clr.w	-(sp)
;	move.w	d1,-(sp)
;	trap	#14
;	lea	10(sp),sp
;	move.l	(sp)+,a2
;	rts

GETVID	MACRO
	move.w	\1,\2
	ENDM

;In: a0=@ buffer
vgetvid:	move.l	a0,-(sp)
	bsr	vgetmode
	move.l	(sp)+,a0
	move.w	d0,(a0)+
	lea	$ff8282,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	$ff82a2,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	GETVID	$ff820e,(a0)+	;line offset
	GETVID	$ff8210,(a0)+	;line width
	GETVID	$ff82c2,(a0)+	;VCO
	GETVID	$ff82c0,(a0)+	;RCO
	GETVID	$ff8266,(a0)+	;SPSHIFT
	rts

SETVID	MACRO
	move.w	\1,\2
;;	lea	\2,a1
;;	move.w	\1,(a1)
	ENDM

;In: a0=@ buffer
vsetvid:	move	sr,-(sp)
	ori	#$700,sr
	tst.w	montype(a6)
	beq	.sthi		;special case on ST high rez mono
.do:;	bsr	wait_vbl	; removing this one should not bring any problem
	move.w	(a0)+,d0
	lea	$ff8282,a1	;hregs
	move.l	(a0)+,(a1)+	; $8282: half-lines / $8284: horiz border end
	move.l	(a0)+,(a1)+	; $8286: horiz border begin / $8288: horiz data end
	move.l	(a0)+,(a1)+	; $828A: horiz data start / $828C: horiz sync start
	lea	$ff82a2,a1	;vregs
	move.l	(a0)+,(a1)+	; $82a2 / $82a4
	move.l	(a0)+,(a1)+	; $82a6 / $82a8
	move.l	(a0)+,(a1)+	; $82aa / $82ac
	lea	$ff8266,a1	;spshift
	clr.w	(a1)
	SETVID	(a0),$ff820e	;line offset
	SETVID	2(a0),$ff8210	;line width
	SETVID	4(a0),$ff82c2	;vco
	SETVID	6(a0),$ff82c0	;rco
	move.w	d0,d1
	andi.w	#7,d1
	beq.s	.1bp		;1bp
	cmp.w	#2,d1
	blt.s	.2bp		;2bp
	beq.s	.4bp		;4bp
.spsft:	move.w	8(a0),(a1)	;8bp | TC set only spshift
	bra.s	.end
.4bp:	btst	#7,d0		;4bp ST comp?
	beq.s	.end		;dont care for ff8260
	clr.b	$ff8260		;ST low
	bra.s	.end		;reset VCO?
.2bp:	move.b	#1,$ff8260	;always set ST med
	SETVID	2(a0),$ff8210	;reset linewidth
	SETVID	4(a0),$ff82c2	;reset vco
	bra.s	.end
.1bp:	tst.w	montype(a6)	;not ST high monitor?
	beq.s	.set_st_high
	lea	$ff8266,a1	;spshift
	clr.w	(a1)
	bsr	wait_full_vbl	; 1bp Videl Bug
	move.w	8(a0),(a1)	;spshift
	move.w	(a0),$ff820e	;line offset
	move.w	2(a0),$ff8210	;line width
	move.w	4(a0),$ff82c2	;vco
	move.w	6(a0),$ff82c0	;rco
	bra.s	.end
.set_st_high:
	move.b	#2,$ff8260	;set ST high
.end:	move	(sp)+,sr
	rts
.sthi:	move.l	a0,-(sp)		;this should be enough for screenblaster/blowup
	move.w	(a0)+,d0
	andi.w	#7,d0
	bne.s	.sethi
	lea	$ff8282,a1	;hregs
	moveq	#3-1,d0
.lh:	cmpm.l	(a0)+,(a1)+
	bne.s	.sethi
	dbf	d0,.lh
	lea	$ff82a2,a1	;vregs
	moveq	#3-1,d0
.lv:	cmpm.l	(a0)+,(a1)+
	bne.s	.sethi
	dbf	d0,.lv
	move.w	$ff820e,d0
	cmp.w	(a0)+,d0		;line offset
	bne.s	.sethi
	move.w	$ff8210,d0
	cmp.w	(a0)+,d0		;line width
	bne.s	.sethi
	move.w	$ff82c2,d0
	cmp.w	(a0)+,d0		;vco
	bne.s	.sethi
	move.w	$ff82c0,d0
	cmp.w	(a0)+,d0		;rco
	bne.s	.sethi
	move.w	$ff8266,d0
	cmp.w	(a0)+,d0		;spshift
	bne.s	.sethi
	move.l	(sp)+,a0
	bra.s	.end
.sethi:	move.l	(sp)+,a0
	bra	.do

	_00

vsetipal:	lea	internal_palette(a6),a0
	cmp.w	#_FALC,machine_type(a6)
	beq.s	.fa
.st:	move.l	(a0),$ff8240
	rts
.fa:	tst.w	montype(a6)
	beq.s	.st
	move.w	(a0),d0
	ext.l	d0
;	andi.l	#$fcfc00fc,d0
	move.l	d0,$ff9800
	move.w	2(a0),d0
	ext.l	d0
;	andi.l	#$fcfc00fc,d0
	move.l	d0,$ff9804
	rts

vsetrgb:	cmp.w	#_FALC,machine_type(a6)
	beq.s	.fa
.st:	lsr.w	#1,d0		;w->l
	lea	$ff8240,a1
	bra.s	.l1
.fa:	tst.w	montype(a6)
	beq.s	.st
	lea	$ff9800,a1
.l1	subq.w	#1,d0
	bmi.s	.end
.l2:	move.l	(a0)+,(a1)+
	dbf	d0,.l2
.end:	rts

vgetrgb:	cmp.w	#_NB,machine_type(a6)
	beq.s	.end
	cmp.w	#_FALC,machine_type(a6)
	beq.s	.fa
.st:	lsr.w	#1,d0
	lea	$ff8240,a1
	bra.s	.l1
.fa:	tst.w	montype(a6)
	beq.s	.st
	lea	$ff9800,a1
.l1:	subq.w	#1,d0
	bmi.s	.end
.l2:	move.l	(a1)+,(a0)+
	dbf	d0,.l2
.end:	rts
	; #] vsetmode:
	; #[ torezflag:
;d0 = res (0-7)
torezflag:		;used in machine init and put_xxx_xxx
	lea	low_rez(a6),a0
	clr.l	(a0)
	clr.l	4(a0)
	andi.w	#%111,d0
	cmp.w	#%110,d0
	beq.s	.meta
	bclr	#2,d0
.meta:	st	(a0,d0.w)
	rts

put_internal_rez:	;used in from_rostruct
	andi.w	#%111,d0
	cmpi.w	#%110,d0
	beq.s	.end
	andi.w	#%11,d0
	beq.s	.f8
	subq.w	#1,d0
	beq.s	.f9
	jmp	f10
.f8:	jmp	f8
.f9:	jmp	f9
.end:	rts
	; #] torezflag:
	; #[ put_color_monitor: switch to color monitor
put_color_monitor:
	tst.b	electronic_switch_flag(a6)
	beq.s	.end
	tst.b	high_rez(a6)
	beq.s	.end
	move.w	sr,-(sp)
	ori.w	#$700,sr

	lea	$ff8800,a0
	move.b	#$e,(a0)
	move.b	(a0),d0		;method for special switcher
	bset	#6,d0
	move.b	d0,2(a0)

	moveq	#1,d0		;update system shadow resolution
	move.b	d0,$44a.w
	move.b	d0,$44c.w
	move.w	(sp)+,sr
.end:	rts
	; #] put_color_monitor:
	; #[ put_mono_monitor: switch to mono monitor
put_mono_monitor:
	tst.b	electronic_switch_flag(a6)
	beq.s	.end
	tst.b	high_rez(a6)
	bne.s	.end
	move.w	sr,-(sp)
	ori.w	#$700,sr
	lea	$ff8800,a0
	move.b	#$e,(a0)
	move.b	(a0),d0
	bclr	#6,d0
	move.b	d0,2(a0)

	moveq	#2,d0
	move.b	d0,$44a.w
	move.b	d0,$44c.w
	move.w	(sp)+,sr
.end:	rts
	; #] put_mono_monitor:
	; #[ wait_full_vbl:
GET_ADDR24	MACRO
	moveq	#0,\4
	move.b	\3,\4
	ror.l	#8,\4
	move.b	\2,\4
	ror.l	#8,\4
	move.b	\1,\4
	swap	\4
	ENDM
wait_full_vbl
	movem.l	d0-d2,-(sp)
	bsr	wait_vbl
	; wait for vcount to go back to begining of screen memory
	GET_ADDR24	$ff8205,$ff8207,$ff8209,d0	; vcount
	moveq	#-1,d1			; use some timeout, just incase...
.wait1
	GET_ADDR24	$ff8205,$ff8207,$ff8209,d2
	cmp.l	d0,d2
	dblo	d1,.wait1
	movem.l	(sp)+,d0-d2
	rts
	; #] wait_full_vbl:
	; #[ wait_vbl:
wait_vbl:
	; Warning: this routine will won't really wait for the VBL if called
	; 2 times in a row (the second call and further one do exit too early)
	movem.l	d0-d2,-(sp)
	move.w	#10000,d2
.l1:	move.b	$ff8209,d0
	moveq	#$7f,d1
.l2:	cmp.b	$ff8209,d0
;	nop
	beq.s	.out
	dbf	d2,.l1
	bra.s	.end
.out:
;	nop
	dbf	d1,.l2
.end:	movem.l	(sp)+,d0-d2
	rts
	; #] wait_vbl:
	; #[ Sbase0_sbase1:
;si c'etait un moniteur mono,je remets pas la reso car:
;	si je suis encore en mono,inutile
;	si je suis en couleur,ca va faire reset
;si c'etait un moniteur couleur,je remets la reso car:
;	si je suis encore en couleur,ca met basse ou moyenne
;	si je suis en mono,ca va faire reset->tester
sbase0_sbase1:
	; switch to user screen (external screen) video settings
	tst.b	screen0_flag(a6)
	beq	.no
	sf	screen0_flag(a6)
	move	sr,-(sp)
	ori	#$700,sr

	bsr	wait_vbl

	lea	$ff820a,a0			;frequence
	move.b	external_frequency(a6),(a0)

	lea	external_palette(a6),a0
	moveq	#2,d0
	bsr	vsetrgb

;	bsr	wait_vbl	; removing this one should not bring any problem
	lea	$ff8201,a0		;@ ecran
	move.w	external_rez(a6),d0		;restaurer la reso de P1
	move.w	machine_type(a6),d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.stscr-.tab
.fa:	lea	external_video(a6),a0
	bsr	vsetvid
	lea	$ff8201,a0		;@ ecran
;	not.b	$c(a0)
	move.l	logbase(a6),d0
	lsr.l	#8,d0
	movep.w	d0,(a0)
	move.b	external_low_base(a6),$ff820d
	move.b	external_hscroll(a6),$ff8265
	bra.s	.end
.tt:	move.b	d0,$ff8262
	bra.s	.stscr
.ste:	move.b	d0,$ffff8260.w
.stescr:	not.b	$c(a0)
	move.l	logbase(a6),d0
	lsr.l	#8,d0
	movep.w	d0,(a0)
	move.b	external_low_base(a6),$ff820d
	move.b	external_line_width(a6),$ff820f
	move.b	external_hscroll(a6),$ff8265
	bra.s	.end
.st:	move.b	d0,$ffff8260.w
.stscr:	move.l	logbase(a6),d0
	lsr.l	#8,d0
	movep.w	d0,(a0)
.end:	move	(sp)+,sr
.no:	rts
	; #] Sbase0_sbase1:
	; #[ Sbase1_sbase0:
sbase1_sbase0:
	; switch to adebug internal screen video settings
	moveq	#RS232_OUTPUT,d0
	cmp.l	device_number(a6),d0
	beq	.no
	tst.b	screen0_flag(a6)
	bne	.no
	st	screen0_flag(a6)

	move.l	d7,-(sp)
	move	sr,-(sp)
	ori	#$700,sr

	moveq	#2,d7
	tst.b	high_rez(a6)
	bne.s	.set
	moveq	#1,d7
	tst.b	mid_rez(a6)
	bne.s	.set
	moveq	#%110,d7
	tst.b	meta_rez(a6)
	bne.s	.set
	moveq	#0,d7
.set:	bsr	wait_vbl	

	lea	$ff820a,a0			;frequence
	move.b	(a0),external_frequency(a6)
	move.b	internal_frequency(a6),(a0)

	lea	external_palette(a6),a0
	moveq	#2,d0
	bsr	vgetrgb
	bsr	vsetipal

	move.w	machine_type(a6),d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.stscr-.tab
.st:	lea	$ffff8260.w,a0
	move.b	(a0),d0				;resolution
	andi.w	#%11,d0
	move.b	d7,(a0)
	move.w	d0,external_rez(a6)
	bra.s	.stscr
.ste:	lea	$ffff8260.w,a0
	move.b	(a0),d0				;resolution
	andi.w	#%11,d0
	move.b	d7,(a0)
	move.w	d0,external_rez(a6)
	bra.s	.stescr
.tt:	lea	$ff8262,a0
	move.b	(a0),d0				;andi.w	#%111,d0
	move.b	d7,(a0)
	move.w	d0,external_rez(a6)
	bra.s	.stscr
.fa:
	bsr	vgetmode
	move.w	d0,external_rez(a6)
	lea	external_video(a6),a0
	bsr	vgetvid		; dump user screen video settings
	move.w	d7,d0
	bsr	vsetimode	; different monitor since we last went to internal screen?
	lea	internal_video(a6),a0
	bsr	vsetvid		; we put the correct mono, vga or rgb parameters
.stescr:	lea	$ff820d,a0
	move.b	(a0),external_low_base(a6)
	clr.b	(a0)
	lea	$ff820f,a0
	move.b	(a0),external_line_width(a6)
	clr.b	(a0)
	lea	$ff8265,a0
	move.b	(a0),external_hscroll(a6)
	clr.b	(a0)
.stscr:	lea	$ff8201,a0			;@ ecran
	move.l	physbase(a6),d0
	lsr.l	#8,d0
	moveq	#0,d7
	movep.w	0(a0),d7
	lsl.l	#8,d7
	move.l	d7,logbase(a6)
	movep	d0,0(a0)
.end:	move	(sp)+,sr
	move.l	(sp)+,d7
.no:	rts
	; #] Sbase1_sbase0:
;	 #[ Flash:

flash:	cmp.l	#RS232_OUTPUT,device_number(a6)
	bne.s	.notrs
	moveq	#7,d0
	bra	rs_put
.notrs:	bsr	wait_vbl
	tst.b	meta_rez(a6)	;TT Meta
	beq.s	.st
	lea	$ff8900,a0
	clr.w	(a0)
	pea	0.w
	move.b	1(sp),3(a0)
	move.b	2(sp),5(a0)
	move.b	3(sp),7(a0)
	pea	8.w
	move.b	1(sp),$f(a0)
	move.b	2(sp),$11(a0)
	move.b	3(sp),$13(a0)
	addq.w	#8,sp
	move.w	#0,$20(a0)
	move.w	#3,(a0)
	moveq	#10,d1
.wait1	moveq	#-1,d0
.wait	dbf	d0,.wait
	dbf	d1,.wait1
	clr.w	(a0)
	rts
.st:	not.l	internal_palette(a6)
	bsr	vsetipal
	move.w	#10000,d0
	IFNE	_68030		; maybe move to wait_full_vbl to remove this hack??
	tst.b	chip_type(a6)
	beq.s	.l1
	asl.w	#2,d0
	ENDC
.l1:	dbf	d0,.l1
	bsr	wait_vbl
	not.l	internal_palette(a6)
	bra	vsetipal

;	 #] Flash:
;	 #[ Flashing cursor:

flashing_cursor:
 lea $ff8201,a0
 moveq #0,d0
 movep.w (a0),d0
 lsl.l #8,d0
 move.l d0,a0
 move.b $ff8260,d0
 and.b #%11,d0
 bchg #7,(a0)
 cmp.b #2,d0
 beq.s .end
 bchg #7,2(a0)
 cmp.b #1,d0
 beq.s .end
 bchg #7,4(a0)
 bchg #7,6(a0)
.end:
 rts

;	 #] Flashing cursor:
;	 #[ Draw window:

draw_window:
 tst.l device_number(a6)
 bne.s .__0
.___0
 rts
.__0:
 tst.b acia_ikbd(a6)
 beq.s ._1
 bsr internal_inkey
._1:
 cmp.l #RS232_OUTPUT,device_number(a6)
 beq terminal_draw_window
 cmp.l #PRINTER_OUTPUT,device_number(a6)
 beq.s .___0
 movem.l d0-a6,-(sp)
 move.l physbase(a6),a0
 move.w upper_x(a6),d0
 move.w upper_y(a6),d1
 move.w lower_x(a6),d2
 move.w lower_y(a6),d3
 moveq #4,d7
 tst.b meta_rez(a6)
 bne .meta_rez
 tst.b high_rez(a6)
 bne .high_rez
 tst.b low_rez(a6)
 bne .low_rez

.mid_rez:
 subq.w #1,d7
 move.w d1,d4
 lsl.w d7,d4
 subq.w #6,d4
 mulu #$a0,d4
 add.w d4,a0
 move.w d2,d6
 add.w d6,d6
 btst #1,d6
 beq.s .0
 subq.w #1,d6
.0:
 move.w d0,d5
 subq.w #1,d5
 add.w d5,d5
 btst #1,d5
 beq.s .2
 subq.w #1,d5
.2:
 sub.w d5,d6
 add.w d5,a0
 move.l a0,-(sp)
 move.w d3,d5
 lsl.w #3,d5
 subq.w #6,d5
 tst.b current_window_flag(a6)
 bne.s .4
.3:
 move.b #%00000100,(a0)
 move.b #%00100000,0(a0,d6.w)
 add.w #$a0,a0
 dbf d5,.3
 bra.s .5
.4:
 move.b #%00011100,(a0)
 move.b #%00111000,0(a0,d6.w)
 add.w #$a0,a0
 dbf d5,.4
.5:
 sub.w #$a0,a0
 move.l a0,-(sp)
 move.l 4(sp),a0
 clr.b line_pattern(a6)
 addq.w #1,d0
 subq.w #1,d2
 move.l a0,-(sp)
 add.w #$a1,a0
 move.l a0,d4
 btst #0,d4
 bne.s .100
 addq.w #2,a0
.100:
 bsr med_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 move.l (sp)+,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 tst.b current_window_flag(a6)
 beq.s .6
 moveq #2,d4
.6:
 move.w d4,-(sp)
.8:
 bsr med_horiz_line
 sub.w #$a0,a0
 dbf d4,.8
 clr.b line_pattern(a6)
 move.w (sp)+,d4
 subq.w #2,d4
 neg.w d4
.9:
 bsr med_horiz_line
 sub.w #$a0,a0
 dbf d4,.9
 move.l (sp)+,a0
 addq.w #1,d0
 subq.w #1,d2
 move.l a0,-(sp)
 sub.w #$9f,a0
 move.l a0,d4
 btst #0,d4
 bne.s .101
 addq.w #2,a0
.101:
 bsr med_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 move.l (sp)+,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 moveq #1,d5
 tst.b current_window_flag(a6)
 beq.s .7
 moveq #2,d4
 moveq #0,d5
.7:
 bsr med_horiz_line
 add.w #$a0,a0
 dbf d4,.7
 clr.b line_pattern(a6)
 tst.w d5
 beq.s .10
.11:
 bsr med_horiz_line
 add.w #$a0,a0
 dbf d5,.11
.10:
 addq.w #4,sp
 movem.l (sp)+,d0-a6
 rts

.low_rez:
 subq.w #1,d7
 move.w d1,d4
 lsl.w d7,d4
 subq.w #6,d4
 mulu #$a0,d4
 add.w d4,a0
 move.w d2,d6
 lsl.w #2,d6
 btst #2,d6
 beq.s .0_
 subq.w #3,d6
.0_:
 move.w d0,d5
 subq.w #1,d5
 lsl.w #2,d5
 btst #2,d5
 beq.s .2_
 subq.w #3,d5
.2_:
 sub.w d5,d6
 add.w d5,a0
 move.l a0,-(sp)
 move.w d3,d5
 lsl.w #3,d5
 subq.w #6,d5
 tst.b current_window_flag(a6)
 bne.s .4_
.3_:
 move.b #%00000100,(a0)
 move.b #%00100000,0(a0,d6.w)
 add.w #$a0,a0
 dbf d5,.3_
 bra.s .5_
.4_:
 move.b #%00011100,(a0)
 move.b #%00111000,0(a0,d6.w)
 add.w #$a0,a0
 dbf d5,.4_
.5_:
 sub.w #$a0,a0
 move.l a0,-(sp)
 move.l 4(sp),a0
 clr.b line_pattern(a6)
 addq.w #1,d0
 subq.w #1,d2
 add.w #$a1,a0
 bsr low_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 sub.w #$a1,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 tst.b current_window_flag(a6)
 beq.s .6_
 moveq #2,d4
.6_:
 move.w d4,-(sp)
.8_:
 bsr low_horiz_line
 sub.w #$a0,a0
 dbf d4,.8_
 clr.b line_pattern(a6)
 move.w (sp)+,d4
 subq.w #2,d4
 neg.w d4
.9_:
 bsr low_horiz_line
 sub.w #$a0,a0
 dbf d4,.9_
 move.l (sp)+,a0
 addq.w #1,d0
 subq.w #1,d2
 sub.w #$9f,a0
 bsr low_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 add.w #$9f,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 moveq #1,d5
 tst.b current_window_flag(a6)
 beq.s .7_
 moveq #2,d4
 moveq #0,d5
.7_:
 bsr low_horiz_line
 add.w #$a0,a0
 dbf d4,.7_
 clr.b line_pattern(a6)
 tst.w d5
 beq.s .10_
.11_:
 bsr low_horiz_line
 add.w #$a0,a0
 dbf d5,.11_
.10_:
 addq.w #4,sp
 movem.l (sp)+,d0-a6
 rts

.meta_rez:
 move.w d1,d4
 lsl.w d7,d4
 subq.w #6,d4
 mulu line_size(a6),d4
 add.l d4,a0
 move.w d2,d6
 move.w d0,d5
 subq.w #1,d5
 sub.w d5,d6
 add.w d5,a0
 move.l a0,-(sp)
 move.w d3,d5
 lsl.w #4,d5
 sub.w #$d,d5
 tst.b current_window_flag(a6)
 bne.s .meta_4
.meta_3:
 move.b #%00000100,(a0)
 move.b #%00100000,0(a0,d6.w)
 tst.b inverse_video_flag(a6)
 beq.s .normal_1
 not.b (a0)
 not.b 0(a0,d6.w)
.normal_1:
 add.w line_size(a6),a0
 dbf d5,.meta_3
 bra.s .meta_5
.meta_4:
 move.b #%00011100,(a0)
 move.b #%00111000,0(a0,d6.w)
 tst.b inverse_video_flag(a6)
 beq.s .normal_2
 not.b (a0)
 not.b 0(a0,d6.w)
.normal_2:
 add.w line_size(a6),a0
 dbf d5,.meta_4
.meta_5:
 sub.w line_size(a6),a0
 move.l a0,-(sp)
 move.l 4(sp),a0
 clr.b line_pattern(a6)
 addq.w #1,d0
 subq.w #1,d2
 add.w line_size(a6),a0
 addq.w #1,a0
 bsr meta_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 sub.w line_size(a6),a0
 subq.w #1,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 tst.b current_window_flag(a6)
 beq.s .meta_6
 moveq #2,d4
.meta_6:
 move.w d4,-(sp)
.meta_8:
 bsr meta_horiz_line
 sub.w line_size(a6),a0
 dbf d4,.meta_8
 clr.b line_pattern(a6)
 move.w (sp)+,d4
 sub.w #9,d4
 neg.w d4
.meta_9:
 bsr meta_horiz_line
 sub.w line_size(a6),a0
 dbf d4,.meta_9
 move.l (sp)+,a0
 addq.w #1,d0
 subq.w #1,d2
 sub.w line_size(a6),a0
 addq.w #1,a0
 bsr meta_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 add.w line_size(a6),a0
 subq.w #1,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 moveq #1,d5
 tst.b current_window_flag(a6)
 beq.s .meta_7
 moveq #2,d4
 moveq #0,d5
.meta_7:
 bsr meta_horiz_line
 add.w line_size(a6),a0
 dbf d4,.meta_7
 clr.b line_pattern(a6)
 tst.w d5
 beq.s .meta_10
.meta_11:
 bsr meta_horiz_line
 add.w line_size(a6),a0
 dbf d5,.meta_11
.meta_10:
 addq.w #4,sp
 movem.l (sp)+,d0-a6
 rts

.high_rez:
 move.w d1,d4
 lsl.w d7,d4
 subq.w #6,d4
 mulu line_size(a6),d4
 add.l d4,a0
 move.w d2,d6
 move.w d0,d5
 subq.w #1,d5
 sub.w d5,d6
 add.w d5,a0
 move.l a0,-(sp)
 move.w d3,d5
 lsl.w #4,d5
 sub.w #$d,d5
 tst.b current_window_flag(a6)
 bne.s ._4
._3:
 move.b #%00000100,(a0)
 move.b #%00100000,0(a0,d6.w)
 add.w line_size(a6),a0
 dbf d5,._3
 bra.s ._5
._4:
 move.b #%00011100,(a0)
 move.b #%00111000,0(a0,d6.w)
 add.w line_size(a6),a0
 dbf d5,._4
._5:
 sub.w line_size(a6),a0
 move.l a0,-(sp)
 move.l 4(sp),a0
 clr.b line_pattern(a6)
 addq.w #1,d0
 subq.w #1,d2
 add.w line_size(a6),a0
 addq.w #1,a0
 bsr high_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 sub.w line_size(a6),a0
 subq.w #1,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 tst.b current_window_flag(a6)
 beq.s ._6
 moveq #2,d4
._6:
 move.w d4,-(sp)
._8:
 bsr high_horiz_line
 sub.w line_size(a6),a0
 dbf d4,._8
 clr.b line_pattern(a6)
 move.w (sp)+,d4
 sub.w #9,d4
 neg.w d4
._9:
 bsr high_horiz_line
 sub.w line_size(a6),a0
 dbf d4,._9
 move.l (sp)+,a0
 addq.w #1,d0
 subq.w #1,d2
 sub.w line_size(a6),a0
 addq.w #1,a0
 bsr high_horiz_line
 subq.w #1,d0
 addq.w #1,d2
 add.w line_size(a6),a0
 subq.w #1,a0
 move.b #-1,line_pattern(a6)
 moveq #0,d4
 moveq #1,d5
 tst.b current_window_flag(a6)
 beq.s ._7
 moveq #2,d4
 moveq #0,d5
._7:
 bsr high_horiz_line
 add.w line_size(a6),a0
 dbf d4,._7
 clr.b line_pattern(a6)
 tst.w d5
 beq.s ._10
._11:
 bsr high_horiz_line
 add.w line_size(a6),a0
 dbf d5,._11
._10:
 addq.w #4,sp
 movem.l (sp)+,d0-a6
 rts

print_title:
 movem.l d0-d3/a2-a3,-(sp)
 tst.b high_rez(a6)
 beq.s .no_title
 cmp.l #SCREEN_OUTPUT,device_number(a6)
 bne.s .no_title
 move.l font8x8_addr(a6),a2
 move.l physbase(a6),a1
 move.w upper_y(a6),d0
 subq.w #1,d0
 mulu #$10,d0
 mulu line_size(a6),d0
 add.l d0,a1
 add.w line_size(a6),a1
 add.w upper_x(a6),a1
 move.w lower_x(a6),d2
 sub.w upper_x(a6),d2
 subq.w #1,d2
 move.l a1,-(sp)
.character_loop:
 move.l (sp),a1
 move.l a2,a3
 moveq #0,d0
 move.b (a0)+,d0
 beq.s .end_string
 add.w d0,a3
 move.w #$100,d0 
 move.w line_size(a6),d1
 bsr.s .print
 addq.l #1,(sp)
 dbf d2,.character_loop
 bra.s .end
.end_string:
 move.l (sp),a1
 move.l a2,a3
 moveq #' ',d0
 add.w d0,a3
 move.w #$100,d0 
 move.w line_size(a6),d1
 bsr.s .print
 addq.l #1,(sp)
 dbf d2,.end_string 
.end:
 addq.w #4,sp
.no_title:
 movem.l (sp)+,d0-d3/a2-a3
 rts

.print:
 rept 8
 move.b (a3),(a1)
 add.w d0,a3
 add.w d1,a1
 endr
 rts
 
med_horiz_line:
 movem.l d2-d3/d7/a0,-(sp)
 move.b line_pattern(a6),d7
 sub.w d0,d2
 subq.w #1,d2
 tst.b d7
 beq.s .5
 move.b #%00000111,(a0)+
 clr.b 1(a0)
 tst.b current_window_flag(a6)
 beq.s .6
 move.b #%00011111,-1(a0)
.1:
 bra.s .6
.5:
 clr.b (a0)+
 clr.b 1(a0)
.6:
 move.l a0,d3
 btst #0,d3
 bne.s .odd
 addq.w #2,a0
.even:
 move.b d7,(a0)+
 clr.b 1(a0)
 dbf d2,.odd
 bra.s .end
.odd:
 move.b d7,(a0)+
 clr.b 1(a0)
 addq.w #2,a0
 dbf d2,.even
.end:
 tst.b d7
 beq.s .3
 move.b #%11100000,(a0)+
 clr.b 1(a0)
 tst.b current_window_flag(a6)
 beq.s .4
 move.b #%11111000,-1(a0)
.2:
 bra.s .4
.3:
 clr.b (a0)+
 clr.b 1(a0)
.4:
 movem.l (sp)+,d2-d3/d7/a0
 rts

high_horiz_line:
 movem.l d2-d3/d7/a0,-(sp)
 move.b line_pattern(a6),d7
 sub.w d0,d2
 subq.w #1,d2
 clr.b (a0)+
 tst.b d7
 beq.s .5
 move.b #%00000111,-1(a0)
 tst.b current_window_flag(a6)
 beq.s .5
 move.b #%00011111,-1(a0)
.5:
 move.b d7,(a0)+
 dbf d2,.5
.end:
 clr.b (a0)
 tst.b d7
 beq.s .4
 move.b #%11100000,(a0)
 tst.b current_window_flag(a6)
 beq.s .4
 move.b #%11111000,(a0)
.4:
 movem.l (sp)+,d2-d3/d7/a0
 rts

meta_horiz_line:
 tst.b inverse_video_flag(a6)
 bne.s .meta_invert
 movem.l d2-d3/d7/a0,-(sp)
 move.b line_pattern(a6),d7
 sub.w d0,d2
 subq.w #1,d2
 clr.b (a0)+
 tst.b d7
 beq.s .5
 move.b #%00000111,-1(a0)
 tst.b current_window_flag(a6)
 beq.s .5
 move.b #%00011111,-1(a0)
.5:
 move.b d7,(a0)+
 dbf d2,.5
;.end:
 clr.b (a0)
 tst.b d7
 beq.s .4
 move.b #%11100000,(a0)
 tst.b current_window_flag(a6)
 beq.s .4
 move.b #%11111000,(a0)
.4:
 movem.l (sp)+,d2-d3/d7/a0
 rts

.meta_invert:
 movem.l d2-d3/d7/a0,-(sp)
 move.b line_pattern(a6),d7
 sub.w d0,d2
 subq.w #1,d2
 move.b #-1,(a0)+
 not.b d7
 bne.s .7
 move.b #%11111000,-1(a0)
 tst.b current_window_flag(a6)
 beq.s .7
 move.b #%11100000,-1(a0)
.7:
 move.b d7,(a0)+
 dbf d2,.7
 move.b #-1,(a0)
 tst.b d7
 bne.s .6
 move.b #%00011111,(a0)
 tst.b current_window_flag(a6)
 beq.s .6
 move.b #%00000111,(a0)
.6:
 movem.l (sp)+,d2-d3/d7/a0
 rts

low_horiz_line:
 movem.l d2-d3/d7/a0,-(sp)
 move.b line_pattern(a6),d7
 sub.w d0,d2
 subq.w #1,d2
 clr.b 2(a0)
 clr.b 4(a0)
 clr.b 6(a0)
 tst.b d7
 beq.s .5
 move.b #%00000111,(a0)
 tst.b current_window_flag(a6)
 beq.s .6
 move.b #%00011111,(a0)
.1:
 bra.s .6
.5:
 clr.b (a0)
.6:
 addq.w #1,a0
 move.l a0,d3
 btst #0,d3
 bne.s .odd
 addq.w #6,a0
.even:
 move.b d7,(a0)+
 clr.b 1(a0)
 clr.b 3(a0)
 clr.b 5(a0)
 dbf d2,.odd
 bra.s .end
.odd:
 move.b d7,(a0)+
 clr.b 1(a0)
 clr.b 3(a0)
 clr.b 5(a0)
 addq.w #6,a0
 dbf d2,.even
.end:
 clr.b 2(a0)
 clr.b 4(a0)
 clr.b 6(a0)
 tst.b d7
 beq.s .3
 move.b #%11100000,(a0)
 tst.b current_window_flag(a6)
 beq.s .4
 move.b #%11111000,(a0)
.2:
 bra.s .4
.3:
 clr.b (a0)
.4:
 movem.l (sp)+,d2-d3/d7/a0
 rts
;	 #] Draw window:
;	 #[ Print instruction:

print_instruction:
 movem.l d0-d7/a1-a4,-(sp)
 tst.b acia_ikbd(a6)
 beq.s .1
 bsr internal_inkey
.1:
 move.l device_number(a6),d0
 beq  .4
 cmp.l #RS232_OUTPUT,d0
 bne.s .2
 bsr poscur
.2:
 cmp.l #6,d0
 bge disk_display
 move.l font_addr(a6),a0
 move.l physbase(a6),a1
 move.w x_pos(a6),d0
 move.w y_pos(a6),d1
 lsl.w #4,d1
 moveq #0,d7
 move.w #159,d7
 tst.b meta_rez(a6)
 bne.s ._1
 moveq #79,d7
 tst.b high_rez(a6)
 bne.s ._1
 tst.b mid_rez(a6)
 bne.s ._2
._3:
 add.w d0,d0
 moveq #39,d7
._2:
 add.w d0,d0
 lsr.w #1,d1
._1:
 add.w d0,a1
 subq.w #4,d1
 bpl.s .no_plantage
 clr.w d1
.no_plantage:
 move.w line_size(a6),d4
 mulu d4,d1
 add.l d1,a1
 moveq #0,d3
 tst.b c_line(a6)
 beq.s .no_cline
 REPT 4
 adda.w d4,a1
 ENDR
 bra.s .print
.no_cline:
 tst.b m_line(a6)
 bne.s .print
.no_mline:
 lea line_buffer(a6),a2
.before_print:
 lea w1_db(a6),a3
 move.w window_redrawed(a6),d0
 lsl.w #4,d0
 move.w x_pos(a6),d7
 cmp.w 0(a3,d0.w),d7
 beq.s .0
 move.w 4(a3,d0.w),d7
 sub.w 0(a3,d0.w),d7
 sub.w x_pos(a6),d7
 bra.s .print
.0:
 move.w 4(a3,d0.w),d7
 sub.w 0(a3,d0.w),d7
 subq.w #1,d7
.print:
 move.l a1,a3
 move.b (a2)+,d0
 and.w #$ff,d0
 beq.s .end
 move.l a0,a4
 add.w d0,a4
 bsr.s print_character
 dbf d7,.print
 bra.s .really_end
.end:
 tst.b c_line(a6)
 bne.s .really_end
 tst.b m_line(a6)
 bne.s .really_end
 cmp.l	#SCREEN_OUTPUT,device_number(a6)
 bne.s	.last_loop
 tst.b	high_rez(a6)
 beq.s	.last_loop
 bsr clear_till_end_of_line
 bra.s .really_end
.last_loop:				; *
 move.l a1,a3				; *
 moveq #' ',d0				; *
 move.l a0,a4				; *
 add.w d0,a4				; *
 bsr.s print_character			; *
 dbf d7,.last_loop			; *
.really_end:
 cmp.l #PRINTER_OUTPUT,device_number(a6)
 bne.s .4
 bsr init_printer_display
.4:
 movem.l (sp)+,d0-d7/a1-a4
 rts

print_character:
 cmp.l #RS232_OUTPUT,device_number(a6)
 beq terminal_display
 cmp.l #PRINTER_OUTPUT,device_number(a6)
 beq printer_display
 tst.b low_rez(a6)
 beq mid_high
print_low:
 move.w a3,d2
 btst #2,d2
 beq.s ._5
 subq.w #3,a3
._5:
 tst.b alt_e_flag(a6)
 bne .1
 rept 8
 move.b (a4),(a3)
 clr.b 2(a3)
 clr.b 4(a3)
 clr.b 6(a3)
 lea $100(a4),a4
 adda.w d4,a3
 endr
 addq.w #4,a1
 rts
.1:
 rept 8
 not.b (a3)
 clr.b 2(a3)
 clr.b 4(a3)
 clr.b 6(a3)
 adda.w d4,a3
 endr
 rts
mid_high:
 tst.b mid_rez(a6)
 beq print_high
print_mid:
 move.w a3,d2
 btst #1,d2
 beq.s ._6
 subq.w #1,a3
._6:
 tst.b alt_e_flag(a6)
 bne.s .1
 rept 8
 move.b (a4),(a3)
 clr.b 2(a3)
 lea $100(a4),a4
 adda.w d4,a3
 endr
 addq.w #2,a1
 rts
.1:
 rept 8
 not.b (a3)
 clr.b 2(a3)
 adda.w d4,a3
 endr
 rts

print_high:
 tst.b high_rez(a6)
 beq print_meta
 tst.b alt_e_flag(a6)
 bne .2
.1:
 rept 16
 move.b (a4),(a3)
 lea $100(a4),a4
 add.w d4,a3
 endr
 addq.w #1,a1
 rts
.2:
 rept 16
 not.b (a3)
 add.w d4,a3
 endr
 rts

print_meta:
 tst.b inverse_video_flag(a6)
 bne .invert
 tst.b alt_e_flag(a6)
 bne .2
.1:
 rept 16
 move.b (a4),(a3)
 lea $100(a4),a4
 add.w d4,a3
 endr
 addq.w #1,a1
 rts
.2:
 rept 16
 not.b (a3)
 add.w d4,a3
 endr
 rts
.invert:
 tst.b alt_e_flag(a6)
 bne .3
 rept 16
 move.b (a4),d0
 not.b d0
 move.b d0,(a3)
 lea $100(a4),a4
 add.w d4,a3
 endr
 addq.w #1,a1
 rts
.3:
 rept 16
 not.b (a3)
 add.w d4,a3
 endr
 rts

clear_till_end_of_line:
 moveq #0,d0
 tst.b meta_rez(a6)
 beq.s .not_meta
.meta:
 tst.b inverse_video_flag(a6)
 bne.s .go_to_high
 moveq #-1,d0
.go_to_high:
 addq.w #1,d7
 moveq #$f,d5
.line_loop:
 moveq #0,d6
 move.w d7,d6
 ror.l #2,d6
 move.l a3,-(sp)
 subq.w #1,d6
 bmi.s .now_small
.high_loop:
 move.b d0,(a3)+
 move.b d0,(a3)+
 move.b d0,(a3)+
 move.b d0,(a3)+
 dbf d6,.high_loop
.now_small:
 swap d6
 rol.w #2,d6
 subq.w #1,d6
 bmi.s .end_small_line
.small_line:
 move.b d0,(a3)+
 dbf d6,.small_line
.end_small_line:
 move.l (sp)+,a3
 add.w d4,a3
 dbf d5,.line_loop
 rts
.not_meta:
 tst.b high_rez(a6)
 bne.s .go_to_high
;
; med, low
;
 rts
 
rs_put:	cmp.w	#_FALC,machine_type(a6)
	bne.s	.nofa
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	d0,-(sp)
	move.l	#$30001,-(sp)
	trap	#13
	addq.w	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts
.nofa:
.nochan	tst.b	$fffa2d
	bpl.s	.nochan
	move.b	d0,$fffa2f
	rts

rs_in:	cmp.w	#_FALC,machine_type(a6)
	bne.s	.nofa
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	#$20001,-(sp)
	trap	#13
	addq.w	#4,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts
.nofa:	move	sr,d1
	move	#$2700,sr
	moveq	#-1,d7
.la	btst	#7,$fffa2b
	bne.s	.la1
	dbf	d7,.la
.la1	move.b	$fffa2f,d0
	move	d1,sr
	rts

prt_char:
	tst.b	system_prt_flag(a6)
	bne.s	.system_prt_char
.not_system:
	move.w	sr,d3
	ori	#$700,sr
	move.w	d0,d2
	bsr	busylec
	bsr	strobenv
	moveq	#5,d6
	tst.b	chip_type(a6)
	beq.s	.l2
	asl.w	#2,d6
.l2:	moveq	#-1,d7
.l1:	btst	#0,$fffa01
	beq.s	.lolo
	dbf	d7,.l1
	dbf	d6,.l2
.pas_good:
	moveq	#-1,d0
	bra.s	.end
.lolo:	moveq	#7,d1
	bsr.s	lit_reg
	ori.b	#$80,d0
	moveq	#7,d1
	bsr.s	ecrit_reg
	move.w	d2,d0
	andi.w	#$ff,d0
	moveq	#15,d1
	bsr.s	ecrit_reg
	bsr.s	strobe_l
	bsr.s	strobe_h
	moveq	#0,d0
.end:
	move.w	d3,sr
	rts

.system_prt_char:
	;empiler d0 pour l'imprimer
	move.w	d0,-(sp)
;	bsr	save_for_trapd
;	move.w	#$11,-(sp)
;	trap	#1
;	addq.w	#2,sp
;	tst.w	d0
;	beq.s	.error
;	move.l	#$30000,-(sp)
;	trap	#13
;	addq.w	#6,sp
	move.w	#5,-(sp)
	trap	#1
	addq.w	#4,sp
;	move.w	d0,-(sp)
;	bsr	restore_for_trapd
;	move	(sp)+,d0
	;-1->0 et vice-versa
	not.l	d0
	rts
;.error:
;	bsr	restore_for_trapd
;	;depiler d0
;	tst.w	(sp)+
;	moveq	#-1,d0
;	rts

strobe_h:
	moveq	#14,d1
	bsr.s	lit_reg
	ori.b	#$20,d0
	moveq	#14,d1
	bsr.s	ecrit_reg
	rts

strobe_l:
	move	sr,-(sp)
	ori	#$700,sr
	moveq	#14,d1
	bsr.s	lit_reg
	andi.b	#$df,d0
	moveq	#14,d1
	bsr.s	ecrit_reg
	move	(sp)+,sr
	rts

lit_reg:
	move	sr,-(sp)
	ori	#$700,sr
	lea	$ff8800,a0
	move.b	d1,(a0)
	moveq	#0,d0
	move.b	(a0),d0
	move	(sp)+,sr
	rts

ecrit_reg:
	move	sr,-(sp)
	ori	#$700,sr
	lea	$ff8800,a0
	move.b	d1,(a0)
	move.b	d0,2(a0)
	moveq	#0,d0
	move.b	(a0),d0
	move	(sp)+,sr
	rts

strobenv:
	moveq	#7,d1
	bsr.s	lit_reg
	ori.b	#$40,d0
	;moveq	#7,d1
	bsr.s	ecrit_reg
	rts

busylec:
	lea	$fffa05,a0
	move.b	(a0),d0
	andi.b	#$fe,d0
	move.b	d0,(a0)
	rts

;	 #] Print instruction:
;	 #[ Print window cursor:

print_window_cursor:
 movem.l d0-d4/a0-a4,-(sp)
 cmp.l #RS232_OUTPUT,device_number(a6)
 bne.s .0
 move.l x_pos(a6),-(sp)
 move.l ex_cursor(a6),x_pos(a6)
 bsr poscur
 move.l (sp)+,x_pos(a6)
 movem.l (sp)+,d0-d4/a0-a4
 rts
.0:
 move.l physbase(a6),a3
 move.l a3,-(sp)
 move.w line_size(a6),d2
 move.w old_ex_cursor(a6),d0
 move.w old_ey_cursor(a6),d1
 bmi.s .new
 bsr.s .internal_pos
.new:
 move.l (sp)+,a3
 move.w line_size(a6),d2
 move.w ex_cursor(a6),d0
 move.w ey_cursor(a6),d1
 bsr.s .internal_pos
 move.l ex_cursor(a6),old_ex_cursor(a6)
 movem.l (sp)+,d0-d4/a0-a4
 rts
.internal_pos:
 lsl.w #4,d1
 tst.b meta_rez(a6)
 bne.s .1
 tst.b high_rez(a6)
 bne.s .1
 tst.b mid_rez(a6)
 bne.s .2
.3:
 add.w d0,d0
.2:
 add.w d0,d0
 lsr.w #1,d1
.1:
 tst.b c_line(a6)
 bne.s .4
 subq.w #4,d1
.4:
 mulu d2,d1
 add.l d1,a3
 add.w d0,a3
 move.w line_size(a6),d4
 moveq #1,d1
 bra print_character

;	 #] Print window cursor:
;	 #[ Print cursor:
;d0=y
;d1=x
print_cursor:
 movem.l d2-d3/a0-a1,-(sp)
 move.w #-1,old_ey_cursor(a6)
 move.w d0,ey_cursor(a6)
 move.w d1,ex_cursor(a6)
 st alt_e_flag(a6)
 bsr print_window_cursor
 sf alt_e_flag(a6)
 movem.l (sp)+,d2-d3/a0-a1
 rts

;	 #] Print cursor:
;  #] Screen functions:
;  #[ RS232 functions:
rs232_init:
	cmp.w	#_FALC,machine_type(a6)
	beq.s	.end
	lea	.datas(pc),a0
	move.l	rs232_speed(a6),d0
	and.l	#$f,d0
	move.b	0(a0,d0.w),d1	;DAT
	lea	.conts(pc),a0
	move.b	0(a0,d0.w),d2	;CONTROL
	lea	$fffa01,a1
	clr.b	42(a1)
	clr.b	44(a1)
	and.b	#$ef,20(a1)
	and.b	#$ef,8(a1)
	and.b	#$ef,12(a1)
	and.b	#$ef,16(a1)
	and.b	#$f8,$1c(a1)
.label:	move.b	d1,$24(a1)
	cmp.b	$24(a1),d1
	bne.s	.label
	or.b	d2,$1c(a1)
	move.l	rs232_parity(a6),d0
	move.b	d0,40(a1)
	move.b	#1,42(a1)
	move.b	#1,44(a1)
	moveq	#-1,d0
.waitset:
	dbf	d0,.waitset
.end:	rts
.datas:	dc.b 1,2,4,5,8,10,11,16,32,64,96,128,143,175,64,96
.conts: dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2
	even
;  #] RS232 functions:
;		#[ Atari_init:
	 ;#[ Get machine type:
get_machine_type:
	move.l	#32256+1024,screen_size(a6)	;default=ST
	lea	_get_machine(pc),a0
	_JMP	supexec
_get_machine:
	move.l	$4f2.w,a0
	move.l	a0,_sysbase(a6)
	move.w	2(a0),d0
	move.w	d0,osnumber(a6)
	cmpi.w	#$104,d0		;if < 1.04 don't check cookies
	blt.s	.st
	move.l	$5a0.w,d0
	beq.s	.st
	move.l	d0,a0
	move.l	#'_MCH',d0
.l1:	move.l	(a0)+,d1
	beq.s	.st
	cmp.l	d1,d0
	beq.s	.this1
	addq.w	#4,a0
	bra.s	.l1
.this1:	move.l	(a0),d0		;ST, Mega ST, STacy
	beq.s	.st
	cmp.l	#$10000,d0	;STe
	beq.s	.ste
	cmp.l	#$10010,d0	;Mega STe
	beq.s	.mste
	cmp.l	#$20000,d0	;TT030
	beq.s	.tt
	cmp.l	#$30000,d0	;Falcon 30 rev 3-4+
	beq.s	.fa
	cmp.l	#$10100,d0	;Sparrow rev 1-2
	beq.s	.fa
	cmp.l	#$10001,d0	;ST Book
	beq.s	.nb
	clr.w	machine_type(a6)	;unknown is as ST
	moveq	#10,d1
	bra.s	.asmch
.st:	clr.w	d1
	bra.s	.setmch
.ste:	moveq	#_STE,d1
	bra.s	.setmch
.mste:	move.w	#_STE,machine_type(a6)
	moveq	#_MSTE,d1
	bra.s	.asmch
.tt:	move.l	#150*1024+1024,screen_size(a6)	;default=TT MONO
	moveq	#_TT,d1
	bra.s	.setmch
.fa:	moveq	#_FALC,d1
	bra.s	.setmch
.nb:	moveq	#_NB,d1
;	bra.s	.setmch
.setmch:	move.w	d1,machine_type(a6)
.asmch:	lea	mch_fmt_txt(pc),a0
	move.l	a0,a1
	add.w	.txttab(pc,d1.w),a1
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	lea	mch_name_buf(a6),a0
	bsr	sprintf3
	addq.w	#8,sp
	move.l	$5a0.w,d0
	beq.s	.nomint
	move.l	d0,a0
	move.l	#'MiNT',d0
.l2:	move.l	(a0)+,d1
	beq.s	.nomint
	cmp.l	d1,d0
	beq.s	.this2
	addq.w	#4,a0
	bra.s	.l2
.this2:	move.l	(a0),mint_vers(a6)
.nomint:
.end:	rts
.txttab:	dc.w	st_txt-mch_fmt_txt
	dc.w	ste_txt-mch_fmt_txt
	dc.w	tt_txt-mch_fmt_txt
	dc.w	fa_txt-mch_fmt_txt
	dc.w	nb_txt-mch_fmt_txt
	dc.w	un_txt-mch_fmt_txt
	dc.w	mste_txt-mch_fmt_txt
	 ;#] Get machine type:
;Prior calling fixwinds, windows are 80*25.
;In: d0.l=initial internal rez
fixwinds:	move.w	machine_type(a6),d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.nb-.tab
.fa:	andi.w	#%110000,d0		;PAL+VGA
	move.w	d0,monmask(a6)
	move.w	montype(a6),d1
	beq.s	.high			;High
	subq.w	#2,d1
	beq.s	.high			;VGA
	bra.s	.med			;RVB
.st:
.ste:	tst.b	d0			;low
	beq.s	.low
	cmp.b	#1,d0			;med
	beq.s	.med
.high:	bra	put_640_400
.low:	;jsr	switch_windows
.med:	bra	put_640_200
.tt:	tst.b	d0			;not low
	bne.s	.ifmeta
	jsr	switch_windows
	bra	put_640_400
.ifmeta:	cmp.b	#%110,d0
	bne.s	.high
	bsr	put_1280_960		;meta
	jmp	switch_windows
.nb:	bra	put_640_400

machine_init:
	IFEQ	accessoire
	move.l	a5,p0_basepage_addr(a6)
	ELSEIF
	jsr	create_false_basepage
	ENDC	;d'accessoire
	bsr	rom_init
	lea	$118.w,a0
	move.l	(a0),initial_kbdvec(a6)
	move.l	(a0),external_kbdvec(a6)
	lea	$80+4*13.w,a0
	move.l	(a0),initial_trap13(a6)
	move.l	(a0),external_trap13(a6)
	lea	$84.w,a0
	move.l	(a0),initial_trap1(a6)
	move.l	(a0),external_trap1(a6)
	move.l	$404.w,initial_etvcritic(a6)

	lea	initial_buffer(a6),a0
	bsr	ram_init
	move.l	$44e.w,logbase(a6)
	bsr	timers_init

;	cmp.w	#_FALC,machine_type(a6)
;	bne.s	.novid
;	lea	external_video(a6),a0
;	bsr	vgetvid
;.novid:
	move.l	#SCREEN_OUTPUT,device_number(a6)
	bsr	set_windows

	move.b	initial_frequency(a6),internal_frequency(a6)
	move.l	#$0000ffff,internal_palette(a6)

	move.w	initial_rez(a6),d0
;	jsr	torezflag
	bsr	fixwinds
	bsr	install_my_vbl
	IFEQ	bridos!accessoire
	bsr	machine_cmd_line
	ENDC	; de bridos
	rts

machine_cmd_line:
	IFNE	cartouche
	tst.b	crdebug_flag(a6)
	bne.s	.end
	ENDC	; de cartouche
	move.l	p0_basepage_addr(a6),a0
	lea	$80(a0),a2
;	move.l	$2c(a0),d0
;	beq.s	.no_envp
;	move.l	d0,a1
;.l0:	cmp.b	#'A',(a1)+
;	bne.s	.next
;	cmp.b	#'R',(a1)+
;	bne.s	.next
;	cmp.b	#'G',(a1)+
;	bne.s	.next
;	cmp.b	#'V',(a1)+
;	bne.s	.next
;	cmp.b	#'=',(a1)+
;	bne.s	.next
;	;CCCPPCC???????
;.l4:	tst.b	(a1)+
;	bne.s	.l4
;	;nom du programme en cours d'exec
;.l5:	tst.b	(a1)+
;	bne.s	.l5
;	;ligne de com
;	move.l	a1,a0
;	bsr	strlen3
;	bra.s	.as_cmd_line
;.next:	tst.b	(a1)+
;	bne.s	.next
;	tst.b	(a1)
;	bne.s	.l0
;.no_envp:
	move.l	a2,a0
	moveq	#0,d0
	move.b	(a0)+,d0
.as_cmd_line:
	move.w	d0,argc(a6)
	lea	argv_buffer(a6),a1
	subq.w	#1,d0
	bmi.s	.no
.l1:	move.b	(a0)+,(a1)+
	dbf	d0,.l1
.no:	clr.b	(a1)
	;puis clearer dans la basepage
;.clr_basepage:
	moveq	#80-1,d0
.l3:	clr.b	(a2)+
	dbf	d0,.l3
.end:	rts

ram_init:	move.l	a0,a2
	;jsr	get_vbr
	move.l	$2c.w,(a2)+	;linef
	move.l	$88.w,(a2)+	;trap2
	move.l	line_a_basepage(a6),a0
	move.w	(a0),(a2)+	;planes
	move.w	-12(a0),(a2)+	;max_x
	move.w	-44(a0),(a2)+	;max_cell_x
	lea	$ff8201,a0
	movep.w	(a0),d0
	lsl.l	#8,d0
	move.l	d0,(a2)+		;logbase

	move.l	a2,a0
	moveq	#16,d0
	bsr	vgetrgb
	lea	16*4(a2),a2	;skip palette

	move.w	machine_type(a6),d0
	move.w	.tab(pc,d0.w),d0
	jmp	.tab(pc,d0.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.nb-.tab
.fa:	bsr	vgetmode
	move.w	d0,(a2)+
	move.l	a2,a0
	bsr	vgetvid
	bra.s	.freq
.st:
.ste:	move.b	$ffff8260.w,d0
	andi.w	#%11,d0
	bra.s	.rez
.tt:	move.b	$ff8262,d0
	andi.w	#$ff,d0
	bra.s	.rez
.nb:	moveq	#%10,d0		;set to high res
.rez:	move.w	d0,(a2)+		;reso
.freq:	lea	VIDEO_SIZE(a2),a2
	move.b	$ff820a,(a2)+	;freq
	move.b	$484.w,(a2)+	;keyconf
	rts

ram_exit:	move.l	a0,a2
	;jsr	getvbr
	move.l	(a2)+,$2c.w
	move.l	(a2)+,$88.w
	move.l	line_a_basepage(a6),a0
	move.w	(a2)+,(a0)
	move.w	(a2)+,-12(a0)
	move.w	(a2)+,-44(a0)
	move.l	(a2)+,d0
	move.l	d0,logbase(a6)
	move.l	d0,$44e.w
	move.l	a2,a0
	moveq	#16,d0
	bsr	vsetrgb
	move.l	(a2),external_palette(a6)

	move.w	machine_type(a6),d0
	move.w	.tab(pc,d0.w),d0
	jmp	.tab(pc,d0.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.nb-.tab
.fa:	move.l	4(a2),external_palette+4(a6)
	bra.s	.rez
.st:
.ste:
.tt:
.nb:
.rez:	lea	16*4(a2),a2
	move.w	(a2)+,d0
	move.w	d0,external_rez(a6)
	cmp.w	#_STE,machine_type(a6)
	bgt.s	.nolog
	move.b	d0,$44c.w
.nolog:	lea	external_video(a6),a0
	moveq	#VIDEO_SIZE/2-1,d0
.l1:	move.w	(a2)+,(a0)+
	dbf	d0,.l1

	move.b	(a2)+,$ff820a
	move.b	(a2),$484.w
	rts

;	IFNE	ATARITT
;	tst.w	machine_type(a6)
;	beq.s	.st_colour
;	lea	$ff8400,a0
;	moveq	#256/2-1,d0
;.l1:	move.l	(a2)+,(a0)+
;	dbf	d0,.l1
;.st_colour:
;	ENDC

;setscreen:
;	move.l	a2,-(sp)
;	move.w	d0,-(sp)
;	pea	-1.w
;	move.l	(sp),-(sp)
;	move.w	#5,-(sp)
;	trap	#14
;	lea	12(sp),sp
;	move.l	(sp)+,a2
;	rts

rom_init:	;header
	move.l	_sysbase(a6),a0
	move.l	40(a0),tos_p0_basepage_addr(a6)
	move.l	36(a0),a0
	cmp.w	#$0100,osnumber(a6)
	bne.s	.done1
	move.w	#$22,-(sp)
	trap	#$e
	addq.w	#2,sp
	move.w	d0,a0
	lea	$4f(a0),a0
.done1:	move.l	a0,kbshift_addr(a6)
	lea	30(a0),a0
	move.l	a0,external_repeat_addr(a6)
	;keyboard ascii maps
	pea	-1.w
	move.l	(sp),-(sp)
	move.l	(sp),-(sp)
	move.w	#16,-(sp)
	trap	#14
	lea	14(sp),sp
	lea	keytbl_descriptor(a6),a0
	move.l	a0,keytbl_addr(a6)
	move.l	d0,a1
	move.l	(a1),keys_table1(a6)
	move.l	(a1)+,(a0)+
	move.l	(a1),keys_table2(a6)
	move.l	(a1)+,(a0)+
	move.l	(a1),keys_table3(a6)
	move.l	(a1),(a0)

	cmp.w	#_FALC,machine_type(a6)
	bne.s	.notfalc
	move.w	#$59,-(sp)		;mon_type
	trap	#14
	addq.w	#2,sp
	move.w	d0,montype(a6)
.notfalc:	;line A base addr
	dc.w	$a000
	move.l	a0,line_a_basepage(a6)
	move.l	4(a1),a2
	cmp.w	#$100,osnumber(a6)
	bne.s	.done2
	move.l	84(a2),d0
	subq.l	#6,d0
	move.l	d0,tos_p0_basepage_addr(a6)
.done2:	;fonts addr
	move.l	76(a2),font8x8_addr(a6)
	move.l	8(a1),a2
	move.l	76(a2),font8x16_addr(a6)

	; line F special opcode
	;TOS 1.4 avril 89
	move.w	#$f768,internal_trap2_return_opcode(a6)
	;TOS 1.4 fevrier 89
;	move.w	#$f764,internal_trap2_return_opcode(a6)
	rts
;		#] Atari_init:
;		#[ Set_windows:
set_windows:
	lea	w1_db(a6),a0
	moveq	#4,d0
	move.w	d0,a2
	move.l	(a2),d0
	move.w	#$ff00,d1
	moveq	#1,d2
	swap	d2
	bset	#0,d2
	moveq	#2,d3

	;fenetre 1
	move.l	d2,(a0)+			; high
	move.l	d2,96-4(a0)			; low
	move.l	d2,192-4(a0)		; meta
	move.l	#$004f000b,(a0)+		; high
	move.l	#$0027000b,96-4(a0)		; low
	move.l	#$009f0018,192-4(a0)		; meta
	move.w	d1,(a0)+			; high
	move.w	d1,96-2(a0)			; low
	move.w	d1,192-2(a0)		; meta
	move.l	d0,(a0)+			; high
	move.l	d0,96-4(a0)			; low
	move.l	d0,192-4(a0)		; meta
	clr.w	(a0)+			; high
	clr.w	96-2(a0)			; low
	clr.w	192-2(a0)			; meta

	move.l	#$0001000c,(a0)+		; high
	move.l	#$0001000c,96-4(a0)		; low
	move.l	#$00010019,192-4(a0)		; meta
	move.l	#$0033000d,(a0)+		; high
	move.l	#$00270008,96-4(a0)		; low
	move.l	#$006b0023,192-4(a0)		; meta
	move.w	#$ffff,(a0)+		; high
	move.w	#$ffff,96-2(a0)		; low
	move.w	#$ffff,192-2(a0)		; meta
	move.l	d0,(a0)+			; high
	move.l	d0,96-4(a0)			; low
	move.l	d0,192-4(a0)		; meta
	move.w	d2,(a0)+			; high
	move.w	d2,96-2(a0)			; low
	move.w	d2,192-2(a0)		; meta

	move.l	#$0035000c,(a0)+		; high
	move.l	#$00010014,96-4(a0)		; low
	move.l	#$006d0019,192-4(a0)		; meta
	move.l	#$004f000d,(a0)+		; high
	move.l	#$00270005,96-4(a0)		; low
	move.l	#$009f0023,192-4(a0)		; meta
	move.w	d1,(a0)+			; high
	move.w	d1,96-2(a0)			; low
	move.w	d1,192-2(a0)		; meta
	move.l	d0,(a0)+			; high
	move.l	d0,96-4(a0)			; low
	move.l	d0,192-4(a0)		; meta
	move.w	d3,(a0)+			; high
	move.w	d3,96-2(a0)			; low
	move.w	d3,192-2(a0)		; meta

	move.l	#$00010013,(a0)+		; high
					; low
	move.l	#$0001002c,192-4(a0)		; meta
	move.l	#$00330006,(a0)+		; high
					; low
	move.l	#$006b0010,192-4(a0)		; meta
	clr.w	(a0)+			; high
					; low
	clr.w	192-2(a0)			; meta
	move.l	d0,(a0)+			; high
					; low
	move.l	d0,192-4(a0)		; meta
	move.w	d2,(a0)+			; high
					; low
	move.w	d2,192-2(a0)		; meta

	move.l	#$00350013,(a0)+		; high
					; low
	move.l	#$006d002c,192-4(a0)		; meta
	move.l	#$004f0006,(a0)+		; high
					; low
	move.l	#$009f0010,192-4(a0)		; meta
	clr.w	(a0)+			; high
					; low
	clr.w	192-2(a0)			; meta
	move.l	d0,(a0)+			; high
					; low
	move.l	d0,192-4(a0)		; meta
	move.w	d3,(a0)+			; high
					; low
	move.w	d3,192-2(a0)		; meta

	move.l	d2,(a0)+			; high
	move.l	d2,96-4(a0)		; low
	move.l	d2,192-4(a0)		; meta
	move.l	#$004f0018,(a0)+		; high
	move.l	#$00270018,96-4(a0)		; low
	move.l	#$009f003b,192-4(a0)	; meta
	clr.l	(a0)+			; high
	clr.l	96-4(a0)			; low
	clr.l	192-4(a0)			; meta
	add.w	a2,a2
	move.l	a2,(a0)+			; high
	move.l	a2,96-4(a0)		; low
	move.l	a2,192-4(a0)		; meta
	move.l	d2,big_window_coords(a6)
	rts
;		#] Set_windows:
;	 #[ p1 registers init:
p1_registers_init:
	lea	d0_buf(a6),a0
	moveq	#8+4-1,d0
.l1:	clr.l	(a0)+
	dbf	d0,.l1
	move.l	text_buf(a6),d0
	move.l	d0,pc_buf(a6)
	move.l	d0,a6_buf(a6)
	move.l	data_buf(a6),a5_buf(a6)
	move.l	bss_buf(a6),a4_buf(a6)
	move.w	#$310,sr_buf(a6)
	move.l	internal_usp(a6),a7_buf(a6)
	move.l	initial_ssp(a6),d0
	move.l	d0,ssp_buf(a6)
	IFNE	_68030
	move.l	d0,isp_buf(a6)
	tst.b	chip_type(a6)
	beq.s	.68000
	_30
	movec	sfc,d0
	move.w	d0,sfc_buf(a6)
	movec	dfc,d0
	move.w	d0,dfc_buf(a6)
	movec	cacr,d0
	move.l	d0,cacr_buf(a6)
	movec	vbr,d0
	move.l	d0,vbr_buf(a6)
	movec	caar,d0
	move.l	d0,caar_buf(a6)
	movec	msp,d0
	move.l	d0,msp_buf(a6)
;	movec	isp,d0
;	move.l	d0,isp_buf(a6)
	lea	crp_buf(a6),a0
	dc.w	$f010,$4e00	;pmove.d	crp,(a0)
	addq.w	#8,a0
	dc.w	$f010,$4e00	;pmove.d	crp,(a0)	;pour l'instant crp->srp
	addq.w	#8,a0
	dc.w	$f010,$4200	;pmove.l	tc,(a0)
	addq.w	#4,a0
	dc.w	$f010,$0a00	;pmove.l	tt0,(a0)
	addq.w	#4,a0
	dc.w	$f010,$0e00	;pmove.l	tt1,(a0)
	addq.w	#4,a0
	dc.w	$f010,$6200	;pmove.w	mmusr,(a0)
	tst.b	fpu_type(a6)
	beq.s	.no_fpu
	addq.w	#2,a0
	dc.w	$f210,$f0ff	;fmovem.x	fp0-fp7,(a0)
	lea	8*3*4(a0),a0
	dc.w	$f210,$bc00	;fmovem.l	fpcr/fpsr/fpiar,(a0)
	_00
.no_fpu:
.68000:
	ENDC
	rts
;	 #] p1 registers init:
;	 #[ update_ro:
;In:
;d0=process #
;a0=process loaded @
;Out:
;d0=ro size to reserve
update_ro:
;d0=taille du fichier
;d1=process #
;a0=process loaded @
;a1=process header @
;a2=process header sizes
	move.l	a5,-(sp)
	move.l	a0,a5
	;passer le header
	lea	$1c(a5),a0
	;buffer de header temporaire
	lea	ro_header_addresses(a6),a1
	;passer 601a
	lea	2(a5),a2
	bsr	relocate_dri
	;passer 601a
	lea	2(a5),a0
	move.l	(a0)+,d0
	add.l	(a0)+,d0
	add.l	(a0)+,d0
	add.l	(a0),d0
	add.l	#$1c,d0
	move.l	(sp)+,a5
	rts
;	 #] update_ro:
;	 #[ Relocate dri:
;--- INPUT ---
;d0=process #
;a0=process text @
;a1=process header @
;a2=process header sizes

;--- IN ---
;d3=
;d7=process #
;a2=sauvegarde de l'@ de la table de reloc pour le clr
;a3=process header @
;a4=process header sizes
	;text size.l @.l
	;data size.l @
	;bss size.l @
	;sym size.l @
;a5=process text @

;--- OUTPUT ---
;d0=0 si ca s'est bien passe,-1 sinon

relocate_dri:
	movem.l	d6-d7/a2-a5,-(sp)

	move.l	d0,d7
	move.l	a0,a5
	move.l	a2,a4
	move.l	a1,a3

	;text
	move.l	(a4),d0
	;data
	add.l	4(a4),d0
	;sym
	move.l	12(a4),d1
	bmi.s	.suite
	beq.s	.suite
	add.l	d1,d0
.suite:	btst	#0,d0
	bne.s	.error
	lea	0(a5,d0.l),a0
	move.l	a0,a2

	moveq	#0,d1
	tst.l	(a0)+				;a0=@ debut table de reloc
	beq.s	.no_more_reloc			;pas de reloc
	move.l	a5,d3
	add.l	-4(a0),d1			;premier offset de reloc
	move.l	d1,a1
	add.l	a5,a1
	cmp.l	a5,a1
	blt.s	.error
	cmp.l	a0,a1
	bge.s	.error
.l1:	btst	#0,d1
	bne.s	.error
	add.l	d3,0(a5,d1.l)
.l2:	move.b	(a0)+,d0
	beq.s	.no_more_reloc
	cmpi.b	#1,d0
	beq.s	.overflow
	andi.l	#$ff,d0
	add.l	d0,d1
	bra.s	.l1
.overflow:
	add.l	#254,d1
	bra.s	.l2
.error:	moveq	#-1,d6
	bra.s	.end
.no_more_reloc:
	moveq	#0,d6
.suite2:
	;vider la table de reloc
	move.l	a0,d0
	sub.l	a2,d0
	lsr.l	#2,d0
	subq.l	#1,d0
.l3:
	clr.l	(a2)+
	dbf	d0,.l3

.end:	move.l	d6,d0
	movem.l	(sp)+,d6-d7/a2-a5
	rts

;	 #] Relocate dri:
;	 #[ Vbl stuff:
		;#[ Install my vbl:
install_my_vbl:
	move.w	$454.w,d0
	subq.w	#2,d0
	move.l	$456.w,a0
	addq.w	#4,a0
	move.l	#VBL_MAGIC,d2
.l1:
	move.l	(a0)+,d1
	beq.s	.out
	move.l	d1,a1
	cmp.l	-(a1),d2
	bne.s	.ddbbff
	cmp.l	#ADEBUG_MAGIC,-4(a1)
	bne.s	.ddbbff
	move.l	-4(a0),rdebug_vbl(a6)
	bra.s	.out
.ddbbff:
	dbf	d0,.l1
	bra.s	.error
.out:
	lea	my_vbl(pc),a1
	tst.l	-(a0)
	move.l	a0,my_vbl_addr(a6)
	move.l	a1,(a0)
.end:
	rts
.error:
	lea	vbl_error_text(pc),a2
	bra	print_error
		;#] Install my vbl:
		;#[ Deinstall my vbl:
deinstall_my_vbl:
	move.l	my_vbl_addr(a6),d0
	beq.s	.end
	move.l	d0,a0
	lea	my_vbl(pc),a1
	cmp.l	(a0),a1
	bne.s	.end
	move.l	rdebug_vbl(a6),d0
	beq.s	.clr
	move.l	d0,(a0)
	bra.s	.end
.clr:
	clr.l	(a0)
.end:
	IFNE	cartouche
	tst.b	crdebug_flag(a6)
	bne.s	.end_2
	; remettre l'ancien nombre de vblq
	move.w	external_vblq_nb(a6),d0
	cmp.w	#6,d0
	bne.s	.end_2
	move.w	d0,$454.w

	; remettre l'ancien a6
	move.l	external_cart_a6(a6),CARTRIDGE_SAVE.w

	; remettre le detournement du trap1
	lea	resident_trap1,a1
	jsr	get_vbr
	move.l	a1,$84(a0)
.end_2:
	ENDC
	rts
		;#] Deinstall my vbl:
		;#[ My vbl:
	SET_ID	VBL_MAGIC
my_vbl:
	GETA6
	IFNE	debug
	move.l	tos_p0_basepage_addr(a6),a0
	move.l	(a0),a0
	cmp.l	p0_basepage_addr(a6),a0
	beq.s	.no_bleme
	cmp.l	p1_basepage_addr(a6),a0
	beq.s	.no_bleme
	bsr	deinstall_my_vbl
	bra.s	.hardcopy
.no_bleme:
	ENDC
	;en mode trace permanent ?
	tst.b	permanent_trace_flag(a6)
	bne.s	.rien

	;interrupt break
;	lea	watchdog_buffer(a6),a0
;	tst.b	(a0)
;	beq.s	.nowatch
;	jsr	evaluate
;	cmp.l	#-1,d0
;	bne.s	.nowatch
;	clr.b	watchdog_buffer(a6)
;	bra.s	.stop
;.nowatch:
	;alt_help ?
	tst.w	$4ee.w
	bmi.s	.no_break

	;shift ? si non,hardcopy
	move.l	kbshift_addr(a6),a0
	btst	#1,(a0)
	beq.s	.hardcopy

	;plus de shift
	bclr	#1,(a0)
	;plus de alt
	bclr	#3,(a0)

	st	halted_flag(a6)

	;chez moi ?
	tst.b	p_number(a6)
	beq.s	.rien

	;plus de alt_help
	move.w	#-1,$4ee.w
.stop:
	;exception 0
	clr.b	exception(a6)
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	;stack frame 0
	clr.w	sf_type(a6)
.68000:
	ENDC
	;remettre la vblqueue
	addq.w	#1,$452.w
	lea	$c(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$2700,sr
	SWITCHA6
	sf	keys_byte(a6)
	bra	p1p0
.rien:
	move.w	#-1,$4ee.w
.hardcopy:
	rts
.no_break:
	tst.b	p_number(a6)	;chez moi ?
	beq.s	.no_var_tree
	tst.b	valid_var_tree_flag(a6)
	beq.s	.no_var_tree
	move.l	74(sp),a1
	tst.b	unclip_profile_flag(a6)
	bne.s	.in_clip
	cmp.l	text_buf(a6),a1
	blt.s	.not_in_clip
	cmp.l	end_buf(a6),a1
	bge.s	.not_in_clip
.in_clip:	move.l	var_tree_nb(a6),d0
	move.l	var_tree_addr(a6),d1
	lea	comp_var_tree_2,a0
	jsr	_trouve
	bmi.s	.no_var_tree
	addq.l	#1,VAR_TREE_COUNT(a0)
.not_in_clip:
.no_var_tree:
	rts
		;#] My vbl:
;	 #] Vbl stuff:
	IFEQ	bridos
	IFEQ	residant
;	 #[ get_cmd_line:
;ds a0 la ligne de cmd
get_cmd_line:
	;analyse et recopie de la ligne de commande
	lea	argv_buffer(a6),a2
	;nb de chars
	moveq	#0,d7
	;nom du fichier a charger
	lea	exec_name_buf(a6),a1
.l1:
	move.b	(a0)+,d0
	beq.s	.eol
	cmp.b	#13,d0
	beq.s	.eol
	cmp.b	#10,d0
	beq.s	.eol
	cmp.b	#' ',d0
	beq.s	.cmd_line
	move.b	d0,(a1)+
	bra.s	.l1
.eol:
	clr.b	(a1)
	clr.b	(a2)
	bra.s	.no_cmd_line
.cmd_line:
	move.l	a2,a1
	clr.b	(a1)
.l2:
	move.b	(a0)+,d0
	beq.s	.eol2
	cmp.b	#13,d0
	beq.s	.eol2
	cmp.b	#10,d0
	beq.s	.eol2
	addq.l	#1,d7
	move.b	d0,(a1)+
	bra.s	.l2
.eol2:
	clr.b	(a1)
.no_cmd_line:
.end:
	;puis argc
	move.w	d7,argc(a6)
	rts
;	 #] get_cmd_line:
;  #[ _load_prg:
;Input
;dans les buffers exec_name_buf,argv_buffer
;dans la variable argc
;In:
;d7=error nb
;-1=open error (file not found)
;-2=read error
;-3=executable error
;-4=memory error
;d4=handle
;Output:
;dans le buffer exec_name_buf
;d0=erreur
_load_prg:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,a5
	moveq	#0,d7	; no error
	bsr	get_exec_name
	bmi	.ropen
	bsr	prepare_tos
	move.l	a5,a0
	bsr	open_header
	move.l	a1,a3
	move.l	d1,d4
	addq.w	#1,d0
	beq	.ropen
	addq.w	#1,d0
	beq	.rread
	addq.w	#1,d0
	beq	.rexec
	;updater les tailles internes a partir du header
	move.l	a3,a0
	bsr	update_header_sizes
	IFNE	turbodebug
	tst.l	p1_dri_len(a6)
	beq.s	.not_tc_source
	move.l	d4,d0
	bsr	tcget_debug_file_info
	bne.s	.not_pc_source
.not_tc_source:
	move.l	d4,d0
	bsr	pcget_debug_file_info
.not_pc_source:
	ENDC
;--------------------------------------
	bsr	reserve_for_p1
	beq	.rmem
	move.l	d0,p1_basepage_addr(a6)
	;lire le prg
	move.l	d0,a0
	lea	$100(a0),a0	;+$100 pour la basepage
	move.l	p1_disk_len(a6),d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	p1_disk_len(a6),d0
	bne	.rread
;--------------------------------------
	move.l	d4,d0
	bsr	close_file

	move.l	p1_basepage_addr(a6),a5
	lea	text_buf(a6),a4
	lea	text_size(a6),a3

	;updater les adresses internes a partir des tailles internes
;a0=process text @
;a1=process header @
;a2=process header sizes
	lea	$100(a5),a0
	move.l	a4,a1
	move.l	a3,a2
	bsr	update_header_addresses
;--------------------------------------
	move.l	a4,a1		;reloger le prog
	move.l	a3,a2
	lea	$100(a5),a0
	move.l	p1_disk_len(a6),d0
	bsr	reloc_exec

	move.l	a5,a0		;construire la basepage
	move.l	a3,a1
	move.l	a4,a2
	bsr	build_basepage
	move.l	a5,a0		;detourner la fin de process
	bsr	install_recup_process
	bsr	p1_registers_init	;initialiser les registres au depart
;--------------------------------------
	bsr	update_text_data_bss	;updater les variables 680xxesques constantes
	move.l	bss_buf(a6),a0	;updater les symboles
	bsr	get_exec_symbols
	bsr	create_var_tree
;--------------------------------------
	bsr	clr_bss
	bsr	tell_residant
	IFNE	sourcedebug
	bsr	begin_source_debug	;updater le source
	ENDC
	bra.s	.end
.ropen:	moveq	#-1,d7
	lea	higher_level_buffer(a6),a2
	move.l	a5,-(sp)
	pea	fnf_error_text
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_error	;no close
	bra.s	.end
.rread:	moveq	#-2,d7
	not.l	d0
	lea	higher_level_buffer(a6),a2
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	pea	read_error_text
	move.l	a2,a0
	bsr	sprintf3
	lea	10(sp),sp
	bra.s	.print
.rexec:	moveq	#-3,d7
	lea	executable_error_text,a2
	bra.s	.print
.rmem:	moveq	#-4,d7
	lea	memory_error_text,a2
;	bra.s	.print
.print:	bsr	print_error
	move.l	d4,d0		;fermer	le fichier
	bsr	close_file
.end:	move.l	d7,d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;  #] _load_prg:
	; #[ Recup reset:
	SET_ID	RESET_MAGIC
recup_reset:
	move	#$2700,sr
	SWITCHA6
;	lea	pterm_stack+500(a6),sp
;	movem.l	d0-d1,-(sp)
;	moveq	#7,d0
;	moveq	#-1,d1
;	bsr	put_internal_sr
;	movem.l	(sp)+,d0-d1
	move.l	ssp_buf(a6),sp
	subq.w	#6,sp
	move.w	sr_buf(a6),(sp)
	move.l	pc_buf(a6),2(sp)
	st	exception(a6)
	bra	p1p0
	; #] Recup reset:
	ENDC	;de residant
;	 #[ get_exec_name:
get_exec_name:
	movem.l	d5/a2-a5,-(sp)
	;fsfirst pour existence+taille
	move.l	a0,a5
;	tst.b	(a5)
;	beq	.end2
	move.l	a5,a0
	moveq	#0,d0
	jsr	find_file
	beq.s	.found
	tst.w	_404_error(a6)
	bne	.not_found

	move.l	a5,a0
	jsr	strlen
	lea	0(a0,d0.w),a0
	move.l	a0,a1
	moveq	#0,d0
.l1:
	cmp.l	a5,a0
	ble.s	.eon
	move.b	-(a0),d1
	cmp.b	#'.',d1
	beq.s	.point
	cmp.b	#DIRECTORY_SEPARATOR,d1
	beq.s	.eon
	cmp.b	#':',d1
	beq.s	.eon
	bra.s	.l1
.eon:	move.l	a1,a0
.point:	move.l	a0,a4
	moveq	#5-1,d5
	lea	prg_text,a3
.l2:	move.l	a4,a0
.l3:	move.b	(a3)+,(a0)+
	bne.s	.l3

	move.l	a5,a0
	moveq	#0,d0
	jsr	find_file
	beq.s	.found
	dbf	d5,.l2
	clr.b	(a4)
.not_found:
	moveq	#-1,d0
	bra.s	.end
.found:	move.l	my_dta+DTA_TIME(a6),exec_timestamp(a6)
	lea	my_dta+DTA_NAME(a6),a0
.l4:	move.b	(a0)+,(a5)+
	bne.s	.l4
	moveq	#0,d0
.end:	movem.l	(sp)+,d5/a2-a5
	rts
;	 #] get_exec_name:
;	 #[ open_header:
;Out:
;d0=0 or error (-1/-2/-3)
;d1=d4=handle
;a1=a3=header
;a0=a5=dta_name
open_header:
	movem.l	d4/a2-a5,-(sp)
	move.l	a0,a5
	lea	my_dta(a6),a0
	move.l	DTA_SIZE(a0),d0	;recuperos la taille pour le fread
	subi.l	#$1c,d0
	bclr	#0,d0
	move.l	d0,p1_disk_len(a6)

	move.l	a5,a0
	bsr	open_file		;open
	bmi	.ropen
	move.l	d0,d4

	move.l	a5,-(sp)
	pea	loading_file_text
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_result

	lea	my_header(a6),a3	;lire le header
	move.l	a3,a0
	moveq	#$1c,d0
	move.l	d4,d1
	bsr	read_file
	moveq	#$1c,d1
	cmp.l	d1,d0
	bne.s	.rread

	cmpi.w	#$601a,(a3)
	bne.s	.rexec
	moveq	#0,d0
.end:	move.l	d4,d1
	move.l	a5,a0
	move.l	a3,a1
	tst.l	d0
	movem.l	(sp)+,d4/a2-a5
	rts
.ropen:	moveq	#-1,d0
	bra.s	.end
.rread:	moveq	#-2,d0
	bra.s	.end
.rexec:	moveq	#-3,d0
	bra.s	.end
;	 #] open_header:
;	 #[ reloc_exec:
reloc_exec:
	;precaution
	clr.l	0(a0,d0.l)

	;tester le type de symboles
	cmp.w	#EXEC_LINK,exec_type(a6)
	beq.s	.reloc_link
	bsr	relocate_dri
	bra.s	.end_reloc
.reloc_link:
	cmp.w	#RELOC_DRI,reloc_type(a6)
	bne.s	.no_reloc_link_dri
	bsr	relocate_link_dri
	bra.s	.end_reloc
.no_reloc_link_dri:
	cmp.w	#RELOC_GST,reloc_type(a6)
	bne.s	.no_reloc_link_gst
	bsr	relocate_link_gst
.no_reloc_link_gst:
.end_reloc:
	beq.s	.end
	lea	reloc_error_text,a2
	bsr	print_press_key
.end:
	rts
;	 #] reloc_exec:
;	 #[ get_exec_symbols:
;In:
;a0=symbol table @
get_exec_symbols:
	bsr	update_drih_source
	tst.l	d0
	beq.s	.no_err
	lea	unknown_sym_error_text,a2
	bsr	print_press_key
.no_err:
	rts
;	 #] get_exec_symbols:
;	 #[ tell_residant:
tell_residant:
	;si ATARI, prevenir Rdebug d'empiler
	jsr	get_vbr
	move.l	$84(a0),a0
	cmp.l	#RESIDANT_TRAP1_MAGIC,-(a0)
	bne.s	.no_rdebug
	cmp.l	#ADEBUG_MAGIC,-(a0)
	bne.s	.no_rdebug
	cmp.l	#BRAINSTORM_MAGIC,-(a0)
	bne.s	.no_rdebug
	move.w	#1,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	addq.w	#4,sp
.no_rdebug:
	rts
;	 #] tell_residant:
;	 #[ prepare_tos:
prepare_tos:
	;rechercher si .tos ou .ttp pour clearer l'ecran
	lea	my_dta+DTA_NAME(a6),a0
	jsr	strlen
	lea	0(a0,d0.w),a1
	move.l	a1,a2
	moveq	#'.',d0
	cmpa.l	a0,a1
	ble	.end
.l1:
	cmp.b	-(a1),d0
	bne.s	.l1
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0
	cmp.l	#'.TOS',d0
	beq.s	.cls
	cmp.l	#'.TTP',d0
	bne.s	.end
.cls:
	;cacher la souris
	dc.w	$a00a
	;effacer l'ecran et allumer le curseur
	lea	cls_vt52_string,a0
	jsr	system_print
.end:
	rts
;	 #] prepare_tos:
;	 #[ clr_bss:
;tenir compte du champ clr_bss du header
clr_bss:
	move.l	bss_size(a6),d0
	beq.s	.end
	lsr.l	#1,d0
	move.l	bss_buf(a6),d1
	addq.l	#1,d1
	bclr	#0,d1
	move.l	d1,a0
.l2:
	clr.w	(a0)+
	subq.l	#1,d0
	bne.s	.l2
.end:
	rts
;	 #] clr_bss:
;	 #[ reserve_for_p1:
reserve_for_p1:
	moveq	#0,d0		;tenir compte des bits du header
	jsr	get_free_memory
	subi.l	#$1000,d0
	cmp.l	p1_mem_len(a6),d0
	blt.s	.error
	cmp.l	p1_disk_len(a6),d0
	blt.s	.error
	st	d1		;allouer toute la memoire moins $1000 (pour la pile)
	moveq	#2,d2
	jsr	reserve_memory
	bne.s	.end
.error:	moveq	#0,d0
.end:	rts
;	 #] reserve_for_p1:
;	 #[ update_header_sizes:
;a0=@ du header source
update_header_sizes:
	lea	text_size(a6),a1
	move.l	2(a0),(a1)
	move.l	6(a0),4(a1)
	move.l	10(a0),8(a1)
	move.l	14(a0),12(a1)
	move.l	22(a0),d0
	bclr	#0,d0
	move.l	d0,p1_dri_len(a6)

	move.l	(a1),d0
	add.l	4(a1),d0
	;taille	sur disk (text + data)
	;taille	en memoire (text + data + bss)
	add.l	8(a1),d0
	;+basepage
	add.l	#$100,d0
	move.l	d0,p1_mem_len(a6)
	rts
;	 #] update_header_sizes:
;	 #[ update_text_data_bss:
update_text_data_bss:
	move.l	current_var_addr(a6),before_ctrll_addr(a6)

	;initialiser text data bss
	move.w	#'la',d0
	lea	text_text,a0
	move.l	text_buf(a6),a1
	bsr	put_in_table

	move.w	#'la',d0
	lea	data_text,a0
	move.l	data_buf(a6),a1
	bsr	put_in_table

	move.w	#'la',d0
	lea	bss_var_text,a0
	move.l	bss_buf(a6),a1
	bsr	put_in_table

	move.w	#'la',d0
	lea	end_text,a0
	move.l	bss_buf(a6),a1
	add.l	bss_size(a6),a1
	bsr	put_in_table

;	addq.l	#4,exec_sym_nb(a6)
	rts
;	 #] update_text_data_bss:
;	 #[ update_header_addresses:
;a0=process header @ (dest)
;a1=process header sizes
;a2=process text @
update_header_addresses:
	;text @
	move.l	a0,(a1)
	;text size
	add.l	(a2),a0
	;data @
	move.l	a0,4(a1)
	;data size
	add.l	4(a2),a0
	;bss @
	move.l	a0,8(a1)
	;bss size
	add.l	8(a2),a0
	;sym addr
	move.l	a0,12(a1)
	;end addr
	move.l	a0,16(a1)

	move.l	p1_mem_len(a6),d0
	add.l	p1_basepage_addr(a6),d0
	move.l	d0,p1_prg_end(a6)
	rts
;	 #] update_header_addresses:
;	 #[ relocate_link_dri:
;--- INPUT ---
;d0=process #
;a0=process text @
;a1=process header @
;a2=process header sizes

;--- IN ---
;d3=
;d7=process #
;a2=sauvegarde de l'@ de la table de reloc pour le clr
;a3=process header @
;a4=process header sizes
	;text size.l @.l
	;data size.l @
	;bss size.l @
	;sym size.l @
;a5=process text @

;--- OUTPUT ---
;d0=0 si ca s'est bien passe,-1 sinon

relocate_link_dri:
	moveq	#-1,d0
	rts
;	movem.l	d6-d7/a2-a5,-(sp)

;	move.l	d0,d7
;	move.l	a0,a5
;	move.l	a2,a4
;	move.l	a1,a3

;	;text
;	move.l	(a4),d0
;	;data
;	add.l	4(a4),d0
;	;sym obligatoire
;	move.l	12(a4),d1
;	bmi.s	.error
;	beq.s	.error
;	add.l	d1,d0

;	lea	(a5,d0.l),a0
;	move.l	a0,a2

;	;a0=@ debut table de reloc
;	;a5=@ debut process
;.again:
;	move.w	(a0)+,d0
;	;rien
;	beq.s	.rien
;	;opcode
;	cmp.w	#%111,d0
;	beq.s	.rien
;	;EQUR
;	btst	#4,d0
;	beq.s	.rien
;	;reloc
;	cmp.w	#%101,d0
;	bne.s	.rien

;.rien:
;	tst.w	(a5)+
;	bra.s	.again
;.error:
;	moveq	#-1,d6
;	bra.s	.suite2
;.no_more_reloc:
;	moveq	#0,d6
;.suite2:
;	;vider la table de reloc
;	move.l	a0,d0
;	sub.l	a2,d0
;	lsr.l	#2,d0
;	subq.l	#1,d0
;.l3:
;	clr.l	(a2)+
;	dbf	d0,.l3

;	move.l	d6,d0
;	movem.l	(sp)+,d6-d7/a2-a5

;	rts
;	 #] relocate_link_dri:
;	 #[ relocate_link_gst:
relocate_link_gst:
	moveq	#-1,d0
	rts
;	 #] relocate_link_gst:
;	 #[ update_drih_source:
;a0=@ basepage p1
update_drih_source:
	movem.l	d5-d7/a5,-(sp)
	lea	source_type(a6),a5
	move.w	(a5),-(sp)
	clr.w	(a5)
	lea	overwrite_var_flag(a6),a5
	move.b	(a5),-(sp)
	st	(a5)
	move.l	a0,a5
	move.l	sym_size(a6),d0		;tester table des symboles
	bmi	.nosym
	beq	.nosym
	btst	#0,d0
	bne	.nosym
;	cmp.l	#$30,d0
;	beq	.errtype
	;gestion table des symboles:
	move.l	text_buf(a6),d7		;@ de debut de texte
	move.l	data_buf(a6),d6		;@ de debut de data
	move.l	bss_buf(a6),d5		;@ de debut de bss
.next:	tst.b	(a5)			;1 label ?
	beq.s	.nosym
	move.l	a5,a0			;oui alors a0 pointe dessus
	addq.w	#8,a5
	move.b	(a5)+,d2			;type de symbole
	move.b	(a5)+,d0			;particulier ?
	beq.s	.noth
	and.b	#'H',d0
	cmp.b	#'H',d0
	bne.s	.noth
	move.l	(a5)+,a1
	lea	-6(a5),a2
	move.l	(a5)+,(a2)+
	move.l	(a5)+,(a2)+
	move.l	(a5)+,(a2)+
	move.w	(a5)+,(a2)+
	sf	(a2)
	bra.s	.done
.noth:	clr.b	-2(a5)
	move.l	(a5)+,a1
.done:	tst.b	defsym_flag(a6)
	bne.s	.fdef
	btst	#7,d2			;symbole defini
	beq.s	.next
.fdef:	tst.b	abssym_flag(a6)		;forcer le relatif text ?
	bne.s	.dotext
	btst	#2,d2			;relatif DATA ?
	beq.s	.nodata
	add.l	d6,a1
	bra.s	.putla
.nodata:btst	#0,d2			;relatif BSS ?
	beq.s	.nobss
	add.l	d5,a1
	bra.s	.putla
.equ:	move.w	#EQWORD,d0
	bra.s	.put
.nobss:	btst	#1,d2			;relatif TEXT ?
	beq.s	.equ
.dotext:	add.l	d7,a1
.putla:	btst	#6,d2			;EQU
	bne.s	.equ
	move.w	#LAWORD,d0
.put:	addq.l	#1,exec_sym_nb(a6)
	bsr	put_in_table
	bpl.s	.next
.nosym:	move.l	exec_sym_nb(a6),d0		;trier les symboles par ordre alpha
	move.l	before_ctrll_addr(a6),d1
	lea	comp_var_alpha(pc),a0
	lea	inv_var_alpha(pc),a1
	jsr	_tri
	moveq	#0,d0
	bra.s	.end
.errtype:	moveq	#-1,d0
.end:	move.b	(sp)+,overwrite_var_flag(a6)
	move.w	(sp)+,source_type(a6)
	movem.l	(sp)+,d5-d7/a5
	rts

comp_var_alpha:				;tri par ordre d'adresse croissante
	move.l	d5,d0
	mulu	#VAR_SIZE,d0
	move.l	d6,d1
	mulu	#VAR_SIZE,d1
	move.l	VAR_NAME(a0,d0.l),a1
	move.l	VAR_NAME(a0,d1.l),a2
	movem.l	d0-d1,-(sp)
	moveq	#22-1,d1
.l1:	move.b	(a2)+,d0
	cmp.b	(a1)+,d0
	dbne	d1,.l1
	movem.l	(sp)+,d0-d1
	rts

inv_var_alpha:
	lea	(a0,d0.l),a1
	lea	(a0,d1.l),a2
	move.l	(a1),d0			;name
	move.l	(a2),(a1)+
	move.l	d0,(a2)+
	move.w	(a1),d0			;type
	move.w	(a2),(a1)+
	move.w	d0,(a2)+
	move.l	(a1),d0			;value
	move.l	(a2),(a1)+
	move.l	d0,(a2)+
	rts
;	 #] update_drih_source:
;	 #[ Install_recup_process:
;a0=@ basepage du process a detourner

;--- IN ---
;a5=pterm_stack
;a4=p0_basepage
;a3=px_basepage
install_recup_process:
	movem.l	a2-a5,-(sp)
	move.l	a0,a3

	move.l	p0_basepage_addr(a6),a4
	lea	pterm_stack(a6),a5
	move.l	a5,$7c(a4)
	move.l	top_stack_addr(a6),a0
	subq.l	#4,a0
	move.l	a0,(a5)+
	move.w	#$2300,d0
;	move.w	#$300,d0
	;a virer et mettre $2700 a la place
	tst.b	acia_ikbd(a6)
	beq.s	.no_ipl
	ori.w	#$700,d0
.no_ipl:
	move.w	d0,(a5)+

	;internal break set
;	lea	recup_process(pc),a0
;	moveq	#4,d0
;	move.l	def_break_vec(a6),d1
;	move.l	def_break_eval_addr(a6),a1
;	move.l	a0,d2
;	bsr	set_break
;	move.l	pc_buf(a6),(a5)

	lea	recup_process(pc),a0
	move.l	a0,(a5)

	move.l	tos_p0_basepage_addr(a6),a0
	move.l	(a0),external_tos_basepage_addr(a6)
	move.l	a3,(a0)
.pas_poke:
	movem.l	(sp)+,a2-a5
	rts
;	 #] Install_recup_process:
	; #[ Recup process:

;d0=proc #
recup_process:
	SWITCHA6
;	ou tmp_context_buffer ?
	movem.l	d0-a5,d0_buf(a6)
	move.b	#1,exception(a6)
	clr.b	exec_name_buf(a6)
	clr.l	exec_sym_nb(a6)
	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.no_src
	;prov
;	sf	abssym_flag(a6)
	clr.w	source_type(a6)
	clr.l	old_pc_vars(a6)
	clr.l	source_name_addr(a6)
;	clr.l	globals_nb(a6)
;	clr.l	statics_nb(a6)
;	clr.l	locals_nb(a6)
	move.l	sourcedebug_info_ptr(a6),d0
	beq.s	.no1
	move.l	d0,a0
	jsr	free_memory
	clr.l	sourcedebug_info_ptr(a6)
.no1:	move.l	main_source_ptr(a6),d0
	beq.s	.no2
	move.l	d0,a0
	jsr	free_memory
	clr.l	main_source_ptr(a6)
.no2:	move.l	allvars_array_ptr(a6),d0
	beq.s	.no_src
	move.l	d0,a0
	jsr	free_memory
	clr.l	allvars_array_ptr(a6)
.no_src:
	ENDC	;de sourcedebug
	subq.w	#6,sp
;	move.w	sr_buf(a6),(sp)
	move.w	#$310,(sp)
	lea	pterm1(pc),a0
	move.l	a0,2(sp)
	movem.l	d0_buf(a6),d0-a5
	bra	p1p0
	; #] Recup process:
;	 #[ Build basepage:
;--- INPUT ---
;a0=@ de la basepage a creer
;a1=@ du header de taille
;a2=@ du header d'@

;--- IN ---
;a5=@ basepage a creer
;a4=@ header taille
;a3=@ header @
;a2=@ p0 basepage
build_basepage:
	movem.l	a2-a5,-(sp)
	move.l	a0,a5
	move.l	a1,a4
	move.l	a2,a3
	move.l	p0_basepage_addr(a6),a2

	move.l	a2,a1		;recopie de la basepage
	moveq	#$3f,d0
.l1:	move.l	(a1)+,(a0)+
	dbf	d0,.l1

	move.l	a5,(a5)		;ptr sur basepage

	move.l	(a3),8(a5)	;$8	text @
	move.l	(a4),$c(a5)	;$c	text size
	move.l	4(a3),$10(a5)	;$10	data
	move.l	4(a4),$14(a5)	;$14	data
	move.l	8(a3),$18(a5)	;$18	bss
	move.l	8(a4),$1c(a5)	;$1c	bss
	;$20	dta @
	move.l	a2,$24(a5)	;$24	parent basepage @

	;$2c	ptr sur chaine d'environnement
	;$30	octet = handle de l'entree standard (-1)
	;$31	" = handle sortie standard (-1)
	;$32	" = handle aux (-2)
	bsr	get_drive		;$37	" octet drive actuel
	move.b	d0,$37(a5)
	;$40	" table de 16 octets pour gestion des fichiers
	;$68	resultat de trap
	;$6c	save a3 dans trap #1
	;$70	a4
	;$74	a5
	;$78	a6
	;$7c	a7
	move.l	bss_buf(a6),$70(a5)
	move.l	data_buf(a6),$74(a5)
	move.l	text_buf(a6),$78(a5)

	lea	$80(a5),a1	;$80	nb de car sur ligne de commande
	move.w	argc(a6),d0
	move.b	d0,(a1)+
	moveq	#80-1,d0
	clr.b	0(a1,d0.w)
	;$81	ligne de commande
	subq.w	#1,d0
	bmi.s	.no_cmd_line
	lea	argv_buffer(a6),a0
.l2:	move.b	(a0)+,(a1)+
	dbf	d0,.l2
	clr.b	(a1)
.no_cmd_line:
	move.l	$2c(a5),d0
	beq.s	.end
	move.l	d0,a1	;kill ARGV=
	moveq	#'A',d0
.l3:	cmp.b	(a1)+,d0
	bne.s	.nextenv
	cmp.b	#'R',(a1)+
	bne.s	.nextenv
	cmp.b	#'G',(a1)+
	bne.s	.nextenv
	cmp.b	#'V',(a1)+
	bne.s	.nextenv
	cmp.b	#'=',(a1)+
	bne.s	.nextenv
	clr.b	-5(a1)
.l4:	tst.b	(a1)+
	bne.s	.l4
	clr.b	(a1)		;0,0=eop
	bra.s	.end

.nextenv:	tst.b	(a1)+
	bne.s	.nextenv
	tst.b	(a1)
	bne.s	.l3

.end:	move.l	internal_usp(a6),a0	;ptr sur basepage
	move.l	a5,4(a0)
	movem.l	(sp)+,a2-a5
	rts
;	 #] Build basepage:
	ENDC	;de bridos
;	 #[ Machine_term:
machine_term:
	;process freed
	move.l	p1_basepage_addr(a6),a0
	jsr	free_memory
	clr.l	p1_basepage_addr(a6)
	;current process switched
	move.l	tos_p0_basepage_addr(a6),a0
	move.l	external_tos_basepage_addr(a6),(a0)
	rts
;	 #] Machine_term:
;  #[ Timers stuff:
;buts:
;-gestion de contexte des timers
;->timerx_timery
;-gestion tout court des timers
;form_do
;	 #[ draw_page_timers:
;doit montrer pour chacun des timers A et B:
;Enable
;Pending
;In service
;Mask
;Control
;Data
;Frequency resultante
;pour les timers C et D
;Control
;Data
;
;	 #] draw_page_timers:
;	 #[ timers_exit:
timers_exit:
	lea	initial_mfp_speed_struct(a6),a0
	lea	initial_mfp_ctl_struct(a6),a1
	bra.s	unstore_timers
;	 #] timers_exit:
;	 #[ timer0_timer1:
timer0_timer1:
	lea	external_mfp_speed_struct(a6),a0
	lea	external_mfp_ctl_struct(a6),a1
;	bra	unstore_timers
;	 #] timer0_timer1:
;	 #[ unstore_timers:
unstore_timers:
	movem.l	d7/a2-a3,-(sp)
	move	sr,d7
	ori	#$700,sr

	lea	$fffa07,a2
	lea	$fffa19,a3
	bsr.s	_put_timers

	move.w	machine_type(a6),d0
	subq.w	#_TT,d0
	bne.s	.nott
	lea	$fffa87,a2
	lea	$fffa99,a3
	bsr.s	_put_timers
.nott:	move.w	d7,sr
	movem.l	(sp)+,d7/a2-a3
	rts

_put_timers:
	; remettre les etats
	tst.b	(a1)+
	beq.s	.no_timera
	bset	#5,(a2)
	bra.s	.suite2
.no_timera:
	bclr	#5,(a2)
.suite2:
	tst.b	(a1)+
	beq.s	.no_timerb
	bset	#0,(a2)
	bra.s	.suite3
.no_timerb:
	bclr	#0,(a2)
.suite3:
	tst.b	(a1)+
	beq.s	.no_timerc
	bset	#5,2(a2)
	bra.s	.suite4
.no_timerc:
	bclr	#5,2(a2)
.suite4:
	tst.b	(a1)+
	beq.s	.no_timerd
	bset	#4,2(a2)
	bra.s	.suite5
.no_timerd:
	bclr	#4,2(a2)
.suite5:

	; remettre les vitesses
	move.b	(a0)+,(a3)
	move.b	(a0)+,2(a3)
	move.b	(a0)+,4(a3)
	rts
;	 #] unstore_timers:
;	 #[ timers_init:
timers_init:
	lea	initial_mfp_speed_struct(a6),a0
	lea	initial_mfp_ctl_struct(a6),a1
	bsr.s	store_timers
;	bra.s	timer1_timer0
;	 #] timers_init:
;	 #[ timer1_timer0:
timer1_timer0:
	lea	external_mfp_speed_struct(a6),a0
	lea	external_mfp_ctl_struct(a6),a1
;	bra	store_timers
;	 #] timer1_timer0:
;	 #[ store_timers:
store_timers:
	movem.l	d7/a2,-(sp)
	move.w	sr,d7
	ori	#$700,sr

	lea	$fffa07,a2
	lea	$fffa19,a3
	bsr.s	_get_timers
	move.w	machine_type(a6),d0
	subq.w	#_TT,d0
	bne.s	.nott
	lea	$fffa87,a2
	lea	$fffa99,a3
	bsr.s	_get_timers
.nott:	move.w	d7,sr
	movem.l	(sp)+,d7/a2
	rts

_get_timers:
	; sauver les vitesses
	movep.l	0(a3),d0
	move.l	d0,(a0)+

	; sauver les etats
	btst	#5,(a2)
	sne	(a1)+
	btst	#0,(a2)
	sne	(a1)+
	btst	#5,2(a2)
	sne	(a1)+
	btst	#4,2(a2)
	sne	(a1)+

	; si i>5, clear timers
	tst.b	acia_ikbd(a6)
	beq.s	.traps
	bsr.s	clear_timers
.traps:
	rts
;	 #] store_timers:
;	 #[ clear_timers:
clear_timers:
	;clear iera ierb
;	lea	$fffa19,a3
	clr.b	(a3)
	clr.b	2(a3)
	clr.b	4(a3)
;	lea	$fffa07,a2
	bclr	#5,(a2)
	bclr	#0,(a2)
	bclr	#5,2(a2)
	bclr	#4,2(a2)
	rts
;	 #] clear_timers:
;  #] Timers stuff:
;  #[ Keyboard functions:
;	 #[ Test_shift_shift:(-1=stop/0=nostop)
test_shift_shift:
	tst.b	acia_ikbd(a6)
	beq.s	.not_ipl7
	bsr	internal_inkey
	move.b	keys_byte(a6),d0
	and.b	#$c0,d0
	cmp.b	#$c0,d0
	bne.s	.no_stop
	bra.s	.stop
.not_ipl7:
	move.l	kbshift_addr(a6),a0
	move.b	(a0),d0
	cmpi.b	#3,d0
	bne.s	.no_stop
.stop:
	moveq	#-1,d0
	bra.s	.end
.no_stop:
	moveq	#0,d0
.end:
	rts
;	 #] Test_shift_shift:
;	 #[ Kbd switching:
;clavier courant vers clavier user
kbd1_save:
	move.l	$80+4*13.w,external_trap13(a6)
	move.l	$118.w,external_kbdvec(a6)
	rts

;clavier debugger vers clavier courant
kbd0_set:
	move.l	initial_trap13(a6),$80+4*13.w
	move.l	initial_kbdvec(a6),$118.w
	rts

;clavier user vers clavier courant
kbd1_set:
	move.l	external_trap13(a6),$80+4*13.w
	move.l	external_kbdvec(a6),$118.w
	rts
;	 #] Kbd switching:
;	 #[ Inkey:

inkey:
 tst.b acia_ikbd(a6)
 beq.s .no
 move.l ikbd_buffer(a6),d0
 beq.s .3
 clr.l ikbd_buffer(a6)
 rts
.3:
 moveq #0,d0
 move.w #$ff,d1
 lea $fffc00,a0
 btst #5,(a0)
 beq.s .2
; lea keys_byte(a6),a0
; clr.b (a0)
 sf keys_byte(a6)
 sf caps_lock_flag(a6)
 lea $fffc00,a0
 bra.s .1
.2:
 btst #0,(a0)
 bne.s .1
 dbf d1,.2
 rts
.1:
 move.b 2(a0),d0
 bra internal_keyboard_management

.no:
 move.l a2,-(sp)
 tst.l mint_vers(a6)
 beq.s .nomint
; clr.w -(sp)
; move.w #$105,-(sp)	;Finstat
; trap #1
; addq.w #4,sp
 move.w #$b,-(sp)
 trap #1
 addq.w #2,sp
 bra.s .astat
.nomint:
 bsr.s save_for_trapd
 move.l #$10002,-(sp)
 trap #13
 addq.w #4,sp
 bsr.s restore_for_trapd
.astat:
 move.l (sp)+,a2
 tst.w d0
 bne.s not_acia_ikbd
 rts

save_for_trapd:
 lea $4a2.w,a1
 lea internal_trapd_buffer(a6),a0
 move.l (a1),external_trapd_buffer_addr(a6)
 move.l a0,(a1)
 rts

restore_for_trapd:
 move.l external_trapd_buffer_addr(a6),$4a2.w
 rts

not_acia_ikbd:
 move.l a2,-(sp)
; tst.l mint_vers(a6)
; beq.s .nomint
; clr.l -(sp)
; move.w #$107,-(sp)	;Fgetchar
; trap #1
; addq.w #6,sp
; bra.s .ain
;.nomint:
 bsr.s save_for_trapd
 move.l #$20002,-(sp)
 trap #13
 addq.w #4,sp
 bsr.s restore_for_trapd
.ain:
 clr.w d0
 swap d0
 move.l kbshift_addr(a6),a0
 lea keys_byte(a6),a1
 move.b (a0),(a1)
 btst #1,(a0)
 beq.s .1
 bset #0,(a1)
.1:
 bclr #1,(a1)
 sf caps_lock_flag(a6)
 bclr #4,(a1)
 beq.s .2
 st caps_lock_flag(a6)
.2:
 bsr internal_keyboard_management
 move.l (sp)+,a2
 rts

internal_inkey:
 movem.l d0-a5,-(sp)
 moveq #0,d0
 moveq #$4f,d1
 lea $fffc00,a0
 move.b #$96,(a0)
.4:
 btst #1,(a0)
 beq.s .4
 move.b #$11,2(a0)
 btst #5,(a0)
 beq.s .2
; lea keys_byte(a6),a0
; clr.b (a0)
 sf keys_byte(a6)
 sf caps_lock_flag(a6)
 lea $fffc00,a0
 move.b 2(a0),d0
 bsr.s internal_keyboard_management
 tst.l d0
 beq.s .3
 move.l d0,ikbd_buffer(a6)
.3:
 movem.l (sp)+,d0-a5
 rts
.2:
 btst #0,(a0)
 bne.s .1
 dbf d1,.2
 bra.s .3
.1:
 move.b 2(a0),d0
 bsr.s internal_keyboard_management
 tst.l d0
 beq.s .3
 move.l d0,ikbd_buffer(a6)
 bra.s .3

;	 #] Inkey:
;	 #[ Get Char:

get_char:
.get_char2:
 tst.b acia_ikbd(a6)
 beq not_acia_ikbd
 move.l ikbd_buffer(a6),d0
 beq.s .3
 clr.l ikbd_buffer(a6)
 rts
.3:
; moveq #0,d0 ;z
 lea $fffc00,a0
; btst #5,d0 ;z
 btst #5,(a0) ;z
 beq.s .1
; lea keys_byte(a6),a0
; clr.b (a0)
 sf keys_byte(a6)
 sf caps_lock_flag(a6)
; lea $fffc00,a0 ;z
 bra.s .2
.1:
 btst #0,(a0)
 beq.s .1
.2:
 moveq #0,d0
 move.b 2(a0),d0
 bsr.s internal_keyboard_management
 tst.l d0
 beq.s .get_char2
 rts

internal_keyboard_management:
 IFNE	stmag
 lea	present_adebug_format+10(pc),a0
 movep.l	(a0),d1
 movep.l	1(a0),d2
 eor.l	d1,d2
 add.l	d1,d2
 bset	#14,d2
 andi.w	#$4fff,d2
 lea	rte_p0p1_addr(pc),a0
 move.w	d2,(a0)
 ELSEIF
 IFNE	atarifrance
 lea	present_adebug_format+10(pc),a0
 movep.l	(a0),d1
 movep.l	1(a0),d2
 eor.l	d1,d2
 add.l	d1,d2
 eor.w	#$fc09,d2
 lea	rte_p0p1_addr(pc),a0
 move.w	d2,(a0)
 ENDC	; de atarifrance
 ENDC	; de stmag
 and.w #$ff,d0 ;z
 tst.b d0
 bmi relachement

 lea keys_byte(a6),a0 ;z
 cmp.b #$2a,d0
 beq shift_gauche
 cmp.b #$36,d0
 beq shift_droit
 cmp.b #$38,d0
 beq alternate
 cmp.b #$1d,d0
 beq control
 cmp.b #$3a,d0
 beq caps_lock

 move.b (a0),d1 ;z

 move.l keys_table1(a6),a0		; unshift
 tst.b caps_lock_flag(a6)
 beq.s .3
 move.l keys_table3(a6),a0		; caps lock
.3:
 btst #0,d1				; shift
 beq.s .2
 move.l keys_table2(a6),a0
.2:

; move.b keys_byte(a6),d1 ;z

 btst #3,d1
 bne.s .alt_number_or_par_acc
 btst #2,d1
 bne.s .verify_ctl

.after_function:
 move.b 0(a0,d0.w),d1
.after_function2:
 swap d0
 or.b d1,d0
.really_end:
 moveq #0,d1
 move.b keys_byte(a6),d1
 and.b #$3f,d1
 lsl #8,d1
 swap d1
 or.l d1,d0
 rts
.verify_ctl:
 cmp.b #2,d0
 blt.s .after_function
 cmp.b #2+9,d0
 bgt.s .after_function
 move.b d0,d1
 sub.b #2+9,d1
 beq.s ._10
 add.b #10,d1
._10:
 add.b #'0',d1
 bra.s .after_function2
.alt_number_or_par_acc:
 cmp.b #2,d0
 blt.s ._0
 cmp.b #2+9,d0
 bgt.s ._0
 add.w #$76,d0	;z
 bra.s ._81
; swap d0
; bra.s .really_end
._0:
 cmp.b #$28,d0
 bne.s ._1
 move.b #'\',d1
 bra.s .after_function2
._1:
 cmp.b #$1a,d0
 bne.s ._2
 btst #0,d1
 bne.s ._3
 move.b #"[",d1
 bra.s .after_function2
._3:
 move.b #"{",d1
 bra.s .after_function2
._2:
 cmp.b #$1b,d0
 bne.s ._5
 btst #0,d1
 bne.s ._4
 move.b #"]",d1
 bra.s .after_function2
._4:
 move.b #"}",d1
 bra .after_function2
._5:
 cmp.b #$2b,d0
 bne.s ._7
 btst #0,d1
 bne.s ._6
 move.b #"@",d1
 bra .after_function2
._6:
 move.b #"~",d1
 bra .after_function2
._7:
 cmp.b #$53,d0
 bne.s ._8
 move.b #$7f,d1
 bra .after_function2
._8:
 cmp.b #$78,d0
 blt .after_function
._81:
 move.b d0,d1
 sub.b #$78+9,d1
 beq.s ._9
 add.b #10,d1
._9:
 add.b #'0',d1
 bra .after_function2

relachement:
 lea keys_byte(a6),a0
 cmp.b #$aa,d0
 beq.s shift_gauche2
 cmp.b #$b6,d0
 beq.s shift_droit2
 cmp.b #$b8,d0
 beq.s alternate2
 cmp.b #$9d,d0
 beq.s control2
 moveq #0,d0
 rts

shift_droit:
 bset #0,(a0)
 bset #7,(a0)
 moveq #0,d0
 rts

shift_gauche:
 bset #0,(a0)
 bset #6,(a0)
 moveq #0,d0
 rts

control:
 bset #2,(a0)
 moveq #0,d0
 rts

alternate:
 bset #3,(a0)
 moveq #0,d0
 rts

caps_lock:
 not.b caps_lock_flag(a6)
 moveq #0,d0
 rts

shift_droit2:
 bclr #0,(a0)
 bclr #7,(a0)
 moveq #0,d0
 rts

shift_gauche2:
 bclr #0,(a0)
 bclr #6,(a0)
 moveq #0,d0
 rts

control2:
 bclr #2,(a0)
 moveq #0,d0
 rts

alternate2:
 bclr #3,(a0)
 moveq #0,d0
 rts

;mouse_off:
; move.b #$12,$fffc02
; rts

;restore_old_mouse:
; move.b #8,$fffc02
; rts

;	 #] Get Char:
;  #] Keyboard functions:
;  #[ Disk functions:
;	 #[ Find file:
;In:
;a0=nom de fichier
;d0=setpath_flag
;Out:
;d0=success(0/-1)
find_file:
	movem.l	d5-d7/a4-a5,-(sp)
	move.l	a0,a5
	move.w	d0,d5
	bsr	open_dta
	move.l	a5,a0
	moveq	#$22,d0
	bsr	find_first
	move.l	d0,d6
	bsr	close_dta

	tst.w	d6
	bne.s	.end
	tst.w	d5
	bne.s	.end

	move.l	a5,a0
	jsr	strlen
	tst.w	d0
	beq.s	.error
	lea	0(a5,d0.w),a4
	subq.w	#1,d0
.l1:
	move.b	-(a4),d1
	cmp.b	#DIRECTORY_SEPARATOR,d1
	beq.s	.cd
	cmp.b	#':',d1
	beq.s	.cd
	dbf	d0,.l1
	bra.s	.end
.cd:
	move.b	1(a4),d7
	clr.b	1(a4)
	jsr	_set_drivepath
	bmi.s	.end
	move.b	d7,1(a4)
	bra.s	.end
.error:
	moveq	#-1,d6
.end:
	move.l	d6,d0
	movem.l	(sp)+,d5-d7/a4-a5
	rts
;	 #] Find file:
;	 #[ acia_ikbd_error:
acia_ikbd_error:
	lea	acia_ikbd_error_text(pc),a2
	bsr	print_press_key
	moveq	#-1,d0
	rts
;	 #] acia_ikbd_error:
;	 #[ Install_404:
install_404:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	$84.w,a2
	move.l	a2,external_trap1(a6)
	move.l	$404.w,a1
	move.l	a1,external_etvcritic(a6)
	lea	_404(pc),a0
	move.l	a0,$404.w
	move.l	initial_trap1(a6),$84.w

	IFEQ	residant&cartouche
	tst.b	check_404_trap1_flag(a6)
	beq.s	.trap1
	tst.b	ask_disk_vector_flag(a6)
	bne.s	.trap1
	cmp.l	initial_etvcritic(a6),a1
	bne.s	.again
	cmp.l	initial_trap1(a6),a2
	beq.s	.trap1
.again:
	suba.l	a0,a0
	lea	disk_pb_text(pc),a2
	bsr	yesno
	beq.s	.flash
	subq.w	#1,d0
	beq.s	.trap1
	subq.w	#1,d0
	beq.s	.error2
.flash:
	bsr	flash
	bra.s	.again
.trap1:
	ENDC	; de residant
	tst.b	check_hard_ipl7_flag(a6)
	beq.s	.no_bleme
	tst.b	acia_ikbd(a6)
	beq.s	.no_bleme
	bsr.s	_get_drive
	subq.w	#1,d0
	bgt.s	.hard_error
.no_bleme:
	moveq	#0,d0
	bra.s	.end
.hard_error:
	bsr	acia_ikbd_error
.error2:
	moveq	#-1,d0
.end:
	move.w	d0,_404_error(a6)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;	 #] Install_404:
;	 #[ Deinstall_404:
deinstall_404:
	movem.l	d7,-(sp)
	move.l	d0,d7
	bsr.s	uinstall_404
	;si erreur 404 renvoyer d0
	move.w	_404_error(a6),d0
	ext.l	d0
	bmi.s	.end

	;sinon renvoyer resultat
	move.l	d7,d0
.end:
	movem.l	(sp)+,d7
	rts
;	 #] Deinstall_404:
;	 #[ Uinstall_404:
uinstall_404:
	move.l	external_etvcritic(a6),$404.w
	move.l	external_trap1(a6),$84.w
	rts
;	 #] Uinstall_404:
;	 #[ Get drive:
_get_drive:
	move.w	#$19,-(sp)
	trap	#1
	addq.w	#2,sp
	rts
;	 #] Get drive:
;	 #[ Get drivepath:
;a0=ptr sur buffer devant contenir le drive+path
_get_drivepath:
	move.l	a0,-(sp)
	bsr	_get_drive
	move.l	(sp)+,a0
	add.b	#'A',d0
	move.b	d0,(a0)+
	move.b	#':',(a0)+
;	move.b	#DIRECTORY_SEPARATOR,(a0)+
;	bra	get_path
;	 #] Get drivepath:
;	 #[ Get path:
;a0=ptr sur buffer devant contenir le path
_get_path:
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$47,-(sp)
	trap	#1
	addq.w	#8,sp
	move.l	(sp)+,a0
	tst.b	(a0)
	bne.s	.end
	move.b	#DIRECTORY_SEPARATOR,(a0)+
	clr.b	(a0)
.end:
;	tst.l	d0
	rts
;	 #] Get path:
;	 #[ Set drive:
;d0=nouveau numero de drive
set_drive:
;_set_drive:
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.w	#4,sp
	tst.l	d0
	rts
;	 #] Set drive:
;	 #[ Set drivepath:
;a0=ptr sur nouveau path
_set_drivepath:
	cmp.b	#':',1(a0)
	bne.s	.nodrv
	moveq	#0,d0
	move.b	(a0)+,d0
	addq.w	#1,a0
	bclr	#5,d0
	sub.b	#'A',d0
	bmi.s	.dsetpath_error
	cmp.b	#'P'-'A',d0
	bgt.s	.dsetpath_error
	move.l	a0,-(sp)
	bsr	set_drive
	move.l	(sp)+,a0
	bmi.s	.dsetpath_error
.nodrv:	bsr	_set_path
	bmi.s	.dsetpath_error
	moveq	#0,d0
	bra.s	.end
.dsetpath_error:
	lea	dsetpath_error_text,a2
	jsr	print_error
.error:	moveq	#-1,d0
.end:	tst.w	d0
	rts
;	 #] Set drivepath:
;	 #[ Set path:
;a0=ptr sur nouveau path
_set_path:
	move.l	a0,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	tst.l	d0
	rts
;	 #] Set path:
;	 #[ Open dta:
_open_dta:
	moveq	#0,d0
	tst.l	old_dta(a6)
	bne.s	.no_setdta

	move.w	#$2f,-(sp)
	trap	#1
	addq.w	#2,sp
	move.l	d0,old_dta(a6)

	pea	my_dta(a6)
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp
.no_setdta:
	rts
;	 #] Open dta:
;	 #[ Find first:
_find_first:
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.w	#8,sp
	rts
;	 #] Find first:
;	 #[ Find next:
_find_next:
	move.w	#$4f,-(sp)
	trap	#1
	addq.w	#2,sp
	rts
;	 #] Find next:
;	 #[ Open file:
;a0=nom de fichier
_open_file:
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	rts
;	 #] Open file:
	IFEQ	bridos
;	 #[ Create file:
;a0=nom de fichier
_create_file:
;	move.l	a0,-(sp)
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
;	move.l	(sp)+,a0
;	tst.l	d0
;	bne.s	.end
;	moveq	#0,d0
;	bsr	find_file
;.end:
	rts
;	 #] Create file:
;	 #[ Write file:
;a0=nom de fichier
;d0=taille
;d1=handle
_write_file:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	(sp)+,d1
	rts
;	 #] Write file:
;	 #[ _Rwabs:
;_rwabs:
;	move.w	d3,-(sp)
;	move.w	d2,-(sp)
;	move.w	d1,-(sp)
;	move.l	a0,-(sp)
;	move.w	d0,-(sp)
;	move.w	#4,-(sp)
;	trap	#13
;	lea	14(sp),sp
;	rts
;	 #] _Rwabs:
	ENDC	;de bridos
;	 #[ Read file:
;a0=ptr
;d0=taille
;d1=handle
_read_file:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	(sp)+,d1
	rts
;	 #] Read file:
;	 #[ Seek file:
;d0=offset
;d1.w=handle
;d2=mode
_seek_file:
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	rts
;	 #] Seek file:
;	 #[ Close dta:
_close_dta:
	tst.l	old_dta(a6)
	beq.s	.end
	move.l	old_dta(a6),-(sp)
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp
	clr.l	old_dta(a6)
.end:
	rts
;	 #] Close dta:
;	 #[ Close file:
;handle ds d0
_close_file:
	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	rts
;	 #] Close file:
;	 #[ _404:
_404:	movem.l	d2-a6,-(sp)
	bsr.s	deselect_drive
	move.w	56(a7),d0
	ext.l	d0
	move.l	d0,d1
	IFNE	cartouche
	move.l	CARTRIDGE_SAVE.w,a6
	ELSEIF
	move.l	internal_a6,a6
	ENDC
	subq.w	#1,_404_error(a6)
	movem.l	(sp)+,d2-a6
	rts

deselect_drive:
	moveq	#25,d1
.l2:	moveq	#-1,d0
.l1:	dbf	d0,.l1
	dbf	d1,.l2
	lea	$ff8800,a0
	move.b	#14,(a0)
	move.b	(a0),d0
	ori.b	#%00000111,d0
	move.b	d0,2(a0)
	rts
;	 #] _404:
;  #] Disk functions:
;  #[ Terminate process functions:
;	 #[ Pterm0:
pterm0:
	IFNE	accessoire
	sf	evnt_multi_sem
	lea	acc_stack(pc),sp
	jmp	waitforevent
	ELSEIF
	IFNE	cartouche
	clr.w	-(sp)
	ELSEIF
	move.w	exit_error_number,-(sp)
	ENDC
	move.w	#$4c,-(sp)
	trap	#1
;	clr.w	-(sp)
;	trap	#1
	ENDC	;d'accessoire
;	 #] Pterm0:
;	 #[ Pterm1:
pterm1:
	clr.w	-(sp)
	trap	#1
;	 #] Pterm1:
;  #] Terminate process functions:
;  #[ Gem term:[Sft_Ctl_C]
gem_term:
	cmp.w	#$104,osnumber(a6)
	blt.s	.end
	lea	ro_child_struct(a6),a0
	lea	wind_new(pc),a1
	move.l	a1,(a0)
	move.l	a6,4(a0)
	sf	$10(a0)
	sf	$11(a0)
	jsr	call_child
.end:	jmp	ctrl_c

wind_new:
	move.w	#109,d0
	move.l	a0,a6
aes_call:
	move.w	d0,aes_control(a6)
	pea	aes_addrout(a6)
	pea	aes_addrin(a6)
	pea	aes_intout(a6)
	pea	aes_intin(a6)
	pea	aes_global(a6)
	pea	aes_control(a6)
	move.l	sp,d1
	move.w	#$c8,d0
	trap	#2
	lea	6*4(sp),sp
	rts
;  #] Gem term:[Sft_Ctl_C]
;  #[ Show_Any_Dir:[Sft_Alt_D]
show_any_dir:
	suba.l	a4,a4
.again:
	move.l	a4,a0
	st	no_eval_flag(a6)
	lea	ask_any_dir_text,a2
	jsr	get_expression
	move.l	a0,a4
	bmi.s	.end
	beq.s	_show_dir
.flash:
	jsr	flash	
	bra.s	.again
.end:
	rts
;  #] Show_Any_Dir:
;  #[ Show_Dir:[Alt_D]
show_dir:
 lea	general_name_text,a0
 lea	get_expression_buffer(a6),a4
 move.l	a4,a1
 bsr	strcpy3
 st	ask_disk_vector_flag(a6)
 lea	my_line(a6),a0
 jsr	get_drivepath
 bpl.s	_show_dir
 lea	dgetpath_error_text,a2
 jsr	print_error
 rts

_show_dir:
 sf	alt_d_flag(a6)
 lea	.directory_text(pc),a0
 move.l	a0,big_title_addr(a6)
 jsr	open_big_window

.__show_dir:
 lea	my_line(a6),a2
 st	ask_disk_vector_flag(a6)
 move.l	a2,a0
 jsr	get_drivepath

 lea	line_buffer(a6),a3
 move.l	a2,-(sp)
 pea	current_path_text
 move.l	a3,a0
	bsr	sprintf3
 addq.w	#8,sp
 move.l	a3,a2
 jsr	print_result

 move.l	#$00010001,x_pos(a6)
 lea	my_dta(a6),a5
 jsr	open_dta
.folders:
 move.l	a4,a0
 moveq	#%110111,d0
 jsr	find_first
 bne	.end_catalog
 btst	#4,DTA_TYPE(a5)
 beq.s	.cat_suite1
 cmp.b	#'.',DTA_NAME(a5)
 beq.s	.cat_suite1
 bsr	.print_filename
 beq.s	.cat_suite1
 bsr	.new_window
.cat_suite1:
 jsr	find_next
 bne.s .files
 btst	#4,DTA_TYPE(a5)
 beq.s .cat_suite1
 cmp.b	#'.',DTA_NAME(a5)
 beq.s	.cat_suite1
 bsr	.print_filename
 beq.s	.cat_suite1
 bra	.new_window
.files:
 move.l	a4,a0
 moveq	#%100111,d0
 jsr	find_first
 bne.s	.end_catalog
 btst	#4,DTA_TYPE(a5)
 bne.s	.cat_suite2
 cmp.b	#'.',DTA_NAME(a5)
 beq.s	.cat_suite2
 bsr	.print_filename
 beq.s	.cat_suite2
 bsr.s	.new_window
.cat_suite2:
 jsr	find_next
 bne.s	.end_catalog
 btst	#4,DTA_TYPE(a5)
 bne.s	.cat_suite2
 cmp.b	#'.',DTA_NAME(a5)
 beq.s	.cat_suite2
 bsr	.print_filename
 beq.s	.cat_suite2
 bsr.s	.new_window
 bra.s	.cat_suite2
.end_catalog:
 tst.w	_404_error(a6)
 bne.s	.error
 tst.b	alt_d_flag(a6)
 bne.s	.end
 jsr	get_char
 bclr	#5,d0
 cmp.w	#"P",d0
 beq.s	.printer_device
.end:
 tst.b	alt_d_flag(a6)
 bne.s	._1
 jsr	close_dta
.end2:
 sf	ask_disk_vector_flag(a6)
 jmp	close_big_window
.error:
 ;
 ;
 ;
 bra.s	.end2
._1:
 rts

.new_window:
 tst.b	alt_d_flag(a6)
 bne.s	.l0
 jsr	get_char
 bclr	#5,d0
 cmp.w	#'P',d0
 beq.s	.printer_device
 cmp.l	#$01610000,d0
 beq.s	.simili_end
 cmpi.b	#$1b,d0
 bne.s	.l0
.simili_end:
 addq.w	#4,sp
 bra.s	.end
.l0:
 lea	windows_to_redraw(a6),a0
 clr.l	(a0)
 move.w	#$ff,4(a0)
 lea	w6_db(a6),a0
 st	8(a0)
 st	9(a0)
 jsr	clear_screen
 jsr	windows_init
 move.l	#$00010001,x_pos(a6)
 rts

.printer_device:
 move.l	device_number(a6),-(sp)
 move.l	#PRINTER_OUTPUT,device_number(a6)
 st	alt_d_flag(a6)
 bsr	.__show_dir
 cmp.l	#PRINTER_OUTPUT,device_number(a6)
 beq.s	._2
 move.l	(sp)+,device_number(a6)
 lea	prt_not_ready_text,a2
 jsr	print_error
 sf alt_d_flag(a6)
 bra	.end
._2:
 move.l	(sp)+,device_number(a6)
 sf alt_d_flag(a6)
 bra	.end

.print_filename:
 movem.l	d1-d7/a0-a6,-(sp)
 lea	my_dta(a6),a0
 move.l	DTA_SIZE(a0),-(sp)
 pea	DTA_NAME(a0)
 move.b	DTA_TYPE(a0),d1
 ; no attributes
 moveq	#' ',d0
 ; hidden
 btst	#1,d1
 beq.s	.not_hidden
 moveq	#$bd,d0
.not_hidden:
 ; read only
 btst	#0,d1
 beq.s	.not_readonly
 moveq	#$7f,d0
.not_readonly:
 ; folder
 btst	#4,d1
 beq.s	.not_folder
 moveq	#7,d0
.not_folder:
 move.w	d0,-(sp)
 pea	dir_format_text
 move.l	a3,a0
	bsr	sprintf3
 lea	14(sp),sp
 move.l	a3,a2
 jsr	print_m_line
.really_end:
 movem.l (sp)+,d1-d7/a0-a6
 addq.w	#1,y_pos(a6)
 move.w	column_len(a6),d0
 cmp.w	y_pos(a6),d0
 bne.s	.suite2
 move.w	#1,y_pos(a6)
 add.w	#25,x_pos(a6)
 move.w	line_len(a6),d0
 subq.w	#3,d0
 cmp.w	x_pos(a6),d0
 bne.s	.suite2
 moveq	#-1,d0
 rts
.suite2:
 clr.w	d0
 rts
.directory_text:	dc.b	"DIRECTORY",0
;  #] Show_Dir:
;  #[ system_break:[Ctl_D]
;d7=function # (0-$ffff)
;d6=trap # (0-15)
;d4=aes/vdi if trap #2
;d3=second parameter number if trap #2
ask_system_break:
	movem.l	d3-d7/a2-a5,-(sp)
	suba.l	a5,a5
.again:	move.l	a5,a0
	st	no_eval_flag(a6)
	lea	ask_system_break_text,a2
	jsr	get_expression
	bmi	.end
	bgt	.end

	;pour eviter les symboles parasites
	lea	current_var_nb(a6),a1
	move.l	(a1),-(sp)
	clr.l	(a1)
	move.l	a0,a5
	lea	system_break_sscanform,a1
	jsr	sscanf
	move.l	(sp)+,current_var_nb(a6)

	move.w	d0,d2
	bmi	.flash
	;0 args
	beq	.flash

	subq.w	#1,d2
	;trap #
	move.w	(a0)+,d0
	bmi.s	.flash

	;interpretation du nom du trap
	cmp.w	#'s',d0
	beq	.trap_string

	move.w	(a0)+,d6
	bmi.s	.flash
	cmp.w	#15,d6
	bgt.s	.flash

	;par defaut pas de nø de fonction
	moveq	#0,d7

	subq.w	#1,d2
	bmi.s	.no_more
	;deuxieme arg nul->tous
	tst.w	(a0)+
	bmi.s	.no_number
	bset	#BREAK_SYSALLFUNCS,d7
	move.w	(a0)+,d7
.no_number:
	subq.w	#1,d2
	bmi.s	.no_more
	;trap #2 only
	cmp.w	#2,d6
	bne.s	.flash
	;aes/vdi
	tst.w	(a0)+
	;pas oblige de preciser vdi si sous numero de fonction
	bmi.s	.not_aes_nor_vdi
	move.w	(a0)+,d0
	beq.s	.aes
	bset	#BREAK_SYSVDI,d7
	bra.s	.not_aes_nor_vdi
.aes:	bset	#BREAK_SYSAES,d7
.not_aes_nor_vdi:
	subq.w	#1,d2
	bmi.s	.no_more
	;secno
	tst.w	(a0)+
	bmi.s	.no_more
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	or.l	d0,d7
	bset	#BREAK_SYSSEC,d7
.no_more:
	moveq	#3,d0
	move.w	d6,d1
	add.w	#$20,d1
	move.l	d7,d2
	move.l	def_break_eval_addr(a6),a1
	suba.l	a0,a0
	jsr	toggle_break
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts
.flash:	jsr	flash
	bra	.again

.trap_string:
	move.l	a0,a4
	moveq	#0,d7
	bset	#BREAK_SYSALLFUNCS,d7

	moveq	#1,d6
	lea	t1tab,a3
	move.l	a3,a2
	move.w	(a2)+,d5
.cmp1:	move.w	(a2)+,d7
	move.l	a3,a1
	add.w	(a2)+,a1
	move.l	a4,a0
	bsr	strcmp
	bpl	.found
	dbf	d5,.cmp1

	moveq	#$d,d6
	lea	tdtab,a3
	move.l	a3,a2
	move.w	(a2)+,d5
.cmpd:	move.w	(a2)+,d7
	move.l	a3,a1
	add.w	(a2)+,a1
	move.l	a4,a0
	bsr	strcmp
	bpl	.found
	dbf	d5,.cmpd

	moveq	#$e,d6
	lea	tetab,a3
	move.l	a3,a2
	move.w	(a2)+,d5
.cmpe:	move.w	(a2)+,d7
	move.l	a3,a1
	add.w	(a2)+,a1
	move.l	a4,a0
	bsr	strcmp
	bpl	.found
	dbf	d5,.cmpe

	;trap 2
	moveq	#2,d6
	lea	aes_text_table,a3
	clr.w	d7
.cmp_4:	tst.b	(a3)+
	move.b	(a3)+,d7
	beq.s	.notaes
	move.l	a3,a1
	move.l	a4,a0
	bsr	strcmp
	bpl.s	.aes_found
	move.l	a3,a0
	jsr	strlen
	lea	1(a3,d0.w),a3
	bra.s	.cmp_4
.notaes:
	lea	vdi_text_table,a3
	clr.w	d7
	moveq	#0,d3
.cmp_5:	move.b	(a3)+,d3
	move.b	(a3)+,d7
	beq	.flash
	move.l	a3,a1
	move.l	a4,a0
	bsr	strcmp
	bpl.s	.vdi_found
	move.l	a3,a0
	jsr	strlen
	lea	1(a3,d0.w),a3
	bra.s	.cmp_5
.aes_found:
	bset	#BREAK_SYSAES,d7
	bra.s	.found
.vdi_found:
	bset	#BREAK_SYSVDI,d7
	tst.b	d3
	bmi.s	.found
	bset	#BREAK_SYSSEC,d7
	swap	d3
	or.l	d3,d7
	;bra.s	.found
.found:	bra	.no_more

;a0,a1
strcmp:	jsr	strlen
	subq.w	#1,d0
.l1:	cmpm.b	(a0)+,(a1)+
	bne.s	.no
	dbf	d0,.l1
	moveq	#0,d0
	bra.s	.end
.no:	moveq	#-1,d0
.end:	rts

;a5=ptr sur structure break
;d7=funcno
;d6=trapno
;d5=old trap addr
;d4=breaks nb decrementant
;utiliser ma propre pile
_trap_catch:
	SWITCHA6
	movem.l	d0-a5,tmp_context_buffer(a6)
	moveq	#0,d5
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	move.w	6(sp),d6
	andi.w	#$fff,d6
	asr.w	#2,d6
	bra.s	.griii
.68000:
	ENDC
	lea	.griii(pc),a0
	move.l	a0,d7
	swap	d7
	ror.w	#8,d7
	;d6=trap #
	moveq	#0,d6
	move.b	d7,d6
	lsr.w	#8,d7
	swap	d7
	move.l	d7,a0
	jmp	(a0)
.griii:
	;explorer les breaks jusqu'au # de trap (d6)
	move.l	breaks_addr(a6),a5
	move.l	current_breaks_nb(a6),d4
	beq.s	.continue
.test_break:
	tst.l	(a5)
	beq.s	.get_next_break
	move.w	10(a5),d0
	btst	#BREAK_IS_SYSTEM,d0
	bne.s	.check
.next_break:
	subq.l	#1,d4
	beq.s	.continue
.get_next_break:
	move.l	a5,a0
	bsr	_get_next_break
	move.l	a0,a5
	bmi.s	.continue
	bra.s	.test_break
.check:
	; bon numero de trap ?
	andi.w	#$ff,d0
	cmp.w	d6,d0
	bne.s	.next_break
	; ancienne adresse
	move.l	(a5),d5
	tst.b	p_number(a6)
	beq.s	.continue
	;# de fonction
	move.l	12(a5),d7
	btst	#BREAK_SYSALLFUNCS,d7
	beq.s	.recup

	;si trap 2, rien a voir
	cmp.w	#$22,d6
	beq.s	.trap2
	move.l	USP,a0
	btst	#5,(sp)
	beq.s	.user
	lea	6(sp),a0
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000_2
	addq.w	#2,a0
.68000_2:
	ENDC
.user:	cmp.w	(a0),d7
	bne.s	.next_break
.recup:	;revenir sur le trap
	subq.l	#2,2(sp)
	;exc #
	move.b	d6,exception(a6)
	move.l	a5,a0
	bsr	_rm_break
.error:	movem.l	tmp_context_buffer(a6),d0-a5
	jmp	p1p0
.continue:
	tst.l	d5
	beq.s	.error
	move.l	d5,-(sp)
	movem.l	tmp_context_buffer(a6),d0-a5
	RESTOREA6
	rts
.trap2:	lea	tmp_context_buffer(a6),a0
	;d0
	move.l	(a0)+,d0
	cmp.w	#-2,d0
	beq.s	.gdos_func

	btst	#BREAK_SYSVDI,d7
	beq.s	.not_vdi
	cmp.w	#$73,d0
	beq.s	.test_func
	bra	.next_break
.not_vdi:
	btst	#BREAK_SYSAES,d7
	beq.s	.not_aes
	cmp.w	#$c8,d0
	beq.s	.test_func
	bra	.next_break
.not_aes:
.test_func:
	;d1
	move.l	(a0)+,a0
	move.l	(a0),a0
	move.w	(a0),d0
.gdos_func:
	cmp.w	d7,d0
	bne	.next_break
	btst	#BREAK_SYSSEC,d7
	beq.s	.recup
	move.l	d7,d0
	swap	d0
	move.b	11(a0),d1
	cmp.b	d1,d0
	bne	.next_break
	bra	.recup

traps_names_table:
	dc.l	unknown_text
	dc.l	trap1_text
	dc.l	trap2_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	unknown_text
	dc.l	trapd_text
	dc.l	trape_text
	dc.l	unknown_text

;a0=break struct
;a1=ASCII buffer
get_system_break_name:
	movem.l	a2-a5,-(sp)
	move.l	a0,a5
	move.l	a1,a3
	move.w	BREAK_VECTOR(a5),d0
	andi.w	#$ff,d0
	sub.w	#$20,d0
	move.w	d0,d1
	asl.w	#2,d1
	;Aes/Vdi
	move.l	traps_names_table(pc,d1.w),-(sp)
	;Trap #2
	move.w	d0,-(sp)
	;Function #
	move.l	BREAK_SYSFLAGS(a5),d1
	btst	#BREAK_SYSALLFUNCS,d1
	beq.s	.all_funcs
	;v_opnwk
	bsr.s	get_function_name

	move.l	a0,-(sp)
	move.w	BREAK_FUNCNO(a5),-(sp)
	pea	catch_one_func_text
	move.l	a3,a0
	bsr	sprintf3
	lea	16(sp),sp
	bra.s	.print
.all_funcs:
	pea	catch_all_funcs_text
	move.l	a3,a0
	bsr	sprintf3
	lea	10(sp),sp
.print:	movem.l	(sp)+,a2-a5
	rts

;d0=trap #
;d1=flags+secno+funcno
get_function_name:
	cmp.w	#2,d0
	beq.s	.trap2
	lea	t1tab,a0
	cmp.w	#1,d0
	beq.s	.trap_recognized
	lea	tdtab,a0
	cmp.w	#13,d0
	beq.s	.trap_recognized
	lea	tetab,a0
	cmp.w	#14,d0
	beq.s	.trap_recognized
.unknown:
	lea	unknown_text(pc),a0
	bra.s	.end
.trap2:	;traiter aes/vdi (5/11)
	btst	#BREAK_SYSVDI,d1
	beq.s	.not_vdi
	lea	vdi_text_table,a0
	bra.s	.chosen
.not_vdi:
	btst	#BREAK_SYSAES,d1
	beq.s	.both
	lea	aes_text_table,a0
	bra.s	.chosen
.both:	lea	trap2_text,a0
	bra.s	.end
.chosen:
.l1:	;end of table
	move.b	(a0)+,d2
	move.b	(a0)+,d0
	beq.s	.unknown
	cmp.b	d0,d1
	beq.s	.function_found
.l2:	tst.b	(a0)+
	bne.s	.l2
	bra.s	.l1
.function_found:
	tst.b	d2
	bmi.s	.end
	move.l	d1,d0
	swap	d0
	cmp.b	d2,d0
	bne.s	.l2
	bra.s	.end
.trap_recognized:
	move.l	a0,a1
	move.w	(a1)+,d0
.l3:	cmp.w	(a1)+,d1
	beq.s	.found
	addq.w	#2,a1
	dbf	d0,.l3
	bra	.unknown
.found:	add.w	(a1)+,a0
.end:	rts

trap1_text:	dc.b	"Gemdos",0
trap2_text:	dc.b	"Aes/Vdi",0
trapd_text:	dc.b	"Bios",0
trape_text:	dc.b	"XBios",0
unknown_text:	dc.b	"Unknown",0
	even

;--- INPUT ---
;a0=
;a1=@ de l'expression a evaluer
;d1.w=nø de vecteur
;d2.l=function #

;--- OUTPUT ---
;a0=@ virtuelle du breakpoint
;a1=@ du buffer de break
;d0<0 si echec
;-1=plus de break
;-2=@ non ecrivible
;-3=bad vector number
;d1.w=nø du break
set_system_break:
	movem.l	d3-d7/a2-a5,-(sp)
	move.w	d0,d4
	move.w	d1,d6
	move.l	d2,d3
	move.l	a0,d5
	move.l	a1,a4

;	move.w	d4,d0
;	moveq	#-1,d1
;	bsr	_check_if_break
;	bpl	.end
	bset	#BREAK_IS_SYSTEM,d6
	bsr	_get_free_break
	bmi	.no_room
	move.l	a0,a5
	move.l	a1,a3
	move.l	d0,d7

	;@ de l'expression a evaluer
	move.l	a5,a0
	move.l	a4,a1
	bsr	_set_break_eval

	;nø du break
	move.w	d7,BREAK_NUMBER(a5)
	;nø du vecteur
	move.w	d6,BREAK_VECTOR(a5)
	;flags+secno+funcno
	move.l	d3,BREAK_SYSFLAGS(a5)
	;plus un break
	addq.l	#1,current_breaks_nb(a6)

	move.b	d6,d0
	;@ de la routine de traitement des exceptions
	lea	_trap_catch,a0
	bsr	_build_breakpt_address

	;d6=break vector
	moveq	#-1,d1
	move.l	d1,(a5)
	move.w	d6,d1
	andi.w	#$ff,d1
	;plus un break pour ce trap
	lsl.w	#2,d1
	move.w	d1,d2
	sub.w	#$80,d2
	lea	traps_caught_nb_table(a6),a1
	addq.l	#1,0(a1,d2.w)
	move.w	d1,a1
	; ancienne @
	move.l	(a1),d1
	; deja reinstallee
	cmp.l	d0,d1
	bne.s	.first_time
	;trouver et sauver la bonne @
	move.w	d6,d0
	bsr	get_os_break
	bmi.s	.no_room
	move.l	(a0),(a5)
	bra.s	.more
.first_time:
	; sauvee
	move.l	d1,(a5)
	; trap detourne
	move.l	d0,(a1)
.more:
	;@ buffer break
	move.l	a5,a0
	;@ virtuelle
	move.l	a3,a1
	;vector
	and.w	#$ff,d6
	move.w	d6,d1
	;break	set:break nb
	move.l	d7,d0
	bra.s	.end
.bad_vector:
	moveq	#-3,d0
	bra.s	.end
.bad_address:
	moveq	#-2,d0
	bra.s	.end
.no_room:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d3-d7/a2-a5
	rts

;d0=# de break os
get_os_break:
	move.l	breaks_addr(a6),a0
	move.l	current_breaks_nb(a6),d1
	beq.s	.not_found
.l1:	tst.l	(a0)
	beq.s	.next
	cmp.w	BREAK_VECTOR(a0),d0
	beq.s	.found
.more:	lea	BREAK_SIZE(a0),a0
	subq.l	#1,d1
	bgt.s	.l1
.not_found:
	moveq	#-1,d0
	rts
.next:	lea	BREAK_SIZE(a0),a0
	bra.s	.l1
.found:	tst.l	(a0)
	bmi.s	.more
	rts
;  #] system_break:
;  #[ Ctl_Alt_D:[Ctl_Alt_D]

ctrl_alt_d:
	lea	traps_form_table(pc),a0
	jmp	form_do

traps_form_table:
 dc.l draw_page_traps-traps_form_table
 dc.l line_up_traps-traps_form_table
 dc.l line_down_traps-traps_form_table
 dc.l page_up_traps-traps_form_table
 dc.l page_down_traps-traps_form_table
 dc.l home_traps-traps_form_table
 dc.l shift_home_traps-traps_form_table
 dc.l init_traps-traps_form_table
 dc.l traps_title_text-traps_form_table

line_up_traps:
 cmp.l a4,a5
 bne.s .no_change
.aes_to_vdi:
 subq.w #3,a5
.no_change:
 cmp.l a3,a5
 beq.s .it_was_start
 subq.w #1,a5
.loop:
 tst.b -(a5)
 bne.s .loop
 addq.w #1,a5
 moveq #0,d0
 rts
 moveq #0,d0
 rts
.go_to_start:
 moveq #0,d0
 rts
.it_was_start:
 moveq #-1,d0
 rts

line_down_traps:
 move.l a5,d0
.loop1:
 tst.b (a5)+
 bne.s .loop1
 tst.b (a5)
 beq.s .last_reached
 moveq #0,d0
 rts
.last_reached:
 cmp.l a4,a5
 blt.s .change
 move.l d0,a5
 moveq #-1,d0
 rts
.change:
 move.l a4,a5
 moveq #0,d0
 rts

page_up_traps:
 move.w column_len(a6),d0
 subq.w #2,d0
.loop:
 move.w d0,-(sp)
 bsr line_up_traps
 tst.w d0
 movem.w (sp)+,d0
 bmi.s .top
 dbf d0,.loop
.top:
 moveq #0,d0
 rts
.nothing:
 moveq #-1,d0
 rts

page_down_traps:
 move.w column_len(a6),d0
 subq.w #2,d0
.loop:
 move.w d0,-(sp)
 bsr line_down_traps
 tst.w d0
 movem.w (sp)+,d0
 bmi.s .nothing
 dbf d0,.loop
.top:
 moveq #0,d0
 rts
.nothing:
 moveq #-1,d0
 rts

home_traps:
 lea vdi_text_table,a5
 moveq #0,d0
 rts
.it_was_home:
 moveq #-1,d0
 rts

shift_home_traps:
 lea aes_text_table,a5
.loop:
 tst.b (a5)
 beq.s .found
 move.l a5,d0
 addq.w #2,a5
.1
 tst.b (a5)+
 bne.s .1
 bra.s .loop
.found:
 move.l d0,a5
 moveq #0,d0
 rts

init_traps:
 lea vdi_text_table,a3
 lea aes_text_table,a4
 move.l a3,a5
 rts

draw_page_traps:
 movem.l d0-d2/a0-a5,-(sp)
 move.w column_len(a6),d0
 subq.w #2,d0
 move.l #$00020001,x_pos(a6)
.redraw_loop:
 move.w d0,-(sp)
 tst.b (a5)
 bne.s .ok
 cmp.l a4,a5
 bgt.s .clear
 move.l a4,a5
.ok:
 lea line_buffer(a6),a0
 move.b 1(a5),d2
 ext.w d2
 move.b (a5),d1
 cmp.b #-1,d1
 beq.s .no_sub
 ext.w d1
 move.w d1,-(sp)
 move.w d2,-(sp)
 pea 2(a5)
 pea .vdi_sub_format(pc)
 bsr sprintf3
 lea 12(sp),sp
 bra.s .print
.no_sub:
 move.w d2,-(sp)
 pea 2(a5)
 pea .vdi_format(pc)
 bsr sprintf3
 lea 10(sp),sp

.print:
 jsr print_instruction

 lea 2(a5),a0
 bsr strlen3
 addq.w #3,d0
 add.w d0,a5
 addq.w #1,y_pos(a6)
 move.w (sp)+,d0
 dbf d0,.redraw_loop
 movem.l (sp)+,d0-d2/a0-a5
 rts
.clear_loop:
 move.w d0,-(sp)
.clear:
 lea line_buffer(a6),a2
 sf (a2)
 jsr print_instruction
 addq.w #1,y_pos(a6)
 move.w (sp)+,d0
 dbf d0,.clear_loop
 movem.l (sp)+,d0-d2/a0-a5
 rts


.vdi_format:	dc.b	" %s #%=Sd",0
.vdi_sub_format:	dc.b	" %s #%=Sd,#%Sd",0
	even
;  #] Ctl_Alt_D:
;  #[ Call_shell:[!]
call_shell:
	move.l	$4f6.w,d7
	beq.s	.flash
	;test if readable
	st	no_eval_flag(a6)
	suba.l	a0,a0
	lea	call_shell_text,a2
	bsr	get_expression
	bne.s	.end
	lea	ro_child_struct(a6),a1
	move.l	d7,(a1)
	move.l	a0,4(a1)
	st	16(a1)
	sf	17(a1)
	move.l	a1,a0
	jsr	call_child
	move.l	d0,d7
	bne.s	.error
	bsr	sbase0_sbase1
	jsr	get_char
	bsr	sbase1_sbase0
.error:
	move.l	d7,d0
	bsr.s	get_system_error_message
	move.l	a0,a2
.print:
	bra	print_result
.flash:
	lea	no_shell_error_text,a2
	bra.s	.print
.end:
	rts
;In:d0=error number
;Out:a0=message @
get_system_error_message:
	cmp.w	#1,d0
	beq.s	.shell_error
	tst.w	d0
	bgt.s	.put_number
	neg.w	d0
	cmp.w	#67,d0
	bgt.s	.error
	asl.w	#2,d0
	lea	system_messages_table,a0
	move.l	0(a0,d0.w),a0
	rts
.shell_error:
	lea	shell_general_error,a0
	rts
.error:	lea	system_unknown,a0
	rts
.put_number:
	lea	lower_level_buffer(a6),a0
	move.l	a0,-(sp)
	move.w	d0,-(sp)
	pea	shell_result_text
	bsr	sprintf3
	addq.w	#6,sp
	move.l	(sp)+,a0
	rts

;  #] Call_shell:
;  #[ _load_prg_vars:
;a0=@ TEXT
_load_prg_vars:
	movem.l	d3-d7/a2-a5,-(sp)
	lea	-$100(a0),a0
	move.l	a0,p1_basepage_addr(a6)

	move.l	before_ctrll_addr(a6),a0
	jsr	clr_table_end

	moveq	#0,d7	; no error
	lea	exec_name_buf(a6),a5
	move.l	a5,a0
	bsr	get_exec_name
	bmi	.ropen
	move.l	a5,a0
	bsr	open_header
	move.l	a1,a3
	move.l	d1,d4
	addq.w	#1,d0
	beq	.ropen
	addq.w	#1,d0
	beq	.rread1
	addq.w	#1,d0
	beq	.rexec
	;updater les tailles internes a partir du header
	move.l	a3,a0
	bsr	update_header_sizes
;--------------------------------------
	;allouer les symboles+1
	move.l	sym_size(a6),d0
	addq.l	#1,d0
	st	d1
	moveq	#2,d2
	jsr	reserve_memory
	beq	.rmem
	move.l	d0,d3
	;seeker de TEXT+DATA+1c
	move.l	text_size(a6),d0
	add.l	data_size(a6),d0
	add.l	#$1c,d0
	move.l	d4,d1
	moveq	#0,d2
	bsr	seek_file
	bmi	.rread2

	;lire les symboles
	move.l	d3,a0
	move.l	sym_size(a6),d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	sym_size(a6),d0
	bne	.rread2

;	bsr	reserve_for_p1
;	beq	.rmem
;	move.l	d0,p1_basepage_addr(a6)
;	;lire le prg
;	move.l	d0,a0
;	;+$100 pour la basepage
;	lea	$100(a0),a0
;	move.l	p1_disk_len(a6),d0
;	move.l	d4,d1
;	bsr	read_file
;	bne	.rread
;--------------------------------------
	;fermer le fichier
	move.l	d4,d0
	bsr	close_file

	move.l	p1_basepage_addr(a6),a5
	lea	text_buf(a6),a4
	lea	text_size(a6),a3

	;updater les adresses internes a partir des tailles internes
;a0=process text @
;a1=process header @
;a2=process header sizes
	lea	$100(a5),a0
	move.l	a4,a1
	move.l	a3,a2
	bsr	update_header_addresses
;--------------------------------------
;	;reloger le prog
;	move.l	a4,a1
;	move.l	a3,a2
;	lea	$100(a5),a0
;	move.l	p1_disk_len(a6),d0
;	bsr	reloc_exec
;
;	;construire la basepage
;	move.l	a5,a0
;	move.l	a3,a1
;	move.l	a4,a2
;	bsr	build_basepage
;	;detourner la fin de process
;	move.l	a5,a0
;	bsr	install_recup_process
;	;initialiser les registres au depart
;	bsr	p1_registers_init
;--------------------------------------
	;updater les variables 680xxesques constantes
	bsr	update_text_data_bss

	;updater les symboles dri
	move.l	d3,a0
	bsr	get_exec_symbols
	move.l	d3,a0
	move.l	sym_size(a6),d0
	addq.l	#1,d0
	jsr	free_memory
	jsr	create_var_tree
;--------------------------------------
;	bsr	clr_bss
;	bsr	tell_residant
;--------------------------------------
	pea	my_dta+DTA_NAME(a6)
	move.l	exec_sym_nb(a6),-(sp)
	pea	prg_vars_loaded_text
	lea	higher_level_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf3
	lea	12(sp),sp
	bsr	print_result
	bra.s	.end
.ropen:	moveq	#-1,d7
	lea	higher_level_buffer(a6),a2
	move.l	a5,-(sp)
	pea	fnf_error_text
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_error	;no close
	bra.s	.end
.rread2:	move.l	d0,-(sp)
	move.l	sym_size(a6),d0
	addq.l	#1,d0
	jsr	free_memory
	move.l	(sp)+,d0
.rread1:	moveq	#-2,d7
	not.l	d0
	lea	higher_level_buffer(a6),a2
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	pea	read_error_text
	move.l	a2,a0
	bsr	sprintf3
	lea	10(sp),sp
	bra.s	.print
.rexec:	moveq	#-3,d7
	lea	executable_error_text,a2
	bra.s	.print
.rmem:	moveq	#-4,d7
	lea	memory_error_text,a2
;	bra.s	.print
.print:	bsr	print_error
	move.l	d4,d0
	bsr	close_file
.end:	jsr	redraw_all_windows
	move.l	d7,d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;  #] _load_prg_vars:
;  #[ ScreenDump:[Alt_Help]
screen_dump:
	move.l	a6,-(sp)
	move.l	$506.w,a0
	jsr	(a0)
	tst.l	d0
	bmi.s	.no_dump
	move.l	$502.w,a0
	jsr	(a0)
.no_dump:	move.l	(sp)+,a6
	rts
;  #] ScreenDump:(Alt_Help)
;  #[ Switch_rez:[Ctrl_O]
ctrl_o:	tst.b	high_rez(a6)
	bne.s	.end
	tst.b	mid_rez(a6)
	bne.s	.med
.low:	bra.s	f9
.med:	bra.s	f8
.end:	rts
;  #] Switch_rez:
;  #[ F8: switch to low res
f8:
	IFNE	ATARIST
	tst.b	low_rez(a6)
	bne.s	.end

	; prov switch interdit sur grand ecran
	tst.b	meta_rez(a6)
	bne.s	.end
	tst.b	high_rez(a6)
	beq.s	.not_in_high
	tst.b	electronic_switch_flag(a6)
	beq.s	.end
.not_in_high:
	;patch pour rs (sinon on peut plus revenir de basse vers haute)
	cmp.l	#RS232_OUTPUT,device_number(a6)
	beq.s	.end
	jsr	put_color_monitor
	jsr	put_320_200
	moveq	#-1,d0
	lea	windows_to_redraw(a6),a0
	move.l	d0,(a0)+
	move.w	d0,(a0)
	jsr	windows_init
	lea	low_rez_text,a2
	bsr	print_result
.end:
	ENDC
	rts
;  #] F8:
;  #[ F9: switch to mid res
f9:
	IFNE	ATARIST
	tst.b	mid_rez(a6)
	bne.s	.end
	; prov switch interdit sur grand ecran
	tst.b	meta_rez(a6)
	bne.s	.end
	tst.b	high_rez(a6)
	beq.s	.not_in_high
	tst.b	electronic_switch_flag(a6)
	beq.s	.end
.not_in_high:
	jsr	put_color_monitor
	jsr	put_640_200
	jsr	clear_screen
	moveq	#-1,d0
	lea	windows_to_redraw(a6),a0
	move.l	d0,(a0)+
	move.w	d0,(a0)
	jsr	windows_init
	lea	mid_rez_text,a2
	bsr	print_result
.end
	ENDC
	rts
;  #] F9:
;  #[ F10: switch to high res
f10:
	IFNE	ATARIST
	tst.b	high_rez(a6)
	bne.s	.end
	; prov switch interdit sur grand ecran
	tst.b	meta_rez(a6)
	bne.s	.end
	;interdit de switcher si pas branche en monochrome
	cmp.w	#2,initial_rez(a6)
	bne.s	.end
	jsr	put_mono_monitor
	jsr	put_640_400
	jsr	clear_screen
	moveq	#-1,d0
	lea	windows_to_redraw(a6),a0
	move.l	d0,(a0)+
	move.w	d0,(a0)
	jsr	windows_init
	lea	high_rez_text,a2
	bsr	print_result
.end:
	ENDC
	rts
;  #] F10:
;  #[ Not_palette:[Ctl_Alt_I]
not_palette:
	not.b	inverse_video_flag(a6)
_not_palette:
	not.l	internal_palette(a6)
	tst.b	screen0_flag(a6)
	beq.s	.nopal
	bsr	vsetipal
.nopal:	bsr	clear_screen
	lea	windows_to_redraw(a6),a4
	moveq	#-1,d0
	move.l	d0,(a4)+
	move.w	d0,(a4)+
	jmp	windows_init
;  #] Not_palette:
;  #[ Reset:[[Sft_]Ctl_Alt_Del]

cold_reset:
 clr.l $420.w
warm_reset:
 move.l $4.w,a0
 jmp (a0)

;  #] Reset:
;  #[ View: [V]

view:	cmp.l	#RS232_OUTPUT,device_number(a6)
	beq.s	.end
	tst.b	screen0_flag(a6)
	bne.s	.put_user
	sf	v_screen1_flag(a6)
	jsr	sbase1_sbase0
	rts
.put_user:
	st	v_screen1_flag(a6)
	jsr	sbase0_sbase1
.end:	rts
;  #] View:
;  #[ system_print:
system_print:
	move.b	(a0)+,d0
	beq.s	.end
	move.l	a0,-(sp)
	bsr.s	vt52_putchar
	move.l	(sp)+,a0
	bra.s	system_print
.end:
	rts
;  #] system_print:
;  #[ vt52_putchar:
vt52_putchar:
	move.w	d0,-(sp)
	move.l	#$30002,-(sp)
	trap	#13
	addq.w	#6,sp
	rts
;  #] vt52_putchar:
;  #[ system_getkey:
system_getkey:	
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	rts
;  #] system_getkey:

