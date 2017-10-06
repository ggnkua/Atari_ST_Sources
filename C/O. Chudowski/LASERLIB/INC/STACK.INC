/**************************************************************************/
/*                                                                        */
/*  NAME:         stack.inc                                               */
/*                                                                        */
/*  DATUM:        14.06.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Include-Datei fuer stack.c.                             */
/*                                                                        */
/**************************************************************************/

#ifndef STACKINC

#define STACKINC
#include <portab.h>

struct _ste
{
   WORD         ste_type;   /* Typ des Elementes                          */
   BYTE        *ste_buf;    /* Zeiger auf Inhalt des Elementes            */
   struct _ste *ste_prev;   /* Zeiger auf Vorgaenger-Element              */
};
typedef struct _ste  STE;

struct _stk
{
   BYTE  *stk_name;         /* Name des Stacks                            */
   STE   *stk_top;          /* Zeiger auf oberstes Stack-Element          */
   WORD   stk_flag;         /* Attribut-Flag des Stacks                   */
   WORD   stk_mdepth;       /* max. Tiefe des Stacks                      */
   WORD   stk_cdepth;       /* akt. Tiefe des Stacks                      */
};
typedef struct _stk  STK;

#define STKNULP     ((STK *) 0L)
#define STENULP     ((STE *) 0L)

#define STKNORMAL   0
#define STKVARDEPTH 1

#define STKEMPTY    0

#define STKBYTE     1       /* char                                       */
#define STKBOOL     2       /* short int                                  */
#define STKWORD     3       /* short int                                  */
#define STKUWORD    4       /* unsigned short int                         */
#define STKLONG     5       /* long int                                   */
#define STKULONG    6       /* unsigned long int                          */
#define STKFLOAT    7       /* float                                      */
#define STKDOUBLE   8       /* long float                                 */
#define STKSTRING   9       /* char *                                     */
#define STKPOINTER 10       /* char * oder int * oder ...                 */

extern STK  *stacknew();
extern VOID  stackdel();
extern VOID  stackshow();
extern BOOL  stackpush();
extern BOOL  stackpop();
extern BOOL  stacktop();

#define StackNew()       (stacknew ("", STKVARDEPTH, 0))
#define PushBYTE(s,c)    (stackpush (s, STKBYTE, c))
#define PushWORD(s,c)    (stackpush (s, STKWORD, c))
#define PushUWORD(s,c)   (stackpush (s, STKUWORD, c))
#define PushBOOL(s,c)    (stackpush (s, STKBOOL, c))
#define PushLONG(s,c)    (stackpush (s, STKLONG, c))
#define PushULONG(s,c)   (stackpush (s, STKULONG, c))
#define PushFLOAT(s,c)   (stackpush (s, STKFLOAT, c))
#define PushDOUBLE(s,c)  (stackpush (s, STKDOUBLE, c))
#define PushSTRING(s,c)  (stackpush (s, STKSTRING, c))
#define PushPOINTER(s,c) (stackpush (s, STKPOINTER, c))

#define stackempty(s)    (s->stk_cdepth == 0)
#define stackdepth(s)    (s->stk_cdepth)
#define stackname(s)     (s->stk_name)
#define stacktype(s)     (stackempty(s) ? STKEMPTY : s->stk_top->ste_type)

#endif STACKINC

