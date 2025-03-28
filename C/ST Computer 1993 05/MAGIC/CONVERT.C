/*******************************************/
/* Sprache : PureC                         */
/*   Modul : CONVERT.C                     */
/* Aufgabe : Konvertieralgorithmus fÅr     */
/*           farbige Bilder ins monochrome */
/*           Format.                       */
/*           (c) 1992 MAXON Computer       */
/*******************************************/


# include <portab.h>


/*******************************************/
/*   Aufgabe : Konvertieren                */
/* Parameter : width, height : Breite und  */
/*             Hîhe des Bildes in Pixeln   */
/*******************************************/
VOID ConvertPic( WORD width, WORD height )
{
   WORD  color,
         x, y;
   UWORD bit_list[16] = { 1,    2,    4,     8,
                          16,   32,   64,    128,
                          256,  512,  1024,  2048,
                          4096, 8192, 16384,
                          (UWORD)32768L };


   for( x=0; x<width; x++ )
      for( y=0; y<height; y++ )
      {
         /* Farbwert des Quellpixels
            ermitteln (0..255) */
         color = GetSourceColor( x, y );



         /* Pixel setzen oder nicht ?? */
         if( grid[color].word[y % 16] &
             bit_list[x % 16] )
            SetDestPoint( x, y );
         else
            ClearDestPoint( x, y );
      }
}
