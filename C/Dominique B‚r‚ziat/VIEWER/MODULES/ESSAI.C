/*
 * macro couleurs
 *	-> un fichier de macros-couleurs
 *	-> un convertisseur texte -> texte en couleurs
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*
 *   C.MAC
 *
 *	 keyword <word> <attributs>
 *						0...F		index couleurs
 *						blui		bold ligth underlined italic
 *	 zone	<begin> <end> <attributs>
 */

typedef struct {
		int type;
		char key1[30],key2[30];
		char color;
		char attrib;
	} MACRO_COLOR;

typedef struct _LIST_MACRO {
		MACRO_COLOR *mac;
		int max;
		char ext[10];
		struct _LIST_MACRO *next;
	} LIST_MACRO;
	

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

int load_macro_colors( char *filename, LIST_MACRO **root)
{
	FILE *fp=fopen( filename, "r");
	int count=0;
	char buf[120],word[50], att[10];
	MACRO_COLOR *mac;
	
	if( fp == NULL) return -33;
	/* count macro */
	while( !feof( fp)) {
		fgets( buf, 120, fp);
		if( *buf == '#')
			continue;
		sscanf( buf, "%s", word);
		if( !strcmp( word, "keyword") ||
			!strcmp( word, "zone"))
			count ++;
	}
	mac = (MACRO_COLOR*)malloc( sizeof(MACRO_COLOR)*count);
	if( mac == NULL) {
		fclose( fp);
		return -69;
	}
	rewind( fp);
	count = 0;
	while( !feof( fp)) 
    {
		fgets( buf, 120, fp);
		if( *buf == '#')
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
		}
	}
	fclose( fp);
	* strrchr( filename , '.') = '\0';
	if( *root == NULL) {
		*root = (LIST_MACRO*)malloc( sizeof( LIST_MACRO));
	}
	else {
		while( (*root)->next) {
			*root = (*root)->next;
		}
		(*root)->next = (LIST_MACRO*)malloc( sizeof( LIST_MACRO));
		*root = (*root) -> next;
	}
	(*root) -> next = NULL;
	(*root) -> max = count;
	(*root) -> mac = mac;
	strcpy( (*root) -> ext, filename);
	return 0;
}

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

int convert( char *filename, LIST_MACRO *root)
{
	FILE *fp = fopen( filename, "r");
	char *p,*q;
	FILE *fq;
	char buf[120];
	int is_zone = 0, i;
	
	if( fp == NULL)
		return -33;
	p = strchr( filename, '.');
	*p++ = '\0';
	while( root) {
		if( !strcmp( p, root->ext)) {
			break;
		}
		root = root->next;
	}
	if( root == NULL) {
		fclose( fp);
		return -1;
	}
	strcat( filename, ".ESC");
	fq = fopen( filename, "w");
	
	q = fgets( buf, 120, fp);
	p = NULL;
	while (!feof( fp)){
		
		for( i=0; i<root->max && p == NULL; p = strstr( q, root->mac[i].key1));
		if( i == root->max) { /* ligne suivante */
			q = fgets( buf, 120, fp);
			fprintf ( fq, "\n");
		}
		else { /* p pointe sur le mot-clef */
			fwrite( q, 1, p-q, fq);
			/* ‚crire le bourgat */
			if( root->mac[i].attrib)
				fprintf( fq, "%c%c", 27, root->mac[i].attrib);
			if( root->mac[i].color)
				fprintf( fq, "%c#%c", 27, root->mac[i].color);
			fprintf( fq, "%s", root->mac[i].key1);
			if( root->mac[i].attrib)
				fprintf( fq, "%c@", 27);
			if( root->mac[i].color)
				fprintf( fq, "%c#1", 27);			
			q = p + strlen( root->mac[i].key1); /* on repart */
		}
	}
	fclose( fq);
	fclose( fp);
	return 0;
}

void main(void) {
	LIST_MACRO *list;
	int i;
	
	load_macro_colors( "C.MAC", &list);
	printf ( "Found %d macros:\n", list->max);
	for( i=0; i<list->max; i++)
		printf( "type=%d %s %s %d 0x%X\n", 
				list->mac[i].type,
				list->mac[i].key1,
				(list->mac[i].type==1)?list->mac[i].key2: "",
				list->mac[i].color,
				list->mac[i].attrib);
	free_macro_colors( list);
}