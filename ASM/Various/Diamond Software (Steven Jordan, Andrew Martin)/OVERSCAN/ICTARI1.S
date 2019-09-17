***************************************************************************
*							    *
*   STFM Overscan 	    - Source code (c) Diamond Software 1994	    *
*   Original Overscan   - Neil (Powerman of TWB - The Wild Boys)          *
*   New Source Code     - Steven J				    *
*   Graphics	    - Spaz (TLB - The Lost Boys)		    *
*							    *
*		    - Set your tabs to 10			    *
*		    - Assemble with GENST V2+ 		    *
*		    - Does not work on STEs (Thanks Nik B!)	    *
*							    *
* if you have the ripper cartridge then you can view full-screen pictures *
* by changing the WIDTH to 0448 and MODULO to 006. You can then move      *
* around by using the cursor keys.				    *
*							    *
***************************************************************************

;				here are the scanlines...				
scan1	equ	160		left & right borders on (normal)
scan2	equ	230		left & right borders off (full scr)
scan3	equ	180		left or right border off

	bsr	setup		setup picture, screen etc
mainloop	cmp.b	#57,$fffffc02	is space pressed?...
	bne	mainloop		no. keep looping
	bra	exit		yes, quit

***************************************************************************
* EXIT						  	    *
* Restore all that was changed				    *
***************************************************************************

exit	
	bsr	mfp_off		restore old interupts
	move.w	oldres,-(sp)	set old resolution
	move.l	oldscr,-(sp)	set old physical screen address
	move.l	oldscr,-(sp)	set old logical screen address
	move.w	#5,-(sp)		set screen
	trap	#14		call xbios
	add.l	12,sp		adjust stack

	bsr       resetoldpal    	reset the old palette

	move.l	#mon,-(sp)	mouse on
	clr.w	-(sp)		keep old
	move.w	#25,-(sp)		
	trap	#14		call xbios
	addq.l	#8,sp		adjust the stack

	move.l    oldsp,-(sp)         reset old stack address
	move.w    #32,-(sp) 	set in supervisor mode 
	trap      #1        	call gemdos
	addq.l    #6,sp     	adjust the stack

	clr.l     -(sp)     	quit
	trap	#1		

***************************************************************************
* SETUP						  	    *
* Setup the screens, resolution, picture etc...			    *
***************************************************************************
	
setup	
	clr.l     -(sp)		keep old stack
	move.w    #32,-(sp)		call supervisor
	trap      #1		call gemdos
	addq.l    #6,sp		adjust the stack
	move.l    d0,oldsp		save old supervisor

	bsr	setscreen		setup the screens and res
	bsr	mouse_off		turn the mouse off
	bsr	savepal		save the palette
	bsr	draw_ictari	draw the full screen ictari picture
	bsr	setpal		set the palette
	bsr	mfp_on		save and install interupts
	
	rts

***************************************************************************
* SETUP THE SCREENS AND RESOLUTION IF WE CAN		  	    *
***************************************************************************

setscreen	
	move.w	#4,-(sp)		get screen res
	trap	#14		call xbios
	addq.l	#2,sp		adjust stack
	cmp.b	#2,d0		are we in high res?
	beq	high		yes, quit
	move.w	d0,oldres		save old res

	move.w	#3,-(sp)		get screen address
	trap	#14		call xbios
	add.l	#2,sp		adjust stack
	move.l	d0,oldscr		save old screen

	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen
	move.l	d0,d1
	add.l	#64000,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

	move.w	#0,-(sp)		low resolution
	move.l	screen,-(sp)	physical screen address
	move.l	screen,-(sp)	logical screen address
	move.w	#5,-(sp)		set screen
	trap	#14		call xbios
	add.l	#12,sp		adjust stack

	move.l	#screen,a6	
	move.l	(a6),d6		
	move.l	d6,4(a6)		
	move.l	scr_xor,d0	
	eor.l	d0,d6		
	move.l	d6,screen		
	lsr.l	#8,d6		
	move.l	#$ffff8201,a5	 
	movep.w	d6,(a5)		
	
	rts

***************************************************************************
* WE'RE IN HIGH REZ					 	    *
***************************************************************************

high
	move.l	#high_mess,-(sp)	get the high res message
	move.w	#9,-(sp)		print it to the screen
	trap	#1		gemdos
	add.l	#6,sp		restore stack

	move.w	#8,-(sp)		wait for a key
	trap	#1		gemdos
	add.l	#2,sp		restore stack

	clr.l	-(sp)		quit
	trap	#1		gemdos

***************************************************************************
* TURN THE MOUSE OFF				 	    *
***************************************************************************

mouse_off	
	move.l	#moff,-(sp)	mouse off
	clr.w	-(sp)		keep old
	move.w	#25,-(sp)		
	trap	#14		call xbios
	addq.l	#8,sp		adjust the stack

	rts			

***************************************************************************
* RESET OLD PALETTE                                                       *
***************************************************************************

resetoldpal  
	movem.l	oldpal,d0-d7	get our old palette
	movem.l	d0-d7,$ffff8240	set it

	rts

***************************************************************************
* SAVE THE PALETTE 						    *                                                       *
***************************************************************************

savepal
	movem.l   $ffff8240,d0-d7     get entire palette
          movem.l   d0-d7,oldpal      	save palette

	movem.l	blank,d0-d7	blank out the palette
	movem.l	d0-d7,$fff8240	set palette

	rts

setpal	movem.l	palette,d0-d7	get new palette
	movem.l	d0-d7,$fff8240	set palette
	
	rts			

***************************************************************************
* SAVE AND INSTALL INTERUPTS 					    *
***************************************************************************

mfp_on	
	move.l  	$120,oldtb	save old timer B vector
	move.l  	$70,old4		save old vb vector
	move.l  	$134,oldtimera	old timer A
	move.b  	$fffffa07,old07	timer B enable
	move.b  	$fffffa09,old09	timer C enable
	move.b  	$fffffa0f,old0f	timer B in-service
	move.b  	$fffffa11,old11	timer C in-service
	move.b  	$fffffa1b,old1b	timer B control
	and.b   	#$df,$fffa09	disable timer C
	and.b   	#$fe,$fffa07	disable timer B 
          move.b    $fffffa07,timera1   interupt enable a
          move.b    $fffffa13,timera2   interupt mask a
          move.b    $fffffa19,timera3   timer a control
          move.b    $fffffa1f,timera4   timer a data
          clr.b     $fffffa19 	empty timer a data
          move.b    #$21,$fffffa07      disable interupt a
          move.b    #$21,$fffffa13      set mask a
          bclr      #3,$fffffa17        reset vector base
	move.l  	#new_vbl,$70	new vb vector
	or.b    	#1,$fffffa07	enable timer B
	or.b    	#1,$fffffa13	set timer B mask

	rts

***************************************************************************
* RESET INTERUPTS                                                         *
***************************************************************************

mfp_off
	move.w	sr,-(sp)		save 
	move.w	#$2700,sr		cut out all interrupts
	move.b  	old07,$fffffa07 	restore all old vectors
	move.b  	old09,$fffffa09	timer c enable
	move.b  	old0f,$fffffa0f	timer b in-service
	move.b  	old11,$fffffa11	timer c in-service
	move.b  	old1b,$fffffa1b	timer b control
          move.b    timera1,$fffffa07   interupt enable a
          move.b    timera2,$fffffa13   interupt mask a
          move.b    timera3,$fffffa19   timer a control
          move.b    timera4,$fffffa1f   timer a data
          move.l    oldtimera,$134      timer a interupt
	move.l  	oldtb,$120	old timer b
	move.l  	old4,$70		old vbl
	move.w  	(sp)+,sr		retore

	rts			return

***************************************************************************
* VBLANK ROUTINE                                                          *
***************************************************************************

new_vbl	
	move.w	#$2700,sr		stop interrupts
	lea	$ffff8209.w,a0	video counter low byte

	moveq.w	#16,d1		used for sync
	move.w	#1432-1,d0	pause for top border
.top_wait	dbf	d0,.top_wait	paused
	moveq.w	#0,d0		clear d0

	move.b	#0,$ffff820a.w	set 60Hz
	dcb.w	10,$4e71		pause for hetz delay
	move.b	#2,$ffff820a.w	set 50Hz (No top border)

.video	move.b	(a0),d0		get the video counter 
	beq.s	.video		wait till we're at the start
	sub.w	d0,d1		get the correct place
	lsl.w	d1,d1		pause for correct amount of cycles

	dcb.w	90,$4e71		pause for correct place
	moveq.w	#0,d0		low res/60hz
	moveq.w	#2,d1		high res/50hz
	lea	$ffff820a.w,a0	get the sync mode (hertz)
	lea	$ffff8260.w,a1	get the shift mode (res)

	move.w	#227-1,d2		number of lines to kill
.no_lines1
	move.b	d1,(a1)		set high res
	move.b	d0,(a1)		set low res
	dcb.w	89,$4e71		move into the border
	move.b	d0,(a0)		set 60Hz
	move.b	d1,(a0)		set 50Hz
	dcb.w	13,$4e71		small delay
	move.b	d1,(a1)		set high res
	nop			wait for 4 cycles
	move.b	d0,(a1)		set low res
	dcb.w	10,$4e71		move into the border
	dbf	d2,.no_lines1	keep overscaning the scanlines

	move.b	d1,(a1)		set high res
	move.b	d0,(a1)		set low res
	move.w	palette+4,$fff8240	colour for the sea (28 cycles)

	dcb.w	88-7,$4e71	move into the border
	move.b	d0,(a0)		set 60Hz
	move.b	d1,(a0)		set 50Hz
	dcb.w	12,$4e71		small delay
	move.b	d0,(a0)		set 60Hz
	move.b	d1,(a1)		set high res
	nop			pause for 4 cycles
	move.b	d0,(a1)		set low res

	moveq.w	#45-1,d2		no. lines in the bottom border
	dcb.w	9,$4e71		pause
	move.b	d1,(a0)		set 50hz

.no_lines2
	move.b	d1,(a1)		set high res
	move.b	d0,(a1)		set low res
	dcb.w	89,$4e71		move into the border
	move.b	d0,(a0)		set 60Hz
	move.b	d1,(a0)		set 50Hz
	dcb.w	13,$4e71		small delay
	move.b	d1,(a1)		set high res
	nop			wait for 4 cycles
	move.b	d0,(a1)		set low res
	dcb.w	10,$4e71		move into the border
	dbf	d2,.no_lines2	keep overscaning the scanline

	move.w	palette+8,$fff8240	colour for the sky (top)

	rte			return from interupt

****************************************************************************
* UNPACK A PC1 PIC - Copyright 1991 The Highlander		     *
* a0=pc1 pic / a1=out pall (32) / a2=out pic (32000)		     *
****************************************************************************

unpack_pc1
	addq.l	#2,a0		; skip resolution flag.
	move.l	(a0)+,(a1)+	; copy over palette.
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

; now the picture area to be uncompressed.

; 0 <= n <= 127	;	n>=0 and n<=127 then no rept for n+1
; -127 <= n <= -1	;	n>=-127 and n<=-1 then rept for -n+1
; n = -128 	;	no operation.

	move.w	#199,d7	; scan lines
.UNCOMP0:	moveq.w	#3,d6
.UNCOMP1:	move.l	#_DEGASBUFF,a3
.UNCOMP2:	move.b	(a0)+,d0
	ext.w	d0
	cmp.b	#-128,d0		; ignore.
	beq.s	.UNCOMP2
	cmp.b	#-1,d0
	ble.s	.REPT
.LOOP1:	move.b	(a0)+,(a3)+		; no repeat.
	dbra	d0,.LOOP1
	cmp.l	#_DEGASBUFF+40,a3
	blt.s	.UNCOMP2
	bra.s	.DUMP_SCANLINE
.REPT:	neg.w	d0
	move.b	(a0)+,d1
.LOOP2:	move.b	d1,(a3)+		; repeat.
	dbra	d0,.LOOP2
	cmp.l	#_DEGASBUFF+40,a3
	blt.s	.UNCOMP2

.DUMP_SCANLINE:	
	move.l	#_DEGASBUFF,a3	; dump completed 
	move.l	a2,a6			; uncompressed scan line
	REPT	20			; plane too screen.
	move.w	(a3)+,(a2)+
	addq.l	#6,a2
	ENDR
	lea.l	2(a6),a2
	dbra	d6,.UNCOMP1
	lea.l	152(a2),a2
	dbra	d7,.UNCOMP0
	rts

***************************************************************************
* DRAW THE BACKGROUND 					    *
* Don't use this drawing routine because it's too slow in main loops!!!!! *
***************************************************************************

draw_back1

dl1
i	set	0		set to 0
	rept	3		repeat chunks (1 chunk=16 pixels)
	move.l	i(a2),i(a0)	copy 1st half of a chunk (logical)
	move.l	i+4(a2),i+4(a0)	copy 2nd half a chunk (logical)
i	set	i+8		next chunk
	endr			end of copying chunks
	add.l	#scan2,a0		next scanline line for logical
	add.l	#scan1,a2		next scanline line for piccy
	dbf	d1,dl1		end of copying lines

	rts

draw_back2
	move	#199-1,d1		;lines
dl2
i	set	0		set to 0
	rept	20		repeat chunks (1 chunk=16 pixels)
	move.l	i(a2),i(a0)	copy 1st half of a chunk (logical)
	move.l	i+4(a2),i+4(a0)	copy 2nd half a chunk (logical)
i	set	i+8		next chunk
	endr			end of copying chunks
	add.l	#scan2,a0		next scanline line for logical
	add.l	#scan1,a2		next scanline line for piccy
	dbf	d1,dl2		end of copying lines

	rts

***************************************************************************
* DRAW THE ICTARI PICTURE					    *
* A Crap way of drawing it but who cares?			    *
***************************************************************************

draw_ictari
	move.l	#pc1_bord,a0
	move.l	#palette,a1
	move.l	#bord,a2
	bsr	unpack_pc1

	move.l	#pc1_ictari,a0
	move.l	#palette,a1
	move.l	#ictari,a2
	bsr	unpack_pc1

	move.l	#bord,a2
	move.l	screen,a0		copy to the left
	add.l	#160*1,a0		hand side of the screen
	add.l	#230*28,a0
	add.l	#8,a0
	move	#198-1,d1		lines
	jsr	draw_back1

	move.l	#bord,a2
	move.l	screen,a0		copy to the right
	add.l	#160*1,a0		hand side of the screen
	add.l	#230*28,a0
	add.l	#8*23,a0
	move	#199-1,d1		lines
	jsr	draw_back1

	move.l	#ictari,a2
	move.l	screen,a0		copy to the right
	add.l	#160*1,a0		hand side of the screen
	add.l	#230*28,a0
	add.l	#8*4,a0
	jsr	draw_back2

i	set	0		draw the top of the sky
	rept	10
	move.l	#bord,a2
	add.l	#8*7,a2
	move.l	screen,a0	
	add.l	#160*1,a0		
	add.l	#i,a0
	move	#29-1,d1		lines
	jsr	draw_back1

	move.l	#bord,a2		draw the water in the bottom
	add.l	#75*160,a2
	add.l	#8*7,a2
	move.l	screen,a0	
	add.l	#160*1,a0		
	add.l	#230*(199+29),a0
	sub.l	#8*5,a0
	sub.l	#2,a0
	add.l	#i,a0
	move	#50-1,d1		lines
	jsr	draw_back1

i	set	i+8*3
	endr

	rts

***************************************************************************

pc1_bord		incbin	"a:\assembly\overscan\borders.pc1"
pc1_ictari	incbin	"a:\assembly\overscan\ictari.pc1"

high_mess	dc.b	27,"E",27,"p"	cls, inverse on
	dc.b	"Sorry but this program needs more than two colours..."
	dc.b	27,"q",0		inverse off, null
	even
mon	dc.b    	8		code for mouse on
moff	dc.b    	18		code for mouse off
old4	dc.l	0		old interupts
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
old0f	dc.b	0
old11	dc.b	0
old1b	dc.b	0
oldtimera	dc.l	0
timera1	dc.l	0
timera2	dc.l	0
timera3	dc.l	0
timera4	dc.l	0

	section bss

oldres	ds.b	2		old resolution
oldscr	ds.l	4		old screen address
oldpal	ds.b	32		old palette
screen	ds.l	1		drawing scr
	ds.l	1
scr_xor	ds.l	1
oldsp    	ds.l	1		old stack pointer
	ds.l	100	
blank	ds.b	32
palette	ds.b	32
bord	ds.b	32000
ictari	ds.b	32000
screens	ds.b	64000		space for physical screen
	ds.b	64000		space for logical screen
;				not the actuall size!!!
_DEGASBUFF:	ds.b	40		