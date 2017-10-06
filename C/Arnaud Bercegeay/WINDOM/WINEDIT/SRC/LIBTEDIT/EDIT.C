/*
 *	Routines d'‚dition de texte
 *	Dominique B‚r‚ziat, tous droits r‚serv‚s
 *	module : edit.c
 *  descr. : 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libtedit.h"

/* NewLine: cr‚‚ une nouvelle ligne */

EDLINE * line_new( char *buf) {
	EDLINE *line = (EDLINE*)malloc(sizeof(EDLINE));
	
	if( line == NULL) return NULL;
	if( buf) {
		line -> buf = strdup( buf);
		if( line -> buf) {
			line -> len = (int)strlen( buf);
			line -> size = line -> len + 1;
			line -> next = line ->prev = NULL;
			return line;
		} 
	} else {
		line -> buf = malloc( sizeof(char)*SIZE_REALLOC);
		if( line -> buf) {
			*line -> buf = '\0';
			line -> len = 0;
			line -> size = SIZE_REALLOC;
			line -> next = line ->prev = NULL;
			return line;
		}
	}
	free( line);
	return NULL;
}

/* Addline : ajoute une ligne dans le buffer */

void line_add( EDIT *edit, EDLINE *line, int mode) {
	EDLINE *tmp;

	edit -> maxline ++;
	if( edit->top == NULL)
		edit->top = edit->bot = edit->cur.line = line;
	else
	switch( mode) {
	case ED_TOP:
		tmp = edit -> top;
		edit -> top = line;
		line -> next = tmp;
		tmp -> prev = line;
		break;
	case ED_BOT:
		tmp = edit -> bot;
		edit -> bot = line;
		line -> prev = tmp;
		tmp -> next = line;
		break;	
	/* Insertion … la position du curseur */
	case ED_CUR:
		tmp = edit -> cur.line;
		/* la ligne ajout‚e devient la ligne courante */
		edit -> cur.line = line;
		/* lien avec la ligne suivante (si elle existe ) */
		line -> next = tmp->next;
		if( tmp -> next) tmp -> next -> prev = line;
		/* lien avec la ligne pr‚c‚dente */
		line -> prev = tmp;
		tmp -> next = line;
		break;
	}
}

/* RemLine : retire la ligne courante */

void line_rem( EDIT *edit) {
	EDLINE *line = edit -> cur.line;

	if( edit -> top == NULL) return;
	edit -> maxline --;
	if( line -> prev) {
		/* connecter les lignes pr‚c‚dente et suivante */
		if( line -> prev)
			line -> prev -> next = line -> next;
		else
			edit -> top = line -> next;
		if( line -> next) 
			line -> next -> prev = line -> prev;
		else
			edit -> bot = line -> prev;

		/* nouvelle ligne courante */
		if( line->next)
			edit -> cur.line = line->next;
		else {
			edit -> cur.line = line->prev?line->prev:NULL;
			if( line->prev) edit -> cur.index --;
		}
		edit -> cur.row = 0;
	} else {
		/* Connecter … la ligne suiante */
		edit -> top = edit->cur.line = line->next;
		if( edit->cur.line)
			edit->cur.line->prev = NULL;
		edit -> cur.row = 0;
	}
	
	free( line -> buf);
	free( line);
}


/*
 * D‚clare un nouveau texte
 */

EDIT* edit_new( void) {
	EDIT *edit = (EDIT *)malloc(sizeof(EDIT));

	if( edit == NULL) return NULL;
	edit -> top = edit -> bot = edit -> cur.line = NULL;
	edit -> cur.row = 0;
	edit -> cur.index = 1;
	edit -> maxline = 0L;
	edit -> maxcur = 0;
	edit -> type = T_DOS;
	* edit -> name = '\0';
	return edit;
}

#define WE_NORMAL		'@'
#define WE_ESCAPE		''
#define WE_COLOR		'#'
#define WE_FONT			'%'
#define WE_SIZE			'('
#define WE_SETNAMEFONT	'&'
#define WE_ENDOFSTRING  '.'
#define WE_BGCOLOR		'$'	/* Nouveau sens ! */
#define WE_TABSIZE		'!'

char escape[] = "@ABDHP`!$#%(&.";

char *my_fgets( FILE *fp, int *type, int *esc) {
	int car, end = 0, bloc = 1;
	char *r, *buf;
	size_t size;
	
	size = MAXBUF;
	r = buf = (char *)malloc( sizeof(char) * MAXBUF);
	if( r == NULL) return NULL;
	*type = -1;
	*esc = 0;
	do {

		if( size == 0) buf = realloc( buf, MAXBUF*++bloc );
		car = fgetc( fp);
		size --;
		
		if( (car>0 && car < 9) || (car > 13 && car < 27))
			*type = T_BIN;
		else
		switch( car) {
		case WE_ESCAPE:
			car = fgetc( fp);
			ungetc( car, fp);
			if( strchr( escape, car))
				*esc = 1;
			* r ++ = WE_ESCAPE;
			break;
		case EOF:	/* cas a ‚tudier */
			end = 1;
			*r = ENDLINE;
			*type = -2;
			break;
		case '\r':
			*r= ENDLINE;
			car = fgetc(fp);
			if( car != '\n') {
				*type = T_MAC;
				ungetc( car, fp);
			} else *type = T_DOS;
			end = 1;
			break;
		case '\0':
			if( !feof( fp)) {
				*r = ENDLINE;
				*type = T_NULL;
			}
			end = 1;
			break;
		case '\n':
			*r= ENDLINE;
			*type = T_UNIX;
			end = 1;
			break;
		default:
			*r++ = car;
			break;
		}
	} while( !end);
	*r ='\0';

	return buf;
}

/* Cette fonction devra ˆtre capable
 * de charger diff‚rents formats (de les
 * identifier : edit->type) et converti
 * dans un format unique : le null-byte
 */
 
int edit_load( EDIT *edit, char *file, void (*update)(EDIT*, int)) {
	FILE *fp = fopen( file, "rb");
	char *buf;
	EDLINE *line;
	int type, esc;
	int nline;

	if( !fp) return -33;
	strcpy( edit->name, file);
	edit -> type = -1;
	nline = 1;
	while( !feof(fp)) {
		buf = my_fgets( fp, &type, &esc);
		if( update) (*update)( edit, nline++);
		if( buf == NULL) break;
		if( type >= 0)	edit -> type = type;
		line = line_new( buf);
		free( buf);
		line_add( edit, line, ED_BOT);
	}
	fclose( fp);
	edit -> cur.line = edit->top;
	return 0;
}

int edit_save( EDIT *edit, char *file, int type, char *end, void (*update)( EDIT*, int)) {
	FILE *fp;
	EDLINE *scan;
	char eol[10];
	int l;
	int nline;

	fp = fopen( file?file:edit->name, "wb");
	if( !fp) return -33;
	if( type == T_AUTO) type = edit->type;
	switch( type) {
	case T_DOS:
		strcpy( eol, "\r\n");
		break;
	case T_MAC:
		strcpy( eol, "\r");
		break;
	case T_UNIX:
		strcpy( eol, "\n");
		break;
	case T_NULL:
		strcpy( eol, "");
		break;
	case T_USER:
		strcpy( eol, end);
		break;
	}
	l = (int) strlen(eol);
	if( type == T_NULL) l++;
	nline = 1;
	for( scan = edit -> top; scan; scan = scan -> next) {
		if( scan->next == NULL && *scan->buf == '\0')
			break;
		fwrite( scan->buf, scan->len, sizeof(char), fp);
		fwrite( eol, l, sizeof(char), fp);
		if( update) (*update)(edit, nline++);
	}
	fclose( fp);
	return 0;
}

void edit_free( EDIT *edit) {
	EDLINE *scan =  edit -> top;
	EDLINE *next;
	
	while( scan) {
		next = scan -> next;
		free( scan->buf);
		free( scan);
		scan = next;
	}
}

int diff_line( EDLINE *up, EDLINE *dn) {
	EDLINE *scan;
	int diff;
	for( diff = 0, scan = up; scan!=dn && scan!=NULL; diff ++, scan = scan->next);
	if( scan == NULL)
		for( diff = 0, scan = up; scan!=dn && scan!=NULL; diff --, scan = scan->prev);

	return diff;
}
