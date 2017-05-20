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
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <mint.h>
#include <xdialog.h>

#include "desk.h"
#include "desktop.h"			/* HR 151102: only 1 rsc */
#include "error.h"
#include "xfilesys.h"
#include "edit.h"
#include "window.h"
#include "applik.h"
#include "file.h"
#include "prgtype.h"

/* Onder MultiTOS eerst kijken of een applikatie draait (met
   appl_find) Als dit het geval is boodschap sturen anders
   programma starten. */

static char *editor;

static void edit_set(const char *name)
{
	if (editor != NULL)
		free(editor);
	editor = (char *) name;
}

void set_editor(void)
{
	char fname[256], *newpath, *newname, *fspec;
	const char *input;
	boolean result = FALSE, prgselected = FALSE;
	WINDOW *w;
	int n, *list, item, error;

	if ((w = wd_selected_wd()) != NULL)
	{
		if (itm_list(w, &n, &list) == FALSE)
			return;
		if ((n == 1) && (itm_type(w, list[0]) == ITM_PROGRAM))
		{
			item = list[0];
			prgselected = TRUE;
		}
		free(list);
	}

	if ((prgselected == TRUE) || (editor != NULL))
	{
		if (prgselected == TRUE)
		{
			if ((input = itm_fullname(w, item)) == NULL)
				return;
		}
		else
			input = editor;

		strcpy(fname, fn_get_name(input));
		fspec = fn_make_newname(input, "*");		/* HR 271102 */

		if (prgselected == TRUE)
			free(input);
	}
	else
	{
		if ((input = getdir(&error)) == NULL)
		{
			xform_error(error);
			return;
		}

		fspec = fn_make_path(input, "*");		/* HR 271102 */

		free(input);
	}

	if (fspec == NULL)
		return;

	do
	{
		char *fsel_seteditor;

		rsrc_gaddr(R_STRING, FSTEDIT, &fsel_seteditor);

		newpath = xfileselector(fspec, fname, fsel_seteditor);

		free(fspec);

		if (newpath == NULL)
			return;

		if (strlen(fname) == 0)
		{
			edit_set(NULL);
			result = TRUE;
		}
		else
		{
			if (prg_isprogram(fname) == FALSE)
				alert_printf(1, MFNPRG, fname);
			else
			{
				if ((newname = fn_make_newname(newpath, fname)) != NULL)
				{
					if ((result = x_exist(newname, EX_FILE)) == FALSE)
					{
						alert_printf(1, MFNEXIST, fname);
						free(newname);
					}
					else
						edit_set(newname);
				}
				else
					result = TRUE;
			}
		}
		fspec = newpath;
	}
	while (result == FALSE);

	free(newpath);
}

boolean call_editor(WINDOW *w, int selected, int kstate)
{
	int list = selected;

	if (editor != NULL)
		return app_exec(editor, NULL, w, &list, 1, kstate, FALSE);
	else
	{
		alert_printf(1, MNEDITOR);
		return FALSE;
	}
}

boolean edit_installed(void)
{
	return (editor == NULL) ? FALSE : TRUE;
}

void edit_init(void)
{
	editor = NULL;
}

int edit_load(XFILE *file)
{
	int error;

	edit_default();

	if ((editor = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
		return error;

	if (strlen(editor) == 0)
	{
		free(editor);
		editor = NULL;
	}

	return 0;
}

int edit_save(XFILE *file)
{
	return x_fwritestr(file, (editor == NULL) ? "" : editor);
}

void edit_default(void)
{
	edit_set(NULL);
}
