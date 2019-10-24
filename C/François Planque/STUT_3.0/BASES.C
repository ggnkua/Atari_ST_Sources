/*
 * bases.c
 *
 * Purpose:
 * --------
 * Gestion des Bases de donn‚es/Rubriques
 * -Cr‚ation d'une rubrique
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"BASES.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"WIN_PU.H"
	#include "AESDEF.H"	
	

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * Exernal prototypes:
 */
	/*
	 * G‚n‚ral: 
	 */
	extern	void	ping ( void );
	/* 
	 * Donn‚es: 
	 */
	extern	DATAPAGE	*	create_newDataPage( 
									char			*	pS_title,		/* In: Titre de la demande */
									DATAGROUP	*	datagroup,		/* In: Datagroup ds lequel on veut cr‚er */
									GRECT	 		*	start_box );	/* In: d‚but effet graphique d'ouverture */
	extern	void	attach_new_data( DATADIR *datadir, DATAPAGE *new_data );
	/*
	 Objets: 
	 */
	extern	void	redraw_icon( WIPARAMS * params_adr, int start_ob, int icon, int take_control );

/*
 * Private internal prototypes:
 */
	static void	creer_rubrique( GRECT *start_box );

   
/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * EXTernal variables: 
 */
	/* 
	 * Bureau: 
	 */
	extern	WIPARAMS	*G_wi_list_adr;		/* Adresse de la liste de paramŠtres */
	extern	WIPARAMS	*G_desk_params_adr;	/* ParamŠtres de la "fenˆtre bureau" */


/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * creer_rubrique(-)
 *
 * Purpose:
 * --------
 * Cr‚er une nouvelle rubrique
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 18.06.94: creation new datapage extraite vers create_newDataPage()
 * 22.11.94: am‚lioration dela d‚tection d'erreur avant d'agir
 */
void	creer_rubrique( GRECT *start_box )
{
	DATAGROUP * datagroup;

	if( G_wi_list_adr == NULL
		|| G_wi_list_adr -> class != CLASS_DIR )	
	{
		ping();
		return;
	}

	datagroup = G_wi_list_adr -> datagroup;

	/* 	
	 * V‚rifie que la fenˆtre sup‚rieure peut recevoir une 
	 * nouvelle rub:  
	 */
	if( datagroup -> DataType != DTYP_DATAS )
	{
		ping();
		return;
	}
	else
	{	/* 
		 * Oui, la fenˆtre peut recevoir une rubrique: 
		 * Demande nouveau nom et cr‚e datapage: 
		 */

		DATAPAGE	* pDataPage = create_newDataPage( 
											"NOUVELLE RUBRIQUE",
											datagroup,
											start_box );

		if( pDataPage != NULL )
		{	/*
			 * Si cr‚ation OK:
			 */
			DATA_RECORDS	*data_records;		/* Infos + Pointeurs sur les enregistrements */

			/* 
			 * Cr‚e une zone d'info sur les enregistrements de la base: 
			 */
			data_records = (DATA_RECORDS *) MALLOC( sizeof( DATA_RECORDS ) );
			/* 
			 * Fixe variables et ptrs: 
			 */
			data_records -> nb_records 	= 0;		/* Aucun enregistrement */
			data_records -> first_record	= NULL;
			data_records -> last_record	= NULL;
			/* 
			 * Fixe ptr sur ces infos: 
			 */
			pDataPage -> data.records = data_records;

		}
	}
}
