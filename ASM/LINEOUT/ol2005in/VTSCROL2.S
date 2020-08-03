scrollupkey equ $50
sscrollupkey equ $4d
scrolldownkey equ $48
sscrolldownkey equ $4b

NORMAL_SCROLL_MODE:=	0
SCROLL_FWD_MODE:=	1
FAST_FWD_MODE:=		2
FAST_BCK_MODE:=		3


;
;
; vertical textscroller 320x200 fonte 8x8 1 plan
;code by gloky
; todo:
;   scrolldown routine
;  assign key with scroll
; sys init
LINEWIDTH 	equ 272
bordersWIDTH	equ LINEWIDTH-160
howmanyline	equ 200

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0				; nifty debug mode
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	main,scroll_init,scroll_deinit
	dc.l	set_fast_scroll_up
	dc.l	set_scroll_up
	dc.l	set_normal
	dc.l	set_fast_scroll_back
	dc.l	0

;- plugin routs ------------------------------------------------------------

scroll_init:
	jsr initconvascii
	jsr initbitmapgen
	lea	background+8*2+2,a0
	rept	4
	move.l	#$06640664,(a0)+
	endr
	rts

scroll_deinit:
	rts

main:	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	cmpi.l	#2,d0
	bhs.s	.scr_done
	tst.l	d0
	bne.s	.res_done
;	move.w	$0468.w,.old468
	bsr	scroll_set_res
.res_done:
;	bsr	scroll_clear_screen
	bsr	scroll_fill_screen
	move.w #0,d0
	move.l scr,a0
	jsr affbitmap
.scr_done:

;	move.w #$777,$ffff8240.w

	move.w	$468.w,d0
.wait:	cmp.w	$468.w,d0
	beq.s	.wait

; actual rendering!
;	move.w #$007,$ffff8240.w
	movea.l scr,a0
	jsr affbitmap
;	move.w #$070,$ffff8240.w

;	bsr	paint_logo

; control
	move.w	scroll_mode,d0
	beq.s	.manual
	cmpi.w	#SCROLL_FWD_MODE,d0
	beq.s	.goscrollup
	cmpi.w	#FAST_BCK_MODE,d0
	beq.s	.goscrolldown4
	cmpi.w	#FAST_FWD_MODE,d0
	bne.s	.try_next
	tst.w	scroll_sync
	bne.s	.goscrollup4
	bra.s	.goscrollup
.try_next:

.manual:move.b $fffffc02.w,d0
	cmp.b #scrollupkey,d0
	beq.s .goscrollup
	cmp.b #scrolldownkey,d0
	beq.s .goscrolldown
	cmp.b #sscrollupkey,d0
	beq.s .goscrollup4
	cmp.b #sscrolldownkey,d0
	beq.s .goscrolldown4
	bra.s	.end

; updating of buffers, counters..
.goscrollup:
 	jsr	scrollUP
	bra.s	.end
.goscrolldown:
	jsr	scrollDOWN
	bra.s	.end
.goscrollup4
 	jsr	scrollUP
 	jsr	scrollUP
 	jsr	scrollUP
 	jsr	scrollUP
	bra.s	.end
.goscrolldown4
	jsr	scrollDOWN
	jsr	scrollDOWN
	jsr	scrollDOWN
	jsr	scrollDOWN

; swap screens, set vbase

.end:
	ifne	0
	movea.l	scr,a0
	lea	fonte,a1
	moveq	#20-1,d7
.loop:	move.b	(a1)+,6(a0)
	move.b	(a1)+,6+160(a0)
	move.b	(a1)+,6+320(a0)
	move.b	(a1)+,6+480(a0)
	move.b	(a1)+,6+640(a0)
	move.b	(a1)+,6+800(a0)
	move.b	(a1)+,6+960(a0)
	move.b	(a1)+,6+1120(a0)
	move.b	(a1)+,7(a0)
	move.b	(a1)+,7+160(a0)
	move.b	(a1)+,7+320(a0)
	move.b	(a1)+,7+480(a0)
	move.b	(a1)+,7+640(a0)
	move.b	(a1)+,7+800(a0)
	move.b	(a1)+,7+960(a0)
	move.b	(a1)+,7+1120(a0)
	addq	#8,a0
	dbf	d7,.loop
	endc

	ifeq	testmode
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc
	
	rts

;- subroutines -------------------------------------------------------------

set_fast_scroll_up
	st	gwem_sync_mode
	move.w	#FAST_FWD_MODE,scroll_mode
	rts

set_scroll_up
	st	gwem_sync_mode
	move.w	#SCROLL_FWD_MODE,scroll_mode
	rts

set_normal:
	clr.w	gwem_sync_mode
	move.w	#NORMAL_SCROLL_MODE,scroll_mode
	rts

set_fast_scroll_back:
	clr.w	gwem_sync_mode
	move.w	#FAST_BCK_MODE,scroll_mode
	rts

TINKER_MODE:=	0

paint_logo:
	movea.l	scr,a0
	ifne	TINKER_MODE
	lea	background_anim+34,a1
	endc

	ifne	0
; copy whole piccy (just a test!)
	move.w	#4000-1,d7
.loop:
	rept	4
	addq	#2,a0
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	addq	#2,a1
	endr
	dbf	d7,.loop

	else

	;addq.w	#1,frame
	;cmpi.w	#16,frame
	move.w	$0468.w,d0
	andi.w	#$000F,d0
	lea	logo_offset_table,a2
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a2
	move.w	(a2)+,d0			; d0.w=#chunks
	adda.w	(a2)+,a1

	moveq	#64-1,d7
.loop:
	rept	4				; 4 chunks
	addq	#2,a0
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	addq	#2,a1
	endr
	lea	160-32(a0),a0
	lea	160-32(a1),a1
	dbf	d7,.loop

	endc
	rts

;--------------------------------------------------------------------------

scroll_flash_rout:
	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	cmpi.l	#2,d0
	blt.s	.go_on
	move.l	#scroll_vbl_rout,palirq
	rts

.go_on:	lea	$FFFF8240.w,a0
	moveq	#-1,d0
	rept	8
	move.l	d0,(a0)+
	endr
	rts

scroll_set_res:
	move.l	#scroll_flash_rout,palirq
	rts

scroll_vbl_rout:
;	move.l	frmcnt,d0
;	cmp.l	lastfrmcnt,d0
;	beq.s	.end

;	lea	background_anim+2,a1
	lea	background+2,a1
	lea	$FFFF8240.w,a0
	rept	8
	move.l	(a1)+,(a0)+
	endr
.end:	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

scroll_fill_screen:
	lea	background+34,a1
	movea.l	scr,a0
;	addq	#6,a0
	move.w	#4000-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop
	rts

scroll_clear_screen:
	movea.l	scr,a0
	lea	32000(a0),a0
	IFNE	1
	clr.l	d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	REPT	(32000)/56
	movem.l	d0-d7/a1-a6,-(a0)	
	ENDR
	REPT	(32000-(32000/56)*56)/4
	move.l	d0,-(a0)
	ENDR
	ENDC
	rts

; refreshes 1 plane text buffer using new bottom line..
copyUpText:
	moveq #0,d0
	move.l text_up_ptr,a0
	move.b (a0)+,d0
	lea bitmapbuftext_up,a1
	lea asciiconv,a2
	moveq #0,d1
	move.b (a2,d0),d1
	lsl.w #3,d1	; *8
	lea fonte,a3
	lea (a3,d1),a4	
	
; 1er car
	move.b (a4)+,(a1)
	move.b (a4)+,40(a1)
	move.b (a4)+,80(a1)
	move.b (a4)+,120(a1)
	move.b (a4)+,160(a1)
	move.b (a4)+,200(a1)
	move.b (a4)+,240(a1)
	move.b (a4)+,280(a1)
		
	move.w #39-1,d3
.loop:
	addq.w #1,a1
	moveq #0,d0
	move.b (a0)+,d0
	moveq #0,d1
	move.b (a2,d0),d1
	lsl #3,d1
	lea (a3,d1),a4

	move.b (a4)+,(a1)
	move.b (a4)+,40(a1)
	move.b (a4)+,80(a1)
	move.b (a4)+,120(a1)
	move.b (a4)+,160(a1)
	move.b (a4)+,200(a1)
	move.b (a4)+,240(a1)
	move.b (a4)+,280(a1)

;	not.w d2
	dbf d3,.loop
	rts

; copy text to 1 plane buffer
copyDownText:
	moveq #0,d0
	movea.l text_down_ptr,a0
	move.b (a0)+,d0
	lea bitmapbuftext_down,a1
	lea asciiconv,a2
	moveq #0,d1
	move.b (a2,d0),d1
	lsl.w #3,d1	; *8
	lea fonte,a3
	lea (a3,d1),a4	
	
; 1er car
	move.b (a4)+,(a1)
	move.b (a4)+,40(a1)
	move.b (a4)+,80(a1)
	move.b (a4)+,120(a1)
	move.b (a4)+,160(a1)
	move.b (a4)+,200(a1)
	move.b (a4)+,240(a1)
	move.b (a4)+,280(a1)
		
	moveq #39-1,d3

.loop:	addq.w #1,a1
	moveq #0,d0
	move.b (a0)+,d0
	moveq #0,d1
	move.b (a2,d0),d1
	lsl #3,d1
	lea (a3,d1),a4

	move.b (a4)+,(a1)
	move.b (a4)+,40(a1)
	move.b (a4)+,80(a1)
	move.b (a4)+,120(a1)
	move.b (a4)+,160(a1)
	move.b (a4)+,200(a1)
	move.b (a4)+,240(a1)
	move.b (a4)+,280(a1)

;	not.w d2
	dbf d3,.loop
	rts



initconvascii:
	lea asciiconv1,a0
	lea asciiconv,a1
	moveq #0,d1
.loop:
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .endloop
	move.b d1,(a1,d0.w)
	addq.w #1,d1
	bra.s .loop
.endloop
	rts

initbitmapgen
	lea bitmapgen,a0
	moveq.l #0,d0
	move.l d0,d1
	move.w #$317C,d0
	swap d0
	move.w #$337C,d1
	swap d1
	moveq.l #6,d2		; offset

	lea 24000(a0),a1	; 6 byte*20*200
	move.w #20*200-1,d3
.loop
	move.l d0,(a0)+
	move.l d1,(a1)+
	move.w d2,(a0)+
	move.w d2,(a1)+
	addq.l #8,d2
	dbra.w d3,.loop
	move.w #$4e75,(a1)
	rts

; modify the huge code tables!
; input:
; d0.w=scanline index?
modifbitmapgen:			; d0 = numline (0..199)
				   *no->; d1 = numline (0..7) of textline
				; a2 = one plan bitmap 320 pix
	mulu #120,d0
	lea bitmapgen,a0
	add.w d0,a0
	lea 24000(a0),a1

;	lea bitmapbuftext,a2
;	mulu #20,d1
;	add.w d1,a2

	move.w (a2)+,d2
	move.w d2,2(a0)
	move.w d2,2(a1)
zozo	set 8
	rept 19
	move.w (a2)+,d2
	move.w d2,zozo(a0)
	move.w d2,zozo(a1)	
zozo	set zozo+6
	endr
	rts

affbitmap
	move.w windowpos,d0
affbitmap0:		; d0 = numline 0..199	; a0 = working screen adress+ selplan
	move.w d0,d1
	mulu #120,d0
	lea bitmapgen,a2
	lea (a2,d0),a3		; a3 = start adress in bitmapgen
	lea 24000(a3),a4	; a4 where there is rts
	mulu #160,d1
	sub.w d1,a0
	lea 32000(a0),a1

	move.w (a4),D7
	move.w #$4e75,(a4)
	jsr (a3)
	move.w D7,(a4)
	rts
	
windowpos: dc.w 0
scuppos: dc.w 0
scrollUP:
	jsr copyUpText

	move.w scuppos,d1
	move.w d1,-(sp)
	lea bitmapbuftext_up,a2
	mulu #40,d1
	add.w d1,a2
	
	move.w windowpos,d0
	jsr modifbitmapgen
	move.w (sp)+,d1

; update text positions, char line index, buffer line index
	addq.w #1,d1
	and.w #$7,d1
	bne.s	.oki

	move.l text_up_ptr,a0
	lea	40(a0),a0
	cmpa.l	#end_infotext,a0
	blo.s .ok0
	move.l #infotext,a0
.ok0:	move.l a0,text_up_ptr
	movea.l text_down_ptr,a1
	lea	40(a1),a1
	cmpa.l	#end_infotext,a1
	blo.s .ok1
	move.l #infotext,a1
.ok1:	move.l	a1,text_down_ptr

.oki:	move.w d1,scuppos

	move.w windowpos,d0
	addq.w #1,d0
	cmp.w #200,d0
	bne.s .1
	sub.w #200,d0
.1:	move.w d0,windowpos
	rts

scrollDOWN:
	jsr copyDownText

	move.w scuppos,d1
	move.w d1,-(sp)
	lea bitmapbuftext_down,a2
	mulu #40,d1
	add.w d1,a2
	
	move.w windowpos,d0
	subq.w #1,d0
	bpl.s .1
	add.w #200,d0
.1	move.w d0,windowpos
	jsr modifbitmapgen
	move.w (sp)+,d1

; update text positions, char line index, buffer line index
	subq.w #1,d1
	bpl.s	.oki

	movea.l text_down_ptr,a0
	lea	-40(a0),a0
	cmpa.l	#infotext,a0
	bhs.s .ok0
	move.l #end_infotext-40,a0
.ok0:	move.l a0,text_down_ptr
	movea.l text_up_ptr,a1
	lea	-40(a1),a1
	cmpa.l	#infotext,a1
	bhs.s .ok1
	move.l #end_infotext-40,a1
.ok1:	move.l a1,text_up_ptr

.oki:	andi.w #$7,d1
	move.w d1,scuppos

	rts


	data

fonte:  dcb.b 8,0
	incbin 'fnt882c.dat'

numlinetext:
	dc.w 0	; 0..7
numlinebitmap:
	dc.w 0	; 0..199*20
asciiconv1
	dc.b	" abcdefghijklmnopqrstuvwxyz0123456789!.,*"
	dc.b	"                     '|=-+\/_*&`[]()@?:;"                                        
	dc.b	0
	even

text_up_ptr:
	dc.l	infotext+40*25
text_down_ptr:
	dc.l	infotext
infotext:
	rept	25
	dc.b	"                                        "
	endr
	dc.b	"----------------------------------------"
	dc.b	"                                        "
	dc.b	" use the keys:                          "
	dc.b	"                                        "
	dc.b	" arrow up:    scroll back               "
	dc.b	" arrow down:  scroll forward            "
	dc.b	" arrow left:  scroll back fast          "
	dc.b	" arrow right: scroll forward fast       "
	dc.b	" space bar:   exit                      "
	dc.b	"                                        "
	dc.b	"----------------------------------------"
	incbin	invit.40
end_infotext:
	even

logo_offset_table:
; top 5 fujis (w,offset)
	dc.w	4,0
	dc.w	4,32
	dc.w	4,64
	dc.w	4,96
	dc.w	4,128
; 6 center fujis
	dc.w	4,64*160+8
	dc.w	2,64*160+32+8
	dc.w	2,64*160+48+8
	dc.w	2,64*160+64+8
	dc.w	4,64*160+80+8
	dc.w	4,64*160+112+8
; bottom 5 fujis (w,offset)
	dc.w	4,128*160
	dc.w	4,128*160+32
	dc.w	4,128*160+64
	dc.w	4,128*160+96
	dc.w	4,128*160+128

	ifne	TINKER_MODE
background_anim:
	incbin	logoata2.pi1
	endc
background:
	incbin	outl2k5e.pi1

	bss

bitmapgen:
	ds.w 3*20*200*2
	ds.w 1			rts
	; 6 byte for instruction move.w #bitmap,dep(a0) or dep(a1) 

numline:ds.w 1
bitmapToScroll
	ds.w 20*howmanyline*2	; buffer for whole screen
bitmapbuftext_up:
	ds.w 20*8	; buffer for one line of font
	ds.w 20*8
bitmapbuftext_down:
	ds.w 20*8	; buffer for one line of font
	ds.w 20*8

asciiconv:
	ds.b 256		; a metre en bss

scroll_sync:
	ds.w	1
scroll_mode:
	ds.w	1
