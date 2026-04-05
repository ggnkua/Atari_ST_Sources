/* **[Fonction commune]********** */
/* *                            * */
/* * 11/05/2002 MaJ 11/08/2017  * */
/* ****************************** */


#ifndef __FCM_RESERVE_RAM_C__
#define __FCM_RESERVE_RAM_C__



/* !!! faudra reecrire cette fonction un de ses quatre !!! */


#include "fcm_reserve_ram.h"




/* Fonction */
uint32 Fcm_reserve_ram( int32 nombre, uint16 mode )
{
/*
   renvoie 0 en cas d'erreur
*/

/* nombre :
   -1  pour le plus gros bloc de mémoire disponible 
*/

/* mode :
    bit 0-2
	#define	MX_STRAM		0
	#define	MX_TTRAM		1
	#define	MX_PREFSTRAM	2
	#define	MX_PREFTTRAM	3
    bit 3
	#MX_MPROT               8
	bit 4-7
	#define	MX_PRIVATE		16
	#define MX_GLOBAL		32
	#define	MX_SUPERVISOR	48
	#define	MX_READABLE		64
*/

	int32	 adr_ram=0;
	int32	 taille_demande=nombre;
	uint32	*pt_set_key;
	//uint16   gemdos_version;


	/* version du GEMDOS */
	/*{
		int16 dummy;

		dummy = Sversion();
		gemdos_version = (uint16)dummy >> 8;
		gemdos_version = gemdos_version + ((uint16)dummy << 8);
	}*/


	if( Fcm_systeme.gemdos_version<0x19 && ((mode & 3)==MX_TTRAM) )
	{
		/* si pas de Mxalloc() et on demande de la TT RAM, ca va pas */
		return(0);
	}
	


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""TAB8"* Fcm_reserve_ram (%ld,%d)"CRLF, nombre, mode );
	log_print(FALSE);
	#endif




	/* ------------------------------ */
	/* On demande la RAM disponible ? */
	/* ------------------------------ */
	if( nombre == -1 )
	{
		if( Fcm_systeme.gemdos_version >= 0x19 )
		{

			#ifdef LOG_FILE
			sprintf( buf_log, TAB8" - Mxalloc()"CRLF);
			log_print(FALSE);
			#endif

			/* Si Mxalloc() est support‚... */
			adr_ram = Mxalloc( nombre, mode );
		}
		else
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
		return( (uint32)adr_ram );
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

		return(0);
	}




	/* 8 octects de plus pour y placer 2 cl‚ de    */
	/* controle afin de pr‚venir des d‚bordements  */
	nombre=nombre+8;


	/* On arrondi la taille du buffer au multiple de 256 sup‚rieur */
	nombre=( nombre + 255 ) & (int32)0xFFFFFF00;


	/* On v‚rifie l'index qui m‚morise nos allocations de RAM.   */
	/* On peut m‚moriser MAX_POINTEUR allocation de RAM, au dela */
	/* on reste sur le dernier index du tableau                  */
	RAM_index_tableau_ram=MIN( (RAM_MAX_POINTEUR-1), RAM_index_tableau_ram );



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - [R%d] Reservation RAM, taille: demand‚=%08ld - reserv‚=%08ld (multiple de 256)"CRLF, RAM_index_tableau_ram, taille_demande, nombre);
	log_print(FALSE);
	#endif



	/* On r‚serve la RAM */
	if( Fcm_systeme.gemdos_version >= 0x19 )
	{
		/* Si Mxalloc() est support‚... */
		adr_ram = Mxalloc( nombre, mode );

		#ifdef LOG_FILE
		sprintf( buf_log, TAB8" - Mxalloc() reponse=&h%lx"CRLF, adr_ram);
		log_print(FALSE);
		#endif
	}
	if( adr_ram<2048 && ( (mode & 3) != MX_TTRAM) )
	{
		/* sinon, on utilise le bon vieux Malloc() */
		adr_ram=Malloc(nombre);

		#ifdef LOG_FILE
		sprintf( buf_log, TAB8" - Malloc() reponse=&h%lx"CRLF, adr_ram);
		log_print(FALSE);
		#endif
	}


	if( adr_ram<2048 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR, la RAM n'a pu etre alou‚ !"CRLF);
		log_print(FALSE);
		#endif

		return(0);
	}


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - adresse=&h%08lx -> ", adr_ram);
	log_print(FALSE);
	if( (uint32)adr_ram & 0xff000000 )
	{
		sprintf( buf_log, "TT RAM"CRLF);
	}
	else
	{
		sprintf( buf_log, "ST RAM"CRLF);
	}
	log_print(FALSE);
	#endif



	RAM_nb_malloc++;
	RAM_table_pointeur[RAM_index_tableau_ram] = (uint32)adr_ram;

	/* on ajoute notre cl‚ de controle anti d‚bordement */
	/* aligné sur adresse multiple de 4 */
	taille_demande = (taille_demande+3) & (int32)0xfffffffc;
	pt_set_key=(uint32 *)(adr_ram+taille_demande);

	RAM_table_key[RAM_index_tableau_ram]=(uint32)pt_set_key;


	/* on incremente l'index pour la prochaine r‚s‚rvation */
	RAM_index_tableau_ram++;

	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - cl‚ de controle: adresse cl‚=&h%08lx (offset=+%ld)"CRLF, (uint32)pt_set_key, ((uint32)pt_set_key-(uint32)adr_ram) );
	log_print(FALSE);
	#endif


//FCM_CONSOLE_DEBUG1("Fcm_reserve_ram() : adr    adr_ram=0x%lx", adr_ram );
//FCM_CONSOLE_DEBUG1("Fcm_reserve_ram() : adr pt_set_key=%p", pt_set_key );

	*pt_set_key++=0x12345678;
	*pt_set_key  =0x87654321;

//FCM_CONSOLE_DEBUG1("Fcm_reserve_ram() :    *pt_set_key=%lx", *pt_set_key );


	/* On retourne l'adresse du buffer RAM */
	return( (uint32)adr_ram );


}


#endif

