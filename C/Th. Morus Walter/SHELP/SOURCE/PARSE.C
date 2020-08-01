/*
	parse.c
		source-code fÅr PureC 1.0
	written by Th. Morus Walter

	v0.9		 5. 1.1995
*/
#include "shelp.h"

TEXT_PUFFER puffer;

/*
	Åberlese spaces in 'str' unter beachtung von kommentaren 
	dir: 1 -> von vorne, -1 -> von hinten
	lese maximal bis 'ende' oder 0-byte
		ende kann 0l sein! (fÅr rÅckwÑrts gedacht!)
*/
static char *skip_spaces(char *str,char *ende,int dir)
{
char *s;
enum {
	R_READ,
	R_COMM_1,
	R_COMM_2,
	R_COMM_3,
} mode=R_READ;
int com_cnt=0;

	if ( dir!=1 && dir!=-1 )
		return str;

	s=str;

	do {
		switch ( mode ) {
		  case R_READ:
			if ( *s=='/' )
				mode=R_COMM_1;
			else if ( !isspace(*s) )
				return s;
		  break;
				/* lese kommentar */
		  case R_COMM_1:
		  	if ( *s=='*' ) {
		  		com_cnt++;
		  		mode=R_COMM_2;
			}
		  	else {
		  		if ( com_cnt )
		  			mode=R_COMM_2;
				else if ( *s=='/' )
					mode=R_COMM_1;
				else if ( !isspace(*s) )
					return s;
		  		else
			  		mode=R_READ;
			}
		  break;
		  case R_COMM_2:
		  	if ( *s=='*' )
		  		mode=R_COMM_3;
			else if ( *s=='/' )
				mode=R_COMM_1;
		  break;
		  case R_COMM_3:
			if ( *s=='/' ) {
				com_cnt--;
				if ( com_cnt==0 )
					mode=R_READ;
				else
					mode=R_COMM_2;
			}
			else if ( *s!='*' )
				mode=R_COMM_2;
		  break;
		}
		s+=dir;
		if ( *s==0 || (ende && s==ende) )	/* textende */
			return s;
		
	} while ( 1 );
}

/*
	ermittle namen einer typedef angabe:
		zwei mîglichkeiten: typedef ... name;
							typedef ... (*name)(...);	(zeiger auf funktion)
*/
static char *get_typedef_name(TEXT_PUFFER *puffer)
{
char *h;
int something=0;

	h=puffer->write-1;
	while ( h>puffer->textstart && (!something || !isspace(*h)) ) {
		h=skip_spaces(h,puffer->textstart,-1);
		if ( *h==')' )
			break;
		if ( isalnum(*h) || *h=='_' )
			something=1;
		if ( something && isspace(*h) )
			break;
		h--;
	}
	if ( *h==')' ) {			/* typedef ... (*name)(...); */
		h=puffer->textstart+7;	/* typedef Åbergehen */
		do {
			h=skip_spaces(h,0l,1);
		} while ( *h++!='(' );
		h=skip_spaces(h,0l,1);
		if ( *h=='*' )
			h=skip_spaces(h+1,0l,1);
	}

	while ( !isalpha(*h) && *h!='_' )
		h++;

	return h;
}

static void found_typedef(TEXT_PUFFER *puffer,int line)
{
	puffer->typ=TYPEDEF;
	puffer->name=get_typedef_name(puffer);
	write_item(puffer);
}

/*
	ermittle funktionsnamen

		Åberliest rÅckwÑrts die Parameterliste
		nimmt ersten folgenden namen
*/
static char *get_fu_name(TEXT_PUFFER *puffer)
{
char *h;
enum {
	FU_READ,
	FU_COM1,
	FU_COM2,
	FU_COM3,
	FU_NAME,
	FU_NAME2,
} mode=FU_READ;
int com_cnt=0,klammer=0;
int exit=0;

	h=puffer->write-2;
	do {
		switch ( mode ) {
		  case FU_READ:
		  	if ( *h=='/' )
		  		mode=FU_COM1;
			else if ( *h==')' ) {
				klammer++;
			}
			else if ( *h=='(' ) {
				klammer--;
				if ( !klammer ) {
					h=skip_spaces(h-1,puffer->textstart,-1);
					mode=FU_NAME;
				}
			}
			else if ( !klammer && *h=='=' ) {
				return 0l;
			}
		  break;
		  case FU_COM1:
		  	if ( *h=='*' ) {
		  		com_cnt++;
		  		mode=FU_COM2;
		  	}
		  	else {
		  		if ( com_cnt )
					mode=FU_COM2;
		  		else
			  		mode=FU_READ;
			}
		  break;
		  case FU_COM2:
		  	if ( *h=='/' )
		  		mode=FU_COM1;
		  	else if ( *h=='*' )
		  		mode=FU_COM3;
		  break;
		  case FU_COM3:
		  	if ( *h=='/' ) {
		  		com_cnt--;
		  		if ( !com_cnt )
		  			mode=FU_READ;
		  		else
		  			mode=FU_COM2;
		  	}
		  	else if ( *h!='*' )
			  	mode=FU_COM2;
		  break;
		  case FU_NAME:
		  	if ( *h=='=' )
		  		return 0l;
		  	else if ( !isspace(*h) )
		  		mode=FU_NAME2;
		  break;
		  case FU_NAME2:
		  	if ( !isalnum(*h) && *h!='_' )
		  		return h+1;
		  break;
		}
		h--;
	} while ( !exit && h>=puffer->textstart );
	return puffer->textstart;
}

static void found_function(TEXT_PUFFER *puffer,int line)
{
	puffer->typ=FUNCTION;
	puffer->name=get_fu_name(puffer);
	if ( !puffer->name )
		return;		/* keine funktion */
	if ( (!strncmp(puffer->name,"enum",4) && isspace(puffer->name[4])) ||
		(!strncmp(puffer->name,"struct",6) && isspace(puffer->name[6])) ||
		(!strncmp(puffer->name,"static",6) && isspace(puffer->name[6])) ||
		(!strncmp(puffer->name,"extern",6) && isspace(puffer->name[6])) 
	)
		return;		/* war wohl doch nix, scheiss syntax */

	write_item(puffer);
}

/*
	define-anweisung
*/
static void found_praeproc(TEXT_PUFFER *puffer,int line)
{
char *c;

	c=puffer->textstart+1;	/* # Åberlesen */
	c=skip_spaces(c,0l,1);
	if ( strncmp(c,"define",6) )
		return;
	c+=6;
	
	c=skip_spaces(c,0l,1);

	puffer->typ=DEFINE;
	puffer->name=c;
	write_item(puffer);
}

/*
	pufferverwaltung
*/
/*
	init puffer
*/
static void init_puffer(TEXT_PUFFER *puffer)
{
	puffer->len=buf_size;
	puffer->start=malloc(buf_size);
	puffer->copy_mode=C_EMPTY;
	if ( !puffer->start )
		do_error(ERR_MEMORY);
}
/*
	exit puffer
*/
static void exit_puffer(TEXT_PUFFER *puffer)
{
	free(puffer->start);
	puffer->start=0l;
}
/*
	setze lesemodus fÅr puffer
*/
static void set_puffer(TEXT_PUFFER *puffer,COPY_MODE mode,int line)
{
	if ( puffer->copy_mode==C_EMPTY || (mode==C_COMM && puffer->copy_mode==C_COMM) ) {
		puffer->write=puffer->start;
		puffer->start_line=line;
	}
	if ( puffer->copy_mode!=C_TEXT ) {
		if ( mode==C_TEXT ) {
			puffer->textstart=puffer->write;
			puffer->text_line=line;
		}
		puffer->copy_mode=mode;
	}
}
/*
	kopiere zeichen in puffer
*/
static void copy_char(TEXT_PUFFER *puffer,char c)
{
	if ( puffer->write-puffer->start<puffer->len )
		*puffer->write++=c;
	else
		do_error(ERR_BUFFER);
}

static void close_puffer(TEXT_PUFFER *puffer,char c)
{
	*puffer->write++=c;
	*puffer->write=0;
	puffer->copy_mode=C_EMPTY;
}

typedef enum {
	M_READ_NL,
	M_READ_SPACE,
	M_READ,
	M_COMM_1,
	M_COMM_2,
	M_COMM_3,
	M_STRING,
	M_STRING2,
	M_CHARACTER,
	M_CHARACTER2,
	M_BLOCK,
} PARSE_MODE;

#define in_string(mode)	((mode)==M_STRING || (mode)==M_STRING2)
#define in_char(mode)	((mode)==M_CHARACTER || (mode)==M_CHARACTER)
#define is_newline(mode) ((mode)==M_READ_NL)
#define is_space(mode) 	((mode)==M_READ_NL || (mode)==M_READ_SPACE)
#define is_read(mode) 	((mode)==M_READ)

static int com_cnt=0;		/* verschachtelte kommentare */
/*
	ermittle fÅr gelesenen text ob
		kommentar
		string-konstate
		character-konstante
	vorliegt
*/
static PARSE_MODE preparse(PARSE_MODE mode,char c)		
{

	switch ( mode ) {

			/* lese trennzeichen */
	  case M_READ_NL:
	    if ( isspace(c) )
			break;

		/* else KEIN break !!! */
	  case M_READ_SPACE:
		if ( !isspace(c) ) {
			mode=M_READ;
			/* KEIN break !!! */
		}
		else {
			if ( c=='\n' )
				mode=M_READ_NL;
			break;
		}

			/* lese text */
	  case M_READ:
		if ( c=='\n' )
			mode=M_READ_NL;
		else if ( c=='/' )		/* kommentar kînnte anfangen */
			mode=M_COMM_1;
		else if ( c=='"' )		/* string fÑngt an */
			mode=M_STRING;
		else if ( c=='\'' )		/* char-const */
			mode=M_CHARACTER;
	  break;

			/* lese kommentar */
	  case M_COMM_1:
	  	if ( c=='*' ) {
	  		com_cnt++;
	  		mode=M_COMM_2;
		}
	  	else {
	  		if ( com_cnt )
	  			mode=M_COMM_2;
			else if ( c=='"' )
				mode=M_STRING;
			else if ( c=='/' )
				mode=M_COMM_1;
			else if ( isspace(c) )
				mode=M_READ_SPACE;
	  		else
		  		mode=M_READ;
		}
	  break;
	  case M_COMM_2:
	  	if ( c=='*' )
	  		mode=M_COMM_3;
		else if ( c=='/' )
			mode=M_COMM_1;
	  break;
	  case M_COMM_3:
		if ( c=='/' ) {
			com_cnt--;
			if ( com_cnt==0 )
				mode=M_READ_SPACE;
			else
				mode=M_COMM_2;
		}
		else if ( c!='*' )
			mode=M_COMM_2;
	  break;

			/* lese string */
	  case M_STRING:
	  	if ( c=='\\' )
	  		mode=M_STRING2;
		else if ( c=='"' )
			mode=M_READ;
	  break;
	  case M_STRING2:
		mode=M_STRING;
	  break;

			/* lese char-const */
	  case M_CHARACTER:
	  	if ( c=='\\' )
	  		mode=M_CHARACTER2;
	  	else if ( c=='\'' )
	  		mode=M_READ;
	  break;
	  case M_CHARACTER2:
	  	mode=M_CHARACTER;
	  break;
	}
	return mode;
}

/*
	zÑhle fÅr do_parse die schachtelungstiefe der { } blîcke
*/
static int block_parse(int bcount,PARSE_MODE mode,char c)
{
	if ( is_read(mode) ) {
		if ( c=='{' )
			bcount++;
		else if ( c=='}' )
			bcount--;
	}
	return bcount;
}

/*
	lese quelltext

	zerlege in blîcke
	schreibe blîcke in puffer
	falls block
		funktions-definition
		typ-definition
		praeprozessor-anweisung
	-> Åbergebe block an found_...()
	EIN kommentar vor definition wird mitÅbergeben!

	FEHLER: erkennt  keine typedefs in funktionen (erlaubt???)
					 keine #defines in {} von typedefs (erlaubt!!!)
			'void function(void)
			 #define xyz
			 {...
			' wird sicher nicht richtig behandelt!!!
*/
void do_parse(FILE *source)
{
char c;
PARSE_MODE mode,old;

int line=1;
int xline;

enum {
	S_SCAN,
	S_DEFINE,
	S_TYPEDEF,
} scanfor=S_SCAN;
int bcount=0;
int old_cnt;

	com_cnt=0;
	init_puffer(&puffer);

	mode=M_READ_NL;

	do {
		c=fgetc(source);
		if ( c=='\n' )
			line++;

		old=mode;
		old_cnt=com_cnt;
		mode=preparse(mode,c);

		switch ( scanfor ) {
		  case S_SCAN:
			if ( com_cnt==1 && !old_cnt ) {		
												/* kommentar hat angefangen */
				if ( puffer.copy_mode!=C_TEXT ) {
					set_puffer(&puffer,C_COMM,line);	/* protokollieren */
					copy_char(&puffer,'/');
				}
				break;
			}
			else if ( com_cnt )
				break;
			else if ( is_newline(old) && c=='#' ) {
				scanfor=S_DEFINE;
				set_puffer(&puffer,C_TEXT,line);
				xline=line;
				/* kein BREAK */
			}
			else if ( puffer.copy_mode==C_COMM && bcount && !isspace(c) ) {
				close_puffer(&puffer,0);
				break;
			}
			else {
				if ( !bcount ) {
					if ( puffer.copy_mode!=C_TEXT && is_space(old) && 
							(isalpha(c) || c=='_') ) {
						set_puffer(&puffer,C_TEXT,line);
					}
					if ( is_read(mode) && (c==';' || c=='{') ) {	/* } */
						if ( c==';' && !strncmp(puffer.textstart,"typedef",7) ) {
							close_puffer(&puffer,c);
							found_typedef(&puffer,line);
						}
						else if ( !strncmp(puffer.textstart,"typedef",7) ) {
							scanfor=S_TYPEDEF;
						}
						else if ( c=='{' ) 	/* } */ {
							close_puffer(&puffer,0);
							found_function(&puffer,line);
						}
						else {
							close_puffer(&puffer,c);
						}
					}
				}
				break;
			}
		  case S_DEFINE:
			if ( !com_cnt && xline!=line ) {
				close_puffer(&puffer,c);
				found_praeproc(&puffer,line);
				scanfor=S_SCAN;
			}
		  break;
		  case S_TYPEDEF:
			if ( is_read(mode) && c==';' && bcount==0 ) {
				close_puffer(&puffer,c);
				found_typedef(&puffer,line);
				scanfor=S_SCAN;
			}
		  break;
		}

		if ( puffer.copy_mode )
			copy_char(&puffer,c);

		bcount=block_parse(bcount,mode,c);

	} while ( !feof(source) );

	exit_puffer(&puffer);
	return;
}
