/*
	LEDPANEL.H - Kontroll-Struktur fr das LED-Panel

	Die folgende C-Struktur dient gleichzeitig als Patch-Area
	fr die Voreinstellungen und zur Kontrolle des LED-Panels
	durch externe Programme, etwa ein Accessory oder CPX-Modul.
	Der 'LEDP'-Cookie enth„lt einen Zeiger auf diese Struktur.
*/

#define LEDP_MAGIC 'LEDP'
#define LEDP_VERSION 0x0209
#define LEDP_VERDATE 0x04011995L
#define LEDP_VARLEN 0x20

typedef struct
{
	struct
	{
		long magic; /* magische Zahl MAGIC */
		int version; /* Versionsnummer und */
		long verdate; /* Datum des LED-Panels */
		int varlen; /* L„nge der Patch-Area in Bytes */
		int light; /* Flag fr "light"-Version */
	}	header;
	int active; /* Flag fr Anzeige aktiv */
	long ledbits; /* gew„hlte Laufwerke */
	int alldrvs; /* Flag fr angemeldete Laufwerke */
	int delay; /* Nachleuchtdauer der LEDs in VBLs */
	struct
	{
		int top; /* Abstand zum oberen Rand in Zeilen */
		int right; /* Abstand zum rechten Rand in Bytes */
	}	margin;
	struct
	{
		res1: 7; /* reserviert */
		bgcol: 1; /* Hintergrundfarbe des Panels */
		res2: 3; /* reserviert */
		ledfrm: 1; /* Flag fr runde LEDs */
		res3: 3; /* reserviert */
		ledcol: 1; /* Flag fr farbige LEDs */
	}	color;
	struct
	{
		lftspc: 1; /* linker Rand */
		caps: 1; /* CapsLock-Anzeige */
		cpspc: 1; /* Lcke zwischen R/W und CapsLock */
		rwsym: 1; /* R/W-Symbol */
		rwspc: 1; /* Lcke zwischen LEDs und R/W-Symbol */
		onlya: 1; /* Floppys zusammenfassen */
		hrdspc: 1; /* Extra-Lcke vor Harddisk */
		ramspc: 1; /* Extra-Lcke vor RAM-Disk */
		allspc: 1; /* Extra-Lcken zwischen Laufwerken */
		frespc: 1; /* Lcken fr freie Laufwerke zeigen */
		leds: 1; /* LED-Panel anzeigen */
		datspc: 1; /* Abstand zwischen Uhr/Datum und LEDs */
		date: 1; /* Datum */
		clock: 1; /* Uhrensymbol */
		time: 1; /* Uhrzeit */
		rgtspc: 1; /* rechter Rand */
	}	setup;
	int lines; /* Anzahl LED-Zeilen (1/2 oder 0=auto) */
	struct
	{
		char year,sec; /* Flag fr Jahr/Sekunden anzeigen */
	}	dtverb;
	struct
	{
		char date,time; /* Null-Zeichen fr Datum/Uhrzeit */
	}	zero;
	struct
	{
		char off,on; /* Symbol fr Uhrzeit aus/an */
	}	clock;
	struct
	{
		char off,on; /* Symbol fr CapsLock aus/an */
	}	caps;
	struct
	{
		char caps,shft; /* Maske fr CapsLock/Umschalt-Taste */
	}	keymask;
	struct
	{
		char hrd,ram; /* erstes Laufwerk der Harddisk/RAM-Disk */
	}	fstdrv;
	struct
	{
		int x,y,w,h; /* letztes benutztes Rechteck */
	}	lstrect;
	struct
	{
		char *pointer; /* Zeiger auf zu berwachendes Byte */
		char check; /* Default fr zu berprfendes Byte */
		char last; /* letzter Wert des Bytes */
		char andmask; /* Und-Maske zum Zurcksetzen */
		char ormask; /* Oder-Maske zum Zurcksetzen */
		char restime; /* Zeit zum Zurcksetzen */
		char counter; /* Z„hler dafr */
		char bit0; /* Zeichen fr 0-Bit */
		char bit1; /* Zeichen fr 1-Bit */
		char bytelft; /* Zeichen links vom Byte */
		char bytergt; /* Zeichen links vom Byte */
	}	watch;
}	LEDP;

/*
	Offsets (dezimal)
	-----------------

	0 header			32 lines
		0 magic			34 dtverb
		4 version		36 zero
		6 verdate		38 clock
		10 varlen		40 caps
		12 light		42 keymask
	14 active			44 fstdrv
	16 ledbits			46 lstrect
	20 alldrvs			54 watch
	22 delay				54 pointer
	24 margin				58 check
		24 top				60 andmask
		26 right			62 restime
	28 color				64 bit0
	30 setup				66 bytelft
*/

/*
	Hinweise
	--------

	magic: XBRA-Kennung des LED-Panels
	varlen: L„nge der zu speichernden Variablen ab Header
	active:	Bit 0: Anzeige ein/ausschalten,
			Bit 15: Anzeige auffrischen
	dtverb: Die "two in one"-Funktion zum Einblenden des
		Datums anstelle der Zeit wird aktiviert durch L”schen
		des "date"-Flags und Setzen des "year"-Flags
	lastrect: Letztes zur Anzeige benutztes Grafik-Rechteck
	watch: Fr Programmierer zu Debugging-Zwecken,
			hiermit kann ein Byte berwacht werden
		pointer: Zeiger auf das Byte, man mu natrlich	global
			(im Supervisor-Modus) darauf zugreifen k”nnen
		check: Unbenutzt, man kann den obigen Zeiger darauf
			zeigen lassen (Zugriff garantiert erlaubt)
		andmask: Nachdem ein Z„hler abgelaufen ist, wird
			eine Und-Operation mit dieser Maske durchgefhrt,
		ormask: zus„tzlich auch noch eine Oder-Operation
		restime: Startwert fr den Z„hler in VBLs (falls 0,
			dann wird das Byte nie ver„ndert)
		bit0/bit1: Zeichen fr 0-Bit und 1-Bit
		bytelft/bytergt: Zeichen fr Umrahmung des Bytes
	
	Vorgehensweise beim Ver„ndern von Parametern:

	1. Header berprfen (magic, version)
	2. LED-Panel abschalten (active=0)
	3. nderungen an der Konfiguration vornehmen
	4. Grafik-Rechteck (lstrect) l”schen
	5. LED-Panel einschalten und auffrischen (active=0x8001)

*/
