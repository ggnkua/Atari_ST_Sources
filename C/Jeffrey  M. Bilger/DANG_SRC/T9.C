char hitwall[] = "2 hitwa";  /* hit wall sound */

#define CH_A_TONE_L     0x00,   /* TONE PERIOD REGS. determines pitch*/  
#define CH_A_TONE_H     0x01,   /* period = 125,000 / freq (Hz) */
#define CH_B_TONE_L     0x02,   /* see page 76 Atari ST TOS */
#define CH_B_TONE_H     0x03,
#define CH_C_TONE_L     0x04,
#define CH_C_TONE_H     0x05,
#define NOISE_PERIOD    0x06,    /* LOW = Thin,static like HIGH = fast rushing (windlike) */
#define ENAB_TONE_NOISE 0x07,    
#define CH_A_VOL_AMP    0x08,
#define CH_B_VOL_AMP    0x09,
#define CH_C_VOL_AMP    0x0a,
#define ENV_PERIOD_L    0x0b,    /* Higher period = more slowly VOL changes and TONES are bell like*/
#define ENV_PERIOD_H    0x0c,    /* lower period  = VOL changes fast and TONES are very raspy! */
#define WAVEFORM        0x0d,    
#define PLACE           0x80,    /* For Ending, or loops */
#define INTO            0x81,
#define INCREMENT_BY
#define UNTIL

/* GLOBAL SOUNDS FOR DOSOUND() */

static unsigned char wind_sound[]={
CH_A_VOL_AMP     0x0b,
CH_B_VOL_AMP     0x11,
CH_C_VOL_AMP     0x03,
CH_A_TONE_H      0x01,
CH_A_TONE_L      0xff,
CH_B_TONE_H      0xff,
CH_B_TONE_L      0xff,
NOISE_PERIOD     0xff,
ENAB_TONE_NOISE  0x03,
ENV_PERIOD_L     0x22,
ENV_PERIOD_H     0xff,
WAVEFORM         0x0e,                         
PLACE 0x02,INTO 0x12, INCREMENT_BY 0x02, UNTIL 0x25};

static unsigned char quiet[] = {
CH_A_VOL_AMP     0x00,
CH_B_VOL_AMP     0x00,
CH_C_VOL_AMP     0x00,
CH_A_TONE_H      0x00,
CH_A_TONE_L      0x00,
CH_B_TONE_H      0x00,
CH_B_TONE_L      0x00,
NOISE_PERIOD     0x00,
ENAB_TONE_NOISE  0x00,
ENV_PERIOD_L     0xff,
ENV_PERIOD_H     0xff,
WAVEFORM         0x00,  
0xff,0x00};
	

static unsigned char rain_sound[]={
CH_A_VOL_AMP     0xff,
CH_B_VOL_AMP     0xff,
CH_C_VOL_AMP     0x03,
CH_A_TONE_H      0xff,
CH_A_TONE_L      0x00,
CH_B_TONE_H      0xff,
CH_B_TONE_L      0x00,
CH_C_TONE_H      0x09,
CH_C_TONE_L      0x00,
NOISE_PERIOD     0xff,
ENAB_TONE_NOISE  0x63,
ENV_PERIOD_L     0x22,
ENV_PERIOD_H     0x11,
WAVEFORM         0x0d,                         
PLACE 0x02,INTO 0x12, INCREMENT_BY 0x02, UNTIL 0x24};


#define WEAPON -5
#define ARMORY -6
#define GUILD -4
#define SUPPLY -10
#define TOWER -8
#define TAVERN -3
#define ARENA -11
#define DUNGEON -13
#define PALACE -7
#define TEMPLE -1
#define INN -2
#define GATE -9
#define BANK -12
#define DOOR -99
#define WALL 0
/*
 Wednesday June 17,1992
 
 FINALLY !!!!!!!!!!!!!!!!
 
 At 3:09 pm listening to Concrete Blonde
 I got it to work!

o  This program will load up 3 grafic screens.
   One title, and 2 back screens. It sets the tempMFDB addr to the 
   1st back screen and copies the top left rectangle to the title screen
   then it sets the tempMFDB to the 2nd back screen and copies the
   top left rectangle to the title! AWESOME..

o  It now loads up 5 back screens and works

o June 19 1991 12:23 am
   It includes the screen fetching set up. One problem, in the 
   set_up module. If I declare any more data past [2] then It will
   NOT fetch the pix properly. VERY WEIRD!. Once I had it up to [3]
   and it worked, i tried to goto [4] it didnt work, so i went back
   to [3] and it STILL DIDNT WORK!! S T R A N G E!

o June 22. 12:52 pm. Fixed the above problem. The fucked up thing was
  that in the room_rec[] declaration I allocated only 3 cells (eg:
  room_rec[3]) and I was assigning to room_rec[4 thru 8] Which 
  DIDNT EXIST! The compiler didnt catch the out of bounds error 
  and It was totally screwing up the program in subtle ways.

  - Everything works, the lookup routines are up and running
    
  - 4:53 pm. Incorporated a mini city. All code is in place, and 
    all bugs are fixed(I hope) the city is officially up and running
    . You can walk around, etc. Too fucking cool. and 6 yrs in the
     making...

o Implementing all modules, fight routines etc.

o July 1, Wednesday. Fight routines updated, only problem is I
  need to check the logic in the fight, and Fix the cast() ROUTINE.
  You now can ancounter 50 diff types of monsters/people

o Degas Elite with Uncompression added. Reduces much WASTED space
  needed for 32k NEO pics

o Added new pixs, Temple etc. Will use its own pallette. Also implemneted
  establishments. I.e walk into a temple now, or go into a shoppe

o 25 Aug. 1992 :College Station. Fixed the main palette because of multiple
  same -colors, Also fixed 2nd pal. to work with first. Updated all 
  DAT files. hint, use Degas Elites Remap fnct when changing colors
  in the palettes much faster than doing it manually. Also updated 
  main screen with 2 pillars with vines.

o 13 Feb.1993 Adding new city co-ords, for main city...most of the new
  templates have been made.
  All templates have been made. Tried to modify prg to work with 
  19 of them .Took up too much memeory, so I'm down to 9 right now. 
  The read map from a file module isnt working, checking on it.

o 4 March Could not fit all pics in memory at one time so i decided
    to use Virtual memory, and swap screens in and out of memory as needed
  Virtual memory implemented. 5 working background screens for city
  template pics. File T3.C IS WORKING..  

o 5 March- The top 1/2 of the city works flawlessly!
           Now creating bottom half.(adding to ROOM.DAT file)  

o 9 March- City is finally coded. Room.dat is completed. ALL city 
           template pics are made (22 pics in all = 22*4 = 88 pics)
           Checking the city to see if all is in order.
o 8 April- Put SND player in as TSR. Fixed array error on monsters[]
           i had 0-50 records but only allocated monsters[50] or 0-49
           thats a no no!
         - Street names are implemented, threw out idea to make it 
           1/2 meg, too many restrictions, also increased physical 
           screens to 10 templates.
o 15 April- Hard drive crashed, new one just came in. 
            - Real time is implemented
            - 
o 25 May  - Schools over, just got back from Stockholm,Sweden.
            - Fixed minor things, made enhancements
            - Added a 'pause' function, 'Help' function
o 29 May  - -Added digitized sounds, gen_estab fixed and up and running
             Weapons Shoppe works.
o 30 May  - -Grabbed fantasy .gifs from the Internet and converted
             them over to degas, very cool. 
            -Can enter houses
            -Everything is working, just some touch ups and 
             minor adjustments.
o 10 June - Fixed: too many 'encounters problem,cast exit problem and 
                   cast problem,Monster talk,now harder to get a chest
o 25 June - Killed the original Bards Tale city wall pics and made
            my own. Looking to fix sky color problem and TSR bombing
            due to the sound samples.
o Month of July- Boy, I implemented alot of stuff. Backpack, user
            item list. A gate that opens. etc.
o 5 Aug  - after this I'm not going to doc any more additions
           Scroller,Gauntlet,Estab pics inside, and animated
           smithy.
o 24 Aug - Implemented Double Buffering. Now all flicker is 
           fixed. and we get smooth animation!
           I'm going to fix all the pics and make them look nice!

    main() - This is the main function for the example VDI functions.
*/
/*

   Screen area to put pic is divided into 6 regions

   +---+---+---+---+---+---+
   |   |   |   |   |   |   |
   |   |   |   |   |   |   |
   |   |   |   |   |   |   |
   |   |   |   |   |   |   |
   |   |   |   |   |   |   |
   |   |   |   |   |   |   |
   +---+---+---+---+---+---+
     1   2   3   4   5   6


 o There are 9 templates. Divided into 3 Main categories.
   
   CLOSE,MID,FAR.
 
 o There are 3 sub categories. 
  
   Left Wall,Right Wall,Front Wall.

  
   |\
   | \
   |  |    <--- this would be a CLOSE,LEFT WALL
   | /
   |/

   |\
   | |     <--- This would be a MID,Left Wall
   |/

   |\       <--- This is a FAR, Left Wall.
   |/

   o The Right Wall is the same but flipped about the Y axis.

   o the Front Wall is:

     ___________
    |           |
    |           |   <-- This is a Close Front Wall.  etc..
    |           |
    -------------


   THE LOGIC
   ---------

o Each pic then has 6 fields, and each field can have one of 6
  templates. If a field is 0 then it does not use any template.

  struct field_data
   {
    int Field1,
        Field2,
        Field3,
        Field4,
        Field5,
        Field6;
   };
  struct pic
   {
    struct field_data N,S,E,W;
   };
 
 o The map is made up of a 2d array of struct pic
   
    struct pic map[y][x];


 o To build the map.
   
   1. Create your 2d map array by assigning the fields.
   
 o To create a picture.for room at  map[0][0] FACING North
   
   1. vrocopy the main template, which is a sky and ground, to the screen.
   2. look at map[0][0].N.Field1 if !0 it tells which template to get.
      vrocopy this to the correct xy loc on the screen.
   3. Do # 2 for Fields 2-6.
  

*/
/****************************************************************/


/* defines for the 9 templates 
   CL is Close Left Wall
   CR is Close Right Wall
   CF is close Front Wall
   ML,MR,MF
   FL,FR,FF
*/

#define CL 1
#define CR 2
#define CF 3
#define ML 4
#define MR 5
#define MF 6
#define FL 7
#define FR 8
#define FF 9
#define EMPTY 0


      /* uses ONLY fncts from there 'h' files*/
#include <gemdefs.h>       /* that it needs. Smart compiler */
#include <osbind.h>
#include <stdio.h>
#include <maindef2.h>
#include <strings.h>
#define pos_rnd(t) Random()%(t)   /*returns a number from 0 to (t-1) */
 
char *screen,*temp;    /* double buffering screens */
int which_screen = 0;  /* if 0 then use 'screen'
                          if 1 then use 'temp'
                         For double buffering purposes. */

 int  buffer[200];        /* holds the char info for disk loading and saving */

main()

{
    MFDB    theMFDB;    /*  Screen definition structure  */
    MFDB    tempMFDB;
   
    char *scr1,*scr2,*scr3,*scr4,*scr5,*scr6;
      /* used to be in main() now global */
    int realtime=4;/* we'l do a realtime%4 */  
    int off();
    int pxyarray[8],enc_true;
    long hold_addr;
    int xs1,ys1,xs2,ys2,xd1,yd1,yd2,xd2;
    int colors[2];       
    int f,g;
    char dis_map;
    int savex,savey;
   

	appl_init();
	handle = open_workstation(&theMFDB);  /*set up screen MFDB */

  
   temp = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) temp & 0xff)
      temp = temp + (0x100 - (long)temp & 0xff);
      
   scr1 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr1 & 0xff)
      scr1 = scr1 + (0x100 - (long)scr1 & 0xff);
      
    scr2 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr2 & 0xff)
      scr2 = scr2 + (0x100 - (long)scr2 & 0xff);
  
    scr3 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr3 & 0xff)
      scr3 = scr3 + (0x100 - (long)scr3 & 0xff);
    
    scr4 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr4 & 0xff)
      scr4 = scr4 + (0x100 - (long)scr4 & 0xff);
  
    scr5 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr5 & 0xff)
      scr5 = scr5 + (0x100 - (long)scr5 & 0xff);
 
   scr6 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr6 & 0xff)
      scr6 = scr6 + (0x100 - (long)scr6 & 0xff);
    /* only 10 main physical screens in memory */

set_up1();             /* init rooms 1-100 */
set_up2();             /* init rooms 101-247 */
init();         /* init map etc.. */

    tempMFDB.fd_w    = theMFDB.fd_w ; /* 320 pixels wide*/
    tempMFDB.fd_h       = theMFDB.fd_h ; /*200 pixels high */
    tempMFDB.fd_wdwidth = theMFDB.fd_wdwidth ; /*16 words wide*/
    tempMFDB.fd_stand = theMFDB.fd_stand ; /* raster coords.*/
    tempMFDB.fd_nplanes = theMFDB.fd_nplanes; /*low rez has 4 planes */
      

set_xy(xs1,ys1,xs2,ys2,xd1,yd1,xd2,yd2,pxyarray);



 read_stuff(pix1,scr1,1);         /* read back screen into memory */
 read_stuff(pix2,scr2,1);         /* if 0 save to pal4(alt palette),*/
                                  /* if 1 save to newpal(main palette)*/
                                  /* pics that should have a 1 */
                                  /* MISCX.DAT and monster pics */
 read_stuff(pix3,scr3,1);         
 read_stuff(pix4,scr4,1);
 read_stuff(pix5,scr5,1);
 read_stuff(pix6,scr6,1);       
 
 

/* find screen base */
screen = (char *)Physbase(); 
read_stuff(title,temp,1);  /* read main title screen onto the screen*/
read_stuff(title,screen,1); /* read main title screen onto back screen also. */
Setscreen(screen,screen,-1);

theMFDB.fd_addr = (long) screen;

Setpalette(newpal);        /* tel sys to use these colors! */

/*main loop */
 start();

colors[0]=1;
colors[1]=0;

events();
if(weather ==4) Setcolor(6,CURRENT_CLOUD);
else Setcolor(6,CURRENT_SKY);

display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6);
Vsync();


double_buffer(&theMFDB,&tempMFDB,pxyarray);

display_user_stats();
 
 do
     {
   /* update location */
   if( (x < 10 && savex == 10) || (x < 100 && savex == 100))
   v_gtext(handle,133,94,"  ");
   v_gtext(handle,122,94,"x:");
   sprintf(string,"%d",x);
   v_gtext(handle,133,94,string);

   if( (y < 10 && savey == 10) || (y < 100 && savey == 100))
   v_gtext(handle,169,94,"  ");
     v_gtext(handle,158,94,"y:");
   sprintf(string,"%d",y);
   v_gtext(handle,169,94,string);
 
   savex = x; savey = y;  /* save */

      while ( !Bconstat(2) )      /* while no input and didnt just have an encounter  */
       {  
        if( realtime%5 == 0 )    /* stagger */
        {
        switch(realtime%4)
          {
           case 0: v_gtext(handle,276,110,"<");  
                   break;
           case 1: v_gtext(handle,276,110,"=");  break;
           case 2: v_gtext(handle,276,110,">");  break;
           case 3: v_gtext(handle,276,110,"?"); 
          }
        }       
       realtime++;
       if ( realtime > 32767 ) realtime = 0;
       enc_true = events();       /* returns 1 if encounter */
      if (enc_true)
        {
       hold_addr = tempMFDB.fd_addr;  /* save current pic */
       encounter(&tempMFDB,&theMFDB,pxyarray,scr6,&enc_true);
        tempMFDB.fd_addr =(long) hold_addr;  /* restore pic */
        Vsync(); 
      if(weather == 4){
                       Setcolor(6,CURRENT_CLOUD); Dosound( rain_sound );
                      }

      else Setcolor(6,CURRENT_SKY);  /* redisplay sky */

        display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6);
        double_buffer(&theMFDB,&tempMFDB,pxyarray);
if(weather !=4) Setcolor(6,CURRENT_SKY);  /* redisplay sky */

        v_gtext(handle,197,99,street_hold); /* restore street name you were on */
        }
      Vsync();                  /* to reduce flicker */  
      v_gtext(handle,204,188,weather_list[weather]); 
     
       }

    
    
      command = Bconin(2);
       if(command == 0x480000)  /* Foreward */
            {
             move(&tempMFDB,&theMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6);
           /*  tempMFDB.fd_addr = hold_addr;   restore pic */ 
            /*Setpalette( newpal );*/
             display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6);
             double_buffer(&theMFDB,&tempMFDB,pxyarray);
            }
       if(command == 0x4b0000)   /* left */
            {
             look();
             display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6);
             double_buffer(&theMFDB,&tempMFDB,pxyarray);
            }
       if (command == 0x4d0000)   /*Right */
            {
             look();
             display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6);
             double_buffer(&theMFDB,&tempMFDB,pxyarray);
            }
     
        check_for_door();
      
       if (command == 0x190050 || command == 0x190070)/* P key to PAUSE */
        {v_gtext(handle,40,76,"PAUSED");
         user_pause();
         v_gtext(handle,40,76,"      ");
        }
       if (command == 0x620000)       /* Help key for HELP! */
        { help_user();
          user_pause();
        }
        if (command == 0x170069 || command == 0x170049)       /*I key for special display..gold etc..*/
        special_display();

       if (command == 0x3b0000 )  /* F1 for change weapon */
         switch_weapon();
       if(command == 0x220047 || command == 0x220067) /* G for game options */
          game_options(temp,scr1,scr2,scr3,scr4,scr5,scr6);   /* save,quit,credits,sound on/off etc */ 
       
       if(command == 0x160075 || command == 0x160055)  /* U for user item list */
         list_user_items();
       if((command == 0x140054 || command == 0x140074) && user.user_items[13] == 1) 
                                      /* if T pressed and you have a timepiece.. */
         check_time();
          display_user_stats();
          display_street();
     


      hold_addr = tempMFDB.fd_addr;  /* save addr of source pix (pic w/ wall templates */         
          special_events(&tempMFDB,&theMFDB,pxyarray,scr3);  /* special actions check */
          /* scr3 holds addr of gate.pic */
      tempMFDB.fd_addr =(long) hold_addr;  /* restore pic */
      
   }while (1);        /* 4-ever loop.... */








  

}

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
if(which <= 0)
 {

 if (which == 0)i = Fread(filehandle,32L,pal4);
 }
else
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


/***********************/

set_xy(xs1,ys1,xs2,ys2,xd1,yd1,xd2,yd2,pxyarray,tmp_array)
 int xs1,ys1,xs2,ys2,xd1,yd1,yd2,xd2;
 int pxyarray[8];
 int tmp_array[8];
{
 
    /**********************/
  /* source is the tempMFDB and dest is the theMFDB */
 /* xs1 ys1 and xs2 ys2 are DIAGONALLY OPPOSITE CORNERS!! */
  xs1=  70;
  ys1=  93;
  xs2=  192;
  ys2=  181;

  xd1=194;
  yd1=3;
  xd2=316;
  yd2=91;

  pxyarray[0] = xs1;
  pxyarray[1] = ys1;
  pxyarray[2] = xs2;
  pxyarray[3] = ys2;
  
hold_xy[0] =  xd1;
hold_xy[1] =  yd1;
hold_xy[2] =  xd2;
hold_xy[3] =  yd2;
hold_xy[4] =  pxyarray[4] = xd1;
hold_xy[5] =   pxyarray[5] = yd1;
hold_xy[6] =   pxyarray[6] = xd2;
hold_xy[7] =  pxyarray[7] = yd2;



/**************************/
}

/*************************************************************/
/*  This function    - creates the map to move around in
                     - reads map data from file ROOM.DAT
                     - sets your starting position 

                       0 - Cant move that way (Wall)
                   pos # - Room you'll goto 
                   neg # - Loads up an establishment 
                    -1 temple
                    -2 inn
                    -3 tavern
                    -4 guild
                    -5 weapon
                    -6 armor
                    -7 castle
                    -8 tower
                    -9 outside, exit city          
                    -999 enter a house(knock down door)     */

 init()

  
{
    char in;
   FILE *ifp;
   char array[5];         /* at most a max of 3 numbers xxx+null */
   int number;            /* stores converted number */
   int xo=0,yo=0;
   int type=0;            /* if =0 store room
                                 1        n
                                 2        s
                                 3        e
                                 4        w */



   
   ifp = fopen("ROOM.DAT","r");        /* r means read only mode */
    if( ifp == NULL) {printf("Error opening room.dat--\n"); exit(1);}
     while( (fgets(array,5,ifp) !=NULL))
      {                /* number read is placed in array . terminated w/  /0 */
         number = atoi(array);      /* converts string to int */
        /* printf("number read:%d\n",number);*/
         if(type ==0)
          {
          map[yo][xo].room = number;    /* store it */
         /* printf("storing room #:%d\n",map[yo][xo]);*/
          }
  
          if(type==1)
            {
             map[yo][xo].n = number;    /* store it */
           /*  printf("storing nort:%d\n",map[yo][xo].n);*/           
            }
        if(type==2)
            {
             map[yo][xo].s = number;    /* store it */
             /*printf("storing south:%d\n",map[yo][xo].s);   */        
            }
           if(type==3)
           {
           map[yo][xo].e = number;    /* store it */
           /* printf("storing east:%d\n",map[yo][xo].e); */          
            }
         if(type==4)
         {
               map[yo][xo].w = number;    /* store it */
          /* printf("storing west:%d\n",map[yo][xo].w); */           
            }


         type++;
         if( type > 4)
           {
            /* printf("#,and dirs done for room\n");*/
             type = 0;     /* if > 4, reset */
             xo++;                /* we will assign in row major*/
           }
          if( xo == 25)           /* if did all horiz. rooms */
          {
            xo = 0;              /* reset x */
            yo++;                /* and increase y */  
          }
       }       /* end of while */

   fclose(ifp);

  
   flags.which_pal = 0;   /* start w/ main palette */
  
}
   

/*******************/

  look()
   
  

 {
   int ret;
    /*v_gtext(handle,1,36,"in look");*/
    

   switch(dir)
    {
     case 'N' : {
                  if(command == 0x4b0000)
                  dir = 'W';
                  if(command == 0x4d0000)
                  dir = 'E';
                  break;
                }   

     case 'S' : {
                  if(command == 0x4b0000)
                  dir = 'E';
                  if(command == 0x4d0000)
                  dir = 'W';
                  break;
                }   
     case 'E' : {
                  if(command == 0x4b0000)
                  dir = 'N';
                  if(command == 0x4d0000)
                  dir = 'S';
                  break;
                }      
     case 'W' : {
                  if(command == 0x4b0000)
                  dir = 'S';
                  if(command == 0x4d0000)
                  dir = 'N';
                  break;
                }
            }  /*end of case*/
      /*v_gtext(handle,1,36,"         ");*/

    } /*end of funct*/





/**************************************************************/
/* This function will :

                 - Check to see if you move is valid
                 - If so it will move you in the dir 
                   you are facing and adjust your new
                   position accordingly                    
                 - load up estabs.pic if needed. and change 
                   the palette, it will save the 3 changed colors
                   in col1,col2,col3 and replace them at end of this
                   module
*/
move(mf_src,mf_dest,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6)
register MFDB *mf_src,*mf_dest;   /* the src and dest MFDBs!! */
char *scr1,*scr2,*scr3,*scr4,*scr5,*scr6;
int pxyarray[8];
  
   {
    int temp_value,m,col1=0; 
    int blocked = 0;
                                     /* clear our 'door is near' mssg */
        v_gtext(handle,6,83,"                      ");

      switch(dir)
     {
     case 'N': {
                temp_value = map[y][x].n;  /* get it to test for - */ 
                if(map[y][x].n == 0)
                blocked = 1;
                  if(map[y][x].n > 0)
                   y = y - 1;
                  break;
               }
     case 'S': {
                temp_value = map[y][x].s;
                if(map[y][x].s == 0)
                blocked = 1;
                 if(map[y][x].s > 0) 
                  y = y + 1;
                  break;
               }
     case 'E': {
                temp_value = map[y][x].e;
                if(map[y][x].e == 0)
                blocked = 1;
                if(map[y][x].e > 0)
                  x = x + 1;
                  break;
               }
     case 'W': {
                temp_value = map[y][x].w;
                if(map[y][x].w == 0) blocked = 1;
                 if(map[y][x].w > 0)
                   x = x - 1;
                  break;
               } 
       } /*end of switch*/
  if(blocked)
   {
     v_gtext(handle,44,65,"Blocked!        ");
     invoke_tsr( hitwall );
      if(CURRENT_SOUND == 1) Dosound( wind_sound );
      if(CURRENT_SOUND == 4) Dosound( rain_sound );
   }  

 /* check for negative . If so, DONT change the x,y coords, but 
    execute establishment code */
   /* lets re set up pxyarray, cause new pic code may have reset it */
    pxyarray[4] = 194; /* just reset the x1 and x2 values */
    pxyarray[6] = 316;

    if (temp_value < 0)
     { 
       if(temp_value == -2 || temp_value == -3 || temp_value == -10 || temp_value == -12)
       {col1=1;
       load_up_inside_pics(mf_src,mf_dest,pxyarray,scr2,1); /* send it addr of estab.dat in scr2 */
       }
       /* will load up pic for, inn,tavern,supply & bank. Will change 
          3 color palette cells to a diff color, col1 is set to 1 denoting a palette color has changed! 
          LOOK at the last parameter in the function call. If 1 then use reg. inside pic, else
          use smithy pic. */
       if(temp_value == -4) /* guild pic */
       {col1 = 1;
        load_up_inside_pics(mf_src,mf_dest,pxyarray,scr2,2);
       }
       if(temp_value == -5 || temp_value == -6  )
       { col1 = 1;
        
       load_up_inside_pics(mf_src,mf_dest,pxyarray,scr2,0);
       }
       /* will load up pic for, armory,weaponry,guild Will change 
          3 color palette cells to a diff color, and change em back upon exit */
      

 
         switch(temp_value)
         {
           case -1: temple(mf_src,mf_dest,pxyarray,scr6);
                    break;
           case -2: inn();
                    break;
           case -3: 
                    tavern();
                    break;
           case -4: guild();
                    break;
           case -5: weapon(); /* ok. if we enter an estab, the pic ESTABS.DAT has just been
                                 loaded. So all we need to send is MFDB source and dest.!*/
                   gen_estab(mf_src,mf_dest,"weapons.dat","Dragons Head Weaponry",0);
                   break;
           case -6:armour();
                   gen_estab(mf_src,mf_dest,"armor.dat","Platinum Armory",1);   /* send it 1 to denote armory */
                   break;
           case -7: castle(mf_src,mf_dest,pxyarray,scr5);
                    break;
           case -8: tower(mf_src,mf_dest,pxyarray,scr6,scr4);
                    break;
           case -9: outside();
                    break;
           case -10:supply();
                    gen_estab(mf_src,mf_dest,"supply.dat","Na chts Supply",2);   /* send it 2 to denote shoppe */
                    break;
           case -11:arena(mf_src,mf_dest,pxyarray,scr3,scr6);
                    break;
           case -12:bank();
                    break; 
           case -99: enter_room(mf_src,mf_dest,pxyarray,scr6);
                      break;
           case -13:dungeon(); break;
           }
              v_gtext(handle,197,99,street_hold); /* redisplay street name*/
        check_for_sound_change();

        if(col1 ==1 ) /* then we changed the current palette, so reset the colors... */
        { Setcolor(10,0x330); Setcolor(11,0x332); Setcolor(14,0x600);
        }
Setcolor(6,CURRENT_SKY);
if(weather == 4){
                 Setcolor(6,CURRENT_CLOUD);}

     

if(temp_value == TOWER)
{
/*Setpalette( newpal );*/
display(mf_dest,mf_src,pxyarray,*scr1,*scr2,*scr3,*scr4,*scr5,*scr6);
Setcolor(6,CURRENT_SKY);
if(weather == 4) Setcolor(6,CURRENT_CLOUD);
}

  } /* END OF TEMP VAL < 0*/
    } /*end of funct*/




/*******************************************/
/**************************************************************/

clean()
  
   {
      loc = map[y][x].room;
   }


/*******************/

/**************************************************************/


/* This funct :   - sets up a new font
                  - inits the hit roll table
                  - inits the AES and Aline
                  - inits the char stats 
                  - inits the virtual memory hit_table so first 
                    5 cells are set to 1, all others are 0 
                  - turns off keyclick so Dosound() will not be 
                    interrupted */
start()

{
    int color,catch;
    int off();
    int cellh,cellw,charh,charw;
    int number1 = 19,pp;
    char disk;
      


 /* hit roll table goes here */      /* the HRT...hmm put it in init! */
 for(pp=0;pp<16;pp++)
  {
    hrt[pp] = number1;
    number1--;
  }


 mhrt[0]=20;    /* users ac will go from 0-15 w/ 0 being lowest! */
 mhrt[1]=20;
 mhrt[2]=20;
 mhrt[3]=20;
 mhrt[4]=20;
 mhrt[5]=20;
 mhrt[6]=19;
 mhrt[7]=18;
 mhrt[8]=17;
 mhrt[9]=16;
 mhrt[10]=15;
 mhrt[11]=14;
 mhrt[12]=13;
 mhrt[13]=12;
 mhrt[14]=11;
 mhrt[15]=10;


    color = 7;                   /*set text color */
    vst_color(handle,color);

   runner=1;      
   mon_alive =1;
   char_alive =1;  /* if either is set to 0, encounter ends */
   
   loadchar(buffer);
   dir = user.dir;   /* set the map coords to place where you saved*/
   x   = user.x_loc;
   y   = user.y_loc;
  
/*
for(pp=0;pp<10;pp++)
 user.backpack[pp]=-1;*/       /* initally set backpack empty */
for(pp=0;pp<max_items;pp++)  /* set up weapon damnage point lookup */
 unique_item[pp].points = pp;

strcpy(unique_item[0].name,"Dagger");
strcpy(unique_item[1].name,"Club");
strcpy(unique_item[2].name,"Staff");
strcpy(unique_item[3].name,"War Hammer");
strcpy(unique_item[4].name,"Short Sword");
strcpy(unique_item[5].name,"Short Bow");
strcpy(unique_item[6].name,"Pole Arm");
strcpy(unique_item[7].name,"Halaberd");
strcpy(unique_item[8].name,"Long Bow");
strcpy(unique_item[9].name,"Long Sword");
strcpy(unique_item[10].name,"Battle Axe");
strcpy(unique_item[11].name,"Bastard Sword");
strcpy(unique_item[12].name,"Magical Staff");
strcpy(unique_item[13].name,"Magical Bow");
strcpy(unique_item[14].name,"Mithril Sword");
strcpy(unique_item[15].name,"Aurraks Staff");
strcpy(unique_item[16].name,"Conir Balde");
/* up to 50 of em , if want to make bigger, change size in maindefs.h */


/* set up street names, intersections */

intersection[0].room = 1;
strcpy(intersection[0].street_name," Herald Street");
intersection[1].room = 6;
strcpy(intersection[1].street_name," Herald Street");
intersection[2].room = 9;
strcpy(intersection[2].street_name," Herald Street");
intersection[3].room = 12;
strcpy(intersection[3].street_name," Herald Street");
intersection[4].room = 15;
strcpy(intersection[4].street_name," Herald Street");
intersection[5].room = 17;
strcpy(intersection[5].street_name," Herald Street");
intersection[6].room = 25;
strcpy(intersection[6].street_name," Herald Street");

intersection[7].room = 19;
strcpy(intersection[7].street_name,"  an alcove   ");

intersection[8].room = 18;
strcpy(intersection[8].street_name," a side street");
intersection[9].room = 49;
strcpy(intersection[9].street_name," a side street");
intersection[10].room = 164;
strcpy(intersection[10].street_name," a side street");
intersection[11].room = 216;
strcpy(intersection[11].street_name," a side street");

intersection[12].room = 69;
strcpy(intersection[12].street_name," Oldham Street");
intersection[13].room = 155;
strcpy(intersection[13].street_name," Oldham Street");
intersection[14].room = 198;
strcpy(intersection[14].street_name," Oldham Street");
intersection[15].room = 222;
strcpy(intersection[15].street_name," Oldham Street");

intersection[16].room = 163;
strcpy(intersection[16].street_name,"secret passage");

intersection[17].room = 220;
strcpy(intersection[17].street_name," Valkerye Way ");
intersection[18].room = 235;
strcpy(intersection[18].street_name," Valkerye Way ");
intersection[19].room = 207;
strcpy(intersection[19].street_name," Valkerye Way ");
intersection[20].room = 195;
strcpy(intersection[20].street_name," Valkerye Way ");

intersection[21].room = 37;
strcpy(intersection[21].street_name,"   a street   ");
intersection[22].room = 21;
strcpy(intersection[22].street_name,"   a street   ");
intersection[23].room = 22;
strcpy(intersection[23].street_name,"   a street   ");
intersection[24].room = 72;
strcpy(intersection[24].street_name,"   a street   ");
intersection[25].room = 44;
strcpy(intersection[25].street_name,"   a street   ");

intersection[26].room = 82;
strcpy(intersection[26].street_name,"  Gran Platz  ");
intersection[27].room = 128;
strcpy(intersection[27].street_name,"  Gran Platz  ");
intersection[28].room = 149;
strcpy(intersection[28].street_name,"  Gran Platz  ");

intersection[29].room = 144;
strcpy(intersection[29].street_name,"  Chariot Way ");
intersection[30].room = 156;
strcpy(intersection[30].street_name,"  Chariot Way ");
intersection[31].room = 199;
strcpy(intersection[31].street_name,"  Chariot Way ");
intersection[32].room = 194;
strcpy(intersection[32].street_name,"  Chariot Way ");

intersection[33].room = 190;
strcpy(intersection[33].street_name,"   an alley   ");
intersection[34].room = 161;
strcpy(intersection[34].street_name,"   an alley   ");

/*kill key repeat */
Kbrate(255,255);  

/* turn off keyclick*/ 

Supexec( off );

/* load font, font must be in INtel format!!!! */
v_gtext(handle,6,11,"Do you want to use the");
v_gtext(handle,6,19,"(C)urrent font or the");
v_gtext(handle,6,27,"(G)ame's font?");
do
{
disk = Bconin(2);
}while(disk != 'G' && disk != 'g' && disk != 'C' && disk != 'c');

if(disk == 'G' || disk == 'g')
{
vst_load_fonts(handle,0);  /*always 0 */
vst_font(handle,50);   /*id of goth_i8.fnt is 50 */
}

/* call funct to load PLAYER as a TSR*/
load_player_as_tsr();     /* will load player (ie.play.prg) as tsr */


assign_monsters(); /* assign the monsters!! */


do
{
if( (catch=Fopen("appla",0)) < 0 )
  {
      v_gtext(handle,6,11,"Please insert Disk 2  ");
      v_gtext(handle,6,19,"into the current drive");
      v_gtext(handle,6,27,"and press any key.");
      disk = Bconin(2);
       clear_it();
  }
    Fclose(catch);
} while(catch < 0 );


/* finally, lets display the constant stuff... */
 v_gtext(handle,24,104,"Name :");
 v_gtext(handle,24,112,"Align:");
 v_gtext(handle,24,120,"Class:");
 v_gtext(handle,24,128,"A.C. :");
 v_gtext(handle,24,136,"Lvl. :");
 v_gtext(handle,24,174,"Weapon:");
 v_gtext(handle,24,184,"Armour:"); 
 v_gtext(handle,24,196,"Location:");
 v_gtext(handle,96,196,"The City    ");
 v_gtext(handle,78,174,user.weapon);   
 v_gtext(handle,79,184,user.armor);
 v_gtext(handle,24,144,"STR. :");
 v_gtext(handle,24,152,"INT. :");
 v_gtext(handle,24,160,"DEX. :");
 v_gtext(handle,204,110,"Realtime:");
 v_gtext(handle,204,156,"S.P.:");
 v_gtext(handle,204,148,"H.P.:");   
 v_gtext(handle,204,180,"Weather");
}


/******************************************/
/* will display the street you are on 
   searches the intersection[max].room array for the room you are currently in
   if found then display new street
  
   room currntly in : = map[y][x].room;
   max == 35*/

display_street()
{
 int cell,max,counter;
 int not_found=1;        /* initally set to 1 */

   cell = map[y][x].room;
    max = 35;                  /* max search limit */
     counter = 0;
 
     while( (counter < max) && (not_found)) /* loop until found or search entire array */
       {
        if (cell == intersection[counter].room)
           { not_found = 0;    /* set to false, we found it */
             v_gtext(handle,197,99,intersection[counter].street_name); 
             strcpy(street_hold,intersection[counter].street_name);
            /* save the street name */
             
           }
        counter++;
       }
}

/**********/
off()
{
 char *conterm;

 conterm = (char *) 0x484L;
 *conterm &=0xFE;   /* turn lsb off */
}

/***********/
/* help user: Displays help info to the user */
help_user()
{
  
clear_it();
v_gtext(handle,6,11,"    ~ Help Options ~ ");
v_gtext(handle,6,27,"Up    Arrow -Go forward");
v_gtext(handle,6,35,"Right Arrow -Turn right");
v_gtext(handle,6,43,"Left  Arrow -Turn left");
v_gtext(handle,6,51,"P     Key   -Pause    ");
v_gtext(handle,6,59,"I     Key   -User Info");
v_gtext(handle,6,85,"Press any key");
user_pause();
clear_it();
v_gtext(handle,6,19,"    ~ Help Options ~ ");
v_gtext(handle,6,35,"F1   Key -Switch Weapon");
v_gtext(handle,6,43,"G    Key -Game Options");
v_gtext(handle,6,51,"U    Key -User Items");
v_gtext(handle,6,59,"T    Key -Check time");
v_gtext(handle,6,67,"Help Key -This Menu");
v_gtext(handle,6,75,"Undo Key -Quit game");
v_gtext(handle,6,83,"Press any key");

}

/*********/
/* user_pause: Waits until user hits a key before returning.. */

user_pause()
{
 char hh;
 
  hh = Bconin(2);
}


/************
Double_Buffer
*************/

double_buffer(theMFDB,tempMFDB,pxyarray)
register MFDB *theMFDB,*tempMFDB;
int pxyarray[8];
{
        
}

/*****************/
/* new pic code */
/*****************************/
 getcoord(Field ,pxyarray)     /* returns source pxyarray 
                       */
 int Field,pxyarray[8];

 /*#define CL 1
#define CR 2
#define CF 3
#define ML 4
#define MR 5
#define MF 6
#define FL 7
#define FR 8
#define FF 9
#define EMPTY 0 */

{char ccc;

  switch(Field)
    {
     case CL: pxyarray[0] = 131; pxyarray[1] = 3; pxyarray[2] = 150; pxyarray[3] = 91; break;
     case ML: pxyarray[0] = 151; pxyarray[1] = 3; pxyarray[2] = 170; pxyarray[3] = 91; break;
     case FL: pxyarray[0] = 171; pxyarray[1] = 3; pxyarray[2] = 192; pxyarray[3] = 91; break;
     case CF: pxyarray[0] = 71; pxyarray[1] = 3; pxyarray[2] = 90; pxyarray[3] = 91; break;
     case MF: pxyarray[0] = 91; pxyarray[1] = 3; pxyarray[2] = 110; pxyarray[3] = 91; break;
     case FF: pxyarray[0] = 111; pxyarray[1] = 3; pxyarray[2] = 129; pxyarray[3] = 91; break;
     case CR: pxyarray[0] = 171; pxyarray[1] = 93; pxyarray[2] = 192; pxyarray[3] = 181; break;
     case MR: pxyarray[0] = 151; pxyarray[1] = 93; pxyarray[2] = 170; pxyarray[3] = 181; break;
     case FR: pxyarray[0] = 131; pxyarray[1] = 93; pxyarray[2] = 150; pxyarray[3] = 181; break;
     case EMPTY: break;
    }

}
/*****************************/

display(mfd,mfs,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6)
register MFDB *mfd,*mfs;
int pxyarray[8];
char *scr1,*scr2,*scr3,*scr4,*scr5,*scr6;

{
int check_for_new_pal,
    facing = 0;
char tyee;

           /* if facing an estab, facing will be a neg # */
           /* if -99 then its a door */
    if( dir == 'N') facing = map[y][x].n;
    if( dir == 'S') facing = map[y][x].s;
    if( dir == 'E') facing = map[y][x].e;
    if( dir == 'W') facing = map[y][x].w;

    cell = map[y][x].room;
      /* set dest as entire window */  /* recopy main template */
    pxyarray[4] = 194; pxyarray[5] = 3; pxyarray[6] = 316; pxyarray[7] = 91;
    mfs->fd_addr = (long) scr1;      /* set addr */
    pxyarray[0] = 194; pxyarray[1] = 93;  /* BR ground and sky only */
    pxyarray[2] = 316; pxyarray[3] = 181;
    vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy  */
   
     
    if(facing <= 0)          /* if your're facing an estab.. */
      {   
          switch(facing)
          {
           case BANK:
           case WEAPON:
           case ARMORY:
           case GUILD:
           case SUPPLY:
           case TAVERN:
           case INN:   mfs->fd_addr = (long) scr5; /* misc2.dat */
                       pxyarray[0] = 194; pxyarray[1] = 3; pxyarray[2]=316; pxyarray[3]=91; /* TR pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case TOWER: mfs->fd_addr = (long) scr5; /* misc2.dat */
                       pxyarray[0] = 70; pxyarray[1] = 3; pxyarray[2]=192; pxyarray[3]=91; /* TL pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case GATE:
           case ARENA: mfs->fd_addr = (long) scr1; /* main.pc1 TR has gate down pic*/
                       pxyarray[0] = 194; pxyarray[1] = 3; pxyarray[2]=316; pxyarray[3]=91; /* TR pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case DUNGEON:
                       mfs->fd_addr = (long) scr4; /* misc1.dat */
                       pxyarray[0] = 70; pxyarray[1] = 3; pxyarray[2]=192; pxyarray[3]=91; /* TL pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case PALACE:
                       mfs->fd_addr = (long) scr5; /* misc2.dat */
                       pxyarray[0] = 194; pxyarray[1] = 93; pxyarray[2]=316; pxyarray[3]=181; /* BR pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case TEMPLE:
                       mfs->fd_addr = (long) scr4; /* misc1.dat */
                       pxyarray[0] = 194; pxyarray[1] = 93; pxyarray[2]=316; pxyarray[3]=181; /* BR pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case DOOR:  mfs->fd_addr = (long) scr4; /* misc1.dat */
                       pxyarray[0] = 194; pxyarray[1] = 3; pxyarray[2]=316; pxyarray[3]=91; /* TR pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
           case WALL:  mfs->fd_addr = (long) scr2; /* estabs.dat */
                       pxyarray[0] = 194; pxyarray[1] = 3; pxyarray[2]=316; pxyarray[3]=91; /* TR pic */
                       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */
                       break;
          }

      } /* end of facing an estab */

            /* ONE more condition, if we opened the gate leading to 
               the wizards tower an the dungeon entrance, we set 
               map[13][1].e = 164;                                  
               map[13][2].w = 163;
               so that we can pass through, the only problem is that 
               we need this info to be = to -9 which reps a gate!
               so test to see if these values ar NOT -9 and if they are not
               then display a pic of a gate thats open and set 
               facing = some neg # so that the case below will fall through.. */
       if( ((cell == 164 && dir == 'W') || (cell == 163 && dir =='E')) 
          && (map[13][1].e == 164 ) )  /* only need to check one */
       {
         mfs->fd_addr = (long) scr3; /* gate.dat */
         pxyarray[0] = 194; pxyarray[1] = 93; pxyarray[2]=316; pxyarray[3]=181; /* BR pic */
         vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy */       
         facing = -88;  /* set facing to a neg # */
       }    

if( facing > 0)       /* if not facing and estab(or door, or front wall) */
 {          
   pxyarray[4] = 195;   /* Reset dest starting coords. for the 6 regions... */
    pxyarray[6] = 214;
            
  switch(dir)
    {
     case 'N' : {
        /* vrocopy the 6 regions
         pxyarray[4-7] is the dest.
         pxyarray[4] & pxyarray[6] need to be inc by 20 
         after each vrocopy is called for a region( cause the regions 
         are 20 pixels long )
         pxyarray[5]& [7] are constant.
   
         */
   /**
      roomrec has an entry for each room
       1. to access that entry use the map[y][x].room variable
          as an index into roomrec[].<Filedx>
   **/
       /* region 1 */
       
       getcoord(roomrec[map[y][x].room].N.Field1,pxyarray ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].N.Field1) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
   
       /*region 2 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].N.Field2,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].N.Field2) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
   
        /*region 3 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].N.Field3,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].N.Field3) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 4 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].N.Field4,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].N.Field4) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].N.Field5,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].N.Field5) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].N.Field6,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].N.Field6) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
           break;
     }   
	
     case 'S' : {
            /* region 1 */
      
       getcoord(roomrec[map[y][x].room].S.Field1,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].S.Field1) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

       /*region 2 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].S.Field2,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].S.Field2) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 3 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].S.Field3,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].S.Field3) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 4 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].S.Field4,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].S.Field4) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].S.Field5,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].S.Field5) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].S.Field6,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].S.Field6) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

          break;
                }   
     case 'E' : {
             /* region 1 */
      
       getcoord(roomrec[map[y][x].room].E.Field1,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].E.Field1) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

       /*region 2 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].E.Field2,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].E.Field2) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 3 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].E.Field3,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].E.Field3) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 4 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].E.Field4,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].E.Field4) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].E.Field5,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].E.Field5) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].E.Field6,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].E.Field6) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

           break;
                }      
     case 'W' : 
      {
       /* region 1 */
      
       getcoord(roomrec[map[y][x].room].W.Field1,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].W.Field1) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

       /*region 2 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].W.Field2,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].W.Field2) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 3 */
       pxyarray[4] += 19;   /* dest */
       pxyarray[6] += 19;
       getcoord(roomrec[map[y][x].room].W.Field3,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].W.Field3) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 4 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].W.Field4,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].W.Field4) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].W.Field5,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].W.Field5) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 20;   /* dest */
       pxyarray[6] += 20;
       getcoord(roomrec[map[y][x].room].W.Field6,pxyarray  ); /* returns source pxyarray */
       if(roomrec[map[y][x].room].W.Field6) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* copy wholescreens */

            break;
       }

   }  /*end of switch*/  
  } /* end of facing a wall */
}

/***/
check_for_door()
{
 int dn,ds,de,dw;

 dn = map[y][x].n;
 ds = map[y][x].s;
 de = map[y][x].e;
 dw = map[y][x].w;

if(dn < 0 || ds < 0 || de < 0 || dw < 0 )
 v_gtext(handle,6,83,"   A door is near.     ");

}
 
