/*
 * ramutil.c vom 16.07.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * EnthÑlt die Hilfsroutinen des Ramdisk-XFS fÅr MagiC (also solche,
 * die nicht direkt von der XFS-Schnittstelle angesprungen werden).
 *
 * History:
 * 30.12.1995: Erstellung.
 *             In work_entry wird das x-Flag jetzt nicht mehr geprÅft,
 *             in findfile nur noch dann, wenn nicht das Verzeichnis
 *             selbst gesucht ist.
 * 31.12.1995: Neue Funktion "increase_refcnts", nÑheres in ramdisk.c
 * 01.01.1996: Wird work_entry NULL fÅr action Åbergeben, liefert es
 *             EINVFN sobald der Test auf einen symbolischen Link
 *             nicht erfolgreich war.
 * 02.01.1996: In prepare_dir wird jetzt fÅr die Blockgrîûe des
 *             Wurzelverzeichnisses eine Null eingetragen.
 * 03.01.1996: get_and_set_drive sucht jetzt bis Laufwerk Z.
 * 20.01.1996: SÑmliche static-chars innerhalb von Funktionen durch
 *             per int_malloc angeforderte ersetzt. Damit ist die
 *             Ramdisk jetzt voll reentrant.
 * 05.02.1996: findfile sucht im Modus FF_EXIST nur noch dann mit
 *             TOS-gestutzten bzw. caseinsensitiven Filenamen weiter,
 *             wenn die TOS-Domain aktiv ist.
 * 10.02.-
 * 12.02.1996: WeiterfÅhrung der Kommentierung.
 * 12.02.1996: Kmalloc prÅft jetzt, ob der grîûte Speicherblock minus
 *             der gewÅnschten Anzahl Bytes noch groû genug ist
 *             (bisher fehlte das Minus...)
 * 13.02.1996: Anpassung an den neuen Prototyp von install_xfs (siehe
 *             pc_xfs.h)
 * 14.02.1996: Auswertung der Infodatei begonnen.
 * 16.02.1996: Auswertung fertiggestellt.
 * 17.02.1996: Neues Kommando fÅr die Infodatei: 8bit, legt fest, ob
 *             in Filenamen ASCII-Zeichen > 127 erlaubt sind. DafÅr
 *             muûte natÅrlich auch check_name angepaût werden.
 *             Die Debug-Version unterstÅtzt jetzt zusÑtzlich die
 *             Kommandos logfile und logbackup in der Infodatei.
 *             findfile nochmal Åberarbeitet.
 * 19.02.1996: Kmalloc verbessert: Erst wird versucht, einen Block
 *             der gewÅnschten Grîûe anzufordern. Klappt das nicht,
 *             ist Schluû. Ansonsten wird jetzt geprÅft, ob sich die
 *             Lange des grîûten noch freien Speicherblocks geÑndert
 *             hat. Falls nicht, wird der Block so als Ergebnis
 *             geliefert. Im anderen Fall wird der Block wieder
 *             freigegeben, wenn der neue Wert kleiner als der
 *             Mindestwert ist. Auf diese Weise kann die Ramdisk auch
 *             bei stark fragmentiertem Speicher noch neue Daten
 *             aufnehmen.
 * 26.02.1996: Die Funktion readline stark beschleunigt, auûerdem
 *             wird jetzt kein Linefeed bei der letzten Zeile mehr
 *             benîtigt.
 *             Neues Kommando fÅr die INF-Datei: label, zum Festlegen
 *             des Volume Labels.
 *             Einschaltmeldung korrigiert.
 * 23.04.1996: Beim Start wird jetzt erstmal der MagX-Cookie geprÅft.
 * 02.06.1996: Kmalloc belegt jetzt nach Mîglichkeit Speicher am Ende
 *             des grîûten freien Blocks, um die Fragmentierung des
 *             freien Speichers zu verringern.
 *             Das Ramdisk-XFS kann jetzt auch Laufwerk B: belegen,
 *             wenn nur ein physikalisches Laufwerk vorhanden ist.
 * 23.06.1996: Neue Funktionen fÅr Kernel-Malloc, Kernel-Mfree und
 *             Kernel-Pdomain, die bei passender Kernelversion
 *             automatisch benutzt werden.
 * 16.07.1996: Die Funktion Pdomain_kernel lieferte leider nicht die
 *             Domain, sondern die PID des laufenden Prozesses...
 */

#include <string.h>
#include <stdlib.h>
#include <ctype.h>
/*
 * Ein XFS kann man schlecht bis Åberhaupt nicht mit konventionellen
 * Mitteln (sprich: Pure Debugger) debuggen, daher verwende ich
 * ganz einfach an den wichtigsten Stellen Debugausgaben, mit deren
 * Hilfe man Fehler schnell einkreisen kann. SelbstverstÑndlich
 * sind diese im tatsÑchlichen Betrieb stîrend, daher werden sie nur
 * eincompiliert, wenn DEBUG definiert ist. LOGFILE legt dabei fest,
 * in welches File die Ausgaben geschrieben werden sollen, LOGBACK
 * ist das Backupfile (bei jedem Start wird das alte Backupfile
 * gelîscht, das letzte Debugfile in LOGBACK umbenannt und ein neues
 * Logfile begonnen). Hier kann man auch u:\\dev\\prn verwenden, wenn
 * man zuviel Papier hat ;)
 * LOGFILE und LOGBACK mÅssen absolute Pfade mit Laufwerkskennung
 * sein und auf dem gleichen physikalischen Laufwerk liegen.
 * Wird beim Start eine der Umschalttasten festgehalten, wird direkt
 * auf die Console (also normalerweise auf den Bildschirm)
 * ausgegeben. Den gleichen Effekt erhÑlt man durch u:\\dev\\con
 * fÅr LOGFILE. LOGBACK sollte dann weggelassen werden.
 * SelbstverstÑndlich wird das Filesystem durch die Debug-Ausgaben
 * sehr stark gebremst, vor allem, wenn man sie in eine Datei auf
 * der Festplatte ausgeben lÑût. Wer's ganz trickreich machen will,
 * legt das Logfile der Ramdisk auf eine andere(!) Ramdisk, damit ist
 * die Geschwindigkeit einigermaûen ertrÑglich.
 * Ach ja, das Ganze ist nur der Default, da man in der Infodatei
 * auch andere Dateien festlegen kann.
 * Das Logfile wird Åbrigens recht schnell sehr groû, daher sollte
 * man es ab und an lîschen, wenn keine Fehler aufgetreten sind. Das
 * Lîschen schadet nichts, da die Datei nur direkt fÅr Ausgaben
 * geîffnet wird.
 */
#ifdef DEBUG
#define LOGFILE	"c:\\gemsys\\magic\\xtension\\ramdebug.log"
#define LOGBACK	"c:\\gemsys\\magic\\xtension\\ramdebug.olg"
#include <stdarg.h>
#endif /* DEBUG */
#define ONLY_EXTERN
#include "ramdisk.h"

static WORD	wait_for_key;
static char	mountname[256];
#ifdef DEBUG
static char	logfile[256];
static char logback[256];
#endif

WORD main(void)
{
	char	help[2];

/* MagX-Cookie suchen und abbrechen, wenn nicht vorhanden */
	if (!get_cookie('MagX', NULL))
	{
		Cconws("The Ramdisk-XFS only works with MagiC 3 or better!"
			"\r\n");
		Cconws("Please press any key!\r\n");
		Cnecin();
		return(-1);
	}
	Cconws("\r\nRamdisk-XFS dated "VERSION"\r\n");
	Cconws("(c) 1995-1996 by Thomas Binder\r\n");
/* Die Parameter mit Defaultwerten belegen */
	leave_free = LEAVE_FREE;
	ram_type = RAM_TYPE;
	ramdisk_drive = -1;
	strcpy(mountname, "");
	strcpy(volume_label, "");
	eight_bit = 0;
#ifdef DEBUG
	strcpy(logfile, LOGFILE);
#ifdef LOGBACK
	strcpy(logback, "");
#else
	strcpy(logback, LOGBACK);
#endif /* LOGBACK */
#endif /* DEBUG */
	read_infofile();
/*
 * ZunÑchst ein/das Laufwerk fÅr die Ramdisk ermitteln. Leider bietet
 * MagiC nicht die Mîglichkeit, ein Filesystem direkt zu mounten; man
 * man muû also immer mindestens ein BIOS-Laufwerk belegen, ob man es
 * nun braucht, oder nicht.
 */
	if (ramdisk_drive < 0)
	{
		if ((ramdisk_drive = (WORD)Supexec(get_and_set_drive)) == -1)
		{
			Cconws("Installation failed (no free drive)!r\n");
			Cconws("Please press any key!\r\n");
			Cnecin();
			return(-1);
		}
	}
	else
	{
		if (Supexec(set_ramdisk_drive) == 0L)
		{
			Cconws("Installation failed (drive already in use)!"
				"\r\n");
			Cconws("Please press any key!\r\n");
			Cnecin();
			return(-1);
		}
	}
/*
 * Die Kernelstruktur ermitteln und prÅfen, ob die per int_malloc
 * angeforderten SpeicherstÅcke groû genug sind, um einen temporÑren
 * Filenamen der Ramdisk aufzunehmen.
 */
	if ((kernel = (THE_MX_KERNEL *)Dcntl(KER_GETINFO, NULL, NULL)) ==
		NULL)
	{
		Cconws("Installation failed (kernel structure unavailable)!"
			"\r\n");
		Cconws("Please press any key!\r\n");
		Cnecin();
		return(-1);
	}
	if (kernel->int_msize < 34)
	{
		Cconws("Installation failed (kernel blocksize too small)!"
			"\r\n");
		Cconws("Please press any key!\r\n");
		Cnecin();
		return(-1);
	}
/*
 * Jetzt das XFS mit der Funktion install_xfs aus pc_xfs.h beim
 * Kernel anmelden. ZurÅckgeliefert wird der Zeiger auf die
 * angepaûte Kernelstruktur, die man fÅr Funktionsaufrufe benutzen
 * muû. Die tatsÑchliche Struktur (wie sie schon weiter oben per
 * Dcntl ermittelt wurde) findet sich jetzt im Zeiger real_kernel.
 */
	if ((kernel = install_xfs(&ramdisk_xfs)) == NULL)
	{
		Cconws("Installation failed!\r\n");
		Cconws("Please press any key!\r\n");
		Cnecin();
		return(-1);
	}
/*
 * Die Ramdisk ist jetzt beim Kernel angemeldet und kann danach nicht
 * mehr entfernt werden. Sollte also bei dem Versuch, den Namen in
 * U:\ zu Ñndern, etwas schiefgehen, muû der Benutzer damit leben.
 */
	if (ramdisk_drive == 1)
	{
/*
 * FÅr Laufwerk B: muû erst noch der Link in Laufwerk U: angelegt
 * werden
 */
#define Fsymlink(old, new)	gemdos(0x12e, (char *)old, (char *)new)
		Fsymlink("B:\\", "U:\\b");
	}
	Cconws("Installed as U:\\");
	if (*mountname)
	{
		Dsetdrv('U' - 'A');
		Dsetpath("\\");
		help[0] = ramdisk_drive + 65;
		help[1] = 0;
		if (Frename(0, help, mountname) != 0L)
		{
			Cconws(help);
			Cconws("! (Frename failed)\r\n");
			wait_for_key = 1;
		}
		else
		{
			Cconws(mountname);
			Cconws("!\r\n");
		}
	}
	else
	{
		Cconout(65 + ramdisk_drive);
		Cconws("!\r\n");
	}
#ifdef DEBUG
	Cconws("MagiC-Kernelversion ");
	Cconout(48 + real_kernel->version);
	Cconws("\r\nDebug-output to ");
	if (Kbshift(-1) & 31)
	{
		debug_to_screen = 1;
		Cconws("screen\r\n");
	}
	else
	{
		if (*logback)
		{
			Fdelete(logback);
			Frename(0, logfile, logback);
		}
		debug_to_screen = 0;
		Cconws(logfile);
		Cconws("\r\n");
	}
#endif
/*
 * Ermitteln, ob Pdomain Åber GEMDOS oder die Kernel-Struktur
 * abgewickelt werden kann
 */
	Pdomain = Pdomain_gemdos;
	if ((real_kernel->version >= 2) &&
		((kernel->proc_info)(0, _BasPag) >= 2))
	{
		Pdomain = Pdomain_kernel;
	}
/*
 * Ermitteln, ob Mxalloc und Mfree Åber GEMDOS oder die Kernel-
 * Struktur aufgerufen werden kînnen.
 */
	_Mxalloc = Mxalloc;
	_Mfree = Mfree;
	if (real_kernel->version >= 4)
	{
		_Mxalloc = Mxalloc_kernel;
		_Mfree = Mfree_kernel;
	}
/* Startzeit und -datum fÅr das Wurzelverzeichnis merken */
	starttime = Tgettime();
	startdate = Tgetdate();
	if (wait_for_key)
	{
		Cconws("Please press any key!\r\n");
		Cnecin();
	}
/*
 * Ein XFS muû, sobald es erfolgreich mit install_xfs angemeldet
 * wurde, dauerhaft im Speicher verbleiben, deswegen muû hier
 * Ptermres aufgerufen werden. Das nachfolgende return ist eigentlich
 * sinnlos, hÑlt Pure C aber vom Meckern ab...
 */
	Ptermres(_PgmSize, 0);
	return(0);
}

/*
 * read_infofile
 *
 * Liest die INF-Datei des Ramdisk-XFS und wertet sie aus. UngÅltige
 * Zeilen werden gemeldet und nicht beachtet.
 */
void read_infofile(void)
{
	static char	filename[128],
				input[256];
	char		*prgname,
				*filename2,
				*arg,
				*pos;
	LONG		err;
	WORD		handle;

	wait_for_key = 0;
/*
 * Die Datei findet sich entweder im Ordner \gemsys\magic\xtension
 * des aktuellen Laufwerks, in dessen Wurzelverzeichnis oder im
 * aktuellen Verzeichnis
 */
	strcpy(filename, "\\gemsys\\magic\\xtension\\");
	filename2 = strrchr(filename, '\\');
/*
 * Versuchen, den Namen des Filesystems Åber den von MagiC angelegte
 * Environment-Variable _PNAM zu ermittlen. Geht das nicht, wird der
 * Name der INF-Datei auf ramdisk.inf gesetzt und direkt zum ôffnen
 * der Datei verzweigt (per unbeliebtem goto...)
 */
	if ((prgname = getenv("_PNAM")) == NULL)
	{
		strcat(filename, "ramdisk.inf");
		goto open_file;
	}
/*
 * EnthÑlt der Programmname keinen Punkt, wird direkt .inf angehÑngt
 * und zum Fileîffnen verzweigt (schon wieder goto...)
 */
	if ((pos = strrchr(prgname, '.')) == NULL)
	{
		if (*prgname == '\\')
		{
			strcpy(filename, prgname);
			filename2 = NULL;
		}
		else
			strcat(filename, prgname);
		strcat(filename, ".inf");
		goto open_file;
	}
/* Ansonsten wird die Extension durch ".inf" ersetzt */
	*pos = 0;
	if (*prgname == '\\')
	{
		filename2 = NULL;
		strcpy(filename, prgname);
	}
	else
		strcat(filename, prgname);
	*pos = '.';
	strcat(filename, ".inf");
/*
 * Die Datei îffnen; wenn der Programmname ein absoluter Pfad war,
 * wird nur dort gesucht, sonst auch im Wurzelverzeichnis und im
 * aktuellen Verzeichnis
 */
open_file:
	if (((err = Fopen(filename, FO_READ)) < 0L) && (!filename2 ||
		(((err = Fopen(filename2, FO_READ)) < 0L) &&
		((err = Fopen(++filename2, FO_READ)) < 0L))))
	{
		return;
	}
	handle = (WORD)err;
/* Die Datei zeilenweise auslesen und auswerten */
	while (readline(handle, input))
	{
/* Leerzeilen werden komplett ignoriert */
		if (!*input)
			continue;
/* Jede Zeile muû mindestens ein Gleichheitszeichen enthalten */
		if ((arg = strchr(input, '=')) == NULL)
		{
/*
 * UngÅltige Zeilen werden gemeldet und Åbergangen; auûerdem wird
 * ein Flag gesetzt, damit vor Programmende auf einen Tastendruck
 * gewartet wird (sonst sind die Meldungen u.U. zu schnell wieder
 * weg)
 */
invalid_line:
			if (arg != NULL)
				*arg = '=';
			Cconws("Invalid line in INF-file (ignored):\r\n");
			Cconws(input);
			Cconws("\r\n");
			wait_for_key = 1;
			continue;
		}
		*arg = 0;
/*
 * Folgt hinter dem Gleichheitszeichen nichts mehr, ist die Zeile
 * ungÅltig
 */
		if (!arg[1])
			goto invalid_line;
/*
 * Hinter dem Kommando drive= muû ein Laufwerksbuchstabe zwischen
 * 'A' und 'Z' (jeweils einschlieûlich) auûer 'U' folgen, sonst ist
 * die Zeile falsch
 */
		if (!stricmp(input, "drive"))
		{
			if (arg[2])
				goto invalid_line;
			arg[1] &= ~32;
			if ((arg[1] < 'A') || (arg[1] > 'Z') || (arg[1] == 'U'))
				goto invalid_line;
			ramdisk_drive = arg[1] - 'A';
			continue;
		}
/*
 * Der Text hinter mountname= wird ohne weitere PrÅfungen Åbernommen
 */
		if (!stricmp(input, "mountname"))
		{
			strcpy(mountname, &arg[1]);
			continue;
		}
/*
 * Hinter ramtype= dÅrfen stonly, altonly, storalt oder altorst
 * folgen, alles andere macht die Zeile ungÅltig
 */
		if (!stricmp(input, "ramtype"))
		{
			if (!stricmp(&arg[1], "stonly"))
				ram_type = 0;
			else if (!stricmp(&arg[1], "altonly"))
				ram_type = 1;
			else if (!stricmp(&arg[1], "storalt"))
				ram_type = 2;
			else if (!stricmp(&arg[1], "altorst"))
				ram_type = 3;
			else
				goto invalid_line;
			continue;
		}
/*
 * Der Inhalt der Zeile hinter leavefree= wird in eine Zahl gewandelt
 * und mit 1024 multipliziert. Weitere öberprÅfungen finden nicht
 * statt.
 */
		if (!stricmp(input, "leavefree"))
		{
			leave_free = atol(&arg[1]) * 1024L;
			continue;
		}
/* Hinter 8bit= muû entweder "true" oder "false" folgen */
		if (!stricmp(input, "8bit"))
		{
			if (!stricmp(&arg[1], "true"))
				eight_bit = 1;
			else if (!stricmp(&arg[1], "false"))
				eight_bit = 0;
			else
				goto invalid_line;
			continue;
		}
/* Die ersten 32 Zeichen hinter label= werden direkt Åbernommen */
		if (!stricmp(input, "label"))
		{
			volume_label[32] = 0;
			strncpy(volume_label, &arg[1], 32L);
			continue;
		}
#ifdef DEBUG
		if (!stricmp(input, "logfile"))
		{
			strcpy(logfile, &arg[1]);
			strcpy(logback, "");
			continue;
		}
		if (!stricmp(input, "logbackup"))
		{
			strcpy(logback, &arg[1]);
			continue;
		}
#endif
/*
 * Sollte die Zeile nicht mit drive, mountname, ramtype, leavefree
 * oder 8bit begonnen haben, ist sie ebenfalls ungÅltig
 */
		goto invalid_line;
	}
	Fclose(handle);
}

/*
 * readline
 *
 * Liest eine Zeile aus einer GEMDOS-Datei ein,
 * die wahlweise mit CRLF oder nur LF enden darf.
 * Beginnt sie mit einem '#', wird gleich die
 * nÑchste Zeile eingelesen.
 *
 * Eingabe:
 * handle: Zu benutzendes GEMDOS-Handle
 * buffer: Zeiger auf 255 Byte groûen Zeilenpuffer
 *
 * RÅckgabe:
 * 0: Fehler beim Lesen (oder: Zeile zu lang)
 * 1: Alles OK
 */
WORD readline(WORD handle, char *buffer)
{
    WORD    count;
    LONG	fpos,
    		add,
    		bytes_read;

    for (;;)
    {
		fpos = Fseek(0L, handle, 1);
		if (fpos < 0L)
			return(0);
		if ((bytes_read = Fread(handle, 255, buffer)) <= 0L)
		{
			return(0);
		}
        count = 0;
		add = 1L;
        for (;;)
        {
        	if (count == bytes_read)
        	{
        		add = 0L;
        		break;
        	}
            if (buffer[count] == '\n')
                break;
            if (count == 255)
                return(0);
            if (buffer[count] == '\t')
            	buffer[count] = ' ';
            count++;
        }
        if (Fseek((LONG)count + fpos + add, handle, 0) < 0L)
        {
        	return(0);
        }
        if (count)
        {
            if (buffer[count - 1] == '\r')
                count--;
        }
        buffer[count] = 0;
        if (*buffer != '#')
            break;
    }
    return(1);
}

/*
 * get_and_set_drive
 *
 * Parameterfunktion fÅr Supexec, die ein freies Laufwerk in _drvbits
 * sucht und belegt. Von der Suche ausgenommen sind A, B und U.
 *
 * RÅckgabe:
 * -1: Keine freie Laufwerkskennung mehr vorhanden.
 * sonst: Belegte Laufwerksnummer (2 = C, 3 = D, etc.)
 */
LONG get_and_set_drive(void)
{
	LONG	*_drvbits,
			i;

	_drvbits = (LONG *)0x4c2;
	for (i = 2L; i < 26L; i++)
	{
		if ((i != (LONG)('U' - 'A')) && !(*_drvbits & (1L << i)))
		{
			*_drvbits |= (1L << i);
			break;
		}
	}
	if (i == 26L)
		return(-1L);
	else
		return(i);
}

/*
 * set_ramdisk_drive
 *
 * éhnlich wie get_and_set_drive, versucht aber nur, das durch
 * ramdisk_drive gebenene Laufwerk in _drvbits zu belegen.
 *
 * RÅckgabe:
 * 0L: Das gewÅnschte Laufwerk war schon belegt.
 * 1L: Alles OK.
 */
LONG set_ramdisk_drive(void)
{
	LONG	*_drvbits;

	_drvbits = (LONG *)0x4c2;
	if (*_drvbits & (1L << ramdisk_drive))
	{
/*
 * Sonderbehandlung bei Laufwerk B: Soll die Ramdisk dieses Laufwerk
 * belegen, wird geprÅft, ob wirklich zwei Laufwerke angeschlossen
 * sind. Falls nicht, wird B: als Kennung akzeptiert.
 */
		if ((ramdisk_drive != 1) || (*(WORD *)0x4a6 > 1))
			return(0L);
	}
	*_drvbits |= (1L << ramdisk_drive);
	return(1L);
}

/*
 * Pdomain_gemdos
 *
 * Ruft direkt das GEMDOS-Pdomain auf.
 *
 * Eingabe:
 * domain: Neue Domain, -1 fragt ab.
 *
 * RÅckgabe:
 * Alte bzw. aktuelle Domain (0 = TOS, 1 = MiNT)
 */
LONG Pdomain_gemdos(WORD domain)
{
	return(gemdos(281, domain));
}

/*
 * Pdomain_kernel
 *
 * Ruft die Kernel-Funktion proc_info zur Ermittlung der aktuellen
 * Domain auf.
 *
 * Eingabe:
 * ignore: Wie domain fÅr Pdomain_gemdos, wird aber ignoriert
 *
 * RÅckgabe:
 * Aktuelle Domain (0 = TOS, 1 = MiNT)
 */
#pragma warn -par
LONG Pdomain_kernel(WORD ignore)
{
	LONG	domain;

	domain = (kernel->proc_info)(1, *(real_kernel->act_pd));
	TRACE(("Kernel-Pdomain liefert %L!\r\n", 1, domain));
	return(domain);
}
#pragma warn .par

/*
 * Mxalloc_kernel
 *
 * Ruft die Kernel-Funktion mxalloc zur Anforderung von Speicher auf.
 *
 * Eingabe:
 * amount: Anzahl der Bytes oder -1L
 * mode: Speichertyp
 *
 * RÅckabe:
 * Zeiger auf allozierten Speicher oder NULL bzw. LÑnge des grîûten
 * freien Speicherblocks
 */
void *Mxalloc_kernel(LONG amount, WORD mode)
{
	return((kernel->mxalloc)(amount, mode & ~0x4000, _BasPag));
}

/*
 * Mfree_kernel
 *
 * Ruft die Kernel-Funktion mfree zur Freigabe von Speicher auf.
 *
 * Eingabe:
 * block: Zeiger auf freizugebenden Speicher.
 *
 * RÅckgabe:
 * 0: Alles OK
 * sonst: GEMDOS-Fehlercode (z.B. EIMBA)
 */
WORD Mfree_kernel(void *block)
{
	return((WORD)(kernel->mfree)(block));
}

/*
 * increase_refcnts
 *
 * Erhîht den ReferenzzÑhler eines DDs und den "ElternschaftszÑhler"
 * aller seiner Vorfahren, wenn er bislang noch nicht referenziert
 * wurde.
 *
 * Eingabe:
 * dd: Zeiger auf den zu bearbeitenden RAMDISK_FD
 */
void increase_refcnts(RAMDISK_FD *dd)
{
	dd->fd_refcnt++;
	if (dd->fd_refcnt > 1)
		return;
	for (dd = dd->fd_parent; dd != NULL; dd = dd->fd_parent)
	{
		dd->fd_is_parent++;
		TRACE(("increase_refcnts: is_parent von %L jetzt %L!\r\n", 2,
			dd, (LONG)dd->fd_is_parent));
	}
}

/*
 * prepare_dir
 *
 * Initialisiert ein Verzeichnis der Ramdisk. Der Speicher wird
 * mit Nullen gelîscht, anschlieûend werden die PseudoeintrÑge "."
 * und ".." eingerichtet.
 *
 * Eingabe:
 * dir: Zeiger auf das Verzeichnis
 * maxentries: Soviele EintrÑge soll das Verzeichnis haben
 * parent: Zeiger auf das Elternverzeichnis, oder ROOT_DE, wenn
 *         dir das Wurzelverzeichnis ist.
 */
void prepare_dir(DIRENTRY *dir, WORD maxentries, DIRENTRY *parent)
{
	(kernel->fast_clrmem)(dir, &dir[maxentries]);
	strcpy(dir[0].de_fname, ".");
	dir[0].de_faddr = (char *)dir;
	dir[0].de_nr = 0;
	dir[0].de_maxnr = maxentries;
	dir[0].de_xattr.mode = S_IFDIR | 0777;
	dir[0].de_xattr.index = (LONG)dir;
	dir[0].de_xattr.dev = ramdisk_drive;
	dir[0].de_xattr.rdev = ramdisk_drive;
	dir[0].de_xattr.nlink = 1;
	dir[0].de_xattr.uid = 0;
	dir[0].de_xattr.gid = 0;
	dir[0].de_xattr.size = 0L;
	if (parent != ROOT_DE)
		dir[0].de_xattr.nblocks = 1L;
	else
		dir[0].de_xattr.nblocks = 0L;
	dir[0].de_xattr.mtime = Tgettime();
	dir[0].de_xattr.mdate = Tgetdate();
	dir[0].de_xattr.atime = Tgettime();
	dir[0].de_xattr.adate = Tgetdate();
	dir[0].de_xattr.ctime = Tgettime();
	dir[0].de_xattr.cdate = Tgetdate();
	dir[0].de_xattr.attr = FA_DIR;
	dir[0].de_xattr.reserved2 = 0;
	dir[0].de_xattr.reserved3[0] = 0L;
	dir[0].de_xattr.reserved3[1] = 0L;
	strcpy(dir[1].de_fname, "..");
	if (parent != ROOT_DE)
	{
		parent[0].de_xattr.atime = parent[0].de_xattr.mtime =
			Tgettime();
		parent[0].de_xattr.adate = parent[0].de_xattr.mdate =
			Tgetdate();
		dir[1].de_faddr = (char *)parent;
		dir[1].de_nr = 1;
		dir[1].de_maxnr = 0;
		dir[1].de_xattr = parent[0].de_xattr;
	}
	else
	{
		dir[1].de_faddr = (char *)&root_de;
		dir[1].de_nr = 1;
		dir[1].de_maxnr = 0;
		dir[1].de_xattr.mode = S_IFDIR | 0777;
		dir[1].de_xattr.index = (LONG)parent;
		dir[1].de_xattr.dev = ramdisk_drive;
		dir[1].de_xattr.rdev = ramdisk_drive;
		dir[1].de_xattr.nlink = 1;
		dir[1].de_xattr.uid = 0;
		dir[1].de_xattr.gid = 0;
		dir[1].de_xattr.size = 0L;
		dir[1].de_xattr.nblocks = 1L;
		dir[1].de_xattr.mtime = Tgettime();
		dir[1].de_xattr.mdate = Tgetdate();
		dir[1].de_xattr.atime = Tgettime();
		dir[1].de_xattr.adate = Tgetdate();
		dir[1].de_xattr.ctime = starttime;
		dir[1].de_xattr.cdate = startdate;
		dir[1].de_xattr.attr = FA_DIR;
		dir[1].de_xattr.reserved2 = 0;
		dir[1].de_xattr.reserved3[0] = 0L;
		dir[1].de_xattr.reserved3[1] = 0L;
	}
}

/*
 * findfile
 *
 * Funktion zum Suchen einer Datei. Hier muû das Problem angemessen
 * berÅcksichtigt werden, daû Programme, die in der TOS-Domain
 * laufen, mîglicherweise verstÅmmelte Filenamen liefern, die mit dem
 * tatsÑchlichen nur noch sehr wenig gemeinsam haben. Besonders
 * unangenehm ist das Ganze mit MagiC 3, da es dort noch kein Pdomain
 * gibt. Es lÑût sich daher dort nicht feststellen, ob ein Prozeû
 * lange Dateinamen versteht.
 *
 * Eingabe:
 * dd: Zeiger auf den RAMDISK_FD des Verzeichnisses, in dem gesucht
 *     werden soll.
 * pathname: Name des gesuchten Files/Directories.
 * spos: Nummer des Eintrags, ab dem die Suche beginnen soll (0, wenn
 *       auch "." und ".." gefunden werden dÅrfen, sonst >= 2).
 * s_or_e: Bestimmt, ob pathname fÅr einen Zugriff gesucht wird
 *         (FF_SEARCH) oder ob fÅr eine Neuanlage des Names geprÅft
 *         werden soll, ob er schon existiert (FF_EXIST). Je nach
 *         Modus und aktiver Domain verhÑlt sich die Funktion anders.
 * maybe_dir: Legt fest, ob pathname leer sein darf (ungleich Null)
 *            oder nicht (0). Wenn ja, und pathname ist tatsÑchlich
 *            leer, wird das aktuelle Verzeichnis selbst gefunden.
 *            Dies ist dann nîtig, wenn ein Programm beispielsweise
 *            Fxattr fÅr "c:\gemsys\" aufruft.
 *
 * RÅckgabe:
 * Zeiger auf den gefundenen Verzeichniseintrag, oder NULL.
 */
DIRENTRY *findfile(RAMDISK_FD *dd, char *pathname, WORD spos,
	WORD s_or_e, WORD maybe_dir)
{
	WORD		i,
				max;
	DIRENTRY	*search;
	char		*temp,
				*dos;

/* Sicherheitscheck fÅr den DD */
	if (!is_dir(dd->fd_file->de_xattr.mode))
		return(NULL);
/* Ein leerer Suchname bedeutet u.U. das aktuelle Verzeichnis */
	if (!*pathname && maybe_dir)
		return(dd->fd_file);
/*
 * Das aktuelle Verzeichnis muû Åberschreitbar sein. Dieser Test
 * erfolgt absichtlich nach der Abfrage auf leeren Suchnamen, da
 * dann ja das Verzeichnis selbst gefunden werden soll, wozu keine
 * öberschreitungsrechte vorhanden sein mÅssen.
 */
	if (!xaccess(dd->fd_file))
		return(NULL);
/* Zweimal Speicher fÅr temporÑre Filenamen anfordern */
	temp = (kernel->int_malloc)();
	dos = (kernel->int_malloc)();
	temp[32] = 0;
	strncpy(temp, pathname, 32L);
	search = (DIRENTRY *)dd->fd_file->de_faddr;
	max = search[0].de_maxnr;
/*
 * ZunÑchst den Filenamen mit exakten Vergleichen suchen, wenn die
 * MiNT-Domain aktiv ist oder der Directoryeintrag fÅr einen Zugriff
 * ermittelt werden soll
 */
	if ((Pdomain(-1) == EINVFN) || (Pdomain(-1) == 1) ||
		(s_or_e == FF_SEARCH))
	{
		for (i = spos; i < max; i++)
		{
			if (search[i].de_faddr == NULL)
				continue;
			if (!strcmp(temp, search[i].de_fname))
			{
				(kernel->int_mfree)(temp);
				(kernel->int_mfree)(dos);
				return(&search[i]);
			}
		}
	}
/*
 * Wurde so nichts gefunden, muû NULL geliefert werden, wenn der
 * Prozeû in der MiNT-Domain lÑuft, oder wenn die Domain nicht
 * ermittelt werden kann _und_ nur auf Existenz geprÅft werden soll
 */
	if ((Pdomain(-1) == 1) ||
		((Pdomain(-1) == EINVFN) && (s_or_e == FF_EXIST)))
	{
		(kernel->int_mfree)(temp);
		(kernel->int_mfree)(dos);
		return(NULL);
	}
/*
 * Sonst den Filenamen in Kleinbuchstaben wandeln und wieder suchen,
 * wenn die TOS-Domain aktiv ist
 */
	if (Pdomain(-1) == 0)
	{
		strlwr(temp);
		for (i = spos; i < max; i++)
		{
			if (search[i].de_faddr == NULL)
				continue;
			if (!strcmp(temp, search[i].de_fname))
			{
				(kernel->int_mfree)(temp);
				(kernel->int_mfree)(dos);
				return(&search[i]);
			}
		}
/*
 * Wurde immer noch nichts gefunden, ist die Suche erfolglos, wenn
 * nur auf Existenz des Namens geprÅft werden soll
 */
		if (s_or_e == FF_EXIST)
		{
			(kernel->int_mfree)(temp);
			(kernel->int_mfree)(dos);
			return(NULL);
		}
	}
/*
 * Jetzt den Suchnamen in's 8+3-Format quetschen und nochmal mit
 * TOS-Gleichheit suchen
 */
	tostrunc(temp, pathname, 0);
	for (i = spos; i < max; i++)
	{
		if (search[i].de_faddr == NULL)
			continue;
		tostrunc(dos, search[i].de_fname, 0);
		TRACE(("findfile: temp = %S, dos = %S\r\n", 2, temp, dos));
		if (!strcmp(temp, dos))
		{
			(kernel->int_mfree)(temp);
			(kernel->int_mfree)(dos);
			return(&search[i]);
		}
	}
/* Es wurde wirklich nichts gefunden */
	(kernel->int_mfree)(temp);
	(kernel->int_mfree)(dos);
	return(NULL);
}

/*
 * findfd
 *
 * Sucht einen FD, der entweder frei oder bereits durch einen
 * bestimmten Verzeichniseintrag belegt ist.
 *
 * Eingabe:
 * fname: Zeiger auf Verzeichniseintrag, der im zu suchenden FD
 *        vorhanden sein soll, oder NULL.
 *
 * RÅckgabe:
 * Zeiger auf den gefundenen FD, oder NULL.
 */
RAMDISK_FD *findfd(DIRENTRY *fname)
{
	WORD	i;

#if 1
/*
 * Ist ein Verzeichniseintrag gegeben, zunÑchst schauen, ob einer der
 * FDs bereits durch ihn belegt ist. Falls ja, diesen FD liefern.
 */
	if (fname != NULL)
	{
		for (i = 0; i < MAX_FD; i++)
		{
			if (fd[i].fd_file == fname)
				return(&fd[i]);
		}
	}
#endif
/*
 * War fname gleich NULL oder noch nicht vorhanden, wird jetzt ein
 * freier FD gesucht, gelîscht und zurÅckgeliefert
 */
	for (i = 0; i < MAX_FD; i++)
	{
		if (fd[i].fd_file == NULL)
		{
			(kernel->fast_clrmem)(&fd[i], &fd[i + 1]);
			return(&fd[i]);
		}
	}
/* Sollte kein FD mehr frei sein, NULL liefern */
	return(NULL);
}

/*
 * new_file
 *
 * Erstellt einen neuen Eintrag in einem Verzeichnis an und belegt
 * die wichtigsten Felder vor.
 *
 * Eingabe:
 * curr: Zeiger auf den FD des Verzeichnisses, in dem der neue
 *       Eintrag angelegt werden soll.
 * name: GewÅnschter Name des neuen Files.
 *
 * RÅckgabe:
 * Zeiger auf den neuen Eintrag, oder NULL.
 */
DIRENTRY *new_file(RAMDISK_FD *curr, char *name)
{
	DIRENTRY	*dir,
				*new_dir;
	WORD		i,
				max;

/* Ist der Filename unzulÑssig, NULL zurÅckliefern */
	if (!check_name(name))
		return(NULL);
	dir = (DIRENTRY *)curr->fd_file->de_faddr;
/*
 * Zum Anlegen eines Eintrags muû das Verzeichnis Åberschreit- und
 * beschreibbar sein
 */
	if (!waccess(curr->fd_file) || !xaccess(curr->fd_file))
		return(NULL);
/* Einen noch leeren Eintrag suchen */
	max = dir[0].de_maxnr;
	for (i = 2; i < max; i++)
	{
		if (dir[i].de_faddr == NULL)
			break;
	}
	if (i == max)
	{
/*
 * War kein leerer Eintrag mehr vorhanden, muû das Verzeichnis um
 * einen Block erweitert werden. Klappt auch das nicht, liefert die
 * Funktion NULL.
 */
		new_dir = Krealloc(dir,
			dir[0].de_xattr.nblocks * DEFAULTDIR * sizeof(DIRENTRY),
			(dir[0].de_xattr.nblocks + 1L) * DEFAULTDIR *
			sizeof(DIRENTRY));
		if (new_dir == NULL)
			return(NULL);
		dir = new_dir;
		dir[0].de_maxnr += (WORD)DEFAULTDIR;
		dir[0].de_xattr.nblocks++;
		dir[0].de_faddr = (char *)new_dir;
		dir[0].de_xattr.index = (LONG)new_dir;
		curr->fd_file->de_maxnr = dir[0].de_maxnr;
		curr->fd_file->de_xattr.nblocks = dir[0].de_xattr.nblocks;
		curr->fd_file->de_faddr = (char *)new_dir;
		curr->fd_file->de_xattr.index = (LONG)new_dir;
		/*** work_entry fÅr Anpassung von index ***/
	}
/* Den neuen Eintrag komplett lîschen und den Namen eintragen */
	(kernel->fast_clrmem)(&dir[i], &dir[i + 1]);
	strncpy(dir[i].de_fname, name, 32L);
	if (Pdomain(-1) == 0)
	{
/*
 * In der TOS-Domain den Namen in Kleinbuchstaben wandeln, weil
 * solche Prozesse oft Filenamen wie STGUIDE.APP liefern, die auf
 * einem casesensitiven Filesystem aber nicht so toll ausehen
 */
		TRACE(("new_file: Wandele Filenamen in Lowercase!\r\n", 0));
		strlwr(dir[i].de_fname);
	}
	else
		TRACE(("new_file: Filename nicht gewandelt!\r\n", 0));
/*
 * Die wichtigsten Felder des Eintrags belegen. Dabei wird das Feld
 * de_faddr bewuût noch nicht gefÅllt, der Eintrag bleibt also bis
 * zur Belegung durch die aufrufende Funktion frei.
 */
	dir[i].de_nr = i;
	dir[i].de_xattr.atime = dir[i].de_xattr.mtime =
		dir[i].de_xattr.ctime = Tgettime();
	dir[i].de_xattr.adate = dir[i].de_xattr.mdate =
		dir[i].de_xattr.cdate = Tgetdate();
	dir[i].de_xattr.dev = ramdisk_drive;
	dir[i].de_xattr.rdev = ramdisk_drive;
	dir[i].de_xattr.nlink = 1;
	dir[i].de_xattr.blksize = DEFAULTFILE;
	return(&dir[i]);
}

/*
 * dir_is_open
 *
 * PrÅft, ob ein gegebenes Verzeichnis per Dopendir geîffnet ist.
 *
 * Eingabe:
 * dir: Zeiger auf den Verzeichniseintrag des Directories.
 *
 * RÅckgabe:
 * 0, wenn das Verzeichnis nicht offen ist, 1 sonst.
 */
WORD dir_is_open(DIRENTRY *dir)
{
	WORD	i;

/*
 * Alle Directory-Handles durchgehen und prÅfen, ob sie das gesuchte
 * Verzeichnis reprÑsentieren
 */
	for (i = 0; i < MAX_DHD; i++)
	{
		if (dhd[i].dhd_dir == dir)
			return(1);
	}
	return(0);
}

/*
 * check_name
 *
 * öberprÅft einen Filenamen auf GÅltigkeit. Erlaubt sind auf der
 * Ramdisk alle ASCII-Zeichen von 32 bis 127/255 (mit Ausnahme des
 * Backslash). Die Obergrenze richtet sich dabei nach dem Wert von
 * eight_bit.
 *
 * Eingabe:
 * name: Zu prÅfender Filename.
 *
 * RÅckgabe:
 * 0, wenn der Name ungÅltig ist, 1 sonst.
 */
WORD check_name(char *name)
{
	WORD	i,
			max,
			check;

/* Leere Namen sind auch nicht zulÑssig */
	if (!*name)
		return(0);
	max = eight_bit ? 255 : 127;
	for (i = 0; i < strlen(name); i++)
	{
		check = (WORD)name[i] & 0xff;
		if ((check < 32) || (check > max) ||
			(name[i] == '\\'))
		{
			return(0);
		}
	}
	return(1);
}

/*
 * check_dd
 *
 * PrÅft einen Directory-Deskriptor auf GÅltigkeit. Zwar sollte man
 * sich darauf verlassen kînnen, daû der Kernel den Funktionen eines
 * XFS nur korrekte DDs liefert, aber schlieûtlich ist Vorsicht die
 * Mutter der Porzellankiste...
 *
 * Eingabe:
 * dd: Zu prÅfender DD.
 *
 * RÅckgabe:
 * E_OK: DD ist nicht erkennbar falsch.
 * EDRIVE: DD gehîrt nicht dem Ramdisk-XFS.
 * EPTHNF: DD ist in Wirklichkeit ein FD, reprÑsentiert also kein
 *         Verzeichnis.
 */
LONG check_dd(RAMDISK_FD *dd)
{
	if (dd->fd_dmd != ramdisk_dmd)
		return(EDRIVE);
	if (!is_dir(dd->fd_file->de_xattr.mode))
		return(EPTHNF);
	return(E_OK);
}

/*
 * check_fd
 *
 * Wie check_dd, nur fÅr Filedeskriptoren.
 *
 * Eingabe:
 * fd: Zu ÅberprÅfender FD.
 *
 * RÅckgabe:
 * E_OK: FD ist nicht erkennbar falsch.
 * EDRIVE: FD gehîrt nicht dem Ramdisk-XFS.
 * EFILNF: FD reprÑsentiert keine Datei.
 */
LONG check_fd(RAMDISK_FD *fd)
{
	if (fd->fd_dmd != ramdisk_dmd)
		return(EDRIVE);
	if (!is_file(fd->fd_file->de_xattr.mode))
		return(EFILNF);
	return(E_OK);
}

/*
 * work_entry
 *
 * Hilfsfunktion, die fÅr einen bestimmten Directoryeintrag eine
 * gegebene Aktion durchfÅhrt und dabei darauf achtet, daû alle
 * ReprÑsentanten dieses Eintrags (also auch die PseudoeintrÑge
 * "." des gleichen und ".." der untergeordneten Verzeichnisse)
 * mit angepaût werden. Damit lassen sich alle Funktionen, die sich
 * auf VerzeichniseintrÑge beziehen, realisieren, ohne sich um die
 * genannten Details kÅmmern zu mÅssen.
 *
 * Eingabe:
 * dd: Zeiger auf den DD, in dessen Verzeichnis sich der zu Ñndernde
 *     Eintrag befindet.
 * name: Name des Eintrags.
 * symlink: Zeiger auf Stringzeiger, hier wird ggf. ein Zeiger auf
 *          das Ziel eines symbolischen Links eingetragen. Ist
 *          symlink NULL, werden keine symbolischen Links verfolgt.
 * writeflag: Wenn ungleich Null, wird der Eintrag durch die
 *            Aktionsfunktion eventuell verÑndert. Dann, und nur
 *            dann, werden auch die anderen ReprÑsentanten
 *            bearbeitet.
 * par1: Erster Parameter, den action erhalten soll.
 * par2: Zweiter Parameter fÅr action.
 * action: Zeiger auf die Aktionsfunktion, die als Parameter den
 *         Zeiger auf den zu bearbeitenden Eintrag und par1/par2
 *         bekommt. ZurÅckliefern muû die Funktionen einen GEMDOS-
 *         Returncode. Ist action ein Nullzeiger, muû name ein
 *         symbolischer Link sein, sonst liefert work_entry sofort
 *         EINVFN.
 *
 * RÅckgabe:
 * GEMDOS-Fehlercode, der meist der Returncode von action ist.
 */
LONG work_entry(RAMDISK_FD *dd, char *name, char **symlink,
	WORD writeflag, LONG par1, LONG par2,
	LONG (*action)(DIRENTRY *entry, LONG par1, LONG par2))
{
	DIRENTRY	*found,
				*help;
	LONG		retcode;
	WORD		i,
				max;
	XATTR		new;

/* DD ÅberprÅfen */
	if (check_dd(dd) < 0)
	{
		if (action == NULL)
			return(EINVFN);
		else
			return(check_dd(dd));
	}
/* Eintrag suchen */
	if ((found = findfile(dd, name, 0, FF_SEARCH, 1)) == NULL)
	{
		if (action == NULL)
			return(EINVFN);
		else
			return(EFILNF);
	}
/* Test auf symbolischen Link */
	if (is_link(found->de_xattr.mode) && (symlink != NULL))
	{
		TRACE(("work_entry: Folge symbolischem Link auf %S!\r\n", 1,
			&found->de_faddr[2]));
		*symlink = found->de_faddr;
		return(ELINK);
	}
	if (action == NULL)
		return(EINVFN);
/*
 * Sollen énderungen vorgenommen werden, obwohl sich name nicht auf
 * das gleiche Verzeichnis bezieht, das auch der DD reprÑsentiert,
 * mÅssen Schreibrechte vorhanden sein
 */
	if (writeflag && (dd->fd_file->de_faddr != found->de_faddr) &&
		!waccess(dd->fd_file))
	{
		return(EACCDN);
	}
/*
 * action aufrufen und den Returncode liefern, falls es ein Fehler
 * war, oder wenn keine énderungen an Eintrag vorgesehen sind
 */
	retcode = (action)(found, par1, par2);
	if ((retcode < 0L) || !writeflag)
		return(retcode);
/*
 * Ist der Eintrag kein Verzeichnis, gibt es auch keine weiteren
 * EintrÑge, die ihn ebenfalls reprÑsentieren und mitgeÑndert werden
 * mÅûten
 */
	if (!is_dir(found->de_xattr.mode))
		return(retcode);
/* Sonst den neuen Inhalt des Eintrags zwischenspeichern */
	new = found->de_xattr;
/* Den Ursprungseintrag des Verzeichnisses ermitteln */
	if (!strcmp(found->de_fname, "."))
		found = dd->fd_file;
	if (!strcmp(found->de_fname, ".."))
	{
/* ".." des Wurzelverzeichnisses hat keine weiteren ReprÑsentanten */
		if (dd->fd_parent == NULL)
			return(retcode);
		found = dd->fd_parent->fd_file;
	}
/*
 * Jetzt den Inhalt an alle nîtigen Positionen kopieren, dabei mÅssen
 * auch alle Unterverzeichnisse, soweit vorhanden, berÅcksichtigt
 * werden, da hier ".." geÑndert werden muû.
 */
	found->de_xattr = new;
	found = (DIRENTRY *)found->de_faddr;
	found->de_xattr = new;
	max = found->de_maxnr;
	for (i = 2; i < max; i++)
	{
		if ((found[i].de_faddr != NULL) &&
			is_dir(found[i].de_xattr.mode))
		{
			help = (DIRENTRY *)found[i].de_faddr;
			help[1].de_xattr = new;
		}
	}
	return(retcode);
}

/*
 * set_amtime
 *
 * Fungiert als Parameterfunktion fÅr work_entry und setzt die letzte
 * Zugriffs- bzw. die letzte énderungszeit auf die aktuellen Werte.
 *
 * Eingabe:
 * entry: Zu bearbeitender Verzeichniseintrag.
 * set_amtime: Wenn 0, soll die énderungszeit geÑndert werden, sonst
 *             die Zugriffszeit.
 *
 * RÅckgabe:
 * Immer E_OK, weil nichts schieflaufen kann.
 */
#pragma warn -par
LONG set_amtime(DIRENTRY *entry, LONG set_atime, LONG unused)
{
	if (set_atime)
	{
		entry->de_xattr.atime = Tgettime();
		entry->de_xattr.adate = Tgetdate();
	}
	else
	{
		entry->de_xattr.mtime = Tgettime();
		entry->de_xattr.mdate = Tgetdate();
	}
	return(E_OK);
}
#pragma warn .par

/*
 * tostrunc
 *
 * Quetscht einen Ramdisk-Filenamen in das 8+3-Format, und zwar nach
 * folgenden Regeln:
 * - "." und ".." werden direkt Åbernommen
 * - alle unerlaubten Zeichen werden durch "X" ersetzt
 * - alle Punkte, auûer dem letzten, werden durch Kommata ersetzt;
 *   ist der letzte Punkt auch das letzte Zeichen des Namens, wird
 *   er gestrichen, ist er das erste Zeichen des Namens, wird er
 *   doch in ein Komma gewandelt
 * - alle Zeichen werden in Groûbuchstaben gewandelt
 * - die ersten acht Zeichen vor dem letzten Punkt werden Åbernommen
 * - die ersten drei Zeichen nach dem letzten Punkt werden Åbernommen
 *   (falls es einen letzten Punkt gibt)
 *
 * Beispiele:
 * Langer Dokumentenanme.txt -> LANGERXD.TXT
 * name.mit.vielen.punkten -> NAME,MIT.PUN
 * .profile -> ,PROFILE
 * punkt.am.ende. -> PUNKT,AM
 *
 * NatÅrlich kînnen so zwei eigentlich verschiedene Dateinamen auf
 * den selben TOS-Namen abgebildet werden, was mit nicht angepaûten
 * Programmen durchaus Probleme bereiten kann. Der Aufwand, dieses
 * Problem absolut sicher zu umgehen, Åbersteigt allerdings meiner
 * Meinung nach den mîglichen Nutzen.
 *
 * Eingabe:
 * dest: Zeiger auf den Zielnamen, hier wird also das Ergebnis der
 *       Umwandlung abgelegt.
 * src: Zeiger auf den Ursprungsnamen.
 * wildcards: Wenn ungleich Null, werden ? und * im Ursprungsnamen
 *            Åbernommen, sonst durch X ersetzt.
 */
void tostrunc(char *dest, char *src, WORD wildcards)
{
	WORD	i;
	char	*lastdot,
			temp[] = "a";

/* Nur zu Debug-Zwecken */
#ifdef DEBUG
	if (!check_name(src))
	{
		TRACE(("tostrunc: Falscher Dateiname: %S\r\n", 1, src));
	}
#endif
	TRACE(("tostrunc: %S -> %L\r\n", 2, src, dest));
/* "." und ".." unverÑndert kopieren */
	if (!strcmp(src, ".") || !strcmp(src, ".."))
	{
		strcpy(dest, src);
		return;
	}
/*
 * Den letzten Punkt im Namen suchen. Ist er das erste oder letzte
 * Zeichen des Namens, wird er "versteckt".
 */
	lastdot = strrchr(src, '.');
	if (lastdot != NULL)
	{
		if ((lastdot == src) || !lastdot[1])
			lastdot = NULL;
	}
/*
 * Den Zielstring vorbereiten und die ersten acht Zeichen vor dem
 * letzten Punkt einsetzen
 */
	strcpy(dest, "");
	for (i = 0; i < 8; i++)
	{
		if (!*src || (src == lastdot))
			break;
/* Punkte als Kommas eintragen */
		if (*src == '.')
			strcat(dest, ",");
		else
		{
/*
 * Unerlaubte Zeichen als "X" Åbernehmen, alle anderen als
 * Groûbuchstaben in den Zielstring einsetzen. "*" und "?" werden
 * dabei in AbhÑngigkeit des Parameters wildcard behandelt.
 */
			if (strchr("_!@#$%^&()+-=~`;\'\",<>|[]{}", *src) ||
				isalnum(*src) || (wildcards && ((*src == '*') ||
				(*src == '?'))))
			{
				*temp = toupper(*src);
				strcat(dest, temp);
			}
			else
				strcat(dest, "X");
		}
		src++;
	}
/*
 * Gab es einen letzten Punkt, wird er jetzt samt den ersten drei
 * dahinter folgenden Zeichen (gewandelt wie oben) an den Zielstring
 * angehÑngt.
 */
	if (lastdot)
	{
		strcat(dest, ".");
		src = lastdot;
		src++;
		for (i = 0; i < 3; i++)
		{
			if (!*src)
				break;
			if (strchr("_!@#$%^&()+-=~`;\'\",<>|[]{}", *src) ||
				isalnum(*src) || (wildcards && ((*src == '*') ||
				(*src == '?'))))
			{
				*temp = toupper(*src);
				strcat(dest, temp);
			}
			else
				strcat(dest, "X");
			src++;
		}
	}
}

/*
 * fill_tosname
 *
 * FÅllt einen von tostrunc gelieferten Namen auf exakt 8+3 Zeichen
 * auf; tritt dabei im Namen oder in der Extension ein "*" auf, wird
 * der betroffene Teil des Filenamens ab dieser Position mit "?"
 * aufgefÅllt (fÅr spÑtere Vergleiche).
 *
 * Beispiele:
 * "PC.PRG" -> "PC      .PRG"
 * "FOO.C" -> "FOO     .C  "
 * "AUTO" -> "AUTO    .   "
 * "*.TXT" -> "????????.TXT"
 * "ABC*.?X*" -> "ABC?????.?X?"
 *
 * Eingabe:
 * dest: Zeiger auf Zielstring, der mindestens fÅr 13 Zeichen (inkl.
 *       abschlieûendem Nullbyte) Platz bieten muû.
 * src: Zeiger auf zu fÅllenden String, der dem von tostrunc
 *      gelieferten Format entsprechen muû.
 */
void fill_tosname(char *dest, char *src)
{
	WORD	i;
	char	*dot;

	TRACE(("fill_tosname...\r\n", 0));
/* "." und ".." werden direkt behandelt */
	if (!strcmp(src, "."))
	{
		strcpy(dest, ".       .   ");
		return;
	}
	if (!strcmp(src, ".."))
	{
		strcpy(dest, "..      .   ");
		return;
	}
/* Ansonsten den Zielstring mit einem leeren Namen belegen */
	strcpy(dest, "        .   ");
/*
 * Alle Zeichen bis zum Punkt werden an den Anfang von dest kopiert
 */
	dot = strchr(src, '.');
	for (i = 0; *src && (src != dot); i++)
		dest[i] = *src++;
/*
 * Alle Zeichen nach dem Punkt (sofern es einen gab) werden hinter
 * den Punkt des Zielstrings kopiert
 */
	if (dot != NULL)
	{
		src = ++dot;
		for (i = 0; *src; i++)
			dest[9 + i] = *src++;
	}
/*
 * Jetzt noch in beiden Namensteilen nach einem "*" suchen, wird
 * einer gefunden, wird der Rest des Teilnamens mit "?" gefÅllt
 * (inklusive der Fundposition)
 */
	for (i = 0; i < 8; i++)
	{
		if (dest[i] == '*')
		{
			memset(&dest[i], '?', (LONG)(8 - i));
			break;
		}
	}
	for (i = 9; i < 12; i++)
	{
		if (dest[i] == '*')
		{
			memset(&dest[i], '?', (LONG)(12 - i));
			break;
		}
	}
	TRACE(("fill_tosname liefert: %S\r\n", 1, dest));
}

/*
 * match_tosname
 *
 * Vergleicht zwei von fill_tosname gelieferte Namen, wobei einer von
 * beiden "?" als Wildcards enthalten darf (der andere darf sie auch
 * enthalten, hier werden sie aber als normale Zeichen angesehen).
 * Diese Funktion stellt den Maskenvergleich fÅr sfirst/snext dar und
 * arbeitet zuverlÑssiger als manche GEMDOS-Version (bei denen laut
 * Profibuch z.B. "A*.**" auf alle Dateien paût).
 *
 * Eingabe:
 * to_check: Zu ÅberprÅfender Dateiname, im fill_tosname-Format.
 * sample: Vergleichsname, ebenfalls im fill_tosname-Format, der "?"
 *         als Wildcards enthalten darf.
 *
 * RÅckgabe:
 * 0: to_check und sample sind nicht miteinander vereinbar.
 * 1: to_check paût zu sample.
 */
WORD match_tosname(char *to_check, char *sample)
{
	WORD	i;

	TRACE(("match_tosname: %S, %S\r\n", 2, to_check, sample));
/*
 * Es werden einfach der Reihe nach alle Zeichen der Namen verglichen
 * (hier wird der Vorteil des von fill_tosname erzeugten Formats
 * deutlich). Ist an der aktuellen Stelle in sample ein "?" zu
 * finden, wird nicht verglichen, womit die Wildcardfunktion einfach
 * erfÅllt ist. Beim ersten fehlgeschlagenen Vergleich wird die
 * Funktion vorzeitig verlassen.
 */
	for (i = 0; i < 12; i++)
	{
		if (sample[i] != '?')
			if (sample[i] != to_check[i])
			{
				TRACE(("Warnix\r\n", 0));
				return(0);
			}
	}
	TRACE(("Alles klar, paût\r\n", 0));
	return(1);
}

/*
 * xext enthÑlt die Filenamensendungen (verkehrt herum), bei denen
 * beim Anlegen in der TOS-Domain automatisch das x-Flag fÅr
 * "AusfÅhrbar" gesetzt wird
 */
static char	*xext[] = {"sot.", "ptt.", "grp.", "ppa.", "ptg.",
	"cca."};

/*
 * has_xext
 *
 * Diese Funktion prÅft, ob ein Filename eine Extension hat, die
 * normalerweise ein ausfÅhrbares Programm kennzeichnet. Dieser Test
 * schlÑgt immer fehl, wenn gerade die MiNT-Domain aktiv ist, weil
 * solche Programme die Flags fÅr "ausfÅhrbar" selbst setzen sollten.
 * Die Vergleichsnamen sind oben im Array xext festgelegt.
 *
 * Eingabe:
 * name: Zeiger auf zu ÅberprÅfenden Filenamen.
 *
 * RÅckgabe:
 * 0: name hat keine passende Extension bzw. die MiNT-Domain ist
 *    aktiv
 * 1: Die TOS-Domain ist aktiv und name hat eine passende Endung.
 */
WORD has_xext(char *name)
{
	char	*temp;
	WORD	i;

	if (Pdomain(-1) == 1)
		return(0);
	temp = (kernel->int_malloc)();
	temp[32] = 0;
	strncpy(temp, name, 32L);
	strrev(temp);
	for (i = 0; i < (sizeof(xext) / sizeof(char *)); i++)
	{
		if (!strnicmp(temp, xext[i], strlen(xext[i])))
		{
			(kernel->int_mfree)(temp);
			return(1);
		}
	}
	(kernel->int_mfree)(temp);
	return(0);
}

/*
 * Kmalloc
 *
 * Funktion, die dauerhaften Speicher anfordert, der also nur durch
 * ein explizites Kfree (nur ein Makro fÅr _Mfree) wieder freigegeben
 * wird. GÑbe es diese Mîglichkeit in MagiC nicht, wÑre ein XFS wie
 * dieses nutzlos, weil bei einem Programmende der Teil der Daten,
 * der von diesem Programm angelegt wurde, wieder verschwinden wÅrde.
 * Der Name ist nicht nur zufÑllig an den der Funktion aus der MiNT-
 * Kernelstruktur angelehnt...
 * Die Funktion achtet auûerdem darauf, daû der grîûte freie
 * Speicherblock die in leave_free festgelegte Mindestgrîûe nicht
 * unterschreitet und fordert immer den durch ram_type festgelegten
 * Speichertyp an. Wenn mîglich, wird der neue Block am Ende des
 * zur Zeit grîûten freien Blocks alloziert, um die Fragmentierung
 * des freien Speichers zu entschÑrfen.
 *
 * Eingabe:
 * len: Wieviele Bytes sollen belegt werden, bei -1L wird die LÑnge
 *      des grîûten zusammenhÑngenden Speicherblocks abzÅglich der
 *      freizuhaltenden Bytes geliefert (ggf. 0L).
 *
 * RÅckgabe:
 * Zeiger auf den allozierten Speicherblock, oder NULL.
 */
void *Kmalloc(LONG len)
{
	LONG	free,
			new_free;
	void	*block,
			*temp;

/* LÑnge des grîûen verfÅgbaren Speicherblocks ermitteln */
	free = (LONG)_Mxalloc(-1L, ram_type);
	if (len == -1)
	{
/*
 * Soll die Zahl der fÅr die Ramdisk noch freien Bytes geliefert
 * werden, muû von der gerade ermittelten Zahl noch die Anzahl der
 * mindestens freizuhaltenden Bytes abgezogen werden. Ggf. ist das
 * Ergebnis Null.
 */
		if (free < leave_free)
			return(0L);
		return((void *)(free - leave_free));
	}
/*
 * Wenn noch soviel Speicher am StÅck frei ist, daû nach Abzug des
 * zu allozierenden Speichers immer noch mehr als leave_free Åbrig
 * bleibt, wird versucht, den neuen Block am Ende dieses StÅcks zu
 * belegen, um eine ÅbermÑûige Fragmentierung zu vermeiden. Vorsicht:
 * Sehr stark auf die MagiC-Speicherverwaltung zugeschnitten und
 * nicht unbedingt zur Nachahmung empfohlen.
 */
	if ((free - leave_free) >= (len + 16))
	{
		temp = _Mxalloc(free - len - 16, ram_type);
		if (temp != NULL)
		{
			block = _Mxalloc(len, 0x4000 | ram_type);
			Kfree(temp);
			if (block != NULL)
				return(block);
		}
	}
/*
 * Versuchen, einen Block der gewÅnschten Grîûe anzufordern; klappt
 * das nicht, muû NULL geliefert werden
 */
	if ((block = _Mxalloc(len, 0x4000 | ram_type)) == NULL)
		return(NULL);
/*
 * Sonst prÅfen, ob sich die LÑnge des grîûten verfÅgbaren
 * Speicherblock geÑndert hat. Falls nicht, kann der Block so als
 * Ergebnis geliefert werden. Dabei wird absichtlich nicht geprÅft,
 * ob der grîûte verfÅgbare Block noch groû genug ist, da seine LÑnge
 * durch unser Mxalloc ohnehin nicht beeinfluût wurde.
 */
	new_free = (LONG)_Mxalloc(-1L, ram_type);
	if (new_free == free)
		return(block);
/*
 * Hat sich die Grîûe jedoch verÑndert, muû der neue Wert noch groû
 * genug sein. Falls nicht, wird der Block wieder freigegeben und
 * NULL geliefert.
 */
	if (new_free < leave_free)
	{
		Kfree(block);
		return(NULL);
	}
/* Ansonsten ist alles OK, der Block ist damit das Ergebnis */
	return(block);
}

/*
 * Krealloc
 *
 * Funktion, um einen Speicherblock auf eine neue Grîûe zu bringen.
 * Dabei bleibt der alte Inhalt intakt (natÅrlich nur bis zum
 * Minimum aus alter und neuer LÑnge).
 *
 * Eingabe:
 * ptr: Bisheriger Zeiger auf den Speicherblock.
 * old_len: Alte LÑnge des Blocks.
 * new_len: Neue LÑnge des Blocks.
 *
 * RÅckgabe:
 * Entweder Zeiger auf neuen Speicherblock in gewÅnschter Grîûe, oder
 * NULL. In letzterem Fall ist der alte Pointer weiterhin gÅltig,
 * der Inhalt unverÑndert.
 */
void *Krealloc(void *ptr, LONG old_len, LONG new_len)
{
	char *new_ptr;

/*
 * Versuchen, einen Speicherblock der neuen Grîûe anzufordern;
 * notfalls gleich NULL liefern
 */
	if ((new_ptr = Kmalloc(new_len)) == NULL)
		return(NULL);
/*
 * Alle Bytes des alten Blocks, die in den neuen Block passen,
 * dorthin kopieren
 */
	memcpy(new_ptr, ptr, (old_len < new_len) ? old_len : new_len);
/* Bei Bedarf den noch freien Bereich des neuen Blocks lîschen */
	if (new_len > old_len)
	{
		(kernel->fast_clrmem)(&new_ptr[old_len],
			&new_ptr[new_len - 1L]);
	}
/* Alten Pointer freigeben */
	Kfree(ptr);
	return(new_ptr);
}

#ifdef DEBUG

#undef O_RDWR
#undef O_APPEND
#undef O_CREAT
#define O_RDWR		0x02
#define O_APPEND	0x08
#define O_CREAT		0x200

/*
 * trace
 *
 * Hilfsfunktion fÅr Debuggingzwecke, die Åber die Kernelfunktion
 * _sprintf einen Ausgabestring erzeugt und diesen dann in das
 * Logfile schreibt.
 *
 * Eingabe:
 * format: Formatstring, wie in der MagiC-Doku beschrieben.
 * params: Anzahl der Parameter, die noch folgen.
 * ...: Die Parameter fÅr den Formatstring, soweit nîtig.
 */
void trace(char *format, WORD params, ...)
{
	va_list		args;
	static char	output[128];
	static LONG	out[10];
	WORD		i,
				handle;
	LONG		err;

	va_start(args, params);
	params = (params > 10) ? 10 : params;
	for (i = 0; i < params; i++)
		out[i] = va_arg(args, LONG);
	va_end(args);
	(kernel->_sprintf)(output, format, out);
	if (debug_to_screen)
		Cconws(output);
	else
	{
		if ((err = Fopen(logfile, O_RDWR|O_APPEND|O_CREAT)) >= 0L)
		{
			handle = (WORD)err;
			Fwrite(handle, strlen(output), output);
			Fclose(handle);
		}
		else
			Cconws(output);
	}
}
#endif /* DEBUG */

/*
 * get_cookie
 *
 * PrÅft, ob ein bestimmter Cookie vorhanden ist
 * und liefert, wenn gewÅnscht, dessen Wert.
 *
 * Eingabe:
 * cookie: Zu suchender Cookie (z.B. 'MiNT')
 * value: Zeiger auf einen vorzeichenlosen Long,
 *        in den der Wert des Cookies geschrieben
 *        werden soll. Ist dies nicht gewÅnscht/
 *        erforderlich, einen Nullzeiger Åber-
 *        geben.
 *
 * RÅckgabe:
 * 0: Cookie nicht vorhanden, value unbeeinfluût
 * 1: Cookie vorhanden, Wert steht in value (wenn
 *    value kein Nullpointer ist)
 */
WORD get_cookie(ULONG cookie, ULONG *value)
{
    LONG    *jar,
            old_stack;
    
    /*
     * Den Zeiger auf den Cookie-Jar ermitteln,
     * dabei ggf. in den Supervisor-Modus
     * wechseln.
     */
    if (Super((void *)1L) == 0L)
    {
        old_stack = Super(0L);
        jar = *((LONG **)0x5a0L);
        Super((void *)old_stack);
    }
    else
        jar = *(LONG **)0x5a0;
    
    /*
     * Ist die "Keksdose" leer, gleich Null zu-
     * rÅckliefern, da ja gar kein Cookie
     * vorhanden ist.
     */
    if (jar == 0L)
        return(0);
    
    /*
     * Sonst den Cookie-Jar bis zum Ende durch-
     * suchen und im Erfolgsfall 1 zurÅckliefern.
     * Falls value kein Nullpointer war, vorher
     * den Wert des Cookies dort eintragen.
     */
    while (jar[0])
    {
        if (jar[0] == cookie)
        {
            if (value != 0L)
                *value = jar[1];
            
            return(1);
        }
        
        jar += 2;
    }
    /*
     * Bis zum Ende gesucht und nichts gefunden,
     * also 0 zurÅckgeben.
     */
    return(0);
}

/* EOF */
