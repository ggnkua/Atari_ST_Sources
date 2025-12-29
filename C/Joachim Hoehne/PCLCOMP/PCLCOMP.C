/*
**  Pclcomp -- PCL compression filter.
**
**  If you have any problems or errors to report, please send them to me:
**
**  Tony Parkhurst  
** 
**  Email address:  tony@sdd.hp.com    -or-   hp-sdd!tony
**
**  Please send a copy of the file that is causing the problem, and the
**  version of pclcomp you are using.
**
**  All suggestions and requests are welcome.
*/

/*
 ***************************************************************************
 *
 * $Source: /disc/44/cgtriton/tony/filters/pclcomp/RCS/pclcomp.c,v $ 
 * $Date: 91/09/13 13:56:28 $ 
 * $Revision: 1.39 $
 *
 * Description: Compresses pcl graphics files.
 *
 * Author:	 Tony Parkhurst
 * Created:	 890427
 * Language:	 C
 *
 * (c) Copyright 1989, Hewlett-Packard Company, all rights reserved.
 *
 ***************************************************************************
 */


/*
 ***************************************************************************
 *
 * $Log:	pclcomp.c,v $
 * Revision 1.39  91/09/13  13:56:28  13:56:28	tony (Tony Parkhurst)
 * Added code to disable zerostrip in mode 2.
 * 
 * Revision 1.38  91/09/10  15:47:28  15:47:28	tony (Tony Parkhurst)
 * Added include file for isdigit()
 * 
 * Revision 1.37  91/09/10  15:08:23  15:08:23	tony (Tony Parkhurst)
 * Clamped horizontal offsets to raster widths.
 * 
 * Revision 1.36  91/09/10  15:04:15  15:04:15	tony (Tony Parkhurst)
 * Re-vamped fraction parsing.
 * 
 * Revision 1.35  91/09/10  14:03:40  14:03:40	tony (Tony Parkhurst)
 * Fixed potential problem with fractions.
 * Removed obsolete invert flag.
 * Cleaned up some comments.
 * 
 * Revision 1.34  91/09/10  13:21:48  13:21:48	tony (Tony Parkhurst)
 * Fixed problems with data gaps  (0W instead of 0V0V0W)
 * Fixed problems with horizontal offsets and mode 3 compression.
 * Added option to strip horizontal offsets (zero value must be white).
 * 
 * Revision 1.33  91/07/18  15:18:43  15:18:43	tony (Tony Parkhurst)
 * Replaced mode 2 compression routine.  Works better now.
 * 
 * Revision 1.32  91/07/08  11:27:24  11:27:24	tony (Tony Parkhurst)
 * Enhanced the strip algorithm for merged graphics.
 * (Also cleaned up some comments, couple of statements.)
 * 
 * Revision 1.31  91/05/30  15:18:51  15:18:51	tony (Tony Parkhurst)
 * Oops, fixed it right this time.
 * 
 * Revision 1.30  91/05/30  15:06:20  15:06:20	tony (Tony Parkhurst)
 * Added fix for negative value for <esc>*r#U.
 * 
 * Revision 1.29  91/05/03  10:12:30  10:12:30	tony (Tony Parkhurst)
 * Small changes.
 * 
 * Revision 1.28  91/04/30  09:41:24  09:41:24	tony (Tony Parkhurst)
 * Now puts stdin and stdout in binary mode for MSDOS.
 *	Changes courtesy of Mike Slomin.
 * Changed usage message a bit.
 * 
 * Revision 1.27  91/04/23  15:48:05  15:48:05	tony (Tony Parkhurst)
 * Added handling of plus_sign in value fields.
 * 
 * Revision 1.26  91/04/23  09:47:11  09:47:11	tony (Tony Parkhurst)
 * Pass thru unknown modes.
 * 
 * Revision 1.25  91/04/18  11:09:27  11:09:27	tony (Tony Parkhurst)
 * Added parse for fractions in values (i.e. <esc>(s16.67H)
 * 
 * Revision 1.24  91/04/10  14:16:30  14:16:30	tony (Tony Parkhurst)
 * strips text and control codes between <esc>*rA and <esc>*rB w/ -s option
 * 
 * Revision 1.23  91/04/05  14:53:25  14:53:25	tony (Tony Parkhurst)
 * Added fixed for deskjet
 * Also added a stripping feature.
 * 
 * Revision 1.22  91/04/05  08:48:53  08:48:53	tony (Tony Parkhurst)
 * Added some error checkin on output for MS-DOS users.
 * 
 * Revision 1.21  91/04/04  12:53:32  12:53:32	tony (Tony Parkhurst)
 * Replaced parser.
 *    Now handles combined escape sequences.
 *    Now handles downloads.
 *    Now combines mode changes with data.
 * 
 * Revision 1.20  91/04/04  08:02:12  08:02:12	tony (Tony Parkhurst)
 * Removed some test code.
 * 
 * Revision 1.19  91/03/25  14:38:48  14:38:48	tony (Tony Parkhurst)
 * Changed defaults.
 * 
 * Revision 1.18  91/03/25  14:31:22  14:31:22	tony (Tony Parkhurst)
 * Re-worked memory allocation stuff for funky input files.
 * 
 * Revision 1.17  91/03/25  13:50:19  13:50:19	tony (Tony Parkhurst)
 * Use command line args for file w/o -i or -o.
 * 
 * Revision 1.16  91/03/04  14:23:15  14:23:15	tony (Tony Parkhurst)
 * Fixed to allow ONLY mode 3 if the user really wants it.
 * 
 * Revision 1.15  91/03/04  14:08:23  14:08:23	tony (Tony Parkhurst)
 * Added an exit(0) at the end of main.
 * fixed up some zerostrip stuff.
 * made mode 3 the highest priority mode.
 * 
 * Revision 1.14  91/02/20  13:57:27  13:57:27	tony (Tony Parkhurst)
 * Changed priority a bit.
 * Added some zerostripping for mode 2.
 * 
 * Revision 1.13  91/02/06  15:31:00  15:31:00	tony (Tony Parkhurst)
 * oops.
 * 
 * Revision 1.12  91/02/06  14:41:28  14:41:28	tony (Tony Parkhurst)
 * fixed usage message
 * 
 * Revision 1.11  91/02/06  14:38:10  14:38:10	tony (Tony Parkhurst)
 * Added file input and output for MS-DOS.
 * 
 * Revision 1.10  91/02/05  17:49:23  17:49:23	tony (Tony Parkhurst)
 * Fixed problem with zero stripped input.
 * 
 * Revision 1.9  91/02/05  16:11:39  16:11:39  tony (Tony Parkhurst)
 * Removed delay code and bitfield stuff.
 * 
 * Revision 1.8  91/02/05  11:04:53  11:04:53  tony (Tony Parkhurst)
 * Added io delay stuff for testing.
 * 
 * Revision 1.7  91/02/05  10:28:32  10:28:32  tony (Tony Parkhurst)
 * Fix for someone specifing ONLY mode 3.
 * 
 * Revision 1.6  91/01/29  14:13:09  14:13:09  tony (Tony Parkhurst)
 * Updated some comments.
 * 
 * Revision 1.5  91/01/29  13:26:24  13:26:24  tony (Tony Parkhurst)
 * Cleaned up, revamped a bit.
 * 
 * Revision 1.4  89/11/09  15:59:16  15:59:16  tony (Tony Parkhurst)
 * Fix for esc * r U coming after esc * r A.
 * 
 * Revision 1.3  89/10/24  11:31:12  11:31:12  tony (Tony Parkhurst)
 * Added parsing of <esc>*rC
 * 
 * Revision 1.2  89/10/13  09:56:46  09:56:46  tony (Tony Parkhurst)
 * Completely revamped by Greg G.
 * 
 * Revision 1.1  89/06/15  13:57:46  13:57:46  tony (Tony Parkhurst)
 * Initial revision
 * 
 *
 ***************************************************************************
 */
 
static const char copyr[]=
	"Copyright (c) 1991, Hewlett-Packard Company, all rights reserved.";

static const char author[]="Tony Parkhurst";

static const char rcs_id[]="$Header: pclcomp.c,v 1.39 91/09/13 13:56:28 tony Exp $";

static const char rev_id[]="$Revision: 1.39 $";
 

/*
 *   This program was first a filter by Dean to compress pcl graphics.
 *
 *   This program now will do optimal compression using modes 0,1,2 and 3
 *
 *   Also, this program will take compressed input.
 *
 *   Input and output formats are standard pcl.
 *
 *   Imaging files ("Configure Image Data") are supported.
 *
 *   Pclcomp does not take advantage of Y-Offset for blank areas.  
 *   This is because Y-Offset creates white areas, but we don't do enough
 *   parsing to determine what value "white" has.  An application that
 *   can assume white values could make use of this sequence.
 *
 *   Pclcomp does not do any of the block compression modes (4-8).
 *
 *   An additional enhancement would be to compare all the planes in a
 *   multi-plane file (color) and if nothing changed, using mode 3, just
 *   output a single <esc>*b0W.
 *
 *
 *   Usage:  pclcomp [-v] [-0] [-1] [-2] [-3] [-z] [-n###] < infile > outfile
 *
 *   Pclcomp will do graphics compression based on compression modes 0, 1, 2
 *   and 3.  (Mode 0 is uncompressed).	Pclcomp will accept all modes, and
 *   will attempt to optimize by selecting the best output mode for each
 *   row (or plane) of data.  By default, pclcomp will use all 4 modes, but
 *   the user may restrict which output modes to use with the -0123 options.
 *   For example, to use pclcomp for output to a PaintJet which only knows
 *   modes 0 and 1 (the XL also understands modes 2 and 3), one would use:
 *
 *	pclcomp -01 < infile > outfile
 *
 *   Note:  Mode 0 should always be allowed.  None of the other modes is
 *   guaranteed to be better than mode 0 in all cases.
 *
 *   The 'v' option tells the number of rows (planes) of data input and output
 *   in the different modes (to stderr).
 *
 *   By default, pclcomp does zero "stripping" which is useful for PaintJet 
 *   files using only modes 0 and 1, the PaintJet (and other PCL printers) 
 *   will do zero "filling".  
 *   NOTE: Use the 'z' option to disable zero stripping.
 *
 *   The 'n' option is to change the default number of pixels in a picture.
 *   The proper way to set the pixel width is with the source raster width
 *   sequence <esc*r#S>, but soo many applications just assume the default,
 *   which is different on different printers, so I am providing this
 *   command line option to set a new default.	One could also change the
 *   DEFAULT constant below (make sure it is a multiple of 8).	
 *   Currently it is set to 8" at 300 dpi (2400).
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifdef MSDOS
#include <fcntl.h>
#endif

/* This flag is for code that uses bitfields for 68000 systems */
/* Not recommended at this time */

#define BITFIELDS 0

#define Get_Character() getchar()

#define MIN(x,y)	( ((x) < (y)) ? (x) : (y) )

#define TRUE 1
#define FALSE 0

#define ESC	27

#define DEFAULT 2400		/* default width in pixels (multiple of 8) */

#define MAXMODES  4
#define MAXPLANES 8
#define MAXBYTES 60000		/* now mostly meaningless, just a big number */

unsigned char	*seed_row[MAXPLANES];
unsigned char	*new_row;
unsigned char	*out_row[MAXMODES];
unsigned int	out_size[MAXMODES];

char	memflag = FALSE;	/* set when memory has been allocated */


char	mode0=FALSE,
	mode1=FALSE,
	mode2=FALSE,
	mode3=FALSE;

unsigned char	num_planes=1;
unsigned char	curr_plane=0;

char	imaging = FALSE;		/* not imaging, so no lockout */

char	verbose = FALSE;

unsigned char	inmode = 0;		/* input compression mode */
unsigned char	outmode = 0;		/* output compression mode */

unsigned int	rasterwidth=DEFAULT/8;	/* width of picture, in bytes */
unsigned int	rpix = DEFAULT; 	/* width of picture, in pixels */

unsigned char	zerostrip= TRUE;	/* strip trailing zeros */

unsigned int	inuse[4]={0,0,0,0}, outuse[4] = {0,0,0,0};

char	widthwarning = FALSE;	/* for trucation warning */
char	firstrow = TRUE;	/* to prevent mode 3 from being first */


struct {			/* this will hold the data for the  */
     unsigned char model;	/* configuring of image processing   */
     unsigned char pix_mode;
     unsigned char inx_bits;
     unsigned char red;
     unsigned char green;
     unsigned char blue;
     short wr;
     short wg;
     short wb;
     short br;
     short bg;
     short bb; 
} imdata;

extern	unsigned char *malloc();

char	*filein = NULL, *fileout = NULL;

/*
**  These variables are for the new parser.
**  The new parser handles more sequences, and also deals with combined
**  escape sequences better.
*/

int	parameter;
int	group_char;
int	terminator;
int	old_terminator;
int	value;
float	fvalue; 		/* fractional value */
int	scanf_count;
char	in_sequence = FALSE;
char	pass_seq;
char	plus_sign;		/* for relative values */


/* dummy buffer */
char buf[BUFSIZ];

/*
**  If the printer is a DeskJet, then we must handle <esc>*rB differently
**  Option '-d' will turn on this mode.
*/

char	deskjet = FALSE;


/*
**  Many drivers it seems put <esc>*rB<esc>*rA between each and every row
**  of data.  This defeats compression mode 3 on a DeskJet, and also
**  makes the PaintJet (not XL) quite slow.  This next flag "-s" on the
**  command line, will attempt to do a reasonable job of stripping
**  out the excess commands.
**
**  The in_graphics flag will be used to strip unwanted control chars from
**  the file.
*/

char	strip_seq = FALSE;
char	in_graphics = FALSE;


/*
**  Just for certain special cases, it would be nice to append an <esc>E reset
**  to the end of the job.  Specify with "-r".
*/

char	reset_seq = FALSE;


char	*progname;		/* to hold the program name for verbose */

/*
**  Even though the horizontal offset command <esc>*b#X is obsolete, many
**  drivers still use it, and it causes some interesting problems with
**  mode 3 compression, so pclcomp needs to deal with it in some hopefully
**  intelligent fashion, and they will get stripped if -x is used.
*/

int	horiz_offset = 0;

char	strip_offsets = FALSE;


static float	Get_Frac();	/* instead of scanf */



/*
******************************************************************************
**
**				Main program.
**
******************************************************************************
*/

main(argc, argv)
int argc;
char *argv[];
{
  int	c,j;
  extern char *optarg;
  extern int   optind;

	progname = argv[0];

#ifdef MSDOS
	setmode(fileno(stdin), O_BINARY);	/* Place stdin and stdout in */
	setmode(fileno(stdout), O_BINARY);	/* binary mode. (Mike Slomin)*/
#endif

	/* parse up the args here */

  while ((c = getopt(argc, argv, "0123drsvzn:i:o:sx")) != EOF )
	switch(c){
	case '0':
			mode0 = TRUE;
			break;
	case '1':
			mode1 = TRUE;
			break;
	case '2':
			mode2 = TRUE;
			break;
	case '3':
			mode3 = TRUE;
			break;
	case 'd':
			deskjet = TRUE;
			break;
	case 'r':
			reset_seq = TRUE;
			break;
	case 's':
			strip_seq = TRUE;
			break;
	case 'v':
			verbose = TRUE;
			break;
	case 'x':
			strip_offsets = TRUE;
			break;
	case 'z':
			zerostrip = FALSE;
			break;
	case 'n':
			rpix = atoi(optarg);	/* new default */
			rasterwidth = (rpix + 7) / 8;	/* round up */
			break;

	case 'i':
			filein = optarg;
			break;
	case 'o':
			fileout = optarg;
			break;

	case '?':
	default:
			fprintf(stderr, 
			"Usage: %s [-0123drsvxz] [-n###] [infile [outfile]]\n",
				argv[0]);
			exit(-1);
	};

	if ( verbose )
	{
		fprintf(stderr, "%s: %s\n", argv[0], rev_id);
	}


  if ( ! ( mode0 || mode1 || mode2 || mode3) )	/* any modes on? */
	mode0 = /* mode1 = */ mode2 = mode3 = TRUE;	/* 3 modes by default */

	/*
	**  Check to see if any file args were given on the command line.
	**  Ones that were not preceded by a "-i" or "-o".
	*/

	if ( filein == NULL && optind < argc && argv[optind] != NULL )
		filein = argv[optind++];

	if ( fileout == NULL && optind < argc && argv[optind] != NULL )
		fileout = argv[optind++];

	/*
	**  Now open files for stdin and stdout if provided by the user.
	*/

	if ( filein != NULL )		/* new input file */

		if ( freopen( filein, "rb", stdin ) == NULL )
		{
			fprintf(stderr,"Unable to open %s for input.\n",filein);
			exit(-42);
		}

	if ( fileout != NULL )		/* new output file */

		if ( freopen( fileout, "wb", stdout ) == NULL )
		{
			fprintf(stderr, "Unable to open %s for output.\n",
				fileout);
			exit(-43);
		}


	/*
	**
	**		This is the pcl input parsing loop.
	**
	*/

	while( ( c = getchar() ) != EOF )
	{

		/*  Ignore all chars until an escape char  */

		/*
		**  If we are in graphics, toss it if strip_seq is set.
		*/

		if ( c != ESC )
		{
			if ( !strip_seq || !in_graphics )
				putchar(c);	/* pass it thru */

			continue;	/* pop to the top of the loop */
		}

		/*
		**  Now we have an escape sequence, get the parameter char.
		*/

		parameter = getchar();

		if ( parameter == EOF ) 	/* oops */
		{
			putchar ( ESC );
			fprintf(stderr, "Warning:  File ended with <esc>.\n");
			break;			/* unexpected end of input */
		}

		/*
		**  Now check to see if it is a two character sequence.
		*/

		if ( parameter >= '0' && parameter <= '~' )
		{
			putchar ( ESC );
			putchar ( parameter );		/* pass it thru */

			/*
			**  If the second character is an E, then we
			**  and the printer do a reset.
			*/

			if ( parameter == 'E' )
			{
				free_mem();
				curr_plane = 0;
				num_planes = 1;
				imaging = FALSE;
				inmode = 0;
				outmode = 0;
				in_graphics = FALSE;

				/* can't do this if user gave value with -n.
				rasterwidth = DEFAULT/8;
				rpix = DEFAULT;
				*/
			}

			continue;		/* return to the top */
		}

		/*
		**  Now check to make sure that the parameter character is
		**  within range.
		*/

		if ( parameter < '!' || parameter > '/' )
		{
			putchar ( ESC );
			putchar ( parameter );

			fprintf(stderr, "Warning:  Invalid escape sequence.\n");

			continue;
		}

		/*
		**  We are only interested in certain parameters, so pass
		**  the rest of the sequences.
		*/

		/*
		**  For the moment, we are only interested in '*' (graphics)
		**  '(' and ')' (downloads).  Although we do not do anything
		**  with downloads, we need to pass the binary data thru
		**  untouched.
		**  Oops, '&' is handled too.
		*/

		if ( parameter != '*' && parameter != '(' 
			&& parameter != ')' && parameter != '&' )
		{

			/*
			**  If the "stripper" is active, we need to suspend
			**  it till graphics are re-started.
			*/

			if ( strip_seq && !in_graphics )
			{
				curr_plane = 0;
				free_mem();		/* force re-start */
			}

			/*
			**  Pass thru the sequence intact.
			*/

			putchar ( ESC );
			putchar ( parameter );
			Flush_To_Term();		/* flush rest of seq. */
			continue;
		}


		/*
		**  Parameter character is in range, look for a valid group char
		*/

		group_char = getchar();

		if ( group_char == EOF )	/* oops, ran out of input */
		{
			putchar ( ESC );
			putchar ( parameter );

			fprintf(stderr, "Warning:  Incomplete escape sequence.\n");
			break;
		}

		/*
		**  See if in proper range.  If it isn't, it is not an error
		**  because the group character is optional for some sequences.
		**  For the moment, we are not interested in those sequences,
		**  so pass them thru.
		*/

		if ( group_char < '`' || group_char > '~' )
		{

			/*
			**  If the "stripper" is active, we need to suspend
			**  it till graphics are re-started.
			*/

			if ( strip_seq && !in_graphics )
			{
				curr_plane = 0;
				free_mem();		/* force re-start */
			}

			/*
			**  Pass thru the sequence intact.
			*/

			putchar ( ESC );
			putchar ( parameter );
			putchar ( group_char );
			if ( group_char < '@' || group_char > '^' )
				Flush_To_Term();	/* pass rest of seq. */
			continue;
		}

		/*
		**  Now we have a valid group character, decide if we want
		**  to deal with this escape sequence.
		**
		**  Sequences we want do deal with include:
		**
		**    <esc>*r	** graphics
		**    <esc>*b	** graphics
		**    <esc>*v	** graphics
		**
		**  Sequences we must pass thru binary data:
		**
		**    <esc>*c	** pattern
		**    <esc>*s	** download dither
		**    <esc>*t	** obsolete
		**    <esc>(f	** download char set
		**    <esc>(s	** download char
		**    <esc>)s	** download font
		**    <esc>&a	** logical page
		**    <esc>&l	** obsolete
		**
		*/

		if (  ( parameter == '*'
			&& group_char != 'r' && group_char != 'b' 
			&& group_char != 'v' && group_char != 'c' 
			&& group_char != 't' && group_char != 's' )
		   || ( parameter == '&'
			&& group_char != 'a' && group_char != 'l' )
		   || ( parameter == '(' 
			&& group_char != 'f' && group_char != 's' )
		   || ( parameter == ')' && group_char != 's' ) )
		{
			/*
			**  Definately not interested in the sequence.
			*/

			/*
			**  If the "stripper" is active, we need to suspend
			**  it till graphics are re-started.
			*/

			if ( strip_seq && !in_graphics )
			{
				curr_plane = 0;
				free_mem();		/* force re-start */
			}

			/*
			**  Pass thru the sequence intact.
			*/

			putchar ( ESC );
			putchar ( parameter );
			putchar ( group_char );
			Flush_To_Term();
			continue;
		}


		/*
		**  If the sequence is <esc>&a#H, it will have gotten past
		**  the above, but we need to suspend the "stripper" if
		**  it is active, because the CAP is getting moved.
		**
		**  The <esc>*p#X/Y sequences will have been filtered
		**  thru just above (<esc>*p is not a needed group).
		*/

		if ( strip_seq && parameter != '*' && !in_graphics )
		{
			curr_plane = 0;
			free_mem();		/* force re-start */
		}


		/*
		**  Now set up a pass thru flag so we can ignore the entire
		**  sequences of some of these.
		*/

		if ( parameter != '*' )
			pass_seq = TRUE;

		else if ( group_char == 'c' || group_char == 't' 
		       || group_char == 's' )

			pass_seq = TRUE;
		else
			pass_seq = FALSE;


		/*
		**  Now we have a sequence that we are definately interested in.
		**
		**  Get the value field and terminator, and loop until final
		**  terminator is found.
		*/

		do
		{
			/* first see if the value has a plus sign */

			scanf_count = scanf(" + %d", &value );

			if ( scanf_count == 1 )

				plus_sign = TRUE;
			else
			{
				plus_sign = FALSE;

				scanf_count = scanf(" %d", &value );

				if ( scanf_count == 0 )
					value = 0;		/* by default */
			}

			/*
			**  I wonder if I will get bitten by a trailing
			**  space character right here?
			*/

			terminator = getchar();

			/*
			**  Check for a fractional component.
			*/

			fvalue = 0.0;

			if ( terminator == '.' )
			{
				fvalue = Get_Frac();

				/*
				**  Now get real terminator.
				*/

				terminator = getchar();
			}


			if ( terminator == EOF )	/* barf */
			{
				fprintf(stderr, 
				"Warning:  Incomplete sequence at EOF.\n");
				break;
			}

			/*
			**  If the pass_seq flag is set, then just pass
			**  it thru to stdout until a 'W' is found.
			*/

			if ( pass_seq )
			{
				/*
				**  If not in sequence, then we output esc
				**  otherwise, output the saved terminator.
				*/

				if ( !in_sequence )
				{
					in_sequence = TRUE;
					putchar ( ESC );
					putchar ( parameter );
					putchar ( group_char );
				} else
				{
					putchar ( old_terminator );
				}

				/* now pass the value */

				if ( plus_sign )
					putchar('+');

				/*
				**  See if there was a non-zero fraction.
				*/

				if ( fvalue != 0.0 )
				{
					if ( value < 0 )
					{
						putchar('-');
						value = -value;
					}

					fvalue += value;

					printf("%g", fvalue);

				} else if ( scanf_count )
					printf("%0d", value);
				
				/*
				**  We save the terminator, because we may
				**  need to change it to upper case.
				*/

				old_terminator = terminator;

				/* if binary data, pass it thru */

				if ( terminator == 'W' )	/* aha */
				{
					putchar ( terminator );
					in_sequence = FALSE;	/* terminates */
					Flush_Bytes ( value );	/* pass data */
				}

				continue;
			}

			/*
			**  Ok, this is a sequence we want to pay attention to.
			**
			**  Do_Graphics returns TRUE if we need to pass seq.
			**
			**  Note:  Do_Graphics modifies the parser vars such
			**	   as in_sequence.  This is because it may
			**	   have to output stuff directly.
			*/

			if ( Do_Graphics ( group_char, value, terminator ) )
			{
				/*
				**  If not in sequence, then we output esc
				**  otherwise, output the saved terminator.
				*/

				if ( !in_sequence )
				{
					in_sequence = TRUE;
					putchar ( ESC );
					putchar ( parameter );
					putchar ( group_char );
				} else
				{
					putchar ( old_terminator );
				}

				/* now pass the value */

				if ( plus_sign )
					putchar('+');

				/*
				**  See if there was a non-zero fraction.
				*/

				if ( fvalue != 0.0 )
				{
					if ( value < 0 )
					{
						putchar('-');
						value = -value;
					}

					fvalue += value;

					printf("%g", fvalue);

				} else if ( scanf_count )
					printf("%0d", value);

				/*
				**  We save the terminator, because we may
				**  need to change it to upper case.
				*/

				old_terminator = terminator;
			}

		} while ( terminator >= '`' && terminator <= '~' );

		/*
		** The oppsite test (above) may be more appropriate.  That is, 
		** !(terminator >= '@' && terminator <= '^').
		*/
		
		/*
		**  If we were in a sequence, then we must terminate it.
		**  If it was lower case, then it must be uppered.
		*/

		if ( in_sequence )
		{
			putchar ( terminator & 0xdf );		/* a ==> A */
			in_sequence = FALSE;
		}
	}
	

	/*
	**  If the user wants a reset, give him one.
	*/

	if ( reset_seq )
	{
		putchar ( ESC );
		putchar ( 'E' );
	}


	/*
	**  Finished up, so print stats and close output file.
	*/

	fclose(stdout);


	if ( verbose )
	{
		for(j = 0; j < 4; j++)
			fprintf(stderr,"Rows in mode %1d: %d\n", j, inuse[j]);
		for(j = 0; j < 4; j++)
			fprintf(stderr,"Rows out mode %1d: %d\n", j, outuse[j]);
	}

	exit(0);
}


/*
**  Do_Graphics() takes the graphics escape sequence and performs the
**  necessary functions.
**  TRUE is returned if the escape sequence needs to be passed to the output.
*/

int	Do_Graphics( group, num, terminator )
int	group, num, terminator;
{
	/*  first look at vW  */

	if ( group == 'v' )

		if ( terminator != 'W' )
			
			return ( TRUE );	/* pass it thru */
		else
		{
			if ( !in_sequence )
			{
				putchar ( ESC );
				putchar ( parameter );
				putchar ( group );
			} else
				putchar ( old_terminator );

			in_sequence = FALSE;		/* terminating */

			printf("%0d", num);
			putchar ( terminator );

			free_mem();	/* reset memory */

			imaging++;

			fread(&imdata, MIN(num, 18), 1, stdin);
			fwrite(&imdata, MIN(num, 18), 1, stdout);

			num -= MIN(num, 18);

			/* copy rest of unknown data */

			if ( num > 0 )
				Flush_Bytes(num);


			switch(imdata.pix_mode){
				case 0x00:
					rasterwidth = (rpix + 7)/8;
					num_planes = imdata.inx_bits;
					break;
				case 0x01:
					rasterwidth = rpix*imdata.inx_bits/8;
					break;
				case 0x02:
					rasterwidth = (rpix + 7)/8;
					num_planes =imdata.red + imdata.green +
						    imdata.blue;
					break;
				case 0x03:
					rasterwidth = (imdata.red +
						       imdata.green +
						       imdata.blue)*rpix/8;
					break;
			}

			return ( FALSE );
		}

	/*
	**  Now deal with <esc>*r stuff
	*/

	if ( group == 'r' )
	{
		switch ( terminator )
		{
			case 'A':
			case 'a':

				/* Enter graphics mode, enable stripping */

				in_graphics = TRUE;

				/* if user wants to strip redundant seq */
				if ( strip_seq && memflag )
					return( FALSE );

				curr_plane=0;
				zero_seeds();	/* may allocate mem */
				break;

			case 'C':
			case 'c':

				/* Exit graphics, disable stripping */

				in_graphics = FALSE;

				if ( strip_seq )
					return( FALSE );

				inmode = 0;
				outmode = 0;

				free_mem();
				curr_plane=0;
				break;

			case 'B':
			case 'b':

				/* Exit graphics, disable stripping */

				in_graphics = FALSE;

				if ( strip_seq )
					return( FALSE );

				if ( deskjet )	/* B resets modes on DJ */
				{
					inmode = 0;
					outmode = 0;
				}
				free_mem();
				curr_plane=0;
				break;

			case 'S':
			case 's':

				/* free mem in case widths changed */
				free_mem();

				rpix = num;

				if (imaging){
					switch(imdata.pix_mode)
					{
						case 0x00:
							rasterwidth=(rpix+7)/8;
							break;
						case 0x01:
							rasterwidth = 
							 rpix*imdata.inx_bits/8;
							break;
						case 0x02:
							rasterwidth=(rpix+7)/8;
							break;
						case 0x03:
							rasterwidth = 
							  (imdata.red 
							  + imdata.green
							  + imdata.blue)*rpix/8;
							break;
					}
				} else
					rasterwidth = (num + 7) / 8;
				break;

			case 'T':
			case 't':
				break;

			case 'U':
			case 'u':
				curr_plane=0;
				free_mem();	/* if ESC*rA came first */

				/*  num can be negative */

				if ( num < 0 )
					num_planes= -num;
				else
					num_planes = num;

				imaging = FALSE;	/* goes off */
				break;

			default:
				break;
		}

		return ( TRUE );		/* pass sequence on */

	}	/* group r */

	/*
	**  Last and final group 'b'.  All the graphics data comes thru here.
	*/


	switch ( terminator )
	{
	       case 'm':
	       case 'M':
			inmode = num;
			return ( FALSE );	/* we do NOT pass this */
			break;

	       /*
	       **  <esc>*b#X is obsolete, but I need to use it.
	       **  In addition, they will not get passed thru.
	       */

	       case 'x':
	       case 'X':
			/*
			**  Compute in bytes, rounding down.
			*/

			horiz_offset = num / 8;

			if ( horiz_offset < 0 ) 	/* just in case */
				horiz_offset = 0;

			if ( strip_offsets || horiz_offset == 0 )
				return ( FALSE );	/* do not pass seq */

			break;

	       case 'y':
	       case 'Y':
			/* zero only if allocated */
			if ( memflag )
				zero_seeds();
			break;

	       case 'W':
			if(!memflag)
				zero_seeds();		/* get memory */

			/* fire up sequence */

			if ( !in_sequence )
			{
				putchar ( ESC );
				putchar ( parameter );
				putchar ( group );
			} else
				putchar ( old_terminator );

			in_sequence = FALSE;		/* terminating */

			/*
			**  Check to see if we are expecting another plane.
			*/

			if(curr_plane < num_planes) 
			{
				/*
				**  If the input file does not have all the
				**  expected planes  (i.e., <esc>*b0W instead
				**  of <esc>*b0V<esc>*b0V<esc>*b0W), then
				**  special handling is needed.
				*/

				if( curr_plane + 1 < num_planes )
				{
					Process_Gap ( num );

				} else		/* don't worry, be happy */

					Process(num, 'W');

			} else		/* oops, too many planes of data */

				Process_extra(num,'W');   

			curr_plane=0;

			return ( FALSE );

			break;

	       case 'V':
			if(!memflag)
				zero_seeds();		/* get memory */
			
			/*
			**  If curr_plane is the last plane, this should
			**  be a 'W', not a 'V'.  I could change it,
			**  then I would fix Process_extra() to not output
			**  anything as the 'W' was already sent.
			*/

			if( curr_plane < num_planes ) 
			{
				/* fire up sequence */

				if ( !in_sequence )
				{
					putchar ( ESC );
					putchar ( parameter );
					putchar ( group );
				} else
					putchar ( old_terminator );

				in_sequence = FALSE;	/* terminating */
			

				Process(num, 'V');
				curr_plane++;
			} else
				Process_extra(num,'V');

			return ( FALSE );

			break;

		default:
			break;
	}

	return ( TRUE );		/* pass sequence */
}


/*
**  Flush_To_Term() simply passes thru input until a valid terminator
**  character is found.  This is for unwanted escape sequences.
*/

Flush_To_Term()
{
	int	c;

	do
	{
		c = getchar();

		if ( c == EOF ) 		/* this is a problem */
			return;
		
		putchar ( c );

	} while ( c < '@' || c > '^' );
}


/*
**  Flush_Bytes() simply transfers so many bytes directly from input to output.
**  This is used to pass thru binary data that we are not interested in so that
**  it will not confuse the parser.  I.e. downloads.
*/

Flush_Bytes( num )
unsigned int	num;
{
	int	bnum;

	while ( num > 0 )
	{
		bnum = MIN ( BUFSIZ, num );

		fread( buf, 1, bnum, stdin );

		if ( fwrite( buf, 1, bnum, stdout ) < bnum )

			/* check for error and exit */

			if ( ferror(stdout) )
			{
				perror("Output error");
				exit(-2);
			}

		num -= bnum;
	}
}




/*----------------------------------------*/

/*
**	Zero_seeds() will allocate and initialize memory.
**	If memory has already been allocated, then it will just initialize it.
*/


zero_seeds()
{
	int r;

	/* first allocate and init seed_rows for number of planes. */

	for ( r = 0; r < num_planes ; r++)
	{
		if(!memflag)
		{
			seed_row[r] = (unsigned char *) malloc(rasterwidth);

			if ( seed_row[r] == NULL )
			{
				fprintf(stderr, "Out of memory.\n");
				exit(-3);
			}
		}

		/* zero seeds for mode 3 */

		memset(seed_row[r], 0, rasterwidth);
	}


	if(!memflag)
	{
		new_row = (unsigned char *) malloc(rasterwidth);

		if ( new_row == NULL )
		{
			fprintf(stderr, "Out of memory.\n");
			exit(-3);
		}

		for(r=0; r<MAXMODES; r++)
		{
			/* 2 * width is needed for modes 1, 2 and 3 */

			out_row[r] = (unsigned char *) malloc(2 * rasterwidth);

			if ( out_row[r] == NULL )
			{
				fprintf(stderr, "Out of memory.\n");
				exit(-3);
			}
		}

	}

	memset(new_row, 0, rasterwidth);

	memflag = TRUE; 		/* memory is in place */
}


/* this routine if for incomplete transfers of data */

zero_upper(plane)
int	plane;
{
	int i;

	/* assume memory already present */

	for ( i = plane; i < num_planes; i++)
		memset(seed_row[i], 0, rasterwidth);
}


/*
**  Process() manages the decompression and re-compression of data.
*/

Process(inbytes, terminator)
int inbytes, terminator;
{

	int insize;
	int minmode = 0;

	inuse[inmode]++;

	/*
	**  Clamp horizontal offset to the rasterwidth for safety.
	*/

	if ( horiz_offset > rasterwidth )

		horiz_offset = rasterwidth;

	/*
	**  Zero out horiz_offset bytes in new_row.
	*/

	if ( horiz_offset )

		memset ( new_row, 0, horiz_offset );


	switch ( inmode ) {

	case 0:
		if ( !widthwarning && inbytes > rasterwidth )
		{
			/* This is likely to result in data truncation. */
			widthwarning = TRUE;
			fprintf(stderr,"Warning: Input pixel width exceeds expected width.\n");
		}

		insize = Mode_0_Graphics( inbytes, rasterwidth - horiz_offset,
				new_row + horiz_offset);
		break;
	case 1:
		insize = Mode_1_Graphics( inbytes, rasterwidth - horiz_offset,
				new_row + horiz_offset);
		break;
	case 2:
		insize = Mode_2_Graphics( inbytes, rasterwidth - horiz_offset,
				new_row + horiz_offset);
		break;
	case 3:
		memcpy(new_row, seed_row[curr_plane], rasterwidth);

		if ( horiz_offset )
			memset ( new_row, 0, MIN( horiz_offset, rasterwidth ) );

		insize = Mode_3_Graphics(inbytes, rasterwidth - horiz_offset,
				new_row + horiz_offset);
		break;

	default:		/* unknown mode? */

		/*  Don't know what to do about seed rows, pass stuff thru */

		fprintf(stderr, "%s: Unsupported compression mode %d.\n",
			progname, inmode );

		ChangeMode(inmode);	/* go to that mode */

		/* <esc>*b has already been output */

		printf("%1d%c", inbytes, terminator);

		Flush_Bytes( inbytes );

		firstrow = TRUE;		/* pop it out of mode 3 */

		/*  Go ahead and clear the seed rows if present  */
		if ( memflag )
			zero_seeds();

		return;

	}

	/*
	**  We need to account for the horizontal offset, but if strip_offsets
	**  is on, then assume that zero is white.
	*/

	if ( strip_offsets )
		horiz_offset = 0;


	if ( mode0 )
		/* actually, this is redundant since new_row is mode 0 */
		out_size[0] = Output_0( new_row + horiz_offset, out_row[0], 
				rasterwidth - horiz_offset );
	else
		out_size[0] = MAXBYTES+1;

	if ( mode1 )
		out_size[1] = Output_1( new_row + horiz_offset, out_row[1], 
				rasterwidth - horiz_offset );
	else
		out_size[1] = MAXBYTES+1;

	if ( mode2 )
		out_size[2] = Output_2( new_row + horiz_offset, out_row[2], 
				rasterwidth - horiz_offset );
	else
		out_size[2] = MAXBYTES+1;

	if ( mode3 )
		out_size[3] = Output_3( seed_row[curr_plane] + horiz_offset, 
				new_row + horiz_offset, out_row[3], 
				rasterwidth - horiz_offset );
	else
		out_size[3] = MAXBYTES+1;
	

	/*
	**  Obsolete comment:
	**
	**  Now determine which mode will give the best output.  Note that it
	**  takes 5 bytes to change modes, so we penalize all modes that are
	**  not the current output by 5 bytes.	This is to discourage changing
	**  unless the benifit is worth it.  The exception to this rule is
	**  mode 3.  We want to encourage going to mode 3 because of the seed
	**  row behaviour.  That is, if we have a simple picture that does
	**  not change much, and say each of the sizes for modes 1 and 2 always
	**  comes out to 4 bytes of data, then if we add 5 to mode 3 each time,
	**  it would never get selected.  But, we remove the penalty, and if
	**  mode 3 is selected (0 bytes of data needed for mode 3), then each
	**  succesive row only needs 0 bytes of data.  For a 300 dpi A size
	**  picture with 3 data planes, this could be a savings of 37k bytes.
	*/

	/*
	**  With the new parser, the output to change modes is now only
	**  2 bytes, since it gets combined with the *b#W sequence.
	**  So, I decided to ignore the switching penalty.
	*/

	/*
	**  Due to a possible bug in PaintJet XL, don't allow mode 3 to be
	**  selected for the first row of output.  But do allow it if the
	**  user has no other mode selected.
	*/

	if ( firstrow && (mode0 || mode1 || mode2) )
	{
		out_size[3] = MAXBYTES+1;	/* disable mode 3 for now */

		if ( terminator == 'W' )	/* last plane? */
			firstrow = FALSE;	/* no longer first row */
	}


	minmode = 3;

	if ( out_size[2] < out_size[minmode] )
		minmode = 2;

	if ( out_size[1] < out_size[minmode] )
		minmode = 1;

	if ( out_size[0] < out_size[minmode] )
		minmode = 0;


					/* I may remove this sometime */
	if ( minmode != outmode )
		if ( out_size[minmode] == out_size[outmode] )
			minmode = outmode;


	outuse[minmode]++;

	if ( outmode != minmode )
		ChangeMode( minmode );
	
	/* <esc>*b has already been output */

	printf("%1d%c", out_size[minmode], terminator);

	if ( fwrite( out_row[minmode], 1, out_size[minmode], stdout) < 
							out_size[minmode] )

		/* check for error and exit */

		if ( ferror(stdout) )
		{
			perror("Output error");
			exit(-2);
		}


	memcpy(seed_row[curr_plane], new_row, rasterwidth);

	/*
	**  Now clear horizontal offset for next plane.
	*/

	horiz_offset = 0;

}


/*
**  Process_Gap() is to handle the case where less planes are sent for a
**  row than we are expecting.	For example, if we are expecting 3 planes
**  per row, and the driver decides to take a short cut for blank areas and
**  send only the final 'W'  ( <esc>*b0W instead of the complete <esc>*b0V
**  <esc>*b0V <esc>*b0W), then we have to do some special handling for mode
**  3 seed rows.
**
**  The terminator is not needed as a parameter since we know that it must
**  be 'W' to get into this routine.
*/

Process_Gap(bytes)
int	bytes;
{
	char	save0, save1, save2, save3;

	/*
	**  If the input file does not have all the expected planes  
	**  (i.e., <esc>*b0W instead **  of <esc>*b0V<esc>*b0V<esc>*b0W), 
	**  then special handling is needed.
	**
	**  4 cases are handled:
	**
	**  input mode	output mode   extra action
	**  ----------	-----------   ------------
	**
	**    non-3	  non-3       zero seeds
	**
	**	3	    3	      do nothing
	**
	**    non-3	    3	      zero seeds & extra output
	**
	**	3	  non-3       extra output
	**
	**  Note:  We don't know what the output
	**  mode will be before we call Process(),
	**  so we must force the modes.
	*/

	/*
	**  Save output modes in case we need to manipulate them.
	*/

	save0 = mode0;
	save1 = mode1;
	save2 = mode2;
	save3 = mode3;


	if ( inmode != 3 )
	{
		/*
		**  Force output to non-3
		**  to do as little as possible.
		*/

		if ( mode0 || mode1 || mode2 )
		{
			mode3 = FALSE;

			Process(bytes, 'W');

			mode3 = save3;		/* restore mode 3 */

			zero_upper( curr_plane + 1);

		} else	/* mode 3 is only one allowed for output */
		{
			/*
			**  We must output more info.
			*/

			Process( bytes, 'V' );	/* convert to plane */

			curr_plane++;

			while ( curr_plane < num_planes )
			{
				/*
				**  Restart graphics data sequence.
				*/

				putchar ( ESC );
				putchar ( '*' );
				putchar ( 'b' );

				/*
				**  Call Process() with 0 bytes instead
				**  of just doing output because we
				**  need Process() to zero the appropriate
				**  seed rows, and to use mode 3 to clear
				**  the seed rows in the output (printer).
				*/

				if ( curr_plane + 1 == num_planes )

					Process(0, 'W');	/* last plane */
				else
					Process(0, 'V');

				curr_plane++;
			}
		}
	} else		/* inmode == 3 */
	{
		/*
		**  Inmode is 3, so make outmode be 3 so we can do nothing.
		*/

		if ( mode3 )			/* is mode 3 allowed? */
		{
			mode0 =
			mode1 =
			mode2 = FALSE;

			Process(bytes, 'W');

			mode0 = save0;		/* restore modes */
			mode1 = save1;
			mode2 = save2;

		} else				/* ooops, no mode 3 */
		{
			/*
			**  We must output more info.
			*/

			Process( bytes, 'V' );	/* convert to plane */

			curr_plane++;

			while ( curr_plane < num_planes )
			{
				/*
				**  Restart graphics data sequence.
				*/

				putchar ( ESC );
				putchar ( '*' );
				putchar ( 'b' );

				/*
				**  Call Process() with 0 bytes instead
				**  of just doing output because we
				**  need Process() to use the seed rows
				**  to create non-mode3 data.
				*/

				if ( curr_plane + 1 == num_planes )

					Process(0, 'W');	/* last plane */
				else
					Process(0, 'V');

				curr_plane++;
			}
		}
	}
}


/*
**  Process_extra() is to handle the extra planes.  That is, for PaintJets,
**  when sending 3 planes of data using <esc>*b#V, many drivers send a
**  fourth plane as <esc>*b0W to terminate the row, instead of the recommended
**  'W' as the 3rd plane.  This routine handles the extra without disturbing
**  the mode 3 seed rows.
**
**  In the future, this routine could be used to strip out the 4th plane.
*/

Process_extra(bytes, terminator)
int	bytes;
char	terminator;
{
	int  i;

	/* toss any excess data */

	for(i = 0; i < bytes; i++)
	   getchar();

	/* last plane? force move down to next row */

	if(terminator == 'W')
	{
		/* <esc>*b has already been output */
		printf("0W");

		firstrow = FALSE;		/* not on first row anymore */

	}

}

/*
**  ChangeMode() simply outputs the sequence to change compression modes.
*/

ChangeMode(newmode)
int newmode;
{
	/*
	**  <esc>*b have already been output.
	**  terminator is 'm' instead of 'M' since will be followed by 'W'
	*/
	printf("%1dm", newmode);
	outmode = newmode;
}


/*-----------------------------------------------------------------------*\
 |									 |
 |  Function Name: Mode_0_Graphics					 |
 |									 |
 |  Description:							 |
 |									 |
 |  This is the routine that handles a Mode 0 graphics block transfer	 |
 |  to the Formatter Module.						 |
 |									 |
\*-----------------------------------------------------------------------*/

/* FUNCTION */

Mode_0_Graphics(input_bytes, output_bytes, address)

unsigned int
   input_bytes, 		/* Count of bytes to be read. */
   output_bytes;		/* Count of bytes to be stored. */

unsigned char
   *address;			/* Pointer to where to store bytes. */

{
   /* LOCAL VARIABLES */

   unsigned char
      *store_ptr;		/* Pointer to where to store the byte. */

   unsigned int
      read_bytes,		/* Local copy of input_bytes. */
      write_bytes;		/* Local copy of output_bytes. */

   /* CODE */

   /* Initialize the local variables. */

   read_bytes = input_bytes;
   write_bytes = output_bytes;
   store_ptr = address;
   

   /* transfer the lesser of available bytes or available room */

     Transfer_Block( MIN(write_bytes,read_bytes), store_ptr);

   /* now zero fill or throw excess data away */

   if ( read_bytes > write_bytes )
      Discard_Block(read_bytes - write_bytes);		/* throw excess */
   else {
      store_ptr += read_bytes;				/* adjust pointer */
      write_bytes -= read_bytes;			/* zero fill count */

      memset(store_ptr, 0, write_bytes);
   }

   return ( input_bytes );
}


/*-----------------------------------------------------------------------*\
 |									 |
 |  Function Name: Mode_1_Graphics					 |
 |									 |
 |  Description:							 |
 |									 |
 |  This is the routine that handles a Mode 1 graphics block transfer	 |
 |  to the Formatter Module.  Mode 1 graphics is a compacted mode.	 |
 |  The data in Mode 1 is in pairs.  The first byte is a replicate	 |
 |  count and the second byte is the data.  The data byte is stored	 |
 |  then replicated the replicate count.  Therefore a replicate count	 |
 |  of 0 means the data byte is stored once.  The input byte count	 |
 |  must be an even amount for the data to be in byte pairs.		 |
 |									 |
\*-----------------------------------------------------------------------*/

/* FUNCTION */

Mode_1_Graphics(input_bytes, output_bytes, address)

unsigned int
   input_bytes, 		/* Count of bytes to be read. */
   output_bytes;		/* Count of bytes to be stored. */

unsigned char
   *address;			/* Pointer to where to store bytes. */

{
   /* LOCAL VARIABLES */

   unsigned char
      *store_ptr,		/* Pointer to where to store the byte. */
      input_char;		/* Byte to be replicated. */

   unsigned int
      read_bytes,		/* Local copy of input_bytes. */
      write_bytes;		/* Local copy of output_bytes. */

   int
      replicate_count;		/* Number of times to replicate data. */

   /* CODE */

   /* Initialize the local variables. */

   read_bytes = input_bytes;
   write_bytes = output_bytes;
   store_ptr = address;
   
   /* Check for an even input count. */

   if ((read_bytes % 2) == 0)
   {
      /* Even so input data is in pairs as required. So store the data. */
   
      while ((read_bytes != 0) && (write_bytes != 0))
      {
	 /* First get the replicate count and the byte to store. */

	 replicate_count = (unsigned char) Get_Character();
	 input_char = Get_Character();
	 read_bytes -= 2;
      
	 /* Since write_bytes was 0 there is room to store the byte. */

	 *store_ptr++ = input_char;
	 write_bytes--;
	 
	 /* Now make sure there is room for the replicated data. */

	 if (replicate_count > write_bytes)
	 {
	    /* Too much so limit to the room available. */

	    replicate_count = write_bytes;
	 }
	    
	 /* Update the amount to be written. */

	 write_bytes -= replicate_count;

	 /* Then replicate it. */

	 while (replicate_count != 0)
	 {
	    /* Store the byte the decrement the count. */

	    *store_ptr++ = input_char;
	 
	    replicate_count--;
	 }
      }

   }
   /* Discard any left over input. */
	/* OR */
   /* Discard all of the input data as odd byte count. */

   Discard_Block(read_bytes);

   read_bytes = store_ptr - address;  /* how much was done? */

   /* zero fill if needed */
   memset(store_ptr, 0, write_bytes);
	 
   return(read_bytes);
}


/*-----------------------------------------------------------------------*\
 |									 |
 |  Function Name: Mode_2_Graphics					 |
 |									 |
 |  Description:							 |
 |									 |
 |  This is the routine that handles a Mode 2 graphics block transfer	 |
 |  to the Formatter Module.  Mode 2 graphics is a compacted mode.	 |
 |  The data in Mode 2 is of one of two types.	The first type is a	 |
 |  class type and the second type is a data type.  The class type is	 |
 |  a single byte which is a combination of replicate count and a sub	 |
 |  mode.  There are two sub modes within mode 2, sub mode 0 and sub	 |
 |  mode 1.  These sub modes are flagged by the MSB of the class type	 |
 |  byte.  If the MSB = 0 then the replicate count is the value of the	 |
 |  class type byte.  In sub mode 0 the replicate count ranges from 1	 |
 |  to 127.  In sub mode 0 the next byte and then the replicate count	 |
 |  of bytes are of the data type and stored.  If the MSB = 1 then the	 |
 |  sub mode is 1 and the replicate count is the negative value of the	 |
 |  class type.  In sub mode 1 the replicate count is stored in 2s	 |
 |  compliment form and ranges from -1 to -127.  In sub mode 1 the	 |
 |  next byte is of the data type and is stored.  That data byte is	 |
 |  then replicated and stored the replicate count.  If the class type	 |
 |  byte is 128 then there is no data type byte.			 |
 |									 |
\*-----------------------------------------------------------------------*/

/* FUNCTION */

Mode_2_Graphics(input_bytes, output_bytes, address)

unsigned int
   input_bytes, 		/* Count of bytes to be read. */
   output_bytes;		/* Count of bytes to be stored. */

unsigned char
   *address;			/* Pointer to where to store bytes. */

{
   /* LOCAL VARIABLES */

   unsigned char
      *store_ptr,		/* Pointer to where to store the byte. */
      input_char,		/* Byte to be replicated. */
      sub_mode; 		/* Flag if sub mode is 0 or 1. */

   unsigned int
      read_bytes,		/* Local copy of input_bytes. */
      write_bytes;		/* Local copy of output_bytes. */

   int
      replicate_count;		/* Number of times to replicate data. */

   /* CODE */

   /* Initialize the local variables. */

   read_bytes = input_bytes;
   write_bytes = output_bytes;
   store_ptr = address;
   
   while ((read_bytes > 1) && (write_bytes != 0))
   {
      /* First get the class type byte and the first data type byte. */

      replicate_count = Get_Character();

      /* First check that this not an ignore class type. */

      if (replicate_count != 128)
      {
	 /* Not ignore so get the data class byte. */

	 input_char = Get_Character();
	 read_bytes -= 2;
	 
	/* Since write_bytes wasn't 0 there is room to store the byte. */

	 *store_ptr++ = input_char;
	 write_bytes--;

	 /* Determine the sub mode. */
   
	 if (replicate_count > 128)
	 {
	    /* Sub mode 1. */
   
	    sub_mode = 1;
	    /* replicate count was unsigned char */
	    replicate_count = 256 - replicate_count;
	 }
	 else
	 {
	    /* Sub mode 0. */
   
	    sub_mode = 0;

	    /* See if there is enoungh input left for the data byte count. */

	    if (replicate_count > read_bytes)
	    {
	       /* Too many data bytes so limit to the input left. */

	       replicate_count = read_bytes;
	    }
	 }
	    
	 /* Now make sure there is room for the replicated data. */
   
	 if (replicate_count > write_bytes)
	 {
	    /* Too much so limit to the room available. */
   
	    replicate_count = write_bytes;
	 }
	       
	 /* Update the amount to be written. */
   
	 write_bytes -= replicate_count;
   
	 /* Then replicate it. */
   
	 if (sub_mode == 0)
	 {
	    /* Sub mode 0 so get the replicate count of data bytes. */
   
	      Transfer_Block(replicate_count, store_ptr);

	    read_bytes -= replicate_count;
	    
	    /* Find the last byte stored. */
   
	    store_ptr += replicate_count;
	 }
	 else
	 {
	    /* Sub mode 1 so just duplicate the original byte. */
   
	    while (replicate_count != 0)
	    {
	       /* Store the byte the decrement the count. */
   
	       *store_ptr++ = input_char;
	    
	       replicate_count--;
	    }
	 }
      }
      else
      {
	 /* Ignore class so don't get the data class byte. */

	 read_bytes--;
      }
   }

   /* Now discard any left over input. */

   Discard_Block(read_bytes);

   read_bytes = store_ptr - address;

   /* zero fill if needed */
   memset(store_ptr, 0, write_bytes);
	 
   
   return(read_bytes);
}


/*-----------------------------------------------------------------------*\
 |									 |
 |  Function Name: Mode_3_Graphics					 |
 |									 |
 |  Description:							 |
 |									 |
 |  This is the routine that handles a Mode 3 graphics block transfer	 |
 |  to the Formatter Module.  Mode 3 graphics is a compacted mode.	 |
 |  Mode 3 data is a difference from one row to the next.  In order to	 |
 |  work, each row must be saved to be a seed for the next.  This	 |
 |  mode is used in conjuction with other compaction modes when the	 |
 |  data remains fairly constant between pairs of rows. 		 |
 |  The data is in the form:						 |
 |  <command byte>[<optional offset bytes>]<1 to 8 replacement bytes>	 |
 |  The command byte is in the form:					 |
 |    Bits 5-7: Number of bytes to replace (1 - 8)			 |
 |    Bits 0-4: Relative offset from last byte. 			 |
 |	 (If the offset is 31, then add the following bytes for offset	 |
 |	 until an offset byte of less then 255 (but inclusive)		 |
 |									 |
\*-----------------------------------------------------------------------*/

/* FUNCTION */

Mode_3_Graphics(input_bytes, output_bytes, address)

unsigned int
   input_bytes, 		/* Count of bytes to be read. */
   output_bytes;		/* Count of bytes to be stored. */

unsigned char
   *address;			/* Pointer to where to store bytes. */

{
   /* LOCAL VARIABLES */

   unsigned char
      *store_ptr,		/* Pointer to where to store the byte. */
      input_char;		/* Byte to be changed. */

   unsigned int
      read_bytes,		/* Local copy of input_bytes. */
      write_bytes;		/* Local copy of output_bytes. */

   unsigned int
      replace,			/* number of bytes to replace, 1-8 */
      offset;			/* relative offset */

#if BITFIELDS
   union comtype {
      unsigned char comchar;	/* command byte as char */
      struct btype {
	 unsigned repcount:3;	/* replace count 1-8 */
	 unsigned roff:5;	/* relative offset 0-30 */
      } bitf;
   } command;
#else
	unsigned char	command;
#endif

   /* CODE */

   /* Initialize the local variables. */

   read_bytes = input_bytes;
   write_bytes = output_bytes;
   store_ptr = address;

/* read_bytes has to be at least 2 to be valid */

   while ( read_bytes > 1 && write_bytes > 0 ){

      /* start by getting the command byte */

      read_bytes--;

#if BITFIELDS
      command.comchar = Get_Character();

      replace = command.bitf.repcount + 1;	/* replace count 1-8 */

      offset = command.bitf.roff;		/* offset 0-30, 31= extend */
#else
	command = Get_Character();
	replace = (command >> 5) + 1;
	offset = command & 0x1f;
#endif

      store_ptr += offset;
      write_bytes -= offset;

      if ( offset == 31 )		/* get more offsets */
	 do{

	    offset = Get_Character();

	    read_bytes--;
	    if ( read_bytes == 0 )		/* premature finish? */
	       return;				/* no zero fill wih 3 */

	    store_ptr += offset;
	    write_bytes -= offset;

	 } while (offset == 255);	/* 255 = keep going */
      
      /* now do the byte replacement */

      while ( replace-- && write_bytes > 0 && read_bytes > 0 ){
	 
	 *store_ptr++ = Get_Character();

	 read_bytes--;
	 write_bytes--;
      }
   }
   
   /* don't do any zero fill with mode 3 */

   /* discard any leftover input */

   Discard_Block(read_bytes);

   return( store_ptr - address );
}


Discard_Block(count)
unsigned int count;
{
	while ( count-- )
		getchar();
}

Transfer_Block( count, dest )
unsigned int count;
unsigned char *dest;
{
	fread(dest, 1, count, stdin);
}


/*
**  Output_0() does mode 0 compression (which is a no compression).
*/

Output_0(src, dest, count)
unsigned char *src, *dest;
int count;
{
	memcpy(dest, src, count);

	if ( zerostrip )
		while ( count && dest[count-1] == 0 )
			count--;

	return(count);

}



/*
**  Output_1() does mode 1 compression (run length encoding)
*/

Output_1(src, dest, count)
unsigned char *src, *dest;
register int count;
{
	unsigned char *optr = dest, *iptr;
	int k,c;

	if ( zerostrip )			/* strip zeros */
	{
		iptr = src + count - 1; 	/* point to end of data */

		while ( count > 0 && *iptr-- == 0 )	/* hunt thru 0's */
			count--;
	}

	iptr = src;

	while ( count ){
		
		c = *iptr++;		/* get value to work with */
		count--;

		k = 0;

		while ( *iptr == c && k < 255 && count ){
			k++;
			iptr++;
			count--;
		}

		*optr++ = k;		/* output repeat count */
		*optr++ = c;		/* output value */
	}

	count = optr - dest;		/* for return value */

	return ( count );
}


/*
******************************************************************************
**
**	 Output_2() does PCL compression mode 2 on the data. 
**	 This mode is a combination of modes 0 and 1.
**
******************************************************************************
*/

Output_2(src, dest, count)
unsigned char *src, *dest;
register int count;
{
	unsigned char	*outptr, *inptr;
	unsigned char	*saveptr;

	unsigned char	data;			/* data byte */
	unsigned char	lastbyte;		/* last byte */
	int		repcount;		/* repeat count */
	int		litcount;		/* literal count */

	/*
	**  src points to the intput data.
	**  dest points to the output buffer.
	**  count is the number of intput bytes.
	*/

	inptr = src;
	outptr = dest;

	/*
	**  Start loop thru data.  Check for possible repeat at beginning.
	*/

	while ( count )
	{
		data = *inptr++;	/* get value to work with */
		count--;

		repcount = 0;		/* no repeat count yet */


		/* 
		**  Check for repeat, since we are not in the middle
		**  of a literal run, it does not have to be more than
		**  two bytes of similar data.
		*/

		while ( count && *inptr == data )
		{
			repcount++;
			inptr++;
			count--;
		}

		/*
		**  Now, if we are out of data (count == 0), then
		**  if the repeated byte was zero, then ignore it
		**  completely (don't bother outputing the trailing zeros).
		**
		**  To always strip zero's, simply remove the "zerostrip"
		**  from the test.
		*/

		if ( count == 0 && data == 0 && zerostrip)
			break;			/* done */


		/*
		**  If there was a repeat (repcount > 0), then we
		**  can output the command here, otherwise, we
		**  need to go into literal run mode.
		**
		**  Note:  This is a while loop because the repeat count
		**  may actually be greater than 127.
		*/

		if ( repcount >= 1 )		/* repeat mode */
		{
			while (repcount > 127)
			{
				*outptr++ = 129;		/* count 127 */
				*outptr++ = data;		/* value */
				repcount-= 128; 		/* offset */
			}

			if (repcount > 0)
			{
				*outptr++ = 256 - repcount;	/* count */
				*outptr++ = data;		/* value */

				/*
				**  Now pop to the top of the loop 
				**  looking for more repeat counts.
				*/

				continue;			/* top of loop */
			}

			/*
			**  Special case.  If we have arrived at this point,
			**  then repcount is now equal to 0.  This means
			**  that when we entered this section, repcount
			**  was a multiple of 128 (i.e. 128 :-).
			**
			**  This means that there were 129 identical bytes,
			**  so the output does a replicate of 127 which
			**  gives 128 bytes, and we now have one byte left
			**  over which should NOT be output as a repeat
			**  run, rather it should be merged into the following
			**  literal run (if it exists).
			**
			**  So, we will simply fall thru to the next section
			**  of code which assumes that we are working on 
			**  a literal run.
			*/

		}

		/*
		**  Literal run.  At this point, the current data byte
		**  does NOT match the following byte.	We will transfer
		**  these non-identical bytes until:
		**
		**	 1)  we run out of input data (count == 0).
		**	 2)  we run out of room in this output block (128)
		**	 3)  we come across a value which occurs at least
		**	     three times in a row.  A value occuring only
		**	     twice in a row does NOT justify dropping
		**	     out of a literal run.
		**
		**  Special case:  If we run out of room in the output block
		**  (which is 128 bytes), the last two values are the same,
		**  AND there is more input, it makes sense to restart
		**  the repeat detector in case the following bytes are
		**  repeats of the two.  A simple check of the following
		**  byte will determine this.
		**  (This case falls out with the test for triples below).
		**
		**  Special case:  If we run out of room in the output block
		**  (which is 128 bytes), the last value is the same as
		**  the next one on the input, then it is better to let
		**  that byte be used in a possible replicate run following
		**  the literal run.  If the last byte matches ONLY the
		**  following byte, (and not the one after that, it is
		**  a wash, but for best results, we will test the
		**  following two bytes.
		**
		*/

		litcount = 0;
		saveptr = outptr++;	/* save location of the command byte */

		*outptr++ = data;	/* save the first byte. */

		lastbyte = data;	/* remember for testing */

		while ( count && litcount < 127 )
		{
			data = *inptr++;
			count--;
			litcount++;
			*outptr++ = data;

			/*
			**  Test to see if this byte matched the last one.
			**  If so, check the next one for a triple.
			*/

			if ( lastbyte == data && count && *inptr == data )
			{
				/*
				**  We have a triple, adjust accordingly.
				**
				**  Add two bytes back onto the input.
				*/

				count += 2;
				inptr -= 2;
				outptr -= 2;
				litcount -= 2;

				break;		/* out of loop */
			}

			lastbyte = data;	/* save data byte */
		}

		/*
		**  Check the special case number 2 above.
		*/

		if ( litcount == 127  &&  count > 1  &&  data == *inptr
		    &&	data == inptr[1] )
		{
			/*  Restore the last byte to the input stream */

			count += 1;
			inptr -= 1;
			outptr -= 1;
			litcount -= 1;
		}


		/*
		**  Save the literal run count.
		*/

		*saveptr = litcount;

		/*
		**  Now go back to the top and look for repeats.
		*/
	}

	count = outptr - dest;		/* for return value */

	return ( count );
}



/*
**  Output_3() does mode 3 compression (delta row encoding).
*/

Output_3(seed, new, dest, count)
unsigned char *seed, *new, *dest;
int count;
{
	unsigned char *sptr=seed, *nptr=new, *dptr=dest;
	int i,j;


#if BITFIELDS
   union comtype {
      unsigned char comchar;	/* command byte as char */
      struct btype {
	 unsigned repcount:3;	/* replace count 1-8 */
	 unsigned roff:5;	/* relative offset 0-30 */
      } bitf;
   } command;
#else
	unsigned char	command;
#endif

	while ( count > 0 ){
		i = 0;

					/* find first diff */
		while ( *sptr == *nptr && i < count ){
			i++;
			sptr++;
			nptr++;
		}

		if ( i >= count )	/* too far to find diff */
			return(dptr - dest);	/* bail */

		count -= i;
		
		/* now count how many bytes to change */

		for ( j = 1; j < 8; j++)	/* j == 0 is already known */
			if ( j > count || sptr[j] == nptr[j] )
				break;
		
		j--;	/* adjust */

#if BITFIELDS
		command.bitf.repcount = j;	/* 0-7 ==> 1-8 */

		command.bitf.roff = MIN ( i, 31 );

		*dptr++ = command.comchar;	/* output command */
#else
		command = (j << 5);
		command += MIN( i, 31 );
		*dptr++ = command;
#endif

		if ( i == 31 )
			*dptr++ = 0;
		
		i -= MIN (i, 31);

		while( i ){
			*dptr++ = MIN ( i, 255 );

			if ( i == 255 )
				*dptr++ = 0;
			
			i -= MIN ( i, 255 );
		}

		while (j-- >= 0){
			*dptr++ = *nptr++;
			sptr++;
			count--;
		}
	}

	return ( dptr - dest );
}


/*----------------------------------------------------------------------*\
 * This is here in case <ESC>*rU is sent after <ESC>*r#A, in which case *
 * we must deallocate the memory to provide for a different amount of	*
 * planes when graphics are sent.					*
\*----------------------------------------------------------------------*/

free_mem()	
{
	int r;


	if ( !memflag )
		return; 	/* no memory to free */

	free(new_row);

	for(r = MAXMODES -1; r >= 0; r--)
		free(out_row[r]);

	for(r = num_planes - 1; r >= 0; r--)
		free(seed_row[r]);

	memflag = FALSE;
}

/*
**  Get_Frac() simply gets the fractional part of a value.  This is here
**  because scanf() will consume a trailing 'e' or 'E', which is a problem
**  in PCL.
*/

static float	Get_Frac()
{
	float	result = 0.0;
	int	c;
	float	position = 10.0;

	while ( (c = getchar()) != EOF )
	{
		/*
		**  Do we have a digit?
		*/

		if ( !isdigit(c) )		/* not a digit */
		{
			ungetc( c, stdin );	/* put it back */
			break;			/* quit */
		}

		result += ((c - '0') / position);

		position *= 10.0;
	}

	return ( result );
}
