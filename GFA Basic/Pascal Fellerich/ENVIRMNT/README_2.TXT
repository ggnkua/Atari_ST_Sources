

     ENVIRO.ACC/PRG   &   AUTOENVR.PRG    (version 2)
    =================================================

       Freeware by Pascal Fellerich




ZWECK:
  Das Setzen und Benutzen der Environment-Strings.

  Der Sinn von Environment-Strings, auch Environment-Variablen 
genannt, liegt darin, anderen Programmen irgendwelche Informationen 
zugÑnglich zu machen. Das Desktop oder auch 'COMMAND.PRG' (das 
Original von Atari!) benutzen diese Informationen um beispielsweise 
ein zu startendes Programm zu finden. Auch das AES benutzt diese 
Variablen, um RSC-Files zu finden. Das Problem ist bekannt: Man 
klickt mit gedrÅcktem rechten Mausknopf ein Programm in einem 
inaktiven Fenster an; es wird gestartet und... findet natÅrlich seine 
RSC nicht. Das kommt daher, daû bei der Suche nach der Resource 
zuerst der aktive Pfad durchsucht wird, anschlieûend alle Pfade, die 
hinter der Environment-Variablen 'PATH=' angegeben sind - aber dort 
ist als Standardeinstellung nur A:\ oder C:\ angegeben.

  Durch Setzen dieser Variable auf die meistbenutzen Pfade erreicht 
man nun, daû die RSC's gefunden werden. Von command.prg aus geht's 
sogar MSDOS-like: alle 'externen Befehle', sprich Programme, in einen 
Ordner schmeiûen und die Environment-Variable entsprechend setzen. 
Erfolg: unabhÑngig vom eingestellten Pfad findet COMMAND seine 
Programme.

  Neuerdings kommen diese Environment-vars wieder in Mode: GEMINI 
benutzt sie ausgiebig, und auch der TURBOASS, mit dem die 
vorliegenden Programme assembliert wurden, benutzt sie. (siehe 
Beispiele).



BEISPIELE:
  Im DESKTOP.ENV-File steht folgendes:
        PATH=;E:\UTILITY\;E:\;C:\;D:\;F:\;G:\;A:\
        SIGMA=E:\ASM\
        RSC2S=E:\ASM\RSC2S\
        SCRAPDIR=C:\CLIPBRD\
  In diesem Fall gibt's 4 Environment-Variablen:
  1. PATH= : die vom Betriebssystem benutzte Variable. Im Beispiel 
wird also zuerst im Ordner UTILITY auf E: gesucht; falls das nix 
bringt, geht die Suche weiter auf E:\, C:\ etc. Ganz zum Schluû erst 
erfolgt der Zugriff auf A: - weil A: das langsamste Kamel in der 
Karawane ist.
  2. SIGMA= : diese Variable beeinfluût den TURBOASS - die folgende 
Pfadangabe gibt an, wo der Assembler seine .DAT, .INF Dateien suchen 
soll.
  3. RSC2S= : fÅr ein weiteres Programm
  4. SCRAPDIR= : Wo das Clipboard-Verzeichnis liegt! Wenn ENVIRO 
diesen String vorfindet, (das '='-Zeichen ist wichtig!) dann setzt 
das ACC auch mit 'SCRP_WRITE' den Zugriffspfad fÅr das Clipboard.



WICHTIG!!!!!!!!!!
  Die erste Variable, PATH=, sollte immer 'PATH=;' lauten, da das 
Betriebssystem das Semikolon hinter '=' rÅcksichtslos Åberschreibt. 


FUNKTIONSWEISE (Intern)

  AUTOENVR.PRG muû im Auto-Ordner liegen. Dieses Programm richtet die 
Emvironment Strings ein und versucht auch, das File 'DESKTOP.ENV' zu 
laden. Autoenvr muû jetzt nicht mehr als letztes Programm im 
Auto-Ordner liegen. Autoenvr trÑgt einen Cookie in den CookieJar ein; 
wenn keiner vorhanden ist, wird selbst einer eingerichtet - 
allerdings werden keine 'System'-Cookies wie _CPU, _MCH, _VDO (fÅr 
den Butler James wichtig!) eingerichtet.

  ENVIRO.ACC setzt von der aktuellen Applikation an abwÑrts alle 
P_ENV-Zeiger der Prozeûdescriptoren. Sogar wenn innerhalb eines 
Programms, das von einer Shell aufgerufen wurde, diese Strings 
verÑndert werden, bekommt das Desktop dies mit.

  WICHTIG: Das Accessory arbeitet nur, wenn AUTOENVR installiert ist. 
Speicherplatzsparer kînnen auch ohne das Accessory leben - das Teil 
lÑuft nÑmlich auch als .PRG !


PROBLEME:
=========
  Die Methode, das Environment eines Programms direkt zu 
manipulieren, ist vom Prinzip her nicht gerade die allersauberste. 
Trotzdem funktioniert's mit allen TOS-Versionen und die wenigen 
Programme, die die Environment-Strings benutzen, stîren sich absolut 
nicht daran.


RATSCHLéGE FöR PROGRAMMIERER:
=============================
  Bei jedem Programmaufruf mit PEXEC als Environment-Pointer einen 
Nullpointer (0L, kein Zeiger auf ein Nullbyte!!) Åbergeben. Dann 
kÅnnert sich das GEMDOS um das Environment. Um dem gestarteten 
Programm einige weitere, eigene Strings zu Åbergeben, wÑre die beste 
Methode, zuerst das eigene Environment Åber den P_ENV-Zeiger in der 
Basepage zu ermitteln (Vorsicht: der Zeiger kînnte in der 
Zwischenzeit geÑndert worden sein!!), dieses in einen eigenen Puffer 
zu kopieren; anschlieûend die eigenen Strings hinzukopieren und dann 
diesen Puffer zu Åbergeben.
  Um Environment-variablen zu finden (im Env. des AES!!) sollte man 
ja SHEL_ENVR benutzen - diese Funktion liefert nÑmlich die richtigen 
Werte.
  Wenn eine Applikation eigene Files nachlÑdt, dann sollte zur 
Ermittlung des kompletten Pfadnamens die Funkion SHEL_FIND (AES 124) 
benutzt werden. Denn diese Funktion benutzt die Environment-Variable 
'PATH=', um diese Datei zu finden.
  Oder, wie im Falle des TURBOASSEMBLERS, ist es denkbar, daû eine 
Applikation eine eigene Variable benutzt.

DER COOKIE:
===========
  AutoEnvr.PRG setzt einen Cookie ein:
Kennung:    ENVR
Daten:      Zeiger auf LongWord-Array

Array:      ARR[0] = Pointer auf AES-Environment
            ARR[1] = LÑnge des Puffers
            ARR[2] = Pointer auf E_INFO - Funktion
            ARR[3] =    "     "  E_SFIRST     "
            ARR[4] =    "     "  E_SNEXT      "

Funktionen:
-----------
  Die Funktionen werden ganz normal mit den Daten auf dem Stack 
aufgerufen. In C: retval=E_xxx(data,...)

  1. E_INFO:
        C-Deklaration:  long e_info()
     AUFRUF:
        C:    version=e_info();
        GFA:  version%=C:e_info%()
     WERTE:
        version: upper word: Versionsnummer, lower word: Unterrev.

  2. E_SFIRST:
        C-Deklaration:  long e_sfirst(pattern)
                                char *pattern;
     AUFRUF:
        C:    found=e_sfirst(pattern);
        GFA:  found%=C:e_sfirst(L:V:pattern$)
     WERTE:
        pattern: Nullterminierter String mit dem Suchmuster.
        found:   entweder -1.L oder Adresse, wo was gefunden wurde.

  3. E_SNEXT:
        C-Deklaration:  long e_snext()
     AUFRUF:
        C:    found=e_sfirst();
        GFA:  found%=C:e_sfirst()
     WERTE:
        found:   entweder -1.L oder Adresse, wo was gefunden wurde.

  Der Patternstring darf maximal 20 Zeichen lang sein, sonst wird 
nicht gesucht. DafÅr darf der String aber beliebig kompliziert sein. 
Als Allquantor gilt '*' (équivalent fÅr Null bis ... Zeichen) und als 
Einzelquantor gilt '?' (ein Zeichen).
Also eine Konstruktion wie ?*MS?D*?*O**S?* ist erlaubt. WÅrde 
Åbrigens auf 'COMSPEC=D:\TOS\XYZ.PRG
                ^^    ^   ^^          passen.

  Ansonsten arbeiten diese Funktionen wie die Gemdos-Funktionen 
FSFIRST und FSNEXT.



ZUM FORMAT der *.ENV-Datei:
  Jede Zeile enthÑlt eine Variable und muû mit CR/LF oder CR oder LF 
abgeschlossen sein. Es wird alles ausgewertet!
Zum Editieren entweder das Accessory oder einen ASCII-Editor 
benutzen. Allerdings werden VerÑnderungen der Datei ohne das ACC erst 
beim nÑchsten Booten aktiv.

BESCHRéNKUNGEN:
  TOS-seitig gibt's keine - auûer daû das AES sich bei 'PATH' auf 50 
Zeichen beschrÑnken soll. Nur das Accessory beschrÑnkt sich auf 
maximal 15 Variablen zu hîchstens 60 Zeichen.



PROBLEM-MELDUNGEN UND EVENTUELLE SPENDEN AN:

   Pascal Fellerich
   45, rue des Genàts
   L-3482 Dudelange
   (Luxembourg)

