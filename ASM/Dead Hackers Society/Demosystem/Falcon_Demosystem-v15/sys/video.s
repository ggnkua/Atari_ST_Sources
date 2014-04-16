
; Videolibrary for Falcon demoshell
;
; Anders Eriksson
; ae@dhs.nu
;
; January 29, 2000
;
; video.s


; Available resolutions are as follows:
;
; jsr video_1			  jsr video_2
; 	VGA	144*100	16bit		VGA	288*200	16bit
;	RGB	288*100	16bit		RGB	288*200	16bit
;
; jsr video_3			  jsr video_4
;	VGA	288*200	8bit		VGA	576*400	8bit
;	RGB	288*200	8bit		RGB	576*400 8bit
;
; jsr video_5			  jsr video_6
;	VGA	320*240	16bit		VGA	320*240	8bit
;	RGB	320*240 16bit		RGB	320*240	8bit
;
; jsr video_7
;	VGA	640*480	8bit
;	RGB	640*480	8bit
;
; All resolutions are running on the 25 MHz videl clock, so it
; should be compatible to all accelerators with modfied 32 MHz
; videl clock. That also means that all reolutions have wide
; overscan on RGB.
;
; Please notice that "video_1" differs between VGA and RGB.
; It means 2*2 effects should have different routines depending
; on the monitor.
;
; 	tst.w	monitor
; 	beq	vgaloop	 	to select routine.
;	bra	rgbloop


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------

video_1:	lea.l	videolib+36*4*0,a0			;144/288*100 16bit
		bra.s	setvideo				;

video_2:	lea.l	videolib+36*4*1,a0			;288*200 16bit
		bra.s	setvideo				;

video_3:	lea.l	videolib+36*4*2,a0			;288*200 8bit
		bra.s	setvideo				;

video_4:	lea.l	videolib+36*4*3,a0			;576*400 8bit
		bra.s	setvideo				;

video_5:	lea.l	videolib+36*4*4,a0			;320*240 16bit
		bra.s	setvideo				;

video_6:	lea.l	videolib+36*4*5,a0			;320*240 8bit
		bra.s	setvideo				;

video_7:	lea.l	videolib+36*4*6,a0			;640*480 8bit


	
setvideo:	tst.w	monitor					;vga?
		bne.s	.rgb					;>rgb
		cmp.w	#60,vga_freq				;60Hz vga?
		bne.s	.vga100					;>100Hz
		bra.s	.setres					;set 60Hz vga
.vga100:	lea.l	36*1(a0),a0				;set 100Hz vga
		bra.s	.setres					;
.rgb:		cmp.w	#50,rgb_freq				;50Hz rgb?
		bne.s	.rgb60					;>60Hz
		lea.l	36*2(a0),a0				;set 50Hz rgb
		bra.s	.setres					;
.rgb60:		lea.l	36*3(a0),a0				;set 60Hz rgb


.setres:	move.l	(a0)+,$ffff8282.w			;horizontal hold timer
		move.l	(a0)+,$ffff8286.w			;horizonal border end
		move.l	(a0)+,$ffff828a.w			;horizontal display end
		move.l	(a0)+,$ffff82a2.w			;vertical frequency timer
		move.l	(a0)+,$ffff82a6.w			;vertical border end
		move.l	(a0)+,$ffff82aa.w			;vertical display end
		move.w	(a0)+,$ffff820a.w			;video sync mode
		move.w	(a0)+,$ffff82c0.w			;video clock
		clr.w	$ffff8266.w				;spshift - videl colourmode
		move.l	(a0)+,d0				;
		bmi.s	.st_comp				;
		clr.b	$ffff8260.w				;st shifter resolution
		move.w	d0,$ffff8266.w				;spshift - videl colourmode
		bra.s	.set_video				;
.st_comp:	clr.w	$ffff8266.w				;spshift - videl colourmode
		swap	d0					;
		move.b	d0,$ffff8260.w				;st shifter resolution
.set_video:	move.w	(a0)+,$ffff82c2.w			;vco - videl pixel width
		move.w	(a0)+,$ffff8210.w			;scanlinewidth
		rts						;


; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

videolib:	incbin	'sys\video.dat'



; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------
