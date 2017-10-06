/*
 * timeout.c - Copyright Steve Woodford, August 1993.
 *
 * Parses a timeout string, as lifted from the SCSI.CNF file and
 * writes the values found into the timeout structure for the
 * specified SCSI target.
 *
 * If I recall, the argument 's' to Scsi_Set_Timeouts is modified...
 */

#include <stdlib.h>
#include <sys/types.h>
#include <ctype.h>
#include <sys/scsi.h>
#include "libscsi.h"


PRIVATE short   Break_Value(char **);


PUBLIC  char *
Scsi_Set_Timeouts(u_char id, char *s, Sc_Timeout *def)
{
    char    *p = s;
    short    i, v,
            *to,
            *de = (short *)def;

    if ( s == (char *)0 )
        return(s);

    if ( (id &= 0x07) > MAX_SCSI_ID )
        return("Invalid Target Id");

    to = &(_Scsi_Timeouts[id & 0x07].st_normal);

    for (i = 0; *s; s++)
    {
        while ( *s && (*s != ',') )
        {
            if ( !isspace(*s) && ((*s < '0') || (*s > '9')) )
                return("Malformed Timeout String");
            s++;
        }
        if ( *s )
            i++;
    }

    if ( i != ((sizeof(Sc_Timeout) / sizeof(short)) - 1) )
        return("Invalid number of arguments");

    do {

        if ( (v = Break_Value(&p)) > 0 )
            *to = v;
        else if ( (de != (short *)0) && *de )
            *to = *de;

        to++;

        if ( de != (short *)0 )
            de++;

    } while (--i);

    return((char *)0);
}

PRIVATE short
Break_Value(char **p)
{
    char    *c = *p;
    short    rv;

    if ( ! *c )
        return(0);

    while ( isspace(*c) )
        c++;

    if ( *c == ',' )
    {
        *p = &(c[1]);
        return(0);
    }

    for (*p = c; *c && (*c != ','); c++)
        ;
    if ( *c )
        c++;

    rv = (short)atoi(*p);
    *p = c;
    return(rv);
}
