/*
 * arbopars.c
 *
 * Purpose:
 * --------
 * Fonctions permettant la manipulation
 * des paramätres d'une pge arbo
 *
 * History:
 * --------
 * 04.12.94: Created by flanque
 */

	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ARBOPARS.C v1.00 - 03.95"
          
/*
 * System headers:
 */
	#include	<stdio.h>
	#include <stdlib.h>
	#include	<string.h>
	
/*
 * Custom headers:
 */
	#include	"ARB_OUT.H"

	#include "SPEC_PU.H"					/* Listes... */	
	#include "S_MALLOC.H"
	#include	"MAIN_PU.H"	
	#include	"DEBUG_PU.H"	
	#include	"FILES_PU.H"	
	#include	"LISTS_PU.H"	
	#include	"DEF_ARBO.H"
	#include	"AFILE_PU.H"
	#include	"ARPAR_PU.H"				/* this */
	#include "WIN_PU.H"


/*
 * ------------------------ FUNCTIONS -------------------------
 */


/*
 * Duplicate_TextParList(-)
 *
 * Purpose:
 * --------
 * Duplique une liste chainÇee de ARBO_TEXTPAR
 *
 * Suggest:
 * ------
 * Move me to another file
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created / replaces old duplicate_textpar() / 
 *           this one uses dup_String() instead of strcpy() which is supposed was a bug!
 * 14.05.95: retourne un ARBO_TEXTPAR * au lieu de VOID ce qui semblait stupide et dangereux
 */
ARBO_TEXTPAR *	Duplicate_TextParList( 
				const ARBO_TEXTPAR *	pTextPar_FirstSrce )	/* In: Ptr sur 1er elt liste source */
{
	const ARBO_TEXTPAR *		pTextPar_Srce = pTextPar_FirstSrce;	/* 1er elt de la liste destination */
	ARBO_TEXTPAR *		pTextPar_FirstDest;			/* 1er elt de la liste destination */
	ARBO_TEXTPAR * *	lastptr_to_next = &pTextPar_FirstDest;	/* Adr du dernier ptr sur le champ suivant */
	ARBO_TEXTPAR *		pTextPar_Dest;					/* Elt courant de la liste destination */

	/*
	 * Copie tous les ÇlÇments: 
	 */
	while( pTextPar_Srce != NULL )
	{
		/*
		 * CrÇe nouvel ÇlÇment; 
		 */
		pTextPar_Dest = MALLOC( sizeof( ARBO_TEXTPAR ) );

		/*
		 * Copie le contenu: 
		 */
		pTextPar_Dest -> fnct_no = pTextPar_Srce -> fnct_no;
		pTextPar_Dest -> nom = dup_String( pTextPar_Srce -> nom );

		/*
		 * Lie ce champ au prÇcÇdent: 
		 */
		*lastptr_to_next = pTextPar_Dest;
		/*
		 * Nouvelle adr du dernier ptr sur champ suivant: 
		 */
		lastptr_to_next = &(pTextPar_Dest -> next);
						
		/*
		 * Passe au champ source suivant: 
		 */
		pTextPar_Srce = pTextPar_Srce -> next;
	}

	/*
	 * Signale fin de la liste: 
	 */
	*lastptr_to_next = NULL;

	/*
	 * Retourne ptr sur nlle liste: 
	 */
	return	pTextPar_FirstDest;
}




/*
 * Delete_TextParList(-)
 *
 * Purpose:
 * --------
 * Efface 1 liste de paramätres textuels de la mÇmoire
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 24.05.94: utilisation de free_String()
 * 02.12.94: change name from free_atextpar()
 * 14.02.95: verified mallocs
 */
void	Delete_TextParList( 
			ARBO_TEXTPAR *	arbo_textpar )
{
	ARBO_TEXTPAR	*	next_textpar;

	while( arbo_textpar != NULL )
	{
		next_textpar = arbo_textpar -> next;	/* Paramätre suivant */

		free_String( arbo_textpar -> nom );		/* Efface le nom */
		FREE( arbo_textpar );						/* Efface le paramätre */

		arbo_textpar = next_textpar;				/* Passe au param suivant */
	}
}






/*
 * Get_ithTextParInList(-)
 *
 * Purpose:
 * --------
 * Trouve les parametres de son numÇro d'ordre ds la liste
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created
 */
ARBO_TEXTPAR	*	Get_ithTextParInList( 
							ARBO_TEXTPAR *	pTextPar, 
							int 				n_Index )
{
	int	i;		/* Compteur */

	for( i=0; i < n_Index  &&  pTextPar != NULL; i++ )
	{	/*
		 * Tant qu'on est pas arrivÇ au champ qui nous intÇresse
		 * et qu'on est pas Ö la fin de la liste: 
		 * Passe au champ suivant 
		 */
		pTextPar = pTextPar -> next;
	}

	return	pTextPar;		/* Ptr sur params; NULL si pas trouvÇ */
}
   


/*
 * InputField_Save(-)
 *
 * Purpose:
 * --------
 * Sauve paramätres d'un champ de saisie
 *
 * History:
 * --------
 * 17.12.94: fplanque: Created
 */
void	InputField_Save( 
			INPUT_FPAR	*	pInputFPar, 	/* In: Champ Ö sauver */
			FILE 			*	fstream )		/* In: Fichier vers lequel sauver */
{
	/*
	 * Sauve tout sauf chaine:
	 */
	fwrite( pInputFPar, 1, sizeof( INPUT_FPAR ) - sizeof( char * ) , fstream );

	/*
	 * Sauve chaine du contenu par dÇfaut:
	 */
 	save_String( pInputFPar -> psz_DefText, fstream );
}


/*
 * InputField_Load(-)
 *
 * Purpose:
 * --------
 * Charge paramätres d'un champs de saisie
 *
 * History:
 * --------
 * 17.12.94: fplanque: Created
 * 23.01.95: ajout FieldCode
 */
void	InputField_Load( 
			INPUT_FPAR	*	pInputFPar, /* In: Champ ds lequel on charge */
			FILE 			*	fstream,		/* In: Fichier duquel on charge */
			int				n_Version )	/* In: version du fichier */
{
	/*
	 * Charge tout sauf chaine:
	 */
	if( n_Version == 0x0002 )
	{
		fread( pInputFPar, 1, 28, fstream );

		memcpy( &(pInputFPar -> InFieldFlags), ((char *)pInputFPar) + 2, 26 );

		pInputFPar -> ul_CodeChamp = get_InFieldCode( pInputFPar -> fnct_no );
	}
	else
	{
		fread( pInputFPar, 1,  sizeof( INPUT_FPAR ) - sizeof( char * ), fstream );
	}

	/*
	 * Charge chaine du contenu par dÇfaut:
	 */
 	pInputFPar -> psz_DefText = load_String( fstream );
}



/*
 * AListPars_Save(-)
 *
 * Purpose:
 * --------
 * Sauve paramätres de liste (d'affichage)
 *
 * History:
 * --------
 * 26.01.95: fplanque: Created
 */
void	AListPars_Save(
			ARBO_LISTPARS	*	pAListPars, /* In: Paramätres Ö sauver */
			FILE 				*	fstream )	/* In: Fichier vers lequel sauver */
{
	if( pAListPars == NULL )
	{
		fputc( 'l', fstream );
	}
	else
	{
		fputc( 'L', fstream );
		fwrite( pAListPars, 1, sizeof( ARBO_LISTPARS ), fstream );
	}
}



/*
 * AListPars_Load(-)
 *
 * Purpose:
 * --------
 * Charge paramätres de liste (d'affichage)
 *
 * History:
 * --------
 * 26.01.95: fplanque: Created
 */
ARBO_LISTPARS	*	AListPars_Load(		/* Out: paramätres chargÇs */
			FILE 				*	fstream )	/* In:  Fichier depuis lequel on charge */
{
	if( fgetc( fstream ) == 'L' )
	{
 		ARBO_LISTPARS	* pAListPars = MALLOC( sizeof( ARBO_LISTPARS ) );
		fread( pAListPars, 1, sizeof( ARBO_LISTPARS ), fstream );
		
		return	pAListPars;
	}
	
	return	NULL;
}



/*
 * OutputField_Save(-)
 *
 * Purpose:
 * --------
 * Sauve paramätres des champs de sorttie (affichage)
 *
 * History:
 * --------
 * 17.12.94: fplanque: Created
 */
void	OutputField_Save( 
			OUTPUT_FPAR	*	pOutputFPar, 	/* In: Champ Ö sauver */
			FILE 			*	fstream )		/* In: Fichier vers lequel sauver */
{
	/*
	 * Sauve tout:
	 */
	fwrite( pOutputFPar, 1, sizeof( OUTPUT_FPAR ), fstream );
}



/*
 * OutputField_Load(-)
 *
 * Purpose:
 * --------
 * Charge paramätres d'un champs de sortie
 *
 * History:
 * --------
 * 17.12.94: fplanque: Created
 * 23.01.95: gesion codechamp
 */
void	OutputField_Load( 
			OUTPUT_FPAR	*	pOutputFPar, /* In: Champ ds lequel on charge */
			FILE 			*	fstream,		/* In: Fichier duquel on charge */
			int				n_Version )	/* In: version du fichier */
{
	/*
	 * Charge tout:
	 */
	if( n_Version == 0x0002 )
	{
		fread( pOutputFPar, 1, 20, fstream );
	
		memcpy( &(pOutputFPar -> OutFieldFlags), ((char*)pOutputFPar) +2, 18 );

		pOutputFPar -> ul_CodeChamp = get_OutFieldCode( pOutputFPar -> fnct_no );

		switch( pOutputFPar -> fnct_no )
		{
			case	0010:
				pOutputFPar -> fnct_no = FO_COMMENT;
				pOutputFPar -> OutFieldFlags.u_GroupId = 1;
				break;
		
			case	0100:
				pOutputFPar -> fnct_no = FO_RECNUMBER;
				pOutputFPar -> OutFieldFlags.u_GroupId = 2;
				break;
		
			case	0200:
				pOutputFPar -> fnct_no = FO_CREATEDATE;
				pOutputFPar -> OutFieldFlags.u_GroupId = 2;
				break;
		
			case	0220:
				pOutputFPar -> fnct_no = FO_PUBPRIV;
				pOutputFPar -> OutFieldFlags.u_GroupId = 2;
				break;
		
			case	0110:
				pOutputFPar -> fnct_no = FO_PAGENUMBER;
			case	FO_TEXT:
				pOutputFPar -> OutFieldFlags.u_GroupId = 4;
				break;
		
			default:
				pOutputFPar -> OutFieldFlags.u_GroupId = 2;
		}
	}
	else
	{
		fread( pOutputFPar, 1, sizeof( OUTPUT_FPAR ), fstream );
	}
}



/*
 * TextParList_Replace1Content(-)
 *
 * History:
 * --------
 * 17.12.94: fplanque: created
 * 11.07.95: fplanque: N'EST PLUS UTILISE! (etait utilise par DataPage_AutoParam())
 */
BOOL	TextParList_Replace1Content(					/* Out: TRUE_1 si ok */
				ARBO_TEXTPAR *	pTextPar_List,			/* In: Liste des textpars Ö remplacer */
				int				n_Fnct,					/* In: Fonction du textpar Ö remplacer */
				const char	 * cpsz_NewContent )		/* In: Modäle du nouveau contenu */
{
	ARBO_TEXTPAR *	pTextPar_Found;
	
	/*
	 * Cherche par de fonction demandÇe:
	 */
	pTextPar_Found = Lookup_SingleLinkList( pTextPar_List, n_Fnct );
	if( pTextPar_Found == NULL )
	{
		return	FALSE0;
	}

	/*
	 * TrouvÇ, remplace le nom:
	 */
	free_String( pTextPar_Found -> nom );
	pTextPar_Found -> nom = STRDUP( cpsz_NewContent );
	
	return 	TRUE_1;
}			
