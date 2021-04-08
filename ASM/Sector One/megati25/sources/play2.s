*********************************************************************
* When the "2 CALLS/VBL" option is enabled, the file is created for *
*  being called two times per VBL. You must do it all by yourself.  *
* Here are three ways to do it: - Using the timer B ( 100th line )  *
*                               - Using the timer D                 *
*                               - Waiting for the good time         *
* This source uses the timer D, a good solution as it allows you to *
*      use the others interrupts without disturbing those ones.     *
*  Coding, as always, by Jedi of Sector One from The Heavy Killers. *
*********************************************************************


	clr.l -(sp)		
	move #$20,-(sp)
	trap #1				Supervisor mode
	move.l d0,2(sp)			Save the old stack
	
	bsr music			Initialize the music
	
	lea saves(pc),a0		Buffer where old datas will be in
	move.l $110.w,(a0)+		Timer D vector
	move.l $fffffa06.w,(a0)+	Interrupt enable A & B
	move.l $fffffa12.w,(a0)+	Interrupt mask A & B
	move.b $fffffa1d.w,(a0)+	Timer C & D control
	move.b $fffffa25.w,(a0)+	Timer D data
	move.b $fffffa17.w,(a0)		Vector
	
	move #$2700,sr			Stop all interrupts
	move.l #rout,$110.w		Our own timer D routine
	or.l #$200010,$fffffa06.w	IERA
	or.l #$200010,$fffffa12.w	IMRA
	andi.b #$f0,$fffffa1d.w		TCDCR
	move.b #123,$fffffa25.w		TDDR	
	or.b #7,$fffffa1d.w		TCDCR
	bclr #3,$fffffa17.w		VR
	move #$2300,sr			Enable all interrupts
	
wait	cmpi.b #$39,$fffffc02.w		Wait for the space key
	bne.s wait
	
	move #$2700,sr			Stop all interrupts
	bsr.s music+4			Current noises off
	
	lea saves(pc),a0	
	move.l (a0)+,$110.w
	move.l (a0)+,$fffffa06.w
	move.l (a0)+,$fffffa12.w	Restore interrupts
	move.b (a0)+,$fffffa1d.w
	move.b (a0)+,$fffffa25.w
	move.b (a0),$fffffa17.w
	move.b #15,$484.w		Click !!!
	move #$2300,sr			Enable all interrupts
	
	trap #1				User mode
	addq.l #4,sp			
	clr (sp)			Back to the desktop
	trap #1

rout	bsr.s music+8			Play
	rte 

saves	ds.l 4				Old datas

music	incbin *.thk			Music