/*
 * getspool.c -- get a message from a file
 *
 * 91Feb22 RH	Eliminated use of global spool file variable.
 * 90Nov06 AA	Munged for gcc/STadel 3.4a stuff
 * 90Oct31 AA	Added support for Fnordadel Developer Field to getspool().
 * 90Aug27 AA	Split off from libmsg.c
 */

#include "ctdl.h"
#include "msg.h"
#include "citlib.h"

/*
 * getstrspool() - get a string from netfile
 */
void
getstrspool(FILE *spl, char *place, register int length)
{
    register i;
    register short c;

    for (i=0,length--; (c = getc(spl)) != EOF && c; )
	if (i < length)
	    place[i++] = c;
    place[i] = 0;
}

int
getspool(FILE *spl)
{
    register int c;
    LABEL tempstr;
    unsigned long lo, hi;

    zero_struct(msgBuf);
    while ((c = getc(spl)) != EOF)
	switch (c) {
	    case 'A': getstrspool(spl, msgBuf.mbauth, ADDRSIZE);	break;
	    case 'C': getstrspool(spl, msgBuf.mbtime, NAMESIZE);	break;
	    case 'D': getstrspool(spl, msgBuf.mbdate, NAMESIZE);	break;
	    case 'M': getstrspool(spl, msgBuf.mbtext, MAXTEXT);	return 1;
	    case 'N': getstrspool(spl, msgBuf.mboname,NAMESIZE);	break;
	    case 'O': getstrspool(spl, msgBuf.mborig, NAMESIZE);	break;
	    case 'R': getstrspool(spl, msgBuf.mbroom, NAMESIZE);	break;
	    case 'T': getstrspool(spl, msgBuf.mbto,   ADDRSIZE);	break;
	    case 'Z': getstrspool(spl, msgBuf.mbroute,NAMESIZE+2);	break;
	    case 'I': getstrspool(spl, msgBuf.mborg,  ORGSIZE);		break;
	    case 'J': getstrspool(spl, msgBuf.mbsub,  ORGSIZE);		break;
	    case 'X': getstrspool(spl, msgBuf.mbdomain, NAMESIZE);	break;
	    case 'S':   getstrspool(spl, tempstr, NAMESIZE);
			if (sscanf(tempstr, "%ld %ld", &hi, &lo) != 2)
			    msgBuf.mbsrcid = 0L;
			else
			    msgBuf.mbsrcid = ((hi << 16) & 0xffff0000L)
				+ (lo & 0x0000ffffL);
			break;

	/* Fnordadel Developer Field support added by AA 90Oct31 */
	    case '7':
		if (((c = getc(spl)) != EOF) && isalpha(c)) {
		    switch(c) {
		    case 'F':	getstrspool(spl, tempstr, NAMESIZE);
				if (sscanf(tempstr, "%lx", &msgBuf.flags) != 1)
				    msgBuf.flags = 0L;
				break;
		    default:	getstrspool(spl, msgBuf.mbtext,1);
				break;
		    }
		}
		break;
	    default:  getstrspool(spl, msgBuf.mbtext, 1);		break;
	}
    return 0;
}
