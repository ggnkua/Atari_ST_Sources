#ifndef _INITFONT

# define _INITFONT

typedef struct
{
   int  chw,
        chh,
        zw,
        zh,
        point;
} SIZESTRCT;

typedef struct
{
   int        id,
              sizes;
   char       name[34];
   SIZESTRCT  *size;
} FONTSTRCT;

FONTSTRCT *InitFonts( int v_handle, int *fonts );

int QPropFont( int v_handle, int id );

int SetSysFont( int v_handle,
                int *ch_width,
                int *ch_height,
                int *cell_width,
                int *cell_height );

#endif
