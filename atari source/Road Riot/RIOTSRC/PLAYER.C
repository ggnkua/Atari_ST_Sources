/*======================================================================*/
/*		TITLE:			PLAYER				*/
/*		Function:		Player associated routines	*/
/*									*/
/*		First Edit:		11/01/88			*/
/*		Project #:		532xx				*/
/*		Programmer:		Dennis Harper			*/
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
#include	"prog/inc/mobinc.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"
#include	"prog/inc/drninc.h"
#include	"prog/inc/buttons.h"
#include	"prog/inc/hrdwmap.h"
#include	"prog/inc/message.h"
#include	"prog/inc/plrcase.h"
#include	"prog/inc/gcode.h"
#include	"prog/inc/audio.h"
#include	"prog/inc/comminc.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:drninc.h"
#include	"inc:hrdwmap.h"
#include	"inc:buttons.h"
#include	"inc:message.h"
#include	"inc:plrcase.h"
#include	"inc:gcode.h"
#include	"inc:audio.h"
#include	"inc:comminc.h"

#endif

#define PHASE1		1

#define	GRAVITY		0x18
#define	MAX_YSPD	0x400
#define	ENG_MAX		0x288
#define	PLRGBL		0

#define	ON_ROAD		0
#define	SHOULDER	1
#define	DIRT		2

#define	SKID		0x8000
#define	HILL		0x4000
#define	OFFRD		0x2000
#define	GRASS		0x1000
#define	CHEER		0x0800

#define	MAX_PASS	(STRIP_SIZE * 2)
#define	PASS_TICK	(MAX_PASS / 25)

#define	MOTOR_DELAY	-0x10

extern	PFI	setup;
extern	MDTYPE	obj[];
extern	MOBLK	rat0blk,rat1blk,pxplblk,fingblk;
extern	DRNBLK  *drtable[];
extern	ulong	frgdsp,bckdsp,coldsp;
extern	ulong   shakes;
extern	long	viewx,viewy,world_len,p0_yabs;
extern	WORD	button,frame,gstate,nstate,world,wave,leg_num;
extern	WORD	leg;
extern  WORD    game_opt;
extern	short	steer_tbl[];
extern	short	wld_edge,z_top;
extern	short	viewy_spd,viewx_spd;
extern	short	turn_cur;
extern	BYTE    world_laps;
extern	BYTE	acc_case,xlock;
extern	BYTE	mk_mode,difficulty,motor_bits;
extern	BYTE	ndl_idx;
extern	BYTE	comp;
extern	char	last_rank;
extern  CTLPKT  *ptable[];		/* pointers to communication packets */
extern short    plyrno;		    /* which machine are we ? */
extern short    thumpcnt;		/* count of thumps */

	MDTYPE	*pp;			/* Player object pointer	*/
	MDTYPE	*pxpl_ptr;		/* Player explosion		*/
	CARBLK	*plrcar;		/* Player's car control block pointer	*/
	ulong	pass_dist;		/* Car pass distance		*/
	long	old_ypos;		/* Last player y position	*/
	WORD	plr_flag;		/* Flag word			*/
	WORD	snd_flag;		/* Player sound flags		*/
	short	plr_zspd;
	short	plr_zoff;
	short	plr_yacc;		/* Y acceleration		*/
	short	friction;		/* Current boat friction	*/
	short	old_yspd;		/* Last yspeed			*/
	short	old_xpos;		/* Last xpos			*/
	BYTE	plr_dir;		/* Player direction (0-31) 	*/
	BYTE	plr_case;		/* Player case index		*/
	BYTE	plr_next;		/* Next Player case 		*/
	BYTE	plr_idx;		/* Player object index save	*/
	BYTE	in_air;			/* In air flag			*/
	BYTE	off_road;		/* Off road sound case		*/
	BYTE	shake_req;		/* Shake control request	*/
	BYTE	thump_req;		/* Thump my butt request	*/
	BYTE	plr_rpm;		/* Engine RPM sound index	*/
	BYTE	skid_snd;		/* Skid sound			*/
	BYTE	fskid_snd;		/* Fade Skid sound		*/
	BYTE	kskid_snd;		/* Kill Skid sound		*/
	BYTE	pass_case;		/* Car pass case switch		*/
	BYTE	fingirl_on;		/* Finish girl on flag		*/
	BYTE	gmove;			/* Great move flag		*/
	char	motor_tmr;		/* Motor on timer		*/
	char	boost_tmr;		/* Boost timer			*/
	char	start_tmr;		/* Startup timer		*/
	char    plr_lap;		/* number of laps player has completed */
	char    plr_rank;		/* players rank in the rat race */
    char    old_rank;		/* rank from previous race  */
	char	last_tmr;		/* Last lap message timer	*/

	TRIAD	skid_tbl[]={S_ADSKID,S_FSKID,S_KSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_ADSKID,S_FSKID,S_KSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_ADSKID,S_FSKID,S_KSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID,
			    S_DRTSKID,S_FDRTSKID,S_KDRTSKID};

long startx[ ] = { 1024, -1024, 1024, -1024 };
long starty [ ] = { PLR_YMIN, PLR_YMIN, PLR_YMIN + 0x400 , PLR_YMIN  + 0x400 }; 

static	MT2 	lastmsg = { 12, 08, "LAST LAP!", 0 };


/*	Init player first time			*/
init_player()
{
	set_player();					/* Setup player		*/
	bckdsp |= B_SCORE | B_LAP;			/* Display stuff	*/
}



/*	Init player at wave start			*/
res_player()
{
	set_player();					/* Setup player		*/
	bckdsp |= B_SCORE | B_LAP;			/* Display stuff	*/
}


set_player()
{
	clr_player();
							/* Setup player		*/
	plr_idx = setobj(plyrno ? &rat1blk : &rat0blk,startx[ plyrno ],
                             starty[ plyrno ] + viewy,0,0,0);
	pp = &obj[plr_idx];
	pp->ad1 = 0x30;

	acc_case = 0;					/* Lock camera accel	*/
	xlock = 2;					/* Lock window	*/

	start_engine();					/* Gentlemen, start your engines!	*/

	plrcar = (CARBLK *)pp->uptr;			/* Get Car control block pointer	*/
	plrcar->car_flag |= PLR_CAR;			/* Flag that we are the player	*/
	plr_case = P_START;				/* Wait for the starting gun */
	plr_next = P_START;				/* Set next state		*/
	plr_lap = 0;					/* no laps completed */
	plr_rank = 0;					/* no rank to display  */
	last_rank = 0;
	viewx = pp->xpos;				/* center the player */

	init_plrsnd();					/* Init player sounds	*/
	link_enemy(pp);					/* Link into laser collision list	*/
}


/*	Setup test rat for debug and registration	*/

set_trat(op)
MDTYPE	*op;
{
	pp = op;					/* Set object pointer		*/
	plrcar = (CARBLK *)pp->uptr;			/* Init car control block	*/
	return(0);
}



/*	Delete player and wake		*/
del_player()
{
	del_car(plrcar);			/* Clear car block	*/
	plrcar = 0;

	delobj(pp);				/* Delete the player	*/
	pp = 0;
}



/*	Clear player variables		*/
clr_player()
{
	plr_yacc = 0;
	plr_flag = 0;
	pp = 0;				/* Clear pointers		*/

	if ( plrcar )
	{
	plrcar->op = 0;
	plrcar = 0;
	}

	plr_dir = 12;			/* Center picture	*/
	ndl_idx = 0;			/* Clear needle picture	*/
}



/*	Do all player routines			*/
do_player()
{
	old_yspd = plrcar->car_yspd;			/* Save speed		*/

	switch (plr_case)
	  {
	  case P_DEAD:
	    break;

	  case P_END:
	    get_angle();				/* Get new player angle	*/
	    engine(plrcar->car_rpm);			/* Engine sounds	*/
	    break;

	  case P_START:
	    if ( gstate == G_PLAY1 )
              {
	      plr_case = P_DRIVE;				/* Startup sequence enable	*/
	      plr_next = P_DRIVE;				/* Set next state		*/
	      plr_flag |= PLR_START;				/* Flag player started		*/
              }
            break;

	  case P_DRIVE:
	    get_angle();				/* Get new player angle	*/
	    plr_speed();				/* Get player's speed	*/
	    new_pos();					/* Get new position	*/
	    engine(plrcar->car_rpm);			/* Engine sounds	*/
	    break;

	  case P_XPLO:					/* Player is exploding	*/
	    send_pos();					/* Update player packet	*/

	    if (plrcar->car_case == CC_BURNOUT)		/* If over...		*/
	      {
	      acc_case = 0;				/* Normal scrolling	*/
	      start_engine();				/* Gentlemen, start your engines!	*/
	      plr_case = P_DRIVE;
	      }
	  }

	plr_sounds();					/* Do player sounds	*/
	speedo();					/* Do speedometer	*/
	rear_view();					/* Do rear view mirror	*/
}



/*	Get player's speed					*/
plr_speed()
{
	BYTE	pot;

	pot = PEDAL ^ 0x1F;				/* Reverse pot		*/
	plrcar->tire_skid = TIRE0;

	switch (plr_rank)
	 {
	 case 1:
	 default:
	   break;

	 case 2:
	   if (comp)
	     pot += pot >> 3;				/* Add 1/8 more		*/
	   break;

	  case 3:
	    pot += (pot >> 3) + (pot >> 4);		/* Add 3/16 more	*/
	    plrcar->tire_skid = TIRE1;
	    break;

	  case 4:
	    pot += pot >> 2;				/* Add 1/4 more		*/
	    plrcar->tire_skid = TIRE2;
	    break;
	  }

	car_speed(plrcar,pot);				/* Car call driver	*/
}



/*	Get new player angle		*/
/*	Entry: pot = 0-3F		*/
get_angle()
{
	BYTE	pot;

	pot = WHEEL ^ 0x3F;					/* Reverse pot			*/
	car_steer(plrcar,steer_tbl[pot],turn_cur);		/* Steer the car		*/
	plr_dir = pp->ad1;
}




new_pos()
/*	Get new player position			*/
{
	int	wrap;
   	CTLPKT *pptr;

	old_ypos = pp->ypos;				/* Save old ypos		*/
	wrap = car_pos(plrcar,turn_cur);		/* Get new position		*/
	plr_yacc = plrcar->car_yspd - old_yspd;		/* Get y acceleration		*/
							/* If stopped..			*/
	if ((plrcar->car_case == CC_DRIVE) && (plrcar->car_spd < 0x10) && (ABS(plrcar->car_dir) < 0x800))
	  set_burn(plrcar);				/* Setup burnout		*/

	if (wrap)					/* If player wrapped around	*/
	  {
	  ++plr_lap;					/* Next lap			*/
	  bckdsp |= B_LAP;				/* Display lap count		*/
	  snd_flag &= ~CHEER;				/* Enable next cheer		*/
	  lap_clr();					/* Clear lap announements	*/

	  if (plr_rank == 1)				/* If first place...		*/
	    add_score(2000);				/* Give 2000 point		*/

	  if ((world_laps - plr_lap) == 1)		/* If last lap...		*/
	    {
	    com_wrt(S_DRIVMUS);				/* Turn on music		*/
	    last_tmr = 0x41;				/* Set timer			*/
	    bckdsp |= B_LAST;				/* Last lap message		*/
	    }
	  }

	if ((old_ypos ^ pp->ypos) & 0x400)		/* If gone 0x400		*/
	  add_score(1);					/* Give 1 point			*/

	if (((world_laps - plr_lap) == 1) &&	/* If last lap...		*/
	   (pp->ypos > world_len - (STRIP_SIZE * 11)) &&
	   (fingirl_on == FALSE))			/* And finish girl NOT on	*/
	  {
	  if (plyrno)
	    setobj(&fingblk,-0xE00,0xB00,0,0,MO_FLIP);
	  else
	    setobj(&fingblk,0xE00,0xB00,0,0,0);

	  fingirl_on = TRUE;
	  }

	send_pos();					/* Update packet		*/
}


send_pos()
/*	Update new player position			*/
{
   	CTLPKT *pptr;

pptr = ptable[ plyrno  ];
pptr->pxpos = pp->xpos;
pptr->pypos = pp->ypos;
pptr->pzpos = pp->zpos;
pptr->pgad1 = pp->ad1;
pptr->pgad2 = pp->ad2;
pptr->plap = plr_lap;
pptr->pgheight = pp->height;
pptr->pxspd = plrcar->car_xspd;
pptr->pyspd = plrcar->car_yspd;

	if ( plrcar->car_case == CC_ROLL )
	     pptr->pstate = DROLL;
	else
	  if ( plrcar->car_case == CC_ENDO )
	     pptr->pstate = DENDO;
	  else
	    if ( plrcar->car_case == CC_XPLO )
	      pptr->pstate = DXPLO;
	    else
	      pptr->pstate = 0;

}


/*	Make engine sounds					*/
engine(rpm)
WORD	rpm;
{
	WORD	rpm_idx;
	WORD	snd;

	if (snd_flag & HILL)					/* If Jumping,		*/
	  return;						/* Exit			*/

	rpm_idx = rpm / (WORD)89;				/* Get rpm index	*/
	if (rpm_idx > 39) rpm_idx = 39;
	snd = (S_ENG1 + rpm_idx) - (plrcar->car_gear << 2);	/* Get target engine level	*/

	if (snd > plr_rpm)					/* Slew sound to target	*/
	  ++plr_rpm;
	else
	  {
	  if (snd < plr_rpm)
	    --plr_rpm;
	  }

	com_wrt(plr_rpm);
/*	pdec(1,7,snd-S_ENG1,2,0,APLT1);		*/
}


/*	Start engine					*/
start_engine()
{
	com_wrt(S_ENGINE);		/* Start sound		*/
	plr_rpm = S_ENG1;		/* Reset rpm sound	*/
}



/*	Rev-up the engine at start			*/
rev_engine()
{
	WORD	rpm;
	rpm = (PEDAL ^ 0x1F) * 0x60;
	engine(rpm);
}


/*	Reset engine RPM				*/
res_engine()
{
	plrcar->car_rpm = 0;				/* Stop the rev-up		*/
}



/*	Coast player to zero				*/
coast_player()
{
	friction = (plrcar->car_spd >> 5) + 1;			/* Coast slowly		*/

	if (plrcar->car_spd >= friction)			/* Get friction		*/
	  plrcar->car_spd -= friction;
	else
	  plrcar->car_spd >>= 1;

	if (plrcar->car_spd < 0) plrcar->car_spd = 0;

	car_speed(plrcar,0);
}


/*	Adjust speedometer if needed			*/
speedo()
{
	BYTE	ndl_old;

	ndl_old = ndl_idx;					/* Save last needle picture	*/
	ndl_idx = plrcar->car_yspd / (ENG_MAX / 0x20);		/* Get new needle index		*/
	if (ndl_idx >= 0x20) ndl_idx = 0x1F;

	if (ndl_idx != ndl_old)				/* If we changed		*/
	  bckdsp |= B_NEEDLE;				/* Draw new needle		*/
}



/*	Player explodes				*/
plr_xplo()
{
	sounds(S_FENG);				/* Fade engine sound	*/
	viewy_spd = 8;				/* Slow scroll		*/
	viewx_spd = 0;
	acc_case = 1;				/* Set external scroll speed	*/

	plr_case = P_XPLO;			/* Player is exploding	*/
}


/*	Transfer player AD1 to caller			*/
/*	Called from script				*/
get_pud1(op)
MDTYPE	*op;
{
	op->ad1 = pp->ad1;
}



/*	Player sounds					*/
plr_sounds()
{
#if	0
	phex(1,12,plrcar->car_spd,4,0,APLT4);
	phex(1,13,plrcar->car_rpm,4,0,APLT4);
	phex(1,14,plrcar->car_gear,1,0,APLT4);
#endif
	if ((snd_flag & CHEER) == 0)				/* If waiting for cheer			*/
	  {
	  if (pp->ypos > (world_len - STRIP_SIZE))	/* If comming up to finish line..	*/
	    {
	    if (random(1))					/* Crowd cheers!			*/
	      com_wrt(S_CHEER);
	    else
	      com_wrt(S_CHEER2);

	    snd_flag |= CHEER;					/* We did this				*/
	    }
	  }

	off_road = ON_ROAD;					/* Default to on the road sounds	*/

	if (plrcar->car_flag & ON_SHOULDER)			/* Set off_road case, if needed		*/
	  off_road = SHOULDER;
	else
	  {
	  if (plrcar->car_flag & ON_DIRT)
	    off_road = DIRT;
	  }

	switch (plrcar->car_case)
	  {
	  case CC_BURNOUT:					/* If burnout				*/
	    if (plrcar->car_spd > 0x10)
	      {
	      if ((snd_flag & SKID) == 0)			/* And sound is off			*/
	        {
	        com_wrt(S_ADSKID);				/* Turn on skid				*/
	        snd_flag |= SKID;
	        }
	      }
	    break;

	  default:
	  case CC_DRIVE:					/* If driving..				*/
	    if (snd_flag & HILL)				/* If hill sound on...		*/
	      {
	      com_wrt(S_LAND);					/* Back on track		*/
	      shake_req = 3;					/* 3 frame shake		*/
	      snd_flag &= ~HILL;

	      if (gmove)					/* If good move is on		*/
	        {
	        announce( random(1) ? S_SEETHAT : S_GTMOVE, 0, 0 );
	        gmove = FALSE;
	        }
	      }

	    do_skid();						/* Do skid sound			*/
	    break;

	  case CC_JUMP:						/* If jumping..				*/
	    if (snd_flag & SKID)				/* And sound is on			*/
	      {
	      com_wrt(kskid_snd);				/* Kill it and exit			*/
	      snd_flag &= ~SKID;
	      }

	    if ((snd_flag & HILL) == 0)				/* If hill sound not on...		*/
	      {
	      com_wrt(S_HILL);					/* Start jump sound			*/
	      snd_flag |= HILL;
	      }

	    if (snd_flag & OFFRD)				/* If OFFRD sound is on			*/
	      {
	      com_wrt(S_BACKON);				/* Kill it				*/
	      snd_flag &= ~(OFFRD | GRASS);
	      }

	    if ((plrcar->car_zspd > 0x10) &&			/* If good jump	and			*/
	       (abs(plrcar->car_pic) >= ROLL_LIMIT))		/* Past roll point			*/
	      gmove = TRUE;					/* Might be good move			*/

	    break;

	  case CC_BOUNCE:
	    if (snd_flag & HILL)				/* If hill sound on...		*/
	      {
	      com_wrt(S_LAND);					/* Back on track		*/
	      shake_req = 3;					/* 3 frame shake		*/
	      snd_flag &= ~HILL;

	      if (gmove)					/* If good move is on		*/
		{
		announce( random(1) ? S_SEETHAT : S_GTMOVE, 0, 0 );
	        gmove = FALSE;
		}
	      }

	    do_skid();						/* Do skid sound			*/
	    break;

	  case CC_ROLL:
	  case CC_ENDO:
	    if (random(3) == 0)					/* Random crunch sound			*/
	      com_wrt(S_SIDEROLL);
	    break;
	  }

	pass_by();						/* Car passby				*/
}



/*	Init player sound					*/
init_plrsnd()
{
	snd_flag = 0;					/* Clear sound flags	*/
	skid_snd = skid_tbl[world].start;		/* Set skid sounds	*/
	fskid_snd = skid_tbl[world].fade;
	kskid_snd = skid_tbl[world].kill;

	pass_case = 0;					/* Init car pass	*/
	pass_dist = MAX_PASS;				/* Init distance	*/

	gmove = FALSE;
}



/*	Kill player sounds					*/
kill_plrsnd()
{
	if (snd_flag & HILL)				/* If Jumping,		*/
	  com_wrt(S_LAND);				/* Kill hill sound	*/

	com_wrt(S_KDRIVMUS);				/* Kill music		*/
	com_wrt(S_FENG);				/* Fade engine		*/
	com_wrt(S_BACKON);				/* Fade any offroad sound	*/
	com_wrt(kskid_snd);				/* Kill skids		*/
	com_wrt(S_KSKID);
	com_wrt(S_KILPAS);				/* Kill pass sound	*/

	snd_flag = 0;					/* Set flags		*/
	off_road = ON_ROAD;
}




/*	Do skid sound processing				*/
do_skid()
{
	switch (off_road)					/* Do off road sound			*/
	  {
	  case ON_ROAD:
	    if (plrcar->car_flag & SKIDDING) 			/* If player is skidding...		*/
	      {
	      if ((snd_flag & SKID) == 0)			/* And sound is off			*/
	        {
	        com_wrt(skid_snd);				/* Turn on skid				*/
	        snd_flag |= SKID;
		}
	      }
	    else
	      {							/* If not skidding...			*/
	      if (snd_flag & SKID)				/* And sound is on			*/
		{
		com_wrt(fskid_snd);				/* Kill it				*/
		snd_flag &= ~SKID;
		}
	      }
	
	    if (snd_flag & OFFRD)				/* If we came from shoulder		*/
	      {
	      com_wrt(S_BACKON);				/* STOP off road sound			*/
	      snd_flag &= ~OFFRD;
	      }
	    break;

	  case SHOULDER:
	    if ((snd_flag & OFFRD) == 0)			/* If OFFRD not started..		*/
	      {
	      com_wrt(fskid_snd);				/* Kill the skid			*/
	      com_wrt(S_OFFRD);					/* Start off road sound			*/
	      snd_flag &= ~SKID;				/* Turn off skid			*/
	      snd_flag |= OFFRD;				/* Flag off road sound			*/
	      }
	    else
	      {
	      if (snd_flag & GRASS)				/* If we came from the grass		*/
		{
		com_wrt(S_SHOULDER);				/* Shoulder sound			*/
		snd_flag &= ~GRASS;
		}
	      }
	    break;

	  case DIRT:
	    if ((snd_flag & OFFRD) == 0)			/* If OFFRD not started..		*/
	      {
	      com_wrt(S_OFFRD);					/* Start off road sound			*/
	      snd_flag |= OFFRD;				/* Flag off road sound			*/
	      }

	    if ((snd_flag & GRASS) == 0)			/* If grass sound not on		*/
	      {
	      com_wrt(S_GRASS);					/* Grass road sound			*/
	      snd_flag |= GRASS;
	      }
	    break;

	  }
}


/*	Shake the control					*/
shake_it()
{
	WORD	shake;

	motor_bits &= ~(MOTOR1 | MOTOR2);		/* Default motor OFF			*/

	if ( (gstate != G_PLAY1) &&			/* If not playing game...		*/
           ( ( frgdsp & F_FIRE) == 0 ) )
	  return;

	if (plrcar->car_case != CC_JUMP)		/* Or player is NOT jumping		*/
	  {						/* Process shaker			*/
	  if (shake_req)				/* If one time request...		*/
	    {
	    if (motor_tmr <= MOTOR_DELAY)		/* If it's been a second since last request	*/
	      motor_tmr = shake_req;			/* Turn it on!				*/

	    shake_req = 0;				/* Clear request			*/
	    }
	  else
	    {
	    if ((plrcar->car_case == CC_ROLL) || (plrcar->car_case == CC_ENDO))
	      {
	      if (((frame & 1) == 0) && random(1))
	      	motor_bits |= MOTOR1;
	      else
	        motor_bits &= ~MOTOR1;
	      }
	    else
	      {
	      shake = plrcar->car_spd >> 7;

	      switch (off_road)				/* Process shake the control 		*/
	        {
	        case ON_ROAD:					/* If roll or endo		*/
	    	  break;

	        case SHOULDER:
	    	  if (((frame & 3) == 0) && random(shake))
	      	    motor_bits |= MOTOR1;
	    	  else
	      	    motor_bits &= ~MOTOR1;
	    	  break;

	        case DIRT:
	    	  if (((frame & 1) == 0) && random(shake))
	      	    motor_bits |= MOTOR1;
	      	  else
	       	    motor_bits &= ~MOTOR1;
	    	  break;
		}
	      }
	    }
	  }

	if (motor_tmr > MOTOR_DELAY) 			/* If timer on...			*/
	  {
	  --motor_tmr;					/* Decrement				*/

	  if (motor_tmr >= 0)
	    motor_bits |= MOTOR1;			/* Pulse motor				*/
	  }

	if ((game_opt & DO_SHAKER) == 0)		/* If shaker is OFF			*/
	  motor_bits &= ~MOTOR1;			/* Clear the bit			*/

	if (thump_req)					/* If my butt gets thumped		*/
	  {
	  thump_req = FALSE;				/* Clear request			*/

	  if ( game_opt & DO_THUMP)
	    {
	    motor_bits |= MOTOR2;			/* Turn it on				*/
	    thumpcnt++;
	    }
	  }

	if ( motor_bits & MOTOR1) 			/* if shaker motor is turned on */
	  shakes++ ;					/* increment shake timer */
}

/*	Setup shake for cnt frames			*/
set_shake(cnt)
BYTE	cnt;
{
	shake_req = cnt;
	motor_tmr = MOTOR_DELAY;
}



/*	Flash LAST LAP message				*/
last_flash()
{
	if (--last_tmr <= 0)				/* If timeout			*/
	  {
	  berase(&lastmsg);				/* Erase message		*/
	  com_wrt(S_LASTLAP);
	  bckdsp &= ~B_LAST;
	  return;
	  }

	if ((last_tmr & 0x07) == 0)			/* Every 1/4 sec		*/
	  {
	  if (last_tmr & 0x08)
	    berase(&lastmsg);
	  else
	    {
	    bwrite(&lastmsg,APLT3);
	    com_wrt(S_BUZZR);
	    }
	  }
}



/*	Pass-By sound			*/
pass_by()
{
	DRNBLK	*drptr;
	int	j;
	ulong	closest;
	long	diff;

	closest = MAX_PASS;					/* Init current closest distance	*/

	for (j=0; j < MAX_DRONE; j++)
	  {
	  if (j != plyrno)					/* If NOT the player	*/
	    {
	    drptr = drtable[j];					/* Get drone pointer	*/

	    if (drptr->op)					/* If drone is active..		*/
	      {
	      diff = drptr->drn_yabs - p0_yabs;			/* Get distance		*/
	      diff = ABS(diff);					/* Get abs distance	*/

	      if (diff < closest)				/* If closer than close	*/
	        closest = diff;
	      }
	    }
	  }

	diff = closest - pass_dist;				/* Get delta change		*/

	if (ABS(diff) >= PASS_TICK)				/* If change needed		*/
	  {
	  switch (pass_case)
	    {
	    case 0:						/* Wait for player to move	*/
	      if (pp->ypos > 0x1000)
		pass_case = 1;
	      break;

	    case 1:						/* Sound not started..		*/
	      com_wrt(S_CARPAS);				/* Start it			*/
	      pass_dist = MAX_PASS;				/* Init distance		*/
	      pass_case = 2;
	      break;

	    case 2:
	      if (closest < pass_dist)				/* If closer...			*/
		{
		pass_dist -= PASS_TICK;
		com_wrt(S_CLOSER);
		}
	      else
		{
		pass_dist += PASS_TICK;				/* If further...		*/
		com_wrt(S_FURTHER);
		}

	      if (pass_dist >= MAX_PASS)			/* If over max			*/
		{
		com_wrt(S_KILPAS);				/* Kill the sound		*/
		pass_case = 1;
		}

	    default:
	      break;
	    }
	  }
}

		  


