	MC68000
	
	incdir	'g:\sources\gemremot\stngdevp'
	incdir	'g:\sources\gemremot\stngdevp\sting'
	incdir	'g:\sources\gemremot\stngdevp\bs_comp'

	include	'gemdos.s'
	include	'bios.s'
	include	'xbios.s'
	include	'annexes.s'

	output	'.prg'

VERSION:	equ	$0100
PORT:		equ	4444

MOUSE_MOTION	equ	0
BUTTON_PRESSED	equ	1
BUTTON_RELEASED	equ	2
KBD_PRESS	equ	3
KBD_RELEASE	equ	4
	
begin:
	jmp	start

****************
* Macros STING *
****************
	opt	w-
	include	'transprt.i'
	opt	w+
	
**************************************
* GEM REMOTE : le corps du programme *
**************************************
*************************
* GEM Remote : l'it VBL *
*************************
	dc.l	gem_remote_control
xbra_VBL:
	dc.b	'XBRA'
	dc.l	ID
old_vbl:
	dc.l	nothing
new_vbl:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	conn_handle
	bne.s	.connected
	bsr.s	open_socket
	bra.s	.end_vbl
.connected:
	bsr	receive_block
.end_vbl:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	old_vbl(pc),-(sp)
	rts

********************************
* GEM Remote : la routine vide *
********************************
nothing:
	rte

**********************************
* GEM Remote : proc‚dures utiles *
**********************************
drivers:	dc.l	0
tpl:		dc.l	0
data_block:	dc.l	0
msg:		dc.l	0
conn_handle:	dc.w	0
info_block:	dcb.b	sizeof_UDPIB,0
	
	even
open_socket:
	tst.w	conn_handle
	bne.s	.no_open
	UDP_open	#0,gem_remote_control_port
	move.w	d0,conn_handle
	blt.s	.open_error
	lea	info_block(pc),a0
	move.l	#UDPI_defer,UDPIB_request(a0)
	UDP_info	conn_handle,info_block
	tst.w	d0
	blt.s	.switch_error
.no_open:
	rts
.open_error:
	clr.w	conn_handle
	rts
.switch_error:
*	bra.s	close_socket

close_socket:
	move.w	conn_handle(pc),d0
	beq.s	.no_close
	UDP_close	d0
	clr.w	conn_handle
.no_close:
	rts
	
packet:
	dcb.b	32,0

button_state:
	dc.b	$f8
	even

call_mouse_vector:
	move.w	sr,d7
	or.w	#$700,sr
	move.w	d7,-(sp)
	move.l	#packet,a0
	move.l	a0,-(sp)
	move.l	kbd_vbase(pc),a1
	move.l	KBDVECS.mousevec(a1),a1
	jsr	(a1)
	addq.w	#4,sp
	move.w	(sp)+,d7
	move.w	d7,sr
	rts

call_kbd_vector:
	move.w	sr,d7
	or.w	#$700,sr
	move.w	d7,-(sp)
	clr.w	d0
	move.b	packet(pc),d0
	lea	$f96.w,a0	; ‡a, c'est mal mais bon
	move.l	kbd_vbase(pc),a1
	move.l	-4(a1),a1
	jsr	(a1)
	move.w	(sp)+,d7
	move.w	d7,sr
	rts

mouse_motion:
; d0.w = dx, d1.w = dy
	ext.l	d0
	bmi.s	.dx_negatif
.dx_positif:
	divs.w	#128,d0
	move.b	#128,d2
	swap	d0
	bra.s	.ok_dx
.dx_negatif:
	neg.l	d0
	divs.w	#127,d0
	move.b	#-127,d2
	swap	d0
	neg.w	d0
.ok_dx:
	ext.l	d1
	bmi.s	.dy_negatif
.dy_positif:
	divs.w	#128,d1
	move.b	#128,d3
	swap	d1
	bra.s	.ok_dy
.dy_negatif:
	neg.l	d1
	divs.w	#127,d1
	move.b	#-127,d3
	swap	d1
	neg.w	d1
.ok_dy:
	movem.l	d0-d3/a1,-(sp)
	move.b	button_state(pc),(a1)+
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	bsr	call_mouse_vector
	movem.l	(sp)+,d0-d3/a1
	swap	d0
	subq.w	#1,d0
	bmi.s	.no_dx
.dx:
	movem.l	d0-d3/a1,-(sp)
	move.b	button_state(pc),(a1)+
	move.b	d2,(a1)+
	clr.b	(a1)+
	bsr	call_mouse_vector
	movem.l	(sp)+,d0-d3/a1
	dbf	d0,.dx
.no_dx:
	swap	d1
	subq.w	#1,d1
	bmi.s	.no_dy
.dy:
	movem.l	d0-d3/a1,-(sp)
	move.b	button_state(pc),(a1)+
	clr.b	(a1)+
	move.b	d3,(a1)+
	bsr	call_mouse_vector
	movem.l	(sp)+,d0-d3/a1
	dbf	d1,.dx
.no_dy:	
	rts
	
traite_block:
	move.l	msg(pc),a0
	lea	packet(pc),a1
	cmp.w	#MOUSE_MOTION,2(a0)
	bne.s	.button_pressed
.mouse_motion:
	move.w	4(a0),d0
	move.w	6(a0),d1
	bsr	mouse_motion
	bra	.no_traitement
.button_pressed:
	cmp.w	#BUTTON_PRESSED,2(a0)
	bne.s	.button_released
	move.w	4(a0),d0
	and.w	#%11,d0
	lsr.b	d0
	bcc.s	.button_pressed_ok
	or.b	#%10,d0
.button_pressed_ok:
	or.b	button_state(pc),d0
	move.b	d0,button_state
	move.b	d0,(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	bsr	call_mouse_vector
	bra.s	.no_traitement
.button_released:
	cmp.w	#BUTTON_RELEASED,2(a0)
	bne.s	.keyboard_press
	move.w	4(a0),d0
	and.w	#%11,d0
	lsr.b	d0
	bcc.s	.button_released_ok
	or.b	#%10,d0
.button_released_ok:
	not.b	d0
	and.b	button_state(pc),d0
	move.b	d0,button_state
	move.b	d0,(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	bsr	call_mouse_vector
	bra.s	.no_traitement
.keyboard_press:
	cmp.w	#KBD_PRESS,2(a0)
	bne.s	.keyboard_release
	move.w	4(a0),d0
	and.w	#$7f,d0
	move.b	d0,(a1)+
	bsr	call_kbd_vector
	bra.s	.no_traitement
.keyboard_release:
	cmp.w	#KBD_RELEASE,2(a0)
	bne.s	.no_traitement
	move.w	4(a0),d0
	and.w	#$7f,d0
	or.w	#$80,d0
	move.b	d0,(a1)+
	bsr	call_kbd_vector
*	bra.s	.no_traitement
.no_traitement:
	rts

receive_block:
	tst.w	conn_handle
	beq.s	.no_block
.receive_block:
	CNget_NDB	conn_handle
	tst.l	d0
	beq.s	.no_block
	cmp.l	#E_LOCKED,d0
	beq.s	.no_block
.ok_block:
	move.l	d0,a0
	move.l	d0,data_block
	move.w	NDB_len(a0),d1
	cmp.w	#2,d1
	blt.s	.free_block
	move.l	NDB_ndata(a0),a1
	move.l	a1,msg
	cmp.w	(a1),d1
	bne.s	.free_block
	bsr	traite_block
.free_block:
	move.l	data_block(pc),a0
	KRfree.i	NDB_ptr(a0)
	KRfree.i	data_block(pc)	
	bra.s	.receive_block
.no_block:
	rts
	
**********************
* GEM Remote Control *
**********************
	even.l
gem_remote_control:
gem_remote_control_version:
	dc.w	VERSION
gem_remote_control_port:
	dc.w	PORT
	
**********************************************************
* Routine en reset pour effacer la cookie-jar sur les ST *
**********************************************************

	even.l
old_resvalid:
	dc.l	0
reset_vector:
	dc.b	'XBRA'
	dc.l	ID
old_reset_vector:
	dc.l	0	
erase_cookie_jar:
	clr.l	$5a0.w
	move.l	old_resvalid(pc),$426.w
	move.l	old_reset_vector(pc),$42a.w
	jmp	(a6)

*******************************
* Quelques variables globales *
*******************************
	
cpu:		dc.l	0
kbd_vbase:	dc.l	0

****************************
* Installation du r‚sident *
****************************
ID:		equ	'GREM'
PARAM:		equ	gem_remote_control

COOKIE_JAR_DEFAULT_SIZE:	equ	32

start:
	Init_prg	#$500
	
	Cconws	present(pc)
	
	Supers	#0
	move.l	d0,super
	
	move.l	#ID,d0
	bsr	search_cookie
	tst.l	d0
	bne.s	end_error
	move.l	#'STiK',d0
	bsr	search_cookie
	tst.l	d0
	beq.s	end_sting_error
	move.l	(a0),drivers
	bsr	sting_corruption_test
	tst.l	d0
	beq.s	end_sting_corrupted
	bsr	get_tpl
	tst.l	d0
	beq.s	end_sting_no_tpl
	move.l	d0,tpl

	Kbdvbase
	move.l	d0,kbd_vbase
	
	bsr	install
end_ok:
	Cconws	installed(pc)
	Supers	super(pc)
	Ptermres	#start-begin+$100,#0
end_error:
	Cconws	not_installed(pc)
	bra.s	end
end_sting_error:
	Cconws	sting_missing(pc)
	bra.s	end
end_sting_corrupted:
	Cconws	sting_corrupted(pc)
	bra.s	end
end_sting_no_tpl:
	Cconws	sting_no_tpl(pc)
end:
	Supers	super(pc)
	Pterm0

search_cookie:
; renvoie 0 si le cookie n'est pas pr‚sent
; sinon A0 pointe sur le paramŠtre du cookie et renvoie le cookie
	move.l	d0,d1
	move.l	$5a0.w,d0
	move.l	d0,a0
	tst.l	d0
	beq.s	.end_search
	move.l	d1,d0
.loop_search:
	move.l	(a0)+,d1
	beq.s	.end_loop
	cmp.l	d0,d1
	beq.s	.end_search	
	addq.l	#4,a0
	bra.s	.loop_search
.end_loop:
	moveq	#0,d0
.end_search:
	rts

install:
	bsr.s	install_vbl
	bsr.s	install_cookie
	bsr.s	get_cpu
	rts

get_cpu:
	move.l	#'_CPU',d0
	bsr.s	search_cookie
	tst.l	d0
	beq.s	.write_cpu	; 68000 par d‚faut
	move.l	(a0),d0
.write_cpu:
	move.l	d0,cpu
	rts

install_vbl:
	Setexc	#$1c,-1.l
	move.l	d0,old_vbl
	Setexc	#$1c,new_vbl
	rts
	
install_cookie:
	move.l	$5a0.w,d0
	move.l	d0,a0
	tst.l	d0
	beq.s	.create_cookie_jar
	moveq	#0,d1
.search_free_cookie:
	addq.l	#1,d1
	move.l	(a0)+,d0
	beq.s	.end_search_free
	addq.l	#4,a0
	bra.s	.search_free_cookie
.end_search_free:
	move.l	(a0),d0
	cmp.l	d0,d1		; test si place libre
	bge.s	.grow_cookie_jar; non -> on agrandit la cookie-jar
	move.l	#ID,-4(a0)
	move.l	#PARAM,(a0)
	clr.l	4(a0)
	move.l	d0,8(a0)
	rts
.create_cookie_jar:
	bsr.s	malloc_cookie_jar
	tst.l	d0
	bne.s	.no_cookie_jar
	bsr.s	install_cookie
.no_cookie_jar:
	rts
.grow_cookie_jar:
	move.l	d1,d0
	bsr.s	grow_cookie_jar
	tst.l	d0
	bne.s	.no_grow_cookie_jar
	bsr.s	install_cookie
.no_grow_cookie_jar:
	rts
	
malloc_cookie_jar:
	Malloc	#COOKIE_JAR_DEFAULT_SIZE*8
	tst.l	d0
	beq.s	.error
	move.l	d0,a0
	lea	st_cookie_jar(pc),a1
	move.w	(a1)+,d1
	subq.w	#1,d1
.copy_st_cookie_jar
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d1,.copy_st_cookie_jar
	clr.l	(a0)+
	move.l	#COOKIE_JAR_DEFAULT_SIZE,(a0)+
	move.l	d0,$5a0.w
	move.l	$42a.w,old_reset_vector		; installe routine
	move.l	$426.w,old_resvalid		; en reset
	move.l	#erase_cookie_jar,$42a.w	; pour effacer
	move.l	#$31415926,$426.w		; le contenu de $5a0
	moveq	#0,d0
	rts
.error:
	moveq	#-1,d0
	rts
	
grow_cookie_jar:
; d0 : taille actuelle
	addq.l	#8,d0
	move.l	d0,-(sp)
	lsl.l	#3,d0
	Malloc	d0
	tst.l	d0
	beq.s	.error
	move.l	(sp)+,d1	; Taille nouvelle cookie jar
	move.l	d0,a1		; adr nouvelle cookie jar
	move.l	$5a0.w,a0	; adr ancienne cookie jar
.copy_cookie_jar:
	move.l	(a0)+,(a1)+
	beq.s	.end_copy
	move.l	(a0)+,(a1)+
	bra.s	.copy_cookie_jar
.end_copy:
	move.l	d1,(a1)+
	move.l	d0,$5a0.w
	moveq	#0,d0
	rts
.error:
	addq.w	#4,sp
	moveq	#-1,d0
	rts	

sting_corruption_test:
	moveq	#0,d0
	move.l	drivers(pc),a0
	cmp.l	#'STiK',DRV_LIST_magic(a0)
	bne.s	.end_test
	cmp.l	#'magi',DRV_LIST_magic+4(a0)
	bne.s	.end_test
	cmp.w	#'c'<<8,DRV_LIST_magic+8(a0)
	bne.s	.end_test
	moveq	#1,d0
.end_test:
	rts

get_tpl:
	get_dftab	#transport_driver
	rts
	
st_cookie_jar:
	dc.w	6
	dc.l	'_MCH',0
	dc.l	'_CPU',0
	dc.l	'_FPU',0
	dc.l	'_FDC',0
	dc.l	'_VDO',0
	dc.l	'_SND',1

super:
	dc.l	0
	
present:
	dc.b	13,11,27,'pGEM Remote v '
	IFNE	VERSION&$f000
	dc.b	(VERSION&$f000)>>12+'0'
	ENDC
	dc.b	(VERSION&$f00)>>8+'0'
	dc.b	'.'
	dc.b	(VERSION&$f0)>>4+'0'
	dc.b	(VERSION&$f)+'0'
	dc.b	' by Seb/The Removers',27,'q',13,11
	dc.b	'A ',27,'pFRENCH',27,'q product for all the ATARIs (& compatibles)',13,11,0
	even
installed:
	dc.b	'GEM Remote is now installed... Enjoy it !',13,11,0
	even
not_installed:
	dc.b	'GEM Remote is already installed !!',13,11,0
	even
sting_missing:
	dc.b	'Sorry but GEM Remote need STiNG to run...',13,11,0
	even
sting_corrupted:
	dc.b	'Sorry but STiNG seems to be corrupted...',13,11,0
	even
sting_no_tpl:
	dc.b	'STiNG Transport Driver not found...',13,11,0
	even
transport_driver:
	dc.b	'TRANSPORT_TCPIP',0
	even