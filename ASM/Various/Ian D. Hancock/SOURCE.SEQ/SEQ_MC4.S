***********************************************************************
*                                                                     *
*                     STE Sample Music 25                             *
*                                                                     *
*                   by ½ Ian Hancock, August 1992                     *
*                                                                     *
***********************************************************************
	CSECT	name,code
	XDEF		_Volume_tone,_Click,_TEST,_DELETE,_SIGN_IT
	XDEF		_RECORD,_PLAY,_Vbl_Remove,_EDIT,_MERGE_BUFFER,_STOP

* system equates

gemdos		equ	$01
print_line	equ	$09
super		equ	$20
gettime		equ	$2C
vbl_queue		equ	$456

snd_cntl_DMA		equ	$FF8901
snd_start_hi_DMA	equ	$FF8903
snd_start_mid_DMA	equ	$FF8905
snd_start_lo_DMA	equ	$FF8907
snd_end_hi_DMA		equ	$FF890F
snd_end_mid_DMA	equ	$FF8911
snd_end_lo_DMA		equ	$FF8913
snd_mode_DMA		equ	$FF8921

voltone_mask		equ	$ff8924
voltone_data		equ	$ff8922

* main program

start
	move.l	4(sp),sample_start
	move.l	8(sp),sample_length
	move.l	12(sp),type
	move.b	19(sp),playmode
	move.b	23(sp),frequency
	move.b	27(sp),stereo_mono
play_sample	
	movem.l	d0-d7/a0-a6,-(sp)

	move.b	(supermode),d7
	cmpi.b	#$ff,d7
	beq		superon
	
* enter supervisor mode
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap		#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)
superon
* do it
	move.l	sample_start,D0
	add.l	sample_length,D0
	move.l	D0,sample_end

* write to sound DMA hardware
	clr.b	snd_cntl_DMA

* set  sampling freq and stereo/mono
	move.b	stereo_mono,d0
	lsl.b	#$7,d0
	or.b		frequency,d0
	move.b	d0,snd_mode_DMA

* set start sample location
	move.l	sample_start,D0
	move.b	D0,snd_start_lo_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_start_mid_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_start_hi_DMA

* set end sample location
	move.l	sample_end,D0
	move.b	D0,snd_end_lo_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_end_mid_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_end_hi_DMA

* start DMA sound, repeating at end
	move.b	playmode,snd_cntl_DMA

* abort sampling
abort_samples
	cmpi.b	#$ff,d7
	beq		superoff
	
* exit supervisor mode
	move.w	#super,-(SP)
	trap		#gemdos
	addq.w	#$06,SP
superoff

	movem.l	(sp)+,d0-d7/a0-a6
	rts

*************************************************************************
* convert 2 Bit System Replay samples into STE format
_SIGN_IT
	move.l	4(sp),(sample_start)	*send passed params to memory variables

	move.l	(sample_start),A0
	move.w	#$ffff,16(a0)			*write signed to header
	move.l	26(a0),(sample_length)	*offsets from a0 for AVR header
	add.l	#128,a0
	
	move.l	a0,D0
	add.l	(sample_length),D0
	move.l	D0,sample_end
	
convert_sample
	move.b	(A0),D0
	sub.b	#$80,D0
	move.b	D0,(A0)+
	cmp.l	sample_end,A0
	bne.s	convert_sample

	rts

*************************************************************************
_STOP
* enter supervisor mode
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap		#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

* set DMA sound, stop
	move.b	#0,snd_cntl_DMA

* exit supervisor mode
	move.w	#super,-(SP)
	trap		#gemdos
	addq.w	#$06,SP

	rts

*************************************************************************

*Install V_blank counter for RECORD

Vbl_Install
	move.l	4(sp),d0		*get stack passed param
	move.l	d2,-(sp)		*store d2
	move.l	d0,d2		*put it in d2

* enter super
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap		#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

* find a space in queue
	move.l	vbl_queue,a0
	move.w	#7,d0
	
find_entry
	tst.l	(a0)+
	beq.s	entry_found
	dbra		d0,find_entry
	bra.s	quit
	
entry_found
	lea		vbl_RECORD(pc),a1

	cmpi.l	#0,d2			*if 0 install vbl_record
	beq		rec
							*else install vbl_edit
	lea		vbl_EDIT(pc),a1

rec	move.l	a1,-(a0)			*put address from a1 in list
	move.l	a0,(vbl_current)	*remember position in list

quit	
* exit supervisor mode
	move.w	#super,-(SP)
	trap		#gemdos
	addq.w	#$06,SP

	move.l	(sp)+,d2		*restore d2
	rts
*************************************************************************
*Remove current vbl
_Vbl_Remove

* enter super
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap		#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

	move.l	(vbl_current),a1	*removes last vbl installed
	move.l	#0,(a1)			*by my prog. puts 0 in list
		
* exit supervisor mode
	move.w	#super,-(SP)
	trap		#gemdos
	addq.w	#$06,SP

	rts

*************************************************************************
*Record interupt
vbl_RECORD
	move.w	(time),d1	*adds 1 to the timer
	addq.w	#1,d1
	move.w	d1,(time)
	
	cmpi.w	#$ffff,d1
	beq		out_of_time *checks to make sure we ain't out a time
	
	rts
	
out_of_time
	move.l	#1,(error)
	rts
*************************************************************************
* vbl routine II for edit and playback
vbl_EDIT
	move.w	(time),d0		*put time in d0
	addq.w	#1,d0		*add 1
	move.w	d0,(time)		*replace new time
	
	cmpi.w	#$ffff,d0
	beq		out_of_time	*check we isn't out of time
	
	move.w	(memo),d1
	cmp.w	d0,d1		*if elapse time is reached
	bls		next_samp		*get next sample
	rts
	
next_samp
	move.l	(sequence2),a0		*get current seq. addr.
	add.l	#4,a0			*increment by a long word
	move.l	a0,(sequence2)		*replace new position
	move.w	(a0),(memo)		*set new elapse time
	move.w	2(a0),d0			*put sample no in d0

	move.b	#$ff,(supermode)	*set super ok flag

	jsr		get_samp			*load samp. data and play it

	move.b	#0,(supermode)		*reset super ok flag to normal

	cmpi.b	#1,(editon)		*if 1 then we are editing
	beq		yep
	move.l	(finish),a0		*play finished
	add.l	#1,(a0)

yep
	cmpi.w	#$ffff,(memo)		*if = ffff
	beq		finishedit		*then seq finished
	rts

finishedit
	move.l	(vbl_current),a1	* vbl EDIT list pos. to a1
	
	cmpi.b	#0,(editon)		*if 1 then we are editing
	beq		nope

	lea		vbl_RECORD(pc),a0	*start rec interupt
	move.l	a0,(a1)			*put address from a1 in list
	rts
	
nope	
	move.l	#0,(a1)			*de-install by putting 0 in list

	cmp.b	#3,snd_cntl_DMA
	bne		not_loopy
	
	move.b	#0,snd_cntl_DMA
	
not_loopy
	move.l	(finish),a0		*play finished
	move.l	#0,(a0)
	rts	
*************************************************************************
_PLAY
*init sequencing
* set up play params
	move.l	4(sp),(sam_start)	*send passed params to memory variables
	move.l	8(sp),(sequence2)
	move.l	12(sp),(seq_bytes)
	move.l	16(sp),(finish)
	
	move.b	#0,(editon)		*not editing
	
	move.l	(sequence2),a0
	move.w	(a0),d0			*get first elapse time in d0
	move.w	d0,(memo)			*put first elapse time in memo
	subq.w	#1,d0			*put actual timer 1 count behind elapse
	move.w	d0,(time)			*store in timer
	
* go (install the interupt)
	move.l	#1,-(sp)			*pass 1 via stack to install
	jsr		Vbl_Install		*EDIT vbl II
	addq.l	#4,sp			*stack correction
* it auto de-stalls
	rts

*************************************************************************
_RECORD
*recording mode
*init sequencing
	move.l	4(sp),(sam_start)	*put passed params in memory
	move.l	8(sp),(items)
	move.l	12(sp),(sequence)
	move.l	16(sp),(seq_bytes)
	move.l	20(sp),(dubbing)
	
	move.l	(sequence),d0		*finds max end address of seq
	add.l	(seq_bytes),d0		*less 16 safety margin
	sub.l	#16,d0
	move.l	d0,(seq_bytes)		*stores it back in seq-Bytes
	move.l	#0,(error)		*clear error flag
	
	move.l	#0,-(sp)		*use stack to pass value to Vbl_Install
	jsr		Vbl_Install	* recording interupt to be used =0
	addq.l	#4,sp		*stack correction
	
*recording mode
	move.l	d2,-(sp)				*store d2
	
	move.l	(sequence),(sequence2)	*put seq. start address in current.
	move.w	#0,(time)

	cmpi.l	#0,(dubbing)	*if none zero then recording
	bne		nodub
	
	move.l	(sequence),a0	* put sequence address in a0
	move.w	#$ffff,(a0)	* in case it is last sample
	subq.l	#4,a0		* go back to previous time

	cmpi.w	#$ffff,(a0)	*check to see if out a time
	bne		leave_it_out	
	move.l	#1,(error)	*better stop now
leave_it_out				*it's ok carry on

	move.w	(a0)+,(time)	* put time in time variable
	addq.l	#4,a0		* go forward to get prev sample
	move.w	(a0),d0		* put sample no in d0
	
	jsr		get_samp   	*load sample info and play it
nodub

another		*do it again until a none sample key is pressed
* wait for key
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap		#13
	addq.l	#4,sp
	move.w	(time),d1	* store time from record interupt in d1
	
* check error flag for time out.
	cmpi.l	#1,(error)
	beq		stop
	
* check input	
	swap		d0			*put scancode in low word
	cmp.w	#$63,d0		*compare with code for '(' on numeric
	blo		stop			*if less then not a sample
	move.l	(items),d2	*put no. of samps-1 in d2
	add.w	#$63,d2		*add scancode for '(' to it
	cmp.w	d2,d0		*compare keypressed with last key owning samp
	bhi		stop			*if higher then not a sample
	sub.w	#99,d0		*make keypress into sample no. (0-x)

* its all cool
* get sample info
	jsr		get_samp   	*load sample info and play it

	move.l	(sequence2),a1		*get current seq. addr. in a1
	move.w	d1,(a1)+			*put time in it
	addq.l	#4,a1			*add a long word
	move.w	d0,(a1)			*put sample no. in
	subq.l	#2,a1			*go back a word
	move.l	a1,(sequence2)		*store new current seq. addr.
	move.w	#$ffff,(a1)		*put a one in it incase it is last samp
	move.w	d1,(time)		*reset timer incase its incremented?!
	cmp.l	(seq_bytes),a1
	blo		another
	move.l	#2,(error)

stop
	move.l	(sequence2),a1		*store ffffffff after last sample in seq
	addq.l	#4,a1
	move.l	#$ffffffff,(a1)+
	move.l	a1,songend		*put end of sequence addr. in songend
	move.l	(sp)+,d2			*restore d2
	jsr		_Vbl_Remove		*remove record interupt
	move.l	(error),d0		*return error code
	rts

*************************************************************************
_TEST
*testing mode
*init sequencing
	move.l	4(sp),(sam_start)	*put passed params in memory
	move.l	8(sp),(items)
	
*test mode
	move.l	d2,-(sp)				*store d2

test_another	*do it again until a none sample key is pressed
* wait for key
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap		#13
	addq.l	#4,sp

* check input	
	swap		d0			*put scancode in low word
	cmp.w	#$63,d0		*compare with code for '(' on numeric
	blo		stop_test		*if less then not a sample
	move.l	(items),d2	*put no. of samps-1 in d2
	add.w	#$63,d2		*add scancode for '(' to it
	cmp.w	d2,d0		*compare keypressed with last key owning samp
	bhi		stop_test		*if higher then not a sample
	sub.w	#99,d0		*make keypress into sample no. (0-x)

* its all cool
* get sample info
	jsr		get_samp   	*load sample info and play it
	jmp		test_another	* repeat until none samp key pressed

stop_test
	move.l	(sp)+,d2			*restore d2

	rts
**************************************************************************
_EDIT
*recording mode
*init sequencing
	move.l	4(sp),(sam_start)	*put passed params in memory
	move.l	8(sp),(items)
	move.l	12(sp),(sequence2)
	move.l	16(sp),(seq_bytes)
	move.l	20(sp),(bufferedit)
	
	move.l	(bufferedit),d0	*finds max end address of buffer
	add.l	(seq_bytes),d0		*plus 16 safety margin
	sub.l	#16,d0
	move.l	d0,(seq_bytes)		*stores it back in seq-Bytes
	move.l	#0,(error)		*clear error flag

	move.b	#1,(editon)
	
	move.l	(bufferedit),(bufstart)
	move.l	(sequence2),a0
	move.w	(a0),d0			*get first elapse time in d0
	move.w	d0,(memo)			*put first elapse time in memo
	subq.w	#1,d0			*put actual timer 1 count behind elapse
	move.w	d0,(time)			*store in timer

	cmpi.w	#$ffff,d0		*check to see if out a time
	bne		leave_it_out2	
	move.l	#1,(error)	*better stop now
leave_it_out2				*it's ok carry on

* go (install the interupt)
	move.l	#1,-(sp)			*pass 1 via stack to install
	jsr		Vbl_Install		*EDIT vbl II
	addq.l	#4,sp			*stack correction

*editing mode
	move.l	d2,-(sp)				*store d2

another2		*do it again until a none sample key is pressed
* wait for key
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap		#13
	addq.l	#4,sp
	move.w	(time),d1	* store time from edit interupt in d1

* check error flag for time out.
	cmpi.l	#1,(error)
	beq		stop2

* check input	
	swap		d0			*put scancode in low word
	cmp.w	#$63,d0		*compare with code for '(' on numeric
	blo		stop2		*if less then not a sample
	move.l	(items),d2	*put no. of samps-1 in d2
	add.w	#$63,d2		*add scancode for '(' to it
	cmp.w	d2,d0		*compare keypressed with last key owning samp
	bhi		stop2		*if higher then not a sample
	sub.w	#99,d0		*make keypress into sample no. (0-x)

* its all cool
* get sample info
	jsr		get_samp   	*load sample info and play it

	move.l	(bufferedit),a1	*get current buf. addr. in a1
	move.w	d1,(a1)+			*put time in it
	move.w	d0,(a1)+			*put sample no. in
	move.l	a1,(bufferedit)	*store new current seq. addr.
	cmp.l	(seq_bytes),a1
	blo		another2			* repeat until none samp key pressed
	move.l	#2,(error)

stop2
	move.l	(bufferedit),a1	*store ffffffff after last sample in seq
	move.l	#$ffffffff,(a1)+
	move.l	(sp)+,d2			*restore d2
	jsr		_Vbl_Remove		*remove record interupt
	move.l	(error),d0		*return error code

	rts
*************************************************************************
_DELETE
*remove current sample
	move.l	4(sp),a0		*get position address in sequence
	
	move.w	4(a0),(a0)	*shift next time to current time
del_loop
	addq.l	#4,a0		*move to next item
	move.l	4(a0),(a0)	*copy item to previous slot
	cmpi.l	#$ffffffff,(a0)	*is it last item
	bne		del_loop		* no then loop

	rts

*************************************************************************
_MERGE_BUFFER
*put passed params in memory
	move.l	4(sp),(sequence)
	move.l	8(sp),(seq_bytes)
	move.l	12(sp),(bufferedit)
	
	move.l	(sequence),d0		*finds max end address of seq
	add.l	(seq_bytes),d0		*plus 16 safety margin
	sub.l	#16,d0
	move.l	d0,(seq_bytes)		*stores it back in seq-Bytes
	move.l	#0,(error)		*clear error flag

	move.l	(sequence),(sequence2)	*store sequence address in seq2
	move.l	(sequence),a0		*move address to a0
	move.l	(bufferedit),a1	*put buffer address in a1
	
mergeloop
	move.w	(a1),d0		*put 1st merge item time in d0
	cmpi.w	#$ffff,d0		*is it last item
	beq		endmerge		*yes then end
	
find_place
	cmp.w	(a0),d0	*compare merge time with time in sequence
	bls		insert	*if lower or same then insert
	addq.l	#4,a0	*go to next item time in sequence
	jmp		find_place	*loop
	
insert
	move.l	a0,d1	*move address of item in seq. to d0

find_end
	cmpi.l	#$ffffffff,(a0)+	*is item last item & inc
	bne		find_end			*no then loop

	addq.l	#4,a0		*inc seq one item past end
	cmp.l	(seq_bytes),a0
	blo		shuffle
	move.l	#1,(error)
	jmp		endmerge
	
shuffle
	subq.l	#8,a0		*dec by 2 items seq
	move.l	(a0)+,(a0)	*copy from current to next item
	cmp.l	d1,a0		*keep counting down till we hit the 
	bne		shuffle		*address of the insert item

	move.w	(a1)+,(a0)+	*insert the item
	move.w	4(a0),(a0)
	move.w	(a1)+,4(a0)
	subq.w	#2,a0
	jmp		mergeloop		*keep merging till all are merged
endmerge
	move.l	(error),d0	*return error code
	rts

*************************************************************************
* sort AVR info for sample to memory variables then call play sample.
* d0 carries samp no.
get_samp
	move.l	(sam_start),a0		*get address of list
	and.l	#$ffff,d0			*mask high word
	lsl.l	#2,d0			* x4 for offset
	add.l	d0,a0			*add offset to get address from list
	lsr.l	#2,d0			* /2 return to original value
	move.l	(a0),a0			*put samp. start address in a0

* get length
	move.l	26(a0),(sample_length)	*offsets from a0 for AVR header
	
* get stereo or mono (0=mono and ffff= stereo. in playback s=0 and m=1)
	move.w	12(a0),d2
	move.b	#1,(stereo_mono)
	cmpi.w	#0,d2
	beq		mono
	move.b	#0,(stereo_mono)
mono	

* get unsigned or signed (un=0 and sn=ffff. in play un=1 and sn=0)
	move.w	16(a0),d2
	move.b	#1,(type)
	cmpi.w	#0,d2
	beq		unsigned
	move.b	#0,(type)
unsigned

* get loopy. (0=no and ffff=yes. in play 1=no and 3=yes)
	move.w	18(a0),d2
	move.b	#1,(playmode)
	cmpi.w	#0,d2
	beq		noloop
	move.b	#3,(playmode)
noloop

* get frequency (25600= 25.6khz in play = 2)
	move.l	22(a0),d2
	move.b	#3,(frequency)
	cmp.w	#$c800,d2
	beq		got_it
	move.b	#2,(frequency)
	cmp.w	#$6400,d2
	beq		got_it
	move.b	#1,(frequency)
	cmp.w	#$30fa,d2
	beq		got_it
	move.b	#0,(frequency)
got_it

	add.l	#128,a0		*set a0 past AVR header (raw sample follows)
	move.l	a0,(sample_start)	* set start address
	
	jsr		play_sample		* do it
	rts
*************************************************************************
_Volume_tone	
	move.l	4(sp),d0		*get value to send to VTC
	move.l	d2,-(sp)		*store d2
	move.l	d0,d2		*use d2 because of supervisor

* enter super
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap		#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

	move.l	#$07ff,voltone_mask		*send data to VTC
	or.l		#$400,d2
	move.l	d2,voltone_data

* exit supervisor mode
	move.w	#super,-(SP)
	trap		#gemdos
	addq.w	#$06,SP

	move.l	(sp)+,d2		*restore d2
	rts
*************************************************************************
_Click
	move.l	4(sp),d0		*get passed value from stack to d0
						*0=keyclick off,7=keyclick on
	move.l	d2,-(sp)		*store d2
	move.l	d0,d2		*use d2 because super wipes d0-d1,a0-a1

* enter super
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap		#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

	move.b	d2,$484		*set keyboard variable
	
* exit supervisor mode
	move.w	#super,-(SP)
	trap		#gemdos
	addq.w	#$06,SP

	move.l	(sp)+,d2		*restore d2
	rts
*************************************************************************

* program equates

	cnop	0,2

sam_start		ds.l	$01	*address of (list containing sample st. address')
items		ds.l	$01	*number of samples stored (-1) ie. 0= 1 sample
sequence		ds.l	$01	*address of start of sequence memory
sequence2		ds.l	$01	*current address in seq. either play or record
bufferedit	ds.l	$01  *editing buffer address
bufstart		ds.l	$01  *start of edit buffer address
seq_bytes		ds.l	$01	*number of bytes available in seq. memory
songend		ds.l	$01	*end address of song
vbl_current	ds.l	$01	*address in vbl queue of last addition to the list
time			ds.l	$01	*counter used by interupts
memo			ds.l	$01	*next time elapse memory.
finish		ds.l	$01  *holds address of finish variable
dubbing		ds.l	$01	*0 if dubbing and 1 if record
error		ds.l	$01	*0 if no probs, 1 if out of memory
	
* variables for sample playback
sample_length	ds.l	$01	*obvious
sample_end	ds.l	$01	* "
sample_start	ds.l	$01	* "
playmode		ds.l	$01	*0=off,1=once,3=looped
type			ds.l	$01	*0=signed,1=unsigned
frequency		ds.l	$01	*0=6khz,1=12khz,2=25khz,3=51khz
stereo_mono	ds.l	$01	*1/0 for mono or stereo

* super mode set to 0 when in user and ff super.
supermode		ds.b	$01	*used because edit vbl is already in super
editon		ds.b	$01	*=0 if play mode / =1 if editing
	end	
