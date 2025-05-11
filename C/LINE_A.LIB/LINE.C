int a_effekte[512];

long A_Base;
long *A_Font;

struct a_fontheader {
     int  s1[18];
     int  first_ade;
     int  last_ade;
     int  s2[7];
     int  l_off;
     int  r_off;
     int  weight;
     int  uline;
     int  litemask;
     int  skewmask;
     int  flag;
     int  *hoff_table;
     int  *off_table;
     long *fontdat;
     int  width;
     int  height;
} *Font; 

struct a_init {
     int  v_planes;
     int  v_lin_wr;
     int  *CONTRL;
     int  *INTIN;
     int  *PTSIN;
     int  *INTOUT;
     int  *PTSOUT;
     int schrott[11];
     long *patptr;
} *Line_A;


int  a_flclip = 0, /* False */
     a_xminclip,a_xmaxclip,
     a_yminclip,a_ymaxclip;



a_arg(ptr,nr,arg)
  int *ptr;
  int nr,arg;
{
     *(ptr + nr) = arg;
}


a_parg(ptr,nr,arg)
  long *ptr;
  int nr,*arg;
{
     *(ptr + nr) = arg;
}



a_xycol(x1,y1,x2,y2,col1,col2,col3,col4)
  int x1,y1,x2,y2,col1,col2,col3,col4;
{
     a_arg(Line_A,19,x1);
     a_arg(Line_A,20,y1);
     a_arg(Line_A,21,x2);
     a_arg(Line_A,22,y2);

     a_arg(Line_A,12,col1);
     a_arg(Line_A,13,col2);
     a_arg(Line_A,14,col3);
     a_arg(Line_A,15,col4);
}


a_fill(wr_mode,patptr,patmask)
  int wr_mode,patmask,*patptr;
{
     a_arg(Line_A,18,wr_mode);
     Line_A->patptr = patptr;
     a_arg(Line_A,25,patmask);
}


a_clip_set()
{
     a_arg(Line_A,27,a_flclip);
     a_arg(Line_A,28,a_xminclip);
     a_arg(Line_A,29,a_yminclip);
     a_arg(Line_A,30,a_xmaxclip);
     a_arg(Line_A,31,a_ymaxclip);
}


a_2arg(x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,patptr,patmask)
  int x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,patmask,*patptr;
{
     a_xycol(x1,y1,x2,y2,col1,col2,col3,col4);
     a_fill(wr_mode,patptr,patmask);
}



long a_init()
{
      asm(".dc.w $a000");
      asm("move.l a0,_A_Base");
      asm("move.l a1,_A_Font");

     Line_A = A_Base;
     a_clip_set();
}


put_pixel(x,y,color)
  int x,y,color;
{
     a_arg(Line_A->PTSIN,0,x);
     a_arg(Line_A->PTSIN,1,y);
     a_arg(Line_A->INTIN,0,color);

     asm(".dc.w $a001");
}


int get_pixel(x,y)
  int x,y;
{
     a_arg(Line_A->PTSIN,0,x);
     a_arg(Line_A->PTSIN,1,y);

     asm(".dc.w $a002");
}


line(x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,mask)
  int x1,y1,x2,y2,col1,col2,col3,col4,mask,wr_mode;
{
     a_xycol(x1,y1,x2,y2,col1,col2,col3,col4);

     a_arg(Line_A,17,mask);
     a_arg(Line_A,18,wr_mode);
     a_arg(Line_A,16,-1);

     asm(".dc.w $a003");
}


hline(x1,y1,x2,col1,col2,col3,col4,wr_mode,patptr,patmask)
  int x1,y1,x2,col1,col2,col3,col4,wr_mode,patmask,*patptr;
{
     a_xycol(x1,y1,x2,0,col1,col2,col3,col4);

     a_fill(wr_mode,patptr,patmask);

     asm(".dc.w $a004");
}


set_clipping(cclip,xmin,ymin,xmax,ymax)
  int cclip,xmin,ymin,xmax,ymax;
{
     a_flclip = cclip;
     a_xminclip = xmin;
     a_xmaxclip = xmax;
     a_yminclip = ymin;
     a_ymaxclip = ymax;

     a_clip_set();
}


fill_rectangle(x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,patptr,patmask)
  int x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,patmask,*patptr;
{
     a_2arg(x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,patptr,patmask);

     asm(".dc.w $a005");
}


fill_polygon(array,anz,y,col1,col2,col3,col4,wr_mode,patptr,patmask)
  int *array,anz,y,col1,col2,col3,col4,wr_mode,patmask,*patptr;
{
  int i;

     a_fill(wr_mode,patptr,patmask);

     a_arg(Line_A,20,y);
     a_arg(Line_A,12,col1);
     a_arg(Line_A,13,col2);
     a_arg(Line_A,14,col3);
     a_arg(Line_A,15,col4);

     for (i = 0; i < (anz+1)*2; i++)
          a_arg(Line_A->PTSIN,i,*array++);

     a_arg(Line_A->CONTRL,1,anz);

     asm(".dc.w $a006");
}


put_char(zeichen,x,y)
  int zeichen,x,y;

{
  int *sourcex;

     sourcex = Font->off_table + zeichen - Font->first_ade;

     a_arg(Line_A,36,*sourcex);
     a_arg(Line_A,37,0);

     a_arg(Line_A,38,x);
     a_arg(Line_A,39,y);

     a_arg(Line_A,40,*(sourcex+1) - *sourcex);
     a_arg(Line_A,41,Font->height);

     asm(".dc.w $a008");
}



set_font(font,style,angle,scale_on,wr_mode)
  int font,style,angle,scale_on,wr_mode;
{
     Font = *(A_Font+font);

     a_arg(Line_A,51,scale_on);
     a_arg(Line_A,33,-1);
     a_arg(Line_A,34,1);
     a_arg(Line_A,56,0x40);

     a_arg(Line_A,18,wr_mode);
     a_arg(Line_A,53,15);
     a_arg(Line_A,57,0);

     a_parg(Line_A,21,Font->fontdat);
     a_arg(Line_A,44,Font->width);

     a_arg(Line_A,45,style);
     a_arg(Line_A,49,Font->r_off);
     a_arg(Line_A,50,Font->l_off);
     a_arg(Line_A,52,angle);
     a_arg(Line_A,35,1);
     a_arg(Line_A,46,Font->litemask);
     a_arg(Line_A,47,Font->skewmask);
     a_arg(Line_A,48,Font->weight);

     a_parg(Line_A,27,a_effekte);
     a_arg(Line_A,32,0x8000);
}


put_string(array,x,y,abstand)
  char *array;
  int x,y,abstand;
{
  int *ptr = Line_A;

     while (*array) {
          put_char(*array++,x,y);
          x += *(ptr + 40) + abstand;
     }
}


show_mouse()
{
     a_arg(Line_A->CONTRL,1,0);
     a_arg(Line_A->CONTRL,3,1);
     a_arg(Line_A->INTIN,0,0);

     asm(".dc.w $a009");
}


hide_mouse()
{
     asm(".dc.w $a00a");
}


new_mouse(cursor,mask)
  int cursor[16],mask[16];
{
  int i;

     for (i = 0; i < 16; i++) {
          a_arg(Line_A->INTIN,i+5,mask[i]);
          a_arg(Line_A->INTIN,i+21,cursor[i]);
     }

     a_arg(Line_A->INTIN,3,0);
     a_arg(Line_A->INTIN,4,1);

     asm(".dc.w $a00b");
}


draw_sprite(x,y,array,sprbuf)
  int x,y,*array,*sprbuf;
{
     asm("movem.l d0-d7/a0-a6,-(sp)");

     asm("move 8(R14),d0");  /* x- Koord. */
     asm("move 10(R14),d1");  /* y- Koord. */
     asm("move.l 12(R14),a0");
     asm("move.l 16(R14),a2");

     asm(".dc.w $a00d");
     asm("movem.l (sp)+,d0-d7/a0-a6");
}


undraw_sprite(sprbuf)
  int *sprbuf;
{
     asm("move.l 8(R14),a2");
     asm(".dc.w $a00c");
}

d_main()
{
}

