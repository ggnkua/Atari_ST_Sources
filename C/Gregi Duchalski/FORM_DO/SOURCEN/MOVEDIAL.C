/****************************************************************
*  Userdefined Objects in GFA-BASIC 3.x							*
*  (c)8/92 Gregi Duchalski										*
*																*
*  last change 05.08.92                                        	*
*      														   	*
*  MOVEDIAL (Routine von Dirk Koenen)				(Tabweite 4)*
****************************************************************/

/* Diese Routine ist noch provisorisch und schlecht dokumentiert 
   Sie wurde zun„chst in BASIC geschrieben und dann nach C trans-
   formiert. */

#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <stdlib.h>

void bitblt(WORD handle,WORD bp,BYTE *q,WORD qw,WORD qh,BYTE *z,WORD zw,WORD zh,WORD qx,WORD qy,WORD zb,WORD zl,WORD zx,WORD zy);

void cdecl dk_flip_do(BYTE *rsc,BYTE *back,WORD x,WORD y,WORD w,WORD h,WORD ax,WORD ay,WORD handle,WORD max_b,WORD max_h,WORD bp)
{
	WORD ab,ah,rb,rh,gw,gh;
	
	ab=max_b+1;
	ah=max_h+1;
	
	gw=abs(x-ax);             /* Verschiebbreite */
	gh=abs(y-ay);             /* Verschiebh”he   */
	rb=w-gw;                  /* Restbreite      */
	rh=h-gh;                  /* Resth”he        */

	if (rb<0 || rh<0)         /* clip$ aužerhalb von flip$ */
	{
	  /* Hintergrund restaurieren ----- */
	  bitblt(handle,bp,back,w,h,0,ab,ah,0,0,w,h,ax,ay);
	  
	  /* flip$ aktualisieren ----- */
	  bitblt(handle,bp,0,ab,ah,back,w,h,x,y,w,h,0,0);
	}
	else                      /* clip$ und flip$ berschneiden sich */
	{  
	  if (x>ax)               /* nach rechts */
	  {  
	    if (y>ay)             /* nach rechts- unten verschoben */
	    {  
	      /* Hintergrund restaurieren ----- */
	      bitblt(handle,bp,back,w,h,0,ab,ah,0,gh,gw,rh,ax,ay+gh);
	      bitblt(handle,bp,back,w,h,0,ab,ah,0,0,w,gh,ax,ay);
	
	      /* flip$ aktualisieren ----- */
	      bitblt(handle,bp,back,w,h,back,w,h,gw,gh,rb,rh,0,0);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x,y+rh,rb,gh,0,rh);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x+rb,y,gw,h,rb,0);
	    }	
	    else                  /* nach rechts-oben / rechts verschoben */
	    {
	      /* Hintergrund restaurieren ----- */
	      bitblt(handle,bp,back,w,h,0,ab,ah,0,0,gw,rh,ax,ay);
	      bitblt(handle,bp,back,w,h,0,ab,ah,0,rh,w,gh,ax,ay+rh);
	      
	      /* flip$ aktualisieren ----- */
	      bitblt(handle,bp,back,w,h,back,w,h,gw,0,rb,rh,0,gh);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x,y,rb,gh,0,0);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x+rb,y,gw,h,rb,0);
	    }
	  }	
	  else                    /* nach links / oben / unten */
	  {
	    if (y>ay)             /* nach links-unten / unten verschoben */
	    {
	      /* Hintergrund restaurieren ----- */
	      bitblt(handle,bp,back,w,h,0,ab,ah,0,0,rb,gh,ax,ay);
	      bitblt(handle,bp,back,w,h,0,ab,ah,rb,0,gw,h,ax+rb,ay);
	      
	      /* flip$ aktualisieren ----- */
	      bitblt(handle,bp,back,w,h,back,w,h,0,gh,rb,rh,gw,0);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x,y,gw,rh,0,0);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x,y+rh,w,gh,0,rh);
	    }
	    else                  /* nach links-oben / links / oben verschoben */
	    {
	      /* Hintergrund restaurieren ----- */
	      bitblt(handle,bp,back,w,h,0,ab,ah,rb,0,gw,rh,ax+rb,ay);
	      bitblt(handle,bp,back,w,h,0,ab,ah,0,rh,w,gh,ax,ay+rh);
	      
	      /* flip$ aktualisieren ----- */
	      bitblt(handle,bp,back,w,h,back,w,h,0,0,rb,rh,gw,gh);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x,y,w,gh,0,0);
	      bitblt(handle,bp,0,ab,ah,back,w,h,x,y+gh,gw,rh,0,gh);
      }	
	}	
	}	
 
	bitblt(handle,bp,rsc,w,h,0,ab,ah,0,0,w,h,x,y);

}	

void bitblt(WORD handle,WORD bp,BYTE *q,WORD qw,WORD qh,BYTE *z,WORD zw,WORD zh,WORD qx,WORD qy,WORD zb,WORD zl,WORD zx,WORD zy)
{
	MFDB 	b,c;
	WORD  	xy[8];

	if (zb!=0 && zl!=0)
	{
  
	xy[0]=qx;
	xy[1]=qy;
	xy[2]=qx+zb-1;
	xy[3]=qy+zl-1;
	xy[4]=zx;
	xy[5]=zy;
	xy[6]=zx+zb-1;
	xy[7]=zy+zl-1;
	
	b.mp=z;
	b.fwp=zw;                         /* Breite des Blocks in Pixeln     */
	b.fh=zh;                          /* H”he des Blocks in Pixeln       */
	b.fww=(zw+15)/16;
	b.ff=1;
	b.np=bp;
	
	c.mp=q;
	c.fwp=qw;                         /* Breite des Blocks in Pixeln     */
	c.fh=qh;                          /* H”he des Blocks in Pixeln       */
	c.fww=(qw+15)/16;
	c.ff=1;
	c.np=bp;

	vro_cpyfm(handle,3,xy,&c,&b);
	}	
}
