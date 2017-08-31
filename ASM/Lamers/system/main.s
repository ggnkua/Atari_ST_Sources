	section text
			move.l  4(sp),a5                ; address to basepage
			move.l  $0c(a5),d0              ; length of text segment
			add.l   $14(a5),d0              ; length of data segment
			add.l   $1c(a5),d0              ; length of bss segment
			add.l   #$1000,d0               ; length of stackpointer
			add.l   #$100,d0                ; length of basepage
			move.l  a5,d1                   ; address to basepage
			add.l   d0,d1                   ; end of program
			and.l   #-2,d1                  ; make address even
			move.l  d1,sp                   ; new stackspace

			move.l  d0,-(sp)                ; mshrink()
			move.l  a5,-(sp)                ;
			move.w  d0,-(sp)                ;
			move.w  #$4a,-(sp)              ;
			trap    #1                  	;
			lea 	12(sp),sp               ;  
	
			;	superUserMode
			clr.l 	-(a7) 
            move.w 	#32,-(a7)
            trap 	#1
            addq.l 	#6,a7
            move.l 	d0,_old_stack			

			ifne MP2_MSX
			; 	audio/dsp
			move.w	#$68,-(sp)				;Dsp_Lock()
			trap	#14					
			addq.l	#2,sp					
		
			tst.w	d0					
			bne		exit

			move.w	#$80,-(sp)				;Locksnd()
			trap	#14					
			addq.l	#2,sp					
		
			cmp.w	#1,d0					
			bne		exit
			endif	

			; 	backupPalAndScrMemAndResolution
			lea.l	$ffff9800.w,a0			;save falcon palette
			lea.l	_save_pal,a1				
			move.w	#256-1,d7				
_backupPalLoop:
			move.l	(a0)+,(a1)+				
			dbra	d7,_backupPalLoop				

			movem.l	$ffff8240.w,d0-d7			;save st palette
			movem.l	d0-d7,(a1)				

			lea.l	_save_video,a0				;store videomode
			move.l	$ffff8200.w,(a0)+			;vidhm
			move.w	$ffff820c.w,(a0)+			;vidl
			move.l	$ffff8282.w,(a0)+			;h-regs
			move.l	$ffff8286.w,(a0)+			;
			move.l	$ffff828a.w,(a0)+			;
			move.l	$ffff82a2.w,(a0)+			;v-regs
			move.l	$ffff82a6.w,(a0)+			;
			move.l	$ffff82aa.w,(a0)+			;
			move.w	$ffff82c0.w,(a0)+			;vco
			move.w	$ffff82c2.w,(a0)+			;c_s
			move.l	$ffff820e.w,(a0)+			;offset
			move.w	$ffff820a.w,(a0)+			;sync
			move.b  $ffff8256.w,(a0)+			;p_o
			clr.b   (a0)					;test of st(e) or falcon mode
			cmp.w   #$b0,$ffff8282.w			;hht kleiner $b0?
			sle     (a0)+					;flag setzen
			move.w	$ffff8266.w,(a0)+			;f_s
			move.w	$ffff8260.w,(a0)+			;st_s
			move.l	#0,borderColor	
			move.l	borderColor,$ffff9800.w
			
			; check monitor
			move.w	#0,monitor
			move.w	#$59,-(sp)				;VgetMonitor()
			trap	#14					
			addq.l	#2,sp					

			tst.w	d0						;mono
			bne.s	_monitorCheckVga		
			bra.w	exit						
_monitorCheckVga:
			cmp.w	#2,d0					;vga
			beq.s	_monitorVga			
			move.w	#1,monitor				;rgb/tv
_monitorVga			

			; 	initScreensMem
			move.l  #screenbuffer+255,d0
			sub.b   d0,d0                           
			move.l  d0,scr1 

			add.l  #640*480,d0                     
			move.l  d0,scr2

			add.l  #640*480,d0                     
			move.l  d0,scr3

			move.l	#640*480*3/2,d7
			move.l	scr1,a1
_clrLoop	clr.l	(a1)+					
			dbra	d7,_clrLoop					;

			move.l	scr1,scr1orig
			move.l	scr2,scr2orig
			move.l	scr3,scr3orig

			; set screen
			move.l	scr3,d0			
			move.b	d0,d1					
			lsr.w   #8,d0					
			move.b  d0,$ffff8203.w				
			swap    d0					
			move.b  d0,$ffff8201.w				
			move.b  d1,$ffff820d.w				

			; dta
			move.w	#$2f,-(sp)				;fgetdta()
			trap	#1						;save old dta
			addq.l	#2,sp					;
			move.l	d0,_save_dta				;
			
			move.l	#dta,-(sp)				;fsetdta()
			move.w	#$1a,-(sp)				;set new dta
			trap	#1					
			addq.l	#6,sp					

			; init ram aligned buffer 
			move.l	#ramBufferArea,d0
			addq.l	#4,d0
			and.b	#%11111100,d0
			move.l	d0,ramBufferPtr
		
			; init msx
			ifne MOD_MSX
			bsr modInit
			endif
			
			ifne MP2_MSX
			bsr mp2load
			bsr mp2start
			endif			

			; init schedule
			move.l	#dummyMain,currentMain
			move.l	#0,currentFrame
			move.l	#demoDefintion,currentDef

			;	ints off
			move.w	sr,d0
			move.w	#$2700,sr

			;	save mfp
			lea.l	_save_mfp,a0
			move.b	$fffffa09.w,(a0)+			
			move.b	$fffffa15.w,(a0)+			
			move.b	$fffffa1d.w,(a0)+			
			move.b	$fffffa25.w,(a0)+			

			ifne	SCHED_TD
			; 	save and init timer d
			bset	#4,$fffffa09.w				
			bset	#4,$fffffa15.w				
			or.b	#%111,$fffffa1d.w			;%111 = divide by 200
			move.b	#41,$fffffa25.w				;2457600/200/41 approx 300 Hz

			move.l	$110.w,_save_timer_d		;save timer-d vector
			move.l	#timer_d,$110.w				;own timer-d			
			endif
			ifeq	SCHED_TD
			move.l	$110.w,_save_timer_d		;save timer-d vector
			move.l	#dummyInt,$110.w				;own timer-d			
			endif

			; ints on
			move.w	d0,sr

			; 	saveOldVBL
			move.l	$70.w,_save_vbl
			move.l	#vbl,$70.w

			; save cacr
			movec	cacr,d0
			move.l	d0,_save_cacr

			ifne CACR_1
			bclr	#13,d0					; no write alloc
			bclr	#12,d0					; d burst off
			bset	#11,d0					; clear d cache
			bclr	#8,d0					; d cache off
			bset	#4,d0					; i burst on
			bset	#0,d0					; i cache on	
			movec	d0,cacr		
			endif
		
			ifne CACR_2
			bclr	#13,d0					; no write alloc
			bset	#12,d0					; d burst on
			bset	#11,d0					; clear d cache
			bset	#8,d0					; d cache on
			bset	#4,d0					; i burst on
			bset	#0,d0					; i cache on	
			movec	d0,cacr		
			endif

			ifne RGB_ONLY
			cmp.w	#0,monitor
			beq.s	exit
			endif

			move.l	#$0,$ffff9800.w

			; *** main loop starts ***
drawLoopStart:
			
			ifne WAIT_1VBL
			move.l	currentFrame,tmpCurrentFrame
			endif
			
			move.l	currentMain,a0
			jsr	(a0)
	
			ifne MP2_MSX
			bsr mp2feeder
			endif	
			
			; end frame
			ifne	MARK_VBL
			move.l	#$ff00,$ffff9800.w
			endif
							
			ifne	EXIT_SPACE				
			; check for spacebar
			cmp.b	#$39,$fffffc02.w
			beq.s	exit
			endif

			ifne WAIT_1VBL
			move.l	tmpCurrentFrame,d0
_drawLoopWaitVSync
			cmp.l	currentFrame,d0
			beq.s	_drawLoopWaitVSync
			endif

			bra.s	drawLoopStart
			
			; *** main loop ends ***

exit:
			; restore cacr
			move.l	_save_cacr,d0
			movec	d0,cacr

			; ints off
			move.w	sr,d0					
			move.w	#$2700,sr

			; 	restore timer d
			move.l	_save_timer_d,$110.w
			;	restoreOldVBL
			move.l	_save_vbl,$70.w
			; 	restore mfp
			lea.l	_save_mfp,a0
			move.b	(a0)+,$fffffa09.w			
			move.b	(a0)+,$fffffa15.w			
			move.b	(a0)+,$fffffa1d.w			
			move.b	(a0)+,$fffffa25.w			

			; ints on
			move.w	d0,sr
						
			ifne MOD_MSX
			bsr modExit
			endif

			ifne MP2_MSX
			bsr mp2stop
			endif						
						
			;	restorePalAndScrMemAndResolution
			lea.l	_save_video,a0				;restore video
			clr.w   $ffff8266.w				;falcon-shift clear
			move.l	(a0)+,$ffff8200.w			;videobase_address:h&m
			move.w	(a0)+,$ffff820c.w			;l
			move.l	(a0)+,$ffff8282.w			;h-regs
			move.l	(a0)+,$ffff8286.w			;
			move.l	(a0)+,$ffff828a.w			;
			move.l	(a0)+,$ffff82a2.w			;v-regs
			move.l	(a0)+,$ffff82a6.w			;
			move.l	(a0)+,$ffff82aa.w			;
			move.w	(a0)+,$ffff82c0.w			;vco
			move.w	(a0)+,$ffff82c2.w			;c_s
			move.l	(a0)+,$ffff820e.w			;offset
			move.w	(a0)+,$ffff820a.w			;sync
	        move.b  (a0)+,$ffff8256.w			;p_o
	        tst.b   (a0)+   					;st(e) comptaible mode?
        	bne.s   _videoRestore1
			move.l	a0,-(sp)					;wait for vbl
			move.w	#37,-(sp)					;to avoid syncerrors
			trap	#14							;in falcon monomodes
			addq.l	#2,sp						;
			movea.l	(sp)+,a0					;
	       	move.w  (a0),$ffff8266.w			;falcon-shift
			bra.s	_videoRestored
_videoRestore1:
			move.w  2(a0),$ffff8260.w			;st-shift
			lea.l	_save_video,a0
			move.w	32(a0),$ffff82c2.w			;c_s
			move.l	34(a0),$ffff820e.w			;offset		
_videoRestored:
			lea.l	$ffff9800.w,a0				;restore falcon palette
			lea.l	_save_pal,a1				
			move.w	#256-1,d7				
_palRestoreLoop:		
			move.l	(a1)+,(a0)+				
			dbra	d7,_palRestoreLoop				
			movem.l	(a1),d0-d7					;restore st palette
			movem.l	d0-d7,$ffff8240.w			

			; dta
			move.l	_save_dta,-(sp)				;fsetdta() restore dta
			move.w	#$1a,-(sp)				
			trap	#1					
			addq.l	#6,sp	

			; audio/dsp
			move.w	#$69,-(sp)				;Dsp_Unlock()
			trap	#14					
			addq.l	#2,sp					

			move.w	#$81,-(sp)				;Unlocksnd()
			trap	#14					
			addq.l	#2,sp					

            ;	quit
            clr.w   -(A7)
			trap    #1

	section bss
monitor			dc.w	0					;0=vga 1=rgb/tv (init.s auto detect)
_vbl_counter	dc.w	0	
_old_stack 		dc.l 	0
_save_vbl		ds.l	1
_save_timer_d	ds.l	1
_save_mfp		ds.b	4
_save_dta		dc.l	0
dta				ds.l	64			
_save_cacr		dc.l	0

_save_pal		ds.l	256+8					;old colours (falcon+st/e)
_save_video		ds.b	32+12+2+2					;videl save

currentMain		dc.l	0
currentFrame	dc.l	0
currentDef		dc.l	0
tmpCurrentFrame dc.l	0

scr1		dc.l	1
scr2		dc.l	1
scr3		dc.l	1

scr1orig	dc.l	1
scr2orig	dc.l	1
scr3orig	dc.l	1
borderColor dc.l	1
	even
screenbuffer	ds.b	3*640*480+256
	even
ramBufferArea	ds.b	RAM_BUFFER_SIZE+4
ramBufferPtr	dc.l	0
	section text
