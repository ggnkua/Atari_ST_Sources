/*
 * macro couleurs
 *	-> un fichier de macros-couleurs
 *	-> un convertisseur texte -> texte en couleurs
 */
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <windom.h>

#include "color.rsh"
#include "color.rh"

/*
 *   C.MAC
 *
 *	 keyword <word> <attributs>
 *						0...F		index couleurs
 *						blui		bold ligth underlined italic
 *	 zone	<begin> <end> <attributs>
 *
 *	 line  <word> <attributs>      concerne la ligne
 *
 *   letter <word> <attributs>
 */

#define EXT_LENGHT	30
#define INFO_LENGHT	100

typedef struct {
		int type;
		char key1[30],key2[30];
		char color;
		char attrib;
	} MACRO_COLOR;

typedef struct _LIST_MACRO {
		MACRO_COLOR *mac;
		int max;
		char ext[EXT_LENGHT];		/* extensions correspondantes (liste) */
		char info[INFO_LENGHT];  	/* infos sur la macro */
		struct _LIST_MACRO *next;  /* pour faire un ensemble de macro */
	} LIST_MACRO;

LIST_MACRO *root_mac = NULL;

char macrospath[255]="";  /* chemin des fichiers macros */
int x,y,w,h;
int silent = 0;

/*
 *	Sous fonction de load_macro_colors
 */

void get_attributes( char *att, MACRO_COLOR *mac)
{
	mac->attrib = 0;
	mac->color = 0;
	while( *att) {
		switch( *att) {
		case 'b':
			mac->attrib |= 'A';
			break;
		case 'l':
			mac->attrib |= 'B';
			break;
		case 'u':
			mac->attrib |= 'H';
			break;
		case 'i':
			mac->attrib |= 'D';
			break;
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			mac->color = *att - '1' + '0';
			break;
		case 'A':
		case 'B':
		case 'C':
		case 'D':
		case 'E':
		case 'F':
			mac->color = '9' + *att -'A' + 1;
			break;
		}
		att ++;
	}
}

/*
 *	Charge un fichier de macros, et la met dans la liste des macros
 *	la liste est cr‚er si besoin est.
 */


LIST_MACRO *load_macro_colors( char *filename, LIST_MACRO **root)
{
	FILE *fp=fopen( filename, "r");
	int count=0;
	char buf[120],word[50], att[10];
	char pinfo[INFO_LENGHT];
	char ext[EXT_LENGHT];
	MACRO_COLOR *mac;
	LIST_MACRO *list;
	
	if( fp == NULL) return NULL;
	/* count macro */
	while( !feof( fp)) {
		fgets( buf, 120, fp);
		if( *buf == '#' || *buf == '\n')
			continue;
		sscanf( buf, "%s", word);
		if( !strcmp( word, "keyword") ||
			!strcmp( word, "letter") ||
			!strcmp( word, "line") ||
			!strcmp( word, "zone"))
			count ++;
	}
	if( count == 0) {
		fclose( fp);
		return NULL;
	}
	mac = (MACRO_COLOR*)malloc( sizeof(MACRO_COLOR)*count);
	if( mac == NULL) {
		fclose( fp);
		return NULL;
	}
	rewind( fp);
	count = 0;
	strcpy( pinfo, "");
	strcpy( ext, "");
	while( !feof( fp)) 
    {
		fgets( buf, 120, fp);
		if( *buf == '#' || *buf == '\n')
			continue;
		sscanf( buf, "%s", word);
		if( !strcmp( word, "keyword")) {
			if( sscanf( buf, "%s %s %s", word, mac[count].key1, att) == 3) {
				mac[count].type = 0;
				get_attributes( att, &mac[count++]);
			}
		} else if( !strcmp( word, "zone")) {
			if( sscanf( buf, "%s %s %s %s", word, mac[count].key1, mac[count].key2, att) == 4) {
				mac[count].type = 1;
				get_attributes( att, &mac[count++]);
			}
		} else if( !strcmp( word, "letter")) {
			if( sscanf( buf, "%s %s %s", word, mac[count].key1, att) == 3) {
				mac[count].type = 2;
				get_attributes( att, &mac[count++]);
			}
		} else if( !strcmp( word, "line")) {
			if( sscanf( buf, "%s %s %s", word, mac[count].key1, att) == 3) {
				mac[count].type = 3;
				get_attributes( att, &mac[count++]);
			}
		} else if( !strcmp( word, "info")) {
			strcpy ( pinfo, buf + 5);
		} else if( !strcmp( word, "ext")) {
			strcpy ( ext, buf + 4);
		}
	}
	
	fclose( fp);
	* strrchr( filename , '.') = '\0';
	if( *root == NULL) {
		*root = (LIST_MACRO*)malloc( sizeof( LIST_MACRO));
		list = *root;
	}
	else {
		list = *root;
		while( list->next) {
			list = list->next;
		}
		list->next = (LIST_MACRO*)malloc( sizeof( LIST_MACRO));
		list = list -> next;
	}
	list -> next = NULL;
	list -> max = count;
	list -> mac = mac;
	strcpy( list -> info, pinfo);
	if( *ext != '\0')
		strcpy( list -> ext, ext);
	else
		strcpy( list -> ext, filename);
	return list;
}

/*
 * libŠre la liste des macros
 */
 
void free_macro_colors( LIST_MACRO *root)
{
	LIST_MACRO *prev;
	
	while( root){
		free( root->mac);
		prev = root;
		root=root->next;
		free( prev);
	}
}

char *strkey( char *p, char *q)
{
	char *s;
	
	do {
		s = strstr( p,q);
		if( s) {
			switch( *(s+strlen(q))) {
			case '\0':
			case '\n':
			case '\t':
			case ' ':
			case '(':
			case ')':
			case '{':
			case '}':
			case '*':
			case '=':
			case '<':
			case '>':
			case ';':
			case ':':
				return s;
			default:
				p = s+strlen(q);	
			}
		}
	} while( s);
	return NULL;
}

/*
 *	Cette fonction convertit un fichier suivant les macros indiqu‚
 */

int convert( char *filename, char *newname, LIST_MACRO *root)
{
	FILE *fp = fopen( filename, "r");
	char *p,*q;
	FILE *fq;
	char buf[120], buf2[120];
	int is_zone = 0, i;
	int j = 1;
	
	fq = fopen( newname, "w");

/*	printf( "line 1"); */
	strcpy( rs_trindex[COLOR][COLOR_LINE].ob_spec.tedinfo->te_ptext, "1");
	if( !silent)
		objc_draw( rs_trindex[COLOR], COLOR_LINE, 0, x,y,w,h);
	q = fgets( buf, 120, fp);
	p = NULL;
	do {
		
		for( i=0; i<root->max && p == NULL; i++) {
			switch( root->mac[i].type) {
			case 0: /* keyword */
				if( is_zone)
					p = NULL;
				else
					p = strkey( q, root->mac[i].key1);
				break;
			case 1: /* zone */
				if( is_zone) {
					p = strstr( q, root->mac[i].key2);
					if( i == is_zone && p)
						is_zone = -1; /* on ferme la zone */
					else
						p = NULL;
				}
				else {
					p = strstr( q, root->mac[i].key1);
					if( p) is_zone = i;  /* on ouvre une zone */
				}
				break;
			case 2: /* letter */
				if( is_zone)
					p = NULL;
				else
					p = strchr( q, *root->mac[i].key1);
				break;
			case 3: /* line */
				if( is_zone)
					p = NULL;
				else {
					p = strstr( q, root->mac[i].key1);
					if( p) is_zone = i;
				}
				break;
			}
		}
		if( i == root->max) { /* ligne suivante */
			if( is_zone) {
				p = strchr( q, '\n');
				if( p) {
					*p = '\0';
					fprintf( fq, "%s", q);
					if( root->mac[is_zone].attrib)
						fprintf( fq, "%c@", 27);
					if( root->mac[is_zone].color)
						fprintf( fq, "%c#1", 27);
					fprintf( fq, "\n");
					if( root->mac[is_zone].type == 3)
						is_zone = 0;
				} else
					fprintf( fq, "%s", q);
				if( root->mac[is_zone].attrib)
					fprintf( fq, "%c%c", 27, root->mac[is_zone].attrib);
				if( root->mac[is_zone].color)
					fprintf( fq, "%c#%c", 27, root->mac[is_zone].color);
			} else
				fprintf( fq, "%s", q);
			
			q = fgets( buf, 120, fp);
			p = NULL;
			
/*			printf( "\033l line %d ", ++j); */
			sprintf( rs_trindex[COLOR][COLOR_LINE].ob_spec.tedinfo->te_ptext, "%d", ++j);
			if( !silent)
				objc_draw( rs_trindex[COLOR], COLOR_LINE, 0, x,y,w,h);
		}
		else { /* p pointe sur le mot-clef */
			i --;
			strncpy( buf2, q, p-q);
			buf2[p-q] = '\0';
			fprintf( fq, "%s", buf2);
			/* ‚crire le bourgat */
			if( is_zone>=0) {
				if( root->mac[i].attrib)
					fprintf( fq, "%c%c", 27, root->mac[i].attrib);
				if( root->mac[i].color)
					fprintf( fq, "%c#%c", 27, root->mac[i].color);
			}
			fprintf( fq, "%s", (is_zone == -1)?root->mac[i].key2:root->mac[i].key1);
			if( is_zone <= 0) {
				if( root->mac[i].attrib)
					fprintf( fq, "%c@", 27);
				if( root->mac[i].color)
					fprintf( fq, "%c#1", 27);
				if( is_zone < 0 )
					is_zone = 0;
			}
			q = p + strlen( root->mac[i].key1); /* on repart */
			p = NULL;
		}
	} while (!feof( fp));
	fclose( fq);
	fclose( fp);
	return 0;
}

/* Retourne ou Charge le bon fichier macro en fonction
 * de l'extension du fichier. C'est une grosse fonction
 * qui fait tout. Elle retourne la liste des macros utile
 * a convert().
 */

LIST_MACRO *find_or_load_macros( char *filename, LIST_MACRO **list)
{
	char *p,*q, *fext, ext[EXT_LENGHT];
	LIST_MACRO *scan;
	int end = 0;
	
	fext = strrchr( filename, '.');
	if( fext == NULL)	return NULL;
	fext++; /* contient l'extension du fichier */
	
	/* On cherche dabord dans la liste des macros */
	scan = *list;
	while ( scan) {
	
		/* comparer les extensions (le scan->ext est une liste!)*/
		q = p = scan -> ext;
		do{
			p = strpbrk( q, ":,\n");
			if( p) {
				strncpy( ext, q, p-q);
				ext[p-q]='\0';
				q = p+1;
			} else 
				strcpy( ext, q);	
			if( !stricmp( fext, ext)) {
				end = 1;
				p = NULL;
			}
		} while( p != NULL);
		if( end) break;
		scan = scan -> next;
	}
	
	/* Sinon on charge la macros */
	if( scan == NULL) {
		char filemacro[255];
		
		sprintf( filemacro, "%s\%s.MAC", macrospath, fext);
		scan = load_macro_colors( filemacro, list);
	}
	return scan;
}

/*
 * Cherche dans le r‚pertoire macrospath tous les fichiers
 * macros et les charges.
 */
 
void load_all_macros( LIST_MACRO **list)
{
	DTA *old = Fgetdta(), new;
	char path[255];
	
	strcpy( path, macrospath);
	strcat( path , "*.MAC");
	Fsetdta( &new);
	if( !Fsfirst( path, 0)) {
		strcpy( path, macrospath);
		strcat( path, new.d_fname);
		load_macro_colors( path, list);
		while( !Fsnext()) {
			strcpy( path, macrospath);
			strcat( path, new.d_fname);
			load_macro_colors( path, list);
		}
	}
	Fsetdta( old);
}


int main( int argc, char *argv[]) {
	LIST_MACRO *list;
	int i = 1, res = 0, dum;
	MFDB mfdb;
	
	ApplInit();
	for( dum=0; dum<NUM_OBS; rsrc_obfix( rs_object, dum++));
	if( argc == 1) {
/*		printf( "Color for Dom's Viewer\nBy Dominique B‚r‚ziat 1997\nsyntaxe: color [-d directory] file1 [file2 ...]\n"); */
		appl_exit();
		return 1;
	}
	/* Analyse des commandes */
	if( !strcmp(argv[1], "-d")) {
		strcpy( macrospath, argv[2]);
		if( macrospath[strlen(macrospath)-1] != '\\')
			strcat( macrospath, "\\");
		i = 3;
	}
	if( !strcmp(argv[i], "-silent")) {
		i++;
		silent = 1;
	}
	/* On charges toutes les macros */
	load_all_macros( &root_mac);
	wind_get( 0, WF_WORKXYWH, &x, &y, &w, &h);
	if( !silent)
		FormBegin( rs_trindex[COLOR], &mfdb);
	for( ; i<argc; i++) {
		char temp[255];
		
		list = find_or_load_macros( argv[i], & root_mac);
				
		if( list) {
			sprintf( rs_trindex[COLOR][COLOR_MACROS].ob_spec.tedinfo->te_ptext, "%16s", list->info);
			if( !silent)
				objc_draw( rs_trindex[COLOR], COLOR_MACROS, 0, x,y,w,h);
			sprintf( rs_trindex[COLOR][COLOR_FILE].ob_spec.tedinfo->te_ptext, "%-15s", argv[i]);
			if( !silent)
				objc_draw( rs_trindex[COLOR], COLOR_FILE, 0, x,y,w,h);
			strcpy( temp, macrospath);
			strcat( temp, "TEMP");
			convert( argv[i], temp, list);
			res = 0;
		} else {
			sprintf( rs_trindex[COLOR][COLOR_MACROS].ob_spec.tedinfo->te_ptext, "no macros file.");
			if( !silent)
				objc_draw( rs_trindex[COLOR], COLOR_MACROS, 0, x,y,w,h);
			res = 1;
		}
	}
	if( !silent)
		FormEnd( rs_trindex[COLOR], &mfdb);	
	free_macro_colors( root_mac);
	ApplExit();
	return res;
} 