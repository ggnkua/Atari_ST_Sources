;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Chipmon2¿ Sound Handler v.1.0ž
; ½1993 by B.A.T from -=>SyNeRgY<=-
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; handler:	function number in d0.w.
;               parameters in d1.w (FOR NOW !)
;	        all regs are saved except for d0.l (used for return values)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions:
;		function 0: Initialize Sound System.
;		            In:  -
;		            Out: d0.l -> pointer to VBL handler
;
;               function 1: Play song.
;			    In:  d1.w -> song number
;                           Out: -
;		
;		function 2: Fade out song. Starts fade out.
;                           In:  d1.w -> fade out speed
;                           Out: -
;		            		
;		function 3: Fade in song. Starts fade in.
;			    In:  d1.w -> fade in speed
;                           Out: -
;	
;		function 4: Fade out check. 
;                           In:  -
;                           Out: d0.l -> 0=fader done, <>0=fader busy
;
;		function 5: Fade in check.
;			    In:  -
;                           Out: d0.l -> 0=fader done, <>0=fader busy
;
;		function 6: Riedel check. (1 pattern tunes)
;			    In:  -
;                           Out: d0.l -> 0=Riedel done, <>0=Riedel busy
;
;		function 7: Save song.
;			    In:  -
;                           Out: -
;			
;		function 8: Restore song.
;                           In:  -
;                           Out: -
;
; 		function 9: Play a sound FX 
;			    In:  d1.w -> sound FX number
;                           Out: -
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 0 only to be called once at start up. Never again, wow !
; function 2 best value for fade out is +/- 10 
; function 3 best value for fade in is +/- 6
; function 6 only works with riedeltjes (1 pattern tunes), you are
;	     warned !
; function 7 saves values over the previous one !
; function 8 restores only the last saved song !
;           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INTERNAL INFO: DO 'NOT' USE THESE VALUES !!!
;                   ----- 
; player:	cm2+0  = relocate song. (a0.l song ptr)
;               cm2+4  = init song in replayer. (a0.l song ptr, d0.w position)
;               cm2+8  = play song (VBL routine)
;               cm2+12 = stop song (clears volume registers)
;               cm2+16 = set general volume. (d0.w 0-15)
;               cm2+20 = save internal registers to a0.l
;               cm2+24 = restore internal register from a0.l
;               cm2+28 = pattern mode flag. (<>0 = pattern mode on)
;               cm2+29 = no play flag. (<>0 = no replay)
;               cm2+30 = Play sound fx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;- Constants -------------------------------------------------------;

MAX_FUNCTIONS:	equ	10
MAX_SONGS:	equ	2


;- Sound Handler ---------------------------------------------------;

Sound_Handler:	movem.l	d1-a6,-(sp)
		cmp.w	#MAX_FUNCTIONS,d0
		bge.s	no_function
		add.w	d0,d0
		move.w	function_list(pc,d0.w),d0
		jsr	function_list(pc,d0.w)
no_function:	movem.l	(sp)+,d1-a6
		rts	

function_list:	dc.w	init_songs-function_list	;0
		dc.w	play_song-function_list		;1
		dc.w	fade_o_song-function_list	;2
		dc.w	fade_i_song-function_list	;3
		dc.w	fade_o_check-function_list	;4
		dc.w	fade_i_check-function_list	;5
		dc.w	riedel_check-function_list	;6
		dc.w	save_song-function_list		;7
		dc.w	rest_song-function_list		;8
		dc.w	play_fx-function_list		;9

;- FUNCTION 0: Relocate all songs in song list ---------------------;

init_songs:	lea	sng_list,a6	;a6 not used in reloc!
		move.w	#MAX_SONGS-1,d2	;d2 not used in reloc!
reloc_loop:	move.l	(a6)+,a0	;fetch song-file pointer
		bsr	cm2+0		;reloc call
		dbra	d2,reloc_loop	;next song-file
reloc_done:	
		st	cm2+29		;disable player
		move.l	#cm2_VBL,d0	;vbl pointer 
		rts					

		
;- FUNCTION 1: Play song -------------------------------------------;		

play_song:	st	cm2+29			;disable player
		lea	riedel_list,a0		;song info's
		lea	sng_list,a1		;song pointers
		moveq	#0,d0			;for .w offset
		moveq	#0,d2			;for .w offset
		mulu	#3,d1			;size song info blocks
		move.b	0(a0,d1.w),d2		;song number
		move.b	1(a0,d1.w),d0		;position start
		move.b	2(a0,d1.w),cm2+28	;pattern_play flag
		move.l	0(a1,d2.w),a0		;song file pointer
		bsr	cm2+4			;init music in player
		move.l	#dummy_rout,fade_routine	;init VBL
		move.w	#15,current_volume	;volume at max
		sf	cm2+29			;enable player			
		rts			

		
;- FUNCTION 2: Fade out song ---------------------------------------;

fade_o_song:	move.w	d1,fade_delay
		move.w	d1,fade_speed
		move.l	#fade_out,fade_routine	;install fade in VBL
		move.w	#15,current_volume	;DIRTY
		rts		


;- FUNCTION 3: Fade in song ----------------------------------------;

fade_i_song:	move.w	d1,fade_delay
		move.w	d1,fade_speed
		move.l	#fade_in,fade_routine	;install fade in VBL
		clr.w	current_volume		;DIRTY
		rts

		
;- FUNCTION 4: Fade out done check ---------------------------------;

fade_o_check:	tst.w	current_volume		;volume at min ?
		beq.s	fade_fin		;if so -> fade out done
		moveq	#-1,d0			;mark: fade out busy
		rts	
		
fade_fin:	move.l	#dummy_rout,fade_routine	;remove fader
		moveq	#0,d0			;mark: fade out done
		rts		


;- FUNCTION 5: Fade in done check ----------------------------------;

fade_i_check:	cmp.w	#15,current_volume	;volume at max ?
		beq.s	fade_fin		;if so -> fade in done
		moveq	#-1,d0			;mark: fade in busy
		rts
			
			
;- FUNCTION 6: Riedel end check ------------------------------------;		

riedel_check:	tst.b	cm2+29			;player disabled (DIRTY)
		bne.s	riedel_done		;if so -> riedel done	
		moveq	#-1,d0			;mark: riedel busy
		rts
riedel_done:	moveq	#0,d0			;mark: riedel done
		rts		
	
	
;- FUNCTION 7: Save song registers ---------------------------------;		

save_song:	st	cm2+29			;disable player
		lea	temp_registers,a0	;Register storage
		bsr	cm2+20			;save song
		sf	cm2+29			;enable player
		rts
		

;- FUNCTION 8: Restore song registers ------------------------------;		
	
rest_song:	st	cm2+29			;disable player
		lea	temp_registers,a0	;Register storage
		bsr	cm2+24			;restore song
		sf	cm2+29			;enable player
		rts
		
		
;- FUNCTION 9: Play a FX -------------------------------------------;

play_fx:	st	cm2+29
		lea	fx_list,a0
		mulu	#3,d1
		moveq	#0,d0
		moveq	#0,d2
		move.b	0(a0,d1.w),d0		;instrument
		move.b	2(a0,d1.w),d2		;note
		move.b	1(a0,d1.w),d1		;volume
		and.w	#$00ff,d1
		bsr	cm2+30
		sf	cm2+29		
		rts
		
;- Other Routines --------------------------------------------------;		
		
cm2_VBL:	movem.l	d0-a6,-(sp)
		subq.w	#1,fade_delay		;delay fade
		bpl.s	no_fade
		move.w	fade_speed,fade_delay
		move.l	fade_routine(pc),a0	;call possible fader
		jsr	(a0)
no_fade:	bsr	cm2+8			;do play
		movem.l	(sp)+,d0-a6
		rts		
		
fade_routine:	dc.l	dummy_rout

fade_in:	move.w	current_volume,d0
		cmp.w	#15,d0
		beq.s	dummy_rout
		addq.w	#1,d0
fade_on:	move.w	d0,current_volume
		bsr	cm2+16			;set volume
dummy_rout:	rts	

fade_out:	move.w	current_volume,d0
		beq.s	dummy_rout
		subq.w	#1,d0
		bra.s	fade_on


;-------------------------------------------------------------------;		

		Section Data
		
sng_list:	dc.l	song1
		dc.l	song2
					;song_numb*4,position,pattern flag
riedel_list:	dc.b	0*4,0,-1	;land selection songs
		dc.b	0*4,1,-1
		dc.b	0*4,2,-1
		dc.b	0*4,3,-1
		dc.b	0*4,4,-1
		dc.b	0*4,5,0		;text song
		dc.b	1*4,0,0		;intro song
		even

fx_list:	dc.b 	0*4,15*4,15*2	;instr*4,volume*4,note*2
		dc.b	1*4,15*4,15*2
		dc.b	2*4,15*4,15*2

cm2:		incbin	"a:\scavy_cm.mus"
		even		

song1:		incbin	"a:\landsel.sng"
		even
song2:		incbin	"a:\crap_int.sng"
		even
	
		Section BSS
		
current_volume:	ds.w	1
fade_speed:	ds.w	1
fade_delay:	ds.w	1
temp_registers:	ds.b	150 	;(iets in die richting)
				
				


