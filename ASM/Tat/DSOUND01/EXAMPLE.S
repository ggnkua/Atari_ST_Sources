;
;
;
;
; Here are some pointers to using these routines successfully:
;
; Setting Up
; ==========
; The number of channels/tracks is set up in 'SoundLib.S', where the
; label 'number_of_tracks' defines how many channels are used.
; The first four channels (1-4) are used to play the module.
; Tracks 5 to 'number_of_tracks' are for your own use. The routines
; 'start_sample5' and 'start_sample6' play an effect sample in this 
; sourcecode.
; I strongly recommend leaving this value at 6 since this has been
;  thoroughly tested!
;
; Using the code supplied should allow you to install the player,
; stick a module on and play samples, then de-install everything
; without any problems or the need to do any technical stuff.
;
;

; this code may be freely used in any atari falcon game/demo/production,
; as long as I am not held responsible for any damage caused...
;
;
;
;	cheers, steve tattersall
;	tat@avena.com
;
;
;




	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1			;switch into supervisor mode
	addq.l	#6,a7

	jsr	install_my_player


;-----------------------------------------------------
;
;
;	Main keypress loop
;
;
;
;-----------------------------------------------------
; this just checks for keys to play samples and/or cut them off
;
; '9' plays sample on channel 5
; '0' plays sample on channel 6
; '8' cuts the samples off
; 'space' quits


waitloop:
	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7
	move.b	d0,keypress

	cmp.b	#" ",keypress
	beq	.quit

	cmp.b	#"9",keypress		;press 9 to start channel 5
	bne.s	.not_channel_5
	bsr	start_sample5
.not_channel_5:
	cmp.b	#"0",keypress		;press 0 to start channel 6
	bne.s	.not_channel_6
	bsr	start_sample6
.not_channel_6

	cmp.b	#"8",keypress		;press 8 to 'kill' samples
	bne.s	.nothelp
	bsr	kill_samples
.nothelp:
.done:
	cmp.b	#" ",keypress		;press space to exit
	bne	waitloop
.quit:

;-----------------------------------------------------
;
;
;	end of keypress loop
;
;
;
;-----------------------------------------------------

; Finally we restore the sound chip and DSP
	jsr	deinstall_my_player


exit:
	clr.w	-(a7)
	trap	#1				;goodbyeee


;---------------------------------------------------------------------
error
	lea	errormess(pc),a0
	bsr	print
	bra	exit


	section	bss
keypress	ds.w	1































;---------------------------------------------------------------------
;
;	Tracker Library Routines
;
;	
;
;
;




install_my_player:

; First we install the DSP routine and set up the soundchip:
	jsr	tracker_player+0
	tst.l	d0			;returns -1 if dsp taken
	bmi	error			;by some other program

; Then we install the module to play. A new module can be installed
; at any time with this routine, so you can have multiple modules
; for hiscores etc
	lea	module,a0		;start address of module
	jsr	tracker_player+4	;sets up the module
					; NOTE: this kills the sample
					; channel as well!


; Now we must set the volume of the music and fx:
; (the default value is 0 ie. silent!)
; values should be in the region of 0-40000 for both

	move.w	#20000,d0
	bsr	tracker_player+24	;+24 set "module" volume
	move.w	#40000,d0
	bsr	tracker_player+28	;+28 set sample fx volume


; Actually start playing, by switching the interrupts on:
	jsr	tracker_player+8	;inits the timer A interrupts
	rts


; Now we switch the interrupts off:
deinstall_my_player:
	jsr	tracker_player+12		;restore interrupts
	jsr	tracker_player+16		;restore dsp
	rts

	

;---------------------------------------------------------------------
;
;	Sound effects routines
;
;	
;
;
;



;
; the next two routines play an effects sample. Note that both
; the start AND end address of the sample to play must be given
; Also NO check is made to see if the channel number is valid!!!
;
;


start_sample5:
	move.w	#5,d0			;d0 track number
	move.l	#sample_start,d1	;d1 sample start address
	move.l	#sample_end,d2		;d2 sample end address
	move.w	#$0d3,d3		;d3 pitch ($d3 normal speed)
	move.w	#$40,d4			;d4 volume (0-$40)
	move.w	#$1000,d5		;d5 stereo pos (0 left, $7fff right)
	move.w	#+$50,d6		;d6 panning mvmt -ve left +ve right
	bsr	tracker_player+20	;do it
	rts

start_sample6:
	move.w	#6,d0			;d0 track number
	move.l	#sample_start,d1	;d1 sample start address
	move.l	#sample_end,d2		;d2 sample end address
	move.w	#$0d3,d3		;d3 pitch ($d3 normal speed)
	move.w	#$40,d4			;d4 volume (0-$40)
	move.w	#$7000,d5		;d5 stereo pos (0 left, $7fff right)
	move.w	#-$50,d6		;d6 panning mvmt -ve left +ve right
	bsr	tracker_player+20	;do it
	rts

;---------------------------------------------------------------------
;
; This cuts off all the effects samples currently playing.
; This routine isn't really needed since no effects samples
;   ever loop - they will die out of their own accord and this
;   is automatically handled by the sound library.
;
;


kill_samples:
	bsr	tracker_player+32	;kill samples
	rts



;---------------------------------------------------------------------
print
		pea	(a0)
		move.w	#9,-(a7)
		trap	#1
		addq.l	#6,a7
		rts

errormess	dc.b	"DSP in use!",0
		even

;---------------------------------------------------------------------
		include	SoundLib.s
;---------------------------------------------------------------------

		section	data




;----------------- Example module (found in Modules.Zip) -------------
module:		incbin	Fantasy.Mod
		even

;----------------- Example sample (found in Samples.Zip) -------------
sample_start:	
		incbin	Death.Spl
sample_end:	equ	*









