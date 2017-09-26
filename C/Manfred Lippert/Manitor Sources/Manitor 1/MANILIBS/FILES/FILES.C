#include <i:\c\fremde\manitor\manilibs\files\files.h>

/* #include <manilibs\xgemdos\xgemdos.h> */
#include <i:\c\fremde\manitor\manilibs\diverses\diverses.h>
#include <i:\c\fremde\manitor\manilibs\alloc\alloc.h>

/* #include <manilibs\parseasc\parseasc.h> */

#include <i:\c\fremde\manitor\toslib\aes\aes.h>

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void current_path(char *path) {
	int16 drv = Dgetdrv();
	path[0] = 'A' + (char)drv;
	path[1] = ':';
	path[2] = TRENNER;
	path[3] = 0;
	Dgetpath(path + 3, drv + 1);
	if (path[3] == TRENNER)
		strcpy(path + 2, path + 3);
	trennerhin(path);
}

boolean trennerweg(char *dat) {
	boolean was_trenner = FALSE;
	int16 len = (int16)strlen(dat);
	while (len-- && dat[len] == TRENNER) {
		dat[len] = 0;
		was_trenner = TRUE;
	}
	return was_trenner;
}

void trennerhin(char *dat) {
	int16 len = (int16)strlen(dat);
	if (len && dat[len - 1] != TRENNER) {
		dat[len] = TRENNER;
		dat[len+1] = 0;
	}
}

char *get_extender(char *file) {
	return strrchr(file, '.');
}

void set_extender(char *file, char *ext) {	/* ext mit Punkt angeben!!! */
	char *right = strrchr(file, TRENNER);
	char *punkt;
	if (!right)
		right = file;
	punkt = strchr(right, '.');
	if (!punkt)
		strcat(file, ext);
	else
		strcpy(punkt, ext);
}

boolean is_extender(char *dat, char *ext) {
	int16 dlen = (int16)strlen(dat);
	int16 elen = (int16)strlen(ext);
	if (dlen < elen)
		return FALSE;
	return (stricmp(dat + dlen - elen, ext) == 0);
}

char *get_filename(char *pfad) {
	char *pos = get_last_dir(pfad);
	if (!pos)
		return pfad;
	return pos;
}

char *get_last_dir(char *pfad) {
	boolean trenner = trennerweg(pfad);
	char *pos = strrchr(pfad, TRENNER);
	if (pos)
		pos++;	/* Hinter Trenner */
	if (trenner)
		trennerhin(pfad);
	return pos;
}

/* letztes Directory vom Pfad abschneiden (Trenner bleibt dran), liefert TRUE, wenn abgeschnitten wurde */
/* Falls file != 0L, wird letztes Dir reingeschrieben (nur bei Erfolg!) */
boolean cut_last_dir(char *pfad, char *file) {
	char *pos = get_last_dir(pfad);
	if (!pos)
		return FALSE;
	if (file) {
		char last[MAXDAT0 + 1];
		strcpy(last, pos);
		trennerweg(last);
		strcpy(file, last);
	}
	if (file != pfad)
		*pos = 0;
	return TRUE;
}

/* kopiert im Fehlerfall (kein Trenner mehr) pfad in file um und lîscht pfad */
void cut_last_dir2(char *pfad, char *file) {
	if (!cut_last_dir(pfad, file) && (int16)strlen(pfad) < MAXDAT0) {
		strcpy(file, pfad);
		pfad[0] = 0;
	}
}

/* Liefert TRUE, falls file am Anfang steht */
boolean file_from_path(char *pfad, char *file) {
	char last[MAXDAT0 + 1];
	char *pos = get_last_dir(pfad);
	if (pos)
		strcpy(last, pos);
	else
		strcpy(last, pfad);
	trennerweg(last);
	strcpy(file, last);
	return (!pos);
}

boolean file_exist(char *file) {
	int32 old_critic = kill_critic();
	int32 fh = Fopen(file, FO_READ);
	restore_critic(old_critic);
	if (fh < 0L)
		return FALSE;
	Fclose((int16)fh);
	return TRUE;
}

/*---------------------

boolean ordner_exist(char *ord) {
	int32 back;
	int32 old_critic = kill_critic();
	int32 dir = Dopendir(ord, 0);
	if ((dir & DIR_FEHLER) == DIR_FEHLER) {
		char ord2[MAXPATHDAT0];
		strcpy(ord2, ord);
		trennerhin(ord2);
		strcat(ord2, "*.*");
		back = Fsfirst(ord2, 0x17);
		restore_critic(old_critic);
		return (back != EPTHNF && back != EFILNF && back != EDRIVE);
	}
	Dclosedir(dir);
	restore_critic(old_critic);
	return TRUE;
}
--------------------*/

boolean link_exist(char *link) {
	char link2[MAXPATHDAT0];
	return (my_Freadlink(MAXPATHDAT0, link2, link) >= 0L);
}

int32 my_Freadlink(int16 bufsize, char *buf, char *name) {
	boolean wastrenner = trennerweg(name);
	int32 back;
	buf[0] = 0;
	back = Freadlink(bufsize, buf, name);

	if (wastrenner) {
		trennerhin(name);
	}

	if (back >= 0L && !buf[0]) {	/* Wegen diverser CD-Treiber! */
		back = -1L;
	}
	if (wastrenner) {
		if (back < 0L) {
			back = Freadlink(bufsize, buf, name);
			if (back >= 0L && !buf[0]) {	/* Wegen diverser CD-Treiber! */
				back = -1L;
			}
		}

/*
		if (back < 0L) {
			char vgl[MAXPATHDAT0];
			Setze_Pfad(name);
			current_path(vgl);
			printf("%s -> %s\n", name, vgl);
		}
*/
	}
	return back;
}

int32 file_len(int16 fh) {
	XATTR attr;
	int32 back = Fcntl(fh, (int32)&attr, FSTAT);
	if (back == 0L)
		return attr.size;
	return file_len2(fh);
}

int32 file_len2(int16 fh) {
	int32 len;
	int32 oldpos = Fseek(0L, fh, 1);
	len = Fseek(0L, fh, 2);
	Fseek(oldpos, fh, 0);
	return len;
}

/* File anhand Environment-Variable finden */
boolean file_findenv(HOME_ENV *env, char *datei, char *resultfile) {
	int16 lenmerk;
	char *next;
	char *value = getenv(env->environment);
	while (value && *value) {
		strcpy(resultfile, value);
		next = strpbrk(resultfile, ";,");
		if (next) {
			*next = 0;
			value += next - resultfile + 1;
		} else {
			value = 0L;
		}
		trennerweg(resultfile);
		if (resultfile[0]) {
			if (resultfile[0] == '.' && resultfile[1] == 0) {
				current_path(resultfile);
			}
			trennerhin(resultfile);
			if (env->zusatzordner) {
				lenmerk = (int16)strlen(resultfile);
				strcat(resultfile, env->zusatzordner);
				trennerhin(resultfile);
				if (!ordner_exist(resultfile))		/* Zusatzordner gibts nicht */
					str_lower(resultfile + lenmerk);	/* dann Zusatzordner in Kleinschreibung probieren */
			}
			lenmerk = (int16)strlen(resultfile);
			strcat(resultfile, datei);
			if (file_exist(resultfile)) {
				return TRUE;
			}
			str_lower(resultfile + lenmerk);		/* Datei in Kleinschreibung probieren */
			if (file_exist(resultfile)) {
				return TRUE;
			}
		}
	}
	return FALSE;
}

/* Ordner anhand Environment-Variable finden */
boolean folder_findenv(HOME_ENV *env, char *folder, char *result) {
	int16 lenmerk;
	char *next;
	char *value = getenv(env->environment);
	while (value && *value) {
		strcpy(result, value);
		next = strpbrk(result, ";,");
		if (next) {
			*next = 0;
			value += next - result + 1;
		} else {
			value = 0L;
		}
		trennerweg(result);
		if (result[0]) {
			if (result[0] == '.' && result[1] == 0) {
				current_path(result);
			}
			trennerhin(result);
			if (env->zusatzordner) {
				lenmerk = (int16)strlen(result);
				strcat(result, env->zusatzordner);
				trennerhin(result);
				if (!ordner_exist(result))		/* Zusatzordner gibts nicht */
					str_lower(result + lenmerk);	/* dann Zusatzordner in Kleinschreibung probieren */
			}
			lenmerk = (int16)strlen(result);
			strcat(result, folder);
			trennerhin(result);
			if (ordner_exist(result)) {
				return TRUE;
			}
			str_lower(result + lenmerk);		/* Datei in Kleinschreibung probieren */
			if (ordner_exist(result)) {
				return TRUE;
			}
		}
	}
	return FALSE;
}

/* File anhand mehrerer Environmentvariablen oder im Startpfad suchen */
/* Achtung: evtl. Setze_Pfad(sysinfo.startpath) machen, da in $PATH "." vorkommen kann! */
boolean file_findhome(char *datei, char *resultfile, HOME_ENV suchlist[], SYSINFO *sysinfo) {
	if (!is_absolut(datei) && suchlist) {
		while (suchlist->environment) {
			if (file_findenv(suchlist, datei, resultfile))
				return TRUE;
			suchlist++;
		}

		strcpy(resultfile, sysinfo->startpath);
		strcat(resultfile, datei);
		if (file_exist(resultfile))
			return TRUE;
		str_lower(resultfile + strlen(sysinfo->startpath));		/* Datei in Kleinschreibung probieren */
		if (file_exist(resultfile))
			return TRUE;
	}

	strcpy(resultfile, datei);
	if (file_exist(resultfile))
		return TRUE;

	return FALSE;
}

int16 file_openhome(char *datei, char *resultfile, int16 mode, HOME_ENV suchlist[], SYSINFO *sysinfo) {
	if (file_findhome(datei, resultfile, suchlist, sysinfo)) {
		int32 fh = Fopen(resultfile, mode);
		if (fh >= 0)
			return (int16)fh;
	}
	return -1;
}

boolean file_addenv(HOME_ENV *env, char *datei, char *resultfile) {
	if (!is_absolut(datei)) {
		char *next;
		char *value = getenv(env->environment);
		while (value && *value) {
			strcpy(resultfile, value);
			next = strpbrk(resultfile, ";,");
			if (next) {
				*next = 0;
				value += next - resultfile + 1;
			} else {
				value = 0L;
			}
			trennerweg(resultfile);
			if (resultfile[0] == '.' && resultfile[1] == 0) {
				current_path(resultfile);
			}
			trennerhin(resultfile);
			if (env->zusatzordner) {
				int16 lenmerk = (int16)strlen(resultfile);
				strcat(resultfile, env->zusatzordner);
				trennerhin(resultfile);
				if (!ordner_exist(resultfile)) {
					str_lower(resultfile + lenmerk);	/* Zusatzordner mal in Kleinschreibung versuchen */
				}
			}
			if (ordner_exist(resultfile)) {
				strcat(resultfile, datei);
				return TRUE;
			}
		}
	}
	return FALSE;
}

int16 file_createhome(char *datei, char *resultfile, HOME_ENV suchlist[], HOME_ENV createlist[], SYSINFO *sysinfo) {
	int32 fh;
	if (!file_findhome(datei, resultfile, suchlist, sysinfo)) {
		if (createlist) {
			while (createlist->environment) {
				if (file_addenv(createlist, datei, resultfile)) {
					fh = Fcreate(resultfile, 0);
					if (fh >= 0) {
						return (int16)fh;
					}
				}
				createlist++;
			}
		}
		if (!is_absolut(datei)) {
			strcpy(resultfile, sysinfo->startpath);
			strcat(resultfile, datei);
		} else {
			strcpy(resultfile, datei);
		}
	}

	fh = Fcreate(resultfile, 0);
	if (fh < 0) {
		return -1;
	}

	return (int16)fh;
}

/* Ordner anhand mehrerer Environmentvariablen oder im Startpfad suchen */
/* Achtung: evtl. Setze_Pfad(sysinfo.startpath) machen, da in $PATH "." vorkommen kann! */
boolean folder_findhome(char *folder, char *result, HOME_ENV suchlist[], SYSINFO *sysinfo) {
	if (!is_absolut(folder) && suchlist) {
		while (suchlist->environment) {
			if (folder_findenv(suchlist, folder, result)) {
				return TRUE;
			}
			suchlist++;
		}

		strcpy(result, sysinfo->startpath);
		strcat(result, folder);
		trennerhin(result);
		if (ordner_exist(result)) {
			return TRUE;
		}
		str_lower(result + strlen(sysinfo->startpath));		/* Datei in Kleinschreibung probieren */
		if (ordner_exist(result)) {
			return TRUE;
		}
	}

	strcpy(result, folder);
	trennerhin(result);

	return ordner_exist(result);
}

boolean load_block_at(int16 fh, int32 pos, int32 len, void *b) {
	if (Fseek(pos, fh, 0) != pos) return FALSE;
	return load_block(fh, len, b);
}

boolean load_block(int16 fh, int32 len, void *b) {
	if (!len)
		return TRUE;
	return (Fread(fh, len, b) == len);
}

int32 load_block2(int16 fh, int32 len, void *b) {
	int32 back;
	if (!len)
		return E_OK;
	back = Fread(fh, len, b);
	if (back < 0L)
		return back;
	else if (back != len)
		return EINTRN;
	return E_OK;
}

boolean load_char(int16 fh, char *c) {
	return load_block(fh, sizeof(char), c);
}

boolean load_int(int16 fh, int16 *i) {
	return load_block(fh, sizeof(int16), i);
}

boolean load_long(int16 fh, int32 *l) {
	return load_block(fh, sizeof(int32), l);
}

boolean load_xstring(int16 fh, char *s) {
	int32 len;
	if (!load_long(fh, &len)) return FALSE;
	return load_block(fh, len, s);
}

/* SAVECACHE kann auch benutzt werden, falls savecache_init FALSE liefert (es wird dann direkt geschrieben) */
boolean savecache_init(SAVECACHE *cache, int32 size) {
	cache->size = size;
	cache->cache = alloc_bestblock(&cache->size, 512L);
	cache->pos = 0L;
	cache->rest = cache->size;
	cache->wrote = 0;
	return (cache->cache != 0L);
}

boolean savecache_sync(SAVECACHE *cache, int16 fh) {
	if (cache->pos) {
		boolean back = (Fwrite(fh, cache->pos, cache->cache) == cache->pos);
		cache->pos = 0L;
		cache->rest = cache->size;
		return back;
	}
	return TRUE;
}

void savecache_clear(SAVECACHE *cache) {
	cache->pos = 0L;
	cache->rest = cache->size;
}

void savecache_free(SAVECACHE *cache) {
	if (cache->cache)
		free(cache->cache);
	cache->cache = 0L;
}

boolean save_block(SAVECACHE *cache, int16 fh, int32 len, void *adr) {
	if (!len)
		return TRUE;
	if (!cache || !cache->cache)
		return (Fwrite(fh, len, adr) == len);

	cache->wrote += len;

savecache_nochmal:
	if (cache->rest >= len) {	/* im Cache ist noch genug Platz */
		memcpy(cache->cache + cache->pos, adr, len);
		cache->pos += len;
		cache->rest -= len;
		return TRUE;
	}
	/* Cache wird zu klein */
	if (cache->rest) {
		memcpy(cache->cache + cache->pos, adr, cache->rest);	/* Cache fÅllen */
		len -= cache->rest;
		(char *)adr += cache->rest;
		cache->pos += cache->rest;
		cache->rest = 0L;
	}
	/* Cache ist jetzt komplett voll */
	if (!savecache_sync(cache, fh))									/* Cache flushen */
		return FALSE;
	goto savecache_nochmal;				/* Mit dem Rest weitermachen! */
}

int32 save_block2(int16 fh, int32 len, void *b) {	/* ACHTUNG! Geht nicht Åber savecache!!!!!!!! */
	int32 back;
	if (!len)
		return E_OK;
	back = Fwrite(fh, len, b);
	if (back < 0L)
		return back;
	else if (back != len)
		return EINTRN;
	return E_OK;
}

boolean save_char(SAVECACHE *cache, int16 fh, char c) {
	return save_block(cache, fh, sizeof(char), &c);
}

boolean save_int(SAVECACHE *cache, int16 fh, int16 i) {
	return save_block(cache, fh, sizeof(int16), &i);
}

boolean save_itoa(SAVECACHE *cache, int16 fh, int16 i) {
	char txt[10];
	itoa(i, txt, 10);
	return save_string(cache, fh, txt);
}

boolean save_long(SAVECACHE *cache, int16 fh, int32 l) {
	return save_block(cache, fh, sizeof(int32), &l);
}

boolean save_ltoa(SAVECACHE *cache, int16 fh, int32 l) {
	char txt[20];
	ltoa(l, txt, 10);
	return save_string(cache, fh, txt);
}

boolean save_ftoa(SAVECACHE *cache, int16 fh, double d, int16 nachkommastellen) {
	char txt[50];
	sprintf(txt, "%.*f", nachkommastellen, d);
	return save_string(cache, fh, txt);
}

boolean save_xstring(SAVECACHE *cache, int16 fh, char *s) {
	int32 len = strlen(s) + 1;
	if (!save_long(cache, fh, len)) return FALSE;
	return save_block(cache, fh, len, s);
}

boolean save_string(SAVECACHE *cache, int16 fh, char *s) {
	return save_block(cache, fh, strlen(s), s);
}


/*----------------------

boolean save_sonderstring(SAVECACHE *cache, int16 fh, char *s) {
	int16 len;
	char *old;
	char c;
	if (!save_char(cache, fh, '\"')) return FALSE;
	do {
		old = s;
		len = 0;
		while ((c = *s) >= 32 && c != 127 && c != SONDERTRENNER && c != '\"') {
			s++;
			len++;
		}
		if (len) {
			if (!save_block(cache, fh, len, old)) return FALSE;
		}
		if (c) {
			if (!save_char(cache, fh, SONDERTRENNER)) return FALSE;
			if (c == SONDERTRENNER) {
				if (!save_char(cache, fh, SONDERTRENNER)) return FALSE;
			} else {
				if (!save_char(cache, fh, hexa[((unsigned char)c) >> 4])) return FALSE;
				if (!save_char(cache, fh, hexa[c & 0xF])) return FALSE;
			}
			s++;
		}
	} while (c);
	return save_char(cache, fh, '\"');
}

----------------------------*/


boolean save_string0(SAVECACHE *cache, int16 fh, char *s) {
	return save_block(cache, fh, strlen(s) + 1, s);
}

boolean save_crlf(SAVECACHE *cache, int16 fh) {
	return save_string(cache, fh, "\r\n");
}

boolean save_stringcrlf(SAVECACHE *cache, int16 fh, char *s) {
	if (!save_string(cache, fh, s)) return FALSE;
	return save_crlf(cache, fh);
}

boolean filesystem_grossklein(char *pfad) {	/* Liefert, ob das Filesystem Groû=Klein behandelt. (TRUE, wenn keine Infos) */
	int32 back = Dpathconf(pfad, 6);
	return (back != 0);
}

boolean filesystem_nurgross(char *pfad) {	/* Liefert, ob das Filesystem Groû=Klein behandelt und auch keinen Unterschied beim Erzeugen macht. (TRUE, wenn keine Infos) */
	int32 back = Dpathconf(pfad, 6);
	return (back < 0L || back == 1);
}

boolean filesystem_DOS(char *pfad) {	/* Liefert, ob das Filesystem 8+3 ist. (TRUE, wenn keine Infos) */
	int32 back = Dpathconf(pfad, 5);	/* KÅrzung */
	if (back == 2)
		return TRUE;						/* Ja, KÅrzung auf DOS (8+3) */
	back = Dpathconf(pfad, 3);			/* Maximale DateinamenlÑnge? */
	return (back <= 12L);
}

int32 filesystem_maxlen(char *pfad) {	/* Liefert maximale DateinamenlÑnge */
	int32 back = Dpathconf(pfad, 3);			/* Maximale DateinamenlÑnge? */
	if (back <= 0L)
		return 12L;
	return back;
}

/* Achtung: Belegt in app mehr als 9 Zeichen!!! (MAXDAT0!) */
void create_applfind_name(char *prg, char *app) {	/* Aus Programm (evtl. mit Pfad) einen 8-Zeichen-Namen fÅr appl_find machen */
	int16 len;
	char *ext;
	file_from_path(prg, app);
	ext = get_extender(app);
	if (ext)
		*ext = 0;
	app[8] = 0;
	str_upper(app);
	len = (int16)strlen(app);
	while (len < 8)
		app[len++] = ' ';
}

void Setze_Pfad(char *pfad) {
	int16 len = (int16)strlen(pfad);
	char path[MAXPATHDAT0];
	if (len < 3)
		return;
	strcpy(path, pfad);
	if (path[len - 1] != TRENNER)
		cut_last_dir(path, 0L);
	if (is_absolut(pfad)) {
		Dsetdrv(LW(path[0]));
		Dsetpath(path + 2);
	}
}

/* pfad mit TRENNER am Ende, maske ohne,
   masklen gibt maximale LÑnge bei Masken-RÅckgabe ab (0 = strlen der aktuellen)
   wenn masklen == -1, dann wird maske nicht verÑndert.
   RÅckgabe: énderung von pfad/maske/datei - jedoch nur bei OK!
*/
int16 fileselect(char *titel, char *pfad, char *maske, int16 masklen, char *datei, int16 *global) {
	char path[MAXPATHDAT0];
	char sel[MAXDAT0];
	
	int16 back, button;

	strcpy(path, pfad);
	strcat(path, maske);
	strcpy(sel, datei);

	wind_update(BEG_MCTRL, global);
	if (((global[0] >= 0x140) && (global[0] < 0x200)) || (global[0] >= 0x300))
		back = fsel_exinput(path, sel, &button, titel, global);
	else
		back = fsel_input(path, sel, &button, global);
	wind_update(END_MCTRL, global);

	if (back == 0)
		return FSEL_ERR;

	if (button == 1) {
		char *such = strrchr(path, TRENNER);
		if (!such) {
			*pfad = '\0';
		} else {
			*such = '\0';
			strcpy(pfad, path);
			trennerhin(pfad);

			if (masklen != -1) {
				if (masklen == 0)
					masklen = (int16)strlen(maske);
				strncpy(maske, such+1, masklen);
				maske[masklen] = '\0';
			}
		}
		strcpy(datei, sel);
	}
	return button;
}

boolean is_ordner(char *pfad) {
	int16 len = (int16)strlen(pfad);
	return (len && pfad[len-1] == TRENNER);
}

boolean is_absolut(char *pfad) {
	return (strlen(pfad) > 2 && pfad[1] == ':' && pfad[2] == TRENNER);
}

boolean is_root(char *pfad) {
	return (is_absolut(pfad) && pfad[3] == 0);
}

boolean is_dosname(char *datei) {
	char dat[MAXDAT0];
	char *ext;
	if (strchr(datei, ' '))		/* Keine Leerzeichen im Namen */
		return FALSE;
	strcpy(dat, datei);
	ext = get_extender(dat);
	if (ext) {
		if ((int16)strlen(ext) > 4)	/* Extender maximal 1+3 Zeichen */
			return FALSE;
		*ext = 0;
	}
	if ((int16)strlen(dat) > 8 || strchr(dat, '.'))	/* vorderer Teil max. 8 Zeichen und kein weiterer Punkt */
		return FALSE;
	return TRUE;
}

boolean is_dospath(char *pfad) {
	char tmp[MAXPATHDAT0];
	char dat[MAXDAT0];
	strcpy(tmp, pfad);
	while (cut_last_dir(tmp, dat)) {
		if (!is_dosname(dat))
			return FALSE;
	}
	return TRUE;
}

void file_time(DOSTIME *time, char *file) {
	int32 fh = Fopen(file, FO_READ);
	if (fh < 0L)
		return;
	Fdatime(time, (int16)fh, 0);
	Fclose((int16)fh);
}

#define PFABK ".."
#define PFABKLEN ((int16)sizeof(PFABK) - 1)
void pfad_abkuerzung(char *path, char *kurz, int16 maxlen, int16 cutfile) {
	char pfad[MAXPATHDAT0];
	strcpy(pfad, path);
	if (cutfile)
		cut_last_dir(pfad, 0L);

	if (maxlen <= PFABKLEN + 2) {
		strncpy(kurz, pfad, maxlen);
	} else {
		int16 len = (int16)strlen(pfad);
		if (len <= maxlen) {
			strcpy(kurz, pfad);
		} else {
			int16 vorne = (maxlen - PFABKLEN) / 2;
			int16 hinten = maxlen - PFABKLEN - vorne;
			if (vorne)
				strncpy(kurz, pfad, vorne);
			strcpy(kurz + vorne, PFABK);
			if (hinten)
				strncpy(kurz + vorne + PFABKLEN, pfad + len - hinten, hinten);
		}
	}
	kurz[maxlen] = 0;
}

extern void	my_critic(void);

int32 kill_critic(void) {
	return (int32)Setexc(0x101, my_critic);
}

void restore_critic(int32 old_critic) {
	Setexc(0x101, (void (*)())old_critic);
}

void environment_abkuerzung(char *pfad, char *ergebnis, int16 maxlen, HOME_ENV *suchinf, SYSINFO *sysinfo) {
	boolean ok;
	boolean dir = is_ordner(pfad);
	char result[MAXPATHDAT0];
	char *pos = pfad + strlen(pfad) - 2;
	char *first = strchr(pfad, TRENNER);

	strncpy(ergebnis, pfad, maxlen);
	ergebnis[maxlen] = 0;

	while (pos > pfad && pos > first) {
		if (*pos == TRENNER) {		/* Von rechts alle Trennstellen durchprobieren, ob Pfad gefunden wird */
			if (dir) {
				ok = folder_findhome(pos + 1, result, suchinf, sysinfo);
			} else {
				ok = file_findhome(pos + 1, result, suchinf, sysinfo);
				if (!ok) {
					char datei[MAXDAT0];
					char test[MAXPATHDAT0];
					strcpy(test, pos + 1);
					if (cut_last_dir(test, datei)) {
						ok = folder_findhome(test, result, suchinf, sysinfo);
						if (ok) {
							strcat(result, datei);
						}
					}
				}
			}
			if (ok && strcmp(pfad, result) == 0) {	/* Gleicher Pfad aus Environment gefunden! */
				strncpy(ergebnis, pos + 1, maxlen);	/* GekÅrzte Form eintragen! */
				break;
			}
		}
		pos--;
	}
	ergebnis[maxlen] = 0;
}
