						/* Alain Birtz, 8/12/85	*/
#include "gemdefs.h"

/************************************************************************/

#define WI_KIND		(MOVER|CLOSER|NAME)	/* can be moved, closed	*/
						/* and title exist	*/
#define NO_WINDOW	(-1)

/************************************************************************/

extern int	gl_apid;

/************************************************************************/

int box[28][4];					/* key			*/
int blank;					/* screen state		*/
int dot;					/* dot in float. point	*/
int oper=3;					/* current operation	*/
long base=10L;					/* 10=DECI, 16=HEXA	*/
long temp_base=0L;				/* used in octal,binary */
long mem_val, scr_val;				/* arithmetic value	*/
long mem_div=1L, scr_div=1L;			/* used in float. point	*/
char key_symb[3][12]={
	{'1','2','3','\275','4','5','6','+','7','8','9','-'},
	{'0','!','\361','*','.','b','o','\366','%','&','|','='},
	{'A','B','C','*','D','E','F','\366','0','&','|','='}
};
char hex_deci[][5]={"HEXA","DECI"};
char chr[]=" ";					/* to print one char	*/


int	menu_id ;				/* our menu id		*/

int 	phys_handle;				/* physical workstation	*/
int 	handle;					/* virtual workstation	*/
int	wi_handle;				/* window handle	*/
int	top_window;				/* handle of topped	*/

int	xdesk=450,ydesk=50,hdesk=310,wdesk=150;
int	xwork,ywork,hwork,wwork;		/* desktop , work areas	*/

int	msgbuff[8];				/* event message buffer	*/
int	mx,my;					/* mouse x and y pos.	*/
int	butdown;				/* button state		*/
int	d;					/* dummy variable	*/

int	contrl[12];				/* AES, VDI variable	*/
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];

int work_in[11];				/* Input GSX parameter	*/
int work_out[57];				/* Output GSX parameter	*/

/************************************************************************/

open_vwork()					/* open workstation	*/
{
int i;
	for(i=0;i<10;work_in[i++]=1);      
		work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
}

/************************************************************************/

open_window()					/* open window		*/
{
	wi_handle=wind_create(WI_KIND,xdesk,ydesk,wdesk,hdesk);
	wind_set(wi_handle, WF_NAME," Calculator ",0,0);
	wind_open(wi_handle,xdesk,ydesk,wdesk,hdesk);
	wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
}

/************************************************************************/

main()
{
	appl_init();
	phys_handle=graf_handle(&d,&d,&d,&d);
	menu_id=menu_register(gl_apid,"  Calculator");

	wi_handle=NO_WINDOW;
	butdown=1;

	multi();
}

/************************************************************************/

multi()
{
int event, k;

	while (1)
		{
		event = evnt_multi(MU_MESAG | MU_BUTTON,
				1,1,butdown,0,0,0,0,0,0,0,0,0,0,
				msgbuff,0,0,&mx,&my,&d,&d,&d,&d);

		wind_update(1);
		wind_get(wi_handle,WF_TOP,&top_window,&d,&d,&d);

		if (event & MU_MESAG)

/*..................................................begin switch........*/
switch (msgbuff[0])
{
	case WM_NEWTOP:case WM_TOPPED:
	if (msgbuff[3] == wi_handle)
		{
		wind_set(wi_handle,WF_TOP,0,0,0,0);
		draw();
		}
	break;

	case AC_CLOSE:
	if ((msgbuff[3] == menu_id)&&(wi_handle != NO_WINDOW))
		{
		v_clsvwk(handle);
		wi_handle = NO_WINDOW;
		}
	break;

	case WM_CLOSED:
	if (msgbuff[3] == wi_handle)
		{
		wind_close(wi_handle);
		wind_delete(wi_handle);
		v_clsvwk(handle);
		wi_handle = NO_WINDOW;
		graf_mouse(0,0);		/* arrow form		*/  
		}
	break;

	case WM_MOVED:
	if (msgbuff[3] == wi_handle)
		{
		wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],			msgbuff[7]);
		wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
		draw();
		}
	break;

	case AC_OPEN:
	if (msgbuff[4] == menu_id && wi_handle == NO_WINDOW)
		{
		open_vwork();
	        open_window();
		draw();
		}
	break;

}
/*....................................................end switch........*/

		if ((event & MU_BUTTON)&&(wi_handle == top_window))
			if (butdown)
				{
				if ((k=key_numb())>-1)
					math(k);
				if (k==-2)
					author();	
 				butdown=0;
				}
			else
				butdown=1;

		wind_update(0);

	}					/* end of while (1)	*/

}
       
/************************************************************************/

author()
{
int i;

	v_gtext(handle,box[26][0]+5,box[26][3]-5," by A.Birtz");
	for (i=0;i<15000;i++)
		;				/* timeout		*/
	v_gtext(handle,box[26][0]+5,box[26][3]-5,"           ");
}

/************************************************************************/

one_key(no,style)				/* draw one key		*/
int no, style;
{
char *s;

	if (no<24)
		{
		chr[0]=key_symb[(no<12 ? 0:1+(base==16L))][no%12];
		s=chr;
		}
	else
		s=hex_deci[no-24];

	graf_mouse(256,0);			/* hide mouse		*/
	vsf_interior(handle,style);		/* white or black	*/
	vr_recfl(handle,box[no]);		/* clear and fill	*/
	rect(box[no]);				/* draw box and text	*/
	v_gtext(handle,box[no][0]+7+2*(no>23),box[no][3]-4,s);
	graf_mouse(257,0);			/* show mouse		*/
}

/***********************************************************************/

reset_v()
{
	blank=1;
	dot=0;
	scr_val=mem_val=0L;
	scr_div=mem_div=1L;
}

/***********************************************************************/

plus()
{
long max_div;

	if (scr_div>1L || mem_div>1L)
		{
		max_div=(scr_div>mem_div ? scr_div:mem_div);
		scr_val=max_div/mem_div*mem_val + max_div/scr_div*scr_val;
		scr_div=max_div;
		}
	else
		scr_val += mem_val;
}

/***********************************************************************/

minus()
{
long max_div;

	if (scr_div>1L || mem_div>1L)
		{
		max_div=(scr_div>mem_div ? scr_div:mem_div);
		scr_val=max_div/mem_div*mem_val - max_div/scr_div*scr_val;
		scr_div=max_div;
		}
	else
		scr_val=mem_val-scr_val;
}

/***********************************************************************/

product()
{
	scr_val *= mem_val;
	scr_div *= mem_div;
	while (scr_div>100L)
		{
		scr_val /= 10L;
		scr_div /= 10L;
		}
}

/***********************************************************************/

quotient()
{
long work;

	if (!scr_div)				/* division by zero	*/
		return;

	if (scr_div>1L || mem_div>1L)
		{
		work=100L;
		scr_val=work/mem_div*mem_val*scr_div/scr_val;
		scr_div=100L;
		}
	else
		scr_val=mem_val/scr_val;
}

/***********************************************************************/

math(k)
int k;
{
int i;
long fact;

	blank=0;
	
	if (k!=-1 && k<21 && k%4!=3)		/* digit (DECI or HEXA)	*/
	    if (base==16L || (k<13 && (!dot || scr_div<100L)))
		{
		scr_val *= base;
		scr_val += (long) ((3*(k/4) + k%4 + 1)%(base==10L ? 10:16));
		if (dot)
			scr_div *= 10L;
		}

	switch(k)
	{
	case 3:reset_v();break;			/* clear		*/			case 7:case 11:case 15:case 19:case 21:case 22:
						/* + - * / & |		*/
		mem_div=scr_div;scr_div=1L;
		mem_val=scr_val;scr_val=0L;
		oper=k;blank=1;dot=0;break;
	case 13:				/* factorial		*/
		if (base==10L && scr_val>-1L && scr_val<16L)
			{
			i=1; fact=1L;
			while (i< (int) scr_val)
				fact *= (long) ++i;
			scr_val=fact;
			}
		break;
	case 14:if (base==10L)			/* sign change		*/
			scr_val= -scr_val;
		break;
	case 16:if (base==10L)			/* set float point dot	*/
			dot=1;
		break;
	case 17:case 18:			/* binary and octal	*/
		if (!dot && base==10L)
			{
			temp_base=(k==17 ? 2L:8L);
			if (k==17)		/* first 8 bits only	*/
				scr_val &= 0xff;
			}
		break;
	case 20:if (base==10L)			/* per cent (%)		*/
			{
			while (mem_div<100L)
				{
				mem_div *= 10L;	/* convert in float.	*/
				mem_val *= 10L;
				}
			product();scr_val /= 100L;
			}
		break;
	case 23:switch(oper)			/* equal (=)		*/
		{
		case  7:plus();break;
		case 11:minus();break;
		case 15:product();break;
		case 19:quotient();break;
		case 21:if (!dot)		/* 'and' operator	*/
				scr_val &= mem_val;
			break;
		case 22:			/* 'or' operator	*/
			if (!dot)
				scr_val |= mem_val;
			break;
		default:break;
		}
		break;
	case 24:case 25:			/* HEXA or DECI		*/
		base=(k==24 ? 16L:10L);
		one_key(24,(k==24));one_key(25,(k==25));
		for(i=12;i<21;i++)
			if (i%4!=3)		/* draw new key		*/
				one_key(i,0);
		if (dot)
			reset_v();
		if (mem_div>1L)
			{
			mem_val=0L;
			mem_div=1L;
			}
		break;
	default:
		break;
	}

	display();
}

/**************************************************************************/

rect(pos)                             /* pos[0],pos[1] left upper corner  */  
int pos[];                            /* pos[2],pos[3] right lower corner */                        
{
int pxyarray[12];
 
   pxyarray[0] = pos[0];
   pxyarray[1] = pos[1];
   pxyarray[2] = pos[2];
   pxyarray[3] = pos[1];
   pxyarray[4] = pos[2];
   pxyarray[5] = pos[3];
   pxyarray[6] = pos[0];
   pxyarray[7] = pos[3];
   pxyarray[8] = pos[0];
   pxyarray[9] = pos[1];
   pxyarray[10] = pos[2];              /* one more for corner end */
   pxyarray[11] = pos[1]; 

   v_pline(handle,6,pxyarray);
}

/***********************************************************************/

draw()
{
int i, j;
char chr[2];

	for(j=0;j<6;j++)			/* 6 key row		*/
		for(i=0;i<4;i++)		/* 4 column		*/
		{
	   	box[i+4*j][0]=xwork+20+30*i;	/* left upper x		*/
		box[i+4*j][2]=box[i+4*j][0]+20;	/* right lower x	*/
	   	box[i+4*j][1]=ywork+100+30*j;	/* left upper y		*/
	   	box[i+4*j][3]=box[i+4*j][1]+20;	/* right lower y	*/          
		}
	for(i=0;i<2;i++)			/* HEXA and DECI box	*/
	{
	box[i+24][0]=xwork+20+60*i;
	box[i+24][2]=box[i+24][0]+50;
	box[i+24][1]=ywork+70;
	box[i+4*j][3]=box[i+24][1]+20;
	}
        
	box[26][0]=xwork+20;			/* show box		*/
	box[26][2]=xwork+130;
	box[26][1]=ywork+20;
	box[26][3]=ywork+50;

	box[27][0]=xwork;			/* calculator box	*/
	box[27][1]=ywork;
	box[27][2]=xwork+wwork;
	box[27][3]=ywork+hwork;


	vsl_width(handle,2);			/* line width		*/
	graf_mouse(256,0);			/* hide mouse		*/  

	vsf_interior(handle,2);			/* style 2		*/
	vsf_style(handle,6);			/* index 6		*/
	vr_recfl(handle,box[27]);		/* fill window		*/

	graf_mouse(257,0);			/* show mouse		*/

	for(i=0;i<25;i++)			/* draw key box		*/ 
		one_key(i,0);			/* with white fill	*/	
	one_key(25,1);				/* DECI active		*/

	graf_mouse(256,0);			/* hide mouse		*/  

	vsf_interior(handle,0);			/* white		*/     
        vr_recfl(handle,box[26]);		/* clear		*/
	rect(box[26]);				/* draw show box	*/
	for(i=0;i<4;i++)			/* reduce size		*/
		box[26][i] += 3*(1-2*(i>1));
	rect(box[26]);				/* interior box		*/

	graf_mouse(3,0);			/* extented finger	*/
	graf_mouse(257,0);			/* show mouse		*/
}

/***********************************************************************/

key_numb()	/* return the clicked key number or -1	if outside	*/
{
int mx_k, my_k;
int r, c;

	if (mx>box[27][2]-3 && my>box[27][3]-3)
		return (-2);			/* mysterious box	*/

	mx_k = mx - (xwork + 20);		/* coord relative to	*/
	my_k = my - (ywork + 70);		/* the keypad block	*/

	if (mx_k<0 || mx_k>110 || my_k<0 || my_k>200)
		return (-1);			/* outside the keypad	*/

	r = my_k / 10;				/* 10 pixels row	*/
	c = mx_k / 10;				/* 10 pixels column	*/

	if (r % 3 == 2)
		return (-1);			/* between two row	*/

	r /= 3;					/* now r is key row	*/ 
						/* number		*/
	if (r == 0)
		if (c == 5)
			return (-1);		/* between HEX and DECI	*/
		else
			return (24 + c / 6);	/* HEXA or DECI value	*/

	if (c % 3 == 2)
		return (-1);			/* between column	*/

	c /= 3;					/* now c is column key	*/
						/* number		*/
	return (c + 4 * (r - 1));		/* other key		*/
}

/***********************************************************************/	
display()
{
int neg, s_index, l_div, i;
long same, value, work_base, r;
char s[12];

	for(i=0;i<12;i++)			/* white space		*/
		s[i]=' ';
	s[i]='\0';

	if (blank)				/* nothing to print	*/			{
		v_gtext(handle,box[26][0]+5,box[26][3]-5,s);
		return;
		}

	neg=0;
	s_index=11;
	same=value=scr_val;
	l_div= (scr_div>1L)+(scr_div>10L);

	work_base=(!temp_base ? base:temp_base);

	if (value==0L)				/* if zero		*/
		{
		if (l_div)
			{
			for(i=0;i<l_div;i++)
				s[s_index--]='0';
			s[s_index--]='.';
			}
		else
			if (dot)
				s[s_index--]='.';
			else
				s[s_index--]='0';
		}

	if (value<0L)				/* if negative		*/
		{
		same = value = -value; 		/* make positive	*/
		neg=1;				/* set neg flag		*/
		}

	while (value>0L)
		{
		if ((dot || scr_div>1L) && s_index==11-l_div)
			s[s_index--]='.';
		r = value;			/* % seem don't work	*/
		value /= work_base;		/* with long integer	*/
		r -= work_base*value;		/* on DRI C		*/
		s[s_index--]= (base==16L && r>9L ? 'A'-10:'0') + (int) r;
		}

	if (same && scr_div>same)
		{				/* header . and 0	*/
		i=l_div+s_index-11;
		while(i--)
			s[s_index--]='0';
		s[s_index--]='.';
		}

	temp_base=0L;

	if (neg==1)				/* negative need sign -	*/
		s[s_index]='-';

	v_gtext(handle,box[26][0]+5,box[26][3]-5,s);
}