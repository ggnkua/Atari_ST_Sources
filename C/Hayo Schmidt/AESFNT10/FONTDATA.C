      /************************************************************/
      /* ERMITTLUNG DER NOTWENDIGEN FONTDATEN FöR GEM-ANWENDUNGEN */
      /************************************************************/
/*                                                Hayo Schmidt 1/93

Neben der exakten Ermittlung der Daten Åber entsprechende Funktion des AES
bzw. die Cookie-Funktion von AESFONT wird eine heuristische Ermittlungs-
methode verwendet.

Die zugrundeliegenden Annahmen fÅr die heuristische Methode sind:
- die Fonts des AES stehen auch fÅr die eigene virt. Workstation zur VerfÅgung
- die Fonts sind sinnvoll designt, d.h. der nÑchstgrîûere Font kann nicht auf
  die Boxgrîûe des aktuellen AES-Fonts verkleinert werden (casus knacksus)
- die RÅckgabewerte von graf_handle() sind das, was alle vermuten

Dieser Code darf frei verwendet werden. Die Teile, die ohne Besitz der
aktuellen MultiTOS-Entwickerunterlagen nicht verstanden werden, sind
'subject to change', kînnen sich also noch Ñndern.
Da ohne diese Teile keine allgemeingÅltige Abfrage zu demonstrieren ist,
sind diese Funktionsaufrufe dennoch eingebaut. Dieser Code wird stÑndig
aktualisiert.
*/

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <fontdata.h>

/* Bei Verwendung des Moduls in eigenen Programmen auskommentieren */
#define DASISNTEST  

#ifndef DASISNTEST

/* Globale Variablen (aus dem Hauptmodul) */
/* -----------------                      */

extern int phys_handle, gl_hhchar, gl_hwchar;
extern int work_out[];
#else

#include <stdio.h>
#include <getcookie.c>

/* Globale Variablen */
/* ----------------- */

int phys_handle, gl_apid, handle;
int gl_hwchar, gl_hhchar, gl_wbox, gl_hbox;
int addfnt;
int work_in[12],
    work_out[57];

/* Globale Strukturen */
/* ------------------ */

FONT_ATTR defsys;
FONT_ATTR ibm;
FONT_ATTR small;

int main()
{
   register int i;
  
   if (( gl_apid = appl_init() ) != -1 )
   {
      /* Virtuelle Workstation îffnen */
      for ( i = 1; i < 10; work_in[i++] = 1 )
         ;
      work_in[10] = 2;
      work_in[0]  = Getrez() + 2;
      handle =
      phys_handle = graf_handle( &gl_hwchar, &gl_hhchar, &gl_wbox, &gl_hbox);
      v_opnvwk( work_in, &handle, work_out );
     
      /* Font-Daten ermitteln und ausgeben */
      if (get_fontinfo(handle, &defsys, &ibm, &small, &addfnt))
      {
         printf("               Face ID   Grîûe               FSM\r\n");
         printf("Default Font: %3i      %3i  %3i  %3i  %3i\r\n",
                        defsys.fontid, defsys.chwdt,defsys.chhgt,
                        defsys.clwdt,defsys.clhgt);
         printf("IBM:          %3i      %3i  %3i  %3i  %3i  %3i\r\n",
                        ibm.fontid, ibm.chwdt, ibm.chhgt, ibm.clwdt,
                        ibm.clhgt, ibm.fsm);   
         printf("SMALL:        %3i      %3i  %3i  %3i  %3i  %3i\r\n",
                small.fontid, small.chwdt, small.chhgt, small.clwdt,
                small.clhgt,small.fsm);
      }
      else
         printf("Fehler bei get_fontinfo\r\n");
        
      /* Entladen der Fonts nicht vergessen! */
      if (addfnt)
         vst_unload_fonts(handle, 0);
      v_clsvwk(handle);
      appl_exit();
   }
   return (0);
}

#endif   /*------------------------------------------------------*/

int get_fontinfo(int handle,  FONT_ATTR *Defsys, FONT_ATTR *Ibm,
                              FONT_ATTR *Small, int *Addfnt)
{
   long  back;
   int   gi_return = 1; /* RÅckgabecode */
   int   xx_return, d;
   int   buggy = 0;     /* wg. MTOS 8.3 Font-ID Bug */
   int   attrib[10];
   register int i;
   int (*xxxx_getinfo)(int af_gtype, int *af_gout1, int *af_gout2,
                                     int *af_gout3, int *af_gout4);
  
   xxxx_getinfo = (_GemParBlk.global[0] < 0x0400) ? afnt_getinfo
                                                  : appl_getinfo;
   /* Default Font */
   vqt_attributes(handle, attrib);          
   Defsys->fontid = attrib[0];
   Defsys->chwdt  = attrib[6];
   Defsys->chhgt  = attrib[7];
   Defsys->clwdt  = attrib[8];
   Defsys->clhgt  = attrib[9];
  
   /* AES IBM font */
   /* ============ */
   if ((xx_return =
             xxxx_getinfo( 0, &Ibm->chhgt, &Ibm->fontid, &Ibm->fsm, &d)) == 0
             || (buggy = (Ibm->fontid == 1)) == TRUE) /* wg. MTOS 8.3 Bug         */
   {                                                  /* ist Font-ID 1 fragwÅrdig */
      vqt_attributes(phys_handle, attrib);
      Ibm->fontid = attrib[0];
   }
   /* font id einstellen */
   if ((vst_font(handle, Ibm->fontid)) != Ibm->fontid)
   {
      *Addfnt = vst_load_fonts(handle, 0);
      if ((vst_font(handle, Ibm->fontid)) != Ibm->fontid)
      {  /* dann ist irgendetwas ist falsch gelaufen */
         if (*Addfnt)
         {
            vst_unload_fonts(handle, 0);
            *Addfnt = 0;
         } 
         Ibm->fontid = Defsys->fontid;
         Ibm->chhgt = Defsys->chhgt;
         gi_return = xx_return = 0;
      }
   }
  
   if (xx_return == 0)
   {  /* Hîhe ermitteln */
           
      if (getcookie('SMAL', &back) && (back & 0xFFFF0000L))
      {
         /* aus 'SMAL'-Cookie */
         Ibm->chhgt = (int)((back & 0xFFFF0000L) >> 16);
      }
      else
      {  /* aus graf_handle */
         vst_font(handle, Ibm->fontid);
         for(i = gl_hhchar; i > 0; i--)
         { 
            vst_height(handle, i, &Ibm->chwdt, &Ibm->chhgt,
                                  &Ibm->clwdt, &Ibm->clhgt);
            if (Ibm->clwdt == gl_hwchar && Ibm->clhgt == gl_hhchar)
               break;
         }
         if (i == 1) /* nicht gefunden */
         {
            if (*Addfnt)
            {
               vst_unload_fonts(handle, 0);
               *Addfnt = 0;
            } 
            vst_font(handle, Ibm->fontid = Defsys->fontid);
            Ibm->chhgt = Defsys->chhgt;
            gi_return = 0;
         }
      } 
   }
   vst_font(handle, Ibm->fontid);
   vst_height(handle, Ibm->chhgt, &Ibm->chwdt, &Ibm->chhgt,
                                  &Ibm->clwdt, &Ibm->clhgt);
  
   /* AES SMALL font */
   if ((xx_return =
         xxxx_getinfo( 1, &Small->chhgt, &Small->fontid, &Small->fsm, &d)) == 0
                        || (buggy && Small->fontid == 1)) /* wg. MTOS 8.3 Bug */
   {
      Small->fontid = Ibm->fontid;
   }
   else
   {  /* hoffentlich nach der nÑchsten MTOS-Revision kÅrzer */
      if ((vst_font(handle, Small->fontid)) != Small->fontid)
      {
         if (*Addfnt != 0)
         {
            Small->fontid = Ibm->fontid;
            gi_return = xx_return = 0;
         }
         else
         {
            *Addfnt = vst_load_fonts(handle, 0);
            if ((vst_font(handle, Small->fontid)) != Small->fontid)
            {  /* dann ist irgendetwas ist falsch gelaufen */
               if (*Addfnt)
               {
                  vst_unload_fonts(handle, 0);
                  *Addfnt = 0;
               } 
               Small->fontid = Ibm->fontid;
               gi_return = xx_return = 0;
            }
         }
      }
   }
  
   if (xx_return == 0)
   {
      /* Der Standardcookie 'SMAL' wird ggf. aus dem Auto-Ordner gesetzt; */
      /* (Spezifikation in Anleitung zur Dialoglibrary RUBY von M. Nick)  */
      if (getcookie('SMAL', &back) && (back & 0x0000FFFFL))
         Small->chhgt = (int) (back & 0x0000FFFFL);
      else
         /* sonst geringste Zeichenhîhe bei v_opnvwk */
         Small->chhgt = work_out[46];
   }
  
   vst_font(handle, Small->fontid);
   vst_height(handle, Small->chhgt, &Small->chwdt, &Small->chhgt,
                                    &Small->clwdt, &Small->clhgt);
  
   /* Daten zurÅcksetzen */
  
   vst_font(handle, Defsys->fontid);
   vst_height(handle, Defsys->chhgt, &d, &d, &d, &d);
  
   return gi_return;
}

int afnt_getinfo(int af_gtype, int *af_gout1, int *af_gout2,
                               int *af_gout3, int *af_gout4)
{ 
   AFNT *afnt;

   if (getcookie('AFnt',(long *) &afnt) && afnt->af_magic == 'AFnt'
                                        && afnt->version > 0x0004)
      return afnt->getinfo(af_gtype, af_gout1, af_gout2, af_gout3, af_gout4);
   else
      return (0);
}

int appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2,
                               int *ap_gout3, int *ap_gout4)
{
   /*if (_GemParBlk.global[0] < 0x0400)
      return (0); */
  
   AESPB aespb;
  
   aespb.contrl   = _GemParBlk.contrl;
   aespb.global   = _GemParBlk.global;
   aespb.intin    = _GemParBlk.intin;
   aespb.intout   = _GemParBlk.intout;
   aespb.addrin   = (int *) _GemParBlk.addrin;
   aespb.addrout  = (int *) _GemParBlk.addrout;
  
   _GemParBlk.contrl[0] = 130;
   _GemParBlk.contrl[1] = 1;
   _GemParBlk.contrl[2] = 5;
   _GemParBlk.contrl[3] = 0;
   _GemParBlk.contrl[4] = 0;
   _GemParBlk.intin[0] = ap_gtype;
   _crystal(&aespb);
   *ap_gout1 = _GemParBlk.intout[1];
   *ap_gout2 = _GemParBlk.intout[2];
   *ap_gout3 = _GemParBlk.intout[3];
   *ap_gout4 = _GemParBlk.intout[4];
   return (_GemParBlk.intout[0]);        
}
