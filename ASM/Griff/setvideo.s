*
* SETVIDEO.S
*
*	@setvideo
*	 Save and set resolution.
* In	 d7.w=mode
*  modeequates: vertflag, stmodes, overscan, pal, vga, col80, bps1-16
* ex.	 move #pal+bps16,d7
*	 (xbios)
*
*	@restorevideo
*	 Restores the saved resolution.
*	 (xbios)
*
*	@setvadr
*	 Sets the physical and logical screenadress.
* In	 d0.l=screenadr.
*	 (xbios)
*
*	@savevadr
*	 Saves the current screenadr.
*	 (xbios)
*
*	@restorevadr
*	 Restores the saved screenadr.
*	 (xbios)
*


; SetVideo() equates.

vertflag	EQU $0100	; double-line on VGA, interlace on ST/TV ;
stmodes		EQU $0080	; ST compatible (uses the ff8240 colour registers);
overscan	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
pal		EQU $0020	; PAL if set, else NTSC ;
vga		EQU $0010	; VGA if set, else TV mode ;
col80		EQU $0008	; 80 column if set, else 40 column ;
bps16		EQU $0004	; True colour mode
bps8		EQU $0003	; 8 bitplanes ... etc.
bps4		EQU $0002
bps2		EQU $0001
bps1		EQU $0000

@setvideo	MOVE	#37,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP

		MOVE.W	#-1,-(SP)
		MOVE.W	#$58,-(SP)
		TRAP	#14
		ADDQ.L	#4,SP
		move	d0,save4856

		MOVE.W	d7,-(SP)
		MOVE.W	#$58,-(SP)
		TRAP	#14
		ADDQ.L	#4,SP
		rts
		
@restorevideo	MOVE.W	save4856,-(SP)
		MOVE.W	#$58,-(SP)
		TRAP	#14
		ADDQ.L	#4,SP
		rts
		
@savevadr	move	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,scradr7112
		rts
		
@restorevadr	move	#-1,-(sp)
		move.l	scradr7112,-(sp)
		move.l	scradr7112,-(sp)
		move	#5,-(sp)
		trap	#14
		lea	12(sp),sp		
		rts
		
@setvadr	move	#-1,-(sp)
		move.l	d0,-(sp)
		move.l	d0,-(sp)
		move	#5,-(sp)
		trap	#14
		lea	12(sp),sp		
		rts


		
save4856	ds.w	1
scradr7112	ds.l	1
