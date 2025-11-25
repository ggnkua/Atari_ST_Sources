
			export r_frac,to_real,e_frac,to_ext,to_single,s_frac
					
			mc68881
		
r_frac:		move.w	4(sp),d1		;REAL-Exponent	
			move.l	6(sp),d0		;REAL-Mantisse (nur die obersten 32 Bit)
			bra		weiter_1
			
e_frac:		lea		extpuf,a0
			fmove.x	fp0,(a0)
			move.w	(a0),d1			;EXTENDED-Exponent
			move.l	4(a0),d0		;EXTENDED-Mantisse (wie REAL nur verschoben)
weiter_1:	move.w	d1,d2
			bclr	#15,d2			;Vorzeichen lîschen
			sub.w	#16383,d2		;Offset vom Exponenten abziehen
			bpl     r_gross			;Poistiver Exponent -> Zahl zu groû
			neg		d2
            cmpi.w	#23,d2			;mehr als 23 Stellen zu Schieben ?
            bgt		r_klein			;dann ist Zahl zu nahe an 0
			addq.w	#8,d2			;Die ersten 8 Bit des LWORDS sind 0
			lsr.l	d2,d0			;Mantisse an die richtige Stelle schieben
			btst	#15,d1			;Vorzeichen prÅfen
			beq		r_exit
			eori.l	#$7fffff,d0		;negatives VZ --> Zweierkomplement bilden
			addq.l	#1,d0 			;Zahl invertieren und +1
			bset	#23,d0			;Vorzeichenbit setzen
r_exit:		rts
r_klein:	moveq	#0,d0			;Zahl=0
			rts
r_gross:	btst	#15,d1			;Zahl zu negativ oder zu positiv ?
			bne		n_rzg
			move.l	#$7fffff,d0		;grîûte positive Zahl (0.9999...)
			rts
n_rzg:		move.l	#$800000,d0		;grîûte negative Zahl (-1)
			rts

									
to_real:	movem.l	d3-d4,-(sp)
			clr.w	d4
			bra		weiter_2
			
to_ext:		movem.l	d3-d4,-(sp)
			move.w	#1,d4
			
weiter_2:	tst.l	d0				;Zahl =0 ?
			beq		rnull			
			cmpi.l	#$800000,d0		;Zahl =-1 ?
			beq		rm_1
			bclr	#23,d0			;Vorzeichen prÅfen und lîschen
			bne     rminus			;negative Zahl
			move.w	#22,d1
rloop_1:	btst	d1,d0			;erstes gesetztes Bit von links suchen		
			dbne	d1,rloop_1
    		move.w	#23,d2			;Exponent zusammenbasteln
			sub.w	d1,d2
			move.w	#16383,d3		;Offset addieren
			sub.w	d2,d3
			addq.w	#8,d2
    		lsl.l   d2,d0			;Mantisse schieben
			ori.w	#$1ff,d0		;restliche Bits der Mantisse setzen
			tst.w	d4
			beq		weiter_3
			lea		extpuf,a0
			move.w	d3,(a0)
			clr.w	2(a0)
			move.l	d0,4(a0)
			move.l	#-1,8(a0)
			fmove.x	(a0),fp0
			movem.l	(sp)+,d3-d4
			rts
weiter_3:   move.w	d3,(a0)+
			move.l	d0,(a0)+
			move.l  #-1,(a0)		;Die unteren 32 Bits der Mantisse
			movem.l	(sp)+,d3-d4
			rts

rminus:		subq.l	#1,d0			;Zweierkomplement rÅckgÑngig machen
			eori.l	#$7fffff,d0
    		move.w	#22,d1
rloop_2:	btst	d1,d0			;Rest siehe oben		
			dbne	d1,rloop_2
    		move.w	#23,d2			;Exponent zusammenbasteln
			sub.w	d1,d2
			move.w	#16383,d3
			sub.w	d2,d3
			addq.w	#8,d2
    		lsl.l   d2,d0			;Mantisse schieben
			ori.w	#$1ff,d0		;restliche Bits der Mantisse setzen
    		bset	#15,d3
			tst.w	d4
			beq		weiter_4
			lea		extpuf,a0
			move.w	d3,(a0)
			clr.w	2(a0)
			move.l	d0,4(a0)
			move.l	#-1,8(a0)
			fmove.x	(a0),fp0
			movem.l	(sp)+,d3-d4
			rts
weiter_4:   move.w	d3,(a0)+
			move.l	d0,(a0)+
			move.l  #-1,(a0)		;Die unteren 32 Bits der Mantisse
			movem.l	(sp)+,d3-d4
			rts            
						
rnull:		tst.w	d4
			beq		weiter_5
			fmovecr	#$F,fp0
			movem.l	(sp)+,d3-d4
			rts
			
weiter_5:	clr.w	(a0)+
			clr.l	(a0)+
			clr.l	(a0)
			movem.l	(sp)+,d3-d4
			rts
			
rm_1:		tst.w	d4
			beq		weiter_6
			fmove.w	#-1,fp0
			movem.l	(sp)+,d3-d4
			rts
			
weiter_6:	move.w	#$bfff,(a0)+
			move.l	#$80000000,(a0)+
			clr.l	(a0)
			movem.l	(sp)+,d3-d4
			rts

s_frac:		move.l	4(sp),d0		;Single-Zahl
			move.l	d0,d1
			swap	d1
			lsr.w	#7,d1			;Exponent
			andi.l	#$7fffff,d0		;Mantisse
			bset	#23,d0			;fÅhrende 1 setzen
			move.w	d1,d2
			bclr    #8,d2			;Vorzeichen lîschen
			sub.w	#127,d2			;Offset vom Exponenten abziehen
			bpl     s_gross			;Poistiver Exponent -> Zahl zu groû
			neg		d2
            cmpi.w	#23,d2			;mehr als 23 Stellen zu Schieben ?
            bgt		s_klein			;dann ist Zahl zu nahe an 0
			lsr.l	d2,d0			;Mantisse an die richtige Stelle schieben
			btst	#8,d1			;Vorzeichen prÅfen
			beq		s_exit
			eori.l	#$7fffff,d0		;negatives VZ --> Zweierkomplement bilden
			addq.l	#1,d0 			;Zahl invertieren und +1
			bset	#23,d0			;Vorzeichenbit setzen
s_exit:		rts
s_klein:	moveq	#0,d0			;Zahl=0
			rts
s_gross:	btst	#8,d1			;Zahl zu negativ oder zu positiv ?
			bne		n_szg
			move.l	#$7fffff,d0		;grîûte positive Zahl (0.9999...)
			rts
n_szg:		move.l	#$800000,d0		;grîûte negative Zahl (-1)
			rts

									
to_single:	move.l	d3,-(sp)
        	tst.l	d0				;Zahl =0 ?
			beq		snull			
			cmpi.l	#$800000,d0		;Zahl =-1 ?
			beq		sm_1
			bclr	#23,d0			;Vorzeichen prÅfen und lîschen
			bne     sminus			;negative Zahl
			move.w	#22,d1
sloop_1:	btst	d1,d0			;erstes gesetztes Bit von links suchen		
			dbne	d1,sloop_1
    		moveq	#0,d3
    		move.w	#23,d2			;Exponent zusammenbasteln
			sub.w	d1,d2
			move.w	#127,d3			;Offset addieren
			sub.w	d2,d3
    		lsl.l   d2,d0			;Mantisse schieben
    		bclr	#23,d0			;fÅhrende 1 lîschen
    		lsl.w	#7,d3
    		swap	d3
    		or.l	d3,d0
			move.l	d0,(a0)
			move.l	(sp)+,d3
			rts

sminus:		subq.l	#1,d0			;Zweierkomplement rÅckgÑngig machen
			eori.l	#$7fffff,d0
    		move.w	#22,d1
sloop_2:	btst	d1,d0			;Rest siehe oben		
			dbne	d1,sloop_2
    		moveq	#0,d3
    		move.w	#23,d2			;Exponent zusammenbasteln
			sub.w	d1,d2
			move.w	#127,d3
			sub.w	d2,d3
    		lsl.l   d2,d0			;Mantisse schieben
    		bclr	#23,d0			;fÅhrende 1 lîschen
    		bset	#8,d3			;Vorzeichen
			lsl.w	#7,d3
			swap	d3
			or.l	d3,d0
			move.l	d0,(a0)
			move.l	(sp)+,d3
			rts            
						
snull:		clr.l	(a0)
			move.l	(sp)+,d3
			rts
			
sm_1:		move.l	#$bf800000,(a0)
			move.l	(sp)+,d3
			rts

extpuf:		ds.l	3

			end