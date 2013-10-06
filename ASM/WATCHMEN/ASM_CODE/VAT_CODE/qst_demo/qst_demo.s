*  All was coded by Vat at 92.10-1  *
*************************************
; jesli znajdziesz cos interesujacego
; w tym kodzie, to znaczy, ze prawie
; nie nie potrafisz napisac..........
Begin:
	lea	Begin(pc),a7
	bsr	res	
	lea	KEYBOARD(pc),a1
	move.l	a1,$118.w
	lea	savuj(pc),a0
	move.l	$120.w,(a0)
	move.l	$70.w,-4(a0)
	lea	VBL(pc),a1
	move.l	a1,$70.w
	move.w	#$2300,sr
	move.b	#$40,$fffffa17.w
key	cmp.b	#$39,$fffffc02.w
	bne.s	key
	bra	Yend

sav118	ds.l	4
savuj	ds.l	4
Yend	move.w	#$2700,sr
	lea	sav118(pc),a0
	move.l	(a0),$118.w
	lea	savuj(pc),a0
	and.b	#$fe,$fffffa07.w
	and.b	#$fe,$fffffa13.w
	move.l	-4(a0),$70.w
	lea	$fffffa00.w,a1
	lea	savek(pc),a0
	move.b	(a0),9(a1)
	move.b	1(a0),$11(a1)
	move.b	2(a0),$15(a1)
	move.b	3(a0),$1d(a1)
	move.b	4(a0),$0d(a1)
	move.b	#7,$484.w
	move.l	(a0),$120.w
	pea	oldcol(pc)
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7
	moveq	#0,d0
	lea	$78000,a0
	move.w	#$7d00/16,d7
ghrum	rept	4	
	move.l	d0,(a0)+
	endr
	dbf	d7,ghrum
	move.l	#$700ffff,$ffff8800.w
	move.l	#$8000000,$ffff8800.w
	move.l	#$9000000,$ffff8800.w
	move.l	#$a000000,$ffff8800.w
	move.w	#$2300,sr
	lea	txt(pc),a0
	lea	kreator,a1
	moveq	#0,d0
bulwa	rept	16
	move.l	d0,(a0)+
	endr
	cmp.l	a0,a1
	bgt.s	bulwa
	clr.l 	-(a7)
	trap 	#1
savek	ds.l	1


txt	
	moveq	#0,d0
	moveq	#0,d1
	lea	ktora_literka(pc),a1
	lea	2(a1),a0
	move.w	(a1),d0
	move.b	(a0,d0.w),d0
	and.w	#$ff,d0
	cmp.b	#0,d0
	bne.s	nic_to1
	clr.w	(a1)
	move.l	#$7b53c,screen
	move.l	#$7b53c,gdie
	bra	rts2
nic_to1	cmp.b	#10,d0
	bne.s	nic_to2
	move.l	#$7b53c,screen
	move.l	#$7b53c,gdie
	MOVE.W	#-1,PM
	bra	rts
nic_to2	cmp.b	#13,d0
	bne.s	nie_rusz
	add.l	#9*160,screen
	move.l	screen(pc),gdie
	clr.l	add
	bra.s	rts
nie_rusz sub.w	#32,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	tab(pc),a1
	lea	fonciki(pc),a0
	add.l	(a1,d0.w),a0
	move.l	gdie(pc),a1
	move.b	(a0),(a1)
	move.b	1(a0),160(a1)
	move.b	2(a0),320(a1)
	move.b	3(a0),480(a1)
	move.b	4(a0),640(a1)
	move.b	5(a0),800(a1)
	move.b	6(a0),960(a1)
	move.b	7(a0),1120(a1)
	lea	add(pc),a0
	bchg	#1,dupa
	btst	#1,dupa
	beq.s	nie
	move.l	#1,(a0)
	bra.s	pixxx
nie	move.l	#7,(a0)
pixxx	move.l	(a0),d0
	add.l	d0,gdie
rts	addq.w	#1,ktora_literka
rts2 	rts
PM	DS.W	1
clin	lea	$7b53c,a0
	moveq	#0,d0
	move.w	#79,d7
fiut	move.w	d0,(a0)
	move.w	d0,8(a0)
	move.w	d0,16(a0)
	move.w	d0,24(a0)
	move.w	d0,32(a0)
	move.w	d0,40(a0)
	move.w	d0,48(a0)
	move.w	d0,56(a0)
	move.w	d0,64(a0)
	move.w	d0,72(a0)
	move.w	d0,80(a0)
   	move.w	d0,88(a0)	
	move.w	d0,96(a0)
	move.w	d0,104(a0)
	lea	160(a0),a0
	dbf	d7,fiut
	rts
dupa	ds.w	1
ktora_literka ds.w 1
; $-A  &-E  +-N  <-S  *-L  ,-O  =-Z
tekst	dc.b	"                            ",13
	dc.b	"                            ",13
	dc.b	"                            ",13
	dc.b	"----------------------------",13
	dc.b	"   CZE<% TO ZNOWU JA -VAT-  ",13
	dc.b	"----------------------------",13
	dc.b	"        ",10
	DC.B	"MY<L&/ =E W TYM (SKROLU ???)",13
	DC.B	"W PRZECIWIE+STWIE DO DOLNEGO",13
	DC.B	"TEKSTY B&D$ DOTYCZY% G*,WNIE",13
	DC.B	"POZDROWIE+/ KT,RE POLEC$ W  ",13
	DC.B	"KOLEJNO<CI PAMI&CIOWEJ!?    ",13
	DC.B	".......... A WI&C DO DZIE*A!",13
	DC.B	"NA POCZ$TKU MEGA THANXY DLA ",13
	DC.B	"REDAKTOR,W MAGAZYNU -QUAST- ",13
	DC.B	"ZA UMIESZCZENIE TEGO DEMKA. ",13
	DC.B	"        ",10
	dc.b	"           - ZYP -      ",13
	dc.b	"CZE<% BARTEK JAK WIDZISZ TO ",13
	dc.b	"DEMKO JEST MA*O ORYGINALNE/ ",13
	dc.b	"ALE......   ",13
	dc.b	"POCZEKAJ NA NAST&PNE MOJE ",13
	dc.b	"DZIE*A/ KT,RE POBIJ$ TO NA  ",13
	dc.b	"G*OW& (JA UWA=AM TO INTERKO ",13
	dc.b	"ZA MA*Y KICZ!)...           ",10
	DC.B	"         - GA*GAN -     ",13
	DC.B	"HEJ RAFCIU/ CO TAM PANIE W  ",13
	DC.B	"KODOWANIU??? JE<LI BARDZO CI",13
	DC.B	"ZALE=Y NA >R,DLE TEGO DEMKA ",13
	DC.B	"TO WPADNIJ DO MNIE ZE SWOIMI",13
	DC.B	"DEMKAMI I INN$ KASZAN$......",13
	DC.B	"        ",10
	dc.b	"          - QUANT -     ",13
	dc.b	"HI PETER! CO TAM S*YCHA%??? ",13
	dc.b	"MAM NADZIEJ&/ =E TERAZ MASZ ",13
	dc.b	"TROCHE WI&CEJ WOLNEGO CZASU ",13
	dc.b	"I M,G*BY< COSIK DLA MNIE  ",13
	dc.b	"NARYSOWA%. UWA=AM CI& ZA  ",13
	dc.b	"NAJLEPSZEGO GRAFIKA W KRAJU!",13
	dc.b	"                  ",10
	DC.B	"          - MAREK -     ",13
	DC.B	"     (MI+SK MAZOWIECKI) ",13
	DC.B	"DZI&KI ZA WSZYSTKIE PROGRAMY",13
	DC.B	"KT,RE DLA MNIE PRZEGRA*E<!!!",13
	DC.B	"        ",10
	dc.b	"          - MC MAT -    ",13
	dc.b	"HEJ MA%KU! ZNAJD> TROCH&  ",13
	dc.b	"WOLNEGO CZASU I WPADNIJ DO  ",13
	dc.b	"MNIE Z KOMPUTEREM...........",13
	dc.b	"TY JU= WIESZ PO CO!         ",10
	DC.B	"         - VON BOBO -   ",13
	DC.B	"MAM NADZIEJ&/ =E ZROBI*E< ",13
	DC.B	"PARE MODU*K,W/ KT,RE B&D$ ",13
	DC.B	"SI& NADAWA% DO WYKO=YSTANIA ",13
	DC.B	"W KT,RYM< Z MOICH NAST&PNYCH",13
	DC.B	"DEMEK. CO DO TEGO INTRA DLA ",13
	DC.B	"CIEBIE TO MY<L&/ =E NIED*UGO",13
	DC.B	"JE SKO+CZ&!!!               ",13,10
	dc.b	"         - PERVERT -    ",13
	dc.b	"JESTE< CHYBA NAJBARDZIEJ  ",13
	dc.b	"LENIWYM HACKEREM/ CRACKEREM ",13
	dc.b	"JAKIEGO KIEDYKOLWIEK WIDZIA-",13
	dc.b	"*EM!!!          ",10
	DC.B	"A TERAZ JU= CZAS NA BARDZIEJ",13
	DC.B	"OG,LNE POZDROWIENIA.........",13
	DC.B	13,13,"TSV (TWORZYSZ CIEKAWE DEMKA)",13
	DC.B	"RADEK (KICK OFF MEGA FAN #1)",13
	DC.B	"PETER (KICK OFF MEGA FAN #2)",13
	DC.B	"PAWE* (OKULARNIK/ COBRETTI!)",13
	DC.B	"        ",10	
	dc.b	"WSZYSCY LUDZIE Z MOJA SZKO*A",13
	dc.b	"XLVII L.O.   (-WYSPIAN-)    ",13
	dc.b	"ARTUR BARANIAK (BARONTRONIC)",13
	dc.b	"WOJCIECH (KOLE< Z KLASY)  ",13
	dc.b	"ANDREAS (NEXT KOLE< Z KLASY)",13
	dc.b	"WRONEK (JESZCZE JEDEN KOLE<)",13
	dc.b	"CIAPEK I JEGO M*ODSZY BRAT  ",13
	dc.b	"        ",10
	DC.B	"SEBASTIAN GOGOL (THANXY ZA",13
	DC.B	" WSZYSTKIE ORYGINA*Y GIEREK)",13
	DC.B	"-SFJ- Z POZNANIA (HI GUYS!) ",13
	DC.B	"KIJOP (KIEDY NAST&PNE DEMKA)",13
	DC.B	"SOFTMAN (PATRZ POWY=EJ) ",13
	DC.B	"MARCHEW (MAM NADZIEJ&/ =E ",13
	DC.B	" NAST&PNE DEMO B&DZIE LEPSZE",13
	DC.B	" OD TEGO VISION! NIE B&D& ",13
	DC.B	" PRZYTACZA% KOMENATRZA ZYP'A",13
	DC.B	"              ",10
	dc.b	"MIXX! (C64- KOSZALIN) ",13
	dc.b	"MAREK I WODZU (AMIGANCI)  ",13
	dc.b	"B AND B (THANXY ZA PROGRAMY)",13
	dc.b	"JERRY (GO<CIU Z [] MEGA STE)",13
	dc.b	"NEMESIS (MA*Y CIPAK LE<NY)",13
	dc.b	"TATU< Z SYNEM ",13
	dc.b	"KUBA I BARTEK ",13
	dc.b	"IMMORTALS (CZEKAM NA DEMO!) ",13
	dc.b	"            ",10
	DC.B	"A TERAZ JU= CZAS NA ANTY PO-",13
	DC.B	"ZDROWIENIA/ CZYLI FUCKSY/ ",13
	DC.B	"KT,RE W&DRUJ$ DO: ",13
	DC.B	"WSZYSTKICH LAMER,W/ KT,RZY  ",13
	DC.B	"WYCINAJ$ CUDZE PROCEDURY Z  ",13
	DC.B	"DEMEK/ DO TYCH/ KT,RZY MNIE ",13
	DC.B	"NIE LUBI$ A TAK=E DO PIER-  ",13
	DC.B	"DOLC,W ZMIENIAJ$CYCH TEKSTY ",13
	DC.B	"W DEMKACH!!!                ",10
	dc.b	"NOW LET'S ME SEND SOME GREE-",13
	dc.b	"TINGS TO FOREIGN CREWS: ",13,13,13
	dc.b	"TLB-DELTA FORCE-REPLICANTS  ",13
	dc.b	"TEX-ULM-LIGHT-TCB-PHALANX-MB",13
	dc.b	"OXYGENE-OVR-OMEGA-ELECTRA ",13
	dc.b	"EQUINOXE-HTL-ELITE-ACF......",13
	dc.b	"AND FOR ALL OTHER I FORGOT! ",13
	dc.b	"            ",10
	DC.B	"I JESZCZE JEDNA SPRAWA: ",13
	DC.B	"JESTEM MANIAKIEM ZBIERAJ$CYM",13
	DC.B	"DEMKA. TERAZ WYPISZ& TE/  ",13
	DC.B	"KT,RE POSIADAM/ JE=ELI IN-  ",13
	DC.B	"TERESUJE CI& WYMIANA TO ",13
	DC.B	"WY<LIJ DO MNIE SPIS WSZY- ",13
	DC.B	"STKICH/ KT,RE POSIADASZ.  ",13
	DC.B	"NA PEWNO ODPISZ&!!! ",13
	DC.B	"            ",10
	dc.b	"        THE LOST BOYS   ",13
	dc.b	"-POWER DEMO -1S ",13
	dc.b	"-MEGABANG DEMO -1S",13
	dc.b	"-TRANSYLVANIA DEMO -1S  ",13
	dc.b	"-MINDBOMB DEMO -1D",13
	dc.b	"-LIFE'S A BITCH -1D ",13
	dc.b	"-OOH CRIKEY WOT A S... -1D",13
	dc.b	"                          ",10
	DC.B	"         DELTA FORCE        ",13
	DC.B	"-SYNTAX TERROR -1D",13
	DC.B	"-PUNISH YOUR MACHINE -2D",13
	DC.B	"        THE CAREBEARS       ",13
	DC.B	"-CUDDLY DEMOS -1D ",13
	DC.B	"-SO WATT DEMO -1D ",13
	DC.B	"            U L M           ",13
	DC.B	"-NEW YEAR DEMO -1D",13
	DC.B	"-DARK SIDE OF THE SPOON -1D ",13
	DC.B	"                          ",10
	dc.b	"    THE EXCEPTIONS (TEX)    ",13
	dc.b	"-SONIX DEMO -1S ",13
	dc.b	"-BIG DEMO -1S ",13
	dc.b	"-UNION DEMO -1D ",13
	dc.b	"          ALLIANCE          ",13
	dc.b	"-BLOOD SUCKER DEMO -1D  ",13
	dc.b	"-SKID ROW DEMO -2D  ",13
	dc.b	"-YEAR AFTER -1D ",13
	dc.b	"                          ",10
	DC.B	"HOBBY ONE DEMO -1D  LCC   ",13
	DC.B	"LIGHTING DEMO -1D PENDRAGONS",13
	DC.B	"THALION SOUND DEMO -1D  ",13
	DC.B	"EUROPEAN DEMOS -2D  OVR   ",13
	DC.B	"WORLD IS MY O... -1D  AURA  ",13
	DC.B	"WILD DEMO -1D  WILD BOYS  ",13
	DC.B	"DECADE DEMO -1D INNER CIRCLE",13
	DC.B	"TRANSBEAUCE -1S BUSHWAKERS  ",13
	DC.B	"TOTAL VISION -1D TVI  ",13
	DC.B	"                          ",10
	dc.b	"OVERDRIVE DEMO -1D PHALANX",13
	dc.b	"OVERDOSE DEMO -1D AGGRESION ",13
	dc.b	"GENIUS DEMO -1D OXYGENE ",13
	dc.b	"ELECTRA DEMO -1D ELECTRA  ",13
	dc.b	"TEA PARTY DEMO -1D DDC  ",13
	dc.b	"ULTIMATE GFA DEMO -1D  OVR",13
	dc.b	"EMPIRE DEMO -1D  TEC OF V8",13
	dc.b	"LOVE SPY PLUS -1D  ^QUANT^  ",13
	dc.b	"VISION DEMO -1D MARCHEW ",13
	dc.b	"                          ",10
	DC.B	"POZA TYMI DEMAMI MAM JESZCZE",13
	DC.B	"MN,STWO INNYCH MA*YCH DEMEK ",13
	DC.B	"Z G,RY INFORMUJ&/ =E NIE  ",13
	DC.B	"ZBIERAM DEMEK Z DIGITALIZO- ",13
	DC.B	"WAN$ MUZYK$/ TZN. TAKICH JAK",13
	DC.B	"POI POI DEMO/ GOTCHA/ ITP...",13
	DC.B	"                          ",10
	dc.b	"    ",13
	dc.b	"    ",13
	dc.b	"    ",13
	dc.b	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	dc.b	"^   UFFF!!! TO CHYBA JU=   ^",13
	dc.b	"^  WSZYSTKO W TYM SKROLU?  ^",13
	dc.b	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	dc.b	"        ",10
	DC.B	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	DC.B	"^   UWAGA! UWAGA! UWAGA!   ^",13
	DC.B	"^ PILNIE POSZUKUJ& DOBREGO ^",13
	DC.B	"^  GRAFIKA!!! CH&TNEGO DO  ^",13
	DC.B	"^ WSP,*PRACY ZE MN$ PROSZ& ^",13
	DC.B	"^ O WYS*ANIE DO MNIE SWOICH^",13
	DC.B	"^ DZIE*. ZWRACAM MATERIA*Y ^",13
	DC.B	"^  ADRES PODAM POD KONIEC  ^",13
	DC.B	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	DC.B	"        ",10
	dc.b	"  ",13
	dc.b	"  V     V     A   TTTTTTTT",13
	dc.b	"  V     V    A A     TT   ",13
	dc.b	"  V     V   A   A    TT   ",13
	dc.b	"  V     V  A     A   TT   ",13
	dc.b	"   V   V   AAAAAAA   TT   ",13
	dc.b	"    V V    A     A   TT   ",13
	dc.b	"     V     A     A   TT   ",13
	dc.b	"                            ",10	
	DC.B	"I TO JU= NAPEWNO KONIEC !!! ",13
	DC.B	"DZ&KI ZA WSZYSTKIE B*&DY/   ",13
	DC.B	"KT,RE W TYM TEK<CIE ZROBI*EM",13
	DC.B	"MY<L&/ =E BY* TO JEDEN Z    ",13
	DC.B	"NAJBARDZIEJ NIELOGICZNYCH   ",13
	DC.B	"TEKST,W JAKI KIEDYKOLWIEK   ",13
	DC.B	"POWSTA*. DO ZOBACZENIA W NA-",13
	DC.B	"ST&PNYM DEMKU!!!            ",10
	dc.b	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	dc.b	"^     A OTO M,J ADRES:     ^",13
	dc.b	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	dc.b	"^      ARTUR KARWATKA      ^",13
	dc.b	"^   UL.APTECZNA 4-6 M.40   ^",13
	dc.b	"^     04-367  WARSZAWA     ^",13
	dc.b	"^       TEL.13-29-37       ^",13
	dc.b	"^^^^^^^^^^^^^^^^^^^^^^^^^^^^",13
	dc.b	"                     ...BYE!",13
	dc.b	"                            ",10,0
last_word ds.b	1
	even
add	dc.l	1
screen	dc.l	$7b53c
gdie	dc.l	$7b53c
tab	ds.l	66
policznij ds.w	1
nexty	ds.w	1
gbr	ds.l	1
gbr2	ds.l	1
pizdka	dc.l	$7b53c
COUNTER_S dc.w	100
WITCH_SPR dc.w	1
WITCH_PAL dc.w	0
WITCH_VBL dc.w	0
KTORY	dc.l	pal_1
WYCIEM	LEA	COUNTER_S(pc),a0
	MOVE.W	(A0),D0
	CMP.W	#512,D0
	BEQ.S	CHANGE_PALETTE
	ADDQ.W	#1,(A0)
	RTS
GHOWNO	ADDQ.W	#1,6(A0)
	RTS
BCHG	DC.W	1
CHANGE_PALETTE
	CMP.W	#2,6(A0)
	BNE.S	GHOWNO
	CLR.W	6(A0)
	MOVE.W	2(A0),D0
	MOVE.W	4(A0),D1
	cmp.b	#8,d1
	bne.s	do_not_change
	cmp.b	#1,d0
	bne.s	nie_1
	bsr	dla_2
	bra.s	do_not_change
nie_1	cmp.b	#2,d0
	bne.s	nie_2
	bsr	dla_3
	bra.s	do_not_change
nie_2	bsr	dla_1
do_not_change
	CMP.B	#16,D1
	BNE	SšEM2
	CMP.B	#1,D0
	BEQ	JEDEN
	CMP.B	#2,D0
	BEQ	DWA
	MOVE.W	#1,2(A0)
	MOVE.L	#pal_1,8(A0)
	BRA	SšEM
DWA	MOVE.W	#3,2(A0)
	MOVE.L	#pal_3,8(A0)
	BRA.S	SšEM
JEDEN	MOVE.W	#2,2(A0)
	MOVE.L	#pal_2,8(A0)
SšEM	CLR.W	(A0)
	CLR.L	4(A0)
	BRA.S	RETURNY
SšEM2	NOP
	ADD.W	D1,D1	
	ADD.W	D1,D1
	LEA	DANE(pc),A1
	MOVEA.L	KTORY(PC),A2
	ADD.L	(A1,D1.W),A2
	ADDQ.W	#1,4(A0)
	MOVEM.L	(A2),D0-D7
	LEA	world(PC),A3
	MOVEM.L	D0-D7,(A3)
RETURNY	RTS
DANE	DC.L	000,032,064,096,128,160,192,224,256
	DC.L	288,320,352,384,416,448,480,512,544
dla_1	move.l	#(vat_1),vat_spr0
	move.l	#(vat_1+16*32),vat_spr1
	move.l	#(vat_1+32*32),vat_spr2
	move.l	#(vat_1+48*32),vat_spr3
	move.l	#(vat_1+64*32),vat_spr4
	rts
dla_2	move.l	#(vat_2),vat_spr0
	move.l	#(vat_2+16*32),vat_spr1
	move.l	#(vat_2+32*32),vat_spr2
	move.l	#(vat_2+48*32),vat_spr3
	move.l	#(vat_2+64*32),vat_spr4
	rts
dla_3	move.l	#(vat_3),vat_spr0
	move.l	#(vat_3+16*32),vat_spr1
	move.l	#(vat_3+32*32),vat_spr2
	move.l	#(vat_3+48*32),vat_spr3
	move.l	#(vat_3+64*32),vat_spr4
	rts
czysciec
	lea	nexty(pc),a1
	addq.w	#1,(a1)
	movea.l	pizdka(pc),a0
	cmp.w	#15,(a1)
	bne.s	wyczer
	clr.w	(a1)
	clr.l	gbr
	add.l	#160*9,gbr2
wyczer	add.l	gbr2(pc),a0
	add.l	gbr(pc),a0
	moveq	#0,d0
	move.w	d0,(a0)
	move.w	d0,160(a0)
	move.w	d0,320(a0)
	move.w	d0,480(a0)
	move.w	d0,640(a0)
	move.w	d0,800(a0)
	move.w	d0,960(a0)
	move.w	d0,1120(a0)
	addq.l	#8,gbr
	addq.w	#1,policznij
	cmp.w	#140,policznij
	bne.s	lkku
	clr.w	PM
	clr.l	policznij
	clr.l	gbr
	clr.l	gbr2
lkku	rts
fonciki	dc.l  $00000000,$00000000,$38383838,$38003838
	dc.l  $6C6C6C00,$00000000,$006CFE6C,$6CFE6C00
	dc.l  $7C06C6C6,$FEC6C60C,$5416C0C0,$C0C67C00
	dc.l  $FE02C0FC,$C0C2FE0C,$18181800,$00000000
	dc.l  $1C383030,$30381C00,$381C0C0C,$0C1C3800
	dc.l  $C000C8D0,$E0C2FE00,$CA26F6DE,$CEC6C600
	dc.l  $5416C6C6,$C6C67C00,$000000FE,$00000000
	dc.l  $00000000,$00303000,$00000000,$00181830
	dc.l  $7CC6CED6,$E6C67C00,$18387818,$18187E00
	dc.l  $7CC6060C,$3860FE00,$FE0C180C,$06C67C00
	dc.l  $1C3C6CCC,$FE0C0C00,$FEC0FC06,$06C67C00
	dc.l  $7CC0C0FC,$C6C67C00,$FE060C18,$30606000
	dc.l  $7CC6C67C,$C6C67C00,$7CC6C67E,$060C7800
	dc.l  $00303000,$30300000,$00001818,$00181830
	dc.l  $5416C03C,$06C67C00,$FE001CFE,$70E2FE00
	dc.l  $AE201C38,$70E2FE00,$7CC6060C,$18001818
	dc.l  $18181818,$18181800,$7C06C6C6,$FEC6C600
	dc.l  $FC06C6FC,$C6C6FC00,$7C06C0C0,$C0C67C00
	dc.l  $F80CC6C6,$C6CCF800,$FE02C0FC,$C0C2FE00
	dc.l  $FE02C0FC,$C0C0C000,$7E02C0CE,$C6C67E00
	dc.l  $C606C6FE,$C6C6C600,$7E001818,$18187E00
	dc.l  $1E000606,$C6C67C00,$C60CD8F0,$D8CCC600
	dc.l  $C000C0C0,$C0C2FE00,$C62EFED6,$C6C6C600
	dc.l  $C626F6DE,$CEC6C600,$7C06C6C6,$C6C67C00
	dc.l  $FC06C6FC,$C0C0C000,$7C06C6C6,$D6CC7600
	dc.l  $FC06C6FC,$CCC6C600,$7C06C07C,$06C67C00
	dc.l  $FE823838,$38383800,$C606C6C6,$C6C67E00
	dc.l  $C606C6C6,$C66C3800,$C606C6D6,$FEEEC600
	dc.l  $C6066C38,$6CC6C600,$C606C66C,$38383800
	dc.l  $FE001C38,$70E2FE00,$0505050D,$0D197971
	dc.l  $183E603C,$067C1800,$A0A0A0B0,$B0989E8E
	dc.l  $10385410,$10101038,$FEFEFEFE,$FEFEFE00

VBL
	move.b	#7,$ffff8201.w
	move.b	#$80,$ffff8203.w
	clr.b	$fffffa1b.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#3,$fffffa21.w
	move.l	#$27,$ffff8240.w
	move.l	#HBL,$120.w
	move.b	#8,$fffffa1b.w
	bsr	vat_sprite
	bsr	horizontal
	bsr	(muzak+8)
	bsr	equal_
	bsr	skroll
	cmp.w	#-1,PM
	beq.s	rteee2
	cmp.w	#4,kutwa
	bne.s	rteee
	bsr	txt
	clr.w	kutwa
rteee	addq.w	#1,kutwa
	bra.s	rteee3
rteee2	bsr	czysciec
rteee3	bsr	WYCIEM
	nop
	rte
kutwa	ds.w	1
KEYBOARD
	bclr	#6,$fffffa11.w
	rte
res	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	dc.w	$a00a
	clr.w	-(a7)
	pea	$78000
	pea	$78000
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	move.b	#$12,$fffffc02.w
	pea	pal_3(pc)
	move.w	#6,-(a7)
	trap	#14 
	addq.l	#6,a7
	moveq	#0,d0
	moveq	#0,d1
	lea	(vat_3+64*32)(pc),a0
	movem.l	d0-d1,(a0)
	movem.l	d0-d1,16(a0)
	moveq	#1,d0	
	bsr	muzak
	lea	tab(pc),a0
	moveq	#0,d0
	moveq	#65,d7
figarek	move.l	d0,(a0)+
	addq.w	#8,d0
	dbf	d7,figarek
	move.b	#$12,$fffffc02.w
	lea	sav118(pc),a0
	move.l	$118.w,(a0)
	lea	$fffffa00.w,a0
	lea	savek(pc),a1
	move.b	9(a0),(a1)
	move.b	$11(a0),1(a1)
	move.b	$15(a0),2(a1)
	move.b	$1d(a0),3(a1)
	move.b	$0d(a0),4(a1)
	clr.b	$09(a0)
	clr.b	$15(a0)
	clr.b	$1b(a0)
	clr.b	$0d(a0)
	clr.b	$1d(a0)
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	bsr	nothing
	bra	create_qm
nothing
	lea	pal_1(pc),a0
	bsr	n1
	lea	pal_2(pc),a0
	bsr	n1
	lea	pal_3(pc),a0
	bsr	n1
	rts
n1	lea	32(a0),a1
	lea	(a1),a2
	bsr	tfu
n2	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfu
n3	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfu
n4	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfu
n5	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfu
n6	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfu
n7	lea	(a2),a0
	lea	32(a2),a1
	lea	(a1),a2
	bsr	tfu
	rts
tfu	movem.l	(a0)+,d0-d3
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	move.w	#$27,d0
	movem.l	d0-d3,(a1)
	movem.l	(a0),d0-d3
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d0,d6
	bsr	one_col
	move.w	d5,d0
	swap	d0
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d1,d6
	bsr	one_col
	move.w	d5,d1
	swap	d1
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d2,d6
	bsr	one_col
	move.w	d5,d2
	swap	d2
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	move.w	d3,d6
	bsr	one_col
	move.w	d5,d3
	swap	d3
	movem.l	d0-d3,16(a1)
	rts
one_col	moveq	#0,d4
	moveq	#0,d5
	move.w	d6,d4
	ror.l	#8,d4
	tst.b	d4
	beq.s	husarz
	subq.w	#1,d4
husarz	move.b	d4,d5
	lsl.w	#4,d5
	rol.l	#4,d4
	and.b	#15,d4
	tst.b	d4
	beq.s	husarz1
	subq.w	#1,d4
husarz1	or.b	d4,d5
	lsl.w	#4,d5
	rol.l	#4,d4
	and.b	#15,d4
	tst.b	d4
	beq.s	husarz2
	subq.w	#1,d4
husarz2	or.b	d4,d5
	rts
create_qm
	moveq	#15,d6
	lea	cr_qm(pc),a0
	lea	kreator,a1
fik	lea	quast(pc),a2
	add.l	(a0)+,a2
	moveq	#31,d7
shown	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbf	d7,shown
	moveq	#31,d7
	dbf	d6,fik
hblsin	lea	hbl_sin(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#32,d2
	move.w	#13*16-2,d6
	move.w	d6,d7
gogo	move.w	d0,(a0)+
	add.l	d2,d0
	dbf	d6,gogo
	sub.w	d2,d0
gogogo	move.w	d0,(a0)+
	sub.w	d2,d0
	dbf	d7,gogogo
	clr.b	$484.w
	movem.l	pal_1(pc),d0-d7
	lea	world(pc),a0
	movem.l	d0-d7,(a0)
	lea	pal_1(pc),a0
	LEA	PAL_P(PC),A1
	bsr	dawaj_policzymy
	lea	pal_2(pc),a0
	LEA	PAL_D(PC),A1
	bsr	dawaj_policzymy
	lea	pal_3(pc),a0
	LEA	PAL_T(PC),A1
	bsr	dawaj_policzymy
	rts
dawaj_policzymy
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,224(a1)
pa2	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,192(a1)
pa3	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,160(a1)
pa4	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,128(a1)
pa5	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,96(a1)
pa6	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,64(a1)
pa7	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,32(a1)
pa8	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	rts
skroll	tst.w	control
	bpl.s	rol
	move.w	lit(pc),d0
	lea	text(pc),a1
	move.b	(a1,d0.w),d0
	tst.b	d0
	bne.s	jeszcze
	move.b	(a1),d0
	clr.w	lit
jeszcze	and.l	#$ff,d0
	addq.w	#1,lit
	sub.w	#32,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	letter(pc),a1
	add.l	d0,a1
	move.l	(a1),a1
	add.l	#fonts,a1
	move.l	a1,adr
	move.w	#24,control
rol	move.w	control(pc),d0
	move.l 	adr(pc),a0
	lea 	$7ed60,a1
	move.w 	#24,d3
move	move.w 	(a0),d2
	swap 	d2
	move.w 	2(a0),d2
	lsr.l 	d0,d2
    	move.b 	1(a1),(a1)
    	move.b 	8(a1),1(a1)
    	move.b 	9(a1),8(a1)
    	move.b 	16(a1),9(a1)
    	move.b 	17(a1),16(a1)
    	move.b 	24(a1),17(a1)
    	move.b 	25(a1),24(a1)
    	move.b 	32(a1),25(a1)
    	move.b 	33(a1),32(a1)
    	move.b 	40(a1),33(a1)
    	move.b 	41(a1),40(a1)
    	move.b 	48(a1),41(a1)
    	move.b 	49(a1),48(a1)
    	move.b 	56(a1),49(a1)
    	move.b 	57(a1),56(a1)
    	move.b 	64(a1),57(a1)
    	move.b 	65(a1),64(a1)
    	move.b 	72(a1),65(a1)
    	move.b 	73(a1),72(a1)
    	move.b 	80(a1),73(a1)
    	move.b 	81(a1),80(a1)
    	move.b 	88(a1),81(a1)
    	move.b 	89(a1),88(a1)
    	move.b 	96(a1),89(a1)
    	move.b 	97(a1),96(a1)
    	move.b 	104(a1),97(a1)
    	move.b 	105(a1),104(a1)
    	move.b 	112(a1),105(a1)
    	move.b 	113(a1),112(a1)
    	move.b 	120(a1),113(a1)
    	move.b 	121(a1),120(a1)
    	move.b 	128(a1),121(a1)
    	move.b 	129(a1),128(a1)
    	move.b 	136(a1),129(a1)
    	move.b 	137(a1),136(a1)
    	move.b 	144(a1),137(a1)
    	move.b 	145(a1),144(a1)
    	move.b 	152(a1),145(a1)
    	move.b 	153(a1),152(a1)
    	move.b 	d2,153(a1)
  	addq.l 	#4,a0
  	lea 	160(a1),a1
	dbf 	d3,move
	subq.w	#8,control
	rts
equal_	move.l	#160,d5
	moveq	#0,d0
	moveq	#0,d1
	lea	$ffff8800.w,a0
	moveq	#-2,d2
	lea	$78000+5288,a1
	lea	136(a1),a2
	moveq	#8,d0
	bsr.s	equalizer
	lea	$78000+5296,a1
	lea	120(a1),a2
	moveq	#9,d0
	bsr.s	equalizer
	lea	$78000+5304,a1
	lea	104(a1),a2
	moveq	#10,d0
	bsr.s	equalizer
	rts
equalizer
	moveq	#15,d6
	move.b	d0,(a0)
	move.b	(a0),d0
	btst	#4,d0
	beq.s	dal0
	moveq	#10,d0
dal0	sub.w	d0,d6
	addq.w	#1,d0
	move.w	d0,d7
	movem.l	d6-d7/a1-a2,-(a7)
write	move.w	d2,(a1)
	move.w	d2,-160(a1)
	sub.l	d5,a1
	sub.l	d5,a1
	move.w	d2,(a2)
	move.w	d2,-160(a2)
	sub.l	d5,a2
	sub.l	d5,a2
	dbf	d7,write
wycz	move.w	d1,(a1)
	move.w	d1,-160(a1)
	sub.l	d5,a1
	sub.l	d5,a1
	move.w	d1,(a2)
	move.w	d1,-160(a2)
	sub.l	d5,a2
	sub.l	d5,a2
	dbf	d6,wycz
	movem.l	(a7)+,d6-d7/a1-a2
	add.l	#480,a1
	add.l	#480,a2
write2	move.w	d2,(a1)
	move.w	d2,-160(a1)
	add.l	d5,a1
	add.l	d5,a1
	move.w	d2,(a2)
	move.w	d2,-160(a2)
	add.l	d5,a2
	add.l	d5,a2
	dbf	d7,write2
wycz2	move.w	d1,(a1)
	move.w	d1,-160(a1)
	add.l	d5,a1
	add.l	d5,a1
	move.w	d1,(a2)
	move.w	d1,-160(a2)
	add.l	d5,a2
	add.l	d5,a2
	dbf	d6,wycz2
	rts
vat_sprite
	move.l	#160,d4
	lea	sin(pc),a0
	movea.l	zcreen_0(pc),a1
	movea.l	vat_spr0(pc),a2
	lea	gdzie0(pc),a3
	bsr.s	_VAT_
	movea.l	zcreen_1(pc),a1
	movea.l	vat_spr1(pc),a2
	lea	gdzie1(pc),a3
	bsr.s	_VAT_
	movea.l	zcreen_2(pc),a1
	movea.l	vat_spr2(pc),a2
	lea	gdzie2(pc),a3
	bsr.s	_VAT_
	movea.l	zcreen_3(pc),a1
	movea.l	vat_spr3(pc),a2
	lea	gdzie3(pc),a3
	bsr.s	_VAT_
	movea.l	zcreen_4(pc),a1
	movea.l	vat_spr4(pc),a2
	lea	gdzie4(pc),a3
	bsr.s	_VAT_
	rts
_VAT_	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a3),d0
	move.w	(a0,d0.w),d1
	cmp.w	#-1,d1
	bne.s	MOVE
	clr.w	(a3)
	move.w	sin(pc),d1
MOVE	add.l	d1,a1
	moveq	#31,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	movem.l	d0-d3,-160(a1)
	movem.l	d0-d3,-320(a1)
	movem.l	d0-d3,-480(a1)
	movem.l	d0-d3,-640(a1)
SHOW	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a1)
	add.l	d4,a1
	dbf	d7,SHOW
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	movem.l	d0-d3,(a1)
	movem.l	d0-d3,160(a1)
	movem.l	d0-d3,320(a1)
	movem.l	d0-d3,480(a1)
	add.w	#2,(a3)
	rts
;  START POSITION FOR FLYING -VAT-
gdzie0	dc.w	0
gdzie1	dc.w	16
gdzie2	dc.w	32
gdzie3	dc.w	48
gdzie4	dc.w	64
;  SHIFTS FOR GFX -QUAST MAGAZINE-
cr_qm	dc.l	6144,3584,5120,0512
	dc.l	4096,4608,0000,2560
	dc.l	0512,1536,0512,5632
	dc.l	2048,3072,1024,6144
horizontal
	move.l	#160,d4
	lea	hbl_sin(pc),a0
	movea.l	skreen_0(pc),a1
	lea	kreator,a2
	lea	where_0(pc),a3
	bsr.s	swing
	movea.l	skreen_1(pc),a1
	lea	kreator,a2
	lea	where_1(pc),a3
	bsr.s	swing
	rts
swing	moveq	#0,d0
	moveq	#0,d1
	move.w	(a3),d0
	move.w	(a0,d0.w),d1
	cmp.w	#-1,d1
	bne.s	MOVING
	clr.w	(a3)
	move.w	hbl_sin(pc),d1
MOVING	add.l	d1,a2
	moveq	#93,d7
SHOWYOU	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a1)
	add.l	d4,a1
	dbf	d7,SHOWYOU
	add.w	#2,(a3)
	rts

;START POSITION FOR HORIZONTAL SCROLL
where_0	dc.w	0
where_1 dc.w	414
; START ADRESS of HORIZONTAL SCROLL
skreen_0 dc.l	$78000+160*77
skreen_1 dc.l	$78000+160*77+144
;   START ADRESS of FLYING -VAT-
zcreen_0 dc.l	$78000+640+40
zcreen_1 dc.l	$78000+640+56
zcreen_2 dc.l	$78000+640+72
zcreen_3 dc.l	$78000+640+88
zcreen_4 dc.l	$78000+640+104
hbl_sin	ds.w	13*32-1
	dc.l	-1,-1
sin	dc.w	0,160,320,480,640
	dc.w	800,960,1120,1280
	dc.w	1440,1600,1760,1920
	dc.w	2080,2240,2400,2560
	dc.w	2720,2880,3040,3200
	dc.w	3360,3520,3680,3840
	dc.w	4000,4160,4320,4480
	dc.w	4640,4480,4320,4160
	dc.w	4000,3840,3680,3520
	dc.w	3360,3200,3040,2880
	dc.w	2720,2560,2400,2240
	dc.w	2080,1920,1760,1600
	dc.w	1440,1280,1120,960
	dc.w	800,640,480,320,160,-1
pal	dc.w	$000,$777,$770,$767,$750,$741,$722,$500
	dc.w	$127,$137,$470,$357,$400,$300,$700,$600
pal_1	dc.w	$000,$027,$400,$510,$620,$730,$740,$752
	dc.w	$020,$030,$040,$051,$062,$073,$363,$300
	DS.W	7*16
PAL_D	DS.W	8*16
pal_2	dc.w	$0000,$0027,$0733,$0722,$0600,$0500,$0400,$0300
	dc.w	$0200,$0711,$0744,$0070,$0070,$0070,$0070,$0776
	DS.W	7*16
PAL_T	DS.W	8*16
pal_3	dc.w	$000,$027,$300,$400,$510,$620,$730,$740
	dc.w	$750,$111,$222,$333,$444,$555,$666,$777
	DS.W	7*16
PAL_P	DS.W	8*16
qst_pal	dc.w	$000,$200,$300,$400,$510,$620,$730,$740
	dc.w	$750,$760,$002,$013,$024,$035,$046,$057
world	ds.w	16
piss_off dc.l	32*0,32*1,32*2,32*3,32*4,32*5,32*6,32*7
ADR_PAL1 DC.L	pal_1
ADR_PAL2 DC.L	pal_2
ADR_PAL3 DC.L	pal_3
HBL	movem.l	d0-d7,-(a7)
	movem.l	world(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(a7)+,d0-d7
	clr.b	$fffffa1b.w
	move.b	#32,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#hbl_1,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_1	clr.b	$fffffa1b.w
	move.b	#4,$fffffa21.w
	move.l	#hbl_2,$120.w
	move.b	#8,$fffffa1b.w
	move.w	#$010,$ffff8242.w
	bclr	#0,$fffffa0f.w
	rte
hbl_2	move.w	#$020,$ffff8242.w
	move.l	#hbl_3,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_3	move.w	#$030,$ffff8242.w
	move.l	#hbl_4,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_4	move.w	#$040,$ffff8242.w
	move.l	#hbl_5,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_5	move.w	#$050,$ffff8242.w
	move.l	#hbl_6,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_6	move.w	#$060,$ffff8242.w
	move.l	#hbl_7,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_7	move.w	#$070,$ffff8242.w
	move.l	#hbl_8,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_8	move.w	#$500,$ffff8242.w
	move.l	#hbl_9,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_9	move.w	#$600,$ffff8242.w
	move.l	#hbl_a,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_a	movem.l	d0-d7,-(a7)
	movem.l	qst_pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(a7)+,d0-d7
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.l	#hbl_b,$120.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
hbl_b	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#hbl_c,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_c	move.w	#$25,$ffff8240.w
	move.l	#hbl_d,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_d	move.w	#$36,$ffff8240.w
	move.l	#hbl_e,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_e	move.w	#$47,$ffff8240.w
	move.l	#hbl_f,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_f	move.w	#$36,$ffff8240.w
	move.l	#hbl_10,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_10	move.w	#$25,$ffff8240.w
	move.l	#hbl_11,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_11	move.l	#hbl_12,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_12	clr.b	$fffffa1b.w
	move.b	#88,$fffffa21.w
	move.l	#hbl_13,$120.w
	move.b	#8,$fffffa1b.w
	move.w	#0,$ffff8240.w
	bclr	#0,$fffffa0f.w
	rte
hbl_13	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#hbl_g2,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_g2	move.w	#$25,$ffff8240.w
	move.l	#hbl_g3,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_g3	move.w	#$36,$ffff8240.w
	move.l	#hbl_g4,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_g4	move.w	#$47,$ffff8240.w
	move.l	#hbl_g5,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_g5	move.w	#$36,$ffff8240.w
	move.l	#hbl_g6,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_g6	move.w	#$25,$ffff8240.w
	move.l	#hbl_g7,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_g7	move.l	#$610,$ffff8240.w
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
vat_spr0 dc.l	vat_1
vat_spr1 dc.l	vat_1+16*32
vat_spr2 dc.l	vat_1+32*32
vat_spr3 dc.l	vat_1+48*32
vat_spr4 dc.l	vat_1+64*32
lit	ds.w	1
adr	ds.l	1
control	dc.w	-8
text	DC.B	" ..........'OD NAS TAK[E ZALE[Y CO W DEMKACH WIDZIMY, MOJE SPOTKANIA Z KLASYK# KODERSK#!!!'...........(HE!HE!HE!). "
	DC.B	"      CZE>$ -VAT- MA ZASZCZYT PRZEDSTAWI$ CI SWOJE NOWE DEMKO NAPISANE SPECJALNIE DLA MAGAZYNU DYSKOWEGO -QUAST-. "
	DC.B	"INTRO TO POWSTA*O W CI#GU TRZECH DNI, JAK ZWYKLE PRZY POMOCY DEVPAC'A I NEOCHROMA MASTER V2.26 (DELTA FORCE). "
	DC.B	"FONTY W JAK I G<RNYM DOLNYM SKROLU ZOSTA*Y ZAPROJEKTOWANE I NARYSOWANE PRZEZE MNIE, POZOSTA*A GRAFIKA ZOSTA*A "
	DC.B	"WYCI%TA PRZEZ MOJEGO KUMPLA PERVERT'A, TO SAMO DOTYCZY MUZYCZKI, KT<RA POCHODZI Z GRY 'RINGS OF MEDUSA II- RETURN OF MEDUSA'. "
	DC.B	"MY>L%, [E PO RAZ OSTATNI KO[YSTAM Z WYCI%TEJ GRAFIKI- (NIE LUBI% TEGO!!!). MY>L%, [E JESZCZE SPORO INNYCH RZECZY M<G*BYM "
	DC.B	"WSADZI$ DO TEGO SCREENU, PONIEWA[ ZOSTA*O MI JESZCZE OKO*O 50 PROCENT CZASU PROCESORA....... (MY>L%, [E TO BARDZO DUUUUU[[[[[OOO!!!). "
	DC.B	"I JESZCZE DLA PORZ#DKU, DATA Z*O[ENIA DEMKA:   1 PA@DZIERNIKA ROKU TYSI#C DZIEWI%$SET DZIEWI%DZIESI#TEGO DRUGIEGO "
	DC.B	"(1-10.1992). I TO BY CHYBA BY*O NA TYLE W TYM SKROLU!!! JE[EL CHCESZ SI% ZE MN# SKONTAKTOWA$ TO ADRES ZNAJDZIESZ "
	DC.B	"POWY[EJ- (PISZ DO MNIE NAWET BEZ POWODU)!!!.....................CZAS JU[ KO+CZY$ TEN TEKST......................."
	DC.B	"10..........9.........8........7......6......5.....4....3...2..1.0              ZA CHWIL% TEKST POLECI OD POCZ#TKU!      "
	DC.B	"                                           ",0
	even
quast	ds.l	512/4 ;odstep
	incbin	\qst_demo\quast_m.dat ;AEGIMNQSTUZ.
vat_1	incbin	\qst_demo\vat1.tlb
vat_2	incbin	\qst_demo\vat2.tlb
vat_3	incbin	\qst_demo\vat3.tlb
oldcol	dc.l  $0FFF0F00,$00F00FF0,$000F0F0F,$00FF0555
	dc.l  $03330F33,$03F30FF3,$033F0F3F,$03FF0000
letter	dc.l  $0000,$0064,$00C8,$012C
	dc.l  $0190,$01F4,$0258,$02BC
	dc.l  $0320,$0384,$03E8,$044C
	dc.l  $04B0,$0514,$0578,$05DC
	dc.l  $0640,$06A4,$0708,$076C
	dc.l  $07D0,$0834,$0898,$08FC
	dc.l  $0960,$09C4,$0A28,$0A8C
	dc.l  $0AF0,$0B54,$0BB8,$0C1C
	dc.l  $0C80,$0CE4,$0D48,$0DAC
	dc.l  $0E10,$0E74,$0ED8,$0F3C
	dc.l  $0FA0,$1004,$1068,$10CC
	dc.l  $1130,$1194,$11F8,$125C
	dc.l  $12C0,$1324,$1388,$13EC
	dc.l  $1450,$14B4,$1518,$157C
	dc.l  $15E0,$1644,$16A8,$170C
	dc.l  $1770,$17D4,$1838,$189C
	dc.l  $1900,$1964,$19C8,$1A2C
	dc.l  $1A90,$1AF4,$0000,$0000
fonts	incbin	\qst_demo\fonty_1.cod
muzak	incbin	\qst_demo\rom_ii.dat
kreator	end
