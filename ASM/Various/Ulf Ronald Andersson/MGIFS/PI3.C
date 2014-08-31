/*
 *	pi3 - display PI3 files (mono only)
 */

static char *sccsid  = "@(#) pi3 1.0 90/12/16 rosenkra\0\0                ";
char        *myname  = "pi3\0\0\0\0\0\0";
char        *version = "pi3 1.0 90/12/16 rosenkra\0\0\0                   ";


#include <stdio.h>
#include <osbind.h>


char	buf[32500];		/* new screen buffer */


/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{
	char   *pbuf;			/* ptr to aligned buffer */
	int	svpal[16];		/* saved palette */
	long	svpbase,		/* saved screen locations */
		svlbase;
	int	i;


	/*
	 *   get current logical and physical screen and save these
	 */
	svpbase = Physbase ();
	svlbase = Logbase ();


	/*
	 *   save original palette...
	 */
	for (i = 0; i < 16; i++)
		svpal[i] = Setcolor (i, -1);


	/*
	 *   align buffer
	 */
	pbuf = (char *) (((long) buf & 0xFFFFFF00L) + 256L);


	/*
	 *   look for switches...
	 */
	argc--, argv++;
	while (argc && **argv == '-')
	{
		switch (*(*argv+1))
		{
		case 'v':
			printf ("%s\n", version);
			exit (0);
			break;

		case 'h':
			usage (0);
			break;
		}
		argc--, argv++;
	}


	/*
	 *   do all files...
	 */
	clr_screen ();
	while (argc--)
	{
		/*
		 *  reset screen...
		 */
		Setpalette (svpal);
		Setscreen (svlbase, svpbase, -1);

		/*
		 *   read image from file into screen buffer
		 */
		if (!read_pi3 (*argv, pbuf))
			/*
			 *   display it
			 */
			Setscreen (pbuf, pbuf, -1);

		/*
		 *   wait for a key...
		 */
		wait_key ();
		argv++;
	}


	/*
	 *   make sure to reset screen...
	 */
	Setpalette (svpal);
	Setscreen (svlbase, svpbase, -1);

	exit (0);
}



/*------------------------------*/
/*	usage			*/
/*------------------------------*/
usage (excode)
int	excode;
{

	fprintf (stderr, "%s file ...\n", myname);

	exit (excode);
}



/*------------------------------*/
/*	read_pi3		*/
/*------------------------------*/

#define NCHUNK		400

int read_pi3 (fname, pbuf)
char	       *fname;
register char  *pbuf;
{
	register int	i,
			j;
	int		fd;
	int		ival;
	char		buf[NCHUNK];
	int		pal[16];
	FILE	       *stream;


	/*
	 *   open the .pi3 file (must be BINARY)...
	 */
#ifdef ALCYON
	if ((stream = fopenb (fname, "r")) == (FILE *) NULL)
#else
	if ((stream = fopen (fname, "rb")) == (FILE *) NULL)
#endif
	{
		printf (" Error openning %s.\n", fname);
		return (1);
	}
	fd = fileno (stream);


	/*
	 *   read .pi3 header. start with rez word...
	 */
	read (fd, &ival, 2);
	if (ival != 2)
	{
		printf (" File %s is not high resolution!\n", fname);
		fclose (stream);
		return (2);
	}


	/*
	 *   now palette...
	 */
	for (i = 0; i < 16; i++)
	{
		read (fd, &ival, 2);
		pal[i] = ival;
	}


	/*
	 *   read the screen...
	 */
	for (i = 0; i < 32000/NCHUNK; i++)	/* screen (32000 bytes) */
	{
		if (read (fd, buf, NCHUNK) != NCHUNK)
		{
			printf (" File %s is improper length, possibly corrupted\n",
				fname);
			fclose (stream);
			return (3);
		}

		for (j = 0; j < NCHUNK; j++)
			*pbuf++ = buf[j];
	}

	fclose (stream);


	/*
	 *   reset palette...
	 */
	Setpalette (pal);

	return (0);
}




/*------------------------------*/
/*	wait_key		*/
/*------------------------------*/
wait_key ()
{

/*
 *	waits for a key and flushes keyboard buffer.
 */

	while (!Bconstat (2))			/* wait for a key... */
		;

	while (Bconstat (2))			/* keep reading while there */
		Bconin (2);			/* are key inputs... */
}




/*------------------------------*/
/*	clr_screen		*/
/*------------------------------*/
clr_screen ()
{

/*
 *	clear screen, home cursor
 */

	Cconws ("\33E");
}

