/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: data.c
 *	description: attache des donn‚es aux fenˆtres
 */

#include <stddef.h>
#include <stdlib.h>
#include "globals.h"

typedef struct _wdata {
		long magic;				/* the magic number idenitfies data */
		void *data; 			/* data address */
		struct _wdata *next; 	/* next item */
	} WDATA;


/*
 * Supprime un element de la liste des donnees d'une
 * fenetre.
 * Retourne 0 si pas d'erreur
 *          ERR_NOT_FOUND si l'element n'existe pas 
 */

int DataDelete( WINDOW *win, long magic) {
	WDATA *scan = win->data;

	/* Cas element en tete */
	if( scan && scan->magic == magic) {
		win->data = scan-> next;
		free(scan);
	} else {
		/* Recherche de l'element */
		for( ; scan->next && scan->next->magic < magic; scan=scan->next);
		/* Supression de l'element */
		if( scan->next && scan->next->magic == magic) {
			WDATA *trash = scan-> next;
			scan->next = scan->next->next;
			free(trash);
		} else
			/* Element non trouve */
			return -1;
	}
	return 0;
}

/*
 * Retourne l'adresse d'une donn‚e associ‚e … une
 * fenetre ou NULL si la donnee n'existe pas.
 */

void *DataSearch( WINDOW *win, long magic) {
	WDATA *scan;

	for( scan=win->data; scan && scan->magic<magic; scan=scan->next );
	if( scan && scan->magic==magic) 
		return scan->data;
	return NULL;
}

/* Insere un element dans la liste des donnees d'une
 * fenetre. Un element qui existe d‚j… est ‚cras‚
 * Retourne 0 si pas d'erreur
 *          ERR_MEM si erreur malloc
 *          ERR_EXIST si l'element existe deja
 */

int DataAttach( WINDOW *win, long magic, void *data) {
	WDATA *new, *scan;

	/* Recherche */
	for( scan = win->data; scan && scan->magic < magic; scan=scan->next);
	if( scan && scan->magic == magic) {
		new = scan;
	} else {
		/* Creation element si besoin */
		new = (WDATA *)malloc(sizeof(WDATA));
		if( !new)	return -69;
		new->next  = NULL;
		/* et insertion */
		scan = win->data;
		/* insertion en tete */
		if( !scan || magic < scan->magic) {
			new->next = win->data;
			win->data = new;
		} else {
			while(scan->next && scan->next->magic < magic)
				scan = scan->next;
			new->next  = scan->next;
			scan->next = new;
		}
	}
	new->magic = magic;
	new->data  = data;
	return 0;
}

void DataClear( WINDOW *win) {
	WDATA *next, *scan = win->data;
	
	while( scan) {
		next = scan -> next;
		free( scan);
		scan = next;
	}
	win->data = NULL;
}

#include <stdio.h>

void DataTrace( WINDOW *win) {
	WDATA *scan;
	printf( "window %d:\n", win->handle);
	for( scan=win->data; scan; scan=scan->next)
		printf( "magic=%c%c%c%c data=0x%lX\n", 
									(char)(scan->magic >> 24),
									(char)(scan->magic >> 16),
									(char)(scan->magic >>  8),
									(char)(scan->magic >>  0),
									scan->data);
}

/* EOF */
