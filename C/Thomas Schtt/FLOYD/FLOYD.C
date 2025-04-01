/*
  FLOYD.C
  Farbreduzierung mit Floyd-Steinberg Algorithmus
  Pure C 1.1
  (c) Maxon Computer GmbH 1993
  Thomas SchÅtt  03.02.1993
*/

/*-- Includes --*/

#include <portab.h>
#include <vdi.h>
#include <aes.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/*-- Defines --*/

#define BOOLEAN int
#define REG     register
#define TRUE    1
#define FALSE   0
#define max(a, b)       ((a) > (b) ? (a) : (b))
#define min(a, b)   ((a) < (b) ? (a) : (b))
#define MAX_COLORS  256
#define MAX_WIDTH       256
#define MAX_HEIGHT  256

/*-- Prototypen --*/

VOID get_colors (WORD colors, UBYTE *rgb_table);
VOID vdi_to_rgb (WORD vdi_rgb[], UBYTE rgb[]);
VOID rgb_to_vdi (UBYTE rgb[], WORD vdi_rgb[]);
VOID verlauf (WORD width, WORD height, UBYTE *pic);
VOID set_pixel (WORD x, WORD y, UBYTE rgb[], WORD rgb_fehler[]);
VOID set_colarray (WORD colors);
BOOLEAN display_fs (WORD width, WORD height, UBYTE *pic);
VOID display_dc (WORD width, WORD height, UBYTE *pic);

/*-- Globale Variablen --*/

UBYTE colarray[32L][32L][32L];
UBYTE coltab[MAX_COLORS * 3];
WORD handle;
WORD work_in[103], work_out[57];

/*-- Das Programm --*/

WORD main ()
{
    UBYTE *pic;
    WORD i, d, width, height;
    appl_init ();
    handle = graf_handle (&d, &d, &d, &d);
    for (i=0; i<103; i++)work_in[i] = 1;
    work_in[10] = 2;
    v_opnvwk (work_in, &handle, work_out);
    width = min (work_out[0] + 1, MAX_WIDTH);
    height = min (work_out[1] + 1, MAX_HEIGHT);
    if ((pic = (UBYTE *)malloc((LONG) width * (LONG) height * 
3L)) != NULL)
    {
        verlauf (width, height, pic);
        v_hide_c (handle);
        v_clrwk (handle);
        /* Falcon DC Modus? */
        if (work_out[13] > 0 && work_out[39] > 0)
        {
            get_colors (work_out[13], coltab);
            set_colarray (work_out[13]);
            display_fs (width, height, pic);
        }/* if */
        else
        {
            display_dc (width, height, pic);
        }/* else */
        free (pic);
        evnt_keybd (); /* auf Taste warten  */
    }/* if */
    v_clsvwk (handle);
    appl_exit ();
    return (0);
}/* main */

/*-- Farben holen und in Array eintragen --*/
VOID get_colors (WORD colors, UBYTE *rgb_table)
{
    WORD i, rgb[3];
    if (work_out[35] == 0)
    {
        *rgb_table++ = 255;
        *rgb_table++ = 255;
        *rgb_table++ = 255;
        *rgb_table++ = 0;
        *rgb_table++ = 0;
        *rgb_table++ = 0;
    }/* if */
    else
    {
        for (i=0; i<colors; i++)
        {
            vq_color (handle, i, 1, rgb);
            vdi_to_rgb (rgb, rgb_table);
            rgb_table = &rgb_table[3];
        }/* for */
    }/* else */
}/* get_colors */

/*-- VDI Farben (0-1000) in 24Bit
           RGB (0-255) umwandeln --*/
VOID vdi_to_rgb (WORD vdi_rgb[], UBYTE rgb[])
{
    WORD i;
    for (i=0; i<3; i++)
        rgb[i] = + (vdi_rgb[i] * 255L) / 1000L;
}/* vdi_to_rgb */


/*-- 24Bit RGB (0-255) in VDI Farben
                  (0-1000) umwandeln --*/

VOID rgb_to_vdi (UBYTE rgb[], WORD vdi_rgb[])
{
    WORD i;
    for (i=0; i<3; i++)
     vdi_rgb[i] = + (WORD)((rgb[i]*1000L)/255L);
}/* rgb_to_vdi */

/*-- Erzeugt einen Farbverlauf kann durch eine
   Laderoutine fÅr RGB-Bilder ersetzt werden  --*/
VOID verlauf (WORD width, WORD height, UBYTE *pic)
{
    WORD x, y, r, g, b;
    for (y=0; y<height; y++)
        for (x=0; x<width; x++)
        {
            r = + (WORD) ((x * 255L) / (width - 1));
            g = + (WORD) (255 - (y * 255L) / (height - 1));
            b = (r + 255 - g) / 2;
            *pic++ = r;
            *pic++ = g;
            *pic++ = b;
        }/* for, for */
}/* verlauf */

/*-- Setzen eines Pixel und Ermittlung
     des Fehlers --*/

VOID set_pixel (WORD x, WORD y, UBYTE rgb[], WORD rgb_fehler[])
{
    WORD color, i, pxy[2];
    color = colarray[(LONG) (rgb[0] >> 3)]
                    [(LONG) (rgb[1] >> 3)]
                    [(LONG) (rgb[2] >> 3)];
    for (i=0; i<3; i++)
      rgb_fehler[i] = rgb[i]-coltab[color*3+i];
    vsm_color (handle, color);
    pxy[0] = x;
    pxy[1] = y;
    v_pmarker (handle, 1, pxy);
}/* set_pixel */

/*-- Belegung des colarrays --*/

VOID set_colarray (WORD colors)
{
    WORD d, dmin, r, rmin, dr, dg, db, red, green, blue;
    for (red=0; red<32; red++)
        for (green=0; green<32; green++)
            for (blue=0; blue<32; blue++)
            {
                dmin = 32767;
                for (r=0; r<colors; r++)
                {
                    dr = red - (coltab[r*3] >> 3);
                    dg = green - (coltab[r*3+1] >> 3);
                    db = blue - (coltab[r*3+2] >> 3);
                    d = dr*dr + dg*dg + db*db;
                    if (d < dmin)
                    {
                        dmin = d;
                        rmin = r;
                    }/* if */
                }/* for */
                colarray[(LONG) red]
                      [(LONG) green]
                      [(LONG) blue] = rmin;
         }/* for, for, for */
}/* set_colarray */

/*-- Darstellung mit Floyd-Steinberg --*/

BOOLEAN display_fs (WORD width, WORD height, UBYTE *pic)
{
    UBYTE *fptr1, *fptr2, *d;
    REG UBYTE *line1, *line2;
    REG WORD fehler, f, i;
    WORD x, y, rgb_fehler[3];
    LONG w;

    w = width * 3L;
    if ((fptr1 = (UBYTE *) malloc (w)) == NULL)
        return (FALSE);
    if ((fptr2 = (UBYTE *) malloc (w)) == NULL)
    {
        free (fptr1);
        return (FALSE);
    }/* if */
    memcpy (fptr1, pic, w);
    for (y=0; y<height-1; y++)
    {
        memcpy (fptr2, pic + (y + 1) * w, w);
        line1 = (fptr1 + 3L);
        line2 = fptr2;
        for (x=0; x<width-1; x++)
        {
            set_pixel (x, y, line1 - 3L, rgb_fehler);
            for (i=0; i<3; i++)
            {
                if ((fehler = rgb_fehler[i]) != 0)
                {
                    /* x 0.25 */
                    f = fehler >> 2;
                    /* x 0.375  */
                    fehler = + (fehler * 96) >> 8;
                    f += *(line2 + 3L);/* x+1,y+1 */
                    if (f < 0) f = 0;
                    else if (f > 255) f = 255;
                    *(line2 + 3L) = f;
                    f = fehler + *line1;/* x+1, y*/
                    if (f < 0) f = 0;
                    else if (f > 255) f = 255;
                    *line1++ = f;
                    f = fehler + *line2; /* x,y+1 */
                    if (f < 0) f = 0;
                    else if (f > 255) f = 255;
                    *line2++ = f;
                }/* if */
                else
                {
                    line1++;
                    line2++;
                }/* else */
            }/* for */
        }/* for */
        set_pixel (x, y, line1 - 3L, rgb_fehler);
        d = fptr1;
        fptr1 = fptr2;
        fptr2 = d;
    }/* for */
    free (fptr1);
    free (fptr2);
    return (TRUE);
}/* display_fs */

/*-- Darstellung im Falcon DC Modus --*/

VOID display_dc (WORD width, WORD height, UBYTE *pic)
{
    WORD x, y, rgb[3], pxy[2];
    vsm_color (handle, 1);
    for (y=0; y<height; y++)
        for (x=0; x<width; x++)
        {
            rgb_to_vdi (pic, rgb);
            pic = &pic[3];
            vs_color (handle, 1, rgb);
            pxy[0] = x;
            pxy[1] = y;
            v_pmarker (handle, 1, pxy);
        }/* for, for */
}/* display_dc */


