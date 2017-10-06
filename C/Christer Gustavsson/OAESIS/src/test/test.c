#include	<aesbind.h>
#include	<osbind.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<vdibind.h>

#define	NR_WIN	6

#define	WORD	int

WORD	vid;

WORD	max(WORD a,WORD b)
{
	if(a > b) 
		return a;
	else
		return b;
}

WORD	min(WORD a,WORD b)
{
	if(a < b) 
		return a;
	else
		return b;
}

WORD	open_windows = 0;

/*extern int	_intout[];
*/
void	updatewait(void)
{
	WORD	ant_klick;
	WORD	buffert[16];
	WORD	happ;
	WORD	knapplage;
	WORD	tangent,tanglage;
	WORD	x;
	WORD	y;

	do
	{
		happ = evnt_multi(MU_KEYBD | MU_MESAG,0,0,0,0,0,0,0,0,0
					,0,0,0,0,buffert,0,&x,&y,&knapplage,&tanglage
					,&tangent,&ant_klick);

		if((happ & MU_MESAG) && (buffert[0] == WM_REDRAW))			
		{
			WORD	x,y,w,h;

			wind_update(BEG_UPDATE);
			wind_get(buffert[3],WF_FIRSTXYWH,&x,&y,&w,&h);
			
						
			while((w > 0) && (h > 0))
			{
				WORD	xn,yn,wn,hn;

				xn = max(x,buffert[4]);
				wn = min(x + w, buffert[4] + buffert[6]) - xn;
				yn = max(y,buffert[5]);
				hn = min(y + h, buffert[5] + buffert[7]) - yn;

				if((wn > 0) && (hn > 0))
				{
					WORD	xyxy[4];
					
					xyxy[0] = xn;
					xyxy[1] = yn;
					xyxy[2] = xn+wn-1;
					xyxy[3] = yn+hn-1;
					
					vsf_color(vid,buffert[3] % 16);
					vsf_style(vid,(buffert[3] % 24));

					graf_mouse(M_OFF,NULL);
										
					vr_recfl(vid,xyxy);
					
					graf_mouse(M_ON,NULL);
				}

				wind_get(buffert[3],WF_NEXTXYWH,&x,&y,&w,&h);
			}				
			wind_update(END_UPDATE);
		}
		else if((happ & MU_MESAG) && (buffert[0] == WM_TOPPED))
		{
			wind_set(buffert[3],WF_TOP);
		}
		else if((happ & MU_MESAG) && (buffert[0] == WM_CLOSED))
		{
			wind_close(buffert[3]);
			
			if(--open_windows == 0)
				break;
		}
		else if((happ & MU_MESAG) && ((buffert[0] == WM_SIZED)
			|| (buffert[0] == WM_MOVED)))
		{
			wind_set(buffert[3],WF_CURRXYWH,buffert[4],buffert[5]
				,buffert[6],buffert[7]);
		}
		else if((happ & MU_KEYBD) && ((tangent & 0xff) == 'q'))
			break;
	}while(1);
};

void	testmesag(WORD apid)
{
	WORD	buffer[50],i;
	WORD	mesag[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
							,17,18,19,20};
	
	printf("appl_write = %d\n",appl_write(apid,40,mesag));
	
/*	evnt_mesag(buffer);
*/
	appl_read(apid,24,buffer);
		
	for(i = 0; i < 25; i++)
	{
		printf("buffer[%d]=%3d\n",i,buffer[i]);
	};	
};

void	testwin(void)
{
	WORD	xoff,yoff,woff,hoff;
	
	WORD	i;
	
	WORD	w[NR_WIN];
	
	char	title[] = "CG's stupid test application";
	char	info[] = "Window number ";
	char	inx[NR_WIN][20];
	
	
	for(i = 0; i < NR_WIN; i++)
	{
		char	s[20];
		
		w[i] = wind_create(NAME|MOVER|FULLER|DNARROW|SIZER|INFO|VSLIDE|UPARROW
			|LFARROW|RTARROW|HSLIDE|CLOSER,0,0,640,480);
			
		wind_set(w[i],WF_NAME,title);
		strcpy(inx[i],info);
		/*itoa(w[i],s,10);
		strcat(inx[i],s);*/
		wind_set(w[i],WF_INFO,inx[i]);
	}

	wind_get(0,WF_WORKXYWH,&xoff,&yoff,&woff,&hoff);

	for(i = 0; i < NR_WIN; i++)
	{
		wind_open(w[i],10*i + xoff,10*i + yoff,400 + 7 * (i % 10),300 + 4 * ((10 - i) % 10));
		open_windows++;
	}	

	updatewait();

	for(i = 0; i < NR_WIN; i++)
	{
		wind_delete(w[i]);
	}
}


void	main(void) {
	WORD	apid;
	
	WORD	work_in[] = {1,1,1,1,1,1
				,1,1,1,1,2,0};

	WORD	work_out[57];
	char head[128],tail[128];
	long	addr;

	OBJECT **hej;
	
	v_opnvwk(work_in,&vid,work_out);

	vsf_interior(vid,2);

	apid = appl_init();
	
	shel_read(head,tail);
	
	graf_mouse(ARROW,0L);
	
	testwin();

/*	testmesag(apid);
*/			
	appl_exit();
	
	v_clsvwk(vid);
}
