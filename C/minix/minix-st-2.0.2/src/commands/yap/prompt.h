/* Copyright (c) 1985 Ceriel J.H. Jacobs */

/* $Header: prompt.h,v 7.0 86/12/05 09:38:34 ceriel Exp $ */

# ifndef _PROMPT_
# define PUBLIC extern
# else
# define PUBLIC
# endif

VOID	give_prompt();
/*
 * void give_prompt()
 *
 * Displays a prompt, with possibly an error message
 */

VOID	error();
/*
 * void error(s)
 * char *s;		The error
 *
 * Takes care that there will be an error message in the next prompt.
 */

VOID	ret_to_continue();
/*
 * void ret_to_continue();
 *
 * Asks the user to type something before continuing.
 */

# undef PUBLIC
