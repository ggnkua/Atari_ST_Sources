/*
 * Teradesk. Copyright (c) 1997, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <np_aes.h>			/* HR 151102: modern */
#include <stddef.h>
#include <string.h>
#include <boolean.h>

#include "desk.h"
#include "font.h"
#include "va.h"				/* HR 060203 */

extern FONT dir_font;

/*
 * int va_start(const char *program, const char *cmdline)
 *
 * Check if the application is already running. If true
 * use the VA_START protocol.
 *
 * Parameters:
 *
 * program	- name of the program.
 * cmdline	- commandline.
 *
 * Result: TRUE if started using the VA_START protocol.
 */

int va_start_prg(const char *program, const char *cmdline)
{
	char prgname[9], *ptr;
	int i, dest_ap_id;

	/*
	 * Check if buffer is large enough for the command line.
	 */

	if (strlen(cmdline) > (GLOBAL_MEM_SIZE - 1))
		return FALSE;

	/*
	 * Copy the name of the program to 'prgname' and
	 * append spaces to make the total length eight characters.
	 */

	if ((ptr = strrchr(program, '\\')) == NULL)
		return FALSE;

	ptr++;
	i = 0;

	while (*ptr && (*ptr != '.') && (i < 8))
		prgname[i++] = *ptr++;

	while (i < 8)
		prgname[i++] = ' ';

	prgname[i] = 0;

	/*
	 * Check if the application is already running.
	 */

	if ((dest_ap_id = appl_find(prgname)) >= 0)
	{
		int message[8];

		strcpy(global_memory, cmdline);

		message[0] = VA_START;
		message[1] = ap_id;
		message[2] = 0;
		*(char **)(message + 3) = global_memory;
		message[5] = 0;
		message[6] = 0;
		message[7] = 0;

		appl_write(dest_ap_id, 16, message);

		return TRUE;
	}
	else
		return FALSE;
}

/*
 * void handle_av_protocol(const int *message)
 *
 * Handle AV messages.
 *
 * Parameters:
 *
 * message	- buffer with AES message.
 */

void handle_av_protocol(const int *message)
{
	int answer[8];

	switch(message[0])
	{
	/*
	 * AV protocol.
	 */

	case AV_PROTOKOLL:
		/*
		 * Ignore the features send by the sender.
		 * Return the supported features.
		 */

		strcpy(global_memory, "DESKTOP");		/* HR 151102 */

		answer[0] = VA_PROTOSTATUS;
		answer[1] = ap_id;
		answer[2] = 0;
		answer[3] = 0x0003;			/* AV_ASKFILEFONT */
		answer[4] = 0;
		answer[5] = 0;
		*(char **)(answer + 6) = global_memory;

		appl_write(message[1], 16, answer);
		break;

	case AV_ASKFILEFONT:
		/*
		 * Return the id and size of the currently selected file font.
		 */

		answer[0] = VA_FILEFONT;
		answer[1] = ap_id;
		answer[2] = 0;
		answer[3] = dir_font.id;
		answer[4] = dir_font.size;
		answer[5] = 0;
		answer[6] = 0;
		answer[7] = 0;

		appl_write(message[1], 16, answer);
		break;

	/*
	 * XACC protocol.
	 */

	case FONT_SELECT:
		fnt_mdialog(message[1], message[3], message[4], message[5],
					message[6], message[7], 1);
		break;
	}
}
