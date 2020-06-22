#include <AES.H>

void main(void)
{
	short work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
	short work_out[57];
	short ap_id,w_id1,w_id2;
	short msg[16],x,y,w,h,cx,cy,cw,ch,wx,wy,ww,wh,clip[4],pnt[4];
	short dummy=0, my_handle, open_windows=2;
	short offs_x=0, offs_y=0;
	short e,evx,evy,a,kc_shstate,kc_key,click_count;
	GRECT dirty, walk;
	char win1_name[20],ktest[202];
	short kt_p=1;
	
	ap_id=appl_init();
	
	my_handle=graf_handle(&x,&y,&w,&h);		// Open a virtual workstation
	v_opnvwk(work_in,&my_handle,work_out);
	
	w_id1=wind_create(NAME|CLOSE|MOVER|FULLER|INFO, 0,0,200,100);
	w_id2=wind_create(NAME|CLOSE|MOVER|SIZER|FULLER|LFARROW|RTARROW|UPARROW|DNARROW|HSLIDE|VSLIDE|INFO, 0,0,240,100);

	wind_set(w_id1,WF_NAME, ADDR("XaAES Demo (1)"));
	sprintf(win1_name,"PID=%d,WinHandle=%d",ap_id,w_id2);
	wind_set(w_id1,WF_INFO, ADDR(win1_name));
	wind_set(w_id2,WF_NAME, ADDR("XaAES Demo (2)"));
	sprintf(ktest,">");
	wind_set(w_id2,WF_INFO, ADDR(ktest));

	wind_open(w_id2,10,10,300,150);	// Open a couple of Windows
	wind_open(w_id1, 20,80,150,100);

	graf_mouse(POINT_HAND, (void*)0);

	while(open_windows)
	{
		e=evnt_multi(MU_MESAG|MU_KEYBD,258,3,0,0,0,0,0,0,0,0,0,0,0,
			msg,0,0,&evx,&evy,&a,&kc_shstate,&kc_key,&click_count);

		if (e&MU_KEYBD)
		{
			if (kt_p==80)
				kt_p=1;
			
			ktest[kt_p]=(char)(kc_key&0xff);
			kt_p++;
			ktest[kt_p]='\0';
			wind_set(w_id2,WF_INFO, ADDR(ktest));
		}

		if (e&MU_MESAG)
		{
			dummy=msg[0];
			switch(dummy)
			{
				case WM_CLOSED:	// did someone close one of our windows?
					wind_close(msg[3]);
					open_windows--;
					break;
				case WM_HSLID:
					if (msg[3]==w_id2)
					{
						wind_set(msg[3], WF_HSLIDE, msg[4], 0, 0, 0);
						wind_update(BEG_UPDATE);
						wind_get(msg[3], WF_WORKXYWH, &wx, &wy, &ww, &wh);
						dirty.g_x=wx;
						dirty.g_y=wy;
						dirty.g_w=ww;
						dirty.g_h=wh;
						cw=ww/2; ch=wh/2;
						cx=wx+cw; cy=wy+ch;
						cw-=5; ch-=5;
						offs_x=msg[4]/2;
						pnt[0]=wx; pnt[1]=wy; pnt[2]=wx+ww; pnt[3]=wy+wh;
						wind_get(msg[3], WF_FIRSTXYWH, &x, &y, &w, &h);
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
								vsf_color(my_handle,WHITE);
								v_bar(my_handle,pnt);
								vsf_color(my_handle,RED);
								v_ellipse(my_handle, cx+offs_x, cy+offs_y, cw, ch);
							}
							wind_get(msg[3], WF_NEXTXYWH, &x, &y, &w, &h);
						}
						vs_clip(my_handle, 0, clip);
						graf_mouse(M_ON, NULL);
						wind_update(END_UPDATE);
					}
					break;
				case WM_VSLID:
					if (msg[3]==w_id2)
					{
						wind_set(msg[3], WF_VSLIDE, msg[4], 0, 0, 0);
						wind_update(BEG_UPDATE);
						wind_get(msg[3], WF_WORKXYWH, &wx, &wy, &ww, &wh);
						offs_y=msg[4]/2;
						dirty.g_x=wx;
						dirty.g_y=wy;
						dirty.g_w=ww;
						dirty.g_h=wh;
						cw=ww/2; ch=wh/2;
						cx=wx+cw; cy=wy+ch;
						cw-=5; ch-=5;
						pnt[0]=wx; pnt[1]=wy; pnt[2]=wx+ww; pnt[3]=wy+wh;
						wind_get(msg[3], WF_FIRSTXYWH, &x, &y, &w, &h);
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
								vsf_color(my_handle,WHITE);
								v_bar(my_handle,pnt);
								vsf_color(my_handle,RED);
								v_ellipse(my_handle, cx+offs_x, cy+offs_y, cw, ch);
							}
							wind_get(msg[3], WF_NEXTXYWH, &x, &y, &w, &h);
						}
						vs_clip(my_handle, 0, clip);
						graf_mouse(M_ON, NULL);
						wind_update(END_UPDATE);
					}
					break;
				case WM_ARROWED:
					if (msg[3]==w_id2)
					{
						x=msg[4];
						switch(x)
						{
							case WA_LFLINE:
								if(offs_x>=4) offs_x-=4;
								break;
							case WA_RTLINE:
								offs_x+=4;
								break;
							case WA_UPLINE:
								if(offs_y>=4) offs_y-=4;
								break;
							case WA_DNLINE:
								offs_y+=4;
								break;
							case WA_LFPAGE:
								if(offs_x>=40) offs_x-=40;
								break;
							case WA_RTPAGE:
								offs_x+=40;
								break;
							case WA_UPPAGE:
								if(offs_y>=40) offs_y-=40;
								break;
							case WA_DNPAGE:
								offs_y+=40;
								break;
						}

						wind_set(msg[3], WF_HSLIDE, offs_x*2, 0, 0, 0);
						wind_set(msg[3], WF_VSLIDE, offs_y*2, 0, 0, 0);
	
						wind_update(BEG_UPDATE);
						wind_get(msg[3], WF_WORKXYWH, &wx, &wy, &ww, &wh);
						dirty.g_x=wx;
						dirty.g_y=wy;
						dirty.g_w=ww;
						dirty.g_h=wh;
						cw=ww/2; ch=wh/2;
						cx=wx+cw; cy=wy+ch;
						cw-=5; ch-=5;
						pnt[0]=wx; pnt[1]=wy; pnt[2]=wx+ww; pnt[3]=wy+wh;
						wind_get(msg[3], WF_FIRSTXYWH, &x, &y, &w, &h);
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
								vsf_color(my_handle,WHITE);
								v_bar(my_handle,pnt);
								vsf_color(my_handle,RED);
								v_ellipse(my_handle, cx+offs_x, cy+offs_y, cw, ch);
							}
							wind_get(msg[3], WF_NEXTXYWH, &x, &y, &w, &h);
						}
						vs_clip(my_handle, 0, clip);
						graf_mouse(M_ON, NULL);
						wind_update(END_UPDATE);
					}
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
					wind_update(BEG_UPDATE);
					wind_get(msg[3], WF_WORKXYWH, &wx, &wy, &ww, &wh);
					walk.g_x=wx;
					walk.g_y=wy;
					walk.g_w=ww;
					walk.g_h=wh;
					cw=ww/2; ch=wh/2;
					cx=wx+cw; cy=wy+ch;
					cw-=5; ch-=5;
					pnt[0]=wx; pnt[1]=wy; pnt[2]=wx+ww; pnt[3]=wy+wh;
					wind_get(msg[3], WF_FIRSTXYWH, &x, &y, &w, &h);
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
							vsf_color(my_handle,WHITE);
							v_bar(my_handle,pnt);
							if (msg[3]==w_id2)
							{
								vsf_color(my_handle,RED);
								v_ellipse(my_handle, cx+offs_x, cy+offs_y, cw, ch);
							}else{
								vsf_color(my_handle,BLUE);
								v_ellipse(my_handle, cx, cy, cw, ch);
							}
						}
						wind_get(msg[3], WF_NEXTXYWH, &x, &y, &w, &h);
					}
					vs_clip(my_handle, 0, clip);
					graf_mouse(M_ON, NULL);
					wind_update(END_UPDATE);
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
	}
	
//	dummy=evnt_button(2,2,2,&dummy,&dummy,&dummy,&dummy);
	
	v_clsvwk(my_handle);
		
	appl_exit();
}
