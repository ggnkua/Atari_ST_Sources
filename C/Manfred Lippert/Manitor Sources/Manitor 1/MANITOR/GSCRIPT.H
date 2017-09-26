/* GSCRIPT.H */

#ifndef __GSCRIPT_H__
#define __GSCRIPT_H__

#ifndef __PORTAB__
#include <portab.h>
#endif

#include "..\toslib\aes\aes.h"
#include "..\manilibs\kette\kette.h"
#include "..\manilibs\dynblock\dynblock.h"
#include <time.h>

#define GS_VERSION	0x0100	/* Eigene unterstÅtzte GEMScript-Version */
#define GS_MSGS  GSM_COMMAND	/* Eigene verstandene Messages */

/* GEMScript-Nachrichten: */

#define GS_REQUEST		0x1350
#define GS_REPLY			0x1351
#define GS_COMMAND		0x1352
#define GS_ACK				0x1353
#define GS_QUIT			0x1354
#define GS_OPENMACRO		0x1355
#define GS_MACRO			0x1356
#define GS_WRITE			0x1357
#define GS_CLOSEMACRO	0x1358

/* Masken fÅr unterstÅtzte Nachrichten (msgs): */

#define GSM_COMMAND		0x0001  /* kann GS_COMMAND empfangen */
#define GSM_MACRO			0x0002  /* (Interpreter) kann GS_OPENMACRO, GS_WRITE und GS_CLOSEMACRO empfangen, GS_MACRO verschicken */
#define GSM_WRITE			0x0004  /* (aufnahmefÑhige App) kann GS_OPENMACRO, GS_WRITE und GS_CLOSEMACRO verschicken, GS_MACRO empfangen */

/* Returnwerte bei GS_ACK (msg[7]): */

#define GSACK_OK			0
#define GSACK_UNKNOWN	1
#define GSACK_ERROR		2
#define GSACK_NO_ACK		-1		/* Nur intern verwendet -> Kein GS_ACK schicken */

typedef struct {
	long len;       /* LÑnge der Struktur in Bytes                      */
	int  version;   /* Versionsnummer des Protokolles beim Sender       */
	int  msgs;      /* Bitmap der unterstÅtzten Nachrichten (GSM_xxx)   */
	long ext;       /* benutzte Endung, etwa '.SIC'                     */
} GS_INFO;

extern GS_INFO *my_gs_info;	/* Eigene GS_INFO-Struktur (wird bei gs_init alloziert) */

int gs_init(void);		/* GEMScript initialisieren */
void gs_deinit(void);	/* GEMScript deinitialisieren */

int gs_messages(int16 *msg);	/* Auswertung der GEMScript-Messages */


/* Nîtige Vereinbarungen fÅr konkrete Implementation: */


extern int apid;	/* Eigene Applikations-ID */

/* Zur Verwaltung "connecteter" GEMScript-Partner: */

typedef struct
{
	GLIED glied;	/* Zur Verwaltung als verkettete Liste (muû am Anfang der Struktur sein!) */
	int pid;			/* apid des Partners */
	int subid;		/* Sub-ID der "Session" */
	GS_INFO *info;	/* Partners GS_INFO-Struktur */
	boolean request;	/* TRUE falls Partner GS_REQUEST geschickt hat, FALSE falls "ich" GS_REQUEST geschickt habe (Partner also GS_REPLY) */
} GS_PARTNER;

extern KETTE gs_partner;	/* verkettete Liste connecteter GEMScript-Partner (Glied-Typ: GS_PARTNER) */

GS_PARTNER *find_gs_partner(int pid, int subid);	/* connecteten Partner suchen */

int my_appl_write(int pid, int16 *msg);

/** msg-Buffer fÅr verschiedene Messages ausfÅllen: **/

void gs_fill_request(int16 *msg, int subid);
void gs_fill_reply(int16 *msg, int subid, int error);
void gs_fill_quit(int16 *msg, int subid);
void gs_fill_command(int16 *msg, char *ptr, int subid);
void gs_fill_ack(int16 *msg, char *ptr1, char *ptr2, int ret);
void gs_fill_openmacro(int16 *msg, char *ptr);
void gs_fill_macro(int16 *msg, char *ptr, int id, int ret);
void gs_fill_write(int16 *msg, char *ptr, int id);
void gs_fill_closemacro(int16 *msg, int id);

/* Strukturen zur Verwaltung der Kommandos: */

typedef void (*gs_freefunc)(void *adr, void *para);
/* adr: Zeiger auf GS_ACK-Returnstring, der abgeschickt wurde.
        Wird von selbst freigegeben!!!!
   para: Zeiger auf beliebige Daten (Userdefiniert)
         z.B. fÅr weitere Daten, die freigegeben werden mÅssen.
*/

/* Struktur um den Return-String aufzubauen: */
typedef struct
{
	DYN_BLOCK dyn;
	gs_freefunc freefunc;	/* Wird in GSBUFFER Åbertragen! */
	void *para;					/* Wird in GSBUFFER Åbertragen! */
} GSRETURN;

/* Struktur fÅr jedes Kommando */
typedef struct
{
	char *cmdkey;	/* Das Kommando */
	int (*funk)(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
						/* Zeiger auf die zugehîrige Funktion */
} GSCMD;

extern GSCMD gs_kommandos[];	/* Array aller verstandener Kommandos! */

/* Struktur fÅr Buffer (meist Return-Werte) */
typedef struct
{
	GLIED glied;
	int pid;			/* ap_id */
	void *adr;		/* benutzte Adresse der Parameter die noch freigegeben werden sollte */

	gs_freefunc freefunc;	/* User-Routine, die beim Freigeben aufgerufen wird */
	void *para;					/* User-Parameter */
} GSBUFFER;

extern KETTE gsbuffer;	/* Kette noch freizugebender GSBUFFER */

GSBUFFER *merk_gsbuffer(int pid, void *adr, gs_freefunc func, void *para);
void free_gsbuffer(GSBUFFER *buf);
GSBUFFER *find_gsbuffer(int pid, void *adr);

char *gs_next(char *cmd);

/********* DOCK: ***********/

typedef struct {
	char *name;
	char *id;
	int *schalter;	/* Zeiger auf Schalter, der Funktion an/ausschaltet oder 0L, dann Sonderbehandlung */
	char *buf;		/* Zeiger auf verschicktes Command (zum Zuordnen des GS_ACK, Freigegeben wird automatisch) */
	int changed;	/* Flag, wenn Parameter verÑndert wurde */
} DOCK_ITEM;

enum {
			DOCK_STARTSTOP,
			DOCK_AES,
			DOCK_AES_RETURNS,
			DOCK_SNDMESSAGES,
			DOCK_RCVMESSAGES,
			DOCK_RCVONLYSCRENMGR,
			DOCK_HIDE_AES,
			DOCK_SHOW_AES,
			DOCK_VDI,
			DOCK_VDI_RETURNS,
			DOCK_GEMDOS,
			DOCK_GEMDOS_RETURNS,
			DOCK_XBIOS,
			DOCK_XBIOS_RETURNS,
			DOCK_BIOS,
			DOCK_BIOS_RETURNS
};

extern DOCK_ITEM dock_item[];

void create_Dock_items(int only_changed);
void delete_Dock_items(void);
void Dock_ack(char *mycmd, char *ack);


/* Prototypen der Kommando-Funktionen: */

int gsfunc_terminate(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_activate(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_deactivate(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_preset(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_aes(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_msg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_vdi(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_gemdos(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_xbios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_bios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_opcode(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_timer(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_set_file(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_set_timer(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_set_bufsize(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_aes(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_vdi(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_gemdos(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_xbios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_bios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_aes(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_vdi(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_gemdos(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_xbios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_bios(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_msg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_msg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_hide_prg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_show_prg(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_exclude_prgs(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_include_prgs(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_clear_prgfilter(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_AppGetLongName(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);
int gsfunc_notify(char *cmd, GSRETURN *ret, int16 *msg, GS_PARTNER *p);

#endif
