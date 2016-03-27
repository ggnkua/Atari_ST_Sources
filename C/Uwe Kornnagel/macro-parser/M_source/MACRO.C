/*
	MACRO-PARSER Version 1.01	(C) Uwe Kornnagel
	-----------------------------------------------
	
	Include-Dateien, Macrobibiliotheken und Macroexpansion
	fÅr TURBOASS (C) Sîren Hellwig, Markus Fritze
	
	Compiler:	TurboC  2.0
	
	Copyright Vermerk:  Es gelten die gleichen Bedingungen wie
	                    fÅr TURBOASS.
	                    
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "syslib.h"

#define STRLEN   82		/* StringlÑnge eines Eingabezeilenbuffers */
#define NAMLEN   18		/* StringlÑnge eines Namensfeldbuffers */
#define MAXSTR	  (STRLEN-2)	/* maximale StringlÑnge einer Zeile */
#define MAXNAM   (NAMLEN-2)	/* maximale StringlÑnge eines Namens */

/* SchlÅsselworte fÅr MACRO */

#define SYSCALL	";@@"		/* Internes Macro SYSCALL */
#define INCLUDE	";INCLUDE"	/* Aufruf einer Include-Datei */
#define MACLIB		";MACLIB"		/* Aufruf einer Macro-Bibiliothek */
#define MAC_DEF	";@MACRO"		/* Definition eines MACROS */
#define MAC_END	";ENDM"		/* Ende des Makrokîrpers"
#define MAC_CALL	";+"			/* Aufruf eines MACROS */
#define PARA_DEF	'\\'			/* Kennung fÅr Parameteraufruf */
#define LABEL_DEF	"./."		/* Kennung fÅr lokale Labels */
#define TEXT_DEF	"TEXT"		/* SchlÅsselwort fÅr Text-Segment */
#define DATA_DEF	"DATA"		/* SchlÅsselwort fÅr Data-Segment */
#define BSS_DEF	"BSS"		/* SchlÅsselwort fÅr Bss-Segment */
#define END_DEF	"END"		/* SchlÅsselwort fÅr Source-Ende */
#define EQU_DEF	".EQU"		/* SchlÅsselwort Konstante zuweisen */

/* erkennt Trennzeichen fÅr Dateinamen bei INCLUDE und MACLIB */
#define is_deli(a)   ( isspace(a) || ( a == '\'') || ( a == '\"'))

/* erkennt gÅltige Zeichen fÅr Labels, Macronamen und Parameter  */
#define is_valid(a)	 ( isalnum(a) || ( a == '_' ) || ( a == '$') )

/* Struktur zur Verwaltung von Lokalen Labels im Macro */
#define LOC_LABEL  struct P_STRUCT
LOC_LABEL
{
	char	name[NAMLEN];
	int		cnt;
	LOC_LABEL	*next;
};
#define P_LEN  		sizeof(LOC_LABEL)
#define NEW_P(a)    a=(LOC_LABEL *) malloc(P_LEN)

/* Strukturen zum verwalten der Source und der Macros */

#define SYSLIB	struct S_CALL
#define SOURCE	struct S_STRUCT
#define MACRO 	struct M_STRUCT


MACRO
{
	char	name[NAMLEN];
	SOURCE	*source;
	MACRO	*next;
} *m_first, *m_last;

#define M_LEN		sizeof(MACRO)
#define	NEW_M(a)    a=(MACRO *) malloc(M_LEN)
SOURCE
{
	int		is_macro;
	char	line[STRLEN];
	SOURCE	*next;
} *s_first, *s_last, *z_first, *z_last, *t_first, *t_last,
  *d_first, *d_last, *b_first, *b_last;
#define S_LEN  		sizeof(SOURCE)
#define NEW_S(a)	a = (SOURCE *) malloc(S_LEN)
#define LINK(a,b,c)	if (!b) b=a; else c->next=a; c = a

int	errx;		/* Error-Counter */
int  wrnx;		/* Warnungs-Counter */
int  lokal;		/* Counter fÅr lokale Labels */
int  segment;		/* Segment-Flagg */

/* Funktions-definitionen */

void fatal( int nbr, char *s );
void gen_code( SOURCE *Adr );
SOURCE *free_source( SOURCE *Adr );
SOURCE *add_source( char *line );
void free_macro( void );
void add_macro( SOURCE *source, char *name );
void get_file(char *name );
void  check_name( char *o_name, char *i_name );
MACRO *find_macro( char *name );
void scan_macro( void );
void splitt( char *token, char *rest, char *line );
int  is_local( char *lbl );
void expand( SOURCE *Adr );
void z_sort( void );

/* Fehlerabbruchroutine bei fatalen Fehlern */
void fatal( int nbr, char *s )
{
	static char *errmsg[] =
	{ "Speicher ist voll %s\n",
	  "Datei %s nicht gesunden!\n",
	  "Datei %s kann nicht beschrieben werden!\n",
	  "Syntax MACRO Quellfile Zielfile [Maclib .. [Maclib]]%s\n",
	  "Quellcode-Ende innerhalb einer Mareodefinition erreicht%s\n",
	  ""
	};
	printf(errmsg[nbr],s);
	printf("***FATALER Fehler: Programmabbruch, bitte Taste drÅcken ");
	getchar();
	exit(0);
}

SOURCE *free_source( SOURCE *Adr )
{
	SOURCE *curr, *link;
	curr = Adr;
	while ( curr )
	{
		link = curr->next;
		free(curr);
		curr = link;
	}
	return NULL;
}

SOURCE *add_source( char *line )
{
	SOURCE *curr;
	NEW_S(curr);
	if ( !curr ) fatal(0,"!");
	memset(curr,0,S_LEN );
	strcpy(curr->line,line);
	return curr;
}

void free_macro( void )
{
	MACRO *curr, *link;
	curr = m_first;
	while ( curr )
	{
		link = curr->next;
		free( curr );
		curr = link;
	}
	m_first = m_last = NULL;
}

void add_macro( SOURCE *source, char *name )
{
	MACRO *curr;
	char Name[NAMLEN];

	NEW_M(curr);
	if ( !curr ) fatal(0,"!");
	memset(curr,0,M_LEN);

	check_name( Name,name );

	strcpy(curr->name,Name);
	curr->source = source;
	LINK( curr, m_first, m_last );
}

void my_exit( void )
{
	free_source( s_first );
	free_source( z_first );
	free_source( t_first );
	free_source( d_first );
	free_source( b_first );
	free_macro();
}

void get_file(char *name )
{
	FILE *f;
	SOURCE *curr;
	char	line[STRLEN], x[STRLEN], *c, *c1;
	
	f = fopen(name,"r");
	if( !f ) fatal(1,name);
	printf(" Including Datei %s\n",name);

	while ( !feof(f) ) 
	{
		memset(line,0,STRLEN);
		fgets( line,STRLEN,f);
		c = line; while( *c ) if ( (*c == 9) || (*c > 0x1f)) c++; else *c=0;
		if ( !feof(f) )
		{
			strcpy(x,line);
			strupr(x);
			c = strstr(x,INCLUDE );
			c1 = strstr(x,MACLIB);
			if ( c1 && !c ) c = c1;
			if ( c )
			{
				while ( !is_deli(*c) ) c++;
				while ( is_deli(*c) )  c++;
				c1 = x;
				while ( !is_deli(*c) ) *c1++ = *c++;
				*c1=0;
				get_file( x );
			}	else
			{
				curr = add_source( line );
				LINK( curr, s_first, s_last );
			}
		}
	}
	fclose(f);
}

void  check_name( char *o_name, char *i_name )
{
	char new_name[NAMLEN];
	strncpy( new_name,i_name,MAXNAM );
	if ( strlen(i_name) > MAXNAM )
	{
		printf("***WARNUNG: %s Name zu lang gekÅrzt (%s)\n",i_name,
			  new_name);
		wrnx++;
	}
	strcpy( o_name, new_name );
}

MACRO *find_macro( char *name )
{
	MACRO *curr, *fm;
	char	 Name[NAMLEN];
	
	curr = m_first;
	fm	 = NULL;
	
	check_name( Name, name );

	while( curr && !fm )
	{
		if( !strcmp(curr->name,Name) ) fm = curr;
		curr = curr->next;
	}
	return fm;
}

void scan_macro( void )
{
	SOURCE *curr;
	char   name[STRLEN], *c, *x;
	int	   cnt;

	cnt = 0;
	curr = s_first;
	while( curr )
	{
		strcpy(name,curr->line);
		strupr(name);
		c = strstr(name,MAC_DEF);
		if ( c )
		{
			x = name;
			c = curr->line +( c - name );
			while (*c && !is_deli(*c) ) c++;
			while (*c &&  is_deli(*c) ) c++;
			while (*c && !is_deli(*c) ) *x++ = *c++;
			*x = 0;
		     x = name;
		     check_name( name, x );
			if ( find_macro(name) )
			{
				printf("***FEHLER: %s MACRO doppelt definiert\n",name);
				errx++;
			} else
			{
				add_macro(curr, name );
				cnt++;
				while ( curr && !strstr(name,MAC_END) )
				{
					curr->is_macro = 1;
					curr = curr->next;
					if ( !curr ) fatal(4,"!");
	                    strcpy(name,curr->line);
					strupr(name);
				}
				curr->is_macro = 1;
			}
		}
		if (curr) curr = curr->next;
	}
}

void splitt( char *token, char *rest, char *line )
{
	char dummy[STRLEN], *c, *x;
	memset(dummy,0,STRLEN);
	strcpy(dummy,line);
	*token = *rest = 0;
	c = dummy;
	x = token;
	while (*c && is_deli(*c) ) c++;
	while (*c && !is_deli(*c)) *x++ = *c++;
	*x = 0;
	strcpy(rest,c);
	x = token;
	check_name( token, x );

}

int  is_local( char *lbl )
{
	if(strstr(lbl,LABEL_DEF)) return 1;
	return 0;
}

void expand( SOURCE *Adr )
{
	SOURCE *first, *last, *curr, *heap;
	MACRO  *mc;
	LOC_LABEL  *pfirst, *plast, *pcurr;
	char   name[STRLEN], rest[STRLEN], line[STRLEN], *c, *xx;
	char   a_name[STRLEN], a_rest[STRLEN], a_line[STRLEN];
	char   m_name[STRLEN], m_rest[STRLEN], m_line[STRLEN];
	char   x_par[STRLEN], *x;
	int    locdef = 0;
	
	first = last = curr = heap = NULL;
	pfirst = plast = pcurr = NULL;
	
	strcpy(line,Adr->line);
	xx = strstr(line,";+")+2;
	splitt(name,rest,xx );
	mc = find_macro(name);
	if ( !mc )
	{
		printf("***FEHLER: %s MACRO ist nicht definiert.\n",Adr->line);
		errx++;
		return;
	}
	
	/* MACRO in lokalen HEAP einlesen */
	curr = mc->source;
	strcpy(line,curr->line);
	strupr(line);
	while( curr && !strstr(line,MAC_END) )
	{
		heap = add_source( curr->line );
		LINK( heap, first, last );
		curr = curr->next;
		strcpy(line,curr->line);
		strupr(line);
	}
	
	/* Positionier Aufrufstring auf 1. Parameter */
	strcpy(a_line,Adr->line);
	splitt( a_name,a_rest,a_line);
	strcpy( a_line,a_rest );
	splitt( a_name,a_rest,a_line);

	/* Positioniere Definitionsstring auf 1. Parameter */
	strcpy( m_line,mc->source->line);
	splitt( m_name,m_rest,m_line);
	strcpy( m_line,m_rest );
	splitt( m_name,m_rest,m_line);
	strcpy( m_line,m_rest );
	splitt( m_name,m_rest,m_line);

	/*	exmandiere die PARAMETER */
	while( strlen(m_name) && strlen(a_name) )
	{
		curr = first->next;
		while ( curr )
		{
			strcpy(line,curr->line);
			memset(x_par,0,STRLEN);
			x_par[0] = PARA_DEF;
			strcat(x_par,m_name);
			c = strstr(line,x_par);
			if (c)
			{
				*c = 0;
				strcpy(name,line);
				c++;
				while( is_valid(*c) ) c++;
				strcpy( rest,c);
				strcpy( line,name );
				strcat( line,a_name );
				strcat( line,rest);
				strcpy( curr->line, line );
			}
			curr = curr->next;
		}
		strcpy( m_line,m_rest );
		splitt( m_name,m_rest,m_line);
		strcpy( a_line,a_rest );
		splitt( a_name,a_rest,a_line);
	}

	/* Teste ob lokale Labels vorhanden sind und definiere sie */
	curr = first->next;
	while( curr )
	{
		if( is_local(curr->line) )
		{
			locdef = 1;
			if (*curr->line == ';')
			{
				c = curr->line;
				while ( *c && !is_valid(*c) ) c++;
				x = name;
				while ( *c && is_valid(*c) ) *x++ = *c++;
				*x = 0;
				NEW_P(pcurr);
				if ( !pcurr )  fatal (0,"!");
				memset(pcurr,0,P_LEN);
				strncpy(pcurr->name,name,(NAMLEN-1));
				pcurr->cnt = lokal;
				LINK( pcurr, pfirst, plast);
				strcpy(rest,c);
				sprintf(line,"%s_%04X%s\000",pcurr->name,pcurr->cnt,rest);
				strcpy( curr->line,line);
			}
		}
		curr = curr->next;
	}

	/*	expandiere die Lokalen Labels  */
	if (locdef)
	{
		curr = first->next;
		while( curr )
		{
			while( is_local(curr->line) )
			{
				c = strstr(curr->line,LABEL_DEF);
				*c = 0;
				strcpy(a_name,curr->line);
				c +=3;
				x=name;
				while( is_valid(*c) ) *x++ = *c++;
				*x = 0;
				pcurr = pfirst;
				while ( pcurr && strcmp(pcurr->name,name) )
				{
					pcurr = pcurr->next;
				}
				if ( !pcurr )
				{
					printf("***FEHLER: %s ist kein lokales Label\n",name);
					sprintf(curr->line,"%s <---Fehler\000",a_rest);
					errx++;
				} else
				{
					strcpy(a_rest,c);
					sprintf(m_name,"%s_%04X\000",pcurr->name,pcurr->cnt);
					strcpy(line,a_name);
					strcat(line,m_name);
					strcat(line,a_rest);
					strcpy(curr->line,line);
				}
			}
			curr = curr->next;
		}
		
		/* Lokale Labels vom HEAP freigeben */
		pcurr = pfirst;
		while( pcurr )
		{
			plast = pcurr->next;
			free( pcurr );
			pcurr = plast;
		}
		pfirst = plast = pcurr = NULL;
		lokal++;
	 }

	/*	generiere den expandierten Code vom Lokalen Heap in die 
		entsprechenden Output-Queues
	*/
	gen_code( first->next );
	
	/* gib lokalen Heap wieder frei */
	first = last = free_source( first );
}


void gen_code( SOURCE *Adr )
{
	SOURCE *curr, *heap;
	char	line[STRLEN], name[STRLEN], rest[STRLEN], *c;
	int x1, y1;

	/* Beginne mit Codegenerierung ab Adresse */
	curr = Adr;

	while(curr)
	{
		if (!curr->is_macro && strstr(curr->line,SYSCALL) )
		{
			c = strstr(curr->line,SYSCALL)+3;
			strcpy( name,c );
			strupr(name);
			x1 = y1 = 0;
			while ( syslib[x1].name[0] && !y1 )
			{
				if (!strcmp(name,syslib[x1].name) ) y1 = x1;
				x1++;
			}

			if ( y1 )
			{
				sprintf(line," move.w #$%02x,-(sp)\000",syslib[y1].fnc);
				heap = add_source(line);
				LINK(heap,t_first,t_last);
				sprintf(line," trap #%d\000",syslib[y1].trap);
				heap = add_source(line);
				LINK(heap,t_first,t_last);
				if (syslib[y1].size )
				{
					if ( syslib[y1].size > 8 )
						sprintf(line," lea $%02x(sp),sp\000",syslib[y1].size);
					else
						sprintf(line," addq.l #$%02x,sp\000",syslib[y1].size);
					heap = add_source(line);
					LINK(heap,t_first,t_last);
				}
				curr->is_macro = 1;
			}	else
			{
				printf("***FEHLER: %s ist kein SYSCALL\n",name);
				errx++;
			}
		}
		if ( !curr->is_macro )
		{
			if (strstr(curr->line,";+") )
			{
				/* Macro expandieren */
				expand(curr);
			} else
			{
				heap = add_source(curr->line);
				heap->is_macro = 0;

				/* Bestimme die SEGMENT-Queue */
				strcpy( line, curr->line );
				strupr(line);
				splitt( name, rest, line );

				if (!strcmp(name,TEXT_DEF))
				{
					segment = 0;
					heap->is_macro = 1;
				}	else
				{
					if (!strcmp(name,DATA_DEF))
					{
						segment = 1;
						heap->is_macro = 1;
					}	else
					{
						if (!strcmp(name,BSS_DEF))
						{
							segment = 2;
							heap->is_macro = 1;
						} else
						{
							if ( !strcmp(name,END_DEF) )
							{
								heap->is_macro = 1;
							} else if (strstr(line,EQU_DEF))
							{
								x1 = segment;
								segment = 3;
							}
						}
					}
				}

				/*  Sourceline an Segmentqueue anfÅgen */
				switch ( segment )
				{
					case 0:	LINK(heap,t_first,t_last); 	break;
					case	1:	LINK(heap,d_first,d_last); 	break;
					case 2:	LINK(heap,b_first,b_last); 	break;
					case 3:	LINK(heap,z_first,z_last); 
							segment = x1;				break;
				}
			}   
			
		}
		
		/* naechte Zeile */
		if( curr ) curr = curr->next;
	}
}

void z_sort( void )
{
	SOURCE *curr, *link;
	char   dummy[STRLEN];
	curr = z_first;
	while ( curr )
	{
		link = curr->next;
		while( link )
		{
			if (strcmp(curr->line,link->line) > 0)
			{
				strcpy( dummy, link->line );
				strcpy( link->line, curr->line );
				strcpy( curr->line, dummy );
			}
			link = link->next;
		}
		curr = curr->next;
	}
}


void main( int argc, char *argv[] )
{
	int i;
	FILE *f;
	SOURCE *curr;

	atexit(my_exit);

	s_first = s_last = z_first = z_last = t_first =
	t_last = d_first = d_last = b_first = b_last  = NULL;
	m_first = m_last = NULL;
	errx = wrnx = lokal = 0;

	
	puts("MACRO V1.01:   Macroparser  (c) 1990 Uwe Kornnagel\n");
	if ( argc < 3 ) fatal(3,"!");

	get_file( argv[1] );
	if ( argc > 3 ) for( i=3; i<argc; get_file(argv[i++]));

	scan_macro();

	gen_code( s_first );

	printf (" %d Fehler und %d Warnungen\n",errx,wrnx);

	if (errx) exit(0);

	f=fopen(argv[2],"w");

	if ( z_first )
	{
		z_sort();
		fprintf(f,"; Definition aller Konatanten\n");
		curr = z_first;
		while (curr)
		{
			if ( !curr->is_macro ) fprintf(f,"%s\n",curr->line );
			curr = curr->next;
		}
	}

	if ( t_first )
	{
		curr = t_first;
		fprintf(f,"\n%s\n",TEXT_DEF);
		while (curr)
		{
			if ( !curr->is_macro ) fprintf(f,"%s\n",curr->line );
			curr = curr->next;
		}
	}

	if ( d_first )
	{
		curr = d_first;
		fprintf(f,"\n%s\n",DATA_DEF);
		while (curr)
		{
			if ( !curr->is_macro ) fprintf(f,"%s\n",curr->line );
			curr = curr->next;
		}
	}

	if ( b_first )
	{
		curr = b_first;
		fprintf(f,"\n%s\n",BSS_DEF);
		while (curr)
		{
			if ( !curr->is_macro ) fprintf(f,"%s\n",curr->line );
			curr = curr->next;
		}
	}

	fprintf(f,"\n%s\n",END_DEF);

	fclose(f);

	exit(0);
}