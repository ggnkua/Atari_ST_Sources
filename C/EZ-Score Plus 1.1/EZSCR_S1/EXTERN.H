/* EXTERN.H - 880225 - Craig Dickson - Copyright 1988 Hybrid Arts Inc */

/* Tom's globals  */

extern int     *Mousex;          /* --> line a variable for mouse x pos.   */
extern int     *Mousey;          /* --> line a variable for mouse y pos.   */
extern int     maxnsymb;         /* num of symbols that can fit in currs.  */
extern int     nsymbonscr;       /* number of symbols in currscreen        */
extern int     *currscreen;      /* array of symbols on screen             */
extern int     *matptr;          /* points to start of MAT in header       */
extern int     rehearw;          /* width of rehearsal mark boxes          */
extern int     symbfamily[];     /* lowest and highest codes for families  */
extern long    scrsave;          /* points to the start of big waste space */
extern short   domainflgs[];     /* set all elements to 0 before calc_data */
extern char    *Mstate;          /* --> line a variable for mouse buttons  */
extern char    *dataptr;         /* points to score image data segment     */
extern char    *envirptr;        /* points to environment info segment     */
extern char    *headptr;         /* points to start of score header        */
extern char    *pageptr;         /* points to start of page layout segment */
extern char    *staffptr;        /* points to staff info segment           */
extern char    printers[];       /* contents of PRINTER.CNF file           */
extern FONTFORM font_info[];     /* info on the seven available fonts      */
extern OBJECT  *pageaddr;        /* points to PAGEDIAL tree                */
extern OBJECT  *poptaddr;        /* points to POPTDIAL tree                */
extern OBJECT  *prinaddr;        /* points to PRINTING tree                */
   /* must restore:  */
extern int     bytesperline;     /* bytes per scan line (120)              */
extern int     gr_clipx1;        /* gr clip rect - coordinates inclusive   */
extern int     gr_clipy1;
extern int     gr_clipx2;
extern int     gr_clipy2;
extern int     gr_device;        /* 1 for printer, 0 for screen            */
extern int     rez;              /* screen resolution - set to 2 for print */
extern int     staff_y[];        /* diatonic unit for top line of staves   */
extern int     staffview[];      /* set all to 1 (all staves visible)      */
extern int     x_left;           /* left and right ends of staves          */
extern int     x_right;
extern long    scrbase;          /* points to the start of screen memory   */
extern short   nof_endg;         /* set TRUE when ending starts with line  */
extern short   skip_lrehr;       /* don't display last ending if at rmarg  */
extern short   skip_rehr;        /* don't display rehearsal marks if TRUE  */
extern char    gr_clip;          /* 0 - gr clipping off, non-zero - on     */
extern char    w_symb[];         /* physical width of each symbol          */

/* Symbols  */

extern PSYM staff;                           /* staff structure and image  */
extern int  staffi();

extern PSYM brackt, brackm, brackb;
extern int brackit(), brackim(), brackib();  /* bracket connector info     */

extern PSYM bracei[];           /* my array of brace image info structures */

extern int brace056i(), brace066i(), brace081i(), brace096i(), brace111i(),
           brace126i(), brace141i(), brace156i(), brace171i(), brace186i(),
           brace201i(), brace216i(), brace231i(), brace246i();

/* EOF */
