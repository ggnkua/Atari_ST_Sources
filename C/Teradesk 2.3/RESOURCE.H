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

#include "desktop.h"			/* HR 151102: only 1 rsc */

extern
OBJECT *menu,
	   *setprefs,
	   *setprgprefs,
	   *addprgtype,
	   *openfile,
	   *newfolder,
	   *driveinfo,
	   *folderinfo,
	   *fileinfo,
	   *infobox,
	   *addicon,
	   *getcml,
	   *nameconflict,
	   *copyinfo,
	   /* *print, DjV 031 080203 */
	   *setmask,
	   *applikation,
	   *seticntype,
	   /* *addicntype, DjV 034 050203 */
	   *loadmods,
	   *viewmenu,
	   *stabsize,
	   *wdoptions,
	   *wdfont,
	   *helpno1,     /* DjV 008 251202 */
	   *helpno2,     /* DjV 008 251202 */
	   *fmtfloppy,   /* DjV 006 251202 */ 
	   *vidoptions,  /* DjV 007 251202 */
	   *copyoptions; /* DjV 016 050103 */

extern
char *dirname,
	 *oldname,
	 *newname,
	 *finame,
	 *flname,
	 *cmdline,		/* HR 240203 */
	 *disklabel,
	 *drvid,
	 *iconlabel,
	 *cmdline1,
	 *cmdline2,
	 *cpfile,
	 *cpfolder,
	 *filetype,
	 *tabsize,
	 *copybuffer,
	 *applname,
	 *appltype,
	 *applcmdline,
	 *applfkey,
	 *prgname,
	 *icnname,
	 *vtabsize;

extern
char dirnametxt[],		/* HR 021202: The 7 scrolling editable texts. */
     finametxt[],
     flnametxt[],
     oldnametxt[],
     newnametxt[],
     cmdlinetxt[],		/* HR 240203 */
     applcmlntxt[]		/* HR 070303 */
     ;

void rsc_init(void);
void rsc_title(OBJECT *tree, int object, int title);
int rsc_form_alert(int def_button, int message);
int rsc_aprintf(int def_button, int message,...);
void rsc_ltoftext(OBJECT *tree, int object, long value);
