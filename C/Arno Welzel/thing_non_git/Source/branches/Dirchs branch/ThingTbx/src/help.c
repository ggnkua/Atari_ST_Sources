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

/**
 * Verschiedene Funktionen fuer Strings.
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <vaproto.h>
#include "..\include\thingtbx.h"

/*------------------------------------------------------------------*/
/*  external variables                                              */
/*------------------------------------------------------------------*/
extern BYTE *aesBuffer;

/**
 show_help()

 Anzeige eines Hilfetextes mit ST-Guide
 -------------------------------------------------------------------------*/
WORD showSTGuideHelp(BYTE *helpfile, BYTE *reference) {
	BYTE ap_id;

	/* ST-Guide vorhanden? */
	ap_id = appl_find("ST-GUIDE");
	if (ap_id < 0)
		return (FALSE);

	strcpy(aesBuffer, "*:\\");
	strcat(aesBuffer, helpfile);
	if (reference) {
		strcat(aesBuffer, " ");
		strcat(aesBuffer, reference);
	}
	appl_send(ap_id, VA_START, PT34, (long) aesBuffer, 0, 0, 0, 0);

	return (TRUE);
}

#if 0
/**
 show_help()

 Anzeige eines Hilfetextes mit ST-Guide
 -------------------------------------------------------------------------*/
void show_help(char *ref) {
	int ap_id, ok, rex;
	APPLINFO app;
	char *p;

	/* Kommandozeile */
	strcpy(aesbuf, "*:\\thing.hyp");
	if (ref) {
		strcat(aesbuf, " ");
		strcat(aesbuf, ref);
	}

	/* ST-Guide vorhanden? */
	ap_id = appl_find("ST-GUIDE");
	if (ap_id >= 0)
		app_send(ap_id, VA_START, PT34, (long) aesbuf, 0, 0, 0, 0);
	else {
		/* In einer Multitasking-Umgebung ggf. nachladen, sonst mosern. */
		ok = 0;
		if (tb.sys & SY_MULTI) {
			p = getenv("STGUIDE");
			if (p) {
				ok = 1;
				strcpy(app.name, p);
				app_default(&app);
				app.overlay = 0;
				app.single = 0;
				app_start(&app, aesbuf, 0L, &rex);
			}
		}
		if (!ok)
			frm_alert(1, rs_frstr[ALNOGUIDE], altitle, conf.wdial, 0L);
	}
}
#endif

/**
 * read_hlp
 *
 * Liest die BubbleGEM-Hilfedatei der Applikation ein und baut die
 * dazugeh”rige verkettete Liste auf.
 *
 * Eingabe:
 * ext: Endung der gesuchten Hilfedatei (inklusive Punkt), wird
 *      benutzt, um residentes oder "on demand"-Laden der Hilfedatei
 *      zu erm”glichen
 */
void read_hlp(char *ext) {
	char fname[256], line[257], *p;
	int state, rebalance;
	long id_and_obj;
	FILE *handle;
	BHELP *new,
	*father,
	*last,
	*one,
	*two,
	*current;

	tb.hlp = NULL;
	strcpy(fname, tb.homepath);
	if ((p = strrchr(tb.apname, '.')) != NULL)
		*p = 0;
	strcat(fname, tb.apname);
	strcat(fname, ext);
	if (p)
		*p = '.';
	if ((handle = fopen(fname, "r")) == NULL)
		return;

	state = 0;
	while (fgets(line, 256, handle)) {
		if ((p = strrchr(line, '\r')) != NULL)
			*p = 0;
		if ((p = strrchr(line, '\n')) != NULL)
			*p = 0;
		if ((!*line) || (*line == '#'))
			continue;
		if (state == 0) {
			sscanf(line, "%lx", &id_and_obj);
			if (id_and_obj == 0L)
				break;
		} else {
			if ((new = malloc(sizeof(BHELP) + strlen(line))) == NULL)
				break;
			new->lt = new->ge = NULL;
			new->bal = 0;
			new->id_and_obj = id_and_obj;
			strcpy(new->txt, line);
			if (tb.hlp == NULL) {
				tb.hlp = new;
			} else {
				father = last = NULL;
				rebalance = 0;
				for (current = tb.hlp;;) {
					current->bal++;
					if (current->bal == 2) {
						rebalance = 1;
						father = last;
					}
					last = current;
					if (current->ge == NULL) {
						current->ge = new;
						break;
					}
					else
					current = current->ge;
				}
				if (rebalance) {
					if (father)
						one = father->ge;
					else
						one = tb.hlp;
					two = one->ge;
					one->ge = two->lt;
					two->lt = one;
					one->bal = two->bal = 0;
					if (father) {
						father->ge = two;
						for (current = tb.hlp; current != two; current = current->ge) {
							current->bal--;
						}
					}
					else
					tb.hlp = two;
				}
			}
		}
		state = 1 - state;
	}
	fclose(handle);
	return;
}

/**
 * free_hlp()
 *
 * Gibt die Liste mit dem BubbleGEM-Hilfebaum wieder frei.
 *
 * Eingabe:
 * root: Zeiger auf die Wurzel des Hilfebaums.
 */
void free_hlp(BHELP *root) {
	BHELP *lt, *ge;

	if (root != NULL) {
		lt = root->lt;
		ge = root->ge;
		free(root);
		free_hlp(lt);
		free_hlp(ge);
	}
}
