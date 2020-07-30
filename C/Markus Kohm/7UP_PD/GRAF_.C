/* Ersatzfunktion. Macht die Maus nicht um jeden Preis sichtbar. */
#include <portab.h>
#include <stdio.h>
#include <aes.h>

static AESPB aespb=
{
   _GemParBlk.contrl,
   _GemParBlk.global,
   _GemParBlk.intin,
   _GemParBlk.intout,
   _GemParBlk.addrin,
   _GemParBlk.addrout
};

static int mhidden=0;

int graf_mouse( int gr_monumber, MFORM *gr_mofaddr )
{
   _GemParBlk.intin [0] = gr_monumber;
   _GemParBlk.addrin[0] = gr_mofaddr;
   _GemParBlk.contrl[0] = 78;   
   _GemParBlk.contrl[1] = 1;   
   _GemParBlk.contrl[2] = 1;   
   _GemParBlk.contrl[3] = 1;   

   switch(gr_monumber)
   {
      case M_ON:
         if(mhidden==1)
         {
            _GemParBlk.intin [0] = M_ON;
            _crystal(&aespb);
            mhidden=0;
         }
         break;
      case M_OFF:
         if(mhidden==0)
         {
            _crystal(&aespb);
            return(mhidden=1);
         }
         else
            return(!mhidden);
         break;
      default:
         _crystal(&aespb);
         break;
   }
   return(_GemParBlk.intout[0]);
}
