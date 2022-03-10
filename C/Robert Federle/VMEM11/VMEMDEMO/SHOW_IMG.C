#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "vmem.h"

#define	MOUSEOFF	graf_mouse (256, NULL);
#define	MOUSEON		graf_mouse (257, NULL);

#define ULONG	unsigned long
#define WORD	unsigned int
#define CHAR	unsigned char

#define BREITE	64
#define	HOEHE	64

/* Funktionsprototypen der Unterprogramme */

void	decrunch	(CHAR *source, V_ADR virtmem);

int	work_in [12],	/* Globale Parameterfelder fÅr Workstation-Aufrufe */
	work_out [57],
	gl_apid,		/* Applikationsnummer */
	vdihandle;		/* Nr. der VDI-Workstation */


/* Ausgabe einer Fehlermeldung: */

void error (char *meldung)
{
	printf ("\n%s", meldung);
	getch ();
	v_clsvwk (vdihandle);
	wind_update (END_MCTRL);
	MOUSEON;
	appl_exit ();
	exit (1);
}


/* Darstellung und Scrollen des Bildschirms: */

int display (V_ADR virtmem, int breite, int hoehe)
{
	int		x, y, max_x, max_y;
	int		mx, my, button, key;
	int		flag;
	long	window;
	char	*data;
	V_ADR	virt;
	int		pxarray [8];
	MFDB	mfdb_src, mfdb_dest;

/* Startposition setzen */

	x = y = 0;

/* öberbreite und öberlÑnge ermitteln */

	max_x = breite - 80;
	if (hoehe >= 400)
	{
		max_y = hoehe - 400;
		hoehe = 400;
	}
	else
		max_y = 0;

	pxarray [0] = pxarray [4] = 0;
	pxarray [1] = pxarray [5] = 0;
	pxarray [2] = pxarray [6] = 639;
	pxarray [3] = pxarray [7] = 399;

	vs_clip (vdihandle, 1, pxarray);

	mfdb_src.fd_addr = NULL;
	mfdb_src.fd_w = breite << 3;
	mfdb_src.fd_h = hoehe;
	mfdb_src.fd_wdwidth = breite >> 1;
	mfdb_src.fd_stand = 1;
	mfdb_src.fd_nplanes = 1;
	mfdb_src.fd_r1 = mfdb_src.fd_r2 = mfdb_src.fd_r3 = 0;

	mfdb_dest.fd_addr = NULL;

/* Grîûe des Zugriffsfensters berechnen */
	
	window = (400L) * (ULONG) breite;

	flag = 1;
	MOUSEON;

	for (;;)
	{

/* Falls flag gesetzt ist, dann neuen Bildausschnitt darstellen */

		if (flag)
		{
			flag = 0;

/* Position innerhalb des virtuellen Speichers berechnen */

			virt = virtmem + (ULONG) y * (ULONG) breite + (ULONG) x;

/* Fenster anfordern */

			data = vm_address (virt, &window, READ_MODE);
			mfdb_src.fd_addr = data;
			if ((long) data < 0)
			{
				printf ("\033E\n");
				switch ((int) data)
				{
					case ILLEGAL_ADDRESS:
						printf ("Fehler: VM_ADDRESS erhielt eine illegale Adresse");
						return (0);
					case ILLEGAL_COUNT:
						printf ("Fehler: VM_ADDRESS wurde mit einer illegalen Windowgrîûe aufgerufen");
						return (0);
					case ILLEGAL_MODE:
						error ("Fehler: VM_ADDRESS wurde mit einem fehlerhaften Zugriffsmodus aufgerufen");
						return (0);
					default:
						printf ("Fehler: VM_ADDRESS liefert eine unbekannte Fehlernummer: %ld", data);
						return (0);
				}
			}


/* Darstellung des Ausschnitts */

			MOUSEOFF;
			vro_cpyfm (vdihandle, 3, pxarray, &mfdb_src, &mfdb_dest);
			MOUSEON;
		}

/* Beide Mausknîpfe abfragen */

		evnt_button (257, 3, 0, &mx, &my, &button, &key);

/* rechte Maustaste gedrÅckt ?? */

		if (button & 2)
		{
			MOUSEOFF;

/* Status der Sondertasten (Control, Alternate und Shift) zurÅckliefern */

			return (key & 0x0f);
		}

/* befindet sich der Mauszeiger im rechten Scrollabschnitt ?? */

		if ((mx >= (639 - BREITE)) && (x < max_x))
		{
			x += 2;			/* 16 Bit nach links scrollen */
			flag = 1;
		}

/* befindet sich der Mauszeiger im linken Scrollabschnitt ?? */

		if ((mx < BREITE) && (x > 0))
		{
			x -= 2;			/* 16 Bit nach rechts scrollen */
			flag = 1;
		}

/* befindet sich der Mauszeiger im unteren Scrollabschnitt ?? */
		
		if ((my >= (400 - HOEHE)) && (y < max_y))
		{
			y += 16;		/* 16 Zeilen nach oben */
			if (y > max_y)
				y = max_y;
			flag = 1;
		}

/* befindet sich der Mauszeiger im oberen Scrollabschnitt ?? */
		
		if ((my < HOEHE) && (y > 0))
		{
			y -= 16;		/* 16 Zeilen nach unten */
			if (y < 0)
				y = 0;
			flag = 1;
		}
	}
}


/* Einlesen der IMG-Datei, Aufruf der Scrollroutine, Sichern der BLD-Datei */

int mainrout (void)
{
	int		handle, button, ret_code;
	ULONG	size;
	ULONG	hoehe, breite;
	int		hoehe2, breite2;
	CHAR	*source;
	V_ADR	virtmem;
	TAB		parameter;
	char	pfad [128], name [128];		/* .IMG - Datei */
	char	pfad2 [128], name2 [128];	/* .BLD - Datei */
	char	filename [256], *position;

/* Virtuellen Speicher konfigurieren: */

	parameter.version = 0x100;			/* Version 1.00 */
	parameter.count_page = 512;			/* max. 512 virtuelle Seiten */
	parameter.cache_size = 6;			/* 6 Cache-Seiten */
	parameter.page_type = SIZE_32768;	/* 1 Seite = 32768 Bytes */
	parameter.fill_value = 0x0;			/* mit 0 initialisieren */
	parameter.drive_no = 3;		/* mit Laufwerk C arbeiten */

	ret_code = vm_config (&parameter);

	if ((ret_code < 0) && (ret_code > -256))
	{
		printf ("\nAchtung: Der Versuch, die temporÑre Datei anzulegen, ging schief !!");
		printf ("\nVermutliche Ursache: freier Speicher auf der Platte reicht nicht");
		error ("oder das Directory des gewÑhlten Laufwerks ist voll !!");
	}
	else
	{
		switch (ret_code)
		{
			case OK:
				break;
			case NO_LIST:
				error ("Es befindet sich keine Cookiejar-Liste im Speicher");
			case NOT_FOUND:
				error ("VMEM ist noch nicht installiert worden");
			case WRONG_CACHE_SIZE:
				error ("Die gewÑhlte Cache-Grîûe ist zu klein");
			case WRONG_PAGE_TYPE:
				error ("PAGE_TYPE enthÑlt einen illegalen Wert");
			case OUT_OF_MEMORY:
				printf ("\nDer zur VerfÅgung stehende freie Speicher reicht nicht aus");
				error ("Dieses Demo benîtigt mindestens 200 KByte Speicher");
			case ILLEGAL_DRIVE:
				error ("Das gewÅnschte Laufwerk existiert nicht");
			case ILLEGAL_FATSIZE:
				error ("Fehler: das gewÅnschte Laufwerk verwendet eine FAT, die von VMEM nicht unterstÅtzt wird");
			default:
				printf ("\nEin unbekannter Fehler ist aufgetreten: %d", ret_code);
				exit (1);
		}
	}

/* Pfadnamen und Filenamen initialisieren */

	strcpy (pfad, "C:\\*.IMG");
	strcpy (pfad2, "C:\\*.BLD");
	name [0] = name2 [0] = '\0';

	for (;;)
	{

/* Quell-Datei (IMG) ermitteln */

		MOUSEON;
		fsel_input (pfad, name, &button);
		MOUSEOFF;
		v_clrwk (vdihandle);		/* Bildschirm lîschen */

		if (button == 0)			/* Abbruch - Knopf gewÑhlt ?? */
		{
			vm_close ();			/* dann virtuellen Speicher entfernen */
			return (0);				/* und Unterprogramm beenden */
		}

/* Filenamen und Pfad zusammensetzen */

		strcpy (filename, pfad);
		position = strrchr (filename, '\\') + 1;
		strcpy (position, name);

/* Datei îffnen */

		handle = Fopen (filename, 0);
		if (handle < 0)
		{
			printf ("\033E\nFehler: Datei <%s> nicht gefunden !!");
			return (2);
		}

/* Dateigrîûe ermitteln */

		size = Fseek (0, handle, 2);
		Fseek (0, handle, 0);

/* Pufferspeicher anfordern */
	
		source = (CHAR *) Malloc (size);
		if (source == NULL)
		{
			printf ("\033E\nFehler: Puffer (%ld Bytes) kann nicht angelegt werden wegen Speichermangel", size);
			return (3);
		}

/* Datei in den Puffer einlesen */
	
		if (Fread (handle, size, source) != size)
		{
			printf ("\033E\nLese-Fehler: Datei eventuell defekt !!");
			return (4);
		}

/* Datei schlieûen */
		
		Fclose (handle);
	
/* Daten ausgeben: */
	
		printf ("\033EGepackt:  %lu Bytes", size);
	
		breite = ((ULONG) (*(source + 12))) * 256;
		breite += (ULONG) (*(source + 13));
	
		hoehe = ((ULONG) (*(source + 14))) * 256;
		hoehe += (ULONG) (*(source + 15));
	
		printf ("\nHîhe:     %lu Pixel", hoehe);
		printf ("\nBreite:   %lu Pixel", breite);

/* Pixel-Breite auf volle WORD-Grîûe erweitern */

		breite = ((breite - 1) | 0x0f) + 1;
		size = (breite >> 3) * hoehe;
	
		printf ("\nEntpackt: %lu Bytes", size);

		printf ("\n\nAnforderung von %ld Bytes virtuellem Speicher", size);

/* virtuellen Speicher anfordern: */

		virtmem = vm_alloc (size);

/* konnte Speicher angelegt werden ?? */

		if (virtmem == _NULL)
		{
			printf ("\033E\nFehler: nicht genÅgend Platz auf der Platte");
			printf ("\nDieses Bild benîtigt %ld Bytes freien Speicher", size);
			return (5);
		}

		else

/* Bild in den virtuellen Speicher entpacken: */

		{
			printf ("\n\nEntpacke das Bild...");
			decrunch (source, virtmem);
		}

/* Freigeben des physikalischen Speichers: */

		Mfree (source);

		printf ("\033E");

/* Darstellen des Bildes: */

		if (display (virtmem, (int) (breite  >> 3), (int) hoehe))
		{

/* Pfad und Namen der BLD-Datei ermitteln */

			MOUSEON;
			fsel_input (pfad2, name2, &button);
			MOUSEOFF;
			v_clrwk (vdihandle);

/* OK - Button gewÑhlt ?? */
		
			if (button)
			{

/* Dateinamen zusammensetzen */

				strcpy (filename, pfad2);
				position = strrchr (filename, '\\') + 1;
				strcpy (position, name2);

/* Datei anlegen */

				handle = Fcreate (filename, 0);
				if (handle < 0)
				{
					printf ("\033E\nFehler: konnte Datei <%s> nicht anlegen !!", filename);
					return (6);
				}

/* Hîhe und Breite des Bildes berechnen */
			
				breite2 = (int) breite;
				hoehe2 = (int) (hoehe - 1);

/* Format-Daten schreiben */
			
				Fwrite (handle, 2, &breite2);
				Fwrite (handle, 2, &hoehe2);

/* Bild-Daten schreiben (ungepackt !!) */
			
				if (vm_write (handle, size, virtmem) != size)
				{
					printf ("\033E\nFehler: konnte das entpackte Bild (%ld Bytes) nicht schreiben", size);
					printf ("\nVermutliche Ursache: Platz auf der Platte reicht nicht");
				}
				else

/* Datei schlieûen */
			
					Fclose (handle);
			}
		}

/* Virtuellen Speicher freigeben: */

		vm_free (virtmem);

/* Cache neu initialisieren: */

		vm_clrcache ();
	}
}


int main (void)
{
	int	retcode, i, dummy;

/* Initialisierung der Applikation und der Workstation */
	
	gl_apid = appl_init ();
	for (i = 1; i < 10; work_in [i++] = 0)
		;
	work_in [10] = 2;
	work_in [0] = vdihandle = graf_handle (&dummy, &dummy, &dummy, &dummy);
	MOUSEOFF;
	wind_update (BEG_MCTRL);
	v_opnvwk (work_in, &vdihandle, work_out);
	printf ("\033E");

/* Aufruf der Unterroutine */

	if ((retcode = mainrout ()) != 0)
		getch ();

/* Schlieûen der Workstation und Beenden der Applikation */

	v_clsvwk (vdihandle);
	wind_update (END_MCTRL);
	MOUSEON;
	appl_exit ();

	return (retcode);
}
