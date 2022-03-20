; mp2 - DSP 44.1kHz Stereo MPEG2 Audio decoder
; Copyright (C) 1996 Fredrik Noring
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; Fredrik Noring
; noring@lysator.liu.se

BUFFER_SIZE		equ	128*1024

INFO_PADDING		equ	9
INFO_MODE		equ	6
INFO_EXTMODE		equ	4

MPG_MD_STEREO	equ	0
MPG_MD_JOINT_STEREO	equ	1
MPG_MD_DUAL_CHANNEL	equ	2
MPG_MD_MONO		equ	3

	include macrodsp.s
	include macrosnd.s

	section	text

soc	move.l	4(sp),a5
	move.l	a5,bp

	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$1100,d0
	move.l	a5,d1
	add.l	d0,d1
	and.l	#-2,d1

	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	lea	info_text0,a0
	bsr	text

	move.l	bp,a0
	lea	128(a0),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	subq.w	#1,d0
	bmi.s	.no_command
	lea	command_copy,a1
.copy	move.b	(a0)+,d1
	cmp.b	#' ',d1
	beq.s	.no_space
	move.b	d1,(a1)+
.no_space	dbra	d0,.copy
	clr.b	(a1)+
	move.l	#command_copy,filename
.no_command
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* Super
	addq.w	#6,sp
	move.l	d0,old_sp

	bsr	start

	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		* Super
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1		* Pterm0

start	clr.w	mute
	clr.w	nosync

.clear_keys	bsr	status_check
	tst.w	d0
	bne.s	.clear_keys

	bsr	fopen
	tst.w	d0
	bmi.s	.no_file
	bsr	restart

	bsr	DSP_init
	bsr	main
	bsr	DSP_exit
	bsr	fclose
	rts
.no_file	lea	error_file1,a0
	bsr	text
	move.l	filename,a0
	bsr	text
	lea	error_file2,a0
	bsr	error
	rts

error	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#8,-(sp)
	trap	#1
	addq.w	#2,sp
	rts

text	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

info	lea	info_text1,a0
	bsr	text
	move.l	filename,a0
	bsr	text
	lea	info_text2,a0
	bsr	text
	move.l	bitrate,d0
	bsr	display_number
	lea	info_text3,a0
	bsr	text
	rts

DSP_init	bsr	mute_on
	setmode #1
	sndstatus #1
	settracks #0,#0
	setmontracks #0
	dsptristate #1,#1
	soundcmd #4,#%10
	Dsp_ExecProg	#DSPbin.start,#(DSPbin.end-DSPbin.start)/3,#'NC'

	lea	DSPtables.start,a0
	move.w	#(DSPtables.end-DSPtables.start)/4-1,d1
.send_tables	move.l	(a0)+,d0
	bsr	DSP.host_send
	dbra	d1,.send_tables

	* Get DSP sync
	bsr	DSP.host_get

	devconnect #0,#%0000,#1,#1,#1
	devconnect #1,#%1000,#1,#1,#1   ; Connect DSPXMIT with DAC
	devconnect #2,#%0000,#1,#1,#1
	devconnect #3,#%0000,#1,#1,#1
	bsr	mute_off
	rts
gogo	Dsp_SetVectors #DSP_sync,#0
	rts
DSP_exit	bsr	mute_on
	Dsp_RemoveInterrupts #3
	sndstatus #1
	bsr	mute_off
	rts

mute_on	tst.w	mute
	bne.s	.muted
	move.w	#-1,mute
	soundcmd #0,#-1
	move.w   d0,ltatten
	soundcmd #1,#-1
	move.w   d0,rtatten
	soundcmd #2,#-1
	move.w   d0,ltgain
	soundcmd #3,#-1
	move.w   d0,rtgain
.muted	soundcmd #0,#$00f0
	soundcmd #1,#$00f0
	soundcmd #2,#$0000
	soundcmd #3,#$0000
	rts
mute_off	tst.w	mute
	beq.s	.not_muted
	clr.w	mute
	soundcmd #0,ltatten
	soundcmd #1,rtatten
	soundcmd #2,ltgain
	soundcmd #3,rtgain
.not_muted	rts

main	lea	buffer1,a0
	move.l	#BUFFER_SIZE,d0
	bsr	fread

	bsr	decode
	bsr	info

	bsr	gogo
.again
.next1	bsr	status_check
	tst.w	d0
	bne.s	.exit
	move.l	stream_bytes,a0
	cmp.l	#buffer1,a0
	blo.s	.next1
	cmp.l	#buffer1+1024,a0
	bhi.s	.next1
	lea	buffer2,a0
	move.l	#BUFFER_SIZE,d0
	bsr	fread

.next2	bsr	status_check
	tst.w	d0
	bne.s	.exit
	move.l	stream_bytes,a0
	cmp.l	#buffer2,a0
	blo.s	.next2
	cmp.l	#buffer2+1024,a0
	bhi.s	.next2
	lea	buffer1,a0
	move.l	#BUFFER_SIZE,d0
	bsr	fread

	bra.s	.again
.exit	rts

status_check	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.w	d0
	beq.s	.no
	move.w	#8,-(sp)
	trap	#1
	addq.w	#2,sp
.yes	moveq	#1,d0
	rts
.no	moveq	#0,d0
	move.w	nosync,d0
	rts

DSP.host_get	btst.b	#0,$ffffa202.w
	beq.s	DSP.host_get
	move.l	$ffffa204.w,d0
	rts
DSP.host_send	btst.b	#1,$ffffa202.w
	beq.s	DSP.host_send
	move.l	d0,$ffffa204.w
	rts
DSP.stream	btst.b	#1,$ffffa202.w
	beq.s	DSP.host_send
	moveq	#0,d0
	move.w	d1,d2
	asr.w	#3,d2
	subq.w	#1,d2
	bmi.s	.no1
.1	rept	8
	move.b	(a0)+,d0
	move.l	d0,$ffffa204.w
	endr
	dbra	d2,.1
.no1	and.w	#$7,d1
	subq.w	#1,d1
	bmi.s	.no2
.2	move.b	(a0)+,d0
	move.l	d0,$ffffa204.w
	dbra	d1,.2
.no2	rts

DSP_sync	*not.l	$ffff9800.w
	tst.w	nosync
	bne	.nosync
	movem.l	d0-a6,-(sp)

	move.l	sblimit,d0
	bsr	DSP.host_send
	move.l	jsbound,d0
	bsr	DSP.host_send
	move.l	frame_size,d0
	subq.l	#4+3,d0
	bsr	DSP.host_send

	move.l	frame_size,d1
	move.l	stream_bytes,a0
	cmp.l	stream_read,d1
	bls.s	.ok2
	move.l	stream_read,d1
	bsr	DSP.stream
	move.l	frame_size,d1
	sub.l	stream_read,d1
	bsr	restart
	move.l	stream_bytes,a0
	sub.l	d1,stream_read
	bsr	DSP.stream
	move.l	a0,stream_bytes
	bra.s	.resume
.ok2	sub.l	d1,stream_read
	bsr	DSP.stream
	move.l	a0,stream_bytes

.resume	bsr	decode
	movem.l	(sp)+,d0-a6
.nosync	*not.l	$ffff9800.w
	rts

decode	move.l	#2,stereo

	moveq	#0,d1
	moveq	#4-1,d2
	move.l	stream_read,d3
	move.l	stream_bytes,a0
.next	tst.l	d3
	bne	.ok1
	lea	buffer1,a0
	move.l	#2*BUFFER_SIZE,d3
.ok1	lsl.l	#8,d1
	move.b	(a0)+,d1
	subq.l	#1,d3
	dbra	d2,.next
	move.l	d1,d2
	and.l	#$fffff,d1
	swap.w	d2
	lsr.w	#4,d2
	and.l	#$fff,d2
	cmp.w	#$fff,d2
	bne	.no_sync

	move.l	d1,d2
	moveq	#12,d3
	lsr.l	d3,d2
	and.l	#$f,d2
	lea	bitrates,a0
	move.w	(a0,d2.w*2),d2
	move.l	d2,bitrate

	mulu.l	#144*1000,d2
	divu.l	#44100,d2
	btst.l	#INFO_PADDING,d1
	beq.s	.no_padding
	addq.l	#1,d2
.no_padding	move.l	d2,frame_size

	move.l	bitrate,d2
	divu.l	stereo,d2
	move.l	#30,sblimit	; table 2
	cmp.l	#56,d2
	blo.s	.not
	cmp.l	#80,d2
	bhi.s	.not
	move.l	#27,sblimit	; table 3
.not
	move.l	sblimit,jsbound
	move.l	d1,d2
	lsr.l	#INFO_MODE,d2
	and.l	#$3,d2
	cmp.b	#MPG_MD_JOINT_STEREO,d2
	bne.s	.nix
	move.l	d1,d2
	lsr.l	#INFO_EXTMODE,d2
	and.l	#$3,d2
	asl.l	#2,d2
	addq.l	#4,d2
	move.l	d2,jsbound
.nix	rts
.no_sync	move.w	#1,nosync
	rts

restart	move.l	#buffer1,stream_bytes
	move.l	#2*BUFFER_SIZE,stream_read
	rts

fopen	clr.w	-(sp)
	move.l	filename,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,fp
	rts
fread	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	fp,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	rts
fclose	move.w	fp,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

* Positive numbers only!
display_number
	lea	buffer+32,a0
	clr.b	-(a0)
.next	clr.l	d1
	divu.l	#10,d1:d0
	add.b	#'0',d1
	move.b	d1,-(a0)
	tst.w	d0
	bne.s	.next
	bsr	text
	rts

	section	data
DSPbin.start
	incbin	mp2.dsp	; DSP binary file
DSPbin.end	even
DSPtables.start
	incbin	dsp.dat
DSPtables.end

bitrates	dc.w	0,32,48,56,64,80,96,112,128,160,192,224,256,320,384

info_text0	dc.b	'mp2 version 0.4alpha, Copyright (C) 1996 Fredrik Noring',10,13
	dc.b	'DSP 44.1kHz Stereo MPEG2 Audio decoder (external clock)',10,13
;	dc.b	'DSP 44.1kHz Stereo MPEG2 Audio decoder',10,13
	dc.b	'This program is free software and distributed under',10,13
	dc.b	'the conditions of the GNU General Public License.',10,13,10,13,0
info_text1
;	dc.b	'(low sound quality due to linear',10,13
;	dc.b	' interpolation for 44.1kHz to 49.17kHz conversion)',10,13
	dc.b	'Now playing ',0
info_text2	dc.b	' (',0
info_text3	dc.b	'kbit/sec)',10,13,0
error_file1	dc.b	'mp2.ttp <filename>',10,13
	dc.b	'Error: File "',0
error_file2	dc.b	'" not found.',10,13,0

	section	bss
fp	ds.w	1
bp	ds.l	1
old_sp	ds.l	1

nosync	ds.w	1
sblimit	ds.l	1
jsbound	ds.l	1
stereo	ds.l	1
frame_size	ds.l	1
bitrate	ds.l	1

stream_read 	ds.l	1
stream_bytes	ds.l	1
filename	ds.l	1

* Mute parameters
mute	ds.w	1
ltatten	ds.w	1
rtatten	ds.w	1
ltgain	ds.w	1
rtgain	ds.w	1

buffer	ds.b	32

command_copy	ds.b	256
buffer1	ds.b	BUFFER_SIZE
buffer2	ds.b	BUFFER_SIZE
	end


