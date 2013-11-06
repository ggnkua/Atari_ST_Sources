mp2_address	ds.l	1
mp2_length	ds.l	1
mp2_frequency	ds.l	1
mp2_external	ds.l	1
mp2_repeat	ds.l	1
mp2_start	bra.w	start_all
mp2_stop	bra.w	stop_all

start_all
	bsr	saveaudio
	bsr	mute
	bsr	set_matrix
	bsr	dsp_load_program
	bsr	initialize_program
	bsr	unmute
	bsr	play
	rts
	
stop_all
	bsr	restoreaudio
	rts


set_matrix
	;	sndstatus(SND_RESET);
	move.w	#1,-(sp)
	move.w	#$8c,-(sp)
	trap	#14
	addq.l	#4,sp
	
	;	setmode(STEREO16);
	move.w	#1,-(sp)
	move.w	#$84,-(sp)
	trap	#14
	addq.l	#4,sp

	;	soundcmd(ADDERIN,MATIN);
	move.w	#2,-(sp)
	move.w	#4,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp

	;	dsptristate(ENABLE,ENABLE);
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	move.w	#$89,-(sp)
	trap	#14
	addq.l	#6,sp

	;	setbuffer(SR_PLAY, stream_get_buffer(), stream_get_buffer_end());
	move.l	mp2_address(pc),d0
	move.l	mp2_address(pc),d1
	add.l	mp2_length(pc),d1
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#0,-(sp)
	move.w	#$83,-(sp)
	trap	#14
	lea	12(sp),sp	


	move.l	mp2_frequency(pc),d0
	move.l	mp2_external(pc),d1

	cmp.l	#48000,d0
	bne.s	.freq48000
	cmp.l	#48000,d1
	bne.s	.freq48000_ext
	bra.s	set_matrix_ext_full
.freq48000_ext
	bra	set_matrix_int_49170
.freq48000
	cmp.l	#44100,d0
	bne.s	.freq44100
	cmp.l	#44100,d1
	bne.s	.freq44100_ext
	bra.s	set_matrix_ext_full
.freq44100_ext
	bra	set_matrix_int_49170
.freq44100
	cmp.l	#32000,d0
	bne.s	.freq32000
	cmp.l	#48000,d1
	bne.s	.freq32000_ext
	bra.s	set_matrix_ext_32000
.freq32000_ext
	bra	set_matrix_int_32780
.freq32000
	cmp.l	#24000,d0
	bne.s	.freq24000
	cmp.l	#48000,d1
	bne.s	.freq24000_ext
	bra.s	set_matrix_ext_half
.freq24000_ext
	bra	set_matrix_int_24585
.freq24000
	cmp.l	#22050,d0
	bne.s	.freq22050
	cmp.l	#44100,d1
	bne.s	.freq22050_ext
	bra.s	set_matrix_ext_half
.freq22050_ext
	bra.s	set_matrix_int_24585
.freq22050
	cmp.l	#16000,d0
	bne.s	.freq16000
	cmp.l	#48000,d1
	bne.s	.freq16000_ext
	bra.s	set_matrix_ext_16000
.freq16000_ext
	bra.s	set_matrix_int_16390
.freq16000

; If unknown, just set 49170, and hope it goes well.
	bra.s	set_matrix_int_49170	
	rts

set_matrix_ext_full:
	move.l	#$63b42080,$ffff8930.w
	move.w	#$0101,$ffff8934.w
	rts

; Only usable if external clock is 48KHz
set_matrix_ext_32000:
	move.l	#$63b42080,$ffff8930.w
	move.w	#$0201,$ffff8934.w
	rts

; Only usable if external clock is 48KHz
set_matrix_ext_16000:
	move.l	#$63b42080,$ffff8930.w
	move.w	#$0501,$ffff8934.w
	rts

set_matrix_ext_half:
	move.l	#$63b42080,$ffff8930.w
	move.w	#$0301,$ffff8934.w
	rts

set_matrix_int_49170:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0001,$ffff8934.w
	rts

set_matrix_int_32780:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0002,$ffff8934.w
	rts

set_matrix_int_24585:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0003,$ffff8934.w
	rts

set_matrix_int_16390:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0005,$ffff8934.w
	rts

saveaudio
	tst.w	audiosaved
	bne.s	.skip
	lea	saveaudiobuf(pc),a0
	move.w	$ffff8930.w,(a0)+
	move.w	$ffff8932.w,(a0)+
	move.b	$ffff8934.w,(a0)+
	move.b	$ffff8935.w,(a0)+
	move.b	$ffff8936.w,(a0)+
	move.b	$ffff8937.w,(a0)+
	move.b	$ffff8938.w,(a0)+
	move.b	$ffff8939.w,(a0)+
;	move.b	$ffff893a.w,(a0)+
	move.b	$ffff893c.w,(a0)+
	move.b	$ffff8941.w,(a0)+
	move.b	$ffff8943.w,(a0)+
	move.b	$ffff8900.w,(a0)+
	move.b	$ffff8901.w,(a0)+
	move.b	$ffff8920.w,(a0)+
	move.b	$ffff8921.w,(a0)+
	move.w	#1,audiosaved
.skip
	rts

restoreaudio
	tst.w	audiosaved
	beq.s	.skip
	lea	saveaudiobuf(pc),a0
	move.w	(a0)+,$ffff8930.w
	move.w	(a0)+,$ffff8932.w
	move.b	(a0)+,$ffff8934.w
	move.b	(a0)+,$ffff8935.w
	move.b	(a0)+,$ffff8936.w
	move.b	(a0)+,$ffff8937.w
	move.b	(a0)+,$ffff8938.w
	move.b	(a0)+,$ffff8939.w
;	move.b	(a0)+,$ffff893a.w
	move.b	(a0)+,$ffff893c.w
	move.b	(a0)+,$ffff8941.w
	move.b	(a0)+,$ffff8943.w
	move.b	(a0)+,$ffff8900.w
	move.b	(a0)+,$ffff8901.w
	move.b	(a0)+,$ffff8920.w
	move.b	(a0)+,$ffff8921.w
	clr.w	audiosaved
.skip
	rts	
	

mute
	lea	savevol(pc),a4
	move.w	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,(a4)+

	move.w	#-1,-(sp)
	move.w	#1,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,(a4)+

	move.w	#$f0,-(sp)
	move.w	#0,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#$f0,-(sp)
	move.w	#1,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp
	rts

unmute
	lea	savevol(pc),a4
	move.w	(a4)+,-(sp)
	move.w	#0,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	(a4)+,-(sp)
	move.w	#1,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp
	rts


play
	move.w	#$1,d0
	tst.l	mp2_repeat(pc)
	beq.s	.norepeat
	move.w	#$3,d0
.norepeat
	move.w	d0,-(sp)
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp
	rts

dsp_load_program
	lea	dsp_mp2_player(pc),a0
	move.l	#(end_mp2_player-dsp_mp2_player)/3,d0

	lea	dsp_program(pc),a1
	move.l	a0,(a1)
	lea	dsp_length(pc),a1
	move.l	d0,(a1)

	bsr.s	dsp_load

	; d0 == status

	rts

dsp_load	bsr.s	dsp_reset
	bsr.s	dsp_go
	rts

dsp_reset	; Power down.
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#$ef,d0
	move.b	d0,$ffff8802.w
	or.b	#$10,d0
	move.b	d0,$ffff8802.w

	; Wait for DSP to power down.
	move.w	#10000-1,d0
.wait	nop
	dbra	d0,.wait

	; Power up.
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#$ef,d0
	move.b	d0,$ffff8802.w
	rts

dsp_go
	; Load system startup code.
	lea	dsp_bootstrap_code(pc),a0
	move.w	#512-1,d0
.next	btst.b	#1,$ffffa202.w
	beq.s	.next
	move.b	(a0)+,$ffffa205.w
	move.b	(a0)+,$ffffa206.w
	move.b	(a0)+,$ffffa207.w
	dbra	d0,.next

	; Load DSP binary
	move.l	dsp_program(pc),a0
	move.l	dsp_length(pc),d0
	subq.w	#1,d0
	bmi.s	.no_way
.copy	btst.b	#1,$ffffa202.w
	beq.s	.copy
	move.b	(a0)+,$ffffa205.w
	move.b	(a0)+,$ffffa206.w
	move.b	(a0)+,$ffffa207.w
	dbra	d0,.copy

	; Launch DSP binary
.go	btst.b	#1,$ffffa202.w
	beq.s	.go
	move.l	#3,$ffffa204.w
	
	moveq	#1,d0
	rts
.no_way	moveq	#0,d0
	rts


initialize_program
	lea	dsp_buf(pc),a0
	move.l	mp2_length(pc),(a0)

	move.l	#0,-(sp)
	pea	0.w
	move.l	#1,-(sp)
	move.l	a0,-(sp)
	move.w	#$62,-(sp)
	trap	#14
	lea	18(sp),sp
	rts

	
	data
audiosaved	dc.w	0
dsp_buf	dc.l	0

dsp_bootstrap_code
	dc.b	$0c,$00,$40,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$60,$f4,$00,$00,$00,$4f,$61,$f4
	dc.b	$00,$00,$7e,$a9,$06,$2e,$80,$00,$00,$47
	dc.b	$07,$d8,$84,$07,$59,$84,$08,$f4,$a8,$00
	dc.b	$00,$04,$08,$f4,$bf,$00,$0c,$00,$00,$fe
	dc.b	$b8,$0a,$f0,$80,$00,$7e,$a9,$08,$f4,$a0
	dc.b	$00,$00,$01,$08,$f4,$be,$00,$00,$00,$0a
	dc.b	$a9,$80,$00,$7e,$ad,$08,$4e,$2b,$44,$f4
	dc.b	$00,$00,$00,$03,$44,$f4,$45,$00,$00,$01
	dc.b	$0e,$a0,$00,$0a,$a9,$80,$00,$7e,$b5,$08
	dc.b	$50,$2b,$0a,$a9,$80,$00,$7e,$b8,$08,$46
	dc.b	$2b,$44,$f4,$45,$00,$00,$02,$0a,$f0,$aa
	dc.b	$00,$7e,$c9,$20,$00,$45,$0a,$f0,$aa,$00
	dc.b	$7e,$d0,$06,$c6,$00,$00,$7e,$c6,$0a,$a9
	dc.b	$80,$00,$7e,$c4,$08,$58,$6b,$0a,$f0,$80
	dc.b	$00,$7e,$ad,$06,$c6,$00,$00,$7e,$cd,$0a
	dc.b	$a9,$80,$00,$7e,$cb,$08,$58,$ab,$0a,$f0
	dc.b	$80,$00,$7e,$ad,$06,$c6,$00,$00,$7e,$d4
	dc.b	$0a,$a9,$80,$00,$7e,$d2,$08,$58,$eb,$0a
	dc.b	$f0,$80,$00,$7e,$ad,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00

dsp_mp2_player	incbin	decoder.dsp
end_mp2_player

dsp_program	ds.l	1
dsp_length	ds.l	1
dsp_value	ds.l	1
savevol	ds.w	2
saveaudiobuf	ds.w	10

	end
