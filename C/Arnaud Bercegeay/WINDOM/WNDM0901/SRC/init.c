/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2001
 *
 *	module: init.c
 *	description: librairie configuration
 *				 version avec tampon pour acc‚l‚rer la lecture
 *				 du fichier de config.
 */

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "globals.h"

/* Configuration de l'application */
char *__confapp_buffer = NULL;
int __confapp_line_top;
int __confapp_line_pos;

/* Configuration par defaut (Default Settings) */
char *__confdef_buffer = NULL;
int __confdef_line_top;
int __confdef_line_pos;

/*
 *	Nom de l'application
 */

static void get_appname( char *name) {
	char path[128], dum[128], *p;
	
	shel_read( path, dum);
	strcpy( name, "[");
	p = strrchr( path, '.');
	if( p) *p = '\0';
	p = strrchr ( path, '\\');
	strcat( name, p?(p+1):path);
	strcat( name, "]");
	strupr( name);
}

/*
 *	Lecture d'une ligne dans un buffer <ptr>
 */
static char *sgets( char *line, long size, char *ptr) {
	char *e=ptr;
	
	line[size-1] = '\0';			/* cas ou l'on d‚passe */
	while( *ptr != '\0' &&
		   *ptr != '\n' &&
		   ptr-e < size-1) {
		*line++ = *ptr++;
	}
	if( *ptr =='\n') {
		ptr ++;
		*line = '\0';
	}
	return ptr;
}

/*
 * interrogation d'une variable dans __conf_buffer
 */

static int conf_inquire( char *buffer, char *keyword, char *fmt, va_list args) {
	char buf[LINE_SIZE], cmd[30], *p, *q, *s;
	int res = -1;
	void *ptr;
	unsigned int bit;
	char *pos = buffer;

	if( pos == NULL)
		return -33;
	while( *pos) {
		/* Lire une ligne */
		pos = sgets( buf, LINE_SIZE, pos);
		if(*buf == '#' || *buf=='\n')
			continue;
		sscanf( buf, "%s", cmd);
		if( !stricmp( cmd, keyword)) {
			res = 0;
			/* ‚valuer les valeurs: a faire nous-meme */
			p = strchr( buf, '=');
/*			va_start( args, fmt); */
			q = fmt;
			while( *q) {
				q = strchr( q, '%');
				if( p)
					p++;
				else
					break;
				res ++;
				if( q)
					switch( *++q) {
					case 'd':
					case 'x':
						ptr = (void*)va_arg( args, int *);
						sscanf( p, (*q=='d')?"%d":"%x", ptr);
						break;						
					case 'f':
						ptr = (void*)va_arg( args, float *);
						sscanf( p, "%f", (float*)ptr);
						break;
					case 'c':
						ptr = (void*)va_arg( args, char *);
						p = strchr( p , '\'');
						if( p) 
							sscanf( p+1, "%c", (char*)ptr);
						else	res --;
						break;
/*
					case 's':
						ptr = (void*)va_arg( args, char *);
						sscanf( p, "%s", ptr);
						s = strchr( ptr, ',');
						if( s) *s='\0';
						break;
					case 'S':
						ptr = (void*)va_arg( args, char *);
						p = strchr( p, '"');
						if( p) {
							strcpy( ptr, p+1);
							*strchr( ptr, '"') = '\0';
							p = strchr( p+1, '"');
						} else res--;
						break;
*/
					case 's':
					case 'S':
						ptr = (void*)va_arg( args, char *);
						s = strchr( p, '"');
						if( s) {
							strcpy( ptr, s+1);
							*strchr( ptr, '"') = '\0';
							p = strchr( s+1, '"');
						} else /* res--; */ {
							sscanf( p, "%s", (char*)ptr);
							s = strchr( ptr, ',');
							if( s) *s='\0';
						}
						break;
					case 'B':
					case 'b':
						ptr = (void *)va_arg( args, unsigned int *);
						if( *q == 'B') bit = va_arg( args, unsigned int);
						else		   bit = 0x1;
						sscanf( p, "%s", cmd);
						s = strchr( cmd, ',');
						if( s) *s='\0';
						if( !stricmp( cmd, "true") ||
							!stricmp( cmd, "on")   ||
							!strcmp ( cmd, "1"))
							SET_BIT( *(unsigned int *)ptr, bit, TRUE);
						else
						if( !stricmp( cmd, "false") ||
							!stricmp( cmd, "off")   ||
							!strcmp ( cmd, "0"))
							SET_BIT( *(unsigned int *)ptr, bit, FALSE);
						else
							res --;
						break;
					default:
						res --;
					}
				p = strchr( p, ',');
			}
	/*		va_end( args); */
			break;
		} else 
			if( !stricmp( cmd, "[end]"))
				break;	/* fin de la boucle */
	}
	return res;
}


int ConfInquire( char *keyword, char *fmt, ...) {
	va_list args;
	int res;
	
	va_start( args, fmt);
	res = conf_inquire( __confapp_buffer, keyword, fmt, args);
	va_end( args);	
	if( res < 0) {
		va_start( args, fmt);
		res = conf_inquire( __confdef_buffer, keyword, fmt, args);
		va_end( args);
	}
	return res;
}


void add_slash( char *path) {
	if( *path && path[strlen(path)-1] != '\\')
		strcat( path, "\\");
}

/* r‚pertoire courant, r‚pertoires HOME[/Defaults], r‚pertoires PATH,
   r‚pertoire C:\
   valeur de  retour: -33 pas de fichier
                      -1  aucune balise pour l'application
                       0  pas d'erreur
*/

/* Test windom.cnf puis .windomrc */

/* Pour WinConf */
char __confpath [FILE_SIZE];

static
FILE *fconf( char *path, char *subpath) {
	FILE *fp;
	
	strcpy( __confpath, path);
	add_slash( __confpath);
	strcat( __confpath, subpath);
	add_slash( __confpath);
	strcat( __confpath, "windom.cnf");
	fp = fopen( __confpath, "r");
	if( fp == NULL && vq_extfs(path)) {
		strcpy( __confpath, path);
		add_slash( __confpath);
		strcat( __confpath, subpath);
		add_slash( __confpath);
		strcat( __confpath, ".windomrc");
		fp = fopen( __confpath, "r");
	}
	return fp;
}

void read_attrib( char *name, ATTRIB *attrib) {
	char buf[80];
	
	strcpy( buf, name);
	strcat( buf, ".color");
	ConfInquire( buf, "%d", &attrib->color);
	strcpy( buf, name);
	strcat( buf, ".size");
	ConfInquire( buf, "%d", &attrib->size);
	strcpy( buf, name);
	strcat( buf, ".font");
	if( ConfInquire( buf, "%S", buf) >= 1) {
		attrib->font = FontName2Id( buf);
		if(attrib->font == -1) attrib->font = 0;
	}
}


/* Trouve une balise et la charge */
/* Fichier, balise, et position de la config dans le fichier */

static
char *find_and_read( FILE *fp, char *tag, int *top) {
	int find = FALSE;
	int tagtop, real;
	int bottom = -1;
	char *buffer, *p;
	char buf[LINE_SIZE+1];
	
	rewind( fp);

	*top = 0;
	while( !feof( fp)) {
		/* indicateur de position pour ConfInquire() */
		tagtop = (int) ftell( fp);			
		p = fgets( buf, LINE_SIZE, fp);
		(*top) ++;
		if( p == NULL) break;
		if( *buf == '#' || *buf=='\n')
			continue;
		while( *p == ' ' || *p == '\t')
			p ++;		
		if( p == strstr( p, tag) ) {
			find = TRUE;
			break;
		}
	}	

	/* Balise non trouv‚e */
	if( find == FALSE) 
		return NULL;
	
	/* Recherche de la balise [end] */	
	fseek( fp, tagtop, 0);
	while( !feof( fp)) {
		p = fgets( buf, LINE_SIZE, fp);
		if( p == NULL) break;
		if(*buf == '#' || *buf=='\n')
			continue;
		while( *p == ' ' || *p == '\t')
			p ++;
		if( p == strstr( p, "[end]")) {
			bottom = (int)ftell( fp);
			break;
		}
	}

	if (bottom == -1) {       /* la balise [end] n'existe pas */
		bottom = (int) ftell( fp);  /* feof(fp)==TRUE => bottom = end of the file */
	}

	buffer = (char*)malloc( sizeof(char)*(bottom-tagtop+1));
	fseek( fp, tagtop, 0);
	real = (int) fread( buffer, sizeof(char), bottom-tagtop, fp);
	buffer[MIN(real, bottom-tagtop)] = '\0';

	return buffer;
}


int ConfRead( void) {
	FILE *fp = NULL;
	char path[FILE_SIZE], *p;
	char buf[LINE_SIZE];
	int  dum;
	char nameprg[20];
	CONFIG *conf = app.conf;
	
	/* Recherche du fichier 'windom.cnf' */
	
	/* r‚pertoire courant */
	
	fp = fconf( ".", "");
	
	/* r‚pertoire HOME[\Defaults] */

	shel_envrn( &p, "HOME=");
	if( fp == NULL && p ) {
		fp = fconf( p, "Defaults");
		if( fp == NULL ) 
			fp = fconf( p, "");
	}

	/* r‚pertorie ETCDIR */
	shel_envrn( &p, "ETCDIR=");
	if( fp == NULL && p )
		fp = fconf( p, "");
	
	/* r‚pertoire PATH */
	
	if( fp == NULL) {
		strcpy( __confpath, "windom.cnf");
		shel_find( __confpath);
		fp = fopen( __confpath, "r");
	}
	
	/* r‚pertoire C:\ */
	
	if( fp == NULL &&  Dsetdrv( Dgetdrv()) & 0x4)	 /* C: */
		fp = fconf( "C:\\", "");

	if( __confapp_buffer != NULL) {
		free( __confapp_buffer);
		__confapp_buffer = NULL;
	}
	if( __confdef_buffer != NULL) {
		free( __confdef_buffer);
		__confdef_buffer = NULL;
	}
				
	if( fp == NULL)
		return -33;

	get_appname( nameprg);
	
	/* On cherche la balise de notre application 
	 * et celle de la config par defaut, on les charges 
	 */

	__confapp_buffer = find_and_read( fp, nameprg, &__confapp_line_top);
	__confapp_line_pos = __confapp_line_top;	
	__confdef_buffer = find_and_read( fp, "[Default Settings]", &__confdef_line_top);
	__confdef_line_pos = __confdef_line_top;
	fclose( fp);
	
	/* Aucune balise n'a ‚t‚ trouv‚ */
	if( !__confapp_buffer && !__confdef_buffer)
		return -1;

	/*
	 * ICI, Interrogation du fichier 
	 */
	
	/* Ev‚nements */
	if( ConfInquire( "windom.evnt.keybd", "%s", buf)>=1)
		SET_BIT( conf->flag, KEYBD_ON_MOUSE, !stricmp(buf,"mouse"));
	if( ConfInquire( "windom.evnt.button", "%s", buf)>=1)
		SET_BIT( conf->flag, BUTTON_ON_MOUSE, !stricmp(buf,"mouse"));

	/* Types ‚tendus */
	read_attrib( "windom.string", 	&conf->string);
	read_attrib( "windom.button", 	&conf->button);
	read_attrib( "windom.exit", 	&conf->exit);
	read_attrib( "windom.xedit.text", 	&conf->xedit_text);
	read_attrib( "windom.xedit.label", 	&conf->xedit_label);
	read_attrib( "windom.xlongedit", 	&conf->xlongedit);
	ConfInquire( "windom.xlongedit.smallsize", "%d", &conf->xlgedt_smlfnt);
	read_attrib( "windom.xtedinfo",		&conf->xtedinfo);
	ConfInquire( "windom.xtedinfo.smallsize", "%d", &conf->xtdinf_smlfnt);
	read_attrib( "windom.menu", 	&conf->title);
	read_attrib( "windom.bubble",	&conf->bubble);
	ConfInquire( "windom.relief.mono" , "%d", &conf->actmono);
	ConfInquire( "windom.relief.color", "%d", &conf->actcol);
	
	/* popup  */
	ConfInquire( "windom.popup.color",  "%d", &conf->popcolor);
	ConfInquire( "windom.popup.border", "%d", &conf->popborder);
	ConfInquire( "windom.popup.framec", "%d", &conf->popfcolor);
	ConfInquire( "windom.popup.pattern","%d", &conf->poppatt);
	if( ConfInquire( "windom.popup.relief", "%b", &dum) >= 1)
		if( dum) conf->poppatt |= 0x100;
	if( ConfInquire( "windom.popup.window", "%s", buf) >= 1 ) {
		if( !stricmp( buf, "default"))	conf->popwind = DEFVAL;
		if( !stricmp( buf, "false"))	conf->popwind = FALSE;
		if( !stricmp( buf, "true"))		conf->popwind = TRUE;
	}

	/* GrectCenter */
	if( ConfInquire( "windom.window.center", "%s", buf) >= 1) {
		if( !stricmp( buf, "screen"))	conf->wcenter = CENTER;
		if( !stricmp( buf, "mouse"))	conf->wcenter = WMOUSE;
		if( !stricmp( buf, "upleft"))	conf->wcenter = UP_LEFT;
		if( !stricmp( buf, "upright"))	conf->wcenter = UP_RIGHT;
		if( !stricmp( buf, "dnleft"))	conf->wcenter = DN_LEFT;
		if( !stricmp( buf, "dnright"))	conf->wcenter = DN_RIGHT;
		if( !stricmp( buf, "form"))		conf->wcenter = FCENTER;
	}

	/* Fenˆtres */
	if( ConfInquire( "windom.window.effect", "%s", buf) >= 1) {
		if( !stricmp( buf, "default"))	conf->weffect = DEFVAL;
		if( !stricmp( buf, "false"))	conf->weffect = FALSE;
		if( !stricmp( buf, "true"))		conf->weffect = TRUE;
	}
	ConfInquire( "windom.mform.widget", "%x", &conf->mwidget);
	ConfInquire( "windom.window.bg.pattern", "%d", &conf->bgpatt);
	ConfInquire( "windom.window.bg.color", "%d", &conf->bgcolor);
	ConfInquire( "windom.window.bg.style", "%d", &conf->bgstyle);
	
	/* Autres */
	dum = TRUE;
	if( ConfInquire( "windom.fsel.fslx", "%b", &dum) > 0)
		SET_BIT( conf->flag, NOMAGICFSEL, !dum);
	ConfInquire( "windom.shortcut.color", "%d", &conf->key_color);
	ConfInquire( "windom.menu.effect", "%d", &conf->menu_effect);
/*	dum = FALSE;
	if( ConfInquire( "windom.menu.autokey", "%b", &dum))
		SET_BIT( conf->flag, KEYMENUOFF, !dum); */
	dum = FALSE;
	if( ConfInquire( "windom.menu.scroll", "%b", &dum) > 0)
		SET_BIT( conf->flag, MENUSCROLL, dum);
	ConfInquire( "windom.iconify.geometry", "%d,%d", &conf->wicon, &conf->hicon);
	if( ConfInquire( "windom.version", "%b", &dum)>=1 && dum) {
		sprintf( path, "[1][WinDom version %d.%-2d, compiled the |%s at %s|with %s compiler][Ok]",
				 WinDom.patchlevel>>8, WinDom.patchlevel&0x00FF,
				 WinDom.date, WinDom.time, WinDom.cc_name);
		form_alert( 1, path);
	}
	return 0;
}

/*
 *	Lecture s‚quentielle du fichier
 */

int ConfGetLine( char *string) {
	char *line;
	static size_t pos = 0;
	int mode = -1;
	
	if( __confapp_buffer) {
		line = __confapp_buffer;
		mode = 1;
	} else if( __confdef_buffer) {
		line = __confdef_buffer;
		mode = 0;
	}

	/* reinit */
	if( line == NULL || string == NULL) {
		pos = 0;
		__confdef_line_pos = __confdef_line_top;
		__confapp_line_pos = __confapp_line_top;
		return 0;
	}
	line += pos;
	if( *line == '\0')
		return 0;	/* plus rien … lire */
	while( *line != '\n' && *line != '\0') {
		*string++=*line++;
		pos++;
	}
	*string='\0';
	if( *line == '\n')
		pos++;

	if( mode == -1) return 0;
	return (mode ? (__confapp_line_pos++) : (__confdef_line_pos++));
}

/*
 *	Ecriture dans le fichier de configuration
 */

static char *find_word( char *buffer, char *find) {
	char *p, *q = buffer;
	do {
		p = strstr( q, find);
		if( p && (q == p || *(p-1) == '\n'))
			return p;
		q = p;
	} while( p);
	return 0L;
}

#ifndef FA_SUBDIR
#define FA_SUBDIR 0x10
#endif

static int is_dir( char *path, char *dir) {
	char buf[255];
	int res;

	strcpy( buf, path);
	add_slash( buf);
	strcat( buf, dir);
	res = Fattrib( buf, 0, 0);
	if( res == -33) return 0;
	if( res & FA_SUBDIR) {
		strcpy( __confpath, buf);
		add_slash( __confpath);
		return 1;
	} else
		return 0;
}

int ConfWrite( char *name, char *fmt, ...) {
	va_list args;
	FILE *fp;
	char *buf, save, *p, *q, *s;
	size_t size;
	char nameprg[20];
	int found = 1;
	
	get_appname( nameprg);	
	fp = fopen( __confpath, "r");
	if( fp == NULL) {
		/* Cr‚er un fichier ad‚quat */
		shel_envrn( &p, "HOME=");
		if( p && is_dir( p, "Defaults"))
			;
		else if( p && is_dir( p, ""))
			;
		else if( is_dir( ".", ""))
			;
		if( vq_extfs(__confpath))
			strcat( __confpath, ".windomrc");
		else
			strcat( __confpath, "windom.cnf");
		
		fp = fopen( __confpath, "w");

		fprintf( fp, "# WinDom configuration file\n%s\n", nameprg);
		if( fmt) {
			fprintf( fp, "%s = ", name);
			va_start( args, fmt);
			vfprintf( fp, fmt, args);
			va_end( args);
			fprintf( fp, "\n");
		}
		fprintf( fp, "[end]\n");
		fclose( fp);
		return 0;
	}

	/* Charger le fichier,
	 * le modifier,
	 * puis sauvegarder
	 */

	fseek( fp, 0L, 2);
	size = ftell( fp);
	fseek( fp, 0L, 0);
	buf = (char *)malloc(sizeof(char)*size);
	if( !buf) {
		fclose( fp);
		return 0;
	}
	size = fread( buf, sizeof(char), size, fp);
	buf[size] = '\0';

	fclose( fp);
	
	/* Trouvons la bonne balise */
	
	p = find_word( buf, nameprg);

	/* On essai la balise par defaut */
	if( p == NULL) p = find_word( buf, "[Default Settings]");
	
	if( p == NULL) {
		/* Cr‚er la balise qui va bien … la fin
		 * du fichier */
		fp = fopen( __confpath, "a");
		fprintf( fp, "\n%s\n", nameprg);
		fprintf( fp, "%s = ", name);
		if( fmt) {
			va_start( args, fmt);
			vfprintf( fp, fmt, args);
			va_end( args);
			fprintf( fp, "\n");
		}
		fprintf( fp, "[end]\n");
		fclose( fp);
		return 0;
	} else {
		/* La balise existe, recherche de la variable */

		/* Pour rester dans le bon champ */
		s = find_word( p, "[end]");
		*s = '\0';
		q = find_word( p, name);
		*s = '[';
		
		if( q == NULL) {
			/* La variable n'existe pas, on l'ajoute */
			q = find_word( p, "[end]");
			found = 0;
		}
		p = q;
		
		/* Ecriture du d‚but */
		save = *p;
		*p = '\0';
		fp = fopen( __confpath, "w");
		fwrite( buf, sizeof( char), strlen( buf), fp);
		*p = save;

		if( fmt) {
			/* Ecriture de la variable */
			fprintf( fp, "%s = ", name);
			va_start( args, fmt);		
			vfprintf( fp, fmt, args);
			va_end( args);
			fprintf( fp, "\n");
		}

		/* Ecriture de la fin */	
		if( found) p = strchr( p, '\n')+1;
		size = strlen( p)+1;
		fwrite( p, sizeof( char), size, fp);
		fclose( fp);
	}
	return 0;
}

/*
 *	Appel de WinConf 
 */

int ConfWindom( void) {
	char *p=NULL;
	char prgname[255], prgcmd[255];
	int locate = FALSE;
    int ShelWrite( char *, char *, void *, int, int);

	/* Nom du programme */
	shel_read( prgname, prgcmd);

	/* Localisation de WinConf */
	if( shel_envrn( &p, "WINCONF="))
		locate = TRUE;
	else {
		strcpy( prgcmd, "winconf.app");
		locate = shel_find( prgcmd);
		p = prgcmd;
	}
	if( locate)
		return ShelWrite( p, prgname, NULL, TRUE, FALSE);
	else
		return -33;
}

