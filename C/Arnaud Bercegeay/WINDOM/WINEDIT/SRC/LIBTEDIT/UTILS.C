/*
 *	Routines d'‚dition de texte
 *  D.B‚r‚ziat 1998
 *	Fonctions utiles a tout ‚diteur
 */

#include <stdio.h>
#include <string.h>
#include "libtedit.h"

/*
 * Conversion tabulation -> espace 
 */

char* tab2spc( int tab, char *dest, char *src, int max) {
	int fill, pos = 0;
	char *beg = dest;

	max--;
	while( *src != '\0' && 
		   *src != '\n' &&
		   *src != '\r' && max) {

		if( *src == '\t') {
			
			fill = tab - (pos % tab);
			while( fill -- && max) {
				* dest++ = ' ';
				max --;
			}
			pos += tab - (pos % tab);
			src ++;
		} else {
			*dest++ = *src++;
			max--;
			pos++;
		}
	}
	*dest = '\0';
	return beg;
}

/*
 * Calcul de la taille d'un buffer 
 */

size_t edit_size( EDIT *edit) {
	size_t size = 0;
	EDLINE *scan;
	for( scan=edit->top; scan; scan=scan->next)
		size += scan->size;
	return size;
}

/*
 * Insertion dans un buffer (position du curseur).
 */

void edit_insert_buffer( EDIT *to, CURSOR *s, CURSOR *e) {
	EDLINE *line;
	char c;
	
	if( s->index == e->index)  {
		c = s->line->buf[e->row+1];
		s->line->buf[e->row+1] = '\0';
		line = line_new( s->line->buf + s->row);
		s->line->buf[e->row+1] = c;
		line_add( to, line, ED_CUR);
	} else {				
		/* insertion ligne s */
		line = s->line;
		line = line_new( s->line->buf + s->row);
		line_add( to, line, ED_CUR);
		/* lignes interm‚daires */
		do {
			line_add( to, line_new( line -> buf), ED_CUR);
			line = line -> next;
		} while( line != e->line);
		
		/* insertion ligne e */
		c = s->line->buf[e->row+1];
		s->line->buf[e->row+1] = '\0';
		line = line_new( s->line->buf);
		s->line->buf[e->row+1] = c;
		line_add( to, line, ED_CUR);
	}
}

/* Insertion dans un buffer */

void edit_fuzz_buffer( EDIT *to, EDIT *from) {
	CURSOR s, e;

	s . line = from -> top;
	s . row  = 0;
	e . line = from -> bot;
	e . row  = from -> top -> len;
	edit_insert( to, &s, &e);
}

int edit_copy_file( CURSOR *s, CURSOR *e, char *endline, char *file) {
	FILE *fp = fopen( file, "w");
	
	if( fp) {
		EDLINE *line;
		
		/* mˆme ligne */
		if( s->index == e->index) {
			fwrite( s->line->buf + s->row, sizeof(char), 
					e->row - s->row + 1, fp);
			fwrite( endline, sizeof(char), strlen(endline), fp);
		} else {
			/* ecriture ligne s */
			fwrite( s->line->buf + s->row, sizeof(char), 
					s->line->len - s->row + 1, fp);
			fwrite( endline, sizeof(char), strlen(endline), fp);
			/* ecriture lignes interm‚diaires */
			for( line = s->line->next; line != e->line; line = line -> next) {
				fwrite( line->buf, sizeof(char), strlen( line->buf), fp);
				fwrite( endline, sizeof(char), strlen(endline), fp);	
			}
			/* ecriture ligne e */
			fwrite( s->line->buf + s->row, sizeof(char), 
					s->line->len - s->row + 1, fp);
			fwrite( endline, sizeof(char), strlen(endline), fp);
			line = s->line; 
		}
		fclose( fp);
		return 0;
	} else
		return -33;
}


