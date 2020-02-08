/*	command.c	/	15.07.91	/	MATRIX	/	WA	*/
/*			   /    25.11.91				    HG  */

# define TEST 0

# define SETonly		0x0002		/* verbose flags	*/
# define COMMANDflag	0x0200

# define ADD_INPUT 1

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <tos.h>

# include "global.h"
# include "error.h"
# include "ascii.h"
# include "scancode.h"
# include "vt52.h"

# include "command.h"

int radix = 0 ;

/*....... history ....*/


# define HISTObuffer struct HISTO
typedef HISTObuffer {
	HISTObuffer *back, *forw ;
	char *string ;
} ;

HISTObuffer *history = NULL ;
bool histo_on = TRUE ;


/*----------------------------------------------- switch_history ---*/
bool switch_history ( bool on )
{
	bool old ;
	
	old = histo_on ;
	histo_on = on ;
	return old ;
}


/*------------------------------------------------- list_history ---*/
void list_history ( void )
{
	HISTObuffer *hb ;
	int num ;
	
	if ( history != NULL )
	{
		hb = history ;
		num = 0 ;
		do
		{
			printf ( "%2d : %s\n", ++num, hb->string ) ;
			hb = hb->forw ;
		}
		while ( hb != history ) ;
 	}
}


/*------------------------------------------ substitute ---*/
void substitute ( char *s, char from, char to )
{
	char *sp ;
	
	sp = s ;
	while ( ( sp = strchr ( sp, from ) ) != NULL )
		*sp++ = to ;
}

/*---------------------------------------------- add_cmd ---*/
void add_cmd ( char *s )
{
	HISTObuffer *hb ;
	char		*hs ;
	
	hs = NULL ;

	substitute ( s, '\t', ' ' ) ;
	
	if ( *s != EOS )	/* save only non-empty commands		*/
	{
		if ( history != NULL )
		{
			hb = history ;
			do
			{
				if ( strcmp ( s, hb->string ) == 0 ) /* avoid dup entry	*/
				{
					if ( hb->forw == history )
						return ;	/* no sequences of identical strings	*/
					hs = hb->string ;
					break ;
				}
				hb = hb->forw ;
			}
			while ( hb != history ) ;
		}
		
		hb = malloc ( sizeof ( HISTObuffer ) ) ;
		if ( hb != NULL )
		{
			if ( hs == NULL )
			{
				hb->string = malloc ( strlen(s)+1 ) ;
				if ( hb->string == NULL )
				{
					free ( hb ) ;
					return ;
				}
				strcpy ( hb->string, s ) ;
			}
			else
				hb->string = hs ;
				
/*
on entry, s = X :
						history ( points to the entry selected at next DOWN )
				  		  |
				  		  v
		+---+	+---+	+---+	+---+
	<---|A	|<--|B	|<--|C	|<--|D	|<--	back	
	--->|	|-->|	|-->|	|-->|	|-->	forw
		+---+	+---+	+---+	+---+
on exit, s = X :	  ^ 
					 |X|
*/
			if ( history != NULL )
			{
# if 1
				hb->back	= history->back ;
				hb->forw	= history ;
			
				history->back  = hb ;
				hb->back->forw = hb ;
# else	/* old	*/
				hb->back	= history ;
				hb->forw	= history->forw ;
			
				history->forw = hb ;
				history		= hb->forw ;
				history->back = hb ;
# endif
			}
			else
			{
				history		= hb ;
				hb->back	= hb ;
				hb->forw 	= hb ;
			}
		}
	}	
}


/*---------------------------------------------------- clear_cmd ---*/
void clear_cmd ( char *s, char **spos )
{
	while ( (*spos)-- > s )
		printf ( "\033D" ) ;
	printf ( "\033K" ) ;

	*spos = s ;
	*s = EOS ;
}



/*-------------------------------------------------- get_histcmd ---*/
void get_histcmd ( char *s, char **spos )
{
	char *sp ;
	
	if ( history != NULL )
	{
		clear_cmd ( s, spos ) ;

		sp = strcpy ( s, history->string ) ;
		while ( *sp != EOS )
			putchar ( *sp++ ) ;
		*spos = sp ;
 	}
}


/*---------------------------------------------- change_cmd ---*/
void change_cmd ( char *s, char **spos, int dir )
{
	if ( history != NULL )
	{
		if ( dir > 0 )
			history = history->forw ;
		else
			history = history->back ;
			
		get_histcmd ( s, spos ) ;
 	}
}

/*---------------------------------------------- ins_cmd_chr ---*/
void ins_cmd_chr ( char **spos, char c, bool insert )
{
	char *sp ;

	if ( c >= ' ' && c < 0x7f )
 	{
 		if ( insert )
 		{					/* make room	*/
 			for ( sp = (*spos)+strlen(*spos) ; sp >= *spos ; sp-- )
 				*(sp+1) = *sp ;
 		}
 		else
 		{
 			if ( **spos == EOS )	/* shift EOS	*/
		 		*(*spos+1) = EOS ;
 		}

 		**spos = c ;
		printf ( "\033j%s\033k\033C", *spos ) ;
		(*spos) += 1 ;
	}										
}


/*....... command interpreter ....*/

# define MAXcliLevel 10

int call_level = 0 ;
int cmdin_device =  2 ;		/* CONsole	*/
int prompt_line  = -1 ;		/* scroll	*/
POLL_FCT *poll_fct = NULL ;
FN_COMMAND_TABLE *fn_command_table = NULL ;

/*--------------------------------------------- set_prompt_line ----*/
void set_prompt_line ( int plin )
{
	prompt_line = plin ;
}

/*--------------------------------------------- set_poll_fct -------*/
void set_poll_fct ( POLL_FCT *pfct )
{
	poll_fct = pfct ;
}

/*---------------------------------------------- get_cmdin_char ----*/
unsigned get_cmdin_char ( void )
{
	long lc ;

	lc = Bconin ( cmdin_device ) ;

	if ( lc & 0x00ff )
		return (unsigned) ( (lc&0xff) ) ;
	else
		return (unsigned) ( (lc>>8) | (lc&0xff) ) ;
}

/*---------------------------------------------- get_cmdin_stat ----*/
bool get_cmdin_stat ( void )
{
	return ( Bconstat ( cmdin_device ) != 0 ) ;
}


/*---------------------------------------------- get_cmdstring ---*/
void get_cmdstring ( char *prompt, char *s, int maxl )
{
	unsigned c, alt_c;
	char *s_pos, *fns ;
	bool insert ;
	long loop ;
	int fn ;
	
	insert = TRUE ;
	
	s_pos = s ;
	*s_pos = EOS ;

	if ( prompt_line >= 0 )
		printf ( CURSORset "%c ", ' ' + prompt_line ) ;
	printf ( CURSORon "%d %s" ERASEeol, call_level, prompt ) ;
		
	for ( loop = 0 ; ! get_cmdin_stat(); )
	{
		if ( poll_fct != NULL )
		{
			while ( ! get_cmdin_stat() )
				(*poll_fct)( loop++ ) ;
		}

		c = get_cmdin_char () ;

		alt_c = 'z' ;
 		switch ( c )
		{
 case ALT_A :		alt_c-- ;
 case ALT_B :		alt_c-- ;
 case ctrl('C') :
 case ALT_C :		alt_c-- ;
 case ALT_D :		alt_c-- ;
 case ALT_E :		alt_c-- ;
 case ALT_F :		alt_c-- ;
 case ALT_G :		alt_c-- ;
 case ALT_H :		alt_c-- ;
 case ALT_I :		alt_c-- ;
 case ALT_J :		alt_c-- ;
 case ALT_K :		alt_c-- ;
 case ALT_L :		alt_c-- ;
 case ALT_M :		alt_c-- ;
 case ALT_N :		alt_c-- ;
 case ALT_O :		alt_c-- ;
 case ALT_P :		alt_c-- ;
 case ALT_Q :		alt_c-- ;
 case ALT_R :		alt_c-- ;
 case ALT_S :		alt_c-- ;
 case ALT_T :		alt_c-- ;
 case ALT_U :		alt_c-- ;
 case ALT_V :		alt_c-- ;
 case ALT_W :		alt_c-- ;
 case ctrl('X') :
 case ALT_X :		alt_c-- ;
 case ALT_Y :		alt_c-- ;
 case ALT_Z :
 
					if ( strlen(s) < maxl )
 						ins_cmd_chr ( &s_pos, alt_c, insert ) ;
 					printf ( CURSORoff ) ;
					return ;

 case SHFT_F1  :
 case SHFT_F2  :
 case SHFT_F3  :
 case SHFT_F4  :
 case SHFT_F5  :
 case SHFT_F6  :
 case SHFT_F7  :
 case SHFT_F8  :
 case SHFT_F9  :
 case SHFT_F10 :	fn = ( c - SHFT_F1 ) / 0x100 + 10 ;  /* map S-F1 -> F11	*/
					goto exec_fn ;
 case F1  :
 case F2  :
 case F3  :
 case F4  :
 case F5  :
 case F6  :
 case F7  :
 case F8  :
 case F9  :
 case F10 :			fn = ( c - F1 ) / 0x100 ;  /* map S-F1 -> F11	*/
	exec_fn:
 					if ( fn_command_table == NULL )
 						break ;

					fns = (*fn_command_table)[ fn ] ;
 					if ( fns == NULL )
 						break ;
					while ( *fns != 0 && strlen(s) < maxl )
 						ins_cmd_chr ( &s_pos, *fns++, insert ) ;
					printf ( CURSORoff ) ;
					return ;

 case ESC :			clear_cmd ( s, &s_pos ) ;
 					break ;
 case RETURN :	
 case ENTER :	
 case CR :
 case LF :			if ( histo_on )
 						add_cmd ( s ) ;
 					printf ( CURSORoff ) ;
 					return ;

 case CUR_DOWN :	change_cmd ( s, &s_pos, +1 ) ;
 					break ;
 
 case CUR_UP :		change_cmd ( s, &s_pos, -1 ) ;
 					break ;
 
 case CUR_LEFT :	if ( s_pos > s )
 					{
 						printf ( "\033D" ) ;
 						s_pos-- ;
 					}
 					break ;
 case CUR_RIGHT :	if ( *s_pos != EOS )
 					{
 						printf ( "\033C" ) ;
 						s_pos++ ;
 					}
 					break ;
 case HOME :		while( s_pos > s )
 					{
 						printf ( "\033D" ) ;
 						s_pos-- ;
 					}
 					break ;
 
 case '\b' :
 case BACKSPACE :	if ( s_pos <= s )
 						break ;
 					printf ( "\033D" ) ;
 					s_pos-- ;
 				/*	cont ;	*/
 case '\x7f' :
 case DELETE :		if ( *s_pos != EOS )
 					{
 						strcpy ( s_pos, s_pos+1 ) ;
 						printf ( "\033j%s \033k", s_pos ) ;
 					}
 					break ;
 
 case INSERT :		insert = ! insert ;
  					break ;

 case UNDO :		get_histcmd ( s, &s_pos ) ; 
 					break ;

 case HELP :		if (  Kbshift(-1) & 0x03 )
 					{
 						printf ( "\r\033K" ) ;
 						list_history() ;
						printf ( "\033e%d %s%s"  ERASEeol, call_level, prompt, s ) ;
 					}
 					else
 					{
 						printf ( "\r\033K\033p"
"ALT-alpha ESC RETURN < > ^ v BACK HOME DEL INS UNDO (SHIFT-)HELP"
							"\033q\n" ) ;
						printf ( CURSORon "%d %s%s"  ERASEeol,
										 call_level, prompt, s ) ;
					}
 					break ;

 case NUL :			break ;

 default :			if ( strlen(s) < maxl )
 						ins_cmd_chr ( &s_pos, c, insert ) ;
  					break ;
 		}
 	}
}


/*-------------------------------------------- input_commands ------*/
void interpret_commands ( char *prompt, CMDloop *cmd_loop )
{
# define CMDmaxLng	128
	char command[CMDmaxLng+1] ;

	if ( call_level < MAXcliLevel )
	{
		call_level++ ;	
		for(;;)
 		{
 			get_cmdstring ( prompt, command, CMDmaxLng ) ;
 			printf ( "\n" ERASEeol ) ;
 			if ( interpret_string ( command, cmd_loop ) == CMDabort )
				break ;
 		}
		call_level-- ;
	}
	else
		printf ( "* too many CLI levels!\n"); 	
}

/*................ i o .............................................*/


long back_pars[10] = {
	0, 0, 0, 0,	 0, 0, 0, 0,  0, 0 } ;

/*------------------------------------------------ io_xy -----------*/
void io_xy ( char *name, XY *val, int npars )
{
	if ( npars > 0 )
	{
		val->x = p[0].u ;
		if ( npars == 2 )
			val->y = p[1].u ;
		back_pars[0] = val->x ;
		back_pars[1] = val->y ;
		if ( ! verbose )
			return ;
	}
	back_pars[0] = val->x ;
	back_pars[1] = val->y ;
	if ( ( verbose & SETonly ) == 0 )
		printf ( "%s : %d = $%04x / %d = $%04x\n", name,
					val->x, val->x, val->y, val->y ) ;
}

/*------------------------------------------------- io_u -----------*/
void io_u ( char *name, unsigned *val, int npars )
{
	if ( npars == 1 )
	{
		*val = p[0].u ;
		back_pars[0] = *val ;
		if ( ! verbose )
			return ;
	}
	back_pars[0] = *val ;
	if ( ( verbose & SETonly ) == 0 )
		printf ( "%s = %u = $%04x\n", name, *val, *val ) ;
}

/*------------------------------------------------- io_i -----------*/
void io_i ( char *name, int *val, int npars )
{
	if ( npars == 1 )
	{
		*val = p[0].i ;
		back_pars[0] = *val ;
		if ( ! verbose )
			return ;
	}
	back_pars[0] = *val ;
	if ( ( verbose & SETonly ) == 0 )
		printf ( "%s = %i = $%04x\n", name, *val, *val ) ;
}

/*------------------------------------------------- io_li ----------*/
void io_li ( char *name, long *val, int npars )
{
	if ( npars == 1 )
	{
		*val = p[0].li ;
		back_pars[0] = *val ;
		if ( ! verbose )
			return ;
	}
	back_pars[0] = *val ;
	if ( ( verbose & SETonly ) == 0 )
		printf ( "%s = %li = $%08lx\n", name, *val, *val ) ;
}

/*------------------------------------------------- io_lu ----------*/
void io_lu ( char *name, ulong *val, int npars )
{
	if ( npars == 1 )
	{
		*val = p[0].lu ;
		back_pars[0] = *val ;
		if ( ! verbose )
			return ;
	}
	back_pars[0] = *val ;
	if ( ( verbose & SETonly ) == 0 )
		printf ( "%s = %lu = $%08lx\n", name, *val, *val ) ;
}


/*.... argument handling ....*/

typedef long LPROC(void);

/*------------------------------------------ get_lexpr -------------------*/
int get_lexpr ( int *arg_num, int arg_count,
						char *arg_value[], long *lres )
{
	char *op ;
	long l1 ;
	int an, opi ;
	int result ;
	
	result = get_larg ( arg_num, arg_count, arg_value, lres ) ;
	if ( result == OK )
	{
		if ( verbose & COMMANDflag )
			printf ( "<%ld> ", *lres ) ;
		while ( ( an = (*arg_num)+1 ) < arg_count )
		{
			op = arg_value[an] ;
			if (      strcmp ( op, "+"  ) == 0 ) opi = 1 ;	/* binaer	*/
			else if ( strcmp ( op, "-"  ) == 0 ) opi = 2 ;
			else if ( strcmp ( op, "*"  ) == 0 ) opi = 3 ;
			else if ( strcmp ( op, "/"  ) == 0 ) opi = 4 ;
			else if ( strcmp ( op, "%"  ) == 0 ) opi = 5 ;
			else if ( strcmp ( op, "==" ) == 0 ) opi = 6 ;
			else if ( strcmp ( op, "!=" ) == 0 ) opi = 7 ;
			else if ( strcmp ( op, "<"  ) == 0 ) opi = 8 ;
			else if ( strcmp ( op, ">"  ) == 0 ) opi = 9 ;
			else if ( strcmp ( op, "<=" ) == 0 ) opi = 10 ;
			else if ( strcmp ( op, ">=" ) == 0 ) opi = 11 ;
			else if ( strcmp ( op, "&"  ) == 0 ) opi = 12 ;
			else if ( strcmp ( op, "|"  ) == 0 ) opi = 13 ;
			else if ( strcmp ( op, "&&" ) == 0 ) opi = 14 ;
			else if ( strcmp ( op, "||" ) == 0 ) opi = 15 ;
			else if ( strcmp ( op, ":" ) == 0 )  opi = 16 ;	/* long Y : X */
			else if ( strcmp ( op, "<<" ) == 0 ) opi = 17 ;
			else if ( strcmp ( op, ">>" ) == 0 ) opi = 18 ;

			else if ( strcmp ( op, "@"   ) == 0 ) opi = 20 ;	/* unaer	*/
			else if ( strcmp ( op, "@b"  ) == 0 ) opi = 21 ;
			else if ( strcmp ( op, "@w"  ) == 0 ) opi = 20 ;
			else if ( strcmp ( op, "@l"  ) == 0 ) opi = 22 ;
			else if ( strcmp ( op, "()"  ) == 0 ) opi = 23 ;
			else if ( strcmp ( op, "~"   ) == 0 ) opi = 24 ;
			else
				return ( OK ) ;	/* expression end */

			if ( verbose & COMMANDflag )
				printf ( "<%s> ", op ) ;

			*arg_num = an ;

			if ( opi < 20 )
			{
				result = get_larg ( arg_num, arg_count, arg_value, &l1 ) ;
				if ( result != OK )
					return ( result ) ;
				if ( verbose & COMMANDflag )
					printf ( "<%ld> ", l1 ) ;
			}

			switch ( opi )
			{
	case 1 :	*lres += l1 ;	break ;
	case 2 :	*lres -= l1 ;	break ;
	case 3 :	*lres *= l1 ;	break ;
	case 4 :	if ( l1 != 0 ) *lres /= l1 ;	break ;
	case 5 :	if ( l1 >  0 ) *lres %= l1 ;	break ;
	case 6 :	*lres = *lres == l1 ;	break ;
	case 7 :	*lres = *lres != l1 ;	break ;
	case 8 :	*lres = *lres <  l1 ;	break ;
	case 9 :	*lres = *lres >  l1 ;	break ;
	case 10 :	*lres = *lres <= l1 ;	break ;
	case 11 :	*lres = *lres >= l1 ;	break ;
	case 12 :	*lres = *lres &  l1 ;	break ;
	case 13 :	*lres = *lres |  l1 ;	break ;
	case 14 :	*lres = *lres && l1 ;	break ;
	case 15 :	*lres = *lres || l1 ;	break ;
	case 16 :	*lres = (*lres<<16)|(l1&0xffffL) ;	break ;
	case 17 :	*lres = *lres << l1 ;	break ;
	case 18 :	*lres = *lres >> l1 ;	break ;
	
	case 20 :	*lres = *(int *)*lres ;				break ;
	case 21 :	*lres = *(byte *)*lres ;			break ;
	case 22 :	*lres = *(long *)*lres ;			break ;
	case 23 :	*lres = (**(LPROC **)lres)() ;		break ;
	case 24 :	*lres = ~ *lres ;					break ;
			}
			if ( verbose & COMMANDflag )
				printf ( " == <%ld> ", *lres ) ;
		} /*- while -*/
		return ( OK ) ;
	}
	else
		return ( result ) ;
}

/*------------------------------------------ get_iexpr --------------*/
int get_iexpr ( int *arg_num, int arg_count,
			 	  char *arg_value[], int *i )
{
	int result ;
	long l ;

	result = get_lexpr ( arg_num, arg_count, arg_value, &l ) ;
	if ( result == OK )
	{
		if ( MINint <= l && l <= MAXint )
		{
			*i = (int) l ;
			return ( OK ) ;
		}
		else
			return ( RANGEerror ) ;
	}
	else
		return ( result ) ;
}





/*... variables ...*/

# define NUMvars 'z'-'a'+1

FORvariable for_variables[NUMvars] ;
long variables[NUMvars] ;

/*------------------------------------------ clear_variables -------------*/
void clear_variables ( void )
{
	int i ;
	long *vp ;
	FORvariable *fvp ;

	vp = variables ;
	fvp = for_variables ;
	for ( i = 0; i < NUMvars; i++ )
	{
		*vp++ = 0 ;
		
		fvp->step		=    1 ;	/* 'endless' loop	*/
		fvp->end 		= 9999 ;
		fvp->label		=    1 ;
		fvp->defined	=	 0 ;
		fvp++ ;
	}
}


/*------------------------------------------ get_forvar ------------*/
FORvariable *get_forvar ( long *varref )
{
	return ( &for_variables [ varref - variables ] ) ;
}


/*------------------------------------------ more  -----------------*/
char more ( int *line )
{
	char c = '\0';
	
	if ( ( *line % LASTline ) == 0 )
	{
		printf ( "- more q/c/Return/' ' -" CURSORon ) ;
		c = tolower ( (char)Bconin ( 2 ) ) ;
		printf ( CURSORoff "        \r\033K" ) ;
		switch ( tolower ( c ) )
		{
	case '\r' : (*line)-- ;		/* RETURN => show another line */
				break ;
	case 'c' :	printf ( CLEARscreen ) ;
				c = ' ' ;
				break ;
		}
	}
	return ( c ) ;
}


/* ============  Define / HG / 22.10.91 ========================= */
/*

	first_def					last_def (shows last define)
		  |						  |
		  v						  v
		+---+	+---+	+---+	+---+
	    |A	|    B	|   |C	|   |D	|	
		|	|-->|	|-->|	|-->|	|-->	next (NULL)
		+---+	+---+	+---+	+---+
*/



DEFpntr first_def = NULL, last_def = NULL;


/*-------------------------------------------- show_defs -----------*/
void show_defs ( void )
{
	DEFpntr def_pntr;
	int		line = 0 ;
	
	def_pntr = first_def;
	while ( def_pntr != NULL )
	{
		line++ ;
		if ( more ( &line ) == 'q' )
			return ;

		switch ( radix )
		{
	case  8 : printf ( "%-8s = %08lo (oct)       ",
					   def_pntr->name, def_pntr->def ) ;
			  break ;
	case 16 : printf ( "%-8s = %08lx (hex)       ",
					   def_pntr->name, def_pntr->def ) ;
			  break ;
	default : printf ( "%-8s = %11li (dec)    ",
					   def_pntr->name, def_pntr->def ) ;
		}
		printf ( "\'%s\'\n", def_pntr->str ) ;
		def_pntr = def_pntr->next;
	}
}


# define EQUAL 0
/*--------------------------------------------- undefvar -----------*/
int undefvar ( char *arg )
{
	DEFpntr def_pntr, pre_pntr;
	
	def_pntr = first_def;
	pre_pntr = first_def;
	while ( def_pntr != NULL )
	{
		if ( strnicmp ( arg, def_pntr->name, MAXDEFNAME ) == EQUAL )
		{	/* FOUND */
			if ( def_pntr == first_def )
			{									/* found in 1st cell	*/
				first_def = def_pntr->next ;	/* (could be NULL)		*/
				if ( def_pntr == last_def )		/* 1st cell = last cell	*/
					last_def = NULL ;
			}
			else if ( def_pntr == last_def )	/* found in last cell	*/
			{
				last_def = pre_pntr ;
				last_def->next = NULL ;			/* end of cell chain	*/
			}
			else								/* found 				*/
				pre_pntr->next = def_pntr->next ; /* remove from middle */
			free ( def_pntr ) ;
			return ( OK ) ;
		}
		else
		{	/* NOT YET FOUND */
			pre_pntr = def_pntr ;				/* always 1 behind def_pntr */
			def_pntr = def_pntr->next;
		}
	}
	return ( NOdefRef ) ;						/* never found			*/
}


/*------------------------------------------- get_defvar -----------*/
DEFpntr get_defvar ( char *arg )
{
	DEFpntr def_pntr;
	
	def_pntr = first_def;
	while ( def_pntr != NULL )
	{
		if ( strnicmp ( arg, def_pntr->name, MAXDEFNAME ) == EQUAL )
			return ( def_pntr );
		else
			def_pntr = def_pntr->next;
	}
	return ( NULL ) ;
}


/*-------------------------------------- set_def -------------------*/
DEFpntr set_def ( char *arg )
{
	DEFpntr def_pntr, old_pntr;
	
	old_pntr = get_defvar ( arg );
	if ( old_pntr == NULL )
	{	/* not a redefine */
		def_pntr = malloc ( sizeof ( struct DEFvariable ) ) ;
		if ( def_pntr != NULL )
		{
			if ( last_def == NULL )
			{	/* first occurrence of define */
				first_def = def_pntr;
				last_def = def_pntr;
			}
			else
			{	/* at least one define previously */
				last_def->next = def_pntr;
				last_def = last_def->next ;
			}
			strncpy ( last_def->name, arg, MAXDEFNAME ) ;
			def_pntr->def = 0L ;
			def_pntr->str[0] = '\0' ;
			last_def->next = NULL ;
			return ( last_def ) ;
		}
		return ( NULL );
	}
	else	/* redefine */
		return ( old_pntr ) ;
}

/*-------------------------------------- set_defvar ----------------*/
int set_defvar ( char *arg, long val )
{
	DEFpntr def_pntr ;

	if ( verbose & COMMANDflag )
		printf ( "= define %s as %ld\n", arg, val ) ;
	
	if ( isalpha ( *arg ) || *arg == '_' )
	{
		def_pntr =  set_def ( arg ) ;
		if ( def_pntr != NULL )
		{
			def_pntr->def = val ;
			return ( OK ) ;
		}
	}
	return ( NOdefRef ) ;
}


/*-------------------------------------- set_defstr ----------------*/
int set_defstr ( char *arg, const char *text )
{
	DEFpntr def_pntr ;
	
	if ( isalpha ( *arg ) || *arg == '_' )
	{
		def_pntr =  set_def ( arg ) ;
		if ( def_pntr != NULL )
		{
			strncpy ( def_pntr->str, text, MAXDEFSTR ) ;
			return ( OK ) ;
		}
	}
	return ( NOdefRef ) ;
}


/*------------------------------------------- check_strdef ---------*/
int check_strdef ( int *arg_num, int arg_count,
				   char *arg_value[], char **strref )
{
	char	*arg ;
	int		an ;
	DEFpntr	def_pntr ;
	
	*strref = NULL ;
	an = (*arg_num)+1 ;
	if ( an < arg_count )
	{
		arg = arg_value[an] ;
		if ( isalpha ( *arg ) )
		{
			def_pntr = get_defvar ( arg );
			if ( def_pntr != NULL )
			{
				*strref = def_pntr->str ;
				(*arg_num)++ ;
				return ( OK ) ;
			}
			else
				return ( NOdefRef ) ;
		}
		return ( NOdefRef ) ;
	}
	else
		return ( NOargs ) ;
}


/* ========================= variables ============================ */


/*------------------------------------- check_variable -------------*/
int check_variable ( int *arg_num, int arg_count,
					 char *arg_value[], long **varref )
{
	char	*arg, vc ;
	int		an ;
	DEFpntr def_pntr ;
	
	*varref = NULL ;
	an = (*arg_num)+1 ;
	if ( an < arg_count )
	{
		arg = arg_value[an] ;
		if ( *arg == '$' )
		{
			arg++;
			vc = toupper ( *arg++ ) ;
			if ( isdigit ( vc ) && *arg == 0 )	/* $0..9	*/
			{
				(*arg_num)++ ;
				*varref = &back_pars[vc-'0'] ;
				return ( OK ) ;
			}
			if ( isalpha ( vc )	&& *arg == 0 )	/* $a..z	*/
			{
				(*arg_num)++ ;
				*varref = &variables[vc-'A'] ;
				return ( OK ) ;
			}
		}
		else if ( *arg == '^' )
		{
			arg++;
			if ( isalpha ( *arg ) || *arg == '_' )
			{
				def_pntr = get_defvar ( arg );
				if ( def_pntr != NULL )
				{
					*varref = &def_pntr->def ;
					(*arg_num)++ ;
					return ( OK ) ;
				}
				else
					return ( NOdefRef ) ;
			}			
		}
		return ( NOvarRef ) ;
	}
	else
		return ( NOargs ) ;
}


/*------------------------------------------ get_darg --------------*/
int get_darg ( int *arg_num, int arg_count,
			   char *arg_value[], double *result )
{
	char *start, *end ;
	double d ;
	int an ;
	
	an = (*arg_num)+1 ;
	if ( an < arg_count )
	{
		start = end = arg_value[an] ;
		d = strtod ( start, &end ) ;
		if ( start != end )
		{
			*result = d ;
			*arg_num += 1 ;
			return ( OK ) ;
		}
		else
			return ( NOnumber ) ;
	}
	else
		return ( NOargs ) ;
}


/*------------------------------------------ get_farg --------------*/
int get_farg ( int *arg_num, int arg_count,
			   char *arg_value[], float *f )
{
	int result ;
	double d ;

	result = get_darg ( arg_num, arg_count, arg_value, &d ) ;
	if ( result == OK )
		*f = (float)d ;
	return ( result ) ;
}


/*------------------------------------------ get_larg -------------*/
int get_larg ( int *arg_num, int arg_count,
				char *arg_value[], long *ll )
{
	char *start, *end ;
	long	l ;
	int an, result, local_radix ;
	long *varref ;

	result = check_variable ( arg_num, arg_count, arg_value, &varref ) ;

	if ( result == OK )
	{
		*ll = *varref ;
		return ( OK ) ;
	}
	else if ( result == NOvarRef )
	{
		an = (*arg_num)+1 ;
		if ( an < arg_count )
		{
			start = end = arg_value[an] ;
			switch ( *start )
			{
	case ';' :	return ( NOargs ) ;

	case '\'' :	*ll = *(start+1) ;
				if ( *ll != 0 && *(start+2) == '\'' )
				{
					*arg_num = an ;
					return ( OK ) ;
				}
				else
					return ( ILLparSyntax ) ;

	case '%' :	local_radix =  2 ;	start++ ; break ;
	case 'ž' :	local_radix =  8 ;	start++ ; break ;
	case '&' :	local_radix = 10 ;	start++ ; break ;
	case '$' :	local_radix = 16 ;	start++ ; break ;
	default :	local_radix = radix ;		  break ;
			}
			*arg_num = an ;
			if ( *start == '-' || *start == '+' )
				l = strtol ( start, &end, local_radix ) ;
			else
				l = (long)strtoul ( start, &end, local_radix ) ;

			if ( start != end )
			{
				if ( *end == 0 )
				{	
					*ll = l ;
					return ( OK ) ;
				}
				else
					return ( ILLparSyntax ) ;
			}
			else
				return ( NOnumber ) ;
		}
	}
	else if ( result == NOdefRef )
		return ( result ) ;

	return ( NOargs ) ;
}



/*------------------------------------------ get_ularg -------------*/
int get_ularg ( int *arg_num, int arg_count,
				char *arg_value[], unsigned long *ul )
{
	return ( get_larg ( arg_num, arg_count, arg_value, (long *)ul ) ) ;
}


/*------------------------------------------ get_iarg --------------*/
int get_iarg ( int *arg_num, int arg_count,
			   char *arg_value[], int *i )
{
	int result ;
	long l ;

	result = get_larg ( arg_num, arg_count, arg_value, &l ) ;
	if ( result == OK )
	{
		if ( MINint <= l && l <= MAXint )
		{
			*i = (int) l ;
			return ( OK ) ;
		}
		else
			return ( RANGEerror ) ;
	}
	else
		return ( result ) ;
}

/*------------------------------------------ get_uiarg --------------*/
int get_uiarg ( int *arg_num, int arg_count,
			    char *arg_value[], unsigned *ui )
{
	int result ;
	unsigned long ul ;

	result = get_ularg ( arg_num, arg_count, arg_value, &ul ) ;
	if ( result == OK )
	{
		if ( ul <= MAXuint )
		{
			*ui = (unsigned) ul ;
			return ( OK ) ;
		}
		else
			return ( RANGEerror ) ;
	}
	else
		return ( result ) ;
}

/*----------------------------------------- get_uiarg --------------*/
int get_xyarg (	int *arg_num, int arg_count,
			    char *arg_value[], XY *xy )
{
	int result ;

	result = get_uiarg ( arg_num, arg_count, arg_value, &xy->x ) ;
	if ( result == OK )
		result = get_uiarg ( arg_num, arg_count, arg_value, &xy->y ) ;
	return ( result ) ;
}


# define STRvars 1
/*--------------------------------------- get_pstrarg --------------*/
int get_pstrarg ( int *arg_num, int arg_count,
			      char *arg_value[], char **str )
{
	int 	an ;

	an = (*arg_num)+1 ;
	if ( an < arg_count )
	{
		*str = arg_value[an] ;
		*arg_num += 1 ;
		return ( OK ) ;
	}
	return ( NOargs ) ;
}


/*---------------------------------------- get_strarg --------------*/
int get_strarg ( int *arg_num, int arg_count,
			     char *arg_value[], char **str )
{
# if STRvars
	int		result ;

	result = check_strdef ( arg_num, arg_count, arg_value, str ) ;

	if ( result == OK )
		return ( OK ) ;
	else if ( result == NOdefRef )
# endif STRvars
		return ( get_pstrarg ( arg_num, arg_count, arg_value, str ) ) ;
	return ( NOargs ) ;
}


/*------------------------------------------ get_carg --------------*/
int get_carg ( int *arg_num, int arg_count,
			   char *arg_value[], char *c )
{
	int result ;
	char *str ;
	
	result = get_strarg ( arg_num, arg_count, arg_value, &str ) ;
	if ( result == OK )
		*c = *str ;
	return ( result ) ;
}



/*... command table ...*/

# define REVvideo	"\033p"
# define NORMvideo	"\033q"

char end_of_statement[] = ";" ;


/*----------------------------------- skip_behind_cmd --------------*/
void skip_behind_cmd ( int *arg_num, int arg_count,
					  char *arg_value[] )
{
	for(;;)
	{
		if ( *arg_num >= arg_count )
			return ;
		if ( *end_of_statement == *(arg_value[(*arg_num)++]) )
			return ;
	}
}


/*----------------------------------- scan_parameters --------------*/
int scan_parameters ( CMD *tabentry,
					  int *arg_num, int arg_count,
					  char *arg_value[],
					  VALUE *pars, int *npars, int maxpars )
{
	int  result ;
	char *format,*last ;
	long l ;
	int an ;

	format = tabentry->parform ;

	if ( verbose & COMMANDflag )
		printf ( "+ scan_parameters : cmd '%s', format '%s'\n",
			 tabentry->cmd, tabentry->parform ) ;

	result = OK ;
    last = format ;
	for ( *npars = 0; *npars < maxpars; )
	{
		an = (*arg_num)+1 ;

		if ( verbose & COMMANDflag )
		{
			printf ( "  scan_parameters(%d) : format -> '%s', next parameter [%d] : '%s'\n",
						result, format, an, an < arg_count ? arg_value[an] : "<<end>>" ) ;
		}

		switch ( *format++ )		/* no more parameters requested	*/
		{
case 0 :	if ( an < arg_count )
			{
				if ( *end_of_statement != *(arg_value[an]) )
				{
					result = TOOmanyPar ;
					do
					{
						an++ ;
					}
					while ( an < arg_count &&
								*end_of_statement != *(arg_value[an]) ) ;
				}
				*arg_num = an ;
			}
			goto error_exit ;

case '-' :	goto error_exit ;

case '*' :	if ( result != OK )
				goto error_exit ;
			if ( an < arg_count
					&& *end_of_statement != *(arg_value[an]))
				format = last ;
			break ;

case '%' :	last = format - 1 ;
			switch ( tolower ( *format++ ) )
			{
	case 'e' :	result = OK ;
				break ;
	case 'i' :
	case 'd' :	result = get_lexpr ( arg_num, arg_count, arg_value, &l ) ;
				if ( result == OK )
				{
					(pars++)->i = (int) l ;
					(*npars)++ ;
				}
				break ;
	case 'u' :	result = get_lexpr ( arg_num, arg_count, arg_value, &l ) ;
				if ( result == OK )
				{
					(pars++)->u = (unsigned) l ;
					(*npars)++ ;
				}
				break ;
	case 'l' :	switch ( *format++ )
				{
		case 'i' :
		case 'd' :	result = get_lexpr ( arg_num, arg_count, arg_value, &(pars++)->li ) ;
					if ( result == OK )
						(*npars)++ ;
					break ;
		case 'u' :	result = get_lexpr ( arg_num, arg_count, arg_value, &l ) ;
					if ( result == OK )
					{
						(pars++)->lu = (unsigned long) l ;
						(*npars)++ ;
					}
					break ;
		default :	printf ( "??? parameter type expected in format ( %l? )\n" ) ;
					result = NotOK ;
				}
				break ;
				
	case 'f' :	result = get_farg ( arg_num, arg_count, arg_value, &(pars++)->f ) ;
				if ( result == OK )
					(*npars)++ ;
				break ;
				
	case 'c' :	result = get_carg ( arg_num, arg_count, arg_value, &(pars++)->c ) ;
				if ( result == OK )
					(*npars)++ ;
				break ;
				
	case 's' :	if ( an < arg_count && *end_of_statement != *(arg_value[an]) )
				{
					result = get_strarg ( arg_num, arg_count, arg_value, &(pars++)->s ) ;
					if ( result == OK )
						(*npars)++ ;
				}
				else
					result = NOargs ;
				break ;

	case 'p' :	if ( an < arg_count && *end_of_statement != *(arg_value[an]) )
				{
					result = get_pstrarg ( arg_num, arg_count, arg_value, &(pars++)->s ) ;
					if ( result == OK )
						(*npars)++ ;
				}
				else
					result = NOargs ;
				break ;
				
	case 'v' :	result = check_variable ( arg_num, arg_count, arg_value, &(pars++)->v ) ;
				if ( result == OK )
					(*npars)++ ;
				break ;
				
	default :	printf ( "??? illegal parameter type in format\n" ) ;
				result = NotOK ;
			}
			break ;

default :	printf ( "??? illegal parameter format syntax ( '%' ? )\n" ) ;
			result = NotOK ;
			break ;
		}
	}

	if ( result == OK )
	{
		if ( *format != 0 )
		{
			printf ( "??? too many parameters in format\n" ) ;
			result = NotOK ;
		}
	}

error_exit:
	if ( verbose & COMMANDflag )
		printf ( "- scan_parameters(%d), npars = %d\n", result, *npars ) ;

	return ( result ) ;
}


		
/*----------------------------------------- show_help --------------*/
void show_help ( CMD *cp )
{
	int	n ;
	char *s ;
	
	printf ( "%4d - ", cp->num ) ;
	for ( n = 14, s = cp->cmd; *s != 0; n--, s++ )
	{
		if ( *s >= 'A' && *s <= 'Z' )
			printf ( REVvideo "%c" NORMvideo, tolower(*s) ) ;
		else
			printf ( "%c", *s ) ;
	}
	while ( n-- > 0 ) printf ( " " ) ;
	printf ( " : %s\n", cp->help ) ;
}


/*------------------------------------------ cmd_help_all ----------*/
int cmd_help_all ( CMD *cmd_table, int start )
{
	CMD *cp ;
	int line ;
	
	cp = cmd_table ;

	for ( line = start ; cp->num != 0; line++ )
	{
        show_help ( cp ) ;
        if ( more ( &line ) == 'q' )
			return ( 0 );
		cp++ ;
	}
	return ( line );
}


/*---------------------------------------------- cmd_help ----------*/
int cmd_help ( CMD *cmd_table, char *cmd_str )
{
	CMD *cp ;
	int	cmd ;
	
	cmd = cmd_look_up ( cmd_table, cmd_str, &cp ) ;
    if ( cmd != 0 /* CMDillegal */ )
    	show_help ( cp ) ;
    return ( cmd ) ; 
}



/*------------------------------------------ cmd_look_up -----------*/
int cmd_look_up ( CMD *cmd_table, char *cmd, CMD **tabentry )
{
	CMD *cp ;
	bool negativ ;
	char c ;

	switch ( *cmd )
	{
 case '-' :	negativ = TRUE ;		/*  -cmd	*/
			cmd++ ;
			break ;

 case '#' :			
 case '+' :	cmd++ ;					/*  +cmd	*/
 		/*	cont ;	*/

 default :	negativ = FALSE ;		/*   cmd	*/
			break ;
	}	
	
	cp = cmd_table ;

	while ( cp->num != 0 )
	{
		if ( stricmp ( cp->cmd, cmd ) == 0 )
		{
			*tabentry = cp ;
			return ( cp->num >= 0 ? cp->num
								  : negativ ? cp->num : -cp->num ) ;
		}
		cp++ ;
	}

	/* command not found, single letter shortcut ?? */


	if ( strlen ( cmd ) == 1 )
	{
		cp = cmd_table ;
		c = toupper(*cmd) ;
		
		while ( cp->num != 0 )
		{
			if ( strchr ( cp->cmd, c ) != NULL )
			{
				*tabentry = cp ;
				return ( cp->num >= 0 ? cp->num
									  : negativ ? cp->num : -cp->num ) ;
			}
			cp++ ;
		}
	}

	*tabentry = NULL ;
	return ( 0 ) ;	/* CMDillegal	*/
}



# define MAX_FILE_ARGS 3072 /* was 2048 - HDG 12/11/91 */
# define MAX_LINE_ARGS   40
# define MAX_NAME_LNG    80
# define MAX_LINE_LNG   256

char cmdint_flag = ' ' ;

/*---------------------------------------------- clear_args --------*/
void clear_args ( char **arg_value, unsigned num_args )
{
	while ( num_args-- > 0 )
		*(arg_value++) = NULL ;
}


/*---------------------------------------------- free_args ---------*/
void free_args ( char **arg_value, unsigned num_args )
{
	while ( num_args-- > 0 )
	{
		if ( *arg_value != NULL && *arg_value != end_of_statement )
			free ( *(arg_value++) ) ;
		else
			arg_value++ ;
	}
}


local char *line1 = NULL ;
local int  line1_size = 0 ;

/*---------------------------------------------- catch_line1 ----*/
void catch_line1 ( char *s, int size )
{
	line1 = s ;
	line1_size = size ;
}


/*---------------------------------------------- interpret_line ----*/
int interpret_line ( int *arg_count, char *((*arg_value)[]),
					 unsigned num_args, char *line )
{
	char *lsp ;
	char *tsp, token[MAX_NAME_LNG] ;
	char *sp;
	char stopc ;

	lsp = line ;
	while ( *lsp == ' ' || *lsp == '\t' )
		lsp++ ;
	switch ( *lsp )
	{
		
 case '$' :	cmdint_flag = lsp[1] ;
			break;
 case '!' :
 case '*' : /* comment line, line 1 awaited ? */
			if ( line1 != NULL )
			{
				strncpy ( line1, line+2, line1_size ) ;
				line1[line1_size-1] = 0 ;		/* terminate string	*/
				sp = strchr ( line1, '\n' ) ;	/* delete new line	*/
				if ( sp != NULL )
					*sp = 0 ;
			}
			break;
 case '\r' :
 case '\n' :
 case EOS :	break ;
 default :	do
			{
				tsp = token ;
				switch ( *lsp )
				{
		case '"' :	stopc = *lsp++ ;
					while ( *lsp >= ' ' || *lsp == '\t' )
					{
						if ( *lsp == stopc )
						{
							lsp++ ;
							break ;
						}
						*tsp++ = *lsp++ ;
					}
					break ;

		case '\'' :	*tsp++ = *lsp++ ;	/*	'	*/
					if ( *lsp == 0 )
						break ;
					*tsp++ = *lsp++ ;	/*	'c	*/
					if ( *lsp == 0 )
						break ;
					*tsp++ = *lsp++ ;	/*	'c'	*/
					break ;

		default :	while ( *lsp > ' '	&& *lsp != ',' )
						*tsp++ = *lsp++ ;
					break ;
				}
									
				*tsp++ = EOS ;

				sp = malloc ( tsp - token ) ;
				if ( sp != NULL )
				{
					if ( isdigit(token[0]) && token[1] == ':' )	/* relative drive	*/
						*token += 'A' - '0' + Dgetdrv() ;
					if ( cmdint_flag == 't' )
						printf ( "- token %2d : %s", *arg_count, token ) ;
					if ( *arg_count < num_args )
						(*arg_value)[(*arg_count)++] = strcpy ( sp, token ) ;
					else
						return ( NOargMemory ) ;
				}
				else
				{
					(*uprintf)("- out of memory\n" ) ;
					return ( NOmemory ) ;
				}
				while ( *lsp == ' ' || *lsp == '\t' )
					lsp++ ;
				if ( *lsp == ',' )
				{
					lsp++ ;
					while ( *lsp == ' ' || *lsp == '\t' )
						lsp++ ;
				}
				if ( *lsp == '\\' && *(lsp+1) < ' ' )
					return ( OK ) ; /* continue line	*/
			}
			while ( *lsp >= ' ' && ( *lsp != '*' ||  *(lsp+1) != '*' ) ) ;

			if ( cmdint_flag == 't' )
				printf ( "- token %2d : %s\n", *arg_count, end_of_statement ) ;
			if ( *arg_count < num_args )
				(*arg_value)[(*arg_count)++] = end_of_statement ;
			else
				return ( NOargMemory ) ;

			break;
	}
	return ( OK ) ;
}

/*---------------------------------------------- interpret_list ----*/
int interpret_list ( char *argfilename, CMDloop *cmd_loop )
{
	FILE *arg_file;

	int  arg_count, result ;
	char *(arg_value[MAX_FILE_ARGS]);
	char line[MAX_LINE_LNG];
# if ADD_INPUT
	char *ap ;
# endif

	result = OK ;
	arg_count = 1 ;

	clear_args ( arg_value, MAX_FILE_ARGS ) ;
	if ( verbose & COMMANDflag )
		printf("* command file %s", argfilename ) ;
	arg_file = fopen ( argfilename, "r" ) ;

	if ( line1 != NULL )	/* clear line 1	*/
		*line1 = 0 ;

	if ( arg_file != NULL)
	{
		if ( verbose & COMMANDflag )
			printf(" found\n") ;	
		while ( result == OK
			&& fgets(line,MAX_LINE_LNG-1,arg_file) != NULL
			&& cmdint_flag != '-' )
		{
			if ( cmdint_flag == 'p' )
				printf ( "- %2d : %s", arg_count, line ) ;
# if ADD_INPUT
			for ( ap = line; *ap != EOS; ap++ )
			{
				if ( *ap == CR || *ap == LF )
				{
					*ap = EOS ;
					break ;
				}
			}
			if ( histo_on )
 				add_cmd ( line ) ;
# endif
			result = interpret_line ( &arg_count, &arg_value, MAX_FILE_ARGS, line ) ;
			line1 = NULL ;	/* delete handle to user-line1 after first line	*/
		}
		if ( cmdint_flag == 'p' )
			printf ( "\n" ) ;
		fclose ( arg_file ) ;
		
		if ( result == OK )
			(*cmd_loop)( arg_count, arg_value ) ;

		free_args ( arg_value, MAX_FILE_ARGS ) ;

		if ( verbose & COMMANDflag )
			(*uprintf) ( "* end interpret_list %s, result = %d",
							argfilename, result ) ;
	    return ( result ) ;
	}
	else
	{
		if ( verbose & COMMANDflag )
			(*uprintf)("* command file %s not found", argfilename ) ;
		return ( FILEnotFound ) ;
	}
}


/*---------------------------------------------- interpret_string --*/
int interpret_string ( char *line, CMDloop *cmd_loop )
{
	int  arg_count, result ;
	char *(arg_value[MAX_LINE_ARGS]);

	result = OK ;
	arg_count = 1 ;

# if TEST
	printf ( "+> interpret_line : %s\n", line ) ;
# endif
	clear_args ( arg_value, MAX_LINE_ARGS ) ;
	result = interpret_line ( &arg_count, &arg_value, MAX_LINE_ARGS, line ) ;
# if TEST
	printf ( "-> interpret_line = %d\n"
			 "+> *cmd_loop # %d %d\n",
			 result, arg_count ) ;
# endif
	if ( result == OK )
		result = (*cmd_loop)( arg_count, arg_value ) ;
	free_args ( arg_value, MAX_LINE_ARGS ) ;
    return ( result ) ;
}
