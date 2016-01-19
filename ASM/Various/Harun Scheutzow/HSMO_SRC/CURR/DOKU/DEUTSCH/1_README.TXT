Modulare (serielle) Ger„tetreiber
*********************************

Aktuelle Anmerkung
------------------
HSMODA07.LZH ist sowas wie eine Zwischenversion. Es sind nicht alle Dinge 
drin, die ich gerne h„tte, aber es stellt allen Nutzern den aktuellen 
Stand der Entwicklung zur Verfgung. Es gibt einige Fehlerkorrekturen.


Inhalt
------
Dieses Paket enth„lt serielle Treiber. Fr jede Schnittstelle oder jeden
Schnittstellenbaustein exisitiert ein eigener Treiber. So hat der Nutzer
die Arbeit mit der Auswahl der passenden Treiber, aber auch den Vorteil,
nur die Treiber laden zu mssen, die er braucht. Da ich einen sauberen
modularen Aufbau verwenden wollte, mu vor den eigentlichen Treibern ein
Programm (DRVIN.PRG) geladen werden, das das Betriebssystem (TOS, MagiC,
MiNT) um die jeweils fehlenden Funktionen zur Treiberinstallation erg„nzt.

Die Texte im HSMODA-Paket beantworten nicht alle Fragen, aber enthalten 
eine Menge Informationen. Einige Informationen sind zur Nutzung der 
Programme notwendig, andere sind ntzlich, weitere einfach nur 
interessant. Ich habe die Texte nicht verfat, damit sie ignoriert werden 
und hier beantwortete Fragen immer wieder gestellt werden. Neuigkeiten und 
nderungen bei Updates sind in Kurzform hinten im Abschnitt "Versionen" 
der einzelnen Texte aufgelistet.


Reihenfolge
-----------
DRVIN.PRG mu vor den Treibern geladen werden. Am Besten ist DRVIN 
zusammen mit den Treibern im \AUTO\-Ordner untergebracht. Dort sollte es 
aus Geschwindigkeitsgrnden m”glichst weit hinten, aber noch vor den 
Treibern, stehen. DRVIN und die Treiber mssen andererseits vor eventuell 
im \AUTO\ installierten Programmen stehen, die die Treiber nutzen wollen. 
DRVIN.PRG wird in DRVIN.TXT n„her beschrieben. Die einzelnen Treiber sind 
entsprechend der Schnittstellenbausteine oder -namen benannt und in den 
*.TXT-Files mit „hnlichem Namen beschrieben.

Mit einem TOS ab Version 2.0 oder einer entsprechenden Shell kann die
Reihenfolge im \AUTO\ einfach ermittelt werden, indem man die Ausgabe der
Verzeichnisse "unsortiert" erfolgen l„t. Bei „lteren TOS-Versionen
kopiert man zuerst alle Programme aus \AUTO\ in ein anderes Verzeichnis,
so da \AUTO\ leer ist, und kopiert die Programme dann in der gewnschten
Reihenfolge wieder nach \AUTO\ zurck.

DRVIN sollte nach folgenden Programmen gestartet werden, falls man diese
verwendet, da andernfalls Probleme auftreten k”nnen:
- Overscan-Treiber (falls TOS1.4-Fix dort eingeschaltet)
- FPATCH2.PRG auf Falcon (FPATCH1.PRG sollte man ohnehin nicht nutzen)


Konfiguration
-------------
Die Auswahl der Treiber durch den Nutzer erlaubt schon eine gewisse
Anpassung an das eigene System. Eine individuellere Einstellung der
einzelnen Treiber ist wegen der Vielfalt der Hardware(umbauten), aber auch
wegen unsch”ner/unsauberer Software, oft erforderlich. Diese Einstellungen
werden direkt in den Treibern gespeichert. Zus„tzlich enth„lt der Treiber
zu jedem Einstellungspunkt eine kurze Erkl„rung. Wenn man ausfhrlichere
Informationen braucht, sind diese oft im *.TXT zum Treiber enthalten.

Die Konfiguration erfolgt durch das beiliegende Programm SETTER.TTP, das
in SETTER.TXT n„her beschrieben ist. Ab TOS1.04 ist die Bedienung von
SETTER einfach: Man nimmt das zu konfigurierende Programm mit der Maus und
zieht es auf SETTER.TTP. SETTER wird gestartet, l„dt das Programm und wird
entweder melden, da es nicht konfigurierbar ist, oder den
Konfigurationsdialog beginnen. Bei alten TOS-Versionen wird SETTER durch
Doppelklick gestartet und in der erscheinenden Dialogbox der Name und Pfad
des zu konfigurierenden Programms angegeben.


HSMODEM1 (-Kompatibilit„t)
--------------------------
Diese Treiber ersetzen HSMODEM1. Die BIOS-Funktionsaufrufe fr MODEM1 sind
wegen der Untersttzung mehrerer Schnittstellen ein ganz klein wenig
langsamer als bei HSMODEM1.

Wenn MFP.PRG als einziger oder als letzter Treiber geladen wird, sollten
alle Programme, die mit den HSMODEM1-Versionen gelaufen sind, auch mit
DRVIN.PRG und MFP.PRG funktionieren.


Kurzanleitung
-------------
Dieser Abschnitt soll die Installation unter TOS und MagiC m”glichst kurz
und einigermaen verst„ndlich beschreiben. Er sollte als Programm
betrachtet und von vorn nach hinten abgearbeitet werden.

Sie haben in einem Programm, das Sie benutzen wollen, den Hinweis
gefunden, da diese Treiber ben”tigt werden oder Vorteile bringen. Sie
haben irgendeinen anderen Grund fr die Installation dieser Treiber. Wenn
Sie keinen Grund zur Installation haben, dann sollten Sie die Texte
aktionslos lesen.

Falls Sie ein Programm im \AUTO\-Ordner haben, das die seriellen
Schnittstellen benutzt, kopieren sie es aus dem \AUTO\ heraus.

Entfernen Sie installierte Patchprogramme fr die seriellen
Schnittstellen, wie z.B. RS232ENC, TURBOCTS, SERIALFX, aus dem \AUTO\.

W„hlen Sie die Treiber aus diesem Paket, die Sie brauchen. Benutzen sie 
die folgende Grundausstattung, wenn Sie nicht wirklich sicher sind, 
welche Treiber sie brauchen.

Computertyp          Treiber fr Grundausstattung
ST, STE, MegaST      MFP.PRG
STacy, STBook        MFP.PRG
MegaSTE              MFP.PRG, SCC.PRG
TT                   MFP.PRG, SCC.PRG, MFP_TT.PRG
Falcon               SCC.PRG
Hades                MFP.PRG, ESCC.PRG

Zus„tzliche oder erweiterte Ausstattungen:

Wenn Sie Ihren MegaSTE, TT oder Falcon mit einem Am85C230A oder Z85230
anstelle des originalen 85C30 ausgestattet haben, k”nnen Sie anstelle des
SCC.PRG das ESCC.PRG verwenden. Im Lieferzustand enthalten diese Computer
nur einen SCC, also dann nur das SCC.PRG verwenden! Der Hades enth„lt laut 
Doku einen Z85230.

Wenn Sie bei Ihrem Falcon die im Originalzustand nicht vorhandene 
MFP-Schnittstelle (MODEM1) herausgefhrt haben, k”nnen Sie dafr 
zus„tzlich das MFP_FALC.PRG ausw„hlen. Es kann fr bestimmte Software, 
z.B. TeleOffice 3er Versionen, sehr ntzlich sein, das MFP_FALC.PRG vor 
dem SCC.PRG zu starten, auch wenn man MODEM1 nicht herausgefhrt hat.

Wer ST_ESCC in seinem ST, STE oder MegaST installiert hat, benutzt dafr
zus„tzlich das ST_ESCC.PRG.

Wer sonstige Schnittstellenumbauten hat, m”ge die Texte lesen und sich
dann eventuell an mich wenden.

Die ausgew„hlten Treiber werden mit SETTER.TTP konfiguriert, siehe oben
unter "Konfiguration". Dazu mssen Sie die gestellten Fragen beantworten
und Entscheidungen treffen. Oft ist die Standardeinstellung verwendbar.
Falls Sie zus„tzliche Informationen brauchen, finden Sie diese in den
*.TXT-Files, die so „hnlich wie die Treiber heien, z.B. in MFP.TXT fr
das MFP_FALC.PRG.

Sie kopieren DRVIN.PRG in den \AUTO\-Ordner. Sie kopieren die ausgew„hlten
und konfigurierten Treiber hinterher. Die Reihenfolge der Treiber ist
unwesentlich, falls alle Programme modern und fehlerfrei sind. Ansonsten 
leider nicht.

Damit ist die Installation abgeschlossen. Booten Sie den Computer neu und 
probieren sie die Treiber aus. Wenn es funktioniert, kopieren Sie das die 
seriellen Schnittstellen nutzende Programm, das Sie am Anfang entfernt 
haben, wieder in \AUTO\ und testen nochmal.


Copyright
---------
Dieses Treiberpaket darf unter folgenden Voraussetzungen frei kopiert
werden:
- Die Anleitung(en) und Treiber werden unver„ndert kopiert.
- Die Kopien sind kostenlos, oder auf dem blichen Preisniveau einer
PD-Disk.
- Das Beilegen zu PD- und Sharewareprodukten ist generell gestattet.
- Das Beilegen zu kommerziellen Produkten ist gestattet. Der Vertreiber
oder Programmierer mu mich aber darber informieren (Email gengt).
- Ich bitte darum, nur in Ausnahmef„llen einzelne Dateien zu kopieren, da
der Erstnutzer mit unvollst„ndigen Paketen wenig anfangen kann.

šbersetzungen der Texte in andere Sprachen sind ausdrcklich erwnscht.
Das deutsche Original mu aber weiterhin beiliegen.

Wer Dateien hinzufgen will, mu diese eindeutig als seine Zugabe
kennzeichnen.

Ich bin an einer Fehlerfreiheit dieser Software interessiert. Deshalb habe
ich sie im Rahmen meiner M”glichkeiten grndlich getestet. Sollten Fehler
auftreten, bitte m”glichst genaue Beschreibung an meine Email- oder
Postadresse schicken. Ich kann nur Fehler beseitigen, die ich anhand der
Beschreibung entweder reproduzieren kann oder bereits finde.

Ich hafte nicht fr irgendwelche Auswirkungen oder Nichtwirkungen, gleich
welcher Art, die der Einsatz oder Nichteinsatz von Teilen dieses Paketes
oder des kompletten Paketes hat.

Produktnamen und Warenzeichen werden ohne Gew„hrleistung einer freien
Verwendbarkeit benutzt.

Diese Treiber und Dokumentationen sind alle in meiner Freizeit entstanden. 
Untersttzt werden meine Aktivit„ten von den Programmierern, die diese 
Treiber verwenden, und von den Usern, die mir (m”glichst gute) 
Fehlermeldungen schicken. Bei ihnen m”chte ich mich an dieser Stelle 
bedanken und gleich einen Aufruf anschlieen: Wenn jemand Fehler in diesen 
Texten findet, ein gutes Beispielprogramm geschrieben hat, das er gern 
weitergeben m”chte, die Beschreibung irgendwo ausfhrlicher und 
verst„ndlicher gemacht oder gar in bersetzt hat, m”ge er sich bei mir 
melden. Ich bin sehr daran interessiert, fachlich korrekte Erg„nzungen und 
Beispielprogramme in dieses Paket aufzunehmen. (Ich bin ein Freund 
ausfhrlicher eindeutiger Dokumentationen, andere m”gen Beispiele.)

Meine Adressen:
Mausnetz: Harun Scheutzow @H (Mailgr”e MAXIMAL 16 KByte!)
Internet: Harun_Scheutzow@H.maus.de
          harun@priv-hs.village.de
Postanschrift:
Harun Scheutzow
Dresdener Strae 83
D-10179 Berlin, Deutschland


Fr Programmierer
-----------------
Das Verzeichnis PROG_MAN enth„lt eine Reihe von Texten, die vor allem fr 
Programmierer interessant sind. Diese Texte sind teilweise in Deutsch und 
Englisch, teilweise aber auch nur in einer Sprache. RSVF_COO.TXT ist die 
Beschreibung des RSVF-Cookies, der die Feststellung der installierten 
Treiber erlaubt. Der Standardisierungsvorschlag fr ein 
hardwareunabh„ngiges Softwareinterface fr serielle (und „hnliche) 
Schnittstellen ist SERSOFST.TXT. Diese Treiber richten sich alle nach 
SERSOFST.TXT. Programmierinformationen im Zusammenhang mit seriellen 
Schnittstellen finden sich, in englischer Sprache, in der Datei 
PROG_MAN.TXT. Es geht dabei nicht nur um diese Treiber, sondern auch um 
hFehler in Ataris Entwicklerdokumentationen.


Versionen
---------
Ich vergebe keine Versionsnummern, sondern verwende fr die Unterscheidung 
das in der Installationsmeldung der einzelnen Programme ausgegebene Datum. 
Dieses Datum ist in der Form Jahr-Monat-Tag notiert, mit vierstelliger 
Jahreszahl. Aushilfsweise kann man das Filedatum betrachten, das sich 
jedoch beim Kopieren unter alten TOS-Versionen „ndern kann.

Achtung! Am 1994-12-30 habe ich eine wesentliche nderung vorgenommen. Es 
funktionieren nur DRVIN und Treiber zusammen, die entweder alle vor dem 
1994-12-30 oder ab diesem Datum erstellt wurden.

Neue Versionen sind zuerst in diversen Mausboxen, z.B. Maus Berlin3 (B3) 
oder Maus Hannover (H), zu finden. Wenn ich die M”glichkeit habe, lege ich 
eine aktuelle Version auch auf ftp-Server im Internet. Man sollte nach dem 
Filenamen "HSMOD*.*" oder "hsmod*.*" suchen lassen. Das Archiv wird 
HSMODAxx.LZH heien, wobei xx fr die fortlaufende Ver”ffentlichungsnummer 
und das A fr alle Schnittstellen steht.


Harun Scheutzow
