
	xdef initialize_audio
	xdef release_audio

;	xdef allocated_samples_buffer
	xdef next_free_sample_address

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

initialize_audio:
	; Allocate the samples buffer (512 kB fixed size, ST-RAM only).

	move	#0,-(sp)
	move.l	#512*1024,-(sp)
	move	#68,-(sp)
	trap	#1
	addq.l	#8,sp

	move.l	d0,allocated_samples_buffer_address
	move.l	d0,next_free_sample_address

	rts

; ------------------------------------------------------------------------------

release_audio:
	; Free allocated samples buffer.

	move.l	allocated_samples_buffer_address,-(sp)
	move	#73,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

allocated_samples_buffer_address:
	ds.l	1

next_free_sample_address:
	ds.l	1

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------


