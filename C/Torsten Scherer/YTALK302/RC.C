/* rc.c -- read the .ytalkrc file */

/*			   NOTICE
 *
 * Copyright (c) 1990,1992,1993 Britt Yenne.  All rights reserved.
 * 
 * This software is provided AS-IS.  The author gives no warranty,
 * real or assumed, and takes no responsibility whatsoever for any 
 * use or misuse of this software, or any damage created by its use
 * or misuse.
 * 
 * This software may be freely copied and distributed provided that
 * no part of this NOTICE is deleted or edited in any manner.
 * 
 */

/* Mail comments or questions to ytalk@austin.eds.com */

#include "header.h"

#define IS_WHITE(c)	((c)==' ' || (c)=='\t' || (c)=='\n')

/* ---- local functions ---- */

static char *
get_word(p)
  char **p;
{
    register char *c, *out;

    c = *p;
    while(IS_WHITE(*c))
	c++;
    if(*c == '\0')
	return NULL;
    out = c;
    while(*c && !IS_WHITE(*c))
	c++;
    if(*c)
	*(c++) = '\0';
    *p = c;
    return out;
}

static int
set_option(opt, value)
  char *opt, *value;
{
    ylong mask = 0;
    int set_it;

    if(strcmp(value, "true") == 0 || strcmp(value, "on") == 0)
	set_it = 1;
    else if(strcmp(value, "false") == 0 || strcmp(value, "off") == 0)
	set_it = 0;
    else
	return -1;
    
    if(strcmp(opt, "scroll") == 0
    || strcmp(opt, "scrolling") == 0
    || strcmp(opt, "sc") == 0)
	mask |= FL_SCROLL;

    if(strcmp(opt, "wrap") == 0
    || strcmp(opt, "word-wrap") == 0
    || strcmp(opt, "wordwrap") == 0
    || strcmp(opt, "wrapping") == 0
    || strcmp(opt, "ww") == 0)
	mask |= FL_WRAP;

    if(strcmp(opt, "import") == 0
    || strcmp(opt, "auto-import") == 0
    || strcmp(opt, "autoimport") == 0
    || strcmp(opt, "importing") == 0
    || strcmp(opt, "aip") == 0
    || strcmp(opt, "ai") == 0)
	mask |= FL_IMPORT;

    if(strcmp(opt, "invite") == 0
    || strcmp(opt, "auto-invite") == 0
    || strcmp(opt, "autoinvite") == 0
    || strcmp(opt, "aiv") == 0
    || strcmp(opt, "av") == 0)
	mask |= FL_INVITE;

    if(strcmp(opt, "ring") == 0
    || strcmp(opt, "auto-ring") == 0
    || strcmp(opt, "auto-rering") == 0
    || strcmp(opt, "autoring") == 0
    || strcmp(opt, "autorering") == 0
    || strcmp(opt, "ar") == 0)
	mask |= FL_RING;

    if(strcmp(opt, "xwin") == 0
    || strcmp(opt, "xwindows") == 0
    || strcmp(opt, "XWindows") == 0
    || strcmp(opt, "Xwin") == 0
    || strcmp(opt, "x") == 0
    || strcmp(opt, "X") == 0)
	mask |= FL_XWIN;

    if(strcmp(opt, "asides") == 0
    || strcmp(opt, "aside") == 0
    || strcmp(opt, "as") == 0)
	mask |= FL_ASIDE;
    
    if(!mask)
	return -1;

    if(set_it)
	def_flags |= mask;
    else
	def_flags &= ~mask;

    return 0;
}

static void
read_rcfile(fname)
  char *fname;
{
    FILE *fp;
    char *buf, *ptr;
    char *w, *arg1, *arg2, *arg3;
    int line_no, errline;

    if((fp = fopen(fname, "r")) == NULL)
    {
	if(errno != ENOENT)
	    show_error(fname);
	return;
    }
    buf = get_mem(BUFSIZ);

    line_no = errline = 0;
    while(fgets(buf, BUFSIZ, fp) != NULL)
    {
	line_no++;
	ptr = buf;
	w = get_word(&ptr);
	if(w == NULL || *w == '#')
	    continue;
	
	if(strcmp(w, "readdress") == 0)
	{
	    arg1 = get_word(&ptr);
	    arg2 = get_word(&ptr);
	    arg3 = get_word(&ptr);
	    if(arg3 == NULL)
	    {
		errline = line_no;
		break;
	    }
	    readdress_host(arg1, arg2, arg3);
	}
	else if(strcmp(w, "set") == 0 || strcmp(w, "turn") == 0)
	{
	    arg1 = get_word(&ptr);
	    arg2 = get_word(&ptr);
	    if(arg2 == NULL)
	    {
		errline = line_no;
		break;
	    }
	    if(set_option(arg1, arg2) < 0)
	    {
		errline = line_no;
		break;
	    }
	}
	else
	{
	    errline = line_no;
	    break;
	}
    }
    if(errline)
    {
	sprintf(errstr, "%s: syntax error at line %d", fname, errline);
	errno = 0;
	show_error(errstr);
    }

    free(buf);
    fclose(fp);
}

/* ---- global functions ---- */

void
read_ytalkrc()
{
    char *w;
    yuser *u;
    char fname[256];

    /* read the system ytalkrc file */

#ifdef SYSTEM_YTALKRC
    read_rcfile(SYSTEM_YTALKRC);
#endif

    /* read the user's ytalkrc file */

    if((w = (char *)getenv("HOME")) != NULL)
    {
	sprintf(fname, "%s/.ytalkrc", w);
	read_rcfile(fname);
    }

    /* set all default flags */

    for(u = user_list; u != NULL; u = u->unext)
	if(!(u->flags & FL_LOCKED))
	    u->flags = def_flags;
}
