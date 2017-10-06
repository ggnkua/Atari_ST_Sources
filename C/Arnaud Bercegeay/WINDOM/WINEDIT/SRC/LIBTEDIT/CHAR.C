/*
 *	Routines d'‚dition de texte
 *  D.B‚r‚ziat 1998
 *	Insertion/Suppressions de caractŠres
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "libtedit.h"

EDLINE *line_new( char *buf);
void line_add( EDIT *edit, EDLINE *line, int mode);
void line_rem( EDIT *edit);

/* d‚calage vers la droite du buffer */

void shift_right( char *buf) {
	int l = (int)strlen(buf);
	
	buf += l;
	*(buf+1) = '\0';
	while( l) {
		*buf = *(buf-1);
		buf --;
		l --;
	}
}

/* d‚calage vers la gauche du buffer */

void shift_left( char *buf) {
	do {
		*buf = *(buf+1);
	} while (*buf++);
}

/* Insertion … la position courante 
 * et incr‚mentation de la position */

void char_put( EDIT *edit, int c) {
	EDLINE *line;
	int pos;
	
	if( edit -> top == NULL) {
		edit -> top = line_new( NULL);
		edit -> bot = edit -> cur.line = edit -> top;
	}
	
	pos = edit->cur.row;
	
	if( c == NEWLINE) {
		line = line_new( edit->cur.line->buf+pos);
		edit->cur.line->buf[pos] = ENDLINE;
		edit->cur.line->len = (int)strlen( edit->cur.line->buf);
		line_add( edit, line, ED_CUR);
		edit->cur.row = 0;
		edit->cur.line = line;
		edit->cur.index ++;
	} else {
		line = edit->cur.line;
		if( ++line->len >= line->size) {
		# ifdef DEBUG
			form_alert( 1, "[1][trace: realloc!][OK]");
		# endif
			line->size += SIZE_REALLOC;
			line->buf = (char*)realloc(line->buf,line->size);
		}
		shift_right( line->buf + pos);
		line->buf[pos] = c;
		edit->cur.row ++;
	}
}

/* int char_get(void); */

/*
 * Efface le caractŠre derriŠre le curseur 
 * retourne 1 si OK 0 si on a effacer une ligne
 */

int char_del( EDIT *edit) {
	if( edit -> top == NULL) return 0;
	if( edit -> cur.row) {
		edit -> cur.row --;
		edit -> cur.line -> len --;
		shift_left( edit -> cur.line->buf + edit -> cur.row);
	} else {
		EDLINE *line = edit -> cur.line;
		int pos, index;
		
		if( line -> prev) {
			/* Concat‚ner la ligne pr‚c‚dente avec la ligne courante */
			pos = line -> prev -> len;
			/* Adapter la taille */
			if( line -> prev -> size < line -> prev -> len + line -> len) {
				line -> prev -> size = line -> prev -> len + line -> len + 1;
				line -> prev -> buf = (char *) realloc( line -> prev -> buf, line -> size);
			}
			strcat( line -> prev -> buf, line -> buf);
			line -> prev -> len = (int) strlen( line -> prev -> buf);
			/* Effacer la ligne courante */
			line = line -> prev;
			index = edit -> cur.index;
			line_rem( edit);
			/* Pointer la ligne pr‚c‚dente … la bonne position */
			edit -> cur.row = pos;
			edit -> cur.line = line;
			edit -> cur.index = index-1;
			return 0;
		}
	}
	return 1;
}

/* Mouvement du curseur */

int curs_left( EDIT *edit) {
	if( edit->cur.row ) {
		edit->cur.row --;
		edit->maxcur --;
	} else if( edit->cur.line->prev) {
		edit->cur.index --;
		edit->cur.line = edit->cur.line->prev;
		edit->maxcur = edit->cur.row = edit->cur.line->len;
	} else
		return 0;
	return 1;
}

int curs_right( EDIT *edit) {
	int c = edit->cur.line->buf[edit->cur.row];
	
	if( c == '\0') {
		if( edit->cur.line->next) {
			edit->cur.index ++;
			edit->cur.line = edit->cur.line->next;
			edit->cur.row = 0;
			edit->maxcur = 0;
		} else 
			return 0; /* fin du buffer */
	} else {
		edit->cur.row ++;
		edit->maxcur ++;
	}
	return 1;
}

#define min(a,b) (((a)<(b))?(a):(b))
#define max(a,b) (((a)>(b))?(a):(b))

int curs_up( EDIT *edit) {
	if( edit -> cur.line -> prev) {
		edit -> cur.index --;
		edit -> cur.line = edit -> cur.line -> prev;
		edit -> cur.row = max( edit -> cur.row, edit -> maxcur);
		edit -> cur.row = min( edit -> cur.row, edit -> cur.line -> len);
		return 1;
	}
	return 0;
}

int curs_down( EDIT *edit) {
	if( edit -> cur.line -> next) {
		edit -> cur.index ++;
		edit -> cur.line = edit -> cur.line -> next;
		edit -> cur.row = max( edit -> cur.row, edit -> maxcur);
		edit -> cur.row = min( edit -> cur.row, edit -> cur.line -> len);
		return 1;
	}
	return 0;
}

/* Insertion d'une chaine dans une ligne */

void string_put( EDIT *edit, char *str) {
	for( ;*str;str++) {
		char_put( edit, *str);
	}
}
