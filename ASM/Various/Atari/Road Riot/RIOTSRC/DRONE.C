/*======================================================================*/
/*		TITLE:			Drone				*/
/*		Function:		drone Routines		*/
/*									*/
/*		First Edit:		4/6/89				*/
/*		Project #:		532xx				*/
/*		Programmer:		Dennis Harper			*/
/*					 	Dave Akers			*/
/*									*/
/*		COPYRIGHT 1990/1991 ATARI GAMES CORP.			*/
/*	  UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,		*/
/*	  PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR		*/
/*	THE ASSOCIATED AUDIOVISUAL WORK	IS STRICTLY PROHIBITED.		*/
/*	       		ALL RIGHTS RESERVED.				*/
/*									*/
/*----------------------------------------------------------------------*/

#ifdef ARIUM

#include	"prog/inc/rrdef.h"
#include	"prog/inc/comminc.h"
#include	"prog/inc/mobinc.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"
#include	"prog/inc/drninc.h"
#include	"prog/inc/gcode.h"
#include	"prog/inc/plrcase.h"
#include	"prog/inc/audio.h"

#else

#include	"inc:rrdef.h"
#include	"inc:comminc.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:drninc.h"
#include	"inc:gcode.h"
#include	"inc:plrcase.h"
#include	"inc:audio.h"

#endif



#define FLAGLEN  5
#define READFLG  1
#define WRTEFLG  3
#define DRONE_GBL 2
#define MAXUNITS 2
#define DCENTER 48 
#define CARLEN  0x200
#define LATIME 16 

typedef struct rampdata {
        BYTE waitpedal;
        BYTE slowpedal;
        BYTE medpedal;
        BYTE fastpedal;
        BYTE lostpedal;
		BYTE shotdelay;
        WORD minangle;
        WORD hillspeed;
        } RAMPDATA;

typedef struct diffdata {
        long infront;
        long  inback;
        long wayback;
        } DIFFDATA;

extern	MDTYPE	obj[];
extern	MDTYPE	*pp;
extern	long	viewx,world_len;
extern	WORD	plr_flag,button;
extern	short	*trkptr;
extern	short	*slope_ptr;
extern	short	left_bank,right_bank;
extern	BYTE	game;
extern  BYTE    solo;
extern	BYTE	comp;
extern  BYTE    difficulty;
extern  WORD    drroll[];
extern  WORD    endo[];
extern  CTLPKT  *ptable[];
extern  DRNPKT  *dtable[];
extern  WORD   mcpno;
extern  WORD  plyrno;
extern	WORD	strip_num;
extern  CARBLK  *plrcar;
extern  BYTE  active[];
extern  BYTE  world_laps;
extern 	WORD  world;
extern  WORD  frame;
extern  BYTE  wincnt;

extern MOBLK *dronetbl[];
extern MOBLK *dyellotbl[];
extern long startx[];
extern long starty[];
extern char plr_lap;
extern char plr_rank;
extern WORD gstate;
extern WORD statelist[];

	DRNBLK 	drones[MAX_DRONE];				/* array of drone blocks	*/
    DRNBLK  *drtable[MAX_DRONE] = {
                                 &drones[0], &drones[1], &drones[2],
                                 &drones[3], &drones[4], &drones[5],
                                 };
	BYTE	drone_cnt;
    DRNBLK  *drone_last;			/* index of drone in last place */
    BYTE    ramp;				/* difficulty level */
    short   c_average[MAX_STRIP] ; /* average of the next 8 curves ahead */
    long p0_yabs, p1_yabs;

/* convert picture number to angle */
#if 0

    short  sharp_agl[] = { 
                          5120, 5120, 4608, 4608,
                          4096, 4096, 2728, 2387,
                          2046, 2046, 1705, 1364,
                          1023, 1023,  682,  341,
                             0,    0, -341, -682,
                         -1023,-1023,-1364,-1705,
                         -2046,-2046,-2387,-2728,
                         -4096,-4096,-4608,-4608,
                         -5120,-5120
                         };


   /* table of increasing angles */ 
   short dirtable[] = { 0x080, 0x100, 0x180, 0x200,
                     0x280, 0x300, 0x380, 0x400,
                     0x480, 0x500, 0x580, 0x600,
                     0x680, 0x700, 0x780, 0x800,
                     0x880, 0x900, 0x980, 0xa00,
                     0x1000, 0x1000, 0x1000, 0x1000,
                     0x1000, 0x1000, 0x1000, 0x1000,
                     0x1000, 0x1000, 0x1000, 0x1000 };
#endif

    /* angles for turns */
    short  sharp_agl[] = { 
                          7680, 7680, 6912, 6912,
                          6144, 6144, 4092, 4092,
                          3069, 3069, 2557, 2046,
                          1534, 1534, 1024,  512,
                             0,    0, -512,-1024,
                         -1534,-1534,-2046,-2553,
                         -3069,-3069,-3580,-4092,
                         -6144,-6144,-6912,-6912,
                         -7680,-7680
                         };


   /* table of increasing angles */ 
   short dirtable[] = { 0x0100, 0x200, 0x300, 0x400,
                     0x500, 0x600, 0x700, 0x800,
                     0x900, 0xa00, 0xb00, 0xc00,
                     0xd00, 0xe00, 0xf00, 0x1000,
                     0x1100, 0x1200, 0x1380, 0x1400,
                     0x2000, 0x2000, 0x2000, 0x2000,
                     0x2000, 0x2000, 0x2000, 0x2000,
                     0x2000, 0x2000, 0x2000, 0x2000 };
/*        speed regions */

/*        pedal = wait pedal */
/*                           */
/*------- 0x8000 ahead-------*/
/*                           */
/*        pedal = slow pedal */
/*                           */
/*------- 0x0200 ahead-------*/
/*                           */
/*        pedal = medpedal   */
/*         player car		 */
/*                           */
/*------- 0x1000 behind------*/
/*                           */
/*        pedal = fastpedal  */
/*                           */
/*------- 0x8000 behind------*/
/*                           */
/*        pedal = lostpedal  */


/*        waitpedal, slowpedal, medpedal, fastpedal, lostpedal, */
/*									shotdelay, minangle, hillspeed		*/
    RAMPDATA ramptbl[ 16 ] = {

             { 0x15, 0x06, 0x1d, 0x24, 0x28, 0x20, 0x2000, 0x260 },
             { 0x15, 0x08, 0x1d, 0x24, 0x28, 0x20, 0x2000, 0x260 },
             { 0x15, 0x10, 0x1d, 0x24, 0x28, 0x20, 0x2000, 0x260 },
             { 0x15, 0x12, 0x1d, 0x24, 0x28, 0x20, 0x2000, 0x260 },

             { 0x15, 0x14, 0x1e, 0x24, 0x28, 0x20, 0x2000, 0x260 },
             { 0x15, 0x16, 0x1e, 0x24, 0x28, 0x20, 0x2000, 0x260 },
             { 0x15, 0x18, 0x1e, 0x24, 0x28, 0x20, 0x1800, 0x260 },
             { 0x15, 0x1b, 0x1e, 0x24, 0x28, 0x20, 0x0800, 0x260 },

             { 0x15, 0x1b, 0x1f, 0x24, 0x28, 0x20, 0, 0x260 },		/* 8 */
             { 0x17, 0x1c, 0x1f, 0x24, 0x28, 0x1e, 0x0400, 0x260 },
             { 0x19, 0x1d, 0x1f, 0x24, 0x28, 0x1c, 0x1000, 0x260 },
             { 0x1b, 0x1e, 0x1f, 0x24, 0x28, 0x1a, 0x0400, 0x270 },

             { 0x1d, 0x1f, 0x1f, 0x24, 0x28, 0x18, 0x1000, 0x270 },
             { 0x15, 0x1f, 0x1f, 0x24, 0x28, 0x14, 0x1000, 0x280 },
             { 0x16, 0x1f, 0x1f, 0x24, 0x28, 0x10, 0x0000, 0x290 },
             { 0x18, 0x1f, 0x20, 0x24, 0x28, 0x09, 0x0000, 0x300 }, 
             };

/* changes for difficulty levels = in front limit, inback limit, way back limit */
DIFFDATA difftbl[] = {
			{  0x200, -0x3800, -0xb000 },	/* 0 easiest */
			{  0x200, -0x3000, -0xa000 },
			{  0x200, -0x2800, -0x9000 },
			{  0x200, -0x2000, -0x8000 },   /* medium */

			{  0x200, -0x2000, -0x8000 },
			{  0x200, -0x1800, -0x4000 },
			{  0x200, -0x1000, -0x3000 },
			{  0x200, -0x0800, -0x2000 },
			{  0x200, -0x0100, -0x1000 },	/* 7 hardest */
			};


char ped_offset[ ] = { 0,0,1,-1 };
char delay_tbl[] = { 3,1,-4, 2, -7, 6, 4, -5 };
char initials[] = { "  DD..SS..AA..  " };

/*	Setup drones				*/
start_drones()
{
	MDTYPE	*op;
    short objno;
	int	j;
    CTLPKT *pptr;
    DRNBLK *drptr;
    DRNPKT *dpkt;

	for (j=0; j < 4; j++)
	  {
      drptr = drtable[j];
      if ( j == 0 )
           drptr->drn_next = drptr;
        else
           {
           drptr->drn_next = drtable[ j - 1 ];
           drone_last = drptr;
           }
	   if ( (drptr->op == 0) && 
           ( (j != plyrno ) ||
             (gstate == G_ATTRACT ) ) )
	    {					/* Setup drone	*/
	     objno = setobj(solo ? dyellotbl[j] : dronetbl[ j ],
                        startx[ j ],
                        starty[ j ],0,0,0);

	    drptr->op = op = &obj[ objno ];	/* Save obj ptr		*/
	    op->ad1 = DCENTER;				/* Set straight angle	*/
	    op->goff = j;					/* Save local index	*/

     	drptr->drn_type = plyrno;		/* assume boat is player controlled */
        drptr->drn_lap = 0;				/* no laps completed */
        drptr->drn_case = DPASS;		/* trying to pass the player */
        drptr->drn_cnt  = j * 5;		/* no time has passed */
        drptr->car_ptr = (CARBLK *)op->uptr;
        drptr->car_ptr->car_case = CC_DRIVE;
        drptr->drn_wins = 0;			/* no wins in accum */
        op->uptr = ( long ) drptr->car_ptr;

         if ( j == 3 ) 
            drptr->drn_agro = 1;
         else
            drptr->drn_agro = 0;
        drptr->drn_timer = random( LATIME ) + LATIME;

        if ( j == plyrno )
          {
          pp = op;
          plrcar = drptr->car_ptr;
		  plrcar->car_flag |= PLR_CAR;			/* Flag that we are the player	*/
          }

	    link_enemy(op);			/* Link into enemy list	*/
	    }
      }
        /* post setup - set up cars controlled by other systems */ 
        /* and init packet data */
        for ( j = 0 ; j < MAX_UNITS ; j++ )
          {
      	   if ( active[ j ] )
            {
        	pptr = ptable[j ] ;
            if ( j != plyrno ) 
               {
               drtable[ j ]->drn_type = REMOTE;		 /* Remote player */ 
               pptr->pgheight = drtable[j]->op->height;
               }
             else
               pptr->pgheight = pp->height;
		 	 pptr->pxpos = startx[ j ];
			 pptr->pypos = starty[ j ];
		 	 pptr->pzpos = 0;
		 	 pptr->pgad1 = DCENTER;
		 	 pptr->pgad2 = 1;
            drtable[ j + DRNOFFSET ]->drn_type = j;  /* and sidekick drone */
            drptr = drtable[j + DRNOFFSET];
            dpkt = dtable[ j ];						/* stuff packet with good data */
            dpkt->drxpos   =  drptr->op->xpos;
            dpkt->drypos   =  drptr->op->ypos;
            dpkt->drzpos   =  drptr->op->zpos;
            dpkt->drad1    =  drptr->op->ad1;
            dpkt->drad2    =  drptr->op->ad2;
            dpkt->drlap = drptr->drn_lap;
            dpkt->drheight  = drptr->op->height;
           }
         }
 return(0);
}

stop_drones()
  {
	int	j;
    DRNBLK *drptr;
	for (j=0; j < 4; j++)
	  {
      if ( j == plyrno ) continue;
      drptr = drtable[ j ];
      if ( drptr->op ) 	/* if this boat is active */
        {
        drptr->op->xspd = 0;
        drptr->op->yspd = 0;
        drptr->op->zspd = 0;
        }
      }
  }


/*	Setup drone				*/
set_drone(op,i)
MDTYPE	*op;
int	i;
{

	return(0);				/*  do nothing */
}


/*	Delete drone		*/
del_drone(op)
MDTYPE	*op;
{
DRNBLK *drptr;

    drptr = drtable[op->goff];
	drptr->op  = 0;		/* Clear object pointer	*/
	unlink_enemy(op);			/* Unlink from enemy list */

	--drone_cnt;				/* If no more left..	*/
}



/*	Clear drones		*/
clr_drone()
{
	int	j;
    DRNBLK *drptr;

	for (j=0; j < MAX_DRONE; j++)
      {
      drptr = drtable[j];
	  drptr->op  = 0;		/* Clear object pointer	*/
      if ( drptr->car_ptr)			/* give up the car */
         {
         drptr->car_ptr->op = 0;
         drptr->car_ptr = 0;
         }
      }

	drone_cnt = 0;
}



/*	drone intelligence 	*/
do_drone()
{
	long	dy;
	int	j;
    int segno;
    short angle;
    short pedal;
    short dir;
    short tidx;
    short dz;
    short curve_avg;
    short median;
    short p1x;
    short max_x;
    short tmp;
    short nodrones;
    short mina;
    short endgame;
    long max_yabs;
    long ydif;
    short max_wins;

    DRNPKT *dpkt;
    DRNBLK *drptr, *d2ptr, *d3ptr, *d4ptr; 
    RAMPDATA *rmptr;
    DIFFDATA *diffptr;

    /* figure out yabs for players and drones */
      p0_yabs = max_yabs = (world_len * plr_lap) + pp->ypos;
      max_x = pp->xpos;
      max_wins = wincnt;
      p1_yabs = p0_yabs;
      p1x = pp->xpos;
      nodrones = 1;					/* assume no drones to control */
	  for (j=0; j < MAX_DRONE; j++)
	    {
        drptr = drtable[j];
        if ( j == plyrno )
          {
          drptr->drn_yabs = p0_yabs;
          drptr->car_ptr = plrcar;
          }
        else if ( drptr->op )
           {
           drptr->drn_yabs = (world_len * drptr->drn_lap) + drptr->op->ypos;
      	   if ( drptr->drn_type == REMOTE )  /* if this drone is controlled remotely */
              {
              p1_yabs = drptr->drn_yabs;
              p1x = drptr->op->xpos;
              if  (p1_yabs > max_yabs) 
                 {
                 max_yabs = p1_yabs;
                 max_x = p1x;
                 max_wins = drptr->drn_wins;
                 }
              }
           else
              nodrones = 0;
           }
        }

    if  (nodrones)
		  return;

   if ( ramp < 7 )
      {
       if ( max_yabs >  
          ( ( world_laps * world_len) - ( 10 * STRIP_SIZE) ) )
            endgame = TRUE;
         else
            endgame = FALSE;
       }
    else
      {
       if ( max_yabs >  
          ( ( world_laps * world_len) - ( 6 * STRIP_SIZE) ) )
            endgame = TRUE;
         else
            endgame = FALSE;
       }

    /* make one pass at sorting the list of drones by yabs */
    drptr =  drone_last;
    d2ptr =  drptr->drn_next;
    d3ptr =  d2ptr->drn_next;
    d4ptr =  d3ptr->drn_next;
    if ( drptr->drn_yabs > d2ptr->drn_yabs )	/* if order is wrong */
       {
       d2ptr->drn_next = drptr;				/* old last is now next to last */
       drone_last = d2ptr;				/* new last */
       drptr->drn_next = d3ptr;			/* point to next index in chain */
       }
    else
      {
       if ( d2ptr->drn_yabs > d3ptr->drn_yabs )	/* if order is wrong */
          {
          /* exchange 2 and 3 */
          d3ptr->drn_next = d2ptr;			/*  */
          drptr->drn_next = d3ptr;		    /*  */
          d2ptr->drn_next = d4ptr;			/*  */
          }
       else
         {
          if ( d3ptr->drn_yabs > d4ptr->drn_yabs )	/* if order is wrong */
             {
             /* exchange 3 and 4 */
             d4ptr->drn_next = d3ptr;			/*  */
             d2ptr->drn_next = d4ptr;		    /*  */
             d3ptr->drn_next = d3ptr;			/*  */
             }
         }
     }

      /* point to ramping data table */
      rmptr = &ramptbl [ ramp & 0x0f ];
	  diffptr = &difftbl [ difficulty ];
	  for (j=0; j < MAX_DRONE; j++ )
	    {
        drptr = drtable[j];
        if ( drptr->op )
	       {
      	   if ( drptr->drn_type != plyrno )  /* if this drone is controlled remotely */
              continue;						/* skip it */
           /* drone smarts */
           segno = drptr->op->ypos >> 12;		/* get number of segment drone is on */
           angle = trkptr[ segno ];				/* get curve of this segment */

            curve_avg = c_average[ segno ];		/* and get average for the next 8 curves */

            /* part 1 - decide what part of the road to drive on */
            if ( ramp < 5 )
              {
              /* find desired lane */
              ydif = p0_yabs - drptr->drn_yabs;
              /* are we anywhere near the player ? */
                 /* if close, try to pass player */
                 if ( ( ydif > CARLEN ) && ( ydif < 0x1000 ) ) 
                   {
                   if ( pp->xpos < 0 ) median = 0x400;
                   else median = -0x400;
                   }
                else	/* try other player */
                  {
                  ydif = p1_yabs - drptr->drn_yabs;
                    if ( ( ydif > CARLEN ) && ( ydif < 0x1000 ) ) 
                        {
                        if (  p1x < 0 ) median = 0x400;
                        else median = -0x400;
                        }
                    else 
                      {
                      if ( curve_avg == 0 ) median = 0;
                      else if ( curve_avg > 0 ) median = -0x300;
                      else median = 0x300;
                      }
                  }
              }
            else	/* try to pass car in front if us */
              {
              if ( drptr->drn_case == DBLAST)
                 {
                 median = max_x;
                 }
              else
                 {
                 ydif = drptr->drn_next->drn_yabs - drptr->drn_yabs; 

                 if ( ( drptr->drn_next != drptr ) &&
                      ( ydif < 0x2000 ) && ( ydif > -0x2000 ) ) 
                      {
                      if ( drptr->drn_next->op->xpos < 0 ) 
                           median = drptr->drn_next->op->xpos + 0x500;
                      else
                           median = drptr->drn_next->op->xpos - 0x500;
                      }
                    else 
                     {
                     if ( curve_avg == 0 ) median = 0;
                     else if ( curve_avg > 0 ) median = -0x400;
                     else median = 0x400;
                     }
                 }
              }

          /* part 2 - find desired direction and target speed */
          /*          ( max speed = 0x18 * pedal - 0x60 ) */
          if ( endgame )
             {
             dir = sharp_agl[ ( angle >> 1 ) + 16 ];
             if ( ( ramp > 8) || (wincnt > 2) )
             	drptr->drn_tspd  = 0x0380 + ( 0x10 * j );
             else
                drptr->drn_tspd = 0x0200;
             }
          else if ( drptr->drn_case == DPASS )
                {
                if ( drptr->drn_cnt > ( 5 * 32 ) )
                   {
                   if ( (gstate == G_ATTRACT) ||
                        (world == 0 ) )
                      drptr->drn_cnt = 0;
                   else
                   if ( abs(max_yabs - drptr->drn_yabs) < 0x0400 )  
                       {
                       drptr->drn_case = DHOVER0;
                       drptr->drn_cnt = 0;
                       }
                   else
                       drptr->drn_cnt -= 32;
                   }
                else
                   drptr->drn_cnt++ ;

                tidx = (drptr->op->ypos + 0x123 ) >> 12;
                dz = slope_ptr[ tidx ] - 
                     slope_ptr[ ( tidx == strip_num ) ? 0 : ( tidx +1) ];
                if ( dz < -0x30 )
                  {
                  drptr->drn_tspd = rmptr->hillspeed + ( 0x10 * j );
                  dir = sharp_agl[ ( curve_avg >> 1 ) + 16 ];
                  }
                else if ( curve_avg == 0 )	/* was if ( angle == 0 ) */
                    {
        	        drptr->drn_tspd = 0x0400 + ( 0x10 * j );
                    dir = 0;
                    }
                else
                   {
                   drptr->drn_tspd  = 0x0360 + ( 0x10 * j );
                   dir = sharp_agl[ ( angle >> 2) + ( curve_avg >> 2 ) + 16 ];
                   }
                }
          else 				/* should be  DHOVER0 */
                if ( drptr->drn_case == DHOVER0 )
                {
                dir = 0;
           		ydif = max_yabs - drptr->drn_yabs;
                if ( (abs( ydif) > 0x1000 ) ||
                     (drptr->drn_cnt > ( 5 * 32 ) ) )
                   {
                   drptr->drn_case = DPASS;
                   drptr->drn_cnt = 0;
                   }
                else
                  {
           		  drptr->drn_tspd = 0x270 + ( ydif >> 4 ); 
                  drptr->drn_cnt++ ;
                  if  ( (drptr->drn_agro) && 
                       (abs( ydif) < CARLEN )  &&
                       (abs( max_x) < 0x800 ) )
                      {
                      if ( max_x > drptr->op->xpos )
                         median = 0x1000;
                      else
                        median = -0x1000;
                      }
                  }
                }
           else  		/* DBLAST */
                {
#if 1
                dir = 0;
#else
                dir = drptr->drn_next->car_ptr->car_dir;
#endif
           		ydif = max_yabs - drptr->drn_yabs;
                if ( ( ydif > 0x3000 ) ||
                     ( ydif < 0x500 ) ||
                     (drptr->drn_cnt > ( 5 * 32 ) ) )
                   {
                   drptr->drn_case = DPASS;
                   drptr->drn_cnt = 0;
                   }
                else
                  {
           		  drptr->drn_tspd =  drptr->drn_next->car_ptr->car_yspd + 
                                    (drptr->drn_next->car_ptr->car_yspd >> 4); 
                  drptr->drn_cnt++ ;
                  }
                }


        mina = 0;

        /* part 3 - compute accelation based on target speed */
        /*          and position  relative to the player */
        if ( world == 0 )
           {
           if ( p1_yabs < p0_yabs )
           	   ydif = drptr->drn_yabs - p1_yabs;
           else
           	   ydif = drptr->drn_yabs - p0_yabs;
               
           /* if in front of any player */
           if ( ydif > 0x0200 )
              pedal = 0x0a;
           else
	       if (drptr->car_ptr->car_spd < drptr->drn_tspd)	/* If target speed not reached	*/
              {
              if (( ydif ) < -0x2000)
               {
               if (( ydif ) < -0x8000)
                 {
                 pedal = rmptr->lostpedal + ped_offset[j];
                 drptr->car_ptr->tire_skid = TIRE2;
                 }
               else
                 {
                 pedal = rmptr->fastpedal + ped_offset[j];
                 drptr->car_ptr->tire_skid = TIRE0;
                 }
               }
            else
               {
               drptr->car_ptr->tire_skid = TIRE0;
               pedal = rmptr->medpedal + ped_offset[j];
               }
              }
            else
	          pedal = 0;
           }
        else
	    if (drptr->car_ptr->car_spd < drptr->drn_tspd)	/* If target speed not reached	*/
            {
            if (( drptr->drn_yabs - max_yabs ) > diffptr->infront)
               {
               mina = rmptr->minangle;
               drptr->car_ptr->tire_skid = TIRE0;
               if (( drptr->drn_yabs - max_yabs ) > 0x8000)
                 {
                 pedal = rmptr->waitpedal;
#if 0
                 if ( drptr->drn_lap == (world_laps - 1 ))
                    pedal += 2;		/* extra 10 % for last lap */
#endif
                 }
               else
                 pedal = rmptr->slowpedal;
               }
            else
            if (( drptr->drn_yabs - max_yabs ) < diffptr->inback)
               {
               if (( drptr->drn_yabs - max_yabs ) < diffptr->wayback)
                 {
                 pedal = rmptr->lostpedal;
                 drptr->car_ptr->tire_skid = TIRE2;
                 }
               else
                 {
                 pedal = rmptr->fastpedal;
                 drptr->car_ptr->tire_skid = TIRE0;
                 }
               }
            else
               {
               drptr->car_ptr->tire_skid = TIRE0;
               pedal = rmptr->medpedal;
               }
            pedal += ped_offset[j];
            }
        else if (drptr->car_ptr->car_spd > drptr->drn_tspd)	/* If target speed exceeded 	*/
	        pedal = 0;


         car_speed( drptr->car_ptr, pedal );
         
              /* part 4 - combined desired lane and desired direction */
              /*          to find steering angle for car  */
              if ( drptr->op->xpos > (median + 0xff) )
                 {
                 tmp = dirtable[ (drptr->op->xpos - median) >> 8 ];
                 if ( tmp < mina ) 
					 tmp = ( ramp < 13 ) ? mina : 0 ;
                 dir -= tmp;
                 }
              else if ( drptr->op->xpos < (median - 0xff ) )
                 {
                 tmp = dirtable[ (median - drptr->op->xpos ) >> 8 ];
                 if ( tmp < mina ) 
					 tmp = ( ramp < 13 ) ? mina : 0 ;
                 dir += tmp;
                 }

         car_steer( drptr->car_ptr, dir, angle );
         if ( car_pos( drptr->car_ptr, angle ))
              drptr->drn_lap += 1;
     
          /* car shooting */
          if ( drptr->drn_timer == 0 )
             {
             if ( drptr->drn_case == DBLAST)
             	drptr->drn_timer = rmptr->shotdelay - 
                                   (rmptr->shotdelay >> 1);
             else
                {
             	drptr->drn_timer = rmptr->shotdelay;
                if ( drptr->drn_timer > 0x1c)
             	    drptr->drn_timer +=  delay_tbl [ frame & 0x07 ];
                }
             if ( (drptr->drn_next->drn_yabs == max_yabs) &&
                  ( ((max_yabs - drptr->drn_yabs ) > 0x0600 ) &&
                    ((max_yabs - drptr->drn_yabs ) < 0x2400 ) ) )
                {
          		set_laser( drptr->car_ptr );
			    com_wrt(S_ENGUN);
                if ( (max_wins > 1 ) && 
                     ( ramp > 7 ) &&
                     (drptr->drn_case == DPASS) && 
                     (drptr->drn_cnt > ( 2 * 32 ) ) )
                   {
                   if ( (comp == 0 ) && (plr_rank < 3 ) )
                      {
                       drptr->drn_case = DBLAST;
                       drptr->drn_cnt = 0;
                       }
                   }
                }
             }
          else
             drptr->drn_timer-- ;
          
          /* save  position for drones in the packet */
         if ( j == ( plyrno + DRNOFFSET ) )
            {
            dpkt = dtable[ plyrno ];
            dpkt->drxpos   =  drptr->op->xpos;
            dpkt->drypos   =  drptr->op->ypos;
            dpkt->drzpos   =  drptr->op->zpos;
            dpkt->drad1    =  drptr->op->ad1;
            dpkt->drad2    =  drptr->op->ad2;
            dpkt->drlap = drptr->drn_lap;
            dpkt->drheight  = drptr->op->height;
            if ( drptr->car_ptr->car_case == CC_ROLL )
         	  	dpkt->drstate = DROLL;
             else
            if ( drptr->car_ptr->car_case == CC_ENDO )
         	  	dpkt->drstate = DENDO;
           else
            if ( drptr->car_ptr->car_case == CC_XPLO )
         	  	dpkt->drstate = DXPLO;
           else
               dpkt->drstate = 0;
            }
           }
      }
 }

plot_drone()
{
	int	j;

    CTLPKT *pptr;
    DRNPKT *dpkt;
    DRNBLK *drptr; 

	if ( (plr_flag & PLR_START) == 0)  	/* If player not started, exit	*/
		  return;

	for (j=0 ; j < MAX_DRONE; j++)

	  {
      drptr= drtable[j];
	  if (drptr->op)				/* If active drone	*/
	    {

        if ( drptr->drn_type == REMOTE )       /* if this boat is controlled remotely */
           {
               pptr = ptable[ j  ] ;
               drptr->op->xpos = pptr->pxpos;
               drptr->car_ptr->lasty = drptr->op->ypos;
               drptr->op->ypos = pptr->pypos;
               drptr->op->zpos = pptr->pzpos;
               drptr->op->height = pptr->pgheight;
               drptr->drn_lap = pptr->plap;
               drptr->drn_wins = pptr->pwincnt;
               drptr->car_ptr->car_ztrg = pptr->pgheight;
               drptr->car_ptr->car_xspd = pptr->pxspd;
               drptr->car_ptr->car_yspd = pptr->pyspd;

               /* if player was in endo and quit */
               if ( ( drptr->drn_state == DENDO ) &&
                    ( pptr->pstate != DENDO ) )
                     end_endo( drptr->car_ptr);

               /* if rolling  */
               if ( pptr->pstate == DROLL )
                  {
                  if ( pptr->pstate != drptr->drn_state ) 
                     {
                     start_roll( drptr->car_ptr );
                     }
                  }
               else if ( pptr->pstate == DENDO )
                  {
                  if ( pptr->pstate != drptr->drn_state ) 
                     {
                     start_endo( drptr->car_ptr, 0, 0 );
                     }
                  }
               else if ( pptr->pstate == DXPLO )
                  {
                  if ( pptr->pstate != drptr->drn_state ) 
                     {
                     start_xplo( drptr->car_ptr );
                     }
                  }
               else	/* not a roll or endo */
                 {
                  drptr->car_ptr->car_case = CC_DRIVE;
                  drptr->op->ad2 = pptr->pgad2;
                  store_angle( drptr->car_ptr, pptr->pgad1 );
                  drptr->op->ad4 = 1;	/* trigger animation */
                  }
               drptr->drn_state = pptr->pstate;
               move_shadow( drptr->car_ptr );
            continue;
           }
           if ( drptr->drn_type == plyrno )  continue;   /* our drone, don't fetch */
           /* get position for drones from the packet */
              dpkt = dtable[ drptr->drn_type ];
              drptr->op->xpos = dpkt->drxpos; 
              drptr->car_ptr->lasty = drptr->op->ypos;
              drptr->op->ypos = dpkt->drypos;
              drptr->op->zpos = dpkt->drzpos;
              drptr->op->height = dpkt->drheight;
              drptr->drn_lap = dpkt->drlap;
              drptr->car_ptr->car_ztrg = dpkt->drheight;
              drptr->car_ptr->car_xspd = dpkt->drxspd;
              drptr->car_ptr->car_yspd = dpkt->dryspd;

               /* if player was in endo and quit */
               if ( ( drptr->drn_state == DENDO ) &&
                    ( dpkt->drstate != DENDO ) )
                     end_endo( drptr->car_ptr);

               if ( dpkt->drstate == DROLL )
                  {
                  if ( dpkt->drstate != drptr->drn_state ) 
                     {
                     start_roll( drptr->car_ptr );
                     }
                  }
               else if ( dpkt->drstate == DENDO )
                  {
                  if ( dpkt->drstate != drptr->drn_state ) 
                     {
                     start_endo( drptr->car_ptr, 0, 0 );
                     }
                  }
               else if ( dpkt->drstate == DXPLO )
                  {
                  if ( dpkt->drstate != drptr->drn_state ) 
                     {
                     start_xplo( drptr->car_ptr );
                     }
                  }
               else
                 {
                 drptr->car_ptr->car_case = CC_DRIVE;
                 drptr->op->ad2 = dpkt->drad2;
                 store_angle( drptr->car_ptr, dpkt->drad1 );
                 drptr->op->ad4 = 1;	/* trigger animation */
                 }
               drptr->drn_state = dpkt->drstate;
               move_shadow( drptr->car_ptr );
              }
	    }
}


