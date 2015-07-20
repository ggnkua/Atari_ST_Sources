;
; How many Floppy drives connected ??
; -----------------------------------
; 
; Coded by: Mike Mee
;
; v1.0 - 15/10/1991 for PVK v2.1

	opt	p+

buffcode	bra.s	start
	dc.b	"Coded by: Mike Mee - 15/10/1991",0
	
start	lea	oldpal(pc),a2
	move.w	$ff8240,(a2)+	; store palette
	move.w	$ff825e,(a2)+
	move.w	#$007,$ff8240
	move.w	#$777,$ff825e
  
text	lea	message(pc),a0	; Intro Message
	bsr.s	print

no_flops	lea	$4a6,a1	; Check 'no_flops' system variable
	cmpi.w	#0,(a1)
	beq.s	drivesnil
	cmpi.w	#1,(a1)
	beq.s	drives1
	cmpi.w	#2,(a1)
	beq.s	drives2

exit	
	lea	linefeed(pc),a0	; put cursor down 3 lines
	bsr.s	print

	move.l	#$50000,d1	; slight pause
pause	subq.l	#1,d1 
	bne.s	pause

	lea	oldpal(pc),a2
	move.w	(a2)+,$ff8240
	move.w	(a2)+,$ff825e
	rts

drivesnil	lea	drvmes1(pc),a0	; No drives connected ?????
	bsr.s	print
	bra.s	exit

drives1	lea	drvmes2(pc),a0	; 1 drive connected
	bsr.s	print
	bra.s	exit

drives2	lea	drvmes3(pc),a0	; 2 drives connected
	bsr.s	print
	bra.s	exit

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

message	dc.b 27,69
	dc.b 27,89,32,38,"Installed with: PVK",191," v2.1"
	dc.b 27,89,34,36,"Floppy Drives Connected : ",0
drvmes1	dc.b "None",0
drvmes2	dc.b "One",0
drvmes3	dc.b "Two",0
linefeed	dc.b 13,10,10,10,0
	even

oldpal	ds.w	2
blanks	ds.w	115
