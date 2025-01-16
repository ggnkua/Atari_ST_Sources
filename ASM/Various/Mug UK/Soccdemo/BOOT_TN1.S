;
; TINY '.TN1' Picture Booter v1.0
; --------------------------------
;
; Coded by:       Mike Mee (although header credits MUG U.K !!)
; Tiny Depack by: Axe of Delight
;
; v1.0 - Adapted from NeoChrome Booter v2.0 from PVK v2.1
;

pic_adr	equ	$20000
buffer	equ	$27d00

yes	equ	1
no	equ	0

text_on	equ	no	; no = saving of 12 bytes + length of text

	opt	p+,o+,d-,s-

	bra.s	start
	dc.b	"Coded by: MUG U.K",191," 17/02/1995",0

start	
	ifne	text_on
	pea	text(pc) 
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7
	endc

	lea	filename(pc),a0	; file to load
	move.l	#pic_adr-34,d6	; destination address
	move.l	#3410,d7 		; length = ????? bytes (ALTER !!)

loadit	lea	handle(pc),a6	
	clr.w	-(a7) 		; mode = 0 (open to read)
	move.l	a0,-(a7)		; filename to open
	move.w	#$3d,-(a7)	; f_open
	trap	#1		; do it !!
	addq.l	#8,a7		; tidy stack
	move.w	d0,(a6) 		; store file handle returned

	move.l	d6,-(a7)		; address to load to
	move.l	d7,-(a7)		; amount to read in
	move.w	d0,-(a7)		; file handle
	move.w	#$3f,-(a7)	; f_read
	trap	#1		; do it
	adda.l	#$c,a7		; tidy stack

	move.w	(a6),-(a7)	; file handle
	move.w	#$3e,-(a7)	; f_close
	trap	#1		; do it !!
	addq.l	#4,a7		; tidy stack

	lea	pic_adr-34,a0
	lea	buffer,a1
	bsr.s	tiny

	lea	tinpal(pc),a0	; pictures palette
	lea	$ffff8240.W,a1	; ST palette
	movem.l	(a0),d0-d7	; move from one
	movem.l	d0-d7,(a1)	; to the other

	move.l	$44e.w,a0		; current screen address
	lea	buffer,A1	; source
	move.w	#$1F3F,D0		; (32000/4)-1 = $1F3F (7999)
bmove	move.l	(A1)+,(A0)+	; move it
	dbf	d0,bmove		; loop

exit	rts			; bye bye

filename	dc.b	"\back_in.'95",0	; don't use a: for those that
				; have to boot from drive b: !!

	ifne	text_on
text	dc.b	$1B,'E'
	dc.b	'Picture Loading !!',0
	endc

; Source for unpacking Tiny-pictures - Written by Axe of Delight
; Assemble with Devpac 2.08, Tab-position: 10
; You need source (packed tiny screen) and destination (screen address)
; for unpacking. After unpacking, the palette is saved at tinpal.

;	lea	source,a0	; source
;	lea	destination,a1	; destination
;	bsr	tiny

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tiny:	movem.l	d1-d6/a2-a5,-(sp)
	bsr	t_getpal		; read resolution and palette
	move.l	a4,d5
	move.l	a1,d6
	add.l	#$7d00,d6
	move.l	a1,d4
	add.l	#$a0,d4
	bra.s	t17a0a
t179be:	moveq	#0,d0
	move.b	(a5)+,d0
	beq.s	t179ce
	cmp.b	#1,d0
	beq.s	t179d6
	ext.w	d0
	bra.s	t179de
t179ce:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	bra.s	t179de
t179d6:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	neg.w	d0
t179de:	tst.w	d0
	bmi.s	t179ea
	move.b	(a4)+,d3
	lsl.w	#8,d3
	move.b	(a4)+,d3
	bra.s	t17a2e
t179ea:	neg.w	d0
	bra.s	t17a06
t179ee:	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a06
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a06
	lea	$ffffff62(a1),a1
t17a06:	dbf	d0,t179ee
t17a0a:	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
t_end:	movem.l	(sp)+,d1-d6/a2-a5
	rts
t17a18:	move.w	d3,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a2e
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a2e
	lea	$ffffff62(a1),a1
t17a2e:	dbf	d0,t17a18
	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
	movem.l	(sp)+,d1-d6/a2-a5
	rts

t_getpal: cmpi.b	#2,(a0)+		; Color mode?
	ble.s	t_color
	addq.l	#4,a0
t_color:	moveq	#31,d0		; install palette
	lea	tinpal(pc),a2
t_copypal:move.b	(a0)+,(a2)+
	dbra	d0,t_copypal
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	addq.l	#2,a0
	movea.l	a0,a5		; beginning of Data
	ext.l	d1
	adda.l	d1,a0
	movea.l	a0,a4		; end of Data
	moveq	#1,d0
	rts

tinpal:	ds.w 16

handle	ds.w	1

;
; Alter length of 'blanks' to ensure length of bootsector is equal
; to 480 bytes !!
;
	ifne	text_on
blanks	ds.w	30	; amount when text function is on
	elseif
	ds.w	46	; and when it's off !!
	endc

