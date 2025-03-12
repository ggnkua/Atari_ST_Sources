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

/**=========================================================================
 DLABOUT.C

 Thing
 Infodialog for Thing
 =========================================================================*/

#include "..\include\globdef.h"
#include "rsrc\thing.h"
/*#include <errno.h>*/
#include <syserr.h>
#include <.\sys\cookie.h>

/**-------------------------------------------------------------------------
 dl_about()

 About Thing
 -------------------------------------------------------------------------*/

/**
 * Initialisierung des Dialogs
 */
void di_about(void) {
	if (fi_about.open) {
		mybeep();
		frm_restore(&fi_about);
		return;
	}
	frm_start(&fi_about, conf.wdial, conf.cdial, 0);
}

#pragma warn -par
void de_about(short mode, short ret) {
	if (!mode) {
		switch (fi_about.exit_obj) {
		case ABINFO:
			fi_ainfo1.init();
			frm_norm(&fi_about);
			break;
		case ABOK:
			frm_end(&fi_about);
			break;
		}
	} else
		frm_end(&fi_about);
}
#pragma warn .par

void di_ainfo1(void) {
	char *ios, *iview, *it2g, *p;
	long dummy;
	TOS2GEM_COOKIE *t2g;
	OSHEADER *sys;
	short naes;
	OBJECT *objectTree;

	objectTree = rs_trindex[AINFO1];

	if (fi_ainfo1.open) {
		mybeep();
		frm_restore(&fi_ainfo1);
		return;
	}

	/* System-Infos eintragen - Betriebssystem */
	ios = getObjectText(objectTree, AIOS);
	iview = getObjectText(objectTree, AIDISPLAY);
	it2g = getObjectText(objectTree, AITOS2GEM);
	if (tb.sys & SY_MAGX) {
		if (Getcookie(C_MgMc /*'MgMc'*/, &dummy) == E_OK )
			strcpy(ios, "MagiC Mac");
		else if (Getcookie(C_MgMx /*'MgMx'*/, &dummy) == E_OK )
			strcpy(ios, "MagiC Mac X");
#if 0
		else if (Getcookie(C_MgPC /*'MgPC'*/, &dummy) == E_OK )
			strcpy(ios, "MagiC PC");
#endif
		else
			sprintf(ios, "MagiC %x", (tb.magx->aesvars->version >> 8) & 0xff);

		/* MagiC-Versionsnummer */
		p = &ios[(short) strlen(ios)];
		sprintf(p, rs_trindex[LANGUAGE][LANGMGXVER].ob_spec.free_string,
				tb.magx->aesvars->version >> 8, tb.magx->aesvars->version & 0xff,
				(tb.magx->aesvars->date & 0xff000000L) >> 24,
				(tb.magx->aesvars->date & 0xff0000L) >> 16,
				tb.magx->aesvars->date & 0xffffL);
	} else {
		
		if (tb.sys & SY_MULTI) {
			char name[MAX_PLEN], name3[257],*pt; int i;
			for (i=0;i<MAX_PLEN;i++) name[i]=0;
			
			if (tb.sys & SY_AGI) (void)appl_getinfo_str(96,name,NULL,name3,NULL);
			name[8]=0;
			if(name[0]!=0) {
				pt=name3;
				while (*pt && *pt!='|') pt++;
				*pt=0;
				sprintf(ios, " %s %s", name, name3);
			}
			else
			if (glob.naesinfo) {
				naes = glob.naesinfo->version;
				sprintf(ios, "N.AES %d.%d.%d (", naes >> 8, (naes >> 4) & 15, naes & 15);
				naes = glob.naesinfo->date;
				p = &ios[strlen(ios)];
				sprintf(p, glob.dateformat, naes & 0x001f, (naes & 0x1e0) >> 5, 1980 + ((naes & 0xfe00) >> 9));
				strcat(ios, ")");
			}
			else if (tb.sys & SY_GNVA) {
				strcpy(ios, "Geneva");
				if (tb.sys & SY_MINT)
					strcat(ios, " + MiNT");
			} else {
				strcpy(ios, "MultiTOS");
				if (!(tb.sys & SY_MINT))
					strcat(ios, "(?)");
			}
		} else {
			sys = get_oshdr();
			strcpy(ios, "TOS");
			p = &ios[(short) strlen(ios)];
			sprintf(p, rs_trindex[LANGUAGE][LANGOSVER].ob_spec.free_string,
					sys->os_version >> 8, sys->os_version & 0xff,
					(sys->os_date & 0xff0000L) >> 16,
					(sys->os_date & 0xff000000L) >> 24,
					sys->os_date & 0xffffL);
			if (tb.sys & SY_MINT)
				strcat(ios, " & MiNT");
		}
	}

	/* System-Infos eintragen - Bildschirm */
	if (tb.planes <= 8)
		sprintf(iview, rs_trindex[LANGUAGE][LANGSCR1].ob_spec.free_string, tb.resx, tb.resy, tb.colors);
	else
		sprintf(iview, rs_trindex[LANGUAGE][LANGSCR2].ob_spec.free_string, tb.resx, tb.resy, tb.planes);

	/* System-Infos eintragen - TOS2GEM */
	if (Getcookie(C_T2GM /*'T2GM'*/, (long *) &t2g) == E_OK) {
		sprintf(it2g, rs_trindex[LANGUAGE][LANGT2GVER].ob_spec.free_string,
				t2g->date & 0x001f, (t2g->date & 0x1e0) >> 5,
				1980 + ((t2g->date & 0xfe00) >> 9));
	} else {
		sprintf(it2g, rs_trindex[LANGUAGE][LANGT2GMISS].ob_spec.free_string);
	}

	frm_start(&fi_ainfo1, conf.wdial, conf.cdial, 0);
}

/**
 *
 */
void de_ainfo1(short mode, short ret) {
	short done, exit_obj;
	UNUSED(ret);

	done = 0;
	if (!mode) {
		exit_obj = fi_ainfo1.exit_obj;
		switch (exit_obj) {
		case AIOK:
			done = 1;
			break;
		}
		fi_ainfo1.exit_obj = exit_obj;
		frm_norm(&fi_ainfo1);
	} else
		done = 1;

	if (done)
		frm_end(&fi_ainfo1);
}
