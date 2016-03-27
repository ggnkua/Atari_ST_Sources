/* falcon.c */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>
# include <ctype.h>
# include <tos.h>
# include <ext.h>

# include <global.h>

# include "tools.h"

int cmdin_device =  2 ;		/* CONsole	*/

/*
0              Shift-Taste rechts
1              Shift-Taste links
2              Control-Taste
3              Alternate-Taste
4              Caps Lock
5              Maustaste rechts
6              Maustaste links
7              reserviert (0)
*/

/*----------------------------------------- AnyShiftPressed --------*/
bool AnyShiftPressed ( void )
{
	return ( Kbshift(-1) & 0x6f ) != 0 ;	/* w/o caps lock	*/
}


/*---------------------------------------------- get_cmdin_char ----*/
unsigned get_cmdin_char ( void )
{
	long lc ;

	lc = Bconin ( cmdin_device ) ;

# if 0
	printf ( "cin   = $%08lx\n", lc ) ;
# endif

	if ( lc & 0x00ff )
		return (unsigned) ( (lc&0xff) ) ;
	else
		return (unsigned) ( (lc>>8) | (lc&0xff) ) ;
}

/*---------------------------------------------- get_cmdin_stat ----*/
bool get_cmdin_stat ( void )
{
# if 1
# if 0
	printf ( "cstat = %d, kbhit=%d\n", Bconstat ( cmdin_device ), kbhit() ) ;
# endif
	return Bconstat ( cmdin_device ) != 0 ;
# else
	return kbhit() ;
# endif
}

/*---------------------------------- GetString -----------------*/
int GetString ( char *prompt, char *string )
{
	StatusLine();
	printf ( "* %s ? >", prompt ) ;
	gets ( string ) ;
	return (int) strlen ( string ) ;
}


/*------------------------------------- ToggleSwitch ---------------*/
bool ToggleSwitch ( char *prompt, bool *b )
{
	*b = ! *b ;
	StatusLine();
	printf ( "* %s = %s", prompt, *b ? "ON" : "OFF" ) ;
	return *b ;
}
												
/*--------------------------------------------- GetLong -------*/
bool GetLong ( char *name, long *var, long defval )
{
	char buffer[64] ;
	
	printf ( "%s = %ld=$%02lx(Ret),d=%ld ? >" "\033K", name, *var, *var, defval ) ;
	gets ( buffer ) ;
	switch ( *buffer )
	{
case 'D' :
case 'd' :	if ( *var != defval )
			{
				*var = defval ;
				printf ( " - use default : %ld\n", *var ) ;
				return TRUE ;
			}
		/*	continue : */
case 0 :	printf ( " - unchanged\n" ) ;
			return FALSE ;

case '+' : case '-' :
case '0' : case '1' : case '2' : case '3' : case '4' :
case '5' : case '6' : case '7' : case '8' : case '9' :
			*var = strtol ( buffer, NULL, 0 ) ;
			printf ( " - new : %ld\n", *var ) ;
			return TRUE ;

default :	printf ( " * illegal input : %s !\n", buffer ) ;
			return FALSE ;
	}
}


/*--------------------------------------------- GetInt -------*/
bool GetInt ( char *name, int *var, int defval )
{
	long  value ;
	bool chgd ;
	
	value = *var ;
	chgd  = GetLong ( name, &value, defval ) ;
	if ( chgd ) 
		*var = (int)value ;
	return chgd ;
}

/*--------------------------------------------- GetUInt -------*/
bool GetUInt ( char *name, unsigned int *var, unsigned int defval )
{
	long  value ;
	bool chgd ;
	
	value = *var ;
	chgd  = GetLong ( name, &value, defval ) ;
	if ( chgd ) 
		*var = (unsigned int)value ;
	return chgd ;
}

/*--------------------------------------------- GetUChar -------*/
bool GetUChar ( char *name, unsigned char *var, unsigned char defval )
{
	long  value ;
	bool chgd ;
	
	value = *var ;
	chgd  = GetLong ( name, &value, defval ) ;
	if ( chgd ) 
		*var = (unsigned char)value ;
	return chgd ;
}


/*--------------------------------------------- Continue -------*/
bool Continue ( bool *continuous )
{
	if ( *continuous )
	{
		if ( SkipInput() )
			*continuous = FALSE ;
		else
			return TRUE ;
	}
	return FALSE ;
}

/*----------------------------------------- More -------------------*/
bool More ( void )
{
	printf ( "- more [Return]/q -" ) ;
	if ( get_cmdin_char() == 'q' )
		return FALSE ;
	printf ( "\033E" ) ;
	return TRUE ;
}

char dotline[] = "...........................................\n" ;

/*----------------------------------------- Help -------------------*/
void Help ( char **table )
{
	while ( *table != NULL )
	{
		printf ( "\033E" ) ;
		printf ( dotline ) ;
		printf ( "%s\n", *table++ ) ;
		printf ( dotline ) ;
		if ( *table != NULL )
			printf ( *table++ ) ;
		else
			printf ( "??? help table format\n" ) ;
		printf ( dotline ) ;
		if ( ! More() )
			return ;
	}
}


/*----------------------------------------- SkipInput -------------------*/
bool SkipInput ( void )
{
	bool keyhit = FALSE ;
	
	while ( get_cmdin_stat() )
	{
		keyhit = TRUE ;
		get_cmdin_char() ;
	}
	return keyhit || AnyShiftPressed() ;
}

/*--------------------------------------------- DumpBuffer ---*/
void DumpBuffer ( unsigned char *buffer, long size )
{
	long i ;

	for ( i = 0 ; i < size ; i++ )
	{
		if ( (i & 15 ) == 0 )
			printf ( "\n%06lx :", i ) ;
		printf ( " %02x", (unsigned)*buffer++ ) ;
		if ( (i & 255 ) == 0 && SkipInput() )
			break ;
	}
	printf ( "\n" ) ;
}




