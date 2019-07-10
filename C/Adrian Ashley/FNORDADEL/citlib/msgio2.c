/*
 * msgio2.c -- still more message i/o stuff
 *
 * 90Nov06 AA	Munging for gcc + 3.4a stuff
 * 90Oct31 AA	Add support for Fnordadel Developer Field parsing.
 * 90Aug27 AA	Split off from libmsg.c
 */

#include "ctdl.h"
#include "msg.h"
#include "citlib.h"

/*
 * getmsgnum() - reads a long integer from msgfile
 */
static long
getmsgnum(void)
{
    LABEL temp;
    long atol();

    getmsgstr(temp, NAMESIZE);
    return atol(temp);
}

void
getmessage(void)
{
    unsigned c;
    LABEL tempstr;
    unsigned long lo, hi;

    msgBuf.mbroute[0] = msgBuf.mborg[0] =
    msgBuf.mbauth[0] = msgBuf.mbtime[0] = 
    msgBuf.mbdate[0] = msgBuf.mborig[0] = 
    msgBuf.mboname[0] = msgBuf.mbroom[0] = 
    msgBuf.mbtext[0] = msgBuf.mbto[0] =
    msgBuf.mbdomain[0] = msgBuf.mbsub[0] = 0;

    msgBuf.flags = msgBuf.mbsrcid = 0L;

    while (getmsgchar() != 0xff)
	;

    msgBuf.mbid = getmsgnum();

    while ((c=getmsgchar()) != 'M') {
	switch (c) {
	case 'A':	getmsgstr(msgBuf.mbauth,  ADDRSIZE);	break;
	case 'T':	getmsgstr(msgBuf.mbto,	  ADDRSIZE);	break;
	case 'D':	getmsgstr(msgBuf.mbdate,  NAMESIZE);	break;
	case 'C':	getmsgstr(msgBuf.mbtime,  NAMESIZE);	break;
	case 'R':	getmsgstr(msgBuf.mbroom,  NAMESIZE);	break;
	case 'I':	getmsgstr(msgBuf.mborg,   ORGSIZE);	break;
	case 'J':	getmsgstr(msgBuf.mbsub,   ORGSIZE);	break;
	case 'N':	getmsgstr(msgBuf.mboname, NAMESIZE);	break;
	case 'O':	getmsgstr(msgBuf.mborig,  NAMESIZE);	break;
	case 'Z':	getmsgstr(msgBuf.mbroute, NAMESIZE+2);	break;
	case 'X':	getmsgstr(msgBuf.mbdomain, NAMESIZE);	break;
	case 'S':	getmsgstr(tempstr, NAMESIZE);
			if (sscanf(tempstr, "%ld %ld", &hi, &lo) != 2)
			    msgBuf.mbsrcid = 0L;
			else
			    msgBuf.mbsrcid = ((hi << 16) & 0xffff0000L)
				+ (lo & 0x0000ffffL);
			break;

	/* Fnordadel Developer Field support added by AA 90Oct31 */
	case '7':
		if ((c = getmsgchar())) {
		    switch(c) {
		    case 'F':	getmsgstr(tempstr, NAMESIZE);
				if (sscanf(tempstr, "%lx", &msgBuf.flags) != 1)
				    msgBuf.flags = 0L;
				break;
		    default:	getmsgstr(msgBuf.mbtext, 1);
				msgBuf.mbtext[0] = 0;
				break;
		    }
		}
		break;
	default:
	    getmsgstr(msgBuf.mbtext, 1);  /* discard unknown field  */
	    msgBuf.mbtext[0] = 0;
	    break;
	}
    }
}
