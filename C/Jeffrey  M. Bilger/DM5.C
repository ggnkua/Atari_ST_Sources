char hitwall[] = "2 D:hitwa";  /* hit wall sound */
char gate[]    = "2 D:gate0";  /* gate sound */


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

#define MOVED_LEFT  0         /* for special_move check */
#define MOVED_RIGHT 1
#define MOVED_BACK  2
#define FOREWARD   0x480000           
#define TURN_LEFT  0x520000
#define TURN_RIGHT 0x470000
#define BACK       0x500000
#define LEFT       0x4b0000
#define RIGHT      0x4d0000
#define NOTHING    0x111111


/* re coding for dungeon module.   1-26-94 

  - Implementing Dungeonmaster walls.

*/





      /* uses ONLY fncts from there 'h' files*/
#include <gemdefs.h>       /* that it needs. Smart compiler */
#include <osbind.h>
#include <stdio.h>
#include <dungmain.h>
#include <strings.h>
#include <linea.h>

#define pos_rnd(t) Random()%(t)   /*returns a number from 0 to (t-1) */
 
char *screen,*back,*temp;    /* double buffering screens */
                       /* back is allocated 32k, 
                          screen = Physbase */

int which_screen = 0;  /* if 0 then use 'screen'
                          if 1 then use 'back'
                         For double buffering purposes. */

 int  buffer[200];        /* holds the char info for disk loading and saving */


/* define our templates */
#define CF64	1                 
#define CL   	2
#define CR		3
#define ML      4
#define MR      5
#define FL      6
#define FR      7
#define CF1     8
#define CF2     9 
#define CF1_SPECIAL   10
#define CF2_SPECIAL   11
#define MF3211		12
#define MF3212		13
#define MF1611		14
#define MF1612		15
#define MF641		16
#define FF3211		17
#define FF3212		18
#define FF1611		19
#define FF1612		20
#define FF641		21
#define MF3221		22	
#define MF3222		23
#define MF1621		24
#define MF1622		25
#define MF642		26
#define FF3221		27
#define FF3222		28
#define FF1621		29
#define FF1622		30
#define FF642		31
#define ML_GATE       32
#define MR_GATE       33
#define FL_GATE       34
#define FR_GATE       35
#define CL_GATE       36
#define CR_GATE       37
#define REG_R4_FILL   38
#define REG_FAR_FILL  39
#define REG_MED_CLOSE_FILL  40
#define FAR_GATE      41
#define CLOSE_GATE    42
#define EMPTY               0

#define OR 7
#define REPLACE 3
int mode;


int room =1;         /* tells what room your in */
int rect1[4];        /* rectangle of display movement area */
lineaport *theport;              /* a line identifier */
unsigned form[37];   /* for new mouse sprite */

int floor = 0;  /* if 0 use floor 1, if 1 use floor 2 */ 



main()

{
    MFDB    theMFDB;    /*  Screen definition structure  */
    MFDB    tempMFDB;
    MFDB    backgroundMFDB;  /* to save background for gates */

 
    /* define background screens. We need 
       1 for Templates
       2,3,4 for monsters?? */

    char *scr1,                   /* wall templates 1 */
         *scr2,					  /* wall templates 2 */
         *scr3,					  /* WALL templates 3*/
         *scr4,		              /* wall templates 4*/
         *scr5,                   /* floor template 1*/
         *scr6,                   /* floor template 2*/
         *scr7,
         *gate_back;              /* memory to store background info*/

      /* used to be in main() now global */
    int realtime=4;/* we'l do a realtime%4 */  
    int off();
    int pxyarray[8],      /* for vrocopyfm */
        enc_true;
    long hold_addr;
    int xs1,ys1,xs2,ys2,xd1,yd1,yd2,xd2;
    int colors[2];       
    int f,g,lll;
    char dis_map;
    int savex,savey;
    int can_move;    /* returned from move() if 1 = you can move that way
                                                0 = its blocked */
                     
    theport = a_init();            /* invoke a line driver */

      appl_init();

         a_hidemouse();



   x =5; y=0;
   dir = 'N';
   pxyarray[4]=7; pxyarray[4]=4; pxyarray[4]=38; pxyarray[4]=144;
   
    rect1[0]= 7;       /* area to 'black out' before we do screen copy */
    rect1[1]= 144;     /* it's the movement display region */
    rect1[2]= 230;
    rect1[3]= 9;


	appl_init();
	handle = open_workstation(&theMFDB);  /*set up screen MFDB */

vsf_color(handle,15);  /* white */
vsf_interior(handle,1);


   screen= malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long)screen & 0xff)
      screen = screen + (0x100 - (long)screen & 0xff);
 
  
   back = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long)back & 0xff)
      back = back + (0x100 - (long)back & 0xff);
      
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
    
   scr7 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr7 & 0xff)
      scr7 = scr7 + (0x100 - (long)scr7 & 0xff);
  

    gate_back = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) gate_back & 0xff)
      gate_back = gate_back + (0x100 - (long)gate_back & 0xff);

     /* only 6 main physical screens in memory */

set_up1();             /* init rooms 1-3 */
/*set_up2();             init rooms 101-247 */
init(12,"level1.dat");         /* init map etc.. */

    tempMFDB.fd_w    = theMFDB.fd_w ; /* 320 pixels wide*/
    tempMFDB.fd_h       = theMFDB.fd_h ; /*200 pixels high */
    tempMFDB.fd_wdwidth = theMFDB.fd_wdwidth ; /*16 words wide*/
    tempMFDB.fd_stand = theMFDB.fd_stand ; /* raster coords.*/
    tempMFDB.fd_nplanes = theMFDB.fd_nplanes; /*low rez has 4 planes */
      
    /* holds the background pic for gate movement */
    backgroundMFDB.fd_w       = theMFDB.fd_w; /*  pixels wide*/
    backgroundMFDB.fd_h       = theMFDB.fd_h ; /*  pixels high*/
    backgroundMFDB.fd_wdwidth = theMFDB.fd_wdwidth;  /*fdw divided by 16 */
    backgroundMFDB.fd_stand = theMFDB.fd_stand; /* raster coords.*/
    backgroundMFDB.fd_nplanes = theMFDB.fd_nplanes; /*low rez has 4 planes */




 read_stuff(pix1,scr1,1); /* WALLS 1*/        /* read back screen into memory */
 read_stuff(pix2,scr2,1); /* walls 2*/
 read_stuff(pix3,scr3,1); /* walls 3*/
 read_stuff(pix4,scr4,1); /* walls 4*/
 read_stuff(pix5,scr5,1);  /*FLOOR1*/
 read_stuff(pix6,scr6,1);  /*FLOOR 2 */
 read_stuff(pix7,scr7,1);  /*GATES*/



/* find screen base */
/*
screen = (char *)Physbase(); 
*/
read_stuff(title,back,1);  /* read main title screen onto the screen*/
read_stuff(title,screen,1); /* read main title screen onto back screen also. */
Setscreen(back,screen,-1);

/* set the destination MFDB to the back screen, and the backgroundMFDB
   to the gate_back area */
theMFDB.fd_addr = (long) back;    
backgroundMFDB.fd_addr = (long) gate_back;




Setpalette(newpal);        /* tel sys to use these colors! */

graf_mouse(3,form);
a_showmouse();



/*main loop */
 start();

colors[0]=1;
colors[1]=0;

/*
events();
*/

                                      /* these are constant ! */
 pxyarray[5] = 9; pxyarray[7] = 144;  /* destination y coords */
command = NOTHING;
display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);
Vsync();



/*
display_user_stats();
*/ 


 do
     {
      
  /* get here, key was pressed */    
      command = Bconin(2);
       if(command == FOREWARD)  /* Foreward */
            {
             can_move=move();
             if(can_move)
              display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);

            }
       if(command == TURN_LEFT)   /* TURN left */
            {
             look();
             display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);      
            }
       if (command == TURN_RIGHT)   /*TURN Right */
            {
             look();
             display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);
            
            }
       if (command == BACK)   /*back*/
            {
             can_move=special_move(MOVED_BACK);
             if(can_move)
              display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);
            
            }
     
         if (command == LEFT)   /*GO LEFT(sideways)*/
            {
             can_move=special_move(MOVED_LEFT);
             if(can_move)
              display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);
             
            }
     
        if (command == RIGHT)   /*GO RIGHT(sideways)*/
            {
             can_move=special_move(MOVED_RIGHT);
             if(can_move)
              display(&theMFDB,&tempMFDB,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,&backgroundMFDB);
            
            }



  check_for_closed_gate(&tempMFDB,&theMFDB,&backgroundMFDB,pxyarray,scr7);


  
}while (1);        /* 4-ever loop.... */  

	v_clsvwk(handle);
	appl_exit();
}



/*************************************************************/
/* This function     - checks the dir you are facing and tests
                       to see if you are at a closed gate    

   Algorithm:     map[room].dir holds values. If this value is:

                    0   -- a wall, you cant move that way
                   >0   -- designates which room you'll end up in 
                           if you decide to move that direction
                   <0   -- Denotes a CLOSED gate. And this negative
                           number is the room number of the room
                           beyond the gate!!!!

                  We will check the value of map[room] for every
                  direction. If a negative value is found and 
                  we're facing it, lets call the gate animation
                  code and then set map[room].dir to the room 
                  number after the gate.( * by -1 of course!! ) 
                  Finally we will set the roomrec[room].dir.Field4
                  to EMPTY so that the gate will not be displayed again
                 
*/

check_for_closed_gate(tempMFDB,theMFDB,backgroundMFDB,pxyarray,scr7)
MFDB *theMFDB,
     *tempMFDB,
     *backgroundMFDB;
int pxyarray[];
char *scr7;

{
 int lll,
     closed = 0;   /* if set to 1, we found a closed gate the 
                      direction we were facing */
 
  if(map[room].n < 0 && dir == 'N') closed =1; /* CHECK for closed gate*/
   if(map[room].s < 0 && dir == 'S')closed =1; /* denoted by a negative #*/
   if(map[room].e < 0 && dir == 'E')closed =1;
  if(map[room].w < 0 && dir == 'W') closed =1;


   if( closed )   /* if closed = 1 then lets animate gate and
                     set map[room].dir = room # after gate */
     {
         /* copy the region that the gate will cover into 
            the gate_back, or the backgroundMFDB store it 
            at coords (71,31)(166,112) using REPLACE mode */
        
  
   /* when we 'built' the scene, if we were at a CLOSE ,CLOSED gate
      we copied regions 1,2,3,5,6,7 then WE saved the area
      that will be behind the gate in backgroundMFDB
      then we display the gate (region4)
   */


  for(lll=0;lll<=2;lll++)
{

     tempMFDB->fd_addr = (long) scr7;  /* scr that holds gate.pc1 */
  
     /* recopy area behind the gate....*/
     /* source coords */
     pxyarray[0]=71; pxyarray[1]=31; pxyarray[2]=166; pxyarray[3]=112;    
     /* dest coords  */
     pxyarray[4]=71; pxyarray[5]=31; pxyarray[6]=166; pxyarray[7]=112;    
     /* do the copy: theMFDB is the DEST, backgroundMFDB is the SOURCE*/
     vro_cpyfm(handle,REPLACE,pxyarray,backgroundMFDB,theMFDB);     


     pxyarray[4] = 71;                /* the destination coords */
     pxyarray[6] = 166;
     pxyarray[5] = 32; pxyarray[7]=112;

    
  switch(lll)
   {
      
    case 0:  
     pxyarray[0]=0; pxyarray[1]=81; pxyarray[2]=95; pxyarray[3]=160;
    vro_cpyfm(handle,4,pxyarray,tempMFDB,theMFDB);  /* copy wholescreens */
    pxyarray[0]=96; pxyarray[1]=81; pxyarray[2]=191; pxyarray[3]=160;
    vro_cpyfm(handle,7,pxyarray,tempMFDB,theMFDB);  /* copy wholescreens */
    break;

    case 1:  
     pxyarray[0]=205; pxyarray[1]=0; pxyarray[2]=300; pxyarray[3]=79;
    vro_cpyfm(handle,4,pxyarray,tempMFDB,theMFDB);  /* copy wholescreens */
    pxyarray[0]=206; pxyarray[1]=84; pxyarray[2]=301; pxyarray[3]=163;
    vro_cpyfm(handle,7,pxyarray,tempMFDB,theMFDB);  /* copy wholescreens */
    break;

   } /* end of switch */
 invoke_tsr(gate);
  pause(15);

 
   } /* end of for */

    /* lets set the map[room].dir = room number. This is so
       we denote the gate is open and you can pass thru it to 
       that room!  NOTE: The number is negative and it just
       happens to be the room # thats beyond the gate. So mult
       by -1 to make it positive!!(nice trick..) 

       BUT:  We must take in account that there are 2 ways to 
             pass through a gate. So we must update 2 room's
             map[] data structure. It's complicted code, but
             just follow through it..

             example: lvl 1 at room 12 if facing south there is
                      a gate. If we open it we must update 
                      map[12].s AND map[23].n!!!

                      The first one is easy. map[room].dir...
                      the next one takes some effort.
                      map[map[map[room].s].s].n = ...  

     We must also set Field4 of the roomrec data struct to EMPTY
     because it is this data that tells our builder engine what
     to display. If a gate went up, we need to modify roomrec
     so that it will not get displayed again thank you...*/

   if(dir == 'N') 
     {       map[room].n = (-1 * map[room].n);
             map[map[map[room].n].n].s = (-1 * map[map[map[room].n].n].s);
             
             roomrec[room].N.Field4 = EMPTY;
             roomrec[map[room].s].N.Field4 = EMPTY;
             roomrec[map[map[room].n].n].S.Field4 = EMPTY;
             roomrec[map[map[map[room].n].n].n].S.Field4 = EMPTY;
 
    }  
   if(dir == 'S')
     {       map[room].s = (-1 * map[room].s);  
             map[map[map[room].s].s].n = (-1 * map[map[map[room].s].s].n);
         
            roomrec[room].S.Field4 = EMPTY;  
            roomrec[map[room].n].S.Field4 = EMPTY;
             roomrec[map[map[room].s].s].N.Field4 = EMPTY;
             roomrec[map[map[map[room].s].s].s].N.Field4 = EMPTY;
 
    }
   if(dir == 'E') 
     {       map[room].e = (-1 * map[room].e);
             map[map[map[room].e].e].w = (-1 * map[map[map[room].e].e].w);
           
             roomrec[room].E.Field4 = EMPTY;
             roomrec[map[room].w].E.Field4 = EMPTY;
             roomrec[map[map[room].e].e].W.Field4 = EMPTY;
             roomrec[map[map[map[room].e].e].e].W.Field4 = EMPTY;
    

     }  
   if(dir == 'W') 
     {       map[room].w = (-1 * map[room].w);  
             map[map[map[room].w].w].e = (-1 * map[map[map[room].w].w].e);
     
             roomrec[room].W.Field4 = EMPTY;
             roomrec[map[room].e].W.Field4 = EMPTY;
             roomrec[map[map[room].w].w].E.Field4 = EMPTY;
             roomrec[map[map[map[room].w].w].w].E.Field4 = EMPTY;

     }

} /* end of if room == 4*/

} /* end of fnct */

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

 init(MAX_X,datafile)
 int MAX_X;  /* holds max x value of level you are reading in */
 char *datafile; /* hold the text file to read the room data from */
  

   /* room holds    room#,n,s,e,w
                    if n,s,e,w = 0 then its a wall and you can not 
                                   go that way,
                    else n,s,e,w = room # you'll be in if you go that way */

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
   int room = 1; /* start at room 1 */


   
   ifp = fopen(datafile,"r");        /* r means read only mode */
    if( ifp == NULL) {printf("Error opening room.dat--\n"); exit(1);}
     while( (fgets(array,5,ifp) !=NULL))
      {                /* number read is placed in array . terminated w/  /0 */
         number = atoi(array);      /* converts string to int */
         /* printf("number read:%d\n",number);*/
         if(type ==0)
          {
          map[room].room = number;    /* store it */
         /*printf("storing room #:%d\n",map[yo][xo]);*/
          }
  
          if(type==1)
            {
             map[room].n = number;    /* store it */
            /* printf("storing north:%d\n",map[yo][xo].n);*/           
            }
        if(type==2)
            {
             map[room].s = number;    /* store it */
             /*printf("storing south:%d\n",map[yo][xo].s);  */    
            }
           if(type==3)
           {
           map[room].e = number;    /* store it */
           /* printf("storing east:%d\n",map[yo][xo].e);      */     
            }
         if(type==4)
         {
               map[room].w = number;    /* store it */
         /*  printf("storing west:%d\n",map[yo][xo].w);*/
            }


         type++;
         if( type > 4)
           {
            /* printf("#,and dirs done for room\n");*/
             type = 0;     /* if > 4, reset */
             room++; /* increase room # */
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
                  if(command == 0x520000)
                  dir = 'W';
                  if(command == 0x470000)
                  dir = 'E';
                  break;
                }   

     case 'S' : {
                  if(command == 0x520000)
                  dir = 'E';
                  if(command == 0x470000)
                  dir = 'W';
                  break;
                }   
     case 'E' : {
                  if(command == 0x520000)
                  dir = 'N';
                  if(command == 0x470000)
                  dir = 'S';
                  break;
                }      
     case 'W' : {
                  if(command == 0x520000)
                  dir = 'S';
                  if(command == 0x470000)
                  dir = 'N';
                  break;
                }
            }  /*end of case*/
      /*v_gtext(handle,1,36,"         ");*/

    } /*end of funct*/

/*************************************************************/
/* this function will: check for 'special move' and if valid
                       it will update the room you are in.
 
   A special move is a sideways move left or right
*/
special_move(direction)
int direction;  /* if 0 you moved left 
                   if 1 you tried to move right 
                   if 2 you tried to move backwards*/

   {
    int blocked = 0;
                                     /* clear our 'door is near' mssg */
      /*  v_gtext(handle,6,83,"                      ");*/

     if( direction == MOVED_LEFT )
      {
           switch(dir)
                     {
                      case 'N': { 
                				if(map[room].w <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].w;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'S': { 
                				if(map[room].e <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].e;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'E': { 
                				if(map[room].n <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].n;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'W': { 
                				if(map[room].s <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].s;  /* goto the room @ the north*/
                  				break;
               					}
               } /*end of switch*/
            } /* end of IF try to go left */
 
     if( direction == MOVED_RIGHT )
      {
           switch(dir)
                     {
                      case 'N': { 
                				if(map[room].e <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].e;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'S': { 
                				if(map[room].w <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].w;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'E': { 
                				if(map[room].s <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].s;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'W': { 
                				if(map[room].n <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].n;  /* goto the room @ the north*/
                  				break;
               					}
               } /*end of switch*/
            } /* end of IF try to go right */
     if( direction == MOVED_BACK )
      {
           switch(dir)
                     {
                      case 'N': { 
                				if(map[room].s <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].s;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'S': { 
                				if(map[room].n <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].n;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'E': { 
                				if(map[room].w <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].w;  /* goto the room @ the north*/
                  				break;
               					}
                      case 'W': { 
                				if(map[room].e <= 0)
                				blocked = 1;
                  				else
                   				room = map[room].e;  /* goto the room @ the north*/
                  				break;
               					}
               } /*end of switch*/
            } /* end of IF try to go back */


  if(blocked)
   {
   

     invoke_tsr( hitwall );  
       /* if blocked return a 0 */
       return(0);

   }  
  
    /* else return  a 1*/
    return(1);


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
move()
  
   { 
    int blocked = 0;
                                     /* clear our 'door is near' mssg */
      /*  v_gtext(handle,6,83,"                      ");*/

      switch(dir)
     {
     case 'N': {
               
                if(map[room].n <= 0)
                blocked = 1;
                  else
                   room = map[room].n;  /* goto the room @ the north*/
                  break;
               }
     case 'S': {
                
                if(map[room].s <= 0)
                blocked = 1;
                 else 
                  room = map[room].s;  /* goto room at the S */
                  break;
               }
     case 'E': {
               
                if(map[room].e <= 0)
                blocked = 1;
                else
                  room = map[room].e;
                  break;
               }
     case 'W': {
                
                if(map[room].w <= 0) blocked = 1;
                 else
                   room = map[room].w;
                  break;
               } 
       } /*end of switch*/
  if(blocked)
   {
   
    invoke_tsr( hitwall );  
       /* if blocked return a 0 */
       return(0);

   }  
  
    /* else return  a 1*/
    return(1);


    } /*end of funct*/




/*******************************************/
/**************************************************************/

clean()
  
   {
      loc = map[room].room;
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
   
/*
   loadchar(buffer);
   dir = user.dir;    set the map coords to place where you saved
   x   = user.x_loc;
   y   = user.y_loc;*/
  
/*
for(pp=0;pp<10;pp++)
 user.backpack[pp]=-1;*/       /* initally set backpack empty */
for(pp=0;pp<max_items;pp++)  /* set up weapon damnage point lookup */
 unique_item[pp].points = pp;

/*
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

*/

/* up to 50 of em , if want to make bigger, change size in maindefs.h */


/* set up street names, intersections */

/*
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


*/

/*kill key repeat */
Kbrate(255,255);  

/* turn off keyclick*/ 

Supexec( off );

/* load font, font must be in INtel format!!!! */
/*
v_gtext(handle,6,11,"Do you want to use the");
v_gtext(handle,6,19,"(C)urrent font or the");
v_gtext(handle,6,27,"(G)ame's font?");
do
{
disk = Bconin(2);
}while(disk != 'G' && disk != 'g' && disk != 'C' && disk != 'c');

if(disk == 'G' || disk == 'g')
{
vst_load_fonts(handle,0);*/  /*always 0 */
/*vst_font(handle,50);*/   /*id of goth_i8.fnt is 50 */
/*}*/

/* call funct to load PLAYER as a TSR*/
load_player_as_tsr();     /* will load player (ie.play.prg) as tsr */

/*
assign_monsters(); *//* assign the monsters!! */

/*
do
{
if( (catch=Fopen("appla",0)) < 0 )
  {
      v_gtext(handle,6,11,"Please insert Disk 2  ");
      v_gtext(handle,6,19,"into the current drive");
      v_gtext(handle,6,27,"and press any key.");
      disk = Bconin(2);
      
  }
    Fclose(catch);
} while(catch < 0 );
*/

/* finally, lets display the constant stuff... */
 
/*
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
*/
}


/******************************************/
/* will display the street you are on 
   searches the intersection[max].room array for the room you are currently in
   if found then display new street
  
   room currntly in : = map[room].room;
   max == 35*/

display_street()
{
 int cell,max,counter;
 int not_found=1;        /* initally set to 1 */

   cell = map[room].room;
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
  

v_gtext(handle,6,11,"    ~ Help Options ~ ");
v_gtext(handle,6,27,"Up    Arrow -Go forward");
v_gtext(handle,6,35,"Right Arrow -Turn right");
v_gtext(handle,6,43,"Left  Arrow -Turn left");
v_gtext(handle,6,51,"P     Key   -Pause    ");
v_gtext(handle,6,59,"I     Key   -User Info");
v_gtext(handle,6,85,"Press any key");
user_pause();

v_gtext(handle,6,19,"    ~ Help Options ~ ");
v_gtext(handle,6,35,"F1   Key -Switch Weapon");
v_gtext(handle,6,43,"G    Key -Game Options");
v_gtext(handle,6,51,"U    Key -User Items");
v_gtext(handle,6,59,"T    Key -Check time");
v_gtext(handle,6,67,"Help Key -This Menu");

v_gtext(handle,6,83,"Press any key");

}

/*********/
/* user_pause: Waits until user hits a key before returning.. */

user_pause()
{
 char hh;
 
  hh = Bconin(2);
}


/*****************/
/* new pic code */
/*****************************/
/* returns source pxyarray for 
      Dungeon templates 
#define MF3211		12
#define MF3212		13
#define MF1611		14
#define MF1612		15
#define MF641		16
#define FF3211		17
#define FF3212		18
#define FF1611		19
#define FF1612		20
#define FF641		21
#define MF3221		22	
#define MF3222		23
#define MF1621		24
#define MF1622		25
#define MF642		26
#define FF3221		27
#define FF3222		28
#define FF1621		29
#define FF1622		30
#define FF642		31

*/

 getcoord(Field ,pxyarray,mfs,scr1,scr2,scr3,scr4,scr7)       
 int Field,pxyarray[8];
 register MFDB *mfs;
 char *scr1,*scr2,*scr3,*scr4,*scr7;



{

char ccc;

mfs->fd_addr = (long) scr1;  /* most of the templates are in scr1 */
                             /* but FL and Fr are on scr2 */

mode = OR;  /* default setting of vrocopyfm mode */

  switch(Field)
    {
     case CF64: pxyarray[0] = 188; pxyarray[1] = 3; pxyarray[2] = 251; pxyarray[3] = 138; mode =REPLACE; break;
     case CL: pxyarray[0] = 36; pxyarray[1] = 3; pxyarray[2] = 67; pxyarray[3] = 138; break;
     case ML: pxyarray[0] = 69; pxyarray[1] = 3; pxyarray[2] = 100; pxyarray[3] = 138; break;
     case CF1: pxyarray[0] = 188; pxyarray[1] = 3; pxyarray[2] = 219; pxyarray[3] = 138; mode =REPLACE; break;
     case CF2: pxyarray[0] = 220; pxyarray[1] = 3; pxyarray[2] = 251; pxyarray[3] = 138; mode =REPLACE; break;
     case CF1_SPECIAL: pxyarray[0] = 188; pxyarray[1] = 3; pxyarray[2] = 203; pxyarray[3] = 138; mode =REPLACE;break;
     case CF2_SPECIAL: pxyarray[0] = 236; pxyarray[1] = 3; pxyarray[2] = 251; pxyarray[3] = 138; mode =REPLACE;break;    
     case ML_GATE: pxyarray[0] = 120; pxyarray[1] = 3; pxyarray[2] = 151; pxyarray[3] = 138; break;
     case MR_GATE: pxyarray[0] = 153; pxyarray[1] = 3; pxyarray[2] = 186; pxyarray[3] = 138; break;
     case FL_GATE: pxyarray[0] = 102; pxyarray[1] = 3; pxyarray[2] = 117; pxyarray[3] = 138; break;
   
     case MF3211: pxyarray[0] = 254; pxyarray[1] = 3; pxyarray[2] = 285; pxyarray[3] = 138; mode =REPLACE;break;
     case MF3212: pxyarray[0] = 286; pxyarray[1] = 3; pxyarray[2] = 317; pxyarray[3] = 138; mode =REPLACE;break;    
     case MF1611: pxyarray[0] = 1; pxyarray[1] = 3; pxyarray[2] = 16; pxyarray[3] = 138; mode =REPLACE;break;
     case MF1612: pxyarray[0] = 19; pxyarray[1] = 3; pxyarray[2] = 34; pxyarray[3] = 138; mode =REPLACE;break;    


      /* SCR2 PICS */
case CR: pxyarray[0] = 281; pxyarray[1] = 6; pxyarray[2] = 312; pxyarray[3] = 141; mfs->fd_addr = (long) scr2; break;
case MR: pxyarray[0] = 248; pxyarray[1] = 6; pxyarray[2] = 279; pxyarray[3] = 141; mfs->fd_addr = (long) scr2; break;
case FR: pxyarray[0] = 0; pxyarray[1] = 6; pxyarray[2] = 15; pxyarray[3] = 141; mfs->fd_addr = (long) scr2; break;
case FL: pxyarray[0] = 16; pxyarray[1] = 6; pxyarray[2] = 31; pxyarray[3] = 141; mfs->fd_addr = (long) scr2; break;
case FR_GATE: pxyarray[0] = 230; pxyarray[1] = 6; pxyarray[2] = 245; pxyarray[3] = 141; mfs->fd_addr = (long) scr2; break;
case REG_R4_FILL: pxyarray[0] = 140; pxyarray[1] = 6; pxyarray[2] = 203; pxyarray[3] = 141; mfs->fd_addr = (long) scr2; mode =REPLACE;break;
case REG_FAR_FILL: pxyarray[0] = 206; pxyarray[1] = 6; pxyarray[2] = 221; pxyarray[3] = 141; mfs->fd_addr = (long) scr2;mode =REPLACE; break;
case REG_MED_CLOSE_FILL: pxyarray[0] = 103; pxyarray[1] = 6; pxyarray[2] = 134; pxyarray[3] = 141; mfs->fd_addr = (long) scr2;mode =REPLACE; break;
case MF641: pxyarray[0] = 140; pxyarray[1] = 6; pxyarray[2] = 203; pxyarray[3] = 141; mfs->fd_addr = (long) scr2;mode =REPLACE; break;
case FF3211: pxyarray[0] = 34; pxyarray[1] = 6; pxyarray[2] = 65; pxyarray[3] = 141; mfs->fd_addr = (long) scr2;mode =REPLACE;break;
case FF3212: pxyarray[0] = 66; pxyarray[1] = 6; pxyarray[2] = 97; pxyarray[3] = 141; mfs->fd_addr = (long) scr2;mode =REPLACE;break;    

/*SCR3 PICS */

case FF1611: pxyarray[0] = 72; pxyarray[1] = 6; pxyarray[2] = 87; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;
case FF1612: pxyarray[0] = 89; pxyarray[1] = 6; pxyarray[2] = 104; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;    
case FF641: pxyarray[0] = 6; pxyarray[1] = 6; pxyarray[2] = 69; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;
case MF3221: pxyarray[0] = 106; pxyarray[1] = 6; pxyarray[2] = 137; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;    
case MF3222: pxyarray[0] = 139; pxyarray[1] = 6; pxyarray[2] = 170; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;
case MF1621: pxyarray[0] = 172; pxyarray[1] = 6; pxyarray[2] = 187; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;    
case MF1622: pxyarray[0] = 189; pxyarray[1] = 6; pxyarray[2] = 204; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;    
case MF642: pxyarray[0] = 206; pxyarray[1] = 6; pxyarray[2] = 269; pxyarray[3] = 141; mfs->fd_addr = (long) scr3;mode =REPLACE;break;    


/* SCREEN 4 PICS */
case FF3221: pxyarray[0] = 6; pxyarray[1] = 2; pxyarray[2] = 37; pxyarray[3] = 137; mfs->fd_addr = (long) scr4;mode =REPLACE;break;
case FF3222: pxyarray[0] = 38; pxyarray[1] = 2; pxyarray[2] = 69; pxyarray[3] = 137; mfs->fd_addr = (long) scr4;mode =REPLACE;break;
case FF1621: pxyarray[0] = 71; pxyarray[1] = 2; pxyarray[2] = 86; pxyarray[3] = 137; mfs->fd_addr = (long) scr4;mode =REPLACE;break;
case FF1622: pxyarray[0] = 88; pxyarray[1] = 2; pxyarray[2] = 103; pxyarray[3] = 137; mfs->fd_addr = (long) scr4;mode =REPLACE;break;
case FF642: pxyarray[0] = 105; pxyarray[1] = 2; pxyarray[2] = 168; pxyarray[3] = 137; mfs->fd_addr = (long) scr4;mode =REPLACE;break;



    }

}
/*****************************/

display(mfd,mfs,pxyarray,scr1,scr2,scr3,scr4,scr5,scr6,scr7,backgroundMFDB)
register MFDB *mfd,*mfs,*backgroundMFDB;
int pxyarray[8];
char *scr1,*scr2,*scr3,*scr4,*scr5,*scr6,*scr7;

{
int check_for_new_pal,
    facing = 0;
char tyee;


a_hidemouse();

  
    
  /* SET the mfs  MFDB dest!!! */
     Setscreen(back,screen,-1); /* back is logical, screen is physical */
     mfd->fd_addr = (long)back; /*set dest to be back screen*/

 
  /* erase the backscreen movement area */
   
         vsf_color(handle,0);
         vr_recfl(handle,rect1); 


                /* find the direction we're facing and display
                   approrate floor */

     /* set the dest for the floor */
     pxyarray[4]=7; pxyarray[5]=9;  /* x coords only, y does not change at all */
     pxyarray[6]=230; pxyarray[7]=144; 
switch(dir)
 {
   case 'N': floor=roomrec[room].N.floor; break;
   case 'S': floor=roomrec[room].S.floor; break;
   case 'E': floor=roomrec[room].E.floor; break;
   case 'W': floor=roomrec[room].W.floor; break;
 }

/* draw the floor first 
   if floor == 0 use floor1 (scr5) 
   if floor == 1 use floor2 (scr6)    */
   
   if(!floor)        /* that is, if floor == 0 */
     {
      mfs->fd_addr = (long)scr5;
      pxyarray[0] = 42; pxyarray[1]=22; pxyarray[2]=265; pxyarray[3]=157;            
     }
   if(floor)   /* that is, if == 1 */
     {
      mfs->fd_addr = (long)scr6;  /* holds floor 2 */
      pxyarray[0] = 47; pxyarray[1]=23; pxyarray[2]=270; pxyarray[3]=158;          
     }
     vro_cpyfm(handle,3,pxyarray,mfs,mfd);  /* display it */ 

    

/* reset starting destination coords */
    pxyarray[4] = 7;   /* Reset dest starting coords. for the 6 regions... */
                       /* just reset the x positions 4,6 cause y pos will stay same */
    pxyarray[6] = 38;
    pxyarray[5] = 9; pxyarray[7] = 144;  

 /* reset default mfdb source */
   mfs->fd_addr = (long)scr1;  /* holds all templates BUT FL,FR */

/* all drawing will be done in the BACK screen, then we'll swap 
   the back to the front */
            
  switch(dir)

    {
     case  'N' : {
        /* vrocopy the 7 regions
         pxyarray[4-7] is the dest.
         pxyarray[4] & pxyarray[6] need to be inc by delta 
         after each vrocopy is called for a region:
         region 1 = 32 pixels    
               r2 = 32  \
               r3 = 16   \ DELTA     
               r4 = 64   / 
               r5 = 16  /
               r6 = 32 /
               r7 = 32/
         pxyarray[5]& [7] are constant.
   
         */
   /**
      roomrec has an entry for each room
       1. to access that entry use the 'room' global variable
          as an index into roomrec[].<Filedx>
   **/
       /* region 1 */
       
       getcoord(roomrec[room].N.Field1,pxyarray,mfs,scr1,scr2,scr3,scr4); /* returns source pxyarray */
       if(roomrec[room].N.Field1 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
   
       /*region 2 */        
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].N.Field2,pxyarray,mfs,scr1,scr2,scr3,scr4); /* returns source pxyarray */
       if(roomrec[room].N.Field2 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
   
        /*region 3 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 16;  /* sets up region 3 coords */
       getcoord(roomrec[room].N.Field3,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].N.Field3 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 64+16;   /* dest */
       pxyarray[6] += 16+64;   /* sets up region 5 dest */
       getcoord(roomrec[room].N.Field5,pxyarray,mfs,scr1,scr2,scr3,scr4); /* returns source pxyarray */
       if(roomrec[room].N.Field5 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 16;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].N.Field6,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].N.Field6 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       /* region 7 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].N.Field7,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].N.Field7 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

        
        /*region 4 */
       pxyarray[4] -= 32+16+64;   /* dest */
       pxyarray[6] -= 32+32+16;   /* sets up region 4 dest */
       getcoord(roomrec[room].N.Field4,pxyarray,mfs,scr1,scr2,scr3,scr4); /* returns source pxyarray */
       if(roomrec[room].N.Field4 == FAR_GATE || roomrec[room].N.Field4 == CLOSE_GATE)
        show_gate(mfs,mfd,pxyarray,scr4,scr7,scr1,roomrec[room].N.Field4,back,backgroundMFDB);
       else if(roomrec[room].N.Field4 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
           

           break;
     }   
	
     case 'S' : {
            /* region 1 */
      
       getcoord(roomrec[room].S.Field1,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field1 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */


       /*region 2 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].S.Field2,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field2 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 3 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 16;
       getcoord(roomrec[room].S.Field3,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field3 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */       

        /*region 5 */
       pxyarray[4] += 64+16;   /* dest */
       pxyarray[6] += 16+64;
       getcoord(roomrec[room].S.Field5,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field5 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 16;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].S.Field6,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field6 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       /* region 7 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].S.Field7,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field7 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       
        /*region 4 */
       pxyarray[4] -= 32+16+64;   /* dest */
       pxyarray[6] -= 32+32+16;
       getcoord(roomrec[room].S.Field4,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].S.Field4 == FAR_GATE || roomrec[room].S.Field4 == CLOSE_GATE)
        show_gate(mfs,mfd,pxyarray,scr4,scr7,scr1,roomrec[room].S.Field4,back,backgroundMFDB);
 
      else if(roomrec[room].S.Field4 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */


          break;
                }   
     case 'E' : {
             /* region 1 */
      
       getcoord(roomrec[room].E.Field1,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field1 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       /*region 2 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].E.Field2,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field2 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 3 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 16;
       getcoord(roomrec[room].E.Field3,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field3 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 64+16;   /* dest */
       pxyarray[6] += 16+64;
       getcoord(roomrec[room].E.Field5,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field5 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 16;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].E.Field6,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field6 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
    
       /* region 7 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].E.Field7,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field7 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

      
        /*region 4 */
       pxyarray[4] -= 32+16+64;   /* dest */
       pxyarray[6] -= 32+32+16;
       getcoord(roomrec[room].E.Field4,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].E.Field4 == FAR_GATE || roomrec[room].E.Field4 == CLOSE_GATE)
        show_gate(mfs,mfd,pxyarray,scr4,scr7,scr1,roomrec[room].E.Field4,back,backgroundMFDB);

       else if(roomrec[room].E.Field4 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */


           break;
                }      
     case 'W' : 
      {
       /* region 1 */
      
       getcoord(roomrec[room].W.Field1,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field1 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       /*region 2 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].W.Field2,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field2 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

        /*region 3 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 16;
       getcoord(roomrec[room].W.Field3,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field3 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
        /*region 5 */
       pxyarray[4] += 64+16;   /* dest */
       pxyarray[6] += 16+64;
       getcoord(roomrec[room].W.Field5,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field5 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */
       
       /*region 6 */
       pxyarray[4] += 16;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].W.Field6,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field6 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

      /* region 7 */
       pxyarray[4] += 32;   /* dest */
       pxyarray[6] += 32;
       getcoord(roomrec[room].W.Field7,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field7 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       
        /*region 4 */
       pxyarray[4] -= 32+16+64;   /* dest */
       pxyarray[6] -= 32+32+16;
       getcoord(roomrec[room].W.Field4,pxyarray,mfs,scr1,scr2,scr3,scr4  ); /* returns source pxyarray */
       if(roomrec[room].W.Field4 == FAR_GATE || roomrec[room].W.Field4 == CLOSE_GATE)
        show_gate(mfs,mfd,pxyarray,scr4,scr7,scr1,roomrec[room].W.Field4,back,backgroundMFDB);
 
     else if(roomrec[room].W.Field4 != EMPTY) /* that is, if !Empty ..then copy */
       vro_cpyfm(handle,mode,pxyarray,mfs,mfd);  /* copy wholescreens */

       
       break;
       }

   }  /*end of switch*/  
 
  temp = screen;
  screen = back;
  back = temp;
  Vsync();
  Setscreen(screen,screen,-1);   /*now display it! */
  a_showmouse();

  /* color which key was pressed */
  display_pressed_key(15);   /* send it the white color */
  pause(8);
  display_pressed_key(0);    /* then send it the back color */
}

/********************/
display_pressed_key(colo)
int colo;
{
 int x99,y99;


     if(command == FOREWARD){ x99=276; y99=117;}
      else if(command == BACK){x99=276; y99=136;}
      else if(command == TURN_LEFT){x99=252; y99=117;}    
      else if(command == TURN_RIGHT){x99=299; y99=117; }  
      else if(command == LEFT){      x99=252; y99=136;  } 
      else if(command == RIGHT){     x99=299; y99=136;   }
      

  if(command !=NOTHING)
  {
    vsf_color(handle,colo);  /*seed fill color  */
    v_contourfill(handle,x99,y99,-1);
  } 
}


/***/
pause(time)
int time;
{
 int tsec;

   for(tsec=0;tsec<time;tsec++)
     Vsync();
}


/***************************/
/* display gate pic

    1. set pxyarray
    2. do copy
    3. reset pxyarray
*/

 show_gate(mfs,mfd,pxyarray,scr4,scr7,scr1,GATE_TYPE,back,backgroundMFDB)
 int GATE_TYPE;
 MFDB *mfs,*mfd,*backgroundMFDB;
 int pxyarray[];
 char *scr4,*scr7,*scr1,*back;
{
 int holdcoords[4];
 int h;

/*
  for(h=0;h<4;h++)
    holdcoords[h] = pxyarray[h+4];
*/
 
if(GATE_TYPE == FAR_GATE )
  {
    /* copy mask and template */
    mfs->fd_addr = (long) scr4;

   /* set new DEST coords */
    pxyarray[4] = 86; pxyarray[5] = 42; pxyarray[6] = 151; pxyarray[7] = 88; 
 
    pxyarray[0] = 170; pxyarray[1] = 2; pxyarray[2] = 235; pxyarray[3] = 48; 
    vro_cpyfm(handle,4,pxyarray,mfs,mfd);  /* copy wholescreens */
    pxyarray[0] = 237; pxyarray[1] = 2; pxyarray[2] = 302; pxyarray[3] = 48; 
    vro_cpyfm(handle,7,pxyarray,mfs,mfd);  /* copy wholescreens */
  
  } 
 else /* its a close gate */
  {
     mfs->fd_addr = (long) back;  /* lets copy what will be behind gate */
      /* source coords */
     pxyarray[0]=71; pxyarray[1]=31; pxyarray[2]=166; pxyarray[3]=112;    
     /* dest coords  */
     pxyarray[4]=71; pxyarray[5]=31; pxyarray[6]=166; pxyarray[7]=112;    
     /* do the copy: theMFDB is the SOURCE, backgroundMFDB is the dest*/
     vro_cpyfm(handle,REPLACE,pxyarray,mfs,backgroundMFDB);     


    /* copy mask and template */
    mfs->fd_addr = (long) scr7;

     pxyarray[4] = 71;                /* the destination coords */
     pxyarray[6] = 166;
     pxyarray[5] = 32; pxyarray[7]=112;

     pxyarray[0]=0; pxyarray[1]=0; pxyarray[2]=95; pxyarray[3]=79;
    vro_cpyfm(handle,4,pxyarray,mfs,mfd);  /* copy wholescreens */
    pxyarray[0]=96; pxyarray[1]=0; pxyarray[2]=190; pxyarray[3]=79;
    vro_cpyfm(handle,7,pxyarray,mfs,mfd);  /* copy wholescreens */  
  }



/* reset starting destination coords */

/*
 for(h=0;h<4;h++)
    pxyarray[h+4]=holdcoords[h];
*/

}
