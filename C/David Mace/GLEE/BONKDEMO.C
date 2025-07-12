/*
 * Davebonk- By David Mace August, 1990
 * Program to bounce my head around using GLEE files
 *
 */

#include <aesbind.h>
#include <gemdefs.h>
#include <vdibind.h>
#include <bonkdemo.h>
#include <osbind.h>

 /* VDI declarations */
int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int work_in[]={1,1,1,1,1,1,1,1,1,1,2};
int work_out[57];
int vh; /* VDI handle */
long noplace; /* My favorite trash pointer */

FDB sform,screen={0L,0,0,0,0,0,0,0,0};
int swd,sht,spl;

main()
{
	appl_init();
	graf_mouse(M_OFF,&noplace);
	vh=graf_handle(&noplace,&noplace,&noplace,&noplace);	
	v_opnvwk(work_in,&vh,work_out);

/* Find out what screen looks like- Who cares what rez? */
	swd=work_out[0];
	sht=work_out[1];
	vq_extnd(vh,1,work_out);
	spl=work_out[4];

	v_clrwk(vh);

/* Set up source memory form block def */
	sform.fd_addr=(long)form;
	sform.fd_w=gwidth;
	sform.fd_h=gheight;
	sform.fd_wdwidth=gwdwidth;
	sform.fd_stand=gstand;
	sform.fd_nplanes=gplnz;
	sform.fd_r1=0;
	sform.fd_r2=0;
	sform.fd_r3=0;

	bonker();

	quit();
}

/* Exit gracefully */
quit()
{
	graf_mouse(M_ON,&noplace);
	v_clsvwk(vh);
	appl_exit();
	exit(0);
}

/* Main program loop- bounce my head around */
bonker()
{
/* Event_multi defs */
int e,buf[8],mx,my,mb,mk,timebase=50,key,t;
Mouse ms={&mx,&my,&mb,&mk};

/* Movement and animation defs */
int xp=swd/2,yp=sht/2,ch=DAVE01;
int xd=-5,yd=5,rd=1;
int ouchflag=0,ouchd=OWLLC;

do	{
	dispblk(xp,yp,ch,1); /* Display my face */
	if(ouchflag>0)	/* Say 'ouch' if appropriate */
		dispblk(xp,yp,ouchd,1);

	e=evnt_multi(0x21,0,0,0,0,0,0,0,0,0,0,0,0,0,buf,timebase,0,ms,&key,&t);
	dispblk(xp,yp,ch,0); /* Clear my face */
	if(ouchflag>0)	/* Clear 'ouch' */
		{
		dispblk(xp,yp,ouchd,0);
		ouchflag--; /* decrement ouchflag counter */
		}

	xp+=xd; /* Keep head moving */
	yp+=yd;
	ch=ch+rd; /* Keep head rolling */
	if(ch>DAVE16)
		ch=DAVE01;
	if(ch<DAVE01)
		ch=DAVE16;

	if(xp+defs[ch].xo<0)
		{
		xp=-defs[ch].xo;
		xd=5; /* Move head right */
		rd=-1; /* Roll head in other direction */
		ouchflag=8; /* Say 'Ouch!' for 400ms */
		if(yp>sht/2) /* Calculate where ouch balloon should be */
			ouchd=OWURC;
		else
			ouchd=OWLRC;
		}
	if((xp+defs[ch].w+defs[ch].xo)>swd)
		{
		xp=swd-defs[ch].w-defs[ch].xo-1;
		xd=-5; /* Move head left */
		rd=1; /* Roll head in other direction */
		ouchflag=8; /* Say 'Ouch!' for 400ms */
		if(yp>sht/2)
			ouchd=OWULC;
		else
			ouchd=OWLLC;
		}

	if(yp+defs[ch].yo<0)
		{
		yp=-defs[ch].yo;
		yd=5; /* Move head down */
		ouchflag=8; /* Say 'Ouch!' for 400ms */
		if(xp>swd/2)
			ouchd=OWLLC;
		else
			ouchd=OWLRC;
		}
	if((yp+defs[ch].h+defs[ch].yo)>sht)
		{
		yp=sht-defs[ch].h-defs[ch].yo-1;
		yd=-5; /* Move head up */
		ouchflag=8; /* Say 'Ouch!' for 400ms */
		if(xp>swd/2)
			ouchd=OWULC;
		else
			ouchd=OWURC;
		}

	if(e&1)
		{
		switch(key>>8)
			{
			case 0x3b:
				timebase=1;
			break;
			case 0x3c:
				timebase=50;
			break;
			case 0x3d:
				timebase=75;
			break;
			case 0x3e:
				timebase=100;
			break;
			case 0x3f:
				timebase=140;
			break;
			case 0x40:
				timebase=180;
			break;
			case 0x41:
				timebase=220;
			break;
			case 0x42:
				timebase=260;
			break;
			case 0x43:
				timebase=300;
			break;
			case 0x44:
				timebase=500;
			break;
			case 0x61:
				quit();
			break;
			case 0x62:
				graf_mouse(M_ON,&noplace);
				form_alert(1,"[0][\
DaveBonk Demo|By David Mace  | |F1-F10 Speed|Undo quits.][OK]");
				graf_mouse(M_OFF,&noplace);
				v_clrwk(vh);
			break;
			}
		}
	} while(1);
}

/* Draw (showflag=1) or clear (showflag=0) a block at X,Y */
dispblk(x,y,blk,showflag)
	int x,y,blk,showflag;
{
static int xya[8];
static FDB s,d;
static int showcolors[]={1,0};
static int hidecolors[]={0,0};

	s=sform;
	d=screen;

	/* Set up object centering offsets */
	x+=defs[blk].xo;
	y+=defs[blk].yo;

	/* Set up raster coordinate array */
	xya[0]=defs[blk].x;
	xya[1]=defs[blk].y;
	xya[2]=defs[blk].x+defs[blk].w-1;
	xya[3]=defs[blk].y+defs[blk].h-1;
	xya[4]=x;
	xya[5]=y;
	xya[6]=x+defs[blk].w-1;
	xya[7]=y+defs[blk].h-1;

	if(spl==1)
		{
		if(showflag)
			vro_cpyfm(vh,3,xya,&s,&d);
		else
			vro_cpyfm(vh,0,xya,&s,&d);
		}
	else
		{
		if(showflag)
			vrt_cpyfm(vh,1,xya,&s,&d,showcolors);
		else
			vrt_cpyfm(vh,1,xya,&s,&d,hidecolors);
		}
}

