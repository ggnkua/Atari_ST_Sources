/* ===============================================================
   < prn8line.h >                              Version: 13.06.1990
   Umwandlung einer monochromen Bitmap-Grafikzeile ( 1 bis 8 Pixel
   hoch ) in Druckerdaten fr 8-Nadel-Drucker mit L„ngen-Optimierung
   ---------------------------------------------------------------
   Copyright (C) 1990 by Thomas Weber - Software Entwicklung
   Dortmunder Straže 5 - 6830 Schwetzingen - Tel. 06202 - 12242
   ---------------------------------------------------------------
   -> Parameter:
   char *bitmap     - Basis-Adresse der monochromen Bitmap-Grafik
   int  y_off       - Startzeile in der Grafik ( bei 0 anfangen zu z„hlen ! )
   int  lines       - Anzahl der zu wandelnden Zeilen (min. 1 / max. 8)
   int  width       - Breite der Grafik in Pixels
   int  z_off       - Zeilenoffset der Grafik in Bytes
   char *buffer     - Adresse des Drucker-Puffers ( auf ausreichende L„nge achten )
   int  optimize    - 0 = Druckzeilenl„nge nicht optimieren
   <- Parameter:
   int  b_len       - aktuelle Anzahl der Druckerdatenbytes (bei 0 nicht drucken
   =============================================================== */

int prn8line( unsigned char *bitmap, int y_off, int lines, int width, int z_off, unsigned char *buffer, int optimize );
