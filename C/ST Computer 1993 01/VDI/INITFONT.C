/***********************************************/
/* Modul  : INITFONT                           */
/* Aufgabe: Fonts initialisieren               */
/***********************************************/

#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>

#include "utility.h"
#include "initfont.h"

/***********************************************/
/* Laden und initialisieren der Fonts          */
/***********************************************/
FONTSTRCT *InitFonts( int v_handle,
                      int *fonts )
{
   char       lname[33],
              name[17],
              desc[17];
   int        i, j, k,
              id,
              fontanz,
              size,
              osize,
              sizes,
              work_out[57],
              _void;
   long       memsize;
   long       tsizeanz;
   SIZESTRCT  *s;
   FONTSTRCT  *f;

   tsizeanz = 0;

   /* Anzahl der Fonts ermitteln */
  vq_extnd( v_handle, 0, work_out );

  if ( vq_gdos() == 0 )
      fontanz = work_out[10];
  else
      fontanz = work_out[10]
                + vst_load_fonts( v_handle, 0 );

   /* Anzahl der Fonts ermitteln, die nicht
      'dummy font' heižen und kein
      Proportionalfont sind */
   *fonts = 0;

   for( i = 0; i < fontanz; i++ )
   {
      id = vqt_name( v_handle, i+1, lname );

      if( strcmp( lname, "dummy font" ) )
         if( !QPropFont( v_handle, id ) )
         {
            /* Anzahl der m”glichen Gr”žen
               ermitteln */
            vst_font( v_handle, id );
            size = 32767;

            do
            {
               osize = size;
               size  =
                   vst_point( v_handle, size - 1,
                              &_void, &_void,
                              &_void, &_void );
               ++tsizeanz;
            }
            while( size != osize );
            --tsizeanz;

            ++(*fonts);
         }
   }

   if( *fonts <= 0 )
      return( 0L );

   /* Speicher reservieren */
   memsize  = (long)sizeof( FONTSTRCT )
              * ((long)(*fonts));
   memsize += (long)sizeof( SIZESTRCT )
              * tsizeanz;
   f = (FONTSTRCT*)Mxalloc( memsize, 3 );
   if( !(f) )
      return( 0L );

   /* Font-ID, -namen und -gr”žen ermitteln */
   s = (SIZESTRCT*)( (long)sizeof( FONTSTRCT )
                     * ((long)(*fonts))
                     + (long)f );
   j  = 0;

   for( i = 0; i < fontanz; i++ )
   {
      /* ID und Namen holen */
      id = vqt_name( v_handle, i + 1, lname );

      if( strcmp( lname, "dummy font" ) )
         if( !QPropFont( v_handle, id ) )
         {
            /* Den Namen konstruieren */
            memmove( name, lname, 16L );
            name[16] = 0;
            memmove( desc, &lname[16], 16L );
            desc[16] = 0;
   
            DeleteSpace( name );
            DeleteSpace( desc );
   
   
            /* Fontgr”žen ermitteln */
            vst_font( v_handle, id );
            size  = 32767;
            sizes = 0;

            do
            {
               osize = size;
               size  =
                   vst_point( v_handle, size - 1,
                              &s[sizes].chw,
                              &s[sizes].chh,
                              &s[sizes].zw,
                              &s[sizes].zh );

               s[sizes].point = size;
               ++sizes;
            }
            while( size != osize );
            --sizes;

            /* Gr”žen tauschen */
            for( k = 0; k < sizes/2; k++ )
            {
               Swap( &s[k].chw,
                     &s[sizes - k - 1].chw );
               Swap( &s[k].chh,
                     &s[sizes - k - 1].chh );
               Swap( &s[k].zw,
                     &s[sizes - k - 1].zw );
               Swap( &s[k].zh,
                     &s[sizes - k - 1].zh );
               Swap( &s[k].point,
                     &s[sizes - k - 1].point );
            }

            /* Werte in die Struktur bertragen */
            sprintf( f[j].name, "%s %s",
                     name, desc );
            f[j].id    = id;
            f[j].size  = s;
            f[j].sizes = sizes;

            /* Lokale Variablen aktualisieren */
            ++j;
            s = (SIZESTRCT*)
                ( (long)s
                  + (long)sizeof( SIZESTRCT )
                  * (long)sizes );
         }
   }

   return( f );
}

/***********************************************/
/* Font auf Proportionalit„t prfen            */
/***********************************************/
int QPropFont( int v_handle, int id )
{
   char  string[2];
   int   i,
         minADE,
         maxADE,
         extent1[8],
         extent2[8],
         _void[5];

   string[1] = 0;

   if( id == -1 )
      return( 0 );

   vst_font( v_handle, id );

   /* Erstes und letztes
      ASCII-Zeichen ermitteln */
   vqt_fontinfo( v_handle, &minADE, &maxADE,
                 _void, &_void[0], _void );
   minADE = ( (minADE < 1) ? 1 : minADE );

   for( i = minADE; i < maxADE-1; i++ )
   {
      /* Ausmaž des ersten Strings ermitteln */
      string[0] = i;
      vqt_extent( v_handle, string, extent1 );

      /* Ausmaž des zweiten Strings ermitteln */
      string[0] = i+1;
      vqt_extent( v_handle, string, extent2 );

      /* Ausmaže vergleichen */
      if( memcmp( extent1, extent2, 16L ) )
         break;
   }

   return( (i==maxADE-1) ? 0 : 1 );
}

/***********************************************/
/* Den Systemfont setzen                       */
/***********************************************/
int SetSysFont( int v_handle,
                int *ch_width,
                int *ch_height,
                int *cell_width,
                int *cell_height )
{
   int  size = 0,
        cboxw,
        cboxh,
        chwidth,
        chheight,
        cellwidth,
        cellheight,
        dummy;

   /* Systemfont setzen */
   vst_font( v_handle, 1 );

   /* Standardzellenbreite und -h”he ermitteln */
   graf_handle( &cboxw, &cboxh, &dummy, &dummy );

   /* ann„hern */
   do
   {
      ++size;
      vst_point( v_handle, size,
                 &dummy, &dummy,
                 &cellwidth, &cellheight );
   }
   while( cellheight <= cboxh &&
          cellwidth <= cboxw );

   /* setzen */
   size = vst_point( v_handle, --size,
                     &chwidth, &chheight,
                     &cellwidth, &cellheight );

   /* Parameter zurckliefern? */
   if( ch_width )
      *ch_width = chwidth;
   if( ch_height )
      *ch_height = chheight;
   if( cell_width )
      *cell_width = cellwidth;
   if( cell_height )
      *cell_height = cellheight;

   return( size );
}
