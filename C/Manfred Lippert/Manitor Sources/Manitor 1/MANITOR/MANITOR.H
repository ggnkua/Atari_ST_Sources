#ifndef _MANITOR_H_
#define _MANITOR_H_

#ifndef __PORTAB__
#include <portab.h>
#endif

#include "..\manilibs\sysinfo\sysinfo.h"

extern int16 global[15];
extern SYSINFO sysinfo;
extern AESINFO aesinfo;

#define DEFAULT_TIMER 250
#define DEFAULT_FILENAME "C:\\MANITOR.LOG"

#define DEFAULT_BUFSIZE 1024L*512

#define DEFAULT_AES_TRACE		1
#define DEFAULT_VDI_TRACE		1
#define DEFAULT_GEMDOS_TRACE	1
#define DEFAULT_BIOS_TRACE		1
#define DEFAULT_XBIOS_TRACE	1

#define DEFAULT_SHOW_SND_MSG			1
#define DEFAULT_SHOW_RCV_MSG			1
#define DEFAULT_RCV_SCRENMGR			1
#define DEFAULT_SHOW_MSG_PRGNAME		0
#define DEFAULT_SHOW_TIMER			1
#define DEFAULT_SHOW_TRAP 			0
#define DEFAULT_SHOW_SHORTTRAP 	0

#define DEFAULT_SHOW_AESRETURNS		1
#define DEFAULT_SHOW_VDIRETURNS		1
#define DEFAULT_SHOW_GEMDOSRETURNS	1
#define DEFAULT_SHOW_XBIOSRETURNS	1
#define DEFAULT_SHOW_BIOSRETURNS		1

#define MAX_GEM_APPS 128

#define OVERFLOW "\r\n\r\n+++ OVERFLOW! +++\r\n\r\n "
#define OVERSIZE ((long)sizeof(OVERFLOW) - 2)
/* Leerzeichen am Ende von OVERFLOW muû sein! (fillbuf_overflow) */
/* OVERSIZE ist die LÑnge von OVERFLOW ohne dieses Leerzeichen! (Und ohne 0-Byte) */

extern int dock_pid;
#define DOCK_SESSION 17

#define SIZE_PRG 27
#define SIZE_MSG 14
#define SIZE_MAX_STR "                           "

typedef struct {
	char gueltig;	/* Dieser Eintrag ist gÅltig */
	char filtered;	/* Diese App wird gefiltert */
	int check;		/* fÅr internen Check, ob App noch da ist */
	int id;			/* AES-ID der App */
	char name[9];	/* Name der App */
	BASPAG *bas;	/* dazu ermittelte Basepage (damit Name auch bei VDI, Gemdos usw. ausgegeben werden kann) */
} GEM_APP;

extern int hooked;	/* in Traps eingeklinkt, Logfile offen */
extern int pending;	/* Buffer darf noch nicht freigegeben werden, da Returns noch verbogen sind... */

extern char filename[128];
extern long want_bufsize;
extern int timer;

extern BASPAG **p_run;					/* Zeiger auf Zeiger auf aktuellen Prozess */
extern long begin_timer;

extern int aes_is_traced;
extern int vdi_is_traced;
extern int gemdos_is_traced;
extern int xbios_is_traced;
extern int bios_is_traced;

extern int show_snd_messages;			/* Zeige Messages bei appl_write */
extern int show_rcv_messages;			/* Zeige Messages bei evnt_mesag/evnt_multi */
extern int rcv_only_screnmgr;			/* Zeige Received Messages nur vom Screenmanager */
extern int show_msg_prgname;			/* Zeige Prozeû-Name bei Messages? */
extern int show_trap;					/* Zeige Trap-"Art" (AES, VDI, Gemdos...) */
extern int show_short_trap;			/* Zeige Trap-"Art" in Kurzform */
extern int show_timer;					/* 200Hz-Timer zeigen? */

extern int show_aesreturns;			/* Zeige AES-Return-Werte */
extern int show_vdireturns;			/* Zeige VDI-Return-Werte */
extern int show_gemdosreturns;		/* Zeige Gemdos-Return-Werte */
extern int show_xbiosreturns;			/* Zeige Xbios-Return-Werte */
extern int show_biosreturns;			/* Zeige Bios-Return-Werte */

extern long my_200hz;		/* mein eigener 200Hz Counter :-) */

void get_prg(BASPAG *bas, int aesid, char **prc_name, char **app_name);

void update_gem_apps(void);

int init_buffer(void);
void fillbuf(char *data, unsigned long len);
void fillbuf_string(char *s);
void fillbuf_maxstring(char *s, int maxlen);
void fillbuf_para(char *s);
void fillbuf_quote(char *str);
void fillbuf_envquote(char *str);
void fillbuf_pexecquote(char *str);
void fillbuf_crlf(void);
void fillbuf_prg(int aesid, char *prc_name, char *app_name, int size);
void fillbuf_aes(int aesid, char *app_name);
void update_buffer(void);
void deinit_buffer(int except);
void free_buffer(void);

int init_aes(void);
int init_vdi(void);
int init_gemdos(void);
int init_xbios(void);
int init_bios(void);

void deinit_aes(void);
void deinit_vdi(void);
void deinit_gemdos(void);
void deinit_xbios(void);
void deinit_bios(void);

void deinit_broadcast(void);
int deinit_aespending(void);
int deinit_vdipending(void);
int deinit_gemdospending(void);
int deinit_xbiospending(void);
int deinit_biospending(void);

#define T_INT 0
#define T_LONG 1
#define T_ADR 2
#define T_STR 3
#define T_DRV0 4	/* drv: 0=A, 1=B ... */
#define T_DRV1 5	/* drv: 0=act. 1=A 2=B ... */
#define T_PEXEC 6	/* Parameter von Pexec */
#define T_AESID 7
#define T_MULTITYPES 8
#define T_FMD 9
#define T_SHELWRITE 10
#define T_APPFINDSTR 11
#define T_GRECT 12
#define T_WKIND 13
#define T_WUPD 14
#define T_WCALC 15
#define T_WGETSET 16
#define T_GS_INFO 17
#define T_STR00 18
#define T_GS_BACK 19
#define T_GS_ACK 20
#define T_OLE_BITS 21
#define T_XACC 22
#define T_INT_HEX 23
#define T_OLGA_ACK 24
#define T_OLGA_START 25
#define T_EXTXACC 26
#define T_OLGA_ACTIVATE 27
#define T_EXT 28
#define T_EXT0ID 29
#define T_AVPROTOKOLL 30
#define T_VAPROTOSTATUS 31
#define T_SHIFT 32
#define T_THAT_IZIT 33
#define T_ARROWED 34
#define T_KEY 35
#define T_LONG_HEX 36
#define T_V_PLINE 37
#define T_VDISTR 38
#define T_VSTEFFECTS 39
#define T_V_BEZ 40
#define T_GRAFMOUSE 41
#define T_EVNT 42
#define T_EVNTMULTI 43
#define T_FIX31 44
#define T_MFDB 45
#define T_COLOR_ENTRY 46
#define T_GCBITMAP 47
#define T_TRANSFER_MODE 48

typedef struct {
	int bitmask;
	char *name;
} BITNAME;

typedef struct {
	long val;
	char *name;
} CONSTNAME;

void show_constname(CONSTNAME *names, long val);

typedef struct {
	int typ;
	char *name;
} PARA;

#define MAX_PARA 9
typedef struct {
	int opcode;
	char *name;
	int para_anz;
	PARA para[MAX_PARA];
	int filtered;		/* Flag, ob diese Funktion gefiltert werden soll */
} FUNC;

typedef struct {
	unsigned int min_hash;
	unsigned int max_hash;
	FUNC **hash;
} FUNCS;

extern FUNC gemdos_func[];
extern FUNC xbios_func[];
extern FUNC bios_func[];

int init_funcs(FUNCS *funcs, FUNC *func);
void deinit_funcs(FUNCS *funcs);

FUNC *find_func(FUNCS *funcs, unsigned int opcode);
void show_func(FUNC *func, void *sp);

void show_funcpara(int typ, char *name, void **ptr);

#define NO_SUBCODE -1
#define EGAL -1

/* FÅr AESPARA/VDIPARA-Eingabeparameter: */
#define INTIN 0
#define ADDRIN 1
#define PTSIN 1
#define AESPBIN 2
#define VDIPBIN 2
#define CONTRL 3

/* FÅr AESPARA/VDIPARA-Ausgabeparameter: */
#define INTOUT 0
#define ADDROUT 1
#define PTSOUT 1

typedef struct {
	int intype;
	int idx;
	int typ;
	char *name;
} VDIPARA;

#define OUT_NONE 0
#define OUT_INT 0x1
#define OUT_PTS 0x2
#define OUT_INTPTS (OUT_INT|OUT_PTS)

#define MAX_VDIPARA 13
typedef struct {
	int opcode;			/* contrl[0] */
	int subcode;		/* contrl[5] */
	int anz_intin;		/* contrl[3] */
	int anz_ptsin;		/* contrl[1] */
	char *name;
	int para_anz;
	VDIPARA para[MAX_VDIPARA];
	int ret_anz;
	VDIPARA retpara[MAX_VDIPARA];
	int outbits;		/* Bit 0: intout, Bit 1: ptsout (OUT_...) */
	int filtered;		/* Flag, ob diese Funktion gefiltert werden soll */
} VDIFUNC;

typedef struct {
	unsigned int min_hash;
	unsigned int max_hash;
	VDIFUNC **hash;
} VDIFUNCS;

extern VDIFUNC vdi_func[];


typedef struct {
	int intype;
	int idx;
	int typ;
	char *name;
} AESPARA;

#define MAX_AESPARA 17
typedef struct {
	int opcode;			/* contrl[0] */
	int anz_intin;		/* contrl[1] */
	int anz_addrin;	/* contrl[3] */
	int subcode;		/* intin[0] */
	int subcode2;		/* intin[1] */
	char *name;
	int para_anz;
	AESPARA para[MAX_AESPARA];
	int ret_anz;
	AESPARA retpara[MAX_AESPARA];
	int filtered;		/* Flag, ob diese Funktion gefiltert werden soll */
} AESFUNC;

typedef struct {
	unsigned int min_hash;
	unsigned int max_hash;
	AESFUNC **hash;
} AESFUNCS;

extern AESFUNC aes_func[];

GEM_APP *find_gem_app(int id);

#define RET_EMPTY 0
#define RET_BUSY	1
#define RET_READY 2

#define RET_BIOS 0
#define RET_XBIOS 1
#define RET_GEMDOS 2
#define RET_VDI 3
#define RET_AES 4

#define RET_MAXINTOUT 9
#define RET_MAXADDROUT 4

typedef struct {
	int state;	/* Empty/Busy/Ready */
	long hz200;	/* Wann kam Return */
	int typ;		/* Welcher Trap */
	long ret;	/* Return d0 */

/* Offset 12 */

	BASPAG *bas;	/* immer: Basepage */
	int pid;			/* AES: global[2], sonst -1 */
	int opcode;		/* Gemdos/Bios/Xbios: stack[0], AES/VDI: control[0] */
	int contrl1;	/* AES/VDI: contrl[1] */
	int contrl3;	/* AES/VDI: contrl[3] */
	int contrl5;	/* VDI:     contrl[5] */
	int intin0;		/* AES: intin[0] */
	int intin1;		/* AES: intin[1] */

/* Offset 30 */

	char prc_name[13];	/* FÅr die Ausgabe (kann nicht mehr nachtrÑglich ermittelt werden!) */
	char app_name[9];		/* FÅr die Ausgabe (kann nicht mehr nachtrÑglich ermittelt werden!) */

/* Offset 52 */

	int intout[16];
	void *addrout[16];	/* Bei VDI: int ptsout[32] */

	int contrl6;			/* Bei VDI: contrl[6] */

/* Offset 150 */

	int msgbuf[8];		/* Bei evnt_mesag/evnt_multi */

/* Offset 166 */

	char resvd[90];

/* Grîûe muû 256 Bytes sein!!! (-> Assembler) */
} RETURN;

/* Muû mit Assemblerteil Åbereinstimmen: !!!!! */
#define RET_ANZ_MASK 0xF		/* Platz fÅr 16 Return-Definitionen in der Tabelle */
#define RET_ANZ (RET_ANZ_MASK + 1)

extern RETURN ret[RET_ANZ];
extern char ret_semaphore;		/* Semaphore zum weiterzÑhlen des Return-Counters */
extern int akt_ret;				/* muû ununterbrechbar weitergezÑhlt werden (ret_semaphore benutzen!) */

void show_returncodes(void);
void clear_returncodes(void);

void aes_return(RETURN *ret);
void vdi_return(RETURN *ret);
void gemdos_return(RETURN *ret);
void xbios_return(RETURN *ret);
void bios_return(RETURN *ret);

extern CONSTNAME oserrconst[];

typedef struct
{
	char name[10];
} PRGFILTER;

#define MAX_PRGFILTER 64

int prg_is_filtered(char *prc_name, char *app_name);

typedef struct {
	int idx;		/* Index im int msg[]-Buffer */
	int typ;		/* Datentyp */
	char *name;	/* Name des Parameters */
} MSGPARA;

#define MAX_MSGPARA 5
typedef struct {
	int nr;				/* Message-Nummer */
	char *name;			/* Message-Name */
	int para_anz;		/* Anzahl Parameter */
	MSGPARA para[MAX_MSGPARA];	/* Parameter */
	int filtered;
} GEM_MSG;

typedef struct {
	unsigned int min_hash;
	unsigned int max_hash;
	GEM_MSG **hash;
} GEM_MSGS;

extern GEM_MSG gem_msg[];

/********* KONFIGURATION: ************/

int activate(void);
int deactivate(int except);
void terminate(int except);

#define NO_CHANGE -1

void preset_manitor(void);
void aes_konfig(int on, int ret);
void msg_konfig(int send, int received, int only_screnmgr, int pnam);
void vdi_konfig(int on, int ret);
void gemdos_konfig(int on, int ret);
void xbios_konfig(int on, int ret);
void bios_konfig(int on, int ret);
void opcode_konfig(int on, int kurz);
void timer_konfig(int on);
void set_file(char *file);
void set_timer(int ms);
void set_bufsize(long size);
void hide_aes(char *name);
void hide_vdi(char *name);
void hide_gemdos(char *name);
void hide_xbios(char *name);
void hide_bios(char *name);
void hide(char *name);
void show_aes(char *name);
void show_vdi(char *name);
void show_gemdos(char *name);
void show_xbios(char *name);
void show_bios(char *name);
void show(char *name);

void hide_msg(char *name);
void show_msg(char *name);

void hide_prg(char *name);
void show_prg(char *name);
void exclude_prgs(void);
void include_prgs(void);
void clear_prgfilter(void);

/************************************/

#define WF_TOOLBAR 30

#endif
