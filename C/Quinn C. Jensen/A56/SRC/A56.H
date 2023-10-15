/*******************************************************
 *
 *  a56 - a DSP56001 assembler
 *
 *  Written by Quinn C. Jensen
 *  July 1990
 *  jensenq@npd.novell.com (or jensenq@qcj.icon.com)
 *
 *******************************************************\

/*
 * Copyright (C) 1990-1992 Quinn C. Jensen
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  The author makes no representations
 * about the suitability of this software for any purpose.  It is
 * provided "as is" without express or implied warranty.
 *
 */

/*
 *  a56.h - general definitions
 *
 */

#include <stdio.h>

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#define NOT !
typedef int BOOL;
#endif

struct sym {
    char *name;
    struct n {
	int type;
#define UNDEF -1
#define INT 0
#define FLT 1
	union val {
	    int i;
	    double f;
        } val;
    } n;
    struct sym *next;
} *find_sym();

extern int pass;

#define NEW(object) ((object *)alloc(sizeof(object)))

#define PROG 0
#define XDATA 1
#define YDATA 2
#define LDATA 3

#define MAX_NEST 20	/* maximum include file nesting */

struct inc {
    char *file;
    FILE *fp;
    int line;
};
extern struct inc inc[];
extern int inc_p;
#define curfile inc[inc_p].file
#define curline inc[inc_p].line

struct psect {
    char *name;
    int seg;
    unsigned int pc, bottom, top;
    struct psect *next;
} *find_psect(), *new_psect();

FILE *open_read(), *open_write(), *open_append();

    /* save string s somewhere */
#define strsave(s) ((s) != NULL ? \
	(char *)strcpy((char *)malloc(strlen(s)+1),(s)) : NULL)

    /* after a call to fgets(), remove the newline character */
#define rmcr(s) {if (s[strlen(s)-1] == '\n') s[strlen(s)-1] = '\0';};
