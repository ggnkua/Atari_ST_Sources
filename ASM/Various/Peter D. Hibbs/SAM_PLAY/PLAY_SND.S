;Plays selected sampled sound from Sampled Sound Block file (.SSB)
;ENTRY d0 = No of sample to play (0-nn)
;      Sound Sample Block data 'included' at address 'snd_data'
;      Sound look up table 'included' at address 'snd_table'
;      Supervisor mode enabled
;      PSG initialised (with init_snd S/R)
;EXIT  Interrupt enabled (Sound played back during interrupts)
;      (samp_addr) holds start of sound sample data
;      (samp_len) holds sample length in bytes

play_snd	lea	snd_data+4,a0	fetch data start addr
play_snd5	dbra	d0,play_snd4	d0-1, d0=-1 ?
	add.l	(a0),a0	skip to next sample
	add	#20,a0	skip header
	bra	play_snd5	loop

play_snd4	move.l	(a0),samp_len	set sample length
	move	4(a0),d0	fetch freq
	and.l	#$ffff,d0
	bsr	hz_to_timer	& calc MFP values
	add	#20,a0	skip to sound data
	move.l	a0,samp_addr	& store start addr
	move.l	#play_snd0,$134	timer A DMA sound
	move.b	#$1,$fffffa19	timer A control (div 4)
	move.b	d0,$fffffa1f	timer A data (freq)
	bset 	#5,$fffffa07	enable interrupt on timer A
	bset	#5,$fffffa13	enable timer A mask
	bclr 	#3,$fffffa17	vector register
	rts

;Sound playing routine (called via interrupt vector $134)

play_snd0	movem.l 	d1/a2/a3,-(sp)
	addq.l 	#1,samp_addr	inc data pointer
	subq.l 	#1,samp_len	dec length counter
	beq	play_snd2	if 0 then exit
	move.l 	samp_addr,a2	locate sample data
	moveq 	#0,d1	clear d1
	move.b 	(a2),d1	fetch next data byte
	lsl 	#3,d1	re-scale data
	lea 	$ffff8800,a2	PSG select
	lea 	snd_table,a3	a3=sound table address		
	lea 	(a3,d1),a3	
	move.l 	(a3)+,d1			
	movep.l 	d1,(a2)	copy to PSG
	move.l 	(a3),(a2)		
play_snd1	movem.l 	(sp)+,d1/a2/a3
	rte		exit exception
	
play_snd2	bclr 	#5,$fffffa07	interrupt enable A
	bclr 	#5,$fffffa13	interrupt mask A
	clr.b 	$fffffa19	timer A control
	bset 	#3,$fffffa17	vector register
	bra	play_snd1

;Stops sampled sound
;ENTRY Interrupts enabled (sound playing)
;      Supervisor mode enabled
;EXIT  Interrupts disabled (sound stops)

stop_snd	bclr 	#5,$fffffa07	interrupt enable A
	bclr 	#5,$fffffa13	interrupt mask A
	clr.b 	$fffffa19	timer A control
	bset 	#3,$fffffa17	vector register
	rts
	
;Initialise PSG and variables
;ENTRY supervisor mode enabled
;EXIT  PSG registers programmed

init_snd	lea 	$ffff8800,a0	sound chip address
	clr.b	(a0)	clr most registers
	clr.b 	2(a0)
	move.b	#1,(a0)
	clr.b 	2(a0)
	move.b	#2,(a0)
	clr.b 	2(a0)
	move.b	#3,(a0)
	clr.b 	2(a0)
	move.b	#4,(a0)
	clr.b 	2(a0)
	move.b	#5,(a0)
	clr.b 	2(a0)
	move.b	#7,(a0)
	move.b	#$ff,2(a0)
	move.b 	#8,(a0)
	clr.b	2(a0)
	move.b 	#9,(a0)
	clr.b	2(a0)
	move.b 	#10,(a0)
	clr.b	2(a0)
	rts
	
;Convert Hz value into Control & Data values for Timers
;ENTRY:	d0 = Interrupt Frequency (in Hertz)
;EXIT:	d0 = Control byte in High word, Data byte in Low word
;USES:	Macro Div_l in INTMATH.I
;	Registers d0-d1

hz_to_timer	move.l	#2457600,d1	timer frequency
	Div_l	d0,d1	answer in d1, remainder in d0
	lsr	#2,d1	divide counter by 4
	move.w	#1,d0	divide by 4 in prescalar
	cmp.l	#128,d1	timer count <256 (allowing for tempo changes)
	ble.s	hz_to_timer1
	lsr	#2,d1
	move.w	#3,d0	divide by 16 in prescalar
	cmp.l	#128,d1
	ble.s	hz_to_timer1
	lsr	#2,d1
	move.w	#5,d0
hz_to_timer1	swap	d0
	move.w	d1,d0	counter value
	rts

snd_table	incbin	stable4.dat	sound lookup table
snd_data	incbin	xxxxxxxx.ssb	sampled sound data block


samp_addr	ds.l	1	sound sample addr store
samp_len	ds.l	1	sample length
