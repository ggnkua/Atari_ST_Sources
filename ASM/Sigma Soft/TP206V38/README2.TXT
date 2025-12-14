
Kurze ErklÑrungen zu "TOSPATCH.TTP" fÅr TOS 2.06            Version 2.4

Ω1990    ‰-soft, Markus Fritze
Ω1992-93 Markus Heiden

TosPatch  ermîglicht  das  einfache  éndern  (Patchen) des Tos. FÅr das
Einbinden  von  Patches  im  Tos  braucht man weder einen Debugger noch
Programme  wie  SPLITROM, o.Ñ. Lediglich ein Texteditor wie z.B. Tempus
ist nîtig, um die Parameterdatei zu editieren.


Haftungsausschluû:

Trotz  sorgfÑltiger  Arbeit  kann  fÅr alle SchÑden, die durch TosPatch
oder  eines  der diesem Paket enthaltenen Programme entstehen, - gleich
welcher  Art  und  Hîhe -  seitens der Autoren keine Haftung Åbernommen
werden.


Beispiele fÅr die Anwendung von TosPatch:

-Man  will  ein  TOS  aus  dem  Rechner  auslesen  und  in  eine  Datei
 schreiben. Dazu ruft man TOSPATCH.TTP mit dem Filenamen "READROM2.FIL"
 auf.  Wenn  das  Programm  fertig ist, sollte sich die Datei "TOS.IMG"
 auf dem DatentrÑger befinden.
 ACHTUNG:  Das  Programm  unterstÅtzt zur Zeit alle TOS-Versionen, d.h.
           die im READROM.FIL angegebenen TOS-Daten mÅssen stimmen.

-Man  will ein "TOS.IMG" in 8 EPROMs brennen. Also TOSPATCH.TTP mit dem
 Filenamen  "SPLIT2_8.FIL" aufrufen und wenig spÑter hat man 8 einzelne
 TOS-Dateien  auf  dem  DatentrÑger.  Will man nur 4 EPROMs haben, gibt
 man als Filenamen "SPLIT2_4.FIL" an oder "SPLIT2_2.FIL" fÅr 2 EPROMs.

-Man  will  einige Bytes im nicht gepatchen "TOS.IMG" Ñndern. Dazu lade
 man  die  Datei  "PATCH.FIL"  in einen Text-Editor seiner Wahl, um das
 Format  zu  ergrÅnden. Ich hoffe, die umfangreichen Beispiele sprechen
 fÅr  sich.  Wie  man  sieht,  kann  man  wahlweise einige Bytes direkt
 Ñndern,  oder  aber  sogar  ganze  Dateien  includen.  Die  Hexzahl am
 Zeilenanfang   entspricht   dabei   dem  Offset  zum  Dateianfang  von
 "TOS.IMG".  Das  "$"  kennzeichnet  den Beginn einiger Hexbytes, sonst
 wird  ein  Filename  angenommen. Zudem gibt es noch einige zusÑtzliche
 Mîglichkeiten, welche alle selbsterklÑrend sein sollten.

-Das Relozieren funktioniert nur mit TOS 2.06 vom 14.11.1991, sonst muû
 die Patch-Liste  angepasst werden. Dazu werden  alle  Langworte, deren
 Wert  im Bereich $E00000-$E3FFFF liegt, reloziert. Die Patchliste gibt
 die  Ausnahmen  der  Regel an, d.h. die Langworte, die nicht reloziert
 werden   dÅrfen.   Die  Langworte  sind  dabei  relative  Offsets  zum
 TOS-Anfang.  Um z.B. ein "TOS.IMG", d.h. das Original-TOS 2.06 fÅr die
 Adresse  $3C0000  (Mega 4) zu relozieren, ist einfach TOSPATCH.TTP mit
 dem  Filenamen "RELOC206.FIL" aufzurufen. Um  die  Adresse  zu  Ñndern
 muû  man   die  Datei  mit  einem  Text-Editor  (wie gehabt)   Ñndern.
 Das so im Ram liegende TOS kann man natÅrlich prima mit einem Debugger
 (z.B.   dem  Bugaboo  aus  dem  TurboAss-Paket)  bearbeiten  (bis  zum
 Absturz...)  und  neue  Patches ausprobieren. Wenn alles funktioniert,
 sollte  man  die Patches allerdings in ASCII-Form bringen, damit alles
 schîn Åbersichtlich bleibt (wo habe ich denn was geÑndert?).

ACHTUNG: Die   Patchfiles,   welche  ein  ausgelesenes  TOS  benîtigen,
         erwarten dieses als STE_TOS.IMG in dem Verzeichnis, in welchem
         auch TOSPATCH.TTP steht. Die Ausnahme bilden die SPLITRO?.FIL.
         Sie  erwarten  ein TOS.IMG jedoch ebenfalls im Verzeichnis, in
         welchem TOSPATCH.TTP steht.


Welche Vorteile bringt denn nun TosPatch?

1. Man  ist nicht mehr gezwungen das TOS.IMG als ganzes weiter zu geben
   (was ja auch zu rechtlichen Problemen fÅhren kann).
2. Zudem  kann  man  seine  Patches  prima Åber Mailboxen anderen Usern
   zugÑnglich machen (wie gesagt, ohne TOS.IMG).
3. Jeder  kann  leicht  erkennen,  was  geÑndert  wird. Dies verringert
   Probleme  bei  UnvertrÑglichkeiten  von  Patches. Man kann ja leicht
   einen Teil entfernen (z.B. das Setzen das Fast-Load-Bits)
4. Man  kann  sich  schnell  fertige  Dateien fÅr den Eprommer erzeugen
   lassen.
5. Man kann ein TOS im Ram testen.


Bei Problemen kann man anfragen:

Einfach  eine  îffentliche  Mail  in  die  D-Box oder in die Turbo-Tron
setzen.

D-Box      : (040) 720 98 43  rep.  (040) 720 98 43
Turbo-Tron : (040) 890 11 62  rep.  (040) 890 11 62

Besonders gelungene Patches sind natÅrlich auch gesucht...


TurboAss erhÑlt man bei:

   ‰-soft
   z.Hd. Markus Fritze
   Birkhahnkamp 38
   2000 Norderstedt 1
   Tel.:040/5223955 (NIE VOR 12 UHR!!!)

TosPatch  ist  Bestandteil des TurboAss-Assemblerpaketes. Das Paket ist
in  diversen  Mailboxen  downloadbar  (z.B.  die Version  V1.7.7 in der
Sigma-Soft  (040) 526 71 85  rep.  (040) 526 71 85),  als  PD-Disk  der
ST-Computer  zu  beziehen oder aber bei obiger Adresse zu erhalten. FÅr
50,-   DM  kann  man  dieses  Sharewareprogramm  dann  erwerben.  Darin
enthalten  ist  eine  ausgedruckte  Anleitung  mit  mehr als 250 Seiten
Umfang, sowie ein Updateservice.
