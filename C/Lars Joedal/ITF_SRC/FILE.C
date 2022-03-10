/*
**	File:	file.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	<stdio.h>
#include	"infocom.h"

#define		NAME_SIZE	80

char	name[NAME_SIZE + 1] ;
FILE	*game_file	= (FILE *)0 ;

Void
read_header ( head )
header	*head ;
{
	/*
	**	Read the Data File Header.
	**
	**	This routine does not read the data-file header
	**	directly into a header structure because certain
	**	machines like the VAX 11/780 store integers in
	**	a different way to machines based on processors
	**	like the 68000 ( a 68000 stores the high byte
	**	first, while a VAX stores the low byte first ).
	**	Consequently, if the header is read directly
	**	into a structure, the integer values are
	**	interpreted differently by the two machines.
	**
	**	Note:
	**		The parameter "head" is of type "header *"
	**		NOT "header_ptr" - these definitions are
	**		different for MSDOS Compilers ("header_ptr" is huge).
	*/

	header	buffer ;

	if ( fseek ( game_file,0L,0 ) < 0 )
	{
		display ( "Failed to Seek Start of File\n" ) ;
		quit () ;
	}
	else
	{
		if ( fread ((char *)(&buffer),sizeof(header),1,game_file ) != 1 )
		{
			display ( "Failed to read File Header\n" ) ;
			quit () ;
		}
		else
		{
			assign ( head,(byte_ptr)&buffer ) ;
			if	(
					( head -> z_code_version == 0 )
					||
					( head -> z_code_version > MAX_VERSION )
				)
			{
				error ( ERR_HEADER ) ;
			}
		}
	}
}

Void
assign ( head,buffer )
header		*head ;
byte_ptr	buffer ;
{
	/*
	**	Process the raw header data in "buffer" and put
	**	it into the appropriate fields in "head". This
	**	processing is required because of the way different
	**	machines internally represent 'words'.
	**
	**	Note:
	**		The parameter "head" is of type "header *"
	**		NOT "header_ptr" - these definitions are
	**		different for MSDOS Compilers ("header_ptr" is huge).
	*/

	int			i ;

	head -> z_code_version		= *buffer++ ;
	head -> mode_bits			= *buffer++ ;
	head -> release				= make_word ( &buffer ) ;
	head -> resident_bytes		= make_word ( &buffer ) ;
	head -> start				= make_word ( &buffer ) ;
	head -> vocab				= make_word ( &buffer ) ;
	head -> object_list			= make_word ( &buffer ) ;
	head -> globals				= make_word ( &buffer ) ;
	head -> save_bytes			= make_word ( &buffer ) ;
	head -> script_status		= make_word ( &buffer ) ;
	for ( i = 0 ; i < 6 ; i++ )
		head -> serial_no[i] = *buffer++ ;
	head -> common_word			= make_word ( &buffer ) ;
	head -> verify_length		= make_word ( &buffer ) ;
	head -> verify_checksum		= make_word ( &buffer ) ;
	head -> interpreter_number	= *buffer++ ;
	head -> interpreter_version	= *buffer++ ;
	head -> screen_height		= *buffer++ ;
	head -> screen_width		= *buffer++ ;
	head -> left				= *buffer++ ;
	head -> right				= *buffer++ ;
	head -> top					= *buffer++ ;
	head -> bottom				= *buffer++ ;
	head -> unknown1			= *buffer++ ;
	head -> unknown2			= *buffer++ ;
	for ( i = 0 ; i < 2 ; i++ )
		head -> padding1[i] = make_word ( &buffer ) ;
	head -> unknown3			= *buffer++ ;
	head -> unknown4			= *buffer++ ;
	head -> unknown5			= make_word ( &buffer ) ;
	for ( i = 0 ; i < 3 ; i++ )
		head -> padding2[i] = make_word ( &buffer ) ;
	head -> unknown6			= make_word ( &buffer ) ;
	for ( i = 0 ; i < 4 ; i++ )
		head -> padding3[i] = make_word ( &buffer ) ;
}

word
make_word ( ptr )
byte_ptr	*ptr ;
{
	/*
	**	Form a word from two bytes.
	**	(High byte before Low byte)
	*/

	word	value ;

	value = *(*ptr)++ ;
	value = ( value << 8 ) + *(*ptr)++ ;
	return ( value ) ;
}

int
open_file ( filename )
char	*filename ;
{
	/*
	**	Open a File for Reading
	*/

	if (( game_file = fopen ( filename,READ_STRING )) == (FILE *)0 )
		return ( FALSE ) ;
	return ( TRUE ) ;
}

Void
close_file ()
{
	/*
	**	Close an Open File
	*/

	if ( game_file != (FILE *)0 )
	{
		if ( fclose ( game_file ) )
			display ( "Cannot Close Game File\n" ) ;
		game_file = (FILE *)0 ;
	}
}

Void
load_page ( block,num_blocks,ptr )
word		block ;
word		num_blocks ;
byte_ptr	ptr ;
{
	long	offset ;

	/*
	**	Read "num_block" blocks from Game File,
	**	starting with block "block", at the
	**	location pointed to by "ptr".
	*/

	offset = (long) block * BLOCK_SIZE ;
	if ( fseek ( game_file,offset,0 ) < 0 )
	{
		display ( "Failed to Seek required Blocks\n" ) ;
		quit () ;
	}
	else
	{
		if ( (int)fread ((char *)ptr,BLOCK_SIZE,(int)num_blocks,game_file) < 0 )
		{
				display ( "Failed to Read required Blocks\n" ) ;
				quit () ;
		}
	}
}

boolean
filename ()
{
	char	ch ;
	int		i ;

	display ( "Filename: " ) ;
	i = 0 ;
	while (( ch = read_char () ) != '\n' )
	{
		/* Handle backspaces */

		if (( ch == '\b' ) && ( i != 0 ))
			--i ;

		/* Convert Uppercase to Lowercase */

		if (( ch >= 'A' ) && ( ch <= 'Z' ))
			ch = ch - 'A' + 'a' ;

		/* Handle Alpha-numeric Characters */

		if (( ch >= 'a' ) && ( ch <= 'z' ) && ( i < NAME_SIZE ))
			name[i++] = ch ;
		if (( ch >= '0' ) && ( ch <= '9' ) && ( i < NAME_SIZE ))
			name[i++] = ch ;

		/* Handle Pathname Characters */

		if ((ch == '/' || ch == ':' || ch == '.') && (i < NAME_SIZE))
			name[i++] = ch ;
	}
	name[i] = '\0' ;
	if ( i == 0 )
	{
		display ( "Bad Filename. Try Again...\n" ) ;
		return ( FALSE ) ;
	}
	return ( TRUE ) ;
}

boolean
put_word ( save_file,number )
FILE	*save_file ;
word	number ;
{
	/*
	**	Returns TRUE if an Error Occurred.
	*/

	byte	c ;

	c = MOST_SIGNIFICANT_BYTE ( number ) ;
	if ( fwrite ((char *)&c,sizeof(byte),1,save_file) != 1 )
		return ( TRUE ) ;
	c = LEAST_SIGNIFICANT_BYTE ( number ) ;
	if ( fwrite ((char *)&c,sizeof(byte),1,save_file) != 1 )
		return ( TRUE ) ;
	return ( FALSE ) ;
}

boolean
ld_word ( save_file,number )
FILE	*save_file ;
word	*number ;
{
	/*
	**	Returns TRUE if an Error Occurred.
	*/

	byte	c ;

	if ( fread ((char *)&c,sizeof(byte),1,save_file) != 1 )
		return ( TRUE ) ;
	*number = c << 8 ;
	if ( fread ((char *)&c,sizeof(byte),1,save_file) != 1 )
		return ( TRUE ) ;
	*number |= c ;
	return ( FALSE ) ;
}

Void
save_game ()
{
	extern header		data_head ;
	extern byte_ptr		base_ptr ;
	extern word			*stack_base ;
	extern word			*stack_var_ptr ;
	extern word			*stack ;
	extern word			stack_space[] ;
	extern word			pc_page ;
	extern word			pc_offset ;
	extern word			save_blocks ;

	FILE				*save_file ;
	boolean				err = FALSE ;
	word				s_offset ;
	int					i ;

	/*
	**	Save a Game.
	**
	**	Swapping Saved Game Files between machines is OK provided the
	**	macro "STACK_SIZE" in file "infocom.h" is the same on each machine.
	**
	**	For the Standard & Enhanced Interpreters:
	**							"ret_value ( FALSE )" -> Save/Restore Error.
	**							"ret_value ( TRUE )"  -> Save/Restore was Ok.
	**
	**	For the PLUS Series Interpreter:
	**							"store ( (word)0 )" -> Save/Restore Error.
	**							"store ( (word)1 )" -> Save was Ok.
	**							"store ( (word)2 )" -> Restore was Ok.
	*/

	while ( ! filename () ) ;
	if (( save_file = fopen ( name,WRITE_STRING )) == (FILE *)0 )
	{
		if ( data_head.z_code_version <= VERSION_3 )
			ret_value ( FALSE ) ;
		else
			store ( (word)0 ) ;
		return ;
	}
	if (fwrite((char *)base_ptr,BLOCK_SIZE,(int)save_blocks,save_file) != save_blocks)
		err = TRUE ;

	/*
	**	Save the Stack, Stack Pointers & Program Counter
	*/

	for ( i = 0 ; i < (int)STACK_SIZE ; i++ )
		err |= put_word ( save_file,stack_space[i] ) ;
	s_offset = stack_base - stack ;
	err |= put_word ( save_file,s_offset ) ;
	s_offset = stack_base - stack_var_ptr ;
	err |= put_word ( save_file,s_offset ) ;
	err |= put_word ( save_file,pc_page ) ;
	err |= put_word ( save_file,pc_offset ) ;

	if ( fclose ( save_file ) )
		err = TRUE ;
	if ( data_head.z_code_version <= VERSION_3 )
	{
		if ( err )
			ret_value ( FALSE ) ;
		else
			ret_value ( TRUE ) ;
	}
	else
	{
		if ( err )
			store ( (word)0 ) ;
		else
			store ( (word)1 ) ;
	}
}

boolean
check ( info )
header	*info ;
{
	extern header	data_head ;

	register int	i ;

	/*
	**
	**	Note:
	**		The parameter "info" is of type "header *"
	**		NOT "header_ptr" - these definitions are
	**		different for MSDOS Compilers ("header_ptr" is huge).
	*/

	if ( info -> z_code_version != data_head.z_code_version )
		return ( FALSE ) ;
	if ( info -> mode_bits != data_head.mode_bits )
		return ( FALSE ) ;
	if ( info -> release != data_head.release )
		return ( FALSE ) ;
	for ( i = 0 ; i < 6 ; i++ )
		if ( info -> serial_no[i] != data_head.serial_no[i] )
			return ( FALSE ) ;
	if ( info -> verify_length != data_head.verify_length )
		return ( FALSE ) ;
	if ( info -> verify_checksum != data_head.verify_checksum )
		return ( FALSE ) ;
	return ( TRUE ) ;
}

Void
restore_game ()
{
	extern header		data_head ;
	extern byte_ptr		base_ptr ;
	extern word			*stack_base ;
	extern word			*stack_var_ptr ;
	extern word			*stack ;
	extern word			stack_space[] ;
	extern word			pc_page ;
	extern word			pc_offset ;
	extern word			save_blocks ;

	FILE				*save_file ;
	header				test ;
	boolean				err = FALSE ;
	word				s_offset ;
	int					i ;

	/*
	**	Restore a Saved Game
	**
	**	Swapping Saved Game Files between machines is OK provided the
	**	macro "STACK_SIZE" in file "infocom.h" is the same on each machine.
	**
	**	For the Standard & Enhanced Interpreters:
	**							"ret_value ( FALSE )" -> Save/Restore Error.
	**							"ret_value ( TRUE )"  -> Save/Restore was Ok.
	**
	**	For the PLUS Series Interpreter:
	**							"store ( (word)0 )" -> Save/Restore Error.
	**							"store ( (word)1 )" -> Save was Ok.
	**							"store ( (word)2 )" -> Restore was Ok.
	*/

	while ( ! filename () ) ;
	if (( save_file = fopen ( name,READ_STRING )) == (FILE *)0 )
	{
		if ( data_head.z_code_version <= VERSION_3 )
			ret_value ( FALSE ) ;
		else
			store ( (word)0 ) ;
		return ;
	}
	if (fread((char *)base_ptr,BLOCK_SIZE,(int)save_blocks,save_file) != save_blocks)
		err = TRUE ;

	/*
	**	Restore Stack, Stack Pointers & Program Counter
	*/

	for ( i = 0 ; i < (int)STACK_SIZE ; i++ )
		err |= ld_word ( save_file,&stack_space[i] ) ;
	err |= ld_word ( save_file,&s_offset ) ;
	stack = stack_base - s_offset ;
	err |= ld_word ( save_file,&s_offset ) ;
	stack_var_ptr = stack_base - s_offset ;
	err |= ld_word ( save_file,&pc_page ) ;
	err |= ld_word ( save_file,&pc_offset ) ;

	if ( fclose ( save_file ) )
		err = TRUE ;

	/*
	**	Check the validity of the restored game file.
	*/

	assign ( &test,base_ptr ) ;
	if (( ! err ) && check ( &test ))
	{
		init_interpreter ( FALSE ) ;
		if ( data_head.z_code_version <= VERSION_3 )
			ret_value ( TRUE );
		else
			store ( (word)2 ) ;
	}
	else
	{
		display ( "Wrong Game or Version ...\nRestarting ...\n" ) ;
		restart () ;
	}
}

/*
**	Scripting Routines and Variables.
*/

/*	Level 2 patch installed -mlk */
FILE		*script_file		= (FILE *)0 ;
byte		tmp_script_status       = 0 ;
byte_ptr	script_status_ptr       = (byte_ptr)&tmp_script_status ;

Void
init_script ()
{
	extern byte_ptr		base_ptr ;
	extern byte_ptr		script_status_ptr ;
	extern boolean		script_on ;

	script_status_ptr = (byte_ptr) &(((header_ptr)base_ptr) -> script_status) ;
	script_status_ptr++ ;
	script_on = FALSE ;
}

boolean
open_script ()
{
	extern char		name[] ;
	extern FILE		*script_file ;

	while ( ! filename () ) ;
	if (( script_file = fopen ( name,APPEND_STRING )) == (FILE *)0 )
		return ( FALSE ) ;
	return ( TRUE ) ;
}

Void
close_script ()
{
	extern FILE		*script_file ;

	if ( script_file != (FILE *)0 )
	{
		if ( fclose ( script_file ) )
			display ( "Cannot Close Script File\n" ) ;
		script_file = (FILE *)0 ;
	}
}

Void
script_char ( c )
char	c ;
{
	extern header	data_head ;
	extern FILE		*script_file ;
	extern boolean	disable_script ;
	extern boolean	script_on ;
	extern byte_ptr	script_status_ptr ;

	if ( data_head.z_code_version <= VERSION_3 )
	{
		if (( script_on ) && (( *script_status_ptr & SCRIPT_MODE_ON ) == 0 ))
		{
			script_on = FALSE ;
			data_head.script_status &= SCRIPT_MODE_OFF ;
			close_script () ;
			return ;
		}
		if (( ! script_on ) && ( *script_status_ptr & SCRIPT_MODE_ON ))
		{
			/*
			**	We must temporarily turn off the "SCRIPT_MODE" bit that
			**	is pointed to by "script_status_ptr" because "script_on"
			**	must remain "FALSE" until the script file is open and
			**	"open_script ()" calls "filename ()" which calls
			**	"read_char ()" which calls this routine which will try to
			**	open a script file by calling "open_script ()" ...
			**
			**	The "SCRIPT_MODE" bit is turned back on if the script file
			**	is successfully opened.
			*/

			*script_status_ptr &= SCRIPT_MODE_OFF ;
			if (( script_on = open_script () ) == TRUE )
			{
				*script_status_ptr |= SCRIPT_MODE_ON ;
				data_head.script_status |= SCRIPT_MODE_ON ;
			}
		}
	}

	if (( script_on ) && ( ! disable_script ) && ( c >= 6 ))
		putc ( c,script_file ) ;
}
