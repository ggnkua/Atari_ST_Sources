***********************************************************************
*                                                                     *
*              STE BASIC MC SOURCE FOR Sample Music                   *
*                                                                     *
*                   by ½ Ian Hancock, September 1992                  *
*                                                                     *
***********************************************************************

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

*variable equates

sam_start		equ	0
items		equ	4
sequence2		equ	8
vbl_current	equ	12
time			equ	16
memo			equ	20
seqperm		equ	24

sample_length	equ	0
sample_end	equ	4
sample_start	equ	8
playmode		equ	12
type			equ	16
frequency		equ	20
stereo_mono	equ	24


* main program
*************************************************************************
sequence		ds.l	$01	*current address in seq. either play or record
finish		ds.l	$01  *holds address of finish variable
*finish conts 1=norm,2=loop,0=stop
keeploop		ds.l	$01	*holds address of loop variable counts down
mix			ds.l	$01	*current mix address
samples_list	ds.l	$18	*sample start addresses
	even

start
	movem.l	d0-d2/a0-a3,-(sp)
* set up play params
	lea		program(pc),a3

	move.l	sequence(pc),a0
	clr.w	d0
	move.b	19(a0),d0		*no. of items (-1)
	move.l	a0,a1
	add.l	#96,a0		*point to first sam
	add.l	#24,a1		*point tosam length list
	lea		samples_list(pc),a2
	move.l	a2,sam_start(a3)
	
sam_filler
	move.l	(a1)+,d1		*next length inc.
	move.l	a0,(a2)+		
	add.l	d1,a0
	dbf.w	d0,sam_filler
		
	move.l	mix(pc),d0
	cmpi.l	#0,d0
	beq		useall

	add.l	#24,d0
	move.l	d0,a0

useall
	move.l	a0,sequence2(a3)	*sequence start address	
	move.l	a0,seqperm(a3)
	
	move.w	(a0),d0			*get first elapse time in d0
	move.w	d0,memo(a3)		*put first elapse time in memo
	subq.w	#1,d0			*put actual timer 1 count behind elapse
	move.w	d0,time(a3)		*store in timer
	
* go (install the interupt)
	move.l	#1,-(sp)			*pass 1 via stack to install
	jsr		Vbl_Install(pc)	*EDIT vbl II
	addq.l	#4,sp			*stack correction
* it auto de-stalls
	movem.l	(sp)+,d0-d2/a0-a3
	rts

*************************************************************************
STOP
*Remove current vbl
	move.l	a3,-(sp)
	lea		program(pc),a3

* enter super
*	clr.l	-(SP)
*	move.w	#super,-(SP)
*	trap		#gemdos
*	addq.l	#$06,SP
*	move.l	D0,-(SP)

	move.l	vbl_current(a3),a1	*removes last vbl installed
	move.l	#0,(a1)			*by my prog. puts 0 in list

* set DMA sound, stop
	move.b	#0,snd_cntl_DMA

* exit supervisor mode
*	move.w	#super,-(SP)
*	trap		#gemdos
*	addq.w	#$06,SP

	move.l	(sp)+,a3
	rts
*************************************************************************

*Install V_blank counter for RECORD

Vbl_Install
	movem.l	d2/a3,-(sp)		*store d2
	lea		program(pc),a3

* enter super
*	clr.l	-(SP)
*	move.w	#super,-(SP)
*	trap		#gemdos
*	addq.l	#$06,SP
*	move.l	D0,-(SP)

* find a space in queue
	move.l	vbl_queue,a0
	move.w	#7,d0
	
find_entry
	tst.l	(a0)+
	beq.s	entry_found
	dbra		d0,find_entry
	bra.s	quit
	
entry_found
	lea		vbl_EDIT(pc),a1
	move.l	a1,-(a0)			*put address from a1 in list
	move.l	a0,vbl_current(a3)	*remember position in list

quit	
* exit supervisor mode
*	move.w	#super,-(SP)
*	trap		#gemdos
*	addq.w	#$06,SP

	movem.l	(sp)+,d2/a3	*restore d2
	rts
*************************************************************************
* vbl routine II for edit and playback
vbl_EDIT
	movem.l	a3/a4,-(sp)
	lea		program(pc),a3
	lea		samplepback(pc),a4

	move.w	time(a3),d0	*put time in d0
	addq.w	#1,d0		*add 1
	move.w	d0,time(a3)	*replace new time
	move.w	memo(a3),d1
	cmp.w	d0,d1		*if elapse time is reached
	bls		next_samp	*get next sample
	movem.l	(sp)+,a3/a4
	rts
	
next_samp
	move.l	sequence2(a3),a0	*get current seq. addr.
	add.l	#4,a0			*increment by a long word
	move.l	a0,sequence2(a3)	*replace new position
	move.w	(a0),memo(a3)		*set new elapse time
	move.w	2(a0),d0			*put sample no in d0

*get_samp
	move.l	sam_start(a3),a0		*get address of list
	and.l	#$ffff,d0			*mask high word
	lsl.l	#2,d0			* x4 for offset
	add.l	d0,a0			*add offset to get address from list
	lsr.l	#2,d0			* /2 return to original value
	move.l	(a0),a0			*put samp. start address in a0

* get length
	move.l	26(a0),sample_length(a4)	*offsets from a0 for AVR header
	
* get stereo or mono (0=mono and ffff= stereo. in playback s=0 and m=1)
	move.w	12(a0),d2
	move.b	#1,stereo_mono(a4)
	cmpi.w	#0,d2
	beq		mono
	move.b	#0,stereo_mono(a4)
mono	

* get unsigned or signed (un=0 and sn=ffff. in play un=1 and sn=0)
	move.w	16(a0),d2
	move.b	#1,type(a4)
	cmpi.w	#0,d2
	beq		unsigned
	move.b	#0,type(a4)
unsigned

* get loopy. (0=no and ffff=yes. in play 1=no and 3=yes)
	move.w	18(a0),d2
	move.b	#1,playmode(a4)
	cmpi.w	#0,d2
	beq		noloop
	move.b	#3,playmode(a4)
noloop

* get frequency (25600= 25.6khz in play = 2)
	move.l	22(a0),d2
	move.b	#3,frequency(a4)
	cmp.w	#$c800,d2
	beq		got_it
	move.b	#2,frequency(a4)
	cmp.w	#$6400,d2
	beq		got_it
	move.b	#1,frequency(a4)
	cmp.w	#$30fa,d2
	beq		got_it
	move.b	#0,frequency(a4)
got_it

	add.l	#128,a0		*set a0 past AVR header (raw sample follows)
	move.l	a0,sample_start(a4)	* set start address
	
*play sample
* do it
	move.l	sample_start(a4),D0
	add.l	sample_length(a4),D0
	move.l	D0,sample_end(a4)

* write to sound DMA hardware
	clr.b	snd_cntl_DMA

* set  sampling freq and stereo/mono
	move.b	stereo_mono(a4),d0
	lsl.b	#$7,d0
	or.b		frequency(a4),d0
	move.b	d0,snd_mode_DMA

* set start sample location
	move.l	sample_start(a4),D0
	move.b	D0,snd_start_lo_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_start_mid_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_start_hi_DMA

* set end sample location
	move.l	sample_end(a4),D0
	move.b	D0,snd_end_lo_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_end_mid_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_end_hi_DMA

* start DMA sound, repeating at end
	move.b	playmode(a4),snd_cntl_DMA

*rts
	move.l	finish(pc),a0		*play finished
	add.l	#1,(a0)

	cmpi.w	#$ffff,memo(a3)	*if = ffff
	beq		finishedit		*then seq finished
	movem.l	(sp)+,a3/a4
	rts

finishedit
	move.l	keeploop(pc),a0	*looping variable address
	move.l	(a0),d0			*0 if not looping
	subq.l	#1,d0			*decrem loop no

	cmpi.l	#0,d0			*if not 0 then loop
	beq		stopped
	cmpi.l	#$ffffffff,d0		*if was 0 now 1 then forever
	bne		notforever
	
	addq.l	#1,d0			*sorted. make forever 0 again

notforever
	move.l	d0,(a0)			*store new count down

	move.l	seqperm(a3),a0
	move.l	a0,sequence2(a3)	*reset seq start position	

	move.w	(a0),d0			*get first elapse time in d0
	move.w	d0,memo(a3)		*put first elapse time in memo
	subq.w	#1,d0			*put actual timer 1 count behind elapse
	move.w	d0,time(a3)		*store in timer

	move.l	finish(pc),a0		*play finished flag reset
	move.l	#1,(a0)

	movem.l	(sp)+,a3/a4
	rts	

stopped
	move.l	vbl_current(a3),a1	* vbl EDIT list pos. to a1
	move.l	#0,(a1)			*de-install by putting 0 in list

	cmp.b	#3,snd_cntl_DMA
	bne		not_loopy
	
	move.b	#0,snd_cntl_DMA
	
not_loopy
	move.l	finish(pc),a0		*play finished
	move.l	#0,(a0)
	movem.l	(sp)+,a3/a4
	rts	
*************************************************************************
* program variables

program		ds.l	$01	*address of (list containing sample st. address')
	ds.l	$01	*number of samples stored (-1) ie. 0= 1 sample
	ds.l	$01	*current address in seq. either play or record
	ds.l	$01	*address in vbl queue of last addition to the list
	ds.l	$01	*counter used by interupts
	ds.l	$01	*next time elapse memory.
	ds.l	$01	*seqperm holder
	
* variables for sample playback
samplepback	ds.l	$01	*obvious
	ds.l	$01	* "
	ds.l	$01	* "
	ds.l	$01	*0=off,1=once,3=looped
	ds.l	$01	*0=signed,1=unsigned
	ds.l	$01	*0=6khz,1=12khz,2=25khz,3=51khz
	ds.l	$01	*1/0 for mono or stereo

	end	
