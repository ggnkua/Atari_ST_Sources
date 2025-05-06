/* main.c */

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
#include <signal.h>
#include "menu.h"

char errstr[132];	/* temporary string for errors */

/* Clean up and exit.
 */
void
bail(n)
  int n;
{
    end_term();
    kill_auto();
    (void)exit(n);
}

/* Display an error.
 */
void
show_error(str)
  register char *str;
{
    static int in_error = 0;

#ifdef __MINT__
    char syserr[81], *serr;

    if(errno == 0)
	strcpy(syserr, "(no system error)");
    else {
	if ((serr = sys_errlist[errno]))
		sprintf(syserr, "%s, errno = %i", serr, errno);
	else
		sprintf(syserr, "errno = %i", errno);
    }
#else
    register char *syserr;

    if(errno == 0)
	syserr = "(no system error)";
    else
	syserr = sys_errlist[errno];
#endif

    putc(7, stderr);
    if(in_error == 0 && what_term() != 0)
    {
	in_error = 1;
	if(show_error_menu(str, syserr) < 0)
	{
	    show_error("show_error: show_error_menu() failed");
	    show_error(str);
	}
	else
	    update_menu();
	in_error = 0;
    }
    else
    {
	fprintf(stderr, "%s: %s\n", str, syserr);
	sleep(2);
    }
}

/* Allocate memory.
 */
yaddr
get_mem(n)
  int n;
{
    register yaddr out;
    if((out = (yaddr)malloc(n)) == NULL)
    {
	show_error("malloc() failed");
	bail(YTE_NO_MEM);
    }
    return out;
}

/* Copy a string.
 */
char *
str_copy(str)
  register char *str;
{
    register char *out;
    register int len;

    if(str == NULL)
	return NULL;
    len = strlen(str) + 1;
    out = get_mem(len);
    (void)memcpy(out, str, len);
    return out;
}

/* Reallocate memory.
 */
yaddr
realloc_mem(p, n)
  char *p;
  int n;
{
    register yaddr out;
    if(p == NULL)
	return get_mem(n);
    if((out = (yaddr)realloc(p, n)) == NULL)
    {
	show_error("realloc() failed");
	bail(YTE_NO_MEM);
    }
    return out;
}

/* Process signals.
 */
static void
got_sig(n)
  int n;
{
    if(n == SIGINT)
	bail(0);
    bail(YTE_SIGNAL);
}

/*  MAIN  */
int
main(argc, argv)
  int argc;
  char **argv;
{
    int xflg = 0, sflg = 0;
    char *prog;

#ifndef __MINT__
    /* check for a 64-bit mis-compile */

    if(sizeof(ylong) != 4)
    {
	if(sizeof(ylong) > 4)
	{
	    fprintf(stderr,
		"You should have compiled ytalk with the -DY64BIT option.\n");
	}
	else
	{
#ifdef Y64BIT
	    fprintf(stderr,
		"You should NOT have compiled ytalk with the -DY64BIT option.\n");
#else
	    fprintf(stderr,
		"Your machine doesn't support 32-bit longs.  Please mail\n");
	    fprintf(stderr,
		"ytalk@austin.eds.com your machine type and OS version.\n");
	    (void)exit(YTE_INIT);
#endif
	}
	fprintf(stderr,
	    "See the README file on how to update the appropriate\n");
	fprintf(stderr,
	    "makefile, then type 'make clean', 'make'.\n");
	(void)exit(YTE_INIT);
    }
#endif

    /* search for options */

    prog = *argv;
    argv++, argc--;
    while(argc > 0 && **argv == '-')
    {
	if(strcmp(*argv, "-x") == 0
	|| strcmp(*argv, "-nw") == 0)
	{
	    xflg++;	/* disable X from the command line */
	    argv++, argc--;
	}
	else if(strcmp(*argv, "-s") == 0)
	{
	    sflg++;	/* immediately start a shell */
	    argv++, argc--;
	}
	else
	    argc = 0;	/* force a Usage error */
    }

    /* check for users */

    if(argc <= 0)
    {
	fprintf(stderr, "Usage: %s [-x] user[@hostname][#tty]...\n", prog);
	(void)exit(YTE_INIT);
    }

    /* set up signals */

    signal(SIGINT, got_sig);
    signal(SIGHUP, got_sig);
    signal(SIGQUIT, got_sig);
    signal(SIGABRT, got_sig);

    /* set default options */

    def_flags = FL_XWIN;

    /* go for it! */

    errno = 0;
    init_fd();
    init_user();
    read_ytalkrc();
    if(xflg)
	def_flags &= ~FL_XWIN;
    init_term();
    init_socket();
    for(; argc > 0; argc--, argv++)
	invite(*argv, 1);
    if(sflg)
	execute(NULL);
    else
	msg_term(me, "Waiting for connection...");
    main_loop();
    bail(YTE_SUCCESS);

    return 0;	/* make lint happy */
}
