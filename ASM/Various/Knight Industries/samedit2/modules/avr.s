; Sam-Edit 2 version 2.0 AVR module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\AVR.SEM

	SECTION	data

moduleName		dc.b	'AVR Module ',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.3 (12/06/1998)',0
moduleFunctions	dc.w	%01111
moduleID		dc.b	'AVR',0

; functions Bit:  0  = ID	(Necessary for all modules)
;           Bit:  1  = Load	"
;           Bit:  2  = Save	"
;           Bit:  3  = Update Header	"
;           Bit:  4  = Intel byte order if set (required)

	SECTION	bss
; info table
	rsreset
sampleModuleAddress	rs.l	1
sampleHeaderSize	rs.w	1
sampleDataSize	rs.l	1
sampleAddress	rs.l	1
sampleFrequency	rs.l	1
sampleChannels	rs.w	1
sampleResolution	rs.w	1
sampleSigned	rs.w	1
sampleLoaded	rs.w	1
sampleSaveStatus	rs.w	1
sampleMode	rs.w	1	; 0 = mem, 1 = d2d
sampleModuleFunctions	rs.w	1
samplePathname	rs.b	256	; holds directory+file
sampleInfoSize	rs.w	0

; AVR header
	rsreset
code	rs.l	1
name	rs.b	8
channels	rs.w	1
resolution	rs.w	1
signed	rs.w	1
loop	rs.w	1
midi	rs.w	1
freq	rs.l	1
length	rs.l	1
loop1	rs.l	1
loop2	rs.l	1
reserved	rs.b	26
message	rs.b	64

	SECTION	text

start	; header in a0, info table in a1, function number in d0
	; d1 = address of D2D buffer , d2 = size of d2d buffer
	; DO NOT touch sampleModuleAddress
	; DO NOT change sampleLoaded

	cmpi.w	#1,d0
	beq	idSample

	cmpi.w	#2,d0
	beq	loadSample

	cmpi.w	#3,d0
	beq	saveSample

	cmpi.w	#4,d0
	beq	updateHeader

	rts

idSample	; return in d0, non zero if found, zero if not found
	; if found enter data in info table
	; set header size/update data size needed

	; sampleDataSize=filesize when module is first called
	; for a sample

	moveq.w	#0,d0	; set to not found

	cmpi.l	#'2BIT',code(a0)
	bne	.notAVR

	move.w	#128,sampleHeaderSize(a1)
	sub.l	#128,sampleDataSize(a1)

	move.w	channels(a0),d0
	neg	d0
	addq.w	#1,d0
	move.w	d0,sampleChannels(a1)

	move.w	resolution(a0),sampleResolution(a1)

	move.w	signed(a0),d0
	neg	d0
	move.w	d0,sampleSigned(a1)

	move.l	freq(a0),d0
	andi.l	#$ffffff,d0
	move.l	d0,sampleFrequency(a1)

	moveq.w	#1,d0	; set to found
.notAVR
	rts

loadSample	; memory has already been reserved and the data
	; loaded, this part is for any decoding that may
	; need to be done (such as byte swapping)

	rts

saveSample	; no need to actually write data to the file
	; as with loading this part is for any encoding that
	; may need to be done

	rts

updateHeader	; Construct a new header to ensure a correct header

	move.l	#'2BIT',code(a0)
	clr.l	name(a0)
	clr.l	name+4(a0)

	move.w	sampleChannels(a1),d0
	subq.w	#1,d0
	neg	d0
	move.w	d0,channels(a0)

	move.w	sampleResolution(a1),resolution(a0)

	move.w	sampleSigned(a1),d0
	neg	d0
	move.w	d0,signed(a0)

	clr.w	loop(a0)	; no looping for the moment

	move.w	#$FFFF,midi(a0)	; no midi

	move.l	sampleFrequency(a1),d0
	ori.l	#$FF000000,d0
	move.l	d0,freq(a0)

	move.l	sampleDataSize(a1),length(a0)

	clr.l	loop1(a0)	; 0 as no looping

	move.l	length(a0),loop2(a0)	; length as no looping

	lea	message(a0),a2
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	movem.l	d0-d5,-(a2)
	clr.w	-(a2)

	lea	message(a0),a0
	move.l	#'Save',(a0)+
	move.l	#'d Wi',(a0)+
	move.l	#'th S',(a0)+
	move.l	#'am-E',(a0)+
	move.l	#'dit ',(a0)+
	move.l	#'2 (A',(a0)+
	move.l	#'tari',(a0)+
	move.l	#') (c',(a0)+
	move.l	#') 19',(a0)+
	move.l	#'97/9',(a0)+
	move.l	#'8 Kn',(a0)+
	move.l	#'ight',(a0)+
	move.l	#' Ind',(a0)+
	move.l	#'ustr',(a0)+
	move.l	#'ies ',(a0)+
	clr.l	(a0)

	move.w	#128,sampleHeaderSize(a1)
	rts