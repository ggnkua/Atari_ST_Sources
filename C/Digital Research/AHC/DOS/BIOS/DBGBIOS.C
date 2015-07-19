
/*  dbgbios.c - bios debug routines					*/


#include	"kportab.h"
#include	"kdump.h"
#include	"kprintf.h"

#define	COMMENT	0

/*
**  globals
*/

GLOBAL	char	buffer[MAXDUMP] ;
GLOBAL	char	*kcrlf = "\n\r" ;


/*
**  hello -
**
*/

hello()
{
	kprintf("Hello, fellow Carplanders!\n\r") ;
	cgetc() ;
}




#if	0
===============

/*
**  cmpanic - panic call from biosa return from cmain
*/

cmpanic()
{
	kprintf( "\n\rcmpanic:  return from cmain! return value is %lX\n",
		cmret) ;
	while(1) ;
}

===============
#endif


/*
**  kpress - display a message, then wait for a key to be input
*/

kpress(s)
	char	*s ;
{
	char	ch ;

	if( s )		/*  if there is a message to display		*/
  	    kprintf(s) ;	/*  display it				*/

	kprintf(" ...PRESS") ;
	ch = cgetc() ;
	kputcrlf() ;
}

/*
**  kputcrlf - output a cr/lf sequence
**	used mostly for the convenience of asm routines
*/

kputcrlf()
{
	kprintf( kcrlf ) ;
}

#if	COMMENT
/*
**  kputs - output a null terminated string direct to the console.
*/

kputs( s )
	char	*s ;
{
	while( *s )
		CONOUT( *s++ ) ;
}
#endif



/*
**  kputl - output the value of a long (in hex) 
*/

kputl( l )
	long	l ;
{
	char	*s ;
	char	*slhex() ;

	s = slhex( l , buffer ) ;
	kprintf( buffer ) ;
}

/*
**  kputw - output the value of a word (in hex)
*/

kputw( w )
	int	w ;
{
	char	*s ;
	char	*swhex() ;

	s = swhex( w , buffer ) ;
	kprintf( buffer ) ;
}

/*
**  kputb - output the value of a byte (in hex) 
*/

kputb( b )
	char	b ;
{
	char	*s ;
	char	*sbhex() ;


	s = sbhex( b , buffer ) ;
	kprintf( buffer ) ;
}

/*
**  kdump - dump memory
**	dump the specified memory locations direct to the console
*/

kdump( start , cnt )
	char	*start ;
	int	cnt ;
{
	if( cnt > MAXDUMP )
	{
		kprintf( "Trying to dump more than MAXDUMP\n" ) ;
		return ;
	}

	bdump( buffer , start , start , cnt ) ;

	kprintf( buffer ) ;
}

/*
**  bdump - byte dump
**	do a byte dump of the memory buffer into the string.
**	format: "hhhhhhhh:  12 34 56 ... nn " with null at end.
**
**	returns ptr to null
*/

char	*bdump( s , h , b , n )
	char	*s ;	/*  string buffer for converted values		*/
	LONG	h ;	/*  header value				*/
	BYTE	*b ;	/*  ptr to buffer to convert			*/
	int	n ;	/*  number of bytes to dump 			*/
{
	int	i ;

	s = DMPHDR( h , s ) ;	/*  store the header into the string	*/

	for( i = n ; i-- ; )
		s = sbhex( *b++ , s ) ;

	return( s ) ;
}


/*
**  dmphdr -dump header
**	take a header value (longword) and store it in header format:
**				"hhhhhhhh:  "
**				          ^^^-- 2 spaces and a null
**	return a pointer to the null
*/

char	*dmphdr( h , s ) 
	LONG	h ;
	char	*s ;
{
	s = slhex( h , s ) ;	/* convert and store header value	*/
	*s++ = ':' ;		/* pad and terminate it			*/
	*s++ = ' ' ;
	*s++ = ' ' ;
	*s  = '\0' ;
	return( s ) ;
}


/*
**  slhex - string long to hexascii - longword format
**	convert a longword into ascii and put it in the string, followed by a
**	space and a null. (e.g. if l = 0x12345678, the string will contain
**	"12345678 " followed by a null.
**
**	return a pointer to the null.
*/

char	*slhex( l , s )
	LONG	l ;
	char	*s ;
{
	s = swhex( (WORD)( l >> 16 ) , s ) ;
	return(  swhex( (WORD)( l ) , s-1 )  ) ;
} 



/*
**  slwhex - string long to hexascii - word format
**	convert a long word into hex-ascii, and place it in the string, placing
**	a null ater it.  it is in the form of swhex.
**	(e.g., if l = 0x12345678, s will contain "1234 5678 " followed by a 
**	null).
**
**	returns a pointer to the null.
*/

char	*slwhex( l , s )
	LONG	l ;
	char	*s ;
{
	s = swhex(  (WORD)( l >> 16) , s ) ;
	return( swhex(  (WORD)( l ) , s ) ) ;
}

/*
**  swhex - string word to hexascii - word format
**	convert a word into hex-ascii, and place it in the string, placing a
**	space and a null after it.  (e.g. if w = 0x1234, s will contain 
**	"1234 " followed by a null).
**	NOTE:  the 'loop' is 'unrolled' to make it a little quicker.
**
**	returns a pointer to the null.
*/

char	*swhex( w , s )
	WORD	w ;
	char	*s ;
{
	*s++ = ntoa( (BYTE)(  w >> 12  ) ) ;
	*s++ = ntoa( (BYTE)(  w >>  8  ) ) ;
	*s++ = ntoa( (BYTE)(  w >>  4  ) ) ;
	*s++ = ntoa( (BYTE)(    w      ) ) ;
	*s++ = ' ' ;
	*s = '\0' ;
	return( s ) ;

}


/*
**  slbhex - string long to hexascii in byte format
**	convert a long word into hex-ascii, in sbhex format.
**	(e.g., a long with the value 0x12345678 will appear in the string as
**	"12 34 56 78 " followed by a null.)
**
**	returns a pointer to the null.
*/

char	*slbhex( l , s )
	LONG	l ;		/*  longword to convert			*/
	char	*s ;		/*  char buffer to put conversion into	*/
{
	s = swbhex( (WORD)( l >> 16 ) , s ) ;
	return(  swbhex( (WORD)( l ) , s ) ) ; 
}

/*
**  swbhex - string word to hexascii in byte format
**	convert a word into hex-ascii, in sbhex format.
**	(e.g., a word with the value 0x1234 will appear in the string s as
**	"12 34 ", with a terminating null.  
**
**	returns a pointer to the null.
*/

char	*swbhex( w , s )
	WORD	w ;
	char	*s ;
{
	BYTE	*sbhex() ;

	s = sbhex( (BYTE)((w>>8) & 0x00ff) , s ) ;
	return(   sbhex((BYTE)( w & 0x00ff ) , s)    ) ;
}

/*
**  sbhex - string byte to hexascii
**	convert a byte into hex-ascii, and place it in the string, followed
**	by a space and a null.  return pointer to the null.
*/

char	*sbhex( c , s )
	BYTE	c ;
	char	*s ;
{
	*s++ = ntoa(  c >> 4  ) ;
	*s++ = ntoa( c ) ;
	*s++ = ' '  ;
	*s = '\0' ;
	return( s ) ;
}


/*
**  ntoa - nibble to ascii
**	convert a nibble to an ascii character and return the character.
**	only the low order 4 bits of the character are used.
*/

char	ntoa( n )
	BYTE	n ;
{
	n = (n & (BYTE)(0x0f)) + '0' ;
	return(  n > '9'  ?  n + 7  :  n  ) ;
}


