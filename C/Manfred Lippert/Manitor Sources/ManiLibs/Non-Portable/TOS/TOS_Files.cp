/*----------------------------------------------------------------------------------------
	TOS_Files.cp, non-portable TOS file routines
	
	15.6.2001 by Manfred Lippert, mani@mani.de

	last change: 15.6.2001
----------------------------------------------------------------------------------------*/

#include <TOS_Files.h>
#include <FileSystem.h>
#include <string.h>

void TOS_current_path(char *path) {
	int16 drv = Dgetdrv();
	path[0] = (char)('A' + (char)drv);
	path[1] = ':';
	path[2] = FSYS_PATH_DELIMITER;
	path[3] = 0;
	Dgetpath(path + 3, drv + 1);
	if (path[3] == FSYS_PATH_DELIMITER) {
		strcpy(path + 2, path + 3);
	}
	TOS_trennerhin(path);
}

void TOS_trennerhin(char *dat) {
	int16 len = (int16)strlen(dat);
	if (len && dat[len - 1] != FSYS_PATH_DELIMITER) {
		dat[len] = FSYS_PATH_DELIMITER;
		dat[len+1] = 0;
	}
}

boolean TOS_trennerweg(char *dat) {
	boolean was_trenner = FALSE;
	int16 len = (int16)strlen(dat);
	while (len-- && dat[len] == FSYS_PATH_DELIMITER) {
		dat[len] = 0;
		was_trenner = TRUE;
	}
	return was_trenner;
}

char *TOS_get_last_dir(char *pfad) {
	boolean trenner = TOS_trennerweg(pfad);
	char *pos = strrchr(pfad, FSYS_PATH_DELIMITER);
	if (pos) {
		pos++;	/* Hinter Trenner */
	}
	if (trenner) {
		TOS_trennerhin(pfad);
	}
	return pos;
}

/* letztes Directory vom Pfad abschneiden (Trenner bleibt dran), liefert TRUE, wenn abgeschnitten wurde */
/* Falls file != 0L, wird letztes Dir reingeschrieben (nur bei Erfolg!) */
boolean TOS_cut_last_dir(char *pfad, char *file) {
	char *pos = TOS_get_last_dir(pfad);
	if (!pos) {
		return FALSE;
	}
	if (file) {
		char last[MAXPATH0];
		strcpy(last, pos);
		TOS_trennerweg(last);
		strcpy(file, last);
	}
	if (file != pfad) {
		*pos = 0;
	}
	return TRUE;
}
