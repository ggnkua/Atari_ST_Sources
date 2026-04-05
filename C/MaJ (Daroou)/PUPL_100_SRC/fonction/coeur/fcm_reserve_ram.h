/* **[Fonction commune]********** */
/* *                            * */
/* * 11/05/2002 MaJ 11/08/2017  * */
/* ****************************** */


#ifndef __FCM_RESERVE_RAM_H__
#define __FCM_RESERVE_RAM_H__



#define FCM_LIBERE_RAM_CHECK (1)


#define RAM_MAX_POINTEUR	(512)				/* 512 pointeurs de RAM distinct */

uint32  RAM_table_pointeur[RAM_MAX_POINTEUR]; 	/* detection fuite Malloc          */
uint32  RAM_table_key[RAM_MAX_POINTEUR];		/* detection d‚bordement de buffer */
uint16  RAM_index_tableau_ram=0;			/* l'index pour les deux tableaux  */
uint16  RAM_nb_malloc=0;					/* Nombre de demande totale */



#endif   /*   __FCM_RESERVE_RAM_H__   */


