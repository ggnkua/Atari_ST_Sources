;EXTRA_74.S by Alex Johnson

;This code was written using devpac ST version 2

	opt	o+			;optimisations on
	opt	ow-			;warnings off
	opt	d+			;debug on

	output	.tos			;set tos output

start_up

;gemdos start up

	move.l	4(sp),a0		
	move.l	12(a0),d0		
	add.l	20(a0),d0		
	add.l	28(a0),d0		
	add.l	#$1000,d0		
	add.l	#$100,d0		
	move.l	d0,-(sp)		
	move.l	a0,-(sp)		
	clr	-(sp)
	move	#$4a,-(sp)		
	trap	#1			
	lea	12(sp),sp		

	move.l	#0,-(sp)		;supervisor mode
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ustack		;save user mode stack
	lea	mstack,sp		;set my stack to avoid misshaps

;$ffff8240.w is the first colour palette register

	movem.l	$ffff8240.w,d0-d7	;save old palette
	movem.l	d0-d7,oldpal

	movem.l	blackout,d0-d7		;black out screen
	movem.l	d0-d7,$ffff8240.w

;$fffffc02.w is the keyboard data register

	move.b	#$12,$fffffc02.w	;mouse off
	
;$484.w is the keyboard status

	move.b	$484.w,old484		;save key stats
	bclr 	#0,$484			;no keyclick
	bclr 	#1,$484			;no repeat key

;$ffff820a.w is the sync mode register (50hz or 60hz)
;$ffff8260.w is the resolution register

	move.b  $ffff820a.w,oldsync	;save sync mode
	move.b	$ffff8260.w,d0		;get old res
	and.l	#3,d0			;mask off unwanted bits
	move	d0,oldres		;save old res

	bsr     vsync			;wait for the vbl

	move.b  #2,$ffff820a.w		;50HZ
	clr.b   $ffff8260.w		;Lowres

	move.w  #2,-(sp)		;get physbase
	trap    #14
	addq.l  #2,sp
	move.l  d0,physbase		;save it

	move.w  #3,-(sp)		;get logbase
	trap    #14
	addq.l  #2,sp
	move.l  d0,logbase		;save it

;now we come to reserving some screen memory
;this source only needs one screen but by changing
;number in d0 you can reserve two or more screens

;the normal screen is 32k but we are adding another
;74 lines to this screen so we need to make the area
;larger and this is how I work it out.

;one screen line = 160 bytes
;normal screen = 200 lines
;divide this number by 1024 (one kilobyte)
;and then ALWAYS round it up to the nearest whole number.
;for a normal screen you would use:

;200 * 160 = 32000
;32000/1024 = 31.25
;screen = 32k

;but for this screen we use:

;274 * 160 = 43840
;36640/1024 = 42.81
;screen = 43k


	move.l  #(43*1024),d0		;one 43k screen
	bsr     reservemem		;malloc the memory		
	move.l  d0,screenmem		;save memory address
	and.l   #-256,d0		;start on 256 byte boundary
	add.l   #256,d0			;just to make sure
	move.l  d0,viewscreen		;set screen address


	move.l	viewscreen,d0		;show the viewscreen
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w		;set vdbase low
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w		;set vdbase high


	bsr	fillscreen

	move	#$2700,sr		;switch off the interrupts
	bsr	set_ints		;put in our ones
	move	#$2300,sr		;switch them back on again

	move	#$777,$ffff8242.w	;show the screen

;now hopefully both borders should now be missing

.1
	cmp.b	#$39,$fffffc02.w	;space?
	beq.s	reset
	bra.s	.1

reset

	move	#$2700,sr		;switch off the interrupts
	bsr	restore_ints		;put back the old ones
	move	#$2300,sr		;switch them back on again

	movem.l	blackout,d0-d7		;black out colours
	movem.l	d0-d7,$ffff8240.w

	move.b	oldsync,$ffff820a.w	;restore old sync
	move	oldres,-(sp)		;restore old res
	move.l	physbase,-(sp)		;restore old physical screen
	move.l	logbase,-(sp)		;restore old logical screen
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.b	#$8,$fffffc02.w		;mouse on

	move.b	old484,$484.w		;restore key stats

	move.l	screenmem,d0		;free screen memory
	bsr	freemem

	movem.l	oldpal,d0-d7		;restore old pal
	movem.l	d0-d7,$ffff8240.w

	move.l	ustack,-(sp)		;user mode
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)			;terminate
	move	#$4c,-(sp)
	trap	#1


vsync

;sync with the electron beam
;to do this we check the fr clock register ($466.w)
;which is incremented every 50th second and wait
;for a different value

	move.l	d0,-(sp)
	move.l	$466.w,d0		;fr clock
.1
	cmp.l	$466.w,d0		;check value
	beq.s	.1			;is it the same?
	move.l	(sp)+,d0
	rts

reservemem

;use MALLOC to reserve some memory
;amount of memory needed is in d0

	
	move.l	d0,-(sp)		;area of memory
	move	#$48,-(sp)		;malloc
	trap	#1
	addq.l	#6,sp
	rts

freemem

;free the memory previously reserved with reserve mem
;address of memory is in d0

	move.l	d0,-(sp)		;address of memory
	move	#$49,-(sp)		;free mem
	trap	#1
	addq.l	#6,sp
	rts

fillscreen

;this fills the screen with a line pattern
;one bitplane only
;274 lines

	movem.l	d0-d1/a0,-(sp)
	move.l	viewscreen,a0		;screen address
	move	#(274-1),d0		;screen lines to do
	move	#$f0f0,d1		;line bit pattern
.1
	move	d1,(a0)			;fill the screen
	move	d1,8(a0)		;one bitplane only
	move	d1,16(a0)
	move	d1,24(a0)
	move	d1,32(a0)
	move	d1,40(a0)
	move	d1,48(a0)
	move	d1,56(a0)
	move	d1,64(a0)
	move	d1,72(a0)
	move	d1,80(a0)
	move	d1,88(a0)
	move	d1,96(a0)
	move	d1,104(a0)
	move	d1,112(a0)
	move	d1,120(a0)
	move	d1,128(a0)
	move	d1,136(a0)
	move	d1,144(a0)
	move	d1,152(a0)
	lea	160(a0),a0		;next screen line
	dbra	d0,.1			;do all screen lines
	movem.l	(sp)+,d0-d1/a0
	rts

set_ints

;initialise timer b interrupt to
;remove the bottom border and
;switch off timer c to avoid any
;interference.
;it also initialises our vbl interrupt

	move.l	$70.w,oldvbl		;save old vbl
	move.l	$120.w,old120		;save old timer b vector
	move.b	$fffffa07.w,olda07	;save old mfp registers
	move.b	$fffffa09.w,olda09
	move.b	$fffffa13.w,olda13
	move.b	$fffffa15.w,olda15
	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21
	andi.b	#$df,$fffffa09.w	;timer c off
	andi.b	#$fe,$fffffa07.w	;timer b off
	ori.b	#1,$fffffa07.w		;init timer b
	ori.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w		;set automatic end of interrupt
	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w
	move.l	#ourvbl,$70.w		;set up our vbl
	rts

restore_ints

;restore all system interrupts

	move.l	oldvbl,$70.w		;restore old vbl
	move.l	old120,$120.w		;restore old timer b vector
	move.b	olda07,$fffffa07.w	;restore old mfp registers
	move.b	olda09,$fffffa09.w
	move.b	olda13,$fffffa13.w
	move.b	olda15,$fffffa15.w
	move.b	olda17,$fffffa17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	rts

ourvbl

;first thing we do is remove the top border

;we need to wait 17218 clock cycles before opening
;the top border. Don`t ask me why this is because i
;don't know

;DO NOT CHANGE THE FOLLOWING PIECE OF CODE

;if you do the hertz change will occur in the wrong
;place and the desired effect will not be achieved

	move.w	#$2700,sr		;16
	movem.l	d0-d7/a0-a6,regis	;132
	move	#(1421-1),d0		;8
.1
	dbra	d0,.1			;(1421*12)+10 = 17062

;17218 cycles so open the top border
;don`t worry this is quite safe because the 60hz/50hz
;switch is done so fast that is isn`t noticed

	move.b	#0,$ffff820a.w		;60hz
	dcb.w	10,$4e71
	move.b	#2,$ffff820a.w		;back to 50hz

;if all has gone well the top border has now been removed

;now we have to set up timer b to remove
;the bottom border.

	clr.b	$fffffa1b.w		;stop timer b
	move.b	#228,$fffffa21.w	;set it to occur on line 228
	move.l	#ourtb,$120.w		;set up our timer b vector
	move.b	#8,$fffffa1b.w		;start timer b
	movem.l	regis,d0-d7/a0-a6	;restore registers
	move	#$2300,sr		;interrupts back on
	st	vblflag			;signal we have finished
	rte				;finish

ourtb

;this is the timer b interrupt that removes
;the bottom screen border

	clr.b	$fffffa1b.w		;stop timer b
	movem.l	a0/d0,-(sp)		;save a0 and d0
	lea	$fffffa21.w,a0		;timer b data register
	move.b	#229,(a0)		;set it to occur on line 229
	move.b	#8,$fffffa1b.w		;start timer b
	moveq	#0,d0			;clear d0
	move.b	(a0),d0			;get timer b data
.1
	cmp.b	(a0),d0			;compare timer b data
	beq.s	.1			;is it the same?

;here is another 60hz/50hz switch don`t worry this
;one is also safe to use

	clr.b	$ffff820a.w		;60hz
	moveq	#3,d0			;we need to
.2
	nop				;wait a little while
	dbra	d0,.2			;for the switch to take effect
	move.b	#2,$ffff820a.w		;back to 50hz

;the bottom border is now history

	movem.l	(sp)+,a0/d0		;restore a0 and d0
	clr.b	$fffffa1b.w		;stop timer b
	rte				;finish

	section	bss

ustack		ds.l	1		;user stack pointer
		ds.l	512		;my stack
mstack		ds.l	1		;stacks go backwards
oldpal		ds.w	16		;old palette
blackout	ds.w	16		;black out colours
old484		ds.b	1		;old key status
oldsync		ds.b	1		;old sync mode
oldres		ds.w	1		;old resolution
logbase		ds.l	1		;logical screen
physbase	ds.l	1		;physical screen
screenmem	ds.l	1		;screen memory address
viewscreen	ds.l	1		;new screen

oldvbl		ds.l	1		;old vbl ($70.w)
old120		ds.l	1		;old timer b ($120.w)

olda07		ds.b	1		;old mfp registers
olda09		ds.b	1
olda13		ds.b	1
olda15		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
vblflag		ds.b	1		;vbl flag
		even

regis		ds.l	16		;store for the 16 registers
