/*
 * dbsystem.c
 *
 * Purpose:
 * --------
 * Routines de gestion du
 * SystŠme de Gestion de Bases de Donn‚es (Relationnelles)
 * Orient‚ R‚seau
 * SGBDRR
 *
 * Notes:
 * ------
 * Designed by Fran‡ois Planque & Xavier Cany
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 1994: fplanque: many revisions
 */

   #include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DBSYSTEM.C v1.00 - 03.95"

/*
 * System headers:
 */
	#include <stdio.h>
	#include <stdlib.h>		/* rand */
	#include <time.h>
	#include <string.h>
	   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"DEBUG_PU.H"	
	#include "DBSYS_PU.H"
	#include "MAIN_PU.H"

/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * Public variables: 
 */
	RECORD_NUMBER	G_RecNb_Null = { 0, 0 };

/*
 * Private variables: 
 */
	static	char	M_magic;				/* Magic number */
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_dbsystem(-)
 *
 * Purpose:
 * --------
 * Init du S.G.B.D.
 *
 * Suggest:
 * --------
 * The MAGIC # should not be random. The Sysop should be allowed
 * to change it.
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_dbsystem( void )
{
	/* 
	 * Nombre magique sp‚ciqiue au serveur: 
	 */
		M_magic = (char) rand();			/* PROVISOIRE */


}


/*
 * CompRec_Create(-)
 *
 * Cr‚ation d'un Compact Record
 *
 * 02.03.95: Created
 */
COMPACT_RECORD * CompRec_Create(				/* Out: ptr sur record cr‚‚ */
							size_t	size_data ) /* In: taille des donn‚es … stocker */
{
	/*
	 * On doit stocker un certain nombre de donn‚es suppl‚mentaires
	 * en plus des donn‚es:
	 */	
	size_data += sizeof( void * );					/* Ptr sur prev */
	size_data += sizeof( void * );					/* next */
	size_data += sizeof( struct s_reclocks );		/* Readlocks sur le record */

	return	(COMPACT_RECORD *) MALLOC( size_data );
}


/*
 * Create_HeaderFld(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'un HEADER d'enregistrement
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 29.11.94: fplanque: chang‚ de fill_header() en Create_HeaderFld()
 * 16.12.94: fplanque: gestion du flag private
 */
RECORD_FIELD	*	Create_HeaderFld(			/* Out: Champ cr‚‚ */
		const RECORD_NUMBER	*	pRecNb_Ref,	/* In:  Id du message auquel on fait r‚f‚rence */
		BOOL							b_Private )	/* In:  !=0 si le message est priv‚ */
{
	HEAD_STRING		*	pHeadString;

	/*
	 * Cr‚e champ:
	 */
	RECORD_FIELD	*	pRecField = MALLOC( sizeof( RECORD_FIELD ) );

	/* ID du champ: */
	pRecField -> field_id = 'HEAD';

	/* Longueur du champ: */
	pRecField -> length = sizeof( HEAD_STRING );

	/*
	 * Cr‚e les infos du HEADER:
	 */
	pHeadString = MALLOC( sizeof( HEAD_STRING ) );
	pRecField -> info.head = pHeadString;
	
	/*
	 * ----------------------------------------
	 * Longueur du message: 
	 * ----------------------------------------
	 * Inconnue pour l'instant, il faudra ABSOLUMENT la mettre … jour … la fin
	 */
	pHeadString -> rec_length = NIL;		

	/*
	 * ----------------------------------------
	 * Num‚ro d'identification du message: 
	 * ----------------------------------------
	 * Date d'‚criture: 
	 */
	time( &(pHeadString -> rec_idnb .date) );		/* Date d'‚criture format UNIX */
									
	/*
	 * Num‚ro de diff‚renciation (Exemple de gestion):
	 * Nombre "magique" que vous choisissez 
	 */
	pHeadString -> rec_idnb .diff .fulc .magic = M_magic;	/* Octet "Magique" */

	/* Repeat Number */
	pHeadString -> rec_idnb .diff .fulc .repeat = 71;	
	/*
	 * Ce message est le 71eme ecrit par le connect‚ depuis l'ouverture
	 * se sa BAL; … 255, on repasse … 0... 
	 */

	/* Nombre al‚atoire */
	pHeadString -> rec_idnb .diff .fulc .random = rand();	/* Num‚ro Random */

	/*
	 * ----------------------------------------
	 * Num‚ro d'identification du message auquel celui-ci fait r‚f‚rence: 
	 * ----------------------------------------
	 */
	pHeadString -> ref_idnb = * pRecNb_Ref;


	/*
	 * ----------------------------------------
	 * Flags de qualification du message:
	 * ----------------------------------------
	 */
	pHeadString -> RecFlags.b_Private = b_Private; 
	pHeadString -> RecFlags.n_Junk = 0;

	return		pRecField;
}



/*
 * Create_SimpleRecFld(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'un Field simple ds un record
 * (un field dont on n'a qu'… coller le contenu(une PSZ) d‚j… tout prˆt)
 *
 * 27.11.94: fplanque: Created
 */
RECORD_FIELD	*	Create_SimpleRecFld(					/* Out: champ cr‚‚ */
							unsigned	long	dw_FieldId,		/* In: Identificateur du champ */
							const char 	*	cpsz_Content )	/* In: texte … recopier DANS le champ */
{
	size_t	field_length;
	char	*	field_string;

	/*
	 * Cr‚e champ:
	 */
	RECORD_FIELD	*	pRecField = MALLOC( sizeof( RECORD_FIELD ) );

	/*
	 * Pas de champ suivant pour l'instant:
	 */
	pRecField -> next = NULL;

	/*
	 * ID du champ 
	 */
	pRecField -> field_id = dw_FieldId;

	/*
	 * Longueur du champ:
	 */
	field_length = ( strlen( cpsz_Content ) +2 ) & PARITY;  /* Longueur paire */
	pRecField -> length = field_length;

	/*
	 * Cr‚e une chaine:
	 */
	field_string = (char *) MALLOC( field_length );			/* R‚serve m‚moire */
	memcpy( field_string, cpsz_Content, field_length );	/* Y recopie les donn‚es */
	field_string[ field_length - 1 ] = '\0';					/* Octet nul comblant le trou si long ‚tait impaire ou ‚crasant l'octet de fin de chaine si long ‚tait d‚j… paire */
	pRecField -> info.string = field_string;				/* Sauve adresse */

	return		pRecField;
}


/*
 * Create_FooterFld(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'un FOOTER d'enregistrement
 *
 * History:
 * --------
 * 29.11.94: fplanque: Created
 */
RECORD_FIELD	*	Create_FooterFld( void )	/* Out: Champ cr‚‚ */
{
	FOOT_STRING		*	pFootString;

	/*
	 * Cr‚e champ:
	 */
	RECORD_FIELD	*	pRecField = MALLOC( sizeof( RECORD_FIELD ) );

	/* ID du champ: */
	pRecField -> field_id = 'FOOT';

	/* Longueur du champ: */
	pRecField -> length = sizeof( FOOT_STRING );

	/*
	 * Cr‚e les infos du FOOTER:
	 */
	pFootString = MALLOC( sizeof( FOOT_STRING ) );
	pRecField -> info.foot = pFootString;
	
	/*
	 * Checksum du message: 
	 * Inconnu pour l'instant, il faudra ABSOLUMENT le mettre … jour … la fin
	 */
	pFootString -> checksum = 0;		

	return		pRecField;
}



/*
 * record_length(-)
 *
 * Purpose:
 * --------
 * D‚termine la longueur totale d'un message
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
size_t	record_length( 
				RECORD_FIELD *field_ptr ) /* In: ptr sur champ header */
{	
	size_t	record_length = 0;
			
	/*
	 * Longueur des segments 
	 */
	while	( field_ptr != NULL )	/* Tant qu'on est pas … la fin de l'enregsitrement */
	{
		record_length +=	  sizeof ( field_ptr -> field_id )	/* Taille d'une ID de champ */
							 	+ sizeof ( field_ptr -> length )		/* Taille de la taille (!) */
							 	+ field_ptr -> length;					/* Taille du texte du champ */
		field_ptr = field_ptr -> next;	/* Pointe sur prochain segment */
	}

	/*
	 * Retourne longueur totale: 
	 */
	return	record_length;
}


/*
 * Create_CompactRecord(-)
 *
 * Purpose:
 * --------
 * Cr‚e un enregistrement sous forme compact‚e
 *
 * History:
 * --------
 *     1993: fplanque: Created
 * 05.12.94: fplanque: changed name from fill_compact_record() and included creation code
 * 11.07.95: fplanque: correction dela taille du malloc (on d‚bordait)
 */
COMPACT_RECORD *	Create_CompactRecord( 
							RECORD_FIELD 	*	field_ptr )
{
	COMPACT_RECORD *	pCompactRec;
	char				*	tmp_msg_start;					/* Adresse de d‚part du message compact‚ */
	char				*	tmp_msg_csr; 					/* Pointeur dans le message complet */
	char				*	last_string_adr = NULL;		/* Adr du dernier string compact‚ */
	char				*	tmp_msg_check;					/* Le mˆme pour checksum */
	unsigned int		checksum = 0;					/* Checksum... */
	

	/*
	 * +------------------------------+ 
	 * |  Longueur totale du message  |
	 * +------------------------------+
	 */
	size_t	rec_length = record_length( field_ptr );		/* Calcul */

	/*
	 * Taille occupp‚e en m‚moire avec 2 pointeurs (sur prev et next)
	 * ainsi que la taille allou‚e aux readlocks: 
	 */
	size_t	rec_memsize = rec_length 
										+ 2 * sizeof( COMPACT_RECORD * )
										+ sizeof( struct	s_reclocks );

	/*
	 * Indique la longueur totale dans les infos du header: 
	 */
	field_ptr -> info.head -> rec_length = rec_length;


	/*
	 * ----------------------------
	 * Alloue une zone en m‚moire :
	 * ----------------------------
	 */
	pCompactRec = (COMPACT_RECORD *) MALLOC ( rec_memsize );
	tmp_msg_start = pCompactRec -> data.compact_rec;	/* Adresse de d‚part du message compact‚ */
	tmp_msg_csr = tmp_msg_start; 	/* Pointeur dans le message complet */

	/*
	 * ----------------------------
	 * remplissage du msg compact‚:
	 * ----------------------------
	 * Les ptr sur PREV et NEXT seront fix‚s ult‚rieurement! 
	 */
	pCompactRec -> prev = NULL;
	pCompactRec -> next = NULL;

	/*
	 * Recopie le contenu des Champs: 
	 */
	while	( field_ptr != NULL )	/* Tant qu'on est pas … la fin du msg */
	{
		/*
		 * Identification du champ: 
		 */
		*( ( unsigned long * ) tmp_msg_csr ) = field_ptr -> field_id;
		tmp_msg_csr += sizeof( unsigned long );

		/*
		 * Longueur du champ: 
		 */
		*( ( size_t * ) tmp_msg_csr ) = field_ptr -> length;
		tmp_msg_csr += sizeof( unsigned long );

		/*
		 * Contenu du champ: 
		 */
		memcpy( tmp_msg_csr, field_ptr -> info.string, field_ptr -> length);
		last_string_adr = tmp_msg_csr;	/* On va conserver l'adresse du string du dernier champ */
		tmp_msg_csr += field_ptr -> length;

		field_ptr = field_ptr -> next;	/* Pointe sur prochain segment */
	}

	/*
	 * Checksum: 
	 */
	for ( tmp_msg_check = tmp_msg_start; tmp_msg_check < tmp_msg_csr; tmp_msg_check++ )
	{
		checksum += *tmp_msg_check;
	}

	/*
	 * InsŠre checksum dans le message: 
	 */
	*(( unsigned int * ) last_string_adr) = checksum;


	/*
	 * Pas (encore) de lock sur ce message:
	 */
	clear_AllLocks( pCompactRec );


	/*
	 * V‚rifie l'int‚grit‚ du compact record cr‚‚:
	 */
	MCHECK( pCompactRec );
	
	return	pCompactRec;
}


/*
 * -------------------------- DATA STORAGE ----------------------------
 */


/*
 * Append_CompactRecToDB(-)
 *
 * Purpose:
 * --------
 * Ajoute un Record Compact … une base de donn‚es
 *
 * History:
 * --------
 * 05.12.94: moved out of Record_InFieldsToDB()
 */
void	Append_CompactRecToDB(
			COMPACT_RECORD *	pCompactRec,	/* In: Ptr sur le Record … ajouter */
			DATA_RECORDS	*	records )		/* In: Base de donn‚es concern‚e */
{
	COMPACT_RECORD	*old_last = records -> last_record;	/* Dernier message avant ajout du nouveau */

	/*	printf( "data records=%lu\n", records ); */
	
	/* 
	 * On va ajouter le message … la fin:
	 * Fixe pointeurs du nouveau message: 
	 */
	pCompactRec -> prev = old_last;		/* Message pr‚c‚dent */
	pCompactRec -> next = NULL;			/* Pas de message suivant */
	
	/* 
	 * Fixe pointeur du dernier message vers le nouveau: 
	 */
	if ( old_last == NULL )
	{	/*
		 * S'il n'existait pas encore de message: 
		 */
		records -> first_record = pCompactRec;		/* On enregistre le premier message */
	}
	else
	{	/*
		 * S'il existait d‚j… un message: 
		 */
		old_last -> next = pCompactRec;
	}
	
	/* 
	 * Fixe pointeur d'infos sur le nouveau dernier message: 
	 */
	records -> last_record = pCompactRec;
	
	/*
	 * 1 message de plus: 
	 */
	records -> nb_records ++;
	
	/* printf("\nNbre de messages=%ld\n", records -> nb_records ); */
}


/*
 * -------------------------- DATA RETRIEVAL ----------------------------
 */

/*
 * Find_FieldinCompactRecord(-)
 *
 * Purpose:
 * --------
 * Cherche un Champ(Field) ds un Enregsitrement(Record)
 *
 * Notes:
 * ------
 * On renvoie le 1er trouv‚!
 * (Il ne devrait normalement pas y en avoir plusieurs!)
 *
 * History:
 * --------
 * 07.12.94: fplanque: Created
 * 24.01.95: sort si compact rec NULL
 */
COMPACT_FIELD * Find_FieldinCompactRecord(
		const	COMPACT_RECORD *	cpCompactRec,
		const ULONG 				cUL_FieldId )
{
	COMPACT_FIELD * cpCompactField;

	if( cpCompactRec == NULL )
	{
		return	NULL;
	}

	for( cpCompactField = &(cpCompactRec -> data.CompactField); ; )
	{
		if( cpCompactField -> UL_FieldId == cUL_FieldId )
		{	/*
			 * On a trouv‚ le champ qui nous int‚resse:
			 */
			return	cpCompactField;
		}
	
		if( cpCompactField -> UL_FieldId == 'FOOT' )
		{	/*
			 * On est arriv‚ … la fin!
			 */
			return	NULL;
		}
	
		/*
		 * Passe au Field suivant:
		 */
		cpCompactField = (COMPACT_FIELD *) ((UBYTE *)cpCompactField 
									+ sizeof(ULONG) 		/* Longueur identifiant */
									+ sizeof(ULONG)		/* Longueur du champ 'longueur' */
									+ cpCompactField -> size_FieldLen);
	}
	
}


/*
 * Find_CompactRecByField(-)
 *
 * Purpose:
 * --------
 * Cherche un Enregistrement(Record) ds une DB
 * en fonction du contenu d'un des champs(Fields)
 *
 * Notes:
 * ------
 * On renvoie le 1er trouv‚
 * (on considŠre qu'il s'agit d'une clef descriptive)
 *
 * History:
 * --------
 * 07.12.94: fplanque: Created
 */
COMPACT_RECORD * Find_CompactRecByField( 
		const	COMPACT_RECORD *	cpCompactRec_Curr,	/* In: Ptr sur record o— doit commencer la recherche */
		const ULONG			 		cUL_FieldId,			/* In: Identifiant du champ qui sert de clef */
		const char 				*	cpsz_FieldContent )	/* In: Clef de recheche */
{
	const COMPACT_FIELD * cpCpactFld;

	while( cpCompactRec_Curr != NULL )
	{
		/*
		 * Cherche le champ(Field) d‚sir‚ dans l'enregistrement(Record):
		 */
		cpCpactFld = Find_FieldinCompactRecord( cpCompactRec_Curr, cUL_FieldId );
		if( cpCpactFld != NULL )
		{	/*
			 * On a trouv‚ le champ qui nous int‚resse:
			 * On v‚rifie le contenu
			 */
			if( strcmp( cpCpactFld -> bytes, cpsz_FieldContent ) == 0 )
			{	/*
				 * Les champs correspondent!
				 */
				return	(COMPACT_RECORD *) cpCompactRec_Curr;
			}
		}
	
		/*
		 * Passe au champ suivant:
		 */	
		cpCompactRec_Curr = cpCompactRec_Curr -> next;
	}
	return	NULL;
}


/*
 * -------------------------- DATA MANAGEMENT ----------------------------
 */

/*
 * clear_AllLocks(-)
 *
 * Purpose:
 * --------
 * Efface tous les locks sur un record
 *
 * Notes:
 * ------
 * A n'utiliser que lors de la cr‚ation d'un enregistrement!
 * On risque des problŠmes s‚rieux dans le cas contraire!
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 */
void	clear_AllLocks( 						
			COMPACT_RECORD *pCompRec ) 	/* In:  Ptr sur record … initialiser */
{

	pCompRec -> locks.nb_ReadLocks = 0;			/* Pas de lock de lecture */
	pCompRec -> locks.b_XLock = FALSE0;			/* Pas de XLock */

} 
 


/*
 * request_ReadLock(-)
 *
 * Purpose:
 * --------
 * Demande et positionne un Lock de lecture sur un enregistrement
 * Lorsqu'une voie/fonction a demand‚ un ReadLock, elle peut librement
 * lire le record, elle n'a, par contre, pas le droit de le modifier.
 *
 * Algorythm:
 * ----------  
 * PROVISOIRE, inachev‚
 *
 * Notes:
 * ------
 * Plusieurs voies/fonctions peuvent detenir simultan‚ment un ReadLock
 * sur le mˆme record
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 */
int	request_ReadLock( 				/* Out: !=0 si erreur */
			COMPACT_RECORD *pCompRec ) /* In:  Ptr sur record … locker */
{

	pCompRec -> locks.nb_ReadLocks ++;			/* Un lock de + */

	/* printf( "\nNbre de readlocks sur record courant: %d  \n", pCompRec -> locks.nb_ReadLocks ); */

	return	SUCCESS0;
} 



/*
 * release_ReadLock(-)
 *
 * Purpose:
 * --------
 * LibŠre le read lock qu'une vois/fonction avait sur un record
 *
 * Algorythm:
 * ----------  
 * PROVISOIRE, inachev‚
 *
 * Notes:
 * ------
 * Plusieurs voies/fonctions peuvent detenir simultan‚ment un ReadLock
 * sur le mˆme record
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 */
void	release_ReadLock(
			COMPACT_RECORD *pCompRec ) 	/* In:  Ptr sur record … d‚locker */
{
	if( pCompRec -> locks.nb_ReadLocks <= 0 )
	{
		signale( "Lib‚ration d'un ReadLock inexistant!" );
		pCompRec -> locks.nb_ReadLocks = 0;			/* S‚curit‚ */
	}
	else
	{
		pCompRec -> locks.nb_ReadLocks --;			/* Un lock de - */
	}

}





/*
 * change_ReadToXLock(-)
 *
 * Purpose:
 * --------
 * Essaie de modifier un ReadLock sur un record en XLock
 *
 * Algorythm:
 * ----------  
 * Si quelqu'un d'autre detient egalement un Readlock sur le record
 * en question, le XLock ne peut pas ˆtre attribu‚.
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 */
int	change_ReadToXLock( 					/* Out: !=0 si impossible */
			COMPACT_RECORD *pCompRec ) 	/* In:  Ptr sur record … locker */
{
	/* printf( "\nNbre de readlocks sur record courant: %d  \n", pCompRec -> locks.nb_ReadLocks ); */

	/*
	 * Abandonne le ReadLock d‚j… d‚tenu et teste s'il y en a d'autres:
	 */
	if( --(pCompRec -> locks.nb_ReadLocks) > 0 )			/* Un lock de - */
	{	/*
		 * S'il y en a d'autres:
		 * On garde son ReadLock et la demande de XLOCK echoue
		 */
		pCompRec -> locks.nb_ReadLocks ++;	
		
		return	FAILURE_1;
	}
	else
	{	/*
		 * Place un XLock:
		 */
		pCompRec -> locks.b_XLock = TRUE_1;
		
		return	SUCCESS0;
	}
} 


/*
 * release_XLock(-)
 *
 * Purpose:
 * --------
 * LibŠre le lock exclusif qu'on avait sur un record
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 */
void	release_XLock(
			COMPACT_RECORD *pCompRec ) 	/* In:  Ptr sur record … d‚locker */
{
	if( pCompRec -> locks.b_XLock == FALSE0 )
	{
		signale( "Lib‚ration d'un XLock inexistant!" );
	}
	else
	{
		pCompRec -> locks.b_XLock = FALSE0;			/* LibŠre lock */
	}

}
