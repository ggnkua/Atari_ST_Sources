* WERCS test program written with DevpacST version 2

* style notes:
* subroutines are named in upper-case, everything else
* is lower-case
* low registers (d0-d2/a0-a2) are trashable, other registers
* are used for parameters

	opt	a+	automatic PC mode to save bytes

* On inclut la biblio des macros du GEM
	include	gemmacro.s

* Puis, le fichier des ‚quivalences pour la ressource.  Ce fichier est
* issu  de  WERCS  qui  le g‚nŠre tout seul au format assembleur. Avec
* K_Ressource  il faut le refaire … la main. En fait … la construction
* chaque objet re‡oit un nom mais l'‚diteur de ressources lui attribue
* aussi  un  num‚ro. Nous  avons donc un petit fichier d'‚quivalences,
* nous  permettant  de  travailler  avec  les  noms  ce  qui  est plus
* pratique. Ce fichier a donc la forme suivante (par ex.)
* 
* bouton1  equ  3
* annul    equ  4 etc...

	include	wrsc.i

* Une macro pour calculer l'adresse d'un objet
OBJECT	macro	tree,object,result,scratchreg
	move.w	\2,\4
	mulu	#ob_sizeof,\4
	lea	0(\1,\4),\3
	endm

* the object structure
	rsreset
ob_next	rs.w	1
ob_head	rs.w	1
ob_tail	rs.w	1
ob_type	rs.w	1
ob_flags	rs.w	1
ob_state	rs.w	1
ob_spec	rs.l	1
ob_x	rs.w	1
ob_y	rs.w	1
ob_width	rs.w	1
ob_height	rs.w	1
ob_sizeof	rs.w	0

* various AES constants
type_tree	equ	0
type_string	equ	5
WF_WORKXYWH	equ	4
WF_NEWDESK	equ	14
FMD_START	equ	0
FMD_GROW	equ	1
FMD_SHRINK	equ	2
FMD_FINISH	equ	3
G_BUTTON	equ	26
bitSELECTED	equ	0
te_txtlen	equ	24
MN_SELECTED	equ	10

* Le programme lui-mˆme, on retrouve notre START. Pour le reste,
* un peu de concentration et vous serez tir‚s d'affaire!!!!

	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp
	bra	start

INITIALISE
	appl_init
	move.w	d0,ap_id		store the application id
	rsrc_load	#rsc_filename
	bne.s	rloaded_ok
* resource load failed
	form_alert	#1,#badrsc_alert
	bra	terminate
rloaded_ok
	graf_mouse	#0		mouse is an arrow
	sf	deskflag
	rsrc_gaddr	#type_tree,#Menu1
	move.l	addr_out,menu_ptr
	menu_bar	menu_ptr,#1
	wind_get	#0,#WF_WORKXYWH
	lea	int_out+2,a0
	lea	screenx,a1
	REPT	4
	move.w	(a0)+,(a1)+		copy screen size
	ENDR
	clr.b	editstring
	move.w	#DRadio1,radio
	rts

* set or reset the Desktop pattern
* in:a3=new address
SETDESK	move.l	a3,int_in+4
	clr.w	int_in+8
	wind_set	#0,#WF_NEWDESK
	form_dial	#FMD_FINISH,#0,#0,#0,#0,screenx,screeny,screenw,screenh
	rts

DEINITIALISE
	tst.b	deskflag
	beq.s	.nodesk
		sub.l	a3,a3
		bsr	SETDESK
		sf	deskflag
.nodesk	menu_bar	menu_ptr,#0
	rsrc_free
terminate
	appl_exit
	move.l	#$4c0000,-(sp)
	trap	#1

* general routine to produce a dialog box and handle interaction
* in:a3=dialog address,d3.w=editable object number
* out:d3.w=exit object number
HANDLE_DIALOG
	movem.l	d4-d7,-(sp)	we need some local variables

	form_center	a3
	movem.w	int_out+2,d4-d7		d4-d7=x,y,w,h
	form_dial	#FMD_START,#0,#0,#0,#0,d4,d5,d6,d7
	move.w	d6,d0
	asr.w	#1,d0
	add.w	d4,d0			=x+w/2
	move.w	d7,d1
	asr.w	#1,d1
	add.w	d5,d1			=y+h/2
	form_dial	#FMD_GROW,d0,d1,#0,#0,d4,d5,d6,d7
	objc_draw	a3,#0,#10,d4,d5,d6,d7
	form_do	a3,d3
	move.w	d0,d3			return result
	move.w	d6,d0
	asr.w	#1,d0
	add.w	d4,d0			=x+w/2
	move.w	d7,d1
	asr.w	#1,d1
	add.w	d5,d1			=y+h/2
	form_dial	#FMD_SHRINK,d0,d1,#0,#0,d4,d5,d6,d7
	form_dial	#FMD_FINISH,#0,#0,#0,#0,d4,d5,d6,d7
	OBJECT	a3,d3,a0,d0
	cmp.b	#G_BUTTON,ob_type+1(a0)
	bne.s	.notbut
	bclr	#bitSELECTED,ob_state+1(a0)
.notbut	movem.l	(sp)+,d4-d7
	rts

* set a tedinfo record
* in:a3=tree,d3.w=object,a4=source string
SET_TEDINFO
	OBJECT	a3,d3,a0,d0
	move.l	ob_spec(a0),a0		the tedinfo record ptr
	move.w	te_txtlen(a0),d2	max length
	subq.w	#1,d2
* copy up to d2.w chars
	move.l	(a0),a0			destination buffer addr
.copy	move.b	(a4)+,d0
	beq.s	.done
	move.b	d0,(a0)+		copy char
	subq.w	#1,d2
	bne.s	.copy			up to the limit
.done	clr.b	(a0)
	rts

* extract a tedinfo record
* in:a3=tree,d3.w=object,a4=where to copy it
GET_TEDINFO
	OBJECT	a3,d3,a0,d0
	move.l	ob_spec(a0),a0		the tedinfo record ptr
	move.l	(a0),a0			the actual text
.copy	move.b	(a0)+,(a4)+
	bne.s	.copy
	rts

* select a particular radio button
* in:a3=tree,d3.w=parent,d4.w=button
SET_BUTTON
	OBJECT	a3,d3,a0,d0
	move.w	ob_head(a0),d2
.until	cmp.w	d3,d2
	beq.s	.done
	OBJECT	a3,d2,a0,d0
	bclr	#bitSELECTED,ob_state+1(a0)
	cmp.w	d4,d2
	bne.s	.boring
	bset	#bitSELECTED,ob_state+1(a0)
.boring	move.w	ob_next(a0),d2
	bra.s	.until
.done	rts

* return which button of a group is selected
* in:a3=tree,d3=parent
* out:d3=selected button number
GET_BUTTON
	OBJECT	a3,d3,a0,d0
	move.w	ob_head(a0),d2
.until	cmp.w	d3,d2
	beq.s	.done
		OBJECT	a3,d2,a0,d0
		btst	#bitSELECTED,ob_state+1(a0)
		bne.s	.gotit			if found
		move.w	ob_next(a0),d2
		bra.s	.until
.gotit	move.w	d2,d3				result
.done	rts

* handle a particular dialog box
TEST_DIALOG
	movem.l	d3/d4/a3/a4,-(sp)
	rsrc_gaddr	#type_tree,#TestDialog
	move.l	addr_out,a3
	moveq	#DEditable,d3
	lea	editstring,a4
	bsr	SET_TEDINFO
	moveq	#DParent,d3
	move.w	radio,d4
	bsr	SET_BUTTON
	moveq	#DEditable,d3
	bsr	HANDLE_DIALOG
	cmp.w	#DOK,d3
	bne.s	.notok
	lea	editstring,a4
	moveq	#DEditable,d3
	bsr	GET_TEDINFO
	moveq	#DParent,d3
	bsr	GET_BUTTON
	move.w	d3,radio
.notok	movem.l	(sp)+,d3/d4/a3/a4
	rts

* handle a menu click
* in:d3=title,d4=item
HANDLE_MENU
	cmp.w	#MAbout,d3
	bne.s	.1
	rsrc_gaddr	#type_string,#AAlert
	form_alert	#1,addr_out
	bra	.done
.1	cmp.w	#MQuit,d3
	bne.s	.2
	st	finished
	bra	.done
.2	cmp.w	#MCheckme,d3
	bne.s	.3
	bchg	#0,checked+1
	menu_icheck	menu_ptr,#MCheckme,checked
	bra	.done
.3	cmp.w	#MDialog,d3
	bne.s	.4
	bsr	TEST_DIALOG
	bra	.done
.4	cmp.w	#MInstall,d3
	bne	.5
	tst.b	deskflag
	beq.s	.nodesk
	sf	deskflag
	sub.l	a3,a3
	bsr	SETDESK
	bra	.done
.nodesk:
	st	deskflag
	rsrc_gaddr	#0,#NewDesktop
	move.l	addr_out,a0
	move.w	screenx,ob_x(a0)
	move.w	screeny,ob_y(a0)
	move.w	screenw,ob_width(a0)
	move.w	screenh,ob_height(a0)
	move.l	a0,a3
	bsr	SETDESK
	bra	.done
.5
.done	menu_tnormal	menu_ptr,d4,#1
	rts

* the main loop of the application
* the only interesting events are messages
MAIN	sf	finished
	clr.w	checked
.loop	evnt_mesag	#messagebuf
	lea	messagebuf,a0
	move.w	(a0),d0			message type
	cmp.w	#MN_SELECTED,d0
	bne.s	.1
	move.w	8(a0),d3
	move.w	6(a0),d4
	bsr	HANDLE_MENU
.1	tst.b	finished
	beq.s	.loop
	rts

start	bsr	INITIALISE
	bsr	MAIN
	bra	DEINITIALISE		never to return...

	SECTION	DATA

rsc_filename	dc.b	'WRSC.RSC',0
badrsc_alert	dc.b	'[3][Resource file error][Quit]',0

	SECTION	BSS

* global variables

deskflag	ds.b	1
finished	ds.b	1
checked		ds.w	1
radio		ds.w	1
menu_ptr	ds.l	1
* these have to remain together
screenx	ds.w 1
screeny	ds.w 1
screenw	ds.w 1
screenh	ds.w 1

ap_id		ds.w 1
messagebuf	ds.b 16

editstring	ds.b	20

	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)


* if not linking then include the run-times

	IFEQ	__LK
	include	aeslib.s
***	include	vdilib.s		VDI not required
	ENDC
