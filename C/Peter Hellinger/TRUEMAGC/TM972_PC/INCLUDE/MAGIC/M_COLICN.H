/*
   Farb-Icons (M_COLICN.H)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPCOLICN_
#define _MPCOLICN_

/* fÅr Farbicons wichtige Strukturen */
typedef struct cicon_data {
   int   num_planes;   /* number of planes in the following data */
   int   *col_data;    /* pointer to color bitmap in standard form */
   int   *col_mask;    /* pointer to single plane mask of col_data */
   int   *sel_data;    /* pointer to color bitmap of selected icon */
   int   *sel_mask;    /* pointer to single plane mask of selected icon */
   struct cicon_data *next_res;  /* pointer to next icon for a different resolution */
} CICON;

typedef struct cicon_blk {
   ICONBLK monoblk;    /* default monochrome icon */
   CICON   *mainlist;  /* list of color icons for different resolutions */
} CICONBLK;

#endif