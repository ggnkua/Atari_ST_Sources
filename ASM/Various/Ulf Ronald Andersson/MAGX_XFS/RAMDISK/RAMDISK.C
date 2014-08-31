/*
 * ramdisk.c vom 21.07.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * C-Quellcode des Ramdisk-Filesystems fÅr MagiC 3, das auf der
 * Pure-C-Schnittstelle aufbaut. Hier finden sich die Routinen, die
 * vom Kernel (indirekt Åber die Schnittstelle) aufgerufen werden,
 * also die Elemente der THE_MGX_XFS- und THE_MGX_DEV-Strukturen
 * darstellen.
 * Anmerkung: Dieser Quellcode stellt keinen Ersatz fÅr die MagiC-
 * Doku dar; nur zusammen mit ihr wird man alles nachvollziehen
 * kînnen (hoffentlich). Deshalb haben nur die Funktionen in
 * ramutil.c Header, die die genaue Funktionsweise erklÑren. Hier
 * hÑtte ich prinzipiell die Doku abtippen mÅssen, was ich aus
 * verstÑndlichen GrÅnden nicht gemacht habe; es wird nur erklÑrt,
 * was allgemein beachtenswert und was fÅr die Ramdisk nîtig ist.
 * Man bekommt die Doku Åbrigens als registrierter MagiC-Benutzer
 * direkt von ASH (wohl auch in der Mailbox).
 *
 * History:
 * 05.11.-
 * 25.11.1995: Erstellung (mit Unterbrechungen)
 * 27.11.1995: Fehler in dfree-Funktion behoben und Cconws bei
 *             check_name wieder in TRACE geÑndert.
 * 03.12.1995: datime eingebaut, chmod und attrib jetzt auch fÅr .
 *             und .., TRACE fÅr restliche dev-Funktionen eingebaut,
 *             "not supported"-Meldung bei TRACE von (noch) nicht
 *             unterstÅtzten Funktionen.
 * 04.12.1995: ramdisk_seek hat bei BereichsÅberschreitungen bisher
 *             "geclippt", jetzt wird korrekt ERANGE geliefert und
 *             der Positionszeiger nicht verÑndert.
 *             Beim Erweitern eines Verzeichnisses wird jetzt korrekt
 *             um DEFAULTDIR EintrÑge aufgestockt.
 * 04.12.-
 * 05.12.1995: Dateien werden jetzt anders verwaltet: Sie bestehen
 *             jeweils aus einzelnen Blîcken a DEFAULTFILE Bytes, die
 *             miteinander verkettet sind (sie sind also eigentlich
 *             noch sizeof(char *) Bytes lÑnger). Dadurch sollte sich
 *             die Speicherfragmentierung vor allem bei Dateien, die
 *             in kleinen Schritten geschrieben werden, deutlich
 *             verringern. Auûerdem wird es dadurch erst mîglich,
 *             Dateien zu erweitern, die lÑnger als der im Moment
 *             noch (an einem StÅck) freie Speicher sind. Der groûe
 *             Nachteil soll aber nicht verschwiegen werden: Die
 *             Geschwindigkeit beim Lesen und insbesondere beim
 *             Schreiben nimmt ab; trotzdem ist die Ramdisk beim
 *             Lesen noch schneller als eine "konventionelle" Ramdisk
 *             (gemessen mit How-Fast).
 *             An einigen Stellen Tests auf x-Bit eingebaut, falls
 *             sie noch gefehlt haben.
 * 06.12.1995: In link wurde der neue Name in TOS-Schreibweise
 *             gewandelt, wenn die TOS-Domain aktiv war. Da neue
 *             Namen aber eigentlich nie gekÅrzt werden, ist dies
 *             jetzt entfernt worden. Dabei wurde gleichzeitig noch
 *             ein weiterer Fehler innerhalb von link entfernt: Wenn
 *             die TOS-Domain aktiv war, wurde beim Verschieben der
 *             Datei der neue Name nicht in Kleinbuchstaben
 *             gewandelt (diese énderung an Filenamen in der
 *             TOS-Domain ist sinnvoll, da dort in der Regel komplett
 *             groû geschriebene Namen geliefert werden).
 * 09.12.1995: readlabel liefert jetzt EFILNF zurÅck, um korrekt
 *             anzuzeigen, daû kein Label vorhanden ist bzw. sein
 *             kann.
 * 11.12.1995: writelabel liefert jetzt EACCDN statt EINVFN, um
 *             anzuzeigen, daû keine Labels unterstÅtzt werden.
 *             In attrib wurde beim éndern des Attributs FA_CHANGED
 *             versehentlich xattr.mode statt xattr.attr verÑndert.
 *             fd_refcnt des Root-dd wird jetzt auf 1 gesetzt, da
 *             MagiC dies ab Kernelversion 3 voraussetzt.
 *             In ddelete wird nur noch dann der refcnt selbst
 *             geprÅft und freigegeben, wenn die Kernelversion
 *             kleiner als 3 ist.
 *             Bei Neuanlage oder "Truncation" eines Files wird jetzt
 *             automatisch das FA_CHANGED-Attribut gesetzt.
 * 26.12.1995: Neuprogrammierung von path2DD, mit der Hoffnung auf
 *             weniger FÑlle, in denen sich ein Verzeichnis angeblich
 *             nicht lîschen lÑût.
 * 27.12.1995: Einige dumme Fehler im neuen path2DD ausgebaut.
 *             trace gibt jetzt in ein File aus. Wird beim Start des
 *             XFS eine Umschalttaste gedrÅckt, erscheinen die Debug-
 *             ausgaben wie vorher direkt auf dem Bildschirm.
 *             findfile um Parameter maybe_dir erweitert, mit dem
 *             festgelegt wird, ob bei leerem Suchnamen das aktuelle
 *             Verzeichnis geliefert werden soll.
 *             findfile und die Aufrufe leicht geÑndert: tostrunc
 *             heiût jetzt s_or_e und legt fest, ob eine Datei zum
 *             ôffnen gesucht wird (== FF_SEARCH), oder ob nur
 *             getestet werden soll, ob die Datei existiert (dann ist
 *             s_or_e == FF_EXIST, was beim Neuanlegen von Files
 *             wichtig ist).
 *             link arbeitet jetzt endlich ganz richtig (hoffe ich
 *             zumindest...)
 *             Kmalloc ist jetzt eine Funktion, die darauf achtet,
 *             daû der grîûte freie Block mindestens leave_free Bytes
 *             lang ist. Soll Kmalloc den grîûten freien Block
 *             ermitteln, wird dessen LÑnge abzÅglich leave_free
 *             geliefert, ggf. 0L.
 * 28.12.1995: Bei ddelete fehlte der Test, ob Schreibrechte fÅr das
 *             aktuelle Verzeichnis vorhanden sind.
 *             Neue Funktion work_entry, die einen Verzeichniseintrag
 *             bearbeitet. Sie erhÑlt dazu eine Funktion als
 *             Parameter, die die gewÅnschten énderungen vornimmt.
 *             Das besondere an der Funktion ist, daû sie bei
 *             Verzeichnissen dafÅr sorgt, daû alle EintrÑge, die
 *             dieses Directory reprÑsentieren, angepaût werden (also
 *             der Eintrag selbst, . innerhalb des dazugehîrigen
 *             Verzeichnisses und .. von allen Unterverzeichnissen).
 *             Damit werden hoffentlich bald atime/adate und mtime/
 *             mdate von Verzeichnissen gesetzt.
 *             UnterstÅtzung des Dcntl-Kommandos FUTIME sowie der
 *             Fcntl-Kommandos FSTAT, FIONREAD, FIONWRITE und FUTIME.
 * 29.12.1995: Angefangen, atime/adate und mtime/mdate auch bei
 *             Verzeichnissen zu verwalten.
 *             work_entry verfolgt symbolische Links nicht mehr, wenn
 *             fÅr symlink ein Nullzeiger Åbergeben wird.
 *             Bei write wird nicht mehr die Zugriffszeit geÑndert,
 *             sondern nur noch die Modifikationszeit.
 * 30.12.1995: VervollstÑndigung von Zugriffs/Modifikationszeit von
 *             Verzeichnissen.
 *             Bei Debug in Datei wird jetzt die alte Datei umbenannt
 *             und nicht mehr gelîscht.
 *             Bei fopen fehlte der Test, ob es sich Åberhaupt um
 *             eine Datei und nicht etwa um ein Verzeichnis handelt.
 *             Das war hoffentlich der Grund fÅr die sporadischen
 *             EACCDNs bei ddelete...
 *             In readlink wird jetzt die Zugriffszeit angepaût.
 *             Bessere (richtige) öberprÅfung des x-Flags von
 *             Verzeichnissen (jetzt in findfile und new_file).
 *             Tracemeldungen erweitert.
 *             Aufsplittung in mehrere Dateien.
 *             Test auf x-Bit in xattr entfernt.
 *             Modus 7 von Dpathconf liefert jetzt korrekt die
 *             unterstÅtzten GEMDOS-Attribute.
 *             Beginn der Kommentierung.
 * 31.12.1995: DD-Verwaltung umgestellt. Durch das neue Element
 *             fd_is_parent wird jetzt beim ZurÅckliefern eines DD
 *             in path2DD vermerkt, wie oft die Eltern-DDs schon
 *             Eltern sind. Dabei werden ihre is_parent-ZÑhler
 *             jeweils um eins erhîht, wenn der neue DD bisher noch
 *             nicht benutzt war. Dies wird durch die neue Funktion
 *             increase_refcnts in ramutil.c erledigt, die auch den
 *             refcnt des neuen DDs erhîht.
 *             Dementsprechend ist auch die Freigabe von DDs durch
 *             freeDD abgeÑndert worden. Das neue Verfahren sollte
 *             wesentlich zuverlÑssiger sein und keine DDs freigeben,
 *             die noch in Benutzung sind. Umgekehrt sollten auch
 *             keine "Leichen" mehr dauerhaft bestehen bleiben.
 *             path2DD an neues Parameterlayout angepaût.
 *             sfirst verlangt jetzt nur noch dann Leserechte fÅr das
 *             Verzeichnis, wenn die Maske Wildcards enthÑlt.
 *             fopen liefert jetzt bei FA_LABEL im Attribut EACCDN
 *             statt EINVFN.
 * 01.01.1996: Nein, ich habe nicht in's neue Jahr 'reinprogrammiert,
 *             sowas Åberlasse ich gerne anderen ;)
 *             WeiterfÅhrung der ausfÅhrlichen Kommentierung.
 *             In dcreate wurde prepare_dir mit einem falschen Wert
 *             fÅr parent aufgerufen. Nichts weltbewegendes, es war
 *             aber ein Fehler...
 *             In link kann jetzt (wieder) ein Verzeichnis innerhalb
 *             der Ordnerhierarchie verschoben werden. Jetzt wird
 *             aber auch der de_faddr-Eintrag von ".." des
 *             betroffenen Verzeichnisses angepaût.
 *             An einigen Stellen unnîtige Tests entfernt, die schon
 *             erfolgt sind bzw. noch bei anderer Gelegenheit
 *             erfolgen (im Programmablauf, versteht sich).
 *             In chmod wird jetzt work_entry so aufgerufen, daû
 *             symoblische Links erkannt werden, sonst aber EINVFN
 *             geliefert wird.
 *             In fopen fehlten die Tests, ob der neue Name "." oder
 *             ".." ist und ob das aktuelle Verzeichnis noch geîffnet
 *             ist.
 *             Bei fdelete fehlte ebenfalls der Test, ob das aktuelle
 *             Verzeichnis noch offen ist.
 *             snext liefert jetzt EFILNF statt ENMFIL, wenn es der
 *             erste Aufruf mit dieser DTA ist, wenn also eigentlich
 *             ein Fsfirst bedient wird.
 * 02.01.1996: Immer noch Kommentierung *stîhn*
 *             get_size hatte noch einen kleinen Fehler, die
 *             bisherige Blockzahl wurde doppelt gezÑhlt. Da diese
 *             aber sowieso vîllig ÅberflÅssig ist, wurde der
 *             Parameter weggelassen.
 *             Nochmaliges Studium der Doku hat ergeben, daû der
 *             Kernel Fcreate und Fsfirst mit Attribut FA_LABEL schon
 *             selbst auf rlabel und wlabel zurÅckfÅhrt, daher sind
 *             die entsprechenden Abfragen in fopen und sfirst
 *             entfernt worden.
 *             Eine sinnlose GrîûenbeschrÑnkung von symbolischen
 *             Links entfernt (was hatte ich mir dabei bloû gedacht?)
 *             readlink etwas verbessert (kaum der Rede wert).
 *             In read und write werden jetzt bei falschen Zugriffen
 *             echte Fehler gemeldet und nicht nur, daû nur 0 Bytes
 *             gelesen bzw. geschrieben wurden.
 *             Die do...while-Schleifen in read und write durch
 *             while-Schleifen ersetzt, weil ja denkbar ist, daû
 *             tatsÑchlich nur 0 Bytes gelesen bzw. geschrieben
 *             werden sollen.
 *             datime ist jetzt FUTIME-kompatibel, d.h. ctime und
 *             cdate werden auf die aktuelle Zeit/das aktuelle Datum
 *             gesetzt.
 *             Fcntl mit FIONWRITE liefert jetzt einen zuverlÑssigen
 *             Wert zurÅck.
 * 03.01.1996: getline funktioniert jetzt richtig.
 *             Sind bei fopen O_CREAT und O_EXCL gesetzt, darf die
 *             Datei nicht existieren; daher wird in diesem Fall
 *             jetzt EACCDN geliefert.
 * 20.01.1996: Die restlichen static-chars durch entsprechende
 *             int_malloc-Aufrufe ersetzt. Die Ramdisk ist dadurch
 *             jetzt voll reentrant.
 * 29.01.1996: Wird sfirst ohne Wildcards aufgerufen, wird direkt
 *             nach der Datei gesucht, ohne den Umweg Åber snext zu
 *             gehen. Somit klappt dann auch das Umbennenen bereits
 *             existierender Files beim Kopieren mit Gemini, das
 *             (zumindest bei dieser Gelegenheit) intelligenterweise
 *             Fsfirst statt Fxattr benutzt, um auf Existenz einer
 *             Datei zu prÅfen. Die énderung hilft auch bei Ñlteren
 *             Programmen, die eine als Argumente Åbergebene Datei
 *             per Fsfirst suchen.
 *             In link wurde bisher nicht geprÅft, ob der neue Name
 *             nicht erlaubte Zeichen enthÑlt.
 * 30.01.1996: Wird eine Datei mit O_CREAT, O_TRUNC und OM_WPERM
 *             geîffnet, versucht die Ramdisk in TOS-Domain-Prozessen
 *             nicht mehr, das File mit 8+3-Vergleich zu finden.
 * 12.02.1996: path2DD Åberliest jetzt mehrfache Backslashes.
 * 18.02.1996: In link kann es jetzt nicht mehr passieren, daû ein
 *             Verzeichnis in eines seiner "Nachfahren" verschoben
 *             wird.
 * 26.02.1996: UnterstÅtzung von Volume Labels.
 * 02.05.1996: Leider befand sich in der Neufassung von path2DD noch
 *             ein saudummer Fehler, durch den symbolische Links
 *             nicht (mehr) funktionierten...
 * 16.06.1996: Bei drv_open werden jetzt auch d_driver und d_devcode
 *             initialisiert.
 * 21.07.1996: Kleinere Optimierungen in ramdisk_write, die leider
 *             keine spÅrbare Verbesserung der Schreibgeschwindigkeit
 *             bringen :(
 */

#include <string.h>
#include "ramdisk.h"

#pragma warn -par

/*
 * Dieses vielleicht etwas ungeschickte Makro ermîglicht es, den
 * RÅckgabewert jeder Funktion automatisch zu protokollieren
 */
#ifdef DEBUG
#define return(x)	{LONG abccba = (LONG)(x);\
	TRACE(("return(%L), Zeile %L\r\n", 2, abccba,\
		(LONG)__LINE__));\
	return(abccba);}
#endif

/*
 * Um das Syncen brauchen wir uns keine Sorgen zu machen, da die
 * Ramdisk ja keinerlei Caches benutzt (im Prinzip ist sie ein
 * einziger, groûer Cache ;)
 */
LONG ramdisk_sync(DMD *d)
{
	TRACE(("sync\r\n", 0));
	return(E_OK);
}

/*
 * Wird ein Programm beendet, muû geprÅft werden, ob es offene
 * Directories "hinterlassen" hat. Wenn ja, sind diese natÅrlich
 * ungÅltig und die zugehîrige Struktur muû freigegeben werden.
 * Hatte man bei dopendir Speicher angefordert, muû dieser natÅrlich
 * dem System zurÅckgegeben werden.
 */
void ramdisk_pterm(BASPAG *pd)
{
	WORD	i;

	TRACE(("pterm\r\n", 0));
	for (i = 0; i < MAX_DHD; i++)
	{
		if (dhd[i].dhd_owner == pd)
			dhd[i].dhd_dir = NULL;
	}
}

/*
 * Eine Garbage Collection brauchen wir auch nicht, weil die Ramdisk
 * nichts dauerhaft per int_malloc anfordert. Zwar kînnte man in der
 * echten XFS-Struktur (also in *real_xfs) fÅr garbcoll einen NULL-
 * Zeiger eintragen, allerdings halte ich es nicht fÅr so schlimm,
 * eine Leerfunktion einzubauen. An *real_xfs sollte man Åbrigens
 * besser nichts verÑndern, wenn einem die FunktionsfÑhigkeit seines
 * XFS am Herzen liegt...
 */
LONG ramdisk_garbcoll(DMD *d)
{
	TRACE(("garbcoll\r\n", 0));
	return(E_OK);
}

/*
 * Die DDs des Ramdisk-XFS sind rÅckwÑrts Åber den fd_parent-Zeiger
 * verkettet. Intern wird dabei Åber fd_is_parent gezÑhlt, von wie
 * vielen DDs ein anderer der Parent ist. Wenn der Kernel freeDD
 * aufruft, darf der DD also nur dann wirklich freigegeben werden,
 * wenn der is_parent-ZÑhler 0 ist. Ebenso werden alle weiter hinten
 * liegenden DDs freigegeben, wenn ihr is_parent-ZÑhler nach
 * Erniedrigung um Eins und der refcnt-ZÑhler gleich Null sind.
 * Auûerdem werden hier alle DDs freigegeben, deren fd_file nicht
 * NULL ist, obwohl refcnt und is_parent 0 sind. Dies sind Leichen,
 * die bei path2DD auftreten kînnen, wenn beim weiteren Parsen ein
 * Fehler aufgetreten ist.
 */
void ramdisk_freeDD(void *dd)
{
	RAMDISK_FD	*i;
	WORD		j;

	TRACE(("freeDD - DD = %L\r\n", 1, dd));
	i = (RAMDISK_FD *)dd;
/* Sicherstellen, daû der DD auch wirklich freigegeben werden soll */
	if (i->fd_refcnt != 0)
	{
		TRACE(("freeDD: fd_refcnt == %L!\r\n", 1, (LONG)i->fd_refcnt));
		return;
	}
/*
 * Den aktuellen is_parent-ZÑhler um Eins erhîhen, da er in der
 * Schleife vermindert wird. Auf diese Weise wird nur eine Schleife
 * gebraucht und trotzdem korrekt ÅberprÅft, ob der vom Kernel
 * freizugebende DD kein Eltern-DD eines anderen mehr ist.
 */
	i->fd_is_parent++;
	while (i != NULL)
	{
		if (i->fd_is_parent)
			i->fd_is_parent--;
/* Nur freigeben, wenn is_parent und refcnt Null sind */
		if (!i->fd_is_parent && !i->fd_refcnt)
		{
			TRACE(("freeDD: Gebe DD %L frei!\r\n", 1, i));
			i->fd_file = NULL;
		}
/*
 * Den nÑchsten DD in der rÅckwÑrts verketteten Liste wÑhlen. Der
 * parent des Root-DDs, der auf jeden Fall erreicht wird, ist NULL,
 * was die Abbruchbedingung der Schleife ist.
 */
		i = i->fd_parent;
	}
/*
 * Die "Leichen" freigeben; also alle DDs, die nicht frei sind,
 * obwohl refcnt und is_parent beide Null sind
 */
	for (j = ROOT + 1; j < MAX_FD; j++)
	{
		if ((fd[j].fd_file != NULL) && !fd[j].fd_refcnt &&
			!fd[j].fd_is_parent)
		{
			TRACE(("freeDD: Gebe \"Leichen\"-DD %L frei!\r\n", 1,
				&fd[j]));
			fd[j].fd_file = NULL;
		}
	}
}

/*
 * FÅr drv_open muû eine statische Variable gefÅhrt werden, die
 * angibt, ob die Ramdisk bereits erfolgreich geîffnet wurde (bei
 * Diskwechseln ist d_xfs ja NULL, der Inhalt der Ramdisk hat sich
 * aber nicht geÑndert). Wichtig ist auch, daû fÅr d_xfs der Zeiger
 * real_xfs aus pc_xfs.h eingetragen wird, da ramdisk_xfs nicht die
 * Struktur ist, die vom Kernel angesprochen werden soll.
 */
LONG ramdisk_drv_open(DMD *d)
{
	static WORD	opened_once = 0;

	TRACE(("drv_open - drive %L\r\n", 1, (LONG)d->d_drive));
	if (d->d_xfs == NULL)
	{
/* PrÅfen, ob sich drv_open auf unser Ramdisk-Laufwerk bezieht */
		if (d->d_drive == ramdisk_drive)
		{
/* Wie gesagt: Unbedingt real_xfs fÅr d_xfs eintragen! */
			d->d_xfs = real_xfs;
			d->d_root = &fd[ROOT];
			d->d_biosdev = -1;
			d->d_driver = d->d_dfs = 0L;
			d->d_devcode = 0L;
			if (!opened_once)
			{
/*
 * Wurde die Ramdisk das erste Mal geîffnet, mÅssen FDs, DHDs und das
 * Wurzelverzeichnis gelîscht sowie einige wichtige Strukturen
 * vorbereitet werden
 */
				opened_once = 1;
				(kernel->fast_clrmem)(root, &root[ROOTSIZE]);
				prepare_dir(root, ROOTSIZE, ROOT_DE);
				(kernel->fast_clrmem)(dhd, &dhd[MAX_DHD]);
				(kernel->fast_clrmem)(fd, &fd[MAX_FD]);
				fd[ROOT].fd_dmd = ramdisk_dmd = d;
				fd[ROOT].fd_file = &root_de;
				fd[ROOT].fd_parent = NULL;
				fd[ROOT].fd_refcnt = 1;
				root_de = root[1];
				strcpy(root_de.de_fname, "");
				root_de.de_faddr = (char *)root;
			}
/*
 * Diskwechsel kînnen ja nicht vorkommen (das ist ja der Zweck von
 * drv_open nach dem ersten ôffnen), also wird immer E_OK geliefert
 */
			return(E_OK);
		}
		else
/* War es das falsche Laufwerk, EDRIVE liefern */
			return(EDRIVE);
	}
/*
 * Gleiches gilt, wenn - aus welchem Grund auch immer -, d_xfs nicht
 * mehr auf den richtigen Wert (real_xfs, nicht &ramdisk_xfs!) zeigt.
 * Das kann eigentlich nur passieren, wenn die Ramdisk auf einem
 * Laufwerk angemeldet wurde, das jetzt von einem anderen XFS
 * beansprucht wird.
 */
	if (d->d_xfs != real_xfs)
		return(EDRIVE);
	return(E_OK);
}

/*
 * Bei drv_close mÅssen nur noch die Directory-Handles ÅberprÅft
 * werden, da DDs schon vom Kernel ÅberprÅft werden. Wird ein noch
 * offenes Directory gefunden, wird bei mode == 0 EACCDN geliefert,
 * ansonsten wird das Handle freigegeben.
 */
LONG ramdisk_drv_close(DMD *d, WORD mode)
{
	WORD	i;

	TRACE(("drv_close - %S\r\n", 1, mode ? "forced" : "requested"));
/*
 * Auch hier sicherheitshalber eine PrÅfung, ob noch das richtige
 * XFS eingetragen ist
 */
	if (d->d_xfs != real_xfs)
		return(EDRIVE);
	for (i = 0; i < MAX_DHD; i++)
	{
/* PrÅfen, ob das Handle Nr. i belegt ist, also noch benutzt wird */
		if (dhd[i].dhd_dir != NULL)
		{
/* Je nach mode entsprechend reagieren */
			if (mode)
				dhd[i].dhd_dir = NULL;
			else
				return(EACCDN);
		}
	}
	return(E_OK);
}

/*
 * path2DD gehîrt zu den XFS-Funktionen, die einem am meisten
 * Kopfzerbrechen bereiten. Die GrÅnde:
 * - Der Pfad muû komplett selbst bearbeitet, also in einzelne
 *   Komponenten zerlegt werden
 * - Die Zugriffsrechte mÅssen, soweit vorhanden, an den richtigen
 *   Stellen selbst geprÅft werden
 * - SpezialfÑlle wie "." und ".." im Pfad mÅssen beachtet werden
 * - Der Pfad darf nicht dauerhaft verÑndert werden, da man direkt
 *   den Pfad des Anwenderprogramms geliefert bekommt; andernfalls
 *   kann es schwere Komplikationen geben
 * - Je nach Modus muû die Bearbeitung an einer anderen Stelle
 *   beendet werden.
 * - Ein DD muû so geschaffen sein, daû man aus ihm den kompletten
 *   Zugriffspfad mit mîglichst wenig Aufwand rekonstruieren kann
 *   (Stichwort DD2name)
 * - Soll path2DD den DD zu einem Verzeichnis liefern, in dem die
 *   letzte Komponente liegt (mode == 0), darf man sich nicht um
 *   die letzte Komponente kÅmmern; es ist also egal, ob es nun
 *   eine Datei, ein Verzeichnis, oder sonstwas ist, die letzte
 *   Komponente muû noch nicht einmal existieren!
 * An dieser Stelle hat man es mit MiNT wesentlich einfacher, da man
 * hier nur eine Lookup-Funktion fÅr einzelne Dateien/Verzeichnisse
 * zur VerfÅgung stellen muû, den Rest erledigt der Kernel. DafÅr ist
 * die MagiC-Lîsung in den meisten FÑllen deutlich schneller.
 */
LONG ramdisk_path2DD(void *reldir, char *pathname, WORD mode,
	char **lastpath, LONG *linkdir, char **symlink)
{
	char		*next,
				*current,
				*nullbyte,
				*temp;
	RAMDISK_FD	*new,
				*dd;
	DIRENTRY	*found;
	WORD		dirlookup = mode;

/*
 * Da temp per int_malloc angefordert wird, muû der Speicher vor
 * Verlassen der Funktion wieder freigegeben werden. Das erreicht man
 * in einer Funktion wie dieser, die an vielen Stellen verlassen
 * wird, am besten, in dem man return so umdefiniert, daû dies
 * automatisch gemacht wird. Nebenbei lÑût sich dabei auch noch
 * wunderschîn eine TRACE-Ausgabe der Returnwerte realisieren...
 * NatÅrlich muû das return-Makro am Ende der Funktion wieder
 * gelîscht werden.
 */
#undef return
#define return(x)	{(kernel->int_mfree)(temp);\
	TRACE(("-> %L, %S, %L, %S; %L\r\n", 5, (LONG)(x), *lastpath,\
		*linkdir, *symlink, (LONG)__LINE__));\
	return(x);}

#ifdef DEBUG
	*lastpath = *symlink = "";
	*linkdir = 0L;
#endif
	TRACE(("path2DD - %L, %S (%L), %S; root = %L\r\n", 5, reldir,
		pathname, pathname, dirlookup ? "Verzeichnis" : "Datei",
		&fd[ROOT]));
/* Speicher fÅr eine Pfadkomponente anfordern (bei der
 * Initialisierung wurde ja sichergestellt, daû int_malloc dafÅr ein
 * genÅgend groûes SpeicherstÅck alloziert). TemporÑrer Speicher
 * ist nîtig, da der gelieferte Pfad nicht verÑndert werden darf
 * und eine Komponente auch lÑnger als 32 Zeichen sein kînnte und
 * daher "beschnitten" werden muû.
 */
	temp = (kernel->int_malloc)();
	temp[32] = 0;
/* PrÅfen, ob der gelieferte DD Åberhaupt OK ist */
	dd = (RAMDISK_FD *)reldir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/* Wird ein Nullzeiger geliefert, lehnt path2DD das ab */
	if (pathname == NULL)
		return(dirlookup ? EPTHNF : EFILNF);
/* Den Zeiger auf das Nullbyte des Pfadnamens merken */
	nullbyte = strchr(pathname, 0);
/*
 * In der folgenden Schleife wird jeweils die erste Komponente des
 * Pfades extrahiert (next zeigt auf sie) und dann entsprechend
 * reagiert. Ebenso zeigt dd immer auf den DD des VorgÑngers, zu
 * Beginn also auf das gelieferte relative Verzeichnis.
 */
	for (next = pathname;;)
	{
/* Eventuell fÅhrende Backslashes Åberlesen */
		for (; *next == '\\'; next++);
/*
 * Wenn noch weitere Komponenten folgen, muû der aktuelle DD ein
 * Verzeichnis mit x-Zugriff sein (das x-Bit bei Verzeichnissen sagt
 * in etwa "darf Åberschritten werden" aus). Wenn es die letzte
 * Komponente ist, findet keine öberprÅfung statt. Dies wird dann
 * in findfile bzw. new_file nachgeholt.
 */
		if (*next && !xaccess(dd->fd_file))
			return(EACCDN);
/*
 * Folgt keine Komponente mehr, ist der aktuelle DD das Ergebnis der
 * Funktion, er muû also zurÅckgeliefert werden. Vorher werden noch
 * fd_refcnt und fd_is_parent durch increase_refcnts angepaût.
 * Dazu noch eine Anmerkung: path2DD wird vom Kernel auch mit leerem
 * Pfadnamen aufgerufen, womit diese Bedingung gleich zu Anfang
 * erfÅllt ist. Das passiert beispielsweise, wenn ein Programm
 * Dopendir vom Wurzelverzeichnis aufruft.
 */
		if (!*next)
		{
			increase_refcnts(dd);
			*lastpath = next;
			return((LONG)dd);
		}
/*
 * current ist ein Zeiger auf die aktuelle Komponente, wÑhrend
 * pathname auf den kompletten Restpfad zeigt
 */
		pathname = current = next;
/*
 * Nach dem nÑchsten Backslash suchen. Wird einer gefunden, muû die
 * aktuelle Komponente nach temp umkopiert und current auf temp
 * gesetzt werden.
 */
		if ((next = strchr(pathname, '\\')) != NULL)
		{
			*next = 0;
			strncpy(temp, pathname, 32L);
			current = temp;
			*next = '\\';
/* Backslash(es) Åberlesen */
			for (; *next == '\\'; next++);
		}
		else
		{
/*
 * Wurde kein Backslash mehr gefunden, ist zu prÅfen, ob der DD einer
 * Datei gesucht wurde. Falls ja, ist die Suche beendet und der
 * aktuelle DD wird zurÅckgeliefert (nach Erhîhung von fd_refcnt und
 * fd_parent).
 */
			if (!dirlookup)
			{
				increase_refcnts(dd);
				*lastpath = pathname;
				return((LONG)dd);
			}
/*
 * Ist jedoch der DD eines Verzeichnisses gesucht, wird next auf
 * das Nullbyte umgesetzt, damit wird der noch zu belegende neue
 * DD zu Beginn des nÑchsten Schleifendurchgangs zurÅckgeliefert.
 */
			next = nullbyte;
		}
/*
 * Ist die aktuelle Komponente "..", wird geprÅft, ob das aktuelle
 * Verzeichnis das Wurzelverzeichnis ist. Wenn ja, wird dies dem
 * Kernel signalisiert (Ñhnlich EMOUNT in MiNT). Andernfalls wird nur
 * der DD auf seinen "Vater" umgesetzt und der nÑchste Durchgang der
 * Schleife gestartet.
 */
		if (!strcmp(current, ".."))
		{
			if (dd == &fd[ROOT])
			{
				*lastpath = next;
				*linkdir = (LONG)dd;
				*symlink = NULL;
				return(ELINK);
			}
			dd = dd->fd_parent;
			continue;
		}
/* "." wird komplett Åbersprungen */
		if (!strcmp(current, "."))
			continue;
/*
 * In allen anderen FÑllen muû die aktuelle Komponente jetzt gesucht
 * werden, sie ist ein Bestandteil des Pfades. Wird sie nicht
 * gefunden, ist der Pfad ungÅltig und es muû EPTHNF geliefert
 * werden.
 */
		if ((found = findfile(dd, current, 2, FF_SEARCH, 0)) == NULL)
			return(EPTHNF);
/*
 * Ist die Komponente ein symbolischer Link, wird dieser ausgelesen
 * und dem Kernel mit einer entsprechenden Meldung geliefert
 */
		if (is_link(found->de_xattr.mode))
		{
			TRACE(("path2DD: Folge symbolischem Link auf %S!\r\n", 1,
				&found->de_faddr[2]));
			increase_refcnts(dd);
			*lastpath = next;
			*linkdir = (LONG)dd;
			*symlink = found->de_faddr;
			return(ELINK);
		}
/* Ist es kein Verzeichnis, ist der Pfad ungÅltig, also EPTHNF */
		if (!is_dir(found->de_xattr.mode))
			return(EPTHNF);
/*
 * Einen DD fÅr das Verzeichnis anfordern, der auch schon vom
 * gleichen Verzeichnis belegt sein kann (der fd_refcnt wird ja
 * erhîht). Auf diese Weise ist sichergestellt, daû ein Verzeichnis
 * bei ddelete z.B. nicht mehrere zu ÅberprÅfende DDs hat. Auûerdem
 * wird dadurch die DD-Ausnutzung effizienter.
 * War allerdings kein DD mehr frei, muû abgebrochen werden.
 */
		if ((new = findfd(found)) == NULL)
			return(ENSMEM);
		new->fd_dmd = ramdisk_dmd;
		new->fd_file = found;
/*
 * Den aktuellen DD als "Vater" des neuen eintragen und danach den
 * neuen DD zum aktuellen machen
 */
		new->fd_parent = dd;
		dd = new;
	}
/* Wichtig: Das oben definierte return-Makro muû gelîscht werden! */
#undef return
}

/*
 * Im Debug-Modus wird jetzt wieder return umdefiniert, um jedes
 * return samt RÅckgabewert protokollieren zu kînnen
 */
#ifdef DEBUG
#define return(x)	{LONG abccba = (LONG)(x);\
	TRACE(("return(%L), Zeile %L\r\n", 2, abccba,\
		(LONG)__LINE__));\
	return(abccba);}
#endif

/*
 * sfirst/snext gehîren auch zu den gemeineren Zeitgenossen,
 * insbesondere fÅr Filesysteme, die nicht mit TOS-Filenamen und
 * -Attributen arbeiten. FÅr die Ramdisk wird das Problem durch
 * ein simuliertes Dreaddir im TOS-kompatiblen Modus gelîst, die
 * Suchmaske wird dabei zusammen mit dem Directory, dem Suchattribut
 * und der aktuellen Suchposition im fÅr das Filesystem verfÅgbaren
 * Bereich der DTA gespeichert (zum GlÅck reicht der Platz dafÅr
 * gerade aus).
 * Die Suchmaske wird vorher in ein spezielles Format gebracht, und
 * zwar immer exakt 8 Zeichen TOS-Filename, Punkt, exakt 3 Zeichen
 * Extension, ggf. wird mit Leerzeichen aufgefÅllt. Ein '*' in einem
 * der beiden Namensteile wird durch '?' bis zum Ende des jeweiligen
 * Teils ersetzt. Beispiele:
 * "*.*" -> "????????.???"
 * "AB*.C" -> "AB??????.C  "
 * "Zu langer Name mit Leerzeichen.txt" -> "ZUXLANGE.TXT"
 * Diese Vorgehensweise erleichert spÑter den Vergleich mit dem
 * aktuellen Filenamen, der auf die gleiche Weise behandelt wird.
 * Es kann zwar zu Problemen kommen, wenn der aktuelle Name '?' oder
 * '*' enthÑlt (das Ramdisk-XFS akzeptiert das), doch viel schlimmes
 * wird dabei nicht passieren.
 */
LONG ramdisk_sfirst(void *srchdir, char *name, MGX_DTA *dta,
	WORD attrib, char **symlink)
{
	RAMDISK_FD	*dd;
	RAMDISK_DTA	*the_dta;
	DIRENTRY	*found;
	char		*temp;

	TRACE(("sfirst - %L\\%S, %L\r\n", 3, srchdir, name, (LONG)attrib));
	dd = (RAMDISK_FD *)srchdir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
	temp = (kernel->int_malloc)();
	the_dta = (RAMDISK_DTA *)dta;
	tostrunc(temp, name, 1);
	fill_tosname(the_dta->dta_mask, temp);
	(kernel->int_mfree)(temp);
	the_dta->dta_pos = 0;
/*
 * FÅr sfirst ist Leseberechtigung nîtig, sobald die fertige Maske
 * ein '?' enthÑlt. In allen anderen FÑllen soll nur die Existenz
 * eines bestimmten Files geprÅft werden, wozu nur x-Rechte nîtig
 * sind, die aber schon von path2DD geprÅft wurden.
 */
	if ((strchr(the_dta->dta_mask, '?') != NULL))
	{
		if (!raccess(dd->fd_file))
			return(EACCDN);
	}
	else
	{
/*
 * Suche ohne Wildcards wird direkt auf findfile zurÅckgefÅhrt (mit
 * Originalmaske!), damit Gemini beim Kopieren bereits existierende
 * Files korrekt umbennenen kann. Auch bei manchen Ñlteren Programmen
 * kann dies hilfreich sein, wenn sie Åbergebene Dateien per Fsfirst
 * suchen: Wenn es ein langer Filename ist, kînnte der alleinige
 * Vergleich auf 8+3-Ebene das falsche File finden, falls sich die
 * Namen im TOS-Format nicht unterscheiden (z.B. dateiname1 und
 * dateiname2).
 */
		if ((found = findfile(dd, name, 0, FF_SEARCH, 1)) == NULL)
			return(EFILNF);
		the_dta->dta_pos = -found->de_nr;
	}
	the_dta->dta_drive = (char)ramdisk_drive;
	the_dta->dta_attr = (char)attrib;
	the_dta->dta_dir = (DIRENTRY *)dd->fd_file->de_faddr;
/*
 * sfirst selbst liest keinen Verzeichniseintrag, sondern ruft snext
 * auf und liefert dessen Ergebnis
 */
	return(ramdisk_snext((MGX_DTA *)the_dta, ramdisk_dmd, symlink));
}

LONG ramdisk_snext(MGX_DTA *dta, DMD *dmd, char **symlink)
{
	RAMDISK_DHD	handle;
	RAMDISK_DTA	*the_dta;
	XATTR		xattr;
	WORD		first_call,
				matched;
	LONG		dummy,
				r;
	char		*name;

	TRACE(("snext - %S\r\n", 1, ((RAMDISK_DTA *)dta)->dta_mask));
	if (dmd != ramdisk_dmd)
		return(EDRIVE);
	the_dta = (RAMDISK_DTA *)dta;
/*
 * Wenn dta_pos noch <= 0 ist, stammt der Aufruf von direkt von
 * sfirst, was in first_call gespeichert wird
 */
	first_call = (the_dta->dta_pos <= 0);
	if (the_dta->dta_pos < 0)
		the_dta->dta_pos = -the_dta->dta_pos;
/*
 * Wenn es nicht der erste Aufruf ist und die Maske keine Wildcards
 * enthÑlt, muû gleich ENMFIL geliefert werden
 */
	if (!first_call && (strchr(the_dta->dta_mask, '?') == NULL))
		return(ENMFIL);
/*
 * Es wird ein Pseudo-Directory-Handle eingerichtet, das dann fÅr
 * dreaddir benutzt wird. Dabei muû natÅrlich der TOS-Modus benutzt
 * werden, damit schon passende Namen geliefert werden.
 */
	handle.dhd_dmd = dmd;
	handle.dhd_dir = the_dta->dta_dir;
	handle.dhd_pos = the_dta->dta_pos;
	handle.dhd_tosmode = 1;
/*
 * Zum Auslesen aus der Kernelstruktur immer den Zeiger real_kernel
 * benutzen, kernel soll und muû nur fÅr Funktionsaufrufe genutzt
 * werden
 */
	handle.dhd_owner = *real_kernel->act_pd;
/*
 * In der folgenden Schleife wird solange dreaddir aufgerufen, bis
 * entweder ein Fehler aufgetreten oder ein passender Name mit
 * passendem Attribut gefunden wurde
 */
	for (;;)
	{
		r = ramdisk_dreaddir(&handle, 13, the_dta->dta_name, &xattr,
			&dummy);
		the_dta->dta_pos = handle.dhd_pos;
		if (r)
		{
/*
 * Ist die Fehlermeldung ENMFIL und dieses snext ist eigentlich
 * sfirst (sfirst ruft ja am Ende snext auf), muû stattdessen EFILNF
 * geliefert werden
 */
			if (first_call && (r == ENMFIL))
				r = EFILNF;
			return(r);
		}
		name = (kernel->int_malloc)();
		fill_tosname(name, the_dta->dta_name);
		matched = match_tosname(name, the_dta->dta_mask);
		(kernel->int_mfree)(name);
		if (matched)
		{
/*
 * Ist der gefundene Name ein symbolischer Link, muû das dem Kernel
 * signalisiert werden
 */
			if (is_link(xattr.mode))
			{
				TRACE(("snext: Folge symbolischem Link auf %S!"
					"\r\n", 1, &((char *)xattr.index)[2]));
				*symlink = (char *)xattr.index;
				return(ELINK);
			}
/*
 * Ansonsten werden Suchattribut und Dateiattribut verglichen. Dabei
 * entspricht die Abfrage dem CodestÅck, das im Profibuch bei Fsfirst
 * angegeben ist.
 */
			TRACE(("Suchattribut: %L, Dateiattribut: %L\r\n", 2,
				(LONG)the_dta->dta_attr, (LONG)xattr.attr));
			TRACE(("Mode: %L\r\n", 1, (LONG)xattr.mode));
			if (xattr.attr == 0)
				break;
			if (xattr.attr & 0x21)
				break;
			if (the_dta->dta_attr & xattr.attr)
				break;
		}
	}
/*
 * Wurde ein passender Eintrag gefunden, muû die DTA entsprechend
 * gefÅllt werden. Als Zeit wird dabei immer die der letzten
 * Modifikation geliefert, was am ehesten zutrifft.
 */
	the_dta->dta_attribute = xattr.attr;
	the_dta->dta_time = xattr.mtime;
	the_dta->dta_date = xattr.mdate;
	the_dta->dta_len = xattr.size;
	return(E_OK);
}

/*
 * fopen beim Ramdisk-XFS ist bislang unvollstÑndig, da eine Datei
 * nur ein einziges Mal geîffnet werden kann. Filesharing ist so
 * nicht mîglich, selbst ein und derselbe Prozeû kann eine Datei
 * nicht mehrmals îffnen.
 * Bei fopen sind auch wieder eine ganze Menge von Dingen zu
 * beachten:
 * - Wenn die Datei nicht gefunden wird, muû sie angelegt werden,
 *   wenn das O_CREAT-Flag in omode gesetzt ist
 * - Sind O_CREAT und O_EXCL gesetzt, darf die Datei noch nicht
 *   existieren
 * - Ist die zu îffnende Datei ein symbolischer Link, muû das dem
 *   Kernel gemeldet werden
 * - Directories dÅrfen nicht per fopen geîffnet werden
 * - Darf die Datei beschrieben bzw. ausgelesen werden?
 * - Die Datei muû ggf. gekÅrzt werden (O_TRUNC)
 * - Bei den bekannten Extensionen von ausfÅhrbaren Programmen sollte
 *   beim Anlegen automatisch das x-Flag gesetzt werden
 * - Wird Filesharing unterstÅtzt, muû natÅrlich geprÅft werden, ob
 *   der neue Modus mit den bisherigen harmoniert
 */
LONG ramdisk_fopen(void *dir, char *name, WORD omode, WORD attrib,
	char **symlink)
{
	RAMDISK_FD	*dd,
				*new_fd;
	DIRENTRY	*found;
	FILEBLOCK	*file,
				*next;

	TRACE(("fopen - %L\\%S, %L, %L\r\n", 4, dir, name, (LONG)omode,
		(LONG)attrib));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/*
 * Diese öberprÅfung ist eigentlich nicht nîtig, da findfile auch das
 * x-Flag testet, aber so wird EACCDN statt EFILNF geliefert
 */
	if (!xaccess(dd->fd_file))
	{
		TRACE(("fopen: x-Bit fehlt!\r\n", 0));
		return(EACCDN);
	}
/*
 * Wenn O_CREAT oder O_TRUNC gesetzt ist, muû auch Schreibzugriff
 * gewÅnscht sein, sonst stimmt etwas nicht
 */
	if (((omode & O_CREAT) || (omode & O_TRUNC)) &&
		((omode & OM_WPERM) != OM_WPERM))
	{
		TRACE(("fopen: O_CREAT bzw. O_TRUNC ohne OM_WPERM!\r\n", 0));
		return(EACCDN);
	}
/*
 * File suchen, ohne 8+3-Vergleich, wenn die Datei neu angelegt
 * werden soll (OM_WPERM, O_CREAT und O_TRUNC gesetzt), sonst mit
 */
	if ((omode & (OM_WPERM | O_CREAT | O_TRUNC)) ==
		(OM_WPERM | O_CREAT | O_TRUNC))
	{
		found = findfile(dd, name, 2, FF_EXIST, 0);
	}
	else
		found = findfile(dd, name, 2, FF_SEARCH, 0);
	if (found != NULL)
	{
/*
 * Wird das File gefunden und es ist ein symbolischer Link, muû das
 * dem Kernel signalisiert werden
 */
		if (is_link(found->de_xattr.mode))
		{
			TRACE(("fopen: Folge symbolischem Link auf %S!\r\n", 1,
				&found->de_faddr[2]));
			*symlink = found->de_faddr;
			return(ELINK);
		}
/* Verzeichnisse kînnen nicht als Datei geîffnet werden */
		if (is_dir(found->de_xattr.mode))
			return(EFILNF);
/* Schreiben in schreibgeschÅtzte Dateien geht auch nicht */
		if ((omode & OM_WPERM) && !waccess(found))
		{
			TRACE(("fopen: OM_WPERM auf schreibgeschÅtzte Datei!\r\n", 0));
			return(EACCDN);
		}
/*
 * Sollten die Modi O_CREAT und O_EXCL gesetzt sein, muû EACCDN
 * geliefert werden, da gewÅnscht wurde, eine neue Datei anzulegen,
 * die bislang nicht existiert
 */
		if ((omode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
		{
			TRACE(("fopen: Datei existiert, O_CREAT und O_EXCL sind "
				"aber gewÅnscht!\r\n", 0));
			return(EACCDN);
		}
	}
/*
 * Einen FD fÅr die Datei anfordern, Fehler melden, wenn das nicht
 * klappt
 */
	if ((new_fd = findfd(found)) == NULL)
		return(ENSMEM);
/*
 * Gibt es schon einen belegten FD fÅr diese Datei, wird mit EACCDN
 * abgebrochen. Genaugenommen mÅûte jetzt hier eine öberprÅfung
 * stattfinden, ob die Zugriffsmodi kompatibel sind. Das habe ich mir
 * aber bisher gespart...
 */
	if (new_fd->fd_parent != NULL)
	{
		TRACE(("fopen: Datei schon geîffnet!\r\n", 0));
		TRACE(("rootDD = %L, new_fd = %L, new_fd->fd_parent = %L\r\n",
			3, &fd[ROOT], new_fd, new_fd->fd_parent));
		return(EACCDN);
	}
	if (found == NULL)
	{
/*
 * Die Datei war noch nicht vorhanden, also muû sie angelegt werden.
 * Dazu muû aber O_CREAT gesetzt sein, sonst wurde nur ôffnen einer
 * bereits existenten Datei gewÅnscht und es muû EFILNF geliefert
 * werden.
 */
		if ((omode & O_CREAT) != O_CREAT)
		{
			TRACE(("fopen: File nicht gefunden, kein O_CREAT!\r\n", 0));
			return(EFILNF);
		}
#ifdef CHECK_OPEN
/* PrÅfen, ob das aktuelle Verzeichnis nicht noch geîffnet ist */
	if (dir_is_open((DIRENTRY *)dd->fd_file->de_faddr))
	{
		TRACE(("fopen: Dir offen!\r\n", 0));
		return(EACCDN);
	}
#endif
/* NatÅrlich darf keine Datei namens "." oder ".." angelegt werden */
		if (!strcmp(name, ".") || !strcmp(name, ".."))
		{
			TRACE(("fopen: Name ist \".\" oder \"..\"!\r\n", 0));
			return(EACCDN);
		}
/*
 * Neuen Verzeichniseintrag anlegen, ggf. Fehler melden. Der Filename
 * wird bei TOS-Domain-Prozessen nur in Kleinbuchstaben gewandelt,
 * nicht in's 8+3-Format. Das ist eine Kompromiûlîsung, weil viele
 * Programme zwar mit langen Dateinamen zurecht kommen, unter MagiC
 * aber nicht in die MiNT-Domain schalten, weil sie das Vorhandensein
 * von Pdomain vom MiNT-Cookie abhÑngig machen, anstatt die Funktion
 * einfach aufzurufen.
 */
		if ((found = new_file(dd, name)) == NULL)
		{
			TRACE(("fopen: File konnte nicht angelegt werden!\r\n", 0));
			return(EACCDN);
		}
/* Speicher anfordern, ggf. Fehler melden */
		if ((file = Kmalloc(sizeof(FILEBLOCK))) == NULL)
			return(ENSMEM);
		file->next = NULL;
/*
 * Jetzt ist sichergestellt, daû tatsÑchlich ein neuer Eintrag
 * entsteht, also muû die Modifikationszeit des Verzeichnisses
 * angepaût werden
 */
		work_entry(dd, ".", NULL, 1, 0L, 0L, set_amtime);
/* Die noch leeren Elemente im neuen Eintrag fÅllen */
		found->de_faddr = (char *)file;
		found->de_xattr.mode = S_IFREG;
/* Bei passender Endung das x-Flag setzen */
		if ((omode & OM_EXEC) || has_xext(name))
			found->de_xattr.mode |= 0777;
		else
			found->de_xattr.mode |= 0666;
/*
 * Wird ein schreibgeschÅtztes File neu angelegt, mÅssen die
 * Zugriffsrechte beschnitten werden. FA_CHANGED wird Åbrigens immer
 * gesetzt, GEMDOS macht das beim Anlegen einer leeren Datei nicht,
 * dadurch gehen beim Backup u.U. EintrÑge verloren.
 */
		if (attrib & FA_RDONLY)
		{
			found->de_xattr.mode &= ~(S_IWUSR | S_IWGRP | S_IWOTH);
			attrib = FA_RDONLY | FA_CHANGED;
		}
		else
			attrib = FA_CHANGED;
		found->de_xattr.index = (LONG)file;
		found->de_xattr.size = 0L;
		found->de_xattr.nblocks = 1L;
		found->de_xattr.attr = attrib;
	}
	else
	{
		if (omode & O_TRUNC)
		{
/*
 * Falls die Datei schon existierte und O_TRUNC gesetzt ist, muû das
 * File jetzt auf LÑnge Null gekÅrzt werden. TatsÑchlich bleibt dabei
 * ein Fileblock vorhanden, eine Datei mit LÑnge 0 belegt auf der
 * Ramdisk trotzdem einen Fileblock. Das ist zwar nicht so toll,
 * erleichert aber einige Dinge.
 */
			file = (FILEBLOCK *)found->de_faddr;
			next = file->next;
			file->next = NULL;
			file = next;
			while (file != NULL)
			{
				next = file->next;
				Kfree(file);
				file = next;
			}
			found->de_xattr.size = 0L;
			found->de_xattr.nblocks = 1L;
			found->de_xattr.attr |= FA_CHANGED;
		}
	}
/* Den neuen FD auffÅllen und zurÅckliefern */
	new_fd->fd_dmd = ramdisk_dmd;
	new_fd->fd_refcnt = 1;
	new_fd->fd_mode = omode;
/*
 * Hier darf die Ramdisk-Struktur eingetragen werden, da die
 * Parameterformate und die Registerbenutzung im Gegensatz zur
 * THE_MGX_XFS-Struktur kompatibel sind
 */
	new_fd->fd_dev = &ramdisk_dev;
	new_fd->fd_fpos = 0L;
	new_fd->fd_file = found;
	new_fd->fd_parent = dd;
/*
 * Zum Auslesen aus der Kernelstruktur immer den Zeiger real_kernel
 * benutzen, kernel soll und muû nur fÅr Funktionsaufrufe genutzt
 * werden
 */
	new_fd->fd_owner = *real_kernel->act_pd;
	return((LONG)new_fd);
}

/*
 * Eine Datei soll gelîscht werden. Es ist zwar schîn, daû der Kernel
 * die öberprÅfung, ob die Datei noch offen ist, dem XFS ÅberlÑût,
 * aber laut Doku muû diese öberprÅfung ergeben, daû die Datei eben
 * nicht mehr offen ist. Dadurch ist es z.B. nicht mîglich, die
 * Datei zu lîschen, solange nur lesend auf sie zugegriffen wird.
 * Physikalisch gelîscht wÅrde sie dann erst, wenn der letzte Prozeû
 * die Datei schlieût.
 */
LONG ramdisk_fdelete(void *dir, char *name)
{
	RAMDISK_FD	*dd,
				*fd;
	DIRENTRY	*found;
	FILEBLOCK	*file,
				*next;

	TRACE(("fdelete - %L\\%S\r\n", 2, dir, name));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/* Die Datei suchen; existiert sie nicht, Fehler melden */
	if ((found = findfile(dd, name, 2, FF_SEARCH, 0)) == NULL)
		return(EFILNF);
#ifdef CHECK_OPEN
/* PrÅfen, ob das aktuelle Verzeichnis nicht noch geîffnet ist */
	if (dir_is_open((DIRENTRY *)dd->fd_file->de_faddr))
	{
		TRACE(("fdelete: Dir offen!\r\n", 0));
		return(EACCDN);
	}
#endif
/*
 * FÅr das Lîschen von Dateien sind Schreib- und Zugriffsrechte fÅr
 * das betroffene Verzeichnis nîtig
 */
	if (!waccess(dd->fd_file) || !xaccess(dd->fd_file))
	{
		TRACE(("fdelete: Kein Schreibrecht fÅr Verzeichnis!\r\n", 0));
		return(EACCDN);
	}
/* Verzeichnisse kînnen nicht per fdelete gelîscht werden */
	if (is_dir(found->de_xattr.mode))
	{
		TRACE(("fdelete: Datei ist Verzeichnis!\r\n", 0));
		return(EACCDN);
	}
/* PrÅfen, ob die Datei noch offen ist und entsprechend reagieren */
	if (((fd = findfd(found)) != NULL) && (fd->fd_parent != NULL))
	{
		TRACE(("fdelete: Datei noch geîffnet!\r\n", 0));
		return(EACCDN);
	}
/* Auch fÅr die Datei selbst mÅssen Schreibrechte vorhanden sein */
	if (!waccess(found))
	{
		TRACE(("fdelete: Datei ist schreibgeschÅtzt!\r\n", 0));
		return(EACCDN);
	}
/*
 * Jetzt den durch die Datei (oder den Link) belegten Speicher
 * freigeben und den Eintrag im Verzeichnis als leer kennzeichnen
 */
	if (is_link(found->de_xattr.mode))
		Kfree(found->de_faddr);
	else
	{
		file = (FILEBLOCK *)found->de_faddr;
		do
		{
			next = file->next;
			Kfree(file);
			file = next;
		} while (file != NULL);
	}
	found->de_faddr = NULL;
/*
 * Schlieûlich noch die Modifikationszeit des betroffenen
 * Verzeichnisses anpassen
 */
	work_entry(dd, ".", NULL, 1, 0L, 0L, set_amtime);
	return(E_OK);
}

/*
 * Das Ramdisk-XFS unterstÅtzt keine Hardlinks, daher werden in
 * dieser Funktion nur das Umbennenen bzw. Verschieben von Dateien,
 * Links und Verzeichnissen ermîglicht.
 * Wird dabei ein Verzeichnis echt verschoben, muû die Adresse von
 * ".." angepaût werden, da sich ja das Elternverzeichnis geÑndert
 * hat. Ebenso muû dann sichergestellt sein, daû das Zielverzeichnis
 * nicht zu den "Nachfahren" des Quellverzeichnis gehîrt (man darf
 * z.B. \usr nicht nach \usr\local verschieben).
 */
LONG ramdisk_link(void *olddir, void *newdir, char *oldname,
	char *newname, WORD flag_link)
{
	RAMDISK_FD	*old,
				*new,
				*i;
	DIRENTRY	*e_old,
				*e_new;
	char		*temp;

	if (flag_link)
	{
		TRACE(("link - hardlinks not supported!\r\n", 0));
		return(EINVFN);
	}
	TRACE(("link - rename %L\\%S to %L\\%S\r\n", 4, olddir, oldname,
		newdir, newname));
	old = (RAMDISK_FD *)olddir;
	new = (RAMDISK_FD *)newdir;
	if (check_dd(old) < 0)
		return(check_dd(old));
	if (check_dd(new) < 0)
		return(check_dd(new));
/*
 * FÅr beide betroffenen Verzeichnisse mÅssen die entsprechenden
 * Rechte vorhanden sein
 */
	if (!waccess(old->fd_file) || !waccess(new->fd_file) ||
		!xaccess(old->fd_file) || !xaccess(new->fd_file))
	{
		return(EACCDN);
	}
/* PrÅfen, ob der gewÅnschte neue Name zulÑssig ist */
	if (!check_name(newname))
		return(EACCDN);
/*
 * Den neuen Namen auf die maximale LÑnge stutzen und, wenn der
 * aufrufende Prozeû in der TOS-Domain lÑuft, in Kleinbuchstaben
 * umwandeln (diese Umwandlung ist sinnvoll, weil TOS-Domain-
 * Prozesse in der Regel komplett groû geschriebene Filenamen
 * liefern, was auf einem case-sensitiven Filesystem unpraktisch
 * ist)
 */
	temp = (kernel->int_malloc)();
	temp[32] = 0;
	strncpy(temp, newname, 32L);
	if (Pdomain(-1) == 0)
		strlwr(temp);
	newname = temp;
/*
 * Das umzubennende File muû gefunden werden, notfalls, je nach
 * MagiC-Version und aktueller Domain, auch mit 8+3-Vergleichen
 */
	if ((e_old = findfile(old, oldname, 2, FF_SEARCH, 0)) == NULL)
	{
		(kernel->int_mfree)(temp);
		return(EFILNF);
	}
/*
 * Im Gegensatz dazu muû beim Zielfilenamen nur sichergestellt sein,
 * daû nicht schon ein Eintrag mit exakt dem selben Namen existiert;
 * daher wird nur mit FF_EXIST gesucht
 */
	if ((e_new = findfile(new, newname, 0, FF_EXIST, 0)) != NULL)
	{
		(kernel->int_mfree)(temp);
		return(EACCDN);
	}
/*
 * Ist der Quelleintrag ein Verzeichnis, muû sichergestellt werden,
 * daû das Zielverzeichnis nicht unterhalb liegt. Dazu reicht es aus,
 * die DD-Kette dies Zielverzeichnis rÅckwÑrts nach Vorkommen des
 * Quelleintrags abzusuchen. Wird er gefunden, ist das Verschieben
 * nicht mîglich.
 */
	if (is_dir(e_old->de_xattr.mode))
	{
		for (i = new; i->fd_parent != NULL; i = i->fd_parent)
		{
			if (i->fd_file == e_old)
			{
				(kernel->int_mfree)(temp);
				return(EACCDN);
			}
		}
	}
/*
 * Der nachfolgende Test ist defaultmÑûig nicht aktiv, weil zumindest
 * Thing beim Verschieben von Dateien in Verzeichnissen Frename
 * direkt nach D(x)readdir aufruft. Ein solches Vorgehen ist nicht
 * empfehlenswert, es ist besser, erst alle Dateinamen in eine Liste
 * einzulesen und sie erst nach dem Dclosedir der Reihe nach
 * zu verschieben.
 */
#ifdef CHECK_OPEN
/*
 * Sicherstellen, daû die beiden betroffenen Verzeichnisse nicht
 * noch per Dopendir geîffnet sind
 */
	if (dir_is_open((DIRENTRY *)old->fd_file->de_faddr))
	{
		(kernel->int_mfree)(temp);
		return(EACCDN);
	}
	if (dir_is_open((DIRENTRY *)new->fd_file->de_faddr))
	{
		(kernel->int_mfree)(temp);
		return(EACCDN);
	}
#endif
/* Wenn die beiden DDs gleich sind, soll nur umbenannt werden */
	if (old == new)
	{
		strcpy(e_old->de_fname, newname);
/* Die Modifikationszeit des aktuellen Verzeichnisses anpassen */
		work_entry(old, ".", NULL, 1, 0L, 0L, set_amtime);
		(kernel->int_mfree)(temp);
		return(E_OK);
	}
/*
 * Sonst versuchen, einen neuen Eintrag im Zielverzeichnis anzulegen
 */
	if ((e_new = new_file(new, newname)) == NULL)
	{
		(kernel->int_mfree)(temp);
		return(EACCDN);
	}
/*
 * Klappte das, die Modifikationszeiten der beiden Verzeichnisse
 * anpassen, den alten Eintrag in den neuen kopieren, den neuen Namen
 * eintrage und den alten Eintrag freigeben
 */
	work_entry(old, ".", NULL, 1, 0L, 0L, set_amtime);
	work_entry(new, ".", NULL, 1, 0L, 0L, set_amtime);
	*e_new = *e_old;
	strcpy(e_new->de_fname, newname);
	e_old->de_faddr = NULL;
/*
 * Wurde ein Unterverzeichnis auf diese Weise in ein neues Directory
 * verschoben, muû noch der ".."-Eintrag angepaût werden
 */
	if (is_dir(e_new->de_xattr.mode))
	{
		((DIRENTRY *)e_new->de_faddr)[1].de_faddr =
			new->fd_file->de_faddr;
		((DIRENTRY *)e_new->de_faddr)[1].de_xattr.index =
			(LONG)new->fd_file->de_faddr;
	}
	(kernel->int_mfree)(temp);
	return(E_OK);
}

/*
 * FÅr die Ramdisk ist xattr keine allzu groûe Schwierigkeit, weil
 * ein Verzeichniseintrag schon die komplette XATTR-Struktur
 * enthÑlt. "Echte" Filesysteme mÅssen hier unter UmstÑnden stark
 * tricksen, um einige der Felder korrekt zu belegen. öbrigens sollte
 * man nicht vergessen, im RÅckgabewert von Dpathconf mit Modus 8
 * anzugeben, welche Felder der XATTR-Struktur mit verlÑûlichen
 * Werten gefÅllt werden.
 */
LONG ramdisk_xattr(void *dir, char *name, XATTR *xattr, WORD mode,
	char **symlink)
{
	RAMDISK_FD	*dd;
	DIRENTRY	*found;

	TRACE(("xattr - %L\\%S (%L)\r\n", 3, dir, name, name));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
	{
		TRACE(("xattr: check_dd fehlgeschlagen!\r\n", 0));
		return(check_dd(dd));
	}
	TRACE(("xattr: %S\r\n", 1, name));
/* Das angeforderte File suchen, ggf. Fehler melden */
	if ((found = findfile(dd, name, 0, FF_SEARCH, 1)) == NULL)
	{
		TRACE(("xattr: %S nicht gefunden!\r\n", 1, name));
		return(EFILNF);
	}
/*
 * Ist das betroffene File ein symbolischer Link und sollen solche
 * verfolgt werden, muû das dem Kernel gemeldet werden
 */
	if (!mode && is_link(found->de_xattr.mode))
	{
		TRACE(("xattr: Folge symbolischem Link auf %S!\r\n", 1,
			&found->de_faddr[2]));
		*symlink = found->de_faddr;
		return(ELINK);
	}
/* In allen anderen FÑllen die Zielstruktur auffÅllen */
	*xattr = found->de_xattr;
	return(E_OK);
}

/*
 * Das Ermitteln bzw. Setzen der GEMDOS-Attribute kann, je nach
 * Filesystem, eine haarige Angelegenheit sein, da nicht alle
 * von ihnen vorhanden sind oder nur aufwendig simuliert werden
 * kînnen. Nicht vorhandene Attribute werden beim Setzen einfach
 * ignoriert, dabei muû natÅrlich darauf geachtet werden, daû man
 * sie auch im RÅckgabewert ausmaskiert hat.
 * Das Ramdisk-XFS benutzt fÅr attrib die Hilfsfunktions work_entry
 * (aus ramutil.c), die bei einem Eintrag Modifikationen vorzunehmen,
 * die durch eine Åbergebene Funktion realisiert werden (hier:
 * attrib_action). Das besondere an work_entry ist, daû es alle
 * nîtigen Tests selbst durchfÅhrt und bei énderungen an ".", "..",
 * oder einem normalen Verzeichniseintrag automatisch dafÅr sorgt,
 * daû die beiden jeweils anderen mitbetroffenen EintrÑge ebenfalls
 * geÑndert werden.
 */
LONG ramdisk_attrib(void *dir, char *name, WORD rwflag, WORD attrib,
	char **symlink)
{
	TRACE(("attrib - %L\\%S, %L, %L\r\n", 4, dir, name, (LONG)rwflag,
		(LONG)attrib));
	return(work_entry((RAMDISK_FD *)dir, name, symlink, rwflag,
		rwflag, attrib, attrib_action));
}

LONG attrib_action(DIRENTRY *entry, LONG rwflag, LONG attrib)
{
	if (rwflag)
	{
/*
 * Die Ramdisk unterstÅtzt, neben dem Verzeichnis-Attribut, das
 * natÅrlich nicht verÑndert werden darf, nur FA_RDONLY und
 * FA_CHANGED. Im Falle von FA_RDONLY werden entweder allen
 * drei Userklassen (Owner/Group/Others) die Schreibrechte entzogen
 * oder gewÑhrt.
 */
		if (attrib & FA_RDONLY)
		{
			entry->de_xattr.mode &= ~(S_IWUSR | S_IWGRP | S_IWOTH);
			entry->de_xattr.attr |= FA_RDONLY;
		}
		else
		{
			entry->de_xattr.mode |= S_IWUSR | S_IWGRP | S_IWOTH;
			entry->de_xattr.attr &= ~FA_RDONLY;
		}
/* FA_CHANGED kann bei Verzeichnissen nicht gesetzt werden */
		if ((attrib & FA_CHANGED) && is_file(entry->de_xattr.mode))
			entry->de_xattr.attr |= FA_CHANGED;
		else
			entry->de_xattr.attr &= ~FA_CHANGED;
	}
/*
 * Am Schluû immer das momentan gÅltige Attribut liefern, damit ist
 * auch die Bedingung erfÅllt, daû bei énderungen nur die tatsÑchlich
 * gesetzten Attribute als Returncode benutzt werden dÅrfen.
 */
	return(entry->de_xattr.attr);
}

/*
 * chown wird bislang nicht unterstÅtzt, aber trotzdem muû die
 * Funktion zumindest soweit ausprogrammiert werden, daû symbolische
 * Links erkannt werden (Fchown bezieht sich, ebenso wie Fchmod,
 * immer auf das Ziel eines symbolischen Links, nicht auf den Link
 * selbst!)
 */
LONG ramdisk_chown(void *dir, char *name, UWORD uid, UWORD gid,
	char **symlink)
{
	TRACE(("chown - not supported\r\n", 0));
/*
 * Wird work_entry mit NULL als action aufgerufen, wird EINVFN
 * geliefert, wenn name kein symbolischer Link ist. Ansonsten wird
 * wie Åblich *symlink belegt und ELINK gemeldet.
 */
	return(work_entry((RAMDISK_FD *)dir, name, symlink, 0, uid, gid,
		NULL));
}

/*
 * chmod Ñndert die Zugriffsrechte fÅr einen Verzeichniseintrag
 * (symbolische Links mÅssen verfolgt werden). FÅr Filesysteme, die
 * nicht direkt mit den Unix-Zugriffsrechten arbeiten, muû hier eine
 * Art "Workaround" realisiert oder die Funktion wie chown ohne echte
 * FunktionalitÑt ausgestatt werden. Solche Probleme gibt es Åbrigens
 * auch im Unix-Bereich, so verwaltet beispielsweise das AFS (ein
 * Netzwerkfilesystem) andere, weitergehende Zugriffsrechte, die dann
 * fÅr chmod soweit mîglich "umgemappt" werden.
 * Beim Ramdisk-XFS ist chmod, wie attrib und chown, Åber work_entry
 * realisiert, damit auch die Zugriffsrechte von Verzeichnissen
 * korrekt geÑndert werden kînnen.
 */
LONG ramdisk_chmod(void *dir, char *name, UWORD mode, char **symlink)
{
	TRACE(("chmod - %L\\%S, %L\r\n", 3, dir, name, (LONG)mode));
	return(work_entry((RAMDISK_FD *)dir, name, symlink, 1, mode, 0L,
		chmod_action));
}

LONG chmod_action(DIRENTRY *entry, LONG _mode, LONG dummy)
{
	UWORD	mode;

/*
 * Der neue Zugriffsmodus wird direkt in die XATTR-Struktur des
 * Verzeichniseintrags kopiert; je nach neuem Zustand der Rechte
 * fÅr das Schreiben wird das FA_RDONLY-Bit im GEMDOS-Attribut
 * gesetzt oder gelîscht
 */
	mode = (UWORD)_mode;
	entry->de_xattr.mode &= S_IFMT;
	entry->de_xattr.mode |= mode;
	if (!waccess(entry))
		entry->de_xattr.attr |= FA_RDONLY;
	else
		entry->de_xattr.attr &= ~FA_RDONLY;
	return(E_OK);
}

/*
 * Das Anlegen eines neuen Unterverzeichnisses ist natÅrlich recht
 * unspektakÅlar...
 */
LONG ramdisk_dcreate(void *dir, char *name)
{
	RAMDISK_FD	*dd;
	DIRENTRY	*entry,
				*new;

	TRACE(("dcreate - %L\\%S, rootDD = %L\r\n", 3, dir, name,
		&fd[ROOT]));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
	{
		TRACE(("dcreate: dd fehlerhaft!\r\n", 0));
		return(check_dd(dd));
	}
#ifdef CHECK_OPEN
/* PrÅfen, ob das aktuelle Verzeichnis nicht noch geîffnet ist */
	if (dir_is_open((DIRENTRY *)dd->fd_file->de_faddr))
	{
		TRACE(("dcreate: Dir offen!\r\n", 0));
		return(EACCDN);
	}
#endif
/*
 * Es darf natÅrlich noch keinen Verzeichniseintrag gleichen Namens
 * geben
 */
	if (findfile(dir, name, 0, FF_EXIST, 0) != NULL)
	{
		TRACE(("dcreate: Datei existiert bereits!\r\n", 0));
		return(EACCDN);
	}
/* Neuen Eintrag anfordern, ggf. Fehler melden */
	if ((entry = new_file(dd, name)) == NULL)
	{
		TRACE(("dcreate: Kein Platz mehr!\r\n", 0));
		return(EACCDN);
	}
/* Speicher fÅr neues Verzeichnis anfordern, ggf. Fehler melden */
	if ((new = Kmalloc(DEFAULTDIR * sizeof(DIRENTRY))) == NULL)
		return(ENSMEM);
/*
 * Erst jetzt ist sichergestellt, daû der neue Eintrag auch von Dauer
 * ist, also kann die Modifikationszeit des aktuellen Verzeichnisses
 * angepaût werden
 */
	work_entry(dd, ".", NULL, 1, 0L, 0L, set_amtime);
/*
 * Das neue Verzeichnis lîschen, die EintrÑge "." und ".." anlegen
 * und den neuen Eintrag fertig ausfÅllen
 */
	(kernel->fast_clrmem)(new, &new[DEFAULTDIR]);
	prepare_dir(new, (WORD)DEFAULTDIR,
		(DIRENTRY *)dd->fd_file->de_faddr);
	entry->de_faddr = (char *)new;
	entry->de_xattr.mode = S_IFDIR | 0777;
	entry->de_xattr.index = (LONG)new;
	entry->de_xattr.size = 0L;
	entry->de_xattr.nblocks = 1L;
	entry->de_xattr.attr = FA_DIR;
	return(E_OK);
}

/*
 * Das Lîschen eines Verzeichnisses ist etwas schwieriger, was leider
 * am MagiC-Kernel liegt: Bis Kernelversion 2 (einschlieûlich) muû
 * man _auf jeden Fall_ selbst den refcnt erniedrigen und ggf. den DD
 * freigegeben (und nur dann darf das Verzeichnis auch gelîscht
 * werden), sonst kommt die Verwaltung ganz gewaltig in's Straucheln.
 * Leider ist bzw. war das noch nicht einmal konkret in der Doku
 * erwÑhnt, es heiût bzw. hieû dort nur, daû der refcnt ÅberprÅft
 * werden muû. Ab Kernelversion 3 regelt der Kernel (voraussichtlich)
 * diesen Teil selbst, was auch wesentlich sinnvoller ist.
 * Wer eine DD-Verwaltung hat, die ein- und demselben Verzeichnis
 * bei path2DD jedesmal einen neuen DD zuordnet, muû hier natÅrlich
 * noch testen, ob es nicht noch einen anderen DD gibt, der das
 * selbe Verzeichnis referenziert. Da das Ramdisk-XFS DDs mehrfach
 * nutzt, erÅbrigt sich das Problem hier.
 */
LONG ramdisk_ddelete(void *dir)
{
	RAMDISK_FD	*dd,
				parent,
				copy;
	DIRENTRY	*the_dir;
	WORD		i,
				cnt,
				max;

	TRACE(("ddelete - %L\r\n", 1, dir));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
	TRACE(("ddelete: %L entspricht %L\\%S\r\n", 3, dir, dd->fd_parent,
		dd->fd_file->de_fname));
	if (real_kernel->version < 3)
	{
/*
 * Vor Kernelversion 3 muû man, wie bereits erwÑhnt, den refcnt des
 * DDs selbst erniedrigen und dann prÅfen, ob er Null ist. Wenn nein,
 * darf das Verzeichnis nicht gelîscht werden, weil es vom Kernel
 * noch gebraucht wird.
 */
		if (--dd->fd_refcnt > 0)
		{
			TRACE(("ddelete: refcnt == %L!\r\n", 1,
				(LONG)dd->fd_refcnt));
			return(EACCDN);
		}
	}
	else
	{
/*
 * Ab Kernelversion 3 erledigt der Kernel diese Aufgabe, daher kann
 * hier der die Verringerung und PrÅfung des refcnts entfallen. Der
 * TRACE ist nur aus SicherheitsgrÅnden eingebaut, falls es wider
 * Erwarten doch nicht funktionieren sollte (bis dato habe ich noch
 * nicht die Kernelversion 3).
 */
		TRACE(("ddelete: Kernelversion > 2, kein fd_refcnt-Check!"
			"\r\n", 0));
	}
/*
 * Vom aktuellen DD eine Kopie machen, weil er u.U. freigegeben wird,
 * womit sein Inhalt natÅrlich verloren geht. Gleiches gilt fÅr den
 * DD des "Vaters".
 */
	copy = *dd;
	parent = *(dd->fd_parent);
/* Vor Kernelversion 3 muû der DD jetzt freigegeben werden */
	if (real_kernel->version < 3)
		ramdisk_freeDD(dd);
/*
 * Zum Lîschen eines Verzeichnisses muû das Vaterverzeichnis
 * beschreibbar sein
 */
	if (!waccess(parent.fd_file))
	{
		TRACE(("ddelete: Kein Schreibzugriff auf Elternverzeichnis!"
			"\r\n", 0));
		return(EACCDN);
	}
/* Das Verzeichnis selbst muû ebenfalls beschreibbar sein */
	if (!waccess(copy.fd_file))
	{
		TRACE(("ddelete: Verzeichnis ist schreibgeschÅtzt!\r\n", 0));
		return(EACCDN);
	}
/* Zum Lesen geîffnet darf das Verzeichnis ebenfalls nicht sein */
	the_dir = (DIRENTRY *)copy.fd_file->de_faddr;
	if (dir_is_open(the_dir))
	{
		TRACE(("ddelete: Verzeichnis offen!\r\n", 0));
		return(EACCDN);
	}
/*
 * Der Check, ob das Vaterverzeichnis noch offen ist, wird auch wegen
 * Problemen mit Thing defaultmÑûig nicht eingebunden, weil Thing
 * beim rekursiven Lîschen Ddelete aufruft, wenn das Vaterverzeichnis
 * noch geîffnet ist :(
 */
#ifdef CHECK_PARENT
/* Gleiches gilt fÅr das Vaterverzeichnis */
	if (dir_is_open((DIRENTRY *)parent.fd_file->de_faddr))
	{
		TRACE(("ddelete: Elternverzeichnis offen!\r\n", 0));
		return(EACCDN);
	}
#endif
/*
 * Jetzt muû geprÅft werden, ob das Verzeichnis leer ist, also keine
 * EintrÑge auûer "." und ".." mehr existieren
 */
	max = the_dir->de_maxnr;
	for (cnt = i = 0; i < max; i++)
	{
		if (the_dir[i].de_faddr != NULL)
		{
			if (++cnt > 2)
			{
				TRACE(("ddelete: Verzeichnis nicht leer!\r\n", 0));
				return(EACCDN);
			}
		}
	}
/*
 * Ging alles glatt, den Speicher, den das Verzeichnis belegt hat,
 * freigeben, die Modifikationszeit des Elternverzeichnisses anpassen
 * und den Eintrag im Vaterverzeichnis freigeben
 */
	Kfree(the_dir);
	work_entry(&parent, ".", NULL, 1, 0L, 0L, set_amtime);
	copy.fd_file->de_faddr = NULL;
	return(E_OK);
}

/*
 * DD2name soll zu einem gegebenen DD den Zugriffspfad liefern; hier
 * wird deutlich, wozu das Ramdisk-XFS eine rÅckwÑrts verkettete DD-
 * Struktur benutzt, da man so ohne groûe Sucherei den Pfad, der bis
 * zu einer bestimmten Stelle fÅhrt, zusammenstellen kann.
 * Unter MagiC 3 wird (zumindest bei mir mit diesem XFS) DD2name nie
 * aufgerufen, wenn man das Laufwerk Åber U: anspricht. Setzt man
 * also auf Laufwerk U: beispielsweise den Pfad \m\testdir und M ist
 * das Laufwerk des XFS, so liefert Dgetpath immer nur \m, DD2name
 * wird Åberhaupt nicht aufgerufen. Beim DOS-XFS passiert das
 * interessanterweise nicht... Zum GlÅck funktioniert mit MagiC 4
 * alles bestens, das Problem besteht also wirklich nur mit MagiC 3.
 */
LONG ramdisk_DD2name(void *dir, char *name, WORD bufsize)
{
	RAMDISK_FD	*dd;
	char		*temp;

	TRACE(("DD2name - %L\r\n", 1, dir));
/* Wie Åblich erstmal prÅfen, ob der dd gÅltig ist */
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/*
 * Wenn nicht mindestens ein Byte Platz hat, gleich einen Fehler
 * melden (wegen des abschlieûenden Nullbytes).
 */
	if (bufsize < 1)
		return(ERANGE);
	*name = 0;
	temp = (kernel->int_malloc)();
/*
 * Jetzt vom aktuellen dd rÅckwÑrts bis zu dem Verzeichnis im Pfad
 * gehen, das Åber dem Wurzelverzeichnis liegt. Damit am Ende der
 * Pfad in der richtigen Reihenfolge herauskommt, wird der aktuelle
 * aktuelle Ordnername umgedreht angehÑngt und das Ergebnis vor der
 * RÅckgabe ebenfalls komplett gedreht. Beim AnhÑngen jedes
 * Zwischenpfades muû natÅrlich geprÅft werden, ob im Puffer noch
 * genug Platz ist.
 */
	for (; dd->fd_parent != NULL; dd = dd->fd_parent)
	{
/* FÅr TOS-Domain-Prozesse einen verkrÅppelten Pfad liefern */
		if (Pdomain(-1) == 0)
			tostrunc(temp, dd->fd_file->de_fname, 0);
		else
			strcpy(temp, dd->fd_file->de_fname);
		if ((WORD)(strlen(name) + strlen(temp) + 1) >= bufsize)
		{
			(kernel->int_mfree)(temp);
			return(ERANGE);
		}
		strrev(temp);
		strcat(name, temp);
		strcat(name, "\\");
	}
/*
 * Zu guter Letzt den erzeugten Pfad umdrehen, damit er die richtige
 * Reihenfolge hat
 */
	strrev(name);
	(kernel->int_mfree)(temp);
	TRACE(("DD2name liefert: %S\r\n", 1, name));
	return(E_OK);
}

/*
 * Bei dopendir muû man, Ñhnlich wie bei path2DD, die zu liefernde
 * Struktur selbst zur VerfÅgung stellen. In ihr sollte man, neben
 * dem vom Kernel vorgeschriebenen DMD-Zeiger, alles speichern, damit
 * dreaddir mîglichst schnell arbeiten kann. Man sollte ebenfalls den
 * Prozeû, der dopendir aufgerufen hat, in der Struktur ablegen,
 * damit man bei dreaddir/dclosedir prÅfen kann, ob der richtige
 * Prozeû den Aufruf tÑtigt.
 * Man darf bzw. sollte in der Struktur keinen Zeiger auf den
 * DD des zu lesenden Verzeichnisses eintragen, da der Kernel nach
 * Dopendir den DD freigibt. Das erste dreaddir des XFS wÅrde dann
 * also einen DD benutzen, der nicht mehr gÅltig und u.U. sogar schon
 * wieder anderweitig vergeben ist.
 */
LONG ramdisk_dopendir(void *dir, WORD tosflag)
{
	WORD		i;
	RAMDISK_FD	*dd;

	TRACE(("dopendir %L\r\n", 1, dir));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/*
 * Zum Lesen eines Verzeichnisses sind nur Leserechte nîtig, das x-
 * Flag muû nur dann gesetzt sein, wenn man einen Eintrag innerhalb
 * des Verzeichnisses ansprechen will (es bedeutet, wie bereits
 * erwÑhnt, soviel wie "Verzeichnis darf Åberschritten werden")
 */
	if (!raccess(dd->fd_file))
		return(EACCDN);
/* Eine freie Directory-Handle-Struktur suchen */
	for (i = 0; i < MAX_DHD; i++)
	{
		if (dhd[i].dhd_dir == NULL)
		{
/*
 * Wurde eine gefunden, diese fÅllen. Dabei wird der Zeiger auf den
 * Beginn des zu lesenden Verzeichnisses, das tosflag und der
 * aufrufende Prozeû abgelegt. dhd_pos gibt fÅr dreaddir an, der
 * wievielte Eintrag der nÑchste zu lesende ist und muû daher zu
 * Beginn auf Null gesetzt werden.
 */
			dhd[i].dhd_dmd = ramdisk_dmd;
			dhd[i].dhd_dir = (DIRENTRY *)dd->fd_file->de_faddr;
			dhd[i].dhd_pos = 0;
			dhd[i].dhd_tosmode = tosflag;
			dhd[i].dhd_owner = *real_kernel->act_pd;
			return((LONG)&dhd[i]);
		}
	}
/* War keine Struktur mehr frei, einen Fehler melden */
	return(ENHNDL);
}

/*
 * In dreaddir hat man wieder zwei Probleme: Der Name muû unter
 * UmstÑnden in's 8+3-Format gewandelt werden und man muû u.U. die
 * XATTR-Struktur belegen. FÅr letzteres kann man natÅrlich die
 * xattr-Funktion benutzen; dazu muû man nur einen Pseudo-DD
 * anlegen, da xattr ja einen DD fÅr das aktuelle Verzeichnis
 * erwartet. Man kann natÅrlich ebenso eine Unterfunktion zum FÅllen
 * der XATTR-Struktur schreiben, die sowohl von xattr als auch von
 * dreaddir benutzt wird. FÅr das Wandeln in's 8+3-Format sollte von
 * sfirst her auch schon eine Funktion zur VerfÅgung stehen, also
 * ist es letztlich nicht so furchtbar schwer, dreaddir zu
 * realisieren.
 * Da ein Verzeichniseintrag der Ramdisk die XATTR-Struktur enthÑlt,
 * erÅbrigt sich das zweite genannte Problem hier ohnehin...
 */
LONG ramdisk_dreaddir(void *dhd, WORD size, char *buf, XATTR *xattr,
	LONG *xr)
{
	RAMDISK_DHD	*handle;
	RAMDISK_FD	help;
	DIRENTRY	*dir;
	WORD		pos;

	TRACE(("%S\r\n", 1, (xattr == NULL) ? "dreaddir" : "dxreaddir"));
	handle = (RAMDISK_DHD *)dhd;
/*
 * ZunÑchst einmal das Handle prÅfen, dabei auch auf den Prozeû 
 * achtenn. Der Test auf NULL ist zwar prinzipiell unnîtig, weil der
 * Kernel ja schon den DMD ermittelt haben muû, aber sicher ist
 * sicher.
 */
	if ((handle == NULL) || (handle->dhd_dmd != ramdisk_dmd) ||
		(handle->dhd_owner != *real_kernel->act_pd))
	{
		return(EIHNDL);
	}
/*
 * Da bei einem Lesezugriff auf ein Verzeichnis dessen Zugriffszeit
 * geÑndert werden muû, wird work_entry aufgerufen. Diese Funktion
 * erwartet allerdings einen DD, daher muû ein solcher generiert
 * werden (Ñhnlich wie oben fÅr den Aufruf von xattr vorgeschlagen).
 */
	help.fd_dmd = ramdisk_dmd;
	help.fd_refcnt = 0;
	help.fd_file = handle->dhd_dir;
	help.fd_parent = NULL;
	work_entry(&help, ".", NULL, 1, 1L, 0L, set_amtime);
	dir = handle->dhd_dir;
	pos = handle->dhd_pos;
/* Den nÑchsten nicht-leeren Verzeichniseintrag suchen */
	for (; (pos < dir->de_maxnr) && (dir[pos].de_faddr == NULL);
		pos++);
/* Gibt es keinen mehr, das Ende des Lesevorgangs signalisieren */
	if (pos >= dir->de_maxnr)
		return(ENMFIL);
/*
 * Ansonsten je nach Modus den Namen in's 8+3-Format quetschen oder
 * ihn unverÑndert samt Index (nicht vergessen!) ablegen. Dabei muû
 * immer darauf geachtet werden, daû der Zielpuffer genÅgend Platz
 * bietet!
 */
	if (handle->dhd_tosmode)
	{
		if (size < 13)
			return(ERANGE);
		tostrunc(buf, dir[pos].de_fname, 0);
	}
	else
	{
		if (((WORD)strlen(dir[pos].de_fname) + 4) >=
			size)
		{
			TRACE(("%S paût nicht in den Puffer!", 1,
				(LONG)dir[pos].de_fname));
			return(ERANGE);
		}
		*(LONG *)buf = (LONG)dir[pos].de_xattr.index;
		strcpy(&buf[4], dir[pos].de_fname);
	}
/*
 * Ggf. auch die XATTR-Struktur gefÅllt werden (also im Falle eines
 * Dxreaddir-Aufrufs). Dabei dÅrfen symbolische Links nicht verfolgt
 * werden!
 */
	if (xattr != NULL)
	{
		*xattr = dir[pos].de_xattr;
		*xr = 0L;
	}
/*
 * Zum Schluû noch den Lesezeiger fÅr den nÑchsten dreaddir-Aufruf
 * setzen
 */
	handle->dhd_pos = pos + 1;
	return(E_OK);
}

/*
 * FÅr das "ZurÅckspulen" eines Verzeichnisses muû nicht viel
 * beachtet werden, das betroffene Filesystem muû natÅrlich dazu in
 * der Lage sein. Wenn nicht, ist EINVFN zu liefern.
 * Beim Ramdisk-XFS genÅgt es, den Lesezeiger wieder auf Null zu
 * setzen.
 */
LONG ramdisk_drewinddir(void *dhd)
{
	RAMDISK_DHD	*handle;

	TRACE(("drewinddir\r\n", 0));
	handle = (RAMDISK_DHD *)dhd;
/* Wieder das Handle ÅberprÅfen */
	if ((handle == NULL) || (handle->dhd_dmd != ramdisk_dmd) ||
		(handle->dhd_owner != *real_kernel->act_pd))
	{
		return(EIHNDL);
	}
/* Lesezeiger zurÅcksetzen */
	handle->dhd_pos = 0;
	return(E_OK);
}

/*
 * Bei dclosedir hat man die Mîglichkeit, Puffer, die man u.U. bei
 * dopendir zur Beschleunigung des Lesens angefordert hat, wieder
 * freizugeben
 */
LONG ramdisk_dclosedir(void *dhd)
{
	RAMDISK_DHD	*handle;

	TRACE(("dclosedir\r\n", 0));
	handle = (RAMDISK_DHD *)dhd;
/* Handle checken */
	if ((handle == NULL) || (handle->dhd_dmd != ramdisk_dmd) ||
		(handle->dhd_owner != *real_kernel->act_pd))
	{
		return(EIHNDL);
	}
/* Handle freigeben */
	handle->dhd_dir = NULL;
	return(E_OK);
}

/*
 * dpathconf ist eine sehr wichtige Funktion, damit Programme
 * Informationen Åber das Filesystem ermitteln kînnen. Bislang sind
 * 8 Modi definiert, die genaue Bedeutung kann man vollstÑndig im
 * ersten Teil meines Artikels "Alternative Filesysteme im Griff" in
 * der ST-Computer 11/95, Seite 44ff nachlesen.
 * Wenn man einen bestimmten Modus nicht unterstÅtzt bzw. nicht
 * unterstÅtzen kann, muû dafÅr EINVFN geliefert werden.
 * Die Ergebnisse von dpathconf sind in der Regel vom Verzeichnis
 * unabhÑngig, es ist allerdings bei speziellen Filesystemen durchaus
 * anders denkbar.
 */
LONG ramdisk_dpathconf(void *dir, WORD which)
{
	TRACE(("dpathconf - %L, %L\r\n", 2, dir, (LONG)which));
	if (check_dd(dir) < 0)
		return(check_dd(dir));
	switch (which)
	{
		case -1:
/* Maximal Modus 8 */
			return(8);
		case 0:
/*
 * Es kînnen allerhîchstens soviel Dateien geîffnet werden wie FDs
 * vorhanden sind (minus 1 fÅr den Root-DD)
 */
			return(MAX_FD - 1);
		case 1:
/* Keine Hardlinks, also maximal 1 Link pro File */
			return(1);
		case 2:
/*
 * Pfadnamen kînnen unendlich lang werden (genaugenommen zwar nicht,
 * weil ja die Anzahl an DDs begrenzt ist, aber das macht letztlich
 * keinen groûen Unterschied)
 */
			return(0x7fffffffL);
		case 3:
/* Maximal 32 Zeichen Filename */
			return(32L);
		case 4:
/* "Am StÅck" kînnen maximal DEFAULTFILE Bytes geschrieben werden */
			return(DEFAULTFILE);
		case 5:
/* Die Ramdisk schneidet zu lange Filenamen automatisch ab */
			return(1L);
		case 6:
/* Volle Unterscheidung von Groû- und Kleinschreibung */
			return(0L);
		case 7:
/*
 * Mîgliche Filetypen: Directories, symbolische Links, normale Files.
 * Alle Unix-Filemodi bis auf Setuid, Setgid und das "Sticky-Bit".
 * TOS-Attribute: Verzeichnis, Nur Lesen, VerÑndert, symbolischer
 * Link (wie es MagiC benutzt)
 */
			return(0x01900000L | (0777L << 8L) |
				FA_RDONLY | FA_DIR | FA_CHANGED | FA_SYMLINK);
		case 8:
/* Alle Elemente der XATTR-Struktur echt vorhanden */
			return(0x0fffL);
		default:
/* Andere Dpathconf-Modi kennt das Filesystem nicht */
			return(EINVFN);
	}
}

/*
 * Bei dfree ist es mir nach wie vor ein RÑtsel, wozu ein DD
 * Åbergeben wird, ein DMD hÑtte gereicht (schlieûlich wird der freie
 * Platz auf einem Laufwerk nicht pfadabhÑngig sein, auûerdem gibt es
 * nur die GEMDOS-Funktion Dfree, die ein Laufwerk als Parameter
 * erhÑlt, keinen Pfad). Bei MiNT ist es Åbrigens Ñhnlich, komisch.
 */
LONG ramdisk_dfree(void *dd, DISKINFO *free)
{
	LONG	freeblocks,
			usedblocks;

	TRACE(("dfree\r\n", 0));
/*
 * Im Debug-Modus wird protokolliert, welche DDs durch welches
 * Verzeichnis belegt sind. Auf diese Weise kann bei Bedarf geprÅft
 * werden, ob DDs falsch oder unnîtig belegt sind oder versehentlich
 * freigegeben wurden
 */
#ifdef DEBUG
	{
		WORD	i;

		for (i = 0; i < MAX_FD; i++)
		{
			if (fd[i].fd_file != NULL)
			{	
				TRACE(("fd %L ist belegt durch %S!\r\n", 2, &fd[i],
					((DIRENTRY *)fd[i].fd_file)->de_fname));
			}
		}
	}
#endif
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/*
 * Die freien Blocks errechnen sich aus dem (fÅr die Ramdisk) noch
 * freien Speicher geteilt durch die Grîûe eines Fileblocks. Das
 * ergibt zwar nie einen 100%ig verlÑûlichen Wert, aber besser wird
 * man es bei einer Ramdisk auch kaum machen kînnen, da sich der
 * freie Speicher stÑndig Ñndern kann.
 */
	freeblocks = ((LONG)Kmalloc(-1) + DEFAULTFILE - 1) / DEFAULTFILE;
/*
 * Die belegten Blîcke werden rekursiv vom Wurzelverzeichnis aus
 * gezÑhlt. Das Wurzelverzeichnis selbst belegt 0 Blîcke, damit die
 * Ramdisk auch wirklich als leer angesehen wird, wenn keine Dateien
 * oder Verzeichnisse vorhanden sind.
 */
	usedblocks = get_size(root);
/* Die Zielstruktur belegen */
	free->b_free = freeblocks;
	free->b_total = freeblocks + usedblocks;
	free->b_secsiz = DEFAULTFILE;
	free->b_clsiz = 1L;
	return(E_OK);
}

/*
 * Diese direkte Hilfsfunktion fÅr dfree ermittelt rekursiv die
 * belegten Blocks relativ zum Directory search
 */
LONG get_size(DIRENTRY *search)
{
	WORD		i;
	LONG		newsize;

	TRACE(("get_size - Verzeichnis %L\r\n", 1, search));
/* ZunÑchst die Grîûe des aktuellen Directories selbst ermitteln */
	newsize = search[0].de_xattr.nblocks;
/*
 * Dann alle EintrÑge auûer "." und ".." durchgehen und ihre Grîûe
 * addieren, wenn es Dateien oder symbolische Links sind. Bei
 * Verzeichnissen wird get_size rekursiv aufgerufen und das
 * Ergebnis addiert.
 */
	for (i = 2; i < search[0].de_maxnr; i++)
	{
		if (search[i].de_faddr != NULL)
		{
			if (is_dir(search[i].de_xattr.mode))
				newsize += get_size((DIRENTRY *)search[i].de_faddr);
			else
				newsize += search[i].de_xattr.nblocks;
		}
	}
/* Am Ende die neu ermittelte Blockzahl zurÅckliefern */
	return(newsize);
}

/*
 * Hier muû ein Label angelegt/geÑndert werden, nÑheres siehe
 * MagiC-Doku. Werden keine Labels unterstÅtzt, muû EACCDN geliefert
 * werden.
 */
LONG ramdisk_wlabel(void *dir, char *name)
{
	TRACE(("wlabel - %S\r\n", 1, name));
/* dir wird nur ÅberprÅft, sonst aber ignoriert */
	if (check_dd(dir) < 0)
		return(check_dd(dir));
/*
 * Bei Bedarf Volume Label lîschen, sonst die ersten 32 Zeichen des
 * gewÅnschten Labels Åbernehmen
 */
	if (*name == '\xe5')
		strcpy(volume_label, "");
	else
	{
		volume_label[32] = 0;
		strncpy(volume_label, name, 32L);
	}
	return(E_OK);
}

/*
 * Zum Ermitteln des Volume Labels, nÑheres siehe MagiC-Doku.
 * Filesysteme ohne Volume Label sollten hier EFILNF liefern.
 * Der Parameter name wird von der Ramdisk ignoriert, was laut
 * Doku auch zulÑssig ist.
 */
LONG ramdisk_rlabel(void *dir, char *name, char *buf, WORD len)
{
	TRACE(("rlabel - %S %L\r\n", 2, name, (LONG)len));
/* dir wird zwar ÅberprÅft, sonst aber ignoriert */
	if (check_dd(dir) < 0)
		return(check_dd(dir));
/*
 * Ist das Label leer, wird EFILNF geliefert, weil genaugenommen
 * keines existiert
 */
	if (!*volume_label)
		return(EFILNF);
/* PrÅfen, ob der Zielpuffer genug Platz bietet */
	if ((WORD)strlen(volume_label) >= len)
		return(ERANGE);
/* Aktuelles Label in Zielpuffer kopieren */
	strcpy(buf, volume_label);
	return(E_OK);
}

/*
 * Ein symbolischer Link soll angelegt werden, werden keine solchen
 * unterstÅtzt, ist EINVFN zu liefern. Beim Ramdisk-XFS werden die
 * Links als ein Speicherblock abgelegt (der Inhalt wird ja sowieso
 * nicht mehr verÑndert) und haben genau das Format, daû MagiC fÅr
 * das ZurÅckliefern von Linkzielen bei ELINK vorschreibt. Bis heute
 * ist mir noch nicht so ganz klar, wieso Andreas ein so eigenartiges
 * Format gewÑhlt hat, das weder ein Pascal-, noch ein C-String ist,
 * sondern eher ein Gemisch aus beidem... Vielleicht ein GFA-Basic-
 * String? ;>
 */
LONG ramdisk_symlink(void *dir, char *name, char *to)
{
	RAMDISK_FD	*dd;
	DIRENTRY	*entry;
	char		*link;
	LONG		len;

	TRACE(("symlink - %S to %L\\%S\r\n", 3, to, dir, name));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
#ifdef CHECK_OPEN
/* PrÅfen, ob das Verzeichnis nicht noch geîffnet ist */
	if (dir_is_open((DIRENTRY *)dd->fd_file->de_faddr))
		return(EACCDN);
#endif
/* Herausfinden, ob eine Datei gleichen Namens schon existiert */
	if (findfile(dd, name, 0, FF_EXIST, 0) != NULL)
		return(EACCDN);
/* Versuchen, einen neuen Eintrag zu erhalten */
	if ((entry = new_file(dir, name)) == NULL)
		return(EACCDN);
/*
 * Berechnen, wieviel Speicher der Link im MagiC-Format braucht und
 * diesen anfordern
 */
	len = strlen(to) + 1L;
	if (len & 1)
		len++;
	if ((link = Kmalloc(len + 2L)) == NULL)
		return(ENSMEM);
/*
 * Ging alles glatt, jetzt die Modifikationszeit des Verzeichnisses
 * anpassen, das Ziel des Links in den angeforderten Speicherbereich
 * kopieren und den neuen Verzeichniseintrag auffÅllen. Dabei wird
 * als GEMDOS-Attribut das von MagiC benutzte FA_SYMLINK eingetragen.
 */
	work_entry(dd, ".", NULL, 1, 0L, 0L, set_amtime);
	*(WORD *)link = (WORD)len;
	strcpy(&link[2], to);
	entry->de_faddr = link;
	entry->de_xattr.mode = S_IFLNK | 0777;
	entry->de_xattr.index = (LONG)link;
	entry->de_xattr.size = len + 2L;
	entry->de_xattr.nblocks = (len + 1L + DEFAULTFILE) / DEFAULTFILE;
	entry->de_xattr.attr = FA_SYMLINK; /* MagiC-TOSFS-like */
	return(E_OK);
}

/*
 * Beim Lesen eine symbolischen Links muû darauf geachtet werden, daû
 * size groû genug ist, den Zugriffspfad samt abschlieûendem Nullbyte
 * aufzunehmen. UnterstÅtzt das XFS keine symbolischen Links, muû
 * auch hier EINVFN geliefert werden.
 */
LONG ramdisk_readlink(void *dir, char *name, char *buf, WORD size)
{
	RAMDISK_FD	*dd;
	DIRENTRY	*found;

	TRACE(("readlink - %L\\%S\r\n", 2, dir, name));
	dd = (RAMDISK_FD *)dir;
	if (check_dd(dd) < 0)
		return(check_dd(dd));
/* Den Verzeichniseintrag suchen */
	if ((found = findfile(dd, name, 2, FF_SEARCH, 0)) == NULL)
		return(EFILNF);
/* Wenn es kein symbolischer Link ist, einen Fehler melden */
	if (!is_link(found->de_xattr.mode))
		return(EACCDN);
/* PrÅfen, ob der Zielpuffer groû genug ist */
	if (size < (strlen(&found->de_faddr[2]) + 1L))
		return(ERANGE);
/*
 * Wenn ja, wird die letzte Zugriffszeit des Links gesetzt und der
 * Zielpfad in den Puffer kopiert
 */
	found->de_xattr.atime = Tgettime();
	found->de_xattr.adate = Tgetdate();
	strcpy(buf, &found->de_faddr[2]);
	return(E_OK);
}

/*
 * dcntl fÅhrt bestimmte Aktionen fÅr VerzeichniseintrÑge durch. Der
 * Inhalt von arg hÑngt dabei von cmd ab. Nicht unterstÅtzte Modi
 * sind mit EINVFN abzulehnen, gleiches gilt natÅrlich auch fÅr den
 * Fall, daû dcntl Åberhaupt nicht unterstÅtzt wird. Auf jeden Fall
 * aber sollten symbolische Links verfolgt werden.
 * Im Ramdisk-XFS ist Dcntl wieder Åber work_entry realisiert, um
 * auch Verzeichnisse bearbeiten zu kînnen. Bislang wird nur FUTIME
 * (Zeiten verÑndern) unterstÅtzt.
 */
LONG ramdisk_dcntl(void *dir, char *name, WORD cmd, LONG arg,
	char **symlink)
{
	RAMDISK_FD	*dd;

	TRACE(("dcntl - %L\\%S, %L, %L\r\n", 4, dir, name, (LONG)cmd,
		arg));
	dd = (RAMDISK_FD *)dir;
	return(work_entry(dd, name, symlink, 1, cmd, arg, dcntl_action));
}

LONG dcntl_action(DIRENTRY *entry, LONG cmd, LONG arg)
{
	WORD	*timebuf;

	switch ((WORD)cmd)
	{
/*
 * Zu FUTIME habe ich bisher keine brauchbare Doku gefunden, daher
 * hier eine kurze Beschreibung (die Funktionsweise habe ich in den
 * MinixFS-Sourcen entnommen):
 * FÅr das Kommando FUTIME zeigt arg auf ein WORD-Array mit vier
 * Elementen. Die Belegung:
 * arg[0] - Uhrzeit des letzten Zugriffs
 * arg[1] - Datum des letzten Zugriffs
 * arg[2] - Uhrzeit der letzten Modifikation
 * arg[3] - Datum der letzten Modifikation
 * Wenn arg ein Nullzeiger ist, sollen alle drei Zeiten (also auch
 * die Erstellungszeit) auf das aktuelle Datum gesetzt werden, sonst
 * atime/adate auf arg[0/1], mtime/mdate auf arg[2/3] und ctime/cdate
 * auf die aktuelle Uhrzeit/das aktuelle Datum. Die Erstellungszeit
 * (also ctime/cdate) wird immer auf die aktuelle Zeit gesetzt, damit
 * man eine Datei nicht zurÅckdatieren kann (das kann durchaus
 * wichtig sein).
 */
		case FUTIME:
/* FÅr FUTIME braucht man Schreibzugriff auf die Datei */
			if (!waccess(entry))
				return(EACCDN);
			timebuf = (WORD *)arg;
			entry->de_xattr.ctime = Tgettime();
			entry->de_xattr.cdate = Tgetdate();
			if (timebuf != NULL)
			{
				entry->de_xattr.atime = timebuf[0];
				entry->de_xattr.adate = timebuf[1];
				entry->de_xattr.mtime = timebuf[2];
				entry->de_xattr.mdate = timebuf[3];
			}
			else
			{
				entry->de_xattr.atime = entry->de_xattr.mtime =
					entry->de_xattr.ctime;
				entry->de_xattr.adate = entry->de_xattr.mdate =
					entry->de_xattr.cdate;
			}
			return(E_OK);
		default:
			return(EINVFN);
	}
}

/* Ab hier folgen die Funktionen des Device-Treibers */

/*
 * Wenn eine Datei geschlossen werden soll, muû man sicherstellen,
 * daû der refcnt auch wirklich Null ist, bevor man ihn freigibt
 */
LONG ramdisk_close(void *file)
{
	RAMDISK_FD	*fd;

	TRACE(("close - %L\r\n", 1, file));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
	{
		TRACE(("close: check_fd fehlgeschlagen!\r\n", 0));
		return(check_fd(fd));
	}
	TRACE(("close: fd_refcnt vorher: %L", 1, (LONG)fd->fd_refcnt));
	if (fd->fd_refcnt)
		fd->fd_refcnt--;
	TRACE(("close: fd_refcnt nachher: %L", 1, (LONG)fd->fd_refcnt));
	if (!fd->fd_refcnt)
		fd->fd_file = NULL;
	return(E_OK);
}

/*
 * Beim Lesen muû man immer darauf achten, daû man nicht Åber das
 * Ende der Datei hinausliest, ggf. muû man weniger lesen. Man darf
 * dabei auch nicht vergessen, daû read nach erfolgreichem Lesen
 * die Anzahl der Bytes zurÅckliefert. Ist man also am Ende der Datei
 * angelangt, wird kein Fehler gemeldet, sondern lediglich 0 Bytes
 * gelesen.
 * Beim Ramdisk-XFS kann beim Lesen natÅrlich kein Fehler auftreten
 * (zumindest kann er nicht bemerkt werden), allerdings ist das Lesen
 * insgesamt etwas trickreich, da man sich ja an der verketteten
 * Liste von Fileblîcken entlanghangeln muû. Erschwert wird das noch
 * durch die Tatsache, daû die Startposition des Lesevorgangs selten
 * direkt am Anfang eines Blocks liegt.
 */
LONG ramdisk_read(void *file, LONG count, char *buffer)
{
	RAMDISK_FD	*fd;
	FILEBLOCK	*the_file;
	LONG		pos,
				read,
				readable;

	TRACE(("read - %L, %L\r\n", 2, file, count));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
/*
 * Wenn das File nicht zum Lesen oder AusfÅhren geîffnet war, einen
 * Fehler melden
 */
	if ((fd->fd_mode & (OM_RPERM | OM_EXEC)) == 0)
		return(EACCDN);
/* Ggf. die Anzahl der zu lesenden Bytes verringern */
	if ((fd->fd_fpos + count) > fd->fd_file->de_xattr.size)
		count = fd->fd_file->de_xattr.size - fd->fd_fpos;
/*
 * Den Fileblock und die Position in ihm ermitteln, an der das Lesen
 * beginnen muû
 */
	pos = 0L;
	the_file = (FILEBLOCK *)fd->fd_file->de_faddr;
	while ((pos + DEFAULTFILE) < fd->fd_fpos)
	{
		the_file = the_file->next;
		pos += DEFAULTFILE;
	}
	pos = fd->fd_fpos - pos;
/*
 * In der folgenden Schleife werden so lange aufeinanderfolgende
 * Fileblîcke in den Zielpuffer kopiert, bis alle lesbaren Bytes
 * bearbeitet wurden. Da Anfang und Ende des Lesens mitten in einem
 * Block liegen kînnen, wird mit der Variable readable angegeben,
 * wieviele Bytes im aktuellen Durchgang gelesen werden kînnen.
 */
	readable = DEFAULTFILE - pos;
	read = 0L;
	while (count > 0L)
	{
		readable = (readable > count) ? count : readable;
		memcpy(buffer, &(the_file->data)[pos], readable);
		count -= readable;
		read += readable;
		buffer = &buffer[readable];
		readable = DEFAULTFILE;
		pos = 0L;
		the_file = the_file->next;
	}
/*
 * Am Ende die Position des innerhalb der Datei auf den aktuellen
 * Stand bringen und die letzte Zugriffszeit setzen
 */
	fd->fd_fpos += read;
	fd->fd_file->de_xattr.atime = Tgettime();
	fd->fd_file->de_xattr.adate = Tgetdate();
/* ZurÅckgeben, wieviele Bytes tatsÑchlich gelesen wurden */
	return(read);
}

/*
 * FÅr das Schreiben gilt Ñhnliches wie fÅr das Lesen, allerdings muû
 * hier die Datei - soweit noch mîglich - erweitert werden, wenn Åber
 * ihr bisheriges Ende hinaus geschrieben werden soll. Kînnen nicht
 * alle Bytes geschrieben werden, muû auch hier die Zahl entsprechend
 * verkÅrzt werden.
 * FÅr die Ramdisk mÅssen, wenn die Datei durch den Schreibzugriff
 * lÑnger wird, entsprechend viele Fileblîcke neu angefordert und an
 * die bisherigen angehÑngt werden. Sollte kein Speicher mehr frei
 * sein, kînnen eben nicht alle Bytes geschrieben werden.
 */
LONG ramdisk_write(void *file, LONG count, char *buffer)
{
	RAMDISK_FD	*fd;
	FILEBLOCK	*the_file,
				*add,
				*j,
				*new;
	LONG		new_blocks,
				i,
				writeable,
				written,
				maxcount,
				pos;

	TRACE(("write - %L, %L\r\n", 2, file, count));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
/* Fehler melden, wenn das File nicht zum Schreiben geîffnet ist */
	if ((fd->fd_mode & OM_WPERM) == 0)
		return(EACCDN);
/*
 * Den Fileblock, in dem das Schreiben beginnt und den, an den ggf.
 * neue Blîcke angehÑngt werden, ermitteln.
 */
	pos = 0L;
	j = the_file = (FILEBLOCK *)fd->fd_file->de_faddr;
	while (j != NULL)
	{
		if ((pos + DEFAULTFILE) < fd->fd_fpos)
		{
			the_file = j->next;
			pos += DEFAULTFILE;
		}
		add = j;
		j = j->next;
	}
/*
 * Berechnen, wieviele Bytes maximal in die bisher vorhandenen
 * Fileblîcke passen. Sollte das nicht reichen, um alle gewÅnschten
 * Bytes zu schreiben, muû die Datei erweitert werden.
 */
	maxcount = fd->fd_file->de_xattr.nblocks * DEFAULTFILE;
	if ((fd->fd_fpos + count) > maxcount)
	{
/*
 * Zum Erweitern berechnen, wieviele neue Fileblîcke benîtigt werden
 */
		new_blocks = (fd->fd_fpos + count + DEFAULTFILE - 1) /
			DEFAULTFILE;
		new_blocks -= fd->fd_file->de_xattr.nblocks;
/*
 * Entsprechend viele Blîcke der Reihe nach anfordern, an das
 * Fileende anhÑngen und die Zahl der schreibbaren Bytes entsprechend
 * erhîhen. Sollte fÅr einen Block kein Speicher mehr verfÅgbar sein,
 * muû die Schleife vorzeitig abgebrochen werden.
 */
		for (i = 0; i < new_blocks; i++)
		{
			if ((new = Kmalloc(sizeof(FILEBLOCK))) == NULL)
				break;
			fd->fd_file->de_xattr.nblocks++;
			maxcount += DEFAULTFILE;
			add->next = new;
			new->next = NULL;
			add = new;
		}
/*
 * Jetzt bestimmen, wieviele Bytes tatsÑchlich geschrieben werden
 * kînnen
 */
		if ((fd->fd_fpos + count) > maxcount)
			count = maxcount - fd->fd_fpos;
	}
/*
 * Die Vorgehensweise zum Schreiben entspricht exakt der zum Lesen,
 * nur daû Quelle und Ziel vertauscht sind
 */
	pos = fd->fd_fpos - pos;
	writeable = DEFAULTFILE - pos;
	written = 0L;
	while (count > 0L)
	{
		writeable = (writeable > count) ? count : writeable;
		memcpy(&(the_file->data)[pos], buffer, writeable);
		count -= writeable;
		written += writeable;
		buffer = &buffer[writeable];
		writeable = DEFAULTFILE;
		pos = 0L;
		the_file = the_file->next;
	}
/*
 * Auch hier nach dem Schreiben die Position innerhalb der Datei auf
 * den aktuellen Stand bringen. Da sich die Datei durch das Schreiben
 * vergrîûert haben kann, muû ggf. die Dateigrîûe im Directoryeintrag
 * angepaût werden. Beim Lesen des Eintrags erhÑlt man also immer die
 * gerade aktuelle LÑnge, selbst wenn das File noch beschrieben wird.
 */
	fd->fd_fpos += written;
	if (fd->fd_fpos > fd->fd_file->de_xattr.size)
		fd->fd_file->de_xattr.size = fd->fd_fpos;
/*
 * Die Modifikationszeit der Datei setzen und anzeigen, daû die Datei
 * verÑndert wurde. Am Schluû dann die Zahl der geschriebenen Bytes
 * zurÅckliefern.
 */
	fd->fd_file->de_xattr.mtime = Tgettime();
	fd->fd_file->de_xattr.mdate = Tgetdate();
	fd->fd_file->de_xattr.attr |= FA_CHANGED;
	return(written);
}

/*
 * Mit stat soll festgestellt werden, ob Bytes gelesen bzw.
 * geschrieben werden kînnen. Da die Ramdisk ohnehin immer bereit
 * ist, wird hier auch keine Interruptroutine benîtigt. Damit habe
 * ich mich auch noch nicht auseinandergesetzt, zumal das Problem
 * in der Regel auch nur fÅr "echte" Devices akut ist.
 */
LONG ramdisk_stat(void *file, MAGX_UNSEL *unselect, WORD rwflag,
	LONG apcode)
{
	RAMDISK_FD	*fd;
	LONG		retcode;

	TRACE(("stat - %L, %L, %L, %L\r\n", 4, file, unselect,
		(LONG)rwflag, apcode));
	fd = (RAMDISK_FD *)file;
/*
 * Man mîge mir die Verwendung von goto verzeihen, aber hier ist es
 * wirklich Ñuûerst praktisch
 */
	if (check_fd(fd) < 0)
	{
		retcode = check_fd(fd);
		goto rs_exit;
	}
/*
 * Wenn Lesebereitschaft bei einem File getestet werden soll, daû
 * nicht zum Lesen geîffnet ist, muû ein Fehler gemeldet werden
 */
	if (!rwflag && ((fd->fd_mode & (OM_RPERM | OM_EXEC)) == 0))
	{
		retcode = EACCDN;
		goto rs_exit;
	}
/* Gleiches gilt natÅrlich auch fÅr den umgekehrten Fall */
	if (rwflag && ((fd->fd_mode & OM_WPERM) == 0))
	{
		retcode = EACCDN;
		goto rs_exit;
	}
/* Ansonsten kann getrost "Bereit" gemeldet werden */
	retcode = 1L;
/*
 * Bei der ErgebnisrÅckgabe muû, wenn unselect kein Nullpointer war,
 * der Returnwert auch in unsel.status abgelegt werden (daher auch
 * das goto, um unnîtige Tipparbeit und if-Verrenkungen zu vermeiden)
 */
rs_exit:
	if (unselect != NULL)
		unselect->unsel.status = retcode;
	return(retcode);
}

/*
 * Wenn der Schreib-/Lesezeiger einer Datei verschoben werden soll,
 * muû man natÅrlich auf BereichsÅberschreitungen achten und ggf.
 * ERANGE melden. Ansonsten ist seek, zumindest beim Ramdisk-XFS,
 * kein Problem.
 */
LONG ramdisk_seek(void *file, LONG where, WORD mode)
{
	RAMDISK_FD	*fd;
	LONG		new_pos;

	TRACE(("seek - %L, %L, %L\r\n", 3, file, where, (LONG)mode));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
/* Je nach Modus die Bezugsposition fÅr das seek ermitteln */
	switch (mode)
	{
		case 0:
			new_pos = 0L;
			break;
		case 1:
			new_pos = fd->fd_fpos;
			break;
		case 2:
			new_pos = fd->fd_file->de_xattr.size;
			break;
		default:
/*
 * Bei einem ungÅltigen Seek-Modus gebe ich einfach die aktuelle
 * Position zurÅck. Ob das so OK ist, weiû ich nicht, aber wenn ein
 * Programm Fseek falsch aufruft, muû es auch mit falschen
 * Ergebnissen rechnen...
 */
			return(fd->fd_fpos);
	}
/*
 * Den Offset addieren (er gibt immer an, wieviele Bytes Åbersprungen
 * werden sollen, also muû er fÅr Modus 2 einen Wert <= 0 haben).
 * WÅrden dadurch die Grenzen Åberschritten, den Zeiger nicht
 * verÑndern und einen Fehler melden.
 */
	new_pos += where;
	if ((new_pos < 0L) || (new_pos > fd->fd_file->de_xattr.size))
		return(ERANGE);
/*
 * Ging alles glatt, den Zeiger auf die neue Position setzen und
 * diese zurÅckliefern
 */
	fd->fd_fpos = new_pos;
	return(new_pos);
}

/*
 * Soll das Datum einer geîffneten Datei verÑndert werden, muû man
 * vorher unter UmstÑnden klÑren, welche der drei Zeiten, die eine
 * Datei haben kann (Erstellung, letzter Zugriff, letzte énderung),
 * man Ñndern bzw. auslesen will. FÅr das Ramdisk-XFS funktioniert
 * datime beim éndern Ñhnlich wie das FUTIME-Kommando von
 * Dcntl/Fcntl, d.h. ctime/cdate werden auf die aktuelle Zeit/das
 * aktuelle Datum gesetzt, atime/adate und mtime/mdate erhalten
 * die Werte, die datime Åbergeben wurden. Beim Auslesen wird immer
 * das Datum der letzten énderung genommen, wie es auch in der DTA
 * von snext geliefert wird.
 */
LONG ramdisk_datime(void *file, WORD *d, WORD setflag)
{
	RAMDISK_FD	*fd;

	TRACE(("datime - %L, %L\r\n", 2, file, (LONG)setflag));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
	switch(setflag)
	{
		case 0:
/* Zeit und Datum der letzten Modifikation auslesen */
			d[0] = fd->fd_file->de_xattr.mtime;
			d[1] = fd->fd_file->de_xattr.mdate;
			break;
		case 1:
/* Zum éndern mÅssen Schreibrechte fÅr die Datei vorhanden sein */
			if (!waccess(fd->fd_file))
				return(EACCDN);
			fd->fd_file->de_xattr.ctime = Tgettime();
			fd->fd_file->de_xattr.cdate = Tgetdate();
			fd->fd_file->de_xattr.atime =
				fd->fd_file->de_xattr.mtime = d[0];
			fd->fd_file->de_xattr.adate =
				fd->fd_file->de_xattr.mdate = d[1];
			break;
		default:
/* UngÅltige Werte fÅr setflag werden mit Fehler quittiert */
			return(EACCDN);
	}
	return(E_OK);
}

/*
 * ioctl ist der Bruder von dcntl und ist fÅr offene Dateien
 * zustÑndig. Hier gibt es eine Reihe von Kommandos, die man
 * unterstÅtzen kann (siehe auch die MagiC- und die MiNT-Doku).
 * Das Ramdisk-XFS unterstÅtzt FSTAT (XATTR-Struktur zur Datei
 * liefern), FIONREAD (wieviele Bytes kînnen sicher gelesen werden),
 * FIONWRITE (wieviele Bytes kînnen sicher geschrieben werden) und
 * FUTIME (Zugriffs- und Modifikationszeit Ñndern).
 */
LONG ramdisk_ioctl(void *file, WORD cmd, void *buf)
{
	RAMDISK_FD	*fd;
	WORD		*timebuf;
	LONG		*avail;
	XATTR		*xattr;

	TRACE(("ioctl - %L, %L, %L\r\n", 3, file, (LONG)cmd,  buf));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
	avail = (LONG *)buf;
	switch (cmd)
	{
/* Zu FUTIME siehe dcntl */
		case FUTIME:
			if (!waccess(fd->fd_file))
				return(EACCDN);
			timebuf = (WORD *)buf;
			fd->fd_file->de_xattr.ctime = Tgettime();
			fd->fd_file->de_xattr.cdate = Tgetdate();
			if (timebuf != NULL)
			{
				fd->fd_file->de_xattr.atime = timebuf[0];
				fd->fd_file->de_xattr.adate = timebuf[1];
				fd->fd_file->de_xattr.mtime = timebuf[2];
				fd->fd_file->de_xattr.mdate = timebuf[3];
			}
			else
			{
				fd->fd_file->de_xattr.atime =
					fd->fd_file->de_xattr.mtime =
					fd->fd_file->de_xattr.ctime;
				fd->fd_file->de_xattr.adate =
					fd->fd_file->de_xattr.mdate =
					fd->fd_file->de_xattr.cdate;
			}
			return(E_OK);
		case FIONREAD:
/*
 * Es kann natÅrlich nur fÅr Dateien, die zum Lesen geîffnet sind,
 * die Anzahl der lesbaren Bytes ermittelt werden
 */
			if ((fd->fd_mode & (OM_RPERM | OM_EXEC)) == 0)
				return(EACCDN);
/*
 * Bei der Ramdisk kînnen immer soviele Bytes gelesen werden, wie
 * noch zwischen Lesezeigerposition und Dateiende vorhanden sind
 */
			*avail = fd->fd_file->de_xattr.size - fd->fd_fpos;
			return(E_OK);
		case FIONWRITE:
/*
 * FÅr FIONWRITE gilt natÅrlich analog zu FIONREAD, daû nur fÅr
 * Dateien, die zum Schreiben offen sind, die Anzahl der schreibbaren
 * Bytes ermittelt werden kann
 */
			if ((fd->fd_mode & OM_WPERM) == 0)
				return(EACCDN);
/*
 * Es kînnen auf jeden Fall soviele Bytes geschrieben werden, wie
 * zwischen Ende des letzten Fileblocks und der Position des
 * Schreibzeigers noch vorhanden sind
 */
			*avail = fd->fd_file->de_xattr.nblocks * DEFAULTFILE -
				fd->fd_fpos;
			if (*avail < 0L)
				*avail = 0L;
			return(E_OK);
		case FSTAT:
/*
 * FÅr FSTAT muû einfach die XATTR-Struktur der Datei in den
 * Zielbereich kopiert werden. FÅr andere Filesysteme ist das u.U.
 * wesentlich kompliziert, weil die XATTR-Struktur erst "gebastelt"
 * werden muû.
 */
			xattr = (XATTR *)buf;
			*xattr = fd->fd_file->de_xattr;
			return(E_OK);
		default:
/* Nicht unterstÅtzte Kommandos mÅssen mit EINVFN abgelehnt werden */
			return(EINVFN);
	}
}

/*
 * Ein Byte aus einer Datei auslesen. Bei Filesystemen fÅhrt man
 * diese Funktion am zweckmÑûigsten auf read mit LÑnge 1 zurÅck.
 * ErhÑlt man dabei einen Wert ungleich 1, ist entweder ein Fehler
 * aufgetreten oder das Dateiende erreicht. Im Ramdisk-XFS wird in
 * beiden FÑllen "Dateiende" signalisiert, weil der nÑchste Aufruf
 * sicherlich ebensowenig erfolgreich sein wird. mode wird nicht
 * beachtet!
 */
LONG ramdisk_getc(void *file, WORD mode)
{
	RAMDISK_FD	*fd;
	UBYTE		dummy;

	TRACE(("getchar - %L, %L\r\n", 2, file, (LONG)mode));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
	if (ramdisk_read(file, 1L, (char *)&dummy) != 1L)
		return(0xff1aL);
/*
 * Konnte ein Byte gelesen werden, dieses auf ULONG erweitern und
 * zurÅckliefern
 */
	return((ULONG)dummy);
}

/*
 * getline ist etwas vertrackter, weil man prinzipiell auch auf
 * Zeilenende reagieren muû. Man kann es sich natÅrlich auch einfach
 * machen, und getline direkt auf read zurÅckfÅhren (size Bytes
 * lesen), dabei werden aber unter UmstÑnden mehrere Zeilen auf
 * einmal gelesen (so macht es z.B. auch MiNT). Auf jeden Fall muû
 * man zum Ermitteln der Zahl der gelesenen Zeichen, die ja als
 * Returnwert geliefert werden sollen, nach dem ersten CR bzw. LF
 * suchen und darf dieses dann _nicht_ dazurechnen.
 * Das Ramdisk-XFS versucht, via getc bis zum Dateiende oder einem
 * Zeilenende zu lesen, maximal natÅrlich size Bytes. Auch hier wird
 * mode nicht beachtet, was aber sowieso eher fÅr Terminal-Devices
 * wichtig ist.
 */
LONG ramdisk_getline(void *file, char *buf, WORD mode, LONG size)
{
	RAMDISK_FD	*fd;
	LONG		dummy,
				count;

	TRACE(("getline - %L, %L, %L\r\n", 3, file, size, (LONG)mode));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(0L);
/*
 * Die Schleife hat nur interne Abbruchsbedingungen, count zÑhlt
 * dabei, wieviele Zeichen bisher eingelesen wurden
 */
	for (count = 0L;; count++)
	{
/* Abbrechen, wenn schon die Maximalzahl an Zeichen gelesen ist */
		if (count == size)
			return(count);
/* Das nÑchste Zeichen via getline einlesen */
		dummy = ramdisk_getc(file, 0);
		TRACE(("getline: count = %L, gelesenes Byte: %L\r\n", 2,
			count, dummy));
/*
 * Ist es das Zeichen fÅr Dateiende, den Puffer mit einem Nullbyte
 * abschlieûen und die Zahl der gelesen Zeichen liefern (das mit dem
 * Nullbyte ist nicht unbedingt nîtig, sieht allerdings besser aus)
 */
		if (dummy == 0xff1aL)
		{
			buf[count] = 0;
			return(count);
		}
/*
 * Wurde ein CR oder ein LF gelesen, ist der Lesevorgang ebenfalls
 * beendet, das jeweilige Zeichen darf aber nicht mitgezÑhlt werden.
 * Im Falle von CR muû noch das nÑchste Zeichen Åberlesen werden, da
 * Zeilenenden entweder CRLF oder LF sind und das LF im ersten Fall
 * eben Åbersprungen werden muû (sonst wÅrde der nÑchste Aufruf von
 * getline eine Leerzeile liefern).
 */
		if ((dummy == 0xdL) || (dummy == 0xaL))
		{
			if (dummy == 0xdL)
				ramdisk_getc(file, 0);
			buf[count] = 0;
			return(count);
		}
/*
 * Bei allen anderen Zeichen dieses jetzt im Puffer plazieren und den
 * nÑchsten Schleifendurchlauf beginnen
 */
		buf[count] = dummy;
	}
}

/*
 * Auch das Ausgeben fÅhrt man am geschicktesten auf write zurÅck,
 * zumal als RÅckgabewert ohnehin die Zahl der geschriebenen Zeichen
 * geliefert werden muû (bei Devicetreiben von Filesystemen entweder
 * 0 oder 1).
 * Das Ramdisk-XFS beachtet auch hier mode nicht, weil das eigentlich
 * nur fÅr Terminal-Devicetreiber sinnvoll ist.
 */
LONG ramdisk_putc(void *file, WORD mode, LONG value)
{
	RAMDISK_FD	*fd;
	char		dummy;

	TRACE(("putc - %L, %L, %L\r\n", 3, file, (LONG)mode, value));
	fd = (RAMDISK_FD *)file;
	if (check_fd(fd) < 0)
		return(check_fd(fd));
	dummy = (char)value;
	return(ramdisk_write(file, 1L, &dummy));
}
#pragma warn .par

/* EOF */
