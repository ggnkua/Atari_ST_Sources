********************************************************
*           EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM        *
*                  FICHIER "ACC_DATA.S"                *
*              VERSION 2.00 (10 Avril 1991)            *
********************************************************
* Datas pour le protocole GEM, cas d'un accessoire.
	SECTION DATA
ALERTE_TUB1:	DC.B	"[1][Tableau endommag‚," 
	DC.B	"|Communication par le |Tube GEM impossible.][  OK  ]",0
	EVEN
ALERTE_TUB2:	DC.B	"[1][Pas d'autres applications|"
	DC.B	"pour l'‚change de donn‚es!][  OK  ]",0
		EVEN
ALERTE_TUB2BIS:	DC.B	"[1][Pas d'autres applications|"
	DC.B	"pilotables. D‚sol‚!][  OK  ]",0
		EVEN
ALERTE_TUB3:	DC.B	"[1][ProblŠme en $5A0.|Communication"
	DC.B	" par le |Tube GEM impossible.][ OK ]",0
		EVEN
