/* text_tab.c / 8.7.91 / MATRIX / WA	*/

# define TEST	0

# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <ctype.h>
# include <tos.h>

# include <global.h>

# include "text_tab.h"


char start_message[128] ;
char date_buffer[32] ;

# undef OK
enum TXTcode
{
	OK,				/* the same start sequence is required in texttab.txt */
	NotOK,

	ILLdateFormat,
	TXdateFormat,
	TXjan,
	
	MATgraph = TXjan+12
} ;

# define NUM_OF_SUBTABLES	32
# define TAB_LENGTH	  		32

typedef char 			*TEXT ;
typedef TEXT			SUBTEXTtable[TAB_LENGTH] ;			/* arr of pointers to char		*/
typedef SUBTEXTtable	*(TEXTtable[NUM_OF_SUBTABLES]) ;	/* arr of pointers to subtab	*/

TEXTtable text_table = { NULL, /* ... */ NULL } ;
int num_text_entries = 0 ;

# define num_ok(n)		( n < TAB_LENGTH*NUM_OF_SUBTABLES )
# define sub_table(t,n)	((t)[n/TAB_LENGTH])
# define text(st,n)		((st)[n%TAB_LENGTH])

# define DEFAULT_MESSAGE_FILE	"*:\\MATRIX\\SYS\\TEXTTAB.TXT"
		/* '*' : search in boot and default drive,
				 also for pure filename				*/
				
FILE *txttabfile	  = NULL ;
char *txttabfile_name = DEFAULT_MESSAGE_FILE ;

char bad_text[128] ;


/*--------------------------------------------- free_text_table ----*/
void free_text_table ( void )
{
	int  ns, nt ;
	TEXT txt ;
	SUBTEXTtable *subtab ;

# if TEST
	printf ( "- free text table\n" ) ;
# endif

	for ( ns = 0 ; ns < NUM_OF_SUBTABLES ; ns++ )
	{
		subtab = text_table[ns] ;
		if ( subtab != NULL )
		{
			for ( nt = 0 ; nt < TAB_LENGTH ; nt++ )
			{
				txt = (*subtab)[nt] ;
				if ( txt != NULL )
					free ( txt ) ;
			}
			free ( subtab ) ;
		}
	}
}

/*--------------------------------------------- clear_text_table ----*/
void clear_text_table ( SUBTEXTtable **txttab )
{
	int i ;

	num_text_entries = 0 ;

	for ( i = 0 ; i < NUM_OF_SUBTABLES ; i++ )
		*txttab++ = NULL ;
}

/*--------------------------------------------- clear_sub_table ----*/
void clear_sub_table ( TEXT *txt )
{
	int i ;
	
	for ( i = 0 ; i < TAB_LENGTH ; i++ )
		*txt++ = NULL ;
}


/*------------------------------------------------- convert_string -*/
char *convert_string ( char *inout )
{
	char *si, *so ;

	si = so = inout ;
	for(;;)
	{
		switch ( *si )
		{
	case '\\' :	si++ ;
				switch ( *si )
				{
		case 'n' :	*so++ = '\n' ;
					break ;
		case 'r' :	*so++ = '\r' ;
					break ;
		case 't' :	*so++ = '\t' ;
					break ;
		default :	if ( isdigit ( *si ) )
					{
						int num = 0 ;

						do
							num = num * 10 + ( *si++ - '0' ) ;
						while ( isdigit ( *si ) ) ;
					}
					else
					{
						*so++ = '\\' ;
						*so++ = *si ;
					}
					break ;
				}
				si++ ;
				break ;
	case 0 :	*so = 0 ;
				return inout ;
	default :	*so++ = *si++ ;
				break ;
		}
	}
} 

/*--------------------------------------------- open_mat_file ------*/
FILE *open_mat_file ( char *filnam )
{
	FILE *mafi ;
	
	if ( *filnam == '*' )
	{
		*filnam = 'A' + Dgetdrv() ;
		if ( ( mafi = fopen ( filnam, "r" ) ) == NULL )
		{
			*filnam = get_boot_drive() ;
			if ( ( mafi = fopen ( filnam, "r" ) ) == NULL )
			{
				char *bs ;
				
				for(;;)
				{
					bs = strchr ( filnam, '\\' ) ;
					if ( bs == NULL )
						break ;
					filnam = bs + 1 ;
				}
				mafi = fopen ( filnam, "r" ) ;
			}	
		}	
	}
	else
		mafi = fopen ( filnam, "r" ) ;
	return mafi ;
}

/*--------------------------------------------- open_text_table ----*/
bool open_text_table ( char *filnam )
# define MAX_LINE_LNG 256
{
	char line[MAX_LINE_LNG+1], *start, *end ;
	TEXT *ptxt ;
	SUBTEXTtable **psubtab ;

# if TEST
	printf ( "- loading text table %s\n", filnam ) ;
# endif
	clear_text_table ( text_table ) ;

	if ( filnam == NULL )
		filnam = txttabfile_name ;
		
	if ( ( txttabfile = open_mat_file ( filnam ) ) != NULL )
	{
# if 0
		psubtab = text_table ;
# endif
		for ( num_text_entries = 0 ; num_ok ( num_text_entries ) && fgets ( line, MAX_LINE_LNG-1, txttabfile ) != NULL ; )
		{
			if ( ( start = strchr ( line,    '"' ) ) != NULL )
			{
				end = strchr ( ++start, '"' ) ;
				if ( end != NULL )
				{
					*end  = 0 ;
					convert_string ( start ) ;
# if 0
					psubtab = &sub_table(text_table,num_text_entries) ;
# else
					psubtab = &(text_table[num_text_entries/TAB_LENGTH]) ;
# endif
					if ( *psubtab == NULL )
					{
# if TEST
						printf ( "- new table, size = %ld\n", sizeof ( SUBTEXTtable ) ) ;
# endif
						*psubtab = malloc ( sizeof ( SUBTEXTtable ) ) ;
						if ( *psubtab == NULL )
							break ;
						clear_sub_table ( **psubtab ) ;
					}
# if 0
					ptxt  = &text(*psubtab,num_text_entries) ;
# else	
					ptxt = &((**psubtab)[num_text_entries%TAB_LENGTH]) ;
# endif
					*ptxt = malloc ( strlen ( start ) + 1 ) ;
					if ( *ptxt == NULL )
						break ;
					strcpy ( *ptxt, start ) ;
# if TEST
					if ( num_text_entries < 10 )
						printf ( " %d : '%s'\n", num_text_entries, *ptxt ) ;
# endif
					num_text_entries++ ;
				}
			}
		}

		fclose ( txttabfile ) ;
# if TEST
		printf ( "\n- ok\n" ) ;
# endif
		return TRUE ;
	}
	else
	{
# if TEST
		printf ( "\n- can't open !\n" ) ;
# endif
		return FALSE ;
	}
}


/*--------------------------------------------- get_text -----------*/
char *get_text ( int txtnum )
{
	SUBTEXTtable  *subtab ;
	TEXT		  txt ;

	if ( txttabfile == NULL )
	{
		if ( ! open_text_table ( NULL ) )
		{
			sprintf ( bad_text, "* Can't open message file %s", txttabfile_name ) ;
			printf ( "%s\n", bad_text ) ;
			return bad_text ;
		}
	}

	if ( txtnum < num_text_entries )
	{
		subtab = sub_table(text_table,txtnum) ;
		if ( subtab != NULL )
		{
# if 0
			txt = *text(subtab,txtnum) ;
# else
			txt = ((*subtab)[txtnum%TAB_LENGTH]) ;
# endif
			if ( txt != NULL )
				return txt ;
		}
	}

	sprintf ( bad_text, "Text #%d not in text table", txtnum ) ;
	printf ( "??? %s\n", bad_text ) ;
	return bad_text ;
}

/*--------------------------------------------- print_text --------*/
void print_text ( int txtnum, const char *s, ... )
{
	printf ( "# %d : %s", txtnum, get_text ( txtnum ) ) ;
	vprintf ( s, ... ) ;
}


/*------------------------------------------------- date_to_string -*/
char *date_to_string ( int d, int m, int y, char *output )
{
	char *format, *so ;

	if ( output == NULL )
		output = date_buffer ;
	
	format = get_text ( TXdateFormat ) ;
	so = output ;
	for(;;)
	{
		switch ( *format )
		{
	case '%' :	format++ ;
				switch ( *format )
				{
		case 'd' :	sprintf ( so, "%d", d ) ;
					so = strchr ( so, 0 ) ;
					break ;
		case 'm' :	strcat ( so, get_text ( TXjan - 1 + m )  ) ;
					so = strchr ( so, 0 ) ;
					break ;
		case 'y' :	sprintf ( so, "%02d", y ) ;
					so = strchr ( so, 0 ) ;
					break ;
		default :	sprintf ( output, get_text ( ILLdateFormat ),
								*format ) ;
					return output ;
				}
				format++ ;
				break ;
	case 0 :	*so = 0 ;
				return output ;
	default :	*so++ = *format++ ;
				break ;
		}
	}
} 


/*--------------------------------------------- get_start_message ---------*/
char *get_start_message ( char *progname, int ver100, char *subver, int d, int m, int y )
{
	sprintf ( start_message,
				"%s - %s V %d.%d%s / %s",
				get_text ( MATgraph ),
					  progname,
					  		ver100/100, ver100%100, subver,
									date_to_string ( d, m, y, NULL ) ) ;
	return start_message ;
}


# if 0
int main ( void )
{
	int i ;

	print_text ( 0, "\n" ) ;
	
	for ( i = 80 ; i < num_text_entries ; i++ )
		print_text ( i, "\n" ) ;
	
	printf ( "RETURN !\n" ) ;
	getchar();

	return 0 ;
}
# endif
