
;**************************************************************************
;*
;*      FAKE STOS VIRUS: Not dangerous!
;*
;**************************************************************************

;**************************************************************************

; Stos basic adaptation: NO NEW INSTRUCTIONS!
        	bra load
        	even
       	dc.b $80
tokens: 	dc.b 0
        	even
jumps:  	dc.w 0
        	even
welcome:	dc.b 0
        	dc.b 0
        	dc.b 0
        	even
table:  	dc.l 0
VBLCpt: 	dc.w 0
Physic: 	dc.l 0
PPhysic:	dc.w 0

**************************************************************************

********* Called after loading
load:   	lea finprg,a0
          lea cold,a1
          rts

********* Called on COLD start
Cold:     move.l a0,table
* Branch on VBL interrupts
 	move.w #50*60,VBLCpt	* Initialise start delay
	move.w #$2,-(sp)		* get PHYSIC address
	trap #14	
	addq.l #2,sp
	move.l d0,Physic		* Store for later
	clr.w PPhysic		* Counter	
	move.l $456,a0		* Find an empty space 
Cold1:	tst.l (a0)+		* in VBL table
	bne.s Cold1
	move.l #Bug,-4(a0)		* Branch!
          lea welcome,a0		* Returns stuff to interpretor
          lea warm,a1
          lea tokens,a2
          lea jumps,a3
warm:     rts 

********* Virus interrupt patch
Bug:	tst.w VBLCpt		* If counter >0
	bmi.s Bug1
	subq.w #1,VBLCpt		* Counts, and returns
	rts
Bug1:	move.w PPhysic(pc),d0	* Position of line to erase
	move.l Physic(pc),a0	* Address of screen
	lea 0(a0,d0.w),a0		
	moveq #160/4-1,d1		* 160 bytes to clear
Bug2:	clr.l (a0)+
	dbra d1,Bug2		
	add.w #160,d0		* Next line
	cmp.w #32000,d0		* Bottom of screen?
	bcs.s Bug3
	moveq #0,d0		* Yes-> back to top
Bug3:	move.w d0,PPhysic		* Store for next vbl
	rts			* Finished!

;************************************************************************
        dc.l 0
finprg: equ *



