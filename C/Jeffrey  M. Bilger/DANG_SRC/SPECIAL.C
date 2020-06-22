#include <globals2.h>

char hammr[] = "2 hammr";
char gate_[] = "2 gate0";

/* this module will check for special events, eg
   if you are at room 164 and user.user_items[14] is true
   Eg you have the key to get into the gate! 
   will also set :

                  map[13][1].e = 164    was = 0 now = room 164
                                        so you can walk past gate.
                  map[13][2].w = 163    was = 0, .....


Also checks to see if you are in front of a smithy and plays 
the hammer sample..

*/
          

special_events(mfs,mfd,pxyarray,scr3)
register MFDB *mfs,*mfd;   /* the src and dest MFDBs!! */
char *scr3;  /* addr of gate.dat */
int pxyarray[8];

{
 int f;
 static int been_in_here = 0;   
 static int hammer = 0;

 if( ((cell == 164 && dir == 'W') || (cell == 163 && dir =='E')) 
     && (user.user_items[14] == 1 && been_in_here == 0)) 
      /* if in room 164 and facing west, or room 163 and facing east
         AND you have the KEY to get in!!...and you have never 
         seen the gate openn.. */
   {

      been_in_here = 1;  /* say you've been in here, so once
                            if opens, you'll never see it open again */

      mfs->fd_addr = (long) scr3; /* copy address */
   
      pxyarray[0] = 70;  /* the movement of the gate will be*/
      pxyarray[1] = 3;  /* top left,top right.bl,br */
      pxyarray[2] = 192;
      pxyarray[3] = 91; 
 Vsync();
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
       invoke_tsr( gate_ );      /*play */
 
    
   

      pxyarray[0] = 194;  /* the movement of the gate will be*/
      pxyarray[1] = 3;  /* top left,top right.bl,br */
      pxyarray[2] = 316;
      pxyarray[3] = 91; 
Vsync();       
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
        invoke_tsr( gate_ );      /*play */
 
    

      pxyarray[0] = 70;  /* the movement of the gate will be*/
      pxyarray[1] = 93;  /* top left,top right.bl,br */
      pxyarray[2] = 192;
      pxyarray[3] = 181;
       Vsync();
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */    
        invoke_tsr( gate_ );      /*play */
 
       

      pxyarray[0] = 194;  /* the movement of the gate will be*/
      pxyarray[1] = 93;  /* top left,top right.bl,br */
      pxyarray[2] = 316;
      pxyarray[3] = 181; 
       Vsync();
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */   
        invoke_tsr( gate_ );      /*play */
 
      


map[13][1].e = 164;   /*update map array to say you can now pass
                        through gate */
                                        
map[13][2].w = 163;



   }  /* end of GATE if */





 if(cell == 47 || cell == 227 || cell == 221 || cell == 46 ||
      cell == 228 || cell == 234)
{
 if(hammer == 0)
 invoke_tsr( hammr );      /*play */
        if(CURRENT_SOUND == 1) Dosound( wind_sound );
        if(CURRENT_SOUND == 4) Dosound( rain_sound );

  hammer++; if(hammer == 12) hammer = 0;   /* every 4th time you're 
                                             near a smithy, you'll
                                             hear this */
} 






}


/*****/
short_wait()
{
 int oo,ppq;

  for(oo=9;oo<500;oo++)
   for(ppq=0;ppq<190;ppq++)
    ;
}

/*********************************/
/** This will load up an inside estab pic.
    o typeofpic. if 1 use reg inside pic, else use smithy pic
  
    o It will load up pic 'estab.dat' which is pic28
    o It will change and SAVE cells 10,11 & 14 of newpal[]
      and return them in the vars   COL1,COL2,COL3
**/


load_up_inside_pics(mf_src,mf_dest,pxyarray,scr2,typeofpic)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr2;
int pxyarray[8],typeofpic;
/* typeof pic. if 1 use regular inside pic.
               if 2 use guild pic.   Bottom left template
               if 0 use smithy pic */

{
 int f;
           mf_src->fd_addr = (long) scr2; /* copy address */
   
           
       /* change these colors.. */
      Setcolor(10,0x430); Setcolor(11,0x432); Setcolor(14,0x320);
   if( typeofpic==1)
     {
      pxyarray[0] = 70;       /* coords for reg estab inside */
      pxyarray[1] = 3;  
      pxyarray[2] = 192;
      pxyarray[3] = 91; 
     }
    if(typeofpic == 2)
    {
      pxyarray[0] = 70;       /* coords for guild */
      pxyarray[1] = 93;  
      pxyarray[2] = 192;
      pxyarray[3] = 181;
    }
    if(typeofpic == 0) 
      {
      pxyarray[0] = 194;    /* coords for smithy... */
      pxyarray[1] = 93;  
      pxyarray[2] = 316;
      pxyarray[3] = 181; 
      }
 Vsync();
       vro_cpyfm(handle,3,pxyarray,mf_src,mf_dest);
      
   }  /* end ofmodule load up estab.pic! */


/****/
