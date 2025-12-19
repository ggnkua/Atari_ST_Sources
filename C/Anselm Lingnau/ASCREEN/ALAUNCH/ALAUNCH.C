/** ALAUNCH.C --- ASCREEN-Startprogramm f"ur MultiGEM
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**" Dieses Programm kann f"ur Dateien mit der Endung DVI angemeldet
**" werden. Es startet ASCREEN mit der betreffenden Datei. Wenn
**" bereits ein ASCREEN l"auft, bekommt er die Message geschickt,
**" die Datei einzulesen und darzustellen.
**"
**" Anselm Lingnau, 24. Oktober 1992 (Turbo-C)
**"
**" Dies ist ein Public-Domain-Programm. Stellen Sie damit an, was
**" Sie wollen.
*/
#include <stdlib.h>
#include <string.h>
#include <aes.h>

#include "ascrmsgs.h"

/*" Dank der Parameter"ubergabe in Registern durch Turbo-C brauchen
**" wir ein 'richtiges' Binding in Assembler. Grr.
*/
extern long Mfork(const char *file, const char *arg);

#define app_count	(_GemParBlk.global[1])
#define MAX_CMDLINE	128

/*" Diese Prozedur startet ASCREEN, falls das Programm noch nicht
**" l"auft.
*/
	void
launch_ascreen (const char *file)
{
	char	*env;
	char	cmdline[MAX_CMDLINE] = " &D:\\TEX\\ASCREEN.SET ";

	if (app_count > 1) {
		if ((env = getenv("ASCREENSET")) != 0) {
			strcpy(cmdline + 2, env);
			strcat(cmdline + 1, " ");
		}
		strcat(cmdline + 1, file);
		cmdline[0] = (char)strlen(cmdline + 1);
/*		shel_write(1, 1, 1, "", cmdline);*/
		if (Mfork("D:\\TEX\\ASCREEN.PRG", cmdline) < 0) {
			(void)form_alert(1, "[3][Konnte ASCREEN|"
						"nicht starten]"
						"[Abbruch]");
		}
	} else {
		(void)form_alert(1, "[3][Nur eine Applikation|"
					"m”glich (kein MultiGEM?)]"
					"[Abbruch]");
	}
}

/*" Falls ein laufender ASCREEN gefunden wurde, schicken wir ihm
**" hier die Nachricht, eine neue Datei einzulesen.
*/
	void
send_message (const int from, const int to, const char *file)
{
	int	size;
	char	msg[8 + MAX_CMDLINE];
#define PUT_WORD(a, i, v) a[i] = (v) >> 8, a[i+1] = (v) & 0xff

	strcpy(msg + 8, file);
	size = 8 + (int)strlen(msg + 8) + 1;
	if (size < 16) size = 16;

	PUT_WORD(msg, 0, MSG_ASCREEN);
	PUT_WORD(msg, 2, from);
	PUT_WORD(msg, 4, size - 16);
	PUT_WORD(msg, 6, MSG_READ);
	if (appl_write(to, size, msg) == 0)
		(void)form_alert(1, "[1][Fehler beim Schicken|"
					"der Nachricht!][Abbruch]");
}

/*" Im Hauptprogramm pr"ufen wir, ob ein ASCREEN l"auft, und springen
**" dann entweder in die Routine zum Starten oder die zum Verschicken
**" einer Message.
*/
	int
main (int argc, char **argv)
{
	int app_id, id;

	if ((app_id = appl_init()) >= 0) {
		if (argc >= 2) {
			if ((id = appl_find("ASCREEN ")) < 0)
				(void)form_alert(1, "[1][Fehler beim|"
					"Suchen von ASCREEN][Abbruch]");
			else if (id <= app_count)
				send_message(app_id, id, argv[1]);
			else
				launch_ascreen(argv[1]);
		} else {
			(void)form_alert(1, "[1][Kein Dateiname|"
					     "angegeben!][Abbruch]");
		}
		appl_exit();
	}
	return 0;
}
