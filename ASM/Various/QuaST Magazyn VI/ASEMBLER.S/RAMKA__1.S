***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - NO BORDER - czyli usuniecie dolnej i gornej ramki   	  *
* autor    		 - Van Eijk ( na podstawie procedury z ST FORMATu4 )      *
* typ Atari		 - ST/E	  - na niektorych STekach ramka moze troche migac *
***************************************************************************

START:
   	clr.l -(sP)					* supervisor !
	move.w #32,-(SP)
	trap #1
	addq.l #6,SP	
	move.b #$12,$ffffc02		* wylaczenie myszki
    clr.w -(a7)                    
    pea $78000                  * niska rozdzielczosc
    pea $78000                     
    move.w #5,-(a7)                
    trap #14                       
    adda.l #12,a7  
						
	move.l #$78000,a0			* czyszczenie ekranu
	move.w #264*40-1,d0
SPRZATAJ1:
	clr (a0)+
	dbf d0,SPRZATAJ1

	jsr PALETA					* ustawienie nowych kolorow

	move.l #$78000+2*160,a0		* rysunek na ekran
	move.l #TLO,a1
	move.w #260*40-1,d0
KOPIUJ:
	move.l (a1)+,(a0)+
	dbf d0,KOPIUJ

	move.l #SAFEREG,a0			* zapamietanie rejestrow MFP
	move.b $fffa07,(a0)+
	move.b $fffa09,(a0)+
	move.b $fffa0b,(a0)+
	move.b $fffa0f,(a0)+
	move.b $fffa13,(a0)+
	move.b $fffa17,(a0)+
	move.b $fffa19,(a0)+	
	move.b $fffa1f,(a0)+	
	move.b $fffa1b,(a0)+
	move.b $fffa1d,(a0)+		
	move.b $fffa21,(a0)+
	MOVE.L $70,OLD_VBL			* zapamietanie starego VBLa
	move.l $120,OLD_TIMERB		* zapamietanie starego TIMERA B
	move.l	$134,OLD_TIMERA    	* zapamietanie starego TIMERA A

	move.b #8,$fffa1b			* ladowanie nowych wartosci pod TIMERy
	move.b #4,$fffa21
	andi.b #%11011111,$fffa09
	clr.b  $fffffa19		
	move.b #$21,$fffffa07	
	move.b #$21,$fffffa13	
	bclr   #3,$fffffa17	
	move.l #VBL,$70				* nowa procedura dla VBLa
	move.l #TIMER_B,$120        *     --//--     dla TIMERA B
	move.l #TIMER_A,$134		*     --//--     dla TIMERA A
	move.w #$2300,sr		

LOOP:							* petla oczekujaca na Spacje
	CMP.B #57,$FFFC02
	BNE.S LOOP

ENDED:							* procedura zakonczenia programu
	jsr END						* skok do proc. zwracajacej stare wartosci

	move.l #$78000,a0			* kasowanie zawartosci ekranu
	move.w #464*40-1,d0
SPRZATAJ:
	clr (a0)+
	dbf d0,SPRZATAJ
	clr -(sp)
	trap #1	

VBL:							* procedura przerwania VBLa
	clr.b	$fffffa19		
	move.b	#100,$fffffa1f	
	move.b	#4,$fffffa19	
	clr.b	$fffffa1b		
	move.b	#228,$fffffa21	
	move.l	#TIMER_B,$120	
	move.b	#8,$fffffa1b	
	cmp.b #57,$fffc02
	beq ENDED
	rte

TIMER_B:						* procedura przerwania TIMERa B
		move.w	d0,-(sp)		
		rept	32		
		nop			nop 
		endr			
		clr.w	d0		
		move.b	$ffff8209,d0	
		neg.b	d0		
		add.b	#192,d0		
		lsl.b	d0,d0		
		move.w	#18,d0		
PAUSE:	dbra	d0,PAUSE		
		move.b	#0,$ffff820a	
		rept	12		
		nop			nop 
		endr			
		move.b	#2,$ffff820a	
		move.w	(sp)+,d0		
		move.w #$000,$ffff8240
		rte

TIMER_A	move.w	#$2100,sr		* procedura przerwania TIMERa A
		stop	#$2100		
		clr.b	$fffffa19	
		rept	78		
		nop			nop 
		endr			
		clr.b	$ffff820a
		nop			nop
		nop			nop 
		move.b	#2,$ffff820a	
		rte			

PALETA:							* ustawienie nowych kolorow
	move.l #PAL,-(sp)
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp
	rts

END:							* zwort starych wartoscu ukladu MPF
	MOVE.L OLD_VBL,$70			* stary VBL
	andi.b #%11111110,$fffa07
	andi.b #%11111110,$fffa13
	move.l OLD_TIMERB,$120		* stary TIMER B
	move.l OLD_TIMERA,$134		* stary TIMER A
	move.l #SAFEREG,a0
	move.b (a0)+,$fffa07
	move.b (a0)+,$fffa09
	move.b (a0)+,$fffa0b                              
	move.b (a0)+,$fffa0f
	move.b (a0)+,$fffa13
	move.b (a0)+,$fffa17
	move.b (a0)+,$fffa19	
	move.b (a0)+,$fffa1f	
	move.b (a0)+,$fffa1b
	move.b (a0)+,$fffa1d
	move.b (a0)+,$fffa21
	move.b #$f7,$fffa23
	move.w	#$2700,sr		
	bset	#3,$fffffa17	
	move.w	#$2300,sr		
	move.w #$777,$ff8240    	* kolory...            
	move.w #$000,$ff8246
	move.b #8,$ffffc02
	rts

OLD_VBL:	ds.l 1
OLD_TIMERB: ds.l 1
OLD_TIMERA: ds.l 1
			even
SAFEREG: 	ds.b 12
			even
								* rysunek w pliku
TLO:		incbin a:\asembler.s\dane.dat\mm_33.pi1	
			even
PAL:							* dane do kolorow
			dc.w $000,$777,$011,$777,$022,$777,$033,$777
			dc.w $044,$777,$055,$777,$066,$777,$077,$777
