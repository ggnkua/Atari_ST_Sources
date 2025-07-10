/*******************************/
/* Includedatei fÅr GEM_INEX.C */
/* (c) Michael Haar 1992       */
/*******************************/

#define FL3DNONE 0x0000
#define FL3DIND 0x0200
#define FL3DBAK 0x0400
#define FL3DACT 0x0600

extern int work_in[12], work_out[57], e_work_out[57];
extern int handle, phys_handle;
extern int gl_hchar, gl_wchar, gl_hbox, gl_wbox;
extern int ap_id;
extern GRECT desk;
extern MFDB screen_mfdb;

extern int gem_init(void);
extern int gem_exit(void);
extern int rc_intersect(GRECT *p1, GRECT *p2);
extern int rc_equal(GRECT *p1, GRECT *p2);
extern int do_extdialog(OBJECT *tree, int *ob_x, int *ob_y, void (*andere_buttons)(OBJECT *tree, GRECT *r, int b_nr));

extern void init_buttons(OBJECT *trees[]);