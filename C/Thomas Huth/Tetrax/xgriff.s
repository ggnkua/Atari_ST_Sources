;-----------------------------------------------------------------------;
;			MOD Player													;
;		7 Bit Ste/TT Pro-Tracker 2.1A Driver							;
;	(C) October/November 1992 Griff of Electronic Images				;
;-----------------------------------------------------------------------;
; Quick notes about this source:										;
; - The ONLY player in the whole wide world to emulate TEMPO properly.  ;
; - This replay is NOT fast and nor should it be.						;
; - It is designed for QUALITY and ACCURATE replay of ProTracker MODS.  ;
; - It doe NOT pad samples and so doesn't waste any setup time/memory.  ;
; - If you use it, then please credit me.								;
;-----------------------------------------------------------------------;

;****************************************************
;* Changes made by T.Huth, 1997-2000				*
;* - Now the player can be called from a C programm *
;* - Some "dirty" routines changed					*
;* - The variables are now in the data-/bss-section *
;*   -> no longer write access to the text-section! *
;* - And some other changes							*
;* - Set tabsize = 4 to read this file				*
;****************************************************

;*** Tables from the FTAB*.S files: ***
.globl ftab12
.globl ftab25
.globl ftab50


bufsize equ 60000	; maximum size of buffer

	.text

;*********************************
;*** A new cookie jar function ***
;*********************************
.globl _xgetcookie
_xgetcookie:
	move.l	4(sp),xgc_val
	move.l	8(sp),xgc_ptr
	movem.l	d1-d2/a1-a2,-(sp)

	clr.l	-(sp)
	move.l	xgc_val,-(sp)
	move.w	#8,-(sp)
	move.w	#$0154,-(sp)	; Ssystem(GETCOOKIE)
	trap	#1
	lea 	$0c(sp),sp
	cmp.l	#-32,d0			; Does Ssystem exist at all?
	beq.s	xgc_oldway
	cmp.l	#-1,d0
	beq.s	xgcnocookie
	move.l	xgc_ptr,a1
	move.l	d0,(a1)
	moveq	#1,d0
	bra.s	xgcret
xgcnocookie:
	moveq	#0,d0
xgcret:
	movem.l	(sp)+,d1-d2/a1-a2
	rts
xgc_oldway:
	pea 	hunt_cookie
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	bra.s	xgcret
hunt_cookie:
	move.l	$05A0,D0
	beq.s   cookie_ex
	movea.l	d0,a0
	move.l	xgc_val,d1
cookie_l:
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	cmp.l	d1,d2
	beq.s	cookie_fnd
	tst.l	d2
	bne.s	cookie_l
cookie_ex:
	moveq	#0,d0
	rts
cookie_fnd:
	move.l	xgc_ptr,d0
	tst.l	d0
	beq.s	xhcnoptr
	move.l	d0,a0
	move.l	d3,(a0)
xhcnoptr:
	moveq   #1,d0
	rts


;********************************
;**** Initialize the player: ****
;********************************
.globl	_mod_init
_mod_init:
	clr.l	snd_cookie
	pea 	snd_cookie
	move.l	#$5F534E44,-(sp)	; '_SND' Cookie
	bsr 	_xgetcookie
	addq.l	#8,sp
	tst.l	d0
	beq.s	minoxbcheck
	move.l	snd_cookie,d0
	btst	#5,d0
	beq.s	minoxbcheck

	; Now check if the current sound hardware supports 8-bit samples..
	move.w	#2,-(sp)
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp
	btst	#0,d0		; Bit 0 = 8-bit sample support flag
	beq 	mi_reterr	; If 8-bit samples are not supported, return error

	; Check for GSXB:
	clr.w	gsxbflag
	clr.l	-(sp)
	move.l	#$47535842,-(sp)	; 'GSXB' Cookie
	bsr 	_xgetcookie
	addq.l	#8,sp
	tst.l	d0
	beq.s	minoxbcheck
	move.w	#-1,gsxbflag
	move.w	#2,bufmode			; If we're running under GSXB, use GSXB-Interrupt now!
	
minoxbcheck:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	#15646,d0		; 12kHz
	lea 	ciatab12,a0
	bsr 	creciatb
	move.l	#31291,d0		; 25kHz
	lea 	ciatab25,a0
	bsr 	creciatb
	move.l	#62582,d0		; 50kHz
	lea 	ciatab50,a0
	bsr 	creciatb

	move.w	#0,-(sp)
	move.l	#(bufsize*2)+256,-(sp)	; allocate sample replay buffers
	move.w	#68,-(sp)
	trap	#1					; Mxalloc
	addq.l	#8,sp
	cmp.l	#-32,d0
	bne.s	mallocok
	move.l	#(bufsize*2)+256,-(sp)
	move.w	#72,-(sp)
	trap	#1					; Malloc
	addq.l	#6,sp
mallocok:
	tst.l	d0
	bmi.s	mi_ret
	add.l	#31,d0				; For GSXB compatibility
	and.l	#-32,d0
	move.l	d0,sambuf_ptrs
	add.l	#bufsize+32,d0
	move.l	d0,sambuf_ptrs+4
mi_retok:
	moveq	#0,d0
	movem.l (sp)+,d1-d2/a0-a2
	rts
mi_reterr:
	moveq	#-1,d0
mi_ret:
	movem.l (sp)+,d1-d2/a0-a2
	rts


;** Create CIA-Emulation-Table: **
;*
;* unsigned short ciaemtab[256], tempo;
;* double hz,cia_clock=709378.92,temponum=1773447.0;
;* ciaemtab[0]=0;			/* tempo=0 case */
;* for(tempo=1 ; tempo<=255 ; tempo++) 
;*  { hz = (cia_clock/temponum)*(double)tempo;
;*    ciaemtab[tempo]=(25033.0/hz);		/* FRAME COUNT */
;*  }
;*
creciatb:
	clr.w	(a0)+
	move.w	#1,d1
crecialp:
	moveq	#0,d2
	move.w	d0,d2
	divu	d1,d2
	move.w	d2,(a0)+
	add.w	#1,d1
	cmp.w	#255,d1
	bls.s	crecialp
	rts


;***********************************
;****		Play a module		****
;***********************************
.globl _mod_play
_mod_play:
	move.l  4(sp),mod_addr	; Store module address
	movem.l	d1-d2/a0-a2,-(sp)
	;incase of accidents, we check if the pointers are not null :)
	tst.l	sambuf_ptrs
	beq 	mperr
	tst.w	_playflag
	beq.s	mp1
	bsr 	_mod_stop
mp1:
	move.w	#128,-(sp)
	trap	#14				; Locksnd()
	addq.l	#2,sp
	cmp.w	#1,d0
	bne 	mperr

	move.w	#0,-(sp)
	move.w	#140,-(sp)
	trap	#14				; Sndstatus(0)
	addq.l	#4,sp
	tst.w	d0
	beq.s	mp2
	move.w	#1,-(sp)		; If error reset codec
	move.w	#140,-(sp)
	trap	#14				; Sndstatus(1)
	addq.l	#4,sp
mp2:
	move.w	#0,-(sp)
	move.w	#134,-(sp)
	trap	#14				; setmontracks(0)
	addq.l	#4,sp

	clr.l	-(sp)
	move.w	#133,-(sp)
	trap	#14				; settracks(0,0)
	addq.l	#6,sp

	move.w	#0,-(sp)
	move.w	#132,-(sp)
	trap	#14				; setmode(0)
	addq.l	#4,sp

	; Set the sign
	; (Only possible with GSXB and MilanBlaster)
	clr.w	signflag		; Clear sign flag (means signed when clear)
	move.l	snd_cookie,d0
	btst	#5,d0
	beq.s	sign_okie		; Assume that we use signed samples
	;Get 8-bit sample formats supported by hardware...
	move.w	#8,-(sp)
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp
	move.l	d0,-(sp)
	;Get the currently selected format
	move.w	#-1,-(sp)
	move.w	#8,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	;If the currently selected format is supported by the hardware, leave it as is
	move.l	(sp)+,d1
	and.l	d1,d0
	bne.s	fmt_ok
	;Choose one of hardware supported sample formats..
	btst	#0,d1
	bne.s	use_signed
	moveq	#2,d0
	bra.s	got_sign
use_signed:
	moveq	#1,d0
got_sign:
	move.l	d0,-(sp)
	;Set the sample format to one supported by hardware
	move.w	d0,-(sp)
	move.w	#8,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	(sp)+,d0
	;Set our flag according to the resulting sign..
fmt_ok:
	btst	#0,d0
	bne.s	sign_okie
	;Using unsigned 8-bit samples..
	move.w	#-1,signflag
sign_okie:		

	bsr		xsetfreq

	move.w	#1,_playflag
	bsr 	mt_init
	bsr 	STspecific
	bsr 	fillfirst
	bsr 	start_music

	moveq	#0,d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts
mperr:
	moveq	#-1,d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts


;*********************************
;**** Stop playing the module ****
;*********************************
.globl _mod_stop
_mod_stop:
	tst.w	_playflag
	beq.s	msret

	movem.l	d0-d2/a0-a2,-(sp)
	move.w	#0,_playflag
	bsr 	stop_music

	move.w	#129,-(sp)
	trap	#14				; Unlocksnd()
	addq.l	#2,sp
	movem.l	(sp)+,d0-d2/a0-a2
msret:
	rts


;***********************
;**** Fast backward **** 
;***********************
.globl _mod_backward
_mod_backward:
	tst.w	_playflag
	beq 	mfbw_end
	cmp.b	#0,mt_SongPos
	ble 	mfbw_end
	clr.b	mt_counter
	clr.w	mt_PatternPos
	subq.b	#1,mt_SongPos

mfbwrestart:
	movem.l sambuf_ptrs,a0-a1
	exg.l	a0,a1
	movem.l a0-a1,sambuf_ptrs
	bsr 	fillbuf

	move.w	#0,-(sp)
	move.w	#136,-(sp)
	trap	#14				; buffoper(0)
	addq.l	#4,sp

	move.l	aktendbuf,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp

	tst.w	bufmode
	beq 	mfbbo1
	move.w	#3,d0
	bra.s	mfbbo
mfbbo1:
	move.w	#1,d0
mfbbo:
	move.w	d0,-(sp)
	move.w	#136,-(sp)
	trap	#14				; buffoper(1)
	addq.l	#4,sp

	movem.l sambuf_ptrs,a0-a1
	exg.l	a0,a1
	movem.l a0-a1,sambuf_ptrs
	bsr 	fillbuf

	move.l	aktendbuf,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp
mfbw_end:
	rts


;**********************
;**** Fast forward **** 
;**********************
.globl _mod_forward
_mod_forward:
	tst.w	_playflag
	beq.s	mfbw_end
	clr.b	mt_counter
	clr.w	mt_PatternPos
	addq.b  #1,mt_SongPos
	andi.b  #$7f,mt_SongPos
	move.b  mt_SongPos,d1
	movea.l mt_SongDataPtr,a0
	cmp.b	950(a0),d1
	blo 	mfbwrestart
	clr.b	mt_SongPos
	bra 	mfbwrestart


;******************************
;**** Configure the player **** 
;******************************
.globl _mod_setup
_mod_setup:
	move.w	4(sp),d0		; type
	cmp.w	#0,d0
	beq.s	mcfreq
	cmp.w	#2,d0
	beq 	mcbufmode
	cmp.w	#3,d0
	beq 	mctoggletempo
	rts
mcfreq:						; Set the frequency
	move.l	6(sp),d0		; value
	move.w	d0,freqval
	cmp.w	#2,d0
	beq.s	mcf50
	cmp.w	#1,d0
	beq.s	mcf25
	move.l	#ftab12,ftab
	move.l	#ciatab12,ciaemtab
	move.w	#7,devconf
	bra.s	mcfdc
mcf25:
	move.l	#ftab25,ftab
	move.l	#ciatab25,ciaemtab
	move.w	#3,devconf
	bra.s	mcfdc
mcf50:
	move.l	#ftab50,ftab
	move.l	#ciatab50,ciaemtab
	move.w	#1,devconf
mcfdc:
	tst.w	_playflag
	beq.s	mcfret
	bsr		xsetfreq
mcfret:
	rts
mcbufmode:					; Set the replay end-of-buffer mode
	tst.w	_playflag
	beq.s	mcbmok1
	bsr 	stop_music
mcbmok1:
	move.l	6(sp),d0		; value (0=polling-normal, 1=polling-loop
	move.w	d0,bufmode      ;   2=GSXB-Interrupt, 3=Timer-A-int, 4=MFP-i7-int)
	tst.w	_playflag
	beq.s	mcbmok2
	bsr 	start_music
mcbmok2:
	rts
mctoggletempo:				; Change tempo control
	move.l	6(sp),d0
	tst.w	d0
	bne.s	mctempoon
	tst.b	tempo_cont_flg
	beq.s	mctempok
	bsr.s	mod_toggletempo
mctempok:
	rts
mctempoon:
	tst.b	tempo_cont_flg
	bne.s	mctempok
	bsr.s	mod_toggletempo
	rts


; *** Set the freq. via XBIOS ***

xsetfreq:

	move.w	#1,-(sp)
	move.w  devconf,-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#0,-(sp)
	move.w	#139,-(sp)		; Devconnect
	trap	#14
	lea		$C(sp),sp

;	move.w	freqval,d0
;	addq.w	#1,d0
;	move.w	d0,-(sp)
;	move.w	#6,-(sp)
;	move.w	#130,-(sp)
;	trap	#14				; Soundcmd(6)
;	addq.l	#6,sp
;	move.w	#1,-(sp)
;	move.w  #0,-(sp)
;	move.w	#0,-(sp)
;	move.w	#8,-(sp)
;	move.w	#0,-(sp)
;	move.w	#139,-(sp)		; Devconnect
;	trap	#14
;	lea		$C(sp),sp
	
	rts


; ** Toggle Tempo Control. **
mod_toggletempo:
	tst.b	tempo_cont_flg		; toggle tempo
	beq.s	tempoon
	sf		tempo_cont_flg		; turn tempo control OFF
	move.w	RealTempo,OldTempo	; save current tempo
	move.w	#125,RealTempo		; switch to default tempo
	bra.s	endtempo
tempoon:
	st  	tempo_cont_flg		; turn tempo control ON
	move.w	OldTempo,RealTempo
endtempo:
	rts



; ** Fill the buffers the first time **
fillfirst:
	cmp.w	#2,bufmode      ; if we are using interrupts we are just setting
	bhs.s	fw_ints         ; emty buffers

	bsr 	fillbuf         ; Fill the first buffer

	move.l	aktendbuf,d0
	move.l	d0,endofbuf
	move.l	d0,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp

	movem.l sambuf_ptrs,a0-a1
	exg 	a0,a1
	movem.l a0-a1,sambuf_ptrs

	bsr 	fillbuf         ; Fill the second buffer

	rts

fw_ints:
	move.l	sambuf_ptrs,d0  ; the first buffer
	add.l	#40000,d0
	move.l	d0,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp

;	movem.l sambuf_ptrs,a0-a1
;	exg 	a0,a1
;	movem.l a0-a1,sambuf_ptrs

	move.l	sambuf_ptrs,d0  ; the second buffer
	add.l	#40000,d0
	move.l	d0,aktendbuf

	rts


; **Start up music**

start_music:
	move.w	#0,-(sp)
	move.w	#136,-(sp)
	trap	#14				; buffoper(0)
	addq.l	#4,sp

	move.w	bufmode,d0
	cmp.w	#0,d0
	bne.s	notmode0

	move.w	#1,-(sp)		; Polling without looping
	move.w	#136,-(sp)
	trap	#14				; buffoper(1)
	addq.l	#4,sp
	rts
notmode0:
	cmp.w	#1,d0
	beq 	setbo3			; Polling with looping
	cmp.w	#2,d0
	bne.s	notmode2

	pea 	i_gsxb			; Interrupt, GSXB mode
	move.w	#1,-(sp)
	move.w	#2,-(sp)
	move.w	#135,-(sp)
	trap	#14				; NSetinterrupt()
	lea 	10(sp),sp
	bra 	setbo3
notmode2:
	cmp.w	#3,d0			; Interrupt mode with Timer-A
	bne.s	notmode3

	pea 	i_timera(pc)
	move.w	#77,-(sp)		; Number of Timer-A
	move.w	#5,-(sp)
	trap	#13				; Setexc
	addq.l	#8,sp
	move.l	d0,oldirqvec	; Save old vector

	pea 	i_timera(pc)
	move.w	#1,-(sp)
	move.w	#8,-(sp)		; Event count mode
	move.w	#0,-(sp)		; Timer-a
	move.w	#31,-(sp)
	trap	#14				; Xbtimer()
	lea 	12(sp),sp

	move.w	#13,-(sp)
	move.w	#27,-(sp)
	trap	#14				; Jenabint
	addq.l	#4,sp

	move.w	#1,-(sp)
	move.w	#0,-(sp)
	move.w	#135,-(sp)
	trap	#14				; Setinterrupt()
	addq.l	#6,sp

	bra 	setbo3
notmode3:					; Interrupt mode with MFP-i7
	pea 	i_mfpi7(pc)
	move.w	#79,-(sp)		; Number of MFP-i7
	move.w	#5,-(sp)
	trap	#13				; Setexc
	addq.l	#8,sp
	move.l	d0,oldirqvec	; Save old vector

	pea 	i_mfpi7(pc)
	move.w	#15,-(sp)		; MFP-i7
	move.w	#13,-(sp)
	trap	#14				; Mpfint
	addq.l	#8,sp

	move.w	#15,-(sp)
	move.w	#27,-(sp)
	trap	#14				; Jenabint
	addq.l	#4,sp

	move.w	#1,-(sp)
	move.w	#1,-(sp)
	move.w	#135,-(sp)
	trap	#14				; Setinterrupt()
	addq.l	#6,sp

setbo3:
	move.w	#3,-(sp)
	move.w	#136,-(sp)
	trap	#14				; buffoper(3)
	addq.l	#4,sp
	rts


; **Stop it**

stop_music:
	move.w	#0,-(sp)
	move.w	#136,-(sp)
	trap	#14				; buffoper(0)
	addq.l	#4,sp

	move.w	bufmode,d0
	cmp.w	#2,d0
	blt 	stopmusend
	bne.s	stpmnot2

	pea 	stopmusend		; End of frame mode 2
	clr.w	-(sp)			; Uninstall interrupt
	move.w	#2,-(sp)
	move.w	#135,-(sp)
	trap	#14				; NSetinterrupt
	lea 	10(sp),sp
	bra.s	stopmusend
stpmnot2:
	cmp.w	#3,d0
	bne.s	stpmnot3

	move.w	#13,-(sp)
	move.w	#26,-(sp)
	trap	#14				; Jdisabint
	addq.l	#4,sp

	move.l 	oldirqvec,-(sp)
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	move.w	#0,-(sp)		; Timer-a
	move.w	#31,-(sp)
	trap	#14				; Xbtimer()
	lea 	12(sp),sp

	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#135,-(sp)
	trap	#14				; Setinterrupt()
	addq.l	#6,sp

	bra.s	stopmusend
stpmnot3:					; Disable MFP-i7 interrupt
	move.w	#15,-(sp)
	move.w	#26,-(sp)
	trap	#14				; Jdisabint
	addq.l	#4,sp

	move.l	oldirqvec,-(sp)
	move.w	#15,-(sp)		; MFP-i7
	move.w	#13,-(sp)
	trap	#14				; Mpfint
	addq.l	#8,sp

	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#135,-(sp)
	trap	#14				; Setinterrupt()
	addq.l	#6,sp

stopmusend:
	rts


; ** Polling mode: Check if the end of a buffer has been reached **
.globl _checkbuf
_checkbuf:
	movem.l	d0-d2/a0-a2,-(sp)

	cmp.w	#1,bufmode
	bhi 	cb0ret
	beq 	checkm1

	move.w	#-1,-(sp)
	move.w	#136,-(sp)
	trap	#14				; Buffoper(-1)
	addq.l	#4,sp
	tst.w	d0
	beq.s	cb0doit

	pea 	xbufptrs
	move.w	#141,-(sp)
	trap	#14				; Buffptr
	addq.l	#6,sp
	move.l	endofbuf,d0
	move.l	xbufptrs,d1
	sub.l	d1,d0
	cmp.l	#1000,d0		; Magic value 1
	bgt.s	cb0ret
cb0loop:

	move.w	#-1,-(sp)
	move.w	#136,-(sp)
	trap	#14				; Buffoper(-1)
	addq.l	#4,sp
	tst.w	d0
	beq.s	cb0doit

	pea 	xbufptrs
	move.w	#141,-(sp)
	trap	#14				; Buffptr
	addq.l	#6,sp
	move.l	endofbuf,d0		; We need to check it with Buffptr, too,
	move.l	xbufptrs,d1     ; since MagicPC 6.00 returns wrong Buffoper return codes!
;	sub.l	d1,d0
;	cmp.l	#2,d0		; Magic value 2
;	bhi.s	cb0loop
	cmp.l	d1,d0
	bne.s	cb0loop

cb0doit:
	move.l	aktendbuf,d0
	move.l	d0,endofbuf
	move.l	d0,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	move.w	#1,-(sp)
	move.w	#136,-(sp)
	trap	#14				; buffoper(1)
	lea		16(sp),sp

	movem.l sambuf_ptrs,a0-a1
	exg 	a0,a1
	movem.l a0-a1,sambuf_ptrs

	bsr 	fillbuf
cb0ret:
	movem.l	(sp)+,d0-d2/a0-a2
	rts


checkm1:					; Polling with looping
	pea 	xbufptrs
	move.w	#141,-(sp)
	trap	#14				; Buffptr
	addq.l	#6,sp
	move.l	endofbuf,d0
	move.l	xbufptrs,d1
	sub.l	d1,d0
	cmp.l	#1600,d0		; Magic value 3
	bgt.s	cb1ret

	move.l	aktendbuf,d0
	move.l	d0,endofbuf
	move.l	d0,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp

	movem.l sambuf_ptrs,a0-a1
	exg 	a0,a1
	movem.l a0-a1,sambuf_ptrs

	bsr 	fillbuf
cb1loop2:
	pea 	xbufptrs
	move.w	#141,-(sp)
	trap	#14				; Buffptr
	addq.l	#6,sp

	move.l	sambuf_ptrs+4,d1
	move.l	xbufptrs,d0
	cmp.l	d1,d0
	blo.s	cb1loop2
	move.l	endofbuf,d1
	cmp.l	d1,d0
	bhi.s	cb1loop2
cb1ret:
	movem.l	(sp)+,d0-d2/a0-a2
	rts




;** Interrupt function that is called when a buffer has been played: **
;** (GSXB mode) **
i_gsxb:
	tst.w	irqflag
	bne.s	igsxbend
	move.w	#1,irqflag
	movem.l	d0-d2/a0-a2,-(sp)

	movem.l sambuf_ptrs,a0-a1
	exg.l	a0,a1
	movem.l a0-a1,sambuf_ptrs

	bsr 	fillbuf

	move.l	aktendbuf,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp

	movem.l	(sp)+,d0-d2/a0-a2
	clr.w	irqflag
igsxbend:
	rts


;** Interrupt function that is called when a buffer has been played: **
;** (Timer-A mode) **
i_timera:
	bclr	#5,$FFFFFA0F		; ISRA
	move	#$2300,sr
	tst.w	irqflag
	bne.s	onlyrte
	move.w	#1,irqflag
	movem.l	d0-d2/a0-a2,-(sp)

	movem.l sambuf_ptrs,a0-a1
	exg.l	a0,a1
	movem.l a0-a1,sambuf_ptrs

	bsr.s	fillbuf

	move.l	aktendbuf,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14					; setbuffer
	lea		$C(sp),sp

	movem.l	(sp)+,d0-d2/a0-a2
	clr.w	irqflag
onlyrte:
	rte


;** Interrupt function that is called when a buffer has been played: **
;** (MFP-i7 mode) **
i_mfpi7:
	bclr	#7,$FFFFFA0F		; ISRA
	move	#$2300,sr
	tst.w	irqflag
	bne.s	onlyrte
	move.w	#1,irqflag
	movem.l	d0-d2/a0-a2,-(sp)

	movem.l sambuf_ptrs,a0-a1
	exg.l	a0,a1
	movem.l a0-a1,sambuf_ptrs

	bsr.s	fillbuf

	move.l	aktendbuf,-(sp)
	move.l	sambuf_ptrs,-(sp)
	move.w	#0,-(sp)
	move.w	#131,-(sp)
	trap	#14				; setbuffer
	lea		$C(sp),sp

	movem.l	(sp)+,d0-d2/a0-a2
	clr.w	irqflag
	rte


; *** Fill a whole buffer ***
fillbuf:
	move.l	sambuf_ptrs,a0
	moveq	#0,d0
fbloop:
	move.l	a0,aktsambuf
	bsr 	do_music
	move.l	ciaemtab,a1
	moveq	#0,d1
	move.w  RealTempo,d1
	add.w	d1,d1
	move.w  0(a1,d1.w),d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	cmp.w	#bufsize,d0
	bhs.s	fblopend
	add.l	d1,a0
	bra.s	fbloop
fblopend:
	move.l	a0,aktendbuf
	rts


; Player - This is THE 'Paula' Emulator.

do_music:
	movem.l d0-a6,-(sp)
	lea 	Voice1Set,a0	; Setup Chan 1
	lea 	ch1s,a5
	moveq	#0,d4
	bsr.s	SetupVoice
	lea 	Voice2Set,a0	;	"	2
	lea 	ch2s,a5
	moveq	#1,d4
	bsr.s	SetupVoice
	lea 	Voice3Set,a0	;	"	3
	lea 	ch3s,a5
	moveq	#2,d4
	bsr.s	SetupVoice
	lea 	Voice4Set,a0	;	"	4
	lea 	ch4s,a5
	moveq	#3,d4
	bsr.s	SetupVoice
	bsr 	Goforit
	bsr 	mt_music
	movem.l (sp)+,d0-a6
	rts


; Routine to add/move one voice to buffer. The real Paula emulation part!!

SetupVoice:
	movea.l sam_start(a5),a2 ; current sample end address(shadow amiga!)
	move.l  sam_length(a5),d0
	movem.w sam_period(a5),d1-d2 ; offset/period/volume
	cmp.w	#$40,d2
	bls.s	vol_ok
	moveq	#$40,d2
vol_ok:
	lsl.w	#8,d2			; offset into volume tab
	move.l 	ftab,a6
	add.w	d1,d1
	move.w  d1,d7
	add.w	d1,d1
	add.w	d7,d1			; => d1 * 6
	adda.l  d1,a6
	move.w  (a6)+,d1		; int part
	move.l  (a6)+,d3
	neg.l	d0				; negate sample offset
	move.w  shadow_dmacon,d7
	btst	d4,d7
	bne.s	vcon2
	moveq	#0,d1			; clear freq if off.
	moveq	#0,d3			; clear freq if off.
	moveq	#0,d2			; volume off for safety!!
vcon2:
	lea 	nulsamp+2,a6
	cmpa.l  a6,a2
	bne.s	vcon
	moveq	#0,d1			; clear freq if off.
	moveq	#0,d3			; clear freq if off.
	moveq	#0,d2			; volume off for safety!!
vcon:
	movea.l sam_lpstart(a5),a6 ; loop addr
	move.l  sam_lplength(a5),d5 ; loop length
	neg.l	d5				; negate it.
	move.w  d1,d6			; freq on loop
	move.l  d3,d7
; cmp.l	#-1,d5			; Added by Thothy for security
; beq.s	noloop
	cmp.l	#-2,d5
	bne.s	isloop
noloop:
	moveq	#0,d6
	moveq	#0,d7			; no loop-no frequency
	lea 	nulsamp+2,a6	; no loop-point to nul
isloop:
	move.l  a2,(a0)+		; store address
	move.l  d0,(a0)+		; store offset int.L
	addq.l  #4,a0			; skip current frac.l
	move.w  d1,(a0)+		; store freq int.w
	move.l  d3,(a0)+		; store freq 32bit fraction
	move.w  d2,(a0)+		; address of volume tab.
	move.l  a6,(a0)+		; store loop addr
	move.l  d5,(a0)+		; store loop offset.L
	move.w  d6,(a0)+		; store loop freq int.w
	move.l  d7,(a0)+		; store loop freq frac.L
	rts


; Make that buffer! (channels are paired together!)

Goforit:
	lea 	ch1s,a2
	lea 	ch4s,a3
	lea 	Voice1Set,a5
	lea 	Voice4Set,a6
	move.l  #0,bufadd
	bsr.s	do2chans
	lea 	ch2s,a2
	lea 	ch3s,a3
	lea 	Voice2Set,a5
	lea 	Voice3Set,a6
	move.l  #1,bufadd
	bsr.s	do2chans
	rts

; Create 2 channels in the buffer.

do2chans:
	movem.l a2-a3/a5-a6,-(sp)
	move.l  voltab_ptr,d2
	move.l  d2,d3
	moveq	#0,d4
	move.w  Vvoltab(a5),d4
	add.l	d4,d2	; volume tab chan 1
	move.w  Vvoltab(a6),d4
	add.l	d4,d3	; volume tab chan 2

	movea.l Vaddr(a5),a0	; ptr to end of each sample!
	move.l  Voffy(a5),d0	; int.w offset
	move.l  Vfrac(a5),d4	; frac.w offset
	move.w  Vfreqint(a5),d6
	movea.l Vfreqfrac(a5),a2 ; frac.w/int.w freq

	movea.l Vaddr(a6),a1
	move.l  Voffy(a6),d1
	move.l  Vfrac(a6),d5
	move.w  Vfreqint(a6),d7
	movea.l Vfreqfrac(a6),a3
	swap	d6

	move.l  Vlpaddr(a5),lpvc1_1 ; loop for voice 1
	move.l  Vlpoffy(a5),lpvc1_2
	move.l  Vlpfreqfrac(a5),lpvc1_3
	move.w  Vlpfreqint(a5),lpvc1_4

	move.l  Vlpaddr(a6),lpvc2_1 ; loop for voice 1
	move.l  Vlpoffy(a6),lpvc2_2
	move.l  Vlpfreqfrac(a6),lpvc2_3
	move.w  Vlpfreqint(a6),lpvc2_4

	move.l	ciaemtab,a4
	move.w  RealTempo,d6
	add.w	d6,d6
	move.w  0(a4,d6.w),d6

	movea.l aktsambuf,a4
	adda.l  bufadd,a4
	bsr.s	add2

	movem.l (sp)+,a2-a3/a5-a6
	neg.l	d0		; +ve offset(as original!)
	neg.l	d1
	move.l  a0,sam_start(a2) ; store voice address
	move.l  d0,sam_length(a2) ; store offset for next time
	move.l  d4,Vfrac(a5)	; store frac part
	move.l  a1,sam_start(a3) ; same for chan 2
	move.l  d1,sam_length(a3)
	move.l  d5,Vfrac(a6)
	rts


add2:
	movea.l a4,a6
make12_stelp:
	move.b  0(a0,d0.l),d2
	movea.l d2,a4
	move.b  (a4),d2
	move.b  0(a1,d1.l),d3
	movea.l d3,a4
	add.b	(a4),d2
	tst.b	signflag
	beq.s	nosign
	eor.b	#$80,d2		; Change the sign!
nosign:
	move.b  d2,(a6)
	move.b  d2,2(a6)	; oversample(!)
	addq.l  #4,a6
	swap	d6
	add.l	a2,d4	; 32 bit fraction
	addx.w  d6,d0
	bcs.s	lpvc1ste
contlp1ste:
	swap	d6
	add.l	a3,d5
	addx.w  d7,d1
contlp2ste:
	dbcs	d6,make12_stelp
	bcs.s	lpvc2ste

	move.b  d2,(a6)		; smooth
	move.b  d2,2(a6)	; in case!
	move.b  d2,4(a6)
	move.b  d2,6(a6)
	move.b  d2,8(a6)
	move.b  d2,10(a6)
	move.b  d2,12(a6)
	move.b  d2,14(a6)

	rts

lpvc1ste:
	ext.l	d0
	move.l 	lpvc1_1,a0
	add.l	lpvc1_2,d0
	move.l 	lpvc1_3,a2
	move.w  lpvc1_4,d6
	bra.s	contlp1ste

lpvc2ste:
	ext.l	d1
	move.l 	lpvc2_1,a1
	add.l	lpvc2_2,d1
	move.l 	lpvc2_3,a3
	move.w  lpvc2_4,d7
	move	#0,ccr
	bra.s	contlp2ste


; Create the 65 volume lookup tables

makevoltab:
	move.l  #vols+256,d0
	clr.b	d0
	movea.l d0,a0
	move.l  a0,voltab_ptr
	lea 	16640(a0),a0
	moveq	#$40,d0
lp7:
	move.w	#$ff,d1
lp8:
	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	asr.l	#7,d2
	move.b  d2,-(a0)
	dbra	d1,lp8
	dbra	d0,lp7
	move.l 	sambuf_ptrs,a0
	move.l	sambuf_ptrs+4,a1
	move.w  #(bufsize/4)-1,d0
	;A check here to determing signed/unsigned samples
	;and use 0 for signed/$80 for unsigned
	tst.b	signflag
	beq.s	clsigned
	move.l	#$80808080,d1
	bra.s	lp9
clsigned:
	moveq	#0,d1
lp9:
	move.l	d1,(a0)+
	move.l  d1,(a1)+
	dbra	d0,lp9
	rts


; ST specific initialise - sets up shadow amiga registers etc

STspecific:
	bsr 	makevoltab
	lea 	nulsamp+2,a2
	moveq	#0,d0
	lea 	ch1s,a0
	bsr.s	initvoice
	lea 	ch2s,a0
	bsr.s	initvoice
	lea 	ch3s,a0
	bsr.s	initvoice
	lea 	ch4s,a0
	bsr.s	initvoice
	rts

; A0-> voice data (paula voice) to initialise.

initvoice:
	move.l  a2,sam_start(a0) ; point voice to nul sample
	move.l  #2,sam_length(a0)
	move.w  d0,sam_period(a0) ; period=0
	move.w  d0,sam_vol(a0)  ; volume=0
	move.l  a2,sam_lpstart(a0) ; and loop point to nul sample
	move.l  #2,sam_lplength(a0)
	rts


;**************************************************
;*	----- Protracker V2.1A Playroutine -----	*
;* Peter "CRAYON" Hanning / Mushroom Studios 1992 *
;*	Vinterstigen 12, 14440 Ronninge, Sweden	*
;**************************************************

; CIA Version 1:
; This playroutine is not very fast, optimized or well commented,
; but all the new commands in PT2.1 should work.
; If it's not good enough, you'll have to change it yourself.
; We'll try to write a faster routine soon...

; Changes from V1.0C playroutine:
; - Vibrato depth changed to be compatible with Noisetracker 2.0.
;	You'll have to double all vib. depths on old PT modules.
; - Funk Repeat changed to Invert Loop.
; - Period set back earlier when stopping an effect.


;---- Playroutine ----

mt_init:
	movea.l mod_addr,a0	; Address of module in A0
	move.l  a0,mt_SongDataPtr
	movea.l a0,a1
	lea 	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop:
	move.l  d1,d2
	subq.w  #1,d0
mtloop2:
	move.b  (a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b  #1,d2

	lea 	mt_SampleStarts,a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#1084,d2
	add.l	a0,d2
	movea.l d2,a2
	moveq	#30,d0
mtloop3:
;	clr.l	(a2)
	move.l  a2,(a1)+
	moveq	#0,d1
	move.w  42(a0),d1
	asl.l	#1,d1
	adda.l  d1,a2
	adda.l  #30,a0
	dbra	d0,mtloop3

	move.b  #6,mt_speed
	clr.b	mt_counter
	clr.b	mt_SongPos
	clr.w	mt_PatternPos
	st		mt_Enable

;(1) move_dmacon #$F
	andi.w  #$f0,shadow_dmacon ; mask bits in dmacon

	rts

mt_end: sf	mt_Enable

;(2) move_dmacon #$F
	andi.w  #$f0,shadow_dmacon

	rts

mt_music:
	tst.b	mt_Enable
	beq	mt_exit
	addq.b  #1,mt_counter
	move.b  mt_counter,d0
	cmp.b	mt_speed,d0
	blo.s	mt_NoNewNote
	clr.b	mt_counter
	tst.b	mt_PattDelTime2
	beq.s	mt_GetNewNote
	bsr.s	mt_NoNewAllChannels
	bra	mt_dskip

mt_NoNewNote:
	bsr.s	mt_NoNewAllChannels
	bra	mt_NoNewPosYet

mt_NoNewAllChannels:
	lea	ch1s,a5
	lea	mt_chan1temp,a6
	bsr	mt_CheckEfx
	lea	ch2s,a5
	lea	mt_chan2temp,a6
	bsr	mt_CheckEfx
	lea	ch3s,a5
	lea	mt_chan3temp,a6
	bsr	mt_CheckEfx
	lea	ch4s,a5
	lea	mt_chan4temp,a6
	bra	mt_CheckEfx

mt_GetNewNote:
	movea.l mt_SongDataPtr,a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b  mt_SongPos,d0
	move.b  0(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_PatternPos,d1
	clr.w	mt_DMACONtemp

	lea	ch1s,a5
	lea	mt_chan1temp,a6
	bsr.s	mt_PlayVoice
	lea	ch2s,a5
	lea	mt_chan2temp,a6
	bsr.s	mt_PlayVoice
	lea	ch3s,a5
	lea	mt_chan3temp,a6
	bsr.s	mt_PlayVoice
	lea	ch4s,a5
	lea	mt_chan4temp,a6
	bsr.s	mt_PlayVoice
	bra	mt_SetDMA

mt_PlayVoice:
	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_PerNop
mt_plvskip:
	move.l  0(a0,d1.l),(a6)
	addq.l  #4,d1
	moveq	#0,d2
	move.b  n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b  (a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq 	mt_SetRegs
	moveq	#0,d3
	lea 	mt_SampleStarts,a1
	move.w  d2,d4
	subq.l  #1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l  0(a1,d2.l),n_start(a6)
	move.w  0(a3,d4.l),n_length(a6)
	move.w  0(a3,d4.l),n_reallength(a6)
	move.b  2(a3,d4.l),n_finetune(a6)
	move.b  3(a3,d4.l),n_volume(a6)
	move.w  4(a3,d4.l),d3	; Get repeat
	tst.w	d3
	beq.s	mt_NoLoop
	move.l  n_start(a6),d2  ; Get start
	asl.w	#1,d3
	add.l	d3,d2	; Add repeat
	move.l  d2,n_loopstart(a6)
	move.l  d2,n_wavestart(a6)
	move.w  4(a3,d4.l),d0	; Get repeat
	add.w	6(a3,d4.l),d0	; Add replen
	move.w  d0,n_length(a6)
	move.w  6(a3,d4.l),n_replen(a6) ; Save replen
	moveq	#0,d0
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)  ; Set volume
	bra.s	mt_SetRegs
mt_NoLoop:
	move.l  n_start(a6),d2
	add.l	d3,d2
	move.l  d2,n_loopstart(a6)
	move.l  d2,n_wavestart(a6)
	move.w  6(a3,d4.l),n_replen(a6) ; Save replen
	moveq	#0,d0
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)  ; Set volume
mt_SetRegs:
	move.w  (a6),d0
	and.w	#$0fff,d0
	beq	mt_CheckMoreEfx ; If no note
	move.w  2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_DoSetFineTune
	move.b  2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; TonePortamento
	beq.s	mt_ChkTonePorta
	cmp.b	#5,d0
	beq.s	mt_ChkTonePorta
	cmp.b	#9,d0	; Sample Offset
	bne.s	mt_SetPeriod
	bsr	mt_CheckMoreEfx
	bra.s	mt_SetPeriod

mt_DoSetFineTune:
	bsr	mt_SetFineTune
	bra.s	mt_SetPeriod

mt_ChkTonePorta:
	bsr	mt_SetTonePorta
	bra	mt_CheckMoreEfx

mt_SetPeriod:
	movem.l d0-d1/a0-a1,-(sp)
	move.w  (a6),d1
	and.w	#$0fff,d1
	lea 	mt_PeriodTable(pc),a1
	moveq	#0,d0
	moveq	#36,d2
mt_ftuloop:
	cmp.w	0(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l  #2,d0
	dbra	d2,mt_ftuloop
mt_ftufound:
	moveq	#0,d1
	move.b  n_finetune(a6),d1
	mulu	#36*2,d1
	adda.l  d1,a1
	move.w  0(a1,d0.w),n_period(a6)
	movem.l (sp)+,d0-d1/a0-a1

	move.w  2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0	; Notedelay
	beq 	mt_CheckMoreEfx

;(3) move_dmacon n_dmabit(A6)
	move.w  d4,-(sp)	; save D4
	move.w  n_dmabit(a6),d4
	btst	#15,d4	; set or clear?
	bne.s	setbits3
	not.w	d4		; zero so clear
	and.w	d4,shadow_dmacon ; mask bits in dmacon
	bra.s	dmacon_set3	; and exit...
setbits3:
	or.w	d4,shadow_dmacon ; not zero so set 'em
dmacon_set3:
	move.w	(sp)+,d4	; restore D4

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc:
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc:
	move.l  n_start(a6),sam_start(a5) ; Set start
	moveq	#0,d0
	move.w  n_length(a6),d0
	add.l	d0,d0
	add.l	d0,sam_start(a5)
	move.l  d0,sam_length(a5) ; Set length

	move.w  n_period(a6),d0
	move.w  d0,sam_period(a5) ; Set period
	move.w  n_dmabit(a6),d0
	or.w	d0,mt_DMACONtemp
	bra 	mt_CheckMoreEfx

mt_SetDMA:
	move.w  mt_DMACONtemp,d0
	or.w	#$8000,d0

;(4) move_dmacon d0
	move.w  d4,-(sp)
	move.w  d0,d4
	btst	#15,d4
	bne.s	setbits4
	not.w	d4
	and.w	d4,shadow_dmacon
	bra.s	dmacon_set4
setbits4:
	or.w	d4,shadow_dmacon
dmacon_set4:
	move.w	(sp)+,d4

	lea 	ch4s,a5
	lea 	mt_chan4temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

	lea	ch3s,a5
	lea	mt_chan3temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

	lea	ch2s,a5
	lea	mt_chan2temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

	lea	ch1s,a5
	lea	mt_chan1temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

mt_dskip:
	addi.w  #16,mt_PatternPos
	move.b  mt_PattDelTime,d0
	beq.s	mt_dskc
	move.b  d0,mt_PattDelTime2
	clr.b	mt_PattDelTime
mt_dskc:
	tst.b	mt_PattDelTime2
	beq.s	mt_dska
	subq.b  #1,mt_PattDelTime2
	beq.s	mt_dska
	subi.w  #16,mt_PatternPos
mt_dska:
	tst.b	mt_PBreakFlag
	beq.s	mt_nnpysk
	sf  	mt_PBreakFlag
	moveq	#0,d0
	move.b  mt_PBreakPos,d0
	clr.b	mt_PBreakPos
	lsl.w	#4,d0
	move.w  d0,mt_PatternPos
mt_nnpysk:
	cmpi.w  #1024,mt_PatternPos
	blo.s	mt_NoNewPosYet
mt_NextPosition:
	moveq	#0,d0
	move.b  mt_PBreakPos,d0
	lsl.w	#4,d0
	move.w  d0,mt_PatternPos
	clr.b	mt_PBreakPos
	clr.b	mt_PosJumpFlag
	addq.b  #1,mt_SongPos
	andi.b  #$7f,mt_SongPos
	move.b  mt_SongPos,d1
	movea.l mt_SongDataPtr,a0
	cmp.b	950(a0),d1
	blo.s	mt_NoNewPosYet
	clr.b	mt_SongPos
mt_NoNewPosYet:
	tst.b	mt_PosJumpFlag
	bne.s	mt_NextPosition
mt_exit:
	rts

mt_CheckEfx:
	bsr	mt_UpdateFunk
	move.w  n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_PerNop
	move.b  n_cmd(a6),d0
	and.b	#$0f,d0
	beq.s	mt_Arpeggio
	cmp.b	#1,d0
	beq	mt_PortaUp
	cmp.b	#2,d0
	beq	mt_PortaDown
	cmp.b	#3,d0
	beq	mt_TonePortamento
	cmp.b	#4,d0
	beq	mt_Vibrato
	cmp.b	#5,d0
	beq	mt_TonePlusVolSlide
	cmp.b	#6,d0
	beq	mt_VibratoPlusVolSlide
	cmp.b	#$0e,d0
	beq	mt_E_Commands
SetBack:move.w  n_period(a6),sam_period(a5)
	cmp.b	#7,d0
	beq	mt_Tremolo
	cmp.b	#$0a,d0
	beq	mt_VolumeSlide
mt_Return:
	rts

mt_PerNop:
	move.w  n_period(a6),sam_period(a5)
	rts

mt_Arpeggio:
	moveq	#0,d0
	move.b  mt_counter,d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_Arpeggio2
	cmp.w	#2,d0
	beq.s	mt_Arpeggio1
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_Arpeggio3

mt_Arpeggio1:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_Arpeggio3

mt_Arpeggio2:
	move.w  n_period(a6),d2
	bra.s	mt_Arpeggio4

mt_Arpeggio3:
	asl.w	#1,d0
	moveq	#0,d1
	move.b  n_finetune(a6),d1
	mulu	#36*2,d1
	lea 	mt_PeriodTable(pc),a0
	adda.l  d1,a0
	moveq	#0,d1
	move.w  n_period(a6),d1
	moveq	#36,d3
mt_arploop:
	move.w  0(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_Arpeggio4
	addq.l  #2,a0
	dbra	d3,mt_arploop
	rts

mt_Arpeggio4:
	move.w  d2,sam_period(a5)
	rts

mt_FinePortaUp:
	tst.b	mt_counter
	bne.s	mt_Return
	move.b  #$0f,mt_LowMask
mt_PortaUp:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	mt_LowMask,d0
	move.b  #$ff,mt_LowMask
	sub.w	d0,n_period(a6)
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_PortaUskip
	andi.w  #$f000,n_period(a6)
	ori.w	#113,n_period(a6)
mt_PortaUskip:
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	move.w  d0,sam_period(a5)
	rts

mt_FinePortaDown:
	tst.b	mt_counter
	bne	mt_Return
	move.b  #$0f,mt_LowMask
mt_PortaDown:
	clr.w	d0
	move.b  n_cmdlo(a6),d0
	and.b	mt_LowMask,d0
	move.b  #$ff,mt_LowMask
	add.w	d0,n_period(a6)
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_PortaDskip
	andi.w  #$f000,n_period(a6)
	ori.w	#856,n_period(a6)
mt_PortaDskip:
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	move.w  d0,sam_period(a5)
	rts

mt_SetTonePorta:
	move.l  a0,-(sp)
	move.w  (a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b  n_finetune(a6),d0
	mulu	#37*2,d0
	lea 	mt_PeriodTable(pc),a0
	adda.l  d0,a0
	moveq	#0,d0
mt_StpLoop:
	cmp.w	0(a0,d0.w),d2
	bhs.s	mt_StpFound
	addq.w  #2,d0
	cmp.w	#37*2,d0
	blo.s	mt_StpLoop
	moveq	#35*2,d0
mt_StpFound:
	move.b  n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_StpGoss
	tst.w	d0
	beq.s	mt_StpGoss
	subq.w  #2,d0
mt_StpGoss:
	move.w  0(a0,d0.w),d2
	movea.l (sp)+,a0
	move.w  d2,n_wantedperiod(a6)
	move.w  n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_ClearTonePorta
	bge	mt_Return
	move.b  #1,n_toneportdirec(a6)
	rts

mt_ClearTonePorta:
	clr.w	n_wantedperiod(a6)
	rts

mt_TonePortamento:
	move.b  n_cmdlo(a6),d0
	beq.s	mt_TonePortNoChange
	move.b  d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_TonePortNoChange:
	tst.w	n_wantedperiod(a6)
	beq	mt_Return
	moveq	#0,d0
	move.b  n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_TonePortaUp
mt_TonePortaDown:
	add.w	d0,n_period(a6)
	move.w  n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_TonePortaSetPer
	move.w  n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_TonePortaSetPer

mt_TonePortaUp:
	sub.w	d0,n_period(a6)
	move.w  n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_TonePortaSetPer
	move.w  n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_TonePortaSetPer:
	move.w  n_period(a6),d2
	move.b  n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_GlissSkip
	moveq	#0,d0
	move.b  n_finetune(a6),d0
	mulu	#36*2,d0
	lea 	mt_PeriodTable(pc),a0
	adda.l  d0,a0
	moveq	#0,d0
mt_GlissLoop:
	cmp.w	0(a0,d0.w),d2
	bhs.s	mt_GlissFound
	addq.w  #2,d0
	cmp.w	#36*2,d0
	blo.s	mt_GlissLoop
	moveq	#35*2,d0
mt_GlissFound:
	move.w  0(a0,d0.w),d2
mt_GlissSkip:
	move.w  d2,sam_period(a5) ; Set period
	rts

mt_Vibrato:
	move.b  n_cmdlo(a6),d0
	beq.s	mt_Vibrato2
	move.b  n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip:
	move.b  n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2:
	move.b  d2,n_vibratocmd(a6)
mt_Vibrato2:
	move.b  n_vibratopos(a6),d0
	lea	mt_VibratoTable(pc),a4
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b  n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b  #255,d2
	bra.s	mt_vib_set
mt_vib_rampdown:
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b  #255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2:
	move.b  d0,d2
	bra.s	mt_vib_set
mt_vib_sine:
	move.b  0(a4,d0.w),d2
mt_vib_set:
	move.b  n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w  n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_VibratoNeg
	add.w	d2,d0
	bra.s	mt_Vibrato3
mt_VibratoNeg:
	sub.w	d2,d0
mt_Vibrato3:
	move.w  d0,sam_period(a5)
	move.b  n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_TonePlusVolSlide:
	bsr	mt_TonePortNoChange
	bra	mt_VolumeSlide

mt_VibratoPlusVolSlide:
	bsr.s	mt_Vibrato2
	bra	mt_VolumeSlide

mt_Tremolo:
	move.b  n_cmdlo(a6),d0
	beq.s	mt_Tremolo2
	move.b  n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip:
	move.b  n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2:
	move.b  d2,n_tremolocmd(a6)
mt_Tremolo2:
	move.b  n_tremolopos(a6),d0
	lea	mt_VibratoTable(pc),a4
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b  n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b  #255,d2
	bra.s	mt_tre_set
mt_tre_rampdown:
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b  #255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2:
	move.b  d0,d2
	bra.s	mt_tre_set
mt_tre_sine:
	move.b  0(a4,d0.w),d2
mt_tre_set:
	move.b  n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b  n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_TremoloNeg
	add.w	d2,d0
	bra.s	mt_Tremolo3
mt_TremoloNeg:
	sub.w	d2,d0
mt_Tremolo3:
	bpl.s	mt_TremoloSkip
	clr.w	d0
mt_TremoloSkip:
	cmp.w	#$40,d0
	bls.s	mt_TremoloOk
	move.w  #$40,d0
mt_TremoloOk:
	move.w  d0,sam_vol(a5)
	move.b  n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_SampleOffset:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b  d0,n_sampleoffset(a6)
mt_sononew:
	move.b  n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip:
	move.w  #$01,n_length(a6)
	rts

mt_VolumeSlide:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_VolSlideDown
mt_VolSlideUp:
	add.b	d0,n_volume(a6)
	cmpi.b  #$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b  #$40,n_volume(a6)
mt_vsuskip:
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)
	rts

mt_VolSlideDown:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_VolSlideDown2:
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip:
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)
	rts

mt_PositionJump:
	move.b  n_cmdlo(a6),d0
	subq.b  #1,d0
	move.b  d0,mt_SongPos
mt_pj2: clr.b	mt_PBreakPos
	st	mt_PosJumpFlag
	rts

mt_VolumeChange:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_VolumeOk
	moveq	#$40,d0
mt_VolumeOk:
	move.b  d0,n_volume(a6)
	move.w  d0,sam_vol(a5)
	rts

mt_PatternBreak:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	move.l  d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b  d0,mt_PBreakPos
	st  	mt_PosJumpFlag
	rts

mt_SetSpeed:
	moveq	#0,d0
	move.b  3(a6),d0
	beq	mt_end
	tst.b	tempo_cont_flg  ; tempo control on?
	beq.s	notempo
	cmp.b	#32,d0			; yes then d0>=32
	bhs.s	SetTempo		; then Set Tempo
	clr.b	mt_counter
	move.b  d0,mt_speed
	rts
notempo:				; tempo control is OFF
	clr.b	mt_counter
	move.b  d0,mt_speed	; so set speed  regardless
	cmp.w	#32,d0
	blo.s	okdefspeed
	move.w  d0,OldTempo	; but store in old tempo
okdefspeed:			; for tempo turn back on.
	rts

SetTempo:
	cmp.w	#32,d0
	bhs.s	setemsk
	moveq	#32,d0
setemsk:move.w  d0,RealTempo	; set tempo speed
	rts

mt_CheckMoreEfx:
	bsr	mt_UpdateFunk
	move.b  2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$09,d0
	beq	mt_SampleOffset
	cmp.b	#$0b,d0
	beq	mt_PositionJump
	cmp.b	#$0d,d0
	beq	mt_PatternBreak
	cmp.b	#$0e,d0
	beq.s	mt_E_Commands
	cmp.b	#$0f,d0
	beq.s	mt_SetSpeed
	cmp.b	#$0c,d0
	beq	mt_VolumeChange
	bra	mt_PerNop

mt_E_Commands:
	move.b  n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
	beq.s	mt_FilterOnOff
	cmp.b	#1,d0
	beq	mt_FinePortaUp
	cmp.b	#2,d0
	beq	mt_FinePortaDown
	cmp.b	#3,d0
	beq.s	mt_SetGlissControl
	cmp.b	#4,d0
	beq.s	mt_SetVibratoControl
	cmp.b	#5,d0
	beq.s	mt_SetFineTune
	cmp.b	#6,d0
	beq	mt_JumpLoop
	cmp.b	#7,d0
	beq	mt_SetTremoloControl
	cmp.b	#9,d0
	beq	mt_RetrigNote
	cmp.b	#$0a,d0
	beq	mt_VolumeFineUp
	cmp.b	#$0b,d0
	beq	mt_VolumeFineDown
	cmp.b	#$0c,d0
	beq	mt_NoteCut
	cmp.b	#$0d,d0
	beq	mt_NoteDelay
	cmp.b	#$0e,d0
	beq	mt_PatternDelay
	cmp.b	#$0f,d0
	beq	mt_FunkIt
	rts

mt_FilterOnOff:
	move.b  n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
;	and.b	#$FD,$BFE001		; filter!
;	or.b	D0,$BFE001		; hehe
	rts

mt_SetGlissControl:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	andi.b  #$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_SetVibratoControl:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	andi.b  #$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_SetFineTune:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b  d0,n_finetune(a6)
	rts

mt_JumpLoop:
	tst.b	mt_counter
	bne	mt_Return
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_SetLoop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b  #1,n_loopcount(a6)
	beq	mt_Return
mt_jmploop:move.b n_pattpos(a6),mt_PBreakPos
	st	mt_PBreakFlag
	rts

mt_jumpcnt:
	move.b  d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_SetLoop:
	move.w  mt_PatternPos,d0
	lsr.w	#4,d0
	move.b  d0,n_pattpos(a6)
	rts

mt_SetTremoloControl:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	andi.b  #$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_RetrigNote:
	move.l  d1,-(sp)
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq	mt_rtnend
	moveq	#0,d1
	move.b  mt_counter,d1
	bne.s	mt_rtnskp
	move.w  (a6),d1
	and.w	#$0fff,d1
	bne	mt_rtnend
	moveq	#0,d1
	move.b  mt_counter,d1
mt_rtnskp:
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_DoRetrig:

;(5) move_dmacon n_dmabit(A6)	; Channel DMA off
	move.w  d4,-(sp)
	move.w  n_dmabit(a6),d4
	btst	#15,d4
	bne.s	setbits5
	not.w	d4
	and.w	d4,shadow_dmacon
	bra.s	dmacon_set5
setbits5:or.w	d4,shadow_dmacon
dmacon_set5:move.w (sp)+,d4

	move.l  n_start(a6),sam_start(a5) ; Set sampledata pointer
	moveq	#0,d0
	move.w  n_length(a6),d0 ; Set length
	add.l	d0,d0
	add.l	d0,sam_start(a5)
	move.l  d0,sam_length(a5) ; Set length

	move.w  n_dmabit(a6),d0
	bset	#15,d0

;(6) move_dmacon d0
	move.w  d4,-(sp)
	move.w  d0,d4
	btst	#15,d4
	bne.s	setbits6
	not.w	d4
	and.w	d4,shadow_dmacon
	bra.s	dmacon_set6
setbits6:or.w	d4,shadow_dmacon
dmacon_set6:move.w (sp)+,d4

	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	add.l	d0,sam_lpstart(a5)
	move.l  d0,sam_lplength(a5)
	move.w  n_replen+2(a6),sam_period(a5)
mt_rtnend:
	move.l  (sp)+,d1
	rts

mt_VolumeFineUp:
	tst.b	mt_counter
	bne	mt_Return
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_VolSlideUp

mt_VolumeFineDown:
	tst.b	mt_counter
	bne	mt_Return
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_VolSlideDown2

mt_NoteCut:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_Return
	clr.b	n_volume(a6)
	move.w  #0,sam_vol(a5)
	rts

mt_NoteDelay:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_Return
	move.w  (a6),d0
	beq	mt_Return
	move.l  d1,-(sp)
	bra	mt_DoRetrig

mt_PatternDelay:
	tst.b	mt_counter
	bne	mt_Return
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_PattDelTime2
	bne	mt_Return
	addq.b  #1,d0
	move.b  d0,mt_PattDelTime
	rts

mt_FunkIt:
	tst.b	mt_counter
	bne	mt_Return
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	andi.b  #$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_Return
mt_UpdateFunk:
	movem.l d1/a0,-(sp)
	moveq	#0,d0
	move.b  n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_FunkTable(pc),a0
	move.b  0(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l  n_loopstart(a6),d0
	moveq	#0,d1
	move.w  n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	movea.l n_wavestart(a6),a0
	addq.l  #1,a0
	cmpa.l  d0,a0
	blo.s	mt_funkok
	movea.l n_loopstart(a6),a0
mt_funkok:
	move.l  a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b  d0,(a0)
mt_funkend:
	movem.l (sp)+,d1/a0
	rts


;**** Tables ****

mt_FunkTable:dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable:
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

mt_PeriodTable:
; Tuning 0, Normal
	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w 844,796,752,709,670,632,597,563,532,502,474,447
	dc.w 422,398,376,355,335,316,298,282,266,251,237,224
	dc.w 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w 838,791,746,704,665,628,592,559,528,498,470,444
	dc.w 419,395,373,352,332,314,296,280,264,249,235,222
	dc.w 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w 832,785,741,699,660,623,588,555,524,495,467,441
	dc.w 416,392,370,350,330,312,294,278,262,247,233,220
	dc.w 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w 826,779,736,694,655,619,584,551,520,491,463,437
	dc.w 413,390,368,347,328,309,292,276,260,245,232,219
	dc.w 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w 820,774,730,689,651,614,580,547,516,487,460,434
	dc.w 410,387,365,345,325,307,290,274,258,244,230,217
	dc.w 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w 814,768,725,684,646,610,575,543,513,484,457,431
	dc.w 407,384,363,342,323,305,288,272,256,242,228,216
	dc.w 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w 907,856,808,762,720,678,640,604,570,538,508,480
	dc.w 453,428,404,381,360,339,320,302,285,269,254,240
	dc.w 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w 900,850,802,757,715,675,636,601,567,535,505,477
	dc.w 450,425,401,379,357,337,318,300,284,268,253,238
	dc.w 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w 894,844,796,752,709,670,632,597,563,532,502,474
	dc.w 447,422,398,376,355,335,316,298,282,266,251,237
	dc.w 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w 887,838,791,746,704,665,628,592,559,528,498,470
	dc.w 444,419,395,373,352,332,314,296,280,264,249,235
	dc.w 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w 881,832,785,741,699,660,623,588,555,524,494,467
	dc.w 441,416,392,370,350,330,312,294,278,262,247,233
	dc.w 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w 875,826,779,736,694,655,619,584,551,520,491,463
	dc.w 437,413,390,368,347,328,309,292,276,260,245,232
	dc.w 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w 868,820,774,730,689,651,614,580,547,516,487,460
	dc.w 434,410,387,365,345,325,307,290,274,258,244,230
	dc.w 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w 862,814,768,725,684,646,610,575,543,513,484,457
	dc.w 431,407,384,363,342,323,305,288,272,256,242,228
	dc.w 216,203,192,181,171,161,152,144,136,128,121,114



;**** DATA segment ****
	.data


n_note  equ 0			; W
n_cmd	equ 2			; W
n_cmdlo equ 3			; B
n_start equ 4			; L
n_length equ 8			; W
n_loopstart equ 10		; L
n_replen equ 14			; W
n_period equ 16			; W
n_finetune equ 18		; B
n_volume equ 19			; B
n_dmabit equ 20			; W
n_toneportdirec equ 22	; B
n_toneportspeed equ 23	; B
n_wantedperiod equ 24	; W
n_vibratocmd equ 26		; B
n_vibratopos equ 27		; B
n_tremolocmd equ 28		; B
n_tremolopos equ 29		; B
n_wavecontrol equ 30	; B
n_glissfunk equ 31		; B
n_sampleoffset equ 32	; B
n_pattpos equ 33		; B
n_loopcount equ 34		; B
n_funkoffset equ 35		; B
n_wavestart equ 36		; L
n_reallength equ 40		; W
mt_chan1temp: dc.l 0,0,0,0,0,$010000,0,0,0,0,0
mt_chan2temp: dc.l 0,0,0,0,0,$020000,0,0,0,0,0
mt_chan3temp: dc.l 0,0,0,0,0,$040000,0,0,0,0,0
mt_chan4temp: dc.l 0,0,0,0,0,$080000,0,0,0,0,0

mt_SampleStarts:
	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr:	dc.l 0
mt_speed:		dc.b 6
mt_counter:		dc.b 0
mt_SongPos:		dc.b 0
mt_PBreakPos:	dc.b 0
mt_PosJumpFlag:	dc.b 0
mt_PBreakFlag:	dc.b 0
mt_LowMask:		dc.b 0
mt_PattDelTime:	dc.b 0
mt_PattDelTime2: dc.b 0
mt_Enable:		dc.b 0
mt_PatternPos:	dc.w 0
mt_DMACONtemp:	dc.w 0


OldTempo: 			dc.w 125
RealTempo:			dc.w 125
tempo_cont_flg:		dc.b -1
	even


ftab:		dc.l	ftab25

ciaemtab:	dc.l	ciatab25

devconf:	dc.w	3
freqval:	dc.w	1


;**** BSS segment ****
	.bss

xgc_val:	ds.l	1
xgc_ptr:	ds.l	1

.globl _playflag
_playflag:	ds.w	1

bufmode:	ds.w	1

mod_addr:	ds.l	1			; Address of module

endofbuf:	ds.l	1

xbufptrs:	ds.l	4

oldirqvec:	ds.l	1

irqflag:	ds.w	1

snd_cookie:	ds.l	1

signflag:	ds.w	1			; =0 means signed, <>0 means unsigned

gsxbflag:	ds.w	1			; =0 no GSXB, <>0 we have GSXB


; Paula emulation storage structure.
sam_start equ 0			; sample start			.l
sam_length equ 4		; sample length			.l
sam_lpstart equ 8		; sample loop start		.l
sam_lplength equ 12		; sample loop length	.l
sam_period equ 16		; sample period(freq)	.w
sam_vol equ 18			; sample volume			.w
sam_strctsiz equ 20		; structure size.

ch1s:	ds.b sam_strctsiz
ch2s:	ds.b sam_strctsiz	; shadow channel regs
ch3s:	ds.b sam_strctsiz
ch4s:	ds.b sam_strctsiz

; Structure produced from 'paula' data
Vaddr	equ 0		; .l
Voffy	equ 4		; .l
Vfrac	equ 8		; .l
Vfreqint equ 12		; .w
Vfreqfrac equ 14	; .l
Vvoltab equ 18		; .w
Vlpaddr equ 20		; .l
Vlpoffy equ 24		; .l
Vlpfreqint equ 28	; .w
Vlpfreqfrac equ 30	; .l
Vstrctsiz equ 34

Voice1Set: ds.b Vstrctsiz
Voice2Set: ds.b Vstrctsiz	; voice data (setup from 'paula' data)
Voice3Set: ds.b Vstrctsiz
Voice4Set: ds.b Vstrctsiz


shadow_dmacon: ds.w 1
shadow_filter: ds.w 1

voltab_ptr: ds.l 1			; ptr to volume table

bufadd: ds.l 1				; To switch between left and right output channel

	ds.l 8					; (in case!!)
nulsamp: ds.l 8				; nul sample

vols: ds.l 64
	ds.l 16640/4

sambuf_ptrs:	ds.l	2
aktsambuf:  	ds.l	1
aktendbuf:  	ds.l	1

lpvc1_1: ds.l 1
lpvc1_2: ds.l 1
lpvc1_3: ds.l 1
lpvc1_4: ds.w 1
lpvc2_1: ds.l 1
lpvc2_2: ds.l 1
lpvc2_3: ds.l 1
lpvc2_4: ds.w 1

ciatab12:	ds.w	256
ciatab25:	ds.w	256
ciatab50:	ds.w	256

;*** End of File ***
