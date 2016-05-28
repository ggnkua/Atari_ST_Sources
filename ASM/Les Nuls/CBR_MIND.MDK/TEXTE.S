codage	movea.l	#message,a2
	movea.l	#code,a1
	moveq	#0,d0

codag1	move.b	(a2),d0
	subi.b	#$20,d0
	move.b	(a1,d0.w),(a2)+
	cmpi.w	#$3b,d0
	bne	codag1

save	lea	nom,a0  
	lea	message,a1
	movea.l	#fmess-message,a2
	bsr	creat
	rts

nom	dc.b	"texte.mdk",0
	even

creat	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bpl	writ
	clr.w	-(sp)
	trap	#1

writ	move.w	d0,d3
	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.w	d3,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	adda.l	#12,sp

close	move.w	d3,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

code	dc.b	46,28,47,48,49,50,51,32,34,35,46,46,27,33,26,46
	dc.b	36,37,38,39,40,41,42,43,44,45
	dc.b	29,30,46,46,46,31,46,00,01,02,03,04,05,06,07,08,09
	dc.b	10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,52
	even
           
message	dc.b 	" "
	dc.b	" LES NULS ONT L'IMMENSE JOIE DE VOUS OFFRIR CYBERMIND"
	dc.b	"  DEPRO PAR NOTRE TANDEM DE CHOC....SHIMROD  ET  BLOOD !!!"
	dc.b	" POUR LES CODES D'ACCES AUX NIVEAUX SUPERIEURS VOIR LA FIN"
	dc.b	" DE L'INTRO LES  MEMBRES DES NULS SONT :...JEANNE D'ARC..."
	dc.b	"LE NAIN...LE MATCHO...LE RINGUARD...LE GRINCHEUX...LE TOMBEUR"
	dc.b	"...LA TANTE...ET LA GRANDE GUEULE...SPECIAL THANK TO METAL68"
	dc.b	" POUR LA LOCATION DE SA GENIALE INTRO...HELLO JO LE DINGUE..."
	dc.b	"GROS BISOUX A ( DANS LE DESORDRE )...MAMAN...BANANE...JESTER"
	dc.b	"...THE CRACK...COLUCHE...SPACE BAR...RANK XEROX...MON AMANT..."
	dc.b	"FABATARI...ELWOOD ( EMJS ''MSTOTM ' )...FRANCIST...LEON ZITRONE"
	dc.b	"...RAL...STFORCE...SOFTWOLF...A LA GARE D'AUSTER ( HEHE NIKKIE )"
	dc.b	"...DOM...MARCUSP...MEGA ST II...GOURMAND...STKC...STF...MES "
	dc.b	"MAITRESSES...AUX GROSSES...AUX MAIGRES...AUX BRUNES...AUX BLONDES"
	dc.b	"...AUX BRUNES...AUX ROUSSES...A MA BROSSE A DENT...AUX FRITES"
	dc.b	".....ENORMES FESSEES A NIKKIE ET ACTARUS.....MEGAGIGA FUCK A L'"
	dc.b	"ARLESIENNE : BARBARIAN 2 ET COMME DIT PASCAL A LA SOUS MACHINE"
	dc.b	"....ALT HELP POUR LA ZIC...ET SPACE BARRRRRR POUR NOUS JETER..."
	dc.b	"GROS CALINS A BIENTOT...LES AMOURS...ATCHOA...BONNE...NUIT...THE"
	dc.b	" END...HE MERDE J'OUBLIAIS LESCODES : HALIM, RIDDLE, CYBORG, "
	dc.b	"WORLDS, COPTER, THEEND                         "
	dc.b 	"["
	even

fmess