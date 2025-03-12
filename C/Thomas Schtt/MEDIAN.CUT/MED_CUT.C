/*  MED_CUT.C
    Farbanpassung mit Median-Cut-Algorithmus

    Pure C 1.1
    by Thomas SchÅtt  (c) MAXON Computer 1993 */

/* Includes */

#include <portab.h>
#include <vdi.h>
#include <aes.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Defines */

#define BOOLEAN int
#define REG     register
#define TRUE    1
#define FALSE   0
#define ERROR   3
#define max(a, b)   ((a) > (b) ? (a) : (b))
#define min(a, b)   ((a) < (b) ? (a) : (b))
#define MAX_WIDTH   256
#define MAX_HEIGHT  256

/* Flags fÅr median_cut */

#define SET_COLORS  1
#define SET_HIST    2

/* Prototypen */

LONG get_entry (WORD red, WORD green, WORD blue);
VOID vdi_pal_inf (WORD vdi_handle, WORD color,
                  WORD rgb_inf[]);
VOID get_rgbbits (WORD rgb_bits[],
                  WORD rgb_inf[]);
VOID rgb_hist (LONG hist[], UBYTE *pic, WORD w,
               WORD h, WORD pal_inf[]);
VOID cut_hist (LONG hist[], WORD rgb_blk[]);
VOID med_hist (LONG hist[], WORD axis,
               WORD rgb_blk1[], WORD rgb_blk2[]);
VOID make_colors (WORD col_tbl[], WORD colors,
                  LONG hist[], WORD basis,
                  WORD rgb_blk[],
                  WORD pal_inf[]);
BOOLEAN set_colors (WORD vdi_handle,
                    WORD fnd_colors,
                    WORD vdi_colors, WORD flag,
                    WORD col_tbl[],
                    WORD rgb_blk[], LONG hist[]);
VOID set_hist (WORD color, WORD rgb_blk[],
               LONG hist[]);
WORD median_cut (WORD vdi_handle, WORD col_tbl[],
                 WORD colors, LONG hist[],
                 WORD flag, WORD basis,
                 WORD pal_inf[]);
VOID display (WORD width, WORD height,
              UBYTE *pic, LONG hist[],
              WORD pal_inf[]);
VOID verlauf (WORD width, WORD height,
              UBYTE *pic);

/* Globale Variablen */

WORD handle;
WORD work_in[103], work_out[57];
WORD rgb_bits[3];

/* Das Programm */

main ()
{
  UBYTE *pic;
  WORD i, d, width, height;
  WORD pal_inf[3], *col_tbl;
  LONG *hist, size;

  appl_init ();
  handle = graf_handle (&d, &d, &d, &d);
  for (i=0; i<103; i++)
    work_in[i] = 1;
  work_in[10] = 2;
  v_opnvwk (work_in, &handle, work_out);
  if (work_out[13] == 0 || work_out[39] == 0)
  {
    (VOID) form_alert (1,
    "[3][Es wird keine Farbpalette unterstÅtzt.]"
    "[ Abbruch ]");
    return (0);
  }/* if */
  if (work_out[13] <= 4)
  {
    (VOID) form_alert (1, "[3][Zu wenig Farben.]"
                          "[ Abbruch ]");
    return (0);
  }/* if */
  v_hide_c (handle);
  v_clrwk (handle);
  width = min (work_out[0] + 1, MAX_WIDTH);
  height = min (work_out[1] + 1, MAX_HEIGHT);
  if ((pic = (UBYTE *) malloc (width * height
      * 3L)) == NULL)
    return (ERROR);
  vdi_pal_inf (handle, work_out[13] - 1,
               pal_inf);
  get_rgbbits (rgb_bits, pal_inf);
  size = (pal_inf[0] + 1) * (pal_inf[1] + 1)
         * (pal_inf[2] + 1);
  if ((hist = (LONG *) calloc (size,
       sizeof (LONG))) == NULL)
    return (ERROR);
  while (size > 0)
    hist[--size] = 0L;
  if ((col_tbl = (WORD *) calloc (work_out[13]
                  * 3L, sizeof (WORD))) == NULL)
    return (ERROR);
  puts ("Generating picture...");
  verlauf (width, height, pic);
  puts ("Making histogram...");
  rgb_hist (hist, pic, width, height, pal_inf);
  puts ("Median-Cut...");
  if (median_cut (handle, col_tbl, work_out[13],
                  hist, SET_HIST, 1000,
                  pal_inf))
  {
    display (width, height, pic, hist, pal_inf);
  }/* if */
  free (pic);
  free (hist);
  free (col_tbl);
  evnt_keybd ();
  v_clsvwk (handle);
  appl_exit ();
  return (0);
}/* main */

/* Berechnung Histogrammposition */

LONG get_entry (WORD red, WORD green, WORD blue)
{
  LONG entry;
  entry = red;
  entry <<= rgb_bits[1];
  entry += green;
  entry <<= rgb_bits[2];
  entry += blue;
  return (entry);
}/* get_entry */

/* Abstufung der VDI-Farbpalette erfragen */

VOID vdi_pal_inf (WORD vdi_handle, WORD color,
                  WORD rgb_inf[])
{
  WORD i, rgb_in[3], rgb_out[3], old[3];
  (VOID) vq_color (vdi_handle, color, 0, old);
  for (i=0; i<3; i++)
  {
    rgb_in[i] = 1000;
    rgb_inf[i] = 0;
  }/* for */
  for (i=0; i<3; i++)
  {
    while (rgb_in[i] > 0)
    {
      vs_color (vdi_handle, color, rgb_in);
      (VOID) vq_color (vdi_handle, color, 1,
                       rgb_out);
      while (rgb_out[i] >= rgb_in[i])
      {
        rgb_in[i] --;
        vs_color (vdi_handle, color, rgb_in);
        (VOID) vq_color (vdi_handle, color, 1,
                         rgb_out);
      }/* while */
      rgb_in[i] = rgb_out[i];
      if (rgb_in[i] > 0 || rgb_inf[i] > 0)
        rgb_inf[i] ++;
    }/* while */
  }/* for */
  vs_color (vdi_handle, color, old);
}/* vdi_pal_inf */

/* Bitanzahl pro Farbe ermitteln */

VOID get_rgbbits (WORD rgb_bits[],
                  WORD rgb_inf[])
{
  WORD i, rgb_wrk[3];
  for (i=0; i<3; i++)
  {
    rgb_wrk[i] = rgb_inf[i];
    rgb_bits[i] = 0;
    while (rgb_wrk[i] > 0)
    {
      rgb_bits[i] ++;
      rgb_wrk[i] >>= 1;
    }/* while */
  }/* for */

}/* get_rgbbits */

/* RGB-Histogramm erstellen */

VOID rgb_hist (LONG hist[], UBYTE *pic, WORD w,
               WORD h, WORD pal_inf[])
{
  WORD x, y, i, rgb[3];
  for (y=0; y<h; y++)
    for (x=0; x<w; x++)
    {
      for (i=0; i<3; i++)
      {
        rgb[i] = *pic++;
        rgb[i] = + (rgb[i] * pal_inf[i]) / 255;
      }/* for */
      hist[get_entry(rgb[0],rgb[1],rgb[2])] ++;
  }/* for, for */
}/* rgb_hist */

/* RGB_histogramm 'cutten' */

VOID cut_hist (LONG hist[], WORD rgb_blk[])
{
  WORD i, i1, i2, j[3];
  for (i=0; i<3; i++)
  {
    i1 = (i + 1) % 3;
    i2 = (i + 2) % 3;
    for (j[i] = rgb_blk[i];
         j[i] <= rgb_blk[i+3];
         j[i] ++)
      for (j[i1] = rgb_blk[i1];
           j[i1] <= rgb_blk[i1+3];
           j[i1] ++)
        for (j[i2] = rgb_blk[i2];
             j[i2] <= rgb_blk[i2+3];
             j[i2] ++)
        {
          if (hist[get_entry(j[0],j[1],j[2])]>0L)
            goto label1;
        }/* for, for, for */
    label1:
    rgb_blk[i] = j[i];
  }/* for */

  for (i=0; i<3; i++)
  {
    i1 = (i + 1) % 3;
    i2 = (i + 2) % 3;
    for (j[i] = rgb_blk[i+3];
         j[i] >= rgb_blk[i];
         j[i] --)
      for (j[i1] = rgb_blk[i1+3];
           j[i1] >= rgb_blk[i1];
           j[i1] --)
        for (j[i2] = rgb_blk[i2+3];
             j[i2] >= rgb_blk[i2];
             j[i2] --)
        {
          if (hist[get_entry(j[0],j[1],j[2])]>0L)
            goto label2;
        }/* for, for, for */
    label2:
    rgb_blk[i+3] = j[i];
  }/* for */
}/* cut_hist */

/* Median-Teilung durchfÅhren */

VOID med_hist (LONG hist[], WORD axis,
               WORD rgb_blk1[], WORD rgb_blk2[])
{
  WORD i[3], j, axis1, axis2;
  LONG slice[32], sum = 0L;
  axis1 = (axis + 1) % 3;
  axis2 = (axis + 2) % 3;
  for (j=0; j<6; j++)
    rgb_blk2[j] = rgb_blk1[j];
  for (i[axis] = rgb_blk1[axis];
       i[axis] <= rgb_blk1[axis+3];
       i[axis] ++)
  {
    slice[i[axis]] = 0L;
    for (i[axis1] = rgb_blk1[axis1];
         i[axis1] <= rgb_blk1[axis1+3];
         i[axis1] ++)
      for (i[axis2] = rgb_blk1[axis2];
           i[axis2] <= rgb_blk1[axis2+3];
           i[axis2] ++)
      {
        slice[i[axis]] +=
        hist[get_entry (i[0], i[1], i[2])];
        sum += hist[get_entry(i[0],i[1],i[2])];
      }/* for, for */
  }/* for */

  sum /= 2;
  for (j = rgb_blk1[axis];
       j < rgb_blk1[axis+3];
       j++)
  {
    sum -= slice[j];
    if (sum <= 0L)
      break;
  }/* for */

  if (j == rgb_blk1[axis+3])
    --j;
  rgb_blk1[axis+3] = j;
  rgb_blk2[axis] = j + 1;

}/* med_hist */

VOID make_colors (WORD col_tbl[], WORD colors,
                  LONG hist[], WORD basis,
                  WORD rgb_blk[], WORD pal_inf[])
{
  WORD r, g, b, i, num;
  LONG sum, c_hist, rval, gval, bval;
  for (i=0; i<colors; i++)
  {
    sum = rval = gval = bval = 0L;
    num = i * 6;
    for (r = rgb_blk[num];
         r <= rgb_blk[num+3];
         r++)
      for (g = rgb_blk[num+1];
           g <= rgb_blk[num+4];
           g++)
        for (b = rgb_blk[num+2];
             b <= rgb_blk[num+5];
             b++)
        {
          c_hist = hist [get_entry (r, g, b)];
          rval += (rgb_blk[num] + 1) * c_hist;
          gval += (rgb_blk[num+1] + 1) * c_hist;
          bval += (rgb_blk[num+2] + 1) * c_hist;
          sum += c_hist;
        }/* for, for, for */

    col_tbl[i*3] =  (WORD) ( + (((rval / sum)
                     - 1) * basis) / pal_inf[0]);
    col_tbl[i*3+1] = (WORD) ( + (((gval / sum)
                     - 1) * basis) / pal_inf[1]);
    col_tbl[i*3+2] = (WORD) ( + (((bval / sum)
                     - 1) * basis) / pal_inf[2]);
  }/* for */
}/* make_colors */

/* Setzen der Farben
   (berÅcksichtigt die alte Farbpalette)
*/

BOOLEAN set_colors (WORD vdi_handle,
                    WORD fnd_colors,
                    WORD vdi_colors, WORD flag,
                    WORD col_tbl[], WORD rgb_blk[],
                    LONG hist[])
{
  WORD i, j, *vdi_tbl, *index, col_ind;
  LONG dr, dg, db, d, dmax;
  if ((index = (WORD *) calloc (fnd_colors,
                        sizeof (WORD))) == NULL)
    return (FALSE);
  if ((vdi_tbl = (WORD *) calloc (vdi_colors*3L,
                         sizeof (WORD))) == NULL)
    return (FALSE);
  for (i=0; i<vdi_colors; i++)
    vq_color (vdi_handle, i, 0, &vdi_tbl[i*3]);
  for (i=0; i<fnd_colors; i++)
  {
    dmax = 3000001L;
    for (j=0; j<vdi_colors; j++)
    {
      if (vdi_tbl[j*3] != -1)
      {
        dr = col_tbl[i*3] - vdi_tbl[j*3];
        dg = col_tbl[i*3+1] - vdi_tbl[j*3+1];
        db = col_tbl[i*3+2] - vdi_tbl[j*3+2];
        d = dr * dr + dg * dg + db * db;
        if (d < dmax)
        {
          dmax = d;
          col_ind = j;
        }/* if */
      }/* if */
    }/* for */

    vdi_tbl[col_ind*3] = -1;
    index[i] = col_ind;
    vs_color (vdi_handle, col_ind,
              &col_tbl[i*3]);
    if (flag == SET_HIST)
      set_hist (col_ind, &rgb_blk[i*6], hist);
  }/* for */

  for (i=0; i<vdi_colors; i++)
    for (j=0; j<3; j++)
      vdi_tbl[i*3+j] = -1;
  for (i=0; i<fnd_colors; i++)
    for (j=0; j<3; j++)
      vdi_tbl[index[i]*3+j] = col_tbl[i*3+j];
  for (i=0; i<vdi_colors; i++)
    for (j=0; j<3; j++)
      col_tbl[i*3+j] = vdi_tbl[i*3+j];
  free (vdi_tbl);
  free (index);
  return (TRUE);
}/* set_colors */

/* Farbindizies in Histogramm eintragen */

VOID set_hist (WORD color, WORD rgb_blk[],
               LONG hist[])
{
  WORD r, g, b;
  for (r=rgb_blk[0]; r<=rgb_blk[3]; r++)
    for (g=rgb_blk[1]; g<=rgb_blk[4]; g++)
      for (b=rgb_blk[2]; b<=rgb_blk[5]; b++)
        hist[get_entry (r, g, b)] = color;
}/* set_hist */

/* Median-Cut Funktion */

WORD median_cut (WORD vdi_handle, WORD col_tbl[],
                 WORD colors, LONG hist[],
                 WORD flag, WORD basis,
                 WORD pal_inf[])
{
  WORD i, j, k, d_max, ind_max, *rgb_blk;
  if ((rgb_blk = (WORD *) calloc (colors * 6L,
                        sizeof (WORD))) == NULL)
    return (FALSE);
  rgb_blk[0] = rgb_blk[1] = rgb_blk[2] = 0;
  rgb_blk[3] = pal_inf[0];
  rgb_blk[4] = pal_inf[1];
  rgb_blk[5] = pal_inf[2];
  for (i=0; i<colors-1; i++)
  {
    d_max = 0;
    cut_hist (hist, &rgb_blk[i * 6]);
    for (j=0; j<=i; j++)
      for (k=0; k<3; k++)
        if (d_max < rgb_blk[j * 6 + k + 3]
                    - rgb_blk[j * 6 + k])
        {
          d_max = rgb_blk[j * 6 + k + 3]
                  - rgb_blk[j * 6 + k];
          ind_max = j * 6 + k;
        }/* if, for, for */
    if (d_max == 0)
      return (i + 1);
    k = ind_max % 6;
    ind_max -= k;
    med_hist (hist, k, &rgb_blk[ind_max],
              &rgb_blk[i * 6 + 6]);
    cut_hist (hist, &rgb_blk[ind_max]);
  }/* for */

  make_colors (col_tbl, i+1, hist, basis,
               rgb_blk, pal_inf);
  if (flag == SET_COLORS || flag == SET_HIST)
    if (! set_colors (vdi_handle, i+1, colors,
                      flag, col_tbl, rgb_blk,
                      hist))
      i = -1;
  free (rgb_blk);
  return (i + 1);
}/* median_cut */

/* Bild erzeugen */

VOID verlauf (WORD width, WORD height,
              UBYTE *pic)
{
  WORD x, y, r, g, b;
  for (y=0; y<height; y++)
    for (x=0; x<width; x++)
    {
      r = + (WORD) ((x * 255L) / (width - 1));
      g = + (WORD) (255 - (y * 255L) /
                   (height - 1));
      b = (r + 255 - g) / 2;
      *pic++ = r;
      *pic++ = g;
      *pic++ = b;
    }/* for, for */

}/* verlauf */

/* Bild anzeigen */

VOID display (WORD width, WORD height,
              UBYTE *pic, LONG hist[],
              WORD pal_inf[])
{
  WORD x, y, i, pxy[2], rgb[3];
  for (y=0; y<height; y++)
  {
    pxy[1] = y;
    for (x=0; x<width; x++)
    {
      pxy[0] = x;
      for (i=0; i<3; i++)
        rgb[i] = + (*pic++ * pal_inf[i]) / 255;
      vsm_color (handle, (WORD) hist[get_entry (
                      rgb[0], rgb[1], rgb[2])]);
      v_pmarker (handle, 1, pxy);
    }/* for */
  }/* for */
}/* display */

