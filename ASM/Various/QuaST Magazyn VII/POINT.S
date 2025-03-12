***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Point - procedura rysujaca punkty (1600 w 1 VBLu)         *
* autor      :  Wachu                                                     *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************

************************************************************************
* Uwaga! Program nalezy uruchomic pod GENSTem w wersji 2.0 lub wyzszej *
* i ustawic tabulacje na 10 miejsc !				       *
************************************************************************
* Uniwersalna procedura 'plot' - wszystkie 16 bitowe komputery ATARI,  *
* takze TT i FALCON po ustawieniu ich w tryb niskiej lub sredniej roz- *
* dzielczosci ST. Uwaga! Plot tylko dla niskiej rozdzielczosci ST!     *
************************************************************************
* Procedury uniwersalne maja to do siebie, ze sa stosunkowo wolne,
* a ta procedurka nie odbiega zbytnio od standardu przyjetego dla
* takich wlasnie programow, chociaz z drugiej strony 1600 punktow
* w 1 VBL'u nie jest takim zlym wynikiem. 
*
*				WACHU (Tomasz Wachowiak)
* P.S. Moja ostatnia rout osiaga 5 tys. punktow na ramke (ST) i mysle, ze
*      jest to jeszcze do poprawienia, ale to juz zupelnie inna historia...
*
* Jesli chcialbys sie ze mna skontaktowac, pisz pod adres:
*						Tomasz Wachowiak
*						Os. B. Chrobrego 20a/24
*						Poznan 60-681
* lub dzwon pod numer: (061) 223-593
*
* P.S. 2  W rejestrze d0 nalezy umieszczac wspolrzedna 'x', a w d1 'y'
*
***********  POCZATEK PROGRAMU  ************* 
	
*section	text

	move.w 	#32,-(sp)		;tryb 'supervisor' procesora
	trap 	#1
	addq.w 	#2,sp
	move.l	d0,old_ssp

	clr.w	-(sp)			;procedura ustawia rozdzielczosc
	pea	$78000				;i adresy ekranow (fizycznego i logicznego)
	pea	$78000	
	move.w	#5,-(sp)	
	trap	#14
	add.w	#12,sp
	
	lea	adr_x(pc),a0		;tablica 'adr_x' do rejestru a0
	lea	adr_y(pc),a1		;tablica 'adr_y' do rejestru a0
	lea	$78000,a6			;adres ekranu do a6
	
	move.w	#199,d6			;tutaj dwie petle, ktore spowoduja
pet2:						;wypelnienie calego ekranu punktami
	move.w	#319,d7
pet:
	move.w	d7,d0			;d7 do d0 (wspolrzedna 'x')
	move.w	d6,d1			;d6 do d1 (wspolrzedna 'y')
	bsr	plot				;wywolanie procedury przeliczajacej
							;wspolrzedne na adresy i zapalanie
							;wyliczonych wartosci
	dbf	d7,pet
	dbf	d6,pet2

czekaj:       
	cmpi.b  	#57,$fffc02
        bne.s   	czekaj
	move.l 	old_ssp,-(sp)	;tryb 'user' procesora
	move.w 	#32,-(sp)
	trap 	#1
  	addq.l 	#6,sp
	clr.w 	-(sp)		;wyjscie
	trap 	#1

plot:
	move.w	d0,d3
	add.w	d0,d0			;d0*2, czyli x*2
	add.w	d1,d1			;d1*2, czyli y*2
	move.w	(a1,d1.w),d2	;adres wspolrzednej 'y' w d2 (odczytany z tablicy 'adr_y')
	add.w	(a0,d0.w),d2	;do tego dodajemy adres wspolrzednej 'x' (z tablicy 'adr_x')
	not.b	d3				;dopelnienie wspolrzednej 'x' np. jesli x=6 to dopelnienie wyniesie 255-6=249
	bset	d3,(a6,d2.w)	;ustaw odpowiedni bit (zapal punkt)
 	rts
	
*	bss
old_ssp	ds.l	1

*	data
adr_x:
	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
	dc.w	8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9
	dc.w	16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17
	dc.w	24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25
	dc.w	32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33
	dc.w	40,40,40,40,40,40,40,40,41,41,41,41,41,41,41,41
	dc.w	48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,49
	dc.w	56,56,56,56,56,56,56,56,57,57,57,57,57,57,57,57
	dc.w	64,64,64,64,64,64,64,64,65,65,65,65,65,65,65,65
	dc.w	72,72,72,72,72,72,72,72,73,73,73,73,73,73,73,73
	dc.w	80,80,80,80,80,80,80,80,81,81,81,81,81,81,81,81
	dc.w	88,88,88,88,88,88,88,88,89,89,89,89,89,89,89,89
	dc.w	96,96,96,96,96,96,96,96,97,97,97,97,97,97,97,97
	dc.w	104,104,104,104,104,104,104,104,105,105,105,105,105,105,105,105
	dc.w	112,112,112,112,112,112,112,112,113,113,113,113,113,113,113,113
	dc.w	120,120,120,120,120,120,120,120,121,121,121,121,121,121,121,121
	dc.w	128,128,128,128,128,128,128,128,129,129,129,129,129,129,129,129
	dc.w	136,136,136,136,136,136,136,136,137,137,137,137,137,137,137,137
	dc.w	144,144,144,144,144,144,144,144,145,145,145,145,145,145,145,145
	dc.w	152,152,152,152,152,152,152,152,153,153,153,153,153,153,153,153
adr_y:
	dc.w	0,160,320,480,640,800,960,1120,1280,1440
	dc.w	1600,1760,1920,2080,2240,2400,2560,2720,2880,3040
	dc.w	3200,3360,3520,3680,3840,4000,4160,4320,4480,4640
	dc.w	4800,4960,5120,5280,5440,5600,5760,5920,6080,6240
	dc.w	6400,6560,6720,6880,7040,7200,7360,7520,7680,7840
	dc.w	8000,8160,8320,8480,8640,8800,8960,9120,9280,9440
	dc.w	9600,9760,9920,10080,10240,10400,10560,10720,10880,11040
	dc.w	11200,11360,11520,11680,11840,12000,12160,12320,12480,12640
	dc.w	12800,12960,13120,13280,13440,13600,13760,13920,14080,14240
	dc.w	14400,14560,14720,14880,15040,15200,15360,15520,15680,15840
	dc.w	16000,16160,16320,16480,16640,16800,16960,17120,17280,17440
	dc.w	17600,17760,17920,18080,18240,18400,18560,18720,18880,19040
	dc.w	19200,19360,19520,19680,19840,20000,20160,20320,20480,20640
	dc.w	20800,20960,21120,21280,21440,21600,21760,21920,22080,22240
	dc.w	22400,22560,22720,22880,23040,23200,23360,23520,23680,23840
	dc.w	24000,24160,24320,24480,24640,24800,24960,25120,25280,25440
	dc.w	25600,25760,25920,26080,26240,26400,26560,26720,26880,27040
	dc.w	27200,27360,27520,27680,27840,28000,28160,28320,28480,28640
	dc.w	28800,28960,29120,29280,29440,29600,29760,29920,30080,30240
	dc.w	30400,30560,30720,30880,31040,31200,31360,31520,31680,31840
	dc.w	32000
	end