********************************************************
*           EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM        *
*                  FICHIER "SOUFLAGE.S"                *
*              VERSION 1.00 (19 sept 1990)             *
********************************************************
* Les messages GEM pouvant ˆtre plac‚s en attente, nous
* utilisons cette routine pour ˆtre s–r qu'il n'en reste
* plus. Pour cela nous nous postons un message!
SOUFFLAGE:	MOVEM.L	D0-D7/A0-A6,-(SP)
	EVNT_TIMER	#105  on attend un petit peu
	LEA	MESSAGEBUF,A0
	MOVE.W	#65535,D0      
	MOVE.W	D0,(A0)+   je m'appelle
	MOVE.W	APP_ID,(A0)+  mon ap_id
	MOVE.L	#0,(A0)+   le reste	
	MOVE.L	#0,(A0)+	est mis
	MOVE.L	#0,(A0)+	… z‚ro
	APPL_WRITE  APP_ID,#16,#MESSAGEBUF
	EVNT_TIMER	#100
.XXX	EVNT_MESAG	#MESSAGEBUF     range message
	LEA	MESSAGEBUF,A0   r‚cup‚re ce qui
	MOVE.W	(A0),D0     est interressant
* On teste le message re‡u de l'ext‚rieur
	CMP.W	#65535,D0	notre message ?
	BNE	.XXX
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
*--------------------------------------------------------------------------*	
