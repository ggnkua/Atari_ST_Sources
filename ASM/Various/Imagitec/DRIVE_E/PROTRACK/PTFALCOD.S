**    Falcon ProTracker    **
** Martin Randall 30/11/92 **

buff_size	equ	(1024*2)	10k buffer

		include	snd_falc.i

_init_sound	
		movem.l	d0-d7/a0-a6,-(sp)	Preserve the regs
		locksnd				Get the DMA
		devconnect	#0,#$8,#0,#9,#1	10kHz samples
		soundcmd	#0,#$0000	Set left volume
		soundcmd	#1,#$0000	Set right volume
		setmode		#0		8 bit stereo
		settracks	#0,#0	  		Play 1 track
		setmontracks	#0
		movem.l	(a7)+,d0-d7/a0-a6
		rts
		
_free_sound	
		movem.l	d0-d7/a0-a6,-(sp)	Preserve the regs
		unlocksnd
		movem.l	(a7)+,d0-d7/a0-a6
		rts
		
** Call with a0, pointing to the start of the MOD file

_pt_mod_on	bsr	_init_sound
		bsr	init_mod
pt_insert	lea	play_buff,a0
		lea	play_buff_end,a1
		bsr	init_play
		rts

_pt_mod_off	
pt_restore	bclr.b	#0,$ff8901	Stop playing
		rts

	**************************
	* Protracker VBL routine *
	**************************

nt_vbl		*movem.l	d0-d7/a0-a6,-(sp)	Preserve the regs


*		move.w	#$2000,d0
*.loop2		dbf	d0,.loop2

*		not.w	$ffff8240
*						get current buffer pos
	
		bclr	#7,$ff8901		Select play register
		moveq	#0,d1
		move.b	$ff8909,d1
		asl.w	#8,d1
		move.b	$ff890b,d1
		asl.l	#8,d1
		move.b	$ff890d,d1

		tst.l	buff_ptr
		bne.s	ptr_ok
		add.l	#200,d1
		move.l	d1,buff_ptr
		bra.s	gap_ok
			
ptr_ok		move.l	buff_ptr,d2

		sub.l	d2,d1		Old buffer pointer
		bpl.s	nt_ok
		add.l	#buff_size,d1		Calculate offset

nt_ok		cmp.l	#(buff_size/2),d1
		ble	no_play
		
		bsr	ntplay
	
gap_ok		move.l	buff_ptr,a0		Get current buffer pointer
		lea	play_buff_end,a6
		
		move.l	a0,d0
		addi.l	#198*2,d0
		cmp.l	d0,a6
		bgt.s	nt_ok2
		sub.l	#buff_size,d0

nt_ok2		move.l	d0,buff_ptr		Restore pointer
		
		lea	channel1,a1		Channel pointer
		moveq	#0,d6			Clear reg
		moveq	#0,d5
		moveq	#1,d0			4 channels
nt_l4		move.l	a0,-(a7)
		move.l	ch_samstart(a1),a3	Sample data #1
		move.l	ch_sampitch(a1),d4	Modulation value #1
		move.l	22+ch_samstart(a1),a4	Sample data #2
		move.l	22+ch_sampitch(a1),d7	Modulation value #2
		lea	vols,a2			Point to volume tables
		lea	vols,a5
		move.w	ch_samvol(a1),d3	Volume #1
		asl.w	#8,d3			Times 256
		lea	(a2,d3.w),a2		Point to volume table #1
		move.w	22+ch_samvol(a1),d3	Volume #2
		asl.w	#8,d3			Times 256
		lea	(a5,d3.w),a5		Point to volume table #2
		move.w	22+ch_samlen(a1),d3	Sample length #2
		subq.w	#1,d3
		swap	d3
		move.w	ch_samlen(a1),d3	Sample length #1
		subq.w	#1,d3
		moveq	#0,d1			Modulation offset #1
		moveq	#0,d2			Modulation offset #2
		swap	d0
		move.w	#197,d0			Move 198 bytes
nt_l3		move.b	(a3,d1.w),d5		Get sample byte
		move.b	(a2,d5.w),d6		Transfer byte #1
		move.b	(a4,d2.w),d5
		add.b	(a5,d5.w),d6		Transfer byte #2
		move.b	d6,(a0)
		moveq	#0,d6
		
		addq.l	#2,a0			Point to next byte
		cmp.l	a0,a6
		bgt.s	nt_ok3
		sub.l	#buff_size,a0
		
nt_ok3		add.l	d4,d1			Update offset #1
		addx.w	d6,d1
		cmp.w	d1,d3			End of sample ?
		bgt.s	mod_ok			
		move.l	ch_samrepst(a1),a3	Repeat start
		move.w	ch_samreplen(a1),d3	Repeat length
		moveq	#0,d1			Reset offset
		
mod_ok		swap	d3			Get length of sample #2
		add.l	d7,d2			Update offset #2
		addx.w	d6,d2
		cmp.w	d2,d3			End of sample ?
		bgt.s	mod_ok2
		move.l	22+ch_samrepst(a1),a4	Repeat start
		move.w	22+ch_samreplen(a1),d3	Repeat length
		moveq	#0,d2			Reset offset
		
mod_ok2		swap	d3			Get length of sample #1
		dbf	d0,nt_l3		Loop for 200 bytes

nt_4		move.l	(a7)+,a0
		addq.l	#1,a0
		lea	(a3,d1.w),a3		New start #1
		move.l	a3,ch_samstart(a1)	Update sample start
		sub.w	d1,d3			New length #1
		move.w	d3,ch_samlen(a1)	Update sample length

		swap	d3			Get length #2
		lea	(a4,d2.w),a4		New start #2
		move.l	a4,22+ch_samstart(a1)	Update sample start
		sub.w	d2,d3			New length #2
		move.w	d3,22+ch_samlen(a1)	Update sample length
		
		lea	44(a1),a1
		swap	d0
		dbf	d0,nt_l4
no_play		**movem.l	(a7)+,d0-d7/a0-a6
*		not.w	$ffff8240
vbl_exit	**jmp	nt_vbl
		rts
			
* Start the DMA playing

init_play	lea	null_sam,a2
		moveq	#2,d0
		moveq	#3,d1
		lea	channel1,a3
ip_l1		move.l	a2,ch_samstart(a3)
		move.l	a2,ch_samrepst(a3)
		move.l	#1,ch_sampitch(a3)
		move.w	d0,ch_samlen(a3)
		move.w	d0,ch_samreplen(a3)
		move.w	#$40,ch_samvol(a3)
		lea	22(a3),a3
		dbf	d1,ip_l1

		move.l	a0,d0		Set sound frame base
		move.b	d0,$ff8907
		asr.l	#8,d0
		move.b	d0,$ff8905
		asr.w	#8,d0
		move.b	d0,$ff8903
	
		move.l	a1,d0		Set sound frame top
		move.b	d0,$ff8913
		asr.l	#8,d0
		move.b	d0,$ff8911
		asr.w	#8,d0
		move.b	d0,$ff890f
		or.w	#3,$ff8900	Play
		bsr.s	init_vol
		bsr.s	init_pit
		rts
		
init_vol	lea	vols+(256*64),a0
		move.l	#$40,d0		Maximum volume
iv_l1		move.l	#255,d1		Number of settings
iv_l2		move.l	d1,d2
		sub.b	#$80,d2		Convert signed to unsigned
		mulu.w	d0,d2		Scale down to currnet volume
		divu.w	#$40,d2
		add.b	#$80,d2
		asr.b	d2		Precalc for merging
 		move.b	d2,(a0,d1.w)	Enter byte into table
		dbf	d1,iv_l2
		lea	-256(a0),a0	Next table
		dbf	d0,iv_l1
		rts
		
init_pit	move.l	#428,d0		Base note
		swap	d0
		move.l	#800,d1		801 pitches
		move.l	#108,d2		Starting with 108
		lea	snd_table,a0
ip_l2		move.l	d0,d3
		divu.l	d2,d3		Get modulation value
		swap	d3
		move.l	d3,(a0)+
		addq.l	#1,d2		Next pitch
		dbf	d1,ip_l2
		rts
		
		even
		
null_sam	dc.l	0		Silence !	


	include protrack.i

snd_table	ds.l	802	The pitches
 	

vols	ds.b	256*65

buff_ptr	ds.l	1

play_buff	dcb.l	buff_size/4,0	play buffer
play_buff_end
