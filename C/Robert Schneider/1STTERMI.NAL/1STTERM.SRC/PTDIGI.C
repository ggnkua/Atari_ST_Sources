overlay "digitals"

#include <osbind.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

set_number(nr)
{
   int hun, zehn, ein;

   hun=nr/100;
   zehn=(nr-(hun*100))/10;
   ein=nr-(hun*100)-(zehn*10);

   if(hun!=old_hun)
      set_all(hun,&old_hun,14);

   if(zehn!=old_zehn)
      set_all(zehn,&old_zehn,7);

   if(ein!=old_ein)
      set_all(ein,&old_ein,0);

   old_hun=hun;
   old_zehn=zehn;
   old_ein=ein;
}

set_all(nr,oldnr,b)
int nr,*oldnr,b;
{
   int a;
   unsigned on,off;

   asm
   {
      LEA      digi(A4), A0
      MOVEA.L  oldnr(A6), A1
      MOVE.W   (A1),D0
      ASL.W    #1, D0
      MOVE.W   0(A0,D0.W), D0       ; DIGI[OLD_EIN] -> D0
      MOVE.W   D0, -(A7)            ; AUF'N STACK

      MOVE.W   nr(A6), D1
      ASL.W    #1, D1
      MOVE.W   0(A0,D1.W), D1       ; DIGI[EIN] -> D1
      MOVE.W   D1, -(A7)            ; AUF'N STACK

      OR.W     D0, D1               ; D1 = D1 | D0
      EOR.W    D0, D1               ; D1 = D1 ^ D0
      MOVE.W   D1, on(A6)           ; D1 -> ON

      MOVE.W   (A7)+, D1            ; DIGI[EIN] -> D1
      MOVE.W   (A7)+, D0            ; DIGI[OLD_EIN] -> D0

      OR.W     D1, D0               ; D0 = D0 | D1
      EOR.W    D1, D0               ; D0 = D0 ^ D1
      MOVE.W   D0, off(A6)          ; BITFIELD DER ZU DESELEKTIERENDEN OBJ.
   }

   for(a=1;a<128;a<<=1,b++)
   {
      if(on&a)
      {
         *digi_flag[b]=0;
         objc_update(proto_di,digi_index[b],1);
      }
      if(off&a)
      {
         *digi_flag[b]=1;
         objc_update(proto_di,digi_index[b],1);
      }
   }
   *oldnr=nr;
}

reset_digis()
{
   int a;

   for(a=0;a<21;a++)
   {
      *digi_flag[a]=0;
   }

   *digi_flag[6]=1;
   *digi_flag[13]=1;
   *digi_flag[20]=1;

   for(a=0;a<21;a++)
      objc_update(proto_di,digi_index[a],0);

   old_ein=0;
   old_zehn=0;
   old_hun=0;
}
