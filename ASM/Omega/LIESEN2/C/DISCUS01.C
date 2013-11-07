/********* DISCUS   (C) Martin Liesen 1991,92   */

#include<tos.h>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<aes.h>
#include<vdi.h>
#include<d:\liesen\c\disc_tol.h>
#include<d:\liesen\c\discus.h>
/* #include<d:\liesen\c\dubug.h>	*/

char	discus_name[]="D:\\LIESEN\\C\\DISCUS.RSC";
char	alert_no_rsc[]=
					"[2][ Can't find the DISCUS.RSC file | |][ Kult ]";
char	alert_wrong_rez[]=
					"[2][ DISCUS can only run | in the on ST-high | resolution ][ Kult ]";

typedef struct 
{
	long		next;			/* nil  if last (and is no real object) */
	long		prev;			/* nil  if first */
	char		name[14];	/* filename.ext */
	int		type;			/* orgin  0= trash  1=work 2=discus */ 
	int		size;			/* sectors */
	char		txt_size[5];/* sectors as text */
} FILOBJ;

typedef struct {
	int		handle;
	char		headline[40];
	char		infotext[40];
	FILOBJ	*first;
	FILOBJ	*top;
	int		antal;
} wind_data;

wind_data	win[3];
int			active;			/* our active window   -1 if none */

char ORGIN[3][4]={"[t]","[w]","[d]"};

/*** PATHS ***/

char	work_path[42]="E:\\WORK\\";
char	temp_path[42]="E:\\TEMP\\";
char	trash_path[42]="E:\\";
int	discus_drive=0;				/* 0=A  1=B */

/*** GEM ***/ 

int	contrl[12],
		intin[128],
		ptsin[128],
		intout[128],
		ptsout[128];
		
int	work_out[57],
		work_in[12];

int	VDI_handle,
		AES_handle;

int	gl_hwchar,
		gl_hhchar,
		gl_hwbox,
		gl_hhbox;

int	MAXX,MAXY,MINX,MINY;

/*** EVENTS ***/

int	quit=1;

int	ev_mgpbuff[8];
int	ev_mwhich,
		ev_mox,
		ev_moy,
		ev_mobutton,
		ev_mokstate,
		ev_kreturn,
		ev_breturn;

/*********************************************************** START */

void main()
{
	appl_init();
	AES_handle=graf_handle(&gl_hwchar,&gl_hhchar,&gl_hwbox,&gl_hhbox);
	open_work();
	read_rsc();
	if(Getrez()!=2) {
		form_alert(1,alert_wrong_rez);
		close_work();
		exit(1);
		}
	Main_Loop();
	close_work();
	return 0;
}

/*************************************************************/
int open_work()
{
	int	i;
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	VDI_handle=AES_handle;
	v_opnvwk(work_in,&VDI_handle,work_out);
}

int close_work()
{
	v_clsvwk(VDI_handle);
	appl_exit();
}

int read_rsc()
{
	int	fel;
	fel=rsrc_load(discus_name);
	if (fel==0) {
		form_alert(1,alert_no_rsc);
		close_work();
		exit(1);
	}
}

/************************************************** SCAN FOR FILES */
int Scan_a_Path(const char *path,FILOBJ *first,int typ)
{
	char		search[50];
	int		result;
	FILOBJ	*current,*last;
	DTA		*dta;

	dta=Fgetdta();

	last=0;
	current=first;

	strcpy(search,path);
	strcat(search,"*.*");
	result=Fsfirst(search,0);
	while(result==0)
	{
		strcpy(current->name,dta->d_fname);
		Extend_Filename(current->name); 
		current->prev=last;
		current->size=(dta->d_length+511)/512;
		itoa(current->size,current->txt_size,10);
		current->type=typ;

		last=current;
		current=malloc(sizeof(FILOBJ));
		if(last != 0)
			last->next=current;
		result=Fsnext();
	}
	current->next=0;
	current->prev=last;
}

/******************************************* CHECK IF PATHS EXISTS */
int exist_paths()
{
	int	result=0;
	if (	(exist_path(trash_path) != 0) ||
			(exist_path(temp_path) != 0) ||
			(exist_path(work_path) != 0)
		)
		result=1;
	return result;
}

/******************************************************* SET PATHS */
int set_paths()
{
	int	cx,cy,cw,ch;
	int	result;
	OBJECT *pressed,*drive_a,*drive_b;
	TEDINFO *work_text,*temp_text,*tras_text;
	
	work_text=g_tedinfo_addr(PATHS,PWORK);
	temp_text=g_tedinfo_addr(PATHS,PTEMP);
	tras_text=g_tedinfo_addr(PATHS,PTRASH);
	drive_a=g_obj_addr(PATHS,PDRIVA);
	drive_b=g_obj_addr(PATHS,PDRIVB);

	work_text->te_txtlen=41;
	temp_text->te_txtlen=41;
	tras_text->te_txtlen=41;
	strcpy(work_text->te_ptext,work_path);
	strcpy(temp_text->te_ptext,temp_path);
	strcpy(tras_text->te_ptext,trash_path);

	if (discus_drive==0) {
		drive_a->ob_state|=1;
		drive_b->ob_state&=0xFE;
	} else {
		drive_b->ob_state|=1;
		drive_a->ob_state&=0xFE;
	}
	

	form_center(gaddr(0,PATHS),&cx,&cy,&cw,&ch);
	form_dial(0,0,0,0,0,cx,cy,cw,ch);
	form_dial(1,320,100,1,1,cx,cy,cw,ch);
	objc_draw(gaddr(0,PATHS),0,5,cx,cy,cw,ch); 
	result=form_do(gaddr(0,PATHS),0);
	pressed=g_obj_addr(PATHS,result);	
	(*pressed).ob_state ^= 1;
	form_dial(2,320,100,1,1,cx,cy,cw,ch);
	form_dial(3,0,0,0,0,cx,cy,cw,ch);

	if (result==POK) {
		strcpy(work_path,work_text->te_ptext);
		strcpy(temp_path,temp_text->te_ptext);
		strcpy(trash_path,tras_text->te_ptext);
		if(( drive_a->ob_state & 1) != 0)
			discus_drive=0;
		else
			discus_drive=1;
	}

}

/*********************************************************** ABOUT */
int about_discus()
{
	int	cx,cy,cw,ch;
	OBJECT *pressed;
	int	result;
	
	form_center(gaddr(0,ABOUT),&cx,&cy,&cw,&ch);
	form_dial(0,0,0,0,0,cx,cy,cw,ch);
	form_dial(1,320,100,1,1,cx,cy,cw,ch);
	objc_draw(gaddr(0,ABOUT),0,5,cx,cy,cw,ch); 
	result=form_do(gaddr(0,ABOUT),0);
	pressed=g_obj_addr(ABOUT,result);	
	(*pressed).ob_state ^= 1;
	form_dial(2,320,100,1,1,cx,cy,cw,ch);
	form_dial(3,0,0,0,0,cx,cy,cw,ch);
}

/************************ Is coordinate on any of our work screens */
int On_Which_Window(int cx,int cy)
{
	int	loop;
	int	x,y,w,h;
	for ( loop=0; loop<3; loop++ )	{
		wind_get(win[loop].handle,4,&x,&y,&w,&h);
		if ( Intercept(cx,cy,0,0,x,y,w,h) == 0 )
			return loop;
	}
	return -1;
}

/********************************** Is Handle one of our windows ? */
int Our_Window(int handle)
{
	int loop;
	for (loop=0;loop<3;loop++)
		if (win[loop].handle==handle)
			return loop;
	return -1;
}

/********************** Return which of our windows that is active */
int Who_Is_Active()
{
	int	h;
	int	loop;

	wind_get(win[0].handle,10,&h,0,0,0);
	for (loop=0;loop<3;loop++)
		if( win[loop].handle == h)
			return loop;
	return -1;
}

/************************************************** CREATE WINDOWS */
int Create_Windows()
{
	int	x,y,w,h;

	win[0].handle=wind_create(0x01D9,0,19,160,350);
	strcpy(win[0].infotext,"Get stuffed");
	strcpy(win[0].headline,"Trash dir");
	wind_calc(0,0x01D9,8,64,176,328,&x,&y,&w,&h);
	wind_set(win[0].handle,2,win[0].headline,0,0);
	wind_set(win[0].handle,3,win[0].infotext,0,0);
	wind_open(win[0].handle,x,y,w,h);

	win[1].handle=wind_create(0x01D9,0,19,160,350);
	strcpy(win[1].infotext,"Get stuffed");
	strcpy(win[1].headline,"Work dir");
	wind_calc(0,0x01D9,224,64,176,328,&x,&y,&w,&h);
	wind_set(win[1].handle,2,win[1].headline,0,0);
	wind_set(win[1].handle,3,win[1].infotext,0,0);
	wind_open(win[1].handle,x,y,w,h);

	win[2].handle=wind_create(0x01D9,0,19,160,350);
	strcpy(win[2].infotext,"Get stuffed");
	strcpy(win[2].headline,"Discus dir");
	wind_calc(0,0x01D9,440,64,176,328,&x,&y,&w,&h);
	wind_set(win[2].handle,2,win[2].headline,0,0);
	wind_set(win[2].handle,3,win[2].infotext,0,0);
	wind_open(win[2].handle,x,y,w,h);

	active=Who_Is_Active();

	Update_W(&win[0],MINX,MINY,MAXX,MAXY);
	Update_W(&win[1],MINX,MINY,MAXX,MAXY);
	Update_W(&win[2],MINX,MINY,MAXX,MAXY);
}

/******************************* Records left in row */
int Record_Left_Down(const FILOBJ *obj)
{
	FILOBJ	*o;
	int		count;
	o=obj;
	count=0;
	while (o->next != 0)
	{
		o=o->next;
		count++;
	}
	return count;
}

/******************************************* REDRAW PART OF WINDOW */
int Update_W(wind_data *win,int u_x, int u_y,int u_w,int u_h)
{
	FILOBJ	*o;
	int		pxyarray[4];
	int		x,y,w,h;

	int		px,py,pw,ph;
	int		loopy;

	wind_get(win->handle,4,&px,&py,&pw,&pw);
	py += 16;
	px += 8;

	graf_mouse(256,0);
	wind_update(1);
	o=win->top;

	wind_get(win->handle,11,&x,&y,&w,&h);
	while((win != 0) && (h != 0))
	{
		if (Intercept(x,y,w,h,u_x,u_y,u_w,u_h)==0)
		{
			Make_Clip(&x,&y,&w,&h,u_x,u_y,u_w,u_h);
			pxyarray[0]=x;
			pxyarray[1]=y;
			pxyarray[2]=x+w;
			pxyarray[3]=y+h;
			vs_clip(VDI_handle,1,pxyarray);
			vsf_color(VDI_handle,0);
			vr_recfl(VDI_handle,pxyarray);
			vst_color(VDI_handle,1);
			for(loopy=0;loopy<20;loopy++)
			{
				if (o->next != 0) {
					v_gtext(VDI_handle,px,py,ORGIN[o->type]);
					v_gtext(VDI_handle,px+32,py,o->name);
					v_gtext(VDI_handle,px+136,py,o->txt_size);
					o=o->next;
				}
				py += 16;
			}
		}
		wind_get(win->handle,12,&x,&y,&w,&h);
	}
	vs_clip(VDI_handle,0,pxyarray);
	wind_update(0);
	graf_mouse(257,0);
}
/******************************************************* INIT DATA */
int Init_Data()
{
	int	loop;

	while ( exist_paths() != 0 )
		set_paths();
	for( loop=0; loop<3; loop++) {
		win[loop].first = malloc( sizeof(FILOBJ) );
		win[loop].top = win[loop].first;
		win[loop].first->next=0;
		win[loop].first->prev=0;
	}

	Scan_a_Path(trash_path,win[0].top,0);
	Scan_a_Path(work_path,win[1].top,1);
	win[0].antal=Record_Left_Down(win[0].first);
	win[1].antal=Record_Left_Down(win[1].first);

	wind_get(0,4,&MINX,&MINY,&MAXX,&MAXY);
}

/************************************************** KEYBOARD EVENT */
int Process_Keys()
{
	switch(ev_kreturn)
	{
		case 0x2D00:{
			quit=0;
			break;
		}
	default:
		printf("\rKey=%x",ev_kreturn);
	}
}

int Invert_Box(int x,int y,int w,int h)
{
	int	pxyarray[4];

	graf_mouse(256,0);
	wind_update(1);
	vsf_color(VDI_handle,0);
	vswr_mode(VDI_handle,3);
	pxyarray[0]=x;
	pxyarray[1]=y;
	pxyarray[2]=x+w-1;
	pxyarray[3]=y+h-1;
	vr_recfl(VDI_handle,pxyarray);
	vswr_mode(VDI_handle,0);
	wind_update(0);
	graf_mouse(257,0);
}

long Get_Obj_Ofs(const FILOBJ *start,int offset)
{
	FILOBJ	*o;
	int		loop;

	o=start;
	for(loop=0; loop<offset; loop++)
		o=o->next;
	return o;
}

int Do_Swap_Same(pos1,pos2)
{
	FILOBJ	copy1,copy2,
				*o1,*o2,
				*next1,*prev1;

	o1=Get_Obj_Ofs(win[active].top,pos1);

	if ( pos2 < Record_Left_Down(win[active].top) )
	{
		o2=Get_Obj_Ofs(win[active].top,pos2);
		copy1=*o1;
		copy2=*o2;
		*o1=copy2;
		*o2=copy1;
		o1->next=copy1.next;
		o1->prev=copy1.prev;
		o2->next=copy2.next;
		o2->prev=copy2.prev;
	}
	else
	{
		copy1=*o1;
		next1=copy1.next;
		prev1=copy1.prev;
		if (prev1 != 0)
			prev1->next=copy1.next;
		if (next1 != 0)
			next1->prev=copy1.prev;

		if (win[active].first==o1)
			win[active].first=next1;
		if (win[active].top==o1)
			win[active].top=next1;

		

	}
	Update_W(&win[active],MINX,MINY,MAXX,MAXY);
}

/***************************************************** MOUSE EVENT */
int Process_Mouse()
{
	int	x,y,w,h;			/* active window coordinates */
	int	pos;				/* position draged from on activ */

	int	out_x,out_y;	/* reales pos */

	int	placed_on;		/* dest window nr */
	int	new_pos;			/* dest window pos */
	int	x1,y1,w1,h1;	/* coordinates of dest window */

	if (active != -1)
	{
		wind_get( win[active].handle, 4, &x, &y, &w, &h );
		if ( Intercept(ev_mox,ev_moy,0,0,x,y,w,h)==0 )
		{
			pos=(ev_moy-y-2)/16;
			if ( pos < Record_Left_Down(win[active].top) )
			{
				Invert_Box(x,y+pos*16+2,176,16);
				graf_dragbox(176,16,x,y+pos*16+2,MINX,MINY,MAXX,MAXY,
									&out_x,&out_y);
				Invert_Box(x,y+pos*16+2,176,16);
				
				placed_on=On_Which_Window(out_x+88,out_y+8);
				if ( placed_on != -1 )
				{
					wind_get( win[placed_on].handle, 4, &x1, &y1, &w1, &h1 );
					new_pos=(out_y-y1-2+7)/16;
					if ( placed_on == active )
					{
						if ( pos != new_pos )
						{
							Do_Swap_Same(pos,new_pos);
						}
					}
				}
			}
		}
	}
}


/****************************************************** MENU EVENT */
int Process_Menus()
{
	menu_tnormal(gaddr(0,MENU),ev_mgpbuff[3],1);
	switch(ev_mgpbuff[4]) {
		case MFQUIT: {
			quit=0;
			break;
		}
		case MDABOUT: {
			about_discus();
			break;
		}
		case MSOATH: {
 			set_paths();
			while (exist_paths() != 0)
	 			set_paths();
			break;
		}
	}
}

/*************************************************** MESSAGE EVENT */
int Process_Message()
{
	int	h;

	switch(ev_mgpbuff[0]) 
	{
		case 10: {					/* Menu selected */
			Process_Menus();
			break;
		}
		case 20: {					/* redraw part of window */
			h=Our_Window(ev_mgpbuff[3]);
			if( h != -1)
				Update_W(&win[h],ev_mgpbuff[4],ev_mgpbuff[5],
											ev_mgpbuff[6],ev_mgpbuff[7]);
			break;
		}
		case 21: {					/* new window is placed TOP */
			h=Our_Window(ev_mgpbuff[3]);
			if( h != -1) {
				wind_set(win[h].handle,10,win[h].handle,0,0,0);
				active=h;
			} else
				active=-1;
			break;
		}
		case 23: {					/* window FULL button */
			break;
		}
		case 24: {					/* Arrows has been pressed */
			break;
		}
		case 26: {					/* vertical slider is changed */
			break;
		}
		case 28: {					/* window is moved */
			h=Our_Window(ev_mgpbuff[3]);
			if( h != -1)
				wind_set(win[h].handle,5,ev_mgpbuff[4],ev_mgpbuff[5],
											ev_mgpbuff[6],ev_mgpbuff[7]);
			break;
		}
	}
}

/******************************************************* MAIN LOOP */
int Main_Loop()
{
	graf_mouse(0,0);
	menu_bar(gaddr(0,MENU),1);
	Init_Data();
	Create_Windows();
	do {
		ev_mwhich=evnt_multi(0x13,1,1,1,
						0,0,0,0,0,0,0,0,0,0,
						ev_mgpbuff,0,0,
				 		&ev_mox,&ev_moy,&ev_mobutton,&ev_mokstate,
						&ev_kreturn,&ev_breturn);
	
		if (ev_mwhich==16)
			Process_Message();
		if (ev_mwhich==1)
			Process_Keys();
		if (ev_mwhich==2)
			Process_Mouse();
	} while (quit==1);
	menu_bar(gaddr(0,MENU),0);
}