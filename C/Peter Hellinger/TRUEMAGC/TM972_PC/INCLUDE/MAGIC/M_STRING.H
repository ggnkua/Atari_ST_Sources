/*
   Modul: M_STRING (Headerdatei)

   geschrieben von Dirk Stadler
   Friedrich-Kînig-Weg 4
   90513 Zirndorf

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPSTRING_
#define _MPSTRING_

#ifndef _MAGICTYP_
#include <magic\types.h>
#endif

long StrLen(char *str);
int StrComp(char *str1, char *str2);
int StrLComp(char *str1, char *str2, long maxlen);
int StrPos(char *str1, char *str2);
int StrScan(char *str, char c);
int StrIPos(char *str1, char *str2, int start);
int StrWPos(char *str1, char *str2, int start, char wild, char joker);
void StrCopy(char *dest, char *source);
void StrLCopy(char *dest, char *source, long maxlen);
void StrCat(char *dest, char *source);
void StrLCat(char *dest, char *source, long maxlen);
void StrInsert(char *str1, char *str2, int start);
void StrDelete(char *str, int start, int len);
void StrUpper(char *str);
void StrLower(char *str);
BOOLEAN StrMatch(char *str1, char *str2, char wild, char joker);
void StrICopy(char *dest, char *source, int start, int len);
int StrSimilar(char *cs1, char *cs2);
int StrLexComp(char *cs1, char *cs2);

#endif
