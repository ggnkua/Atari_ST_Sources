/****************************************************************/
/*	Translate characters in a file				*/
/*								*/
/*	By David Megginson, 1991				*/
/*	Released into the public domain.			*/
/*								*/
/*	Command line options:					*/
/*		-c	use the complement of the characters	*/
/*		-d	delete the given characters		*/
/*		-s	squeeze repeated instances		*/
/*	(count everything by default)				*/
/*								*/
/*	Makefile options:					*/
/*		-DBUFFER_SIZE=n		Read n bytes at a time	*/
/*		-DCHARSET_SIZE=n	Character set size	*/
/*		-DSKIP_CR		Ignore carriage returns	*/
/****************************************************************/


/* $Id: tr.c,v 1.2 1991/03/05 09:01:38 david Exp david $ */

/*
 * $Log: tr.c,v $
 * Revision 1.2  1991/03/05  09:01:38  david
 * Changed `static version' to `static char * version' (duh!)
 *
 * Revision 1.1  1991/03/05  08:58:44  david
 * Initial revision
 *
 */

static char * version = "$Id: tr.c,v 1.2 1991/03/05 09:01:38 david Exp david $";


#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

/* The string of legal options for getopt			*/

#define	OPTSTRING	"cds"

/* The size of the character set in use. Allow the Makefile	*/
/* to override this, if desired.				*/

#ifndef	CHARSET_SIZE
#define	CHARSET_SIZE	256
#endif

/* The translation table					*/

char table[CHARSET_SIZE];

/* The combined size of the buffers. Allow the user to define	*/
/* this in the Makefile if desired.				*/

#ifndef	BUFFER_SIZE
#define	BUFFER_SIZE	50000L
#endif

/* Use these buffers to do the translation			*/

static char buffer1[BUFFER_SIZE/2];
static char buffer2[BUFFER_SIZE/2];

/* Command line options						*/

#define	OPTSTRING	"cds"

/* Command line flags						*/

static int c_flag = 0;
static int d_flag = 0;
static int s_flag = 0;

/* getopt() stuff						*/

extern int optind;

/* Local functions */

static void parse_string( const char * string );
static void parse_strings( const char * string1,const char * string2 );
static void expand_string( const char * string,char * buffer );
static void do_delete( void );
static fpos_t delete_between_buffers( fpos_t count );
static void do_translate( void );
static fpos_t translate_between_buffers( fpos_t count );
static void usage( void );


main( int ac,const char ** av )
{
	int opt;

	/* Register the options				*/
	
	opt = getopt(ac,av,OPTSTRING);
	while( opt != EOF ) {
		switch( opt ) {

		case 'c':	/* complement	*/
			c_flag = 1;
			break;
		case 'd':	/* delete	*/
			d_flag = 1;
			if( s_flag ) {
				fprintf(stderr,"%s: -d and -s conflict\n",
						av[0]);
				exit(2);
			}
			break;
		case 's':	/* squeeze	*/
			s_flag = 1;
			if( d_flag ) {
				fprintf(stderr,"%s: -d and -s conflict\n",
						av[0]);
				exit(2);
			}
			break;
		}

		opt = getopt(ac,av,OPTSTRING);
	}

	/* If the -d option is given, we need only	*/
	/* one string; otherwise, we need two.		*/
	
	if( d_flag ) {
		if( optind != ac - 1 ) {
			usage();
			exit(2);
		}
		parse_string(av[optind]);
		do_delete();
	} else {
		if( optind != ac - 2 ) {
			usage();
			exit(2);
		}
		parse_strings(av[optind],av[optind+1]);
		do_translate();
	}

	return 0;
}


/*******
	Parse a single command-line string.

	Arguments:	const char * string
	Return value:	none
*******/

static void
parse_string( const char * string )
{
	int x,def,special;
	char * ptr;

	/* If the complement flag is set, flag everything	*/
	/* in the table except the contents of the string;	*/
	/* otherwise, flag only the contents of the string.	*/
	
	if( c_flag ) {
		def = 1;
		special = 0;
	} else {
		def = 0;
		special = 1;
	}

	/* Set the whole table to the default setting.		*/
	
	for( x = 0; x < CHARSET_SIZE; x++ )
		table[x] = def;

	/* Expand the string.					*/
	
	expand_string(string,buffer1);

	/* Read the string into the table			*/
	
	for( ptr = buffer1; *ptr; ptr++ )
		table[*ptr] = special;
}


/*******
	Parse two command-line strings for translation.

	Arguments:	const char * string1
			const char * string2
	Return value:	none
*******/

static void
parse_strings( const char * string1,const char * string2 )
{
	int x;
	char * ptr1,* ptr2;

	/* expand both strings, borrowing the i/o buffers	*/
	
	expand_string(string1,buffer1);
	expand_string(string2,buffer2);
	ptr1 = buffer1;
	ptr2 = buffer2;

	/* if the complement flag is set, use everything but	*/
	/* the characters in string1				*/
	
	if( c_flag ) {

		/* flag the entire table		*/
		
		for( x = 0; x < CHARSET_SIZE; x++ )
			table[x] = 1;

		/* unflag the characters given		*/
		
		for( ; *ptr1; ptr1++ )
			table[*ptr1] = 0;

		/* translate all flagged characters	*/
		for( x = 0; x < CHARSET_SIZE; x++ ) {
			if( table[x] ) {
				table[x] = *ptr2;
				if( *(ptr2+1) )
					ptr2++;
			}
		}

	/* set up the translation table				*/
	
	} else {
		for( ; *ptr1; ptr1++ ) {
			table[*ptr1] = *ptr2;
			if( *(ptr2+1) )
				ptr2++;
		}
	}
}
	
/*******
	Expand a command-line string into a full string.

	Arguments:	const char * string
			char * buffer	the output buffer
	Return value:	none
*******/

static void
expand_string( const char * string,char * buffer )
{
	int c;
	
	while( *string ) {
		if( *(string+1) == '-' && *(string+2) ) {
			for( c = *string; c <= *(string+2); c++ )
				*(buffer++) = c;
			string += 3;
		} else if( *string == '\\' ) {
			if( *(string+1) >= '0'
					&& *(string+1) <= '7' ) {
				c = *(++string) - '0';
			}
			if( *(string+1) >= '0'
					&& *(string+1) <= '7' ) {
				c = c * 8 + *(++string) - '0';
			}
			if( *(string+1) >= '0'
					&& *(string+1) <= '7' ) {
				c = c * 8 + *(++string) - '0';
			}
			*(buffer++) = c;
			string++;
		} else {
			*(buffer++) = *(string++);
		}
	}
	*buffer = '\0';
}


/*******
	Copy from stdin to stdout, deleting characters.
*******/

static void
do_delete()
{
	fpos_t total_read,total_write;

	do {
		total_read = read(0,buffer1,BUFFER_SIZE/2);
		if( total_read > 0 )
			total_write = delete_between_buffers(total_read);
		write(1,buffer2,total_write);
	} while( total_read > 0 );
}

/*******
	Filter delete between buffers.
*******/

static fpos_t
delete_between_buffers( fpos_t count )
{
	fpos_t x,outpos = 0;

	for( x = 0; x < count; x++ ) {
#ifdef SKIP_CR
		/* Make sure that we delete the \r as well as	*/
		/* the \n in an \r\n combination		*/
		
		if( buffer1[x] == '\r' && buffer1[x+1] == '\n'
				&& !table['\n'] )
			continue;
#endif SKIP_CR
		if( !table[buffer1[x]] )
			buffer2[outpos++] = buffer1[x];
	}
	return outpos;
}

/*******
	Copy from stdin to stdout, translating characters.
*******/

static void
do_translate()
{
	fpos_t total_read,total_write;

	do {
		total_read = read(0,buffer1,BUFFER_SIZE/2);
		if( total_read > 0 )
			total_write = translate_between_buffers(total_read);
		write(1,buffer2,total_write);
	} while( total_read > 0 );
}


/*******
	Filter translate between buffers.
*******/

static fpos_t
translate_between_buffers( fpos_t count )
{
	fpos_t x,outpos = 0;
	int lastchar = 0;

	for( x = 0; x < count; x++ ) {
#ifdef SKIP_CR
		/* If the \n is going to become something else,	*/
		/* we should not copy the \r			*/
		
		if( buffer1[x] == '\r' && buffer1[x+1] == '\n'
				&& table['\n'] )
			x++;
#endif
		if( !table[buffer1[x]] ) {
			lastchar = buffer1[x];
			buffer2[outpos++] = lastchar;
		} else if( s_flag && table[buffer1[x]] == lastchar ) {
			continue;
		} else {
#ifdef SKIP_CR
		/* If we are translating into \n, do not add	*/
		/* \r for now (buffer overflow)			*/
#endif SKIP_CR
			lastchar = table[buffer1[x]];
			buffer2[outpos++] = lastchar;
		}
	}
	return outpos;
}


/*******
	Print a usage message.
*******/

static void
usage()
{
	fprintf(stderr,"usage: tr [-cds [string1 [string2]]]\n");
}
