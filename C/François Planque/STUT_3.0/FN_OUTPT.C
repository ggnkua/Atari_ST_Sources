/*
 * Fn_Output.c
 *
 * Fonctions sortie/Output: 
 *
 * fplanque: Created
 */

/*
 * Variables:
 */
static	FNCTSPEC			M_fnctsortie[]=
	{
		FO_COMMENT,			"Commentaire",
		FO_DATACOMMENT,	"Comment DB",
		FO_TEXTCOMMENT,	"Comment Text",
		FO_RECNUMBER,		"No Enregist.",
		FO_PAGENUMBER,		"No Page/Messag",
		FO_CREATEDATE,		"Date Cr‚ation",
		FO_PUBPRIV,			"Public/Priv‚",
		FO_PATH,				"Chemin d'accŠs",
		FO_NBFILES,			"Nb de Fichiers",
		FO_FILENAME,		"Nom de Fichier",
		FO_FILEATTRIB,		"Attrbs Fichier",
		FO_FILEDATE,		"Date Fichier",
		FO_FILESIZE,		"Taille Fichier",
		FO_USERNAME,		"UserName",
		FO_FIRSTNAME,		"Pr‚nom",
		FO_LASTNAME,		"Nom",
		FO_TITLE,			"Titre     MTIT",
		FO_TEXT,				"Texte    /MTXT",
		FO_DSTA,				"AdrDest   DSTA",
		FO_MPSE,				"Auteur    MPSE"
	};


/*
 * Formats d'affichage:
 */
static POPUP_ENTRY	M_Format_menu[]=
	{	
		"  Standard",				FMT_STANDARD,
		NULL,							0xFFFF
	};

static POPUP_ENTRY	M_FmtNumber_menu[]=
	{	
		"  1234",					FMT_NUMBER_LEFT,
		"    1234",					FMT_NUMBER_RIGHT,
		"  001234",					FMT_NUMBER_ZEROS,
		NULL,							0xFFFF
	};
	
static POPUP_ENTRY	M_FmtDate_menu[]=
	{	
		"  Standard",				FMT_DATE_STD,
		"  24 Mar 1995 23:..",	FMT_DATE_JmAAHMS,
		"  24 Mar 95 23:00..",	FMT_DATE_JmAHMS,
		"  24.03.1995 23:0..",	FMT_DATE_JMAAHMS,
		"  24.03.95 23:00:00",	FMT_DATE_JMAHMS,
		"  24/03 23:00:00",		FMT_DATE_JMHMS,
		"  Fri 24.03.95 23..",	FMT_DATE_JJMAHMS,
		"  Fri 24/03 23:00..",	FMT_DATE_JJMHMS,
		"  23:00:00",				FMT_DATE_HMS,
		"  11:00:00 PM",			FMT_DATE_HMSP,
		"  11:00 PM",				FMT_DATE_HMP,
		"  23h",						FMT_DATE_H,
		NULL,							0xFFFF
	};

static POPUP_ENTRY	M_FmtFileSize_menu[]=
	{	
		"  Octets",					FMT_FILESIZE_OCTETS,
		"  Kilo-Octets",			FMT_FILESIZE_KOCTETS,
		NULL,							0xFFFF
	};


/*
 * page ECRITURE: 
 */
static	OUTPUT_FPAR		M_Ecri_OutDefs[]=
	{
		FO_COMMENT,		'N.A.',	{ 0, -1, 0,  0, 1, 0 },	 3, 1, 36,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	
		FO_DATACOMMENT,'N.A.',	{-1, -1, 0,  0, 1, 0 },	20, 2, 20,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	 
		NIL,				'N.A.',	{-1,  0, 0,  0, 0, 0 },	 0, 0,  0,  0, MMAGENTA, MCYAN, FMT_STANDARD, 0     
	};
static	ARBO_FIELDPARS	* M_ecri_OutFields;		


/*
 * page LECTURE: 
 */
static	OUTPUT_FPAR		M_Lect_OutDefs[]=
	{
		FO_COMMENT,		'N.A.',	{ 0, -1, 0,  0, 1, 0 },	 3, 1, 36,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	
		FO_DATACOMMENT,'N.A.',	{-1, -1, 0,  0, 1, 0 },	19, 2, 21,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	
		FO_RECNUMBER,	'N.A.',	{-1, -1, 0, -1, 2, 0 },	38, 4,  2,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,
		FO_CREATEDATE,	'N.A.',	{-1, -1, 0, -1, 2, 0 },	12, 3, 26,  1, MROUGE, 	MCYAN, FMT_DATE_JMAHMS, 0,
		FO_PUBPRIV,		'N.A.',	{-1, -1, 0, -1, 2, 0 },	 6, 3,  1,	1, MROUGE, 	MCYAN, FMT_STANDARD, 0,
		FO_DSTA,			'DSTA',	{-1, -1, 0, -1, 2, 0 },	 8, 5, 25,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,
		FO_MPSE,			'MPSE',	{-1, -1, 0, -1, 2, 0 },	 6, 4, 10,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,
		FO_TITLE,		'MTIT',	{-1,  0, 0, -1, 2, 0 },	 9, 7, 31,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,	
		FO_PAGENUMBER,	'N.A.',	{-1, -1, 0, -1, 4, 0 },	38, 5,  2,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,
		FO_TEXT,			'MTXT',	{-1,  0, 0, -1, 4, 0 },	 2, 9, 38, 12, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		NIL,				'N.A.',	{-1,  0, 0,  0, 0, 0 },	 0, 0,  0,  0, MMAGENTA, MCYAN, FMT_STANDARD, 0     
	};
static	ARBO_FIELDPARS	* M_lect_OutFields;		



/*
 * page DISP_TEXT: 
 */
static	OUTPUT_FPAR		M_DispText_OutDefs[]=
	{
		FO_COMMENT,		'N.A.',	{0,  0, 0,  0, 1, 0 },	 3, 1, 36,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	
		FO_TEXTCOMMENT,'N.A.',	{-1, 0, 0,  0, 1, 0 },	 3, 2, 36,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,	
		FO_TEXT,			'N.A.',	{-1, 0, 0, -1, 4, 0 },	 2, 4, 38, 19, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		NIL,				'N.A.',	{-1, 0, 0,  0, 0, 0 },	 0, 0,  0,  0, MMAGENTA, MCYAN, FMT_STANDARD, 0     
	};
static	ARBO_FIELDPARS	* M_DispText_OutFields;		




/*
 * page FA_LIST: 
 */
static	OUTPUT_FPAR		M_List_OutDefs[]=
	{
		FO_COMMENT,		'N.A.',	{-1,  0, 0,  0, 1, 0 },	 3, 2, 36,  1, MVERT, MCYAN, FMT_STANDARD, 0,	
		FO_DATACOMMENT,'N.A.',	{ 0,  0, 0,  0, 1, 0 },	19, 2, 21,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,	
		FO_RECNUMBER,	'N.A.',	{-1,  0, 0,  0, 4, 0 },	 2, 4,  3,  1, MBLANC,	 MCYAN, FMT_STANDARD, 0,
		FO_CREATEDATE,	'N.A.',	{-1,  0, 0,  0, 4, 0 },	32, 4,  8,  1, MROUGE,	 MCYAN, FMT_DATE_JMAHMS, 0,
		FO_PUBPRIV,		'N.A.',	{-1,  0, 0,  0, 4, 0 },	 5, 4,  1,	1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_MPSE,			'MPSE',	{-1,  0, 0,  0, 4, 0 },	 7, 4,  8,  1, MJAUNE,	 MCYAN, FMT_STANDARD, 0,
		FO_DSTA,			'DSTA',	{-1,  0, 0,  0, 4, 0 },	17, 4, 13,  1, MBLEU, 	 MCYAN, FMT_STANDARD, 0,
		FO_TITLE,		'MTIT',	{-1,  0, 0,  0, 4, 0 },	 9, 5, 31,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,	
		NIL,				'N.A.',	{-1,  0, 0,  0, 0, 0 },	 0, 0,  0,  0, MMAGENTA, MCYAN, FMT_STANDARD, 0     
	};
static	ARBO_FIELDPARS	* M_List_OutFields;		
/*
 * Params liste par d‚faut:
 */
static	ARBO_LISTPARS  M_AListPars_Def = { 0, 6, 1, 3, 15, 0, 0 };
	

/*
 * page FA_DIRECTORY: 
 */
static	OUTPUT_FPAR		M_Dir_OutDefs[]=
	{
		FO_COMMENT,		'N.A.',	{ 0,  0, 0,  0, 1, 0 },	 3, 1, 36,  1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	
		FO_DATACOMMENT,'N.A.',	{-1,  0, 0,  0, 1, 0 },	19, 2, 21,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,	
		FO_RECNUMBER,	'N.A.',	{-1,  0, 0, -1, 4, 0 },	 2, 4,  3,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_USERNAME,	'USER',	{-1,  0, 0, -1, 4, 0 },	 6, 4,  8,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_FIRSTNAME,	'1STN',	{-1,  0, 0, -1, 4, 0 },	 6, 5, 15,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_LASTNAME,	'LSTN',	{-1,  0, 0, -1, 4, 0 },	20, 5, 15,  1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		NIL,				'N.A.',	{-1,  0, 0,  0, 0, 0 },	 0, 0,  0,  0, MMAGENTA, MCYAN, FMT_STANDARD, 0     
	};
static	ARBO_FIELDPARS	* M_Dir_OutFields;		


/*
 * page FA_FILESEL: 
 */
static	OUTPUT_FPAR		M_FileSel_OutDefs[]=
	{
		FO_COMMENT,		'N.A.',	{0,   0, 0,  0, 1, 0 },	 3, 1, 36, 1, MROUGE, 	MCYAN, FMT_STANDARD, 0,	
		FO_PATH,			'N.A.',	{-1,  0, 0, -1, 2, 0 },	 2, 5, 38, 2, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_NBFILES,		'N.A.',	{-1,  0, 0,  0, 2, 0 },	36, 4,  4, 1, MMAGENTA, MCYAN, FMT_NUMBER_RIGHT, 0,
		FO_RECNUMBER,	'N.A.',	{-1,  0, 0, -1, 4, 0 },	 2, 9,  3, 1, MBLANC,	MCYAN, FMT_NUMBER_RIGHT, 0,
		FO_FILEATTRIB,	'N.A.',	{-1,  0, 0, -1, 4, 0 },	 6, 9, 12, 1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_FILENAME,	'N.A.',	{-1,  0, 0, -1, 4, 0 },	12, 9, 12, 1, MMAGENTA, MCYAN, FMT_STANDARD, 0,
		FO_FILEDATE,	'N.A.',	{-1,  0, 0, -1, 4, 0 },	25, 9,  8, 1, MROUGE,	MCYAN, FMT_DATE_JMAHMS, 0,
		FO_FILESIZE,	'N.A.',	{-1,  0, 0, -1, 4, 0 },	33, 9,  5, 1, MMAGENTA, MCYAN, FMT_FILESIZE_KOCTETS, 0,
		NIL,				'N.A.',	{-1,  0, 0,  0, 0, 0 },	 0, 0,  0, 0, MMAGENTA, MCYAN, FMT_STANDARD, 0     
	};
static	ARBO_FIELDPARS	* M_FileSel_OutFields;		
/*
 * Params liste par d‚faut:
 */
static	ARBO_LISTPARS  M_AListPars_FSelDef = { 0, 12, 1, 1, 1, 0, 0 };
