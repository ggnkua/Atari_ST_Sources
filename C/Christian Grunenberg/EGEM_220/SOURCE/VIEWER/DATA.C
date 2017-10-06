
#include "data.h"

SETUP set={4,{0,0,BLACK},{0,0,BLACK},{0,0,0,0}};

#ifndef SMALLTOOL
static char *mem="Not enough memory to load";
#endif
static byte textline[1024];

void ClearData(DATA *data)
{
	if (data->valid)
	{
		if (data->img_mem)
			Mfree(data->img_mem);
		if (data->mem)
			Mfree(data->mem);
	}

	memset(data->fname,0,sizeof(DATA)-sizeof(WIN *)-sizeof(SCROLL));
}

void CalcText(DATA *data)
{
	TEXT *text=data->text;
	long i=data->lines;
	int rows=0,tabs=data->tab_size-1;

	if (tabs<=0)
		for (rows=data->rows;--i>=0;text++)
			text->max_len = text->len;
	else
		for (;--i>=0;text++)
			if (rows<(text->max_len=text->len+text->tabs*tabs))
				rows = text->max_len;
	data->max_rows = rows;
}

#ifndef SMALLTOOL
static void load_error(int icn,char *text,char *file)
{
	char *p=(char *) textline;

	strcpy(p,text);
	if (file)
		strcat(strcat(p," file "),GetFilename(file));
	else
		strcat(p," file!");
	error(icn,p);
}
#endif

void SetFont(DATA *data,boolean set_font)
{
	int out[8];
#ifdef CURSOR
	int i,*p;
#endif

	v_set_text(data->font.id,data->font.size,FAIL,0,0,out);
	data->font_cw = out[2];
	data->font_ch = out[3];
	vqt_extent(x_handle," ",out);
	data->font_spw = out[4];
	data->font_prop = FontInfo(data->font.id)->type & (FNT_PROP|FNT_ASCII);

	if (set_font)
	{
		set.text = data->font;
		if (!data->font_prop)
			set.dump = data->font;
	}

#ifdef CURSOR
	if (data->font_prop)
		memset(data->crs_width,0xffff,512);
	else
		for (p=data->crs_width,i=256;--i>=0;)
			*p++ = data->font_cw;
#endif
}

static int LoadText(DATA *data,char *fmem,char *fname,long len,long handle,int ascii)
{
	TEXT *t;
	byte *q,*p,spec[256];
	char c,s='\r',tab='\t';
	long max_lines;
	int cnt;

	if ((data->mem=GetMsgBuffer(max_lines=(len<2048) ? 4096 : len<<1))!=NULL)
	{
		data->valid = TRUE;
		data->data = data->mem;
		data->size = len;

		if (fmem || Fread((int) handle,len,data->data)==len)
		{
		#ifdef CURSOR
			memset(data->mrk_line,0xffff,40);
			memset(data->mrk_row,0xffff,20);
		#endif

			load_dump:
			data->font = ascii ? set.text : set.dump;
			SetFont(data,FALSE);

			data->tabs = data->rows = 0;
			data->lines = 1;
			data->text = t = (TEXT *) &data->mem[(len+32) & ~15];

			if (fmem)
				memcpy(data->data,fmem,len);

			if (ascii)
			{
				memset(spec,0,256);
				spec[0] = spec[9] = spec[10] = spec[13] = 0xff;

				max_lines -= len+32;
				max_lines /= sizeof(TEXT);
				data->flag = ASCII;

				t->text = q = data->data;
				*(p=&q[len]) = '\0';

				for (cnt=0;;)
				{
					while (!spec[*q++]);

					if ((c=q[-1])==tab)
						cnt++;
					else
					{
						t->tabs = cnt;
						if (cnt>data->tabs)
							data->tabs = cnt;

						t->len = cnt = (int) (q-t->text-1);
						if (cnt>data->rows)
							data->rows = cnt;

						t++;
						if (--max_lines<=0)
						{
							if (q<p)
							{
								ascii = FALSE;
								goto load_dump;
							}
							break;
						}
						else if (c=='\0')
						{
							if (q>=p)
								break;
						}
						else if (c==s && *q++!='\n')
							q--;

						t->text = q;
						data->lines++;
						cnt = 0;
					}
				}
			}
			else
			{
				data->flag = DUMP;
				data->rows = (len>=64) ? 64 : (int) len;
				data->lines = ((len+63)>>6);

				q = data->data;
				for (;len>0;len-=64,q+=64)
				{
					t->text = q;
					t->tabs = 0;
					t->len = (len>64) ? 64 : (int) len;
					t++;
				}
			}

			if (data->tabs)
				data->tab_size = set.tab;

			CalcText(data);
			Mshrink(0,data->mem,(long) (((byte *) t)-data->mem));
			return(LOADED);
		}
		else
			return(DISC_ERR);
	}
	else
		return(MEM_ERR);
}

#include "decode.c"

static int LoadImage(IMG *img_hdr,DATA *data,char *fmem,long len,long handle)
{
	byte *end,*start,*buf;

	if ((data->mem=GetMsgBuffer(len+16))!=NULL)
	{
		buf = data->mem;
		if ((long) buf & 1)
			buf++;

		data->valid = TRUE;
		data->data = buf;
		data->size = len;

		if (fmem || Fread((int) handle,len,buf)==len)
		{
			if ((data->img_mem=Malloc(mfdb_size(&data->img)+1024))==NULL)
				return(MEM_ERR);
			else
			{
				data->flag = IMAGE;

				if (fmem)
					memcpy(buf,fmem,len);

				start = (byte *) &buf[img_hdr->headlength<<1];
				end = &start[len];

				buf = data->img_mem;
				if ((long) buf & 1)
					buf++;
				decode_img(start,end,(byte *) (data->img.fd_addr=buf),data->width,data->height,data->img.fd_wdwidth<<1,img_hdr->patlen);

			#ifndef XCLIPBRD
				Mfree(data->mem);
				data->mem = NULL;
			#endif

				return(LOADED);
			}
		}
		else
			return(DISC_ERR);
	}
	else
		return(MEM_ERR);
}

int LoadData(DATA *data,char *fname,char *fmem,long fsize)
{
	char buffer[1024];
	IMG *img_hdr;
	byte *buf,*src,c;
	int i,j,loaded,ascii,d,state,crlf;
	long handle;

	if (fmem || ((handle=Fopen(fname,0))>0 && Fread((int) handle,1024,buffer)>0))
	{
		if (fmem)
			buf = (byte *) fmem;
		else
		{
			fsize = Fseek(0l,(int) handle,SEEK_END);
			Fseek(0l,(int) handle,SEEK_SET);
			buf = (byte *) buffer;
		}

		ClearData(data);
		img_hdr = (IMG *) buf;
		mfdb(&data->img,NULL,data->width=img_hdr->width,data->height=img_hdr->height,1,1);

		for (ascii=crlf=0,i=j=(fsize>1024) ? 1024 : (int) fsize,src=buf;--i>=0;)
		{
			if ((c=*src++)<9 || (c>13 && c<32 && c!=27))
				ascii++;
			if (c==13 || c==10 || c==0)
				crlf++;
		}

		ascii = (ascii<=(j>>4) && crlf>=(j/100));

		graf_mkstate(&d,&d,&d,&state);
		if (state & K_CTRL)
			ascii = TRUE;
		else if (state & K_ALT)
			ascii = FALSE;

		i = img_hdr->headlength;
		if ((state & (K_ALT|K_CTRL)) || fsize<=sizeof(IMG) || i<8 || img_hdr->nplanes!=1 || img_hdr->version<0 || data->width<1 || data->height<1 || (fsize>>1)<=i)
			loaded = LoadText(data,fmem,fname,fsize,handle,ascii);
		else
			loaded = LoadImage(img_hdr,data,fmem,fsize,handle);
		if (loaded!=LOADED)
			ClearData(data);

		if (fmem==NULL)
			Fclose((int) handle);
	}
	else
		loaded = DISC_ERR;

#ifndef SMALLTOOL
	switch (loaded)
	{
	case DISC_ERR:
		load_error(X_ICN_DISC_ERR,"Couldn't read",fname);break;
	case MEM_ERR:
		load_error(X_ICN_ALERT,mem,fname);break;
	case LOADED:
#else
	if (loaded==LOADED)
	{
#endif
		if (fname)

			strcpy(data->fname,fname);
	}
	return(loaded);
}

#ifdef CURSOR
int StringWidth(DATA *data,byte *string,int len)
{
	int d,w=0,cw,set=0,*table=data->crs_width;
	byte c;

	while (--len>=0 && (c=*string++)!='\0')
	{
		if ((cw=table[c])<0)
		{
			if (!set)
			{
				v_set_text(data->font.id,data->font.size,FAIL,0,0,NULL);
				set++;
			}
			vqt_width(x_handle,c,&cw,&d,&d);
			table[c] = cw;
		}
		w += cw;
	}
	return(w);
}

int CharWidth(DATA *data,byte c)
{
	byte str=c;
	return(StringWidth(data,&str,1));
}

static int calc_cursor(DATA *data,GRECT *cursor)
{
	SCROLL *sc=&data->sc;
	long line=data->crs_line;
	int row=data->crs_row;

	if (line<sc->vpos || line>=(sc->vpos+sc->vpage) || !window_work(data->win,cursor))
		return(FALSE);

	if (data->crs_valid)
	{
		cursor->g_x += data->crs_x;
		cursor->g_y += (int) (data->crs_y-sc->px_vpos);
	}
	else
	{
		cursor->g_x += (data->crs_x=StringWidth(data,textline,row));
		cursor->g_y += (int) ((data->crs_y=data->crs_line*data->font_ch)-sc->px_vpos);
		if (row>=(data->crs_len=(int) strlen((char *) textline)))
		{
			data->crs_row = data->crs_len;
			data->crs_w = data->font_spw;
		}
		else
			data->crs_w = CharWidth(data,textline[row]);
	}

	cursor->g_x -= (int) sc->px_hpos;
	cursor->g_w = data->crs_w;
	cursor->g_h = data->font_ch;
	data->crs_valid = 1;
	return (TRUE);
}

static void draw_cursor(int f,WIN *d,GRECT *r,GRECT *w,void *p)
{
	rc_sc_invert(r);
}

void DrawCursor(DATA *data)
{
	GRECT work;
	if (calc_cursor(data,&work))
	{
		WIN *win=data->win;
		win->vdi_handle = -1;
		draw_window(win,&work,data,MOUSE_TEST,draw_cursor);
		win->vdi_handle = x_handle;
	}
}
#endif

byte *MakeString(DATA *data,TEXT *src,int *len,byte **end)
{
	byte *text=src->text,*t=textline,*start=t+1;
	byte s='\t',sp=' ';
	int i,j=src->len,masc;

	if (data->flag==DUMP)
	{
		while (--j>=0)
			if ((*t++=*text++)=='\0')
				t[-1] = sp;
	}
	else if (src->tabs==0 || (masc=data->tab_size)==0)
		while (--j>=0)
			*t++ = *text++;
	else if (--masc==0)
	{
		for (;--j>=0;)
			if ((*t++=*text++)==s)
				t[-1] = sp;
	}
	else
		for (;--j>=0;)
			if ((*t++=*text++)==s)
			{
				t[-1] = sp;
				for (i=masc - (((int) (t-start)) & masc);--i>=0;)
					*t++ = sp;
			}

	*t = '\0';
	*len = (int) (t-textline);
	if (end)
		*end = t;

	return(textline);
}

static void DrawText(DATA *data,GRECT *area,int x,int y,SCROLL *sc)
{
#ifdef CURSOR
	GRECT cursor;
	int draw;
#endif
	byte *t,*start,c=' ';
	TEXT *src;
	int i,j,offset,extent[8];
	long start_line,max_lines;
	int page,lines,xe=area->g_x+area->g_w;
	byte *end;

	v_set_mode((data->font_cw&7)==0 && data->font_prop==0 ? MD_REPLACE : MD_TRANS);
	v_set_text(data->font.id,data->font.size,data->font.color,0,0,NULL);
	rc_sc_clear(area);

	start_line = (int) ((area->g_y-y)/data->font_ch);
	y += ((int) start_line)*data->font_ch;
	start_line += sc->vpos;

	if (data->font_prop)
		x -= (int) sc->px_hpos;
	else
	{
		offset = (area->g_x-x)/data->font_cw;
		x += offset*data->font_cw;
		page = (area->g_x-x+area->g_w+data->font_cw-1)/data->font_cw;
		offset += (int) sc->hpos;
	}

	max_lines = data->lines-start_line;
	lines = (area->g_y-y+area->g_h+data->font_ch-1)/data->font_ch;
	if (lines>max_lines)
		lines = (int) max_lines;

	src = &data->text[start_line];
	for (;--lines>=0;y+=data->font_ch,start_line++,src++)
	{
		start = MakeString(data,src,extent,&end);

	#ifdef CURSOR
		draw = (data->crs_on && start_line==data->crs_line && calc_cursor(data,&cursor) && rc_intersect(area,&cursor));
	#endif

		for (i=extent[0],t=end;*--t==c && --i>0;);

		t = start;
		if (!data->font_prop)
		{
			if ((i-=offset)>page)
				i = page;
			t += offset;
		}

		if (i>0)
		{
			t[i] = '\0';
			for (j=x;*t++==c;j+=data->font_spw,i--);
			t--;

			if (i>120)
				for (;j<xe;)
				{
					t += 120;
					c = *t;
					*t = '\0';
					v_gtext(x_handle,j,y,(char *) (t-120));
					if ((i-=120)<=0)
						break;
					if (data->font_prop)
					{
					#ifdef CURSOR
						j += StringWidth(data,t-120,120);
					#else
						vqt_extent(x_handle,(char *) (t-120),extent);
						j += extent[4];
					#endif
					}
					else
						j += 120*data->font_cw;
					*t = c;
				}
			else if (i>0)
				v_gtext(x_handle,j,y,(char *) t);
		}

	#ifdef CURSOR
		if (draw)
			rc_sc_invert(&cursor);
	#endif
	}
}

static int color[] = {BLACK,WHITE};

static void DrawImg(DATA *data,GRECT *area,int dx,int dy,SCROLL *sc)
{
	GRECT work;
	int pxy[8],x,y,w,h,*ptr=pxy;

	*ptr++ = x = area->g_x-dx+(int) sc->px_hpos;
	*ptr++ = y = area->g_y-dy+(int) sc->px_vpos;
	*ptr++ = x+(w=min(data->width-x,area->g_w))-1;
	*ptr++ = y+(h=min(data->height-y,area->g_h))-1;

	if (w>0 && h>0)
	{
		*ptr++ = x = area->g_x;
		*ptr++ = y = area->g_y;
		*ptr++ = x+w-1;
		*ptr++ = y+h-1;
		vrt_cpyfm(x_handle,MD_REPLACE,pxy,&data->img,screen,color);
	}
	else
	{
		rc_sc_clear(area);
		return;
	}

	if ((w=area->g_w-w)>0)
	{
		work.g_x = x+area->g_w-w;
		work.g_y = y;
		work.g_w = w;
		work.g_h = h;
		rc_sc_clear(&work);
	}

	if ((h=area->g_h-h)>0)
	{
		work.g_x = x;
		work.g_y = y+area->g_h-h;
		work.g_w = area->g_w;
		work.g_h = h;
		rc_sc_clear(&work);
	}
}

void DrawData(int f,WIN *win,GRECT *area)
{
	SCROLL *sc=win->scroll;
	DATA *data=(DATA *) win->para;
	int x=win->work.g_x+sc->tbar_l,y=win->work.g_y+sc->tbar_u;

	switch (data->flag)
	{
	case IMAGE:
		DrawImg(data,area,x,y,sc);break;
	case ASCII:
	case DUMP:
		DrawText(data,area,x,y,sc);break;
	default:
		rc_sc_clear(area);
	}
}
