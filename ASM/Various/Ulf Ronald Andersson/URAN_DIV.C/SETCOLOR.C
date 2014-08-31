/****************************************************************/
/* File name:	SETCOLOR.C	Revised:	1990.12.11	*/
/* Creator:	U.R. Andersson	Created:	1990.12.10	*/
/* Copyright:	(c)1990 U.R. Andersson, all rights reserved.	*/
/*   but...	Rights for non-commercial uses released to PD.	*/
/****************************************************************/

#include	<stdio.h>
#include	<string.h>
#include	<osbind.h>

main(argc, argv) char *argv[];
{	int	i, n, color, rgbmix;
	char	*termpt;
	if( argc == 1 || (argc & 1) == 0 )
	{	puts("usage: setcolor color rgbmix ...");
		puts("usage: Several colors can be set");
		exit(-1);
	}
	for( i=1; i<argc; i+=2 )
	{	n = sscanf(argv[i+0],"%i",&color);
		n+= sscanf(argv[i+1],"%i",&rgbmix);
		if( n == 2  &&  color >= 0  &&  color < 16 )
		{	printf("Calling: Setcolor(%d,0x%03.4x);",
				color,rgbmix);
			Setcolor(color,rgbmix);
		}
		else
			printf("Refused: Setcolor( %d, 0x%03.4x);",
				color,rgbmix);
	}
} /* ends main(argc, argv) */

/* End of:	SETCOLOR.C	*/
