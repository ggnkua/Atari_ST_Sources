/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: rsrc.c
 *	description: fonctions ressources basiques
 */

#include <stdlib.h>
#include <string.h>
#include "globals.h"
#include "userdef.h"

/*
 *	RsrcLoad() en plus de l'appel de rsrc_load() initialise la
 *	variable app.ntree pour la fonction RsrcXtype()
 *	Dans une version future, on chargera nous-meme le fichier
 *	ressource. -> Une fonction RsrcXload() ?
 *  sous naes, les chemin TOS ne sont pas reconnus
 *  par rsrc_load(). La foncton conv_path() entre action
 */

int RsrcLoad( const char *name) {
	int res;
	RSHDR RSCheader;
	int fd;
	char path[255];
	
	strcpy( path, name);
	res = rsrc_load( path);
	if( !res) {
		conv_path(path);
		res = rsrc_load( path);
	}
	if( !res) return 0;
	fd = (int)Fopen( path, 0 /*FO_READ*/);
	if( fd < 0 && shel_find( path))
		fd = (int)Fopen( path, 0 /*FO_READ*/);	
	if( fd < 0) {
		rsrc_free();
		return 0;
	}
	Fread( fd, sizeof( RSHDR), &RSCheader);
	app.ntree = (signed int)RSCheader .  rsh_ntree;
	Fclose( fd);
	return 1 ;
}

void RsrcUserFree( OBJECT *tree) {
	int index = 0;
	do {
		if( (tree[index].ob_type >> 8) == USERDRAW ) {
			free( (void*)tree[index].ob_spec.userblk->ub_parm);
			free( tree[index].ob_spec.userblk);
			tree[index].ob_type = G_IBOX;
			tree[index].ob_spec.index = 0L;
		}
	} while( !(tree[index++].ob_flags & LASTOB));
}

/********** EOF **************/
