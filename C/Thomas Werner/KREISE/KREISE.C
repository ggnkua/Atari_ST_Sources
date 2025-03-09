/*----------------------------------------------------------------*/
/*		 Inkrementaler Kreisgenerator (nach Horns Algorithmus)			*/
/*			             		  								   					            */
/* Originalroutine in GFA-BASIC von Andreas Hollmann 							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <aes.h>
#include <vdi.h>


extern	int	handle;


/*--------------------------------------*/
/* Parameter:														*/
/* x0,y0: Kreismittelpunkt-Koordinaten	*/
/* r:     Kreisradius										*/
/* type:  Linienmuster (16 Bits)				*/
/*--------------------------------------*/

void circle(int x0, int y0, int r, int type)
{
	int		octant, x, y, test;
	
	void	Plot(int x, int y);
	
	
	graf_mouse(M_OFF,0);
  x = r;
  y = 0;
  test = 1;
  
  for (octant = 1; octant <= 8; octant++)
  {
    switch(octant)
    {
	    case 1:										/* Oktant 1,3,5,7 */	
	    case 3:
	    case 5:
	    case 7:
	    
	      r -= (x<<1);
	      while (y<=x)
	      {
	        if (type & test)  	  /* Muster-Bit gesetzt? */
	          switch(octant)      /* dann Punkt setzen */
	          {
		          case 1:
	  	        	Plot(x0+x,y0+y);
	    	      break;
	      	    
	        	  case 3:
	          	  Plot(x0-y,y0+x);
		          break;
	  	        
	    	      case 5:
	      	      Plot(x0-x,y0-y);
	        	  break;
	          	
		          case 7:
	  	          Plot(x0+y,y0-x);
	    	      break;
	          }
	        test <<= 1;
	        if (test == 0)
	        	test = 1;
	        r += ((y<<1) + 1);
	        y++;
	        if (r>=0)
	        {
	          r -= ((x<<1) - 2);
	          x--;
	        }
	      }
	    break;
	    
	    case 2:									/* Oktant 2,4,6,8 */
	    case 4:
	    case 6:
	    case 8:
	      r += (x<<1);
	      while (y>=0)
	      {
	        r -= ((y<<1) - 1);
	        y--;
	        
	        if (r<0)
	        {
	          r += ((x<<1) + 2);
	          x++;
	        }
	        
	        if (x != y)						  /* Diagonalen-Linien vermeiden */
	        {
	          if (type & test)      /* Muster-Bit gesetzt? */
	          {
		          switch(octant)      /* dann Punkt setzen */
		          {
			          case 2:
		  	        	Plot(x0+y,y0+x);
		    	      break;
		      	    
		        	  case 4:
		          	  Plot(x0-x,y0+y);
			          break;
		  	        
		    	      case 6:
		      	      Plot(x0-y,y0-x);
		        	  break;
		          	
			          case 8:
		  	          Plot(x0+x,y0-y);
		    	      break;
		          }
		        }
		        test <<= 1;
		        if (test == 0)
	  	      	test = 1;
	      	}
	      }
	      test <<= 1;
	      if (test == 0)
	       	test = 1;
	    break;
	  }
  }
	graf_mouse(M_ON,0);
}



void	Plot(int x, int y)
{
	int		xy[4];
	
	xy[0] = x;
	xy[1] = y;
	xy[2] = x;
	xy[3] = y;
	
	v_pline(handle,2,xy);
}
