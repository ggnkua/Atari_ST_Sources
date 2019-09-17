***********************************************************************
*                                                                     *
*               STE Sample Music in the background                    *
*               converted from Paul Lay's source January 1991         *
*               by Ian Hancock, August 1993                           *
*								      *
*		It now loads an AVR file instead of a raw SPL file    *
*		NOTE you need to change a line in the _PLAY_SAMPLE    *
*		routine if you want it to loop on a none looped       *
* 		sample (as described by it's header)		      *
*								      *
*		The _PLAY_SAMPLE routine was written for ICARI U.G.   *
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

*************************************************************************
* Driver for the _PLAY_SAMPLE routine. Allows background DMA music on STE
* from an AVR file as opposed to a raw sample file. 
* Most of the driver was written by Paul Lay - thanks to his PD source
Driver
	
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

***************************************************************************
* If you want to use the STE DMA sound routine _PLAY_SAMPLE then you
* need to include this code after loading your sample.
* A0 needs to point to the start of the AVR sample file you have loaded
* You also need to include the routine _SIGN_IT, which converts
* unsigned AVR files to signed in memory.

	move.l	#sample_start,A0
	cmp.w	#0,16(a0)
	bne	already_signed
	
	bsr	_SIGN_IT
	
already_signed

* With A0 pointing to the start of the loaded AVR sample file call _PLAY_SAMPLE
* NOTE also that the 68000 must be in SUPERVISOR MODE !!
	bsr	_PLAY_SAMPLE

***************************************************************************
* the rest of the driver

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

***************************************************************************
* Load a file from disk
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
	
*************************************************************************
* THIS ROUTINE WAS WRITTEN BY IAN FOR THE ICTARI USER GROUP 93
* Sort AVR header information into the DMA sound chip.
* Then play the sample Looped/once according to the header.
* a0 carries address of the start of the AVR file.

_PLAY_SAMPLE

* write to sound DMA hardware
	clr.b	snd_cntl_DMA

* get length from AVR header to d2
	move.l	26(a0),d2	*length of raw sample
	
* get raw sample start. Which is 128 bytes past header
	move.l	a0,d0		*AVR file start
	add.l	#128,d0		*raw sample start
	move.l	d0,d1		* "
	
	add.l	d2,d1		*add length for end of sample

* set start sample location
	move.b	D0,snd_start_lo_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_start_mid_DMA
	lsr.l	#$08,D0
	move.b	D0,snd_start_hi_DMA

* set end sample location
	move.b	D1,snd_end_lo_DMA
	lsr.l	#$08,D1
	move.b	D1,snd_end_mid_DMA
	lsr.l	#$08,D1
	move.b	D1,snd_end_hi_DMA

* get stereo or mono (0=mono and ffff= stereo variable in AVR file)
* the DMA needs mono = 1 and stereo = 0
* this byte also has to include the frequency information.
	move.w	12(a0),d1
	move.b	#1,d0
	cmpi.w	#0,d1
	beq	mono
	move.b	#1,d0
mono	
	lsl.b	#$7,d0		* shuffle it into position

* get frequency from AVR and convert to DMA byte
	move.l	22(a0),d2
	move.b	#3,d1
	cmp.w	#$c800,d2
	beq	got_it
	
	move.b	#2,d1
	cmp.w	#$6400,d2
	beq	got_it
	
	move.b	#1,d1
	cmp.w	#$30fa,d2
	beq	got_it
	
	move.b	#0,d1
got_it
	
	or.b	d1,d0		* mix the frequency with stereo/mono byte
	move.b	d0,snd_mode_DMA * write to the DMA chip

* get loopy information from AVR. (0=no and ffff=yes.)
* the DMA needs 1=no and 3=yes
**** NOTE if you want to loop always omit the next 6 lines of code ****
**** and replace them with the following line.                     ****
*	move.b	#3,d0

	move.w	18(a0),d1
	move.b	#1,d0
	cmpi.w	#0,d1
	beq	noloop
	move.b	#3,d0
noloop

* start DMA sound - with loop or not depending on AVR file header.
	move.b	d0,snd_cntl_DMA

	rts

*************************************************************************
* THIS ROUTINE ACCOMPANIES THE ONE _PLAY_SAMPLE ROUTINE ABOVE.
* Convert unsigned AVR samples into STE format (signed)
* A0 carries address of start of AVR file
_SIGN_IT
	move.w	#$ffff,16(a0)		*write signed to header
	move.l	26(a0),d0		*offsets from a0 for AVR header
	add.l	#128,a0
	
	move.l	a0,D1
	add.l	d0,D1			*add length to start to get end
	
convert_sample
	move.b	(A0),D0
	sub.b	#$80,D0
	move.b	D0,(A0)+
	cmp.l	d1,A0
	bne.s	convert_sample

	rts

*************************************************************************
* program equates

	even

sample_filename
	dc.b	'sample.avr',$00

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