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

#include <stdio.h>
#include <string.h>

/*--- Variables ---*/

int output_to_file;
FILE *output_handle;

/*--- Functions ---*/

void PAR_TestRedirect(int myargc, char **myargv)
{
	int	i;

	output_to_file = 0;
	output_handle = stdout;

	for (i=1; i<myargc; i++) {
		if ( !strcasecmp("-file", myargv[i]) ) {
			output_to_file = 1;
		}
	}
}

void PAR_RedirectStdout(void)
{
	output_handle = fopen("stdout.txt","w");
}

