	SECTION	text

; init sound for falcon

falcSoundPatch
	cmpi.l	#$30000,machine
	bne	.continue
; install sound patch

	move.w	#$1,-(sp)		
	clr.l	-(sp)		
	move.w	#$8,-(sp)		
	clr.w	-(sp)		
	move.w	#139,-(sp)		
	trap	#$E		; Devconnect call	
	lea	$C(sp),sp		

	clr.w	-(sp)	
	move.w	#132,-(sp)	
	trap	#$E		; set 8 bit stereo		
	addq.l	#4,sp	

	move.w	#$40,-(sp)		
	move.w	#$2,-(sp)	; value : determines freq	?	
	move.w	#130,-(sp)		
	trap	#$E		; Soundcmd
			
	move.w	#$3,$2(sp)	; repeat above with value=3		
	trap	#$E		
	addq.l	#6,sp	

	move.w	#$3,-(sp)		
	move.w	#$6,-(sp)	; value : determines freq?
	move.w	#$130,-(sp)		
	trap	#$E		; Soundcmd
	
	move.w	#$4,$2(sp)	; repeat above with value=4		
	trap	#$E	
	
	move.w	#$5,$2(sp)	; repeat above with value=5	
	trap	#$E		
	addq.w	#6,sp

	super	#0
	move.b	#48,$ffff8920
	super	d0
.continue
	rts
;-------------------------------------------------------------------
; is the sound system locked?

checkFalconSoundSystem
	cmpi.l	#$30000,machine
	bne	falconNotLocked

falconSoundLock
	move.w	#128,-(sp)		;(Locksound)
	trap	#xbios
	addq.l	#2,sp	

	cmpi	#1,d0
	bne	soundLocked

falconNotLocked
	rts

soundLocked
	rsrc_gaddr	#5,#SOUNDSYSLOCKED
	form_alert	#1,addrout

	cmpi.w	#2,intout
	bne	quitRoutine
.unlock
	move.w	#129,-(sp)
	trap	#xbios
	addq.w	#2,sp
	bra	falconSoundLock