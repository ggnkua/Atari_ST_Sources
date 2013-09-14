/* st.c */

/*
 * ST specific code
 * and error handling.
 *
 */
#include "gemdefs.h"
#include "defs.h"
#include "part.h"

extern char sbuf[];


/*
 * Stupid delay between writes (.01 second);
 * called in supervisor mode on the ST.
 *
 * The hard disk controller cannot keep up with
 * full-tilt accesses for some reason.
 *
 */
delay()
{
    register long hz200v, *p;

    p = (long *)0x4ba;
    hz200v = *p + 2L;		/* compute future value */
    while (*p < hz200v)		/* wait for it to reach that */
	;
}


/*
 * Throw up an alert box
 * with the given text.
 *
 */
err(s)
char *s;
{
    ARROW_MOUSE;
    form_alert(1, s);
    BEE_MOUSE;
    return ERROR;
}


/*
 * Error, concatenate the three strings
 * and throw up an alert box.
 *
 */
errs(s1, s2, s3)
char *s1, *s2, *s3;
{
    strcpy(sbuf, s1);
    strcat(sbuf, s2);
    strcat(sbuf, s3);
    return err(sbuf);
}
