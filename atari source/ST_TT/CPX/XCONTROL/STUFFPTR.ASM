*	Assembly language module to handle Saving and Restoring
*	the mouse mask.
*
*	03/07/90 - cjg   - Added Line-A code to force mouse to redraw
*			   at the next VBLANK
*
        .globl  linea_init
	.globl  MSKsave
	.globl  MSKrst

*	IN: TRUE-FALSE in D0    Used to store mouse in a second location	
*				during an alert box. This way, we don't
*				destroy the saved mask in case we need to
*				save it a second time.

*
*	Line A init code 
*
*
	.text

linea_init:  dc.w $a000
	     move.l a0,linea_var
	     rts

MSKsave:
	 movem.l  a1-a5/d1-d5,-(sp)
         move.w	  #36, d1			;37 items, but count from 0
	 movea.l  linea_var, a0
         lea	  -$358(a0), a1

	 tst.w	  d0
	 beq.w	  .10
         lea	  mask0, a2         
	 bra.s	  .20
.10:     lea	  mask1, a2

.20:	 move.w   (a1)+,(a2)+
         dbra	  d1,.20
	 movem.l  (sp)+,a1-a5/d1-d5
         rts
         

MSKrst: 
	 movem.l  a1-a5/d1-d5,-(sp) 
	 move.w   #36, d1	; 37 items, but count from 0
	 movea.l  linea_var,a0
	 lea      -$358(a0),a2
	 tst.w	  d0
	 beq.w	  .10
	 lea	  mask0, a1
	 bra.s	  .20
.10:	 lea	  mask1, a1

.20:	 move.w	  (a1)+, (a2)+
	 dbra	  d1,.20

	 lea	  -$154(a0), a2
         ori.b	  #1,(a2)

         movem.l  (sp)+,a1-a5/d1-d5
	 rts
	

	.bss

mask0:  .ds.w   5
        .ds.w   32

mask1:  .ds.w	5
	.ds.w	32

linea_var: .ds.l 1

.end
