/*
  BUILDER!!!!!!!!

    . This program will allow the user to interactively create
      any scene with a few template primitives. 
    . Once a scene in created, the program will generate C
      code for it.
    . Hopefully this will take away the boredom of creating 
      scenes via typing in Bl,FL,FF etc for EVERY room and 
      for EVERY direction of the compass.


                 Jeff Bilger, Monday 1:20 am 1-2?-94


   THE LOGIC
   ---------

o Each pic then has 7 fields, and each field can have one of 9
  templates. If a field is 0 then it does not use any template.

  struct field_data
   {
    int Field1,
        Field2,
        Field3,
        Field4,
        Field5,
        Field6,
        Field7;
   };

  struct pic
   {
    struct field_data N,S,E,W;    for each direction it has 7 fields
                                    that'll define the view
   };
 
 o The map is made up of a 2d array of struct pic
   
    struct pic map[y][x];


 o To build the map.
   
   1. Create your 2d map array by assigning the fields.
       map[x][y].NSEorW.Field1
       ......... ...... ......
       map[x][y].NSEorW.Field7
   
 o To create a picture.for room at  map[0][0] FACING North
   
   1. vrocopy the main template, which is a sky and ground, to the screen.
   2. look at map[0][0].N.Field1 if !0 it tells which template to get.
      vrocopy this to the correct xy loc on the screen.
   3. Do # 2 for Fields 2-6.
  

*/

      /* uses ONLY fncts from there 'h' files*/
#include <gemdefs.h>       /* that it needs. Smart compiler */
#include <osbind.h>
#include <stdio.h>
#include <strings.h>
#include <linea.h>
#define pos_rnd(t) Random()%(t)   /*returns a number from 0 to (t-1) */

int pts[4][2] = { 
	320, 050,
	120, 150,
	520, 150,
	320, 050
};
lineaport *theport;              /* a line identifier */
 
char *screen;    
                     
/* define our templates */
#define CL  1
#define CR  2
#define CF1 3
#define CF2 4
#define ML  5
#define MR  6
#define MF  7
#define FL  8
#define FL_SPECIAL  9       /*  FL with a FF wall */
#define FR  10
#define FR_SPECIAL 11       /*  Fr w/ A FF wall */
#define FF  12
#define EMPTY 0

/* and our regions */
#define R1  100
#define R2  101
#define R3  102
#define R4  103
#define R5  104
#define R6  105
#define R7  106

#define EXIT 200
#define NEXT 201
#define OK   202

int template_chosen,
    region_chosen,
    choice_chosen,
    room,count ; 
char string[80];
unsigned form[37];

char pix1[] = "builder.pc1";
char dir;
int handle;
int filehandle,i;
int newpal[16],savepal[16];
char	 temp_[32000],		             /* Temp buffer where file is read in	*/
         *hld,
		 *iff_in, *iff_out;	              /* Pointers for DEGAS unpack() routine	*/
int contrl[12];
int intin[256],  ptsin[256];
int intout[256], ptsout[256];
int rect1[] ={1,102,119,1};

FILE *ofp;   /* out file ptr */

main()

{
    MFDB    theMFDB;    /*  Screen definition structure  */
    MFDB    tempMFDB;
    int status,Field;
    char *scr1;
    int pxyarray[8];      /* for vrocopyfm */
    long hold_addr;
   int x,y,template;
   int ch,cw,dummy;
   char com;
   int count=0;   

  /* start up params */
  printf("Start at which room #:");
  scanf("%d",&room);
       


   theport = a_init();            /* invoke a line driver */

   x =0; y=0;
   dir = 'N';
    tempMFDB.fd_w    = theMFDB.fd_w ; /* 320 pixels wide*/
    tempMFDB.fd_h       = theMFDB.fd_h ; /*200 pixels high */
    tempMFDB.fd_wdwidth = theMFDB.fd_wdwidth ; /*16 words wide*/
    tempMFDB.fd_stand = theMFDB.fd_stand ; /* raster coords.*/
    tempMFDB.fd_nplanes = theMFDB.fd_nplanes; /*low rez has 4 planes */
    
 
	appl_init();
	handle = open_workstation(&theMFDB);  /*set up screen MFDB */

  
   ofp = fopen("roomrec.dat","a");
     

   vst_height(handle, 4, &dummy, &dummy, &cw, &ch);
 
   scr1 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr1 & 0xff)
      scr1 = scr1 + (0x100 - (long)scr1 & 0xff);
      
read_stuff(pix1,scr1,1); /*templates*/        /* read back screen into memory */
 

/* find screen base */
screen = (char *)Physbase(); 
Setscreen(scr1,scr1,-1);

theMFDB.fd_addr = (long) scr1;    /* set destination to be BACK screen*/
tempMFDB.fd_addr = (long) scr1;
Setpalette(newpal);        /* tel sys to use these colors! */


graf_mouse(3,form);


template_chosen = 0;
region_chosen = 0;
choice_chosen = 0;
count = 0;  /* when count = 7, then we have created a full picture */

 while( Field != EXIT )
{
   count++;  /* when count == 7  reset to 0,
                                 increment direction,
                                    if dir = W set dir = N and room++
             */

  
   sprintf(string,"%c",dir);  /* convert char to string! */
   v_gtext(handle,268,169,string);   /* show the direction */
   sprintf(string,"%d",room);  
   v_gtext(handle,268,160,string); /* show the room you're in */
   v_gtext(handle,1,160,"Select a template and");
   v_gtext(handle,1,167,"press left button.");
  do                   /* do until you pick a template */
   {
    vq_mouse(handle,&status,&x,&y);
      if(status & 0x1) Field=pick_template(x,y);       /* if left button pressed */
   }while(!template_chosen);                     /* choose template */
    
template = Field;  /* save template type */
template_chosen = 0;     /* reset this to 0 */
print_template_chosen(Field,pxyarray); /* print which template was picked
                                          and set pxyarrat for source     */

   v_gtext(handle,1,160,"Select a REGION and  ");
   v_gtext(handle,1,167,"press left button.");
                  /* now lets pic a destination region */
  do 
   {
    vq_mouse(handle,&status,&x,&y);
      if(status & 0x1) Field=pick_region(x,y); /* if left button pressed */
   }while(!region_chosen);                     /* choose region */

  region_chosen = 0;     /* reset this to 0 */
 print_region_chosen(Field,pxyarray,template); /* print which template was picked
                                          and set pxyarrat for source     */

a_hidemouse();
 copytemplates(&theMFDB,pxyarray);  /* copy the thing! */
a_showmouse();
  
                                    /* Given Field = region and
                                       template = template chosen
                                       dir = direction
                                       room = room #
                                       CREATE a 'roomrec' entry */
 create_roomrec(Field,template,dir,room);

/*
  v_gtext(handle,1,160,"Press OK or NEXT     ");
  v_gtext(handle,1,167,"press left button."); 
*/

           /* check for either ok,Next or done 
 do 
   {
    vq_mouse(handle,&status,&x,&y);
      if(status & 0x1) Field=pick_choice(x,y);  
   }while(!choice_chosen);                    
  choice_chosen = 0;     
 process_choice(Field);  
*/


/*
 v_gtext(handle,1,160,"                     ");
 v_gtext(handle,1,167,"                     ");
*/
if( Bconstat(2) ) Field = EXIT;  /* press a key...we quit! */

v_gtext(handle,268,178,"    ");
v_gtext(handle,268,187,"  ");

   if(count == 7)
       {
         vsf_color(handle,0);
         vr_recfl(handle,rect1); 				/* clear out regions*/
        count = 0;
        switch(dir)
         {
           case 'N': dir = 'S'; break;
           case 'S': dir = 'E'; break;
           case 'E': dir = 'W'; break;
           case 'W': dir = 'N'; room++; break;
         }
       }


  }

	v_clsvwk(handle);
	appl_exit();

}                      /* end of program */



/***************************************************************/






/***********************************************/
/* creates an entry in the roomrec[room].dir.Field */

create_roomrec(Field,template,dir,room)
int Field,template,room;
char dir;
{


 if( Field == R1)
  {
    fprintf(ofp,"/********************************************/\n");
    sprintf(string,"roomrec[%d].%c.Field1=%d\n",room,dir,template);
    fprintf(ofp,string);
  }
 if( Field == R2)
  {
    sprintf(string,"roomrec[%d].%c.Field2=%d\n",room,dir,template);
    fprintf(ofp,string);
  }
 if( Field == R3)
  {
    sprintf(string,"roomrec[%d].%c.Field3=%d\n",room,dir,template);
    fprintf(ofp,string);

  }
 if( Field == R4)
  {
    sprintf(string,"roomrec[%d].%c.Field4=%d\n",room,dir,template);
    fprintf(ofp,string);

  }
if( Field == R5)
  {
    sprintf(string,"roomrec[%d].%c.Field5=%d\n",room,dir,template);
    fprintf(ofp,string);

  }
if( Field == R6)
  {
    sprintf(string,"roomrec[%d].%c.Field6=%d\n",room,dir,template);
    fprintf(ofp,string);
  }
if( Field == R7)
  {
    sprintf(string,"roomrec[%d].%c.Field7=%d\n",room,dir,template);
    fprintf(ofp,string);
    fprintf(ofp,"/********************************************/\n\n");
  }



}
/***********************************************/
process_choice(field)
int field;
{
  if (field == EXIT) { }
  if (field == NEXT) { vsf_color(handle,0);
                       vr_recfl(handle,rect1); /* clear out regions*/
                       if(dir == 'N') {dir = 'S'; return ; }
                       if(dir == 'S') {dir = 'E';return ; }
                       if(dir == 'E') {dir = 'W';return ; }
                       if(dir == 'W') {dir = 'N'; room++; return ; }
                     }

  if (field == OK)   { }
                       
}
/*************************************************/
copytemplates(mf,pxyarray)  /* copy the thing! */
MFDB *mf;
int pxyarray[];
{

vro_cpyfm(handle,3,pxyarray,mf,mf);  /* copy it */

}
/***********************************/
/*
   Choose which choice chosen, 
   this will  set 
   choice_chosen = 1 if a valid choice was picked
*/
int pick_choice( x,y )
int x,y;

{

  choice_chosen = 1;          /* set it valid */

  if(y >119  && y<142 )        /* in Y range of choices */ 
   {
    if( x > 173 && x < 222 ) return EXIT;
    if( x > 230 && x < 272 ) return NEXT;
    if( x > 279 && x < 319 ) return OK;
   }

          /* if we get here, a valid choice was NOT found
              so set CHOICE_chosen = 0 */
  choice_chosen = 0;
  return(0);  
  
}
/***********************************/
/*
   Choose which template chosen, 
   this will print WHICH template was chosen and set 
   template_chosen = 1 if a valid template was picked
*/
int pick_template( x,y )
int x,y;

{

  template_chosen = 1;          /* set it valid */

  if(y > 0 && y<103 )        /* in Y range of templates */ 
   {
    if( x > 146 && x < 163 ) return FF;
    if( x > 163 && x < 180 ) return CL;
    if( x > 180 && x < 197 ) return ML;
    if( x > 204 && x < 212 ) return FL_SPECIAL;
    if( x > 212 && x < 220 ) return FR_SPECIAL;
    if( x > 197 && x < 213 ) return FL;
    if( x > 213 && x < 230 ) return FR;
    
    if( x > 231 && x < 247 ) return MR;
    if( x > 247 && x < 264 ) return CR;
    if( x > 264 && x < 281 ) return CF1;
    if( x > 281 && x < 298 ) return CF2;
    if( x > 298 && x < 315 ) return MF;
    if( x > 124 && x < 142 ) return EMPTY;
    
   }

          /* if we get here, a valid choice was NOT found
              so set template_chosen = 0 */
  template_chosen = 0;
  return(0);  
  
}
/********************************************************/
/* print which template was chosen and set the pxyarray
   for the source */

print_template_chosen(Field,pxyarray)
int Field,
    pxyarray[];

{

 switch(Field)
    {
     case CL: pxyarray[0] = 163; pxyarray[1] = 1; pxyarray[2] = 179; pxyarray[3] = 102; v_gtext(handle,268,178,"CL"); break;
     case ML: pxyarray[0] = 180; pxyarray[1] = 1; pxyarray[2] = 196; pxyarray[3] =102; v_gtext(handle,268,178,"ML"); break;
     case FL: pxyarray[0] = 197; pxyarray[1] = 1; pxyarray[2] = 205; pxyarray[3] =102; v_gtext(handle,268,178,"FL"); break;
     case FL_SPECIAL: pxyarray[0] = 197; pxyarray[1] = 1; pxyarray[2] = 213; pxyarray[3] =102; v_gtext(handle,268,178,"FL Sp"); break;
     case CF1: pxyarray[0] = 265; pxyarray[1] = 1; pxyarray[2] = 281; pxyarray[3] =102; v_gtext(handle,268,178,"CF1"); break;
     case CF2: pxyarray[0] = 282; pxyarray[1] = 1; pxyarray[2] = 298; pxyarray[3] =102; v_gtext(handle,268,178,"CF2"); break;
     case MF: pxyarray[0] = 299; pxyarray[1] = 1; pxyarray[2] = 315; pxyarray[3] =102; v_gtext(handle,268,178,"MF"); break;
     case FF: pxyarray[0] = 146; pxyarray[1] = 1; pxyarray[2] = 162; pxyarray[3] = 102; v_gtext(handle,268,178,"FF"); break;
     case CR: pxyarray[0] = 248; pxyarray[1] = 1; pxyarray[2] = 264; pxyarray[3] = 102; v_gtext(handle,268,178,"CR"); break;
     case MR: pxyarray[0] = 231; pxyarray[1] = 1; pxyarray[2] = 247; pxyarray[3] = 102; v_gtext(handle,268,178,"MR"); break;
     case FR: pxyarray[0] = 222; pxyarray[1] = 1; pxyarray[2] = 230; pxyarray[3] = 102; v_gtext(handle,268,178,"FR"); break;
     case FR_SPECIAL: pxyarray[0] = 214; pxyarray[1] = 1; pxyarray[2] = 230; pxyarray[3] = 102; v_gtext(handle,268,178,"FR Sp"); break;
     case EMPTY: pxyarray[0] = 125; pxyarray[1] = 2; pxyarray[2] = 141; pxyarray[3] = 103; v_gtext(handle,268,178,"EMPTY"); break;
break;

    }


}
/********************************************************/
/***********************************/
/*
   Choose which region chosen, 
   sets  
   region_chosen = 1 if a valid region was picked
*/
int pick_region( x,y )
int x,y;

{

  region_chosen = 1;          /* set it valid */

  if(y > 0 && y<103 )        /* in Y range of regions */ 
   {
    if( x > 0 && x < 18 ) return R1;
    if( x > 17 && x < 35 ) return R2;
    if( x > 34 && x < 52 ) return R3;
    if( x > 51 && x < 69 ) return R4;
    if( x > 68 && x < 86 ) return R5;
    if( x > 87 && x < 103 ) return R6;
    if( x > 102 && x < 120 ) return R7;
    }

          /* if we get here, a valid choice was NOT found
              so set REGION_chosen = 0 */
  region_chosen = 0;
  return(0);  
  
}
/********************************************************/
/* print which region was chosen and set the pxyarray
   for the dest */

print_region_chosen(Field,pxyarray,template)
int Field,
    pxyarray[],
    template;

{

 switch(Field)
    {
     case R1: pxyarray[4] = 1; pxyarray[5]   = 1; pxyarray[6] = 17; pxyarray[7] = 102; v_gtext(handle,268,187,"R1"); break;
     case R2: pxyarray[4] = 18; pxyarray[5]  = 1; pxyarray[6] = 34; pxyarray[7] =102; v_gtext(handle,268,187,"R2"); break;
     case R3: pxyarray[4] = 35; pxyarray[5]  = 1; pxyarray[6] = 51; pxyarray[7] =102; v_gtext(handle,268,187,"R3"); break;
     case R4: pxyarray[4] = 52; pxyarray[5]  = 1; pxyarray[6] = 68; pxyarray[7] =102; v_gtext(handle,268,187,"R4"); break;
     case R5: pxyarray[4] = 69; pxyarray[5]  = 1; pxyarray[6] = 85; pxyarray[7] =102; v_gtext(handle,268,187,"R5"); break;
     case R6: pxyarray[4] = 86; pxyarray[5]  = 1; pxyarray[6] = 102; pxyarray[7] =102; v_gtext(handle,268,187,"R6"); break;
     case R7: pxyarray[4] = 103; pxyarray[5] = 1; pxyarray[6] = 119; pxyarray[7] =102; v_gtext(handle,268,187,"R7"); break;
    }

  /* for display purposes only */
if(template == FL) {
            pxyarray[4] = 35; pxyarray[5]  = 1; pxyarray[6] = 43; pxyarray[7] =102;
                   }
if(template == FR) {
            pxyarray[4] = 77; pxyarray[5]  = 1; pxyarray[6] = 85; pxyarray[7] =102;  
                   }


}
/********************************************************/



/*********************************************************/
/* load degas compressed pics */

/************************/
read_stuff(hold,adrr,which)
char hold[];
register char *adrr;
int which;  
/* if which = 1 then store palette into newpal*/
/* which is the main pal of the game. If = neg then store */
/* into pal 4. the alternate pals of the game */

{
 char buf[130];
 int lines,m;
 static int only_once = 1;
 
filehandle = Fopen(hold,0); 

if( only_once )        /* save the palette ONCE!!! */
{
for(i=0; i<16;i++)
 savepal[i]=Setcolor(i,-1);
only_once = 0;
}

/* read header data */
i=Fread(filehandle,2L,buf);


/* read 16 words of palette data into newpal array */

i =Fread(filehandle,32L,newpal);
 

 

i=Fread(filehandle,32000L,temp_);  /* read image onto back screen*/
/* Close file */
Fclose(filehandle);
	 lines = 200;		             /* Low, med-res	*/
				 iff_in  = temp_;                /* iff_in pts to temp_buf*/
			     iff_out = adrr;      /* iff_out pts to pic_buffer*/
			      do		
         unpack(0);			                          /* Unpack a line at a time */
			      while (--lines); 


 /*v_gtext(handle,1,5,"             ");*/
       
}
/************************/

/***********************/

/*---------------------------------------------------------------------------*/
/*					         |--------- DEGAS ---------|			*/
/*					          UNCOMPRESSED   COMPRESSED			*/
/*			     NEO  low med mono   low med mono	 TINY	*/
/*	typ...		0     1   2   3     4   5   6     7		*/

/* Unpacks a single scan line & updates iff_in & iff_out global pointers

                     /	byt ==  0 to  127  copy next [byt+1] bytes
Unpack routine --if-<	byt == -1 to -127  copy next byte [-byt+1] times
                     \	byt == 128         NO-OP							*/

unpack(rez)
int	 rez;

{
	register char	 *src_ptr, *dst_ptr,           /* ptrs to source/dest */
              byt, cnt;                     /* byt holds the ACTUAL compressed data code(control byte ) */
	register int	  minus128 = -128, 
              len;                          
	char			     linbuf[320];		                    /* Oversize just in case! */
	int				      llen;


	if (rez < 2)	 len = 160;
	else			 len = 80;
	llen = len;
	src_ptr = iff_in;           /* iff_in is ptr to compressed data */
	dst_ptr = &linbuf[0];       /* linbuf WILL hold an ENTIRE Uncompressed scan line. 4 bitplanes * 80 = 320 max! */ 

	while (len > 0)
   {
		    byt = *src_ptr++;       /* get byte value at address scr_ptr, THEN inc scr_ptr+1 */
		    if (byt >= 0)           /* If ctrl code >= 0 then use the next x+1 bytes*/
    {
			     ++byt;                 /* inc byt +1 */
			      do 
       {
				        *dst_ptr++ = *src_ptr++;  /* get byte value from address source, and inc the 2 ptrs */
				        --len;                    /* one byte down.. */
			       }
         while (--byt);           /* do this byt TIMES (remember byt here = byt+1 */
		     }
		     else 
       if (byt != minus128)       /* else if ctrl code NOT = -128*/
         {                        /*Then use the next byte -x+1 times, (-x) cause x will be negative and - - = + */
			          cnt = -byt + 1;         /* cnt = -x + 1 */
			          byt = *src_ptr++;       /* byt = THE very next byte past the ctrl code(or ctrl byte! */
			           do {
				               *dst_ptr++ = byt;  /* store that byte */
				               --len;         
			              }
               while (--cnt);    /* keep doing it cnt times */
		          }
	    }

	ilbm_st(linbuf, iff_out, rez);   /* convert the format line */
	iff_in = src_ptr;					                /* Update global pointers */
	iff_out += llen;

}                                /* end of module uncompress() */

/*---------------------------------------------------------------------------*/

ilbm_st(src_ptr, dst_ptr, rez)		   /* Convert ILBM format line to ST format */
int		 *src_ptr, *dst_ptr, rez;
{
	int		 x, *p0_ptr, *p1_ptr, *p2_ptr, *p3_ptr;

	if (rez==0) 
 {				                                     /* Low-res */
  
		p0_ptr = src_ptr;
		p1_ptr = src_ptr + 20;
		p2_ptr = src_ptr + 40;
		p3_ptr = src_ptr + 60;
		for (x=0; x<20; ++x)
  {
			   *dst_ptr++ = *p0_ptr++;
			   *dst_ptr++ = *p1_ptr++;
			   *dst_ptr++ = *p2_ptr++;
			   *dst_ptr++ = *p3_ptr++;
		  }
	} 
 else if (rez==1) 
  {		                                    /* Med-res */
		   p0_ptr = src_ptr;
		   p1_ptr = src_ptr + 40;
		   for (x=0; x<40; ++x)
    {
			     *dst_ptr++ = *p0_ptr++;
			     *dst_ptr++ = *p1_ptr++;
		    }
	}
    else 
     {					                               /* Monochrome */
		      for (x=0; x<40; ++x)
			      *dst_ptr++ = *src_ptr++;
	     }
 
 }
/*---------------------------------------------------------------------------*/



