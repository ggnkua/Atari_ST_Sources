/* zooshell.c fuer ZOOSHELL.TTP 1.1.89  stefan brueck 
 *
 * verwendeter Compiler: SOZOBON mit DLibs 1.2
 *
 * ein miniprogramm zum aufruf von zoo.ttp vom desktop aus mit
 *	+ langer kommandozeile (124 zeichen) statt den paar zeichen in
 *	  der zwergendialogbox von GEM (tm)
 *	+ wartet an ende das programms auf einen tastendruck, damit
 *	  die zoomeldungen wenigstens betrachtet werden koennen.
 *	+ eingabe- und ausgabeumleitung mit '<' und '>' sind moeglich
 *	+ bei uebergabe eines Pfades koennen die Aus- und Eingaben fuer
 *	  das zu startende Programm umgeleitet werden --- sollte hier
 *	  der anfang eines kommandlineinterpreters schlummern?
 *	- nicht moeglich ist ein <more> der ausgabe, das kann dieser
 *	  "einzeiler" nicht leisten.
 *	- nicht moeglich ist ein piping der ausgabe nach MASTER 5.x oder GULAM
 *	  vorbild.
 *
 * zooshell ist public domain und sollte mit source weitergegeben werden.
 * ueber verbesserungs- oder erweiterungsvorschlaege wuerde ich mich freuen.
 */

#include <stdio.h>
#include <osbind.h>

#define DEFAULT_PATH	"ZOO.TTP"
#define DEBUG

char buffer[256];
char pfad[128];

main(argc, argv)
int argc;
char *argv[];
{
	int status, buffer_len;
	short stdout_handle, stdin_handle;
	char *bp, *fname;
	short saved_stdin  = 1234;	/* "memonumber" */
	short saved_stdout = 1234;	/* "memonumber" */
	extern char *parse_io_redirection();

	/*
	 *	nachsehen, wie der auf welchem Pfad ZOO.TTP steht
	 *	bei uebergabe vom entsprechenden Pfad kann auch die 
	 *  ausgabe von FNAMS, BOOZ oder FIZ umgeleitet werden!
	 */

	if (argc == 2)
		strcpy(pfad, argv[1]);
	else
		strcpy(pfad, DEFAULT_PATH);

	/*
	 *	eine minianleitung ausgeben
	 */
	Cconws("ZOOshell v1.0 sb\r\n\r\n");
	Cconws("Experte  : zoo {acDehlLPTuUvx} [bcdEfInMNoOpPquv1:./@] ");
	Cconws("Archive [Datei-1 ... ]\r\n\t\t[<Eingabedatei] [>Ausgabedatei]\r\n");
	Cconws("Anfaenger: zoo -Kommando Archiv [Datei-1 ... ]\r\n");
	Cconws("(Kommandos sind hierbei:\r\n");
	Cconws("-add -extract -move -test -print -delete -list -update ");
	Cconws("-freshen -comment)\r\n");
	Cconws("Hilfe    : zoo h\r\n\r\n");
	Cconws("Bei Aufruf mit Pfadangabe sind je nach Pfad moeglich:\r\n");
	Cconws("Fnams    : fnams pfad\ [>ausgabedatei]\r\n");
	Cconws("Booz     : booz {ltx} Archiv [Datei-1 ...] [>Ausgabedatei]\r\n");
	Cconws("Fiz      : fiz Archiv [>Ausgabedatei]\r\n");
	Cconws("\r\nAnhalten/Weiterschalten der Bildschirmausgabe mit ");
	Cconws("CONTROL-S/CONTROL-Q\r\n\r\n\r\n");

	/*
	 *	die kommandozeile fuer zoo einlesen
	 */
	Cconws(pfad);					/* ein kleiner prompt 	*/
	Cconout(' ');
	
	buffer[0] = (char) 124;			/* maximal erlaubt		*/
	Cconrs(buffer);
	buffer[1] = ' ';   		/* anzahl der eingegebenen zeichen loeschen */
	Cconws("\033E");				/* optik				*/

	/*
	 *	eine vorgegebene ein/ausgabe umleitung einrichten
	 *				vorsicht glatteis
	 */

	/*
	 *	vor der eingabeumleitung duerfen bei GNU CC keine
	 *	eingaben mit gets,fgets gemacht werden. falls doch
	 *	wird von der console eingelesen! noch schlimmer ist 
	 *	das bei fread(stdin), hier wird ueberhaupt nix ein-
	 *	gelesen. das haengt wohl noch an der library vom GNU 
	 *	CC und da bin ich noch am wurschteln. 
	 *
	 *	mit dem SOZOBON C Compiler und den dLibs 1.2 klappt
	 *	aber dieses programm.
	 */

	if ((fname = parse_io_redirection(&buffer[1],'<')) != NULL) 
 	{
		stdin_handle = (short) Fopen(fname,0);
		if (stdin_handle > -33)
		{
			saved_stdin = Fdup(fileno(stdin));
			if (Fforce(fileno(stdin),stdin_handle) < 0)
			{
				fprintf(stderr,"Fehler bei der Eingabeumlenkung\n");
			}
		}
	}

	if ((fname = parse_io_redirection(&buffer[1],'>')) != NULL)
	{
		if ((stdout_handle = (short) Fopen(fname,1)) <= -33)
			stdout_handle = (short) Fcreate(fname,0);
		if (stdout_handle > -33)
		{
			saved_stdout = Fdup(fileno(stdout));
			if (Fforce(fileno(stdout),stdout_handle) < 0)
			{
				fprintf(stderr,"Fehler bei der Ausgabeumlenkung\n");
			}
		}
	}

	/*
	 *	die kommandozeile fuer zoo.ttp vorbereiten
	 *	format:
	 *	byte = laenge des folgenden strings OHNE abschliessendes CR
	 *	laenge * byte = string
	 *	byte = CR
	 *	byte = '\0'
	 */

	buffer_len = strlen(&buffer[2]);
	bp = &buffer[1] + buffer_len;
	while((*bp == ' ') && buffer_len)
	{
		*bp-- = '\0';
		buffer_len--;
	}

	buffer[1] = (char) buffer_len;
	strcat(&buffer[2],"\r");

	/*
	 *	yeah - do it!
	 */

	status = (int) Pexec(0, pfad, &buffer[1], "");

	/*
	 *	die ein- und ausgabeumleitung wieder aufheben
	 */

	if (saved_stdin != 1234)
	{
			Fforce(fileno(stdin),saved_stdin);
			if (!isatty(stdin_handle))
				Fclose(stdin_handle);
	}
	if (saved_stdout != 1234)
	{
			Fforce(fileno(stdout),saved_stdout);
			if (!isatty(stdout_handle))
				Fclose(stdout_handle);
	}

	switch (status) {
		case -33: strcpy(buffer, "FEHLER: ");
			  strcat(buffer, pfad);
			  strcat(buffer, " nicht gefunden\r\n");
			  Cconws(buffer);
			  break;
		case -39: Cconws("FEHLER: Zuwenig Speicher vorhanden\r\n"); 
			  break;
		default:  break;
	}

	Cconws("--- weiter zum Desktop ---");
	Bconin(2);
	exit(status);	/* schliessen aller Dateien und tschuess */
}

