(  Sound.fth
  Here are some simple sounds. There are 15 byte registers on the sound
  chip. DoSound is a function which takes the address of a string of
  'commands'. These commands load registers. For instance, 'dc.b 0,$3B'
  compiles two bytes which will cause the value $3B to be loaded into
  sound register 0.
  This is a dabble demo. Just keep changing values and
  reloading until you're tired.

Registers:
Register 0:	8-bit. Period for channel A
Register 1:	4-bit. Step size for channel A
Register 2:	Same as register 0 but for channel B
Register 3:	Same as register 1 but for channel B
Register 4:	Same as register 0 but for channel C
Register 5:	Same as register 1 (but for channel C)
Register 6:	5-bit. If using noise gen, this holds the period
Register 7:	configuration byte for channels and ports. 
  Bit 0: 0,1 if Channel A tone on,off
  Bit 1: 0,1 if Channel B tone on,off
  Bit 2: 0,1 if Channel C tone on,off
  Bit 3: 0,1 if Channel A noise on,off
  Bit 4: 0,1 if Channel B noise on,off
  Bit 5: 0,1 if Channel C noise on,off
  Bit 6: 0,1 if Port A in,out
  Bit 7: 0,1 if Port B in,out
Register 8:	5-bit. If bit 4 set, then using envelope. Else bits 0-3
		are the signal volume for channel A.
Register 9:	Same as Reg 8 but is for channel B.
Register 10:	Same as Reg 8 but is for channel C.
Register 11:	8-bit. Low byte of the sustain value.
Register 12:	8-bit. High byte of the sustain.
Register 13:	4-bit. The value determines which envelope shape to use.
Register 14:	8-bit. This is Port A.
Register 15:	8-bit. This is Port B.

Commands: (used in the doSound command strings)
$00-$0F		Load the following byte into the sound register.
$80		Save the following byte as a temporary value.
$81		Three bytes follow. First is the number of a temporary
		register to store the byte from the $80 command. Second
		is a loop increment. Third is the loop exit value for
		the temp register.
$82-$FF		If the byte following is zero, sound stops. Else the byte
		is the number of ticks (50hz) 'till the next sound
		processing.
)

also assembler


create keyclick
	dc.b	0,$3B	( channel A period is 60)
	dc.b	1,0
	dc.b	2,0
	dc.b	3,0
	dc.b	4,0
	dc.b	5,0
	dc.b	6,0	( Noise generator won't be used)
	dc.b	7,%11111110	( Turn on tone for channel A)
	dc.b	8,$10	( means channel A will be using the envelope)
	dc.b	9,0
	dc.b	10,0
	dc.b	11,$80
	dc.b	12,$1	( sustain will be $180)
	dc.b	13,3	( envelopes 0-3 are ramp-down, hold-at-zero)
	dc.b	255,0	( stop processing immediately)

keyclick call dosound

create bell			( a bell)
	dc.b	0,$34		( channel A period is 52)
	dc.b	1,0
	dc.b	2,0
	dc.b	3,0
	dc.b	4,0
	dc.b	5,0
	dc.b	6,0
	dc.b	7,%11111110	( turn on tone for Channel A)
	dc.b	8,$10		( will be using envelope)
	dc.b	9,0
	dc.b	10,0
	dc.b	11,0
	dc.b	12,$10		( sustain will be $1000)
	dc.b	13,9		( wave 9 is same as 0)
	dc.b	255,0		( stop processing)

bell call dosound


