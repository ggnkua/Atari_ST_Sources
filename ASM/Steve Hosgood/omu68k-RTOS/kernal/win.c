/******************************************************************************
 *	Win.c		Window hacks for window operation
 ******************************************************************************
 */

#ifdef	VIWINDOWS
/*
 *	THIS IS A MAJOR HACK !
 *	The window driver calls this routine on open to
 *	Set the address of functions to be called when the
 *	Kernal whishes to know which processes window a point
 *	is within.
 *	The kernal can now call these functions via winset() etc.
 */
static int	(*posfunc)();
static int	(*echofunc)();

/*
 *	Initwin()	Initialise window functions to required addresses
 */
initwin(pfunc, efunc)
int	(*pfunc)();
int	(*efunc)();
{
	posfunc = pfunc;
	echofunc = efunc;
	return 0;
}

/*
 *	Winset()	Calls window driver, if present, to see what process
 *			has the window given the reqired point co-ords.
 *			If the mode argument is 1 then the window is brought
 *			to the forground.
 *			The viinfo structure, pointed to by arg, is
 *			is filled with the required data.
 */
winset(arg, mode)
int	*arg;
int	mode;
{
	if(posfunc)
		return (*posfunc)(arg, mode);
	else
		return -1;
}

/*
 *	Winecho()	Calls window driver, to print the given character
 *			in the previously defined echo window.
 */
winecho(buf, nbytes)
char	*buf;
int	nbytes;
{
	if(echofunc){
		return (*echofunc)(buf, nbytes);
	}
	else
		return -1;
}
#endif
