
#include "proto.h"
#include <string.h>
#include <stdio.h>

#ifdef __PUREC__
#ifdef __MINT_LIB__
#include <basepage.h>
#define _BasPag	_base
extern void vql_attributes(int,int *);
#endif

static char	*envbeg;
static void copyenv(char *,char *);
static char *getvar(const char *);
#endif

static long *get_cookiejar(void);

void create_cookie (COOKIE *cookie, long id, long value)
{
	*((long *) cookie)++ = id;
	*((long *) cookie)++ = value;
}

boolean	new_cookie (COOKIE *entry)
{
	reg long *cookiejar = get_cookiejar();
	reg int  act_row = 0;
	
	if (cookiejar)
	{		
		while (*cookiejar)
		{
			cookiejar+=2;
			act_row++;
		}

		if (act_row<cookiejar[1])
		{
			cookiejar[2] = cookiejar[0];
			cookiejar[3] = cookiejar[1];
			
			*cookiejar++ = *((long *) entry)++;
			*cookiejar++ = *((long *) entry)++;
			return(TRUE);
		}
	}
	return(FALSE);
}

boolean	get_cookie (long cookie, long *value)
{
	reg long *cookiejar = get_cookiejar();
	
	if (cookiejar)
	{
		while (*cookiejar)
		{
			if (*cookiejar==cookie)
			{
				if (value)
					*value = *++cookiejar;
				return(TRUE);
			}
			cookiejar += 2;
		}
	}
	return(FALSE);
}

void remove_cookie (long cookie_id)
{
	reg long *cookiejar = get_cookiejar();
	
	if (cookiejar)
	{	
		while (*cookiejar && *cookiejar!=cookie_id)
			cookiejar += 2;
		
		if (*cookiejar)
		{
			do
			{
				*cookiejar++ = cookiejar[2];
				*cookiejar++ = cookiejar[2];
			} while (*cookiejar);
		}
	}
}

void move_cookiejar (long *dest, long size)
{
	reg long old_stack,*cookiejar,*dest_cop=dest;
	
	old_stack = Super (NULL);
	cookiejar = *((long **) 0x5a0l);

	if (cookiejar)
		do
		{
			*dest++ = *cookiejar++;
			*dest++ = *cookiejar++;
		} while (*cookiejar);

	*dest++ = 0;
	*dest	= size;
		
	cookiejar = (long *) 0x5a0l;
	*cookiejar = (long) dest_cop;

	Super ((void *) old_stack);
}

long cookie_size()
{
	reg long *cookiejar = get_cookiejar();
	
	if (cookiejar)
	{
		while (*cookiejar)
			cookiejar+=2;
		return(*++cookiejar);
	}
	return(0);
}

static long *get_cookiejar()
{
	reg long old_stack,*jar;
	
	old_stack = Super (NULL);
	jar = *((long **) 0x5a0l);
	Super ((void *) old_stack);
	return (jar);
}

#ifdef __PUREC__
char *getenv(const char *var)
{
	reg char *s = _BasPag->p_env;
	reg const char *v;

	if (s)
		while (*s)
		{
			for (v=var;*s && *s++==*v++;)
				if (*s=='=' && *v=='\0')
					return(++s);
			while (*s++);
		}
	return(NULL);
}

int	putenv(const char *entry)
{
	reg char *d,*s,*e;
	reg long envlen=0;
	reg unsigned l,new;
	
	s = _BasPag->p_env;
	if (s!=NULL && *s)
	{
		while (*s)
		{
			while (*s++);
		}
		envlen = s - _BasPag->p_env;
	}
	
	if (envbeg == NULL)
	{
		s = _BasPag->p_env;
		if ((envbeg=malloc(envlen+2))==NULL)
			return (FALSE);
		if (s!=NULL && *s)
			copyenv(s,envbeg);
		else
			envbeg[0] = envbeg[1] = '\0';
		_BasPag->p_env = envbeg;
	}
	
	if ((d=s=getvar(entry))!=NULL)
	{
		while (*s++);
		envlen -= s - d;
		
		if (*s)
			copyenv(s,d);
		else
			d[0] = d[1] = '\0';
	}
	
	for (e=(char *) entry,new=l=0;*e++;l++)
		if (*e=='=')
			new = l;
	
	if (new)
		envlen += l + 1;
		
	if ((d=malloc(envlen+2))==NULL)
		return (FALSE);
	
	copyenv(envbeg, d);
	free(envbeg);
	envbeg = d;

	if (new)
	{
		while (*d)
			while (*d++);
		e = (char *) entry;
		while ((*d++=*e++)!=0);
		*d = 0;
	}

	_BasPag->p_env = envbeg;
	return (TRUE);
}

static char *getvar(const char *var)
{
	reg char *r,*s = envbeg;
	reg const char *v;
	
	while (*s)
	{
		for (r=s,v=var;*s && *s++==*v++;)
			if (*s=='=' && (*v=='=' || *v == '\0'))
				return (r);
		while (*s++);
	}
	return (NULL);
}

static void copyenv(char *s, char *d)
{
	do
	{
		while ((*d++=*s++)!='\0');
	} while (*s);
	*d = '\0';
}
#endif

#ifndef SMALL_NO_CLIPBRD
void _scrp_init(void)
{
	reg char scrap[MAX_PATH],*path;
	reg long handle,len;

	scrp_read(scrap);
	if (scrap[0]=='\0')
	{
		if ((path=getenv("CLIPBOARD"))!=NULL || (path=getenv("CLIPBRD"))!=NULL || (path=getenv("SCRAPDIR"))!=NULL)
			strcpy(scrap,path);
		else
		{
			reg long ssp;

			strcpy(scrap,"X:\\clipbrd");
			ssp = Super(NULL);
			*scrap = (char) (*((int *) 0x446)+65);
			Super((void *) ssp);
		}
	}

	if ((len = strlen(scrap))>0)
	{
		len--;
		if (scrap[len]=='\\')
			scrap[len]='\0';
	
		handle = Dcreate(scrap);
		if (handle>=0 || handle==-36)
		{
			scrp_write(strcat(scrap,"\\"));
			return;
		}
	}

	scrp_write("");
}

int scrp_path(char *path,char *file)
{
	scrp_read(path);
	if (path[0])
	{
		MakeFullpath(path,NULL,(file) ? file : "");
		return (TRUE);
	}
	else
		return (FALSE);
}

void scrp_clear(int all)
{
	reg char scrap[MAX_PATH];

	if (scrp_path(scrap,(all) ? "*.*" : "scrap.*"))
	{
		reg DTA *old = Fgetdta(), dta;
		reg char fname[MAX_PATH];

		Fsetdta(&dta);
		if (!Fsfirst(scrap,0))
		{
			strcpy(fname,scrap);
			do
			{
				strcpy(GetFilename(fname),dta.d_fname);
				Fdelete(fname);
			}
			while (!Fsnext());
		}
		Fsetdta(old);
	}
}

long scrp_length()
{
	reg long length = 0;
	char scrap[MAX_PATH];

	if (scrp_path(scrap,"scrap.*"))
	{
		reg DTA *old = Fgetdta(), dta;

		Fsetdta(&dta);
		if (!Fsfirst(scrap,0))
			do
				length += dta.d_length;
			while (!Fsnext());
		Fsetdta(old);
	}

	return (length);
}

int	scrp_find(char *extension,char *filename)
{
	int exit = FALSE;
	char scrap[MAX_PATH];

	if (scrp_path(scrap,"scrap.*"))
	{
		reg DTA *old = Fgetdta(), dta;
		reg char path[MAX_PATH],ext_buf[MAX_PATH],*ext,*sep=" ,.";

		Fsetdta(&dta);
		if (!Fsfirst(scrap,-1))
		{
			strcpy(path,scrap);
			*GetFilename(scrap) = '\0';

			ext = strtok(strcpy(ext_buf,extension),sep);
			while (ext!=NULL)
			{
				strcpy(GetExtension(path)+1,ext);
				if (!Fsfirst(path,-1) && (dta.d_attrib & 0x18)==0)	/* (FA_LABEL|FA_DIR) */
				{
					MakeFullpath(filename,scrap,dta.d_fname);
					exit = TRUE;
					break;
				}
				ext = strtok(NULL,sep);
			}
		}
		Fsetdta(old);
	}

	return (exit);
}

#ifndef SMALL_NO_XACC_AV
void scrp_changed(int format,long best_ext)
{
	int msg[8];

	msg[0] = SC_CHANGED;
	msg[3] = format;
	*(long *) &msg[4] = best_ext;
	*(long *) &msg[6] = 0l;
	XAccBroadCast(msg);
}
#endif
#endif

void rc_sc_clear(GRECT *dest)
{
	rc_sc_copy(dest,dest->g_x,dest->g_y,0);
}

void rc_sc_invert(GRECT *dest)
{
	rc_sc_copy(dest,dest->g_x,dest->g_y,D_INVERT);
}

void rc_sc_copy(GRECT *source,int dx,int dy,int mode)
{
	reg int pxy[8];

	rc_grect_to_array(source,pxy);

	pxy[4] = dx;
	pxy[5] = dy;
	pxy[6] = dx+source->g_w-1;
	pxy[7] = dy+source->g_h-1;

	vro_cpyfm(_rc_handle,mode,pxy,screen,screen);
}

int rc_sc_scroll(GRECT *work,int dist_h,int dist_v,GRECT *work2)
{
	reg int dx,dy,abs_dist_h,abs_dist_v;
	int x,y,w,h;

	if (!rc_intersect(&desk,work))
		return (0);
	else if (dist_h==0 && dist_v==0)
		return (1);

	abs_dist_h = (dist_h<0) ? -dist_h : dist_h;
	abs_dist_v = (dist_v<0) ? -dist_v : dist_v;

	w = work->g_w;
	h = work->g_h;

	if (abs_dist_h<w && abs_dist_v<h)
	{
		dx = x = work->g_x;
		dy = y = work->g_y;

		if (dist_h>0)
			work->g_x += abs_dist_h;
		else
			dx += abs_dist_h;

		if (dist_v>0)
			work->g_y += abs_dist_v;
		else
			dy += abs_dist_v;

		work->g_w -= abs_dist_h;
		work->g_h -= abs_dist_v;
		rc_sc_copy(work,dx,dy,3);

		if (abs_dist_h)
		{
			if (abs_dist_v)
			{
				work2->g_x = x;
				if (dist_h>0)
					work2->g_x += work->g_w;
				work2->g_y = y;
				work2->g_w = abs_dist_h;
				work2->g_h = h - abs_dist_v;

				work->g_x = x;
				if (dist_v>0)
					work->g_y = y + work->g_h;
				else
					work2->g_y += abs_dist_v;

				work->g_w = w;
				work->g_h = abs_dist_v;

				return (2);
			}
			else
			{
				if (dist_h>0)
					work->g_x = x + work->g_w;
				work->g_w = abs_dist_h;
			}
		}
		else
		{
			if (dist_v>0)
				work->g_y = y + work->g_h;
			work->g_h = abs_dist_v;
		}
	}

	return (1);
}

int rc_sc_save(GRECT *rect,RC_RECT *rc)
{
	reg int pxy[8],*ptr = &pxy[4];
	reg long mem,len;

	mfdb(&rc->mfdb,NULL,rect->g_w,rect->g_h,0,planes);
	len = mfdb_size(&rc->mfdb);

	if (rect->g_x>=0 && rect->g_y>=0 && (rect->g_x+rect->g_w)<=max_w && (rect->g_y+rect->g_h)<=max_h &&
		(mem=(long) malloc(len+16l))>0l)
	{
		rc->mem = (void *) mem;
		rc->area = *rect;
		rc->mfdb.fd_addr = (int *) ((mem+1) & (~1l));

		rc_grect_to_array(&rc->area,pxy);
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = rc->area.g_w - 1;
		*ptr++ = rc->area.g_h - 1;
		vro_cpyfm(_rc_handle,3,pxy,screen,&rc->mfdb);

		rc->valid = TRUE;
	}
	else
		rc->valid = FALSE;

	return (rc->valid);
}

int _rc_sc_savetree(OBJECT *tree,RC_RECT *rc)
{
	GRECT save;
	int valid;

	save.g_x = tree->ob_x - 3;
	save.g_y = tree->ob_y - 3;
	save.g_w = tree->ob_width + 6;
	save.g_h = tree->ob_height + 6;

	MouseOff();
	valid = rc_sc_save(&save,rc);
	MouseOn();

	return (valid);
}

int rc_sc_freshen(int sx,int sy,RC_RECT *rc)
{
	reg int pxy[8],*ptr = &pxy[4];
	reg GRECT *area = &rc->area;

	if (rc->valid && (sx+area->g_w)<=max_w && (sy+area->g_h)<=max_h)
	{
		area->g_x = sx;
		area->g_y = sy;

		rc_grect_to_array(area,pxy);
		*ptr++ = 0;
		*ptr++ = 0;
		*ptr++ = area->g_w - 1;
		*ptr++ = area->g_h - 1;
		vro_cpyfm(_rc_handle,3,pxy,screen,&rc->mfdb);

		return (TRUE);
	}
	else
		return (FALSE);
}

int rc_sc_restore(int x,int y,RC_RECT *rc,int mode)
{
	reg int pxy[8],*ptr = pxy;

	if (rc->valid)
	{
		if (mode!=FAIL)
		{
			*ptr++ = 0;
			*ptr++ = 0;
			*ptr++ = rc->area.g_w - 1;
			*ptr++ = rc->area.g_h - 1;
			*ptr++ = x;
			*ptr++ = y;
			*ptr++ = x + pxy[2];
			*ptr++ = y + pxy[3];
			vro_cpyfm(_rc_handle,3,pxy,&rc->mfdb,screen);
		}

		if (mode!=FALSE)
		{
			free(rc->mem);
			memset(rc,0,sizeof(RC_RECT));
		}

		return (TRUE);
	}
	else
		return (FALSE);
}

static int clipping_area[4];

void save_clipping(int *area)
{
	reg long *clip=(long *) clipping_area;

	*((long *) area)++ = *clip++;
	*((long *) area)++ = *clip++;
}

void _clip_rect(GRECT *area)
{
	int pxy[4];
	rc_grect_to_array(area!=NULL ? area : &desk,pxy);
	restore_clipping(pxy);
}

void restore_clipping(int *new_area)
{
	reg long *clip = (long *) clipping_area,*area = (long *) new_area;

	if (clip[0]!=area[0] || clip[1]!=area[1])
	{
		vs_clip(x_handle,1,new_area);
		*clip++ = *area++;
		*clip = *area;
	}
}

static int _act_font,_mode,_lwidth,_lcolor,_lstart,_lend,_ltype,_fcolor,_finter,_fstyle,_fperi,_tfont,_tcolor,_teffect,_trotate;
int _theight;

void vs_attr(void)
{
	int attr[10];

	vqt_attributes(x_handle,attr);
	_act_font = _tfont = attr[0];
	_tcolor = attr[1];
	_trotate = attr[2];
	_theight = attr[7];
	vst_effects(x_handle,_teffect=0);

	vqf_attributes(x_handle,attr);
	_finter = attr[0];
	_fcolor = attr[1];
	_fstyle = attr[2];
	_fperi = attr[4];

#ifdef __PUREC__
	vql_attributes(x_handle,attr);
#else
	vql_attribute(x_handle,attr);
#endif

	_ltype = attr[0];
	_lcolor = attr[1];
	_mode = attr[2];

	vsl_ends(x_handle,_lstart=0,_lend=0);
	vsl_width(x_handle,_lwidth=1);
}

void _vdi_attr(int mode,int wid,int col,int type)
{
	v_set_mode(mode);
	v_set_line(col,wid,type,0,0);
}

void v_set_text(int font,int height,int color,int effect,int rotate,int *out)
{
	if (font>=0)
		v_set_font(font);

	if (out!=NULL || (height!=0 && height!=_theight))
	{
		int dummy[4];

		if (height==0)
			height = _theight;

		if (out==NULL)
			out = dummy;

		if (height>0)
			vst_height(x_handle,height,&out[0],&out[1],&out[2],&out[3]);
	#ifndef SMALL_NO_FONT
		else if (speedo && (FastFontInfo(_act_font)->type & FNT_VECTOR))
			vst_arbpt(x_handle,-height,&out[0],&out[1],&out[2],&out[3]);
	#endif
		else
			vst_point(x_handle,-height,&out[0],&out[1],&out[2],&out[3]);
		_theight=height;
	}

	if (color>=0 && color!=_tcolor)
		vst_color(x_handle,_tcolor=color);

	if (effect>=0 && effect!=_teffect)
		vst_effects(x_handle,_teffect=effect);

	if (rotate>=0 && rotate!=_trotate)
		vst_rotation(x_handle,_trotate=rotate);
}

int v_set_font(int font)
{
	if (_tfont!=font)
	{
		_act_font = vst_font(x_handle,_tfont=font);
		_theight = -22222;
	}
	return (_act_font);
}

int v_set_point(int all,int height)
{
	int d;

	_theight = -height;
#ifndef SMALL_NO_FONT
	if (all && speedo && (FastFontInfo(_act_font)->type & FNT_VECTOR))
		return (vst_arbpt(x_handle,height,&d,&d,&d,&d));
	else
#endif
		return (vst_point(x_handle,height,&d,&d,&d,&d));
}

void v_set_mode(int mode)
{
	if (mode>=0 && mode!=_mode)
		vswr_mode(x_handle,_mode=mode);
}

void v_set_line(int color,int width,int type,int start,int end)
{
	reg int ends;

	if (width>=0 && width!=_lwidth)
		vsl_width(x_handle,_lwidth=width);

	if (color>=0 && color!=_lcolor)
		vsl_color(x_handle,_lcolor=color);

	if (type>=0 && type!=_ltype)
		vsl_type(x_handle,_ltype=type);

	if (start>=0 && start!=_lstart)
	{
		_lstart = start;
		ends = TRUE;
	}
	else
		ends = FALSE;

	if (end>=0 && end!=_lend)
	{
		_lend = end;
		ends = TRUE;
	}

	if (ends)
		vsl_ends(x_handle,_lstart,_lend);
}

void v_set_fill(int color,int inter,int style,int peri)
{
	if (color>=0 && color!=_fcolor)
		vsf_color(x_handle,_fcolor=color);

	if (inter>=0 && inter!=_finter)
		vsf_interior(x_handle,_finter=inter);

	if (style>=0 && style!=_fstyle)
		vsf_style(x_handle,_fstyle=style);

	if (peri>=0)
	{
		if (peri>0)
			peri = 1;
		if (peri!=_fperi)
			vsf_perimeter(x_handle,_fperi=peri);
	}
}

void vsf_aespattern(int handle, int obx, int oby, int patternindex)
{
	static long aespatterns[] = {0x00000000L,0x00440011L,0x00550055L,0x88552288L,0x55AA55AAL,0xAADDAA77L,0x55FF55FFL,0xFFFFFFFFL};

	unsigned long pat;
	reg int i,j,pattern[16];
	reg char *patptr, *p;

	pat = aespatterns[patternindex];

	obx &= 3;
	pat >>= obx;
	pat &= 0x0F0F0F0FL;
	pat |= (pat<<4);

	oby &= 3;
	pat = (pat<<((4-oby)<<3))|(pat>>(oby<<3));

	patptr = (char *) pattern;
	for (i=4;--i>=0;)
	{
		p = (char *) &pat;
		for (j=4;--j>=0;)
		{
			*patptr++ = *p;
			*patptr++ = *p++;
        }
    }

	vsf_interior(handle, 4);
	vsf_udpat(handle, pattern, 1);
}

void v_aespattern(int ob_x, int ob_y, int pattern)
{
	vsf_aespattern(x_handle, ob_x, ob_y, pattern);
	_finter = 4;
}

void v_line(int x1,int y1,int x2,int y2)
{
	reg int pxy[4];
	
	pxy[0] = x1;
	pxy[1] = y1;
	pxy[2] = x2;
	pxy[3] = y2;
	v_pline(x_handle,2,pxy);
}

void _bar(int x,int y,int w,int h,int interior,int style,int color,int peri)
{
	reg int pxy[4];

	v_set_fill(color,interior,style,peri);

	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w - 1;
	pxy[3] = y + h - 1;
	v_bar(x_handle,pxy);
}

void v_rect(int sx,int sy,int dx,int dy)
{
	reg int pxy[10];

	pxy[0] = pxy[6] = pxy[8] = sx;
	pxy[1] = pxy[3] = pxy[9] = sy;
	pxy[2] = pxy[4] = dx;
	pxy[5] = pxy[7] = dy;
	v_pline(x_handle,5,pxy);
}

int mm2dpi(int size)
{
    switch (size)
    {
	case 35:
		return (720);
	case 42:
		return (600);
	case  71:
		return (360);
	case 85:
		return (300);
	case 117:
	case 118:
		return (216);
	case 130:
		return (196);
	case 141:
		return (180);
	case 175:
	case 176:
		return (144);
	case 211:
	case 212:
		return (120);
	default:
		return (25400/size);
    }
}

int min(int v_1,int v_2)
{
	if (v_1<v_2)
		return(v_1);
	else
		return(v_2);
}

int max(int v_1,int v_2)
{
	if (v_1>v_2)
		return(v_1);
	else
		return(v_2);
}

void Min(int *var,int val)
{
	if (*var>val)
		*var = val;
}

void Max(int *var,int val)
{
	if (*var<val)
		*var = val;
}

static int digits[] = {10000,1000,100,10};

int int2str(char *p,int val,int size)
{
	reg char *q = p,c = '0';
	reg int *d = digits,x,i,all = FALSE;

	if (val<0)
	{
		*q++ = '-';
		val = -val;
	}

	for (i=4;--i>=0;)
	{
		x = *d++;
		if (all || val>=x)
		{
			*q++ = val/x + c;
			val %= x;
			all = TRUE;
		}
	}

	*q++ = val + c;
	if (size>=0)
		*q = '\0';

	if ((i=(int) (q-p))<abs(size))
	{
		if (size<0)
			memcpy(&p[x=-size-i],p,i);
		else
			memcpy(&p[x=size-i],p,i+1);
		for (c=' ';--x>=0;)
			*p++ = c;
		return (abs(size));
	}
	else
		return (i);
}

char *strlcpy(reg char *d,reg char *s)
{
	while ((*d++=*s++)!='\0');
	return (d-1);
}

char UpperChar(char ch)
{
	if (ch>='a')
	{
		if (ch>'z')
		{
			if (ch=='„')
				return ('Ž');
			else if (ch=='”')
				return ('™');
			else if (ch=='')
				return ('š');
		}
		else
			return (ch-32);
	}

	return (ch);
}

char LowerChar(char ch)
{
	if (ch>='A')
	{
		if (ch>'Z')
		{
			if (ch=='Ž')
				return ('„');
			else if (ch=='™')
				return ('”');
			else if (ch=='š')
				return ('');
		}
		else
			return (ch+32);
	}

	return (ch);
}

int scan_2_ascii(int scan,int state)
{
	static int last_scan = 0,last_state = 0,last_ascii = 0;
	reg int sc = (int) (((unsigned) scan)>>8);

	if (last_scan==scan && last_state==state)
		return (last_ascii);

	last_scan = scan;
	last_state = state;

	if (state && sc)
	{
		reg KEYTAB *keytab = Keytbl((void *) -1l,(void *) -1l,(void *) -1l);
		if (sc>=120 && sc<=131)
			sc -= 118;
		if (state & 3)
			scan = (int) *(keytab->shift+sc);
		else
			scan = (int) *(keytab->unshift+sc);
	}

	return (last_ascii=UpperChar(scan));
}

void mfdb(MFDB *fm,int *adr,int w,int h,int st,int pl)
{
	fm->fd_addr	= adr;
	fm->fd_w = (w+15) & 0xfff0;
	fm->fd_h = h;
	fm->fd_wdwidth = fm->fd_w>>4;
	fm->fd_stand = st;
	fm->fd_nplanes = pl;
}

long mfdb_size(MFDB *fm)
{
	return ((long) (fm->fd_wdwidth<<1) * (long) fm->fd_h * (long) fm->fd_nplanes);
}
