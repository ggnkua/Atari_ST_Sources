/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include <types2b.h>
#include	<ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"strcmd.h"
#include	"core.h"

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* function definitions																							*/
/*----------------------------------------------------------------------------------------*/

static	int16	hi( int16 wert );
static	int16	lo( int16 wert );


static	int16	hi( int16 wert )
{
	return (wert / 256);
}

static	int16	lo( int16 wert )
{
	return (wert % 256);
}

/*----------------------------------------------------------------------------------------*/
/* rpalce all tabs with spaces																				*/
/* Funktionsresultat: -															 								*/
/*----------------------------------------------------------------------------------------*/
void	tab2space( uint8 *string )
{
	int16 i = 0;

	while( string[i] != EOS )
	{
		if( string[i] == '\t' )
			string[i] = ' ';

		i++;
	}
}


/*----------------------------------------------------------------------------------------*/
boolean	match_start( uint8 *src, uint8 *cmp )
{
	if( strncmpi( src, cmp, strlen(cmp) ) == 0 )
		return TRUE;
	else
		return FALSE;
}


/*----------------------------------------------------------------------------------------*/
boolean	strsame( uint8 *src, uint8 *cmp )
{
	if( strcmpi( src, cmp ) == 0 )
		return TRUE;
	else
		return FALSE;
}


/*----------------------------------------------------------------------------------------*/
boolean	strfind( uint8 *src, uint8 *cmp )
{
	if( strstr( src, cmp ) != NULL )
		return TRUE;
	else
		return FALSE;
}


/*----------------------------------------------------------------------------------------*/
uint8 *strstri( const uint8 *s, const uint8 *wanted )
{
	register const uint8 *scan;
	register size_t len;
	register uint8 firstc;

	firstc = *wanted;
	len = strlen(wanted);
	for (scan = s; (toupper( (int16)*scan ) != toupper( (int16)firstc )) || strnicmp(scan, wanted, len) != 0; )
		if (*scan++ == '\0')
			return(NULL);
	return((uint8 *)scan);
}


/*----------------------------------------------------------------------------------------*/
void	str_upper( uint8 *src )
{
	uint8	*str;

	str = src;

	while (*str != EOS)
	{
		if( (*str > 96) && (*str < 123) )
		{
			if( *str == (uint8)'Å' ) *str = (uint8)'ö';
			else if( *str == (uint8)'î' ) *str = (uint8)'ô';
			else if( *str == (uint8)'Ñ' ) *str = (uint8)'é';
		}
		str++;
	}
}


/*----------------------------------------------------------------------------------------*/
uint8	*read_line( uint8 *src, uint8 *dest )
{
	if( src && dest )
	{
		int16	i = 0;

		while( src[i] != EOS && src[i] != '\n' && src[i] != '\r' )
		{
			dest[i] = src[i];
			i++;
		}

		dest[i] = EOS;

		while( (src[i] == '\n' || src[i] == '\r') && src[i] != EOS )
			i++;

		if( src[i] != EOS )
			return (uint8 *)&src[i];
	}
	return NULL;
}


/*----------------------------------------------------------------------------------------*/
/* Count unsignificant caracters at the beginning of a string (TABs & SPACEs & CR & LF)	*/
/* Return: amount of caracters												 								*/
/*----------------------------------------------------------------------------------------*/
int16	voidchars( uint8 *string )
{
	int16	begin = 0;

	while( (string[begin] == '\r') || (string[begin] == '\n') || (string[begin] == 9)
		 || (string[begin] == 32) || (begin > 1024) )
		begin++;

	return begin;
}


boolean	get_inside( uint8 beg, uint8 end, uint8 *zeile, uint8 *val )
{
	uint8 *p, *q;

	p = zeile + voidchars( zeile );
	q = strrchr(zeile, end);

	if((*p == beg) && (q != NULL) && (p < q))
	{
		uint8	*w;

		w = strchr(p, ' ');			/* Search first space after tag */

		if((w != NULL) && (w<q))	/* suitable space found */
		{
			w = w + voidchars( w );
			strncpy(val, w, q-w);
			val[q-w] = EOS;

			return TRUE;
		}
	}
	strcpy( val, "" );
	return FALSE;
}


/*----------------------------------------------------------------------------------------*/
/* XML <Zeile> auswerten																						*/
/* Funktionsresultat: 1, falls ein Wert gelesen werden konnte		 								*/
/*----------------------------------------------------------------------------------------*/
int16	parse_items( uint8 *zeile, uint8 *data, uint8 *value )
{
	uint8		*p = zeile, *q = zeile;
	int16		dlen = (int16)strlen( data );

	while( p != NULL )
	{
		p = strstri(q, data);
	/*	printf( "%s >%s< p=0x%p\n", zeile, data, p ); */
	
		if( p && ((p==zeile) || p[-1] != '\"') && (p[dlen] == '=') )
		{
			get_str( p+dlen+1, value );
			return 1;
		}
		else if( p != NULL )
			q = p+1;
		else
			value[0] = EOS;
	}

	return 0;
}


int16	AttrGetString( StringPtr attrs, StringPtr key, StringPtr value )
{
	return parse_items( attrs, key, value );
}


int16	AttrGetInt32( StringPtr attrs, StringPtr key, int32 *value )
{
	uint8	valstr[32] = "";
	uint8	*endptr = NULL;
	int16	ret = 0;

	if( parse_items( attrs, key, valstr ) )
	{
		*value = strtol( valstr, &endptr, 10 );
		ret = 1;
	}

/*	if( endptr == NULL || endptr == valstr )
		ret = 0; */
		
	return ret;
}


int16	AttrGetUint32( StringPtr attrs, StringPtr key, uint32 *value )
{
	int16	ret = 0;
	int32	val;

	ret = AttrGetInt32( attrs, key, &val );

	if( ret )
		*value = (uint32)val;
	
	return ret;
}


int16	AttrGetInt16( StringPtr attrs, StringPtr key, int16 *value )
{
	int16	ret = 0;
	int32	val = 0;

	ret = AttrGetInt32( attrs, key, &val );

	if( ret )
		*value = (int16)val;
	
	return ret;
}


int16	AttrGetBoolean( StringPtr attrs, StringPtr key, boolean *value )
{
	uint8	valstr[32] = "";
	*value = FALSE;

	parse_items( attrs, key, valstr );
	return read_cfg_bool( valstr, value );		
}


/*----------------------------------------------------------------------------------------*/
/* Liest Boolwert aus Konfigurationszeile heraus														*/
/* Funktionsresultat:	-														 								*/
/*----------------------------------------------------------------------------------------*/
int16	read_cfg_bool( uint8 *str, boolean *val )
{
	if ((stricmp(str, "TRUE") == 0) || (stricmp(str, "\"TRUE\"") == 0))
		*val = TRUE;
	else if ((stricmp(str, "FALSE") == 0)|| (stricmp(str, "\"FALSE\"") == 0))
		*val = FALSE;
	else
		return 0;
	return 1;
}


/*----------------------------------------------------------------------------------------*/
boolean	get_posval( int16 position, uint8 *string, uint8 *value )
{
	uint8	*start = string;
	uint8	*lpos;
	uint8 *rpos;
	int16	len, i;

	for( i = 0; i < position; i++ )
	{
		lpos = start;
		rpos = strchr( start, ' ' );
		start = rpos+1;
		if( lpos[0] == '\"' )
		{
			lpos++;
			rpos = strchr( lpos, '\"' );
			start++;
		}
	}

	if( lpos && rpos )
	{
		len = (int16)(rpos-lpos);
		strncpy( value, lpos, len );
		value[len] = EOS;
		return 1;
	}
	else
	{
		value[0] = EOS;
		return 0;
	}
}


/*----------------------------------------------------------------------------------------*/
/* Get string from a line in config file. Example: key="string"									*/
/* Return:	-																		 								*/
/*----------------------------------------------------------------------------------------*/
void	get_str( uint8 *str, uint8 *val )
{
	val[0] = EOS;
	if ((str[0] == '\"') && (str[1] == '\"'))
		return;
	else
	{
		int16	len = (int16)strlen(str);
		int16	j = 0;
		int16	i = 1;

		if (str[0] == '\"')
		{
			while ((str[i] != '\"') && (i < len))
			{
			/*	if ((str[i] == '\\') && (str[i+1] == '"'))
					i++; */
				val[j++] = str[i++];
			}
			val[j] = EOS;
		}
		else if( str[0] != ' ' )
		{
			i = 0;

			while ((str[i] != ' ') && (i < len))
				val[j++] = str[i++];

			val[j] = EOS;
		}
	}
}


/*----------------------------------------------------------------------------------------*/
/* [string] keyword find & replace 																			*/
/* result: TRUE if keyword was found																		*/
/*----------------------------------------------------------------------------------------*/
boolean	str_insert( uint8 *dest, uint8 *src, uint8 *key, uint8 *ins )
{
	uint8 *p;
	
	p = strstr( src, key );
	
	if( p && key )
	{
		strcpy( dest, src );
		dest[p-src] = EOS;
		strcat( dest, ins );
		strcat( dest, (p + strlen(key)) );
	}
	else
	{
		strcpy( dest, src );
		return FALSE;
	}
	
	return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/* Filtert aus [str] alle Zeichen [chr] heraus															*/
/* Funktionsergebnis: 0																							*/
/*----------------------------------------------------------------------------------------*/
int16	str_delchr( uint8 *str, uint8 chr )
{
	int16	len = (int16)strlen(str);
	int16	j = 0;
	int16	i = 0;
		
	while (i < len)
	{
		if( str[i] == chr )
			i++;
		str[j++] = str[i++];
	}
	str[j] = EOS;
	
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/*	Lîscht eventuelle Leerzeichen am Schluss eines Strings											*/
/* Funktionsergebnis: Anzahl entfernte Leerzeichen														*/
/*----------------------------------------------------------------------------------------*/
int16	str_clean( const uint8 *string )
{
	register uint8 *p, *q;

	if( !string )	return 0;
	p = q = (uint8*)string + strlen(string) - 1;
	while( p >= string )
	{
		if( *p == ' ' )
			*p-- = '\0';
		else
			break;
	}
	return (int16)(q-p);
}


/*----------------------------------------------------------------------------------------*/
/* Testet, ob eine (Datei-)Name Wildcards '[]*?' enthÑlt												*/
/* Funktionsergebnis: TRUE wenn ja, FALSE sonst															*/
/*----------------------------------------------------------------------------------------*/
boolean	nowildcard( const uint8 *fname )
{
	if( strchr( fname, '*' ) != NULL )
		return FALSE;

	if( strchr( fname, '?' ) != NULL )
		return FALSE;

	if( strchr( fname, '[' ) != NULL )
		return FALSE;

	return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/*	Testet, ob eine String-Variable gefÅllt wurde, d.h. nicht "[]" entspricht					*/
/* Funktionsergebnis: TRUE wenn ja, FALSE sonst															*/
/*----------------------------------------------------------------------------------------*/
boolean	is_filled( const uint8 *string )
{
	if( string == NULL )
		return FALSE;
	else if( strcmp(string, "[]") == 0 )
		return FALSE;
	else if( string[0] == EOS )
		return FALSE;
	else
		return TRUE;
}


/*----------------------------------------------------------------------------------------*/
/*	Erzeugt aus hexadezimalen Versionsnummern passende Strings										*/
/* Funktionsergebnis: -																							*/
/*----------------------------------------------------------------------------------------*/
boolean	make_vstr( uint8 *string, uint8 *prefix, int16 version, int16 radix )
{
	uint8	vstr_hi[6];
	uint8	vstr_lo[6];
	uint8	nullstr[4] = "";

	if( version )
	{
		itoa( hi(version), vstr_hi, radix );
		itoa( lo(version), vstr_lo, radix );
		
		if( lo(version) < radix )
			strcpy( nullstr, "0" );

		sprintf( string, "%s%s.%s%s", prefix, vstr_hi, nullstr, vstr_lo );
		return TRUE;
	}
	else
	{
		sprintf( string, "%s-", prefix );
		return FALSE;
	}
}


/*----------------------------------------------------------------------------------------*/ 
/* Liest ein Wort aus einer mit [div] getrennter Liste (10/11/2k)									*/
/* Funktionsergebnis: Zeiger auf nÑchstes Wort bzw. NULL												*/
/*----------------------------------------------------------------------------------------*/
uint8	*divlist_get( uint8 *dest, uint8 *dlist, uint8 div )
{
	uint8		entry[128];
	uint8		*p = dlist;
	uint8		*q;

	if( (*dlist == '\0') || (dlist == NULL) )
	{
		*dest = '\0';
		q = NULL;
	}
	else 
	{
		q = strchr( p, div);
		if (q != NULL)
		{
			strncpy( dest, p, (uint32)(q-p) );
			entry[q-p] = '\0';
			q++;
		}
		else
			strcpy( dest, p );
	}
	return q;
}


/*----------------------------------------------------------------------------------------*/ 
/* Lîscht ein Wort aus einer mit [div] getrennter Liste (04/11/2k)								*/
/* Funktionsergebnis: TRUE wenn der Name noch nicht da war, FALSE sonst							*/
/*----------------------------------------------------------------------------------------*/
boolean	divlist_del( uint8 *name, uint8 *dlist, uint8 div, boolean cs )
{
	boolean	found = FALSE;
	uint8		entry[128];
	uint8		*p = dlist;
	uint8		*q;

	if( *dlist == '\0' )
		found = FALSE;
	else 
	{
		while( p != NULL && !found )
		{
			q = strchr( p, div);
			if (q != NULL)
			{
				strncpy( entry, p, (uint32)(q-p) );
				entry[q-p] = '\0';
				q++;
			}
			else
				strcpy( entry, p );
	
			if( cs )
				found = !strcmp( name, entry );
			else
				found = !stricmp( name, entry );
				
			if( found )
			{
				if( q )
					strcpy( p, q );
				else if( dlist < p )
					strcpy( p-1, "" );
				else
					strcpy( p, "" );
			}
			p = q;
		}
	}	
	return found;
}


/*----------------------------------------------------------------------------------------*/ 
/* FÅgt ein Wort einer mit [div] getrennter Liste zu, falls er noch nicht vorhanden ist	*/
/* Funktionsergebnis: TRUE wenn der Name noch nicht da war, FALSE sonst							*/
/*----------------------------------------------------------------------------------------*/
boolean	divlist_add( uint8 *name, uint8 *dlist, uint8 div, boolean cs )
{
	boolean	found = FALSE;
	uint8		entry[128];
	uint8		*p = dlist;
	uint8		*q;

/*	printf("divlist_add( \"%s\", \"%s\", \'%c\', \"%d\" );\n", name, dlist, div, (int16)cs ); */

	if( *dlist == '\0' )
	{
		strcpy( dlist, name );
		found = FALSE;
	}
	else 
	{
		while( p != NULL && !found )
		{
			q = strchr( p, div);
			if (q != NULL)
			{
				strncpy( entry, p, (uint32)(q-p) );
				entry[q-p] = '\0';
				q++;
			}
			else
				strcpy( entry, p );
			p = q;
	
			if( cs )
				found = !strcmp( name, entry );
			else
				found = !stricmp( name, entry );
		}
	
		if( !found )
		{
			uint8	divstr[3];
			divstr[0] = div;
			divstr[1] = '\0';
			
			strcat( dlist, divstr );
			strcat( dlist, name );	
		}
	}
	
	return !found;
}


/*----------------------------------------------------------------------------------------*/ 
/* FÅgt ein Dateiname einer Liste zu, falls er noch nicht vorhanden ist							*/
/* Funktionsergebnis: TRUE wenn der Name noch nicht da war, FALSE sonst							*/
/*----------------------------------------------------------------------------------------*/
boolean	namelist_add( uint8 *list, uint8 *name )
{
	if( strstr(list, name) != NULL )
		return FALSE;
	else if( (strlen(list) + strlen(name) + 1) > 512 )
		return FALSE;
	else
	{
		strcat( list, "\t" );
		strcat( list, name );
		return TRUE;
	}	
}


/*----------------------------------------------------------------------------------------*/ 
/* converts a string into a version number array (uint16[3])										*/
/* result: -																										*/
/*----------------------------------------------------------------------------------------*/
void	vstringread( StringPtr vstring, uint16 vfield[] )
{
	StringPtr qp = vstring;
	uint8	number[8] = "";
	int16	i;

	for( i = 0; i < 3; i++ )
	{
		if( qp )
			qp = divlist_get( number, qp, '.' );

		if( number[0] != EOS )
			vfield[i] = (uint16)atoi( number );
		else
			vfield[i] = 0;
	}
}
