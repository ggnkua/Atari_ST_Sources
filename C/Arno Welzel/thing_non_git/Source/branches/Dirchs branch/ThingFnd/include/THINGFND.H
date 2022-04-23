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
	int page; /* Aktuelle Karteikarte */
	int datecheck; /* Datumsgrenzen verwenden */
	int sizecheck; /* Grîûenlimits verwenden */
	int grep; /* Inhaltsmaske verwenden */
	int verbose; /* AusfÅhrliche Statusangaben */
	/* Bedeutung der restlichen Komponenten siehe bei search_main() */
	long drvbits;
	char searchpath[MAX_PLEN];
	int follow;
	char *filemask;
	int fm_case;
	int fm_dirs;
	unsigned int mindate;
	unsigned int maxdate;
	long minsize;
	long maxsize;
	char *contentmask;
	int cm_case;
	int cm_binary;
} FIND_DATA;

typedef struct {
	int use3d, /* 3d-Look verwenden */
	backwin; /* Fenster vor Schlieûen nach hinten stellen */
	int done, /* Programm beendet */
	menu; /* MenÅzeile aktiv */
	char tname[MAX_PLEN], rname[MAX_PLEN], lname[MAX_PLEN];
	int avid, tid;
	int avflags;
} GLOB;

void mn_istate(int item, int enable);
void mn_disable(void);
void mn_update(void);
void di_about(void);
void de_about(int mode, int ret);
void dl_nextwin(void);
void dl_quit(void);
void di_find(void);
void de_find(int mode, int ret);
void ddnak(EVENT *mevent);
void handle_menu(int title, int item, int ks);
void handle_win(int handle, int msg, int f1, int f2, int f3, int f4, int ks);
void handle_button(int mx, int my, int but, int ks, int br);
void handle_key(int ks, int kr);
void handle_fmsg(EVENT *mevent, FORMINFO *fi);
int get_buf_entry(char *buf, char *name, char **newpos);
int main_init(void);
void main_loop(void);
void main_exit(void);
long search_main(long drvbits, char *searchpath, int follow, char *filemask,
		int fm_case, int fm_dirs, unsigned int mindate, unsigned int maxdate,
		long minsize, long maxsize, char *contentmask, int cm_case,
		int cm_binary, int (*update)(char *current, long hits),
		char *resultfile, char *resulttemplate);
int wild_match(char *string, char *pattern);
unsigned int parse_date(char *date);

#endif
