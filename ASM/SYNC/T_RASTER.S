*
* useful:
* Interrupt routine by BlueSTar of SYNC...
* Use it yourself as a shell to your programs
* In this code, A6 is reserved as color pointer
* ESC to exit
* *** For INC MAGAZINE ***
*
*

	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,nd+2
	bsr	init

lopen:
	.wait_vbl:
	tst.b	vsync
	beq.s	.wait_vbl
	sf	vsync
	cmp.b	#$81,$fffffc02.w
	bne.s	lopen

	bsr	bye

nd:	move.l	#0000000,-(sp)		* set user
	move.w	#$20,-(sp)
	trap		#1
	add.l		#6,sp

	clr.w	-(sp)					*End
	trap	#1

bye:	move.w	#$2700,sr
shbl	move.l	#0,$120	restore old interrupts
svbl	move.l	#0,$70
s09	move.b	#0,$fffa09
sxx	MOVE.B	#0,$FFFA07
s1b	move.b	#0,$fffa1b
s21	move.b	#0,$fffa21
	bset		#3,$fffffa17
	move.w	#$2300,sr
	rts

init:
	move.w	#$2700,sr
	move.l	$120,shbl+2	*save old interrupts
	move.l	$70,svbl+2
	move.b	$fffa09,s09+3
	MOVE.B	$FFFA07,sxx+3
	move.b	$fffa1b,s1b+3
	move.b	$fffa21,s21+3
	* Set New ones...
	move.l	#hbl,$120
	move.l	#vbl,$70
	MOVE.B	#1,$FFFA07
	MOVE.b	#0,$fffa09
	move.b	#1,$fffa21	*STEP of rasters
	move.b	#8,$fffa1b
	bclr	#3,$fffffa17
	OR.B	#1,$FFFFFA13
	move.w	#$2300,sr
	rts

vbl:
	lea	col_tab(pc),a6	*Use a6 as colorpointer
	st	vsync
	rte

hbl: 	move.w	(a6)+,$ffff8240.w
	rte
	
vsync	dc.w	0
col_tab:
	rept 12
	dc.w	$001,$012,$123,$234,$345,$456,$567,$677,$777
	dc.w	$776,$765,$654,$543,$432,$321,$210,$100,$000
	endr	
