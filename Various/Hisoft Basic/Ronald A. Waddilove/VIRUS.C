/*	Virus Killer
	By R.A.Waddilove
	Last altered 27/08/89
*/
 
#include <obdefs.h>
#include <osbind.h>

#define SHOW 257
#define HIDE 256
#define POINTER 0
#define BEE 2

#define DIALOGUE	0
#define QUIT	 	5
#define TEST		6
#define BOX			7
#define KILL		8

int	contrl[12],
	intin[128],
	intout[128],
	ptsin[128],
	ptsout[128],
	work_in[12],
	work_out[57];

int	handle,
	hchar,
	wchar,
	dx,dy,dw,dh,
	drive;

char buffer[1100];

OBJECT *dialog;

gem_on()
{
	int i;
	appl_init();
	handle = graf_handle(&wchar,&hchar,&i,&i);
	for ( i=0; i<10; work_in[i++]=1);
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
	if ( gem_on()==0)
		gem_off();
	if ( !rsrc_load("virus.rsc") )
		gem_off();
	rsrc_gaddr(0,DIALOGUE,&dialog);
	form_center(dialog,&dx,&dy,&dw,&dh);
	dx = 8*(dx/8);	dialog->ob_x = dx;
	dy = 8*(dy/8);	dialog->ob_y = dy;
	drive = Dgetdrv();
	if ( drive>1 ) drive = 0;
	do_dialog();
	gem_off();
}
 
do_dialog()
{
	register int result;
	graf_mouse(POINTER,0);
	graf_mouse(HIDE,0);
	form_dial(0,0,0,0,0,dx,dy,dw,dh);
	objc_draw(dialog,0,32767,dx,dy,dw,dh);
	do {
		graf_mouse(SHOW,0);
		do {
			result = form_do(dialog,0);
		} while ( result<1 || result>8 );
		graf_mouse(HIDE,0);
		objc_draw(dialog,BOX,0,dx,dy,dw,dh);
		if ( result == TEST )	check_disc();
		if ( result == KILL )	kill_virus();
		dialog[result].ob_state ^= SELECTED;
		objc_draw(dialog,result,0,dx,dy,dw,dh);
	} while ( result!=QUIT );
	form_dial(3,0,0,0,0,dx,dy,dw,dh);
	graf_mouse(SHOW,0);
}
 
check_disc()
{
	register int x,y;
	x = dx+wchar*3;
	y = dy+hchar*13;
	Floprd(buffer,0L,drive,1,0,0,1);
	if ( buffer[0] == 0x60 ) {
		v_gtext(handle,x,y,"Boot sector program present.");
		v_gtext(handle,x,y+hchar,"If this disc shouldn't have");
		v_gtext(handle,x,y+2*hchar,"one it might be a virus.");
		return;
	}
	if ( buffer[0]+buffer[1] == 0 ) {
		v_gtext(handle,x,y,"Standard boot sector.");
		v_gtext(handle,x,y+hchar,"This disc is ok.");
	}
	else {
		v_gtext(handle,x,y,"Non-standard boot sector.");
		v_gtext(handle,x,y+hchar,"Might be a virus.");
	}
}

kill_virus()
{
	Floprd(buffer,0L,drive,1,0,0,1);
	buffer[0] = 0;
	buffer[1] = 0;
	Flopwr(buffer,0L,drive,1,0,0,1);
	check_disc();
}
