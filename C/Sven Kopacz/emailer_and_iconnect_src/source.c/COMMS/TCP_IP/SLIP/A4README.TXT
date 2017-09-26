Readme zur A4


Aloha alle zusammen,

hier die énderungen:

Ein Fehler im HDLC-Framing konnte dazu fÅhren, daû zwei Bytes Åber
den reservierten Speicher hinausgeschrieben wurde (Verrechner beim 
Worst-case Fall).

Speziell fÅr T-Deadline hab ich im PPP-LCP fÅr die "Multiplexer 
Discriminator"-Option statt Code Reject ein Configure Reject eingebaut.
Mein Prog hat zwar keinen Plan von dieser Option und sollte nach RFC
deshalb besser den Code Reject verschicken, aber da die Jungs bei 
T-WirHabenUnsereEigenenStandardsLine eine schlicht falsche Implementierung
verwenden, ist es wohl besser es funktioniert so als garnicht.

Trotz allem rÅckt der Server aber nur eine IP raus, wenn er gerade
lustig ist. Wenn es nicht klappt, erhÑlt man die PPP-Fehlerbox, in der
die Optionen "Peer did not provide local IP-Address/DNS-Address" auf
YES stehen.

Einen Fehler in IPCP behoben: Wenn der Host kein IP_ADDRESS kannte,
wurde das alte IP_ADDRESSES benutzt. Wenn der Host nicht mal das kannte,
wurde das nicht geblickt, d.h. der Verbindungsaufbau wurde erst nach
dem Timeout abgebrochen (bei welchem Server sich dieses Problem ergab?
Richtig, T-...line ;-) Jetzt wird frÅher abgebrochen.

Erweiterungen:
Die Lib bietet jetzt eine Funktion parse_url, mit der eine URL zerlegt
werden kann.
Der Kernel-Server bietet USIS, User Setup Information Service, mit dem
man die ganzen neuen Einstellungen, die man im neuen Konfig-Programm
vornehmen kann, von einer Applikation aus abfragen kann.

Die neue Lib und die ergÑnzende Doku (zum ersten BLIP-Archiv) liegen
im PROG-Ordner.

Das neue CAB.OVL nutzt zumindest parse_url. Mit den Proxies, die per
USIS erfragt werden kînnen, dauert es aber noch bis zur nÑchsten Version.


So, dann was ganz was neues, nÑmlich das neue Konfig- und Einwahlprogramm.
Ich hab beide jetzt in der ersten Beta-Version fertig, ihr kînnt sie also
frîhlich testen.
Die Anleitung (die mal ein HYP wird) liegt ebenfalls bei (I-CON.TXT).
FÅr den Fall, daû die Programme bei euch noch Åberhaupt nicht wollen, 
liegt auch noch mal das olle SLIP.PRG bei.

ToDo: Beide Programme sind noch komplett englisch, deutsche Version folgt.

Viel Spaû damit,
 hoffentlich lÑuft alles:-)
 
Gruû, Sven