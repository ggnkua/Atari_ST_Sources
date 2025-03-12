Beschreibung der Treiberstruktur fÅr MIDI-COM 3.92

Der vorliegende Treiber ist in 3 Ebenen aufgeteilt. Jede der Ebenen setzt 
auf die darunerliegende auf.

Ebene 0:
(DRV_ASS.S)
a) liest und schreibt auf der Schnittstelle (Interruptebene):
b) Installiert die Interruptfunktionen.

Ebene 1:
liest und schreibt Blockweise

Ebene 2:
Kontrolle des Netzes. (Token/Fehlerkorrektur/Erkennung von Verdopplungen ...)

Die oberste Ebene bietet Ihre Funktionen in einem COOKIE an. Der COOKIE wird 
mit "MCTR" identifiziert.

Der COOKIE-Wert zeigt auf die folgende Struktur:

typedef struct 
{
	int		(*SENDE)(int an,int LEN,char *buff);
	int		(*REPLY)(int LEN,char *buff);
	ret_wert	(*LESE)(int *len,char *buff);
	int		(*CMD)(int cmd,int *par1,int *par2);
	char		*unused2;
}io_port;

Beschreibung der Funktionen:
============================

		int	(*SENDE)(int an,int LEN,char *buff);

an:	Ein Bit-Muster, das die EmpfÑnger angibt. Es kînnen auch mehr als 
		ein EmpfÑnger fÅr eine Sendung angegeben werden.
		Die Node-ID's mÅssen zwischen 0 und 6 liegen (s. CMD).
		Ist BIT 0 gesetzt ist also der Rechner mit der Node-ID 0 der EmpfÑnger.
		Ist BIT 1 gesetzt ist also der Rechner mit der Node-ID 1 der EmpfÑnger.
		.....
Ist BIT 7 gesetzt, ist eine Broadcast-Sendung vorgesehen.
Broadcastsendungen werden an den Absender zurÅckgegeben, wenn alle EmpfÑnger 
erreicht wurden. Im Gegensatz zu normalen Datenpaketen werden KEINE REPLY-
Aufrufe von MIDI_COM durchgefÅhrt. Das heiût, eine normale Sendung 
(==genau ein EmpfÑnger) wird immer durch MIDI_COM beantwortet, Broadcasts 
nicht.

LEN	Die Paket-LÑnge

*buff Zeiger auf die Daten, die verschickt werden sollen.

Return-Wert:  Wird zur Zeit noch nicht von MIDI_COM ausgewertet. 

Bei dieser Funktion erwartet MIDI_COM, das die Datenpakete MIT 
SICHERHEIT den EmpfÑnger mindestens einmal erreichen.  Der Treiber muû 
also dafÅr sorgen, das eine Sendung solange wiederholt wird, bis die 
Nachricht eingetroffen ist.

-----------------------------------------------------------------------

		int	(*REPLY)(int LEN,char *buff);

LEN	Die Paket-LÑnge
*buff Zeiger auf die Daten, die verschickt werden sollen.

Dieser Aufruf erfolgt nach einem Datenempfang (siehe READER). Der Treiber 
sollte also wissen, von woher das zuletzt empfangene Datenpaket kam. Erst 
wenn ein REPLY empfangen wurde, ist der SENDER von der Pflicht entbunden, 
seine Sendung zu wiederholen.

Return-Wert:  Wird zur Zeit noch nicht von MIDI_COM ausgewertet. 

-----------------------------------------------------------------------

		ret_wert	(*LESE)(int *len,char *buff);

*len		PaketlÑnge
*buff 	zeiger auf die Daten

ret_wert ist ein Bit-Pattern.
typedef struct
{
	int	frei:8;
	int	erg:2;
	int	doubl:1;
	int	reply:1;
	int	von:4;
}r_wert;

von:	Die ersten 4 Bits (LSB) enthalten eine zahl zwischen 0 und 6, die 
		angiebt, welcher Rechner der Urheber (Absender) der empfangenen 
		Nachricht ist.

reply:	Boolean-Wert, der anzeigt ob es sich um eine Antwort auf eine 
			gesendetes Datenpaket handelt (1) oder um ein Datenpaket von einem 
			anderen Rechner (0). Zur Zeit wertet MIDI_COM noch hauptsÑchlich 
			VON aus. Aber nicht immer.

doubl:	Boolean-Wert, der anzeigt, ob das empfangene Datenpaket schon 
			einmal empfangen wurde. Die kann vorkommen, wenn ein REPLY nicht 
			beim EmpfÑnger ankommt und dieser die letzte Anfrage wiederholt.

erg:		00:	Nachricht im Puffer vorhanden
			01:	Keine Nachricht vorhanden.
			11:	Der Treiber scheint keinen Anschluû mehr zu haben. Im Ring 
					ist dieser Timeout auf ca. 10 Sekunden eingestellt. Bei 
					dieser RÅckmeldung sperrt MIDI_COM alle Operationen des 
					Netzwerks, bis wieder ein anderes "erg" geliefert wird.


Die Funktion LESE wird durch MIDI_COM regelmÑûig aufgerufen.

-----------------------------------------------------------------------

		int	(*CMD)(int cmd,int *par1,int *par2);
Die Funktion CMD erlaubt es MIDI_COM, einige Abfragen vorzunehmen
Bisher sind die folgenden Kommandos definiert:

#define  anmeldung	0

 CMD(anmeldung,NULL,NULL);

erster definierter Aufruf. MIDI_COM ist nun startbereit.

+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

#define	id_request	1
 CMD(id_request,NULL,NULL);

liefert FAIL (-1) falls das Netz nicht betriebsbereit ist.
liefert eine NODE-ID zwischen 0 und 6, die fÅr Adressierungen benutzt 
werden kann.

+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

#define	new_appl		2
 CMD(new_appl,NULL,NULL);
liefert TRUE, falls seit der letzten Abfrage eine Neuinitialsierung 
stattgefunden hat, FALSE sonst.

Abfrage, ob sich zwischenzeitlich eine neue NODE-Nummer im Netz angemeldet 
hat. Dies ist immer dann der Fall, wenn ein Rechner im Netz neu gebootet 
wurde.

+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

#define	err_bell		3
	CMD(err_bell,&state,NULL);

state ist die Adresse einer INT-Variablen. Diese kann die folgenden Werte 
annehmen.
0	:Anzeige der NetztÑtigkeit aus
1	:kleines Protokoll (bei dem beiliegenden Treiber werden Empfangsfehler 
		der Hardware als Auslîser fÅr eine Anzeige verwendet.)
2	:volles Protokoll (bei dem beiliegenden Treiber wird jeder 
		LESE-Aufruf als Auslîser fÅr eine Anzeige verwendet.)

+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

#define	stop			4
	CMD(stop,&state,NULL);

Dieses Kommando soll, um die Rechner zu entlasten, den Netzbetrieb 
stoppen. Es wird erwartet, das LESE auf allen Rechnern FAIL liefert, wenn 
auf einem Rechner im Netz der Stop-Befehl gegeben wurde.

+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

#define	start			5
	CMD(start,&state,NULL);

Dieses Kommando hebt den Stop-Befehl wieder auf


+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

#define	storno		6
	CMD(storno,NULL,NULL);

MIDI_COM kehrt normalerweise erst dann zum Aufrufenden Programm zurÅck, wenn 
die gewÅnschte Funktion ausgefÅhrt wurde. Tritt allerdings in dieser Zeit 
ein Timeout auf, kann MIDI_COM mit diesem Kommando den eventuell noch 
aktiven Sendeauftrag wieder deakitvieren.

+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

