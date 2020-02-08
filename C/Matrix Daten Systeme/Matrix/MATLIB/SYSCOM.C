/*=============================================================
*
*	cli : MATRIX - Command Line Interpreter (System Commands)
*	---------------------------------------------------------
*
*	File :		syscom.c
*
*	Date :		07.11.91
*	Version :	
*	Company :	MATRIX Daten Systeme GmbH
*				Talstr. 16
*				7155 Oppenweiler
*
*===============================================================*/

# define ECHOflag	0x0001
# define MESGflag	0x0004
# define SYScomFlag	0x0100

# include <portab.h>
# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <math.h>
# include <ctype.h>
# include <ext.h>
# include <tos.h>

# include "global.h"
# include "command.h"
# include "error.h"
# include "text_tab.h"
# include "vt52.h"
# include "dir.h"
# include "file.h"
# include "sys_cmd.h"
# include "syscom.h"
# include "gi.h"

int		 last_error = OK ;
unsigned key_code	= 0 ;

char 	 last_include[80] = "" ;

local bool error_messages = TRUE ;

# ifndef SMALLsyscom
local int  disk_error = OK ;
# endif

VALUE p[NUMpars] ;

/* =========================================================== */
/* The following definitions MUST appear in the user program!  */

extern	void user_command_case ( int cmd, int npars,
							 	 char *argument, int *result );
extern	CMD user_cmd_table[];
/* =========================================================== */



# ifndef SMALLsyscom
/*... resolution switch ........................................*/

# define _bootdev 0x446

char boot_drive	   = 'C' ;


/*------------------------------------ set_boot_drive --------------*/
long set_boot_drive(void)
{
	boot_drive = *(int *)_bootdev + 'A' ;
	return ( 0 ) ;
}


/*------------------------------------------ set_videochip --------*/
long set_videochip ( void )
{
	*(int *)0xffff8240L = 0 ;
	*(unsigned char *)0xffff820aL &= ~ 2 ;
	return ( 0 ) ;
}


/*------------------------------------------ set_resolution --------*/
void set_resolution ( void )
{
	if ( Getrez() == 0 )	/* change resolution	*/
	{
		Setscreen ( (void *)-1, (void *)-1, 1 ) ;
		Supexec ( set_videochip ) ;
	}
}

/*------------------------------------------- long_lines -----------*/
void long_lines ( void )
{
	char temp_name[80] ;

	Supexec ( set_boot_drive ) ;
	Dgetpath ( temp_name, 0 ) ;
	if ( boot_drive == ('A'+Dgetdrv()) && *temp_name == 0 )
		set_resolution() ;
}

# define MAXsysColor	15

local int syspalette[MAXsysColor+1] ;
local bool syspal_stored = FALSE ;

/*--------------------------------------- sys_pal_set ---------------*/
bool sys_pal_set ( void )
{
	int colornum ;

	for ( colornum = 0 ; colornum <= MAXsysColor ; colornum++ )
		if ( Setcolor ( colornum, -1 ) )
			return TRUE ;

	return FALSE ;
}

/*--------------------------------------- sys_screen_off -----------*/
void sys_screen_off ( void )
{
	int colornum, *pcolval ;

	if ( sys_pal_set() )
	{	
		pcolval = syspalette ;
		for ( colornum = 0 ; colornum <= MAXsysColor ; colornum++ )
			*pcolval++ = Setcolor ( colornum, 0 ) ;
		syspal_stored = TRUE ;
	}
}

/*--------------------------------------- sys_screen_on -----------*/
void sys_screen_on ( void )
{
	int colornum, *pcolval ;

	if ( syspal_stored )
	{	
		pcolval = syspalette ;
		for ( colornum = 0 ; colornum <= MAXsysColor ; colornum++ )
			Setcolor ( colornum, *pcolval++ ) ;
	}
	else if ( ! sys_pal_set() )
	{
		Setcolor ( 0, 0x777 ) ;
		Setcolor ( 1, 0x777 ) ;
	}
}





/*------------------------------------------ delay_loop --------*/
int delay_loop ( int sec )
/* returns abort char	*/
{
	int tim ;

	for( tim = 10 * sec; tim >= 0 ; tim-- )
	{
		if ( get_cmdin_stat() )
			return ( get_cmdin_char() & 0xff ) ;
		delay ( 100 /* msec */ ) ;
	}
	return ( 0 ) ;
}


/*---------------------------------------------- do_delay ---------*/
char do_delay ( int del )
{
	if ( del > 0 )
	{
		return ( delay_loop ( del ) ) ;
	}
	else
	{
		delay ( -del ) ;
		return ( 0 ) ;
	}
}

/*.... labels ....*/


/*--------------------------------------------- find_label ---------*/
int find_label ( int *arg_num, int arg_count, char *arg_value[],
				 char *label )
{
# define LABlen 32
	int  an ;
	char labcol[LABlen] ;

	strncpy ( labcol, label, LABlen-1 ) ;
	strcat ( labcol, ":" ) ;
	for ( an = 1; an < arg_count; an++ )
	{
		if ( stricmp ( arg_value[an], labcol ) == 0 )
		{
			*arg_num = an ;
			return ( OK ) ;
		}
	}
	return ( NOargs ) ;
}


/*.... conditionals ....*/

/*------------------------------------------ skip_sequence ---------*/
int skip_sequence ( int *arg_num, int arg_count, char *arg_value[], bool skip_elsif )
{
	int  an, level ;
	char *arg ;

	level = 0 ;
	while ( ( an = ++(*arg_num) ) < arg_count )
	{
		arg = arg_value[an] ;
		if ( stricmp ( arg, "if" ) == 0 )
		{
			level ++ ;
		}
		else if ( stricmp ( arg, "elsif" ) == 0 && ! skip_elsif )
		{
			if ( level == 0 )
			{
				(*arg_num)-- ;	/* process elsif !	*/
				return ( -1 ) ;
			}
		}
		else if ( stricmp ( arg, "else" ) == 0 && ! skip_elsif )
		{
			if ( level == 0 )
				return ( OK ) ;
		}
		else if ( stricmp ( arg, "endif" ) == 0 )
		{
			if ( level == 0 )
				return ( OK ) ;
			level -- ;
		}
	}
	return ( NOargs ) ;
}


bool elsif_process = TRUE ;

/*----------------------------------- cat -----------*/
int cat ( char *name, unsigned lines )
/*
	lines		list
	-------------------
	0			whole file
	> 0			'lines' lines
*/
{
	FILE *file ;
	char line[128] ;
	int	 ix ;
	
	if ( verbose & SYScomFlag )
		printf ( "cat '%s'\n", name ) ;
	file = fopen ( name, "r" ) ;	
	if ( file != NULL )
	{
	    for ( ix = 1; lines == 0 || ix <= lines ; ix++ )
	    {
			if ( verbose & SYScomFlag )
				printf ( "%3u:", ix ) ;
	    	if ( fgets ( line, (int)sizeof(line)-1, file ) != NULL )
	    		printf ( "%s", line ) ;
	    	else
	    		break ;
	   	}
	   	fclose ( file ) ;
		return ( OK ) ;
	}
	else
		return FILEopenError ;
}

/*----------------------------------------- fhelp ------*/
void fhelp ( void)
{
	int fn ;
	
	for ( fn = 1; fn <= 10 ; fn++ )
		printf ( "%-8d", fn ) ;
	printf ( "\n" ) ;
	for ( fn = 10; fn <= 19 ; fn++ )			/* shift	*/
		printf ( "%-8s", fn_command_table[fn] ) ;
	printf ( "\n" ) ;
	for ( fn = 0; fn <= 9 ; fn++ )				/* normal	*/
		printf ( "%-8s", fn_command_table[fn] ) ;
	printf ( "\n" ) ;
}

# endif ! SMALLsyscom


# ifndef SMALLsyscom
# define ALIAS 1
# else
# define ALIAS 0
# endif

/*------------------------------------------ command_loop ----------*/
int command_loop ( int arg_count, char *arg_value[] )
{
	int	 			cmd, arg_num, result = OK,
					npars ;
	bool  do_skip ;
	char			*argument ;
	CMD				*cmdentry ;
# ifndef SMALLsyscom
# if ALIAS
	int				dum_arg_num ;
# endif ALIAS
	int				cnt, n ;
	COMMAND progpar ;
	FORvariable *fvp ;
	int call_stack[NUMcallLevels],
		call_level ;

	call_level = 0 ;
# endif

	last_error = OK ;
	
	for ( arg_num = 1; arg_num < arg_count; )
	{
# if ALIAS
		dum_arg_num = arg_num - 1 ;
		result = get_strarg ( &dum_arg_num, arg_count,
							  arg_value, &argument ) ;
# else
		argument = arg_value[arg_num] ;
# endif


		if ( *argument != 0
				&& *(strchr(argument,0)-1) == ':' )
		{
			do_skip = FALSE ;
			if ( verbose & SYScomFlag )
				printf ( "- at label '%s'\n", argument ) ;
			arg_num++ ;
		}
		else
		{
			do_skip = TRUE ;
			if ( result == OK )
			{
				if ( verbose & SYScomFlag )
					printf ( "\n- command : %s = ", argument ) ;
	
				/* === System commands === */
				cmd = cmd_look_up ( sys_cmd_table, argument, &cmdentry ) ;
				if ( cmd == CMDillegal ) 
					/* === User commands === */
					cmd = cmd_look_up ( user_cmd_table, argument, &cmdentry ) ;
	
				if ( verbose & SYScomFlag )
					printf ( " %d\n", cmd ) ;
	
				if ( cmd != CMDillegal && cmdentry != NULL )
				{
					result = scan_parameters ( cmdentry,
									&arg_num, arg_count, arg_value,
									p, &npars, NUMpars ) ;
				}
				else
					result = OK ;
			}
			else
			{
				cmd = CMDillegal ;
				result = OK ;
			}
			
			if ( result == OK )
			{
				if ( abs ( cmd ) >= FIRSTuser )		/* ==== User Commands ==== */
					user_command_case ( cmd, npars, argument, &result );
				else 
				{	/* ==== System Commands ==== */
					switch ( cmd )
	    			{
	case  CMDnop :		break ;

# ifndef SMALLsyscom
	case +CMDerrors :	error_messages = TRUE ;
						break ;
	case -CMDerrors :	error_messages = FALSE ;
						break ;

	case +CMDhistory :	switch_history ( TRUE ) ;
						break ;
	case -CMDhistory :	switch_history ( FALSE ) ;
						break ;

	case  CMDfhelp :	fhelp() ;
						break ;

	case  CMDfor :		fvp = get_forvar ( p[0].v ) ;
						*(p[0].v) = p[1].li ;
						fvp->step = p[2].li ;
						fvp->end  = p[3].li ;
						fvp->label   = arg_num ;
						fvp->defined = 1 ;
						break ;						
	
	case  CMDendfor :	fvp = get_forvar ( p[0].v ) ;
						if ( fvp->defined )
						{
							*(p[0].v) += fvp->step ;
							if (   ( fvp->step >= 0 && *(p[0].v) <= fvp->end )   /* up	*/
						  		|| ( fvp->step <= 0 && *(p[0].v) >= fvp->end ) ) /* down	*/
							{
								arg_num = fvp->label ;
								do_skip = FALSE ;
							}
							else
								fvp->defined = 0 ;
						}
						else
							result = FORvarUndef ;
						break ;						
	
	
	case  CMDset :		if ( verbose & SYScomFlag )
							printf ( "- set &var $%p to %ld\n",
										 p[0].v, p[1].li ) ;
						*(p[0].v) = p[1].li ;
						break ;

	case  CMDprintvalue:if ( radix == 16 )
						{
							for ( cnt = 0; cnt < npars-1; cnt++ )
								printf ( "$%08lx ", p[cnt].li ) ;
							printf ( "$%08lx\n", p[cnt].li ) ;
						}
						else
						{
							for ( cnt = 0; cnt < npars-1; cnt++ )
								printf ( "%ld ", p[cnt].li ) ;
							printf ( "%ld\n", p[cnt].li ) ;
						}
						break ;
	
	
	case  CMDcall :		if ( call_level < NUMcallLevels )
						{
							if ( verbose & SYScomFlag )
								printf ( "- call '%s'\n", p[0].s ) ;
							call_stack [ call_level ] = arg_num ;
							result = find_label ( &arg_num, arg_count, arg_value,
													p[0].s ) ;
							if ( result == OK )
							{
								do_skip = FALSE ;
								call_level++;
							}
						}
						else
							result = CALLstackOver ;
						break ;
	
	case  CMDreturn :	if ( verbose & SYScomFlag )
							printf ( "- RETURN : call_level %d\n", call_level ) ;
						if ( call_level <= 0 )
						{
							result = CALLstackUnder ;
							break ;
						}
						arg_num = call_stack [ --call_level ] ;
						do_skip = FALSE ;
						break ;
	
	case  CMDgoto :		if ( verbose & SYScomFlag )
							printf ( "- goto '%s'\n", p[0].s ) ;
						result = find_label ( &arg_num, arg_count, arg_value,
												p[0].s ) ;
						if ( result == OK )
							do_skip = FALSE ;
						break ;

	case  CMDif :		if ( verbose & SYScomFlag )
							printf ( "- if %ld\n", p[0].li ) ;
		cmd_if:			elsif_process = FALSE ;
						if ( p[0].li == 0 )
						{
							result = skip_sequence ( &arg_num, arg_count,
													 arg_value, 0 ) ;
							if ( result == -1 )
							{
								elsif_process = TRUE ;
								result = OK ;
							}
						}
						/* here we are after 'if <cond>', 'else' or 'endif'	*/
						break ;
	
	case  CMDelsif:		if ( elsif_process )
						{
							if ( verbose & SYScomFlag )
								printf ( "- elsif %ld\n", p[0].li ) ;
							goto cmd_if ;
						}
						else
							result = skip_sequence ( &arg_num, arg_count,
													 arg_value, 1 ) ;
						break ;

	case  CMDelse :		/* only reached if <cond> was true	*/
						result = skip_sequence ( &arg_num, arg_count,
													 arg_value, 0 ) ;
						break ;
	
	case  CMDendif :	/* end of conditional 'if' or 'else' case	*/
						break ;
	
	case  CMDdelay :	if ( do_delay ( p[0].i ) == ' ' )
							return ( OK ) ;
						break ;

	case  CMDexec :		switch ( npars )
						{
					case 0 :	result = NOargs ;
								break ;
					case 1 :	/* no commandline parameter	*/
								progpar.command_tail[0] = 0 ;
								progpar.length = 0 ;
								break ;
					case 2 :	strncpy ( progpar.command_tail, p[1].s, 126 ) ;
								progpar.length = strlen ( progpar.command_tail ) ;
								break ;
					default :	result = TOOmanyPar ;
								break ;
						}
						if ( result == OK )
						{
							if ( Pexec ( 0, p[0].s, (COMMAND *)&progpar, "" ) != 0 )
								result = EXECerror ;
						}
						break ;

	
	case  CMDkbshift :	if ( Kbshift(-1) != 0 )
							interpret_commands ( "- kbshift ? >", command_loop ) ;
						break ;
	
	case  CMDdir :		switch ( npars )
						{
					case 0 :	result = dir_list ( "", 0 ) ;
								break ;
					case 1 :	result = dir_list ( p[0].s, 0 ) ;
								break ;
					case 2 :	result = dir_list ( p[0].s, p[1].u ) ;
								break ;
						}
						disk_error = result ;
						break ;
	
	case  CMDcopy :		result = NOargs ;
						if ( npars >= 2 )
						{
							if ( verbose == ECHOflag )
								printf ( " - copy %s -> %s\n", p[0].s, p[1].s ) ;
							if ( npars < 3 )
								disk_error = result = file_copy ( p[0].s, p[1].s, 0 ) ;
							else
								disk_error = result = file_copy ( p[0].s, p[1].s, p[1].u ) ;
						}
						break ;
	
	case  CMDrename :	if ( verbose == ECHOflag )
							printf ( " - rename %s -> %s\n", p[0].s, p[1].s ) ;
						disk_error = result = file_rename ( p[0].s, p[1].s ) ;
						break ;

	case  CMDmkdir :	if ( verbose == ECHOflag )
							printf ( " - mkdir %s\n", p[0].s ) ;
						disk_error = result = make_dir ( p[0].s ) ;
						break ;

	case  CMDrmdir :	disk_error = result = remove_dir ( p[0].s ) ;
						break ;

	case  CMDdel :		disk_error = result = file_delete ( p[0].s ) ;
						break ;

	case  CMDexist :	disk_error = result = FileExists ( p[0].s, FALSE ) ? OK : NotOK ;
						break ;

	case  CMDcd :		switch ( npars )
						{
				case 2 :	p[0].s[0] = p[1].u ;
						/*	continue ;	*/
				case 1 :	disk_error = result = cd ( p[0].s ) ;
							break ;
				case 0 :	disk_error = result = pwd() ;
							break ;
						}
						break ;
	
	case  CMDpwd :		disk_error = result = pwd() ;
						break ;
	
	case  CMDecho :		n = stricmp ( p[0].s, "-n" ) == EQUAL ? 1 : 0 ;
						for ( cnt = n; cnt < npars-1; cnt++ )
							printf ( "%s ", p[cnt].s ) ;
						printf ( "%s", p[cnt].s ) ;
						if ( n == 0 )
							printf ( "\n" ) ;
						break ;

	case  CMDcat :		disk_error = result = cat ( p[0].s, 0 ) ;
						break ;
	
	case  CMDhead :		if ( npars == 1 )
							disk_error = result = cat ( p[0].s, 1 ) ;
						else
							disk_error = result = cat ( p[0].s, p[1].u ) ;
						break ;
	
	case  CMDhelp :		if ( npars == 0 )
						{
							printf ("System commands :\n");
							cnt = cmd_help_all ( sys_cmd_table, 2 ) ;
							if ( cnt != 0 )
							{
								printf ("User commands :\n");
								cmd_help_all ( user_cmd_table, cnt ) ;
							}
						}
						else if ( npars == 1 )
						{
							if ( cmd_help ( sys_cmd_table, p[0].s ) == CMDillegal )
								cmd_help ( user_cmd_table, p[0].s ) ;
						}
						break ;
	
	case  CMDcli :		interpret_commands ( "- cmd ? >", command_loop ) ;
						break ;

# endif
	
	case  CMDinclude :	if ( npars < 1 )
							break ;
						if ( verbose & SYScomFlag )
								printf ( "\n- include %s\n", p[0].s ) ;
						strcpy ( last_include, p[0].s ) ;
						result = interpret_list ( p[0].s, command_loop ) ;
						break ;
	
# ifndef SMALLsyscom

	case  CMDkey :		if ( verbose )
							printf ( "- press any key !\n" ) ;
						key_code = get_cmdin_char() ;
						if ( verbose & SYScomFlag )
							printf ( "- key code : $%04x\n", key_code ) ;
						break ;
	
	case  CMDquit :		return ( CMDabort ) ;
	
	case  CMDexit :		exit ( last_error ) ;
						break ;
# endif	
	case  CMDradix :	if ( npars == 1 )
						{
							switch ( tolower ( *(p[0].s) ) )
							{
					case 'b'	:	radix =  2 ; break ;
					case 'o'	:	radix =  8 ; break ;
					case 'd'	:	radix = 10 ; break ;
					case 'h'	:	radix = 16 ; break ;
					default		:	printf (
							"* illegal input : '%s', use 'h', 'b', 'o' or 'd'\n",
											 p[0].s );
							}
						}
						printf ( "radix = %u\n", radix ) ;
						break ;
	
	case -CMDverbose :
	case +CMDverbose :	if ( npars == 1 )
							verbose = p[0].i ;
						else
							verbose += cmd > 0 ? +1 : -1 ;
						if ( verbose & MESGflag )
							printf ( "verbose = %d\n", verbose );
						break ;
						
	case  CMDhome :		switch ( npars )
						{
				case 0 : 	printf ( CURSORhome ) ;
							break ;
				case 1 :	p[1].i = 0 ;	/* y - pos	*/
				case 2 :	printf ( CURSORset "%c%c",
								 ' ' + p[1].u, ' ' + p[0].u ) ;
							break ;
						}
						break ;

# ifndef SMALLsyscom
	case +CMDsysscreen:	sys_screen_on() ;
						break ;

	case -CMDsysscreen:	sys_screen_off() ;
						break ;

	case  CMDwide :		long_lines() ;
						break ;

	case +CMDprompt :	if ( npars == 1 )
						{
							set_prompt_line ( p[0].i ) ;
							break ;
						}
						else /* : */
	case -CMDprompt :	set_prompt_line ( -1 ) ;
						break ;
						
	case  CMDclear :	printf ( CLEARscreen ) ;
						break ;
	
	case  CMDdefine:	if ( npars == 0 )
							show_defs ();
						else
						{
							if ( npars > 2 )
								result = TOOmanyPar ;
							else if ( npars == 1 )
								result = NOargs ;
							else
							{
								result = set_defvar ( strupr ( p[0].p ),
													  p[1].lu );
							}
						}
						break ;
	
	case  CMDalias:		if ( npars == 0 )
							show_defs ();
						else
						{
							if ( npars > 2 )
								result = TOOmanyPar ;
							else if ( npars == 1 )
								result = NOargs ;
							else if ( stricmp ( p[0].p, "undef" ) == EQUAL )
								result = ILLcommand ; 
							else
							{
								if ( verbose & SYScomFlag )
									printf ( "- alias %s as \'%s\'\n",
										 p[0].p, p[1].s ) ;
								result = set_defstr ( strupr ( p[0].p ),
													  p[1].s );
							}
						}
						break ;
	
	case  CMDundef:		result = undefvar ( p[0].p ) ;
						break ;

	case  CMDpeek :		if ( npars == 1 )
							p[1].u = 1 ;
						switch ( p[1].u )
						{
				case 1 :	printf ( "@$%08lx = $%02x\n",
										p[0].lu, *(byte *)p[0].lu ) ;
							break ;
				case 2 :	printf ( "@$%08lx = $%04x\n",
										p[0].lu, *(uword *)p[0].lu ) ;
							break ;
				case 4 :	printf ( "@$%08lx = $%08lx\n",
										p[0].lu, *(ulong *)p[0].lu ) ;
							break ;
						}
						break ;
					
	case   CMDpoke :	if ( npars == 2 )
							p[2].u = 1 ;
						switch ( p[2].u )
						{
				case 1 :	*(byte  *)p[0].lu = (byte)p[1].lu ;
							break ;
				case 2 :	*(uword *)p[0].lu = (uword)p[1].lu ;
							break ;
				case 4 :	*(ulong *)p[0].lu = p[1].lu ;
							break ;
						}
						break ;
					
	case -CMDsound :	switch ( npars )
						{
				case 0 :	gi_off ( 0 ) ;
							gi_off ( 1 ) ;
							gi_off ( 2 ) ;
							break ;
				case 1 :	gi_off ( p[0].u ) ;
							break ;
						}
						break ;

	case +CMDsound :	switch ( npars )
						{
				case 0 :	gi_on ( 0 ) ;
							gi_on ( 1 ) ;
							gi_on ( 2 ) ;
							break ;
				case 1 :	gi_on ( p[0].u ) ;
							break ;
				case 2 :	gi_tone ( 0, p[0].u, p[1].u ) ;
							break ;
				case 3 :	gi_tone ( p[2].u, p[0].u, p[1].u ) ;
							break ;
				case 4 :	gi_tone ( p[2].u, p[0].u, p[1].u ) ;
							do_delay ( p[3].i ) ;
							gi_off ( p[2].u ) ;
							break ;
						}
						break ;
				
# endif ! SMALLsyscom
						
	default  :			result = ILLcommand ;
						break ;
	
					} /* switch */
				} /* else system command */
			} /* if result == OK */
			
			if ( do_skip )
				skip_behind_cmd ( &arg_num, arg_count, arg_value ) ;
	
			if ( result != OK && error_messages )
				(*uprintf) ( "* %-8s # %2d : %s\n",
					argument, result, get_text ( result ) ) ;

			last_error = result ;
		}

# ifndef SMALLsyscom
		switch ( (int)Kbshift(-1) )
		{
case 3 :	interpret_commands ( "- 2*shift ? >", command_loop ) ;
			break ;
		}
# endif
	} /* for arg_num */
	
	return ( last_error ) ;

} /* command_loop */


# ifndef SMALLsyscom
/*... user functions ...*/

/*--------------------------------------------------- kb_shift -----*/
long kb_shift ( void )
{
	return ( Kbshift(-1) ) ;
}

/*--------------------------------------------------- kb_hit -----*/
long kb_hit ( void )
{
	return ( get_cmdin_stat() ) ;
}

/*--------------------------------------------------- kb_in -----*/
long kb_in ( void )
{
	return ( get_cmdin_char() ) ;
}

# endif ! SMALLsyscom


/*----------------------------------------------- syscom_init ------*/
void syscom_init ( void )
{
# ifndef SMALLsyscom
	set_defvar ( "error",		(long)&last_error ) ;
	set_defvar ( "diskerror",	(long)&disk_error ) ;
	set_defvar ( "keycode",	 	(long)&key_code ) ;
	set_defvar ( "keyshift",	(long)kb_shift ) ;
	set_defvar ( "keyhit",		(long)kb_hit ) ;
	set_defvar ( "keyin",		(long)kb_in ) ;
# endif
}
