/* cdzone gemsetup.c
 * Based on various bits of code lifted from books/magazines etc
 * Roland Givan Summer/Autumn 1993
 *
 */

#include "c_includ.h"
#include <stdio.h>
#include <osbind.h>
#include "gem.h"


GEM_SIZE    contrl[12],
	intin[128],
	ptsin[128],
	intout[128],
	ptsout[128];

GEM_SIZE    work_out[57],
	work_in[12];

MFDB s,d;

short *back_base,*back_ptr,*front_ptr;	/*back and front screen addresses*/

GEM_SIZE handle;
GEM_SIZE gl_hhbox,gl_hwbox,gl_hhchar,gl_hwchar;

int ap_id;	/* Application ID of this process */
OBJECT *dlog;
int width,height;	/* width and height of screen */

/* Function prototypes for this file */

int gem_setup(void);
void gem_close_down(void);
void open_work(void);
void create_screen_fdb(short *addr, MFDB *fdb);
void update_front(int backx, int backy, int frontx, int fronty, int w, int h, int mode);
void set_front(void);
void set_back(void);
void initialise_back_screen(void);
void delete_back_screen(void);
int handle_dialog(OBJECT *dlog,int editnum);
void get_tedinfo(OBJECT *tree, int obj, char *dest);
char *score_dialog(void);
void pause_dialog(void);
void version_dialog(char *);


int gem_setup(void)
{
	int ret=TRUE;

	ap_id = appl_init();
	graf_mouse(M_OFF,0);
	handle = graf_handle(&gl_hwchar,&gl_hhchar,&gl_hwbox,&gl_hhbox);
	open_work();
	vq_extnd(handle,1,work_out);
	v_hide_c(handle);		/* hide mouse pointer */
	if(!rsrc_load("CBZONE.RSC")){
		form_alert(1,"[3][Can't load resource file][ OK ]");
		ret=FALSE;
	}
	rsrc_gaddr(R_TREE,FORM1,&dlog);
	initialise_back_screen();
	set_back();
	return(ret);
}

void gem_close_down(void)
{
	set_front();
	v_show_c(handle,1);
	graf_mouse(M_ON,0);
	wind_update(END_UPDATE);
	v_clsvwk(handle);
	delete_back_screen();
	form_dial(FMD_START,0,0,0,0,0,0,width,height);
	form_dial(FMD_FINISH,0,0,0,0,0,0,width,height);
	rsrc_free();
	appl_exit();
	exit(0);
}

void open_work(void)
{
	int i;

	for (i=0; i<10; work_in[i++]=1);
	work_in[10] = 2;
	v_opnvwk(work_in, &handle, work_out);
	v_clrwk(handle);
#ifdef DEBUG
delete_log();	/* delete old log if any */
#endif
	width = work_out[0];
	height = work_out[1];
	wind_update(BEG_UPDATE);
}

#if 0
void copy_raster_opaque(int handle, MFDB *src, MFDB *dest, int mode, int sx,
                        int sy, int sw, int sh, int dx, int dy, int dw, int dh)
{

        /* Coverts height and width coords to absolute x,y coords */
        block[0]=sx;
        block[1]=sy;
        block[2]=sx+sw-1;
        block[3]=sy+sh-1;
        block[4]=dx;
        block[5]=dy;
        block[6]=dx+dw-1;
        block[7]=dy+dh-1;

        vro_cpyfm(handle,mode,pxarray,src,dest);
}
#endif

#if 0
void create_screen_fdb(short *addr, MFDB *fdb)
/* Fills in a blank FDB with standard information and the supplied
   screen address */
{
        fdb->fd_addr = (void *)(addr); /* changed from long to void */
        fdb->fd_w = (short)(640);
        fdb->fd_h = (short)(400);
        fdb->fd_wdwidth = (short)(40);
        fdb->fd_stand = (short)(0);
        fdb->fd_nplanes = (short)(1);
        fdb->fd_r1 = (short)(0);
        fdb->fd_r2 = (short)(0);
        fdb->fd_r3 = (short)(0);
}
#endif

void update_front(int backx, int backy, int frontx, int fronty, int w, int h, int mode)
{
		static GEM_SIZE	block[8]={35,37,465,207,35,37,465,207};

#ifdef LATTICE
		MFDB s = {(void *)(0),(short)(640),(short)(400),(short)(40),(short)(0),(short)(1),(short)(0),(short)(0),(short)(0)};
		MFDB d = {(void *)(0),(short)(640),(short)(400),(short)(40),(short)(0),(short)(1),(short)(0),(short)(0),(short)(0)};

		s.fd_addr=(void *)(back_ptr);
		d.fd_addr=(void *)(front_ptr);
#else
		MFDB s = {(long)(0),(short)(640),(short)(400),(short)(40),(short)(0),(short)(1),(short)(0),(short)(0),(short)(0)};
		MFDB d = {(long)(0),(short)(640),(short)(400),(short)(40),(short)(0),(short)(1),(short)(0),(short)(0),(short)(0)};

		s.fd_addr=(long)(back_ptr);
		d.fd_addr=(long)(front_ptr);
#endif
        vro_cpyfm(handle,S_ONLY,block,&s,&d);
}

void set_front(void){
/* Sets writing screen to front */
        Setscreen(front_ptr,(void *)(-1),-1);
}

void set_back(void){
/* Sets writing screen to back */
        Setscreen(back_ptr,(void *)(-1),-1);
}

void initialise_back_screen(void){
        front_ptr = (short *)(Physbase()); /* This line isn't strictly ANSI as
                                                Physbase expands to a {}
                                                which isn't allowed in an
                                                expression */
        back_base = (short *)(calloc(16384,2));
        back_ptr = (short *)((long)((back_base) + 0xFF) & (long)(0xFFFFFF00));
}

void delete_back_screen(void){
        free(back_base);
}

int handle_dialog(OBJECT *dlog,int editnum)
{
	GEM_SIZE x,y,w,h;
	int but;

	form_center(dlog,&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	objc_draw(dlog,0,10,x,y,w,h);
	but=form_do(dlog,editnum);
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	dlog[but].ob_state&=~SELECTED;	/* de-select exit button */
	return but;
}


/*
 * copy the string from a TEDINFO into another string
 */
void get_tedinfo(OBJECT *tree, int obj, char *dest)
{
	char *source;

	source=((TEDINFO *)tree[obj].ob_spec)->te_ptext;	/* extract address */
	strcpy(dest,source);
}

char *score_dialog(void)
{
	char name[20];
	
	handle_dialog(dlog,name_field);
	get_tedinfo(dlog,name_field,name);
	return(name);
}

void pause_dialog(void)
{
	set_front();
	form_alert(1,"[3][ Game Paused ][ CONTINUE ]");
	set_back();
}

void version_dialog(char *ver)
{
	char buf[100];

	set_front();
	sprintf(buf,"[0][ CBZONE Version: | %s | Atari Version 0.2 29/12/93 ][ OK ]",ver);
	form_alert(1,buf);
	set_back();
}
