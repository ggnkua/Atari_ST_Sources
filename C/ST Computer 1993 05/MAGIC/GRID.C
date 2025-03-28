/*******************************************/
/* Sprache : PureC                         */
/*   Modul : GRID.C                        */
/* Aufgabe : Erzeugen von Rastern          */
/*           (c) 1992 MAXON Computer       */
/*******************************************/

# include <portab.h>
# include <string.h>


/* Rasterdefinition */
typedef struct
{
   UWORD word[16];
} GRID_STRUCT;


/* Punkte */
typedef struct
{
   WORD  g_x,
         g_y;
} GPOINT;



GRID_STRUCT curr_grid = { 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            grid[256];


/*******************************************/
/* Aufgabe : Berechnet 256 verschiedene    */
/*           Raster und legt sie im Feld   */
/*           'grid' ab                     */
/*******************************************/
VOID CalcGridTable( VOID )
{
   GPOINT start_pos[16] = { { 1, 1 }, { 3, 3 },
                            { 3, 1 }, { 1, 3 },
                            { 2, 2 }, { 4, 4 },
                            { 4, 2 }, { 2, 4 },
                            { 2, 1 }, { 4, 3 },
                            { 4, 1 }, { 2, 3 },
                            { 1, 2 }, { 3, 4 },
                            { 3, 2 }, { 1, 4 } };
   UWORD bit_list[16] = { 1,    2,    4,     8,
                          16,   32,   64,    128,
                          256,  512,  1024,  2048,
                          4096, 8192, 16384,
                          (UWORD)32768L };
   WORD i, j,
        x, y,
        grid_index = 0;




   for( i=0; i<=15; i++ )
      for( j=0; j<=15; j++ )
      {
         x = (start_pos[j].g_x - 1) * 4
             + start_pos[i].g_x;
         y = (start_pos[j].g_y - 1) * 4
             + start_pos[i].g_y;


         /* Das 0.Raster */
         if( !i && !j )
            memcpy( &grid[grid_index++],
             &curr_grid, sizeof( GRID_STRUCT ) );


         curr_grid.word[y - 1] |= bit_list[x - 1];



         /* Das n.Raster */
         if( i || j )
            memcpy( &grid[grid_index++],
             &curr_grid, sizeof( GRID_STRUCT ) );
      }
}
