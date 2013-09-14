/* st.c */

#include "gemdefs.h"
#include "mydefs.h"

extern char sbuf[];



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
