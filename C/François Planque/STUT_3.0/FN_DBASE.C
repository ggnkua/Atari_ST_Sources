/*
 * Fn_Base.c
 *
 * Fonctions Bases de donn‚es: 
 *
 * 04.01.94: fplanque: Created
 */

/*
 * Variables:
 */

static	FNCTSPEC		M_fnctData[]=
	{
		FB_RUB,			"Rubrique",
		FB_DIRECTORY,	"Annuaire",
		
		FT_TEXT,			"Texte"
	};



/*
 * page ECRITURE: 
 */
static	ARBO_TEXTPAR	M_Ecri_DBDefs[]=
	{
		NULL,	FB_RUB,			"MESSAGES.RUB",
		NULL,	FB_DIRECTORY,	"ANNUAIRE.DIR",
		NULL,	NIL,				NULL
	};
static	ARBO_TEXTPAR	* M_Ecri_DBs;		


/*
 * page FA_LECT: 
 * page FA_LIST:
 */
static	ARBO_TEXTPAR	M_Lect_DBDefs[]=
	{
		NULL,	FB_RUB,	"MESSAGES.RUB",
		NULL,	NIL,		NULL
	};
static	ARBO_TEXTPAR	* M_Lect_DBs;		


/*
 * page FA_DISP_TEXT: 
 */
static	ARBO_TEXTPAR	M_DispText_DBDefs[]=
	{
		NULL,	FT_TEXT,	"INFO.TXT",
		NULL,	NIL,		NULL
	};
static	ARBO_TEXTPAR	* M_DispText_DBs;		



/*
 * page FA_ID: 
 * page FA_NEW_ACCOUNT: 
 * page FA_DIRECTORY:
 */
static	ARBO_TEXTPAR	M_Id_DBDefs[]=
	{
		NULL,	FB_DIRECTORY,	"ANNUAIRE.DIR",
		NULL,	NIL,				NULL
	};
static	ARBO_TEXTPAR	* M_Id_DBs;		

