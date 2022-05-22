;This CODE DOES run far better, but maybe is a teeny bit Buggy....
	opt	O+
	include	E:\yama\macro.s
DATA	equ	55		;timer fine tune..
MODE	equ	6		;1=4,2=10,3=16,4=50,5=64,6=100,7=200
timerA	equ	$134		;the smaller the subdiv the faster.
iea	equ	$fffffa07	;enable
ima	equ	$fffffa13	;mask   (1 = ON)
acon	equ	$fffffa19	;A control clr.b = RESET, else 1-7 Subdiv
adat	equ	$fffffa1f	;A data
vbs	equ	$fffffa17	;Vector Base..??!!
;##############################################
Delta 	macro
;a0 points to DATA,d0,d1 destroyed, a0 updated!	Returns Ticks in d0.l
	moveq.l	#0,d0		;long clear of D0
	move.b	(a0)+,d0	;get first (?only) byte
	bge.s	dun\@		;only was one byte!
	bclr	#7,d0		;clear it!
	lsl.w	#7,d0		;shift up seven bits!
	move.b	(a0)+,d1	;get second byte..
	bge.s	last\@
	bclr	#7,d1
	or.b	d1,d0
	lsl.l	#7,d0
	move.b	(a0)+,d1	;get third byte..
	bge.s	last\@
	bclr	#7,d1
	or.b	d1,d0
	lsl.l	#7,d0
	move.b	(a0)+,d1	;get Last byte..
last\@	or.b	d1,d0
dun\@	
	endm
;##############################################
	super_on
	lea	file(pc),a0	;the buffer!
	move.l	(a0)+,d0
	cmp.l	#"MThd",d0	;is it the header
	bne	finitos
	move.l	(a0)+,a1	;Size of Header (6) of following data!
	add.l	a0,a1		;a1 points to next Track!
	move.l	(a0)+,d7	;no. of tracks (should be 7 here!) Version in upper word..
	subq.l	#1,d7
	move.w	d7,trkcnt	;for DBras!!
	move.w	d7,cntdwn	;for loop!!
	move.w	(a0)+,d6
	move.w	d6,divt+2	;division info!  = ticks/Crotchet!
;	asr.w	#3,d6		
;	move.w	d6,Frame	;For sending Clock to External!
;	move.w	d6,Oframe	;For Restoring it!
	lea	ptrs(pc),a2	;Store the pointers!
	lea	Vtrs(pc),a3
setptr:	move.b	(a1)+,d0	;Check for Authenticity!
	lsl.w	#8,d0
	move.b	(a1)+,d0
	swap	d0
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	cmp.l	#"MTrk",d0	;Is it a track?! It should be..
	bne	finitos		
	move.b	(a1)+,d0	;Get Next Track OFFSET!
	lsl.w	#8,d0
	move.b	(a1)+,d0
	swap	d0
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	move.l	a1,(a2)+	;store this address!
	move.l	a1,(a3)+
	add.l	d0,a1
	dbra	d7,setptr
;##### Now We have a full list of all the track pointers in ptrs!
;Now to set up the first load of tick values!
	move.w	trkcnt(pc),d7	;count them through!
	lea	ptrs(pc),a1	;the source address
	lea	Vtrs(pc),a4	;the source address
	lea	deltas(pc),a2	;the object address
	lea	Veltas(pc),a3	;the object address
stklp:	move.l	(a1),a0
	Delta			;get the first set of times!
	addq.l	#$1,d0		;Add a little pause to all.. (1 crotchet)
 	move.l	a0,(a1)+	;save the new address!
 	move.l	a0,(a4)+	;save the new address!
	move.l	d0,(a2)+	;Save the delta time
	move.l	d0,(a3)+
	dbra	d7,stklp	;Now all the deltas have been set up!
;################################################
	move	#$2700,SR
	move.b  iea.w,sa1+3
	move.b	ima.w,sa2+3
	move.b	acon.w,sa3+3
	move.b	adat.w,sa4+3
	move.l	timerA.w,ota
	move.l	#myta,timerA.w
	bclr    #3,vbs.w
	or.b	#$20,iea.w
	or.b	#$20,ima.w	;enable interrupt A
	move.b	#DATA,adat.w
	move.b	#MODE,acon.w	;Default values!!
	move	#$2300,SR

main:	move.w	#7000,d0
mlp:	dbra	d0,mlp
	cmpi	#57,$fffffc02.w	;keyboard.. Space!
	bge.s	finitos
	bra.s	main

;################################################
finitos:
	moveq	#15,d0
	move.b	#$B0,d1
	lea	$fffffc04.w,a3	;Midi port
alloff:				;All notes off, for each channel!
w1:	btst	#1,(a3)		;Ready to take it  ?!
	beq.s	w1
	move.b	d1,2(a3)	;Load up next byte !!
w2:	btst	#1,(a3)		;Ready to take it  ?!
	beq.s	w2
	move.b	#123,2(a3)	;Load up next byte !!
w3:	btst	#1,(a3)		;Ready to take it  ?!
	beq.s	w3
	clr.b	2(a3)		;Load up next byte !!
	addq	#1,d1
	dbra	d0,alloff
	move	#$2700,SR
	move.l	ota(pc),TimerA.w
	bclr.b	#5,iea.w
	bclr.b	#5,ima.w
sa1	move.b  #2,iea.w
sa2	move.b	#2,ima.w
sa3	move.b	#2,acon.w
sa4	move.b	#2,adat.w
	move	#$2300,SR
	super_off
	exit
;##################################################################
;Input: a0 points to Data pos., a1 points to ptr table, a2 points to Deltas!
;A0 must be updated, A1,A2 must be preserved. 
;D7 holds current track no. and also must be kept!
;New delta time must be put into D0
;Currently, only a few Meta-Events are supported..
;##################################################################
ft:	dc.b	-1,1,2,1,0,0,0,0	;System Common Instructions
	dc.b	0,0,0,0,0,0,0,-2	;System Real Time stuff..
dt:	dc.b	2,2,2,2,1,1,2,0		;no. of bytes-1 for each type 
;               8 9 A B C D E F		;of MIDI Event (Except $Fx)
;##################################################################
detrk:	addq.l	#4,a2			;miss out this track!
nextrk:	dbra	d7,dodels
	movem.l	(sp)+,d0/d1/d7/a0-a3
	move.w	#$000,$ffff8240.w
	RTE
;##################################################################
myta:	move.w	#$700,$ffff8240.w
	movem.l	d0/d1/d7/a0-a3,-(sp)
	lea	$fffffc04.w,a3	;Midi port
;	subq	#1,Frame	;If want to send external Clock!
;	bgt.s	notim
;Tax:	btst	#1,(a3)		;Ready to take it ?!
;	beq.s	tax
;	move.b	#$F8,2(a3)	;Load up $F8 (Timer!)
;	move.w	Oframe,Frame
notim:	move.w	trkcnt(pc),d7	;No. of tracks!
	lea	deltas(pc),a2	;Current Delta times for each track
	lea	ptrs(pc),a1	;list of track pointers..
dodels:	move.l	(a1)+,a0	;Get next track
	blt.s	detrk		;-ve = This is finitos!! Dead!!
	subq.l	#1,(a2)+	;-1 from a2.. Count down..
	bne.s	nextrk		;Not finished counting yet!
agin:	moveq.l	#$70,d0		;set up mask (mask out high bit too..)
	and.b	(a0),d0		;get the type! -Byte 1
	lsr.b	#4,d0		;Shift nybble for jump table
	move.b	dt(pc,d0.w),d0	;Get no. of bytes to shove out -1
	bne	wait		;It's not an 'F' instruction!
	moveq.l	#$0f,d0
	and.b	(a0),d0
	move.b	ft(pc,d0.w),d0
	bge	wait		;If it don' jump, it's either Sysex, or META
	addq.l	#1,d0		;is it SysEx?
	beq.s	sysex
	addq.l	#1,a0
	move.b	(a0)+,d0	;Get meta Event type!
	move.b	(a0)+,d1	;No. of Data bytes to follow..
	cmp.b	#$2f,d0		;End of track?!
	beq.s	endtrk
	cmp.b	#$51,d0		;Tempo declaration?!
	beq.s	setemp
	ext.w	d1
	add.w	d1,a0		;skip it altogether!
	bra	dodel		;hee hee
setemp:	clr.w	d0		;Only these two are used!
	move.b	(a0)+,d0	;'Cos there is only sound output
	swap	d0		;and no Text (as Yet.)
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	move.l	d0,Tempo	;reset the tempo (here?!)
	move.l	a0,-(sp)
	lea	firstt(pc),a0
	move.w	#lastt-firstt,d1
divt:	divu	#$00C0,d0	;By value of Clicks/Crotchet!
	cmp.w	(a0),d0
	ble.s	out1		;d0 < (A0)
	cmp.w	(a0,d1.w),d0
	bge.s	out2		;d0 > (a0+d1)
tlpo:	asr.w	#1,d1		;Divide by 2
	and.w	#$fffc,d1	;Next point? (Long)
	beq.s	out1
	cmp.w	(a0,d1.w),d0
	beq.s	out2
	blt.s	tlpo
	add.w	d1,a0
	bra.s	tlpo
out2:	add.w	d1,a0
out1:	move.b	3(a0),adat.w
	move.b	2(a0),acon.w	
	move.l	(sp)+,a0
	bra.s	dodel
endtrk:	move.w	#-1,a0		;back to start of this!
	move.l	#$7fffffff,d0	;Large delta time!
	subq.w	#1,cntdwn
	ble	rst
	bra.s	loadm
sysex:	btst	#1,(a3)		;Ready to take it ?!
	beq.s	sysex
	move.b	(a0)+,2(a3)	;Load up $F0
	bra.s	sxin
sxlp:	btst	#1,(a3)		;Ready to take it ?!
	beq.s	sxlp
	move.b	(a0)+,2(a3)	;Load up next byte !!
sxin:	move.b	(a0),d0
	cmp.b	#$F7,d0
	bne.s	sxlp
	moveq.l	#0,d0
	
wait:	btst	#1,(a3)		;Ready to take it  ?!
	beq.s	wait
	move.w	#$077,$ffff8240.w
	move.b	(a0)+,2(a3)	;Load up next byte !!
	dbra	d0,wait
	move.w	#$700,$ffff8240.w
dodel:	Delta			;Set up next Delta!
	tst.l	d0		;Is Time = Zero ? If so,
	beq	agin		;do next event Now!
loadm:	move.l	a0,-4(a1)
	move.l	d0,-4(a2)
	dbra	d7,dodels
	movem.l	(sp)+,d0/d1/d7/a0-a3
	move.w	#$000,$ffff8240.w
	RTE
;##################################################################
rst:	move.w	trkcnt(pc),d1
	move.w	d1,cntdwn
	lea	Vtrs(pc),a0
	lea	Ptrs(pc),a1
	lea	Veltas(pc),a2
	lea	deltas(pc),a3
rstlp:	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	dbra	d1,rstlp
	movem.l	(sp)+,d0/d1/d7/a0-a3
	move.w	#$000,$ffff8240.w
	RTE
;##################################################################
	DATA
	EVEN
ota:	ds.l	1
Tempo:	ds.l	1
Frame:	ds.w	1
Oframe: ds.w	1
trkcnt:	ds.w	1
cntdwn:	ds.w	1
ptrs:	ds.l	16	;Enough for 16 tracks !!
Vtrs:	ds.l	16	;Enough for 16 tracks !!
Veltas:	ds.l	16	;for loops!!
deltas:	ds.l	16	;Enough for 16 tracks !!
firstt: incbin  E:\yama\tempo.dat
lastt:			;Used for binary Chop!
file:	incbin	E:\yama\skisundy.mid