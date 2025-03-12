; the power generation. disk menu 1

N_FILES	equ	3

start	move.l	4(a7),a0
	move.l	$c(a0),d0
	add.l	#$500,d0
	
	move.l	d0,d1
	add.l	a0,d1
	andi.l	#-2,d1
	move.l	d1,a7	; new stack
	
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	
	move.l	#finish+1024,d0

	andi.l	#-256,d0	; on 256 byte boundary

	move.l	d0,image_buff_p
	
	move.l	d0,a0
	
; clear screen buffer

	move.w	#(160*270)-1,d0
	
.1	clr.b	(a0)+
	dbra	d0,.1

	move.l	image_buff_p,a0
	add.l	#160*37,a0	; offset
	lea	back_data+34,a1
	
	move.w	#(160*192)-1,d0
	
.copy	move.b	(a1)+,(a0)+
	dbra	d0,.copy
	
	pea	off_str
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
		
	pea	main
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	pea	on_str
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	
	pea	null
	pea	null
	move.l	name_ptr,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
		
.exit	clr.w	-(sp)
	trap	#1

; main demo routine

main	move.w	sr,-(sp)

	bclr	#0,$484	; to keyclick
	
; relocate music driver and install

	lea	music_start,a0
	lea	$70000,a1
	lea	music_end,a2
	
.reloc	move.b	(a0)+,(a1)+
	cmp.l	a0,a2
	bne	.reloc
	
	jsr	$70030

	bsr	swap_palette

	move.w	#37,-(sp)	; vsync
	trap	#14
	addq.l	#2,sp	

	move.b	$ff8260,save_res
	clr.b	$ff8260
	
	move.b	$fffa07,save_iera
	move.b	$fffa09,save_ierb
	move.b	$fffa0f,save_isra
	move.b	$fffa11,save_isra
	move.b	$fffa13,save_imra
	move.b	$fffa15,save_imrb
	move.b	$fffa1d,save_tcdcr
	
	move.b	#%00000000,$fffa07
	move.b	#%01000000,$fffa09
	clr.b	$fffa0f
	clr.b	$fffa11
	move.b	#%00000000,$fffa13
	move.b	#%01000000,$fffa15
	clr.b	$fffa1d

	move.l	$68,save_hbl
	move.l	$70,save_vbl

	move.l	#vbl_handler,$70

	move.w	#2,-(sp)
	trap	#14	; get physbase
	addq.l	#2,sp
	
	move.l	d0,save_physbase

	move.l	$100+(4*6),kbdvec_save
	move.l	#kbd_handler,$100+(4*6)
	
	move.w	#-1,-(sp)
	move.l	image_buff_p,-(sp)
	move.l	image_buff_p,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
		
	pea	hbl_handler1	; vector
	move.w	#2,-(sp)	; data
	move.w	#8,-(sp)	; control (event count)
	move.w	#1,-(sp)	; timer B
	move.w	#31,-(sp)	; Xbtimer
	trap	#14
	add.l	#12,sp
	
.loop	move.w	vsync_count,d0

.wait	cmp.w	vsync_count,d0
	beq	.wait
	
	move.w	#$700,d0
.delay	dbra	d0,.delay

;	not.w	$ff8240
	bsr	do_scrolls
;	not.w	$ff8240

	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.b	d0
	beq	.loop
	
	subi.w	#'1',d0
	bmi	.loop
	
	cmpi.w	#N_FILES-1,d0
	bgt	.loop
	
; valid key pressed!!!

	move.w	d0,-(sp)
	
.exit	move.w	#-1,-(sp)
	move.l	save_physbase,-(sp)
	move.l	save_physbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	kbdvec_save,$100+(4*6)	
	move.l	save_hbl,$68
	move.l	save_vbl,$70

	move.b	save_iera,$fffa07
	move.b	save_ierb,$fffa09
	move.b	save_isra,$fffa0f
	move.b	save_isrb,$fffa11
	move.b	save_imra,$fffa13
	move.b	save_imrb,$fffa15
	move.b	save_tcdcr,$fffa1d
	
	bclr	#0,$fffa07	; iera

	bclr	#1,$ff8260
	
	move.w	#37,-(sp)	; vsync
	trap	#14
	addq.l	#2,sp	

	move.b	save_res,$ff8260
	move.w	#-1,$ff8240
	bset	#1,$ff820a
	
	bsr	swap_palette

run	clr.l	$4da	; byebye music

	move.w	#$80+8,-(sp)
	clr.w	-(sp)
	move.w	#28,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#$80+9,-(sp)
	clr.w	-(sp)
	move.w	#28,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#$80+10,-(sp)
	clr.w	-(sp)
	move.w	#28,-(sp)
	trap	#14
	addq.l	#6,sp
	

	move.w	(sp)+,d0	; get program number
	lsl.w	#2,d0
	lea	ptr_table,a0
	move.l	0(a0,d0.w),name_ptr

	move.w	(sp)+,sr
		
	rts
	
kbd_handler	move.w	#$2300,sr

.call	jmp	$ffffffff
kbdvec_save	equ	.call+2

vbl_handler	move.b	#1,$fffa21	; data
	bset	#0,$fffa07	; iera (enable B)
	
	move.l	#hbl_handler1,$120
	
	addi.w	#1,vsync_count
	
	bclr	#1,$ff820a

.call	jmp	$ffffffff
save_vbl	equ	.call+2

hbl_handler1	bset	#1,$ff820a
	
	bclr	#0,$fffa0f	; aknowledge B
	move.b	#226,$fffa21	; data
	move.l	#hbl_handler2,$120

	rte

hbl_handler2	move.l	#hbl_handler3,$120
	
	bclr	#0,$fffa0f	; aknowledge B
	move.b	#1,$fffa21	; data

	rte
	
; remove lower border and disable timer B ready for next VBL

hbl_handler3	rept	110	; (110 works!!)
		nop
	endr
	
	bclr	#1,$ff820a
	
	rept	20	; (20 works!!!)
		nop
	endr

	bset	#1,$ff820a
	
	bclr	#0,$fffa0f	; aknowledge B
	bclr	#0,$fffa07	; disable B
	
	rte
	
swap_palette	lea	back_data+2,a0
	lea	$ff8240,a1
	
	move.w	#15,d0	; 16 colours
	
.1	move.w	(a0),d1
	move.w	(a1),(a0)+
	move.w	d1,(a1)+
	dbra	d0,.1
	
	rts

; scroll routines

font_height	equ	32
font_width	equ	32

scroll_offset1	equ	160*7
scroll_offset2	equ	160*230

wrap_offset1	equ	scroll_offset1+(160*34)
wrap_offset2	equ	scroll_offset2-(160*32)

scroll_width	equ	19	; long words
scroll_height	equ	32

do_scrolls	tst.b	scroll_pause
	beq	.no_pause

	subi.b	#1,scroll_pause

	rts

.no_pause	tst.w	char_pos
	bne	.1
	
	bsr	new_char
	tst.b	scroll_pause
	beq	.1
	
	rts	; quit if in pause mode
	
.1	addi.w	#1,char_pos
	andi.w	#31,char_pos	; mask
	
	move.l	image_buff_p,a0
	move.l	a0,a1
	add.l	#scroll_offset1,a0
	add.l	#scroll_offset2,a1

	lea	char_buffer,a4
	
	move.w	#scroll_height-1,d7
	
shift	macro

	roxl.w	160-(8*\1)(a1)
	
	endm

shift2	macro

	roxr.w	(8*\1)(a0)
	
	endm
	
.y	

; do first plane

	lsl.w	8(a4)	; shift buffer end
	roxl.w	0(a4)	; into next position
	
	shift	1
	shift	2
	shift	3
	shift	4
	shift	5
	shift	6
	shift	7
	shift	8
	shift	9
	shift	10
	shift	11
	shift	12
	shift	13
	shift	14
	shift	15
	shift	16
	shift	17
	shift	18
	shift	19
	shift	20
	
; scroll reverse image

	shift2	0
	shift2	1
	shift2	2
	shift2	3
	shift2	4
	shift2	5
	shift2	6
	shift2	7
	shift2	8
	shift2	9
	shift2	10
	shift2	11
	shift2	12
	shift2	13
	shift2	14
	shift2	15
	shift2	16
	shift2	17
	shift2	18
	shift2	19
	
	addq.l	#2,a0
	addq.l	#2,a1
	addq.l	#2,a4
	
; do second plane

	lsl.w	8(a4)	; shift buffer end
	roxl.w	0(a4)	; into next position
	
	shift	1
	shift	2
	shift	3
	shift	4
	shift	5
	shift	6
	shift	7
	shift	8
	shift	9
	shift	10
	shift	11
	shift	12
	shift	13
	shift	14
	shift	15
	shift	16
	shift	17
	shift	18
	shift	19
	shift	20
	
; scroll reverse image

	shift2	0
	shift2	1
	shift2	2
	shift2	3
	shift2	4
	shift2	5
	shift2	6
	shift2	7
	shift2	8
	shift2	9
	shift2	10
	shift2	11
	shift2	12
	shift2	13
	shift2	14
	shift2	15
	shift2	16
	shift2	17
	shift2	18
	shift2	19
	
	adda.l	#160-2,a0
	adda.l	#160-2,a1
	adda.l	#16-2,a4
	
	dbra	d7,.y

; do wraped logos

	move.w	#31,d7	; y count
	
	move.l	image_buff_p,a0
	move.l	a0,a1

	add.l	#wrap_offset2,a0
	add.l	#wrap_offset1,a1
	
.wrap	move.w	(a1),d0
	lsl.w	#1,d0	; get carry
	
	shift	1
	shift	2
	shift	3
	shift	4
	shift	5
	shift	6
	shift	7
	shift	8
	shift	9
	shift	10
	shift	11
	shift	12
	shift	13
	shift	14
	shift	15
	shift	16
	shift	17
	shift	18
	shift	19
	shift	20

	addq.l	#2,a1

; do second plane


	move.w	(a1),d0
	lsl.w	#1,d0

	shift	1
	shift	2
	shift	3
	shift	4
	shift	5
	shift	6
	shift	7
	shift	8
	shift	9
	shift	10
	shift	11
	shift	12
	shift	13
	shift	14
	shift	15
	shift	16
	shift	17
	shift	18
	shift	19
	shift	20
	
; do bottom logo

	move.w	152(a0),d0
	lsr.w	#1,d0

	shift2	0
	shift2	1
	shift2	2
	shift2	3
	shift2	4
	shift2	5
	shift2	6
	shift2	7
	shift2	8
	shift2	9
	shift2	10
	shift2	11
	shift2	12
	shift2	13
	shift2	14
	shift2	15
	shift2	16
	shift2	17
	shift2	18
	shift2	19

	addq.l	#2,a0

; do second plane

	move.w	152(a0),d0
	lsr.w	#1,d0

	shift2	0
	shift2	1
	shift2	2
	shift2	3
	shift2	4
	shift2	5
	shift2	6
	shift2	7
	shift2	8
	shift2	9
	shift2	10
	shift2	11
	shift2	12
	shift2	13
	shift2	14
	shift2	15
	shift2	16
	shift2	17
	shift2	18
	shift2	19

	add.l	#160-2,a0
	add.l	#160-2,a1
	
	dbra	d7,.wrap
		
	rts

new_char	move.l	text_pointer,a0
	move.b	(a0)+,d0
	bne	.not_zero
	
	move.l	#scroll_text,text_pointer	; wrap
	bra	new_char
	
.not_zero	cmpi.b	#1,d0
	bne	.not_pause
	
	move.b	(a0)+,scroll_pause
	move.l	a0,text_pointer
	rts

.not_pause	move.l	a0,text_pointer	; update

.search	lea	font_map,a0
	clr.w	d1	; character number

.loop	tst.b	(a0)	; end of map?
	beq	.no_found	; not valid!
	
	cmp.b	(a0)+,d0
	beq	.found
	
	addq.w	#1,d1
	bra	.loop
	
.no_found	move.b	#' ',d0
	bra	.search	; ' ' in place of invalid
	
.found	andi.l	#$ffff,d1	; clip quotient
	divu.w	#10,d1	; 10 per line

	lea	font_data+34,a0
	
	move.w	d1,d0	; copy row
	swap.w	d1	; get column
	
	andi.l	#$ffff,d0
	andi.l	#$ffff,d1

	mulu.w	#160*32,d0
	add.l	d0,a0
	
	mulu.w	#16,d1
	add.l	d1,a0

	lea	char_buffer,a1
	
	move.w	#font_height-1,d0
	
.1	rept	4
		move.l	(a0)+,(a1)+
	endr

	add.l	#160-16,a0
	
	dbra	d0,.1
	
	rts

; data/working storage

vsync_count	dc.w	0

char_pos	dc.w	0

char_buffer	ds.w	(4*2)*32	; 32*32 pixels

save_physbase	ds.l	1

image_buff_p	ds.l	1

save_res	ds.b	1
	
save_iera	ds.b	1
save_ierb	ds.b	1
save_isra	ds.b	1
save_isrb	ds.b	1
save_imra	ds.b	1
save_imrb	ds.b	1

save_tcdcr	ds.b	1

save_hbl	ds.l	1

name_ptr	ds.l	1

scroll_text	

 dc.b 'read all scroller.....the power generation is prowd to present '
 dc.b 'their first compacted disk...'
 dc.b 'owing to many requests, and conmplaints about another groups packed disks,'
 dc.b 'we will only pack programs that work on all systems, so some games will not'
 dc.b 'get packed (unless they are 1mb originals).  '
 dc.b 'we will pack games from any hackers and leave their credits/titles'
 dc.b ' complete also all in-house cracks.           '
 dc.b ' the power generation is made up of           '
 dc.b '   the    ',1,50
 dc.b 'a.b.c. man',1,50
 dc.b '   and    ',1,50
 dc.b '   the    ',1,50
 dc.b 'terminator',1,50
 dc.b '        if you think that this intro is good wait till you see our furture productions, '
 dc.b 'some of them are amazing.....while on the subject of compacted disks some of you will'
 dc.b ' have seen lots of nasty messages on recent disks by another group, we will not lower ourselves '
 dc.b 'to the petty name calling and threats of others          '
 dc.b '   but    ',1,50
 dc.b 'i (a.b.c. man) would like to point out to you that the vilefication started after ozz was told '
 dc.b 'about our intentions to produce compacted disks that work....'
 dc.b 'on all systems..  i will leave you to draw your own conclusions on this.....'
 dc.b 'now that is strait on to the greetings.......'
 dc.b 'hi to the union (all members), the blade runners (all members), the untouchables (all members)'
 dc.b ', birdy!!!, edit-man, scs (hi mark), medway-boys, was (not-was), a-ha, 007, kam, and any other'
 dc.b 'hackers who don',39,'t spring to mind... the one hello goes to ozz of l.s.d. (hi rick) how '
 dc.b 'about dropping the silly staments now. i know you said ',34,'we couldnt think of anything else to do',34
 dc.b 'but it appears that some people did not realise your humour....'
 dc.b 'that is all for this scroll line and we hope to have a more light hearted'
 dc.b ' approach in future....... message-ends..........'
 
 dc.b 0

font_map	dc.b	" !",34,"#$%&",39,"()*+,-./0123456789:;"
	dc.b	"abcdefghijklmnopqrstuvwxyz",0
	
	even
	
text_pointer	dc.l	scroll_text
scroll_pause	dc.w	0

null	dc.b	0

name1	dc.b	'led.prg',0
name2	dc.b	'fizz.prg',0
name3	dc.b	'abc.prg',0

	even

ptr_table	dc.l	name1
	dc.l	name2
	dc.l	name3
	
off_str	dc.b	$12
on_str	dc.b	$8

	
	SECTION	DATA
	
music_start	incbin	'\secret.top\power.bin'
music_end	ds.l	1
	
font_data	incbin	'\font32.pi1'

back_data	incbin	'\title.pi1'

finish	end
