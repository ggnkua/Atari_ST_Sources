#include <aes.h>
#include <ext.h>
#include <stdio.h>
#include <vdi.h>

#include "initfont.h"
#include "initvwk.h"
#include "exitfont.h"
#include "exitvwk.h"

static void CheckStry( int v_handle,
                       int zh,
                       int *stry,
                       int *clip,
                       GRECT *work );

int main( void )
{
   char      str[100];
   int       i, j,
             v_handle,
             pw,
             ph,
             sw,
             sh,
             syschw,
             syschh,
             syszw,
             syszh,
             planes,
             fonts,
             handle,
             stry,
             clip[4],
             _void;
   GRECT     def, work;
   FONTSTRCT *f;

   /* Bei den AES anmelden */
   if( appl_init() < 0 )
      return( -1 );

   /* Ein Fenster anlegen */
   wind_get( 0, WF_WORKXYWH, &def.g_x, &def.g_y,
                             &def.g_w, &def.g_h );

   def.g_x += 4;
   def.g_y += 4;
   def.g_w -= 8;
   def.g_h -= 8;

   handle = wind_create( NAME|CLOSER,
                         def.g_x, def.g_y,
                         def.g_w, def.g_h );
   if( handle < 0 )
   {
      appl_exit();
      return( -1 );
   }
   wind_set( handle, WF_NAME, " VDI-Fonts " );

   /* Bildschirmworkstation ”ffnen */
   if( !InitVWork( &v_handle, &pw, &ph, &sw, &sh,
                   0L, 0L, &planes ) )
   {
      appl_exit();
      return( -1 );
   }

   /* Fonts initialisieren */
   f = InitFonts( v_handle, &fonts );
   if( !f )
   {
      ExitVWork( v_handle );
      appl_exit();
      return( -1 );
   }

   /* Fenster ”ffnen */
   if( !wind_open( handle, def.g_x, def.g_y,
                           def.g_w, def.g_h ) )
   {
      ExitFonts( v_handle, f );
      ExitVWork( v_handle );
      appl_exit();
      return( -1 );
   }

   /* Ausgabe */
   wind_calc( WC_WORK, NAME|CLOSER,
              def.g_x, def.g_y, def.g_w, def.g_h,
              &work.g_x, &work.g_y,
              &work.g_w, &work.g_h );

   clip[0] = work.g_x;
   clip[1] = work.g_y;
   clip[2] = work.g_x + work.g_w - 1;
   clip[3] = work.g_y + work.g_h - 1;

   vsf_interior( v_handle, FIS_HOLLOW );
   vswr_mode( v_handle, MD_REPLACE );

   vs_clip( v_handle, 1, clip );
   graf_mouse( M_OFF, 0L );

   /* Die Fontnamen, die ID und alle m”glichen
      Gr”žen ausgeben. Dabei immer den 
      entsprechenden Font und die entspr.
      Gr”že setzen */
   for( i = 0; i < fonts; i++ )
   {
      /* weižer Hintergrund */
      vr_recfl( v_handle, clip );

      stry = work.g_y + f[i].size[0].zh;

      /* Fontnamen und ID ausgeben */
      vst_font( v_handle, f[i].id );
      vst_point( v_handle, f[i].size[0].point,
                 &_void, &_void, &_void, &_void );

      sprintf( str, "Der %d. Font heižt \"%s\"" \
                    " und hat die ID %d.",
                    i+1, f[i].name, f[i].id );
      v_gtext( v_handle, work.g_x, stry, str );

      for( j = 0; j < f[i].sizes; j++ )
      {
         /* Eine Kostprobe des Fonts in der
            Gr”že */
         vst_point( v_handle, f[i].size[j].point,
                    &_void, &_void,
                    &_void, &_void );

         CheckStry( v_handle, f[i].size[j].zh,
                    &stry, clip, &work );
         sprintf( str,
              "So sieht er in %d Point Gr”že aus.",
              f[i].size[j].point );
         v_gtext( v_handle, work.g_x + 10,
                  stry, str );

         /* Die Ausmaže von Zeichen und Zelle
            ausgeben */
         CheckStry( v_handle, f[i].size[j].zh,
                    &stry, clip, &work );
         sprintf( str, "Zeichenbreite: %d",
                  f[i].size[j].chw );
         v_gtext( v_handle, work.g_x + 20,
                  stry, str );

         CheckStry( v_handle, f[i].size[j].zh,
                    &stry, clip, &work );
         sprintf( str, "Zeichenh”he  : %d",
                  f[i].size[j].chh );
         v_gtext( v_handle, work.g_x + 20,
                  stry, str );

         CheckStry( v_handle, f[i].size[j].zh,
                    &stry, clip, &work );
         sprintf( str, "Zellenbreite : %d",
                  f[i].size[j].zw );
         v_gtext( v_handle, work.g_x + 20,
                  stry, str );

         CheckStry( v_handle, f[i].size[j].zh,
                    &stry, clip, &work );
         sprintf( str, "Zellenh”he   : %d",
                  f[i].size[j].zh );
         v_gtext( v_handle, work.g_x + 20,
                  stry, str );
      }

      getch();
   }

   /* Noch etwas ber den Systemfont */
   vr_recfl( v_handle, clip );
   SetSysFont( v_handle, &syschw, &syschh,
                         &syszw, &syszh );
   stry = work.g_y + syszh;

   sprintf( str, "Das ist der Systemfont." );
   v_gtext( v_handle, work.g_x, stry, str );

   CheckStry( v_handle, syszh,
              &stry, clip, &work );
   sprintf( str, "Zeichenbreite: %d   " \
                 "Zeichenh”he: %d",
            syschw, syschh );
   v_gtext( v_handle, work.g_x, stry, str );

   CheckStry( v_handle, syszh,
              &stry, clip, &work );
   sprintf( str, "Zellenbreite: %d   " \
                 "Zellenh”he: %d",
            syszw, syszh );
   v_gtext( v_handle, work.g_x, stry, str );

   /* und noch etwas ber das System */
   CheckStry( v_handle, syszh,
              &stry, clip, &work );
   sprintf( str,
       "Pixelbreite / -h”he in " \
       "tausendstel Millimetern: %d / %d",
       pw, ph );
   v_gtext( v_handle, work.g_x, stry, str );

   CheckStry( v_handle, syszh,
              &stry, clip, &work );
   sprintf( str,
       "Bildschirmbreite / -h”he in Pixeln: " \
       "%d / %d", sw, sh );
   v_gtext( v_handle, work.g_x, stry, str );

   CheckStry( v_handle, syszh,
              &stry, clip, &work );
   sprintf( str,
       "Anzahl der Planes: %d", planes );
   v_gtext( v_handle, work.g_x, stry, str );

   getch();

   /* fertig */
   graf_mouse( M_ON, 0L );
   vs_clip( v_handle, 0, clip );

   /* alles abmelden */
   ExitFonts( v_handle, f );
   ExitVWork( v_handle );
   appl_exit();
   
   return( 0 );
}

void CheckStry( int v_handle,
                int zh,
                int *stry,
                int *clip,
                GRECT *work )
{
   if( *stry >= work->g_y + work->g_h )
   {
      *stry = work->g_y + zh;
      getch();
      vr_recfl( v_handle, clip );
   }
   else
      *stry += zh;
}
