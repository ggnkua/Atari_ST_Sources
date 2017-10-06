/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: font.c
 *	description: librairie fontes
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "globals.h"
#include "cookie.h"

/*
 *	Appel custom des fonctions vqt_extname, vqt_xfntinfo,
 *	vqt_fontheader.
 *	name: nom de la fonte (pas forc‚ment sur 31 octets)
 *	flags: FNT_OUTLINE, fonte vectorielle (ou bitmap sinon)
 *		   FNT_MONO,	fonte non proportionnelle (ou proportionnelle sinon)
 *		   FNT_SPEEDO,  fonte vectorielle de type speedo
 *		   FNT_TRUETYPE,fonte vectorielle de type true type
 *		   FNT_TYPE1,	fonte vectorielle de type postscript type 1
 *	index: index fonte
 *	retour: id de la fonte
 */

int vqt_xname( int handle, int id, int index, char *name, int *flags) {
	int speedo;
	INT16 nvdi_fmt, nvdi_flg;
	long vers;
	int get_cookie( long, long*);

	if( index == 0) {
		for( index = 0; index < app.gdos; index++) {
			if( id == vqt_name( handle, index, name))
				break;
		}
		if( index == app.gdos) return -1;	/* erreur, id non trouv‚e */
	} 
	
	id = vqt_extname( handle, index, name, &speedo, &nvdi_fmt, &nvdi_flg);

	*flags = 0;
	/* fonte vectorielle ? */
	if( speedo == 1 /*SP_OUTLINE*/) 
		*flags |= FNT_OUTLINE;
	/* fonte monospaced ? */
	if( nvdi_flg == 1 /*NVDI_MONO*/)
		*flags |= FNT_MONO;
	if( nvdi_fmt & 0x2 /*NVDI_SPEEDO*/)
		*flags |= FNT_SPEEDO;
	if( nvdi_fmt & 0x4 /*NVDI_TRUETYPE*/)
		*flags |= FNT_TRUETYPE;
	if( nvdi_fmt & 0x8 /*NVDI_TYPE1*/)
		*flags |= FNT_TYPE1;

	if( vq_nvdi() >= 0x0302) {
		XFNT_INFO xfnt;

		/* Le nom long sous Nvdi */
		if( speedo == 0)	return id;
		vqt_xfntinfo( handle, 0x1 /*XFNT_NAME*/, id, 0, &xfnt);
		strcpy( name, xfnt.font_name);
	} else 
#define _FSM 0x5F46534DUL
#define FSMC 0x46534D43UL
#define _SPD 0x5F535044UL
	if( vq_vgdos() == _FSM	 	 &&	/* Il faut speedo */
		get_cookie( FSMC, &vers) && /*				  */
		*(long*)vers == _SPD 	 && /*				  */
		speedo == 1 /*SP_OUTLINE*/ ) {		/* et une fonte vectorielle */
		char buf [421];
		char path[128];
	
		vst_font( handle, id);
		*(buf+24) = '\0';
		vqt_fontheader( handle, buf, path);
		/* le nom long sous Speedo */
		strcpy( name, buf+24);
		/* fonte monospaced ? */
		if( *(buf+263) & 0x2)
			*flags |= FNT_MONO;
		*flags |= FNT_SPEEDO;
	} else {
		/* vqt_fontheader() ne fonctionne pas avec
		 * les fontes bitmap Gdos */
		INT16 cellw1, cellw2, dum;
		#define l_ASCII	0x6C
		#define W_ASCII	0x57

		vqt_width( handle, l_ASCII, &cellw1, &dum, &dum);
		vqt_width( handle, W_ASCII, &cellw2, &dum, &dum);
		if( cellw1 == cellw2) *flags |= FNT_MONO;
	}
	return id;
}

/*
 *	Emulation des fonts Gdos
 */

static struct fontid {
	char name[44];
	int  id;
	int flags;		/* monospaced, vectoriel, etc ... */
} *listfontid;

static int maxfontid = 0;		/* non charg‚e */

static
int load_fontid( void) {
	FILE *fconf( char *path, char *name);
	FILE *fp;
	char *p, *q;
	int i;
	char path[255];

	fp = fopen( "fontid", "r");
	if( !fp) {
		shel_envrn( &p, "ETCDIR=");
		if( p) {
			strcpy( path, p);
			strcat( path, "\\fontid");
			fp = fopen( path, "r");
		}
	}
	if( !fp) {
		shel_envrn( &p, "HOME=");
		if( p) {
			strcpy( path, p);
			strcat( path, "Defaults\\fontid");
			fp = fopen( path, "r");
		}
	}
	if( !fp) {
		shel_envrn( &p, "FONTDIR=");
		if( p) {
			strcpy( path, p);
			strcat( path, "\\fontid");
			fp = fopen( path, "r");
		}
	}
	if( !fp)
		fp = fopen( "C:\\gemsys\\fontid", "r");

	if( fp) {
		char buf[LINE_SIZE];
		int count = 0;
		
		/* Compte des entr‚es */
		while( fgets( buf, LINE_SIZE, fp)) {
			if( *buf == '#' ||
				*buf == '\n')
				continue;
			count ++;
		}
		rewind( fp);
		maxfontid = count;
		listfontid = (struct fontid *)malloc( sizeof(struct fontid)*count);
		if( !listfontid) {
			fclose( fp);
			return -69;	/* memory error */
		}

		/* Puis lecture */
		while( fgets( buf, LINE_SIZE, fp)) {
			if( *buf == '#' ||
				*buf == '\n')
				continue;

			/* format ligne : num "Name" id flags */

			sscanf( buf, "%d", &i);
			p = strchr( buf, '"');
			if( p && i < maxfontid) {
				q = strchr( p+1, '"');
				if( q) {
					*q = '\0';
					strcpy( listfontid[i].name, p+1);
					sscanf( q+1, "%d %x", &listfontid[i].id, &listfontid[i].flags);
				}
			}
				/* ELSE : Erreur de format */
		}
		
		return maxfontid - 1;
	} else {
		/* La fonte systŠme est toujours dispo */
		listfontid = (struct fontid *)malloc( sizeof(struct fontid));
		if( !listfontid) {
			maxfontid = 2;
			strcpy( listfontid[0].name, "system font");
			listfontid[0].id = 1;
			listfontid[0].flags = FNT_MONO;
		}
		
		return -33;	/* file not found */
	}
}

static
void close_fontid( void) {
	if( maxfontid)
		free( listfontid);
}

/*
 *	Emule vst_load_fonts() lorsque Gdos non pr‚sent
 */

int VstLoadFonts( int vh, int res) {
	return vq_gdos()?vst_load_fonts( vh, res) : load_fontid();
} 

/*
 *	Emule vst_unload_fonts() lorsque Gdos non pr‚sent
 */

void VstUnloadFonts( int vh, int res) {
	vq_gdos()?vst_unload_fonts( vh, res) : close_fontid();
}

/*
 *	Emule vst_font()
 */

int VstFont( int vh, int id) {
	int res = 0;
	if( vq_gdos())
		res = vst_font( vh, id);
	return res;
}

/* Emule vqt_name lorsque Gdos non pr‚sent
 * mais /etc/fontid pr‚sent 
 */

int VqtName( int vh, int elem, char *name) {
	if( vq_gdos())
		return vqt_name( vh, elem, name);
	else {
		if( elem < maxfontid) {
			strcpy( name, listfontid[elem].name);
			return listfontid[elem].id;
		}
	}
	strcpy( name, "system font");
	return 1;
}

/*
 * Emule vqt_xname()
 */

int VqtXname( int vh, int id, int index, char *name, int *fl) {
	if( vq_gdos())
		return vqt_xname( vh, id, index, name, fl);
	else {
		/* recherche par id */
		if( index == 0) {
			while( listfontid[index].id != id && index < maxfontid)
				index ++;
		}
		if( index < maxfontid) {
			strcpy( name, listfontid[index].name);
			*fl = listfontid[index].flags;
			return index?listfontid[index].id:index;
		} else
			return -1;
	}
}


/* Retourne l'id d'un nom de fonte ou -1 si la fonte
   n'existe pas */

int FontName2Id( char *name) {
	int id, i;
	char buf[60];
	
	for( i=0; i<app.gdos; i++) {
		id = VqtName(app.handle,i,buf);
		if( !strcmp(buf, name))
			return id;
	}
	return -1;
}

/* L'inverse */

int FontId2Name( int id, char *name) {
	int  i, scan;
	
	for( i=0; i<app.gdos; i++) {
		scan = VqtName(app.handle,i,name);
		if( id == scan)
			return 0; /* OK, name contient le nom de la fonte */
	}
	return -1;	/* Pas trouv‚ */
}

