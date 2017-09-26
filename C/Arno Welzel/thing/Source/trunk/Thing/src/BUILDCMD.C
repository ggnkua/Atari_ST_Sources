/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

#include "..\include\globdef.h"
#include "..\include\types.h"

/*
 * build_commandline
 *
 * Builds a commandline containing many parameters formatted according to a
 * format string.
 *
 * Input parameters:
 *
 * dest: pointer to the destination area to which the resulting commandline
 *       will be copied
 *
 * len: maximum length of dest in bytes including null termator byte.
 *
 * format: format string for the commandline.
 *         Copied verbatim to dest except for:
 *         $1 means: Replace with the first filename in params
 *         $2 means: Replace with the second filename in parms
 *         and so on
 *         $-3 means: Replace with the filenames 1 to 3 in params
 *         $4- means: Replace with all filenames in params, starting with the
 *                    fourth
 *         $2-4 means: Replace with filenames 2, 3, and 4
 *         $$: Replace with a single $
 *         $(n): Treat as $n (where n may be any of the possibilities
 *               described above); this is necessary to be able to create
 *               formats like "$(2)-" to get the second filename followed by
 *               a dash, and not all filenames starting with the second.
 *         $d means: Replace with the current directory (curdir).
 *         All filenames used for replacing should be quoted if they contain
 *         spaces or single quotes, see below.
 *
 * params: string containing the parameters. Filenames are separated by spaces
 *         and quoted if necessary.
 *
 * curdir: string containing the current directory (for $d).
 *
 * Return value:
 * 1: no error occured.
 * 0: error occured. No assumptions about the validity of the resultant commandline can be made in this case.
 */
#pragma warn -sig
int build_commandline(char *dest, size_t len, char *format, char *params,
		char *curdir) {
	char *fmt_pos; /* Current position in format string */
	char *dest_pos; /* Current position in dest. Next char is copied here. */
	char *dest_end; /* Pointer to end of dest. */

	if (len < 2)
		return (0);

	fmt_pos = format;
	dest_pos = dest;
	dest_end = dest_pos + len - 1;

	while (*fmt_pos != '\0') {
		if (*fmt_pos == '$') { /* It's an argument to be replaced */
			int inbracket = 0; /* Flag whether we are inside parentheses */
			int pfirst = -1, plast = -1; /* First and last param to replace (default "none") */
			int pos; /* Current position in argument */
			int cur_arg; /* Used for finding right argument */
			int status; /* Current status from get_buf_entry */
			char buf[127 + 1]; /* Buffer */
			int length, doquote;
			int insert_type; /* Signals from where to insert arguments */
			fmt_pos++;
			if (*fmt_pos == '(') {
				inbracket = 1;
				fmt_pos++;
			}
			switch (*fmt_pos) {
			case '$': /* Copy verbatim */
				if (dest_pos == dest_end) {
					*dest_pos = '\0';
					return (0);
				}
				*dest_pos = *fmt_pos;
				dest_pos++;
				fmt_pos++;
				break;

			case '1': /* Insert params */
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
			case '0':
				insert_type = 1; /* Means insert from param */
				if (inbracket)
					length = strcspn(fmt_pos, ")-");
				else
					length = strspn(fmt_pos, "1234567890");
				if (length - 1 > sizeof(buf))
					return (0);
				strncpy(buf, fmt_pos, length);
				buf[length] = '\0';
				pfirst = atoi(buf);
				fmt_pos += length;
				if (inbracket && *fmt_pos == ')') {
					plast = pfirst; /* Only one parameter */
					fmt_pos++;
					break;
				}
				if (*fmt_pos != '-') {
					plast = pfirst; /* Only one parameter */
					break;
				}

			case '-':
				insert_type = 1; /* Means insert from param */
				fmt_pos++;
				if (inbracket)
					length = strcspn(fmt_pos, ")");
				else
					length = strspn(fmt_pos, "1234567890");
				if (length == 0 && pfirst != -1) {
					plast = -2;
				} else {
					if (length - 1 > sizeof(buf))
						return (0);
					strncpy(buf, fmt_pos, length);
					buf[length] = '\0';
					plast = atoi(buf);
					if (pfirst == -1)
						pfirst = 1;
					fmt_pos += length;
				}
				if (inbracket)
					fmt_pos++;
				break;
			case 'd': /* Insert current directory */
				fmt_pos++;
				insert_type = 2; /* Signal later code to insert from curdir */
				pfirst = 1; /* Only insert parm 1 from curdir */
				plast = 1;
				break;
			}
			/* pfirst and plast, if not -1, now contain the argument numbers to be copied. */
			if (pfirst > -1) {
				/* Copy the arguments into the destination */
				/* Get the first argument */
				switch (insert_type) {
				case 1: /* Insert from param */
					status = get_buf_entry(params, buf, NULL);
					break;
				case 2: /* Insert from curdir */
					strncpy(buf, curdir, sizeof(buf) - 1);
					buf[sizeof(buf) - 1] = 0;
					status = 1;
					break;
				}
				for (cur_arg = 1; cur_arg < pfirst; cur_arg++)
					status = get_buf_entry(NULL, buf, NULL);
				if ((status == 0)
						&& !((insert_type == 1) && (pfirst == 1)
								&& (plast == -2))) {
					return (0);
				}
				/* Position is now at pfirst, the argument for which is in buf */
				for (cur_arg = pfirst; plast == -2 ? 1 : (cur_arg <= plast);
						cur_arg++) /* Insert each argument */
						{
					if (status) {
						pos = 0;
						doquote = 0;
						while (buf[pos] != '\0') {
							if (buf[pos] == ' ' || buf[pos++] == '\'') {
								doquote = 1;
								*dest_pos++ = '\'';
								if (dest_pos == dest_end) {
									*dest_pos = '\0';
									return (0);
								}
								break;
							}
						}
						pos = 0;
						while (buf[pos] != '\0') {
							if (doquote && buf[pos] == '\'') {
								*dest_pos++ = '\''; /* Add extra quote */
								if (dest_pos == dest_end) {
									*dest_pos = '\0';
									return (0);
								}
							}
							*dest_pos++ = buf[pos++];
							if (dest_pos == dest_end) {
								*dest_pos = '\0';
								return (0);
							}
						}
						if (doquote) {
							*dest_pos++ = '\'';
							if (dest_pos == dest_end) {
								*dest_pos = '\0';
								return (0);
							}
						}
						status = get_buf_entry(NULL, buf, NULL);
						if (cur_arg != plast)
							*dest_pos++ = ' ';
						if (dest_pos == dest_end) {
							*dest_pos = '\0';
							return (0);
						}
					} else {
						if (plast == -2) {
							plast = 1;
							cur_arg = 2; /* Fool it into finishing */
						} else {
							*dest_pos = '\0';
							return (0);
						}
					}
				}
			}
		} else { /* It's plain text to be copied verbatim */
			if (dest_pos == dest_end) {
				*dest_pos = '\0';
				return (0);
			}
			*dest_pos++ = *fmt_pos++;
		}
	}
	/* This test is not really necessary as such an event should be caught earlier. */
	if (dest_pos > dest_end) {
		*(dest_pos - 1) = '\0';
		return (0);
	} else
		*dest_pos = '\0';
	return (1);
}
#pragma warn .sig
/* EOF */
