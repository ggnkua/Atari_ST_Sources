***************************************************************************
*							    *
*   Chip Music Routine  - Source code (c) Diamond Software 1993	    *
*   Programming         - Steven And Andrew 			    *
*   Music		    - Mad Max				    *
*							    *
*		    - Set your tabs to 10!!!			    *
*		    - Assemble with GENST V2 or V3 		    *
*							    *
***************************************************************************

lets_start_by_giving_steven_and_andrew_a_big_hand	;start variable?!
	
	bsr	set_super		;set supervisor mode
	bsr	initmusic		;set up music for playing
	bsr       mfp_on     	;turn on all interupts

***************************************************************************

loop_01	cmp.b	#57,$fffffc02	;is space pressed?...
	bne	loop_01		;no. keep looping
	
	bra	exit		;yes. exit

***************************************************************************
* EXIT - RESTORE ALL THAT WE CHANGED			  	    *
***************************************************************************

exit	bsr       mfp_off    	;turn off all interupts
	bsr	stop_music	;I forgot what this does!

          move.l    oldsp,-(sp)         ;reset old stack address
          move.w    #32,-(sp) 	;set in supervisor mode 
          trap      #1        	;call gamdos
          addq.l    #6,sp     	;adjust the stack

          clr.l     -(sp)     	;PTERM (Quit)
          trap      #1        	;call gemdos

;**************************************************************************
; SET SUPERVISOR MODE	                                            *
;**************************************************************************

set_super
	clr.l     -(sp)		;get old
          move.w    #32,-(sp)		;call supervisor
          trap      #1		;call gemdos
          addq.l    #6,sp		;adjust the stack
          move.l    d0,oldsp		;save old supervisor

	rts

;**************************************************************************
; INIT MUSIC                                                              *
;**************************************************************************

initmusic	moveq	#2,d0		;music number two
	jsr	music		;call music program
	rts			;return

;**************************************************************************
; STOP MUSIC                                                              *
;**************************************************************************

stop_music	
	moveq	#0,d0		;music zero
	jsr	music		;setup music 

	move.b	#8,$ffff8800	;channel A...
	clr.b	$ffff8802		;no volume
	move.b	#9,$ffff8800	;channel B...
	clr.b	$ffff8802		;no volume
	move.b	#10,$ffff8800	;channel C...
	clr.b	$ffff8802		;no volume
	
	rts			;return

;**************************************************************************
; INSTALL INTERUPTS                                                       *
;**************************************************************************

mfp_on:	
	move.l  $70,oldvbl		;save old vbl vector
	move.l  #vblank,$70		;new vb vector
	rts			;return

;**************************************************************************
; RESET INTERUPTS                                                         *
;**************************************************************************

mfp_off: 	move.l  oldvbl,$70		;get old vbl	
	rts			;return

;**************************************************************************
; VBLANK ROUTINE                                                          *
;**************************************************************************

vblank:   
	jsr	music+8		;we must add 8 to Max Max's music
				;program because that is the
				;offset of the program that
				;plays the music.

	rte			;return from interrupt

***************************************************************************
* VARABLES AND OTHER STUFF!						  *
***************************************************************************

music		incbin	"a:\assembly\music\music5.dat"

***************************************************************************

	section	data		
oldvbl    dc.l    	0		;old vbl
	section bss		;save memory/disk space
oldsp     ds.l	1		;the supervisor


 	format 	0-,1-,2-		;format the text
 	list 	+		;print everything from here 

***************************************************************************
* 							    *
*        DIAMOND SOFTWARE : "USE OUR CODE, BUT DON'T ABUSE IT..."         *
*							    *
***************************************************************************

	list	-
