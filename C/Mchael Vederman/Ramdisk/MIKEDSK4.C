/*This program is copyright 1986 by Mchael Vederman, distribute it freely
so long as proper credit for code is given.  The ramdisk resize was not
implemented with this version.*/


#include "d:portab.h"
#include "d:obdefs.h"
#include "d:define.h"
#include "d:gemdefs.h"
#include "d:osbind.h"

TEDINFO rs_tedinfo[] = {
"00100",
"Size:_____K",
"99999",
3, 6, 2, 0x1073, 0x0, -2, 6,12,
" Enter ramdisk size, then select",  /*THERE IS A CTRL-C AT END*/
"",
"",
3, 6, 0, 0x1180, 0x0, -1, 39,1,
" Type in the size you desire",  /*THERE IS A CTRL-C HERE*/
"",
"",
3, 6, 0, 0x1180, 0x0, -1, 39,1,
" To free ramdisk memory, select", /*THERE IS A CTRL-C HERE*/
"",
"",
3, 6, 0, 0x1180, 0x0, -1, 39,1,
" First enter new size, then select", /*THERE IS A CTRL-C HERE*/
"",
"",
3, 6, 0, 0x1180, 0x0, -1, 39,1};

OBJECT rs_object[] = {
-1, 1, 15, G_BOX, NONE, OUTLINED, 0x21143L, 0,0, 576,160,
4, 2, 3, G_BOX, NONE, NORMAL, 0x11172L, 360,48,184,80,
3, -1, -1, G_BUTTON, 0x5, 0x28, "Deallocate Ramdisk", 16,32,152,16,
1, -1, -1, G_BUTTON, 0x5, 0x28, "Resize Ramdisk", 16,64,152,16,
8, 5, 7, G_BOX, NONE, SHADOWED, 0xFE1142L, 376,16,152,16,
6, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL, &rs_tedinfo[0], 24,0,104,16,
7, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x4000142L, 136,0,8,16,
4, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x3000142L, 8,0,8,16,
9, -1, -1, G_BUTTON, 0x7, NORMAL, "EXIT", 136,144,56,16,
10, -1, -1, G_STRING, NONE, NORMAL, "Program by", 40,144,88,16,
11, -1, -1, G_STRING, NONE, NORMAL, "Michael Vederman", 208,144,128,16,
12, -1, -1, G_BOXTEXT, NONE, NORMAL, &rs_tedinfo[1], 32,48,312,16,
13, -1, -1, G_BOXTEXT, NONE, NORMAL, &rs_tedinfo[2], 32,16,312,16,
14, -1, -1, G_BOXTEXT, NONE, DISABLED, &rs_tedinfo[3], 32,80,312,16,
15, -1, -1, G_BOXTEXT, NONE, DISABLED, &rs_tedinfo[4], 32,112,312,16,
0, -1, -1, G_BUTTON, 0x25, SHADOWED, "Allocate Ramdisk", 376,48,152,16};

#define RAM DISK 0
#define SIZEBOX 5
#define ALOCSTR 11
#define DALOCSTR 13
#define RESIZSTR 14
#define ALOCBOX 15
#define DALOCBOX 2
#define RESIZBOX 3
#define GOODBYE 8

struct bpb
{ WORD recsiz,
       clsiz,
       clsizb,
       rdlen,
       fsiz,
       fatrec,
       datrec,
       numcl,
       bflags;
};



typedef LONG (*PL)();  /*pointer to function returning a long*/
typedef WORD (*PW)();  /*pointer to a function returning a word*/

PL getbpb;
PW mediach;
PL rwabs;

struct bpb rdiskbpb = { 512, 1, 512, 7, 5, 6, 18, 0, 0, +;

/*The 1 after 512 above will give you 1 sector clusters, for more useable
'DISK' space, you can do the same to the boot sector of a disk after you
format it, but before you write to it, by changing the second 02 (I
believe it is byte 12 offset) to a 01.  Using the extended formatter
you can get quite a lot of extra disk space.*/

char

alert1[]="[3][YOU HAVE TRIED TO ALLOCATE|TOO MUCH MEMORY. THE MAXIMUM|\
SIZE HAS BEEN ALLOCATED|CHECK DISK D INFO FOR SIZE][ Time to upgrade ]",
alert2[]="[3][COULD NOT ALLOCATE|TRY REBOOTING][ Oh Well... ]",
alert3[]="[1][Memory Allocated][ Thanks ]",
alert4[]="[0][Michael Vederman|15319 Tonya|Houston, Tx 77060|UHACE BBS+
 713-820-6120][ A U of H ACEware +",
alert5[]="[0][Memory Deallocate|does not work right|due to GEMDOS bugs.|\
You can reallocate up|to 1K less than before][ OK ]",
alert6[]="[0][Ramdisk Resize| |(under construction)][ OK ]",
alert7[]="[0][No memory allocated| |  Enter size and|    try again][ OK ]",
alert8[]="[1][Allocate ramdisk FIRST| |Then install drive D][ SURE ]";

extern	int gl_apid;

int	*ramdisk_ptr;

long	size, newmaxsize;

long 	*bpbvect = 0x472;
long 	*rwvect  = 0x476;
long 	*mcvect  = 0x47e;
long 	*devset  = 0x4c2;

long    maxsize,newsize;

char     ok, in_place, dinstal;

int event

int	gl_hchar, gl_wchar, gl_wbox, gl_hbox,
    menu_id, phys_handle, handle, wi_handle,
	xdesk, ydesk, hdesk, wdesk, xold, yold, hold, wold,
	xwork, ywork, hwork, wwork,
    msgbuff[8], ret,
	contrl[12], intin[128], ptsin[128], intout[128], ptsout[128],
	work_in[11], work_out[57];	

int    fo_cx, fo_cy, fo_cw, fo_ch,
	fo_doreturn;
/**************************************************************************/
/*This is the ramdisk read/write abs routine*/

LONG rdrwabs(rw,buf,count,recno,dev)
WORD rw;
int *buf;
WORD count, recno, dev;
{  int i, *p;

   if (dev != 3) /*Drive D -- could be 2 for C, etc...*/
      return( (*rwabs)(rw,buf,count,recno,dev) );
   else
   { if (rw > 1) rw -=2; /* function number never > 1 */
     while ( count > 0 )
     {  p = ramdisk_ptr+(((long) recno) * 256L);
        if (rw==0) /* read */
          for (i=0; i<256; i++) *buf++ = *p++;
        else      /* write */
          for (i=0; i<256; i++) *p++ = *buf++;
        count--; recno++;
     }
     return(0L); /* everything worked (everything ALWAYS works!) */
   }
}

/**************************************************************************/
LONG rdgetbpb(dev) /* get our BPB -- this describes certain attributes */
WORD dev;
{
   if (dev != 3)
      return( (*getbpb)(dev) ); /* real disk BPB */
   else
      return( &rdiskbpb ); /* ramdisk BPB */
}

/**************************************************************************/

WORD rdmediach(dev) /* has the media changed -- ramdisk reinitted? */
WORD dev;
{
   if (dev != 3)
      return((*mediach)(dev)) ;
   else
     if (dinstal){ dinstal=FALSE; return( 2 );}
     else
       return( 0 ); /* if ramdisk just installed then get bpb else no */
}

/**************************************************************************/
clear_fat()  /* erase any erroneous junk */
{
char	*temp;

	for(temp=ramdisk_ptr; temp < ramdisk_ptr+9216; temp++)
		*temp = 0;
}
/**************************************************************************/

install()  /* install ramdisk handler vectors */
{
         getbpb  = (PL) *bpbvect;
         mediach = (PW) *mcvect;
         rwabs   = (PL) *rwvect;
		*bpbvect = rdgetbpb;
		*mcvect  = rdmediach;
		*rwvect  = rdrwabs;
         *devset  = *devset | (0x8L);  /* set drive bits - 0x4L for C, etc. */
}
/*************************************************************************/
deinstall()  /* very interesting little fact:  ROM TOS does not re-init
              the vectors, so if you reset, ramdisk is still installed
              unless you do a xbios(38, deinstall) in main() */


{
         *bpbvect = 0x472;
         *mcvect  = 0x47e;
         *rwvect  = 0x476;
         *devset  = *devset & 0xfffffff7L; /* clear drive bits */
}
/*************************************************************************/

main()
{
	appl_init();
	phys_handle=graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	menu_id=menu_register( gl_apid,"  Mike's Ramdisk " );
/* put name into desk menu */

	wind_get( 0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
/* get max size of window */

    xbios(38, deinstall); /* deinstall vectors (just in case of reset)*/
    in_place = FALSE; /* ramdisk is not installed yet (for alert box) */
	wi_handle=(-1);
	start();
}
/**************************************************************************/
LONG atoi(s) /* convert the size entered by user to integer */
char s[];

{
WORD     n, i;
		
	for(i=0, n=0; s[i] >= '0' && s[i] <= '9' && i < 5; ++i)
		n = 10 * n +s[i] - '0';
	return(n);
}	

/**************************************************************************/
do_ramdisk()
{
	ok = FALSE;
 	maxsize = Malloc(-1L);
	size=atoi(rs_tedinfo[0].te_ptext);

/* In the following, we should probably limit the max size so as to not
screw up the system, but what the heck, you can allocate all your
memory, but for safety sake, it should be about 50-60K less */

		if (size)
		    {
			newsize=(size+9)*1024;
			newmaxsize = maxsize/1024-9;
			   if ( newsize > maxsize )
			     {
				form_alert(1,&alert1);
				newsize=maxsize;
				size=newmaxsize;
			     }
			ramdisk_ptr = Malloc(newsize);
			if (ramdisk_ptr)
			    {
				in_place=TRUE;
                   rdiskbpb.numcl=(WORD)size * 2;
				clear_fat();
				xbios(38,install);
				form_alert(1,&alert3);
				ok = TRUE;
			    }
			else
				form_alert(1,&alert2);
		     }
		else
			form_alert(1,&alert7);
}
/**************************************************************************/
open_vwork()  /* standard stuff */
{
int i;
	for( i=0; i<10; work_in[i++]=1 ); work_in[10]=2;
	handle=phys_handle;
	v_opnvwk( work_in, &handle, work_out );
}

/*********************************************************************/

clear_window()
/* paint it white (could be a good song if it was black) */
{
int temp[4];
    graf_mouse(M_OFF,0x0L);/* mistake by many programs leaves mouse on */
	vsf_interior(handle,2);
	vsf_style(handle,8);
	vsf_color(handle,0);
	temp[0]=xwork;
	temp[1]=ywork;
	temp[2]=xwork+wwork;
	temp[3]=ywork+hwork;
	v_bar(handle,temp);
	graf_mouse(M_ON,0x0L);
}
/**************************************************************************/

open_window()
{
	wi_handle=wind_create( NAME, xdesk, ydesk, wdesk, hdesk );
	wind_set( wi_handle, WF_NAME," Mike's Ramdisk v 0.9 ", 0, 0 );
	graf_growbox( 15, 27, 160,8, xdesk, ydesk, wdesk,hdesk );
    wind_open( wi_handle, xdesk, ydesk, wdesk - 1, hdesk - 1 );
    wind_get( wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork );
}

/**************************************************************************/
remove_rdisk() /* see ya later ramdisk */
{
rdiskbpb.numcl=(int)0;
xbios(38, deinstall);
dinstal=TRUE;
Mfree(ramdisk_ptr);
}

/**************************************************************************/

open_dialog()
{
int c;

/* This routine does a lot.  It probably could have been done easier
by direct assignment to the structure, but standard system calls never
hurt. (gag) It opens a dialog box into our window, then does a form_do,
indicating one editable field, which makes it wait for something to
happen.  Then it does whatever the return code tells it.  I tried for
the longest time to get the fmd_finish to erase the dialog, but it
doesn't.  It merely pipes a message, you have to do a redraw manually!!
Which means you better know VDI.  I cheated by getting rid of the whole
window, in this way it has to redraw the desktop, automatically. */

	clear_window(wi_handle);
	form_center(rs_object, &fo_cx, &fo_cy, &fo_cw, &fo_ch);
  	form_dial(FMD_START,xdesk,ydesk,wdesk,hdesk,fo_cx, fo_cy, fo_cw, fo_ch);
	objc_draw(rs_object,0,15,fo_cx,fo_cy,fo_cw,fo_ch);
	if (!in_place)
		form_alert(1,&alert8);
	fo_doreturn=form_do(rs_object, SIZEBOX);
	form_dial(FMD_FINISH,xdesk,ydesk,wdesk,hdesk,fo_cx,fo_cy,fo_cw,fo_ch);

	switch (fo_doreturn)
		{
		  case ALOCBOX:
			{

			do_ramdisk();
			if (ok){
			objc_change(rs_object, ALOCBOX, 0,
			            xdesk, ydesk, wdesk,hdesk,
				    SHADOWED+DISABLED, 0);
			objc_change(rs_object, ALOCSTR, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    DISABLED, 0);
			objc_change(rs_object, DALOCSTR, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    NORMAL, 0);
			objc_change(rs_object, RESIZSTR, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    NORMAL, 0);
			objc_change(rs_object, DALOCBOX, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    NORMAL|SHADOWED, 0);
			objc_change(rs_object, RESIZBOX, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    NORMAL|SHADOWED, 0);
				}
			else
			objc_change(rs_object, ALOCBOX, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    NORMAL|SHADOWED, 0);
			}
		break;

		case RESIZBOX:
			{
			objc_change(rs_object, RESIZBOX, 0,
				    xdesk, ydesk, wdesk, hdesk,
				    NORMAL|SHADOWED, 0);
			form_alert(1,&alert6);
			}
		break;
			
		case DALOCBOX:
			{
			remove_rdisk();
              objc_change(rs_object, ALOCBOX, 0,
				    xdesk, ydesk, wdesk,hdesk,
				    NORMAL|SHADOWED, 0);
			objc_change(rs_object, ALOCSTR, 0,
				    xdesk, ydesk, wdesk,hdesk,
				    NORMAL, 0);
			objc_change(rs_object, DALOCBOX, 0,
				    xdesk, ydesk, wdesk,hdesk,
				    DISABLED|SHADOWED, 0);
			objc_change(rs_object, DALOCSTR, 0,
				    xdesk, ydesk, wdesk,hdesk,
				    DISABLED, 0);
			objc_change(rs_object, RESIZBOX, 0,
				    xdesk, ydesk, wdesk,hdesk,
				    DISABLED|SHADOWED, 0);
			objc_change(rs_object, RESIZSTR, 0,
				    xdesk, ydesk, wdesk,hdesk,
				    DISABLED, 0);
			form_alert(1,&alert5);
			}
		break;

		case GOODBYE:
		    {
			form_alert(1, &alert4);
			objc_change(rs_object, GOODBYE, 0,
			            xdesk, ydesk, wdesk,hdesk,
				    NORMAL, 0);
		    }
		break;

	}

	wind_close(wi_handle);
	graf_shrinkbox(15,27,160,8, xdesk, ydesk, wdesk, hdesk );
	wind_delete(wi_handle);

	msgbuff[0]=AC_CLOSE;
	msgbuff[3]=menu_id;
	wi_handle=(-1);

}
/***************************************************************************/

start()
{

	while (TRUE)
	{
	  event=evnt_multi( MU_MESAG,
			1, 1, ret,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			msgbuff, 0, 0, &ret, &ret, &ret, &ret, &ret, &ret );

	  if ( event & MU_MESAG )
		switch( msgbuff[0] )
		{

		  case AC_OPEN:
		    if (msgbuff[4]==menu_id)
		    {
			if (wi_handle==(-1))
				 { open_vwork();
				 open_window();
				 open_dialog(); }
		    }
		  break;

		  case AC_CLOSE:
		    if ((msgbuff[3]==menu_id) && (wi_handle != (-1) ))
			{ v_clsvwk(handle); wi_handle=(-1); }
		  break;

		}
	}
}

