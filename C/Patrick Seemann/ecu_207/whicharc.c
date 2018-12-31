/* --------------------------------------------------------------------
   Module:     WHICHARC.C
   Subject:    stellt fest, welcher Packer zum Packen eines Archivs
               verwendet wurde.
   Author:     ho
   Started:    28.09.1991   13:35:57
   Modified:   13.10.1991   14:15:57
   --------------------------------------------------------------------
   Prototype:  int WhichArc(char *pName)
      pName    vollstÑndiger Name der zu untersuchenden Datei
      Ergebnis -1:      Datei nicht vorhanden
               UNKNOWN: unbekannter Packer
               ARC:     ARC oder PKARC
               ARJ:     ARJ
               LHA:     LHARC oder LHA
               ZIP:     PKZIP
               ZOO:     Zoo

   Kriterien zum Erkennen der verschiedenen Packer:

   LHARC/LHA
      Diese Archive haben keinen Archiv-Header. Das Archiv beginnt also
      sofort mit dem ersten Datei-Header. WhichArc prÅft, ob die PrÅf-
      summe Åber den Header stimmt, und ob als Methode '-lh?-' angege-
      ben ist. Schon alleine die PrÅfsumme sollte jedoch als Kriterium
      genÅgen.

   ARJ
      Diese Archive beginnen immer mit der Bytefolge 0x60, 0xEA. Jeden-
      falls weigert sich UNARJ Archive auszupacken, die nicht so begin-
      nen. Und was UNARJ recht ist, ist mir allemale billig.

   ZIP
      Das einzige feststellbare Merkmal fÅr geZIPte Archive ist, da·
      sie immer mit "PK" beginnen.

   ZOO
      GeZOOte Archive beginnen immer mit dem String "ZOO x.xx Archive".
      Mir genÅgt hier "ZOO".

   ARC
      Auch diese Archive haben keinen Archiv-Header. Das Format eines
      Datei-Headers ist zwar bekannt, enthÑlt nichts, an dem man ohne
      gro·en Aufwand zweifelsfrei feststellen kann, ob es sich um ein
      solches Archiv handelt oder nicht. Nur das erste Byte - 0x1A -
      ist fest. Also betrachtet WhichArc alle Files, die mit 0x1A be-
      ginnen, und kein anderes Archiv sein kînnen, als ARC-Archiv.
   -------------------------------------------------------------------- */



#include <stdio.h>
#include <string.h>

#include "defines.h"
#include "llegadef.h"


int WhichArc(char *pName)
{
   FILE  *fp;
   BYTE  header[128];
   int   c, i, n;

   memset(header, 0, sizeof(header));
   fp = fopen(pName, "rb");
   if (fp == NULL) return -1;
   n = (int) fread (header, sizeof(BYTE),
                    sizeof(header) - sizeof(BYTE), fp);
   fclose(fp);

   if (n <= 0) return -1;

   if (n >= 7 && n >= header[0] + 2)
   {
      for (c = 0, i = header[0]; i--; c += (header+2)[i]);
      if ((c & 0x00FF) == header[1] &&
          header[2] == '-'          &&
          header[3] == 'l'          &&
          header[4] == 'h'          &&
                               header[6] == '-') return (header[5] > '1') ? LHA : LHARC;
   }

   if (n >= 2)
   {
      if (header[0] == 0x60 && header[1] == 0xEA) return ARJ;
      if (header[0] == 'P'  && header[1] == 'K')  return ZIP;
   }

   if (n >= 3
      && header[0] == 'Z' && header[1] == 'O' && header[2] == 'O') return ZOO;

   if (n >= 25 && header[0] == 0x1A) return ARC;

   return UNKNOWN;
}
