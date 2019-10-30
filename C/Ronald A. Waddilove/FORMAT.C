/*   Multi - Formatter   */
/*    By R.A.Waddilove   */
/* Last altered 18/08/89 */
 
#include <obdefs.h>
#include <osbind.h>

#define SHOW 257
#define HIDE 256
#define POINTER 0
#define BEE 2

/* resource set indicies for FORMAT */
#define DIALOGUE 0 /* form/dialog */
#define DRIVEA 6   /* BUTTON in tree DIALOGUE */
#define DRIVEB 7   /* BUTTON in tree DIALOGUE */
#define NINE 11     /* BUTTON in tree DIALOGUE */
#define TEN 12      /* BUTTON in tree DIALOGUE */
#define SINGLE 15   /* BUTTON in tree DIALOGUE */
#define DOUBLE 16   /* BUTTON in tree DIALOGUE */
#define FORMAT 17   /* BUTTON in tree DIALOGUE */
#define QUIT 18     /* BUTTON in tree DIALOGUE */
#define ZERO 21     /* BUTTON in tree DIALOGUE */
#define TWO 22      /* BUTTON in tree DIALOGUE */
#define ONE 23      /* BUTTON in tree DIALOGUE */
#define BOX 24      /* BOX in tree DIALOGUE */
 
int contrl[12],
     intin[128],
     intout[128],
     ptsin[128],
     ptsout[128],
     work_in[12],
     work_out[57];
 
int handle,       /* vdi handle */
    hchar,         /* character height */
    wchar,         /* character width */
    dx,dy,dw,dh,/* dialog coords */
    scr_mode;     /* screen mode */
 
char buffer[11000];
 
OBJECT*dialog;
 
gem_on()
{
	int i;
	appl_init();
	handle = graf_handle(&wchar,&hchar,&i,&i);   /* i is dummy variable */
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	return (v_opnvwk(work_in,&handle,work_out));
}
 
gem_off()
{
	rsrc_free();
	v_clsvwk(handle);
	appl_exit();
}
 
main()
{
	if (gem_on() == 0)
		gem_off();     /* exit if low res */
	if (!rsrc_load("format.rsc"))
		gem_off();     /* exit if can't find resource */
	rsrc_gaddr(0,DIALOGUE,&dialog);
	form_center(dialog,&dx,&dy,&dw,&dh);     /* centre dialog */
	dx = 8*(dx/8); dialog->ob_x = dx;
	dy = 8*(dy/8); dialog->ob_y = dy;
	do_dialog();
	gem_off();
}
 
do_dialog()
{
	graf_mouse(POINTER,0);
	graf_mouse(HIDE,0);
	form_dial(0,0,0,0,0,dx,dy,dw,dh);    /* save screen */
	objc_draw(dialog,0,32767,dx,dy,dw,dh);  /* draw dialog */
	graf_mouse(SHOW,0);
	while (form_do(dialog,0) != QUIT) {
		format();
		dialog[FORMAT].ob_state ^= SELECTED;
		graf_mouse(HIDE,0);
		objc_draw(dialog,FORMAT,0,dx,dy,dw,dh);
		objc_draw(dialog,BOX,0,dx,dy,dw,dh);
		graf_mouse(SHOW,0);
	}
	dialog[QUIT].ob_state ^= SELECTED;
	graf_mouse(HIDE,0);
	form_dial(3,0,0,0,0,dx,dy,dw,dh);    /* restore screen */
	graf_mouse(SHOW,0);
}
 
format()
{
	register int i,t,s,skew;
	int drive,tracks,sectors,sides,box[4];
	box[0] = dx+wchar*10;
	box[1] = dy+hchar*17;
	box[2] = box[0]+wchar;
	box[3] = box[1]+hchar-1;
	vsf_interior(handle,2); /* pattern fill */
	vsf_style(handle,4);
	vsf_color(handle,2);
	drive = 0;
	if (dialog[DRIVEB].ob_state & SELECTED) drive = 1;
	tracks = 80;
	if (dialog[TWO].ob_state & SELECTED) tracks = 82;
	if (dialog[ONE].ob_state & SELECTED) tracks = 81;
	sides = 1;
	if (dialog[DOUBLE].ob_state & SELECTED) sides = 2;
	sectors = 9; skew = 11;
	if (dialog[TEN].ob_state & SELECTED) {
		sectors = 10;
		skew = 1;
	}
	if (form_alert(1,"[3][Format disc?][Start|Stop]")==2)
		return;
	graf_mouse(BEE,0);
	for (t=0; t<tracks; ++t) {
		graf_mouse(HIDE,0);
		vr_recfl(handle,box);
		graf_mouse(SHOW,0);
		box[2] += wchar/2;
		for (s=0; s<sides; ++s){
			if (Flopfmt(buffer,0L,drive,sectors,t,s,skew,0x87654321L,0xE5E5)){
				graf_mouse(POINTER,0);
				form_alert(1,"[1][A disc error|has occurred][Crumbs!]");
				return;
			}
		}
	}
	for (i=0; i<5120; buffer[i++]=0);    /* zero buffer */
	Flopwr(buffer,0L,drive,1,2-sides,sides-1,sectors);    /* zero directory */
	Protobt(buffer,0x1000000L,sides+1,0); /* make boot sector */
	buffer[19] = tracks*sectors*sides%256;
	buffer[20] = tracks*sectors*sides/256;
	buffer[24] = sectors;
	Flopwr(buffer,0L,drive,1,0,0,sectors); /* write track 0 */
	graf_mouse(POINTER,0);
}
 
