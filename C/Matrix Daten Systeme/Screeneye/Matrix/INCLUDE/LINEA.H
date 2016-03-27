/*      LINEA.H

        LineA Definitions

        Copyright (C) Borland International 1990
        All Rights Reserved.
*/


#if  !defined( __LINEA__ )
#define __LINEA__

#if  !defined( __AES__ )
#include <aes.h>                    /* for MFORM                    */
#endif


#define REPLACE 0                   /* set_wrt_mode()               */
#define TRANS   1
#define XOR     2
#define INVERS  3

#define VDIFM 1                     /* sdb.form                     */
#define XORFM -1


typedef struct
{
    int xhot,                       /* X-Offset                     */
        yhot,                       /* Y-Offset                     */
        form,                       /* Format (1 = VDI, -1 = XOR)   */
        bgcol,                      /* Hintergrundfarbe             */
        fgcol,                      /* Vordergrundfarbe             */
        image[32];                  /* Sprite-Image                 */
} SDB;

typedef int SSB[10 + 4 * 64];

typedef int PATTERN[16];            /* Bei Bedarf vergrîûern        */

typedef struct fonthdr
{
    int id,                         /* Fontnummer                   */
        size;                       /* Fontgrîûe in Punkten         */
    char facename[32];              /* Name                         */
    int ade_lo,                     /* kleinster ASCII-Wert         */
        ade_hi,                     /* grîûter ASCII-Wert           */
        top_dist,                   /* Abstand Top <-> Baseline     */
        asc_dist,                   /* Abstand Ascent <-> Baseline  */
        hlf_dist,                   /* Abstand Half <-> Baseline    */
        des_dist,                   /* Abstand Descent <-> Baseline */
        bot_dist,                   /* Abstand Bottom <-> Baseline  */
        wchr_wdt,                   /* maximale Zeichenbreite       */
        wcel_wdt,                   /* maximale Zeichenzellenbreite */
        lft_ofst,                   /* Offset links                 */
        rgt_ofst,                   /* Offset rechts                */
        thckning,                   /* Verbreiterungsfaktor fÅr Bold*/
        undrline,                   /* Dicke der Unterstreichung    */
        lghtng_m,                   /* Maske fÅr Light              */
        skewng_m;                   /* Maske fÅr Kursiv             */
    struct
    {
        unsigned             :12;   /* Frei                         */
        unsigned mono_spaced : 1;   /* Proportional/Monospaced      */
        unsigned f68000      : 1;   /* 8086-/68000 Format           */
        unsigned hot         : 1;   /* HOT verwenden                */
        unsigned system      : 1;   /* Default system font          */
    }   flags;
    char *hz_ofst;                  /* Horizontal Offset Table      */
    int *ch_ofst;                   /* Font-Offset-Tabelle          */
    void *fnt_dta;                  /* Zeichensatz-Image            */
    int frm_wdt,                    /* Breite des Font-Image        */
        frm_hgt;                    /* Hîhe des Fonts               */
    struct fonthdr *next;           /* NÑchster Font                */
}   FONT_HDR;

typedef struct
{
    int v_planes,                   /* # Bitplanes (1, 2 od. 4)     */
        v_lin_wr,                   /* # Bytes/Scanline             */
        *contrl,
        *intin,
        *ptsin,                     /* Koordinaten-Eingabe          */
        *intout,
        *ptsout,                    /* Koordinaten-Ausgabe          */
        fg_bp_1,                    /* Plane 0                      */
        fg_bp_2,                    /* Plane 1                      */
        fg_bp_3,                    /* Plane 2                      */
        fg_bp_4,                    /* Plane 3                      */
        lstlin;
    unsigned ln_mask;               /* Linienmuster                 */
    int wrt_mode,                   /* Schreib-Modus                */
        x1, y1, x2, y2;             /* Koordinaten                  */
    void *patptr;                   /* FÅllmuster                   */
    unsigned patmsk;                /* .. dazugehîrige Maske        */
    int multifill,                  /* FÅllmuster fÅr Planes        */
        clip,                       /* Flag fÅr Clipping            */
        xmn_clip, ymn_clip,
        xmx_clip, ymx_clip,         /* Clipping Rechteck            */
                                    /* Rest fÅr text_blt:           */
        xacc_dda,
        dda_inc,                    /* Vergrîûerungsfaktor          */
        t_sclsts,                   /* Vergrîûerungsrichtung        */
        mono_status,                /* Proportionalschrift          */
        sourcex, sourcey,           /* Koordinaten im Font          */
        destx, desty,               /* Bildschirmkoordinaten        */
        delx, dely;                 /* Breite und Hîhe des Zeichen  */
    FONT_HDR *fbase;                /* Start der Font-Daten         */
    int fwidth,                     /* Breite des Fontimage         */
        style;                      /* Schreibstil                  */
    unsigned litemask,              /* Maske fÅr Light              */
             skewmask;              /* Maske fÅr Kursiv             */
    int weight,                     /* Breite bei Bold              */
        r_off,                      /* Kursiv-Offset rechts         */
        l_off,                      /* Kursiv-Offset links          */
        scale,                      /* Vergrîûerung ja/nein         */
        chup,                       /* Rotationswinkel *10          */
        text_fg;                    /* Textfarbe                    */
    void *scrtchp;                  /* Buffer                       */
    int scrpt2,                     /* Index in Buffer              */
        text_bg,                    /* unbenutzt                    */
        copy_tran,                  /* --                           */
        (*fill_abort)( void );      /* Testet Seed Fill             */
} LINEA;

typedef struct
{
    long reserved6;                 /* reserviert (-0x38e)          */
    FONT_HDR *cur_font;             /* Zeiger auf Header akt. Font  */
    int reserved5[23],              /* reserviert                   */
        m_pos_hx,                   /* X-Koordinate Maus            */
        m_pos_hy,                   /* Y-Koordinate Maus            */
        m_planes,                   /* Zeichenmodus der Maus        */
        m_cdb_bg,                   /* Maus Hintergrundfarbe        */
        m_cdb_fg,                   /* Maus Vordergrundfarbe        */
        mask_form[32],              /* Vordergrund und Maske        */
        inq_tab[45],                /* wie vq_extnd()               */
        dev_tab[45],                /* wie v_opnwk()                */
        gcurx,                      /* X-Position Maus              */
        gcury,                      /* Y-Position Maus              */
        m_hid_ct,                   /* Anzahl der hide_mouse-calls  */
        mouse_bt,                   /* Status der Mausknîpfe        */
        req_col[3][16],             /* Interne Daten fÅr vq_color() */
        siz_tab[15],                /* wie v_opnwk()                */
        reserved4[2];               /* reserviert                   */
    void *cur_work;                 /* Attribute der akt. Workstn.  */
    FONT_HDR *def_font;             /* Standard Systemzeichensatz   */
    FONT_HDR *font_ring[4];         /* Zeichensatzlisten            */
    int font_count,                 /* Anzahl der ZeichensÑtze      */
        reserved3[45];              /* reserviert                   */
    char cur_ms_stat,               /* Mausstatus                   */
         reserved2;                 /* reserviert                   */
    int v_hid_cnt,                  /* Anzahl der Hide_cursor-calls */
        cur_x,                      /* X-Position Maus              */
        cur_y;                      /* Y-Position Maus              */
    char cur_flag,                  /* != 0: Maus neu zeichnen      */
         mouse_flag;                /* != 0: Maus-Interrupt ein     */
    long reserved1;                 /* reserviert                   */
    int v_sav_xy[2],                /* gerettete X-Y-Koordinaten    */
        save_len;                   /* Anzahl der Bildschirmzeilen  */
    void *save_addr;                /* Erstes Byte im Bildspeicher  */
    int save_stat;                  /* Dirty-Flag                   */
    long save_area[4][16];          /* Buffer fÅr Bild unter Maus   */
    void (*user_tim)( void );       /* Timer-Interrupt-Vektor       */
    void (*next_tim)( void );       /* alter Interrupt              */
    void (*user_but)( void );       /* Maustasten-Vektor            */
    void (*user_cur)( void );       /* Maus-Vektor                  */
    void (*user_mot)( void );       /* Mausbewegungs-Vektor         */
    int v_cel_ht,                   /* Zeichenhîhe                  */
        v_cel_mx,                   /* maximale Cursorspalte        */
        v_cel_my,                   /* maximale Cursorzeile         */
        v_cel_wr,                   /* Characterzeilenbreite        */
        v_col_bg,                   /* Hintergrundfarbe             */
        v_col_fg;                   /* Vordergrundfarbe             */
    void *v_cur_ad;                 /* Adresse der Cursorposition   */
    int v_cur_off,                  /* Vertikaler Bildschirmoffset  */
        v_cur_xy[2];                /* X-Y-Cursor                   */
    char v_period,                  /* Blinkgeschwindigkeit         */
         v_cur_ct;                  /* ZÑhler fÅr Blinken           */
    void *v_fnt_ad;                 /* Zeiger auf Font              */
    int v_fnt_nd,                   /* grîûter ASCII-Wert           */
        v_fnt_st,                   /* kleinster ASCII-Wert         */
        v_fnt_wd,                   /* Breite des Fontimage in Byte */
        v_rez_hz,                   /* Bildschirmbreite in Pixel    */
        *v_off_ad,                  /* Font-Offset-Tabelle          */
        reserved,                   /* Cursorflag/reserviert        */
        v_rez_vt,                   /* Bildschirmhîhe in Pixel      */
        bytes_lin;                  /* Bytes pro Pixelzeile         */
}   VDIESC;

typedef struct
{
    int b_wd,                       /* Breite des Blocks in Pixeln  */
        b_ht,                       /* Hîhe des Blocks in Pixeln    */
        plane_ct,                   /* Anzahl der Farbplanes        */
        fg_col,                     /* Vordergrundfarbe             */
        bg_col;                     /* Hintergrundfarbe             */
    char op_tab[4];                 /* VerknÅpfung (fÅr jede Plane) */
    int s_xmin,                     /* X-Quellraster                */
        s_ymin;                     /* Y-Quellraster                */
    void *s_form;                   /* Adresse des Quellrasters     */
    int s_nxwd,                     /* Offset zum nÑchsten Wort     */
        s_nxln,                     /* Breite des Quellrasters      */
        s_nxpl,                     /* Offset zur nÑchsten Plane    */
        d_xmin,                     /* X-Zielraster                 */
        d_ymin;                     /* Y-Zielraster                 */
    void *d_form;                   /* Adresse des Zielrasters      */
    int d_nxwd,                     /* Offset zum nÑchsten Wort     */
        d_nxln,                     /* Breite des Quellrasters      */
        d_nxpl;                     /* Offset zur nÑchsten Plane    */
    void *p_addr;                   /* 16-Bit-Masken zum Undieren   */
    int p_nxln,                     /* Breite der Maske in Bytes    */
        p_nxpl,                     /* Offset zur nÑchsten Plane    */
        p_mask;                     /* Hîhe der Maske in Zeilen     */
    char filler[24];                /* Interner Buffer              */
}   BITBLT;

typedef struct
{
    FONT_HDR *font[3];
} FONTS;

typedef struct
{
    int (*funp[16])( void );
} LINEA_FUNP;


void linea_init( void );
void put_pixel( int x, int y, int color );
int  get_pixel( int x, int y );
void draw_line(int x1, int y1, int x2, int y2);
        /* set_fg_bp(), set_ln_mask(), set_wrt_mode() */
void horizontal_line( int x1, int y1, int x2 );
        /* set_fg_bp(), set_wrt_mode(), set_pattern() */
void filled_rect( int x1, int y1, int x2, int y2 );
        /* set_fg_bp(), set_wrt_mode(), set_pattern(), set_clipping() */
void filled_polygon( int *xy, int count );
        /* set_fg_bp(), set_wrt_mode(), set_pattern(), set_clipping() */
void bit_blt(BITBLT *bitblt);
void text_blt( int x, int y, unsigned char c );
        /* set_txtblt() */
void show_mouse( int flag );
void hide_mouse( void );
void transform_mouse( MFORM *mform );
void undraw_sprite( SSB *ssb );
void draw_sprite( int x, int y, SDB *sdb, SSB *ssb );
void copy_raster( void );                   /* 14, COPY RASTER FORM */
void seed_fill( void );                     /* 15, SEED FILL        */
        /* WARNING: 14 & 15 are NOT supported ! */

void set_fg_bp( int auswahl );
void set_ln_mask( int mask );
void set_wrt_mode( int modus );
void set_pattern( int *pattern, int mask, int multifill );
void set_clip( int x1, int y1, int x2, int y2, int modus );
void set_text_blt( FONT_HDR *font, int scale, int style, int chup,
                   int text_fg, int text_bg );

void draw_circle( int x, int y, int radius, int color );
void print_string( int x, int y, int xoff, char *string );


extern LINEA *Linea;
extern VDIESC *Vdiesc;
extern FONTS *Fonts;
extern LINEA_FUNP *Linea_funp;

#endif

/**************************************************************************/
