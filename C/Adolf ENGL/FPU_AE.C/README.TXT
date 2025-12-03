--------------------------------------------------------------------------
FPU_AE.LIB  fÅr TURBO C (Atari-ST / TT)                         README.TXT
Version 1.0                                               13.November 1990

Copyright: Adolf ENGL (C)           Barthgasse 9/18   A-1030 Wien  AUSTRIA
--------------------------------------------------------------------------


            *** INFORMATIONEN ZU FPU_AE.LIB (VERSION 1.0) ***                 



1) PRODUKT-INFO:
      "FPU_AE.LIB" ist eine Bibliothek fÅr den C-Compiler "TURBO-C"
    von Borland International (C) fÅr alle ATARI-Modelle mit folgenden
    Prozessortypen:

                - MC68020 + MC68881 (FPU-Coprocessor) 
                              oder
                - MC68020 + MC68882 (FPU-Coprocessor)
                              oder                      
                - MC68030 + MC68881 (FPU-Coprocessor)
                              oder
                - MC68030 + MC68882 (FPU-Coprocessor)
                    
    Dies sind beispielsweise die neuen ATARI-TT Modelle, oder auch die mit
    diversen Erweiterungskarten (z.B PAK-68k mit MC68020/MC68881 von CT) 
    aufgerÅsteten ATARI-ST Modelle.
        Vollkommen unbrauchbar ist diese Bibliothek fÅr ATARI's ohne 
    FPU-Coprocessor oder fÅr ATARI-ST Modelle mit (nur) einem MC68000 
    und einer Coprocessor-Zusatzplatine.
    
        Die "FPU_AE.LIB" soll als Ersatz der von Borland (C) mitgelieferten 
    Flieûkommabibliothek "TCFLTLIB.LIB" dienen. 
    
    Obwohl die Version 2.03 von TURBO-C nun schon brauchbaren Code fÅr 
    das Prozessorgespann MC68020/MC68881 erzeugt, beinhaltet die mitge-
    lieferte Bibliothek "TCFLTLIB.LIB" nach wie vor (nur) Funktionen, die 
    mit einem 80 Bit Format fÅr [long] double rechnen. Die FPU-Coproces-
    soren MC68881 und MC68882 von Motorola benîtigen jedoch anstelle dieses
    80 Bit Formates, ein 96 Bit Format fÅr "extended precision real" 
    Operanten. Ein 80 Bit Format wird von den Fpu-Coprocessoren keinesfalls
    richtig verstanden und ein Aufruf von Funktionen aus "TCFLTLIB.LIB"
    fÅhrt daher (bei Verwendung der FPU) bestenfalls zu unsinnigen Resul-
    taten oder meist gleich zum Programmabsturz.
    Borland schreibt dazu in der README Datei von Turbo C V2.x :
       "... Programme,  die Flieûkommafunktionen aufrufen, welche in der 
        Bibliothek TCFLTLIB definiert sind, jedoch vom Coprozessor nicht 
        unterstÅtzt werden (z.B. printf(), scanf(), atof()),
        sollten nicht mit dem Schalter -8 Åbersetzt werden."
    Das bedeutet, benîtigt man eine der in "TCFLTLIB" enthaltenen 
    Funktionen, wie etwa printf() oder scanf() zur Flieûkomma-I/O, so muû
    man auf den eingebauten FPU-Coprocessor verzichten und alles geht so 
    langsam wie ohne FPU.
    
        Ein sinnvolles Arbeiten unter Verwendung von Flieûkommazahlen 
    mit einer der oben angefÅhrten Systemkonfigurationen ist daher, 
    alleine mit den von Borland mitgelieferten Bibliotheken, derzeit 
    auch mit Turbo C V2.03 noch nicht mîglich.
    
        Da sich die Turbo-C Entwickler(innen) bislang (seit August 90 ver-
    spricht mir am Telefon ein freundlicher Herr von Borland MÅnchen 
    "sogleich" das entsprechende Update zu schicken) zur Herausgabe einer
    brauchbaren Flieûkommabibliothek nicht aufraffen konnten, habe ich 
    nun als "erste Hilfe Paket" die "FPU_AE.LIB" entwickelt.
    
        Die Funktionen in der "FPU_AE.LIB" verwenden intern das, auch vom 
    TURBO-C Compiler (bei der Verwendung des Schalters -8) fÅr [long] double
    erzeugte 96-Bit Format und verstehen sich daher prÑchtig mit den 
    Motorola FPU-Coprozessoren.
  
    
2) Funktions - Umfang:
        
    Die Bibliothek "FPU_AE.LIB" umfaût folgende Funktionen:
    
    int printf( const char *format, ... );
    int fprintf( FILE *stream, const char *format, ... );
    int sprintf( char *string, const char *format, ... );
        
    int scanf( const char *format, ... );
    int fscanf( FILE *stream, const char *format, ... );
    int sscanf( const char *string, const char *format, ... );
    
    int vfprintf( FILE *stream, const char *format, va_list param );
    int vprintf( const char *format, va_list param );
    int vsprintf( char *string, const char *format, va_list param );
    int vfscanf( FILE *stream, const char *format, va_list param );
    int vscanf( const char *format, va_list param );
    int vsscanf( char *string, const char *format, va_list param );
            
    char    *ecvt( double d, int ndig, int *dec, int *sign ); 
    double  atof( const char *digStr );
    double  strtod( const char *s, const char **endptr );
    double  modf( double x, double *nptr );
    double  ceil( double x );
    double  floor( double x );
    double  round( double x );
    double  difftime( time_t time2, time_t time1 );
    void    xdcnv( double *val, void *rep8bytes );
    void    dxcnv( void *rep8bytes, double *val );

    Alle Åbrigen Standard-FPU-Funktionen werden direkt vom FPU-Coprozessor
    unterstÅtzt und sind in MATH.H ALS MAKROS definiert.
   
    
3) Produkt - Umfang:

   "FPU_AE.LIB" Version 1.0 besteht aus folgenden Dateien:
       - fpu_ae.lib   ...  die eigentliche Bibliotheks-Datei
       - math.h       ...  die zugehîrige Include - Datei
       - readme.txt   ...  das sollten Sie gerade lesen


4) Fehler:
   Es wird NICHT fÅr die fehlerfreie Funktion der Bibliothek garantiert.
   Die Bibliothek wurde vorallem fÅr den Eigengebrauch entwickelt und wurde
   bislang nur auf einem ATARI-Mega-ST mit PAK-68k (mit MC68020/MC68881)
   (spÑrlich) getestet. Fehler sind daher mit groûer Sicherheit zu erwarten.
   Aber hoffentlich weniger als in den derzeitigen TC-Bibliotheken.
      
   Bewuûte EinschrÑnkungen:
     - nachfolgende Nullen werden bei g-Format (printf()) nicht unterdrÅckt;
     - keine eigene ftoa() - Funktion 

   
5) Installation:
    
   a) "fpu_ae.lib" in den TC-Library-Ordner kopieren; (im allg. nach "tc/lib")
   b) "math.h" im TC-Includefile-Ordner durch das mitgelieferte "math.h"
      ERSETZEN.
      
      
6) Verwendung:

   FÅr die Verwendung der Bibliothek "FPU_AE.LIB" sind folgende Punkte zu
   beachten:
              - Compiler-Option -2 und -8 EINSCHALTEN
              - Assembler-Option -2 oder -3 EINSCHALTEN
              - Assembler-Option -8 EINSCHALTEN
              - in Projektdatei fpu_ae.lib anstelle von TCFLTLIB.LIB
                schreiben oder zumindestens fpu_ae.lib VOR TCFLTLIB.LIB
                anfÅhren.


7) Verwendungsberechtigung:
   
a) FÅr die Verwendung der Bibliothek "fpu_ae.lib", oder von Teilen daraus,
   in Programmen bzw. zur Erstellung von Programmen und sonstigen Soft-
   wareprodukten ist KEINERLEI GEBöHR zu entrichten, soferne es sich bei
   diesen Programmen und sonstigen Softwareprodukten um solche fÅr den
   EIGENEN GEBRAUCH handelt, oder um Produkte, die UNENTGELTLICH an
   Dritte weitergegeben werden, wie z.B. Public-Domain-Programme.

b) Die Verwendung der Bibliothek "fpu_ae.lib", oder von Teilen daraus,
   in kommerziellen Produkten, das heiût in oder zur Erstellung von
   Programmen und sonstigen Softwareprodukten fÅr deren Weitergabe ein 
   Entgelt verlangt wird, ist hiermit NICHT GESTATTET, sondern bedarf
   einer eigenen Lizenzvereinbarung.
   DiesbezÅgliche Anfragen richten Sie bitte an folgende Adresse:
                   Adolf ENGL  
                   Barthgasse 9/18 
                   A-1030  Wien   Austria       

c) Das Produkt "FPU_AE.LIB" darf (und soll) beliebig oft und unentgeltlich
   kopiert und an DRITTE weitergegeben werden, soferne immer ALLE UNTER 
   Punkt (3) ("Produkt-Umfang") aufgelisteten Dateien in UNVERéNDERTER Form
   enthalten sind.
   

8) freiwilliger Entwicklungsbeitrag:
   
   Die Verwendung der "FPU_AE.LIB" ist, gemÑû den unter Punkt (7) ("Verwen-
   dungsberechtigung") angefÅhrten Bestimmungen, KOSTENLOS gestattet.
   
   Falls Sie jedoch das Produkt gut gebrauchen kînnen und deshalb auch die
   Arbeit des Autors honorieren wollen, so kînnen Sie einen Betrag Ihres
   Ermessens als finanziellen Entwicklungsbeitrag an folgende Adresse senden:
         Adolf Engl  Barthgasse 9/18   A-1030  Wien   Austria
    
  (Bitte Åbersenden Sie nur Banknoten und/oder Euroschecks. Euroschecks
   bitte in ôster. Schillingen (KÅrzel ôS) ausstellen.)

   
9) Anregungen, WÅnsche und Kritik:
     
     DiesbezÅgliche Mitteilungen senden Sie bitte an die Adresse des Autors
   oder via eMail z.B. an Adolf Engl 2:310/3 im FidoNet.
   
   Bedenken Sie dabei bitte, daû diese Bibliothek nur als UberbrÅckungshilfe
   fÅr all jene Leidensgenossen mit einer der anfangs beschriebenen System-
   konfigurationen, dienen soll. Und vorallem nur solange bis Borland 
   endlich ein besseres Turbo-C Update herausbringt.   
   
   
                                  Mit freundlichen GrÅûen

                                         Adolf Engl
                                         
