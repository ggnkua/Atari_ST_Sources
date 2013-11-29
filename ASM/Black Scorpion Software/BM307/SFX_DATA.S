maxchannels	=	16	; Maximum number of channels
chansize	=	28	; bytes in channel status block

	SECTION DATA
sfx_sine:				; sine list 0-255/words
	incbin	"data\sine.dat"

freqtabledata:
	dc.w	$10000*11025/12500
	dc.w	$10000*12000/12500
	dc.w	$10000*10000/12500
	dc.w	$10000*11500/12500
	dc.w	$10000*10500/12500
	dc.w	$10000*9000/12500
	dc.w	$10000*12400/12500
	dc.w	$10000*9500/12500

sfx_init:
	dc.b	10,13,10,13,"Initiate SoundFX driver Coded By PeyloW",10,13,0
sfx_initvariables:
	dc.b	"  Init SFX variables.. ",0
sfx_initfreq:
	dc.b	"Done",10,13,"  Init pitch table.. ",0
sfx_initvol:
	dc.b	"Done",10,13,"  Init volume table.. ",0
sfx_initamb:
	dc.b	"Done",10,13,"  Init ambient table.. ",0
sfx_initpan:
	dc.b	"Done",10,13,"  Init paning table.. ",0
sfx_initdone:
	dc.b	"<NOT>",10,13,"SoundFX driver initiated.",10,13,0
	even

shootsample:
	incbin	data\shot.raw
shootsampleend:
growlsample:
	incbin	data\growl.raw
growlsampleend:
talksample:
	incbin	data\horned.raw
talksampleend:
painsample:
	incbin	data\aah.raw
painsampleend:

	SECTION BSS

sound_on:
	ds.w	1

randfreq:
	ds.w	1	; random(?) frequenzy pointer

freqtable:			; frequenzy add table
	ds.w	8
samdiv:			; number of sample units per VBL
	ds.w	1
num_channels:		; number of max channels
	ds.w	1
num_VBLs:			; number of VBL delays
	ds.w	1
freq:			; frequenzy to use
	ds.w	1

channellist:		; channel status data
	ds.b	chansize*maxchannels

voltable:			; volume table
	ds.b	256*256
ambtable:			; ambient table
	ds.l	256
pantable:			; panoration table
	ds.l	256*256

samstart:	ds.l	1	; start of sample buffer
samend:	ds.l	1	; end of sample buffer
sampos:	ds.l	1	; current possition in sample buffer

;samplebuffer:
;	ds.b	3072	; sample buffer

*****
* Channel status specifics
*****
	rsreset
chanstatus:	rs.w	1	; Status of channel
chanprio:	rs.w	1	; Priority of channel
chanpriodec:rs.w	1	; Priority decreaser
chanXpos:	rs.w	1	; Xpos of channel
chanYpos:	rs.w	1	; Ypos of channel
chandist:	rs.l	1	; distanse to sound
chandir:	rs.l	1	; direction to sound
chanpitch:	rs.w	1	; Pitch to use
chanpos:	rs.l	1	; current sample position
chanend:	rs.l	1	; end of sample
