
****************************************************************
*                                                              *
*                   SoundInit Version 1.0                      *
*                                                              *
*                   PD 1993 by Richard Kurz                    *
*                   Vogelherdbogen 62                          *
*                   88069 Tettnang                             *
*                                                              *
*                   Via E-Mai:                                 *
*                   Fido, 2:246/8520.5                         *
*                   Nest, 90:400/403.5                         *
*                   AtariNet, 51:601/115.5                     *
*                   CompuServe, 100025,2263                    *
*                   Maus, UN                                   *
*                                                              *
****************************************************************


Dieses Programm ist PD! Die Weitergabe ist absolut erlaubt bzw.
erwnscht.


Was tut's

SoundInit initialisiert das Soundsystem auf STE/TT und FALCON 
aus dem Autoordner heraus, also vor XCONTROL. Damit kann z.B.
auf dem TT und FALCON der interne Lautsprecher rechtzeitig ab-
geschaltet werden. Die Parameter sind ber den Dateinamen 
einstellbar. Auf dem FALCON wird gleichzeitig fr STE-
Kompatibilit„t gesorgt. Bei STE und TT wird auch noch das 
Microwire-Interface freigeblasen, damit nach den Einschalten
auch die ersten Samples ordentlich klingen.

Der Dateiname muž so aussehen: SINI_xxy.PRG

xx steht fr die Lautst„rke. Es sind Werte zwischen 0 und 40 
erlaubt.

y steht fr den internen Lautsprecher, dieser Parameter hat nur
auf TT und FALCON eine Wirkung, muž allerdings auch auf den 
anderen Rechnern angegeben werden. Erlaubte Werte sind 'Y' und
'N'.


Beispiele:

SINI_30N.PRG -> stellt die Lautst„rke auf 30 und schaltet den
                internen Lautsprecher aus.

SINI_40Y.PRG -> gibt volle Lautst„rke und schaltet den internen
                Lautsprecher an.



