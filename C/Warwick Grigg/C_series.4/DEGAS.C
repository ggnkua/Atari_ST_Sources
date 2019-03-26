/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		degas.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <osbind.h>
#include <stdio.h>
#include "scratt.h"
#include "errexit.h"

struct degashdr_s {	/* structure of first part of a degas picture	*/
    int		res;
    int		pallette[16];
};

static int  nplanes;	/* number of planes at current resolution	*/
static int  screendimx;	/* number of pixels wide			*/
static int  screendimy;	/* number of pixels deep			*/

static int  row;	/* current row number				*/
static int  plane;	/* current plane number				*/
static int  bytix;	/* byte index for this row and plane		*/
static char *planep;	/* pointer to first word in this row and plane	*/
static int  bytesperrow;/* number of bytes per row * planes		*/

static char *msg[] = {	
    "[1][ Sorry, | I can't read the picture file][OK]",
    "[1][ Sorry, | I can't find the picture file][OK]",
    "[1][ Sorry, | the picture file format is wrong][OK]" 
};

static void DgPutInit(buf)	/* Initialise unpacking of Degas screen		*/
char *buf;
{
    nplanes = planes();
    screendimx = scrdimx();
    screendimy = scrdimy();
    bytesperrow = (screendimx/8) * nplanes;
    planep = buf;
    row =
    plane =
    bytix = 0;
}

static void DegasPutByte(b)	/* Puts b into screen buffer */
char b;
{
    planep[bytix++] = b;
    if ((bytix&1)==0) {
	bytix += (nplanes+nplanes-2);
	if (bytix >= bytesperrow) {
	    plane++;
	    if (plane >= nplanes) {
		plane = 0;
		planep += bytesperrow;
		row++;
    	    }
	    bytix = plane+plane;
	}
    }
}

void DegasGet(buf, filename)	/* Gets Degas picture into screen buffer */
char *buf;	/* screen buffer, must be 32000 bytes long		 */
char *filename;	/* file name, must be for current resolution, compressed */
{
    FILE *f;			/* file handle			*/
    struct degashdr_s hdr;	/* Degas picture header		*/
    int prefix;			/* character buffer		*/
    int c;			/* another character buffer	*/

    if ((f=fopen(filename, "rb")) != NULL) { 
	if (fread(&hdr, sizeof(struct degashdr_s), 1, f) != 1)
		errexit(msg[0]);
	DgPutInit(buf);
	do {
	    prefix = fgetc(f);
	    if (prefix==EOF)
		errexit(msg[2]);
	    if (prefix>=0 && prefix<=127 ) {
		prefix++;
		while ((prefix--)>0) {
		    c = fgetc(f);
		    if (c==EOF || row>=screendimy)
			errexit(msg[2]);
		    DegasPutByte(c);
	        }
	    }
	    else if (prefix>=129 && prefix<=255) {
		prefix = 257-prefix;
		c = fgetc(f);
		if (c==EOF)
		    errexit(msg[2]);
		while ((prefix--)>0) {
		    if (row>=screendimy)
			errexit(msg[2]);
		    DegasPutByte(c);
		}
	    }
	} while (row<screendimy);
	fclose(f);
    }
    else {
	errexit(msg[1]);
    }
    Setpallete(&hdr.pallette[0]);
    Vsync();
}
