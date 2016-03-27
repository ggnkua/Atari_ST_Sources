/*	bt473.c / 8.7.91 / MATRIX / WA	*/

# include <stdio.h>
# include <stddef.h>
# include <tos.h>

# include "sys_vars.h"

# include "global.h"

# include "traps.h"

int		 null = 0 ;
int		 verbose = 0 ;
PRINTfct uprintf = printf ;

/*------------------------------------------------ ld --------------*/
int ld ( int i )
/* i != 2^^N -> result < 0	*/
{
	int n ;
	
	for ( n = 0; i > 0; n++, i >>= 1 )
	{
		if ( i & 1 )
			return ( i == 1 ? n : -1-n ) ;	/* i != 2^^n ? */
	}
	return ( -1 ) ;	/* i <= 0 */
}

void *addr ;
long cont ;

/*------------------------------------------------------ get_lc ----*/
long get_lc ( void )
{
	cont = *(long *)addr ;
	return ( 0 ) ;
}

/*------------------------------------------------------ get_wc ----*/
long get_wc ( void )
{
	cont = *(word *)addr ;
	return ( 0 ) ;
}

/*------------------------------------------------------ get_lcont -*/
long get_lcont ( long *a )
{
	addr = a ;
	Supexec ( get_lc ) ;
	return ( cont ) ;
}

/*------------------------------------------------------ get_wcont -*/
word get_wcont ( word *a )
{
	addr = a ;
	Supexec ( get_wc ) ;
	return ( (word)cont ) ;
}

/*------------------------------------------------------ put_lc ----*/
long put_lc ( void )
{
	*(long *)addr = cont ;
	return ( 0 ) ;
}

/*------------------------------------------------------ put_lcont -*/
void put_lcont ( long *a, long c )
{
	addr = a ;
	cont = c ;
	Supexec ( put_lc ) ;
}


/*------------------------------------------------- get_long_frame -*/
word get_long_frame ( void )
{
	return ( get_wcont ( _longframe ) ) ;
}


/*------------------------------------------------------ nation -*/
int nation ( void )
{
	KEYTAB *kt ;
	
	kt = Keytbl((void *)-1,(void *)-1,(void *)-1) ;
	switch ( kt->unshift[26] )
	{
case '' :	return GERMAN ;
default  :  return FOREIGN ;
	}
}


/*------------------------------------------------------ TOSversion -*/
int TOSversion ( void )
{
	SYSHDR			*syshead ;

	syshead = (SYSHDR *) get_lcont ( (long *)_sysbase ) ;
		
	return syshead->os_version ;
}


/*------------------------------------ get_boot_drive --------------*/
char get_boot_drive ( void )
{
	char boot_drive	;
	void *old_stack;
	
	if ( Super ( (void *)1L ) )
		old_stack = NULL ;	/* already in Super mode	*/
	else
		old_stack = (void *)Super ( (void *)0L ) ;

	boot_drive = *_bootdev + 'A' ;

	if ( old_stack != NULL )
		Super ( (void *) old_stack );

	return boot_drive ;
}

/*------------------------------------------------------ key_click -*/
void key_click ( int on )
# define _keyclick ((byte *)0x484L)
{
	void	*old_stack;
	
	if ( Super ( (void *)1L ) )
		old_stack = NULL ;	/* already in Super mode	*/
	else
		old_stack = (void *)Super ( (void *)0L ) ;

	if ( on )
		*_keyclick |=  1 ;
	else
		*_keyclick &= ~1 ;
		 
	if ( old_stack != NULL )
		Super ( (void *) old_stack );
}


unsigned	old_level ;

/*-------------------------------------------- disa_irq ----------*/
long disa_irq (void)
{
	old_level = disable_irq() ;
	return (0L) ;
} /*- disa_irq -*/


/*--------------------------------------------- ena_irq ----------*/
long ena_irq (void)
{
	enable_irq (old_level) ;
	return (0L) ;
} /*- ena_irq -*/



