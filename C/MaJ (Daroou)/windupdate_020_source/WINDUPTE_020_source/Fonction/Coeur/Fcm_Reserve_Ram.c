/* **[Fonction commune]********** */
/* *                            * */
/* * 11/05/2002 :: 09/06/2014   * */
/* ****************************** */


#ifndef __Fcm_reserve_ram__
#define __Fcm_reserve_ram__



#include "Coeur_define.c"
#include "type_gcc.h"


#define RAM_MAX_POINTEUR	512				/* 512 pointeurs de RAM distinct */

ULONG  RAM_table_pointeur[RAM_MAX_POINTEUR]; 	/* detection fuite Malloc          */
ULONG  RAM_table_key[RAM_MAX_POINTEUR];		/* detection d‚bordement de buffer */
UWORD  RAM_index_tableau_ram=0;			/* l'index pour les deux tableaux  */
UWORD  RAM_nb_malloc=0;					/* Nombre de demande totale */






/* Prototype */
ULONG Fcm_reserve_ram( LONG nombre, WORD mode );


/* Fonction */
ULONG Fcm_reserve_ram( LONG nombre, WORD mode )
{
/*	#define	MX_STRAM		0
	#define	MX_TTRAM		1
	#define	MX_PREFSTRAM	2
	#define	MX_PREFTTRAM	3

	#define	MX_PRIVATE		16
	#define MX_GLOBAL		32
	#define	MX_SUPERVISOR	48
	#define	MX_READABLE		64*/

	LONG	 adr_ram=0;
	LONG	 taille_demande=nombre;
	ULONG	*pt_set_key;
	uint16   gemdos_version;


	/* version du GEMDOS */
	{
		int16 dummy;

		dummy=Sversion();
		gemdos_version=dummy>>8;
		gemdos_version=gemdos_version + (dummy<<8);
	}



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_reserve_ram (%ld,%d)"CRLF, nombre, mode );
	log_print(FALSE);
	#endif




	/* ------------------------------ */
	/* On demande la RAM disponible ? */
	/* ------------------------------ */
	if( nombre == -1 )
	{
		if( gemdos_version >= 0x19 )
		{

			#ifdef LOG_FILE
			sprintf( buf_log, TAB8" - Mxalloc()"CRLF);
			log_print(FALSE);
			#endif

			/* Si Mxalloc() est support‚... */
			adr_ram = Mxalloc( nombre, mode );
		}

		if( adr_ram < 2048 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, TAB8" - Malloc()"CRLF);
			log_print(FALSE);
			#endif

			/* sinon, on utilise le bon vieux Malloc() */
			adr_ram = Malloc(nombre);
		}

		#ifdef LOG_FILE
		sprintf( buf_log, TAB8" - %08ld octets libre"CRLF, adr_ram);
		log_print(FALSE);
		#endif

		/* On retourne la quantit‚ de RAM dispo */
		return( adr_ram );
	}




	/* -------------------------- */
	/* On veut r‚server de la RAM */
	/* -------------------------- */

	/* la quantit‚ est correct ? */
	if( nombre <= 0  )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR - Taille demand‚ invalide ! (%ld octets)"CRLF, nombre );
		log_print(FALSE);
		#endif

		return( FALSE );
	}




	/* 8 octects de plus pour y placer une cl‚ de */
	/* controle afin de pr‚venir des d‚bordements  */
	nombre=nombre+8;


	/* On arrondi la taille du buffer au multiple de 256 sup‚rieur */
	nombre=( nombre + 255 ) & 0xFFFFFF00;


	/* On v‚rifie l'index qui m‚morise nos allocations de RAM.   */
	/* On peut m‚moriser MAX_POINTEUR allocation de RAM, au dela */
	/* on reste sur le dernier index du tableau                  */
	RAM_index_tableau_ram=MIN( (RAM_MAX_POINTEUR-1), RAM_index_tableau_ram );
	/* RAM_MAX_POINTEUR defini dans variable fonction */


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - [R%d] Reservation RAM, taille: demand‚=%08ld - reserv‚=%08ld"CRLF, RAM_index_tableau_ram, taille_demande, nombre);
	log_print(FALSE);
	#endif



	/* On r‚serve la RAM */
	if( gemdos_version >= 0x19 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB8" - Mxalloc()"CRLF);
		log_print(FALSE);
		#endif
		/* Si Mxalloc() est support‚... */
		adr_ram = Mxalloc( nombre, mode );
	}
	if( adr_ram<2048 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB8" - Malloc()"CRLF);
		log_print(FALSE);
		#endif
		/* sinon, on utilise le bon vieux Malloc() */
		adr_ram=Malloc(nombre);
	}


	if( adr_ram<2048 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR, la RAM n'a pu etre alou‚ !"CRLF);
		log_print(FALSE);
		#endif

		return( FALSE );
	}


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - adresse=$%08lx"CRLF, adr_ram);
	log_print(FALSE);
	#endif



	RAM_nb_malloc++;
	RAM_table_pointeur[RAM_index_tableau_ram]=adr_ram;

	/* on ajoute notre cl‚ de controle anti d‚bordement */
	pt_set_key=(ULONG *)(adr_ram+taille_demande);

	RAM_table_key[RAM_index_tableau_ram]=(ULONG)pt_set_key;


	/* on incremente l'index pour la prochaine r‚s‚rvation */
	RAM_index_tableau_ram++;

	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - cl‚ de controle: adresse cl‚=%08lx (offset=+%ld)"CRLF, (ULONG)pt_set_key, ((ULONG)pt_set_key-adr_ram) );
	log_print(FALSE);
	#endif


	*pt_set_key++=0x12345678;
	*pt_set_key  =0x87654321;



	/* On retourne l'adresse du buffer RAM */
	return( adr_ram );


}


#endif

