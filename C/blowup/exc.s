Hi,
a long time ago (:-) you have sent us your Warp9, to check
it with BlowUP030. Sad to say, but it doesn't run with neither
BlowUP030 nor with Multitos. Here's a little piece of source 
code of our Blowboot.prg, eventually you can find a hint why
Warp9 doesn't run with BlowUP030.
  
; VDI-trap ($88)
		dc.b	"XBRA"
		dc.b	"BLOW"
old_2:	dc.l	0	
own_disp:
		cmp #115,d0		; AES or VDI ?
		beq	do_new
do_old:		
		move.l old_2,a0
		jmp (a0)		; AES !
do_new:
		move.l 	d1,a0
		move.l 	(a0),a0 ; contrl
		move 	(a0),d2	; functionnumber
		cmp 	#1,d2	; v_opnwk ?
		beq.s do_new1
		cmp 	#2,d2	; v_clswk ?
		beq do_new2
		bra do_old
;--------------------------------------------------------------
do_new1:
		move.l $45e,old_screen
		move.l d1,pb			; save d1 	
		move.l d1,a0
		move.l 4(a0),a0
			
		cmpi #10,(a0)		; blow screens only
		bgt do_old
		move #1,vsetflag	; internal flags (to check in vsetscreen wether
		clr vsetflag1			; it's called in v_opnwk or not)
		movem.l d1/d2/a1,-(sp)	
		bsr trap2_emul			; do original v_opnwk first
		movem.l (sp),d1/d2/a1
		move.l pb,d1
		move.l d1,a0
		move.l (a0),a0
		move 12(a0),d0				; handle
		move d0,old_handle
		
; Now the right number of planes is in 0(linea)		
; in v_opnwk (our) vsetscreen was called, so we know, if it's
; a compatibility mode and the plane count in actres

		tst actres
		bge	weiter			; no compatibilitymode
		tst Su78				; should we do "Super78"-mode?
		beq go_home			; No
		move.w #$182,$ff82c0 ; Yo! MTV Raps ... (switch to 78Hz)
		bra go_home
weiter:							; a funny german label :-)	
		move.l linea,a1	; linea-base adress
		move (a1),d2		; plane count
		bsr get_color_mode
		move d2,actplanes
		bsr get_table		; new res. configured?
		bne go_home			; no...
		move actplanes,actres	; internal stuff		
		move.l a1,actdat			; a1: pointer to init-data for linea and video

; Now we start with the initalisation of all

		bsr screen_malloc		; get screen memory (via Gemdos 20, srealloc)
		move.l actdat,a1

		bsr patch_intout		; patch the intout-array in (12(d1))
												; just xres,yres and planecount

		move.l actdat,a1

		tst vsetflag1				; set hardware-regs? 
		bne kein_set_video_mehr	; no, it has been done before
		bsr set_video						; write hardware-regs (top secret :-)

kein_set_video_mehr:				; another funny german label
		movem.l d0-a6,-(sp)
		move.w #-1,-(sp)				; set screen adress
		move.l screen_mem,-(sp)	; phys
		move.l screen_mem,-(sp)	; log
		move #5,-(sp)
		trap #14			
		lea $c(sp),sp
		movem.l (sp)+,d0-a6
		
		bsr set_linea						; and now patch linea variables
ende:
		movem.l (sp)+,d1/d2/a1 
		rte			; good bye...
		
go_home:
		move #-1,actres					; notice: no BlowUP030-res
		movem.l (sp)+,d1/d2/a1
		rte
;-----		
trap2_emul:
		move #$88,-(sp) ; TRAP #2 emulation
		pea cp
		move sr,-(sp)
		move.l old_2,a0
		jmp (a0)		; original VDI-call
cp:
		rts
;---------------------------------------------------------
set_linea:
		movem.l d0-d7/a0-a6,-(sp)
		move.l linea,a0			; linea base
		move.l actdat,a1		; 'our' values
		
		move yres(a1),d2
		move d2,-$2b2(a0)		; workout[1] in linea
		addq.w #1,d2
		move  d2,-4(a0)			; screen height
		
		move xres(a1),d2
		move d2,-$2b4(a0)		; workout[0] in linea
		addq.w #1,d2
		move d2,-$c(a0)			; screen width in pix.
		
		move bpl(a1),-2(a0)			; Bytes / line
		move planes(a1),(a0)
		move planes(a1),-$306(a0)	; workout[4] in vq_extnd
		move bpl(a1),2(a0)				; dito
		
		move xres(a1),d2
		asr #4,d2
		move d2,-$1e6(a0)		; workout[51] in linea
		
		move celwr(a1),d2		; char line width
		cmpi #$10,-$2e(a0)
		beq no_div
		lsr #1,d2				; small font!
no_div:
		move d2,-$28(a0)
		
		move xres(a1),d2
		lsr #3,d2
		move d2,-$2c(a0)		; max cursor-width
		
		move yres(a1),d2
		ext.l d2
		divu -$2e(a0),d2		; char height
		move d2,-$2a(a0)		; max cursor-height

sl_rts:
		movem.l (sp)+,d0-d7/a0-a6
		rts									; done