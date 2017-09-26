#include "cookie.h"

#include <mgx_dos.h>

int get_cookie(int32 cookie, int32 *wert) {
	int32 *cookiejar = (int32 *)Setexc(0x5A0/4, (void (*)())-1);
	if (!cookiejar) {
		return FALSE;
	}
	while (cookiejar[0]) {
		if (cookiejar[0] == cookie) {
			if (wert) {
				*wert = cookiejar[1];
			}
			return TRUE;
		}
		cookiejar += 2;
	}
	return FALSE;
}

int16 install_cookie(long key, long value) {
	COOKIE *ptr = (COOKIE *)Setexc(0x5A0/4, (void (*)())-1);	/* Zeiger auf Cookie-Jar */
	int anz = 1;	/* Nullcookie z„hl ich besser mal mit... */
	if (!ptr) {
		return ERRCOOKIE_NOJAR;
	}
	while (ptr->key) {
		if (ptr->key == key) {		/* schon installiert? */
			return ERRCOOKIE_ALREADYINSTALLED;
		}
		anz++;
		ptr++;
	}
	if (ptr->value <= anz) {
		return ERRCOOKIE_NOSPACE;
	}
	ptr[1].key = 0L;						/* Neuer Nullcookie dahinter */
	ptr[1].value = ptr->value;			/* Mit gleicher Maximalanzahl */
	ptr->key = key;
	ptr->value = value;
	return ERRCOOKIE_OK;
}

void deinstall_cookie(int32 key) {
	boolean found = FALSE;
	COOKIE *ptr = (COOKIE *)Setexc(0x5A0/4, (void (*)())-1);	/* Zeiger auf Cookie-Jar */
	if (!ptr) {
		return;	/* Kein Cookie-Jar */
	}
	while (ptr->key) {
		if (ptr->key == key) {
			found = TRUE;
		}
		if (found) {
			*ptr = *(ptr + 1);
		}
		ptr++;
	}
}
