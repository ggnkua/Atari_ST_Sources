/*
   Modul: M_TERMIN (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPTERMIN_
#define _MPTERMIN_

#ifndef _MPWINDOW_
#include <magic\m_window.h>
#endif

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#define  Fat          1
#define  Light        2
#define  Italic       4
#define  Underline    8
#define  Outline     16
#define  Shadowed    32
#define  Invers     128    /* ZusÑtzliches Flag fÅr Text-Effekte. Wird in
                              mpTerminal emuliert! */

int OpenTextwindow(WindowHandler draw,BITSET element,LONGBITSET extended,
                   int x,int y,int w,int h,
                   int xo,int yo,int wo,int ho,
                   int bcolor,int fcolor,
                   int font,int size,
                   BITSET effects,
                   int wrappos,
                   char *name,char *info,
                   OBJECT *rsc);
void CloseTextwindow(int win);
void WriteChar(int win,char ch);
void WriteLine(int win,char *str);
void WriteLn(int win);
void WriteLInt(int win,long val,int len);
void WriteInt(int win,int val,int len);
void WriteWord(int win,unsigned int val,int len);
char GetChar(int win,int x,int y);
void GetLine(int win,int line,char *string);
void WindowInfo(int win,int *column,int *lines,int *font);
void InsertLine(int win);
void DeleteLine(int win);
void WhereXY(int win,int *spalte,int *zeile);
void GotoXY(int win,int spalte,int zeile);
void CursorOn(int win);
void CursorOff(int win);
void WrapPos(int win,int pos);
void WrapOff(int win);
void WrapOn(int win);
void ClearLine(int win);
void ClearStartOfLine(int win);
void ClearEndOfLine(int win);
void ClearScreen(int win);
void ClearStartOfScreen(int win);
void ClearEndOfScreen(int win);
void ForegroundColor(int win,int color);
void BackgroundColor(int win,int color);
void InversOn(int win);
void InversOff(int win);
void SetAttribut(int win,BITSET attrib);
void SetTabspace(int win,int tab);
void ChangeFont(int win,int font,int size,int color,BITSET attrib);
int TopTerminal(void);
void CalcRedraw(int win,GRECT *rect,int *von,int *bis);
void TermfontSelector(char *msg,BITSET flags);

#define LoadTermFonts() CallMagic(2033)

#endif