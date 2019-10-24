/*
 * pagecran.c
 *
 * Purpose:
 * --------
 * Cr‚ation des pages ‚cran
 *
 * History:
 * --------
 * 18.06.1994: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"PAGECRAN.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<string.h>   
	#include	<stdlib.h> 
	#include <time.h>
	#include <errno.h>

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "DEBUG_PU.H"
	#include "PROGR_PU.H"
	#include "DATPG_PU.H"
	#include "DTDIR_PU.H"
	#include "DESK_PU.H"
	#include "MAIN_PU.H"
	#include "OBJCT_PU.H"
	#include "PGECR_PU.H"
	#include "RAMSL_PU.H"
	#include "RTERR_PU.H"
	#include "SPEC_PU.H"
	#include	"TERM_PU.H"	
	#include	"MINITEL.H"	
	#include	"TEXT_PU.H"
	#include "WIN_PU.H"

/*
 * 03.08.94: n_1stCode est maintenant un int
 */
typedef
	struct
	{
		char	*	pS_inst;
		int		n_1stCode;
		char		c_procIdx;
		char		c_GraphStop;
	}
	COMPILE_CODE;

typedef
	struct
	{
		char	*	psz_Var;
		char	*	psz_Val;
	}
	VARIABLE;

typedef
	struct	
	{
		char		c_code;
		char	*	psz_instruct;
	}
	DECOMPILE_ESCAPE;

	enum
	{ 
		CODE_NONE,
		CODE_INK,
		CODE_PAPER,
		CODE_LINE0,
		CODE_TEXT,
		CODE_POS,
		CODE_LOCATE,
		CODE_REP,
		CODE_CODE,
		CODE_FLASH,
		CODE_INVERSE,
		CODE_LINE,
		CODE_SIZE,
		CODE_SCROLL,
		CODE_SGCHAR
	};

enum {
	STATUS_ERR_FILEEND = -1000, 
	STATUS_ERR_LINEEND,
	STATUS_ERR_TOOLONG,
	STATUS_ERR_NOTOKEN,
	STATUS_ERR_UNKNOWN,
	STATUS_ERR_OUTOFRANGE,
	
	STATUS_PROGRESS,
	STATUS_INSTRUCTOK };

/*
 * S‚parateur d'arguments:
 */
#define	ARGUMENT_SPERATOR 0xFF
	char	* psz_ArgumentSeparator = "\xFF";

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	/*
	 * Accents:
	 */
	extern	char	*convert_Asc2Vdt( 		/* Out: Ptr sur tampon de caractŠres ‚quivalents */
							char	c_ascii );		/* In:  caractŠre … traduire */

	
/*
 * PRIVate INTernal prototypes:
 */
	static	DATAPAGE *	add_datapage(
									DATATYPE		DataType,		/* In: Grp de donn‚es ds lequel on cr‚e */
									const char*	psz_DefName );	/* In: Nom par d‚faut */
	static	void decomp_vdt2text(
								DATABLOCK	*	pDataBlock,
								const	char	*	cpsz_name,			/* In: Nom de la page qu'on d‚compile */
								const char	*	cpsz_NomText,		/* In: Nom du fichier destination */
								TEXTINFO		*	pTextInfo );
	static	size_t	compile_text2vdt(						/* Out: Taille de la page compil‚e */
								TEXTINFO 	* pTextInfo,		/* In:  Ptr sur texte source */
								const char  * cpBsz_Nom,		/* In:  Nom de la page … afficher ds progress */
								char	 * *	ppm_OutputBuf );	/* Out: Ptr sur buffer contenant le code compil‚ */
	static	BOOL	translate_inst2code( 
								char	*	pS_inst,
								char	*	pS_arg1,		/* In: Premier paramŠtre */
								char	*	pS_arg2 );	/* In: DeuxiŠme paramŠtre */
	static	int	filter_memcpy( 
							char	*	pm_dest,
							char	*	pm_source,
							int		n_length );



/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * External variables: 
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	WIPARAMS	*G_wi_list_adr;			/* Adresse de l'arbre de paramŠtres */
	extern	char		*G_tmp_buffer;				/* Peut contenir un texte long de 511 signes + '\0' */
	extern	char		*G_2nd_buffer;				/* 2Šme buffer */
	extern	char		*G_empty_string;			/* Chaine vide */
	/* 
	 * Serial: 
	 */
	extern	int	G_term_dev;			/* Port utilis‚ par icone terminal */


/*
 * Private variables: 
 */
	/*
	 * Constantes:
	 */
	VARIABLE		M_Constantes[]=
						{
							"ON"		,	"1",
							"OFF"		,	"0",
							"NORMAL"	,	"0",
							"HIGH"	,	"1",
							"WIDE"	,	"2",
							"DOUBLE"	,	"3",
							NULL		,	NULL
						};
	int	M_nbConstantes;		/* Nbre de constantes: initialis‚ dans init_PagesEcran */
	/* 
	 * Codes Minitel pour COMPILATION:
	 * aussi utilis‚ pour DECOMPILATION en ce qui concerne
	 * les insts cod‚es sur 1 seul octet
	 */
	COMPILE_CODE	M_TCC_minitel[]=
		{
			"bell"		,	BEL		,	0,					0,
			"can"			,	CAN		,	0,					0,
			"cls"			,	FF			,	0,					1,
			"code"		,	NIL_1		,	CODE_CODE,		0,
			"cr"			,	CR			,	0,					0,
			"csroff"		,	CSR_OFF	,	0,					0,
			"csron"		,	CSR_ON	,	0,					0,
			"down"		,	LF			,	0,					0,
			"flash"		,	ESC		,	CODE_FLASH,		0,
			"graphmode"	,	SO			,	0,					2,
			"home"		,	HOME		,	0,					1,
			"ink"			,	ESC		,	CODE_INK,		0,
			"inverse"	,	ESC		,	CODE_INVERSE,	0,
			"left"		,	BS			,	0,					0,
			"line"		,	ESC		, 	CODE_LINE,		0,
			"line0"		,	US			,	CODE_LINE0,		1,
			"loc"			,	US			,	CODE_LOCATE,	1,
			"nul"			,	NUL		,	0,					0,
			"paper"		,	ESC		,	CODE_PAPER,		0,
			"pos"			,	US			,	CODE_POS,		1,
			"repeat"		,	REP		,	CODE_REP,		0,
			"right"		,	HT			,	0,					0,
			"scroll"		,	ESC		,	CODE_SCROLL,	0,
			"size"		,	ESC		,	CODE_SIZE,		0,
			"text"		,	NIL_1		,	CODE_TEXT,		0,
			"textmode"	,	SI			,	0,					1,
			"up"			,	VT			,	0,					0,
			"Graph"		,	NIL_1		,	CODE_SGCHAR,	0,
			NULL			,	0			,	0,					0
		};
	int	M_nbCodesMinitel;		/* Nbre d'instructions: initialis‚ dans init_PagesEcran */
	/*
	 * S‚quences escape pour DECOMPILATION:
	 */
	DECOMPILE_ESCAPE M_TDEscapes_mntl[]=
		{
			MNTL_ENOIR,			"ink(0)",
			MNTL_EROUGE,		"ink(2)",
			MNTL_EVERT,			"ink(4)",
			MNTL_EJAUNE,		"ink(6)",
			MNTL_EBLEU,			"ink(1)",
			MNTL_EMAGENTA,		"ink(3)",
			MNTL_ECYAN,			"ink(5)",
			MNTL_EBLANC,		"ink(7)",

			MNTL_FLASH_ON,		"flash(ON)",
			MNTL_FLASH_OFF,	"flash(OFF)",
			
			MNTL_SIZE_NORM,	"size(NORMAL)",
			MNTL_SIZE_HIGH,	"size(HIGH)",
			MNTL_SIZE_WIDE,	"size(WIDE)",
			MNTL_SIZE_DOUBLE,	"size(DOUBLE)",
		
			MNTL_ENOIR,			"paper(0)",
			MNTL_FROUGE,		"paper(2)",
			MNTL_FVERT,			"paper(4)",
			MNTL_FJAUNE,		"paper(6)",
			MNTL_FBLEU,			"paper(1)",
			MNTL_FMAGENTA,		"paper(3)",
			MNTL_FCYAN,			"paper(5)",
			MNTL_FBLANC,		"paper(7)",
			
			MNTL_LINE_OFF,		"line(OFF)",
			MNTL_LINE_ON,		"line(ON)",
			
			MNTL_INVERSE_OFF,	"inverse(OFF)",
			MNTL_INVERSE_ON,	"inverse(ON)",
			
			'\0',					NULL
		};
	int	M_nbEscapes;		/* Nbre de s‚quences ds tableau ci dessus */
	/*
	 * Codes couleur:
	 * Conversion entre l'ordre d'intensit‚ vers l'ordre vid‚otex
	 */
	int	M_CouleursVdt[ 8 ] = { 0, 4, 1, 5, 2, 6, 3, 7 };
	/*
	 * Messages d'erreur:
	 */
	char	*	M_CompilerError[] =
	{
		/*	STATUS_ERR_FILEEND */		"Fin de fichier pr‚matur‚e: instruction tronqu‚e",
		/* STATUS_ERR_LINEEND */		"Fin de ligne dans une chaŒne texte",
		/*	STATUS_ERR_TOOLONG */		"Instruction trop longue: compilation impossible",
		/* STATUS_ERR_NOTOKEN */		"Token introuvable!",
		/* STATUS_ERR_UNKNOWN */		"Instruction non reconnue",
		/* STATUS_ERR_OUTOFRANGE */	"ParamŠtre hors limites"
	};
	/*
	 * Buffer temporaire contenant l'instruction en cours de compilation:
	 */
	char 		*	M_p_InstrBuf;	
#define	INSTR_BUFFER_SIZE		(TMP_BUFFER_SIZE -1 -10)		/* 10 est une marge de s‚curit‚ pour l'expansion des constantes */

/*
 * ------------------------ FUNCTIONS -------------------------
 */


/*
 * init_PagesEcran(-)
 *
 * Purpose:
 * --------
 * Initialisation n‚cessaires … l'utilisation de ce module
 *
 * History:
 * --------
 * 31.07.94: fplanque: created
 */
void	init_PagesEcran( void )
{

	/*
	 * Le buffer de stockage commence un octet aprŠs le d‚but du tmp buffer 
	 */ 
	M_p_InstrBuf = &G_tmp_buffer[1];
	
	
	/*
	 * Cherche combien il y a de constantes:
	 */
	M_nbConstantes = 0;
	
	while( M_Constantes[ M_nbConstantes ] .psz_Var != NULL )
	{	/*
		 * Une instruction de plus:
		 */
		M_nbConstantes++;
	}

	/*
	 * Cherche combien il y a d'instructions videotex pour COMPILATION:
	 */
	M_nbCodesMinitel = 0;
	
	while( M_TCC_minitel[ M_nbCodesMinitel ] .pS_inst != NULL )
	{	/*
		 * Une instruction de plus:
		 */
		M_nbCodesMinitel++;
	}

	/*
	 * Cherche combien il y a de s‚quences ESC pour DECOMPILATION:
	 */
	M_nbEscapes = 0;
	
	while( M_TDEscapes_mntl[ M_nbEscapes ] .c_code != '\0' )
	{	/*
		 * Une s‚quence ESC de plus:
		 */
		M_nbEscapes++;
	}

}




/*
 * decompile_page(-)
 *
 * Purpose:
 * --------
 * D‚compile une page vid‚otex
 *
 * Suggest:
 * --------
 * Lorsqu'on entre dans une s‚quence sp‚ciale, il faut v‚rifier
 * qu'il reste assez de caractŠres pour terminer ladite s‚quence
 *
 * History:
 * --------
 * 31.08.94: fplanque: Created
 * 02.09.94: Prend param GRECT
 * 13.11.94: extension ".SV" pour fichier g‚n‚r‚
 */
void	decompile_page( GRECT * pGRect_start )	/* In: d‚but effet graphique */
{
	DATAPAGE		*	pDataPage_srce;
	TEXTINFO 	*	pTextInfo;
	size_t			size;
	char			*	pBuf;
	DATAPAGE		*	pDataPage_dest;	
	DATABLOCK	*	pDataBlock;
	char				Bsz_NomTexte[13];		/* Contient nom du texte cr‚‚ */
		
	FAKE_USE( pGRect_start );
		
	if(   G_selection_adr == NULL
		|| G_selection_adr -> class != CLASS_DIR )
	{	/*
		 * Si on a pas s‚lectionn‚ d'objet dans un directory:
		 */
		ping();
		return;
	}
	
	pDataPage_srce = page_adr_byicno( G_selection_adr -> datadir, G_selection_adr -> selected_icon );

	if( pDataPage_srce == NULL || pDataPage_srce -> DataType != DTYP_PAGES )
	{	/*
		 * Si on a pas s‚lectionn‚ une page ‚cran:
		 */
		return;
	}

	/*
	 * Cr‚e nom page destination:
	 */
	strcpy( Bsz_NomTexte, pDataPage_srce -> nom );
	replace_extension( Bsz_NomTexte, ".SV" );

	/*
	 * Cr‚e un texte vide:
	 */
	pTextInfo = create_TextInfo();

	/*
	 * D‚compilation:
	 */
	decomp_vdt2text( 
			pDataPage_srce -> data.dataBlock, 
			pDataPage_srce -> nom, Bsz_NomTexte, pTextInfo );

	/*
	 * PROVISOIRE:
	 * compactage en bloc:
	 */
	size = compact_text(	pTextInfo -> firstline -> next, 
											FMTMODE_NEARBINARY, &pBuf );

	free_formatext( pTextInfo );

	
	/*
	 * Sauve ds datapage destination:
	 */
	pDataPage_dest = add_datapage( DTYP_TEXTS, Bsz_NomTexte );

	/*
	 * Cr‚e un datablock contenant le code la page compil‚e:
	 */
	pDataBlock	= create_stdDataBlock();
	pDataBlock -> p_block	= pBuf;
	pDataBlock -> ul_length = size;
	
	/*
	 * Assigne le code compil‚ … la nouvelle page:
	 */
	pDataPage_dest -> data.dataBlock = pDataBlock;
		 
}



/*
 * decomp_vdt2text(-)
 *
 * Purpose:
 * --------
 * D‚compile une page vid‚otex
 *
 * Algorythm:
 * ----------  
 * Ajoute … la fin du texte indiqu‚ par TEXTINFO pass‚ en param
 *
 * Suggest:
 * --------
 * Lorsqu'on entre dans une s‚quence sp‚ciale, il faut v‚rifier
 * qu'il reste assez de caractŠres pour terminer la dite s‚quence
 *
 * History:
 * --------
 * 31.08.94: fplanque: Created
 * 08.01.95: utilise loc() plutot que pos()
 */
void decomp_vdt2text(
			DATABLOCK	*	pDataBlock,
			const	char	*	cpsz_name,		/* In: Nom de la page qu'on d‚compile */
			const char	*	cpsz_NomText,	/* IN: Nom du fichier destination */
			TEXTINFO		*	pTextInfo )
{
	char	 *	piBlock	= pDataBlock -> p_block;
	char		c_code;
	char	 *	psz_Instrcution;
	size_t	s_InstLen;
	char	 *	psz_newline;
	ULONG		ul_pos;
	BOOL		b_Graphmode = FALSE0;
	time_t	current_time;
	/*
	 * Ligne courante dans texte destination:
	 */
	TEXTLINE	*	pTextLine = pTextInfo -> lastline;
	
	/*
	 * Affiche progress 
	 */
	long	l_BlkSize = start_progress( " D‚compilation Page Ecran: ", 
													cpsz_NomText, pDataBlock -> ul_length, 5, FALSE0 );
	long	l_DoneSize = 0;		/* Pour l'instant on a rien compil‚ */

	/*
	 * Cr‚e header de texte:
	 */
	sprintf( M_p_InstrBuf, "// D‚compilation du fichier %s", cpsz_name );
	psz_newline = STRDUP( M_p_InstrBuf );
	pTextLine = insert_line( pTextLine, psz_newline, NIL_1, pTextInfo );

	current_time = time( NULL );
	sprintf( M_p_InstrBuf, "// %s", ctime( &current_time ) );
	M_p_InstrBuf[27] = '\0';
	psz_newline = STRDUP( M_p_InstrBuf );
	pTextLine = insert_line( pTextLine, psz_newline, NIL_1, pTextInfo );

	/*
	 * Parcourt la page:
	 */
	for( ul_pos = 0; ul_pos < (pDataBlock -> ul_length); ul_pos++, piBlock++ )
	{
		/*
		 * Instruction qui vient d'etre d‚cod‚e:
		 */
		psz_Instrcution = NULL;
		
		/*
		 * Code en cours:
		 */
		c_code = *piBlock;

		switch( c_code )
		{
			case	REP:
				/* 
				 * Il s'agit d'une r‚p‚tition de caractŠres
				 */
				sprintf( M_p_InstrBuf, "repeat(%d)", (int)piBlock[1]-0x40 );
				psz_Instrcution = M_p_InstrBuf;

				/*
				 * On avance de 2 caractŠres:
				 */				 
				ul_pos++;
				piBlock++;
				break;


			case	ESC:
			{
				int	c_NextCode = piBlock[1];
				int	n_index;
				
				for( n_index=0; n_index < M_nbEscapes; n_index++ )
				{	/*
					 * Cherche s‚quence esc ds tableau:
					 */
					if( M_TDEscapes_mntl[ n_index ] .c_code == c_NextCode )
					{	/*
						 * On a trouv‚:
						 */
						psz_Instrcution = M_TDEscapes_mntl[ n_index ] .psz_instruct;
							
						/*
						 * OK, on avance sur le prochain car:
						 */
						ul_pos++;
						piBlock++;
						break;
					}
				}
			}	
				break;


			case	US:
				/* 
				 * Il s'agit d'un POS/LOCATE/LINE0
				 */
				sprintf( M_p_InstrBuf, "loc(%d,%d)", (int)piBlock[2]-0x40, (int)piBlock[1]-0x40 );
				psz_Instrcution = M_p_InstrBuf;

				/*
				 * On est plus en Graphmode:
				 */
				b_Graphmode = FALSE0;

				/*
				 * On avance de 2 caractŠres:
				 */				 
				ul_pos+=2;
				piBlock+=2;
				break;
							
			default:
				if( ! b_Graphmode && c_code >= ' ' && c_code < MNTL_DEL )
				{	/*
					 * Il s'agit de texte normal:
					 */
					int	n_InstrLen	= 7;		/* On a d‚j… 7 cars ds buf d'instrcution, voir ligne suivante: */
					
					sprintf( M_p_InstrBuf, "text(\"%c", c_code );
					
					/*
					 * On continue d'ajouter dans le buffer
					 * tant qu'on a des codes apropri‚s:
					 *
					 * Tant qu'on est avant la fin:
					 */
					while( ul_pos < (pDataBlock -> ul_length)-1 )
					{
						/*
						 * Prochain car:
						 */ 
						c_code = *(piBlock+1);
		
						if( c_code < ' ' || c_code >= MNTL_DEL )
						{	/*
							 * Si code hors intervale texte:
							 */
							break;	/* On termine l'instruction text */
						}
						
						/*
						 * OK, on avance sur le prochain car:
						 */
						ul_pos++;
						piBlock++;
		
						/*
						 * Ajoute code au texte:
						 */
						M_p_InstrBuf[ n_InstrLen++ ] = c_code;
						
						if( n_InstrLen >= INSTR_BUFFER_SIZE-2 )
						{	/*
							 * Si on a atteint la longueur maximale:
							 * (-2 pour la fin de l'inst:  ")   )
							 */
							break;
						}
		
					}
					
					/*
					 * Fin de l'instruction text:
					 */
					M_p_InstrBuf[ n_InstrLen++ ] = '"';
					M_p_InstrBuf[ n_InstrLen++ ] = ')';
					M_p_InstrBuf[ n_InstrLen++ ] = '\0' ;	


					psz_Instrcution = M_p_InstrBuf;
				}
				else if( b_Graphmode && c_code >= ' ' && c_code <= MNTL_DEL )
				{	/*
					 * CaractŠre graphique:
					 * Macro de g‚n‚ration d'un caractŠre semi-graphique:
					 * D‚codage selon format:
					 *	positions	0 3		bits				0 1
					 *	dans			1 4		dans				2 3
					 *	source		2 5		destination		4 6
					 */
					char *pisz = M_p_InstrBuf + 6;
					
					strcpy( M_p_InstrBuf, "Graph(" );
					
					*(pisz++) = ( c_code & 0x01 ) ? '*' : '-';
					*(pisz++) = ( c_code & 0x04 ) ? '*' : '-';
					*(pisz++) = ( c_code & 0x10 ) ? '*' : '-';
					*(pisz++) = ( c_code & 0x02 ) ? '*' : '-';
					*(pisz++) = ( c_code & 0x08 ) ? '*' : '-';
					*(pisz++) = ( c_code & 0x40 ) ? '*' : '-';
					
					*(pisz++) = ')';
					*(pisz) = '\0';


					psz_Instrcution = M_p_InstrBuf;
				}
				else
				{	/* 
				    * On a affaire … des codes non imprimables:
				    */
					int	n_index;
					
					for( n_index=0; n_index < M_nbCodesMinitel; n_index++ )
					{	/*
						 * Cherche s‚quence esc ds tableau:
						 */
						if( M_TCC_minitel[ n_index ] .c_procIdx == 0
							&& M_TCC_minitel[ n_index ] .n_1stCode == c_code )
						{	/*
							 * On a trouv‚:
							 */
							char		c_GraphStop = M_TCC_minitel[ n_index ] .c_GraphStop;

							psz_Instrcution = M_TCC_minitel[ n_index ] .pS_inst;
								
							/*
							 * V‚rifie si on change de Graph/Text-Mode:
							 */
							if( c_GraphStop == 1 )
							{
								b_Graphmode = FALSE0;
							}
							else if( c_GraphStop == 2 )
							{
								b_Graphmode	= TRUE_1;
							}

							break;
						}
					}
				}
			}
				
		/*
		 * V‚rifie si on a pu d‚coder une instruction (‚volu‚e):
		 */
		if( psz_Instrcution == NULL )
		{	/*
			 * Code ne peut etre d‚cod‚:
			 */
			sprintf( M_p_InstrBuf, "code(%d)", (int)c_code );
			psz_Instrcution = M_p_InstrBuf;
		}	

		/*
		 * Cr‚e la ligne a ins‚rer:
		 * +2 pour ; et \0
		 */
		s_InstLen = strlen( psz_Instrcution );

		psz_newline = (char*) MALLOC( s_InstLen +2 );
		memcpy( psz_newline, psz_Instrcution, s_InstLen );

		psz_newline[ s_InstLen++ ] = ';';
		psz_newline[ s_InstLen ] = '\0';

		/*
		 * InsŠre ligne dans texte:
		 */
		pTextLine = insert_line( pTextLine, psz_newline , NIL_1, pTextInfo );

		/*
		 * Mise … jour de la barre de progression: 
		 */
		if( ul_pos+1 >= l_DoneSize + l_BlkSize )
		{
			/* block_size = */
			update_progress( l_DoneSize ); 
			
			/*
			 * M‚morise nle position affich‚e:
			 */
			l_DoneSize = ul_pos+1;
		}
	}

	/*
	 * Efface progress:
	 */
	end_progress( NULL );
}




/*
 * add_datapage(-)
 *
 * TEMPORAIRE
 * maj statut sauvegarde
 *
 * Suggest:
 * --------
 * Impl‚menter s‚lecteur de fichier
 *
 * 31.08.94: fplanque: extracted from compile_page()
 * 01.09.94: chgt update
 * 02.09.94: prend nom par d‚faut
 */
DATAPAGE *	add_datapage(
					DATATYPE		DataType,		/* In: Grp de donn‚es ds lequel on cr‚e */
					const char*	psz_DefName )	/* In: Nom par d‚faut */
{
	DATAGROUP * pDataGroup	 = find_datagroup_byType( DataType );
	DATADIR	 * pDataDir 	 = pDataGroup -> root_dir;

	/*
	 * Cr‚e page TEMP, ‚crase si existe d‚j…:
	 */
	DATAPAGE	 *	pDataPage = dataDir_InsertStdDataPg( psz_DefName, pDataDir );

	/*
	 * Mise … jour des fenˆtres et des infos de la zone de donn‚es: 
	 */
	dataPage_chgSavState( pDataPage, SSTATE_MODIFIED, FALSE0, TRUE_1 );
	/*
	 * R‚affiche le dir ds les fenˆtres concern‚es:
	 */
	remplace_dir( pDataDir );
	
	
	return	pDataPage;
}



/*
 * compile_page(-)
 *
 * Purpose:
 * --------
 * Compile le source sous forme de texte
 * qui se trouve dans la top window
 * en page ‚cran
 *
 * Suggest:
 * --------
 * Nom lorsque le texte n'est pas issu d'une datapage
 *
 * History:
 * --------
 * 06.07.94: fplanque: Created by extracting and renaming compile_text2vdt()
 * 15.07.94: update affichage du groupe de pages
 * 09.08.94: modif des routines d'update
 * 02.09.94: Prend param GRECT
 * 13.11.94: Utilise nom du .TXT d'origine pour nommer .VDT
 */
void	compile_page( GRECT * pGRect_start )	/* In: d‚but effet graphique */
{
	WIPARAMS	*	pWiParams = G_wi_list_adr;
	char		*	pm_CompiledPage;		/* ptr sur page compil‚e en RAM */
	size_t		size_CompiledPage;	/* taille du code */
	char			Bsz_NomPage[ 13 ];	/* Contient nom du fichier target */

	FAKE_USE( pGRect_start );

	/* 
	 * V‚rifie que la fenˆtre sup‚rieure 
	 * contient du texte pouvant ˆtre compil‚
	 */
	if( pWiParams == NULL || pWiParams -> type != TYP_TEXT )
	{
		ping();
		return;
	}

	/*
	 * D‚termine nom du fichier .VDT target:
	 */
	if( pWiParams -> class == CLASS_DATAPAGE )
	{
		strcpy( Bsz_NomPage, pWiParams -> datapage -> nom );
	}
	else
	{
		strcpy( Bsz_NomPage, "TEMP" );
	}
	replace_extension( Bsz_NomPage, ".VDT" );

	/*
	 * ProcŠde … la compilation:
	 */
	size_CompiledPage = compile_text2vdt( 
									pWiParams -> content_ptr.textInfo, 
									Bsz_NomPage,
									&pm_CompiledPage );

	if( size_CompiledPage >= 0  &&  pm_CompiledPage != NULL )
	{	/*
		 * Si la compilation est OK:
 		 * Cr‚e datapage:
		 */
		DATAPAGE * pDataPage = add_datapage( DTYP_PAGES, Bsz_NomPage );

		/*
		 * Cr‚e un datablock contenant le code la page compil‚e:
		 */
		DATABLOCK *	pDataBlock	= create_stdDataBlock();
		pDataBlock -> p_block	= pm_CompiledPage;
		pDataBlock -> ul_length = size_CompiledPage;
		
		/*
		 * Assigne le code compil‚ … la nouvelle page:
		 */
		pDataPage -> data.dataBlock = pDataBlock;
	}
}


/*
 * compile_text2vdt(-)
 *
 * Purpose:
 * --------
 * Compile un source sous forme de texte
 * en page ‚cran
 *
 * Suggest:
 * --------
 * G‚rer pression sur ANNULER dans progress
 *
 * History:
 * --------
 * 18.06.94: fplanque: Created
 * 04.07.94: permet maintenant plusieurs instructions par ligne
 * 05.07.94: remodelage total: augmentation souplesse
 * 06.07.94: Sauvegarde code compil‚ ds bloc m‚moire, am‚lioration gestion d'erreurs
 * 06.07.94: Le code r‚cup‚rant le source ds la fenˆtre au top a ‚t‚ extrait.
 * 31.07.94: Gestion des espaces et autres caractŠres sp‚ciaux … l'int‚rieur des chaines texte
 * 31.07.94: Commentaires type //
 * 01.08.94: Expansion des constantes symboliques
 * 02.09.94: Affichage PROGRESS
 * 26.09.94: Gestion des erreurs en fenetre
 * 28.09.94: Fereme progress avant d'ouvrir fen d'erreurs
 * 13.11.94: Prend nom de la page en param 
 */
size_t	compile_text2vdt(						/* Out: Taille de la page compil‚e */
				TEXTINFO 	* pTextInfo,		/* In:  Ptr sur texte source */
				const char  * cpBsz_Nom,		/* In:  Nom de la page … afficher ds progress */
				char		 * * ppm_OutputBuf )	/* Out: Ptr sur buffer contenant le code compil‚ */
{
	/*
	 * Texte SOURCE:
	 * Saute ligne 0 et commence sur ligne no 1:
	 */
	TEXTLINE	*	pTextLine =	pTextInfo -> firstline -> next;
	char		*	pS_source;
	BOOL			b_DbleQuotes;			/* ==FALSE0 si pas dans une chaine de caractŠres */
	BOOL			b_AllUpper;				/* ==TRUE_1 si que des majuscules ds le param courant */ 
	BOOL			b_EndParam;				/* !=FALSE0 dŠs qu'on est en fin de paramŠtre */
	long			l_NbL_compiled = 0;	/* Nbre de lignes d‚j… compil‚es */

	char			cur_char;
	int			n_bufLen;			/* Longueur texte dans buffer */
	char		*	pS_instruction;
	char		*	pS_arg1;
	char		*	pS_arg2;
	/*
	 * Gestion des erreurs:
	 */
	int			n_status;
	int			nb_errors = 0;		/* Nbre d'erreurs */
	/*
	 * Buffer de destination de la page compil‚e:
	 */
	size_t		size_CompBuf = pTextInfo -> nb_lignes;	/* Longueur arbitraire */
	char		*	pm_CompBuf = (char *) MALLOC( size_CompBuf );	/* Buffer qui va recevoir le code compil‚ */
	size_t		size_Code = 0;		/* Buffer vide */

	/*
	 * Affiche progress 
	 */
	long	l_BlkSize = start_progress( 
								" Compilation Texte -> Vid‚otex ", 
								cpBsz_Nom, pTextInfo -> nb_lignes-1, 2, FALSE0 );
	long	l_DoneSize = 0;		/* Pour l'instant on a rien compil‚ */

	/*
	 * Initialise buffer temporaire:
	 * Juste avant le d‚but, on place un ARGUMENT_SPERATOR
	 * ce qui sert a ne pas avoir d'effets ind‚sirables lorsque l'on teste
	 * le caractŠre AVANT le 1ER caractŠre!!
	 */
	G_tmp_buffer[ 0 ] = ARGUMENT_SPERATOR;
	
	/*
	 * Texte de la ligne en cours de compilation:
	 */
	pS_source = pTextLine -> text;

	while( pTextLine != NULL )
	{	/*
		 * Tant qu'il y a des lignes … compiler:
		 *
		 * D‚but compilation d'une nouvelle instruction:
		 */
		n_bufLen = 0;		/* Vide buffer */
		n_status = STATUS_PROGRESS;
		b_DbleQuotes	= FALSE0;
		b_AllUpper		= TRUE_1;	/* A priori le prochain param est plein de majuscules */
		b_EndParam		= FALSE0;

		do
		{	/* --------------------------------------------------------- */

			if( pS_source == NULL )
			{	/*
				 * Si la ligne courante est vide:
				 * Passe … la ligne suivante:
				 */
				pTextLine = pTextLine -> next;
				l_NbL_compiled++;

				if( pTextLine == NULL )
				{	/*
					 * Plus de ligne suivante:
					 */
					n_status = STATUS_ERR_FILEEND;
					break;
				}
				/*
				 * Texte de la ligne en cours de compilation:
				 */
				pS_source = pTextLine -> text;

				continue;				
			}
			
			/*
			 * Si la ligne n'est pas vide;
			 */
			switch( cur_char = *( pS_source ++ ) )
			{
				case	'\0':
					/*
					 * Si on a trouv‚ une fin de ligne:
					 * Passe … la ligne suivante:
					 */
					pTextLine = pTextLine -> next;
					l_NbL_compiled++;

					if( pTextLine == NULL )
					{	/*
						 * Plus de ligne suivante:
						 */
						n_status = STATUS_ERR_FILEEND;
						break;
					}
					else
					{	/*
					  	 * Texte de la nlle ligne en cours de compilation:
					 	 */
						pS_source = pTextLine -> text;
					}

					if( b_DbleQuotes != FALSE0 )
					{	/*
						 * Si on est dans du texte:
						 */
						n_status = STATUS_ERR_LINEEND;
						break;
					}
					
					/*
					 * L'argument courant n'est pas entiŠrement constitu‚ de majuscules:
					 * c'est pas une constante:
					 */
					b_AllUpper = FALSE0;		

					break;

				case	'"':
					/*
					 * Guillemets:
					 * Fin ou d‚but de texte:
					 */
					b_DbleQuotes = ! b_DbleQuotes;
					/*
					 * L'argument courant n'est pas entiŠrement constitu‚ de majuscules:
					 * c'est pas une constante:
					 */
					b_AllUpper = FALSE0;		
					break;

				case	'(':
					/*
					 * ParenthŠse:
					 */
					if( b_DbleQuotes == FALSE0 )
					{	
					 	b_EndParam = TRUE_1;		/* Fin d'argument atteinte */ 
					}
					else
					{	/* 
					 	 * ParenthŠse dans un texte:
					 	 */
						M_p_InstrBuf[ n_bufLen++ ] = '(';
					}
					break;

				case	')':
					/*
					 * ParenthŠse:
					 */
					if( b_DbleQuotes == FALSE0 )
					{
					 	b_EndParam = TRUE_1;		/* Fin d'argument atteinte */ 
					}
					else
					{	/* 
					 	 * ParenthŠse dans un texte:
					 	 */
						M_p_InstrBuf[ n_bufLen++ ] = ')';
					}
					break;

				case	',':
					/*
					 * Virgule:
					 */
					if( b_DbleQuotes == FALSE0 )
					{
					 	b_EndParam = TRUE_1;		/* Fin d'argument atteinte */ 
					}
					else
					{	/* 
					 	 * Virgule dans un texte:
					 	 */
						M_p_InstrBuf[ n_bufLen++ ] = ',';
					}
					break;

				case	'/':
					if( M_p_InstrBuf[ n_bufLen-1 ] == '/' && !b_DbleQuotes )
					{	/*
					 	 * Commentaire commen‡ant par //:
					 	 */
						n_bufLen --;	/* On revient sur nos pas */
						/*
						 * On se rend … la fin de ligne, ce qui correspond … la fin d'un commentaire de type //:
						 */
						while( *pS_source != '\0' )
						{
							pS_source++;
						}
					}
					else
					{	/* 
					 	 * Copie le caractŠre dans le buffer:
					 	 */
						M_p_InstrBuf[ n_bufLen++ ] = '/';
						/*
						 * L'argument courant n'est pas entiŠrement constitu‚ de majuscules:
						 * c'est pas une constante:
						 */
						b_AllUpper = FALSE0;		
					}
					break;

				case	';':
					/*
					 * Teste si on est dans un texte ou si c'est une fin d'instruction:
					 */
					if( b_DbleQuotes == FALSE0 )
					{	/*
					 	 * Si on a trouv‚ la fin d'une instruction:
					 	 */
						n_status = STATUS_INSTRUCTOK;
					}
					else
					{	/* 
					 	 * Point-Virgule dans un texte:
					 	 */
						M_p_InstrBuf[ n_bufLen++ ] = ';';
					}
					break;
					
				default:
					/*
					 * CaractŠre normal:
					 */
					if( cur_char >= ' ' )
					{	/*
					 	 * CaractŠre affichable:
					 	 */
						if( cur_char == ' ' && b_DbleQuotes == FALSE )
						{	/*
							 * Si on a un espace mais qu'on est pas dans un chaine:
							 * on filtre cet espace inutile:
							 */
							break;
						}

						/*
						 * Ajoute car au buffer:
						 */
						M_p_InstrBuf[ n_bufLen++ ] = cur_char;

						if( cur_char < 'A' || cur_char > 'Z' )
						{	/*
							 * L'argument courant n'est pas entiŠrement constitu‚ de majuscules:
							 * c'est pas une constante:
							 */
							b_AllUpper = FALSE0;		
						}
					}
			}	/* Fin du switch */



			/*
			 * Teste si on est en fin de paramŠtre:
			 */
			if( b_EndParam )
			{
				if( b_AllUpper )
				{	/*
					 * Si le dernier param ‚tait constitu‚ uniquement de majuscules:
					 */
					int		n_ParamStart = n_bufLen;
					int		i;
					char	*	psz_Constant;
					
					M_p_InstrBuf[ n_bufLen ] = '\0';
					
					/*
					 * Cherche d‚but:
					 */
					while( M_p_InstrBuf[ --n_ParamStart ] != ARGUMENT_SPERATOR )
					{ };
					psz_Constant = &M_p_InstrBuf[ ++n_ParamStart ];
					
					/* printf("\nConstante: %s<", psz_Constant ); */

					/*
					 * Transforme constante en son contenu:
					 */
					for( i = 0; i < M_nbConstantes; i++ )
					{
						if( strcmp( psz_Constant, M_Constantes[ i ] .psz_Var ) == 0 )
						{	/*
							 * On a trouv‚ la constante dans la table:
							 */
							strcpy( psz_Constant, M_Constantes[ i ] .psz_Val );
							/*
							 * Cherche index de la fin:
							 */
							n_bufLen = (int) (strchr( psz_Constant, '\0' ) - M_p_InstrBuf );
						}
					}
				}
			
				/*
				 * Marque la fin du param dans le buffer:
				 */
				M_p_InstrBuf[ n_bufLen++ ] = ARGUMENT_SPERATOR;
				b_EndParam	= FALSE0;	/* On entame un nouveau paramŠtre */
				b_AllUpper	= TRUE_1;	/* A priori le prochain param est plein de majuscules */
			}
			
			/*				 
			 * Teste conditions de fin d'instruction forc‚e:
			 */
			if( n_bufLen >= INSTR_BUFFER_SIZE )
			{	/*
				 * Si on ne peut pas copier la nouvelle instruction
				 * parce qu'elle est trop longue
				 */
				n_status = STATUS_ERR_TOOLONG;
				break;
			}


		}	/* --------------------------------------------------------- */
		while( n_status == STATUS_PROGRESS );

		/*
		 * ----------------------------------------------------
		 * On vient de terminer l'extraction d'une instruction:
		 * ----------------------------------------------------
		 */
		if( n_status == STATUS_INSTRUCTOK )
		{	/*
			 * Extraction OK:
			 * Termine le buffer:
			 */
			M_p_InstrBuf[ n_bufLen ] =	'\0';

			/*
			 * Prend 1er token de l'instruction courante:
			 */
			/*	printf( "\ninst: >%s<     ", M_p_InstrBuf ); */
			pS_instruction = strtok( M_p_InstrBuf, psz_ArgumentSeparator );
			if( pS_instruction == NULL )
			{
				n_status = STATUS_ERR_NOTOKEN;
			}
			else
			{
				int 	n_result;
				
				/*
				 * Arguments (1er arg = 2Šme token):
				 */
				pS_arg1 = strtok( NULL, psz_ArgumentSeparator );
				pS_arg2 = strtok( NULL, psz_ArgumentSeparator );
				
				/*
				 * Essaie de le compiler:
				 */
				n_result = translate_inst2code( pS_instruction, pS_arg1, pS_arg2 );
				if( n_result < 0 )
				{	/*
					 * S'il s'est produit une erreur:
					 */
					n_status = n_result;
				}
				else
				{	/*
					 * L'instruction a ‚t‚ correctement compil‚e:
					 */
					
					int	n_nbCodes = n_result;
					 
					/* 
					 * Envoi block sur prise:
					 */
					/* printf("\nout: %d %d", (int) G_2nd_buffer[0], (int) G_2nd_buffer[1] ); */
					sconout( G_term_dev, n_nbCodes, G_2nd_buffer );
		
					/*
					 * V‚rifie taille buffer de compilation:
					 */
					if( size_Code + n_nbCodes > size_CompBuf )
					{	/*
						 * Buffer trop petit:
						 */
						size_CompBuf += 100;		/* Agrandi buffer */
						pm_CompBuf = (char *) REALLOC( pm_CompBuf, size_CompBuf );
					}

					/*
					 * Sauve dans buffer de compilation:
					 */
					memcpy( &pm_CompBuf[ size_Code ], G_2nd_buffer, n_nbCodes );
					size_Code += n_nbCodes;
					
				}
			}
		}
		else if( n_status == STATUS_ERR_FILEEND && n_bufLen == 0 )
		{	/* 
			 * Si on est arriv‚ … la fin du fichier, 
			 * mais qu'il n'y a pas d'instruction en cours:
			 */
			n_status = STATUS_INSTRUCTOK;
		}

		/*
		 * Mise … jour de la barre de progression: 
		 */
		if( l_NbL_compiled >= l_DoneSize + l_BlkSize )
		{
			/* block_size = */
			update_progress( l_DoneSize ); 
			
			/*
			 * M‚morise nle position affich‚e:
			 */
			l_DoneSize = l_NbL_compiled;
		}


		/*
		 * Affichage message d'erreur:
		 */
		if( n_status != STATUS_INSTRUCTOK )
		{	/*
			 * Il y a eu une erreur:
			 */
			nb_errors ++;		/* 1 de plus! */

			if( nb_errors == 1 )
			{	/*
				 * Si c'est la premiŠre erreur:
				 * Ferme progress et d‚bute une liste d'erreurs:
				 */
				end_progress( NULL );
				errorLog_AddLine( "*** Compilation Texte >> Page Ecran:" );
			}

			errorLog_AddLine( M_CompilerError[ n_status + 1000 ] );
		}
	} 		


	/*
	 * Efface progress:
	 */
	end_progress( NULL );


	/*
	 * Contr“le s'il y a eu des erreurs:
	 */
	if( nb_errors == 0)
	{	/* 
		 * Si pas d'erreur:
		 */
		*ppm_OutputBuf =	pm_CompBuf;
		return				size_Code;
	}
	else
	{	/*
		 * Il y a eu des erreurs:
		 */
		/* text_addLineToEnd( M_pTextInfo_Errors, "Erreurs!" ); */
		
	}

	/*
	 * Il y a eu une erreur: on abandonne la compilation.
	 */
	FREE( pm_CompBuf );
	*ppm_OutputBuf =	NULL;
	return				ERROR_1;
}





/*
 * translate_inst2code(-)
 *
 * Purpose:
 * --------
 * Traduit une instrction
 * en son code correspondant
 *
 * History:
 * --------
 * 18.06.94: fplanque: Created
 * 06.07.94: retourne codes d'erreurs ou nbre de codes g‚n‚r‚s
 * 31.07.94: support code(x), ink(x), loc(x,y), repeat(x), etc..
 * 01.08.94: size(), flash(), inverse(), line()
 * 03.08.94: correction bug lorsque 1stcode == NIL_1
 * 13.11.94: ttmt des cars accentu‚s ds text()
 */
int	translate_inst2code( 		/* Out: nbre de codes g‚n‚r‚s ou code d'erreur si <0 */
				char	*	pS_inst,		/* In: Instruction */
				char	*	pS_arg1,		/* In: Premier paramŠtre */
				char	*	pS_arg2 )	/* In: DeuxiŠme paramŠtre */
{
	int	i;
	int	n_firstCode;
	int	int1, int2;
	int	n_buf2Len = 0;
	
	for( i = 0 ; i < M_nbCodesMinitel ; i++ )
	{
		if( strcmp( pS_inst, M_TCC_minitel[ i ].pS_inst ) == 0 )
		{
			/* printf( "Inst:%s Code:%d\n", M_TCC_minitel[ i ].pS_inst, (int)M_TCC_minitel[ i ].c_1stCode ); */

			/*
			 * M‚mo premier code:
			 */
			if( (n_firstCode = M_TCC_minitel[ i ].n_1stCode) != NIL_1 )
			{
				G_2nd_buffer[ n_buf2Len ++ ] = n_firstCode;
			}
			
			/*
			 * Traite argument:
			 */
			switch( M_TCC_minitel[ i ].c_procIdx )
			{
				case	CODE_CODE:
					/*
					 * code(x)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 255 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = int1;
					break;			

				case	CODE_REP:
					/*
					 * repeat(x)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 63 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x40 + int1;
					break;			

				case	CODE_FLASH:
					/*
					 * flash(ON/OFF)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 1 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x49 - int1;
					break;			

				case	CODE_INVERSE:
					/*
					 * inverse(ON/OFF)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 1 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x5C + int1;
					break;			

				case	CODE_LINE:
					/*
					 * line(ON/OFF)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 1 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x59 + int1;
					break;			

				case	CODE_SIZE:
					/*
					 * size(NORMAL/HIGH/LARGE/DOUBLE)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 3 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x4C + int1;
					break;			

				case	CODE_INK:
					/*
					 * ink(x)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 7 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x40 + M_CouleursVdt[ int1 ];
					break;			

				case	CODE_PAPER:
					/*
					 * paper(x)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 7 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = 0x50 + M_CouleursVdt[ int1 ];
					break;			

				case	CODE_LINE0:
					/*
					 * line0
					 */
					G_2nd_buffer[ n_buf2Len ++ ] = 0x40;
					G_2nd_buffer[ n_buf2Len ++ ] = 0x41;
					break;			

				case	CODE_POS:
					/*
					 * pos(y,x)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 24 )
					{
						return STATUS_ERR_OUTOFRANGE;
					}

					int2 = atoi( pS_arg2 );	
					if( int2 < 1 || int2 > 40 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}

					G_2nd_buffer[ n_buf2Len ++ ] = 0x40 + int1;
					G_2nd_buffer[ n_buf2Len ++ ] = 0x40 + int2;
					break;			

				case	CODE_LOCATE:
					/*
					 * pos(x,y)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 1 || int1 > 40  )
					{
						return STATUS_ERR_OUTOFRANGE;
					}

					int2 = atoi( pS_arg2 );	
					if( int2 < 0 || int2 > 24)
					{	
						return STATUS_ERR_OUTOFRANGE;
					}

					G_2nd_buffer[ n_buf2Len ++ ] = 0x40 + int2;
					G_2nd_buffer[ n_buf2Len ++ ] = 0x40 + int1;
					break;			

				case	CODE_TEXT:
				{	/*
					 * text:
					 */
					char *	pciB_CurrCar = pS_arg1;
					char		c_CurrCar;
					while( ( c_CurrCar = *(pciB_CurrCar++) ) != '\0' )
					{
						if( c_CurrCar < 128 )
						{
							G_2nd_buffer[ n_buf2Len ++ ] = c_CurrCar;
						}
						else
						{
							const char * cpsz_Accent = convert_Asc2Vdt( c_CurrCar );
							strcpy( &(G_2nd_buffer[ n_buf2Len ]), cpsz_Accent );
							n_buf2Len += (int) strlen( cpsz_Accent );
						}
					}
				}
					break;			

				case	CODE_SCROLL:
					/*
					 * scroll(ON/OFF)
					 */
					int1 = atoi( pS_arg1 );	
					if( int1 < 0 || int1 > 1 )
					{	
						return STATUS_ERR_OUTOFRANGE;
					}
					G_2nd_buffer[ n_buf2Len ++ ] = PRO2;
					G_2nd_buffer[ n_buf2Len ++ ] = int1 ? P_START : P_STOP;
					G_2nd_buffer[ n_buf2Len ++ ] = ROULEAU;
					break;				

				case	CODE_SGCHAR:
				{	/*
					 * Macro de g‚n‚ration d'un caractŠre semi-graphique:
					 * D‚codage selon format:
					 *	positions	0 3		bits				0 1
					 *	dans			1 4		dans				2 3
					 *	source		2 5		destination		4 6
					 */
					char	c_SgChar = 0x20;
					
					if( pS_arg1[ 0 ] == '*' )
					{
						c_SgChar |= 0x01;
					}

					if( pS_arg1[ 1 ] == '*' )
					{
						c_SgChar |= 0x04;
					}

					if( pS_arg1[ 2 ] == '*' )
					{
						c_SgChar |= 0x10;
					}

					if( pS_arg1[ 3 ] == '*' )
					{
						c_SgChar |= 0x02;
					}

					if( pS_arg1[ 4 ] == '*' )
					{
						c_SgChar |= 0x08;
					}

					if( pS_arg1[ 5 ] == '*' )
					{
						c_SgChar |= 0x40;
					}

					/* printf( "\n SgChar = %s -> >%c<", pS_arg1, c_SgChar ); */
					G_2nd_buffer[ n_buf2Len ++ ] = c_SgChar;
				}	
					break;
			} 

			/*
			 * Pas d'erreur:
			 * Retourne le nombre de codes compil‚s:
			 * (l'appellant peut les r‚cup‚rer dans G_2nd_buffer)
			 */
			return	n_buf2Len;
		}
	}

	/*
	 * L'instruction n'est pas reconnue:
	 */
	return	STATUS_ERR_UNKNOWN;
}


/*
 * watch_PageEcran(-)
 *
 * Purpose:
 * --------
 * Selection d'une page ‚cran puis visualisation
 *
 * History:
 * --------
 * 08.01.95: fplanque: Created
 */
void	watch_PageEcran(
			OBJECT	*	pObj_CallForm,	/* In: Formulaire appellant */
			int 			call_obj )		/* In: objet appellant */
{
	/* Datagroup dans lequel on va choisir une page */
	DATAGROUP *	pDataGroup = find_datagroup_byType( DTYP_PAGES );
	/* Va recevoir s‚lection */
	char		 *	piBsz_PageName = NULL;
	/* Adr de la page trouv‚e */
	DATAPAGE	 *	pDataPage_Ecran;

	/*
	 * S‚lecteur RAM: 
	 */
	RAMSEL selection = ramselect_fromForm( "Voir une Page Ecran:",
											 	pDataGroup, &piBsz_PageName,
											 	pObj_CallForm, call_obj );

	if( selection != RAMSEL_ABORT )
	{
		/*
		 * Cherche page demand‚e: 
		 */
		pDataPage_Ecran = page_adr_bynamecmp( pDataGroup -> root_dir, &piBsz_PageName[5] );

		if( pDataPage_Ecran == NULL )
		{	/*
			 * On a pas trouv‚ la page ‚cran: 
			 */
			alert( ENOENT );
			return;
		}

		/*
		 * Visu de la page:
		 */
		visu_page( pDataPage_Ecran, pObj_CallForm ); 	/* Visu page */

	}

}

/*
 * visu_page(-)
 *
 * Purpose:
 * --------
 * Visu d'une page ‚cran sur le terminal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.01.95: gŠre arbre appellant
 */
void	visu_page( 
			DATAPAGE	*	pDataPage,			/* In: Page ‚cran … afficher */ 
			OBJECT	*	pObj_CallForm )	/* In: Arbre appellant, peut ˆtre NULL */
{
	DATABLOCK * pDatablock = pDataPage -> data.dataBlock;
	long			block_size;			/* Taille des blocs entre 2 mises … jour du progress: */
	char		*	page_ptr;			/* Pointeur dans la page */
	long			done_size = 0;

	/*
	 * Affiche progress 
	 */
	block_size = start_progress( " Visu page sur terminal: ", pDataPage -> nom, pDatablock -> ul_length, 30, (pObj_CallForm != NULL) );
	
	/*
	 * Envoi de la page au minitel: 
	 */
	page_ptr = pDatablock -> p_block;		/* Ptr sur d‚but de la page */

	while( done_size < pDatablock -> ul_length )
	{
		/*
		 * Envoi d'un block: 
		 */
		sconout ( G_term_dev, block_size, page_ptr );

		/*
		 * On se place au d‚but du bloc suivant: 
		 */
		done_size += block_size;			/* Taille d‚j… envoy‚e */
		page_ptr += block_size;				/* Passe … la suite */

		/*
		 * Mise … jour de la barre de progression: 
		 * et recup‚ration taille prochain block
		 */
		block_size = update_progress( done_size ); 
		
		/*
		 * Contr“le si on a pas annul‚: 
		 */
		if( block_size < 0 )
		{	/*
			 * Si on a annul‚: 
			 */
			break;
		}
		
	}

	/*
	 * Efface progress:
	 */
	end_progress( pObj_CallForm );
}
