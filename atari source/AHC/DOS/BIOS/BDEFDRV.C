/*  bdefdrv.c - default drive support					*/
/*	contains all default-drive dependant info			*/



/*
**  env - string used to load in shell
*/

#ifndef DEFDRV
#define	DEFDRV	0		/* 0 = A:, 2 = C: */
#endif

#if	DEFDRV == 0
char env[] = "COMSPEC=A:\\COMMAND.PRG\0";
#endif


#if	DEFDRV == 2
char env[] = "COMSPEC=C:\\COMMAND.PRG\0";
#endif


/*
**  defdrv - the indicator for the default drive number
**	0 = a:, 2 = c:
*/

int	defdrv = DEFDRV ;

