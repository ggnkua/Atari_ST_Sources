/*      CTYPE.H

        Character definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __CTYPE )
#define __CTYPE


int     isalnum( int c );
int     isalpha( int c );
int     isascii( int c );
int     iscntrl( int c );
int     isdigit( int c );
int     isodigit( int c );
int     isxdigit( int c );
int     isgraph( int c );
int     isprint( int c );
int     ispunct( int c );
int     islower( int c );
int     isupper( int c );
int     isspace( int c );
int     tolower( int c );
int     toupper( int c );

#define toascii(c)      ((c) & 0x7f)

#endif

/************************************************************************/
