/************************************************************************/
/*									*/
/*	string.h	written by John Feagans		16 Apr 86	*/
/*	copyright 1986 by Atari Corp.					*/
/*									*/
/*	for use with Alcyon C as distributed in ST developers package.	*/
/*									*/
/************************************************************************/

extern	char	*ftoa();	/* floating to ascii		*/
extern	char	*etoa();	/* floating to ascii		*/
extern  char	*getpass();	/* get password function	*/
extern	char	*index();	/* locate first occurence	*/
extern	char	*rindex();	/* locate last occurence	*/
extern	char	*mktemp();	/* create temp file name	*/
extern	char	*sprintf();	/* print to string		*/
extern	char	*strcat();	/* concat whole			*/
extern	char	*strncat();	/* concat number specified.	*/
extern	char	*strcpy();	/* copy whole string		*/
extern	char	*strncpy();	/* copy specified length	*/
extern	int	strlen();	/* return length of string	*/
