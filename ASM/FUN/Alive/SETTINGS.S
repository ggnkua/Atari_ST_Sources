	COMMENT	HEAD=%111
;	OPT	D-

* Equates for the graphical layer.
FUNDEMOSETTER:	EQU	0			* Formulier/Dialoog
demosetterbox:	EQU	0			* BOX in boom FUNDEMOSETTER
TITEL:		EQU	1			* BOXTEXT in boom FUNDEMOSETTER
exitbutton:	EQU	3			* BUTTON in boom FUNDEMOSETTER
runbutton:	EQU	4			* BUTTON in boom FUNDEMOSETTER
videoselect:	EQU	5			* BUTTON in boom FUNDEMOSETTER
VDOMODESTRING:	EQU	6			* STRING in boom FUNDEMOSETTER
DETAILSTRING:	EQU	7			* STRING in boom FUNDEMOSETTER
detailselect:	EQU	8			* BUTTON in boom FUNDEMOSETTER

videomodes:	EQU	1			* Formulier/Dialoog
vdorgb50:	EQU	2			* STRING in boom VIDEOMODES
vdovga60:	EQU	3			* STRING in boom VIDEOMODES
vdovga100:	EQU	4			* STRING in boom VIDEOMODES
vdodefault:	EQU	vdorgb50

detaillevels:	EQU	2			* Formulier/Dialoog
detaillow:	EQU	2			* STRING in boom DETAILLEVELS
detailmid:	EQU	3			* STRING in boom DETAILLEVELS
detailhigh:	EQU	4			* STRING in boom DETAILLEVELS
detaildefault:	EQU	detaillow

* Internal equates
rgb50:		EQU	1
vga60:		EQU	2
vga100:		EQU	3

******** MAIN CODE ********

	bra	START

	INCLUDE	D:\CODING\DEVPAC3\INCDIR\AESLIB.S
	TEXT

START:	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	bsr	GET_SETTINGS

EXIT:	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

* OUTPUT: d0.w:	0=Run demo
*               -1=Exit demo
GET_SETTINGS:
	bsr	INIT_DIALOG

* graf_mouse
* Muis in z'n graf?? 8-)
* Kill the summsummbee and get a nice mousepointer again =)
	move.w	#0,int_in
	moveq	#78,d0
	bsr	CALL_AES

.loop:
* objc_draw
	lea	int_in,a0
	move.w	#0,(a0)+
	move.w	#5,(a0)+
	movem.l	dialogsize_tbl,d0-d1
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	treeadr,addr_in
	moveq	#42,d0
	bsr	CALL_AES

* form_do
	move.l	treeadr,addr_in
	move.w	#0,int_in
	moveq	#50,d0
	bsr	CALL_AES

	cmpi.w	#exitbutton,d0
	beq	.enddialog
	cmpi.w	#runbutton,d0
	beq	.enddialog
	cmpi.w	#videoselect,d0
	beq	.videopopup
	cmpi.w	#detailselect,d0
	beq	.detailpopup
	bra	.loop

.videopopup:
	movea.l	treeadr,a0
	movea.l	vdopopupadr,a1
	lea	videoselect*6*4(a0),a0
	move.l	16(a0),d0
	add.l	dialogpos,d0
	bsr	HANDLE_POPUP

	cmpi.w	#vdorgb50,d0
	bne.s	.vga60
	move.w	#rgb50,monitormode
	bra.s	.endrescodes
.vga60:	cmpi.w	#vdovga60,d0
	bne.s	.vga100
	move.w	#vga60,monitormode
	bra.s	.endrescodes
.vga100:
	cmpi.w	#vdovga100,d0
	bne.s	.next
	move.w	#vga100,monitormode
.next:
.endrescodes:
	movea.l	vdopopupadr,a0
	move.w	d0,d1
	mulu.w	#6*4,d1
	movea.l	12(a0,d1.l),a0
	movea.l	treeadr,a1
	lea	videoselect*6*4(a1),a1
	andi.w	#$fffe,10(a1)
	move.l	a0,12(a1)

	bra	.loop

.detailpopup:
	movea.l	treeadr,a0
	movea.l	detailpopupadr,a1
	lea	detailselect*6*4(a0),a0
	move.l	16(a0),d0
	add.l	dialogpos,d0
	bsr	HANDLE_POPUP

	move.w	d0,detaillev

	movea.l	detailpopupadr,a0
	move.w	d0,d1
	mulu.w	#6*4,d1
	movea.l	12(a0,d1.l),a0
	movea.l	treeadr,a1
	lea	detailselect*6*4(a1),a1
	andi.w	#$fffe,10(a1)
	move.l	a0,12(a1)

	bra	.loop

.enddialog:
	move.w	d0,-(sp)
	bsr	KILL_DIALOG
	move.w	(sp)+,d0

	cmpi.w	#exitbutton,d0
	bne.s	.exitcode
	moveq	#0,d0
	rts
.exitcode:
	moveq	#-1,d0
	rts

INIT_DIALOG:
* rsrc_load
* HuhhUhU. You said "load" huhuh.. YEh!
	move.l	#rscfilename_txt,addr_in
	moveq	#110,d0
	bsr	CALL_AES
	move.w	d0,d0
	beq	EXIT			* Path was not found.

* rsrc_gaddr
	clr.w	int_in
	move.w	#demosetterbox,int_in+2
	moveq	#112,d0
	bsr	CALL_AES
	move.l	addr_out,treeadr
	clr.w	int_in
	move.w	#videomodes,int_in+2
	moveq	#112,d0
	bsr	CALL_AES
	move.l	addr_out,vdopopupadr
	clr.w	int_in
	move.w	#detaillevels,int_in+2
	moveq	#112,d0
	bsr	CALL_AES
	move.l	addr_out,detailpopupadr

* form_center
	move.l	treeadr,addr_in
	moveq	#54,d0
	bsr	CALL_AES
	move.l	int_out+2,dialogpos

* Resize a bit to fit in the outline as well.
	movem.l	int_out+2,d0-d1
	sub.l	#$00030003,d0
	add.l	#$00060006,d1
	movem.l	d0-d1,dialogsize_tbl

* form_dial: FDM_START
	lea	int_in,a0
	move.w	#0,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	moveq	#51,d0
	bsr	CALL_AES

* Initialize default videosetting.
	movea.l	treeadr,a0
	movea.l	vdopopupadr,a1
	lea	vdodefault*6*4(a1),a1
	ori.w	#$0001,10(a1)
	move.l	12(a1),videoselect*6*4+12(a0)
	move.w	vdodefault,monitormode
* Initialize default detaillevel.
	movea.l	treeadr,a0
	movea.l	detailpopupadr,a1
	lea	detaildefault*6*4(a1),a1
	ori.w	#$0001,10(a1)
	move.l	12(a1),detailselect*6*4+12(a0)
	move.w	detaildefault,detaillev
	rts

KILL_DIALOG:
* form_dial: FDM_FINISH
	lea	int_in,a0
	move.w	#3,(a0)+
	movem.l	dialogsize_tbl,d0-d1
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	moveq	#51,d0
	bsr	CALL_AES

* rsrc_free
	moveq	#111,d0
	bsr	CALL_AES
	rts

* INPUT: d0.l: x and y position
*        a1: address of childtree
* OUTPUT: d0.w: objecthandle of selection
HANDLE_POPUP:
	move.l	a1,-(sp)

	move.l	d0,16(a1)
	subi.l	#$00010001,d0
	move.l	20(a1),d1
	addi.l	#$00040004,d1

* objc_draw
	lea	int_in,a0
	move.w	#0,(a0)+
	move.w	#5,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	a1,addr_in
	moveq	#42,d0
	bsr	CALL_AES

	move.l	(sp)+,a1

* form_do
	move.l	a1,addr_in
	move.w	#0,int_in
	moveq	#50,d0
	bsr	CALL_AES

	rts

******** DATA AND INCLUDES ********

	DATA
rscfilename_txt:
	DC.B	"D:\CODING\DEMOS1\SETTINGS.RSC",0
	EVEN

******** RESERVES ********

	BSS

treeadr:
	DS.L	1
vdopopupadr:
	DS.L	1
detailpopupadr:
	DS.L	1
dialogpos:
	DS.W	2
dialogsize_tbl:
	DS.L	2

monitormode:
	DS.W	1
detaillev:
	DS.W	1