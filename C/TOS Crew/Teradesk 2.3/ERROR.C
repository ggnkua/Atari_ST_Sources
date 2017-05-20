/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
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
#include <stdarg.h>
#include <sprintf.h>		/* HR 240203: get rid of stream io */
#include <stddef.h>
#include <vdi.h>	/* DjV 035 50203 */
#include <xdialog.h> /* DjV 035 050203 */

#include "desktop.h"			/* HR 151102: only 1 rsc */
#include "error.h"

int alert_msg(const char *string, ...)
{
	char alert[256];
	va_list argpoint;
	int button;
	sprintf(alert, "[1][ %s ][ Ok ]", string);
	va_start(argpoint, string);
	button = vaprintf(1, alert, argpoint);
	va_end(argpoint);

	return button;
}

int alert_printf(int def, int message,...)
{
	va_list argpoint;
	int button;
	char *string;

	rsrc_gaddr(R_STRING, message, &string);

	va_start(argpoint, message);
	button = vaprintf(def, string, argpoint);
	va_end(argpoint);

	return button;
}

/* DjV 035 120203 ---vvv--- */
/* 
 * get_freestring routine gets pointer to a free-string in the resource;
 * handy for composing various texts.
 */

char *get_freestring( int stringid )
{
	OBSPEC s;
	xd_gaddr(R_STRING, stringid, &s);
	return s.free_string;
}

/* DjV 035 120203 ---^^^--- */

void xform_error(int error)
{
	int message;

	switch (error)
	{
	case EFILNF:
		message = TFILNF; /* DjV 035 050203 was MEFILENF; */
		break;
	case EPTHNF:
		message = TPATHNF; /* DjV 035 050203 was MEPATHNF; */
		break;
	case ENSMEM:
		message = TENSMEM; /* DjV 035 050203 was MENSMEM; */
		break;
	case ELOCKED:
		message = TLOCKED; /* DjV 035 050203 was MELOCKED; */
		break;
	case EPLFMT:
		message = TPLFMT; /* DjV 035 050203 was MEPLFMT; */
		break;
	case ECOMTL:
		message = TCMDTLNG; /* DjV 035 050203 was MCMDTLNG; */
		break;
	case EREAD:
		message = TREAD; /* DjV 035 050203 was MEREAD; */
		break;
	case EFNTL:
		message = TFILNF; /* DJV 035 050203 was MEFNTLNG; */
		break;
	case EPTHTL:
		message = TPTHTLNG; /* DJV 035 050203 was MEPTHTLN; */
		break;
	case _XDVDI:
		/* message = MVDIERR; DjV 035 050203 */
		alert_printf( 1, MVDIERR );	/* DjV 035 050203 because of another icon here*/
		return;	/* DjV 035 050203 */
		/* break; DjV 035 050203 */
	default:
		message = -1;
		break;
	}

	if (message == -1)
	{
		if ((error <= EINVFN) && ((error > XABORT) || (error < XFATAL)))
			alert_printf(1, MERROR, error);
	}
	else
		/* alert_printf(1, message); DJV 035 050203 */
	/* DjV 035 120203 ---vvv--- */
    /*
	{
		OBSPEC s;
		xd_gaddr(R_STRING, message, &s); 
		alert_printf (1,GENALERT, s.free_string );
	}
	*/
		alert_printf( 1, GENALERT, get_freestring(message) ); /* DjV 035 120203 */
}

static char *get_message(int error)
{
	static char buffer[32], *s;
	int msg;

	switch (error)
	{
	case EFILNF:
		msg = TFILNF;
		break;
	case EPTHNF:
		msg = TPATHNF;
		break;
	case EACCDN:
		msg = TACCDN;
		break;
	case ENSMEM:
		msg = TENSMEM;
		break;
	case EDSKFULL:
		msg = TDSKFULL;
		break;
	case ELOCKED:
		msg = TLOCKED;
		break;
	case EPLFMT:
		msg = TPLFMT;
		break;
	case EFNTL:
		msg = TFNTLNG;
		break;
	case EPTHTL:
		msg = TPTHTLNG;
		break;
	case EREAD:
		msg = TREAD;
		break;
	case EEOF:
		msg = TEOF;
		break;
	default:
		rsrc_gaddr(R_STRING, TERROR, &s);
		sprintf(buffer, s, error);
		return buffer;
	}

	rsrc_gaddr(R_STRING, msg, &s);

	return s;
}

void hndl_error(int message, int error)
{
	if (error > EINVFN)
		return;

	alert_printf(1, message, get_message(error));
}

int xhndl_error(int msg, int error, const char *file)
{
	int button;
	char *message;

	if ((error >= XFATAL) && (error <= XERROR))
		return error;
	else
	{
		if ((error < 0) && (error >= -17))
			return XFATAL;
		else
		{
			message = get_message(error);

			if ((error == EFILNF) || (error == EACCDN) || (error == ELOCKED))
			{
				char *buttons;

				rsrc_gaddr(R_STRING, TSKIPABT, &buttons);
				button = alert_printf(1, msg, file, message, buttons);
				return ((button == 1) ? XERROR : XABORT);
			}
			else
			{
				char *buttons;

				rsrc_gaddr(R_STRING, TABORT, &buttons);
				alert_printf(1, msg, file, message, buttons);
				return XABORT;
			}
		}
	}
}
