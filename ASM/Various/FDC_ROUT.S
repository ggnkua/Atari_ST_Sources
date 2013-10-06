**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
restore	equ	0	reset drive to track zero
seek	equ	1	goto track
step	equ	2	move drive in last Direction
stepin	equ	3	track=track+1
stepout	equ	4	track=track-1
read	equ	5	read sector
write	equ	6	write sector
readid	equ	7	get ID fields ( NOT DONE )
readtrk	equ	8	read track
writetrk	equ	9


	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	move.l	d0,sp

	moveq	#1,d0			sector
	moveq	#2,d1			track
	moveq	#0,d2			side
	moveq	#0,d3			drive
	moveq	#1,d4			leave drive on
	moveq	#restore,d7		seek track zero
	lea	readbuff,a0
	bsr	RunFDC

	moveq	#seek,d7
	bsr	RunFDC

wrtrk	moveq	#writetrk,d7		write track
	moveq	#1,d4			leave drive on
	lea	sp_track,a0
*	bsr	RunFDC

trk	moveq	#readtrk,d7		read track
	moveq	#1,d4			leave drive on
	lea	readbuff,a0
	bsr	RunFDC

	moveq	#restore,d7		restore
	moveq	#0,d4			drive off
	bsr	RunFDC

	clr	-(sp)
	trap	#1
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
**  d0=sector
**  d1=track
**  d2=side
**  d3=drive
**  d4=turn drive off after operation (0=turn it off 1=leave it on)
**  d7=function number (replaced with 0(no error) or -1(timeout) )
**  a0=where to write/read data to/from

RunFDC:
	move	#1,$43E.w		lock dma
	movem.l	d0-6/a0-6,-(sp)
	lea	$FFFF8604.w,a1		data reg
	lea	$FFFF8606.w,a2		command reg
	lea	$FFFF8609.w,a3		address reg
	lea	$FFFFFA01.w,a4		mfp gpip
	lea	$FFFF8800.w,a5		sound chip

	bsr	Select_Drive

	lsl.l	#2,d7			function number times 4
	move.l	functiontable(pc,d7),a6
	jsr	(a6)

	tst	d4
	bne	notoff

	bsr	MotorOff
	move	#-1,d3
	bsr	Select_Drive

notoff	movem.l	(sp)+,d0-6/a0-6
	move	#0,$43E.w		unlock
	rts

functiontable
	dc.l	Restore			0	reset FDC seek track zero
	dc.l	Seek			1	goto previous track
	dc.l	Step			2	move drive in last Direction
	dc.l	StepIn			3	track=track+1
	dc.l	StepOut			4	track=track-1
	dc.l	Read			5	read sector
	dc.l	Write			6	write sector
	dc.l	ReadID			7	get ID fields ( NOT DONE )
	dc.l	ReadTrk			8	read track
	dc.l	WriteTrk		9

**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
**  d6 id used by wfeoc to signal a time out
**  -1 = time out  0 = ok
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
Restore	move	#$80,(a2)		select command register
	move	#$01,(a1)		do restore
	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
Seek	move	#$86,(a2)		select data register
	move	d1,(a1)		write track to it
	move	(a2),stat
	move	#$80,(a2)		select command register
	move	#$11,(a1)		perform seek
	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
Step	move	#$80,(a2)		select command register
	move	#$31,(a1)		perform step
	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
StepIn	move	#$80,(a2)		select command register
	move	#$51,(a1)		perform step in
	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
StepOut	move	#$80,(a2)		select command register
	move	#$71,(a1)		perform step out
	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
Read	move	#$84,(a2)		select sector register
	move	d0,(a1)		set sector

	pea	(a0)
	move.b	3(sp),4(a3)	lo byte first
	move.b	2(sp),2(a3)	middle byte secound
	move.b	1(sp),0(a3)	hi byte last
	addq	#4,sp

	move	#$90,(a2)		set dma to read status
	move	#$190,(a2)
	move	#$90,(a2)
	move	#1,(a1)		read one sector

	move	#$80,(a2)		select command register
	move	#$80,(a1)		read one sector

	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts

**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
Write	move	#$184,(a2)	select sector register
	move	d0,(a1)		set sector

	pea	(a0)
	move.b	3(sp),4(a3)	lo byte first
	move.b	2(sp),2(a3)	middle byte secound
	move.b	1(sp),0(a3)	hi byte last
	addq	#4,sp

	move	#$190,(a2)	set dma to write status
	move	#$90,(a2)
	move	#$190,(a2)
	move	#1,(a1)		write one sector

	move	#$180,(a2)	select command register
	move	#$a0,(a1)		write one sector

	bsr	wfeoc		wait for end of command
	move.l	d6,d7
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
ReadID	rts

*	pea	(a0)
*	move.b	3(sp),4(a3)	lo byte first
*	move.b	2(sp),2(a3)	middle byte secound
*	move.b	1(sp),0(a3)	hi byte last
*	addq	#4,sp

*	move	#$90,(a2)		set dma to read status
*	move	#$190,(a2)
*	move	#$90,(a2)
*	move	#1,(a1)		read one sector

*	move	#$80,(a2)		select command register
*	move	#$C0,(a1)		read id fields

*	bsr	wfeoc		wait for end of command
*	move.l	d6,d7
*	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
ReadTrk
	pea	(a0)
	move.b	3(sp),4(a3)	lo byte first
	move.b	2(sp),2(a3)	middle byte secound
	move.b	1(sp),0(a3)	hi byte last
	addq	#4,sp

	move	#$90,(a2)		set dma to read status
	move	#$190,(a2)
	move	#$90,(a2)
	move	#13,(a1)		read 512*13 bytes

	move	#$80,(a2)		select command register
	move	#$E0,(a1)		read track

	bsr	wfeoc		wait for end of command
	move.l	d6,d7

	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
WriteTrk
	pea	(a0)
	move.b	3(sp),4(a3)	lo byte first
	move.b	2(sp),2(a3)	middle byte secound
	move.b	1(sp),0(a3)	hi byte last
	addq	#4,sp

	move	#$190,(a2)	set dma to write status
	move	#$90,(a2)
	move	#$190,(a2)
	move	#13,(a1)		write 512*13 bytes

	move	#$180,(a2)	select command register
	move	#$F0,(a1)		read track

	bsr	wfeoc		wait for end of command
	move.l	d6,d7

	rts

**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
**	RunFDC subroutines (called internaly by the functions)
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
wfeoc	move.l	#2000000,d6	gives approx. 4 secounds

.wfeoc	subq.l	#1,d6
	beq	Timed_out
	nop
	nop
	btst	#5,(a4)
	bne.s	.wfeoc
	clr.l	d6
	rts
Timed_out
	moveq	#-1,d6
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
Select_Drive
	eor	#1,d2		flip side
	tst	d3
	bmi	Nodrive
	beq	DriveA
	move	#%0010,d3
	bra	Setd
DriveA	move	#%0100,d3
	bra	Setd
Nodrive	move	#%0110,d3
Setd	or	d2,d3
	move.b	#14,(a5)
	move.b	d3,2(a5)
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
MotorOff
	move	#$180,(a2)	select status reg
motson	move	(a1),d4
	tst.b	d4
	bmi.s	motson
	move	d4,stat
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
	section data
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


**--**--**--**	nine sector disk format  **--**--**--**
**  total lenght is 6969 bytes

track	dcb.b	60,$4e		track header

sector	set	1
	rept	9

	dcb.b	12,$00		pre-record
	dcb.b	03,$F5
	dc.b	$FE
	dc.b	79		track number
	dc.b	0		side
	dc.b	sector		sector
	dc.b	2		sector size
	dc.b	$F7
	dcb.b	22,$4E		post-record
	dcb.b	12,$00
	dcb.b	03,$F5
	dc.b	$FB		data address mark

	dcb.b	512,$12		the actual data

	dc.b	$F7
	dcb.b	40,$4E		end of sector

sector	set	sector+1
	endr

	dcb.b	1401,$4E		end of track
	even

**--**--**--**--**--**--**--**--**--**--**
sp_track
	dcb.b	60,$4E

	dcb.b	12,$00		you can't put anything here
			;	'cause it gets corrupted

	dcb.b	03,$F5
	dc.b	$FE
	dc.b	2		track number
	dc.b	0		side
	dc.b	1		sector
	dc.b	2		sector size
	dc.b	$F7

	dcb.b	22,$4E		post-record
	dcb.b	12,$00
	dc.b	"Jimy"		protection value
	dcb.b	03,$F5
	dc.b	$FB		data address mark

	dcb.b	512,$00		the actual data

	dc.b	$F7
	dcb.b	40,$4E		end of sector

sector	set	2
	rept	8

	dcb.b	12,$00			pre-record
	dcb.b	03,$F5
	dc.b	$FE
	dc.b	2			track number
	dc.b	0			side
	dc.b	sector			sector
	dc.b	2			sector size
	dc.b	$F7
	dcb.b	22,$4E			post-record
	dcb.b	12,$00
	dcb.b	03,$F5
	dc.b	$FB			data address mark

	dcb.b	512,$00			the actual data

	dc.b	$F7
	dcb.b	40,$4E			end of sector

sector	set	sector+1
	endr

	dcb.b	1401,$4E		end of track
	even

**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
	section bss
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
stat	ds.w	1
readbuff	ds.b	6656		for read track


