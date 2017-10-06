; Adapte ST/STE
	move.l $8,d1
	move.l #Ste,$8
	move.l sp,d2
	move.w $FC0002,d0
FinSte:	move.l d2,sp
	move.l d1,$8
          lea adapt(pc),a0
          moveq #NbAdapt-1,d1
adapt1:   cmp.w (a0)+,d0
          beq.s adapt2
          add.w #28,a0
          dbra d1,adapt1
          lea adapt+2(pc),a0        ;par defaut: ROM du mega ST
adapt2:   lea adapt+2(pc),a2
          moveq #6,d0
adapt3:   move.l (a0)+,(a2)+    ;recopie en ADAPT+2
          dbra d0,adapt3
; Fausse trappe FLOAT en trappe 6
          move.l #FauxFloat,d0
          move.l d0,$98
          rts
; Erreur de bus si sur STE
Ste:	move.w $E00002,d0
	bra.s FinSte
