; This is an example of how to play a song from MUZEXX MAKER.

	opt	d+	This is to help you debug
	
; We need to be in supervisor mode to install the music interrupt
; address into a protected area
	clr	-(sp)	go into SUPERVISOR mode
	move	#32,-(sp)	
	trap	#1	
	addq	#6,sp	
	move.l	d0,save_stk
	
; <Minuse> is bit map of music channels of the form xxxxxABC
; 1=on, 0=off 
; For the sake of example we shall install the interrupt into the VBL queue.
; It can be placed in a timer register or the actual IPL 5. 
; NB. The music interrupt is terminated with RTS not RTE and needs to be
; changed if placed in the Exception vector table.
	
	move.b	#0,Minuse	Turn all music channels off
	move.l	$456,a0	Get @ of VBL queue
repeat
	move.l	(a0)+,d0	If @ is 0 then install @
	cmp.l	#Minterrupt,d0	
	beq	install
	tst	d0
	bne	repeat
install	
	sub	#4,a0
	move.l	#Minterrupt,(a0)
	move.l	a0,vector	save @ of place in VBL queue
	
	move.l	#song,a0	this is our song start address
	jsr	Mplayer	place in a0 and call this routine
	
; MUSIC STARTS NOW - Mplayer has set <Minuse> bits. If you clear one 
; you will stop a channel.
	move	#2,-(sp)	wait for a key press
	move	#2,-(sp)
	trap	#13
	addq	#4,sp
	
	move.l	vector,a0	leave VBL queue as found
	move.l	#0,(a0)
	
	move.l	save_stk,-(sp)
	move	#32,-(sp)	USER mode
	trap	#1
	addq	#6,sp
	
	move	#0,-(sp)	terminate
	trap	#1

; -----------------------------------------------------
; This is the routine to include
Mplayer	include	"a:musicmod.s"
; ^ or whatever you wish to refer to it as.
	
	SECTION 	DATA
	
	even
save_stk	dc.l	0	for storing super stack
vector	dc.l	0	the VBL queue address we used

; This is the song we want to play:
song	incbin	"a:mad_max.mdt"

