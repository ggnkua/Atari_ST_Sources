/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module EVENT : Event Handling

	do_mouse, do_key, do_menu, do_midi

	do_hotspot, do_vslide, do_hslide, do_varrow, do_harrow,
	do_area, do_mainclip, do_studio

	do_patch, do_range, do_drag, do_hot

	sel_side, patch_sel, sel_allpats, comp_windcnxs, scrollStudio
	set_v_home, set_h_home

******************************************************************************/

overlay "event"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */
#include "scan.h"			/* keyboard scan codes */

extern int ndatabyte[];	/* in monitor.c */

/* handle mouse button clicked on main screen ...............................*/
/* returns 0 to allow mouse repeat, 1 to prevent */

do_mouse(x,y,mstate)
int x,y;		/* mouse position */
int mstate;	/* button state:  1= left, else right */
{
	kill_exec(1);	/* copy protection */
	mstate= _do_mouse(x,y,mstate);
	kill_exec(0);	/* copy protection */
	return mstate;
}

_do_mouse(x,y,mstate)
int x,y;		/* mouse position */
int mstate;	/* button state:  1= left, else right */
{
	register int i,temp;
	int kstate;

	/* alt/ctrl/shift */
	kstate= Kbshift(-1) & 0x0F;

	for (i=0; i<2; i++)
	{
		/* clicked on vertical slider ? */
		if (in_rect(x,y,vslide_x[i],vslide_y[i],vslide_w[i],vslide_h[i]))
			return do_vslide(i,kstate);

		/* clicked on horizontal slider ? */
		if (in_rect(x,y,hslide_x[i],hslide_y[i],hslide_w[i],hslide_h[i]))
			return do_hslide(i,kstate);

		/* clicked on vertical scroll bar ? */
		if (in_rect(x,y,vscroll_x[i],vscroll_y,vscroll_w,vslide_y[i]-vscroll_y))
			return do_varrow(i,-window_h,kstate);
		temp= vslide_y[i] + vslide_h[i];
		if (in_rect(x,y,vscroll_x[i],temp,vscroll_w,vscroll_y+vscroll_h-temp))
			return do_varrow(i,window_h,kstate);

	/* clicked on horizontal scroll bar ? */
		temp= hscroll_x[i];
		if (in_rect(x,y,temp,hscroll_y,hslide_x[i]-temp,hscroll_h))
			return do_harrow(i,-window_w/2,kstate);
		temp= hslide_x[i] + hslide_w[i];
		if (in_rect(x,y,temp,hscroll_y,hscroll_x[i]+hscroll_w-temp,hscroll_h))
			return do_harrow(i,window_w/2,kstate);

	/* clicked on up/down arrow ? */
		if (in_rect(x,y,vscroll_x[i],up_y,vscroll_w,up_h))
			return do_varrow(i,-1,kstate);
		if (in_rect(x,y,vscroll_x[i],down_y,vscroll_w,down_h))
			return do_varrow(i,1,kstate);

	/* clicked on left/right arrow ? */
		if (in_rect(x,y,left_x[i],hscroll_y,left_w,hscroll_h))
			return do_harrow(i,-1,kstate);
		if (in_rect(x,y,right_x[i],hscroll_y,right_w,hscroll_h))
			return do_harrow(i,1,kstate);

	/* clicked within window work area ? */
		if (in_rect(x,y,area_x[i],area_y,area_w,area_h))
			return do_area(i,mstate,kstate,x,y);
	}	/* end for i=0 to 1 */

	/* clicked on clipboard ? */
	if (in_rect(x,y,mainclip_x,mainclip_y,mainclip_w,mainclip_h))
		return do_mainclip(mstate,kstate);

	/* clicked on studio description ? */
	if (in_rect(x,y,studio_x1,studio_y1,studio_x4-studio_x1,studio_y3-studio_y1))
		return do_studio(mstate,kstate,x,y);

	/* clicked on window title, disk icon, midi icon ? */
	for (i=0; i<NHOTSPOTS; i++)
		if (in_rect(x,y,hotspotx[i],hotspoty[i],hotspotw[i],hotspoth[i]))
			return do_hotspot(i,mstate,kstate);

	/* clicked nowhere: deselect all patches */
	temp= sel_side();
	if (temp>=0) sel_allpats(temp,0);
	return 1;

}	/* end _do_mouse() */

/* handle mouse button clicked on main clipboard ............................*/
/* returns 1 to prevent mouse repeat */

do_mainclip(mstate,kstate)
int mstate;	/* button state:  1= left, else right */
int kstate;	/* keyboard modifier keys */
{
	int side,pat,nhot,npats;
	int wind1[2],windn[2];
	register int i,temp;
	int *hotx,*hoty,*hotw,*hoth,*hotpat;
	long templong;
	int x1,y1,w1,h1;
	char tempbuf1[80];

	/* re-use scrsave for hot spot arrays */
	hotx= (int*)(scrsave);
	hoty= hotx + 100;
	hotw= hotx + 200;
	hoth= hotx + 300;
	hotpat= hotx + 400;

	templong= heap[mainclpmem].nbytes;
	if (!templong) return 1;	/* clipboard is empty */

	if (mstate!=1)
	{
		ltoa(templong,tempbuf1,-1);
		strcat(tempbuf1,SHOWCLPMSG);
		menuprompt(tempbuf1);
		Crawcin();
		menuprompt(0L);
		return 1;
	}

	if (kstate==K_ALT)
	{
		if (form_alert(1,CHEKCLRCLIP)==1) change_mem(mainclpmem,0L);
	}
	if (!kstate)
	{
		x1= mainclip_x;
		y1= mainclip_y;
		w1= mainclip_w;
		h1= mainclip_h;
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(mainclip_x,mainclip_y,mainclip_w,mainclip_h,1);
		vswr_mode(gl_hand,MD_REPLACE);

		/* set up hot spots for allowable destinations -- */
		nhot=0;
		for (side=0; side<2; side++)
		{
			npats= min(window_h,npatches[side]-homepatch[side]);
			wind1[side]= windn[side]= -1;
			for (i=0; i<npats; i++)
			{
				temp= homepatch[side] + i;
				if (wind1[side]<0) wind1[side]=nhot;
				windn[side]= nhot;
				hotpat[nhot]= temp;
				hotx[nhot]= charw * (window_x[side]-1) + (side==0) ;
				hoty[nhot]= window_y + i*charh;
				hotw[nhot]= charw * (window_w+2) - 1;
				hoth[nhot++]= charh;
			}	/* end for patches */
		}	/* end for sides */

		slide_box(&x1,&y1,w1,h1,0,0,640,200*rez,
						nhot,hotx,hoty,hotw,hoth,hotx,hoty,hotw,hoth);
		getmouse(&x1,&y1);

		vswr_mode(gl_hand,MD_XOR);
		fill_rect(mainclip_x,mainclip_y,mainclip_w,mainclip_h,1);
		vswr_mode(gl_hand,MD_REPLACE);

		/* find which hot spot x1,y1 is in */
		for (i=0; i<nhot; i++)
			if (in_rect(x1,y1,hotx[i],hoty[i],hotw[i],hoth[i])) break;
		if (i==nhot) return 1;
		for (side=0; side<2; side++)
			if ((i>=wind1[side])&&(i<=windn[side])) break;
		if (side==2) return 1;

		pat= hotpat[i];
		if (copy_mem(mainclpmem,editmem))
		{
			if (putpgetp((int)(cnxETOD),side,pat))
			{
				change_flag[side ? rdatCHANGE : ldatCHANGE]= 1;
				build_1name(side,pat);
				draw_names(side,pat);
			}
			change_mem(editmem,0L);	/* shrink edit buffer */
		}
	}	/* end if !kstate */
	return 1;
}	/* end do_mainclip() */

/* handle mouse button clicked on studio description ........................*/
/* returns 1 to prevent mouse repeat, else 0 */

do_studio(mstate,kstate,x,y)
int mstate;	/* button state:  1= left, else right */
int kstate;	/* keyboard modifier keys */
int x,y;		/* mouse coordinate */
{
	register temp,which;

	/* scroll studio description window */
	temp= 0;
	if ((x>=studio_x1)&&(x<studio_x2)&&(y>=studio_y1)&&(y<studio_y2))
		temp= -1; /* up */
	if ((x>=studio_x3)&&(x<studio_x4)&&(y>=studio_y1)&&(y<studio_y2))
		temp=  1; /* down */
	if (mstate!=1) temp *= NDEVPERSCR; /* r-click by page */
	if (temp)
	{
		if ( scrollStudio(temp) )
		{
			return (mstate==1) ? 0 : 1; /* L-click auto-repeats */
		}
		return 1;
	}

	/* init studio description */
	if ((x>=studio_x2)&&(x<studio_x3)&&(y>=studio_y1)&&(y<studio_y2))
	{
		if ((kstate==K_ALT)&&(mstate==1)) init_studio(-1);
		return 1;
	}

	/* which studio slot clicked on? */
	which= (y-studio_y2)/(10*rez);
	if ((which<0)||(which>=NDEVPERSCR)) return 1;
	/* R-click = edit it */
	if ((kstate==0)&&(mstate!=1))
	{
		if (edit_studio(which+studioHome))
		{
			draw_studio(which);
			change_flag[stuCHANGE]= 1;
		}
		return 1;
	}
	/* alt-left-click = init it */
	if ((kstate==K_ALT)&&(mstate==1))
	{
		if (form_alert(1,CHEKCLRST1)==1)
		{
			init_studio(which+studioHome);
			draw_studio(which);
			change_flag[stuCHANGE]= 1;
		}
		return 1;
	}
	/* control-left-click = insert */
	if ((kstate==K_CTRL)&&(mstate==1))
	{
		for (temp= NDEVICES-1; temp>=(which+studioHome+1); temp--)
		{
			studioDev[temp]= studioDev[temp-1];
			studioLink[temp]= studioLink[temp-1];
		}
		init_studio(which+studioHome);
		draw_studio(-1);
		change_flag[stuCHANGE]= 1;
		return 1;
	}

	/* control-right-click = delete */
	if ((kstate==K_CTRL)&&(mstate!=1))
	{
		for (temp= which+studioHome+1; temp<NDEVICES; temp++)
		{
			studioDev[temp-1]= studioDev[temp];
			studioLink[temp-1]= studioLink[temp];
		}
		init_studio(NDEVICES-1);
		draw_studio(-1);
		change_flag[stuCHANGE]= 1;
		return 1;
	}

	/* drag from it */
	if ((kstate==0)&&(mstate==1))
		return do_hotspot(which+NHOTSPOTS,mstate,kstate);

	return 1;

}	/* end do_studio() */

/* handle mouse left button clicked on a selected patch .....................*/
/* returns 1 to prevent mouse repeat */

do_patch(side,mx,my)
int side;	/* 0= left, 1= right */
int mx,my;
{
	register int i,temp;
	int line,pat1,pat2,npats,to_side;
	int x1,y1,w1,h1;
	int nhot;
	int *hotx,*hoty,*hotw,*hoth,*hotpat;
	int thiswind1,thiswindn,otherwind1,otherwindn;
	int edit2mem;
	int device1n;

	/* re-use scrsave for hot spot arrays */
	hotx= (int*)(scrsave);
	hoty= hotx + 100;
	hotw= hotx + 200;
	hoth= hotx + 300;
	hotpat= hotx + 400;

	/* range of patches to be dragged */
	line= (my-window_y) / charh ;
	pat1= line + homepatch[side];
	for (; pat1>=homepatch[side]; pat1--) if (!patchselect[side][pat1]) break;
	pat1++;
	npats= min(window_h,npatches[side]-homepatch[side]);
	for (pat2=pat1; pat2<npats+homepatch[side]; pat2++)
		if (!patchselect[side][pat2]) break;
	pat2--;

	if (pat1!=pat2) return do_range(side,pat1,pat2);

	/* position and size of patch being dragged */
	x1= charw*window_x[side];
	y1= window_y + charh*line;
	w1= charw*window_w;
	h1= charh;

	/* hack mouse y coordinate to center of patch -- safer for dragging */
	setmouse(-1,y1+h1/2);

	/* set up hot spots for allowable destinations -- */
	nhot=0;
	/* -- to midi */
	hotx[nhot]= hotspotx[H_MIDI];
	hoty[nhot]= hotspoty[H_MIDI];
	hotw[nhot]= hotspotw[H_MIDI];
	hoth[nhot++]= hotspoth[H_MIDI];
	/* -- to same/other window title (only if that window contains patches) */
	hotx[nhot]= npatches[0] ? hotspotx[H_LWIND] : -1 ;
	hoty[nhot]= npatches[0] ? hotspoty[H_LWIND] : -1 ;
	hotw[nhot]= npatches[0] ? hotspotw[H_LWIND] : -1 ;
	hoth[nhot++]= npatches[0] ? hotspoth[H_LWIND] : -1 ;
	hotx[nhot]= npatches[1] ? hotspotx[H_RWIND] : -1 ;
	hoty[nhot]= npatches[1] ? hotspoty[H_RWIND] : -1 ;
	hotw[nhot]= npatches[1] ? hotspotw[H_RWIND] : -1 ;
	hoth[nhot++]= npatches[1] ? hotspoth[H_RWIND] : -1 ;
	/* -- to clipboard */
	hotx[nhot]= mainclip_x;
	hoty[nhot]= mainclip_y;
	hotw[nhot]= mainclip_w;
	hoth[nhot++]= mainclip_h;
	/* -- to other patches in same window */
	npats= min(window_h,npatches[side]-homepatch[side]);
	thiswind1= thiswindn= -1;
	for (i=0; i<npats; i++)
	{
		temp= homepatch[side] + i;
		if (temp!=pat1)
		{
			if (thiswind1<0) thiswind1=nhot;
			thiswindn= nhot;
			hotpat[nhot]= temp;
			hotx[nhot]= charw * (window_x[side]-1) + (side==0) ;
			hoty[nhot]= window_y + i*charh;
			hotw[nhot]= charw * (window_w+2) - 1 ;
			hoth[nhot++]= charh;
		}
	}
	/* -- to patches in other window */
	npats= min(window_h,npatches[!side]-homepatch[!side]);
	otherwind1= otherwindn= -1;
	for (i=0; i<npats; i++)
	{
		if (otherwind1<0) otherwind1=nhot;
		otherwindn= nhot;
		hotpat[nhot]= homepatch[!side] + i;
		hotx[nhot]= charw * (window_x[!side]-1) + (side==1) ;
		hoty[nhot]= window_y + i*charh;
		hotw[nhot]= charw * (window_w+2) - 1 ;
		hoth[nhot++]= charh;
	}
	/* -- to devices in studio setup */
	device1n=nhot;
	for (i=0; i<NDEVPERSCR; i++,nhot++)
		hot_to_xywh(i+NHOTSPOTS,&hotx[nhot],&hoty[nhot],&hotw[nhot],&hoth[nhot]);

	slide_box(&x1,&y1,w1,h1,0,0,640,200*rez,
				nhot,hotx,hoty,hotw,hoth,hotx,hoty,hotw,hoth);
	if (getmouse(&x1,&y1)==3)
		i=0;	/* "both"-click = to midi */
	else		/* find which hot spot x1,y1 is in */
	{
		for (i=0; i<nhot; i++)
			if (in_rect(x1,y1,hotx[i],hoty[i],hotw[i],hoth[i])) break;
		if (i==nhot) return 1;
	}

	switch (i)
	{
		case 0:					/* to midi */
		if (putpgetp((int)(cnxDTOE),side,pat1))
			edittomidi(side);
		break;

		case 1:					/* to left window title */
		case 2:					/* to right window title */
		to_side= i==2 ;		/* 0= left, 1= right */
		if (side!=to_side)	/* warning if incompatible cnx's */
			if (comp_windcnxs())
				if (form_alert(2,CHEKCNXDIF)!=1) break;
		edit2mem= alloc_mem(0L);
		if (edit2mem<0) break;
		if (putpgetp((int)(cnxGETP),side,pat1))
		{
			if (copy_mem(editmem,edit2mem))
			{
				graf_mouse(BEE_MOUSE);
				for (i=0; i<npatches[to_side]; i++)
				{
					/* note: edit buffer must be restored from edit2mem repeatedly
						because PUTP might destroy it */
					if (!copy_mem(edit2mem,editmem)) break;
					if (!putpgetp((int)(cnxPUTP),to_side,i)) break;
					build_1name(to_side,i);
				}
				change_flag[to_side ? rdatCHANGE : ldatCHANGE]= 1;
				draw_names(to_side,-1);
				graf_mouse(ARROWMOUSE);
			}	/* end if copied editmem to edit2mem */
		}
		dealloc_mem(edit2mem);
		break;

		case 3:					/* to clipboard */
		if (putpgetp((int)(cnxDTOE),side,pat1))
		{
			copy_mem(editmem,mainclpmem);
		}
		break;

		default:
		if (i>=device1n)			/* to device */
		{
			if (putpgetp((int)(cnxDTOE),side,pat1))
				edittodev(side,i-device1n+studioHome);
			break;
		}
		/* to patch in same or other window */
		to_side= -1;
		if ((i>=thiswind1)&&(i<=thiswindn)) to_side= side;
		if ((i>=otherwind1)&&(i<=otherwindn)) to_side= !side;
		if (to_side<0) break;
		/* warning if incompatible cnx's */
		if (side!=to_side)
			if (comp_windcnxs())
				if (form_alert(2,CHEKCNXDIF)!=1) break;
		if (putpgetp((int)(cnxGETP),side,pat1))
		{
			pat2= hotpat[i];
			if (putpgetp((int)(cnxPUTP),to_side,pat2))
			{
				change_flag[to_side ? rdatCHANGE : ldatCHANGE]= 1;
				build_1name(to_side,pat2);
				draw_names(to_side,pat2);
			}
		}
	}	/* end switch (i) */

	/* shrink edit buffer */
	change_mem(editmem,0L);

	return 1;
}	/* end do_patch() */

/* drag a range of patches ..................................................*/
/* returns 1 to prevent mouse repeat */

do_range(side,pat1,pat2)
int side;		/* 0= left, 1= right */
int pat1,pat2;	/* 1st and last patch # (not equal) */
{
	int *hotx,*hoty,*hotw,*hoth,*hotpat,*hotside;
	int *showh;
	int npatsdrag,nhot,npatswind,to_pat,to_side;
	int x1,y1,w1,h1;
	register int i,j,k;

	/* re-use scrsave for hot spot arrays */
	hotx= (int*)(scrsave);
	hoty= hotx + 100;
	hotw= hotx + 200;
	hoth= hotx + 300;
	hotpat= hotx + 400;
	hotside= hotx + 500;
	showh= hotx + 600;

	npatsdrag= pat2-pat1+1;	/* how many patches to be dragged */
	/* position and size of patches being dragged */
	x1= charw*window_x[side];
	y1= window_y + charh*(pat1-homepatch[side]);
	w1= charw*window_w;
	h1= charh*npatsdrag;

	/* set up destinations */
	nhot=0;
	for (j=0; j<2; j++)
	{
		npatswind= min(window_h,npatches[j]-homepatch[j]);
		for (i=homepatch[j]; i<=(homepatch[j]+npatswind-npatsdrag); i++)
		{
			for (k=i; k<(i+npatsdrag); k++) if (patchselect[j][k]) break;
			if (k==(i+npatsdrag))
			{
				k--;
				hotx[nhot]= charw * (window_x[j]-1) + (j==0) ;
				hoty[nhot]= window_y + charh*(i-homepatch[j]);
				hotw[nhot]= charw*(window_w+2) - 1 ;
				hoth[nhot]= charh;
				hotpat[nhot]= i;
				hotside[nhot]= j;
				showh[nhot++]= charh*npatsdrag;
			}
		}
	}

	slide_box(&x1,&y1,w1,h1,0,0,640,200*rez,
				nhot,hotx,hoty,hotw,hoth,hotx,hoty,hotw,showh);
	getmouse(&x1,&y1);

	/* find which hot spot x1,y1 is in */
	for (i=0; i<nhot; i++)
		if (in_rect(x1,y1,hotx[i],hoty[i],hotw[i],hoth[i])) break;
	if (i==nhot) return 1;
	to_pat= hotpat[i];
	to_side= hotside[i];
	/* warning if incompatible cnx's */
	if (side!=to_side)
		if (comp_windcnxs())
			if (form_alert(2,CHEKCNXDIF)!=1) to_side= -1;

	graf_mouse(BEE_MOUSE);
	if (to_side>=0)
	{
		for (; pat1<=pat2; pat1++,to_pat++)
		{	
			if (!putpgetp((int)(cnxGETP),side,pat1)) break;
			if (!putpgetp((int)(cnxPUTP),to_side,to_pat)) break;
			change_flag[to_side ? rdatCHANGE : ldatCHANGE]= 1;
			build_1name(to_side,to_pat);
			draw_names(to_side,to_pat);
		}
	}
	graf_mouse(ARROWMOUSE);

	/* shrink edit buffer */
	change_mem(editmem,0L);

	return 1;
}	/* end do_range() */

/* handle mouse button clicked in window work area ..........................*/
/* returns 1 to prevent mouse repeat, 0 to allow */

do_area(side,mstate,kstate,mx,my)
int side;	/* 0= left, 1= right */
int mstate;	/* button state:  1= left, else right */
int kstate;				/* keyboard modifier keys */
int mx,my;
{
	int sel,pat,line,oldpat,result=1;

	if (!npatches[side]) return 1;

	/* deselect patches in other window */
	if (patch_sel(!side)) sel_allpats(!side,0);

	/* what patch clicked on? */
	pat= (my-window_y)/charh + homepatch[side];
	if ((pat<0)||(pat>=npatches[side]))
	{
		sel_allpats(side,0);
		return 1;
	}

	/* R-click: edit */
	if (mstate==2)
	{
		if (patch_sel(side)) sel_allpats(side,0);
		patchselect[side][pat]=1;
		draw_names(side,pat);
		ex_edit(side,pat);
		return 1;
	}

	switch (kstate)
	{
		case 0:
		/* deselect any patches selected in this window, then select 1 */
		if (!patchselect[side][pat])
		{
			if (patch_sel(side)) sel_allpats(side,0);
			patchselect[side][pat]=1;
			draw_names(side,pat);
		}
		result= do_patch(side,mx,my);
		break;

		case K_LSHIFT:		/* select/deselect 1 or more patches */
		case K_RSHIFT:
		sel= !patchselect[side][pat];
		oldpat= -1;
		while (getmouse(&mx,&my))
		{
			if ((mx>=area_x[side])&&(mx<=(area_x[side]+area_w-1)))
			{
				line= (my-window_y)/charh;
				if ((line>=0)&&(line<window_h))
				{
					pat= line + homepatch[side];
					if ((pat>=0)&&(pat<npatches[side])&&(pat!=oldpat))
					{
						if (patchselect[side][pat]!=sel)
						{
							patchselect[side][pat]=sel;
							xortext(window_w,window_x[side],window_y+line*charh);
						}
					}
					oldpat=pat;
				}	/* end if mouse within window height */
			}	/* end if mouse within window width */
		}
		break;
		
		case K_CTRL:
		/* select all patches in this window */
		sel_allpats(side,1);

	}	/* end switch (kstate) */

	return result;
}	/* end do_area() */

/* handle mouse button clicked on up/down arrow .............................*/
/* returns 0 to allow mouse repeat, 1 to prevent */

do_varrow(side,dir,kstate)
int side;	/* 0= left, 1= right */
int dir;		/* >0 up, <0 down */
int kstate;
{
	int newhome,x,y,w,h;
	int result=1;

	if (!npatches[side]) return 1;
	if (vslide_h[side]==vscroll_h) return 1;

	newhome= homepatch[side]+dir;
	newhome= min(newhome,npatches[side]-1);
	newhome= max(newhome,0);

	if (newhome!=homepatch[side])
	{
		/* invert the arrow while scrolling -- purely cosmetic */
		x= vscroll_x[side];
		y= dir<0 ? up_y : down_y ;
		w= vscroll_w;
		h= dir<0 ? up_h : down_h ;
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(x,y,w,h,1);
		vswr_mode(gl_hand,MD_REPLACE);

		set_v_home(side,newhome);
		if ( kstate&(K_LSHIFT|K_RSHIFT) ) set_v_home(!side,newhome);

		/* re-invert arrow */
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(x,y,w,h,1);
		vswr_mode(gl_hand,MD_REPLACE);

		/* allow mouse repeat if scrolling by single patch */
		if ( (dir==1) || (dir==(-1)) ) result=0;
	}
	return result;
}	/* end do_varrow() */

/* set window's homepatch ...................................................*/

set_v_home(side,newhome)
int side,newhome;
{
	if (npatches[side])
	{
		homepatch[side]= min( npatches[side]-1 , newhome );
		build_vbar(side);
		draw_vbar(side);
		draw_names(side,-1);
	}
}	/* end set_v_home() */

/* set window's homechar ....................................................*/

set_h_home(side,newhome)
int side,newhome;
{
	if (npatches[side])
	{
		homechar[side]= min( nameleng[side]-1 , newhome );
		build_hbar(side);
		draw_hbar(side);
		draw_names(side,-1);
	}
}	/* end set_h_home() */

/* handle mouse button clicked on left/right arrow ..........................*/
/* returns 0 to allow mouse repeat, 1 to prevent */

do_harrow(side,dir,kstate)
int side;	/* 0= left, 1= right */
int dir;		/* <0 left, >0 right */
int kstate;
{
	int newhome,x,y,w,h;
	int result=1;

	if (!npatches[side]) return 1;
	if (hslide_w[side]==hscroll_w) return 1;

	newhome= homechar[side]+dir;
	newhome= min(newhome,nameleng[side]-1);
	newhome= max(newhome,0);

	if (newhome!=homechar[side])
	{
		/* invert the arrow while scrolling -- purely cosmetic */
		x= dir<0 ? left_x[side] : right_x[side] ;
		y= hscroll_y;
		w= dir<0 ? left_w : right_w ;
		h= hscroll_h;
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(x,y,w,h,1);
		vswr_mode(gl_hand,MD_REPLACE);

		set_h_home(side,newhome);

		/* re-invert the arrow */
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(x,y,w,h,1);
		vswr_mode(gl_hand,MD_REPLACE);

		/* allow mouse repeat if scrolling by single character */
		if ( (dir==1) || (dir==(-1)) ) result=0;
	}
	return result;
}	/* end do_harrow() */

/* handle mouse button clicked on vert slider ...............................*/
/* returns 0 to allow mouse repeat, 1 to prevent */

do_vslide(side,kstate)
int side;	/* 0= left, 1= right */
int kstate;
{
	int x1,y1,w1,h1,x2,y2,w2,h2;
	int home,ymax;

	if (!npatches[side]) return 1;

	x1= vslide_x[side];
	y1= vslide_y[side];
	w1= vslide_w[side];
	h1= vslide_h[side];
	x2= vscroll_x[side];
	y2= vscroll_y;
	w2= vscroll_w;
	h2= vscroll_h;
	slide_box(&x1,&y1,w1,h1,x2,y2,w2,h2,0,0L,0L,0L,0L,0L,0L,0L,0L);
	if (y1!=vslide_y[side])
	{
		ymax= vscroll_y + vscroll_h - vslide_h[side] ;
		if (ymax==vscroll_y) return;
		home= ((long)(y1-vscroll_y)*(long)(npatches[side]-1))/(ymax-vscroll_y);
		home= max(home,0);
		if (home!=homepatch[side])
		{
			set_v_home(side,home);
			if ( kstate&(K_LSHIFT|K_RSHIFT) ) set_v_home(!side,home);
		}
	}
	return 1;
}	/* end do_vslide() */

/* handle mouse button clicked on horz slider ...............................*/
/* returns 0 to allow mouse repeat, 1 to prevent */

do_hslide(side,kstate)
int side;	/* 0= left, 1= right */
int kstate;
{
	int x1,y1,w1,h1,x2,y2,w2,h2;
	int xmax,home,xhome;

	if (!npatches[side]) return 1;

	x1= hslide_x[side];
	y1= hslide_y[side];
	w1= hslide_w[side];
	h1= hslide_h[side];
	x2= hscroll_x[side];
	y2= hscroll_y;
	w2= hscroll_w;
	h2= hscroll_h;
	slide_box(&x1,&y1,w1,h1,x2,y2,w2,h2,0,0L,0L,0L,0L,0L,0L,0L,0L);
	if (x1!=hslide_x[side])
	{
		xhome= hscroll_x[side];
		xmax= xhome + hscroll_w - hslide_w[side] ;
		if (xmax==xhome) return;
		home= ((long)(x1-xhome)*(long)(nameleng[side]-1))/(xmax-xhome);
		if (home!=homechar[side]) set_h_home(side,home);
	}
	return 1;
}	/* end do_hslide() */

/* handle mouse button clicked on hot spot ..................................*/
/* returns 1 to prevent mouse repeat */

do_hotspot(i,st,kstate)
register int i;	/* 0..(NHOTSPOTS-1), NHOTSPOTS..(NHOTSPOTS+NDEVPERSCR-1) */
int st;				/* button state:  1= left, 2= right, 3= both */
int kstate;			/* keyboard modifier keys */
{
	int hotlist[NHOTSPOTS];
	register int j;
	int source_x,source_y,source_w,source_h;
	int dest_x[NHOTSPOTS+NDEVPERSCR];
	int dest_y[NHOTSPOTS+NDEVPERSCR];
	int dest_w[NHOTSPOTS+NDEVPERSCR];
	int dest_h[NHOTSPOTS+NDEVPERSCR];

	/* source rectangle */
	hot_to_xywh(i,&source_x,&source_y,&source_w,&source_h);

	/* destination rectangles */
	for (j=0; j<NHOTSPOTS+NDEVPERSCR; j++)
		hot_to_xywh(j,&dest_x[j],&dest_y[j],&dest_w[j],&dest_h[j]);

	/* prevent source dragged to self */
	dest_x[i]= 0x7FFF;

	switch (i)
	{
		case H_DRIVE:
		if (st>1)
			ex_paths();
		else
		{
			j= do_drag(source_x,source_y,source_w,source_h,
						  NHOTSPOTS+NDEVPERSCR,
						  dest_x,dest_y,dest_w,dest_h);
			do_hot(i,j);
		}
		break;

		case H_LWIND:
		case H_RWIND:
		/* ignore if window is empty */
		if (!heap[windatamem[i==H_RWIND]].nbytes) break;
		if (kstate==K_ALT)		/* alt-click: clear window */
			ex_clear(i==H_RWIND);
		else
		{
			if (st>1)
				ex_infowind(i==H_RWIND);
			else
			{
				j= do_drag(source_x,source_y,source_w,source_h,
							  NHOTSPOTS+NDEVPERSCR,
							  dest_x,dest_y,dest_w,dest_h);
				do_hot(i,j);
			}
		}
		break;

		case H_MIDI:
		if (st>1)
			ex_midi();
		else
		{
			j= do_drag(source_x,source_y,source_w,source_h,
						  NHOTSPOTS,
						  dest_x,dest_y,dest_w,dest_h);
			do_hot(i,j);
		}
		break;

		default:	/* from device */
		dest_x[H_MIDI]= 0x7FFF; /* can't drag device to midi */
		j= do_drag(source_x,source_y,source_w,source_h,
					  NHOTSPOTS+NDEVPERSCR,
					  dest_x,dest_y,dest_w,dest_h);
		do_hot(i,j);
		
	}	/* end switch (which hot spot was clicked on) */
	return 1;
}	/* end do_hotspot() */

/* drag one of main screen's hot spots ......................................*/
/* returns 0 - (n_dest-1), -1 for none */

do_drag(source_x,source_y,source_w,source_h,
		  n_dest,
		  dest_x,dest_y,dest_w,dest_h)
int source_x,source_y,source_w,source_h;		/* source rectangle */
int n_dest;												/* number of destinations */
int *dest_x,*dest_y,*dest_w,*dest_h;			/* destination rectangles */
{
	int x,y;
	register int i;

	/* xor the source */
	vswr_mode(gl_hand,MD_XOR);
	fill_rect(source_x,source_y,source_w,source_h,1);
	vswr_mode(gl_hand,MD_REPLACE);

	/* drag */
	x=source_x;	y=source_y;
	slide_box(&x,&y,source_w,source_h, 0,0,640,200*rez,
					n_dest,dest_x,dest_y,dest_w,dest_h,
							 dest_x,dest_y,dest_w,dest_h);
	getmouse(&x,&y);

	/* re-xor the source */
	vswr_mode(gl_hand,MD_XOR);
	fill_rect(source_x,source_y,source_w,source_h,1);
	vswr_mode(gl_hand,MD_REPLACE);

	/* which destination is the mouse over? */
	for (i=0; i<n_dest; i++)
		if (in_rect(x,y,dest_x[i],dest_y[i],dest_w[i],dest_h[i])) break;

	waitmouse();

	return i<n_dest ? i : -1 ;

}	/* end do_drag() */

/* handle drag between disk/midi/windows/devices ............................*/

do_hot(src,dest)
register int src,dest;	/* source and dest:
								0-(NHOTSPOTS-1), NHOTSPOTS - (NHOTSPOTS+NDEVPERSCR-1) */
{
	/* ignore nonsense */
	if (src==dest) return;
	if (src<0) return;
	if (dest<0) return;
	if (src>=(NHOTSPOTS+NDEVPERSCR)) return;
	if (dest>=(NHOTSPOTS+NDEVPERSCR)) return;

	switch (src)
	{
		case H_DRIVE:
		switch (dest)
		{
			case H_LWIND:
			case H_RWIND:	disktowind(dest==H_RWIND); break;
			case H_MIDI:	disktomidi();	break;
			default:			disktodev(dest-NHOTSPOTS+studioHome); break;
		}
		break;

		case H_MIDI:
		switch (dest)
		{
			case H_DRIVE:	miditodisk();	break;
			case H_LWIND:
			case H_RWIND:	miditowind(dest==H_RWIND);	break;
		}
		break;

		case H_LWIND:
		case H_RWIND:
		switch (dest)
		{
			case H_DRIVE:	windtodisk(src==H_RWIND); 	break;
			case H_MIDI:	windtomidi(src==H_RWIND);	break;
			case H_LWIND:
			case H_RWIND:	windtowind(src==H_RWIND,dest==H_RWIND); break;
			default:			windtodev(src==H_RWIND,dest-NHOTSPOTS+studioHome);
		}
		break;

		default:
		switch (dest)
		{
			case H_DRIVE: devtodisk(src-NHOTSPOTS+studioHome); break;
			case H_LWIND:
			case H_RWIND: devtowind(src-NHOTSPOTS+studioHome,dest==H_RWIND); break;
			default:	/* copy device */
			if (dest>=NHOTSPOTS)
			{
				if (form_alert(1,CHEKCPYDV)==1)
				{
					studioDev[studioHome+dest-NHOTSPOTS]=
						studioDev[studioHome+src-NHOTSPOTS];
					studioLink[studioHome+dest-NHOTSPOTS]=
						studioLink[studioHome+src-NHOTSPOTS];
					draw_studio(dest-NHOTSPOTS);
					change_flag[stuCHANGE]= 1;
				}
			}
		}
	}	/* end switch src */
}	/* end do_hot() */

/* handle key ...............................................................*/
/* returns non-0 to quit, 0 to continue */

do_key(key,kstate)
int key;		/* high byte is scan code, low byte is ascii */
int kstate;
{
	kill_exec(1);	/* copy protection */
	kstate= _do_key(key,kstate);
	kill_exec(0);	/* copy protection */
	return kstate;
}

_do_key(key,kstate)
int key;		/* high byte is scan code, low byte is ascii */
int kstate;
{
	int scan;
	register int i,j;
	int messbuf[8];
	int graf_mouse();
	int done=0;
	int hotx,hoty,hotw,hoth;
	static int menukeys[29*4]=
	{
		/* scan code, kstate, title, item */
		SCAN_D, K_ALT, GEFILE, GEDELETE,
		SCAN_F, K_ALT, GEFILE, GEFORMAT,
		SCAN_P, K_ALT, GEFILE, GEPATHS,
		SCAN_M, K_ALT, GEFILE, GEMULTI,
		SCAN_C, K_ALT, GEFILE, GECOPY,
		SCAN_R, K_ALT, GEFILE, GERENAME,
		SCAN_U, K_ALT, GEFILE, GEPREFS,
		SCAN_Q, K_ALT, GEFILE, GEQUIT,

		SCAN_L, K_ALT, GEEDIT, GECLOAD,
		SCAN_E, K_ALT, GEEDIT, GECEDIT,
		SCAN_I, K_ALT, GEEDIT, GECINIT,
		SCAN_S, K_ALT, GEEDIT, GECSAVE,

		SCAN_C, K_CTRL, GEWINDS, GECLEAR,
		SCAN_X, K_CTRL, GEWINDS, GEEXPORT,
		SCAN_W, K_CTRL, GEWINDS, GEWNDOPT,
		SCAN_P, K_CTRL, GEWINDS, GEPRINT,
		SCAN_D, K_CTRL, GEWINDS, GEDUPLIC,
		SCAN_I, K_CTRL, GEWINDS, GEINFO,
		SCAN_S, K_CTRL, GEWINDS, GESORT,

		SCAN_M, K_CTRL, GEMIDI, GEMONITR,
		SCAN_O, K_CTRL, GEMIDI, GEMIDOPT,
		SCAN_R, K_CTRL, GEMIDI, GERECSEQ,
		SCAN_SPACE, K_ALT, GEMIDI, GEPLYSEQ,

		SCAN_E, 0, GEPATCH, GEEDITP,
		SCAN_R, 0, GEPATCH, GERANDP,
		SCAN_D, 0, GEPATCH, GEDISTP,
		SCAN_N, 0, GEPATCH, GENAMEP,
		SCAN_A, 0, GEPATCH, GEAVERP,

		0,0,0,0									/* marks end of table */
	};

	scan= key >> 8;

	/* Steinberg Switcher */
	if ( (scan>=SCAN_F1) && (scan<=SCAN_F10) && (kstate==(K_CTRL|K_LSHIFT))
		&& (midi_opsys==2) )
	{
		steinswitch();
		return 0;
	}

	/* memory manager debugger */
	if ( (scan==SCAN_M) && (kstate==(K_ALT|K_CTRL|K_LSHIFT)) )
	{
		display_mem();
		return 0;
	}

	/* play co-resident mtst sequence */
	if ((kstate==0)&&(scan==SCAN_SPACE))
	{
		play_mtst(thruchan);
		return 0;
	}

	/* targeted HybriSwitch */
	if ( (kstate==K_ALT) && (scan>=SCAN_f1) && (scan<=SCAN_f10) && sw_ptr )
	{
		ex_switch(scan-SCAN_f1);
		return 0;
	}

	/* macros */
	if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT))
	{
		for (i=0; i<NMACROS; i++)
			if (scan==macroscan[i]) break;
		if (i<NMACROS)
		{
			send_macro(i);
			return 0;
		}
	}

	/* scroll studio setup window */
	if (kstate==K_CTRL)
	{
		i= 0;
		if (scan==SCAN_UP) i= -NDEVPERSCR;
		if (scan==SCAN_DOWN) i= NDEVPERSCR;
		if (i)
		{
			scrollStudio(i);
			return 0;
		}
	}

	/* drag between disk/midi/windows */
	i= kstate ? -1 : scan_to_hot(scan) ;
	/* ignore empty window */
	if ((i==H_LWIND)||(i==H_RWIND))
		if (!heap[windatamem[i==H_RWIND]].nbytes) i= -1;
	if (i>=0)
	{
		hot_to_xywh(i,&hotx,&hoty,&hotw,&hoth);
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(hotx,hoty,hotw,hoth,1);
		vswr_mode(gl_hand,MD_REPLACE);
		menuprompt(DRAG_MSG);
		j= Crawcin()>>16;
		j= scan_to_hot(j);
		menuprompt(0L);
		vswr_mode(gl_hand,MD_XOR);
		fill_rect(hotx,hoty,hotw,hoth,1);
		vswr_mode(gl_hand,MD_REPLACE);
		do_hot(i,j);
		return 0;
	}

	/* menu commands */
	for (i=0; menukeys[i]; i+=4)
	{
		if ((scan==menukeys[i])&&(kstate==menukeys[i+1]))
		{
			messbuf[3]=menukeys[i+2];
			messbuf[4]=menukeys[i+3];
			if (messbuf[3]==GEEDIT)
			{
				menuprompt(CMT_MSG);
				switch (Crawcin()>>16)
				{
					case SCAN_C: i= 0;	break;
					case SCAN_M: i= 5;	break;
					case SCAN_T: i= 10;	break;
					default:	  i= -1;
				}
				menuprompt(0L);
				if (i<0) return 0;
				messbuf[4]+=i;
			}
			if ( !(menuaddr[messbuf[4]].ob_state & DISABLED) )
			{
				menu_tnormal(menuaddr,messbuf[3],0);
				done= _do_menu(messbuf);
			}
			break;
		}
	}	/* end scan through menu commands */

	return done;

}	/* end _do_key() */

scan_to_hot(scan)
int scan;
{
	static int hotscan1[NHOTSPOTS+NDEVPERSCR]= {
		SCAN_UP, SCAN_LEFT, SCAN_RIGHT, SCAN_DOWN,
		SCAN_1,SCAN_2,SCAN_3,SCAN_4,SCAN_5,SCAN_6,SCAN_7,SCAN_8,SCAN_9,SCAN_0
	};
	static int hotscan2[NHOTSPOTS+NDEVPERSCR]= {
		SCAN_UP, SCAN_LEFT, SCAN_RIGHT, SCAN_DOWN,
		SCAN_NUM1,SCAN_NUM2,SCAN_NUM3,SCAN_NUM4,SCAN_NUM5,SCAN_NUM6,
		SCAN_NUM7,SCAN_NUM8,SCAN_NUM9,SCAN_NUM0
	};
	register int i;

	for (i=0; i<(NHOTSPOTS+NDEVPERSCR); i++)
		if (scan==hotscan1[i]) return i;
	for (i=0; i<(NHOTSPOTS+NDEVPERSCR); i++)
		if (scan==hotscan2[i]) return i;

	return -1;
}	/* end scan_to_hot() */

hot_to_xywh(i,x,y,w,h)
int i;
int *x,*y,*w,*h;
{
	if (i<NHOTSPOTS)
	{
		*x= hotspotx[i];
		*y= hotspoty[i];
		*w= hotspotw[i];
		*h= hotspoth[i];
	}
	else	/* a device */
	{
		*x= studio_x1;
		*y= studio_y2 + (i-NHOTSPOTS)*10*rez;
		*w= studio_x4-studio_x1;
		*h= 10*rez;
	}
}

/* handle menu selection ....................................................*/
/* returns non-0 to quit, 0 to continue */

do_menu(messbuf)
int *messbuf;
{
	int i;

	kill_exec(1);	/* copy protection */
	i= _do_menu(messbuf);
	kill_exec(0);	/* copy protection */
	return i;
}

_do_menu(messbuf)
int *messbuf;
{
	int done=0;					/* default: don't quit */
	register int i,j;
	int side;

	/* desk title must de-select BEFORE handling, else mouse interrupt can
		falsely detect an accessory running */
	/* hybriswitch menu title must de-select before handling, or menu xor
		gets messed up */
	if ((messbuf[4]==GEABOUT)||(messbuf[4]==GESWITCH))
		menu_tnormal(menuaddr,messbuf[3],1);

	/* selected patches are on which side? (needed for some commands) */
	side= sel_side();

	switch (messbuf[4])
	{

	/* DESK menu */

		case GEABOUT:	do_dial(infoaddr,-1); break;

	/* FILE menu */

		case GEDELETE: ex_delete();	break;
		case GECOPY:	ex_copyfile();	break;
		case GERENAME:	ex_rename();	break;
		case GECREATF:	ex_creatf();	break;
		case GEDELETF:	ex_deletf();	break;
		case GEFORMAT: ex_format();	break;
		case GEPATHS:  ex_paths();		break;
		case GEPREFS:  ex_prefs();		break;
		case GEMULTI:	ex_multi();		break;
		case GESWITCH: ex_switch(-1); break;

		case GEQUIT:
		done=1;
		for (i=0; i<6; i++)
		{
			if (change_flag[i])
			{
				j= SELECTED;
				done=0;
			}
			else
				j=0;
			quitaddr[QUIT1+i].ob_state= j;
		}
		if (!done) done= (do_dial(quitaddr,-1)==OKQUIT);
		if (done&&quit_prot) done= (form_alert(2,CHEKQUIT)==1);
		break;

	/* EDIT menu */

		case GECLOAD:  ex_loadcnx();	break;
		case GECSAVE:  ex_savecnx();	break;
		case GECEDIT:  ex_editcnx();	break;
		case GEMLOAD:  ex_loadmac();	break;
		case GEMSAVE:  ex_savemac();	break;
		case GEMEDIT:  ex_editmac();	break;
		case GETLOAD:  ex_loadtem();	break;
		case GETSAVE:  ex_savetem();	break;
		case GETEDIT:  ex_edittem();	break;

		case GETINIT:
			i= form_alert(1,change_flag[temCHANGE] ? CHNGETEM : CHEKTINIT );
			if (i==1) init_tem();
			break;
		case GECINIT:
			i= form_alert(1,change_flag[cnxCHANGE] ? CHNGECNX : CHEKCINIT );
			if (i==1)
			{
				init_cnxs();
				change_mem(cnxmem,0L);	/* put inside init_cnxs() !!! */
			}
			break;
		case GEMINIT:
			i= form_alert(1,change_flag[macrCHANGE] ? CHNGEMAC : CHEKMINIT );
			if (i==1) init_macros();
			break;

	/* WINDOWS menu */

		case GECLEAR :	ex_clear(-1);		break;
		case GEEXPORT:	ex_export();		break;
		case GEWNDOPT: ex_windopts();		break;
		case GEPRINT : ex_print();			break;
		case GEDUPLIC: ex_duplic();		break;
		case GEINFO  : ex_devwind();		break;
		case GESORT  :	ex_sortwind();		break;

	/* MIDI menu */

		case GEMONITR: ex_monitor();			break;
		case GEMIDOPT:	ex_midi();				break;
		case GERECSEQ: record_seq();			break;
		case GEPLYSEQ:	play_seq(thruchan);	break;
		case GELODSEQ: load_seq();				break;
		case GESAVSEQ: save_seq();				break;
		case GESTLOAD:	load_studio();			break;
		case GESTSAVE:	save_studio();			break;
		case GESTINIT:	init_studio(-1);		break;

	/* PATCHES menu */

		case GEEDITP:
		j= -1;
		if (side>=0)
		{
			/* find the selected patch:  0 or 1 is okay, >1 is error */
			for (i=0; i<npatches[side]; i++)
				if (patchselect[side][i])
					if (j<0)
						j=i;
					else
						break;
			if (i<npatches[side])
			{
				form_alert(1,BADNEDIT);
				break;
			}
		}
		ex_edit(side,j);
		break;

		case GERANDP:
		if (side>=0) ex_random(side);
		break;

		case GEDISTP:
		if (side>=0) ex_distort(side);
		break;

		case GENAMEP:
		if (side>=0) ex_name(side);
		break;

		case GEAVERP:
		if (side>=0) ex_average(side);

	}	/* end switch (messbuf[4]) */

	/* deselect menu title (if not already deselected) */
	/* make this more intelligent by checking the selection bit in the
		title object !!! */
	if ((messbuf[4]!=GEABOUT)&&(messbuf[4]!=GESWITCH))
		menu_tnormal(menuaddr,messbuf[3],1);

	return done;
}	/* end _do_menu() */

/* handle midi byte received during main loop ...............................*/

do_midi(midibyte)
unsigned int midibyte;			/* 0xFF = reset status tracking */
{
	static unsigned int midievent[3];
	static int ndata,ndatcnt;
	unsigned int statusbyte,channel;
	register int side,pat;

	if (midibyte>=midiSOX)		/* can't track system status */
	{
		midievent[0]=0xFF;
		return;
	}
	if (midibyte&0x80)
	{
		ndata= ndatabyte[ whichstat(midibyte&0xF0) ];
		midievent[ndatcnt=0]= midibyte;
	}
	else
	{
		if (midievent[0]==0xFF) return;
		midievent[++ndatcnt]= midibyte;
	}

	if (ndatcnt!=ndata) return;	/* event not completely constructed yet */
	ndatcnt=0;							/* prepare for running status */

	statusbyte= midievent[0]&0xF0;	/* without channel */
	channel= midievent[0]&0x0F;		/* channel */

	/* patch change sends single patch from data window(s) */
	if (statusbyte==midiPTCH)
	{
		pat= midievent[1];
		for (side=0; side<2; side++)
			if ( windpatsend[side] && (npatches[side]>pat) )
				if ( (windpatchan[side]<0) || (windpatchan[side]==channel) )
					if (putpgetp((int)(cnxDTOE),side,pat))
						edittomidi(side);
	}	/* end if this midi event is a patch change */

}	/* end do_midi() */

/* selected patches are on which side? ......................................*/
/* returns 0 or 1 for side, -1 for neither */

sel_side()
{
	register int side;

	for (side=0; side<2; side++)
		if (patch_sel(side)) return side;
	return -1;
}	/* end sel_side() */

/* any patches selected on this side? .......................................*/
/* returns 1= yes, 0= no */

patch_sel(side)
int side;
{
	register long *lptr;
	register int i;

	lptr= (long*)(patchselect[side]);	/* check 4 at a time */
	for (i=0; i<MAXNPATS/4; i++) if (*lptr++) break;
	return i<MAXNPATS/4;
}	/* end patch_sel() */

/* (de)select all patches on a side and redraw ..............................*/

sel_allpats(side,flag)
int side,flag;
{
	set_bytes(patchselect[side],MAXNPATS,flag);
	draw_names(side,-1);
}	/* end sel_allpats() */

/* configurations in the two windows are different? .........................*/
/* returns 1= different, 0= same */

comp_windcnxs()
{
	register int side;
	register long templong;
	long cnxstart,cnxend;
	long getpstart[2],getpend[2];
	long putpstart[2],putpend[2];

	/* two windows must have same GETP and same PUTP segments */
	for (side=0; side<2; side++)
	{
		cnxstart= heap[ windcnxmem[side] ].start;
		cnxend= cnxstart + heap[ windcnxmem[side] ].nbytes;
		if (!_findcnxseg((int)cnxGETP,cnxstart,cnxend,
				&getpstart[side],&getpend[side])) return 1;
		if (!_findcnxseg((int)cnxPUTP,cnxstart,cnxend,
				&putpstart[side],&putpend[side])) return 1;
	}
	templong= getpend[0] - getpstart[0];
	if ( templong != (getpend[1]-getpstart[1]) ) return 1;
	if (comp_bytes(getpstart[0],getpstart[1],templong-1)) return 1;
	templong= putpend[0] - putpstart[0];
	if ( templong != (putpend[1]-putpstart[1]) ) return 1;
	if (comp_bytes(putpstart[0],putpstart[1],templong-1)) return 1;

	return 0;
}	/* end comp_windcnxs() */

/* scroll studio setup window ...............................................*/
/* returns 1= it scrolled, 0= it didn't */

scrollStudio(delta)
int delta;
{
	delta += studioHome;
	delta= max(delta, 0);
	delta= min(delta, NDEVICES-NDEVPERSCR);
	if (delta!=studioHome)
	{
		studioHome= delta;
		draw_studio(-1);
		return 1;
	}
	return 0;
}

/* EOF */
