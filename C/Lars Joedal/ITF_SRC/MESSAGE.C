/*
**	File:	message.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

/*
**	Coded Message Routine Global Variables
*/

char		*table ;				/* Character Table used by "print_coded" */
proc_ptr	letter ;				/* Routine used by "print_coded ()" to   */
									/* print a letter.                       */
word		(*find_mode)() ;		/* Routine used by "encode ()" to find   */
									/* the mode of a character.              */
int			print_mode ;			/* General Printing Mode                 */
int			single_mode ;			/* Mode for printing the next char       */
word		word_bank ;				/* There are 3 banks of common           */
									/* words, each 32 words long.            */

/*
**	Character Table
*/

char	table_1[] =	{	'a','b','c','d','e','f','g','h','i','j','k','l',
						'm','n','o','p','q','r','s','t','u','v','w','x',
						'y','z','A','B','C','D','E','F','G','H','I','J',
						'K','L','M','N','O','P','Q','R','S','T','U','V',
						'W','X','Y','Z',' ','0','1','2','3','4','5','6',
						'7','8','9','.',',','!','?','_','#','\'','\"',
						'/','\\','<','-',':','(',')','\0','\0'
					} ;

char	table_2[] =	{	'a','b','c','d','e','f','g','h','i','j','k','l',
						'm','n','o','p','q','r','s','t','u','v','w','x',
						'y','z','A','B','C','D','E','F','G','H','I','J',
						'K','L','M','N','O','P','Q','R','S','T','U','V',
						'W','X','Y','Z',' ',' ','0','1','2','3','4','5',
						'6','7','8','9','.',',','!','?','_','#','\'',
						'\"','/','\\','-',':','(',')','\0','\0'
					} ;

/*
**	Decode Routines
*/

Void
init_message ( version )
byte	version ;
{
	extern char		*table ;
	extern char		table_1[] ;
	extern char		table_2[] ;
	extern proc_ptr	letter ;
	extern Void		letter_v1 () ;
	extern Void		letter_v2 () ;
	extern Void		letter_v3 () ;
	extern word		(*find_mode)() ;
	extern word		find_mode_v1 () ;
	extern word		find_mode_v3 () ;

	switch ( version )
	{
		case VERSION_1:
						table = table_1 ;
						letter = letter_v1 ;
						find_mode = find_mode_v1 ;
						break ;
		case VERSION_2:
						table = table_2 ;
						letter = letter_v2 ;
						find_mode = find_mode_v1 ;
						break ;
		case VERSION_3:
		case VERSION_4:
		case VERSION_5:
		default:
						table = table_2 ;
						letter = letter_v3 ;
						find_mode = find_mode_v3 ;
						break ;
	}
}

Void
print_coded ( page,offset )
word	*page ;
word	*offset ;
{
	word	data ;

	/*
	**	Print mode :-		= 0		:	Lower Case Letter ;
	**						= 1		:	Upper Case Letter ;
	**						= 2		:	Number or Symbol ;
	**						= 3		:	ASCII Letter - first byte ;
	**						= 0x40	:	ASCII Letter - second byte ;
	**						= 0x80	:	Common Word ;
	*/

	print_mode = 0 ;
	single_mode = 0 ;

	/*
	**	Last word has high bit set
	*/

	do
	{
		data = get_word ( page,offset ) ;
		decode ( data ) ;
	}
	while (( data & 0x8000 ) == 0 ) ;
}

Void
decode ( data ) 
word	data ;
{
	extern byte_ptr		common_word_ptr ;
	extern proc_ptr		PrintChar ;
	extern proc_ptr		letter ;
	
	word				page ;
	word				offset ;
	word				code ;
	int					save_mode ;
	int					i ;
	byte_ptr			ptr ;
	char				ch[3] ;

	/*
	**	Reduce word to 3 characters of 5 bits
	*/

	code = data ;
	for ( i = 0 ; i <= 2 ; i++ )
	{
		ch[i] = code & 0x1F ;
		code >>= 5 ;
	}

	/*
	**	Print each character
	*/

	for ( i = 2 ; i >= 0 ; i-- )
	{
		if ( single_mode & 0x80 )
		{
			/*
			**	Print a Special Word
			**
			**	Note:
			**		We need to save the 'print_mode' before
			**		recursively calling 'print_coded ()'. This
			**		is because 'print_mode' is most efficiently
			**		implemented as a global variable.
			*/

			ptr = common_word_ptr + word_bank + (int)( ch[i] << 1 ) ;
			page = *ptr++ ;
			offset = *ptr << 1 ;
			save_mode = print_mode ;
			print_coded ( &page,&offset ) ;
			single_mode = print_mode = save_mode ;
			continue ;
		}
		if ( single_mode < 3 )
		{
			/*
			**	Print a single character
			*/

			(*letter)( ch[i] ) ;
			continue ;
		}
		if ( single_mode == 3 )
		{
			/*
			**	Print ASCII character - store the high 3 bits of
			**	char in the low 3 bits of the current printing mode.
			*/

			single_mode = 0x40 + ch[i] ;
			continue ;
		}
		if ( single_mode & 0x40 )
		{
			/*
			**	Print an ASCII character - consists of the current
			**	character as the low 5 bits and the high 3 bits coming
			**	from the low 3 bits of the current printing mode.
			*/

			ch[i] += ( single_mode & 0x03 ) << 5 ;
			(*PrintChar)( (word)ch[i] ) ;
			single_mode = print_mode ;
		}
	}
}

Void
letter_v1 ( ch )
char	ch ;
{
	extern proc_ptr	PrintChar ;
	extern char		*table ;

	if ( ch == 0 )
	{
		(*PrintChar)( (word)' ' ) ;
		single_mode = print_mode ;
		return ;
	}

	if ( ch == 1 )
	{
		/*
		**	Print a Carriage Return
		*/

		new_line () ;
		single_mode = print_mode ;
		return ;
	}

	if (( ch == 2 ) || ( ch == 3 ))
	{
		/*
		**	Switch printing modes
		*/

		single_mode = ( single_mode + 2 + ch ) % 3 ;
		return ;
	}

	if (( ch == 4 ) || ( ch == 5 ))
	{
		/*
		**	Switch printing modes
		*/

		print_mode = ( single_mode + ch ) % 3 ;
		single_mode = print_mode ;
		return ;
	}

	if (( ch == 6 ) && ( single_mode == 2 ))
	{
		/*
		**	Increment printing mode to 3 - ASCII Letter.
		*/

		++single_mode ;
		return ;
	}

	/*
	**	None of the above, so this must be a single character
	*/

	(*PrintChar)( (word)table[( single_mode * 26 ) + ch - 6] ) ;
	single_mode = print_mode ;
}

Void
letter_v2 ( ch )
char	ch ;
{
	extern proc_ptr	PrintChar ;
	extern char		*table ;

	if ( ch == 0 )
	{
		(*PrintChar)( (word)' ' ) ;
		single_mode = print_mode ;
		return ;
	}

	if ( ch == 1 )
	{
		/*
		**	Set single_mode to "Common Word" & set word_bank
		*/

		single_mode |= 0x80 ;
		word_bank = ( ch - 1 ) << 6 ;
		return ;
	}

	if (( ch == 2 ) || ( ch == 3 ))
	{
		/*
		**	Switch printing modes
		*/

		single_mode = ( single_mode + 2 + ch ) % 3 ;
		return ;
	}

	if (( ch == 4 ) || ( ch == 5 ))
	{
		/*
		**	Switch printing modes
		*/

		print_mode = ( single_mode + ch ) % 3 ;
		single_mode = print_mode ;
		return ;
	}

	if (( ch == 6 ) && ( single_mode == 2 ))
	{
		/*
		**	Increment printing mode to 3 - ASCII Letter.
		*/

		++single_mode ;
		return ;
	}

	if (( ch == 7 ) && ( single_mode == 2 ))
	{
		/*
		**	Print a Carriage Return
		*/

		new_line () ;
		single_mode = print_mode ;
		return ;
	}

	/*
	**	None of the above, so this must be a single character
	*/

	(*PrintChar)( (word)table[( single_mode * 26 ) + ch - 6] ) ;
	single_mode = print_mode ;
}

Void
letter_v3 ( ch )
char	ch ;
{
	extern proc_ptr	PrintChar ;
	extern char		*table ;

	if ( ch == 0 )
	{
		(*PrintChar)( (word)' ' ) ;
		single_mode = print_mode ;
		return ;
	}

	if ( ch <= 3 )
	{
		/*
		**	Set single_mode to "Common Word" & set word_bank
		*/

		single_mode |= 0x80 ;
		word_bank = ( ch - 1 ) << 6 ;
		return ;
	}

	if (( ch == 4 ) || ( ch == 5 ))
	{
		/*
		**	Switch printing modes
		*/

		if ( single_mode == 0 )
			single_mode = ch - 3 ;
		else
		{
			if ( single_mode != ch - 3 )
				single_mode = 0 ;
			print_mode = single_mode ;
		}
		return ;
	}

	if (( ch == 6 ) && ( single_mode == 2 ))
	{
		/*
		**	Increment printing mode to 3 - ASCII Letter.
		*/

		++single_mode ;
		return ;
	}

	if (( ch == 7 ) && ( single_mode == 2 ))
	{
		/*
		**	Print a Carriage Return
		*/

		new_line () ;
		single_mode = print_mode ;
		return ;
	}

	/*
	**	None of the above, so this must be a single character
	*/

	(*PrintChar)( (word)table[( single_mode * 26 ) + ch - 6] ) ;
	single_mode = print_mode ;
}

/*
**	Encode Routines
*/

Void
std_encode ( the_word,coded )
byte	*the_word ;
word	coded[] ;
{
	extern word			(*find_mode)() ;

	word				data[STD_CHARS_PER_WORD] ;
	word				mode ;
	word				offset ;
	register byte		ch ;
	register int		count ;

	/*
	**	Note:
	**		The parameter "the_word" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	count = 0 ;
	while ( count < (int)STD_CHARS_PER_WORD )
	{
		ch = *the_word++ ;
		if ( ch == 0 )
		{
			/*
			**	Finished, so fill with blanks
			*/

			while ( count < (int)STD_CHARS_PER_WORD )
				data[count++] = 5 ;
		}
		else
		{
			/*
			**	Get Character Print-Mode
			*/

			mode = (*find_mode)( (char)ch ) ;
			if ( mode != 0 )
				data[count++] = mode ;

			/*
			**	Get offset of character in Table[]
			*/

			if ( count < (int)STD_CHARS_PER_WORD )
			{
				offset = convert ( (char)ch ) ;
				if ( offset == 0 )
				{
					/*
					**	Character not in Table[], so use ASCII
					*/

					data[count++] = 6 ;
					if ( count < (int)STD_CHARS_PER_WORD )
						data[count++] = ch >> 5 ;
					if ( count < (int)STD_CHARS_PER_WORD )
						data[count++] = ch & 0x1F ;
				}
				else
					data[count++] = offset ;
			}
		}
	}

	/*
	**	Encrypt
	*/

	for ( count = 0 ; count < (int)STD_ENCODED_SIZE ; count++ )
		coded[count] = (data[count*3] << 10) | (data[count*3+1] << 5) | data[count*3+2] ;
	coded[STD_ENCODED_SIZE - 1] |= 0x8000 ;
}

Void
plus_encode ( the_word,coded )
byte	*the_word ;
word	coded[] ;
{
	extern word			(*find_mode)() ;

	word				data[PLUS_CHARS_PER_WORD] ;
	word				mode ;
	word				offset ;
	register byte		ch ;
	register int		count ;

	/*
	**	Note:
	**		The parameter "the_word" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	count = 0 ;
	while ( count < (int)PLUS_CHARS_PER_WORD )
	{
		ch = *the_word++ ;
		if ( ch == 0 )
		{
			/*
			**	Finished, so fill with blanks
			*/

			while ( count < (int)PLUS_CHARS_PER_WORD )
				data[count++] = 5 ;
		}
		else
		{
			/*
			**	Get Character Print-Mode
			*/

			mode = (*find_mode)( (char)ch ) ;
			if ( mode != 0 )
				data[count++] = mode ;

			/*
			**	Get offset of character in Table[]
			*/

			if ( count < (int)PLUS_CHARS_PER_WORD )
			{
				offset = convert ( (char)ch ) ;
				if ( offset == 0 )
				{
					/*
					**	Character not in Table[], so use ASCII
					*/

					data[count++] = 6 ;
					if ( count < (int)PLUS_CHARS_PER_WORD )
						data[count++] = ch >> 5 ;
					if ( count < (int)PLUS_CHARS_PER_WORD )
						data[count++] = ch & 0x1F ;
				}
				else
					data[count++] = offset ;
			}
		}
	}

	/*
	**	Encrypt
	*/

	for ( count = 0 ; count < (int)PLUS_ENCODED_SIZE ; count++ )
		coded[count] = (data[count*3] << 10) | (data[count*3+1] << 5) | data[count*3+2] ;
	coded[PLUS_ENCODED_SIZE - 1] |= 0x8000 ;
}

word
find_mode_v1 ( ch )
char	ch ;
{
	if ( ch == 0 )
	{
		/*
		**	Mode is 3.
		*/

		return ( 3+3 ) ;
	}
	if (( ch >= 'a' ) && ( ch <= 'z' ))
	{
		/*
		**	Mode is 0.
		*/

		return ( 0 ) ;
	}
	if (( ch >= 'A' ) && ( ch <= 'Z' ))
	{
		/*
		**	Mode is 1.
		*/

		return ( 1+1 ) ;
	}

	/*
	**	Mode is 2.
	*/

	return ( 2+1 ) ;
}

word
find_mode_v3 ( ch )
char	ch ;
{
	if ( ch == 0 )
	{
		/*
		**	Mode is 3.
		*/

		return ( 3+3 ) ;
	}
	if (( ch >= 'a' ) && ( ch <= 'z' ))
	{
		/*
		**	Mode is 0.
		*/

		return ( 0 ) ;
	}
	if (( ch >= 'A' ) && ( ch <= 'Z' ))
	{
		/*
		**	Mode is 1.
		*/

		return ( 1+3 ) ;
	}

	/*
	**	Mode is 2.
	*/

	return ( 2+3 ) ;
}

word
convert ( ch )
char	ch ;
{
	extern char		*table ;

	register char	*ptr ;
	register word	code ;

	ptr = table ;
	while (( *ptr != ch ) && ( *ptr != 0 ))
		++ptr ;
	if ( *ptr == 0 )
		return ( 0 ) ;
	code = ( ptr - table ) + 6 ;
	while ( code >= 0x20 )
		code -= 0x1A ;
	return ( code ) ;
}
