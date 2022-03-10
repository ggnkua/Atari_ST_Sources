/**********************************************/
/* FONT.C                                     */
/* Erstellen und verwalten der Fontliste      */
/* 12.01.94 sk                                */
/**********************************************/
#include <stdlib.h>
#include <vdibind.h>
#include <aesbind.h>
#include <e_gem.h>
#include <string.h>
#include <stdio.h>
#include "gprint.h"
#include "gdos.h"

extern int load_fontliste (FONT *fonts, int *anzahl);
extern int open_wkst      (int wk_handle);

extern int oldhandle, cb[];
extern OBJECT *font_tree;

int  get_fonts(int wk_handle);
int  set_font(int wk_handle, int font_id);
void get_speed(int wkh, FONT *fp);

int  oldhandle, anz_font, akt_font, id_akt_font;
/********************************************************/
/* Fonts der Workstation ermitteln und Fontliste        */
/* erstellen.                                           */
/********************************************************/
int get_fonts(int wk_handle)
{
  FONT *fp;
  int i;
  unsigned long memavail;

  if(oldhandle != PF.lh)                       /* Workstation geÑndert ? */
  {
    akt_font = 0;                              /* Fonts neuladen         */
    font_tree[ZHBEL].ob_state &= ~SELECTED;    /* Flag Beliebige Hîhe    */
    if(fontp != NULL)
      free((void *)fontp);
    fontp = NULL;
    afp   = NULL;
  }
  if(akt_font == 0)
  {
    oldhandle = wk_handle;                     /* fÅr's nÑchste mal      */

    if((wk_handle = open_wkst(wk_handle)) != 0)
    {
      int char_width, char_height, cell_width, cell_height;
      char fname[40];

      anz_font = vst_load_fonts(wk_handle, 0) + work_out[10] + 1;

      memavail = (long)malloc((unsigned long)-1) - 20000;
      if(anz_font * sizeof(FONT) < memavail)
      {
        fontp = (FONT *)malloc(anz_font * sizeof(FONT));
        fp  = fontp;
        afp = fontp;
      }

      if(fp != NULL)
      {
        for(i = 1; i <= anz_font; i++, fp++)     /* FÅr alle Fonts         */
        {
          fp->font_id = vqt_name(wk_handle, i, fname);    /* ID & Name     */

          if(fp->font_id != -1 && strcmp(fname, "System") != 0)
          {
            strcpy(fp->font_name, fname);
            if(fname[32] == 0x01)                /* Byte 32 = 1 => Speedo  */
              fp->font_spd = TRUE;
            else
              fp->font_spd = FALSE;

            if(akt_font == 0)
            {
              akt_font = i;
              afp = fp;
            }
            vst_font(wk_handle, fp->font_id);    /* Aktuellen Font setzen  */

            vst_height(wk_handle, 10, &char_width, &char_height,
                       &cell_width, &cell_height);
            get_speed(wk_handle, fp);
          }
          else
          {
            strcpy(fp->font_name, fname);
            fp->font_id   = -1;
            fp->font_prop = FALSE;
            fp->font_spd  = FALSE;
          }
        }
        vst_unload_fonts(wk_handle, 0);
        m_v_clswk(wk_handle);
        return(TRUE);
      }
      else
      {
        form_alert(1, "[3][ GDOS-Print: | Nicht genug Speicher | fÅr Fontliste! ][Abbruch]");
        vst_unload_fonts(wk_handle, 0);
        m_v_clswk(wk_handle);
        return(FALSE);
      }
    }
    return(FALSE);
  }

  return(TRUE);
} /* get_fonts() */

/******************************************************/
/* Beim Start den eingestellten Font eintragen        */
/******************************************************/
int set_font(int wk_handle, int ft_id)
{
  FONT *fp;
  int i;
  unsigned long memavail;

  if(akt_font == 0)
  {
    oldhandle = wk_handle;

    if((wk_handle = open_wkst(wk_handle)) != 0)
    {
      int char_width, char_height, cell_width, cell_height;
      char fname[50];

      anz_font = vst_load_fonts(wk_handle, 0) + work_out[10] + 1;

      memavail = (long)malloc((unsigned long)-1) - 20000;
      if(anz_font * sizeof(FONT) < memavail)
      {
        fontp = (FONT *)malloc(anz_font * sizeof(FONT));
        fp  = fontp;
        afp = fontp;
      }

      for(i = 1; i <= anz_font; i++, fp++)
      {
        fp->font_id = vqt_name(wk_handle, i, fname);
        if(fp->font_id != -1)
        {
          strcpy(fp->font_name, fname);
          if(fname[32] == 0x01) fp->font_spd = TRUE;

          if(fp->font_id == ft_id)
          {
            akt_font = i;
            afp = fp;
          }
          vst_font(wk_handle, fp->font_id);

          vst_height(wk_handle, 10, &char_width, &char_height,
                     &cell_width, &cell_height);
          get_speed(wk_handle, fp);
        }
      }
      vst_unload_fonts(wk_handle, 0);
      m_v_clswk(wk_handle);
      return(TRUE);
    }
    return(FALSE);
  }
  return(FALSE);
} /* set_font() */

/*********************************/
void get_speed(int wkh, FONT *fp)
{
  int ext1[8], ext2[8];

  if(fp->font_spd == TRUE)
  {
    vqt_f_extent(wkh, "m", ext1);
    vqt_f_extent(wkh, "i", ext2);
    if((ext1[2]-ext1[0]) != (ext2[2]-ext2[0]))
      fp->font_prop = TRUE;
    else
      fp->font_prop = FALSE;
  }
  else
  {
    fp->font_prop = FALSE;
  }
} /* get_speed() */
