/*
 * conio.h - console I/O declarations
 *
 * Started 7/12/89 Alex G. Kiernan
 *
 * Copyright (c) 1989 HiSoft
 */

#ifndef _CONIO_H
#define _CONIO_H

#ifdef LATTICE
 int cget(void);
 int cgetc(void);
 char *cgets(char *);
 int cputc(int);
 int cprintf(const char *, ...);
 int cscanf(const char *, ...);
 int getch(void);
 int getche(void);
 int kbhit(void);
 int putch(int);
 int ungetch(int);
#endif

int cputs(const char *);

#endif

