/*

CKBD file format
----------------

* plain ASCII (8 bit)

* basic (scanner) datatypes are:
	Terminal symbols:
		Keywords 	following identifier rules
		Delimiters	. , : { [ ( ) ] }
		Operators	+ - * / ^ % & | 

	Constants:
		Real		-1.23e-4
		Integer		123
		Hexadecimal	$FF
		String		"string"	or 'string'



* Example:

NAME 'Bollocks'

SWITCHES
	COMPOSE ON/OFF,DEC_MODE/MULTICHAR/AUTOMULTI,ORDER/NOORDER
	DEADKEY ON/OFF,string
	EXTKEY  ON/OFF
	ALT_NNN  ON/OFF
	TABLE_APPLIES_TO NONE/KEYBOARD/COMPOSE/BOTH


KBTAB_NORMAL				;Data is read straight into the 128 byte tables
	27,'1234567890-=',8		;an example of constant data
	'QWERTYUIOP'


KBTAB_SHIFT
	...up to 128 bytes of data...


KBTAB_CAPSLOCK
	...up to 128 bytes of data...


KBTAB_COMPOSE				; data is read straight into the compose table
	{ '"aä' }				; entries in { } are padded to 4 bytes
	{ 50,70,90,ORDER+(NO)AUTOMULTI }
	{ <3 bytes of data>,<optional_flags> }	

END							; ends file read
*/


/*==========================================================================*/


#define EXTERN extern

#include <vdi.h>
#include <aes.h>
#include <portab.h>

#include "CKBD.H"

#include "scanner.h"


#define ccolumn ((long)(lineptr-line)+1L)
#define sym symbol.token

#define MAX_COMPTAB_ENTRIES		255		/* valid entries */
#define MAX_DEADKEYS			15		/* valid deadkeys */


/*==========================================================================*/


/*==========================================================================*/
/* bitmapped stuff and other ckbd driver related defs 						*/
/*==========================================================================*/
#define CKB_INQUIRE			-1
#define CKB_OFF				0
#define CKB_ON				1
#define CKB_SET				2

#define CKB_ORDERSENSITIVE	0x02
#define CKB_MULTICHAR		0x04		/* enable multicharacter mode */
#define CKB_IMPLICIT		0x08		/* enable implicit (AUTO) mode */

#define CKB_NONE			0x00		/* table applies to what ? */
#define CKB_KEYBOARD		0x01
#define CKB_COMPOSE			0x02

/* compose table flags */
#define CKB_ORDER			0x01		/* order sensitive flag */
#define CKB_AUTOMULTI		0x02		/* seq may trigger auto-multi mode */


#define MAXTABLENAMELENGTH		16		/* length of the table name */



/*==========================================================================*/
/* function prototypes, internal											*/
/*==========================================================================*/
void			interprete_file(void);
void			interprete_switches(void);
void			interprete_kbtab(int table);
void			interprete_composetab(void);
unsigned long	interprete_composetabentry(void);


/* global vars */

long	error_counter;
FILE	*inputfile;

extern interface	*ckbd;					/* cookie aufruf */
extern struct safe {
	char	loadfile[128];			/* welche Datei wird geladen!? */
	short	filetype;				/* 0 none, 1 KBD, 2 CKB */
	short	extkey, compose, alt_nnn, deadkey;
	short	mapping;				/* cfg data for those fn's */
	short	language;
	char	keys[16];				/* deadkeys */
} save_vars;
 
/*==========================================================================*/
/* Data structure holding the 'compiled' file 								*/
/*==========================================================================*/
struct {
	char tabname[MAXTABLENAMELENGTH];		/* tab name */
	struct {
		short int	compose,				/* config switches */
					deadkey,
					extkey,
					alt_nnn,
					tablevalid;
	} switches;
	unsigned char	unshift[128],			/* kbd translation tables */
					shift[128],
					caps[128],
					deadkeys[20];
	struct {
		unsigned char 
					*unshift,
					*shift,
					*caps;
		unsigned long
					*compose;
	} available;
											/* Composed characters table */
	unsigned long composetable[MAX_COMPTAB_ENTRIES+1];
} ckb;

/*==========================================================================*/
/* error msgs																*/
/*==========================================================================*/
/*
 * error output function
 *
 * param:	string ptr to message. Null ptr or empty string = no message
 *
 * usage:	same as printf().
 */
void syntax_error(char *msg, ...)
{
	va_list	vptr;

	if (msg!=NULL && *msg)
	{
		error_counter++;
		va_start(vptr, msg);
		/* printf("**ERROR Line %ld, Col %ld: ", cline, ccolumn); */
		printf("ERROR Line %ld: ", cline);
		vprintf(msg, vptr);
		printf("\n");
		va_end(vptr);
	}
}


void internal_error(char *msg)
{
	if (msg!=NULL)
	{
		error_counter++;
		printf("INTERNAL ERROR: %s.\n", msg);
	}
}



/*==========================================================================*/
/* data handling															*/
/*==========================================================================*/

/*
 * clear_ckbtable()
 *	set up the ckb structure
 */
void clear_ckbtable(void)
{
	ckb.tabname[0]=NUL;

	ckb.switches.compose = Compose(INQUIRE);
	ckb.switches.deadkey = Deadkey(INQUIRE, ckb.deadkeys);
	ckb.switches.extkey  = Extkey(INQUIRE);
	ckb.switches.alt_nnn = Alt_nnn(INQUIRE);

	ckb.available.unshift=NULL;
	ckb.available.shift=NULL;
	ckb.available.caps=NULL;
	ckb.available.compose=NULL;

	ckb.composetable[0]=0L;
}


/*
 * read_ckb: read a CKB file, parse it and install it.
 *
 */
BOOL read_ckb(void)
{
	BOOL	retval=FALSE;
	scanner_init();							/* prepare scanner */
	
	inputfile = fopen(save_vars.loadfile, "r");			/* open input file */
	if (inputfile!=NULL)
	{
		interprete_file();
		if (error_counter) 
			puts("There were errors. File not accepted.");
			/* form_alert(1, say(WRONGFILEFORMAT)); */
		else
		{
			/* file is correct, use data */
			Ckeytbl(ckb.available.unshift, ckb.available.shift,
					ckb.available.caps, ckb.available.compose,
					ckb.tabname );
			Compose(ckb.switches.compose);
			Deadkey(ckb.switches.deadkey, ckb.deadkeys);
			Extkey(ckb.switches.extkey);
			Alt_nnn(ckb.switches.alt_nnn);
			save_vars.filetype=2;
			retval=TRUE;
		}
		fclose(inputfile); inputfile=NULL;		
	}

	scanner_exit();				/* leave scanner */
	return retval;
}


/* 
 * ReadLine()
 *	read a single line, called by the scanner.
 */
int ReadLine(char *buf, size_t nchars)
{
	if (inputfile && fgets(buf, (int)nchars, inputfile) ) return 1;
	else return 0;
}



/*==========================================================================*/
/* parser section: interprete the ckb file									*/
/*==========================================================================*/

/*
 * Special get_symbol:
 *
 */
void getsym(void)
{
	get_symbol();
	if (sym==S_SEMICOLON) flushline();		/* ignore comments */
}


/*
 * interprete_file()
 *		interpreter entry point.
 *
 *		No symbols have been read yet.
 */
void interprete_file(void)
{
	int go_ahead = TRUE;

	clear_ckbtable();

	error_counter = 0;					/* global errorcounter */

	getsym();							/* read the first symbol */

	do {
		switch (sym)
		{
		case NEWLINE:
			getsym();					/* newline: empty line, read next sym */
		case EOS:
			break;						/* no further action, loop aborts */

		case K_NAME:					/* define the table name */
			get_symbol();
			if (sym==STRINGCONST)
			{
				if (strlen(symbol.name)>MAXTABLENAMELENGTH)
					syntax_error("Table name too long, truncating");
				strncpy(ckb.tabname,symbol.name,MAXTABLENAMELENGTH);
				ckb.tabname[MAXTABLENAMELENGTH+1]=NUL;
			}
			else
				syntax_error("Table name expected");
			get_symbol();
			break;

		case K_SWITCHES:				/* define the switches */
			interprete_switches();
			break;

		case K_KBTAB_NORMAL:			/* load the kbd tables */
			interprete_kbtab(0);
			break;

		case K_KBTAB_SHIFT:
			interprete_kbtab(1);
			break;

		case K_KBTAB_CAPSLOCK:
			interprete_kbtab(2);
			break;

		case K_KBTAB_COMPOSE:			/* load the compose table */
			interprete_composetab();
			break;

		case K_END:						/* accept file */
			getsym();				/* read next sym (NEWLINE) */
			/* check_ckbtable(); */
			go_ahead = FALSE;
			break;
		
		default:
			syntax_error("Unexpected symbol %s\n", symbol.name);
			flushline();
			break;
		};

	} while (go_ahead && sym!=EOS);

	if (go_ahead) syntax_error("END statement missing");

}


	
/* 
 * interprete_switches()
 *		Reads the various switch options.
 *		switches are specified on one single line. 
 *
 * Param:	none
 * Return:	none
 *
 * Prerequisites:
 *			Parser must be in the switch section of the file.
 * Global:	next symbol is already read. (due to lookahead)
 *
 */
void interprete_switches(void)
{
	int		i = 0;
	char	*p;
	char	*e_parameter = "Bad or missing switch option";


	do {
		getsym();
		switch (sym)
		{
		case NEWLINE:					/* empty line... */
			break;
	
		case K_COMPOSE:
			do {
				getsym();				/* read next sym (should be a parameter) */
				if (sym==K_ON)
					ckb.switches.compose |= CKB_ON;
				else if (sym==K_OFF)
					ckb.switches.compose &= ~CKB_ON;
				else if (sym==K_DEC_MODE)
					ckb.switches.compose &= ~(CKB_MULTICHAR|CKB_IMPLICIT);
				else if (sym==K_MULTICHAR) {
					ckb.switches.compose |= CKB_MULTICHAR;
					ckb.switches.compose &= ~CKB_IMPLICIT;
				}
				else if (sym==K_AUTOMULTI)
					ckb.switches.compose |= (CKB_MULTICHAR|CKB_IMPLICIT);
				else if (sym==K_ORDER)
					ckb.switches.compose |= CKB_ORDERSENSITIVE;
				else if (sym==K_NOORDER)
					ckb.switches.compose &= ~CKB_ORDERSENSITIVE;
				else {
					syntax_error(e_parameter);
					flushline();
					break;						/* leave parsing loop */
				};
	
				getsym();

				/* optional comma indicates that another switch option follows */
			} while (sym==S_COMMA);
	
			/* symbol other than a comma read */
			break;
	
		case K_DEADKEY:
			i=0;
			do {
				getsym();
				if (sym==K_ON)
					ckb.switches.deadkey |= CKB_ON;
				else if (sym==K_OFF)
					ckb.switches.deadkey &= ~CKB_ON;
				else if (sym==INTEGERCONST)
				{
					if (i<MAX_DEADKEYS)
						ckb.deadkeys[i++]=(unsigned char)atoi(symbol.name);
				}
				else if (sym==BINCONST)
				{
					if (i<MAX_DEADKEYS)
						ckb.deadkeys[i++]=(unsigned char)strtol(symbol.name, NULL, 2);
				}
				else if (sym==HEXCONST)
				{
					if (i<MAX_DEADKEYS)
						ckb.deadkeys[i++]=(unsigned char)strtol(symbol.name, NULL, 16);
				}
				else if (sym==STRINGCONST)
				{
					p=symbol.name;
					while (*p && i<MAX_DEADKEYS)
						ckb.deadkeys[i++]=*p++;
				}
	
				getsym();			/* read next symbol */
			} while (sym==S_COMMA);
			ckb.deadkeys[i]=NUL;
			break;
	
		case K_EXTKEY:
			getsym();
			if (sym==K_ON)
				ckb.switches.extkey |= CKB_ON;
			else if (sym==K_OFF)
				ckb.switches.extkey &= ~CKB_ON;
			else
				syntax_error(e_parameter);
			getsym();			/* read next symbol */
			break;
	
		case K_ALT_NNN:
			getsym();
			if (sym==K_ON)
				ckb.switches.extkey |= CKB_ON;
			else if (sym==K_OFF)
				ckb.switches.extkey &= ~CKB_ON;
			else
				syntax_error(e_parameter);
			getsym();			/* read next symbol */
			break;
	
		case K_TABLE_APPLIES_TO:
			do {
				getsym();
				if (sym==K_NOTHING)
					ckb.switches.tablevalid = CKB_NONE;
				else if (sym==K_KEYBOARD)
					ckb.switches.tablevalid = CKB_KEYBOARD;
				else if (sym==K_COMPOSE)
					ckb.switches.tablevalid = CKB_COMPOSE;
				else if (sym==K_BOTH)
					ckb.switches.tablevalid = CKB_KEYBOARD|CKB_COMPOSE;
				else {
					syntax_error(e_parameter);
					break;
				};
				getsym();
			} while (sym==S_COMMA);
			break;
		};
	} while (sym==NEWLINE);
}



/*
 * interprete_kbtab
 *		reads a keyboard table.
 *
 * Param:	Number of the kbd tranlation table to store data into.
 *			(0=normal, 1=shifted, 2=capslock table)
 *
 * Return:	none
 *
 * Prerequisites:
 *			Last read symbol was K_KBTAB_xxx
 * Global:	next  symbol is already read. (due to lookahead)
 *
 */
void interprete_kbtab(int table)
{
	int				nbyte;
	unsigned char	*comptab, *p;

	nbyte=0;					/* table offset, 0 to 127 */
	if (table==0) comptab=ckb.unshift;
	else if (table==1) comptab=ckb.shift;
	else if (table==2) comptab=ckb.caps;
	else {
		internal_error("Illegal table specified");
		return;
	}

	do {
		getsym();
		switch (sym)
		{
		case NEWLINE:
			break;

		case INTEGERCONST:
			if (nbyte<128)
				comptab[nbyte] = (unsigned char)atoi(symbol.name);
			nbyte++;
			getsym();
			break;

		case HEXCONST:
			if (nbyte<128)
				comptab[nbyte] = (unsigned char)strtol(symbol.name,NULL,16);
			nbyte++;
			getsym();
			break;

		case BINCONST:
			if (nbyte<128)
				comptab[nbyte] = (unsigned char)strtol(symbol.name,NULL,2);
			nbyte++;
			getsym();
			break;

		case STRINGCONST:
			if (nbyte<128)
			{
				p = symbol.name;
				while (*p && nbyte<128)  comptab[nbyte++] = *p++;
			}
			else nbyte++;
			getsym();
			break;
		};

		/* continue as long as COMMA and NEWLINE separators are read */
	} while (sym==NEWLINE || sym==S_COMMA);

	/* table should be filled up now. Check size. */
	if (nbyte<128) {
		syntax_error("KBD translation table less than 128 bytes");
	}
	else if (nbyte>128) {
		syntax_error("KBD translation table exceeds 128 bytes");
	}
	else
	{
		if (table==0)		ckb.available.unshift=ckb.unshift;
		else if (table==1)	ckb.available.shift=ckb.shift;
		else if (table==2)	ckb.available.caps=ckb.caps;
	}
}



/*
 * interprete_composetab()
 *		read a compose table.
 *		Format is:	entry [ { , entry } ]
 *			with entry being: 
 *
 *
 */
void interprete_composetab(void)
{
	unsigned long comptabentry;
	int		tabindex;

	tabindex=0;

	do {
		/* read a single table entry */
		comptabentry = interprete_composetabentry();

		/* store it if possible */
		if (comptabentry && tabindex<MAX_COMPTAB_ENTRIES)
			ckb.composetable[tabindex] = comptabentry;

		/* always count number of entries */
		if (comptabentry) tabindex++;

		/* continue as long as COMMA and NEWLINE separators are read */
	} while (sym==NEWLINE || sym==S_COMMA);

	if (tabindex<MAX_COMPTAB_ENTRIES)
		ckb.composetable[tabindex] = 0L;
	else {
		syntax_error("Too many compose table entries");
		ckb.composetable[MAX_COMPTAB_ENTRIES] = 0L;
	}
	ckb.available.compose = ckb.composetable;
}



/*
 * interprete_composetabentry()
 *		read a single compose table entry.
 *		Format is "{" 3_bytes_of_data [ , flags ] "}"
 * 
 * Param:	none
 * Return:	compose sequence longword if syntax was correct.
 *
 * Global:	next symbol is read.
 *
 */
unsigned long interprete_composetabentry(void)
{
	char	entry[4], *p;
	int		nbyte, flags;
	unsigned long retval;

	static char *e_needmoredata="Incomplete compose sequence";

	flags=0; nbyte=0; retval=0L;

	getsym();
	if (sym==S_LBRACE)
	{
		/* read entry data */
		do {
			getsym();
			switch (sym)
			{
			case INTEGERCONST:
				if (nbyte<3)
					entry[nbyte] = (unsigned char)atoi(symbol.name);
				nbyte++;
				break;

			case HEXCONST:
				if (nbyte<3)
					entry[nbyte] = (unsigned char)strtol(symbol.name,NULL,16);
				nbyte++;
				break;

			case BINCONST:
				if (nbyte<3)
					entry[nbyte++] = (unsigned char)strtol(symbol.name,NULL,2);
				nbyte++;
				break;

			case STRINGCONST:
				if (nbyte<3) {
					p = symbol.name;
					while (*p && nbyte<3)  entry[nbyte++] = *p++;
				}
				else nbyte+=(int)strlen(symbol.name);
				break;

			/* Flag to enable AUTOMULTI mode for this sequence */
			case K_AUTOMULTI:
				if (nbyte<3) syntax_error(e_needmoredata);
				flags |= CKB_AUTOMULTI;
				break;

			case K_NOAUTOMULTI:
				if (nbyte<3) syntax_error(e_needmoredata);
				flags &= ~CKB_AUTOMULTI;
				break;

			case K_ORDER:
				if (nbyte<3) syntax_error(e_needmoredata);
				flags |= CKB_ORDER;
				break;

			case K_NOORDER:
				if (nbyte<3) syntax_error(e_needmoredata);
				flags &= ~CKB_ORDER;
				break;

			default:
				if (nbyte<3)
					syntax_error("Bad data type, constant expected");
				else
					syntax_error("Bad data type, FLAG word expected");
				break;
			}
			getsym();
		} while (sym==S_COMMA);

		/* expect } to close an entry */
		if (sym==S_RBRACE)
		{
			if (nbyte<3)
				syntax_error("Not enough data (must be 3 bytes)");
			else {
			/* everything was correct, return the long word */
				retval	= (entry[0] << 24)	| (entry[1] << 16)
						| (entry[2] << 8)	| (flags & 0xFF) ;
			}
			getsym();
		}
		else
		{
			syntax_error("closing brace '}' expected");
			flushline();
		}
	}
	return retval;
}

/*==========================================================================*/
/* eof 																		*/
/*==========================================================================*/

