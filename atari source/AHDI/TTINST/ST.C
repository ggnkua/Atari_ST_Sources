/* st.c */

/*
 * 
 * Error handling code.
 *
 */
#include "defs.h"
#include <gemdefs.h>

extern char sbuf[];


/*
 * Throw up an alert box
 * with the given text.
 *
 */
err(s)
char *s;
{
    graf_mouse(ARROW, 0L);
    form_alert(1, s);
    graf_mouse(HOURGLASS, 0L);
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
