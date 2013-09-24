; Falcon demosystem
;
; January 29, 2000
; Updated June 17, 2006
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

video_1:	lea	videolib+36*4*0,a0			;144/288*100 16bit
		move.w	#288,video_width			;
		move.w	#100,video_height			;
		move.w	#16,video_depth				;
		bra	setvideo				;

video_2:	lea	videolib+36*4*1,a0			;288*200 16bit
		move.w	#288,video_width			;
		move.w	#200,video_height			;
		move.w	#16,video_depth				;
		bra	setvideo				;

video_3:	lea	videolib+36*4*2,a0			;288*200 8bit
		move.w	#288,video_width			;
		move.w	#200,video_height			;
		move.w	#8,video_depth				;
		bra.s	setvideo				;

video_4:	lea	videolib+36*4*3,a0			;576*400 8bit
		move.w	#576,video_width			;
		move.w	#400,video_height			;
		move.w	#8,video_depth				;
		bra.s	setvideo				;

video_5:	lea	videolib+36*4*4,a0			;320*240 16bit
		move.w	#320,video_width			;
		move.w	#240,video_height			;
		move.w	#16,video_depth				;
		bra.s	setvideo				;

video_6:	lea	videolib+36*4*5,a0			;320*240 8bit
		move.w	#320,video_width			;
		move.w	#240,video_height			;
		move.w	#8,video_depth				;
		bra.s	setvideo				;

video_7:	lea	videolib+36*4*6,a0			;640*480 8bit
		move.w	#640,video_width			;
		move.w	#480,video_height			;
		move.w	#8,video_depth				;


	
setvideo:	tst.w	monitor					;VGA?
		bne.s	.rgb					;>RGB
		cmp.w	#60,vga_freq				;60Hz VGA?
		bne.s	.vga100					;>100Hz
		bra.s	.setres					;Set 60Hz VGA
.vga100:	lea	36*1(a0),a0				;Set 100Hz VGA
		bra.s	.setres					;
.rgb:		cmp.w	#50,rgb_freq				;50Hz RGB?
		bne.s	.rgb60					;>60Hz
		lea	36*2(a0),a0				;Set 50Hz RGB
		bra.s	.setres					;
.rgb60:		lea	36*3(a0),a0				;Set 60Hz RGB


.setres:	move.l	(a0)+,$ffff8282.w			;Horizontal hold timer
		move.l	(a0)+,$ffff8286.w			;Horizonal border end
		move.l	(a0)+,$ffff828a.w			;Horizontal display end
		move.l	(a0)+,$ffff82a2.w			;Vertical frequency timer
		move.l	(a0)+,$ffff82a6.w			;Vertical border end
		move.l	(a0)+,$ffff82aa.w			;Vertical display end
		move.w	(a0)+,$ffff820a.w			;Video sync mode
		move.w	(a0)+,$ffff82c0.w			;Video clock
		clr.w	$ffff8266.w				;Spshift - Videl colourmode
		move.l	(a0)+,d0				;
		bmi.s	.st_comp				;
		clr.b	$ffff8260.w				;ST shifter resolution
		move.w	d0,$ffff8266.w				;Spshift - Videl colourmode
		bra.s	.set_video				;
.st_comp:	clr.w	$ffff8266.w				;Spshift - Videl colourmode
		swap	d0					;
		move.b	d0,$ffff8260.w				;ST shifter resolution
.set_video:	move.w	(a0)+,$ffff82c2.w			;VCO - videl pixel width
		move.w	(a0)+,$ffff8210.w			;Scanlinewidth
		rts						;


		section	data

videolib:	incbin	'sys/video.dat'



		section	text
