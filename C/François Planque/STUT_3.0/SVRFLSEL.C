/*
 * SvrFlSel.c
 *
 * Purpose:
 * -------- 
 * S‚lecteur de fichiers
 *
 * History:
 * --------
 * 22.01.95: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"SVRFLSEL.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
	#include	<stdlib.h>					/* Pour malloc etc.. */
	#include <tos.h>

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "DEF_ARBO.H"
	#include "DATPG_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include "GEMDIRPU.H"
	#include "GENRC_PU.H"
	#include "SERCOMPU.H"
	#include	"IOFLD_PU.H"
	#include "TEXT_PU.H"
	#include	"FILES_PU.H"


static	void	FileSel_ReadDir(
						VOIE	*	pVoie_curr );		/* In: Voie concern‚e */


/*			
 * --------------------------- METHODES -------------------------------
 */


/*
 * FileSel_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * Suggest:
 * --------
 * Le read-dir ne devrait pas etre inclus ici
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */
void	FileSel_ENPG(
			VOIE	*	pVoie_curr )		/* In: Voie concern‚e */
{
	PAGEARBO 	*	pArboPg = pVoie_curr -> arboparams;
	const char	*	cpsz_RootPath = pArboPg -> special_par.filesel -> pMsz_RootPath;
	char			*	pMsz_SearchPath;

	/*
	 * Affiche donn‚es 
	 */
	register_action( pVoie_curr, DDAT, 0, 0, NULL );
 	
	/*
	 * Cr‚ation PATH courant:
	 */
	free_String( pVoie_curr -> pMsz_Path );
	pMsz_SearchPath = MALLOC( strlen( cpsz_RootPath ) + 15 );
 	strcpy( pMsz_SearchPath, cpsz_RootPath );
 	path_add_backslash( pMsz_SearchPath );
 	strcat( pMsz_SearchPath, "*.*" );
	pVoie_curr -> pMsz_Path = pMsz_SearchPath;
	 	
	/*
	 * Lecture directory:
	 */
	FileSel_ReadDir( pVoie_curr ); 
}



/*
 * FileSel_ReadDir(-)
 *
 * Purpose:
 * --------
 * Lecture du directory courant
 *
 * Notes:
 * ------
 * For direct call: create batches, Should not be batched
 *
 * History:
 * --------
 * 28.01.95: fplanque: Created
 */
void	FileSel_ReadDir(
			VOIE	*	pVoie_curr )		/* In: Voie concern‚e */
{
	/*
	 * Efface eventuellement le directory d‚j… charg‚ en m‚moire:
	 */
 	Dir_Forget( pVoie_curr -> TpDirEnt, pVoie_curr -> nb_DirEnt );

	/*
	 * Charge nouveau dir:
	 */
  	pVoie_curr -> nb_DirEnt = Dir_Read( pVoie_curr -> pMsz_Path, &(pVoie_curr -> TpDirEnt), &(pVoie_curr -> nb_TableEnt) );
	Dir_Sort( pVoie_curr -> TpDirEnt, pVoie_curr -> nb_DirEnt );

	/*
	 * Num‚ro de record en haut de l'‚cran:
	 * Num‚ro de record courant:
	 */
	pVoie_curr -> n_RecIndex_Top = 1;
	pVoie_curr -> n_RecIndex_Curr = 1;

	/*
	 * Demande l'affichage:
	 */
	register_action( pVoie_curr, DREC, 0, 0, NULL );
	register_action( pVoie_curr, DPAG, 0, 0, NULL );
}


/*
 * FileSel_DispData(-)
 *
 * Purpose:
 * --------
 * Affiche les donn‚es initiales … l'‚cran:
 *
 * Notes:
 * ------
 * Ceci n'est normalement ‚x‚cut‚ qu'une seule fois … l'entr‚e de la page
 *
 * History:
 * --------
 * 24.03.95: fplanque: Created
 * 28.03.95: n'affiche plus que le groupe 1
 */
void	FileSel_DispData(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * Affichage champs groupe 1 (commentaire...):
	 */
	OutFields_DisplayGroup( pVoie_curr, 1, 0, 0 );
}


/*
 * FileSel_DispRec(-)
 *
 * Purpose:
 * --------
 * Affiche les donn‚es concernat le dir courant
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 28.03.95: fplanque: Created
 */
void	FileSel_DispRec(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * Affichage champs groupe 2 (Path):
	 */
	OutFields_DisplayGroup( pVoie_curr, 2, 0, 0 );
}



/*
 * FileSel_DispPage(-)
 *
 * Purpose:
 * --------
 * Affiche une page de liste
 *
 * History:
 * --------
 * 24.03.95: fplanque: Created
 */
void	FileSel_DispPage(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	ARBO_LISTPARS	* pArboListPars = pVoie_curr -> arboparams -> pArboListPars;	

	/*
	 * Compteurs de lignes:
	 */
	int	n_Line;
	/*
	 * Offsets d'affichage par rapport aux champs de r‚f‚rence
	 * du groupe 4:
	 */
	int	n_YOffset = 0;

	for( n_Line = 1; 
			n_Line <= pArboListPars -> nb_Lines;
			 n_Line++ )
	{
		if( pVoie_curr -> n_RecIndex_Curr > pVoie_curr -> nb_DirEnt )
		{
			return;
		}

		/*
		 * Affichage des champs du groupe 4:
		 */
		OutFields_DisplayGroup( pVoie_curr, 4, 0, n_YOffset );

		/*
		 * Prochain no de record:
		 */
		(pVoie_curr -> n_RecIndex_Curr) ++;	/* + ou - Relatif au d‚but du groupe */
		
		/*
		 * Descend … l'‚cran:
		 */
		n_YOffset += pArboListPars -> n_InterLine;
	}
}


/*
 * FileSel_ChgePage(-)
 *
 * Purpose:
 * --------
 * Changement de page dans la liste suite … pression sur SUITE ou RETOUR
 *
 * History:
 * --------
 * 26.03.95: fplanque: Created
 */
void	FileSel_ChgePage( 
			VOIE	*	pVoie_curr,			/* In: Voie concern‚e */
			KEYCODE	curr_keypress )	/* In: Touche press‚e */
{
	int	nb_DirEnt = pVoie_curr -> nb_DirEnt;
	int	n_TopDirEnt = pVoie_curr -> n_RecIndex_Top;
	ARBO_LISTPARS	* pArboListPars = pVoie_curr -> arboparams -> pArboListPars;	
	int	nb_MaxDispLines = pArboListPars -> nb_Lines;

	if( nb_DirEnt == 0 )
	{	/*
		 * S'il n'y a rien d'affich‚
		 * ... c'est qu'il n'y a rien … afficher!
		 */
		aff_msg_l0( pVoie_curr, "Dossier Vide!" );
		return;
	}

	affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

	if( curr_keypress == KEY_RETOUR )
	{	/*
		 * Retour:
		 */
		if( n_TopDirEnt <= 1 )
		{
			aff_msg_l0( pVoie_curr, "D‚but de liste!" );
			return;
		}

		n_TopDirEnt -= nb_MaxDispLines;
		if( n_TopDirEnt < 1 )
		{
			n_TopDirEnt = 1;
		}

		pVoie_curr -> n_RecIndex_Top	= n_TopDirEnt;
		pVoie_curr -> n_RecIndex_Curr = n_TopDirEnt;
		
		/*
		 * Demande r‚affichage page:
		 */
		Generic_DisplayPageChange( pVoie_curr );
	}
	else
	{	/*
		 * Suite:
		 */	
		if( n_TopDirEnt + nb_MaxDispLines > nb_DirEnt )
		{
			aff_msg_l0( pVoie_curr, "Fin de liste!" );
			return;
		}

		n_TopDirEnt += nb_MaxDispLines;

		pVoie_curr -> n_RecIndex_Top	= n_TopDirEnt;
		pVoie_curr -> n_RecIndex_Curr = n_TopDirEnt;
		
		/*
		 * Demande r‚affichage page:
		 */
		Generic_DisplayPageChange( pVoie_curr );
	}
}


/*
 * FileSel_KeyAction(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚e sur une page de S‚lection de fichier
 *
 * History:
 * --------
 * 25.03.95: fplanque: Created
 * 14.05.95: correction BUG: le realloc ne gardait pas la place du \0 final du path
 * 14.05.95: efface no apres l'entr‚e dans un dossier
 * 14.10.95: m‚morise nom de fichier selectionne
 */
void	FileSel_KeyAction( 
			KEYCODE	curr_keypress, /* In: Touche press‚e */
			VOIE	*	pVoie_curr )	/* In: Voie concern‚e */
{
	switch( curr_keypress )
	{
		case	KEY_RETOUR:
		case	KEY_SUITE:
			/*
			 * On veut changer de page:
			 */
			FileSel_ChgePage( pVoie_curr, curr_keypress ); 
			break;
					
		case	KEY_ENVOI:				
		{	/*
	 		 * Obtient ligne de commande:	
	 		 * (NE PAS MODIFIER la ligne de commande!)
			 */
			const char * cpBsz_CmdLine = aim_CurrField( pVoie_curr );
			
			long	l_number;
			
			if( extract_number( cpBsz_CmdLine, &l_number ) )
			{	/*
				 * Demande d'ouverture:
				 */
				DIRENTRY 	* pDirEntry;
				const char	* cpsz_FileName; 
				char			* pisz;
				
				if( l_number < 1 || l_number > pVoie_curr -> nb_DirEnt ) 
				{
					aff_msg_l0( pVoie_curr, "Num‚ro de fichier incorrect!" );
					return;
				}
				
				pDirEntry = (pVoie_curr -> TpDirEnt)[ l_number-1 ];
				cpsz_FileName = pDirEntry -> sz_fname;

				if( (pDirEntry -> uc_attrib) & FA_SUBDIR )
				{	/*
					 * Il s'agit d'un sous dossier:
					 */
					sprintf( G_tmp_buffer, "  Ouverture du dossier: %s", cpsz_FileName );
					add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );

					/*
					 * Cr‚ation du nouveau path:
					 * 15: provisoire
					 */					
					pVoie_curr -> pMsz_Path = REALLOC( pVoie_curr -> pMsz_Path, strlen( pVoie_curr -> pMsz_Path ) + strlen( cpsz_FileName ) + 15 );

					pisz = strBchr( pVoie_curr -> pMsz_Path, '\\' ); 
					if( pisz == NULL )
					{
						pisz = pVoie_curr -> pMsz_Path;
					}
					
					sprintf( pisz+1, "%s\\*.*", cpsz_FileName );
					
					/*
					 * Affiche page de transition:
					 */
					register_action( pVoie_curr, DISP, FE_CHGPAGE, 0, NULL );		/* Demande affichage page ‚cran */
	
					/*
					 * Lecture nouveau directory:
					 */
					FileSel_ReadDir( pVoie_curr );
					 
					/*
					 * Efface le champ de saisie en question 
					 * et se remet en attente pour une nouvelle saisie:
					 */
					register_action( pVoie_curr, CLRF, 0, 0, pVoie_curr -> pIOField_CurrIn );		
					register_action( pVoie_curr, WAIT, 0, 0, NULL );		/* Repasse en mode d'attente d'action */
				
					return;
				}
							
				/*
				 * On a tap‚ le no d'un fichier
				 * C'est trŠs probablement pour le t‚l‚charger!
				 * Compose nom du fichier et le m‚morise dans la variable appropri‚e
				 */
				strcpy( G_tmp_buffer, pVoie_curr -> pMsz_Path );
				pisz = strBchr( G_tmp_buffer, '\\' ); 
				if( pisz )
				{
					pisz++;
				}
				else
				{
					pisz = G_2nd_buffer;
				}
				strcpy( pisz, cpsz_FileName );
				freeOld_dupString( &(pVoie_curr ->pMsz_VFile), G_tmp_buffer );
				
				sprintf( G_tmp_buffer, "   S‚lection du fichier: %s", pVoie_curr ->pMsz_VFile );
				add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
				 
				/*
				 * Demande Changement de page:
				 */
				if( follow_ArboLink( pVoie_curr, FL_DOWNLOAD ) == TRUE_1 )
				{	/*
					 * parametres pour la page arbo suivante:
					 */
					/* pVoie_curr -> pDataPage_LockedDB_OUT = pVoie_curr -> database; */
				}
				return;
			}

			/*
			 * On n'a pas tap‚ un nombre...
			 */
			if( ! serv_handleKeyword( pVoie_curr, '\0' ) )
			{	/*
				 * Si pas de mot clef:
				 */
				affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

				/*
				 * Demande Changement de page:
				 */
				follow_KeyArboLink( pVoie_curr, curr_keypress );
			}
			break;
		}
		
		case	KEY_SOMM:
		{
			PAGEARBO 	*	pArboPg = pVoie_curr -> arboparams;
			const char	*	cpsz_RootPath = pArboPg -> special_par.filesel -> pMsz_RootPath;
			char			*	pMsz_CurrPath = pVoie_curr -> pMsz_Path;
			size_t 			size_Root = strlen( cpsz_RootPath );
			char			*	piBsz_EndSlash = strBchr( pMsz_CurrPath, '\\' );

			if( cpsz_RootPath[ size_Root-1 ] != '\\' )
			{	/*
				 * Si le rootpath ne se termine pas par \
				 * sa vraie longueur est plus longue!
				 */
				size_Root++;
			}

			if( piBsz_EndSlash > &( pMsz_CurrPath[ size_Root-1 ] ) )
			{	/*
				 * On est dans un subdir par rapport … Root:
				 * Vire le masque
				 */
				*piBsz_EndSlash = '\0';
				/* 
				 * Cherche
				 */
				piBsz_EndSlash = strBchr( pMsz_CurrPath, '\\' );
				if( piBsz_EndSlash != NULL )
				{
					strcpy( piBsz_EndSlash+1, "*.*" );
					pVoie_curr -> pMsz_Path = REALLOC( pMsz_CurrPath, strlen( pMsz_CurrPath )+1 );

					/*
					 * Affiche page de transition:
					 */
					register_action( pVoie_curr, DISP, FE_CHGPAGE, 0, NULL );		/* Demande affichage page ‚cran */

					/*
					 * Lecture nouveau directory:
					 */
					FileSel_ReadDir( pVoie_curr );

					register_action( pVoie_curr, CPOS, 0, 0, NULL );		/* Repositionne curseur pour continuer ‚dition */
					register_action( pVoie_curr, WAIT, 0, 0, NULL );		/* Repasse en mode d'attente d'action */

					return;
				}
			}
				
			/*
			 * Si on ne peux pas remonter l'arbo, traite sommaire normalement
			 */
		}	


		case	KEY_ANNUL:
		case	KEY_REPET:
		case	KEY_GUIDE:
		case	KEY_CORREC:
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
			/*
			 * Demande Changement de page:
			 */
			follow_KeyArboLink( pVoie_curr, curr_keypress );
			break;

	}

}

