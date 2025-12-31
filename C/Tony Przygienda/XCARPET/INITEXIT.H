/* 'defs' for INITEXIT */

extern WORD gr_hwchar;   /* character width      */
extern WORD gr_hhchar;   /* character height      */
extern WORD gr_hwbox;     /* box (cell) width      */
extern WORD gr_hhbox;     /* box (cell) height      */
extern WORD gr_hspace;   /* height of space between lines */
extern int  colours;    /* how much colours allows the resolution !! */

/* Variablen des Programms, direkt von Resource gesetzt */

extern OBJECT *menu_tree;  /* Adress of the pulldown */
extern OBJECT *icons_tree; /* Adress of the icons   */
extern WORD gr_handle;   /* physical workstation handle   */
extern WORD handle;     /* virtual workstation handle    */
extern WORD wi_handle;/* window handle     */
extern WORD top_window;
extern WORD ap_id;

extern int  xdesk, ydesk,hdesk,wdesk; /* the size of the desktop window */
extern int  xwork, ywork,hwork,wwork; /* window absolute Koordinates and size */
extern int  xpict, ypict,hpict,wpict; /* x,y are the coordinates of the upper */
                               /* corner of the window in the graphics */
                               /* the h&w concerns the help graph page */
                               
/* Konstanten des RSC Files, abhÑngig von Auflîsung und von der Routine */
/* rscConstSet initialisiert */

/* pulldown-titel (vt...), menÅpunkte (vm...), bÑume + objekte	*/

				/*  menÅ-titel	(pulldown)	*/
extern int vpulldown, vtinfo, vtdata, vtaction, vtconst, vthelp; 

				/*  desk- und daten-menÅ	*/
extern int vminfo;
extern int vmfile, vmfunc, vmsavemode, vmsave;
extern int vinfo,vmyname;
extern int vinputfun,vfunc1,vfunc2,vxstart,vxend,vystart,vconsta,vconstb,vconstc;

				/*  action-menu			*/
extern int vmdrawf, vmhardcopy, vmexit;
extern int vdrawfun,vcount3d,vcount2d,vcountfl,vcountsh;

				/*  konstanten-menÅ		*/
extern int vmrotate,vmview,vmlight,vmresol,vmdrawmode,vmdegree,vmradiant;
extern int vrotation,vzrotate,vxrotate;
extern int vview,vlookx,vlooky,vlookz,vplaney;
extern int vlight,vlightx,vlighty,vlightz,vrahmein;
extern int vdrawmode,vxraster,vyraster,vxyraster,vcentral,vparallel,
    vwire,vhidden,vshadow;
extern int vresoluti,vxlinien,vylinien;
extern int vstartinf;
extern int vsavemode,votimg,votstad,votdegas,votdoodle,votascii;

				/*  help-menÅ			*/
extern int vmhstad,vmhfunc,vmhspecf,vmhrotate,vmhview,vmhresol,vmhdraw; 
extern int vhfunct,vhrotate,vhprojekt,vhresol,vhdraw,vhspecf,vhstad;

				/*  icons und sonstiges		*/
extern int vsyserror,vqsyserr,vsavefun;
extern int vicons,vdesktop,visave,viinputf,vidrawf,virotate,vilight,viview,viresol,vistyle; /* icons */
extern int vmemostat,vhelpkey;

extern char    pic_format;
extern boolean degree;      /* are all the angles in programs in degree or not ?*/

extern int     drawmode; /* gives information about the graph's resolution */
extern boolean central; 		/* orthogonal or central projection */
extern boolean xraster,yraster;	/* zu zeichnende rasterlinien	    */

extern FDB source,target;
extern char *reserved_screen; /* zur Rettung des Bildschirms dienend ! */

extern long screenbytes; 	/* how much bytes contains an normal screen */

void close_vwork(void),aes_exit(void);
int init_carpet(void);
void exitus(void);
void show_startmessage(void);
void test_name(void);
void init_variables(void);
WORD llog2(LONG);
void reserve_screen(void);
