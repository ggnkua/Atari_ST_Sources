#line 1/*ACE 4 0145 */
/*
 * Dieser Quelltext stammt ursprÅnglich von Dirk Haun und
 * wurde angepaût und erweitert von Holger Weets
 */
#ifdef SOZOBON
#include <gemfast.h>
#include <errno.h>

/*
 * AV-Meldungen
 */
#define AV_PROTOKOLL        0x4700
#define AV_SENDKEY          0x4710
#define VA_START            0x4711
#define AV_STARTPROG        0x4722
#define VA_PROGSTART        0x4723
#define AV_ACCWINDOPEN      0x4724
#define VA_DRAGACCWIND      0x4725
#define AV_ACCWINDCLOSED    0x4726
#define  Pexec(mode,prog,tail,env) gemdos(75,mode,prog,tail,env)

extern int _argc;
extern char **_argv;
_main()
{
	_exit(main(_argc, _argv));
}
#else
/* Pure-C */
#include <aes.h>
#include <tos.h>
#include <errors.h>
#include <vaproto.h>
#endif


int main(argc, argv)
int argc;
char **argv;
{
	int event, viewer, gl_apid, open, msg[8];
	int ret;
	int d, buf[8];
	char cmd[150], *p;

start:
	ret=0;
	if (argc==2) {
		if ((gl_apid=appl_init())<0)
			return(ENSMEM);

		/*
		 * ACC suchen: ST-Guide, 1stGuide und 1stView in dieser
		 * Reihenfolge
		 */
		viewer=appl_find("ST-GUIDE");
		if (viewer<0) viewer=appl_find("1STGUIDE");
		if (viewer<0) viewer=appl_find("1STVIEW ");
		if (viewer<0)
			ret=EFILNF;                     // kein ACC vorhanden
		else {

			/*
			 * Meldung fÅr ACC basteln
			 */
			msg[0]=VA_START;
			msg[1]=gl_apid;
			msg[2]=0;
			*(char **)&msg[3] = argv[1];    // Kommando
			msg[5]=0; msg[6]=0; msg[7]=0;

			/*
			 * ACC aktivieren
			 */
			appl_write(viewer,16,msg);

			/*
			 * warten, bis ACC geîffnet, oder Timeout
			 */
			do {
				event = evnt_multi(MU_TIMER|MU_MESAG,
									0, 0, 0,
									0,0,0,0,0,
									0,0,0,0,0,
									buf, 2000, 0,
									&d, &d, &d, &d, &d, &d);
				if (event & MU_TIMER) break;
			} while (buf[0] != AV_ACCWINDOPEN);

			/*
			 * wenn Timeout, dann haben wir
			 * hier nichts mehr zu tun
			 */
			if (event & MU_TIMER)
				ret=EFILNF;
			else {

				/*
				 * ACC ist jetzt offen. Also mitzÑhlen, wieviele
				 * seiner Fenster noch geîffnet sind, und abbrechen,
				 * sobald das letzte geschlossen wird
				 */
				open=1;
				do {
					event = evnt_multi(MU_MESAG,
										0, 0, 0,
										0,0,0,0,0,
										0,0,0,0,0,
										buf, 0, 0,
										&d, &d, &d, &d, &d, &d);
					if (event & MU_MESAG) {
						if (buf[0] == AV_ACCWINDCLOSED)
							/* ein Fenster weniger */
							open--;
						else if (buf[0] == AV_ACCWINDOPEN)
							/* ein Fenster mehr */
							open++;
						else if (buf[0] == AV_STARTPROG) {
							/*
							 * Programm sol gestartet werden:
							 *
							 * Kommandozeile fÅr Programmaufruf
							 * zurechtmachen
							 */
							p = *(char **)&buf[5];
							if (p) {
								strcpy(cmd+1, p);
								*cmd = strlen(p);
							}
							else {
								*cmd = 0;
							}
							/*
							 * Hier mÅûte eigentlich noch getestet werden,
							 * ob wir es mit einer TOS- oder GEM- Appl.
							 * zu tun haben...
							 */
							shel_write(1, 1, 1, *(char **)&buf[3], cmd);
							open = 0;

							/*
							 * dieses gefiele mir besser,
							 * lÑuft aber bei mir nicht
							 * (ACC wird nicht geschlossen)
							 * WIESO?
							 */
#                           if 0
								appl_exit();
								ret = Pexec(0, *(char **)&buf[3],
											cmd,
											0L);
								return(ret);
#                           endif
						}
					}
				} while (open>0);
			}
		}
		appl_exit();
	}
	else
		ret=ENMFIL;
	return(ret);
}
