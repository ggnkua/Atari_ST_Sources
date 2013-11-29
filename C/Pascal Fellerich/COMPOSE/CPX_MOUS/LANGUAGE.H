/* main popup!! */


#define NUMLANGUAGES 4

char *languagestr[] = {
   	"  Deutsch        ",
   	"  English        ",
   	"  Fran‡ais       ",
   	"  L‰tzebuergesch "
};


/* Textpointer Arrays */

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_german[] = {
	"OK",							/* 'OK' */
	"Abbruch",						/* 'Cancel' */
	"Sichern",						/* 'Save' */
	"Mausbeschleuniger",			/* 'Speeder' */
	"Maustasten:",					/* mse buttons */
	"Rotation: ___ \370",			/* 'rotation' */
	"Aufl”sung: ___ dpi",			/* 'resolution' */
	"zum Polynom-Editor",			/* go to polynominal editor */
	"Auto-Anpassung",				/* Automatic mode */
	"Pixel B/H = 256:___",			/* pixel ratio */
	"Aufl”sung: ___ dpi",			/* 'resolution' */
	"Sprache:",						/* 'language' */
	"Deutsch",						/* current language */

	"BESCHLEUNIGUNGSPOLYNOMEDITOR",	/* speedup polynomial editor */
	"OK",							/* 'OK' */
	"Abbruch",						/* 'Cancel' */
	"Polynomfakt.",					/* polynomial factors */
	"Voreinstell.:",				/* poly presets */
};
	
char *OTHER_german[] = {
	/* ALERTS */
	/*   123456789012345678901234567890  */
	"[2][ "
	   "|CKBD.PRG nicht installiert? ][Abbruch]",
	"[1][CPX-Version 1.01"
	   "|Dieses Programm ist Freeware"
	   "|von: Pascal Fellerich"
	   "|     45, rue des Genˆts"
	   "|     L-3482 Dudelange][  OK  ]",
	   
	/* Popup button labels */
	"EIN","AUS",
	"L | R","R | L",
	"Minimal", "Langsam", "Normal", "Schnell", "Turbo!",
	"Deutsch",

	/* Fileselector titles */

	/* POP UP menues */
	/*-------------------------- ? ------------------*/
	"  EIN  ", /*0*/
	"  AUS  ",
	/*-------------------------- ? ------------------*/
	"  L, R  ", /*2*/
	"  R, L  ",
	/*-------------------------- Preset PopUp -------*/
	"  Sehr langsam  ",
	"  Langsam       ",
	"  Normal        ",
	"  Schnell       ",
	"  Sehr schnell  ",
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_english[] = {
	"OK",							/* 'OK' */
	"Cancel",						/* 'Cancel' */
	"Save",							/* 'Save' */
	"Mouse speeder",				/* 'Speeder' */
	"Mse buttons:", 				/* mse buttons */
	"Rotation: ___ \370",			/* 'rotation' */
	"Resolution: ___ dpi",			/* 'resolution' */
	"Polynomial editor",			/* go to polynominal editor */
	"Autodetect",					/* auto */
	"Pixel W/H 256:___",			/* pixel ratio */
	"Resolution: ___ dpi",			/* 'resolution' */
	"Language:",					/* 'language' */
	"English",						/* current language */

	"SPEEDER POLYNOMIAL EDITOR",	/* speedup polynomial editor */
	"OK",							/* 'OK' */
	"Cancel",						/* 'Cancel' */
	"polyfactors",					/* polynomial factors */
	"Presets:",						/* poly presets */
};
	
char *OTHER_english[] = {
	/* ALERTS */
	/*   123456789012345678901234567890  */
	"[2][ "
	   "|CKBD.PRG not installed? ][Cancel]",
	"[1][CPX release 1.01"
	   "|This program is freeware"
	   "|by:  Pascal Fellerich"
	   "|     45, rue des Genˆts"
	   "|     L-3482 Dudelange][  OK  ]",
	
	/* Popup button labels */
	"ON","OFF",
	"L | R","R | L",
	"Very slow", "Slow", "Normal", "Fast", "Very fast",
	"English",

	/* Fileselector titles */

	/* POP UP menues */
	/*-------------------------- ? ------------------*/
	"  ON   ", /*0*/
	"  OFF  ",
	/*-------------------------- ? ------------------*/
	"  L, R  ", /*2*/
	"  R, L  ",
	/*---------------------- speed popup ------------*/
	"  Very slow  ",
	"  Slow       ",
	"  Normal     ",
	"  Fast       ",
	"  Very fast  ",
	
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_french[] = {
	"OK",							/* 'OK' */
	"Refuser",						/* 'Cancel' */
	"Sauver",						/* 'Save' */
	"Acc‚l‚rateur",					/* 'Speeder' */
	"Touches:",						/* mse buttons */
	"Rotation: ___ \370",			/* 'rotation' */
	"R‚solution: ___ dpi",			/* 'resolution' */
	"‚diteur de polynome",			/* go to polynominal editor */
	"autod‚tection",				/* auto */
	"Rapport W/H 256:___",			/* pixel ratio */
	"R‚solution: ___ dpi",			/* 'resolution' */
	"Langue:",						/* 'language' */
	"Fran‡ais",						/* current language */

	"EDITEUR DU POLYNOME D'ACCELERATION",	/* speedup polynomial editor */
	"OK",							/* 'OK' */
	"Refuser",						/* 'Cancel' */
	"facteurs p(x):",				/* polynomial factors */
	"Pr‚s‚lection",					/* poly presets */
};

char *OTHER_french[] = {
	/* ALERTS */
	/*   123456789012345678901234567890  */
	"[2][ "
	   "|CKBD.PRG n'est pas install‚!][Continuer]",
	"[1][CPX version 1.01"
	   "|Ce logiciel est `freeware`"
	   "|par: Pascal Fellerich"
	   "|     45, rue des Genˆts"
	   "|     L-3482 Dudelange][  OK  ]",
	
	/* Popup button labels */
	"ON","OFF",
	"L | R","R | L",
	"TrŠs lent", "Lent", "Normal", "Vite", "TrŠs vite",
	"Fran‡ais",

	/* Fileselector titles */

	/* POP UP menues */
	/*-------------------------- ? ------------------*/
	"  ON  ", /*0*/
	"  OFF ",
	/*-------------------------- ? ------------------*/
	"  L, R ", /*2*/
	"  R, L ",
	/*------------------------ vitesse popup --------*/
	"  TrŠs lent  ",
	"  Lent       ",
	"  Normal     ",
	"  Vite       ",
	"  TrŠs vite  ",
	
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/

char *RSC_luxbg[] = {
	"OK",							/* 'OK' */
	"Ofbroch",						/* 'Cancel' */
	"S‰cheren",						/* 'Save' */
	"Maus-speeder",					/* 'Speeder' */
	"Mauskn„pp:",					/* mse buttons */
	"Rotatioun: ___ \370",			/* 'rotation' */
	"Opl‚isung: ___ dpi",			/* 'resolution' */
	"zum Polynomeditor",			/* go to polynominal editor */
	"Auto Upassung",				/* AutoMode */
	"Pixel B/H 256:___",			/* pixel ratio */
	"Opl‚isung: ___ dpi",			/* 'resolution' */
	"Sprooch:",						/* 'language' */
	"L‰tzebuergesch",				/* current language */

	"ACCELERATIOUNSPOLYNOMEDITOR",	/* speedup polynomial editor */
	"OK",							/* 'OK' */
	"Ofbroch",						/* 'Cancel' */
	"Polynomfakt.",					/* polynomial factors */
	"Preset",						/* poly presets */
};
	
char *OTHER_luxbg[] = {
	/* ALERTS */
	/*   123456789012345678901234567890  */
	"[2][ "
	   "|CKBD.PRG ass n‰t install‚iert!][Vergiess ‰t]",
	"[1][CPX Versioun 1.01"
	   "|D‰sen Programm ass Freeware"
	   "|vum: Pascal Fellerich"
	   "|     45, rue des Genˆts"
	   "|     L-3482 Dudelange][  OK  ]",
	
	/* Popup button labels */
	"UN","AUS",
	"L | R","R | L",
	"Adagio", "Andante", "Moderato", "Allegro", "Presto",
	"L‰tzebuergesch",

	/* Fileselector titles */

	/* POP UP menues */
	/*-------------------------- ? ------------------*/
	"  UN   ", /*0*/
	"  AUS  ",
	/*-------------------------- ? ------------------*/
	"  L, R ", /*2*/
	"  R, L ",
	/*------------------------ egal wat -------------*/
	"  Adagio    ", /*4*/
	"  Andante   ",
	"  Moderato  ",
	"  Allegro   ",
	"  Presto    ",
	
};

/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*/


enum OTHER_objectindex {
	NOTINSTALLED=0,
	INFOBOX,
	
	POP_ON, POP_OFF,
	POP_LR, POP_RL,
	POP_S1, POP_S2, POP_S3, POP_S4, POP_S5, 
	MYLANGUAGE,
	
	POPUPBASE
};

#define POP_ONOFF		POPUPBASE+0
#define POP_MBUT		POPUPBASE+2
#define POP_SPEED		POPUPBASE+4


int RSC_objectindex[][2] = {
	MAIN,	M_OK,
	MAIN,	M_ABORT,
	MAIN,	M_SAVE,
	MAIN,	M_MOUSESPEEDER,
	MAIN,	M_MOUSEBUTTON,
	MAIN,	M_ROTATION,
	MAIN,	M_MRESOLUTION,
	MAIN,	M_POLYNOMEDIT,
	MAIN,	M_AUTOMATIC,
	MAIN,	M_ASPECTRATIO,
	MAIN,	M_SRESOLUTION,
	MAIN,	M_LANGTITLE,
	MAIN,	M_LANGUAGE,

	POLY_ED,	P_TITLE,
	POLY_ED,	P_OK,
	POLY_ED,	P_ABORT,
	POLY_ED,	P_POLYFACTORS,
	POLY_ED,	P_PRESETS,
	-1
};


/* eof */
/*----------------------------------------------------------------------*/
