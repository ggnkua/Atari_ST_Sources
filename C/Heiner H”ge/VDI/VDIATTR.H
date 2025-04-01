/* <<< VDIATTR.H 1.1 13.02.93 >>> */

#ifndef __VDIATTR
#define __VDIATTR

#ifndef __PORTAB
   #include <portab.h>
#endif
#ifndef __VDI
   #include <vdi.h>
#endif

/* Linienattribute: */
typedef struct
   {
   WORD wrmode;      /* VDI-Zeichenmodus */
   WORD color;       /* Linienfarbe */
   WORD type;        /* VDI-Linientyp */
   WORD user_style;  /* freies Linienmuster */
   WORD width;       /* Linienbreite */
   WORD begin_style; /* Art des Linienanfangs */
   WORD end_style;   /* Art des Linienendes */
   } LINE_ATTRIBUTES;

/* FÅllattribute: */
typedef struct
   {
   WORD wrmode;      /* VDI-Zeichenmodus */
   WORD color;       /* FÅllfarbe */
   WORD type;        /* FÅlltyp */
   WORD style;       /* FÅllstil-Index */
   WORD perimeter;   /* Umriûlinien-Flag */
   } FILL_ATTRIBUTES;

/* Textattribute: */
typedef struct
   {
   WORD font_id;  /* Font-ID (Index) */
   WORD wrmode;   /* Schreibmodus */
   WORD points;   /* Typengrîûe in Points */
   WORD effects;  /* Flags fÅr Texteffekte */
   WORD color;    /* Schriftfarbe */
   WORD h_align;  /* Hori. Zeichenausrichtung */
   WORD v_align;  /* Vert. Zeichenausrichtung */
   WORD rotation; /* Basislinienausrichtung */
   } TEXT_ATTRIBUTES;

/* Infos zu den eingestellten Textattributen: */
typedef struct
   {
   WORD font_id;  /* Font-ID (Index) */
   WORD wrmode;   /* Schreibmodus */
   WORD points;   /* Typengrîûe in Points */
   WORD effects;  /* Flags fÅr Texteffekte */
   WORD color;    /* Schriftfarbe */
   WORD h_align;  /* Hori. Zeichenausrichtung */
   WORD v_align;  /* Vert. Zeichenausrichtung */
   WORD rotation; /* Basislinienausrichtung */
   WORD char_w;   /* Max. Zeichenbreite */
   WORD char_h;   /* Max. Zeichenhîhe */
   WORD cell_w;   /* Max. Zeichenzellenbreite */
   WORD cell_h;   /* Max. Zeichenzellenhîhe */
   } TEXT_ACTL_ATTR;

/* Prototypen der Einstellfunktionen: */
LINE_ATTRIBUTES *set_line_attributes
   (WORD handle, LINE_ATTRIBUTES *lattr);
FILL_ATTRIBUTES *set_fill_attributes
   (WORD handle, FILL_ATTRIBUTES *fattr);
TEXT_ACTL_ATTR *set_text_attributes
   (WORD handle, TEXT_ATTRIBUTES *tattr);

#endif /* __VDIATTR */
