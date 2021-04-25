/*
 * stdio.h
 *
 * the stdio header most things include
 */

#define FILE char
#define EOF (-1)
#define NULL ((char *)0)

extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;
extern FILE *fopen();
extern char *gets();
extern char *fgets();
