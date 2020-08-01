/*
	shelp.c
		source-code fÅr PureC 1.0
	written by Th. Morus Walter

	v0.9		 5. 1.1995
	  changes:	13. 1.1995 ausgabe einer @$VER - Zeile 

*/
#include "shelp.h"
#include <time.h>


	/* io streams */
		/* global um sie im fehlerfall schlieûen zu kînnen */
FILE *dest;
FILE *source;

char *source_name;		/* name der aktuellen quelldatei */

	/* parameter die durch kommandozeilen optionen geÑndert werden kînnen */
		/* definition der zu schreibenden daten */
typedef enum {
	WR_NONE,			/* nicht schreiben */
	WR_NO_COMM,			/* schreibe ohne vorigen kommentar */
	WR_PART_COMM,		/* schreibe mit vorigem kommentar, 
							falls keine leerzeile dazwischen */
	WR_ALL,				/* schreibe immer mit vorigem kommentar */
} WRITE_MODE;
WRITE_MODE write_function=WR_NONE;
WRITE_MODE write_typedef=WR_NONE;
WRITE_MODE write_define=WR_NONE;

		/* doppelte referenzen nur einmal schreiben */
int dont_write_double=1;

		/* headerdatei fÅr hypertext */
char header_file[128]="header.stg";
		/* ausgabedatei */
char out_file[128]="shelp.stg";

char database[128]="Online-Hilfe zu C-Sourcen";

		/* puffergrîûe fÅr typedef/funktionskopf */
long buf_size=16*1024l;
		/* puffergrîûe fÅr namen */
long names_size=64*1024l;

/* puffer fÅr namen um
	doppeleintrÑge zu ermittlen
	indexseiten zu schreiben
*/
typedef struct _names {
	struct _names 	*next;		/* zeiger auf nÑchste struktur */
	int 			count;		/* nummer bei mehrfacheintrÑgen */
	int 			unique;		/* name eindeutig (oder erstmalig) */
	NAME_TYP		typ;		/* typ des eintrags */
	char 			name[];
} NAMES;

NAMES *names,*next;
int name_count[3];				/* zaehler fÅr eintrage der versch. typen */

/*
		fehler ausgeben und prog. terminieren
*/
void do_error(ERR_NUMS error)
{
	switch ( error ) {
	  case ERR_INTERNAL:		/* should not happen (UNUSED) */
		fprintf(stderr,"Something went wrong\n");
	  break;
	  case ERR_MEMORY:
	  	fprintf(stderr,"Speicher reicht nicht\n");
	  break;
	  case ERR_FILE:
	  	fprintf(stderr,"Dateifehler\n");
	  break;
	  case ERR_OPTIONS:
	  	fprintf(stderr,"unbekannte Option angegeben\n");
	  break;
	  case ERR_BUFFER:
	  	fprintf(stderr,"Seitenpuffer zu klein, vergrîûern mit -b \n");
	  break;
	  case ERR_NAMES:
	  	fprintf(stderr,"Puffer fÅr Namen voll, vergrîûern mit -s \n");
	  break;
	  case ERR_NOFILES:
	  	fprintf(stderr,"Keine Quelldateien angegeben \n");
	  break;
	}
	if ( source )
		fclose(source);
	if ( dest )
		fclose(dest);
	if ( puffer.start )
		free(puffer.start);
	if ( names )
		free(names);

	exit(1);
}

/*
	protokolliere namen und typ aus puffer in der liste 'names'
*/
NAMES *protocol_name(TEXT_PUFFER *puffer)
{
NAMES *act;
long len;
int unique=1;
int count=0;
char name[256],*h,*d;

		/* kopiere namen (ist in puffer NICHT nullterminiert) */
	h=puffer->name;
	d=name;
	while ( isalnum(*h) || *h=='_' )
		*d++=*h++;
	*d=0;

		/* suche ob eintrag schon ex. */
	for ( act=names; act->next!=0l; act=act->next ) {
		if ( !strcmp(name,act->name) ) {
			if ( dont_write_double )	/* hmm, sinnvoll? */
				return 0l;				/* gleicher namen ungleicher typ */

			if ( puffer->typ==act->typ ) {
				count=act->count+1;
				unique=act->unique;
			}
			else
				unique=0;
		}
	}

	len=sizeof(NAMES)+strlen(name)+1;
	if ( len&1 )
		len++;
	next->next=(NAMES*)((char*)next+len);
	if ( next->next>(NAMES*)((char*)names+names_size) )
		do_error(ERR_NAMES);

	name_count[puffer->typ]++;
	next->typ=puffer->typ;
	next->count=count;
	next->unique=unique;
	strcpy(next->name,name);
	act=next;
	next=next->next;
	next->next=0l;
	return act;
}

/*
	teste ob kommentar in puffer vor text vom durch leerzeile getrennt ist
	oder nicht
	return 1 falls keine leerzeile
	       0 sonst
*/
int check_comm(TEXT_PUFFER *puffer)
{
char *h;
int nl=0;

	if ( puffer->textstart==puffer->start )
		return 0;		/* eigentlich egal, kein kommentar vorhanden */
	h=puffer->textstart-1;
	while ( isspace(*h) && h>=puffer->start ) {
		if ( *h=='\n' )
			nl++;
		*h--;
	}
	if ( nl>1 )
		return 0;
	else
		return 1;
}

/*
	schreibe hypertextseite

			@node NAME
			FILE file LINE nn

			... (text)
			
			@endnode

		wobei 'file' link auf Datei/Zeile ist
		in NAME gegebenenfalls doppelte EintrÑge markieren
*/
void write_item(TEXT_PUFFER *puffer)
{
WRITE_MODE mode;
NAMES *name;
char mode_c;
int line;
char *start;

	switch ( puffer->typ ) {
	  case FUNCTION:
		mode=write_function;
		mode_c='F';
	  break;
	  case TYPEDEF:
		mode=write_typedef;
		mode_c='T';
	  break;
	  case DEFINE:
	  	mode=write_define;
		mode_c='D';
	  break;
	  default:
		mode=WR_NONE;		/* should not happen */
	  break;
	}
	if ( mode==WR_NONE )
		return;				/* all die arbeit, ganz umsonst */

	if ( mode==WR_NO_COMM ) {
		start=puffer->textstart;
		line=puffer->text_line;
	}
	else if ( mode==WR_PART_COMM ) {
		if ( check_comm(puffer) ) {
			start=puffer->start;
			line=puffer->start_line;
		}
		else {
			start=puffer->textstart;
			line=puffer->text_line;
		}
	}
	else /* if ( mode==WR_ALL ) */ {
		start=puffer->start;
		line=puffer->start_line;
	}

	name=protocol_name(puffer);
	if ( !name )
		return;

	fputs("@node ",dest);

	fputs(name->name,dest);
	if ( name->unique ) {
		if ( name->count )
			fprintf(dest,".%d",name->count);
	}
	else {
		if ( name->count )
			fprintf(dest,".%c%d",mode_c,name->count);
		else
			fprintf(dest,".%c",mode_c);
	}
	fprintf(dest,"\n\nFILE @{%s link %s/Main %d} LINE @{B}%d@{b}\n\n",source_name,source_name,line,line);

	fputs(start,dest);

	fputs("\n\n\@endnode\n\n",dest);
}

void make_xname(char *out,char *in)
	/*
		erzeuge absoluten dateinamen 'out' aus dem mîglicherweise relativen 'in'
	*/
{
	if ( in[1]==':' )
		strcpy(out,in);
	else {
		out[0]=Dgetdrv()+'A';
		out[1]=':';
		if ( *in=='\\' )
			strcpy(out+2,in);
		else {
			Dgetpath(out+2,0);
			strcat(out,"\\");
			strcat(out,in);
		}
	}
}

void do_file(char *name)
	/*
		bearbeite datei
	*/
{
char xname[256];

	source=fopen(name,"r");
	if ( !source )
		return;
	make_xname(xname,name);

	source_name=xname;
	do_parse(source);

	fclose(source);
	source=0l;
}

int qsort_cmp(NAMES **n1,NAMES **n2)
{
int cmp;

	cmp=strcmp((*n1)->name,(*n2)->name);
	if ( !cmp )
		return (*n1)->count-(*n2)->count;
	return cmp;
}

void write_indizes(void)
	/* 
		schreibe index-seiten
	*/
{
int i,j,k,l;
NAMES **index,*n;
char types[]="FTD";

	for ( i=0; i<3; i++ ) {

		switch ( i ) {
		  case TYPEDEF:
			fputs("@node Typ-Definitionen\n\n",dest);
			fputs("@{B}Typ Definitionen@{b}\n\n",dest);
		  break;
		  case DEFINE:
			fputs("@node PrÑprozessor-Definitionen\n\n",dest);
			fputs("@{B}PrÑprozessor Definitionen@{b}\n\n",dest);
		  break;
		  case FUNCTION:
			fputs("@node Funktionen\n\n",dest);
			fputs("@{B}Funktionen@{b}\n\n",dest);
		  break;
		}

		if ( name_count[i] ) {
			index=calloc(name_count[i],sizeof(*index));
			j=0;
			for ( n=names; n->next!=0; n=n->next ) {
				if ( n->typ==i ) {
					index[j++]=n;
				}
			}
			qsort(index,name_count[i],sizeof(*index),qsort_cmp);
			free(index);
	
			for ( j=0; j<name_count[i]; j++ ) {

				l=24;
				if ( index[j]->unique ) {
					if ( index[j]->count ) {
						l=22;
						fprintf(dest,"@{%s.%d link %s.%d}",index[j]->name,index[j]->count,index[j]->name,index[j]->count);
					}
					else
						fprintf(dest,"@{%s link %s}",index[j]->name,index[j]->name);
				}
				else {
					if ( index[j]->count ) {
						l=21;
						fprintf(dest,"@{%s.%c%d link %s.%c%d}",index[j]->name,types[index[j]->typ],index[j]->count,index[j]->name,types[index[j]->typ],index[j]->count);
					}
					else {
						l=22;
						fprintf(dest,"@{%s.%c link %s.%c}",index[j]->name,types[index[j]->typ],index[j]->name,types[index[j]->typ]);
					}
				}
				if ( !((j+1)%3) )
					fputs("\n",dest);
				else {
					if ( strlen(index[j]->name)<l-2 )
						for ( k=l-(int)strlen(index[j]->name); k>0; k-- )
							fputs(" ",dest);
					else
						fputs("  ",dest);
				}
			}
		}
		else {
			fputs("Keine Eintragungen",dest);
		}
		fputs("\n\n@endnode\n\n",dest);
	}
}

void write_filenames(int first,int last,char *names[])
	/* 
		schreibe dateinamen
	*/
{
char str[256];
int i;

	fputs("@node Source-Files\n\n",dest);
	fputs("@{B}Source Files@{b}\n\n",dest);
	for ( i=first; i<last; i++ ) {
		make_xname(str,names[i]);
		fputs("  @{",dest);
		fputs(str,dest);
		fputs(" link ",dest);
		fputs(str,dest);
		fputs("/Main}\n",dest);
	}
	fputs("\n@endnode",dest);
}

/*
	schreibe hypertext header
*/
void write_header(void)
{
char c,*h;
struct tm *actdate;
time_t acttime;

		/* schreibe database ... */
	fputs("@database \"",dest);
	fputs(database,dest);
	fputs("\"\n",dest);

		/* schreibe $VER... */
	time(&acttime);
	actdate=localtime(&acttime);
	h=strrchr(out_file,'\\');
	if ( !h )
		h=out_file;
	else
		h++;
	fprintf(dest,"@$VER: %s (%d/%d/%d)\n",h,actdate->tm_mday,actdate->tm_mon+1,actdate->tm_year);

		/* kopiere headerdatei */
	source=fopen(header_file,"r");
	if ( source ) {
		c=fgetc(source);
		while ( !feof(source) ) {
			fputc(c,dest);
			c=fgetc(source);
		}
		fclose(source);
		source=0l;
	}
}
int main(int argc,char *argv[])
{
int i,ii;

	printf(	"\nSHelp\n\n  Online-Hilfe zu C-Sourcen mit ST-Guide\n"
			"  V0.9 4.1.1995 (compiliert %s)\n"
			"  written by Th. Morus Walter\n\n"
			,__DATE__
		  );

	if ( argc==1 ) {
		printf(	"Usage   : shelp [Optionen] File[s]\n"
				"Optionen: -d    : doppelte Referenzen jedesmal schreiben (.NR zur Kennung)\n"
				"          -sSIZE: Puffergrîûe fÅr Namen angeben (in Kbyte), Default: 64\n"
				"          -bSIZE: Puffergrîûe fÅr Strukturen/Funktionskîpfe angeben (in Kbyte)\n"
				"                  Default: 16\n"
				"          -hFILE: Headerfile angeben, Default: HEADER.STG\n"
				"          -oFILE: Outputfile angeben, Default: SDOKU.STG\n"
				"          -iTEXT: Database angeben, Default: \"Online-Hilfe zu C-Sourcen\"\n"
				"          -fX   : Funktionsdeklarationen ausgeben\n"
				"          -tX   : Typ-Definitionen (typedef) ausgeben\n"
				"          -pX   : PrÑprozessor Definitionen ausgeben\n"
				"          -aX   : all: AbkÅrzung fÅr -fX -tX -pX\n"
				"			X='' : ohne vorhergehendem Kommentar\n"
				"           X='+': mit vorhergehendem Kommentar\n"
				"           X='*': mit unmittelbar vorhergehendem Kommentar\n"
				"          ist weder -fX noch -tX noch -pX noch -aX gesetzt,\n"
				"          so wird -a* verwendet\n\n"
			  );
		return 1;
	}

	i=1;
	while ( *argv[i]=='-' ) {
		switch ( tolower(argv[i][1]) ) {
		  case 'a': {
		   WRITE_MODE mode;
			mode=WR_NO_COMM;
			if ( argv[i][2]=='+' )
				mode=WR_ALL;
			if ( argv[i][2]=='*' )
				mode=WR_PART_COMM;
			else if ( argv[i][2]!=0 )
				do_error(ERR_OPTIONS);
			write_function=mode;
			write_typedef=mode;
			write_define=mode;
		  } break;
		  case 'f':
			write_function=WR_NO_COMM;
			if ( argv[i][2]=='+' )
				write_function=WR_ALL;
			else if ( argv[i][2]=='*' )
				write_function=WR_PART_COMM;
			else if ( argv[i][2]!=0 )
				do_error(ERR_OPTIONS);
		  break;
		  case 't':
			write_typedef=WR_NO_COMM;
			if ( argv[i][2]=='+' )
				write_function=WR_ALL;
			else if ( argv[i][2]=='*' )
				write_function=WR_PART_COMM;
			else if ( argv[i][2]!=0 )
				do_error(ERR_OPTIONS);
		  break;
		  case 'p':
			write_define=WR_NO_COMM;
			if ( argv[i][2]=='+' )
				write_function=WR_ALL;
			else if ( argv[i][2]=='*' )
				write_function=WR_PART_COMM;
			else if ( argv[i][2]!=0 )
				do_error(ERR_OPTIONS);
		  break;
		  case 's':
			sscanf(argv[i]+2,"%ld",&names_size);
			names_size*=1024;
		  break;
		  case 'b':
			sscanf(argv[i]+2,"%ld",&buf_size);
			buf_size*=1024;
		  break;
		  case 'd':
			dont_write_double=0;
		  break;
		  case 'h':
		    strcpy(header_file,argv[i]+2);
		  break;
		  case 'o':
		    strcpy(out_file,argv[i]+2);
		  break;
		  case 'i':
		    strcpy(database,argv[i]+2);
		  break;
		  default:
			do_error(ERR_OPTIONS);
		  break;
		}
		i++;
		if ( i==argc )
			break;
	}

	if ( i==argc )
		do_error(ERR_NOFILES);

	if ( write_function==WR_NONE && write_typedef==WR_NONE && write_define==WR_NONE )
		write_function=write_typedef=write_define=WR_PART_COMM;

	names=malloc(names_size);
	if ( !names )
		do_error(ERR_MEMORY);

	next=names;
	next->next=0l;

	dest=fopen(out_file,"w");
	if ( !dest )
		do_error(ERR_FILE);

		/* schreibe/kopiere header */
	printf("erzeuge Header\n");
	write_header();

		/* bearbeite source-dateien */
	for ( ii=i; ii<argc; ii++ ) {
		printf("bearbeite %s\n",argv[ii]);
		do_file(argv[ii]);
	}

		/* schreibe index-seiten */
	printf("schreibe Indexseiten\n");
	write_indizes();

		/* schreibe dateiliste */
	printf("schreibe Dateiliste\n\n");
	write_filenames(i,argc,argv);

	fclose(dest);
	free(names);

	return 0;
}
