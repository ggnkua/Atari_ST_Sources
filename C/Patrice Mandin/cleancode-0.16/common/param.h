/*
	Just test command line params for redirection

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _PARAM_H
#define _PARAM_H

#include <stdio.h>

/*--- Variables ---*/

extern int output_to_file;
extern FILE *output_handle;

/*--- Functions ---*/

void PAR_TestRedirect(int myargc, char **myargv);
void PAR_RedirectStdout(void);

#endif /* _PARAM_H */
