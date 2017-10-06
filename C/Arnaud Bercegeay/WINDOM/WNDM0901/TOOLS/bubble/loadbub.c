/*
 *	Charge le texte des bulles d'aide de Bubble
 *	contenus dans les fichiers BUB
 *  Dominique B‚r‚ziat 1996/1998 
 *  Tous droits r‚serv‚s
 */

#include <windom.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_SIZE	255		/* Longueur maximale d'un texte de bulle d'aide */

char *bubble_adr=NULL;

int LoadBubble( char *filename)
{
	FILE *fp;
	char buf[MAX_SIZE],*p,*q;
	size_t fsize;
	int pere, obj;
	OBJECT *tree;
	
	strcpy( buf, filename);
	shel_find( buf);
	
	fp = fopen( buf, "r");
	if( fp == NULL) {
		return -33;
	}
	fseek( fp, 0, 2);
	fsize = ftell( fp);
	rewind( fp);
	
	/* reserver de la m‚moire */
	bubble_adr = (char*)malloc(sizeof(char)*fsize);
	if( bubble_adr == NULL) {
		form_alert( 1, "[1][Plus de m‚moire disponible|pour les bulles d'aides!][Ok]");
		fclose( fp);
	}
	q = bubble_adr;
	while( !feof(fp)) {
		fgets( buf, MAX_SIZE, fp);
		if( buf[strlen(buf)-1] == '\n')
			buf[strlen(buf)-1] = '\0';
		sscanf( buf, "%d %d", &pere, &obj);
		rsrc_gaddr( 0, pere, &tree);

		if( (p = strchr( buf, '@')) != NULL) {	/* Alias */
			int pere_a, obj_a;
			OBJECT *tree_a;
			
			sscanf( p, "@ %d %d", &pere_a, &obj_a);
			rsrc_gaddr( 0, pere_a, &tree_a);
			BubbleFind( tree_a, obj_a, &p);
			BubbleAttach( tree, obj, p);
		} else {
			p = strchr( buf, ' ')+1;
			p = strchr( p, ' ')+1;
			strcpy( q, p);
			BubbleAttach( tree, obj, q);
			q += strlen( p)+1;
		}
	} 
	fclose( fp);
	return 0;
}

void UnLoadBubble( void) {
	if( bubble_adr) {
		BubbleFree();
		free( bubble_adr);
	}
}