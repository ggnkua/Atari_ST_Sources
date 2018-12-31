/*
	file: search.h
	utility: header file of search.c
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#ifndef SEARCH_H
#define SEARCH_H

#include "wind.h"

#define MAX_SEARCH	32

extern int find(windowptr	thewin);
extern void find0(int button);
extern void back1(windowptr	thewin,char *sstr);
extern int forward1(windowptr	thewin,char *sstr);
extern char *chk_sstr_len(void);

extern char		s_str[MAX_SEARCH];
extern char		r_str[MAX_SEARCH];
extern long		sstrlen;
extern long		rstrlen;

#endif