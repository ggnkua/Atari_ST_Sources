#include "manitor.h"
#include "..\toslib\aes\aes.h"
#include <string.h>
#include <stdlib.h>
#include "gscript.h"

char filename[128] = DEFAULT_FILENAME;
int log_handle;
char laufwerk_offen;

long want_bufsize = DEFAULT_BUFSIZE;
long bufsize;
char *buf;
char *bufsaveptr;
long bufsaverest;
char *bufptr;
long bufrest;

int init_buffer(void)
{
	long back;
	if (!pending) {
		bufsize = want_bufsize;
		buf = Malloc(bufsize);
		if (!buf)
			return FALSE;
		bufsaveptr = buf;
		bufsaverest = bufsize;
		bufptr = buf;
		bufrest = bufsize;
	}
	back = Fcreate(filename, 0);
	if (back < 0L && !pending) {
		Mfree(buf);
		buf = 0L;
		return 0;
	}
	log_handle = (int)back;
	laufwerk_offen = filename[0];

	clear_returncodes();	/* Evtl. aus "Pending" noch anstehende Returncodes l”schen */
	return TRUE;
}

/* fillbuf wrde ber noch zu speichernde Daten (bufsaveptr) drberschreiben! */
/* bufsaveptr muž > bufptr sein, Ausnahme: bufsaveptr == buf */
void fillbuf_overflow(void)
{
	long offset = bufsaveptr - bufptr;
	if (offset < 0L)	/* Kommt nur bei bufsaveptr == buf vor */
		offset += bufsize;
	if (offset > OVERSIZE) {	/* Overflow-Meldung pažt noch "rein" */
		memcpy(bufptr, OVERFLOW, OVERSIZE);
		bufrest -= OVERSIZE;
		bufptr += OVERSIZE;
	} else {
		char *neuptr = bufsaveptr - OVERSIZE - 1;	/* Hier mžte OVERFLOW-Text anfangen */
		offset = buf - neuptr;
		if (offset > 0L) {	/* Steht links raus? */
			memcpy(buf + bufsize - offset, OVERFLOW, offset);
			if (OVERSIZE - offset > 0L)
				memcpy(buf, OVERFLOW + offset, OVERSIZE - offset);
		} else {
			memcpy(neuptr, OVERFLOW, OVERSIZE);
		}
		bufptr = neuptr + OVERSIZE;
		if (bufptr < buf)
			bufptr += bufsize;
		bufrest = bufsize - (bufptr - buf);
	}
}

void fillbuf(char *data, unsigned long len)
{
	if (len) {
		while (len >= bufrest) {
			if (bufsaveptr > bufptr || bufsaveptr == buf) {	/* Fllzeiger darf Schreibzeiger nie einholen! */
				fillbuf_overflow();
				return;
			}
			memcpy(bufptr, data, bufrest);
			data += bufrest;
			len -= bufrest;
			bufptr = buf;
			bufrest = bufsize;
		}
		if (len) {
			char *neuptr = bufptr + len;
			if (bufsaveptr > bufptr && bufsaveptr <= neuptr) { /* Fllzeiger darf Schreibzeiger nie einholen! */
				fillbuf_overflow();
				return;
			}
			memcpy(bufptr, data, len);
			bufrest -= len;
			bufptr = neuptr;
		}
	}
}

void fillbuf_string(char *s)
{
	fillbuf(s, strlen(s));
}

void fillbuf_maxstring(char *s, int maxlen)
{
	int len = 0;
	char *tst = s;
	while (*tst++ && len < maxlen)
		len++;
	fillbuf(s, len);
}

void fillbuf_para(char *s)
{
	if (s && *s) {
		fillbuf_string(s);
		fillbuf(" = ", 3);
	}
}

void fillbuf_quote(char *str)
{
	if (!str) {
		fillbuf("<NULL>", 6);
	} else if ((long)str < 0L) {
		char nr[12];
		fillbuf("<", 1);
		ltoa((long)str, nr, 10);
		fillbuf_string(nr);
		fillbuf(">", 1);
	} else {
		fillbuf("¯", 1);
		fillbuf_string(str);
		fillbuf("®", 1);
	}
}

void fillbuf_envquote(char *str)
{
	if (!str) {
		fillbuf("<NULL>", 6);
	} else if ((long)str < 0L) {
		char nr[12];
		fillbuf("<", 1);
		ltoa((long)str, nr, 10);
		fillbuf_string(nr);
		fillbuf(">", 1);
	} else {
		fillbuf("¯", 1);
		while (*str) {
			fillbuf_string(str);
			str += strlen(str) + 1;
			if (*str)
				fillbuf("\\0", 2);
		}
		fillbuf("®", 1);
	}
}

void fillbuf_pexecquote(char *str)
{
	char nr[12];
	if (!str) {
		fillbuf("<NULL>", 6);
	} else if ((long)str < 0L) {
		fillbuf("<", 1);
		ltoa((long)str, nr, 10);
		fillbuf_string(nr);
		fillbuf(">", 1);
	} else {
		int len = (int)*(unsigned char *)str++;
		itoa(len, nr, 10);
		fillbuf_string(nr);
		fillbuf(":¯", 2);
		if (len == 254) {
			while (*str) {
				fillbuf_string(str);
				str += strlen(str) + 1;
				if (*str)
					fillbuf("\\0", 2);
			}
		} else {
			fillbuf_string(str);
		}
		fillbuf("®", 1);
	}
}

void fillbuf_crlf(void)
{
	fillbuf("\r\n", 2);
}

void fillbuf_prg(int aesid, char *prc_name, char *app_name, int size)
{
	int len;
	if (prc_name && *prc_name) {
		fillbuf("[", 1);
		fillbuf_string(prc_name);
		len = 2 + (int)strlen(prc_name);	/* "]" mitgez„hlt */
	} else {
		fillbuf("[<???>", 6);
		len = 7;							/* "]" mitgez„hlt */
	}
	if (aesid >= 0) {
		char nr[8];
		itoa(aesid, nr, 10);
		fillbuf(" ", 1);
		fillbuf_string(nr);
		fillbuf(" ", 1);
		len += 2 + (int)strlen(nr);
		if (app_name && *app_name) {
			fillbuf_string(app_name);
			len += (int)strlen(app_name);
		} else {
			fillbuf("<???>", 5);
			len += 5;
		}
	}
	fillbuf("]", 1);
	if (size && len < size) {
		fillbuf(SIZE_MAX_STR, size - len);
	}
}

void fillbuf_aes(int aesid, char *app_name)
{
	char nr[8];
	itoa(aesid, nr, 10);
	fillbuf("[", 1);
	fillbuf_string(nr);
	fillbuf(" ", 1);
	if (app_name && *app_name) {
		fillbuf_string(app_name);
	} else {
		fillbuf("<???>", 5);
	}
	fillbuf("]", 1);
}

void update_buffer(void)
{
	char *local_bufptr = bufptr;	/* Da st„ndig ge„ndert! */
	if (bufsaveptr > local_bufptr) {
		Fwrite(log_handle, bufsaverest, bufsaveptr);
		bufsaveptr = buf;
		bufsaverest = bufsize;
	}
	{
		long len = local_bufptr - bufsaveptr;
		if (len > 0L) {
			Fwrite(log_handle, len, bufsaveptr);
			bufsaverest -= len;
			bufsaveptr += len;
		}
	}
}

void deinit_buffer(int except)
{
	update_buffer();
	Fclose(log_handle);
	if (!except) {
		int16 msg[8];

		msg[0] = SH_WDRAW;
		msg[3] = (int)laufwerk_offen - 'A';
		*(long *)&msg[4] = 0L;
		*(long *)&msg[6] = 0L;
		my_appl_write(0, msg);
	}
}

void free_buffer(void)
{
	if (buf)
		Mfree(buf);
	buf = 0L;
}
