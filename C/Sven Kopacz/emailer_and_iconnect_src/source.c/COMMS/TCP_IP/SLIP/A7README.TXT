Hi Thomas,

hier die Ergebnisse des heutigen abends:

SOCKETS.PRG:

An allen noch gefundenen Stellen die type-conversions auf den Bytestrom
rausgenommen (wg. Addresserror auf 68000ern).
Allerdings war kein einziger davon in der Init-Phase und eben dort
tritt der Absturz auf. Ich bin mir aber sicher, da dieser erste
Absturz eh nicht der einzige ist. Ich berlege, ob ich mir nicht schnell
einen 68000-Atari irgendwo besorge, sonst k”nnte das eine ziemlich
langatmige Geschichte werden...

Ich hab es jetzt trotzdem mal mit den Debug-Infos (und allen Symbolen)
gelinkt. Wer wei, vielleicht ist es ja doch nur eine Kleinigkeit.
(Ja, der Absturz tritt mit Sicherheit im SOCKET.PRG auf, nicht im 
ICONNECT.PRG. Denn das macht zwischen den zwei Alerts, die Du mir
genannt hast, nichts anders als die Init-Routine des Kernels aufzurufen.
D.h. mit SLIP.PRG wrde der gleiche Absturz auftreten).

Vielleicht w„re es aber sowieso sinnvoller, gleich einen Exception-Handler 
zu schreiben, der den Zugriff auf ungerade Adressen auf dem 68000 einfach 
nachrstet, ist ja schlielich eh eine v”llig unn”tige Beschr„nkung. Obwohl..
das wird wahrscheinlich recht langsam. Ne, doch keine gute Idee.

Fehler im NAK/REJ-Configure-memory behoben, der zum Loop fhrte, wenn
ein Host fr verschiedene Optionen erst REJ dann NAK schickte. Damit
sollte der ISDN-Zugang bei T-Online jetzt funktionieren.

Wichtig: In HSMODEM die Buffergr”e mindestens auf die in 100ms max. zu
erwartenden Daten setzen!
Dazu einfach die Baudrate durch 80 teilen und grozgig aufrunden.
Bsp: Zugang mit 64kBit: 64k/80=820 Bytes/100ms. Also den Buffer einfach
auf 1K (1024) setzen.
Damit ist auch klar, warum es beim ISDN-Zugang zu FCS-Fehlern bei Paketen
> 256 Bytes kam. HSMODEM konnte die einfach nicht mehr Puffern, so da
da Bytes gefehlt haben (der Puffer steht bei Dir wohl auf 256 Bytes?).

Da das nur bei MagiC-PC auftrat, liegt dann eher daran, da Du Daten
von einem schnellen Host erhalten hast, w„hrend beim Test auf den anderen
Systemen halt nicht so viel reinkam, da gleich der Puffer berlief.

Beim Sendebuffer ist die Gr”e eigentlich egal, zumindest solange man z.B.
CAB benutzt, weil da sowenig abgeschickt wird, da es kaum auffallen
drfte, ob das in einem oder in zwei Rutsch ber die Schnittstelle geht.


ICONNECT

Die Icons im Connect-Fenster (das mit dem Balken) wanderten bei jedem 
neuen ™ffnen immer weiter nach oben.

Der Prozebalken wurde beim Retry nicht zurckgesetzt.

Der Retry hat sowieso nicht funktioniert, weil die Schnittstelle nicht
neu ge”ffnet wurde.

Fehler im USIS behoben, der dazu fhrte, da der Proxy fr <any other>-
Service nicht ausgewertet wurde.

Erster Versuch einer L”sung fr das Compuserve 7/8-Problem:
Da die eigentliche Internetanbindung sowieso nur mit 8-Bit laufen kann
(schlielich nutzen alle existierenden Protokolle die vollen 8 Bit)
ist es eigentlich unn”tig, eine zweite Konfig-Option zu machen. D.h.
es wird jetzt grunds„tzlich nach Abarbeitung des Login-Scripts auf 8 Bit
umgeschaltet. Oder anders ausgedrckt, die Einstellung in ICONF gilt nur
fr das Script.
Probleme kann es dann h”chstens noch mit den Parity und Stopbit-Parametern
geben. Ich kann mir aber nicht vorstellen, warum ein Provider die auch
noch umstellen sollte (naja, schwaches Argument...:-}


ICONF

Die Abstrze beim ™ffnen der Input-Fenster sollten (hoffentlich) nicht
mehr auftreten. Ich konnte den Fehler jetzt auf meinem echten Atari
problemlos reproduzieren und er tritt dort nun nicht mehr auf.
Trotzdem ist mir immer noch nicht klar, was eigentlich schief l„uft.
Die einzige nderung war, da die Objekte fr das Script jetzt erst
gesetzt werden, wenn das Login/Logout-Icon angeklickt wird. Vorher wurden
diese bereits beim Laden oder Initialisieren des Default-Setups gesetzt.
Ich vermute, ich habe irgendwo einen Wert bersehen, der tats„chlich erst
beim Anzeigen des Scripts gesetzt wird, und der bewirkt, da die Tedinfo-
Objekte in der RSC teilweise zerst”rt wurden, wenn ohne diesen Wert das
Script in die Objekte gesetzt wurde. Sicher bin ich mir da aber nicht, weil
ich keinen solchen Wert finden konnte.
Es kann genausogut sein, da dadurch nur ein Seiteneffekt gemindert wurde
und der Absturz jetzt nur noch jedes 100 Mal auftritt. Ich bin da also
nicht so ganz glcklich damit, konnte aber andererseits trotz zig-fachem
Editbox-Aufrufen den Fehler nicht mehr ausl”sen.

Die meisten Icons wurden in S/W im selektierten Zustand nicht gezeichnet,
weil die Maske gefehlt hat.

Der Icon-Rahmen und der Script-Rahmen waren in S/W selektiert.

Nicht ben”tigte Speicherbereiche in einem Setup (z.B. unbenutzte Script-
Schritte) werden jetzt mit 0 initialisiert, damit die Datei nicht so 
komisch aussieht. Funktioniert allerdings nicht mit bereits vorhandenen
Setup-Dateien sondern halt nur mit neu angelegten Setups/Dateien.



Ich melde mich dann heute nachmittag aus dem Bro.

Gru, Sven