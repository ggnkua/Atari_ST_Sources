/*	   CRC claculator	  */
/*    By R.A.Waddilove    */
/* Last modified 08/09/89 */

#include <strings.h>
#include <obdefs.h>
#include <stdio.h>
#include <osbind.h>

#define DIALOGUE	0
#define CRC			5
#define QUIT		6

#define POINTER 0
#define BEE		2
#define HIDE	256
#define SHOW	257

int	contrl[12],
	intin[128], intout[128],
	ptsin[128], ptsout[128],
	work_in[12], work_out[57];
 
int	handle,			/* vdi handle */
	hchar,			/* character height */
	wchar,			/* character width */
	dx,dy,dw,dh;	/* dialog coords */
  
OBJECT *dialog;
 
gem_on()
{
	int i;
	appl_init();
	handle = graf_handle(&wchar,&hchar,&i,&i);   /* i is dummy variable */
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in,&handle,work_out);
}
 
gem_off()
{
	rsrc_free();
	v_clsvwk(handle);
	appl_exit();
}
 
char path[80],name[20];

main()
{
	gem_on();
	if ( !rsrc_load("crc.rsc") ) {
		v_clsvwk(handle);
		appl_exit();	/* can't find resource */
	}
	rsrc_gaddr(0,DIALOGUE,&dialog);			/* Get dialog address */
	form_center(dialog,&dx,&dy,&dw,&dh);	/* centre dialog */
	do_dialog();
	gem_off();
}

do_dialog()
{
	long crc,get_crc();
	int result;
	char number[5];
	graf_mouse(POINTER,0);
	graf_mouse(HIDE,0);
	form_dial(0,0,0,0,0,dx,dy,dw,dh);		/* save screen */
	objc_draw(dialog,0,32767,dx,dy,dw,dh);	/* draw dialog */
	graf_mouse(SHOW,0);
	do {
		do {
			result = form_do(dialog,0);
		} while ( result<1 || result>7 );
		dialog[result].ob_state ^= SELECTED;
		if ( result==CRC )
			if ( get_file() ) {
				graf_mouse(HIDE,0);
				v_gtext(handle,dx+wchar*10,dy+hchar*14,name);
				crc = get_crc();
				num_to_asc(crc,number);
				v_gtext(handle,dx+wchar*10,dy+hchar*16,number);
				graf_mouse(SHOW,0);
			}
	} while ( result!=QUIT );
	graf_mouse(HIDE,0);
	form_dial(3,0,0,0,0,dx,dy,dw,dh);    /* restore screen */
	graf_mouse(SHOW,0);
}

get_file()
{
	int button,len;
	strcpy(path,"A:\\*.*");	/* default path */
	path[0] += Dgetdrv();	/* set to current drive */
	strcpy(name,"");		/* null filename */
	fsel_input(path,name,&button);	/* do file selector */
	graf_mouse(HIDE,0);
	objc_draw(dialog,0,32767,dx,dy,dw,dh);	/* re-draw dialog */
	graf_mouse(SHOW,0);
	if ( name[0]=='\0' || button==0 )
		return(0);	/* no filename or Cancel pressed */
	len = strlen(path);
	while ( path[len-1]!='\\' )
		--len;
	path[len] = '\0';
	strcat(path,name);
	return(1);
}

long get_crc()
{
	register int x;
	register long hl,c;
	FILE *stream = fopen(path,"br");
	if ( stream==0 ) return;
	hl = c = 0;
	while ( !feof(stream ) ) {
		hl ^= (unsigned) (getc(stream) << 8);
		for (x = 8; x > 0; --x){
			c = hl>>15;
			if (c)
				hl ^= 0x810;
			hl = hl<<1; hl |= c; c = hl>>16; hl &= 0xFFFF;
       }
    }
	fclose(stream);
	return(hl);
}

num_to_asc(n,s)
register long n;
char s[];
{
	register int i,r;
	s[0]=' '; s[1]=' '; s[2]=' '; s[3]=' '; s[4] = '\0';
	for ( i=3; i>-1; --i ) {
		r = n % 16;
		if ( r>9 )	r += 7;
		s[i] = r+48;
		n /= 16;
	}
}
