;modifi‚ pour MI-9 by rockyone					28.10.2018
;
;ON 	+ 28
;DATA 	+110  16 W pallet image + 1 W line split + 16 W pallet MI-9
;Of 	+132
;-----------------------------
;
; PALETTE SPLIT
; allow GFABASIC to do a single palette split after a given amount 
; of scanlines
;
; (c) 2007 by Simon Sunnyboy / Paradize
; http://paradize.atari.org/
;
; USE AT YOUR OWN RISK!
;
;
;...............................;+28 ...init raster interrupt system.......
init_rasters:
	movem.l d0-d7/a0-a6,-(SP)
        lea.l	storage(PC),a3		; 	store interrupt context
        move.l  $70.w,(a3)+		; 	save old VBL
        move.l  $120.w,(a3)+		; 	save old Timer B
        move.b  $fffffa1b.w,(a3)+	; tbcr
        move.b  $fffffa21.w,(a3)+	; tbdr
        move.b  $fffffa07.w,(a3)+	; iera
        move.b  $fffffa09.w,(a3)+	; ierb
        move.b  $fffffa13.w,(a3)+	; imra

;.......................................set interrupts....................

        move.w	#$2700,SR			; 	stop interrupts
        lea.l	rastercontrol_vbl(PC),a1
        move.l  a1,$70.w			; 	set new VBL
        lea.l	raster_timerb(PC),a1
        move.l  a1,$120.w			; 	set new Timer B

; enable Timer B
        ori.b   #1,$fffffa07.w			; iera	enable Timer B
        ori.b   #1,$fffffa13.w			; imra	mask Timer B
        clr.b   $fffffa1b.w			; tbcr	stop Timer B

        move.w	#$2300,SR			; 	reenable interrupts
        movem.l (SP)+,D0-d7/a0-A6
        rts

;.......................................interface basic ...................
;
raster_address:	dc.l	0	;+110  	point to buffer pallets
;				; 	16 words for the first pallet 
;				;	 1 byte to zero
;				;        1 byte for the number of lines
;				;	16 words for the second pallet

raster2:	dc.l	0
storage:	dc.l	0,0		
		dc.b	0,0,0,0,0
		even
;...............................;+132 ...........disable splitscreen......
stop_rasters:
        move.l  a3,-(SP)
        move.w	#$2700,SR		; 	 stop irq system
        lea.l	storage(PC),A3
        move.l  (A3)+,$70.w		; vbl    restore old VBL
        move.l  (A3)+,$120.w		; timerb save old Timer B
        move.b  (A3)+,$fffffa1b.w	; tbcr   restore MFP context
        move.b  (A3)+,$fffffa21.w	; tbdr
        move.b  (A3)+,$fffffa07.w	; iera
        move.b  (A3)+,$fffffa09.w	; ierb
        move.b  (A3)+,$fffffa13.w	; imra
        move.w	#$2300,SR		; 	 reenable irqs
        movea.l (SP)+,a3
        rts

;.......................................new VBL to control the rasters..
rastercontrol_vbl:
	move.l	a3,-(sp)
	move.l	a4,-(sp)

        lea.l	raster_address(PC),a3	;    	address first pallet
        movea.l (a3),a3			;	pallet image
	lea.l	$ffff8240.w,a4
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	
	lea.l	$fffffa1b.w,a4
	clr.b	(a4)
	move.w	(a3)+,$20-$1b(a4) 	; tbdr	number of lines
	move.b	#8,(a4)			; tbcr	event count mode 
	move.l	a3,raster2		;	address second pallet
	move.l	(sp)+,a4
	move.l	(sp)+,a3
	move.l  storage(PC),-(SP)	; push old VBL address on to stack
        rts				; and jump to it :)

;........................................screensplit handling Timer B ISR 
raster_timerb:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.l	raster2,a3		; 	set new color from table
;					;	pallet MI-9, 5 colors
 	lea.l	$ffff8240.w,a4
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
*	move.l	(a3)+,(a4)+
*	move.l	(a3)+,(a4)+
*	move.l	(a3)+,(a4)+
*	move.l	(a3)+,(a4)+
*	move.l	(a3)+,(a4)+
*	move.l	(a3)+,(a4)+
	move.w	22(a3),22(a4)
;					; 	stop interuption Timer B
        bclr.b  #0,$fffffa0f.w		; isra 	aknowledge Timer B
	move.l	(sp)+,a4
	move.l	(sp)+,a3

        rte

        END
;------------------------------------------------------------------------