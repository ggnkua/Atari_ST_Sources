ADDRBOOK.APP

ADDRBOOK.APP ist Freeware.
Die Benutzung erfolgt auf eigene Gefahr. Fr eventuell m”gliche Datenverluste 
wird keine Gew„hr bernommen.

Installation:
Die Installation ist denkbar einfach, s„mtliche Dateien dieses Archivs mssen
nur im selben Verzeichnis wie der EMailer abgelegt werden. Das w„r schon alles.

Entstehungsgeschichte:
Nun, eigentlich wollte ich mich nur ein bischen mit verketteten Listen in C und 
den WDIALOG-Listboxen besch„ftigen. Mich hat, wie etliche andere User vom 
Emailer wohl auch, die doch arg spartanische Adressverwaltung vom EMailer 
gest”rt. Die Adressen wurden nicht sortiert, die Verteilererstellung ist auch 
alles andere als einfach gewesen etc. (um mal ein paar Beispiele zu nennen).

Und so bot es sich an, beides miteinander zu Verbinden, sprich, ich habe viel 
ber WDIALOG und Pointeradressierung in C gelernt (und natrlich auch das 
fluchen, da Nullpointerzugriffe auf original-Ataris mit Abstrzen bestraft 
werden ;-) ) und gleichzeitig fr Komfort bei der Adressverwaltung gesorgt.

bei Bugmeldungen, nderungswnschen etc. bitte eine Mail an mich senden.
Meine Adresse: Christian.Putzig@t-online.de


Wichtige Hinweise:
Um den vollen Funktionsumfang benutzen zu k”nnen wird MagiC zwingend ben”tigt. 
(siehe auch "vorhandene Bugs")
Wenn man Adressen bearbeitet („ndern, l”schen und hinzufgen) ist es ratsam nur 
eines der Programme aktiv zu haben. Emailer sowie Addrbook laden nur beim 
Programmstart die ADDRBOOK.TXT und wrden nderungen an dieser durch das jeweils 
andere Programm nicht mitbekommen.

Man kann aber ruhig mit Addrbook.APP Adressen ver„ndern etc. diese dann in die 
Empf„ngerliste setzen, mit Klick auf "Email schreiben" wird der Emailer 
automatisch gestartet und eine leere Mail mit den Empf„ngern editierfertig 
erzeugt.


Vorhandene Bugs:
Addrbook.APP ben”tig MagiC, macht seine Laufbarkeit aber nicht von dessen 
Vorhandensein abh„ngig.
MagiC wird fr die scrollenden Eingabefelder zwingend ben”tigt. 
Adressbearbeitungen ber die Formulare sollten unter anderen Betriebssystemen 
vorerst unterlassen werden da die Felder grade mal 32 Zeichen gro sind. (Namen 
drfen aber 64 Zeichen, die Klartextadresse 256 Zeichen gro sein).
Intern wird mit diesen gr”en gearbeitet, das hin- und herschieben der Adressen 
in Verteiler, aus Verteilern, in die Empfangsliste etc. ist problemlos m”glich.

Da Emailer m.W. bei anderen Betriebssystemen (TOS/MultiTOS/N.AES) nicht korrekt 
l„uft, wird Addrbook knftig wohl auch eine Sperre hinsichtlich dessen eingebaut 
bekommen.

Bei den Verteilern mu noch eine Prfung auf mind. zwei Adressen eingebaut 
werden, da sie mit einer Adresse beim n„chsten Programmstart sonst nur als 
normale Emailadresse erkannt werden.

Beim nachstarten des Emailers mittels va_start mittels "mailto:"-string gibts 
noch ein Timingproblem (zumind. auf meinem TT) so da die Zeichenkette beim 
ersten Leerzeichen abgeschnitten wird.

Beim Adressl”schen k”nnen im Hauptfenster u.U. die Icons fr die Verteiler 
"stehen" bleiben.

Anschauen mu ich mir auch noch das Verhalten, wenn mit einer nackten 
Emailer-Installation gearbeitet wird und noch kein Adressbuch (ADDRBOOK.TXT) 
vorhanden ist.


