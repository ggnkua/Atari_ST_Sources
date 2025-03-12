;HI FOLKS, HERE IS A LITTLE TRAP #1 LOAD DEPACKING SOURCE TO
;BE USED WITH THE POMPEY PUFFS PACKER V1.5
;IT IS NOTHING SPECIAL. IT IS UP TO YOU TO WRITE BETTER ONES
;OTHERWISE YOU SHOULD BE GIVING US CREDIT FOR THE CODE
;ALL THIS WILL DO IS ENABLE STRAIGHT FORWARD OPEN-READALL-CLOSE
;TYPE OF GEMDOS FILELOAD PROGRAMS TO WORK IN FULLY DEPACKED FORM

;SOME QUICK NOTES ABOUT THE PACKER
;EXEC IS FOR PROGRAM/TOS FILES (IN OTHER WORDS EXECUTABLE FILES)
;DATA IS FOR ALL OTHER FILES AND WILL NEED A TRAP #1 DEPACKER SUCH AS
; THIS ONE TO BE ABLE TO DEPACK THEM BACK TO FULL SIZE WHILST LOADING
; KILL/KEEP  KILL WILL PACK A FILE AND OVERWRITE THAT FILE WHEREAS KEEP
; WILL PACK IT AND CREATE ANOTHER FILE WITH A .POP EXTENDER
; ALL OTHER FUNCTIONS ARE USED IN THE SAME WAY AS OUR PACKERS SO
; THERE IS LITTLE POINT IN SAYING ANY MORE. IF YOU CAN USE ONE PACKER
; THEN YOU CAN SURELY USE THIS ONE
; TOUGH SHIT POMPEI PUFFS AND THANKS TO JPM AND MOB

		opt c+,d-

	
	MOVEA.L	4(A7),A5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	lea $c(a7),a7
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	MOVE.L D0,2(A7)
	MOVE.L	$84.w,old84	;SAVE OLD TRAP 1 ADDRESS
	MOVE.L	#new84,$84.w	;SET UP NEW TRAP 1 ADDRESS
	TRAP	#$01
	ADDQ.L	#6,A7
	clr.w -(sp)
	pea $ffffffff
	move.l (a7),-(sp)
	move.w #5,-(sp)
	trap #14
	lea $c(a7),a7
	pea text	;PUT YOUR SHIT HERE
	move.w #9,-(sp)
	trap #1
	pea jamf
	move.l (a7),-(sp)
	move.l #gam,-(sp)	;SELECT PROG TO EXECUTE FIRST
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
	clr.w -(sp)
	trap #1
jamf	DC.L	0

new84		movem.l	a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	alien_is
		move.l 	usp,a1
alien_is	cmpi.w 	#$3F,(a1)
		bEQ.s 	read
a_prick		movem.l 	reg,a0-a6/d0-d7
		dc.w 	$4ef9
old84		dc.l 	$0
memadd		dc.l 	$0
read		move.l 	$8(a1),memadd	;store address that file is loading to
		move.l $2(a7),exit3f	;make return address
		move.l #domore,$2(a7)	;now change return address so we can depack before really returning back to main program
		bra.s a_prick
reg		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
realsize	dc.l 0
domore		movem.l d0-d7/a0-a6,-(sp)
		move.l d0,realsize	;d0 now contains actual size of datafile just read
					;d0 will be changed if the file just read is packed
		pea pompey_puffs
		move.w #$26,-(sp)	
		trap #14	;use supervisor mode (not necessary if you do not want to flash colors)
		addq.l #6,sp
		movem.l (a7)+,d0-d7/a0-a6
		move.l realsize,d0	;return with file size in d0
		dc.w $4ef9	;hex code for JMP instruction
exit3f		dc.l 0
pompey_puffs
		move.l memadd,a4
		add.l realsize,a4	;pointer now at file end
		move.l a4,a2
		subq.l #4,a4
		move.b (a4),d0		;using bytes in case of odd addressing
		rol.l #8,d0
		move.b 1(a4),d0
		rol.l #8,d0
		move.b 2(a4),d0
		rol.l #8,d0
		move.b 3(a4),d0		
		cmp.l #$50554646,d0	;check header (PUFF) to see if flie is packed
		bne ret
		move.l a4,a0
		move.l -(a0),d6		;d6 = realsize
		move.l d6,realsize  	;change realsize as this file is packed
		move.l -(a0),d2		;d2 = packed size
		sub.l d2,a2
		move.l a2,a4
		add.l d6,a2
		moveq.l #0,d0
		lea $ffff8240.w,a6
		move.w (a6),d7
puffs0		move.b -(a0),d0
		beq.s puffs0
puffs1		moveq.l #0,d2
		cmpa.l a2,a0
		bgt ret
		bsr puffs15
		bcs.s puffs4
		move.b -(a0),d2
puffs2		move.b d2,-(a2)
		bra.s puffs6
puffs3		moveq.l #15,d4
		moveq.l #2,d3
		bsr puffs18
		bne puffs13
		move.w d4,d2
		bra.s puffs2
puffs4		bsr puffs15
		bcc puffs9
		bsr puffs15
		bcc puffs3
		bsr puffs15
		bcs puffs5
		moveq.l #2,d1
		bsr puffs22
		exg d1,d2
		addq.w #1,d2
		bset d1,d2
		bra puffs2
puffs5		bsr puffs15
		bcs.s puffs8
		moveq.l #15,d4
		moveq.w #3,d3
		bsr.s puffs18
		bne.s puffs13
		move.b (a2),-(a2)
puffs6		neg.w (a6)	;play around with blah.w,(a6) for colour flashing effects
		move.w d7,(a6)	;d7 is restoring default colour
		cmpa.l a2,a4
		blt puffs1
puffs7		rts
puffs8		moveq.l #4,d3
		bra.s puffs12
puffs9		bsr puffs15
		bcs puffs27
		moveq.l #1,d1
puffs10		lsr.b #1,d0
		bne.s puffs11
		move.b -(a0),d0
		roxr.b #1,d0
puffs11		addx.w d2,d2
		dbf d1,puffs10
		move.w d2,d1
		beq puffs26
		addq.w #1,d1
		add.w d1,d1
		subq.w #1,d1
		bsr puffs22
		move.w d2,d3
puffs12		bsr.s puffs17
puffs13		movea.l a2,a1
		adda.l d2,a1
puffs14		move.b -(a1),-(a2)
		dbf d3,puffs14
		bra puffs6
puffs15		lsr.b #1,d0
		bne.s puffs16
		move.b -(a0),d0
		roxr.b #1,d0
puffs16		rts
puffs17		moveq.l #0,d4
puffs18		moveq.l #1,d1
		moveq.l #0,d2
puffs19		lsr.b #1,d0
		bne.s thanks_jpm
puffs20		move.b -(a0),d0
		roxr.b #1,d0
thanks_jpm
		addx.w d2,d2
		dbf d1,puffs19
		move.w d2,d1
		addq.w #1,d1
		lsl.w #2,d1
		subq.w #1,d1
		eor.b d1,d4
		bne.s puffs22
		rts
puffs21		moveq.l #7,d1
puffs22		moveq.l #0,d2
puffs23		lsr.b #1,d0
		bne.s puffs25
puffs24		move.b -(a0),d0
		roxr.b #1,d0
puffs25		addx.w d2,d2
		dbf d1,puffs23
		rts
puffs26		bsr puffs17
		move.w d2,d3
		moveq.l #1,d2
		bra puffs13
puffs27		moveq.l #1,d3
		move.b -(a0),d2
		bra puffs13 

ret		rts			
gam		dc.b "gamename.prg",0
text		dc.b "WHOEVER PRESENTS . . .",13,10
		dc.b "WHICHEVER GAME",0