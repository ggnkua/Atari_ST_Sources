/*
 *	Pr‚pare un fichier BUB … partir
 *	des index du fichier header
 *
 * (c) 2001 - Dominique B‚r‚ziat
 *
 *	entr‚e: file.idx  fichier d'aide index‚ avec les
 *					  nom de macro
 *			file.h	  fichier header g‚n‚r‚ par l'‚diteur
 *					  de ressource
 *	sortie: file.bub  le fichier bubble
 *
 * version 1.1 : on peut sp‚cifier des noms differents pour chaque fichier
 *               diagnostique plus pr‚cis des alertes
 * version 1.0 : premiŠre version distribu‚ dans WinDom
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXNAME	30
#define FILENAME	128
#define MAXBUF	255

struct index {
		char name[MAXNAME];
		int index;
		int tree;	/* index dans struct index */
	} ;

/* Retourne le nom d'un fichier sans le chemin
 */

char *getfilename( char *file) {
	char *p = strrchr( file, '\\');
	return p?p+1:file;
}


/*
 *	Coupe une chaine lorsqu'on rencontre le caractŠre 'c'
 */

char *cut( char *s, char c) {
	s = strchr( s, c);
	if( s) *s++ = '\0';
	return s;
}

/*
 *	retourne la premiŠre position diff‚rente de 'c' dans
 *	la chaŒne
 */

char *skip( char *s, char c) {
	while( *s == c)
		s++;
	return s; 
}

/* Cr‚er le tableau des index */

struct index *read_header( char *headfile, int *count) {
	FILE *fp;
	char buf[MAXBUF];
	int i;
	int root=0;
	struct index *Index;

	fp = fopen( headfile, "r");

	if( fp == NULL) return NULL;
	
	/* Compter les ‚l‚ments */	
	for( *count = 0; !feof(fp); fgets( buf, MAXBUF, fp))
		if( strstr( buf, "#define") == buf)
			(*count) ++;
	
	rewind( fp);
	Index = (struct index *) malloc( sizeof(struct index)**count);
	i = 0;

	/* Remplir les index */
	while( !feof( fp)) {
		fgets( buf, MAXBUF, fp);
		if( *buf == '\n') {
			/* Le prochain ‚l‚ment est une racine  */
			if( !feof( fp))
				root = -1;
		} else if( strstr( buf, "#define") == buf) {
			sscanf( buf, "#define %s %d", Index[i].name, &Index[i].index);
			if( root == -1)
				root = Index[i].index;
			Index[i].tree = root;
			i ++;
		}
		if( i >= *count) break;
	}
	fclose( fp);
	return Index;
}
	
int convert( char *idxfile, char *bubfile, 
			  struct index *Index, int count) {
	FILE *in, *out;
	char buf[MAXBUF], *p;
	int i; 
	int line = 1;

	/* Maintenant on lit le fichier template 
	 * et on cr‚‚ le fichier bubble 
	 */

	in = fopen( idxfile, "r");
	out = fopen( bubfile, "w");
	if( !in || !out) return 0;
	
	while( !feof( in)) {
		fgets( buf, MAXBUF, in);
		if( *buf == '\n' || *buf == '#') {
			line ++; continue;
		}
		p = cut( buf, ' ');
		if( !p) continue;
		p = skip( p, ' ');
		if( !p) continue;
	
		/* Chercher l'index qui correspond au mot-clef */
		for( i=0; i<count; i++) {
			if( !strcmp( Index[i].name, buf)) {
				if( *p == '@') {	/* Cas d'un alias */
					char name[MAXNAME];
					int j;
					
					sscanf( p, "@ %s", name);
					for( j=0; j<count; j++)
						if( !strcmp( Index[j].name, name))
							fprintf( out, "%d %d @ %d %d\n", Index[i].tree, Index[i].index, 
														   Index[j].tree, Index[j].index);
				} else
					fprintf( out, "%d %d %s", Index[i].tree, Index[i].index, p);
				break;
			}
		}
		if( i == count)
			fprintf( stderr, "\nWarning:%s:%d keyword %s does not exist", 
						getfilename(idxfile), line, buf);
		line ++;
	}
	fclose( in);
	fclose( out);
	return 1;
}

int main( int argc, char *argv[]) {
	int go = 0;
	char idx[128], bub[128], head[128];
	
	if( argc == 2) {
		char *p;

		strcpy( idx, argv[1]);
		p = strrchr( argv[1], '.');
		if( p) *p = '\0';
		strcpy( bub, argv[1]);
		strcat( bub, ".bub");
		strcpy( head, argv[1]);
		strcat( head, ".h");
		go = 1;
	} else if( argc == 4) {
		strcpy( idx,  argv[1]);
		strcpy( head, argv[2]);
		strcpy( bub,  argv[3]);
		go = 1;
	} else {
		fprintf( stderr, "Create bubble file by D.B‚r‚ziat, version 1.1 \n");
		fprintf( stderr, "Usage is: idx2bub idx-file [C-header-file bub-file] \n");
		return 0;		
	}
	
	if( go) {
		struct index *Ind;
		int count; 
		
		fprintf( stderr, "Read header file %s ...", head);
		Ind = read_header( head, &count);
		if( Ind == NULL) {
			fprintf( stderr, "\nFatal: can't find header C file %s.h.\n", head);
			return 0;
		}
		fprintf( stderr, " done.\nConvert %s to %s ...", idx, bub);
		if( convert( idx, bub, Ind, count) == 0) {
			fprintf( stderr, "\nFatal: can't read %s or create %s\n", idx, bub);
		} else
			fprintf( stderr, " done.\n");
		free( Ind);
	}
		
	return 0;
}

