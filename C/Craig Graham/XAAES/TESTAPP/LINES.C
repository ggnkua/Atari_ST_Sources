/*
	Primitive command line console for XaAES
	- No terminal emulation at all.....
*/

#include <AES.H>
#include <VDI.H>

typedef struct tri {
	short x1,y1;
	short x2,y2;
	short x3,y3;
	short a,b;
} TRI;

short my_handle,ap_id;
short w_id1;
GRECT dirty;

void draw_triangles(TRI *t,short cnt,short bgd)
{
	short *tpnt=(short*)t;
	short x,y,w,h,wx,wy,ww,wh,clip[4],pnt[4];
	short f;
	GRECT walk;

	for(f=0; f<cnt; f++)
	{
		t[f].a=t[f].x1;
		t[f].b=t[f].y1;
	}

	wind_update(BEG_UPDATE);
	wind_get(w_id1, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	walk.g_x=wx;
	walk.g_y=wy;
	walk.g_w=ww;
	walk.g_h=wh;
	pnt[0]=wx; pnt[1]=wy; pnt[2]=wx+ww; pnt[3]=wy+wh;
	wind_get(w_id1, WF_FIRSTXYWH, &x, &y, &w, &h);
	rc_intersect(&walk,&dirty);
	graf_mouse(M_OFF, NULL);
	while(h)
	{
		walk.g_x=x;
		walk.g_y=y;
		walk.g_w=w;
		walk.g_h=h;
		if (rc_intersect(&dirty,&walk))
		{
			clip[0]=walk.g_x; clip[1]=walk.g_y;
			clip[2]=walk.g_x+walk.g_w; clip[3]=walk.g_y+walk.g_h;
			vs_clip(my_handle, 1, clip);

			if (bgd)
				v_bar(my_handle,pnt);
			
			vsl_color(my_handle, LWHITE);
			v_pline(my_handle, 4, tpnt);
			
			for(f=1; f<cnt-1; f++)
			{
				tpnt+=sizeof(TRI);
				vsl_color(my_handle, f);
				v_pline(my_handle, 4, tpnt);
			}
		}
		wind_get(w_id1, WF_NEXTXYWH, &x, &y, &w, &h);
	}
	vs_clip(my_handle, 0, clip);
	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);
}

void main(int argc, char *argv[])
{
	short work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
	short work_out[57];
	short msg[16],x,y,w,h,wx,wy,ww,wh,*ta,*tb;
	short dummy=0, open_windows=1;
	short f,e,evx,evy,a,kc_shstate,kc_key,click_count;
	TRI this={10,10,10,20,20,10,0,0},old[10],dir={-4,16,-5,-2,5,3,0,0};
	
	ta=(short*)&old;
	for(f=0; f<10*8; f++)
		ta[f]=-1;
	
	ap_id=appl_init();
	
	my_handle=graf_handle(&x,&y,&w,&h);		// Open a virtual workstation
	v_opnvwk(work_in,&my_handle,work_out);
	vsf_color(my_handle,LWHITE);
	vsf_interior(my_handle, FIS_SOLID);
	vswr_mode(my_handle, MD_TRANS);
	
	wind_calc(0,NAME|CLOSE|MOVER|FULLER|SIZER,0,0,100,100,&wx,&wy,&ww,&wh);
	
	w_id1=wind_create(NAME|CLOSE|MOVER|FULLER|SIZER, wx,wy,ww,wh);

	wind_set(w_id1,WF_NAME, ADDR("XaAES Lines"));

	wind_open(w_id1,20,40,ww,wh);

	while(open_windows)
	{
		e=evnt_multi(MU_MESAG|MU_TIMER,258,3,0,0,0,0,0,0,0,0,0,0,0,
			msg,5,0,&evx,&evy,&a,&kc_shstate,&kc_key,&click_count);

		if (e&MU_MESAG)
		{
			dummy=msg[0];
			switch(dummy)
			{
				case WM_CLOSED:	// did someone close one of our windows?
					wind_close(msg[3]);
					open_windows=0;
					break;
				case WM_SIZED:
				case WM_MOVED:
					wind_set(msg[3], WF_CURRXYWH,msg[4], msg[5], msg[6], msg[7]);
					break;
				case WM_REDRAW:
					dirty.g_x=msg[4];
					dirty.g_y=msg[5];
					dirty.g_w=msg[6];
					dirty.g_h=msg[7];					
					draw_triangles(old,5,1);
					break;
				case WM_FULLED:
					wind_get(msg[3], WF_FULLXYWH, &x, &y, &w, &h);
					wind_get(msg[3], WF_CURRXYWH, &wx, &wy, &ww, &wh);
					if ((((x==wx)&&(y==wy))&&(w==ww))&&(h==wh))
						wind_get(msg[3], WF_PREVXYWH, &x, &y, &w, &h);
					wind_set(msg[3], WF_CURRXYWH, x, y, w, h);
					break;
				case WM_TOPPED:
					wind_set(msg[3], WF_TOP, 0, 0, 0, 0);
					break;
				case WM_BOTTOMED:
					wind_set(msg[3], WF_BOTTOM, 0, 0, 0, 0);
					break;
			}
		}
		
		if (e&MU_TIMER)
		{
			wind_get(w_id1, WF_WORKXYWH, &wx, &wy, &ww, &wh);
			ta=(short*)&this;
			tb=(short*)&dir;
			for(f=0; f<8; f+=2)
			{
				ta[f]+=tb[f];
				if (ta[f]<wx)
				{
					tb[f]=-tb[f];
					ta[f]=wx;
				}
				if (ta[f]>wx+ww)
				{
					tb[f]=-tb[f];
					ta[f]=wx+ww;
				}
			}
			for(f=1; f<8; f+=2)
			{
				ta[f]+=tb[f];
				if (ta[f]<wy)
				{
					tb[f]=-tb[f];
					ta[f]=wy;
				}
				if (ta[f]>wy+wh)
				{
					tb[f]=-tb[f];
					ta[f]=wy+wh;
				}
			}

			for(f=0; f<9; f++)
				old[f]=old[f+1];
			
			old[9]=this;

			dirty.g_x=wx;
			dirty.g_y=wy;
			dirty.g_w=ww;
			dirty.g_h=wh;
			
			draw_triangles(old,5,0);
		}
			
			
	}
	
	v_clsvwk(my_handle);
		
	appl_exit();
}
