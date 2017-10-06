/*
	Modul: MPXOBJEC.C (Headerdatei)
	
	geschrieben von Thomas KÅnneth
	Friedrich-Neuper-Str. 2b
	90552 Rîthenbach
	
	Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
	Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
	Nutzungsbedingungen von Magic fÅr C verwendet werden
	
	Alle Rechte beim Autor
*/

#ifndef _MPXOBJEC_
#define _MPXOBJEC_

#ifdef __GNUC__
#define OBSPEC U_OB_SPEC
#endif

typedef PARMBLK* PtrPARMBLK;
typedef int (*DrawProc)(PtrPARMBLK para);

typedef struct {
     void      *ubCode;
     OBSPEC    ubPara;
     DrawProc  draw;
     int       obType;
     void      *priv;
} USER_BLK;

typedef USER_BLK* PtrUSER_BLK;

BOOLEAN InstUserdef(OBJECT *tree,int objc,DrawProc proc,void *private);
void FreeUserdef(OBJECT *tree,int objc);
int GetObtype(OBJECT *tree,int objc);
OBSPEC *GetObSpec(OBJECT *tree,int objc);
void *GetPrivate(OBJECT *tree,int objc);
void GetValues(OBJECT *tree,int objc,long *v1,long *v2);
void SetValues(OBJECT *tree,int objc,long v1,long v2);
void SetPrivate(OBJECT *tree,int objc,void *private);

#endif