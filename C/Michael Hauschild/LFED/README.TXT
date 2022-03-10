Smart Systems im September 1992                Michael Hauschild
                                               Windhornstraûe 2
Telefon: 05137 / 9 20 09                                                                
                                               3016 Seelze 1
                                                                                                                
Das unwichtige vorweg: LFED der LineF-Emulator ist Freeware und
darf somit nach herzenslust kopiert und  weitergegeben werden 
(Voraussetzung ist allerdings, daû der gesamte Ordner FPU_EMU 
und alle Dateien weitergegeben werden!).

--------------------------------------------------------------------------

Was ist LFED ?
--------------
LFED ist die Kommunikations-Schnittstelle zwischen CPU und FPU. Das
Protokoll, welches die Motorola-Prozessoren ab MC68020 von Haus aus kennen
und damit die FloatingPointUnit (MatheCo-Prozessor / MC68881 oder MC68882)
ansteuern, mu· beim MC68000 oder MC68010 emuliert werden. Dieses Åbernimmt
LFED. Der Atari TT hat natÅrlich keine Probleme mit seiner FPU, denn in ihm 
"wohnt" ja ein MC68030, der sich liebevoll um den MC68882 kÅmmert - folg-
lich ist fÅr einen TT ein LFED eher ein Klotz am Bein als eine Hilfe.


Warum zwei Versionen von LFED ?
-------------------------------
Die Version 1.x ist fÅr Systeme mit TOS v1.0 bis einschlieûlich v1.04! In
diesen Tos-Versionen wurde der LineF-Trap "miûbraucht" und daher ist eine
PrÅfung notwendig, die zwischen "kam aus dem ROM oder aus dem RAM?" unter-
scheidet.

Die LFED-Version 2.x macht diese PrÅfung nicht mehr und ist daher auch et-
was schneller :-). Diese Version ist aber nur auf Systemen einsetzbar, die
ein TOS ab Version 1.06 haben!


FÅr wen ist LFED ?
------------------
Geeignetes Einsatzgebiet fÅr LFED ist jeder Atari ST, Mega ST, STE und 
Mega STE mit Standard-Prozessoren (MC68000/10) UND FPU (MC68881) !
Besonders interessant dÅrfte LFED fÅr Entwickler/Programmierer sein, die
mit Entwicklungssystemen arbeiten, welche die FPU direkt unterstÅtzen 
(Beispielhaft sei hier PureC und Pure Pascal genannt) und natÅrlich fÅr 
Anwender, die solche Programme/Applikationen auf ihren Rechnern instal-
lieren wollen. Zum Beispiel CAD-, EBV-Applikationen, Tabellenkalkulationen 
und nicht zuletzt wissenschaftliche Programme kînnen durch die effektive 
Nutzung (ohne programmiertechnischen Mehraufwand) der FPU auch auf den 
"kleineren" Ataris recht zÅgig bearbeitet werden.


Wie verhÑlt sich LFED im System ?
---------------------------------
Kurz und gut - vîllig neutral, d.h. UnvertrÑglichkeiten sind nicht bekannt.
LFED ist XBRA-Konform programmiert und erkennt sein "schon Vorhandensein"
an seiner Kennung 'LFED'. Er ist nicht resetfest und muû bei Warm- oder
Kaltstart wieder neu geladen werden.


Wie installiert man LFED ?
--------------------------
Da LFED nicht resetfest und vom Prinzip eine Systemkomponente ist, fÅhlt
er sich im AUTO-Ordner auf den "vorderen PlÑtzen" am wohlsten. Er instal-
liert einen eigenen LineF-Handler (eben das FPU-Protokoll). Wer mîchte,
kann ihn aber auch vom Desktop aus starten.


Was ist mit uns Entwicklern ?
-----------------------------
FÅr die sind vor allem die Sourcen von Interesse - und diese sind hier im
Ordner. Wie man "FPU-Projekte" behandelt sieht man in FPUDEF.PRJ


Die Zukunft von LFED !
----------------------
Nun, es fehlen noch ein paar FPU-Befehle (z.B. FSAVE/FRESTORE; und bei
beiden bin ich mir nicht sicher, ob sie nicht in einer Multitasking-
Umgebung notwendig werden) und der FTRAP-Befehl erscheint mir sehr inte-
ressant in seinen Mîglichkeiten - man wird sehen ...


Mehr Informationen ? - immer, z.B. in ...
--------------------
c't 4/90 "Schneller rechnen" von Roger Butenuth ab Seite 430

ATARI Profibuch ST-STE-TT von Jankowski/Rabich/Reschke erschienen im 
Sybex Verlag

PureC Compiler-Handbuch und Online-Hilfe (obwohl dort die Nutzbarkeit
der FPU in o.g. Rechnertypen (noch) verneint wird) - Åbrigens, der 
Pure-Assembler erlaubt auch den Befehlssatz der FPU (neben vielen anderen
Mîglichkeiten!) zu nutzen.

... und natÅrlich die einschlÑgige Literatur von Motorola.

Ich wÅnsche Allen viel Spaû dabei, der FPU in ihren Rechnern 'mal richtig
"Dampf" zu machen ;-)