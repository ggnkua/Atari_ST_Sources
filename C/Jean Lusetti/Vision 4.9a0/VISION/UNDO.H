#ifndef __UNDO_H
#define __UNDO_H

/***************************/
/* Header du module UNDO.C */
/***************************/
#if !defined(__DEFS_H)
#include "defs.h"
#endif

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

/* Types de modifs des buffers Undo */
#define UPOINT     1
#define UTRACE     2
#define UAEROSOL   3
#define ULIGNE     4
#define ULIGNES    5
#define UCERCLE    6
#define UDISQUE    7
#define URECT      8
#define UPLAN      9
#define UTEXTE    10
#define UPEINT    11
#define UEFFACE   12
#define UCOUPE    13
#define UCOLLE    14
#define UGOMME    15
#define UREFAIRE  16
#define UNEGATIF  17
#define UTAB      18
#define USYMX     19
#define USYMY     20
#define USYMXY    21
#define UPINCEAU  22
#define ULUMIERE  23
#define UGAMMA    24
#define UFILTRE   25
#define UROTATION 26
#define UTAILLE   27
#define UCONVERT  28
#define UNEGLASSO 29
#define ULDV      30

typedef struct
{
  void* spec ;
  long  nb_bytes_to_allocate_and_copy ;
  char  RFU[24] ;
}
XUNDO ;

extern UNDO_DEF clipboard ;           /* Buffer Couper/Coller ...        */

void      update_raster(GEM_WINDOW* gwnd, int xmin, int ymin, int xmax, int ymax) ;
void      clip_put(GEM_WINDOW* gwindow, int x1, int y1, int x2, int y2) ;
void      clip_putlasso(GEM_WINDOW* gwindow, int x1, int y1, int x2, int y2, MFDB *mask, MFDB *masked_img) ;
int       undo_put(GEM_WINDOW* gwindow, int x1, int y1, int x2, int y2, int type_modif, XUNDO *xundo) ;
int       uundo_put(GEM_WINDOW* gwnd) ;
void      undo_restore(GEM_WINDOW* gwnd) ;
void      traite_refaire(GEM_WINDOW* gwnd) ;
void      set_modif(GEM_WINDOW* gwindow) ;
void      traite_effbuffers(GEM_WINDOW* gwnd) ;
void      free_lastundo(GEM_WINDOW* gwnd) ;
UNDO_DEF* GetUndoBuffer(VXIMAGE *vimage) ;
void      FreeUndoBuffer(UNDO_DEF* undo) ;
void      FreeUUndoBuffer(GEM_WINDOW* gwnd) ;
void      FreeClipboard(void) ;

#endif
