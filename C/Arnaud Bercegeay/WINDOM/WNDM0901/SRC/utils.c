/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2001
 *
 *	module: utils.c
 *	description: librairie utilitaires
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>	
#include "globals.h"
#include "cookie.h"


/**********************************
 *	GESTION DES RECTANGLE AES
 **********************************/

/* Initialise un rectangle */

void rc_set( GRECT *rect, int x, int y, int w, int h) {
	rect->g_x = x;
	rect->g_y = y;
	rect->g_w = w;
	rect->g_h = h;
}

/* etablit un rectangle de masquage */

void rc_clip_on( int handle, GRECT *r) {
	INT16 xy[4];

	xy[0] = MAX( app.x, r->g_x);
	xy[1] = MAX( app.y, r->g_y);
	xy[2] = MIN( app.x+app.w-1, r->g_x+r->g_w-1);
	xy[3] = MIN( app.y+app.h-1, r->g_y+r->g_h-1);
	rc_set( &clip, xy[0], xy[1], xy[2]-xy[0]+1, xy[3]-xy[1]+1);
	vs_clip( handle, 1, xy);
}

/* annule le masquage */

void rc_clip_off( int handle) {
	INT16 xy[4];
/*	clip.g_w = clip.g_h = 0; */
	vs_clip( handle, 0, xy);
}

/*
 * Gestion de la Palette 
 */
	
void w_getpal( W_COLOR *palette) {
	int index;

	for ( index = 0; index < app.color; index ++)
		vq_color( app.aeshdl, index, 0, palette[ index]);
}

void w_setpal( W_COLOR *palette) {
	int index;

	if( palette == NULL)		/* On prend la palette du bureau */
		palette = app.palette;
	for ( index = 0; index < app.color; index++)
		vs_color( app.aeshdl, index, palette[index]);
}

/*
 *		Sauvegarde portion d'‚cran
 */

void w_get_bkgr(int of_x, int of_y, int of_w, int of_h, MFDB *img) {
	INT16 pxy[8], work[57];
	unsigned long taille;
	MFDB ecr = {0};		/* Ecran logique */

	vq_extnd( app.handle, 1, work);
		
	/* Taille tampon de copie fond */
	/* work[4] = nombre de plans */

	taille = ((((unsigned long)(of_w / 16) + ((of_w % 16) != 0)) * 2 * (long)work[ 4]) * (unsigned long)of_h) + 256; 
#ifdef __SOZOBONX__
	img->fd_addr = lalloc( taille);			/* R‚server tampon */
#else
	img->fd_addr = malloc( taille);			/* R‚server tampon */
#endif
	img->fd_w = of_w;		/* Remplir la structure MFDB */
	img->fd_h = of_h;
	img->fd_wdwidth = (of_w / 16) + ((of_w % 16) != 0);
	img->fd_stand = 1;
	img->fd_nplanes = work[ 4];

	pxy[0] = of_x;		/* Remplir le tableau */
	pxy[1] = of_y;
	pxy[2] = pxy[0] + of_w - 1;
	pxy[3] = pxy[1] + of_h - 1;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = of_w - 1;
	pxy[7] = of_h - 1;
	v_hide_c ( app.handle);				/* Virer la souris */
	vro_cpyfm ( app.handle, S_ONLY, pxy, &ecr, img);	/* Copier l'image */
	v_show_c ( app.handle, 1);		/* Remettre la souris */
}

/* Restaure un fond d'‚cran */

void w_put_bkgr(int of_x, int of_y, int of_w, int of_h, MFDB *img) {
	INT16 pxy[8];
	MFDB ecr = {0};	/* Ecran logique */

	pxy[0] = 0;		/* Remplir le tableau */
	pxy[1] = 0;
	pxy[2] = of_w - 1;
	pxy[3] = of_h - 1;
	pxy[4] = of_x;
	pxy[5] = of_y;
	pxy[6] = of_x + of_w - 1;
	pxy[7] = of_y + of_h - 1;
	v_hide_c ( app.handle);			/* Remettre la souris */
	vro_cpyfm ( app.handle, S_ONLY, pxy, img, &ecr);	/* Copier l'image */
	v_show_c ( app.handle, 1);	/* Virer la souris */
	free ( img->fd_addr);		/* Lib‚rer la m‚moire */
}

/*
 * R‚cupŠre le vrai code ascii d'un ‚vement clavier
 * scancode = valeur associ‚e … l'‚v‚nement MUKEYBD, 
 *			  champ evnt.keybd ou retour de la fonction 
 *			  evnt_keybd()
 * shift = 1 : shift actif, 0 shift non actif.
 * retour: code ascii de la touche ou 0 si la touche n'a pas
 * 		   de valeur ascii (on utilise alors le scancode).
 */

typedef struct {
        char *unshift;
        char *shift;
        char *capslock;
} MY_KEYTAB;

int keybd2ascii( int keybd, int shift) {
	MY_KEYTAB *key;
	key = (MY_KEYTAB *)Keytbl( (char*)-1, (char*)-1, (char*)-1);
	return (shift)?key->shift[keybd>>8]:key->unshift[keybd>>8];
}

/*
 *	Malloc pour GEM (mode partageable)
 */

#define MGLOBAL	0x20

void *Galloc( long size) {
	long val;
	
	if( Sversion() >= 0x1900 ||
		get_cookie (MAGX_COOKIE, &val) ||
    	get_cookie (MiNT_COOKIE, &val))
		return (void *)Mxalloc( size, 0 | MGLOBAL);
	else
    	return (void *)Malloc( size);
}

/*
 * en attendant un ‚tude plus pouss‚e des r‚pertoires
 * … la unix, cette fonction convertie les chemins
 * TOS en unix et vis et versa.
 */

char *conv_path( char *p) {
	char *q = p;
	
	if( p[1] == ':') {
		p[1] = p[0];
		p[0] = '\\';
	} else if( p[0] == '/') {
		p[0] = p[1];
		p[1] = ':';
	}

	while( *p) {
		if( *p == '\\') *p= '/';
		else if( *p == '/') *p = '\\';
		p ++;
	}
	return q;
}

/* Required by GemLib but does not defined
 * in the standard libraries of Pure C */
#if defined(__PUREC__) && defined(__GEMLIB__)
void bzero( void *adr, long size) {
	memset( adr, 0, size);
}
#endif


/* Copie d'une chaine dans le presse papier GEM */

int scrap_txt_write( char *str) {
	char scrpdir[255];
	FILE *fp;
	
	if( !scrp_read( scrpdir))
		return 0;
	strcat( scrpdir, "\\SCRAP.TXT");
	fp = fopen( scrpdir, "w");
	if( !fp) return  0;
	fwrite( str, sizeof(char), strlen(str)+1, fp);
	fclose( fp);
	return 1;
}

char *scrap_txt_read( void) {
	char scrpdir[255], *buf;
	FILE *fp;
	size_t size;
	
	if( !scrp_read( scrpdir))
		return NULL;
	strcat( scrpdir, "\\SCRAP.TXT");
	fp = fopen( scrpdir, "r");
	if( !fp) return  NULL;
	fseek( fp, 0, 2);
	size = ftell( fp);
	fseek( fp, 0, 0);
	buf = malloc( size+1);
	fread( buf, sizeof(char), size, fp);
	fclose( fp);
	return buf;
}

/* EOF */
