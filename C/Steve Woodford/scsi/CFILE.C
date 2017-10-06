
/*
 * cfile.c - Copyright Steve Woodford, August 1993
 *
 * A common method for accessing configuration text files.
 * This is in my personal library, but libscsi.a uses it so here
 * is the source. Ideally, 'cfile.h' should go in your normal
 * include directory, eg. /usr/include
 */

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <ctype.h>
#include <strings.h>
#include "cfile.h"

#define PRIVATE static
#define EXTERN  extern
#define PUBLIC


#define CF_MAX      2

typedef struct _cf_tree {
    struct _cf_tree *left;
    struct _cf_tree *right;
    char            *key;
    char            *value;
} Cf_Tree;

PRIVATE short    cf_open(char *);
PRIVATE short    cf_close(short);
PRIVATE char    *cf_search(short, char *);
PRIVATE char    *cf_error_msg;
PRIVATE Cf_Tree *cf_tree[CF_MAX] = {0L, 0L};


PUBLIC  long
config_file(int func, ...)
{
    int     *arg = (int *) &((&func)[1]);

    switch (func)
    {
      case CFILE_OPEN:
            return( (long)cf_open( ((char **)arg)[0]) );

      case CFILE_CLOSE:
            return( (long)cf_close((short) *arg) );

      case CFILE_SEARCH:
            return( (long)cf_search((short) *arg, *((char **)&(arg[1]))) );
    }

    cf_error_msg = "Invalid function code";
    return(-1);
}

PRIVATE int
nch(f)
FILE    *f;
{
    int     c = fgetc(f);

    for (; (c != EOF) && ((char)c == '#'); )
    {
        for (; ((c = fgetc(f)) != EOF) && ((char)c != '\n'); )
            ;
    }
    return(c);
}


PRIVATE int
skip_space(f)
FILE    *f;
{
    int c;

    for (;;)
    {
        if ( ((c=nch(f)) == EOF) || (((char)c != ' ') && ((char)c != '\t')) )
            break;
    }
    return(c);
}


PRIVATE short
get_line(f, buf, max)
FILE    *f;
char    *buf;
short    max;
{
    char    *p = &(buf[0]);
    short    len = 0;
    int      c = 0;

    if ( max-- == 0 )
        return(0);

    for (len = 0; len == 0; )
    {
        for (c = skip_space(f);
            (c != EOF) && ((char)c != '\n'); c = nch(f) )
        {
            if ( ((char)c == '\\') && ((char)(c = nch(f)) != '\\') )
            {
                for (; (c != EOF) && ((char)c != '\n'); c = nch(f) )
                    ;
                if ( c != EOF )
                    (void)fungetc(c, f);
                c = (int)' ';
            }
            *p++ = (char)c;
            len += 1;
            if ( len >= max )
                break;
        }
        if ( c == EOF )
            break;
    }
    *p = '\0';
    return(len);
}


PRIVATE short
insert_data(d, key, value)
short   d;
char    *key;
char    *value;
{
    long        l1 = strlen(key) + 2,
                l2 = strlen(value) + 2;
    Cf_Tree   **ct = &(cf_tree[d]);

    for (ct = &(cf_tree[d]); *ct; )
    {
        Cf_Tree *node = *ct;
        int      z;

        if ( (z = strcmp(key, node->key)) < 0 )
            ct = &(node->left);
        else
        if ( z > 0 )
            ct = &(node->right);
        else
            return(0);
    }

    if ( ! (*ct = (Cf_Tree *) malloc( sizeof(Cf_Tree) + l1 + l2 )) )
    {
        cf_error_msg = "Out of memory";
        return(-1);
    }
    else
    {
        Cf_Tree *new = *ct;

        (void) bzero((char *)new, sizeof(Cf_Tree) + l1 + l2);
        new->key   = (char *)&(new[1]);
        new->value = &(new->key[l1]);
        (void)strcpy(new->key, key);
        (void)strcpy(new->value, value);
    }
    return(0);
}


PRIVATE void
unlink_node(node)
Cf_Tree *node;
{
    if ( node->left )
        unlink_node(node->left);

    (void) free((char *)(node->left));

    if ( node->right )
        unlink_node(node->right);
}


PRIVATE short
cf_open(char *fn)
{
    FILE    *fp;
    char    *tok,
            *val,
            *p,
             line[128];
    short    d;

    for (d = 0; d < CF_MAX; d++)
        if ( cf_tree[d] == (Cf_Tree *)0 )
            break;
    if ( d >= CF_MAX )
    {
        cf_error_msg = "No free file slots!";
        return(-1);
    }

    if ( (fp = fopen(fn, "r")) == NULL )
    {
        cf_error_msg = "Can't open config file";
        return(-1);
    }

    while ( get_line(fp, line, sizeof(line)) > 0 )
    {
        tok = line;
        for (val = tok; *val && (*val != '=') && !isspace(*val); val++)
            ;
        if ( ! *val )
            continue;

        *val++ = '\0';

        while ( *val && ((*val == '=') || isspace(*val)) )
            val++;

        /*
         * Find end of value string.....
         */
        for (p = val; *p; p++)
            ;
        /*
         * Skip back to 1st non-space character...
         */
        for (p -= 1; (p >= val) && isspace(*p); p--)
            *p = '\0';

        if ( insert_data(d, tok, val) < 0 )
        {
            (void) cf_close(d);
            (void) fclose(fp);
            return(-1);
        }
    }
    return(d);
}


PRIVATE short
cf_close(short d)
{
    if ( (u_short)d >= CF_MAX )
        return(-1);

    if ( cf_tree[d] )
        unlink_node(cf_tree[d]);

    (void) free((char *)(cf_tree[d]));
    return(0);
}


PRIVATE char *
cf_search(short d, char *key)
{
    Cf_Tree *ct;
    int      i;

    if ( ((u_short)d >= CF_MAX) || !(ct = cf_tree[d]) )
        return((char *)0);

    for (; ct && (i = strcmp(key, ct->key)); )
    {
        if ( i > 0 )
            ct = ct->right;
        else
            ct = ct->left;
    }

    if ( ! ct )
        return((char *)0);

    return(ct->value);
}
