NVDI Rasterkit vom 26.2.97
==========================

Haftung
ÿÿÿÿÿÿÿÿ
Trotz sorgf„ltiger Entwicklung und umfangreicher Tests k”nnen wir keine Gew„hr 
bernehmen, da die Software und die beiliegenden Quelltexte unterbrechungs-
und fehlerfrei laufen. Die Haftung fr unmittelbare Sch„den, Folgesch„den
und Drittsch„den ist ausgeschlossen!

Bedienung
ÿÿÿÿÿÿÿÿÿ
Ein oder mehrere ESM-Bilder (24 Bit RGB) auf die Demoprogramme TSTFLOYD.PRG oder 
TSTDITHR.PRG ziehen.

Weitergabe
ÿÿÿÿÿÿÿÿÿÿ
Das Rasterkit ist ein Teil der NVDI-Dokumentation. Die in diesem Ordner
befindlichen Dateien drfen frei kopiert und weitergegeben werden. In jedem
Fall mssen aber alle in diesem Ordner vorhandenen Dateien (insbesondere
die Datei README.TXT) komplett und unver„ndert weitergegeben werden.

Es ist erlaubt und ausdrcklich erwnscht, da die Beispielquellen als
Grundlage fr Rasterwandlung in eigenen Programmen benutzt werden!



Anmerkungen zu den Sourcen
==========================
- Alle Dateien aus dem Ordner INCLUDE geh”ren in den INCLUDE-Ordner
  des Compilers.

- "Types2B.h" ist die Header-Datei mit den Datentypdefinitionen


COLMAP_G.C:

 - es wird davon ausgegangen, da vq_scrninfo() vorhanden ist,
   eine Abfrage mu noch eingebaut werden. Diese Funktion
   ist ab NVDI 2.5, NOVA-VDI 2.6x und dem VDI-Enhancer (EdDI 1.0
   - Freeware) verfgbar.

 - Durch die Invers-Colormap-Routine kann mit nahezu jeder Palette
   gearbeitet werden. Um gute Resultate zu erreichen, sollte aber eine
   Palette vorhanden sein, die den RGB-Farbraum abdeckt. Neben der 
   NVDI_NEU.PAL funktionien auch die Dither-Paletten von Gemview, CAB,
   Calamus oder 1st-Guide gut.
   
TESTDIT2.C:

 - Es k”nnen nur ESM-Bilder mit 24 Bit RGB geladen werden.
 - mit USE_FLOYD kann eingestellt werden, ob Floyd-Steinberg
   oder Ordered Dither zum Darstellen benutzt wird
 - mit USE_DEFAULT_COLORS wird die neue Standardpalette (siehe
   "Anmerkungen zur Farbpalette") gesetzt
 - Der Schalter DITHER_SINGLE_LINES legt fest, ob das gesamte Bild 
   gedithert, transformiert und anschlieend ausgegeben wird 
   (DITHER_SINGLE_LINES ist 0) oder ob Zeile fr Zeile gedithert, 
   transformiert und ausgegeben wird (DITHER_SINGLE_LINES ist 1).
   In letzterem Fall wird das der Funktion show_image() bregebene 
   Quellbild nicht zerst”rt, in ersterem wird es berschrieben, da der 
   Bildspeicher als Puffer fr die Wandlung benutzt wird.   

CFLOYD_G.C:
DITHER_G.C:
 - Die Routinen <do_floyd()> und <do_dither()> wandeln jetzt auch
   Farbbilder in Schwarzweibilder um. Die Umrechnung der Farbwerte
   in einen Grauwert erfolgt dabei nach CCIR 709
   (ungef„hr: Grau = 0.33 * R + 0.60 * G + 0.07 * B ).

 - Wer eine Bitmap dithern m”chte, die 256 Farben enth„lt (um sie z.B. in 16 
   Farben anzuzeigen), sollte zur Anzeige das Bild ber einen kleinen
   Buffer scheibchenweise in xRGB-Pixel wandeln. Eine Wandelfunktion s„he dann
   wie folgt aus:
   
void  von_8_bit_zu_xRGB( uint8 *src, int32 *buf, int16 xmax, int16 ymax, 
                         COLOR_ENTRY *src_colors )
{   
   int16 x;
   int16 y; 

   for ( y = 0; y <= ymax; y++ )
   {
      for ( x = 0; x <= xmax; x++ )
      {
         uint8    index;
         int32    red;
         int32    green;
         int32    blue;
    
         index = *src++;                                       /* 8-Bit-Pixel einlesen */
   
         red = src_colors[index].rgb.red >> 8;                 /* Farbwert auslesen */
         green = src_colors[index].rgb.green >> 8;             /* und durch 256 teilen */
         blue = src_colors[index].rgb.blue >> 8;
      
         *buf++ = ( red << 16 ) | ( green << 8 ) | blue;       /* xRGB-Pixel ausgeben */
      }
      /* hier mu ggf. noch
      
      src += src_offset;
      buf += buf_offset;
      
      addiert werden, um in die n„chste Zeile zu kommen. */
   }
}
  
   <src_colors> zeigt auf die Farbtabelle des Quellbilds, wobei obiger Code 
   davon ausgeht, da die RGB-Werte 16bittig sind (0 <= rgb <= 65535).
   
EDDILIB.C:
 - zus„tzliche VDI-Funktionen

Anmerkungen zur Farbpalette
===========================
Im Source kann per Compilerdirektive eine Palette gesetzt werden,
welche die n„chsten NVDI-Version default-m„ig setzen wird.

Diese Palette zeichnet sich gegenber der (zur Abschreckung bei-
liegenden) ATARI-Palette durch folgende Eigenschaften aus:

- Systemfarben sind nicht voll aufgerissen, wodurch z.B. Grn als
  Hintergrundfarbe wieder einsetzbar wird.

- Die 16 Systemfarben sind so gesetzt, da man damit einen vernnftigen
  Floyd-Steinberg-Dither durchfhren kann (mit der ATARI-Palette grauen
  Bilder aus, da die ATARI-Grauwerte aufgrund der Lage innerhalb des 
  Farbwrfels bevorzugt verwendet werden). Einfach mal mit den 
  beiliegenden ESM-Dateien testen, indem die Farbindizes 16 - 255 im
  beiliegenden COLOR.CPX auf wei gesetzt werden ...
  
- Die statischen Farben der Windows-Farbpalette wurden bercksichtigt,
  wodurch Farbverf„lschungen bei den brigen Farben verhindert werden.
  
- Die Palette enth„lt ansprechende Selektionsfarben fr die XOR-
  Verknpfung (siehe z.B. Popup in MagiC-Dateiauswahl oder im
  Desktop).
  
- Die Palette deckt den gesamten RGB-Farbraum und nicht nur die
  Auenfl„chen des RGB-Wrfels ab, was Farbsprnge bei der Fehler-
  verteilung vermeidet.
  
Anmerkungen zu Pure Pascal
==========================
Um den Assemblerfile TRNSFM.S problemlos unter Pure Pascal zu nutzen,
mssen die im BSS-Segment definierten Felder t8ip4_tab und t8ip8_tab
im Pascal-Programm definiert werden:

VAR   t8ip4_tab : ARRAY of LONGINT[16];
      t8ip8_tab : ARRAY of LONGINT[2*256];

Am Anfang des Assemblerfiles TRNSFM.S mssen beide dann mit

                  IMPORT   t8ip4_tab
                  IMPORT   t8ip8_tab
 
importiert werden. Das BSS-Segment (die letzten fnf Zeile vor 'END')
kann dann gel”scht werden.
               
Changes/korrigierte Fehler
==========================

TESTDIT1.C:
-  Probleme mit falschem VDI-Handle auf Nova-Grafikkarten behoben

COLMAP_G.C:
-  VGA-Modi mit 16-Farben-VGA-Modus werden erkannt

TRNSFM.S:
-  Speicherschieer bei 16-Farb-VGA-Modus entfernt.
-  Wandlung von 8 Bit auf 1 Bit korrigiert.
-  Wandlungsroutine fr 8 Farben (Druckausgabe) umgeschrieben, um Probleme bei 
   gleicher Bufferadresse zu beheben.
-  Die Wandlungstabellen t8ip4_tab und t8ip8_tab werden wegen Pure Pascal nicht 
   mehr PC-relativ adressiert.

CFLOYD_G.C:
-  Routine fr Darstellung auf Schwarzwei-Bildschirmen eingebaut.

DITHER_G.C
-  Das Zielrechteck wird bergeben, um bei Ausgabe von Einzelzeilen die richtige 
   Position in der Dithermatrix anzusprechen.
-  Ditherfunktion fr Darstellung auf Schwarzwei-Bildschirmen eingebaut.


