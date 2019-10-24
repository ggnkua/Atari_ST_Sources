/*
 * generic.c
 *
 * Purpose:
 * -------- 
 * routines de gestion de page g‚n‚riques:
 *
 * History:
 * --------
 * 21.01.95: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"GENERIC.C v1.00 - 03.95"
          

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
	#include	"ARB_OUT.H"
	
	#include "SPEC_PU.H"

	#include "DEF_ARBO.H"
	#include "DATPG_PU.H"
	#include "DBSYS_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"DBINT_PU.H"
	#include	"IOFLD_PU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include "ARBGENPU.H"

/*
 * private
 */
char * Format_Number(
			int		number,		/* In: Nbre … formatter */
			int		n_Format,	/* In: Format d‚sir‚ */
			int		n_Len );		/* In: Longueur du champ */
char * Format_Date(
			const time_t * timer,		/* In: Date … formatter */
			int				n_Format );	/* In: Format d‚sir‚ */
char * Format_FAttrib(
			unsigned char	uc_Attrib,	/* In: Date … formatter */
			int				n_Format );	/* In: Format d‚sir‚ */
char * Format_Size(
			size_t	size,			/* In: Date … formatter */
			int		n_Format,	/* In: Format d‚sir‚ */
			int		n_Len );		/* In: Longueur du champ */

/*
 * --------------------------- METHODES -------------------------------
 */



/*
 * OutFields_DisplayGroup(-)
 *
 * Purpose:
 * --------
 * Affiche tous les champs d'un groupe donn‚
 * Avec effacement pr‚alable pour les champs l'ayant demand‚
 *
 * History:
 * --------
 * 24.01.95: Created: new concept for data display
 * 25.01.95: gŠre offsets
 * 30.01.95: ne traite pas les champs disabled
 * 24.03.95: gestion infos directory
 */
void	OutFields_DisplayGroup(
				VOIE	*	pVoie_curr,			/* In: Voie concern‚e */
				UINT		u_GroupId,			/* In: Groupe … afficher */
				int		n_XOffset,			/* In: Offsets … appliquer aux coordonn‚es des champs */			
				int		n_YOffset )
{
	PAGEARBO 		*	pPageArbo = pVoie_curr -> arboparams;
	ARBO_FIELDPARS	* 	pFieldPars_Output;
	OUTPUT_FPAR		*	pOutput_FPar;
	OUTPUT_FPAR		*	pOutput_FPar_CurrScroll = NULL;
	char				*	psz;

	/*
	 * Beaucoup de champs portent sur l'enregistrement
	 * en cours de visualisation:
	 */
	COMPACT_RECORD	*	pCompactRec = pVoie_curr -> curr_comprec;
	RECORD_NUMBER	*	pRecNumber	= NULL;
	if( pCompactRec != NULL )
	{	/*
		 * Num‚ro de diff‚rentiation de l'enregistrement:
		 */
	 	pRecNumber	= &(pCompactRec -> data.header .header .rec_idnb); 
	}


	/*
	 * Champ scrollable courant:
	 */
	if( pVoie_curr -> pIOField_CurrOut != NULL )
	{
		pOutput_FPar_CurrScroll = pVoie_curr -> pIOField_CurrOut -> FPar.Output;
	}


	/*
	 * -------------------------
	 * Parcourt tous les champs:
	 * En vue de leur effacement:
	 * -------------------------
	 */
	for( pFieldPars_Output = pPageArbo -> output_fields ;
			pFieldPars_Output != NULL ;
			 pFieldPars_Output = pFieldPars_Output -> next )
	{
		pOutput_FPar = &(pFieldPars_Output -> data.output);
	
		/*
		 * V‚rifie l'appartenance du champ au groupe demand‚:
		 */
		if( pOutput_FPar -> OutFieldFlags.u_GroupId != u_GroupId
			|| pOutput_FPar -> OutFieldFlags.b_enabled == FALSE0 )
		{	/*
			 * Ce champ ne nous int‚resse pas,
			 * on passe au suivant:
			 */
			continue;
		}

		/*
		 * Efface le champ:
		 */
		OutField_Clear( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset );
		 
	}


	/*
	 * -------------------------
	 * Parcourt tous les champs:
	 * En vue de leur affichage:
	 * -------------------------
	 */
	for( pFieldPars_Output = pPageArbo -> output_fields ;
			pFieldPars_Output != NULL ;
			 pFieldPars_Output = pFieldPars_Output -> next )
	{
		pOutput_FPar = &(pFieldPars_Output -> data.output);
	
		/*
		 * V‚rifie l'appartenance du champ au groupe demand‚:
		 */
		if( pOutput_FPar -> OutFieldFlags.u_GroupId != u_GroupId
			|| pOutput_FPar -> OutFieldFlags.b_enabled == FALSE0 )
		{	/*
			 * Ce champ ne nous int‚resse pas,
			 * on passe au suivant:
			 */
			continue;
		}

		/* printf("\nAffiche champ: %o %d %x  ", pOutput_FPar -> fnct_no, pOutput_FPar -> fnct_no, pOutput_FPar -> fnct_no ); */
		 
		if( pOutput_FPar_CurrScroll != NULL && pOutput_FPar_CurrScroll == pOutput_FPar )
		{	/*
			 * S'il s'agit du champ principal en cours de consultation
			 * (celui qu'on peut scroller avec suite/retour)
			 * On affiche le texte d‚j… formatt‚ au pr‚alabale et on le
			 * garde en ram pour plus tard (scroll...):
			 */
			OutField_Display( pVoie_curr, pVoie_curr -> pIOField_CurrOut, n_XOffset, n_YOffset );

			/*
			 * Passe au champ suivant:
			 */
			continue;
		}
	
	
		/*
		 * En fonction du type de champ:
		 */
		switch( pOutput_FPar -> fnct_no )
		{
			case	FO_COMMENT:
			{	/*
				 * Commentaire de la page arbo:
				 */
				char *	cpsz_Comment = pVoie_curr -> arbopage -> comment;
				if( cpsz_Comment != NULL )
				{
					IOField_DisplayText( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, cpsz_Comment, strlen( cpsz_Comment ) );
				}
				break;
			}
			
			
			case	FO_DATACOMMENT:
				/*
				 * Commentaire de la base de donn‚es affich‚e:
				 */
				if( pVoie_curr -> database != NULL )
				{
					char *	cpsz_Comment = pVoie_curr -> database -> comment;
					if( cpsz_Comment != NULL )
					{
						IOField_DisplayText( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, cpsz_Comment, strlen( cpsz_Comment ) );
					}
				}
				break;


			case	FO_TEXTCOMMENT:
				/*
				 * Commentaire du texte affich‚:
				 */
				if( pVoie_curr -> pDataPage_OpenText != NULL )
				{
					char *	cpsz_Comment = pVoie_curr -> pDataPage_OpenText -> comment;
					if( cpsz_Comment != NULL )
					{
						IOField_DisplayText( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, cpsz_Comment, strlen( cpsz_Comment ) );
					}
				}
				break;


			case	FO_RECNUMBER:
				/*
				 * No de record courant:
				 */
				psz = Format_Number( pVoie_curr -> n_RecIndex_Curr, pOutput_FPar -> n_Format, pOutput_FPar -> w );
				IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );
				break;


			case	FO_PAGENUMBER:
				/*
				 * No de page courante:
				 */
				psz = Format_Number( pVoie_curr -> n_PageNumber_Curr, pOutput_FPar -> n_Format, pOutput_FPar -> w );
				IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );
				break;


			case	FO_CREATEDATE:
				/*
			 	 * Date de cr‚ation RECORD:
	 			 */
				if( pRecNumber == NULL )
				{
					break;
				}

				psz = Format_Date( &(pRecNumber -> date), pOutput_FPar -> n_Format ); 
				IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );

				break;
			
			
			case	FO_PUBPRIV:
				/*
				 * Enregsitrement public ou priv‚:
				 */
				if( pRecNumber != NULL )
				{
					RECORD_FLAGS	RecFlags = CompRec_GetRecFlags( pCompactRec );
					const char * 	cpsz_PubPriv;

					if( RecFlags .b_Private )
					{
						cpsz_PubPriv = "V";
					}
					else
					{
						cpsz_PubPriv = "P";
					}
					IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, cpsz_PubPriv );
				}
				break;

			case	FO_PATH:			/* Chemin d'accŠs courant */		
				psz = pVoie_curr -> pMsz_Path;
				IOField_DisplayText( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz, len_String(psz) );
				break;
				
			case	FO_NBFILES:
				/*
				 * Nbre de fichiers ds dir courant:
				 */
				psz = Format_Number( pVoie_curr -> nb_DirEnt, pOutput_FPar -> n_Format, pOutput_FPar -> w );
				IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );
				break;

			case	FO_FILENAME:	/* Nom de fichier */
			case	FO_FILEATTRIB:	/* Nom de fichier */
			case	FO_FILEDATE:	/* Date de maj du fichier */
			case	FO_FILESIZE:	/* Taille du fichier */
			{
				DIRENTRY	**	TpDirEnt = pVoie_curr -> TpDirEnt;
				DIRENTRY	*	pDirEnt;
				if( TpDirEnt == NULL )
				{
					break;
				}
				pDirEnt = TpDirEnt[ pVoie_curr -> n_RecIndex_Curr -1 ];
				
				switch( pOutput_FPar -> fnct_no )
				{
					case	FO_FILENAME:	/* Nom de fichier */
						psz = pDirEnt -> sz_fname;
						IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );
						break;
	
					case	FO_FILEATTRIB:	/* Attributs */
						psz = Format_FAttrib( pDirEnt -> uc_attrib, pOutput_FPar -> n_Format ); 
						IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );
						break;
	
					case	FO_FILEDATE:	/* Date de maj du fichier */
						psz = Format_Date( &(pDirEnt -> time_LastChange), pOutput_FPar -> n_Format ); 
						IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, psz );
						break;
	
					case	FO_FILESIZE:	/* Taille du fichier */
						psz = Format_Size( pDirEnt -> ul_length, pOutput_FPar -> n_Format, pOutput_FPar -> w );
						IOField_DisplayString( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, G_tmp_buffer );
						break;
				}
				break;
			}

			case	FO_USERNAME:	/* USER Login/Username/Pseudo */
			case	FO_FIRSTNAME:	/* 1STN pr‚nom */
			case	FO_LASTNAME:	/* LSTN nom */
			case	FO_TITLE:		/* MTIT Aff du titre */
			case	FO_TEXT:			/* MTXT Affichage du texte */
			case	FO_DSTA:			/* DSTA Adresse destination */
			case	FO_MPSE:			/* MPSE Pseudo Auteur */
			/* case	DB_FIELD: 	/ user database code */
			{	/*
				 * On veut l'affichage d'un champ de base de donn‚es:
				 * Il faut commencer par trouver ce champ dans le record courant:
				 */
				COMPACT_FIELD * 	pCompField = Find_FieldinCompactRecord( pCompactRec, pOutput_FPar -> ul_CodeChamp );
				if( pCompField == NULL || pCompField -> size_FieldLen == 0 )
				{	/*
					 * Si le champ voulu n'est pas disponible dans ce record:
					 */
					break;
				}

				/* Affiche nom du champ: */
				/*	printf("Champ %c%c%c%c: ", rec_ptr[0], rec_ptr[1], rec_ptr[2], rec_ptr[3]); */

				/*
				 * Affichage du champ:
				 */
				IOField_DisplayText( pVoie_curr, pOutput_FPar, n_XOffset, n_YOffset, (char*) (pCompField -> bytes), pCompField -> size_FieldLen );

				break;			
			}
			
			default:
				/*
				 * Ne sait pas afficher ce champ:
				 */
				ping();
				sprintf( G_tmp_buffer, "WARNING: Ne sait pas afficher OutField Fnct %d", pOutput_FPar -> fnct_no );
				add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
				break;
		}
	}
} 


/*
 * Format_Number(-)
 *
 * Formattage d'un nombre selon format d‚sir‚
 *
 * 26.03.95: Created
 */  
char * Format_Number(
			int		number,		/* In: Nbre … formatter */
			int		n_Format,	/* In: Format d‚sir‚ */
			int		n_Len )		/* In: Longueur du champ */
{
	static	FNCTSPEC	 fnspec_Numbers[]=
	{
		FMT_NUMBER_LEFT,	"%d",
		FMT_NUMBER_RIGHT,	"%*d",
		FMT_NUMBER_ZEROS,	"%0*d"
	};
	
	const char * cpsz_Format = fnct_spec( fnspec_Numbers, n_Format ) -> fnct_name;

	if( n_Format < FMT_NUMBER_RIGHT )
	{	/*
		 * La longueur du champ n'intervient pas!
		 */
		sprintf( G_tmp_buffer, cpsz_Format, number );
	}
	else
	{ 
		sprintf( G_tmp_buffer, cpsz_Format, n_Len, number );
	}
	
	return	G_tmp_buffer;
}


/*
 * Format_Date(-)
 *
 * Formattage d'une date selon format d‚sir‚
 *
 * 25.03.95: Created
 */  
char * Format_Date(
			const time_t * timer,		/* In: Date … formatter */
			int				n_Format )	/* In: Format d‚sir‚ */
{
	static	FNCTSPEC	 fnspec_Dates[]=
	{
		FMT_DATE_STD,		"%T",							/* Fri Mar 24 23:00:00 1995 */
		FMT_DATE_JmAAHMS,	"%D %N %Y %H:%M:%S",		/* 24 Mar 1995 23:00:00 */
		FMT_DATE_JmAHMS,	"%D %N %y %H:%M:%S",		/* 24 Mar 95 23:00:00 */
		FMT_DATE_JMAAHMS,	"%D.%n.%Y %H:%M:%S",		/* 24.03.1995 23:00:00 */
		FMT_DATE_JMAHMS,	"%D.%n.%y %H:%M:%S",		/* 24.03.95 23:00:00 */
		FMT_DATE_JMHMS,	"%D/%n %H:%M:%S",			/* 24/03 23:00:00 */
		FMT_DATE_JJMAHMS,	"%J %D.%n.%y %H:%M:%S",	/* Fri 24.03.95 23:00:00 */
		FMT_DATE_JJMHMS,	"%J %D/%n %H:%M:%S",		/* Fri 24/03 23:00:00 */
		FMT_DATE_HMS,		"%H:%M:%S",					/* 23:00:00 */
		FMT_DATE_HMSP,		"%h:%M:%S %P",				/* 11:00:00 PM */
		FMT_DATE_HMP,		"%h:%M %P",					/* 11:00 PM */
		FMT_DATE_H, 		"%Hh",						/* 23h */
	};
	
	const char * cpsz_Time = ctime( timer );
	
	const char * cpsz_Format = fnct_spec( fnspec_Dates, n_Format ) -> fnct_name;

	const char * cpiBsz_Format = cpsz_Format;
	char		  * piBsz_Output = G_tmp_buffer;
	char				car;
	
	while( (car = *(cpiBsz_Format++) ) != '\0' )
	{
		if( car == '%' )
		{	/*
			 * Il faut faire un remplacement:
			 * Selon code donn‚ aprŠs %
			 */
			const char * cpsz_Srce;
			size_t		 size; 
			 
			 
			switch( *(cpiBsz_Format++) )
			{
				case	'D':
					/*
					 * Date  24
					 */
					cpsz_Srce = cpsz_Time+8;
					size = 2;
					break;

				case	'H':
					/*
					 * Heure 23
					 */
					cpsz_Srce = cpsz_Time+11;
					size = 2;
					break;

				case	'h':
				{	/*
					 * Heure 11:
					 */
					int heure = atoi( cpsz_Time+11 );	
					if( heure > 12 )
					{
						heure %= 12;
					}
					sprintf( G_2nd_buffer, "%02d", heure );
					cpsz_Srce = G_2nd_buffer;
					size = 2;
				}
					break;
					
				case	'J':
					/*
					 * Jour	Fri
					 */
					cpsz_Srce = cpsz_Time;
					size = 3;
					break;

				case	'M':
					/*
					 * Minutes 00
					 */
					cpsz_Srce = cpsz_Time+14;
					size = 2;
					break;

				case	'N':
					/*
					 * Mois Mar
					 */
					cpsz_Srce = cpsz_Time+4;
					size = 3;
					break;

				case	'n':
					/*
					 * Mois 03
					 */
					cpsz_Srce = NULL;

					switch( cpsz_Time[ 4 ] )
					{
						case	'A':
							switch( cpsz_Time[ 5 ] )
							{
								case	'p':
									cpsz_Srce = "04";
									break;
								
								case	'u':
									cpsz_Srce = "08";
									break;
							}
							break;
							
						case	'D':
							cpsz_Srce = "12";
							break;
						
						case	'F':
							cpsz_Srce = "02";
							break;
						
						case	'J':
							switch( cpsz_Time[ 5 ] )
							{
								case	'a':
									cpsz_Srce = "01";
									break;
								
								case	'u':
									switch( cpsz_Time[ 6 ] )
										{
											case	'n':
												cpsz_Srce = "06";
												break;
											
											case	'l':
												cpsz_Srce = "07";
												break;
										}
										break;
								}
							break;
							
						case	'M':
							switch( cpsz_Time[ 6 ] )
							{
								case	'r':
									cpsz_Srce = "03";
									break;
								
								case	'y':
									cpsz_Srce = "05";
									break;
							}
							break;

						case	'O':
							cpsz_Srce = "10";
							break;

						case	'N':
							cpsz_Srce = "11";
							break;

						case	'S':
							cpsz_Srce = "09";
							break;
					}

					if( cpsz_Srce == NULL )
					{
						cpsz_Srce = "?m";
					}
					size = 2;
					break;

				case	'P':
					/*
					 * AM/PM
					 */
					if( cpsz_Time[11] == '2' ||
						 (cpsz_Time[11] == '1' && cpsz_Time[12] >= '2' ) )
					{
						cpsz_Srce = "PM";
					}
					else
					{
						cpsz_Srce = "AM";
					}
					size = 2;
					break;

				case	'S':
					/*
					 * Secondes 00
					 */
					cpsz_Srce = cpsz_Time+17;
					size = 2;
					break;

				case	'T':
					/*
					 * Time complet
					 */
					cpsz_Srce = cpsz_Time;
					size = 24;
					break;

				case	'Y':
					/*
					 * Year 1995
					 */
					cpsz_Srce = cpsz_Time+20;
					size = 4;
					break;
	
				case	'y':
					/*
					 * year 95
					 */
					cpsz_Srce = cpsz_Time+22;
					size = 2;
					break;

				default:
					/*
					 * Code non reconnu:
					 */
					cpsz_Srce = "?%";
					size = 2;
			}

			strncpy( piBsz_Output, cpsz_Srce, size );
			piBsz_Output += size;
		}
		else
		{	/*
			 * On insŠre le caractŠre tel quel:
			 */
			*(piBsz_Output++) = car;		
		}
	}

	/*
	 * Fin de chaine:
	 */	
	*piBsz_Output = '\0';

	return	G_tmp_buffer;
}			


/*
 * Format_FAttrib(-)
 *
 * Formattage des attributs de fichier selon format d‚sir‚
 *
 * 26.03.95: Created
 */  
char * Format_FAttrib(
			unsigned char	uc_Attrib,	/* In: Date … formatter */
			int				n_Format )	/* In: Format d‚sir‚ */
{
	FAKE_USE( n_Format );
	
	strcpy( G_tmp_buffer, "-----" );
	
	if( uc_Attrib & FA_SUBDIR )
	{
		G_tmp_buffer[0] = 'D';
	}

	if( uc_Attrib & FA_READONLY )
	{
		G_tmp_buffer[1] = 'R';
	}

	if( uc_Attrib & FA_HIDDEN )
	{
		G_tmp_buffer[2] = 'H';
	}

	if( uc_Attrib & FA_SYSTEM )
	{
		G_tmp_buffer[3] = 'S';
	}

	if( uc_Attrib & FA_ARCHIVE )
	{
		G_tmp_buffer[4] = 'A';
	}

	return	G_tmp_buffer;
}


/*
 * Format_Size(-)
 *
 * Formattage d'une taille de fichier selon format d‚sir‚
 *
 * 26.03.95: Created
 */  
char * Format_Size(
			size_t	size,			/* In: Date … formatter */
			int		n_Format,	/* In: Format d‚sir‚ */
			int		n_Len )		/* In: Longueur du champ */
{
	if( n_Format == FMT_FILESIZE_KOCTETS && size > 0)
	{
		size /= 1024;	
		if( size == 0 )
		{
			size = 1;
		}
	}
	
	sprintf( G_tmp_buffer, "%*lu", n_Len, size );
	
	return	G_tmp_buffer;
}



/*
 * Generic_DisplayPageChange(-)
 *
 * Purpose:
 * --------
 * Affiche les informations de la nouvelle page
 * … laquelle on vient de se rendre
 *
 * Notes:
 * ------
 * Egalement utilis‚ par DISPTEXT.C
 *
 * History:
 * --------
 * 19.12.94: fplanque: Created
 * 13.01.95: effacement des champs qui vont ˆtre renouvel‚s
 * 21.01.95: chang‚ nom depuis LectMsg_DisplayPageChange()
 * 24.01.95: n'efface plus les champs: c auto matok now
 */
void	Generic_DisplayPageChange(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	register_action( pVoie_curr, DISP, FE_CHGPAGE, 0, NULL );		/* Demande affichage page ‚cran */
	register_action( pVoie_curr, DPAG, 0, 0, NULL );		/* Affiche message */
	register_action( pVoie_curr, CPOS, 0, 0, NULL );		/* Repositionne curseur pour continuer ‚dition */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );		/* Repasse en mode d'attente d'action */
}


/*
 * Generic_DispPage(-)
 *
 * Purpose:
 * --------
 * Affiche une page du texte formatt‚ courant
 *
 * History:
 * --------
 * 18.12.94: fplanque: moved from LectMsg_DispMsg()
 * 21.01.95: chang‚ nom depuis LectMsg_DispPage()
 */
void	Generic_DispPage(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{

	/*
	 * Calcul du num‚ro de page:
	 */
	if( pVoie_curr -> pIOField_CurrOut != NULL )
	{
		long  l_TopLineText = pVoie_curr -> pIOField_CurrOut -> l_TopLine;
		int	nb_LinesOnPage = pVoie_curr -> pOutputFPar_CurrOut -> h;
		pVoie_curr -> n_PageNumber_Curr = (int) (l_TopLineText / nb_LinesOnPage) + 1;
	}
	else
	{
		pVoie_curr -> n_PageNumber_Curr = 0;
	}

	/*
	 * Affichage des champs du groupe 4:
	 * (MTXT, no page)
	 */
	OutFields_DisplayGroup( pVoie_curr, 4, 0, 0 );
}
