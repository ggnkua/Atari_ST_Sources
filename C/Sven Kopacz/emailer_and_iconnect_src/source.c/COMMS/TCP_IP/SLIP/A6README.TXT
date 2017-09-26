Mann Mann Mann,

T-Online kostet mich ganz sch”n Nerven.

Ok, aber diesmal war alles mein Fehler.

Erstmal folgendes zu Deinem T-Online-Setup und den Logfiles:

Die waren tats„chlich verdammt kurz. Irgendwie hab ich Dir da am 
Telefon nicht richtig zugeh”rt, sonst h„tte ich gleich stutzig werden
mssen. Ich ging ohne n„her ber die Dateigr”e nachzudenken davon aus,
da die halt jetzt nur noch etwa so gro sind, wie die mit denen es 
bei SLIP.PRG geklappt hat.

Ist natrlich K„se, da kommen ja nur ein paar Bytes vom Modem und dann
ist Sense. Und wenn man sich diese empfangenen Bytes mal anschaut
(stehen ja als Hex-Code drin), dann heien die im Klartext...NO CARRIER.
Witzig, was? Woran's wohl liegt? Du hattest ja gesagt, da euer Zugang
in Heidelberg recht schnell auflegt, wenn nix reinkommt. Tja, und mein
ach so toller Tip mit der Pause im Anwahlscript hat eben genau das
verursacht. Ich nehme also alles zurck und behaupte das Gegenteil;-)

Und dann hab ich noch eine halbe Ewigkeit gegrbelt, warum es mit SLIP
bei Dir immer klappt und mit ICONNECT nie. Tja, das h„tte ich mir auch
sparen k”nnen, denn so unwahrscheinlich es auch klingen mag, aber das
war reiner Zufall!

Nach einigen Anrufen bei T-Online-Heidelberg habe ich jetzt folgendes
rausgefunden:

T-Online schickt neben dem IPCP-Request (um das IP-Protokoll zu 
konfigurieren) ab und zu, so bei Lust und Laune, noch einen Request
fr ein Compression-Protokoll (das berhaupt nicht benutzt wird).
Der Kernel antwortet (weil er das Protokoll nicht kennt) mit einem
Protokoll Reject (deswegen auch immer die Fehlermeldung bei Dir, da
ein Local Protocol Reject stattfand, der die Verbindung vereitelt hat).

Das dumme dabei: Ich hatte einen Fehler im Kernel, der die Paketl„nge
der Reject-Info um zwei Bytes zu gro gesetzt hat (long mit int vertauscht).
Der Server bei T-Online hat das Paket natrlich weggeworfen und partout
keine Verbindung aufgebaut, weil sein Request damit ja nie beantwortet
wurde. Ok, den Fehler hab ich behoben. Dummerweise hatte ich noch einen
drin, nach dem ich ganz sch”n lange suchen durfte (die Paket-ID hat sich
selbst berschrieben, weil T-Online den IPCP- und den Compress-Request
gleichzeitig abschickte, so da der Kernel den Acknowledge auf seinen
eigenen Request nicht mehr akzeptiert hat. Wenn Dir das nix sagt, macht
das auch nix, ich wollte es nur loswerden;-).

Jedenfalls das Ende vom Lied: Gerade eben war ich ber den Heidelberg-
Zugang m„chtig online (natrlich mit ICONNECT:-) und hab mir mit CAB
ein bischen Bl”dsinn angeguckt, hat alles funktioniert.

Jetzt hoffe ich natrlich, da es bei Dir auch funktioniert, aber vorher
mut Du mit ICONF noch Dein T-Online-Setup „ndern:

Stell die Datenbits im Modemsetup wieder auf 8! (Die stehen bei Dir auf 7)
Verkrze die Pause vor dem Done von 3 auf 1 Sekunde.
Es kann gut sein, da es auch ganz ohne Pause funktioniert, hab ich noch
nicht ausprobiert und will ich jetzt auch nicht mehr. Ich will ins Bett.
Du kannst es ja mal testen.

Nach dem Fehler in ICONF schaue ich dann morgen. Wenn der T-Online-Zugang
auch ohne Pause funktioniert, scheint das ja das einzige zu sein, was 
noch schiefl„uft, oder hab ich was vergessen?
Achja, die 7/8-Umschaltung fr Compuserve. Ich mach mich da noch mal
schlau, vielleicht gibt es ja auch eine M”glichkeit, das automatisch
zu erkennen (obwohl ich kein Atari-Modem-Programm kenne, bei dem man
diese Parameter NICHT einstellen mu? Keine Ahnung, wie die das beim
Mac gedreht haben. Da kenne ich n„mlich kein Programm, bei dem man das
berhaupt einstellen KANN).
 
Naja, eins nach dem anderen, also, erstmal Dein Test mit dem neuen
SOCKETS.PRG und dann sehen wir weiter.

Bis morgen,
Sven
