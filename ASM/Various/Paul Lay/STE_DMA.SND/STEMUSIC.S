***********************************************************************
*                                                                     *
*                     STE Background Music                            *
*                                                                     *
*                   by Paul Lay, January 1991                         *
*                                                                     *
***********************************************************************


* system equates

textsz		equ	$0C
bsssz		equ	$1C
datasz		equ	$14

gemdos		equ	$01
term		equ	$00
print_line	equ	$09
set_dta		equ	$1A
super		equ	$20
gettime		equ	$2C
keep_process	equ	$31
open		equ	$3D
read_only	equ	$00
read		equ	$3F
close		equ	$3E
setblock	equ	$4A
sfirst		equ	$4E

snd_cntl_DMA		equ	$FF8901
snd_start_hi_DMA	equ	$FF8903
snd_start_mid_DMA	equ	$FF8905
snd_start_lo_DMA	equ	$FF8907
snd_end_hi_DMA		equ	$FF890F
snd_end_mid_DMA		equ	$FF8911
snd_end_lo_DMA		equ	$FF8913
snd_mode_DMA		equ	$FF8921

p_cookies		equ	$5A0


* main program

start

* remember old stack
	move.l	SP,old_stack
	move.l	#my_stack,SP

* enter supervisor mode
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap	#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

* look to see if this machine has got stereo DMA sound
	tst.l	p_cookies
	bne	some_cookies
* not stereo DMA sound chip set error
	move.l	#no_DMA_sound_error,-(SP)
	bra	abort_samples

some_cookies
	move.l	p_cookies,A0
	clr.l	D1

examine_cookie
	move.l	(A0),D0

* last cookie?
	beq	no_more_cookies

* background music already installed?
	cmp.l	#'PLAY',D0
	bne	not_already_playing
* already playing error
	move.l	#already_playing_error,-(SP)
	bra	abort_samples

not_already_playing
* is it sound cookie?
	cmp.l	#'_SND',D0
	beq.s	not_sound_cookie
	move.l	$04(A0),D1
not_sound_cookie

	addq.l	#$08,A0
	bra.s	examine_cookie

no_more_cookies
* dma stereo sound?
	tst.l	D1
	bne	DMA_sound_chip_set
* not stereo DMA sound chip set error
	move.l	#no_DMA_sound_error,-(SP)
	bra	abort_samples

DMA_sound_chip_set
* look for file info
	move.l	#dta_buffer,-(SP)
	move.w	#set_dta,-(SP)
	trap	#gemdos
	addq.l	#$06,SP

	clr.w	-(SP)
	move.l	#sample_filename,-(SP)
	move.w	#sfirst,-(SP)
	trap	#gemdos
	addq.l	#$08,SP
	tst.w	D0
	beq	found_file
* no sample file error
	move.l	#no_file_error,-(SP)
	bra	abort_samples	

found_file
* evaluate end of samples
	move.l	#sample_start,D0
	add.l	sample_length,D0
	move.l	D0,sample_end

* return unnecessary RAM to GEM
	move.l	old_stack,A5
	move.l	$04(A5),A5
	move.l	textsz(A5),D0
	add.l	datasz(A5),D0
	add.l	bsssz(A5),D0
	add.l	sample_length,D0
	add.l	#$100,D0
	move.l	D0,program_length
	move.l	D0,-(SP)
	move.l	A5,-(SP)
	clr.w	-(SP)
	move.w	#setblock,-(SP)
	trap	#gemdos
	add.l	#$0C,SP
	tst.l	D0
	beq	enough_room
* not enough memory for samples error
	move.l	#not_enough_memory_error,-(SP)
	bra	abort_samples

enough_room
* find last cookie
	move.l	p_cookies,A0
	clr.l	D0

test_cookie
	addq.l	#$01,D0
	tst.l	(A0)
	beq.s	last_cookie
	addq.l	#$08,A0
	bra.s	test_cookie

last_cookie
* can we add own cookie to jar
	cmp.l	$04(A0),D0
	beq	no_room_in_cookie_jar

* add cookie
	move.l	#'PLAY',(A0)
	move.l	$04(A0),$0C(A0)
	clr.l	$08(A0)

no_room_in_cookie_jar 
* load samples
	move.l	#sample_filename,A4
	move.l	#sample_start,A5
	move.l	sample_length,D4
	bsr	load_file

* THIS BLOCK IS NOT NEEDED IF SAMPLE IS ALREADY SIGNED !!!
	bra	signed		*so we skip it !
* convert 2 Bit System Replay samples into STE format
	move.l	#sample_start,A0
convert_sample
	move.b	(A0),D0
	sub.b	#$80,D0
	move.b	D0,(A0)+
	cmp.l	sample_end,A0
	bne.s	convert_sample

signed

* SET UP DMA CHIP - THIS ACTUALLY DOES THE BIZ
* write to sound DMA hardware
	clr.b	snd_cntl_DMA

* set 6258Hz mono sampling
	move.b	#$80,snd_mode_DMA

* set start sample location
	move.l	#sample_start,D0
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
	move.b	#$03,snd_cntl_DMA

* exit supervisor mode
	move.w	#super,-(SP)
	trap	#gemdos
	addq.w	#$06,SP

* return to GEM
	clr.w	-(SP)
	move.l	program_length,-(SP)
	move.w	#keep_process,-(SP)
	trap	#gemdos


* abort sampling
abort_samples

* print pending error
	move.w	#print_line,-(SP)
	trap	#gemdos
	addq.l	#$06,SP

* delay a while
	move.w	#gettime,-(SP)
	trap	#gemdos
	addq.w	#$02,SP
	move.w	D0,D7

delay
	move.w	#gettime,-(SP)
	trap	#gemdos
	addq.w	#$02,SP

	cmp.w	D0,D7
	beq.s	delay

* exit supervisor mode
	move.w	#super,-(SP)
	trap	#gemdos
	addq.w	#$06,SP

	move.w	#term,-(SP)
	trap	#gemdos


* load a file from disk

* A4.l pointer to filename
* A5.l load address
* D4.l number of bytes

load_file

* open file
	move.w	#read_only,-(SP)
	move.l	A4,-(SP)
	move.w	#open,-(SP)
	trap	#gemdos
	addq.l	#$08,SP
	move.w	D0,handle	

* read bytes
	move.l	A5,-(SP)
	move.l	D4,-(SP)
	move.w	handle,-(SP)
	move.w	#read,-(SP)
	trap	#gemdos
	add.l	#$0C,SP

* close file
	move.w	handle,-(SP)
	move.w	#close,-(SP)
	trap	#gemdos
	addq.l	#$04,SP

	rts


* program equates

sample_filename
	dc.b	'sample.sam',$00

no_DMA_sound_error
	dc.b	27,'Y',34,32,'DMA chip set not present',$00

already_playing_error
	dc.b	27,'Y',34,32,'Program already installed',$00

no_file_error
	dc.b	27,'Y',34,32,'Cannot find sample file',$00

not_enough_memory_error
	dc.b	27,'Y',34,32,'Not enough memory',$00

	even

handle
	ds.w	$01

old_stack
	ds.l	$01

program_length
	ds.l	$01

	ds.l	$40
my_stack

dta_buffer
	ds.b	$2C

sample_length	equ	dta_buffer+$1A

sample_end
	ds.l	$01

sample_start

	end	
