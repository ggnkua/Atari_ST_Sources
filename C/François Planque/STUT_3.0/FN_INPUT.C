/*
 * Fn_Input.c
 *
 * Fonctions saisie/Input: 
 *
 * fplanque: Created
 */

/*
 * Variables:
 */

/*
 * page standard: 
 */
static	INPUT_FPAR		M_Std_InDefs[]=
	{
		FEI_CMD, 'N.A.',	{-1,  0,  0, -1,  0,  0,  0, 0, 0},	2,	24, 38, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE, 1, 0, NULL,
		NIL,		'N.A.',	{ 0,  0,  0, -1,  0,  0,  0, 0, 0},	0,  0,  0, 0,  NUL,  NUL,  MBLEU, MBLANC, FILTER_NONE, 0, 0, NULL
	};
static	ARBO_FIELDPARS	* M_Std_InFields;		


/*
 * page ECRITURE: 
 */
static	INPUT_FPAR		M_Ecri_InDefs[]=
	{
		FEI_PUBPRIV,'N.A.',	{-1,  0, -1, -1,  0,  0, 0, 0, 0}, 16, 3,  1,  1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NAME_NOSPC,1, 0, NULL,
		FEI_DEST,	'DSTA',	{-1,  0,  0, -1,  0,  0, 0, 0, 0}, 16, 4,  8,  1,  '.',  NUL,  MBLEU, MBLANC, FILTER_USERNAME, 	1, 0, NULL,
		FEI_TITLE,	'MTIT',	{-1,  0, -1, -1,  0,  0, 0, 0, 0},	9, 6, 31,  1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE,		1, 0, NULL,
		FEI_TEXT,	'MTXT',	{-1, -1, -1, -1,  0,  0, 0, 0, 0},	2, 8, 38, 13,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE,	5000, 0, NULL,
		NIL,			'N.A.',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	0,  0,  0, 0,  NUL,  NUL,  MBLEU, MBLANC, FILTER_NONE,		0, 0, NULL
	};
static	ARBO_FIELDPARS	* M_Ecri_InFields;		


/*
 * page FA_ID: 
 */
static	INPUT_FPAR		M_Id_InDefs[]=
	{
		FEI_USERNAME,	'N.A.',	{-1,  0, -1, -1,  0,  0, 0, 0, 0},	17, 12,  8, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_USERNAME, 1, 0, NULL,
		FEI_FIRSTNAME,	'N.A.',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	17,  9, 28, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NAME_NOSPC, 1, 0, NULL,
		FEI_LASTNAME,	'N.A.',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	17, 10, 28, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NAME_SPACE, 1, 0, NULL,
		FEI_PASSWORD,	'N.A.',	{-1,  0,  0, -1,  0,  0, 0, 0, 0},	17, 14, 16, 1,  '.',  '*',  MBLEU, MROUGE, FILTER_PASSWORD, 1, 0, NULL,
		NIL,				'N.A.',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	 0,  0,  0, 0,  NUL,  NUL,  MBLEU, MBLANC, FILTER_NONE, 0, 0, NULL
	};
static	ARBO_FIELDPARS	* M_Id_InFields;		



/*
 * page FA_NEW_ACCOUNT: 
 */
static	INPUT_FPAR		M_NewAcc_InDefs[]=
	{
		FEI_USERNAME,	'USER',	{-1,  0, -1, -1,  0,  0, 0, 0, 0},	13,  5,  8, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_USERNAME, 	1, 0, NULL,
		FEI_FIRSTNAME,	'1STN',	{-1,  0, -1, -1,  0,  0, 0, 0, 0},	13,  6, 12, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NAME_NOSPC,	1, 0, NULL,
		FEI_LASTNAME,	'LSTN',	{-1,  0, -1, -1,  0,  0, 0, 0, 0},	13,  7, 20, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NAME_SPACE,	1, 0, NULL,
		FEI_PASSWORD,	'PASS',	{-1,  0, -1, -1,  0,  0, 0, 0, 0},	13,  9, 12, 1,  '.',  '*',  MBLEU, MROUGE, FILTER_PASSWORD, 	1, 0, NULL,
		FEI_OFFICE,		'OFFC',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	13, 16, 20, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE, 			1, 0, NULL,
		FEI_ADDRESS1,	'ADR1',	{ 0, -1,  0, -1,  0,  0, 0, 0, 0},	13, 17, 25, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE, 			2, 0, NULL,
		FEI_ADDRESS2,	'ADR2',	{ 0, -1,  0, -1,  0,  0, 0, 0, 0},	13, 18, 25, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE, 			2, 0, NULL,
		FEI_ZIP,			'ZIPC',	{-1,  0,  0, -1,  0,  0, 0, 0, 0},	 6, 11,  5, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NUMERIC,		1, 0, NULL,
		FEI_TOWN,		'TOWN',	{-1,  0,  0, -1,  0,  0, 0, 0, 0},	19, 11, 22, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE, 			1, 0, NULL,
		FEI_STATE,		'ETAT',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	13, 19, 15, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NONE, 			1, 0, NULL,
		FEI_COUNTRY,	'PAYS',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	13, 20, 15, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_NAME_SPACE,	1, 0, NULL,
		FEI_PHONE,		'PHON',	{-1,  0,  0, -1,  0,  0, 0, 0, 0},	13, 13, 15, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_PHONE,			1, 0, NULL,
		FEI_FAX,			'FAXN',	{-1,  0,  0, -1,  0,  0, 0, 0, 0},	13, 14, 15, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_PHONE,			1, 0, NULL,
		FEI_MODEM,		'MODM',	{-1,  0,  0, -1,  0,  0, 0, 0, 0},	13, 15, 15, 1,  '.',  NUL,  MBLEU, MBLANC, FILTER_PHONE,			1, 0, NULL,
		NIL,				'N.A.',	{ 0,  0,  0, -1,  0,  0, 0, 0, 0},	 0,  0,  0, 0,  NUL,  NUL,  MBLEU, MBLANC, FILTER_NONE, 			0, 0, NULL
	};
static	ARBO_FIELDPARS	* M_NewAcc_InFields;		
