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

/*=========================================================================
 TPROTO.C

 Thing
 Externe Module via Thing-Protokoll
 =========================================================================*/
#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"
#include <ctype.h>
#include "..\include\tcmd.h"

/**
 Handler fuer Thing-Kommandos generell
 -------------------------------------------------------------------------*/
void tp_handle(EVENT *event) {
	int id, cmd;
	char *buf;
	ALICE_WIN *awin;

	id = event->ev_mmgpbuf[1];
	cmd = event->ev_mmgpbuf[3];

	switch (cmd) {
	case AT_ILOAD: /* ThingIcn: Icons neu laden */
		dl_iconload();
		break;
	case AT_WINICONIFY: /* Alice: Fenster anmelden */
		buf = (char *) int2long(&event->ev_mmgpbuf[4], &event->ev_mmgpbuf[5]);
		if (!avp_checkbuf(id, AT_WINICONIFY, "AT_WINICONIFY", buf, 0))
			return;
		strcpy(aesbuf, buf);
		alw_add(aesbuf, event->ev_mmgpbuf[6]);
		break;
	case AT_WINUNICONIFY: /* Alice: Fenster abmelden */
		awin = alw_get(event->ev_mmgpbuf[4]);
		if (awin)
			alw_remove(awin);
		break;
	}
}

/**
 Alice-Fenster anmelden
 -------------------------------------------------------------------------*/
ALICE_WIN *alw_add(char *name, int handle) {
	ALICE_WIN *awin, *aptr;
	int i, n;
	ICONIMG *icon, *first_icon;
	char *suffixes[] = { ".PRG", ".APP", ".GTP", ".ACC", 0L };
	char *suffix;

	awin = pmalloc(sizeof(ALICE_WIN));
	awin->next = 0L;
	if (!awin)
		return 0L;
	if (!glob.alicewin) {
		awin->prev = 0L;
		glob.alicewin = awin;
	} else {
		aptr = glob.alicewin;
		while (aptr->next)
			aptr = aptr->next;
		awin->prev = aptr;
		aptr->next = awin;
	}

	/* Daten eintragen */
	awin->handle = handle;
	i = 0;
	while (i < 12 && name[i] && name[i] != '.') {
		awin->itext[i] = nkc_toupper(name[i]);
		i++;
	}
	awin->itext[i] = 0;

	/* Icon ermitteln */
	icon = first_icon = 0L;
	if ((suffix = strrchr(name, '.')) != 0L) {
		if (stricmp(suffix, ".PRG"))
			suffix = 0L;
	}
	for (i = 0; suffixes[i]; i++) {
		icon = 0L;
		if (suffix)
			strcpy(suffix, suffixes[i]);
		for (n = 0; n < desk.maxicon; n++) {
			if (desk.icon[n].class == 0) {
				if (wild_match1(desk.icon[n].mask, name)) {
					icon = &desk.icon[n];
					break;
				}
			}
		}
		if (icon) {
			if (!strchr(desk.icon[n].mask, '*') && !strchr(desk.icon[n].mask, '?')) {
				break;
			}
			if (!first_icon)
				first_icon = icon;
			else {
				if (i > 0)
					icon = 0L;
			}
		}
	}
	if (!icon) {
		if (!first_icon)
			icon = &desk.ic_appl;
		else
			icon = first_icon;
	}

	/* Daten des Icons eintragen */
	awin->iblk.monoblk = *icon->iconblk;
	awin->iblk.monoblk.ib_ptext = awin->itext;
	awin->iblk.monoblk.ib_char = icon->iconblk->ib_char & 0xff00;
	awin->iblk.monoblk.ib_xicon = (72 - icon->iconblk->ib_wicon) / 2;
	awin->iblk.monoblk.ib_xtext = 0;
	awin->iblk.monoblk.ib_ytext = icon->iconblk->ib_hicon;
	awin->iblk.monoblk.ib_wtext = 72;
	if (icon->cblk) {
		awin->cblk = *icon->cblk;
		awin->cblk.original = &awin->iblk;
		awin->block.ub_code = icon->ub_code;
		awin->block.ub_parm = (long) &awin->cblk;
	} else
		awin->block.ub_code = 0L;

	/* Objektbaum erzeugen */
	awin->tree[0].ob_next = -1;
	awin->tree[0].ob_head = 1;
	awin->tree[0].ob_tail = 1;
	awin->tree[0].ob_type = G_BOX;
	awin->tree[0].ob_flags = LASTOB;
	awin->tree[0].ob_state = NORMAL;
	awin->tree[0].ob_spec.obspec.framesize = 0;
	awin->tree[0].ob_spec.obspec.framecol = 0;
	awin->tree[0].ob_spec.obspec.textcol = 0;
	awin->tree[0].ob_spec.obspec.textmode = 0;
	awin->tree[0].ob_spec.obspec.fillpattern = 0;
	awin->tree[0].ob_spec.obspec.interiorcol = 0;

	awin->tree[1].ob_next = 0;
	awin->tree[1].ob_head = -1;
	awin->tree[1].ob_tail = -1;
	awin->tree[1].ob_flags = LASTOB;
	awin->tree[1].ob_state = NORMAL;
	if (!awin->block.ub_code) {
		awin->tree[1].ob_type = G_ICON;
		awin->tree[1].ob_spec.iconblk = &awin->iblk.monoblk;
	} else {
		awin->tree[1].ob_type = G_USERDEF;
		awin->tree[1].ob_spec.userblk = &awin->block;
	}
	awin->tree[1].ob_width = 72;
	awin->tree[1].ob_height = 40;

	return awin;
}

/**
 Alice-Fenster abmelden
 -------------------------------------------------------------------------*/
void alw_remove(ALICE_WIN *awin) {
	ALICE_WIN *prev, *next;

	prev = awin->prev;
	next = awin->next;
	if (prev)
		prev->next = next;
	else
		glob.alicewin = next;
	if (next)
		next->prev = prev;
	pfree(awin);
}

/**
 Alice-Fenster ermitteln
 -------------------------------------------------------------------------*/
ALICE_WIN *alw_get(int handle) {
	ALICE_WIN *awin;

	awin = glob.alicewin;
	while (awin) {
		if (awin->handle == handle)
			return awin;
		awin = awin->next;
	}
	return 0L;
}

/**
 Redraw eines Alice-Fenster ausfuehren
 -------------------------------------------------------------------------*/
void alw_draw(ALICE_WIN *awin, int x, int y, int w, int h) {
	RECT area, box, full, work;

	/* AES sperren und Maus abschalten */
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, 0L);

	/* Vorbereitungen */
	area.x = x;
	area.y = y;
	area.w = w;
	area.h = h;

	/* Groesse des Arbeitsbereiches und erster Eintrag Rechteckliste */
	wind_get(0, WF_WORKXYWH, &full.x, &full.y, &full.w, &full.h);
	wind_get(awin->handle, WF_WORKXYWH, &work.x, &work.y, &work.w, &work.h);
	wind_get(awin->handle, WF_FIRSTXYWH, &box.x, &box.y, &box.w, &box.h);

	/* Objektbaum anpassen */
	awin->tree[0].ob_x = work.x;
	awin->tree[0].ob_y = work.y;
	awin->tree[0].ob_width = work.w;
	awin->tree[0].ob_height = work.h;
	awin->tree[1].ob_x = (work.w - awin->tree[1].ob_width) / 2;
	awin->tree[1].ob_y = (work.h - awin->tree[1].ob_height) / 2;

	/* Rechteckliste abarbeiten */
	while (box.w && box.h) {
		/* sichtbar? */
		if (rc_intersect(&full, &box)) {
			/* Nur durchfuehren, wenn Rechteck innerhalb des zu zeichnenden Bereichs liegt */
			if (rc_intersect(&area, &box)) {
				objc_draw(awin->tree, ROOT, MAX_DEPTH, box.x, box.y, box.w, box.h);
			}
		}

		/* Naechstes Rechteck holen */
		wind_get(awin->handle, WF_NEXTXYWH, &box.x, &box.y, &box.w, &box.h);
	}

	/* Maus einschalten und AES freigeben */
	wind_update(END_UPDATE);
	graf_mouse(M_ON, 0L);
}

/* EOF */
