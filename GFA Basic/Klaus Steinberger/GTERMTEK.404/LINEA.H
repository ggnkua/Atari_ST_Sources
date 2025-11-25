/*
 *   linea.h   struct definitions for the linea graphik functions
 *
 *             struct linea:  Structure for linea Data
 *             struct fontheader:  Fontdatastructure
 *
 *   K. Steinberger 12.4.1986
 *   Beschleunigerlaboratorium der LMU und TU MÅnchen
 *   HochschulgelÑnde
 *   D-8046 Garching
 *
 */


struct linea {
     int  v_planes;
     int  v_lin_wr;
     char *CONTRL;
     char *INTIN;
     char *PTSIN;
     char *INTOUT;
     char *PTSOUT;
     int  _FG_BP_1;
     int  _FG_BP_2;
     int  _FG_BP_3;
     int  _FG_BP_4;
     int  _LSTLIN;
     int  _LN_MASK;
     int  _WRT_MODE;
     int  _X1;
     int  _Y1;
     int  _X2;
     int  _Y2;
     char *_patptr;
     int  _patmsk;
     int  _multifill;
     int  _CLIP;
     int  _XMN_CLIP;
     int  _YMN_CLIP;
     int  _XMX_CLIP;
     int  _YMX_CLIP;
     int  _XACC_DDA;
     int  _DDA_INC;
     int  _T_SCLSTS;
     int  _MONO_STATUS;
     int  _SOURCEX;
     int  _SOURCEY;
     int  _DESTX;
     int  _DESTY;
     int  _DELX;
     int  _DELY;
     char *_FBASE;
     int  _FWIDTH;
     int  _STYLE;
     int  _LITEMASK;
     int  _SKEWMASK;
     int  _WEIGHT;
     int  _R_OFF;
     int  _L_OFF;
     int  _SCALE;
     int  _CHUP;
     int  _TEXT_FG;
     char *_scrtchp;
     int  scrtp2;
     int  _TEXT_BG;
     int  _COPYTRAN;
};

struct fontdata {
     int  fontid;   /* Font Identifier */
     int  fontsize; /* Size of the Font in Points */
     char fontname[32];  /* Name of the Font as ASCII-String */
     int  firstade;      /* First displayable Character in ASCII */
     int  lastade;       /* Last displayable */
     int  top;           /* Relative distance top to base */
     int  ascent;
     int  half;
     int  decent;
     int  bottom;
     int  fontwidth;     /* largest width in the font */
     int  fontcell;      /* largest cell in the font */
     int  l_off;         /* left offset */
     int  r_off;         /* right offset (both used for skewing */
     int  thick;         /* used for bold */
     int  underline;     /* height of the underlin */
     int  light;         /* lightening mask */
     int  skew;          /* skewing mask */
     int  fontflag;      /* some flags for the font */
                         /* bit0 : system font if set */
                         /* bit1 : horizontal offset available if set */
                         /* bit2 : byte swap flag, 68k format if set else intel stuff */
                         /* bit3 : all characters are equal width if set (non proportional) */
     int *hor_off;      /* pointer to the horizontal offset table or 0 */
     int *char_off;     /* pointer to the character offset table */
     char *font_data;    /* pointer to tzhe real fontdata */
     int  form_width;    /* sum of the width of all chars in the font */
     int  form_height;   /* all scanlines in the font */
     char *next_font;
};

