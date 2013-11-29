/* main popup!! */


#define NUMLANGUAGES 4

char *languagestr[] = {
   	"  Deutsch        ",
   	"  English        ",
   	"  Franáais       ",
   	"  Lâtzebuergesch "
};


/* Textpointer Arrays */

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_german[] = {
	"COMPOSED CHARACTERS KONFIGURATION",	/* titel config */
	"DEADKEY KONFIGURATION",				/* titel config */
	"Einstellen \003",						/* 'Setup' */
	"Sprache:",						/* 'language' */
	"Deutsch",						/* current language */
	"Die Tabelle",					/* 'The table' */
	"gilt bei",						/* 'is valid for' */
	"Sichern",						/* 'Save' */
	"OK",							/* 'OK' */
	"Abbruch",						/* 'Cancel' */
	"Compose Modus:",				/* 'compose mode' */
	"Reihenfolge ist",				/* 'compose order' */
	"GÅltige Deadkeys sind:",		/* 'valid deadkeys are' */
	"OK",							/* 'OK' */
	"Abbruch",						/* 'Cancel' */
};
	
char *OTHER_german[] = {
	/* ALERTS */
	"[2][ |CKBD.PRG nicht installiert? ][Abbruch]",
	"[3][ |Fehlerhaftes Dateiformat ][Abbruch]",
	"[1][CPX-Version 1.10"
	   "|Dieses Programm ist Freeware"
	   "|von: Pascal Fellerich"
	   "|     45, rue des Genàts"
	   "|     L-3482 Dudelange][  OK  ]",
	
	/* Popup button labels */
	"MultiChar", "MultiAuto", "DEC (VT2xx)",
	"einzuhalten", "egal",
	"nichts", "Tastatur", "Compose", "Tastatur & Compose",
	"Deutsch",

	/* Fileselector titles */
	"Neue Tastaturtabelle laden", "Neue Compose-Tabelle laden",

	/* POP UP menues */
	/*-------------------------- loadtab -----------*/
	"  Lade *.CKB Datei ", /*0*/
	"  Lade *.KBD Datei ",
	"  Systemtabelle    ",
	/*-------------------------- tableactive -------*/
	"  nichts...          ", /*3*/
	"  Tastatur           ",
	"  Compose            ",
	"  Tastatur & Compose ",
	/*-------------------------- comporder ---------*/
	"  egal        ", /*7*/
	"  einzuhalten ",
	/*-------------------------- compmode -----------*/
	"  DEC (VT) Modus    ", /*9*/
	"  MultiChar         ",
	"  Multi automatisch "
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_english[] = {
	"COMPOSED CHARACTERS CONFIGURATION",	/* titel config */
	"DEADKEY CONFIGURATION",				/* titel config */
	"Setup \003",					/* 'Setup' */
	"Language:",					/* 'language' */
	"English",						/* current language */
	"The table",					/* 'The table' */
	"applies to",					/* 'is valid for' */
	"Save",							/* 'Save' */
	"OK",							/* 'OK' */
	"Cancel",						/* 'Cancel' */
	"Compose mode:",				/* 'compose mode' */
	"Compose order:",				/* 'compose order' */
	"Valid Deadkeys are:",			/* 'valid deadkeys are' */
	"OK",							/* 'OK' */
	"Cancel",						/* 'Cancel' */
};
	
char *OTHER_english[] = {
	/* ALERTS */
	"[2][ |CKBD.PRG not installed? ][Cancel]",
	"[3][ |Bogous CKB file! ][Abort]",
	"[1][CPX release 1.10"
	   "|This program is freeware"
	   "|by:  Pascal Fellerich"
	   "|     45, rue des Genàts"
	   "|     L-3482 Dudelange][  OK  ]",
	
	/* Popup button labels */
	"MultiChar", "MultiAuto", "DEC (VT2xx)",
	"Order Sens.", "Order Indf.",
	"nothing", "Keyboard", "Compose", "Keyboard & Compose",
	"English",

	/* Fileselector titles */
	"Load new keyboard table", "Load new compose table",

	/* POP UP menues */
	/*-------------------------- loadtab -----------*/
	"  Load *.CKB file ", /*0*/
	"  Load *.KBD file ",
	"  reset systables ",
	/*-------------------------- tableactive -------*/
	"  nothing...         ", /*3*/
	"  Keyboard           ",
	"  Compose            ",
	"  Keyboard & Compose ",
	/*-------------------------- comporder ---------*/
	"  Order indifferent ", /*7*/
	"  Order sensitive   ",
	/*-------------------------- compmode -----------*/
	"  DEC (VT) mode       ", /*9*/
	"  MultiChar mode      ",
	"  automatic MultiChar "
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_french[] = {
	"CONFIGURATION CHARACTERES COMPOSES",	/* titel config */
	"CONFIGURATION TOUCHES MORTES",			/* titel config */
	"Modifier \003",						/* 'Setup' */
	"Langue:",						/* 'language' */
	"Franáais",						/* current language */
	"La table",						/* 'The table' */
	"valide pour",					/* 'is valid for' */
	"Sauver",						/* 'Save' */
	"OK",							/* 'OK' */
	"Refuser",						/* 'Cancel' */
	"mode de compose",				/* 'compose mode' */
	"l'ordre est",					/* 'compose order' */
	"Les touches mortes sont:",		/* 'valid deadkeys are' */
	"OK",							/* 'OK' */
	"Refuser",						/* 'Cancel' */
};

char *OTHER_french[] = {
	/* ALERTS */
	"[2][ |CKBD.PRG n'est pas installÇ!][Retour]",
	"[3][ |Format du fichier incorrect][RefusÇ]",
	"[1][CPX version 1.10"
	   "|Ce logiciel est `freeware`"
	   "|par: Pascal Fellerich"
	   "|     45, rue des Genàts"
	   "|     L-3482 Dudelange][  OK  ]",

	/* Popup button labels */
	"MultiChar", "MultiAuto", "DEC (VT2xx)",
	"respectÇ", "ignorÇ",
	"rien", "Clavier", "Compose", "Clavier & Compose",
	"Franáais",

	/* Fileselector titles */
	"Table de translation KDB:", "Table CKB pour Compose:",

	/* POP UP menues */
	/*-------------------------- loadtab -----------*/
	"  Charger fichier *.CKB ", /*0*/
	"  Charger fichier *.KBD ",
	"  Çtat systäme initial  ",
	/*-------------------------- tableactive -------*/
	"  rien...           ", /*3*/
	"  Clavier           ",
	"  Compose           ",
	"  Clavier & Compose ",
	/*-------------------------- comporder ---------*/
	"  ignorÇ   ", /*7*/
	"  respectÇ ",
	/*-------------------------- compmode ----------*/
	"  mode DEC (VT)         ", /*9*/
	"  mode MultiChar        ",
	"  MultiChar automatique "
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_luxbg[] = {
	"ZESUMMEGESAATEN ZEECHEN KONFIGURATIOUN",	/* titel config */
	"DEADKEY KONFIGURATIOUN",				/* titel config */
	"Astellen \003",						/* 'Setup' */
	"Sprooch:",						/* 'language' */
	"Lâtzeburgesch",				/* current language */
	"d'Tabell",						/* 'The table' */
	"gâllt fir",					/* 'is valid for' */
	"Sâcheren",						/* 'Save' */
	"OK",							/* 'OK' */
	"Ofbroch",						/* 'Cancel' */
	"Compose Modus:",				/* 'compose mode' */
	"d'Reihenfolg ass",				/* 'compose order' */
	"Als Deadkey fonktionÇieren:",	/* 'valid deadkeys are' */
	"OK",							/* 'OK' */
	"Ofbroch",						/* 'Cancel' */
};
	
char *OTHER_luxbg[] = {
	/* ALERTS */
	"[2][ |CKBD.PRG ass nât installÇiert!][Vergiess et!]",
	"[3][ |Feler am CKB Fichier. ][Vergiess et!]",
	"[1][CPX Versioun 1.10"
	   "|Dâsen Programm ass Freeware"
	   "|vum: Pascal Fellerich"
	   "|     45, rue des Genàts"
	   "|     L-3482 Dudelange][  OK  ]",
	
	/* Popup button labels */
	"MultiChar", "MultiAuto", "DEC (VT2xx)",
	"anzehaalen", "egal",
	"nÑischt", "Tastatur", "Compose", "Tastatur & Compose",
	"Lâtzeburgesch",

	/* Fileselector titles */
	"Nei Tastaturtabell lueden", "Nei Composetabell lueden",

	/* POP UP menues */
	/*-------------------------- loadtab -----------*/
	"  Lued en *.CKB Fichier ", /*0*/
	"  Lued en *.KBD Fichier ",
	"  reset Systemtabell    ",
	/*-------------------------- tableactive -------*/
	"  nÑischt...         ", /*3*/
	"  Tastatur           ",
	"  Compose            ",
	"  Tastatur & Compose ",
	/*-------------------------- comporder ---------*/
	"  egal       ", /*7*/
	"  anzehaalen ",
	/*-------------------------- compmode -----------*/
	"  DEC (VT) Modus       ", /*9*/
	"  MultiChar Modus      ",
	"  Automatâsch MultiChar"
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/


enum OTHER_objectindex {
	NOTINSTALLED=0,
	WRONGFILEFORMAT,
	INFOBOX,
	
	MC_EXPLICIT, MC_IMPLICIT, DECVT200,
	ORDERSENS, ORDERINDIFF,
	POPNOVALID, POP2, POP3, POP4,
	MYLANGUAGE,
	
	LOADNEWKEYBOARDTABLE, LOADNEWCOMPOSETABLE,
	
	POPUPBASE
};

#define POPLOADTAB		POPUPBASE+0
#define POPTABLEACTIVE	POPUPBASE+3	
#define POPCOMPORDER	POPUPBASE+7
#define POPCOMPMODE		POPUPBASE+9



int RSC_objectindex[][2] = {
	CC_CFG,	C_CCCTITLE,
	CC_CFG,	C_DKTITLE,
	MAIN,	M_SETUP,
	MAIN,	M_LANGTITLE,
	MAIN,	M_LANGUAGE,
	MAIN,	M_TABNAME,
	MAIN,	M_TABVALID,
	MAIN,	M_SAVE,
	MAIN,	M_OK,
	MAIN,	M_ABORT,
	CC_CFG,	C_CMODE,
	CC_CFG,	C_CORDER,
	CC_CFG,	C_VALIDKEYS,
	CC_CFG,	C_OK,
	CC_CFG,	C_ABORT,
	-1
};


/* eof */
/*----------------------------------------------------------------------*/
