/**
 * ThingFnd - Thing Find
 * Copyright (C) 1999-2012 Thomas Binder
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
 * @copyright  Thomas Binder 1999-2012
 * @author     Thomas Binder
 * @license    LGPL
 */

#ifndef __PROTO_H__
#define __PROTO_H__

#include <thingtbx.h>

#define NUM_TREE 7

#define FNAME_TPL "template.grp"	/* Vorlage fÅr Ergebnisgruppe */
#define FNAME_RES "result.grp"      /* Name der Ergebnisgruppe */
#define FNAME_LOG "thingfnd.log" 	/* Logbuch */
#define PNAME_RSC "rsrc"			/* Resourcen */
#define PNAME_CON "config"			/* Konfiguration */
#define PNAME_DOC "doc"				/* Hypertexte */
#define MAX_PLEN 256
#define MAX_FLEN 64
#define MAX_AVLEN 16384

#define THING_MSG 0x46ff /* Thing-Protokoll */
#define AT_ILOAD 0x0001 /* Thing-Protokoll, Icons neuladen */

typedef struct {
	short page; /* Aktuelle Karteikarte */
	short datecheck; /* Datumsgrenzen verwenden */
	short sizecheck; /* Grîûenlimits verwenden */
	short grep; /* Inhaltsmaske verwenden */
	short verbose; /* AusfÅhrliche Statusangaben */
	/* Bedeutung der restlichen Komponenten siehe bei search_main() */
	long drvbits;
	char searchpath[MAX_PLEN];
	short follow;
	char *filemask;
	short fm_case;
	short fm_dirs;
	unsigned short mindate;
	unsigned short maxdate;
	long minsize;
	long maxsize;
	char *contentmask;
	short cm_case;
	short cm_binary;
} FIND_DATA;

typedef struct {
	short use3d, /* 3d-Look verwenden */
	backwin; /* Fenster vor Schlieûen nach hinten stellen */
	short done, /* Programm beendet */
	menu; /* MenÅzeile aktiv */
	char tname[MAX_PLEN], rname[MAX_PLEN], lname[MAX_PLEN];
	short avid, tid;
	short avflags;
} GLOB;

void mn_istate(short item, short enable);
void mn_disable(void);
void mn_update(void);
void di_about(void);
void de_about(short mode, short ret);
void dl_nextwin(void);
void dl_quit(void);
void di_find(void);
void de_find(short mode, short ret);
void ddnak(EVENT *mevent);
void handle_menu(short title, short item, short ks);
void handle_win(short handle, short msg, short f1, short f2, short f3, short f4, short ks);
void handle_button(short mx, short my, short but, short ks, short br);
void handle_key(short ks, short kr);
void handle_fmsg(EVENT *mevent, FORMINFO *fi);
short get_buf_entry(char *buf, char *name, char **newpos);
short main_init(void);
void main_loop(void);
void main_exit(void);
long search_main(long drvbits, char *searchpath, short follow, char *filemask,
		short fm_case, short fm_dirs, unsigned short mindate, unsigned short maxdate,
		long minsize, long maxsize, char *contentmask, short cm_case,
		short cm_binary, short (*update)(char *current, long hits),
		char *resultfile, char *resulttemplate);
short wild_match(char *string, char *pattern);
unsigned short parse_date(char *date);

#endif
