/*
   Modul: M_UTILS (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPUTILS_
#define _MPUTILS_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#ifdef __GNUC__
#define OBSPEC U_OB_SPEC
#endif

typedef enum
{
   SearchType,
   SearchState,
   SearchFlags
} ScanType;

typedef enum
{
   left,
   right,
   both
} BounceMode;

void InclFlag(OBJECT *tree,int entry,int bit);
void ExclFlag(OBJECT *tree,int entry,int bit);
void SetFlag(OBJECT *tree,int entry,int bit,BOOLEAN setit);
BOOLEAN InFlag(OBJECT *tree,int entry,int bit);
void InclState(OBJECT *tree,int entry,int bit);
void ExclState(OBJECT *tree,int entry,int bit);
void SetState(OBJECT *tree,int entry,int bit,BOOLEAN setit);
BOOLEAN InState(OBJECT *tree,int entry,int bit);
void ObjcString(OBJECT *tree,int entry,char *str);
char *ObjcStringAdr(OBJECT *tree,int entry);
void SetObjcString(OBJECT *tree,int entry,char *str);
void SetObjcStringAdr(OBJECT *tree,int entry,char *str);
void ObjcStrLen(OBJECT *tree,int entry,int *textLen,int *tmpltLen);
void ObjcColor(OBJECT *tree,int entry,int *inner,int *text,int *frame,int *raster);
void SetObjcColor(OBJECT *tree,int entry,int inner,int text,int frame,int raster);
int ObjcParent(OBJECT *tree,int entry);
void ObjcPos(OBJECT *tree,int entry,int *x,int *y);
void ObjcArea(OBJECT *tree,int entry,GRECT *rect);
void ObjcRect(OBJECT *tree,int entry,GRECT *rect);
void SetObjcRect(OBJECT *tree,int entry,GRECT *rect);
int ObjcFrame(OBJECT *tree,int entry);
void CalcArea(OBJECT *tree,int entry,GRECT *rect);
int ScanFlags(OBJECT *tree,ScanType styp,int entry,int typ,int flag);
void SetObjc(OBJECT *tree,int num,int parent,int typ,BITSET flags,BITSET state,OBSPEC *spec,
                   int obx,int oby,int obw,int obh,BOOLEAN add);
OBSPEC *GetObjcspec(OBJECT *tree,int entry);
void Bounce(BounceMode mode);
void AbsRect(GRECT *rect);
void RelRect(GRECT *rect);
void RectToVars(GRECT *rect,BOOLEAN abs,int *x,int *y,int *w,int *h);
void VarsToRect(int x,int y,int w,int h,BOOLEAN abs,GRECT *rect);
void AbsRectToVars(GRECT *rect,BOOLEAN abs,int *x,int *y,int *w,int *h);
void AbsVarsToRect(int x,int y,int w,int h,BOOLEAN abs,GRECT *rect);
BOOLEAN InAbsRect(int x,int y,GRECT *rect);
BOOLEAN InRelRect(int x,int y,GRECT *rect);
void DecAbsRect(GRECT *r,int *num);
void DecRelRect(GRECT *r,int *num);
void IncAbsRect(GRECT *r,int *num);
void IncRelRect(GRECT *r,int *num);
void CalcSlider(long max,long act,long fpos,int *pos,int *size);
long CalcDocPos(int max,int act,int spos);
void ObjcFString(OBJECT *tree,int entry,char *str);
void HideObjctree(OBJECT *tree, int entry, BOOLEAN hide);
long LCalcDocPos(long max,long act,long spos);

#endif
