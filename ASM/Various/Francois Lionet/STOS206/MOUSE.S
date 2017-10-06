

******************************************************************************
*	Mouse interrupts in Stos
******************************************************************************
*	The mouse interrupt used by Stos DO NOT CHANGE ANYTHING IN THE
*	KEY BOARD PROCESSOR! The routine just replace the normal routine
*	that exploit the coordinates entered by the system. The vector
*	for this routine changes from Tos to Tos. The address are:


*	The routine I use, is copied from the system routine. It does 
*	exactly the same job! SO I don't think the problem comes from this
*	small routine!
*****************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Entree des interruptions souris 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sourint:  move.w d0,-(sp)
          move.w d1,-(sp)
          move.w d2,-(sp)
          move.l a1,-(sp)
          move.b (a0),d0
          move.b d0,d1
          and.b #$f8,d1
          cmp.b #$f8,d1
          bne sourint10
          move.l admouse(pc),a1      ;Address of mouse coordinates for this version
          and.w #$3,d0
          lsr.b #1,d0
          bcc.s sourint1
          bset #1,d0
sourint1: move.b 254(a1),d1 
          and.w #$3,d1
          cmp.b d1,d0
          beq.s sourint2
          move.w d0,6(a1)
          eor.b d0,d1
          ror.b #2,d1
          or.b d1,d0
          move.b d0,254(a1)
sourint2: move.b 1(a0),d0
          or.b 2(a0),d0
          bne.s sourint3
          bclr #5,254(a1)
          bra.s sourint10
sourint3: bset #5,254(a1)
          move.w (a1),d0
          move.b 1(a0),d1
          ext.w d1
          add.w d1,d0
          move.w 2(a1),d1
          move.b 2(a0),d2
          ext.w d2
          add.w d2,d1
; Test for limits!
          tst.w d0
          bge.s sourint4
          clr.w d0
          bra.s sourint5
sourint4: cmp.w mxmouse(pc),d0
          ble.s sourint5
          move.w mxmouse(pc),d0
sourint5: tst.w d1
          bge.s sourint6
          clr.w d1
          bra sourint7
sourint6: cmp.w mymouse(pc),d1
          ble.s sourint7
          move.w mymouse(pc),d1
; End of routine. Pokes new coordinates...
sourint7: move.w d0,(a1)
          move.w d1,2(a1)
sourint10:move.l (sp)+,a1
          move.w (sp)+,d2
          move.w (sp)+,d1
          move.w (sp)+,d0
          rts
