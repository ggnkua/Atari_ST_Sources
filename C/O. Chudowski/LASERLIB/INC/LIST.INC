/**************************************************************************/
/*                                                                        */
/*  NAME:         list.inc                                                */
/*                                                                        */
/*  DATUM:        23.11.88                                                */
/*                                                                        */
/*  BESCHREIBUNG: Includefile fuer Modul list.c.                          */
/*                                                                        */
/*  AENDERUNGEN:  CH270788 - Prototyp.                                    */
/*                CH290788 - Makros fuer lfndelm(lp, MODE) ...            */
/*                CH310888 - #ifndef PORTAB eingebaut.                    */ 
/*                CH010988 - LGetName() Macro, etc                        */
/*                CH030988 - IsLast(), IsFirst(),...                      */
/*                         - LSTRECNO, LFindRecno()                       */
/*                CH040988 - LSTNOSPACE, LSTNOCASE                        */
/*                CH060988 - struct key, key in LIST                      */
/*                         - LSetError(),LGetError                        */
/*                CH231188 - LPut ... eingefuegt.                         */
/*                CH181288 - lst_hash in Struktur LSTLIST aufgenommen     */
/*                                                                        */
/**************************************************************************/

#include <portab.h>
#include <boolop.h>

typedef struct _Elem
{
   struct _Elem *elm_prev;
   struct _Elem *elm_next;
          BYTE  *elm_buf;
          BYTE  *elm_key;
} ELEM;

typedef struct _List
{
   ELEM  *lst_first;
   ELEM  *lst_last;
   ELEM  *lst_curr;
   LONG   lst_cnt;
   WORD   lst_kypos;
   WORD   lst_kylen;
   WORD   lst_buflen;
   WORD   lst_flag;
   BYTE  *lst_name;
   BYTE  *lst_buf;
   BYTE  *lst_key;
   ELEM **lst_hash;
} LIST;

extern BYTE  *strcpy();
extern WORD   strncmp();
extern BYTE  *malloc();
extern BYTE  *lgetver();
extern LIST  *lnewlst();
extern BOOL   ldellst();
extern BOOL   linselm();
extern BOOL   ldelelm();
extern VOID   lcopbuf();
extern VOID   lgenkey();
extern VOID   lprtlst();
extern VOID   lprtbuf();
extern BOOL   lprtelm();
extern BOOL   lfndelm();
extern BOOL   lgetelm();
extern BOOL   lputelm();
extern BOOL   lgenelm();
extern VOID   lcoplst();
extern BOOL   lchgkey();
extern LONG   lgetrno();
extern WORD   lseterr();
extern BOOL   lwrtlst();
extern BOOL   lrealst();
extern VOID   lfilbuf();

#define LSTNOERROR       0
#define LSTEUNIQUE      -1
#define LSTEBADELEM     -2
#define LSTENOMEM       -3
#define LSTENOFOUND     -4
#define LSTEREAD        -5
#define LSTEWRITE       -6

#define LSTVERSION      "2.6"   /* Versionsnummer des Moduls */
#define LSTUNIQUE       0x1
#define LSTFILE         0x2
#define LSTMEMORY       0x4
#define LSTNOSPACE      0x8
#define LSTNOCASE       0x10
#define LSTHASH         0x20
#define LSTTITLE        0x40
#define LSTNUM          0x80
#define LSTKEYMODES     (LSTNOSPACE | LSTNOCASE)

#define LSTCURR         0x0
#define LSTNEXT         0x1
#define LSTPREV         0x2
#define LSTFIRST        0x4
#define LSTLAST         0x8
#define LSTEQUAL        0x10
#define LSTNOTEQUAL     0x20
#define LSTGREATER      0x40
#define LSTLESS         0x80
#define LSTRECNO        0x100
#define LSTSET          0x200

#define LSTENULP        ((ELEM *) 0L)
#define LSTNULP         ((LIST *) 0L)

#define LToFirst(lp)    (lp->lst_curr = lp->lst_first)
#define LToLast(lp)     (lp->lst_curr = lp->lst_last)
#define LToNext(ep)     (ep = ep->elm_next)
#define LToPrev(ep)     (ep = ep->elm_prev)
#define LIsFirst(lp)    (lp->lst_curr == lp->lst_first)
#define LIsLast(lp)     (lp->lst_curr == lp->lst_last)
#define LIsNull(ep)     (ep == LSTENULP)

#define LCmpBuf(lp,ep)  (strncmp (lp->lst_key, ep->elm_key, lp->lst_kylen))
#define LExtraKey(lp)   (BOGetVal (lp->lst_flag, LSTKEYMODES))

#define LGetName(lp)      (lp->lst_name)
#define LGetBuflen(lp)    (lp->lst_buflen)
#define LGetCount(lp)     (lp->lst_cnt)
#define LGetKyLen(lp)     (lp->lst_kylen)
#define LGetFlag(lp)      (lp->lst_flag)
#define LGetBuf(lp)       (lp->lst_buf)
#define LGetKey(lp)       (lp->lst_key)
#define LSetFlag(lp,f)    (lp->lst_flag |= (f))

#define LSetError(err)    lseterr (err)
#define LGetError()       lseterr (LSTNOERROR)

#define LFindNext(lp)     lfndelm (lp, LSTNEXT)
#define LFindPrev(lp)     lfndelm (lp, LSTPREV)
#define LFindCurr(lp)     lfndelm (lp, LSTCURR)
#define LFindFirst(lp)    lfndelm (lp, LSTFIRST)
#define LFindLast(lp)     lfndelm (lp, LSTLAST)
#define LFindEqual(lp)    lfndelm (lp, LSTEQUAL)
#define LFindNotEqual(lp) lfndelm (lp, LSTNOTEQUAL)
#define LFindGreater(lp)  lfndelm (lp, LSTGREATER)
#define LFindLess(lp)     lfndelm (lp, LSTLESS)
#define LFindEGreater(lp) lfndelm (lp, LSTGREATER | LSTEQUEAL)
#define LFindELess(lp)    lfndelm (lp, LSTLESS | LSTEQUAL)
#define LFindRecno(lp)    lfndelm (lp, LSTRECNO)

#define LGetNext(lp)      lgetelm (lp, LSTNEXT)
#define LGetPrev(lp)      lgetelm (lp, LSTPREV)
#define LGetCurr(lp)      lgetelm (lp, LSTCURR)
#define LGetFirst(lp)     lgetelm (lp, LSTFIRST)
#define LGetLast(lp)      lgetelm (lp, LSTLAST)
#define LGetEqual(lp)     lgetelm (lp, LSTEQUAL)
#define LGetNotEqual(lp)  lgetelm (lp, LSTNOTEQUAL)
#define LGetGreater(lp)   lgetelm (lp, LSTGREATER)
#define LGetLess(lp)      lgetelm (lp, LSTLESS)
#define LGetEGreater(lp)  lgetelm (lp, LSTGREATER | LSTEQUEAL)
#define LGetELess(lp)     lgetelm (lp, LSTLESS | LSTEQUAL)
#define LGetRecno(lp)     lgetelm (lp, LSTRECNO)

#define LPutNext(lp)      lputelm (lp, LSTNEXT)
#define LPutPrev(lp)      lputelm (lp, LSTPREV)
#define LPutCurr(lp)      lputelm (lp, LSTCURR)
#define LPutFirst(lp)     lputelm (lp, LSTFIRST)
#define LPutLast(lp)      lputelm (lp, LSTLAST)
#define LPutEqual(lp)     lputelm (lp, LSTEQUAL)
#define LPutNotEqual(lp)  lputelm (lp, LSTNOTEQUAL)
#define LPutGreater(lp)   lputelm (lp, LSTGREATER)
#define LPutLess(lp)      lputelm (lp, LSTLESS)
#define LPutEGreater(lp)  lputelm (lp, LSTGREATER | LSTEQUEAL)
#define LPutELess(lp)     lputelm (lp, LSTLESS | LSTEQUAL)
#define LPutRecno(lp)     lputelm (lp, LSTRECNO)

#define LInsNext(lp)      linselm (lp, LSTNEXT)
#define LInsPrev(lp)      linselm (lp, LSTPREV)
#define LInsCurr(lp)      linselm (lp, LSTCURR)
#define LInsFirst(lp)     linselm (lp, LSTFIRST)
#define LInsLast(lp)      linselm (lp, LSTLAST)
#define LInsEqual(lp)     linselm (lp, LSTEQUAL)
#define LInsNotEqual(lp)  linselm (lp, LSTNOTEQUAL)
#define LInsGreater(lp)   linselm (lp, LSTGREATER)
#define LInsLess(lp)      linselm (lp, LSTLESS)
#define LInsEGreater(lp)  linselm (lp, LSTGREATER | LSTEQUEAL)
#define LInsELess(lp)     linselm (lp, LSTLESS | LSTEQUAL)
#define LInsRecno(lp)     linselm (lp, LSTRECNO)

#define LDelNext(lp)      ldelelm (lp, LSTNEXT)
#define LDelPrev(lp)      ldelelm (lp, LSTPREV)
#define LDelCurr(lp)      ldelelm (lp, LSTCURR)
#define LDelFirst(lp)     ldelelm (lp, LSTFIRST)
#define LDelLast(lp)      ldelelm (lp, LSTLAST)
#define LDelEqual(lp)     ldelelm (lp, LSTEQUAL)
#define LDelNotEqual(lp)  ldelelm (lp, LSTNOTEQUAL)
#define LDelGreater(lp)   ldelelm (lp, LSTGREATER)
#define LDelLess(lp)      ldelelm (lp, LSTLESS)
#define LDelEGreater(lp)  ldelelm (lp, LSTGREATER | LSTEQUEAL)
#define LDelELess(lp)     ldelelm (lp, LSTLESS | LSTEQUAL)
#define LDelRecno(lp)     ldelelm (lp, LSTRECNO)

#define LPrtList(lp)   (lprtlst (lp,(LSTTITLE|LSTNUM),stdout),0,lp->lst_buflen)

#if GEMDOS & LASERC
#define free(s)            /* bei free() stuerzt LaserC ab */
#endif GEMDOS & LASERC
