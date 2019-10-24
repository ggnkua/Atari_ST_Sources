/*
 * Fn_Vdt.c
 *
 * Fonctions pages vdt: 
 *
 * fplanque: Created
 */

/*
 * Variables:
 *
 * Equivalent texte:
 */
static	FNCTSPEC			M_fnctVdtInput[]=
	{
		FE_FOND,				"Fond d'‚cran",
		FE_CHGREC,			"Changmt Messge",
		FE_CHGPAGE,			"Changmt Page",
		FE_LOGINDENIED,	"Login Refus‚",

		FEI_CMD,				"Ligne Commande",
		FEI_PUBPRIV,		"Public/Priv‚",

		FEI_USERNAME,		"UserName",
		FEI_FIRSTNAME,		"Pr‚nom",
		FEI_LASTNAME,		"Nom",
		FEI_PASSWORD,		"Mot de Passe",

		FEI_OFFICE,			"Fonction",

		FEI_ADDRESS1,		"Adresse 1",
		FEI_ADDRESS2,		"Adresse 2",
		FEI_ZIP,				"Code Postal",
		FEI_TOWN,			"Ville",
		FEI_STATE,			"Etat",
		FEI_COUNTRY,		"Pays",

		FEI_PHONE,			"T‚l‚phone",
		FEI_FAX,				"Fax",
		FEI_MODEM,			"AccŠs Modem",

		FEI_DEST,			"Destinataire",
		FEI_TITLE,			"Saisie Titre",
		FEI_TEXT,			"Saisie Texte"
	};



/*
 * PAGE STANDARD
 */
static	ARBO_TEXTPAR	M_stdpecran[]=
	{
		NULL,	FE_FOND,	NULL,
		NULL,	FEI_CMD,	NULL,
		NULL,	NIL_1,	NULL
	};			
static	ARBO_TEXTPAR	*M_std_pecran;



/*
 * PAGE LECT_MSG
 */
static	ARBO_TEXTPAR	M_lectpecran[]=
	{
		NULL,	FE_FOND,		"DEFLECFN.VDT",
		NULL,	FE_CHGREC,	NULL,
		NULL,	FE_CHGPAGE,	NULL,
		NULL,	FEI_CMD,		NULL,
		NULL,	NIL_1,		NULL
	};			
static	ARBO_TEXTPAR	*M_lect_pecran;


/*
 * PAGE ECRITURE
 */
static	ARBO_TEXTPAR	M_ecripecran[]=
	{
		NULL,	FE_FOND,			"DEFECRFN.VDT",
		NULL,	FEI_PUBPRIV,	NULL,		/* 11/12/94 */
		NULL,	FEI_TITLE,		NULL,
		NULL,	FEI_DEST,		NULL,		/* 11.12.94 */
		NULL,	FEI_TEXT,		NULL,
		NULL,	NIL_1,			NULL
	};			
static	ARBO_TEXTPAR	*M_ecri_pecran;


/*
 * PAGE FA_DISP_TEXT
 */
static	ARBO_TEXTPAR	M_DispText_PEcrDefs[]=
	{
		NULL,	FE_FOND,			"DEFTXTFN.VDT",
		NULL,	FE_CHGPAGE,		NULL,
		NULL,	FEI_CMD,			NULL,
		NULL,	NIL_1,			NULL
	};			
static	ARBO_TEXTPAR	*	M_DispText_PEcrans;


/*
 * PAGE IDENTIFICATION
 */
static	ARBO_TEXTPAR	M_IdPEcran[]=
	{
		NULL,	FE_FOND,				"DEFIDFND.VDT",
		NULL,	FE_LOGINDENIED,	NULL,
		NULL,	FEI_USERNAME,		NULL,
		NULL,	FEI_FIRSTNAME,		NULL,
		NULL,	FEI_LASTNAME,		NULL,
		NULL,	FEI_PASSWORD,		NULL,
		NULL,	NIL_1,				NULL
	};			
static	ARBO_TEXTPAR	*M_Id_pecran;



/*
 * PAGE NEW_ACCOUNT
 */
static	ARBO_TEXTPAR	M_NewAccPEcran[]=
	{
		NULL,	FE_FOND,				"DEFNEWAC.VDT",
		NULL,	FEI_USERNAME,		NULL,
		NULL,	FEI_FIRSTNAME,		NULL,
		NULL,	FEI_LASTNAME,		NULL,
		NULL,	FEI_PASSWORD,		NULL,
		NULL,	FEI_OFFICE,			NULL,
		NULL,	FEI_ADDRESS1,		NULL,
		NULL,	FEI_ADDRESS2,		NULL,
		NULL,	FEI_ZIP,				NULL,
		NULL,	FEI_TOWN,			NULL,
		NULL,	FEI_STATE,			NULL,
		NULL,	FEI_COUNTRY,		NULL,
		NULL,	FEI_PHONE,			NULL,
		NULL,	FEI_FAX,				NULL,
		NULL,	FEI_MODEM,			NULL,
		NULL,	NIL_1,				NULL
	};			
static	ARBO_TEXTPAR	*M_NewAcc_pecran;



/*
 * PAGE FA_LIST
 */
static	ARBO_TEXTPAR	M_ListPEcran[]=
	{
		NULL,	FE_FOND,		"DEFLSTFN.VDT",
		NULL,	FE_CHGPAGE,	"DEFLSTCH.VDT",
		NULL,	FEI_CMD,		NULL,
		NULL,	NIL_1,		NULL
	};			
static	ARBO_TEXTPAR	*M_List_pecran;


/*
 * PAGE FA_DIRECTORY
 */
static	ARBO_TEXTPAR	M_DirPEcran[]=
	{
		NULL,	FE_FOND,		"DEFLSTFN.VDT",
		NULL,	FE_CHGPAGE,	"DEFLSTCH.VDT",
		NULL,	FEI_CMD,		NULL,
		NULL,	NIL_1,		NULL
	};			
static	ARBO_TEXTPAR	*M_Dir_pecran;


/*
 * PAGE FA_FILESEL
 */
static	ARBO_TEXTPAR	M_FileSelPEcran[]=
	{
		NULL,	FE_FOND,		"DEFFLSEL.VDT",
		NULL,	FE_CHGPAGE,	NULL,
		NULL,	FEI_CMD,		NULL,
		NULL,	NIL_1,		NULL
	};			
static	ARBO_TEXTPAR	*M_FileSel_PEcran;


/*
 * PAGE FA_DOWNLOAD
 */
static	ARBO_TEXTPAR	M_DownLoadPEcran[]=
	{
		NULL,	FE_FOND,		"DEFDWNLD.VDT",
		NULL,	NIL_1,		NULL
	};			
static	ARBO_TEXTPAR	*M_DownLoad_PEcran;

