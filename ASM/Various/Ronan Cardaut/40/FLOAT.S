	MC68881

	lea	NUM,a0
	bsr	READ_FLOAT	
	illegal
	
	fmove.l	fp0,d0
	
	fmove.x	#-151.0E10,fp0



NUM	dc.b	'-151.0E10',0
	even	
;------------------------------------------------------------------------------



	lea	ASCII,a0
	fmove.s	#3999,fp0
;------------------------------------------------------------------------------
;void FLOT_TO_SCI(float , char*)
;------------------------------------------------------------------------------
;IN:
;	fp0:	float … convertir
;	a0	ptr ASCII
;------------------------------------------------------------------------------
FLOT_TO_SCI	
	flog10	fp0,fp1
	fintrz	fp1
	fmove.l	fp1,d1
	

	fmove.s	#10.0,fp2
	flogn	fp2
	fmul	fp2,fp1
	
	fetox	fp1
	fmove.l	fp1,d0
	
	fdiv	fp1,fp0

	fintrz	fp0,fp1
	fmove.l	fp1,d0
	fsub	fp1,fp0
	add.b	#'0',d0
	fmul.s	#10.0,fp0
	move.b	d0,(a0)+
	move.b	#'.',(a0)+

	move	#6-1,d7	
.LOOP	
	fintrz	fp0,fp1
	fmove.l	fp1,d0
	fsub	fp1,fp0
	add.b	#'0',d0
	fmul.s	#10.0,fp0
	move.b	d0,(a0)+
	dbra	d7,.LOOP

	move.b	#'E',(a0)+
	add.b	#'0',d1
	move.b	d1,(a0)+
	rts
				
					

S_DEC
		
		

	
	
MAX_VAL	dc.l	10000
MIN_VAL	dc.l	-10000	
	
ASCII	ds.b	128
