/****************************************************************/
/* File name:	UNEASY.C	Revised:	1993.10.03	*/
/* Created by:	U.R. Andersson	Created:	1990.11.27	*/
/* Copyright:	(c)1990 U.R. Andersson, all rights reserved.	*/
/*   but...	Rights for non-commercial uses released to PD.	*/
/****************************************************************/

/*
 * Inspired by Les Kneeling's "UNTAB.C / UNTAB.TTP"
 * but completely rewritten to provide specialized
 * reformatting capability for "easyride" files.
 *
 */

#include	<stdio.h>
#include	<osbind.h>
#include	<stdlib.h>

void	retab( short input, short output );

#define	tbsize 16384L

long	icnt;		/* input count 		*/
char	ibuf[tbsize];	/* input buffer		*/
long	ipos;		/* input position	*/
char	obuf[tbsize];	/* output buffer	*/
long	opos;		/* output position	*/

main( int argc, char **argv )
{
	short	input, output;

	if( argc < 3 || argc > 3 )
	{
		puts("UNEASY: Will retabulate \"easyride\" text");
		puts("");
		puts(" Usage: UNEASY iname oname");
		puts(" Where: iname = input  text file path\\name");
		puts("   and: oname = output text file path\\name");
		puts("   and: Those can not be the same file !");
		puts("");
		puts("Now press a key to exit.");
		Crawcin();
		return(0);
	}
	input = open( argv[1], 0 );
	if( input > 0 )
	{
		output = creat( argv[2], 0 );
		if( output > 0 )
		{	retab(input, output);
			close(output);
		}
		close( input );
	}
	return(0);
} /* ends main(argc, argv) */

void	retab( short input, short output)
{
	register	int	dpos;	/* definitive pos */
	register	int	tpos;	/* tentative pos  */
	register	int	qflg;	/* quote mode flag */
	register	int	nuch;	/* new input char */

	int	qflg2;

	nuch = qflg = dpos = tpos = 0;	/* zero initial values */
	qflg2 = 0;
	while( ( icnt = read(input, ibuf, tbsize) )  >  0 ) /* until EOF */
	{
		for( ipos = 0;  ipos < icnt;  ipos++ )
		{
			nuch = ibuf[ipos];
			switch(nuch)
			{	/* This is the main filter switch */

			case ' ':	/* space => note/send tentative space */
			case '\t':	/* HTab  => note/send tentative space */
				tpos++;		/* note it */
				if( qflg )	/* quoted constant ? */
				{	/* send it */
					obuf[opos++] = nuch;
					if( opos >= tbsize )
					{	write(output, obuf, opos);
						opos = 0;
					}
					dpos++;
				}
				break;

			case '\n':	/* LF => note & send definitive line end */
			case '\r':	/* CR => note & send definitive line end */
				obuf[opos++] = nuch;
				if( opos >= tbsize )
				{	write(output, obuf, opos);
					opos = 0;
				}
				dpos = tpos = qflg = 0;
				break;

			case '"':	/* Quote => start/end string constant */
			case '\'':	/* Apostrophe => start/end char constant */
				if( qflg == nuch )
					qflg = -1;	/* note quote end */
				if( qflg == 0 )
					qflg = nuch;	/* note quote */
			/* Then continue as for other "visible" char's */

			default:	/* Here we assume "nuch" = visible char */
				if( dpos < tpos  &&  qflg2 == 0 )
				{
					obuf[opos++] = '\t';
					if( opos >= tbsize )
					{	write(output, obuf, opos);
						opos = 0;
					}
					dpos = tpos = ((dpos+8) & (-8));
				}
				obuf[opos++] = nuch;
				if( opos >= tbsize )
				{	write(output, obuf, opos);
					opos = 0;
				}
				dpos = ++tpos;
				if( qflg < 0 )
					qflg = 0;
			} /* ends switch */
			qflg2 = qflg;
		} /* ends for */
	} /* ends while */
	if( opos )
	{	write(output, obuf, opos);
		opos = 0;
	}
} /* ends retab(input, output)	*/

/* End of file:	UNEASY.C	*/
