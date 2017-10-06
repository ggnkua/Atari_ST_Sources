/*  CPX.H
 *  Headerdatei zur Erzeugung von CPX-Modulen
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 1
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *
 *  Erstellt mit Pure C
 */

/* So sieht der Kopf eines CPX-Moduls aus   */
typedef struct
{
    UWORD   magic;
    struct
    {
        unsigned reserved : 13;
        unsigned ram_resident : 1;
        unsigned boot_init : 1;
        unsigned set_only  : 1;
    } flags;
    LONG    cpx_id;
    UWORD   cpx_version;
    char    i_text[14];
    UWORD   icon[48];
    struct
    {
    	unsigned i_color :4;
    	unsigned reserved : 4;
    	unsigned i_char : 8;
    } i_info;
    char    text[18];
    struct
    {
    	unsigned c_board : 4;
    	unsigned c_text : 4;
    	unsigned pattern : 4;
    	unsigned c_back : 4;
    } t_info;
    char    buffer[64];
    char    reserved[306];
}   CPXHEAD;

/* Mausparameter                                */
typedef struct
{
    WORD x;
    WORD y;
    WORD buttons;
    WORD kstate;
} MRETS;

/* Struktur zur Verwaltung von CPX-Modulen      */
typedef struct cpxlist
{
        char f_name[14];
        WORD head_ok;
        WORD segm_ok;
        struct
        {
                void *text_seg;
                long len_text;
                void *data_seg;
                long len_data;
                void *bss_seg;
                long len_bss;
        } *segm;
        struct cpxlist *next;
        CPXHEAD header;
} CPX_LIST;

/* Funktionen und Flags die von XControl zur VerfÅgung  */
/* gestellt werden.                                     */
typedef struct
{
    WORD    handle;
    WORD    booting;
    WORD    reserved;
    WORD    SkipRshFix;

    CPX_LIST *  cdecl (*get_cpx_list)(void);
    WORD cdecl  (*save_header)(CPX_LIST *header);

    void cdecl  (*rsh_fix)(WORD num_objs,WORD num_frstr,
                    WORD num_frimg, WORD num_tree,
                    OBJECT *rs_object, TEDINFO *rs_tedinfo,
                    char *rs_strings[], ICONBLK *rs_iconblk,
                    BITBLK *rs_bitblk, long *rs_frstr,
                    long *rs_frimg, long *rs_trindex,
                    struct foobar *rs_imdope);

    void cdecl  (*rsh_obfix)(OBJECT *tree, WORD ob);

    WORD cdecl  (*Popup)(char *items[],WORD num,
                WORD def_item,WORD font,
                GRECT *up, GRECT *world);

    void cdecl  (*Sl_size)(OBJECT *tree, WORD base,
                WORD slider, WORD entrys, WORD vis_ent,
                WORD hvflag, WORD min_pix);

    void cdecl  (*Sl_x)(OBJECT *tree, WORD base, WORD slider,
                WORD value, WORD min, WORD max,
                void (*foo)(void));

    void cdecl  (*Sl_y)(OBJECT *tree, WORD base, WORD slider,
                WORD value, WORD min, WORD max,
                void (*foo)(void));

    void cdecl  (*Sl_arrow)(OBJECT *tree, WORD base,
                WORD slider, WORD obj, WORD inc, WORD min,
                WORD max, WORD *value, WORD hvflag,
                void (*foo)(void));

    void cdecl  (*Sl_dragx)(OBJECT *tree, WORD base,
                WORD slider, WORD min, WORD max,
                WORD *value, void (*foo)(void));

    void cdecl  (*Sl_dragy)(OBJECT *tree, WORD base,
                WORD slider, WORD min, WORD max,
                WORD *value, void (*foo)(void));

    WORD cdecl  (*Xform_do)(OBJECT *tree,WORD eobj,
                WORD *msg);

    GRECT * cdecl   (*GetFirstRect)(GRECT *prect);

    GRECT * cdecl   (*GetNextRect)(void);

    void cdecl  (*Set_Evnt_Mask)(WORD mask, MOBLK *m1,
                MOBLK *m2, long time);

    WORD cdecl  (*XGen_Alert)(WORD al);

    WORD cdecl  (*CPX_Save)(void *ptr, long bytes);

    void * cdecl    (*Get_Buffer)(void);

    WORD cdecl  (*getcookie)(long cookie, long *p_value);

    WORD        Country_Code;

    void cdecl  (*MFsave)(WORD flag, MFORM *mf);

} XCPB;

/* Funktionen die vom CPX-Modul zur VerfÅgung   */
/* gestellt werden.                             */
typedef struct
{
    WORD cdecl  (*cpx_call)(GRECT *rect);
 
    void cdecl  (*cpx_draw)(GRECT *clip);
 
    void cdecl  (*cpx_wmove)(GRECT *work);
 
    void cdecl  (*cpx_timer)(WORD *quit);
 
    void cdecl  (*cpx_key)(WORD kstate, WORD key, WORD *quit);
 
    void cdecl  (*cpx_button)(MRETS *mrets, WORD nclicks,
    			 WORD *quit);
 
    void cdecl  (*cpx_m1)(MRETS *mrets, WORD *quit);
 
    void cdecl  (*cpx_m2)(MRETS *mrets, WORD *quit);
 
    WORD cdecl  (*cpx_hook)(WORD event, WORD *msg, 
                MRETS *mrets, WORD *key, WORD *nclicks);
 
    void cdecl  (*cpx_close)(WORD flag);
} CPXINFO;

/* NÅtzliche Definitionen               */
#define SAVE_DEFAULTS   0
#define MEM_ERR         1
#define FILE_ERR        2
#define FILE_NOT_FOUND  3

#define MFSAVE      1
#define MFRESTORE   0

#define CT_KEY  53
