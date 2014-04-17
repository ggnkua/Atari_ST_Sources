;GDOS_TST- GDOS test returns in D0 whatever GDOS returns :-)
; _FSM for FSMGDOS

	.globl	    gdos_tst

	.text

gdos_tst: move.w #-2, d0
	  trap #2
	  rts

	.end
