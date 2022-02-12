/* Copyright (c) 1985 Ceriel J.H. Jacobs */

/* $Header: pattern.h,v 7.0 86/12/05 09:38:12 ceriel Exp $ */

# ifndef _PATTERN_
# define PUBLIC extern
# else
# define PUBLIC
# endif

char *	re_comp();
int	re_exec();

# undef PUBLIC
