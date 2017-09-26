#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"


void set_popup(OBJECT *dst, OBJECT *src, int offset, int len)
{
	long	t, v, l;
	int a=1;

	
	/* Strings umh„ngen */
	while(a <= SPTLAST)
	{
    dst[a].ob_spec.free_string=src[a+offset].ob_spec.free_string;
    ++a;
	}

	/* Slider setzen */
	l=SPTLAST-SPT1+1;	/* Sichtbare Zeilen */
	v=l*(long)(dst[0].ob_height); /* Sichtbare Pixel */
	
	/* Slidergr”že */
	t=(long)len*(long)(dst[0].ob_height);	/* Gesamte Liste in Pixeln */
	dst[SPSLIDE].ob_height=(int)(((long)dst[SPBAR].ob_height*v)/t);
	if(dst[SPSLIDE].ob_height < dst[SPSLIDE].ob_width)
		dst[SPSLIDE].ob_height=dst[SPSLIDE].ob_width;
	/* Sliderpos. */
	dst[SPSLIDE].ob_y=(int)((long)(
				(long)((long)(dst[SPBAR].ob_height-dst[SPSLIDE].ob_height)*
				 (long)(offset)) 
				 / 
				 (long)((long)len-l)));
}

void slide_popup(OBJECT *tree, OBJECT *dst, int *poffset, int *plen)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum, offset=*poffset, len=*plen;
	long	l, off;

	maxy=tree[SPBAR].ob_height-tree[SPSLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(tree, SPSLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(tree, SPBAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=SPTLAST-SPT1+1;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(len-l))/(long)maxy);
		if(off!=offset)
		{
			offset=(int)off;
			set_popup(tree, dst, offset, len);
			objc_draw(tree, 0, 8, sx,sy,sw,sh);
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	*plen=len;
	*poffset=offset;
}

int	scroll_form_popup(OBJECT *srcroot, int x, int y)
{ /* Verarbeitet das Popup aus dem Objc.-Tree poproot */ 
  /* Das Popup wird an der Position x,y ge”ffnet */ 
	/* Es wird ein Scrollbares Popup mit 16 Eintr„gen ge”ffnet */   
  /* Zurckgeliefert wird die Nr. des Eintrags (0-n) */ 
  /* oder -1 (=Cancel) */ 

	OBJECT	*poproot;   
  int a, mx, my, mox, moy, mb, dum;
  int	sx,sy,sw,sh;
  int obj, oobj, sel, evt; 
  int ox,oy,ow,oh,doy; 
  int klick=0;
  int	offset=0, len=0;


	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);
	
	wind_get(0,WF_WORKXYWH, &sx, &sy, &sw, &sh);
 
 	rsrc_gaddr(0, SCROLLPOP, &poproot);
 	
  /* Popup-Init */ 
	if(srcroot[0].ob_width > sw-poproot[SPUP].ob_width)
		srcroot[0].ob_width=sw-poproot[SPUP].ob_width;

	poproot[0].ob_width=srcroot[0].ob_width+poproot[SPUP].ob_width;
	poproot[SPUP].ob_x=poproot[SPDOWN].ob_x=poproot[SPBAR].ob_x=
		srcroot[0].ob_width;
	 
 	a=1;
  while(obj_type(poproot, a)==G_STRING)
  {
    poproot[a].ob_state&=(~SELECTED); 
    poproot[a].ob_width=srcroot[a].ob_width;
  	++a;
  }

	len=a-1;
	while(obj_type(srcroot, a++)==G_STRING)++len;
	
	set_popup(poproot, srcroot, 0, len);
	
  a=1; 
  sel=-1; 
 
  oobj=-1; 
  mox=moy=0; 
   
  /* Popup zeichnen */ 
 
  form_center(&poproot[0], &dum, &dum, &ow, &oh);
  if ((x+ow) > (sx+sw))
  	x=sx+sw-ow;
  if (x < sx)
  	x=sx;
  if ((y+oh) > (sy+sh))
  	y=sy+sh-oh;
  if (y < sy)
  	y=sy;

  poproot[0].ob_x=ox=x;
  poproot[0].ob_y=oy=y;
  form_dial(FMD_START,ox-3,oy-3,ow+3,oh+3,ox-3,oy-3,ow+3,oh+3);
  objc_draw(poproot,0,6,ox-3,oy-3,ow+3,oh+3);

  /* Warten, daž Taste losgelassen wird */
  mb=1;
	evnt_button(1,1,0,&dum,&dum,&dum,&dum);
  
  /* Popup verarbeiten */ 
  while (!klick) 
  { 
    graf_mkstate(&mx, &my, &dum, &dum); 
 
    evt=evnt_multi(MU_BUTTON|MU_M1, 
                1,1,1, 1,mx,my,1,1, 0,0,0,0,0,  
                NULL,0,0, &mx,&my,&mb, &dum, &dum, &dum); 
    
    if(evt & MU_BUTTON)
	    klick=mb & 1; 
 
  	if((evt & MU_BUTTON) && ((obj=objc_find(poproot,0,6,mx,my)) > SPTLAST))
  	{
  		klick=mb=0;
  		switch(obj)
  		{
  			case SPUP:
  				if(offset==0) break;
  				--offset;
  				set_popup(poproot, srcroot, offset, len);
  				objc_draw(poproot, 0, 8, sx,sy,sw,sh);
  			break;
  			case SPDOWN:
  				if(len-offset == SPTLAST-SPT1+1) break;
  				++offset;
  				set_popup(poproot, srcroot, offset, len);
  				objc_draw(poproot, 0, 8, sx,sy,sw,sh);
  			break;
  			case SPBAR:
  				objc_offset(poproot, SPSLIDE, &dum, &doy);
  				if(my < doy) /* Page up */
  				{
  					offset-=SPTLAST-SPT1+1;
  					if(offset < 0) offset=0;
  				}
  				else				/* Page down */
  				{
  					offset+=SPTLAST-SPT1+1;
	  				if(len-offset < SPTLAST-SPT1+1) offset=len-(SPTLAST-SPT1+1);
  				}
   				set_popup(poproot, srcroot, offset, len);
  				objc_draw(poproot, 0, 8, sx,sy,sw,sh);
	 			break;
  			case SPSLIDE:
  				slide_popup(poproot, srcroot, &offset, &len);
  			break;
  		}
  	}
    else if ((evt & MU_BUTTON) || (evt & MU_M1)) 
    { /* Vielleicht Maus-Bewegung */ 
      if ((mx != mox) || (my != moy)) 
      { 
        mox=mx; 
        moy=my; 
        obj=objc_find(poproot,0,6,mx,my); 
        if((poproot[obj].ob_state & DISABLED) | !(poproot[obj].ob_flags & SELECTABLE))
          obj=-1; 
        if (obj != oobj) 
        { 
          if (oobj > -1) 
            objc_change(poproot,oobj,0,ox,oy,ow,oh,poproot[oobj].ob_state&(~SELECTED),1); 
          if (obj > -1) 
            objc_change(poproot,obj,0,ox,oy,ow,oh,poproot[obj].ob_state|SELECTED,1); 
          oobj=sel=obj; 
        } 
      }/* endif mauspos*/ 
    }/* endif evnt Mouse */ 
  }/* end while noklick */ 
  form_dial(FMD_FINISH,ox-3,oy-3,ow+3,oh+3,ox-3,oy-3,ow+3,oh+3);

  evnt_button(1,1,0,&dum,&dum,&dum,&dum); 

	wind_update(END_UPDATE);
	wind_update(END_MCTRL);

	if(sel > -1) sel+=offset;
  return(sel); 
} 



int	form_popup(OBJECT *poproot, int x, int y)
{ /* Verarbeitet das Popup aus dem Objc.-Tree poproot */ 
  /* Das Popup wird an der Position x,y ge”ffnet */ 
   
  /* Zurckgeliefert wird die Nr. des Eintrags (0-n) */ 
  /* oder -1 (=Cancel) */ 
   
  int a, mx, my, mox, moy, mb, dum;
  int	sx,sy,sw,sh;
  int obj, oobj, sel, evt; 
  int ox,oy,ow,oh; 
  int klick=0; 

	a=1;
	while(!(poproot[a].ob_flags & LASTOB))
	{
		if(obj_type(poproot, a) != G_STRING) break;
		if(a > (SPTLAST-SPT1+1)) return(scroll_form_popup(poproot, x, y));
		++a;
	}
	
	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);
	
	wind_get(0,WF_WORKXYWH, &sx, &sy, &sw, &sh);
 
  /* Popup-Init */ 
 
 	a=-1;
 	do
  { 
  	++a;
    poproot[a].ob_state&=(~SELECTED); 
  }while(!(poproot[a].ob_flags & LASTOB));
  
  a=1; 
  sel=-1; 
 
  oobj=-1; 
  mox=moy=0; 
   
  /* Popup zeichnen */ 
 
  form_center(&poproot[0], &dum, &dum, &ow, &oh);
  if ((x+ow) > (sx+sw))
  	x=sx+sw-ow;
  if (x < sx)
  	x=sx;
  if ((y+oh) > (sy+sh))
  	y=sy+sh-oh;
  if (y < sy)
  	y=sy;

  poproot[0].ob_x=ox=x;
  poproot[0].ob_y=oy=y;
  form_dial(FMD_START,ox-3,oy-3,ow+3,oh+3,ox-3,oy-3,ow+3,oh+3);
  objc_draw(poproot,0,6,ox-3,oy-3,ow+3,oh+3);

  /* Warten, daž Taste losgelassen wird */
  mb=1;
	evnt_button(1,1,0,&dum,&dum,&dum,&dum);
  
  /* Popup verarbeiten */ 
  while (!klick) 
  { 
    graf_mkstate(&mx, &my, &dum, &dum); 
 
    evt=evnt_multi(MU_BUTTON|MU_M1, 
                1,1,1, 1,mx,my,1,1, 0,0,0,0,0,  
                NULL,0,0, &mx,&my,&mb, &dum, &dum, &dum); 
     
    klick=mb & 1; 
 
  
    if ((evt & MU_BUTTON) || (evt & MU_M1)) 
    { /* Vielleicht Maus-Bewegung */ 
      if ((mx != mox) || (my != moy)) 
      { 
        mox=mx; 
        moy=my; 
        obj=objc_find(poproot,0,6,mx,my); 
        if((poproot[obj].ob_state & DISABLED) | !(poproot[obj].ob_flags & SELECTABLE))
          obj=-1; 
        if (obj != oobj) 
        { 
          if (oobj > -1) 
            objc_change(poproot,oobj,0,ox,oy,ow,oh,poproot[oobj].ob_state&(~SELECTED),1); 
          if (obj > -1) 
            objc_change(poproot,obj,0,ox,oy,ow,oh,poproot[obj].ob_state|SELECTED,1); 
          oobj=sel=obj; 
        } 
      }/* endif mauspos*/ 
    }/* endif evnt Mouse */ 
  }/* end while noklick */ 
  form_dial(FMD_FINISH,ox-3,oy-3,ow+3,oh+3,ox-3,oy-3,ow+3,oh+3);

  evnt_button(1,1,0,&dum,&dum,&dum,&dum); 

 	a=-1;
 	do
  { 
  	++a;
    poproot[a].ob_state&=(~SELECTED); 
  }while(!(poproot[a].ob_flags & LASTOB));

	wind_update(END_UPDATE);
	wind_update(END_MCTRL);
	 
  return(sel); 
} 
