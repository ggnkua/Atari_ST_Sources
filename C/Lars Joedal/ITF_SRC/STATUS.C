/*
**	File:	status.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

/*
**	Status-Bar Routine Variables.
**
**	Note:
**		The variable "s_buff_ptr" is of type "byte *"
**		NOT "byte_ptr" - these definitions are
**		different for MSDOS Compilers ("byte_ptr" is huge).
*/

byte			s_buffer[MAX_LINE_LENGTH] ;
byte			*s_buff_ptr ;
static char		*score_str	= "Score: " ;
static char		*time_str	= "Time:  " ;

Void
put_status ( ch )
word	ch ;
{
	*s_buff_ptr++ = (byte)ch ;
}

char
*copy_string ( src,dst )
char	*src ;
char	*dst ;
{
	while ( *src != '\0' )
		*dst++ = *src++ ;
	return ( dst ) ;
}

Void
prt_status ()
{
	extern header	data_head ;
	extern boolean	disable_script ;
	extern proc_ptr	PrintChar ;
	extern int		screen_width ;

	word			hour ;
	word			minutes ;
	char			ch ;
	boolean			old_disable_script ;
	proc_ptr		old_procptr ;

	s_buff_ptr = s_buffer ;
	*s_buff_ptr++ = ' ' ;
	old_disable_script = disable_script ;
	disable_script = TRUE ;
	old_procptr = PrintChar ;
	PrintChar = put_status ;

	std_p_obj ( load_var ( 0x10 ) ) ;

	if (( data_head.mode_bits & USE_TIME ) == 0 )
	{
		while ( s_buff_ptr < ( s_buffer + screen_width - 0x14 ) )
			*s_buff_ptr++ = ' ' ;
		s_buff_ptr = (byte *)copy_string ( score_str,(char *)s_buff_ptr ) ;
		print_num ( load_var ( 0x11 ) ) ;
		*s_buff_ptr++ = '/' ;
		print_num ( load_var ( 0x12 ) ) ;
	}
	else
	{
		while ( s_buff_ptr < ( s_buffer + screen_width - 0x10 ) )
			*s_buff_ptr++ = ' ' ;
		s_buff_ptr = (byte *)copy_string ( time_str,(char *)s_buff_ptr ) ;
		hour = load_var ( 0x11 ) ;

		/*
		**	Convert 24 hour time to AM/PM
		*/

		ch = 'A' ;
		if ( hour >= 12 )
		{
			hour -= 12 ;
			ch = 'P' ;
		}
		if ( hour == 0 )
			hour = 12 ;

		/*
		**	Print Time
		*/

		print_num ( hour ) ;
		*s_buff_ptr++ = ':' ;

		/*
		**	Can't use print_num for minutes since we want leading zeros
		*/

		minutes = load_var ( 0x12 ) ;
		*s_buff_ptr++ = ((minutes / 10) + '0') ;
		*s_buff_ptr++ = ((minutes % 10) + '0') ;
		*s_buff_ptr++ = ' ' ;
		*s_buff_ptr++ = ch ;
		*s_buff_ptr++ = 'M' ;
	}
	while ( s_buff_ptr < ( s_buffer + screen_width ) )
		*s_buff_ptr++ = ' ' ;
	print_status ( s_buffer ) ;
	disable_script = old_disable_script ;
	PrintChar = old_procptr ;
}
