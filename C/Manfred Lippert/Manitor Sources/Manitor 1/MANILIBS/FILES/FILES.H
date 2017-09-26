#ifndef __MANILIBS_FILES_H__
#define __MANILIBS_FILES_H__

#ifndef __PORTAB__
#include <portab.h>
#endif
#include <i:\c\fremde\manitor\manilibs\diverses\diverses.h>
#include <i:\c\fremde\manitor\manilibs\sysinfo\sysinfo.h>
#include <mgx_dos.h>

#define TRENNER '\\'
#define TRENNER_STR "\\"

#define LW(c) (upper(c) - 'A')
#define LWBEZ(i) ((i) + 'A')
#define LWMASK(i) (0x1L << i)
#define LWANZ 26
#define IS_LW(c) (LW(c) >= 0 && LW(c) < LWANZ)

typedef struct
{
	int32 Type;
	int32 Creator;
	unsigned int Flags;
	int Location1;
	int Location2;
	int Fldr;
} MacFinderInfo;

/* Dateinamen/Pfad-LÑngen (ohne 0-Bytes) */
#define MAXPATH 256
#define MAXDAT 63
#define MAXPATHDAT (MAXPATH + MAXDAT)
/* mit 0-Bytes: */
#define MAXPATH0 (MAXPATH+1)
#define MAXDAT0 (MAXDAT+1)
#define MAXPATHDAT0 (MAXPATHDAT+1)

typedef struct
{
	char *environment;
	char *zusatzordner;
} HOME_ENV;

void current_path(char *path);					/* Aktuellen Pfad ermitteln */

boolean trennerweg(char *dat);					/* Trenner abschneiden */
void trennerhin(char *dat);						/* Trenner anhÑngen */
char *get_extender(char *dat);					/* Zeiger auf Extender (auf Punkt!) oder 0L */
void set_extender(char *dat, char *ext);		/* Extender anhÑngen. !!! ext mit Punkt angeben!!! */
boolean is_extender(char *dat, char *ext);	/* PrÅfen, ob Datei best. Extender hat. */
boolean file_from_path(char *pfad, char *file);	/* letzten Dateinamen von Pfad extrahieren (TRUE, falls ganz vorne) */
boolean cut_last_dir(char *pfad, char *file);		/* letztes Directory vom Pfad abschneiden (Trenner bleibt dran), liefert TRUE, wenn abgeschnitten wurde */
void cut_last_dir2(char *pfad, char *file);	/* im Fehlerfalle pfad->file, pfad lîschen */
char *get_last_dir(char *pfad);					/* letztes Dir/File vom Pfad (NULL wenn kein Trenner) */
char *get_filename(char *pfad);					/* letztes File vom Pfad liefern (garantiert) */

boolean file_exist(char *file);		/* Existiert File? */
boolean ordner_exist(char *pfad);	/* Existiert Ordner? */
boolean link_exist(char *link);		/* Existiert Link? */

int32 file_len(int16 fh);				/* LÑnge eines offenen Files */
int32 file_len2(int16 fh);			/* Nur mit Fseek (z.B. fÅr Mac-RFork wichtig) */

int16 file_openhome(char *datei, char *resultfile, int16 mode, HOME_ENV suchlist[], SYSINFO *sysinfo);	/* Fopen einer Datei mit Suche in suchlist-Angaben und startpath */
int16 file_createhome(char *datei, char *resultfile, HOME_ENV suchlist[], HOME_ENV createlist[], SYSINFO *sysinfo);	/* Fcreate einer Datei. Zuerst obige Suche der Datei, wenn erfolglos Create in createlist-Angaben bzw. startpath (je nach Environment-Existenz) */
boolean file_findhome(char *datei, char *resultfile, HOME_ENV list[], SYSINFO *sysinfo);
boolean folder_findhome(char *folder, char *result, HOME_ENV suchlist[], SYSINFO *sysinfo);

void environment_abkuerzung(char *pfad, char *ergebnis, int16 maxlen, HOME_ENV *suchinf, SYSINFO *sysinfo);

boolean load_block(int16 fh, int32 len, void *b);	/* Leseoperationen... */
int32 load_block2(int16 fh, int32 len, void *b);	/* Leseoperationen... (liefert Gemdos-Fehler) */
boolean load_block_at(int16 fh, int32 pos, int32 len, void *b);
boolean load_char(int16 fh, char *c);
boolean load_int(int16 fh, int16 *i);
boolean load_long(int16 fh, int32 *l);
boolean load_xstring(int16 fh, char *s);

typedef struct {
	char *cache;	/* Cache-Buffer (oder 0) */
	int32 size;		/* Grîûe des Buffers */
	int32 pos;		/* Schreibposition im Buffer */
	int32 rest;		/* restlicher Platz im Buffer */
	int32 wrote;	/* insgesamt Åber den Cache geschickte Bytes */
} SAVECACHE;

/* SAVECACHE kann auch benutzt werden, falls savecache_init FALSE liefert (es wird dann direkt geschrieben) */

boolean savecache_init(SAVECACHE *cache, int32 size);	/* Cache fÅr save_...-Operationen */
boolean savecache_sync(SAVECACHE *cache, int16 fh);	/* Muû am Ende unbedingt gemacht werden!!! (Cache rausschreiben) */
void savecache_clear(SAVECACHE *cache);					/* Nur in NotfÑllen... */
void savecache_free(SAVECACHE *cache);						/* Muû am Ende gemacht werden! */

boolean save_block(SAVECACHE *cache, int16 fh, int32 len, void *b);	/* Schreib-Operationen... */
int32 save_block2(int16 fh, int32 len, void *b);	/* Achtung, geht nicht Åber Cache! */
boolean save_char(SAVECACHE *cache, int16 fh, char c);
boolean save_int(SAVECACHE *cache, int16 fh, int16 i);
boolean save_itoa(SAVECACHE *cache, int16 fh, int16 i);
boolean save_long(SAVECACHE *cache, int16 fh, int32 l);
boolean save_ltoa(SAVECACHE *cache, int16 fh, int32 l);
boolean save_ftoa(SAVECACHE *cache, int16 fh, double d, int16 nachkommastellen);
boolean save_xstring(SAVECACHE *cache, int16 fh, char *s);
boolean save_string(SAVECACHE *cache, int16 fh, char *s);
boolean save_sonderstring(SAVECACHE *cache, int16 fh, char *s);
boolean save_string0(SAVECACHE *cache, int16 fh, char *s);
boolean save_crlf(SAVECACHE *cache, int16 fh);
boolean save_stringcrlf(SAVECACHE *cache, int16 fh, char *s);

boolean filesystem_grossklein(char *pfad);	/* Liefert, ob das Filesystem Groû=Klein behandelt. (TRUE, wenn keine Infos) */
boolean filesystem_nurgross(char *pfad);	/* Liefert, ob das Filesystem Groû=Klein behandelt und auch keinen Unterschied beim Erzeugen macht. (TRUE, wenn keine Infos) */
boolean filesystem_DOS(char *pfad);			/* Liefert, ob das Filesystem 8+3 ist. (TRUE, wenn keine Infos) */
int32 filesystem_maxlen(char *pfad);	/* Liefert maximale DateinamenlÑnge */

void create_applfind_name(char *prg, char *app);	/* Aus Programm (evtl. mit Pfad) einen 8-Zeichen-Namen fÅr appl_find machen */

void Setze_Pfad(char *pfad);

#define FSEL_OK 1
#define FSEL_ABB 0
#define FSEL_ERR -1
int16 fileselect(char *titel, char *pfad, char *maske, int16 masklen, char *datei, int16 *global);
#define FSEL_ALL (app.sysinfo.magic ? "*" : "*.*")

boolean is_ordner(char *pfad);
boolean is_absolut(char *pfad);
boolean is_root(char *pfad);

boolean is_dosname(char *datei);	/* 8+3-Name ohne Leerzeichen? */
boolean is_dospath(char *pfad);	/* Pfad besteht nur aus 8+3-Namen? */

void file_time(DOSTIME *time, char *file);

void pfad_abkuerzung(char *path, char *kurz, int16 maxlen, int16 cutfile);

int32 kill_critic(void);					/* Critical-Error-Handler umsetzen und somit deaktivieren */
void restore_critic(int32 old_critic);	/* Critical-Error-Handler wiederherstellen */

int32 my_Freadlink(int16 bufsize, char *buf, char *name);

#endif
