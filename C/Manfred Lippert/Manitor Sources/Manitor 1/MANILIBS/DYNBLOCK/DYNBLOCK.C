#include <i:\c\fremde\manitor\manilibs\dynblock\dynblock.h>
#include <string.h>


void xdyn_init(DYN_BLOCK *dyn, int16 xmode, SYSINFO *info) {
	dyn->adr = 0L;
	dyn->len = 0L;
	dyn->xmode = xmode;
	dyn->info = info;
}

void dyn_free(DYN_BLOCK *dyn) {
	if (dyn->adr) {
		xfree(dyn->adr, dyn->xmode);
		dyn->adr = 0L;
		dyn->len = 0L;
	}
}

boolean dyn_add_len(DYN_BLOCK *dyn, int32 len) {
	if (len) {
		if (!dyn->adr) {
			dyn->alloclen = len + DYN_VORAUS;
			if ((dyn->adr = xalloc(dyn->alloclen, dyn->xmode, dyn->info)) == 0L) {
				return FALSE;
			}
		}
		if (dyn->alloclen < dyn->len + len) {
			long newsize = dyn->len + len + DYN_VORAUS;
			void *new = xalloc(newsize, dyn->xmode, dyn->info);
			if (!new) {
				newsize = dyn->len + len;
				new = xalloc(newsize, dyn->xmode, dyn->info);
				if (!new) {
					return FALSE;
				}
			}
			memcpy(new, dyn->adr, dyn->len);
			xfree(dyn->adr, dyn->xmode);
			dyn->adr = new;
			dyn->alloclen = newsize;
		}
		dyn->len += len;
	}
	return TRUE;
}

boolean dyn_add_block(DYN_BLOCK *dyn, void *adr, long len) {
	if (len) {
		long oldlen = dyn->len;
		if (!dyn_add_len(dyn, len)) {
			return FALSE;
		}
		memcpy((char *)dyn->adr + oldlen, adr, len);
	}
	return TRUE;
}

boolean dyn_add_string(DYN_BLOCK *dyn, char *adr) {		/* ohne Nullbyte! */
	long len = strlen(adr);
	return dyn_add_block(dyn, adr, len);
}

boolean dyn_add_string0(DYN_BLOCK *dyn, char *adr) {		/* mit Nullbyte! */
	long len = strlen(adr);
	return dyn_add_block(dyn, adr, len + 1);
}

boolean dyn_add_string00(DYN_BLOCK *dyn, char *adr) {		/* mit zwei Nullbytes! */
	long len = strlen(adr);
	return (dyn_add_block(dyn, adr, len + 1) && dyn_add_null(dyn));
}

boolean dyn_add_null(DYN_BLOCK *dyn) {						/* HÑngt Nullbyte an */
	char null = 0;
	return dyn_add_block(dyn, &null, 1L);
}

boolean dyn_add_crlf(DYN_BLOCK *dyn) {						/* HÑngt CR/LF an */
	return dyn_add_block(dyn, "\r\n", 2L);
}

boolean dyn_add_line(DYN_BLOCK *dyn, char *adr) {	/* HÑngt String+CRLF an - Achtung bei Fehler kann's schon teilweise geschrieben sein! (ohne CRLF) */
	if (!dyn_add_string(dyn, adr)) {
		return FALSE;
	}
	return dyn_add_crlf(dyn);
}

boolean dyn_add_string_evtl_quoted(DYN_BLOCK *dyn, char *s, boolean *leer_flag) {
	if (strchr(s, ' ') || strchr(s, '\'')) {		/* muû gequotet werden? */
		if (leer_flag) {
			*leer_flag = TRUE;							/* Leerzeichen-Flag setzen */
		}
		if (!dyn_add_string(dyn, "\'")) {			/* Anfangsquote */
			return FALSE;
		}
		while (*s) {
			if (!dyn_add_block(dyn, s, 1L)) {
				return FALSE;
			}
			if (*s == '\'') {
				if (!dyn_add_block(dyn, s, 1L)) {	/* Quotes doppeln */
					return FALSE;
				}
			}
			s++;
		}
		return dyn_add_string(dyn, "\'");			/* Endquote */
	}
	return dyn_add_string(dyn, s);
}

boolean dyn_kill_last(DYN_BLOCK *dyn) {
	char *pos;

	if (!dyn->adr) {
		return FALSE;
	}
		
	pos = (char *)dyn->adr + dyn->len - 1;
	while (pos > dyn->adr && *pos == 0) {
		pos--;
	}
	while (pos > dyn->adr && *pos) {
		pos--;
	}
	if (pos > dyn->adr) {
		pos[1] = 0;				/* Neuer Abschluû */
		dyn->len = (char *)dyn->adr - pos + 2;
	} else {						/* Nicht mal Platz fÅr einen Parameter... */
		dyn_free(dyn);
		return FALSE;
	}
	return TRUE;
}
