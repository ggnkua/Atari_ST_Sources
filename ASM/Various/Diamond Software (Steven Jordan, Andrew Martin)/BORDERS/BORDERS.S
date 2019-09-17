;**************************************************************************
;                    DEATH TO THE UPPER AND LOWER BORDERS                 *
;                                                                         *
;                         ½ 1993 DIAMOND SOFTWARE                         *
;                                                                         *
;                 CODED BY STEVEN JORDAN AND ANDREW MARTIN                *
;                                                                         *
; A word of warning - do NOT move the mouse when you press space to quit  *
; because your ST is likely to crash because the Video Shifter chip gets  *
; a current surge and blows. Your RAM may also get damaged, so be         *
; carefull. Only kidding, it is imposible to damage any piece of hardware *
; using software. 						    *
; 							    *
;**************************************************************************

start

	bsr	set_super	;set supervisor mode
	bsr	save_res	;check for high res
          bsr       setscreen ;set up the screens for drawing	
	bsr	put_graphics	;err, what it says!
	bsr       mfp_on     ;turn on all interupts
	bsr	palette	 ;set the palette

loop_01
	cmp.b	#57,$fffffc02
	bne	loop_01

	bra	exit

****************************************************************************

exit     
	bsr       mfp_off    	;turn off all interupts
          bsr       resetoldpal    	;reset the old palette

          move.w    oldres,-(sp)        ;Set old resolution
          move.l    oldscr,-(sp)        ;old screen address
          move.l    oldscr,-(sp)        ;old screen address
          move.w    #5,-(sp)  	;call setscreen
          trap      #14       	;call xbois
          adda.l    #12,sp    	;adjust the stack

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
; SAVE THE PALETTE 						    *                                                       *
;**************************************************************************

palette 
	movem.l   $ffff8240,d0-d7     ;get entire palette
          movem.l   d0-d7,savepal       ;save palette

	movem.l	pic1+2,d0-d7	;get our new palette
	movem.l	d0-d7,$ffff8240	;set it

	rts

;**************************************************************************
; SAVE THE SCREEN AND CHANGE TO LOW REZ IF WE CAN.		    *                                                       *
;**************************************************************************

save_res	move.w    #4,-(sp)		;get screen		
          trap      #14		;call XBOIS
          addq.l    #2,sp		;adjust the stack

          cmp.b     #2,d0		;is it high res		
          bne       pass		;no, don't quit		

          clr.l     -(sp)		;quit		
          trap      #1		;call GEMDOS (Bye)

pass      move.w    d0,oldres		;get old res	

          rts                 		

;**************************************************************************
; RESET OLD PALETTE                                                       *
;**************************************************************************

resetoldpal  

	movem.l	savepal,d0-d7	;get our old palette
	movem.l	d0-d7,$ffff8240	;set it

          rts       

;**************************************************************************
; SET LOW RESOLUTION AND PHYSICAL SCREEN ADDRESS                          *
;**************************************************************************

setscreen:          
          move.w    #3,-(sp)  	;get screen address
          trap      #14       	;xbios call
          addq.l    #2,sp     	;tidy stack
          move.l    d0,oldscr 	;save old screen

          move.l    #log,d0   	;move our logical screen
          addi.l    #256,d0   	;add 256 
          andi.l    #$ffffff00,d0       ;put it on a 256 byte boundary
          move.l    d0,logscreen        ;get our new logical screen
          move.l    d0,screen 	;also put it on our drawing screen

          move.l    #phy,d0   	;move our physical screen 
          addi.l    #256,d0   	;add 256 
          andi.l    #$ffffff00,d0       ;put it on a 256 byte boundary
          move.l    d0,physcreen        ;get new physical screen

          move.w    #0,-(sp)  	;put us in low resolution
          move.l    physcreen,-(sp)     ;physical screen address
          move.l    physcreen,-(sp)     ;logical screen address
          move.w    #5,-(sp)  	;now set the screen
          trap      #14       	;call xbois
          adda.l    #12,sp    	;adjust the stack

          rts       

;**************************************************************************
; INSTALL INTERUPTS                                                       *
;**************************************************************************

mfp_on:   lea       mfpstore,a0         ;where to store the mfp registers
          move.b    $fffffa07,(a0)+     ;interupt enable a
          move.b    $fffffa09,(a0)+     ;interupt enable b
          move.b    $fffffa13,(a0)+     ;interupt mask a
          move.b    $fffffa15,(a0)+     ;interupt mask b
          move.b    $fffffa19,(a0)+     ;timer a control
          move.b    $fffffa1b,(a0)+     ;timer b control
          move.b    $fffffa1f,(a0)+     ;timer a data
          move.b    $fffffa21,(a0)+     ;timer b data
          move.l    $68,(a0)+ 	;horizontal blank
          move.l    $70,(a0)+ 	;vertical blank
          move.l    $120,(a0)+          ;timer b interupt
          move.l    $134,(a0)+          ;timer a interupt
          clr.b     $fffffa1b 	;empty timer b data
          clr.b     $fffffa19 	;empty timer a data
          move.b    #$21,$fffffa07      ;disable interupt a
          clr.b     $fffffa09 	;disable interupt b
          move.b    #$21,$fffffa13      ;set mask a
          clr.b     $fffffa15 	;set mask b
          bclr      #3,$fffffa17        ;reset vector base
          move.l    #topbord,$134       ;put top border rout in timer a
          move.l    #bottom,$120        ;put bottom border rout in timer b
          move.l    #vblank,$70         ;new vertical blank rout
          move.w    #$2300,sr 	;all systems go 

          rts       		;return

;**************************************************************************
; RESET INTERUPTS                                                         *
;**************************************************************************

mfp_off:  move.w    #$2700,sr 	;stop all interupts
          lea       mfpstore,a0         ;address of saved registers
          move.b    (a0)+,$fffffa07     ;interupt enable a (top)
          move.b    (a0)+,$fffffa09     ;interupt enable b (bottom)
          move.b    (a0)+,$fffffa13     ;interupt mask a
          move.b    (a0)+,$fffffa15     ;interupt mask b
          move.b    (a0)+,$fffffa19     ;timer a control
          move.b    (a0)+,$fffffa1b     ;timer b control
          move.b    (a0)+,$fffffa1f     ;timer a data
          move.b    (a0)+,$fffffa21     ;timer b data (scan line)
          move.l    (a0)+,$68 	;Horizontal bank interupt
          move.l    (a0)+,$70 	;A normal Vertical bank
          move.l    (a0)+,$120          ;Ttimer B interupt (BOTTOM BORDER)
          move.l    (a0)+,$134          ;timer A interupt  (TOP BORDER)
          bset      #3,$fffffa17        ;reset mfp vector base
          move.w    #$2300,sr 	;all interupts go 
          rts       

;**************************************************************************
; TOP BORDER REMOVING ROUTINE                                             *
;**************************************************************************

topbord:  move.w    #$2100,sr 	;set status register
          stop      #$2100    	;wait for interupt
          clr.b     $fffffa19 	;disable timer a
	rept 78             	;repeat 78 times
          nop                 	;pause for 4*78 Cycles
          endr	          	;end the repeat
          clr.b     $ffff820a 	;change to 60HZ
          nop                 	;pause again
          nop                 	;and again
          move.b    #2,$ffff820a        ;set it back to 50hz. NO TOP BORDER
          rte                 	;return from interupt

;**************************************************************************
; This just points to an rte so interupts can be removed                  *
;**************************************************************************

phbl:     rte               		 ;Return back

;**************************************************************************
; BOTTOM BORDER REMOVING ROUTINE                                          *
;**************************************************************************

bottom:   move.w    d0,-(sp)  	;Move d0 into the Stack Pointer
          rept 32             	;Repeat 32 times
          nop                 	;Pause
          endr	          	;End repeat
          clr.w     d0        	;Clear 
          move.b    $ffff8209,d0        ;Get low byte of video address counter
          neg.b     d0        	;Minus it
          addi.b    #192,d0   	;Add 192 to it
          lsl.b     d0,d0     	;Pause to get the correct place
          move.w    #18,d0    	;Loop 18 times
pause:    dbra      d0,pause  	;End of loop
          move.b    #0,$ffff820a        ;Set to 60HZ
          rept 12  			;Repeat 12 times
          nop                 	;Puase
          endr                	;End repeat
          move.b    #2,$ffff820a        ;Set it back the 50HZ. No Border
          move.w    (sp)+,d0  	;Move the Stack Pointer back to 'd0'
          rte                 	;Retern

;**************************************************************************
; VBLANK ROUTINE                                                          *
;**************************************************************************

vblank:   clr.b     $fffffa19 	;stop timer A
          move.b    #100,$fffffa1f      ;set timer a data
          move.b    #4,$fffffa19        ;start timer A again

          clr.b     $fffffa1b 	;stop timer b
          move.b    #228,$fffffa21      ;scan line 228 is the bottom border
          move.l    #bottom,$120        ;move the no bottom border into scan line 120
          move.b    #8,$fffffa1b        ;start timer B agian

          rte                 	;return 

;**************************************************************************
; PUT THE CONCTACT BIT IN THE TOP BORDER AND THE LOWER BORDER	    *                                 
; PUT THE ADDRESS IN THE MIDDLE OF THE SCREEN			    *
; SCROLL THE NAMES IN THE LEFT AND RIGHT BORDERS ........ NOT             *
;**************************************************************************

put_graphics

          lea       pic1+34,a0      	;get our logo
          movea.l   physcreen,a1        ;copy to the physical screen
          adda.l    #0*160,a1           ;draw at line 0

          move.w    #4000-1,d6 	;repeat
copy1:    move.l    (a0)+,(a1)+         ;draw our logo
          move.l    (a0)+,(a1)+         ;draw our logo
          dbra      d6,copy1  	;4000 times!

* copy to the lower border

          lea       pic1+34,a0
          movea.l   physcreen,a1
          adda.l    #230*160,a1

          move.w    #700-1,d6
copy3     move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          dbra      d6,copy3

          rts       

;****************************************************************************

pic1	incbin	"a:\assembly\borders\address.pi1"

	section bss

savepal   ds.b 	32
mfpstore  ds.b	24
oldsp     ds.l	1
logscreen ds.l	1
physcreen ds.l	1
screen	ds.l	1
oldres    ds.b	2
oldscr    ds.l	4
log	ds.b	43856
phy	ds.b	43856

