/*----------------------------------------------------------------------------------------
	Cookie.c, handling TOS cookies
	
	?.?.1999 by Manfred Lippert, mani@mani.de

	last change: 13.9.2000
----------------------------------------------------------------------------------------*/

#include <Cookie.h>
#include <bios.h>
#include <gemdos.h>

bool get_cookie(int32 cookie, int32 *wert) {
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

bool set_cookie(int32 key, int32 value) {
	int32 *cookiejar = (int32 *)Setexc(0x5A0/4, (void (*)())-1);
	if (!cookiejar) {
		return FALSE;
	}
	while (cookiejar[0]) {
		if (cookiejar[0] == key) {
			cookiejar[1] = value;
			return TRUE;
		}
		cookiejar += 2;
	}
	return FALSE;
}

/* Should not be used in applications! */
int16 install_cookie(int32 key, int32 value) {
	COOKIE *ptr = (COOKIE *)Setexc(0x5A0/4, (void (*)())-1);	/* Zeiger auf Cookie-Jar */
	int anz = 1;	/* Nullcookie zŠhl ich besser mal mit... */
	if (!ptr) {
		return ERRCOOKIE_NOJAR;
	}
	while (ptr->key) {
		if (ptr->key == key) {			/* schon installiert? */
			return ERRCOOKIE_ALREADYINSTALLED;
		}
		anz++;
		ptr++;
	}
	if (ptr->value <= anz) {
		return ERRCOOKIE_NOSPACE;
	}
	ptr[1].key = 0L;					/* Neuer Nullcookie dahinter */
	ptr[1].value = ptr->value;			/* Mit gleicher Maximalanzahl */
	ptr->key = key;
	ptr->value = value;
	return ERRCOOKIE_OK;
}

void deinstall_cookie(int32 key) {
	bool found = FALSE;
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
