/* <<< VDIATTR.C 1.1 13.02.93 >>>

   Dieses Modul enth„lt die globalen Funktionen:
      -  set_line_attributes
      -  set_fill_attributes
      -  set_text_attributes

   (c) 1993 by MAXON Computer
           und Heiner H”gel,
               Am Hofgraben 16
               W-6236 Eschborn

   History:
      1.0  03.02.93  -  Ersterstellung
                        (set_line_attributes,
                        set_fill_attributes,
                        set_text_attributes)!
      1.1  13.02.93  -  Alle Funktionen melden 
                        jetzt die aktl. Attr. 
                        zurck. Der Schreibmodus 
                        wird nun immer erkannt!
*/

#include "vdiattr.h"

/*============================================*/

LINE_ATTRIBUTES *set_line_attributes
   (int handle, LINE_ATTRIBUTES *lattr)

   {
   static LINE_ATTRIBUTES actl_attr;

   WORD attrib[6];

   /* Aktl. Linienattribute ermitteln
      (soweit m”glich):
   */
   vql_attributes(handle, attrib);
   actl_attr.wrmode      = attrib[2];
   actl_attr.color       = attrib[1];
   actl_attr.type        = attrib[0];
   actl_attr.user_style  = -1;
   actl_attr.width       = attrib[3];
   actl_attr.begin_style = -1;
   actl_attr.end_style   = -1;

   /* lattr berprfen: */
   if (lattr == NULL)
      return (&actl_attr);

   /* Attribute einstellen: */
   if (lattr->wrmode > 0)
      actl_attr.wrmode =
         vswr_mode(handle, lattr->wrmode);
   if (lattr->color >= 0)
      actl_attr.color =
         vsl_color(handle, lattr->color);
   if (lattr->type > 0)
      actl_attr.type =
         vsl_type(handle, lattr->type);
   if (lattr->type == 7)
      {
      vsl_udsty(handle, lattr->user_style);
      actl_attr.user_style = lattr->user_style;
      }
   if (lattr->width > 0)
      actl_attr.width =
         vsl_width(handle, lattr->width);
   if (    lattr->begin_style >= 0
       &&  lattr->end_style   >= 0
      )
      {
      vsl_ends(handle, lattr->begin_style,
                       lattr->end_style);
      actl_attr.begin_style = lattr->begin_style;
      actl_attr.end_style   = lattr->end_style;
      }

   return (&actl_attr);
   }

/*--------------------------------------------*/

FILL_ATTRIBUTES *set_fill_attributes
   (int handle, FILL_ATTRIBUTES *fattr)

   {
   static FILL_ATTRIBUTES actl_fattr;

   WORD attrib[5];

   /* Aktl. Fllattribute ermitteln: */
   vqf_attributes(handle, attrib);
   actl_fattr.wrmode    = attrib[3];
   actl_fattr.color     = attrib[1];
   actl_fattr.type      = attrib[0];
   actl_fattr.style     = attrib[2];
   actl_fattr.perimeter = attrib[4];

   /* Attribute einstellen: */
   if (fattr != NULL)
      {
      if (fattr->wrmode > 0)
         actl_fattr.wrmode =
            vswr_mode(handle, fattr->wrmode);
      if (fattr->color >= 0)
         actl_fattr.color =
            vsf_color(handle, fattr->color);
      if (fattr->type >= 0)
         actl_fattr.type =
            vsf_interior(handle, fattr->type);
      if (    fattr->type != FIS_USER
          &&  fattr->style >= 0
         )
         actl_fattr.style =
            vsf_style(handle, fattr->style);
      if (fattr->perimeter >= 0)
         actl_fattr.perimeter =
            vsf_perimeter(handle,
                          fattr->perimeter);
      }

   return (&actl_fattr);
   }

/*--------------------------------------------*/

TEXT_ACTL_ATTR *set_text_attributes
   (int handle, TEXT_ATTRIBUTES *tattr)

   {
   static TEXT_ACTL_ATTR  result;
   static TEXT_ATTRIBUTES do_not_change =
      { -1, -1, -1, -1, -1, -1, -1, -1 };

   WORD attribs[10];

   /* šberprfung von tattr und Abfrage eines
      Teils der aktuellen Textattribute:
   */
   if (tattr == NULL)
      tattr = &do_not_change;
   vqt_attributes(handle, attribs);

   /* Einstellung des Fonts: */
   result.font_id =
        (    tattr->font_id >= 0
         &&  tattr->font_id != attribs[0]
        )
      ? vst_font(handle, tattr->font_id)
      : attribs[0];

   /* Einstellung der via VDI nicht sauber
      erfragbaren Attribute:
   */
   result.effects =
        (tattr->effects >= 0)
      ? vst_effects(handle, tattr->effects)
      : -1;
   if (tattr->points >= 0)
      result.points = vst_point(handle,
                                tattr->points,
                                &result.char_w,
                                &result.char_h,
                                &result.cell_w,
                                &result.cell_h);
   else
      {
      result.points = -1;
      result.char_w = attribs[6];
      result.char_h = attribs[7];
      result.cell_w = attribs[8];
      result.cell_h = attribs[9];
      }

   /* Einstellung der restlichen abfragbaren
      Attribute:
   */
   if (tattr->wrmode > 0)
      result.wrmode =
         vswr_mode(handle, tattr->wrmode);
   else
      {
      WORD fattribs[5];
      vqf_attributes(handle, fattribs);
      result.wrmode = fattribs[3];
      }
   result.color =
        (    tattr->color >= 0
         &&  tattr->color != attribs[1]
        )
      ? vst_color(handle, tattr->color)
      : attribs[1];
   if (    tattr->h_align >= 0
       ||  tattr->v_align >= 0
      )
      {
      if (    tattr->h_align != attribs[3]
          ||  tattr->v_align != attribs[4]
         )
         vst_alignment(handle, tattr->h_align,
                       tattr->v_align,
                       &result.h_align,
                       &result.v_align);
      }
   else
      {
      result.h_align = attribs[3];
      result.v_align = attribs[4];
      }
   result.rotation =
        (    tattr->rotation >= 0
         &&  tattr->rotation != attribs[2]
        )
      ? vst_rotation(handle, tattr->rotation)
      : attribs[2];

   return (&result);
   }

/*============================================*/

