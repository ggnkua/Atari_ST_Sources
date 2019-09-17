***************************************************************************
*							    *
*   Some Nice Colourful Rasters				    *
*   Slanting ones!						    *
*							    *
*		    - Source code (c) Diamond Software 1994	    *
*   Programming	    - Steven Jordan			              *
*							    *
*		    - Set your tabs to 10			    *
*		    - Assemble with GENST V2+ 		    *
*							    *
***************************************************************************

	bsr	set_super		;set supervisor mode
	bsr	mouse_off		;turn the mouse off
	bsr	save_pal		;save the palette	
	bsr	cls		;clear the screen

	bsr       mfp_on     	;turn on all interupts

***************************************************************************
* MAIN LOOP						    *
***************************************************************************

loop_01	cmp.b	#57,$fffffc02	;is space pressed?...
	bne	loop_01		;no. keep looping
	
	bra	exit		;yes. exit

***************************************************************************
* EXIT - RESTORE ALL THAT WE CHANGED			  	    *
***************************************************************************

exit	bsr       mfp_off    	;turn off all interupts

          bsr       resetoldpal    	;reset the old palette
	bsr	mouse_on		;turn the mouse on
	bsr	leave_super	;leave supervisor mode

          clr.l     -(sp)     	;PTERM (Quit)
	trap	#1

***************************************************************************
* SET SUPERVISOR MODE	                                            *
***************************************************************************

set_super
	clr.l     -(sp)		;get old
          move.w    #32,-(sp)		;call supervisor
          trap      #1		;call gemdos
          addq.l    #6,sp		;adjust the stack
          move.l    d0,oldsp		;save old supervisor

	rts			;return

***************************************************************************
* LEAVE IN SUPERVISOR MODE	                                            *
***************************************************************************

leave_super
          move.l    oldsp,-(sp)         ;reset old stack address
          move.w    #32,-(sp) 	;set in supervisor mode 
          trap      #1        	;call gamdos
          addq.l    #6,sp     	;adjust the stack

	rts			;return

***************************************************************************
* SAVE THE PALETTE 						    *                                                       *
***************************************************************************

save_pal
	movem.l   $ffff8240,d0-d7     ;get entire palette
          movem.l   d0-d7,old_pal      	;save palette

	rts			;return

***************************************************************************
* RESET OLD PALETTE                                                       *
***************************************************************************

resetoldpal  
	movem.l	old_pal,d0-d7	;get our old palette
	movem.l	d0-d7,$ffff8240	;set it

          rts     			;return  

***************************************************************************
* TURN THE MOUSE OFF				 	    *
***************************************************************************

mouse_off	
	move.l	#moff,-(sp)	;mouse off
	clr.w	-(sp)		
	move.w	#25,-(sp)		
	trap	#14		
	addq.l	#8,sp		

	rts			;return

***************************************************************************
* TURN THE MOUSE ON					 	    *
***************************************************************************

mouse_on
	move.l	#mon,-(sp)	;mouse on
	clr.w	-(sp)		
	move.w	#25,-(sp)		
	trap	#14		
	addq.l	#8,sp		

	rts			;return

***************************************************************************
* SAVE AND INSTALL INTERUPTS 					    *
***************************************************************************

mfp_on:	move.l  	$120,oldtb	;save old timer B vector
	move.l  	$70,old4		;save old vb vector
	move.l  	$134,oldtimera	;old timer A
	move.b  	$fffffa07,old07	;timer B enable
	move.b  	$fffffa09,old09	;timer C enable
	move.b  	$fffffa0f,old0f	;timer B in-service
	move.b  	$fffffa11,old11	;timer C in-service
	move.b  	$fffffa1b,old1b	;timer B control
	and.b   	#$df,$fffa09	;disable timer C
	and.b   	#$fe,$fffa07	;disable timer B 
          move.b    $fffffa07,timera1   ;interupt enable a
          move.b    $fffffa13,timera2   ;interupt mask a
          move.b    $fffffa19,timera3   ;timer a control
          move.b    $fffffa1f,timera4   ;timer a data
          clr.b     $fffffa19 	;empty timer a data
          move.b    #$21,$fffffa07      ;disable interupt a
          move.b    #$21,$fffffa13      ;set mask a
          bclr      #3,$fffffa17        ;reset vector base
	move.l 	#tb1,$120.w	;the timer b stuff
	move.l  	#new_vbl,$70	;new vb vector
	or.b    	#1,$fffffa07	;enable timer B
	or.b    	#1,$fffffa13	;set timer B mask
	rts

***************************************************************************
* RESET INTERUPTS                                                         *
***************************************************************************

mfp_off: 	move.w  	sr,-(sp)		;save 
	move.w  	#$2700,sr		;cut out all interrupts
	move.b  	old07,$fffffa07 	;restore all old vectors
	move.b  	old09,$fffffa09	;timer c enable
	move.b  	old0f,$fffffa0f	;timer b in-service
	move.b  	old11,$fffffa11	;timer c in-service
	move.b  	old1b,$fffffa1b	;timer b control
          move.b    timera1,$fffffa07   ;interupt enable a
          move.b    timera2,$fffffa13   ;interupt mask a
          move.b    timera3,$fffffa19   ;timer a control
          move.b    timera4,$fffffa1f   ;timer a data
          move.l    oldtimera,$134      ;timer a interupt
	move.l  	oldtb,$120	;old timer b
	move.l  	old4,$70		old vbl
	move.w  	(sp)+,sr		;retore
	rts			;return

***************************************************************************
* VBLANK ROUTINE                                                          *
* The scanline for the raster needs to be on a multiple of 8-1	    *
***************************************************************************

new_vbl	
	clr.b 	$fffffa1b		;stop timer b
	move.b 	#7,$fffffa21	;the scanline
	move.b 	#8,$fffffa1b	;start timer b
	move.l 	#tb1,$120		;the timer b stuff

	rte			;return from interupt

***************************************************************************
* TIMER B 1						    *
***************************************************************************

tb1	
	clr.b	$fffffa1b		;stop timer B
	move	sr,-(sp)		;save
	move	#$2700,sr		;cut out all interrupts
	lea	rast_col1(pc),a0	;get the colours
	lea	$ffff8240.w,a1	;get the border palette
	lea	$ffff8209.w,a2	;video counter low byte
				;(this counts the number of bytes)
				;drawn along the screen.
	lea	col_raster1(pc),a3	;get the colour routine

	moveq.w	#16,d1		;needed for timing
	moveq.w	#0,d0		;clear d0
.video	move.b	(a2),d0		;get the video counter 
	beq.s	.video		;make sure it's 0 first
	sub.w	d0,d1		;get the correct place
	lsl.w	d1,d0   		;pause to get the right place 

	move.b	(a2),d0		;get the low byte of video counter
	adda.l	d0,a3		;add it to our colour routine
	jmp	(a3)		;execute the colour routine

col_raster1
	dcb.w	164,$4e71		;pause for sync

	move.w	#10-1,d0
.col_loop	rept	40		;repeat for number of colours
	move	(a0)+,(a1)	;draw the colours and get the 
	endr			;end of repeat

	lea	rast_col1(pc),a0	;get the colours
	dcb.w	2,$4e71		;pause for sync
	dbra	d0,.col_loop

	move.w	#10-1,d0
col_loop2	rept	40		;repeat for number of colours
	move	(a0)+,(a1)	;draw the colours and get the 
	endr			;end of repeat

	lea	rast_col1(pc),a0	;get the colours
	dcb.w	4,$4e71		;pause for sync
	dbra	d0,col_loop2

	move	#0,(a1)		;change the border back to black
	move	(sp)+,sr		;restore

	rte			;return from interrupt

***************************************************************************
* CLEAR THE SCREEN						    *
***************************************************************************

cls
	move.w	#16000-1,d0	;set up a loop counter
	move.l	$44e,a0		;get the screen
.cls_loop	move.w	#0,(a0)+		;put a nought in that location, 
				;then increment
	dbra	d0,.cls_loop	;repeat 16000 times

	rts			;return

***************************************************************************

rast_col1	
	rept	16

	dc.w	$001,$002,$003,$004,$005,$006,$007,$017,$027,$037
	dc.w	$047,$057,$067,$077,$177,$277,$377,$477,$577,$677
	dc.w	$777,$777,$677,$577,$477,$377,$277,$177,$077,$067
	dc.w	$057,$047,$037,$027,$017,$007,$006,$005,$004,$003
	dc.w	$002,$002

	endr

x_pos		dc.w	1

***************************************************************************

	section bss


old_pal		ds.b	16		;old palette
pal		ds.b	16		;new palette
oldsp    		ds.l	1		;old stack pointer

***************************************************************************

	section	data

mon	dc.b    	8		;code for mouse on
moff	dc.b    	18		;code for mouse off
old4:    	dc.l    	0		;old interrupts
oldtb:   	dc.l    	0
old07:   	dc.b    	0
old09:    dc.b    	0
old0f:    dc.b    	0
old11:    dc.b    	0
old1b:    dc.b    	0
oldtimera	dc.l	0
timera1:  dc.l    	0
timera2:  dc.l    	0
timera3:  dc.l    	0
timera4:  dc.l    	0	

	format 0-,1-,2-
	list +


***************************************************************************
*							    *
*   Nice Colourful Rasters   -   Source code (c) Diamond Software 1994    *
*							    *
***************************************************************************


	list -
