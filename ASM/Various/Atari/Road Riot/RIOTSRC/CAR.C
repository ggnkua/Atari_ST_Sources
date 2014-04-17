/*======================================================================*/
/*		TITLE:			CAR				*/
/*		Function:		Car Model Routines		*/
/*									*/
/*		First Edit:		10/02/90			*/
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
#include	"prog/inc/message.h"
#include	"prog/inc/audio.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:drninc.h"
#include	"inc:message.h"
#include	"inc:audio.h"

#endif

#define	CAR_ANGLES	96
#define	CAR_TICK	(0x10000 / CAR_ANGLES)

#define	SHOULDER	0x780
#define	OFF_ROAD	0xC00
#define	ROAD_FRIC	0x0C
#define	SHLDR_FRIC	0x09
#define	OFF_FRIC	0x06
#define	SPIN_FRIC	0x03
#define	ROLL_FRIC	0x01
#define	MIN_FRIC	0x08

#define	MAX_RPM		0x1000
#define	MAX_YSPD	0x0288
#define	UP_SHIFT	(MAX_RPM - 0x200)
#define	GEAR0_MAX	0x0100
#define	GEAR1_MAX	0x0200
#define	GEAR2_MAX	0x0300
#define	DOWN_SHIFT0	(((GEAR0_MAX * UP_SHIFT)/GEAR1_MAX) - 0x100)
#define	DOWN_SHIFT1	(((GEAR1_MAX * UP_SHIFT)/GEAR2_MAX) - 0x100)

#define	ROLL_BOUNCE	-0x10

#define	GRAVITY		4
#define	SHOCK_SPD	2

#define	MAX_EXT		0x400
#define	EXT_ACC		2

#define	SPN0		0x1000
#define	SPN1		0x1C00
#define	SPN2		0x2800
#define	SPN3		0x3000

#define	ENDO_ZOFF	0x80
#define	ROLL_ZMIN	0x20

extern	MDTYPE	obj[];
extern	MOBLK	dust1blk,dust2blk,splatblk;
extern	DRNBLK	*drtable[];
extern	int	abs();
extern	ulong	coldsp;
extern	long	world_len;
extern	WORD	(*wheels[])[],(*bodys[])[],shds[];
extern	WORD	roll[],endo[],endo1[],expl0[],expl1[],shd_roll[],shd_endo[],shd_endo1[];
extern	WORD	droll[],dendo[],drn_tbl[];
extern	WORD	mocolr[],tirepal3[];
extern	WORD	frame,world;
extern	WORD	plyrno;
extern	short	dust_xoff[],dust_yoff[];
extern	short	ssin(),scos();
extern  short	slope_tbl[];
extern	short	viewx_spd;
extern	BYTE	thump_req;
extern	BYTE	BLOCK000[];
extern	CANIM_BLOCK	*start_rotate();

	LIST_HEAD	car_list,car_free;			/* Linked list head pointers		*/
	CARBLK		car_blks[MAX_CARS];			/* Car control blocks			*/
	WORD		grav;					/* Gravity constant			*/

	WORD	gear_max[]={GEAR0_MAX,GEAR1_MAX,GEAR2_MAX};
	WORD	bounce_mask[]={0xFF,0x0F,0x07,0x03,0x01,0x00};

	WORD	spin_tbl[]={SPN1,SPN1,SPN1,SPN1,
			    SPN1,SPN1,SPN0,SPN1,
			    SPN1,SPN1,SPN1,SPN1};

	BYTE	rot_off[]={5,5,2,5,5,2,5};


/*	Init car linked list					*/
init_cars()
{
    CARBLK	*cptr;
    
    car_list.next = car_list.prev = &car_list;				/* Null active list		*/
    car_free.next = car_free.prev = &car_free;				/* Null free list		*/

    for(cptr = car_blks; cptr < &car_blks[MAX_CARS]; ++cptr)		/* Put all blocks on free list	*/
      link_last(&car_free,cptr);
}



/*	Returns next free carblk pointer			*/
CARBLK *get_carblk()
{
	CARBLK	*temp;

	if( (temp = car_free.next) == &car_free ) /* no memory left - punt */
 	  return(NULL);

	dlink(temp);						/* De-link from free list		*/
	return( temp );
}


/*	Init a car data block				*/
/*	Returns pointer to assigned car block		*/
/*	Entry:	car_op = car object pointer		*/
CARBLK	*init_carblk(car_op)
MDTYPE	*car_op;
{
	CARBLK	*carptr;

	if ((carptr = get_carblk()) == NULL)		/* If none left...			*/
	  trap();

	carptr->op = car_op;			/* Init object pointers			*/
	carptr->mir_ptr = 0;
	carptr->car_spd = 0;				/* stop the car */
	carptr->car_rpm = 0;
	carptr->car_xspd = 0;
	carptr->car_yspd = 0;
	carptr->car_zspd = 0;
	carptr->car_ztrg = 0;
	carptr->car_dir = 0;
	carptr->car_trg = 0;
	carptr->car_pic = 0;
	carptr->slew_dir = 0;
	carptr->spin_dir = 0;
	carptr->car_xext = 0;
	carptr->car_yext = 0;
	carptr->jump_spd = 0;
	carptr->slope = 0;
	carptr->car_flag = 0;
	carptr->tire_skid = TIRE0;
	carptr->car_spin = spin_tbl[world];		/* Set spinout threshold	*/
	carptr->car_gear = 0;
	carptr->lasty = 0;
	carptr->next_rot = TIRE_ROT;
	carptr->tire_pal = car_op->pal >> 4;

	carptr->cblk0 = start_rotate(MOB_BASE,car_op->pal >> 4,1,0,4);	/* Init tire rotate			*/
	carptr->cblk1 = start_rotate(MOB_BASE,car_op->pal >> 4,28,0,3);
	carptr->tire_rot = 0;

	set_burn(carptr);

	car_op->uptr = (long)carptr;			/* Save car block pointer in obj	*/

	link_first(&car_list,carptr);			/* Link into active list		*/

	coldsp |= C_CAR;				/* Enable collsion			*/
	return(carptr);					/* Tell caller our addrs		*/
}


/*	Delete a car							*/
del_car(carptr)
CARBLK	carptr;
{
	dlink(carptr);				/* Unlink from active list	*/
	link_first(&car_free,carptr);		/* Link into free list		*/
}



/*	Steer the car							*/
/*	Entry:	carptr = car block pointer				*/
/*		dir = target direction angle				*/
/*		curve = curve value under car				*/

car_steer(carptr,dir,curve)
CARBLK	*carptr;
short	dir,curve;
{
#define	SPIN_TICK	0x400

	long	dangle;
	int	slew_left,slew_right,abs_angle;
	short	last_dir;

	switch (carptr->car_case)
	  {
	  case CC_BURNOUT:
	    get_target(carptr,dir);					/* Get the target angle			*/
	    carptr->car_dir = carptr->car_trg;				/* Set direction			*/

	    if (carptr->car_flag & MID_BURN)
	      {
	      if (ABS(carptr->car_pic) >= carptr->burn_max)		/* If burnout limit			*/
		{
	      	carptr->car_flag &= ~MID_BURN;				/* Wait for middle burn			*/
	      	carptr->burn_max -= 0x200;

	      	if (carptr->burn_max <= (BURN_TICK*2)) 			/* If done				*/
	          {
	          carptr->car_dir = carptr->car_trg = carptr->car_pic;	/* Get delta from current picture	*/
		  carptr->car_yext += 0x40;				/* Burst forward			*/

		  if (carptr->car_flag & PLR_CAR)			/* If the player...			*/
		    com_wrt(S_FSKID);					/* Fade the skid			*/

	          chg_ccase(carptr,CC_DRIVE);				/* Drive the car			*/
	          break;
	          }

	        if (carptr->burn_dir > 0)				/* Reverse burnout and faster		*/
	          carptr->burn_dir = -(carptr->burn_dir + BURN_TICK);
	        else
	          carptr->burn_dir = -(carptr->burn_dir - BURN_TICK);
		}
	      }
	    else
	      {
	      last_dir = carptr->car_dir;					/* Save last direction			*/

	      if ((carptr->car_pic ^ last_dir) & 0x8000)			/* If crossed zero			*/
	        carptr->car_flag |= MID_BURN;					/* Flag mid crossing			*/
	      }

	    if (carptr->car_flag & START_BURN)					/* If we HAVEN'T started yet		*/
	      {
	      if (carptr->car_spd > 0x10)					/* If moving				*/
		carptr->car_flag &= ~START_BURN;				/* Do it 				*/
	      }
	    else
	      carptr->car_pic += carptr->burn_dir;

	    break;

	  default:
	  case CC_DRIVE:						/* Driving the car			*/
	    if (carptr->spin_dir)					/* If spin was interrupted...		*/
	      {
	      carptr->car_trg = dir;					/* Set direction			*/
	      chg_ccase(carptr,CC_SPIN);				/* Change car case			*/
	      break;
	      }

	    get_target(carptr,dir);					/* Get the target angle			*/

	    if (curve >= 0)
	      {
	      slew_left = carptr->tire_skid - (curve << 5);		/* Get direction slews			*/
	      slew_right = carptr->tire_skid;
	      }
	    else
	      {
	      slew_left = carptr->tire_skid;
	      slew_right = carptr->tire_skid - (-curve << 5);
	      }

	    dangle = carptr->car_trg - carptr->car_dir;			/* Get delta angle signed		*/
	    abs_angle = abs(dangle);					/* Get absoulute angle			*/

	    if (((dangle < 0) && (abs_angle <= slew_left)) ||		/* If within slew range			*/
	       ((dangle >= 0) && (abs_angle <= slew_right)))
	      {
	      carptr->car_dir = carptr->car_trg;
	      carptr->slew_dir = 0;
	      carptr->car_flag &= ~SKIDDING;				/* No skidding				*/
	      }
	    else
	      {
	      carptr->car_flag |= SKIDDING;				/* Flag Skidding			*/

	      if (carptr->car_flag & ON_DIRT)				/* If off road				*/
		{							/* Do a spinout				*/
		if (abs_angle >= carptr->car_spin)			/* If in spin range			*/
		  {
		  start_spin(carptr);					/* Start a new spin			*/
		  break;
		  }
		}

	      if (carptr->car_dir < carptr->car_trg)			/* Bump current to target  		*/
	        carptr->slew_dir = slew_right >> 2;
	      else
	        carptr->slew_dir = -(slew_left >> 2);

              carptr->car_dir += carptr->slew_dir;
	      }

	    carptr->car_pic = carptr->car_trg;				/* Picture is target direction		*/
	    break;

	  case CC_SPIN:							/* Spinout				*/
	    get_target(carptr,dir);					/* Get target angle			*/

	    carptr->car_pic += carptr->spin_dir;			/* Spin car picture			*/
	    carptr->slew_dir = carptr->spin_dir;

	    if (abs(carptr->car_pic) > 0x7000)				/* If facing backward			*/
	      carptr->car_flag &= ~SPIN_START;				/* Unflag spin started			*/

	    if (((carptr->car_flag & SPIN_START) == 0) &&		/* If spinout 1/2 over			*/
	       (abs(carptr->car_pic - carptr->car_trg) <= SPIN_TICK))	/* If back in place			*/
	      {
	      carptr->car_pic = carptr->car_dir = carptr->car_trg;		/* Point in correct direction		*/
	      carptr->spin_dir = 0;					/* Clear spin direction			*/
	      chg_ccase(carptr,CC_DRIVE);				/* Change car case			*/
	      }

	    if (abs(carptr->car_dir - carptr->car_trg) < SPIN_TICK)	/* Bump current to target  		*/
	      carptr->car_dir = carptr->car_trg;
	    else
	      {
	      if (carptr->car_dir < carptr->car_trg)			/* Bump current to target  		*/
		carptr->car_dir += SPIN_TICK;
	      else
	        carptr->car_dir -= SPIN_TICK;
	      }

	    break;

	  case CC_JUMP:
	    carptr->car_pic += carptr->slew_dir;			/* Use last slew value			*/
	    break;

	  case CC_ROLL:							/* If rolling...			*/
	  case CC_ENDO:
	  case CC_XPLO:
	    return;							/* No control				*/
	  }

	set_angle(carptr);						/* Set car picture angle 		*/
}



/*	Slew target angle to direction				*/
/*	Entry:	carptr = car block pointer			*/
/*		dir = target direction angle			*/
get_target(carptr,dir)
CARBLK	*carptr;
short	dir;
{
	long	dangle;
	int	slew_trg,abs_angle;

	slew_trg = (carptr->car_spd << 1) + (carptr->car_spd >> 7);	/* Get slew target value		*/

	dangle = dir - carptr->car_trg;					/* Get delta angle signed		*/
	abs_angle = abs(dangle);					/* Get absoulute angle			*/

	if (abs_angle <= slew_trg)					/* Slew car target angle 		*/
	  carptr->car_trg = dir;					/* Set target angle			*/
	else
    	  {								/* Slew to target angle			*/
	  if (carptr->car_trg < dir)
	    carptr->car_trg += slew_trg;
	  else
	    carptr->car_trg -= slew_trg;
	  }

	turn_wheels(carptr,dir);					/* Turn wheels if needed		*/
}



/*	Set car angle and picture				*/
set_angle(carptr)
CARBLK	*carptr;
{
	WORD	dangle;
	BYTE	angle,old_angle;
	
	dangle = carptr->car_pic + 0x8000;

	old_angle = carptr->op->ad1;				/* Save old angle			*/
	angle = (WORD)dangle / (WORD)CAR_TICK;

	if (old_angle != angle)						/* If picture changed			*/
	  store_angle(carptr,angle);					/* Store new angle			*/
}



/*	Store new angles and enable animation				*/
/*	Entry:	carptr = car block pointer				*/
/*		angle = angle to set					*/
store_angle(carptr,angle)
CARBLK	*carptr;
BYTE	angle;
{
	WORD	*wp;

	if ((carptr->op->flags & MO_DIR) == 0)			/* If NOT in direct mode...		*/
	  return;						/* Later!				*/

	carptr->op->ad1 = angle;				/* Change tire picture			*/
	wp = carptr->wheels;					/* Get table base			*/
	carptr->op->seqn = (WORD *)wp[angle];			/* Get current picture			*/
	carptr->op->flags |= MO_NEW;				/* Display new picture			*/

	carptr->body_ptr->ad1 = angle;				/* Change body picture			*/
	wp = carptr->bodys;					/* Get table base			*/
	carptr->body_ptr->seqn = (WORD *)wp[angle];		/* Get current picture			*/
	carptr->body_ptr->flags |= MO_NEW;			/* Display new picture			*/

	carptr->shdo_ptr->ad1 = angle;				/* Change shadow picture		*/
	wp = carptr->shadows;					/* Get table base			*/
	carptr->shdo_ptr->seqn = (WORD *)wp[angle];		/* Get current picture			*/
	carptr->shdo_ptr->flags |= MO_NEW;			/* Display new picture			*/

	if (carptr->mir_ptr)					/* If my image is in mirror		*/
	  {
	  carptr->mir_ptr->seqn = (WORD *)drn_tbl[angle];
	  carptr->mir_ptr->flags |= MO_NEW;			/* Display new picture			*/
	  }

}


/*	Bump picture angle 						*/
bump_angle(carptr,da)
CARBLK	*carptr;
short	da;
{								/* If rolling (or endo), exit	*/
	if ((carptr->car_case == CC_ROLL) || (carptr->car_case == CC_ENDO) || (carptr->car_case == CC_SPIN))
	  return;

	if (da > 0)						/* Check angle bump limits	*/
	  {
	  if (carptr->car_trg > 0x2000)
	    return;
	  }
	else
	  {
	  if (carptr->car_trg < -0x2000)
	    return;
	  }

	carptr->car_trg += da * (short)CAR_TICK;		/* Bump to new angle		*/
	carptr->car_pic = carptr->car_dir = carptr->car_trg;
	set_angle(carptr);
}
	


/*	Turn the wheels							*/
/*	Entry:	carptr = car block pointer				*/
/*		dir = target direction					*/
turn_wheels(carptr,dir)
CARBLK	*carptr;
short	dir;
{
#define	WHEEL_TICK	0x800

	short	wheel_tick;
	BYTE	seqidx;

	wheel_tick = WHEEL_TICK;
	seqidx = carptr->op->ad2;				/* Get sequence index			*/

	switch (seqidx)
	  {
	  case 0:						/* If wheels are straight		*/
	  case 3:
	  case 6:
	  case 9:
	  case 12:
	    if (dir <= -wheel_tick)				/* If going left...			*/
	      new_seq(carptr,seqidx+1);				/* Add 1 to sequence index		*/
	    else
	      {
	      if (dir >= wheel_tick)				/* If going right...			*/
	        new_seq(carptr,seqidx+2);			/* Add 2 to sequence index		*/
	      }
	    break;

	  case 1:						/* If wheels are left			*/
	  case 4:
	  case 7:
	  case 10:
	  case 13:
	    if (dir > -wheel_tick)				/* If going right...			*/
	      new_seq(carptr,seqidx-1);				/* Sub 1 from sequence index		*/
	    break;

	  case 2:						/* If wheels are right			*/
	  case 5:
	  case 8:
	  case 11:
	  case 14:
	    if (dir < wheel_tick)				/* If going left...			*/
	      new_seq(carptr,seqidx-2);				/* Sub 2 from sequence index		*/
	    break;
	  }
}


/*	Set car sequence index							*/
/*	Entry:	carptr = car block pointer					*/
/*		seqidx = sequence index (ad2)					*/
new_seq(carptr,seqidx)
CARBLK	*carptr;
BYTE	seqidx;
{
	carptr->op->ad2 = seqidx;				/* Store wheel sequence index		*/
	carptr->wheels = wheels[seqidx];			/* Get table base addrs		*/

	carptr->body_ptr->ad2 = seqidx;				/* Store body sequence index		*/
	carptr->bodys = bodys[seqidx];				/* Get table base addrs		*/

	store_angle(carptr,carptr->op->ad1);			/* Store car angle		*/
}



/*	Get new car position and speeds				*/
car_pos(carptr,curve)
CARBLK	*carptr;
short	curve;
{
	int	wrap,absx,jump;
	long	ycenter;
	short	spd,zpos,last_slope;
	WORD	ext_xacc,ext_yacc;

	wrap = FALSE;							/* Default no wrap 		*/
	jump = FALSE;							/* Default no jump		*/
	grav = GRAVITY;

	if (carptr->car_flag & ON_DIRT)					/* Set external accel		*/
	  {
	  ext_xacc = EXT_ACC << 2;
	  ext_yacc = EXT_ACC << 3;
	  }
	else
	  {
	  if (carptr->car_flag & ON_SHOULDER)
	    {
	    ext_xacc = EXT_ACC << 1;
	    ext_yacc = EXT_ACC << 2;
	    }
	  else
	    {
	    ext_xacc = EXT_ACC;
	    ext_yacc = EXT_ACC << 1;
	    }
	  }

	spd = carptr->car_spd;						/* Get component speeds		*/
	carptr->car_xspd = ((curve * spd) >> 6) + ((spd * ssin(carptr->car_dir)) >> 14);
	carptr->car_yspd = (spd * scos(carptr->car_dir)) >> 14;

	if (abs(carptr->car_xext) < ext_xacc)				/* Dampen external X speed	*/
	  carptr->car_xext = 0;
	else
	  {
	  if (carptr->car_xext > 0)
	    {
	    if (carptr->car_xext > MAX_EXT)				/* High limit check		*/
	      carptr->car_xext = MAX_EXT;

	    carptr->car_xext -= ext_xacc;
	    }
	  else
	    {
	    if (carptr->car_xext < -MAX_EXT)				/* Low limit check		*/
	      carptr->car_xext = -MAX_EXT;

	    carptr->car_xext += ext_xacc;
	    }

	  carptr->car_xspd += carptr->car_xext;				/* Add external speed		*/
	  }

	if (abs(carptr->car_yext) < ext_yacc)				/* Dampen external y speed	*/
	  carptr->car_yext = 0;
	else
	  {
	  if (carptr->car_yext > 0)
	    {
	    if (carptr->car_yext > MAX_EXT)				/* High limit check		*/
	      carptr->car_yext = MAX_EXT;

	    carptr->car_yext -= ext_yacc;
	    }
	  else
	    {
	    if (carptr->car_yext < -MAX_EXT)				/* Low limit check		*/
	      carptr->car_yext = MAX_EXT;

	    carptr->car_yext += ext_yacc;
	    }

	  carptr->car_yspd += carptr->car_yext;				/* Add external speed		*/
	  }

	if ((carptr->car_yspd < 0) && (carptr->car_flag & PLR_CAR))	/* No going backward for the player	*/
	  carptr->car_yspd = carptr->car_yext = 0;	    

	last_slope = carptr->slope;					/* Save last slope we were on	*/
	carptr->lasty = carptr->op->ypos;				/* Save last ypostion		*/
	carptr->op->xpos += carptr->car_xspd;				/* Get new car position		*/
	carptr->op->ypos += carptr->car_yspd;

	if (carptr->op->xpos >= WLD_EDGE)				/* Clip x at world edge	*/
	  {
	  carptr->op->xpos = WLD_EDGE;
	  carptr->car_flag |= ON_EDGE;
	  carptr->car_xext = 0;
	  }
	else
	  {
	  if (carptr->op->xpos <= -WLD_EDGE)
	    {
	    carptr->op->xpos = -WLD_EDGE;
	    carptr->car_flag |= ON_EDGE;
	    carptr->car_xext = 0;
	    }
	  else
	    carptr->car_flag &= ~ON_EDGE;
	  }

	if (carptr->op->ypos > world_len )				/* Wrap y coordinate		*/
	  {
	  carptr->op->ypos -= world_len;
	  wrap = TRUE;
	  }
	else
	  {
	  if (carptr->op->ypos < 0)
	    carptr->op->ypos = 0;
	  }

	ycenter = carptr->op->ypos + CAR_RAD;				/* Find center of car		*/
	if (ycenter >= world_len) ycenter -= world_len;			/* Wrap 			*/
	carptr->op->height = carptr->car_ztrg = get_height(ycenter);	/* Get target z position	*/
	carptr->slope = slope_tbl[ycenter >> 12];			/* Get new slope 		*/
	store_slope(carptr);

	if (carptr->slope < last_slope)					/* If going over a hill		*/
	  {
	  jump = TRUE;							/* Flag jumping			*/
	  spd = (carptr->car_yspd > MAX_YSPD) ? MAX_YSPD : carptr->car_yspd;
	  carptr->jump_spd = (last_slope * spd) >> 12;			/* Get jump speed		*/
	  }

	switch (carptr->car_case)
	  {
	  default:
	  case CC_BURNOUT:
	  case CC_DRIVE:
	    if (jump)							/* If over a hill..		*/
	      {
	      carptr->op->zpos += carptr->jump_spd;			/* Add speed over the hill	*/
	      carptr->car_zspd = carptr->jump_spd;
	      chg_ccase(carptr,CC_JUMP);				/* Change car case			*/
	      }
	    else
	      carptr->op->zpos = carptr->car_ztrg;			/* Get new position	*/

	    break;

	  case CC_JUMP:							/* Here if jumping		*/
	    if ((jump) && (carptr->car_flag & BOUNCE))			/* If over a hill while bounce jumping...	*/
	      {
	      carptr->car_zspd = carptr->jump_spd;			/* Get new jump speed		*/
	      carptr->car_flag &= ~BOUNCE;				/* Turn off bounce jump flag	*/
	      }
	    else
	      carptr->car_zspd -= grav;					/* Add gravity			*/

	    zpos = carptr->op->zpos + carptr->car_zspd;			/* Add zspeed			*/

	    if (zpos <= carptr->car_ztrg)				/* If on the ground		*/
	      {
	      carptr->car_flag &= ~BOUNCE;				/* Turn off bounce jump flag	*/
	      zpos = carptr->car_ztrg;					/* Put on the ground		*/

	      if (carptr->slope < 0)					/* If landing on downhill..	*/
	        carptr->jump_spd >>= 2;					/* Large bounce decay		*/
	      else
	        carptr->jump_spd >>= 1;					/* Smaller bounce decay		*/

	      if ((abs(carptr->car_pic) >= ROLL_LIMIT) &&		/* If past roll point		*/
		 (carptr->car_zspd <= ROLL_BOUNCE))			/* On a big bounce		*/
	        start_roll(carptr);					/* Do a roll			*/
	      else
		{
	        carptr->car_trg = carptr->car_pic;			/* Picture is target direction	*/

	        if (abs(carptr->jump_spd) <= grav)			/* If bounce <= gravity		*/
		  {
	          carptr->car_zspd = 0;					/* Stop the bounce		*/
		  chg_ccase(carptr,CC_DRIVE);				/* Change car case		*/
	          }
		else
		  {
	          carptr->car_zspd = carptr->jump_spd;
		  carptr->op->zoff = 0;					/* Stop any bounce in progress	*/
		  carptr->body_ptr->yspd = 0;
		  carptr->shdo_ptr->yspd = 0;
		  carptr->body_ptr->attr = SHOCK_SPD;			/* Start bouncing body		*/
		  chg_ccase(carptr,CC_BOUNCE);				/* Change car case			*/
		  }

	        car_puff(carptr);					/* Puff from tires		*/
		}
	      }

	    carptr->op->zpos = zpos;				/* Store zposition		*/
	    break;

	  case CC_BOUNCE:
	    if (jump)							/* If over a hill..		*/
	      {
	      carptr->op->zpos += carptr->jump_spd;			/* Add speed over the hill	*/
	      carptr->car_zspd = carptr->jump_spd;
	      chg_ccase(carptr,CC_JUMP);				/* Change car case			*/
	      }
	    else
	      {
	      carptr->op->zpos = carptr->car_ztrg;			/* Get new position		*/
	      carptr->body_ptr->yspd += carptr->body_ptr->attr;		/* Bounce body			*/

	      if (carptr->body_ptr->yspd == 0) 				/* If bounce done...		*/
		{
		carptr->car_flag |= BOUNCE;				/* Flag bounce jump		*/
		chg_ccase(carptr,CC_JUMP);				/* Change car case		*/
		}
	      else
	        {							/* Reverse bounce dir		*/
	        if ((carptr->body_ptr->attr > 0) && (carptr->body_ptr->yspd >= (SHOCK_SPD * 3)))
	          carptr->body_ptr->attr = -SHOCK_SPD;
	        }
	      }
	    break;

	  case CC_ROLL:
	    carptr->car_zspd -= grav;					/* Do one bounce		*/
	    carptr->op->zpos += carptr->car_zspd;			/* Add zspeed			*/

	    if (carptr->op->zpos <= carptr->car_ztrg)			/* If on the ground		*/
	      {
	      if (carptr->op->ad3)					/* If all over			*/
	        {
	        carptr->car_zspd = 0;					/* No more bouncing		*/
	        carptr->op->zpos = carptr->car_ztrg;			/* Set on ground		*/
	        }
	      else
		{
	        carptr->op->ad3 = TRUE;					/* Next roll			*/
	        carptr->shdo_ptr->ad3 = TRUE;
	        carptr->car_zspd = ROLL_ZMIN;				/* One more bounce		*/
		}
	      }
	    break;

	  case CC_ENDO:
	    carptr->car_zspd -= grav;					/* Add grav			*/
	    carptr->op->zpos += carptr->car_zspd;			/* Add zspeed			*/

	    if (carptr->op->zpos <= carptr->car_ztrg)			/* If hitting ground		*/
	      {
	      if (carptr->op->ad3)					/* If all over			*/
		end_endo(carptr);
	      else
		{
	        carptr->op->ad3 = TRUE;					/* Next endo			*/
	        carptr->shdo_ptr->ad3 = TRUE;
	        carptr->car_zspd = ENDO_ZMIN;				/* One more bounce		*/
		}
	      }
	    break;

	  case CC_XPLO:
	    break;
	  }

	carptr->car_flag &= ~(ON_SHOULDER | ON_DIRT);			/* Default not off track	*/
	absx = abs(carptr->op->xpos);				/* Get absolute xpos		*/

	if (absx > SHOULDER)						/* Set flags if off road	*/
	  {
	  if (absx > OFF_ROAD)
	    carptr->car_flag |= ON_DIRT;
	  else
	    carptr->car_flag |= ON_SHOULDER;

	  }

	car_dust(carptr);						/* Do dust clouds		*/
	bounce_tires(carptr);						/* Bounce the tires		*/
	rotate_tires(carptr);						/* Every 40,000 miles		*/
	return(wrap);
}


/*	Store car angle slope			*/
store_slope(carptr)
CARBLK	*carptr;
{
#define	SLOPE_TICK	0x80

	BYTE	seqidx;

	seqidx = carptr->op->ad2;					/* Get current sequence index	*/

	switch (seqidx)
	  {
	  case 0:							/* On flats			*/
	  case 1:
	  case 2:
	    if (abs(carptr->slope) >= SLOPE_TICK)			/* If on a slope		*/
	      {
	      if (carptr->slope > 0)					/* Going up?			*/
	        new_seq(carptr,seqidx+3);				/* Add 3 to sequence index	*/
   	      else							/* Going down...		*/
	        new_seq(carptr,seqidx+9);				/* Add 9 to sequence index	*/
	      }
	    break;

	  case 3:							/* Up 6"			*/
	  case 4:
	  case 5:
	    if (carptr->slope >= (SLOPE_TICK*2))			/* Up more?			*/
	      new_seq(carptr,seqidx+3);					/* Add 3 to sequence index	*/
	    else
	      {
	      if (carptr->slope < SLOPE_TICK)				/* If back on flat		*/
	        new_seq(carptr,seqidx-3);				/* Sub 3 from sequence index	*/
	      }
	    break;

	  case 6:							/* Up 12"			*/
	  case 7:
	  case 8:
	    if (carptr->slope < (SLOPE_TICK*2))				/* If going down...		*/
	      new_seq(carptr,seqidx-3);					/* Sub 3 from sequence index	*/
	    break;

	  case 9:							/* Down  6"			*/
	  case 10:
	  case 11:
	    if (carptr->slope <= -(SLOPE_TICK*2))			/* If down more			*/
	      new_seq(carptr,seqidx+3);					/* Add 3 to sequence index	*/
	    else
	      if (carptr->slope > -SLOPE_TICK)				/* If back on flat		*/
	        new_seq(carptr,seqidx-9);				/* Sub 9 from sequence index	*/
	    break;

	  case 12:							/* Down 12"			*/
	  case 13:
	  case 14:
	    if (carptr->slope > -(SLOPE_TICK*2))			/* If going back up...		*/
	      new_seq(carptr,seqidx-3);					/* Sub 3 from sequence index	*/
	    break;
	  }
}



/*	Start a spinout						*/
/*	Entry:	carptr = car block pointer			*/
start_spin(carptr)
CARBLK	*carptr;
{
	int	ok;

	ok = chg_ccase(carptr,CC_SPIN);			/* See if case can change		*/

	if (ok)						/* If everything hunky dory		*/
	  {
	  if (carptr->op->xpos < 0)			/* Get skid direction			*/
       	    carptr->spin_dir = (CAR_TICK << 1);
          else
	    carptr->spin_dir = -(CAR_TICK << 1);

	  carptr->car_flag |= SPIN_START;		/* Flag spin started			*/
	  }

	return(ok);
}



/*	Start car roll sequence						*/
start_roll(carptr)
CARBLK	*carptr;
{
	if  (chg_ccase(carptr,CC_ROLL))				/* If car case can change	*/
	  {
	  if (carptr->car_pic > 0)				/* Left or right flip?		*/
	    carptr->op->flags |= MO_FLIP;

	  carptr->spin_dir = 0;					/* Don't restore to spin	*/

	  carptr->op->seqn = roll;				/* Goto roll picture		*/
	  carptr->op->ftime = 1;				/* Change palette		*/
	  carptr->op->pal = carptr->body_ptr->pal;		/* To body's			*/
	  carptr->op->flags &= ~MO_DIR;				/* Not a direct pix		*/
	  carptr->op->satime = 1;				/* Start animation		*/
	  carptr->op->ad1 = 96;					/* Flag roll picture for link	*/
	  carptr->op->ad3 = FALSE;				/* Roll NOT done flag		*/
	  carptr->car_zspd = ROLL_ZMIN;

	  carptr->body_ptr->seqn = (WORD *)BLOCK000;		/* Blank out the body		*/
	  carptr->body_ptr->flags |= (MO_NEW | MO_DIR);		/* Make sure we're in direct mode!	*/
	  carptr->body_ptr->satime = carptr->body_ptr->satime = 0;

	  carptr->shdo_ptr->seqn = shd_roll;			/* Roll the shadow too		*/
	  carptr->shdo_ptr->flags &= ~MO_DIR;			/* Not a direct pix		*/
	  carptr->shdo_ptr->satime = 1;				/* Start animation		*/

	  if (carptr->mir_ptr)					/* If mirror drone active..	*/
	    {
	    carptr->mir_ptr->flags |= carptr->op->flags | MO_FLIP;	/* Get flip bit		*/
	    carptr->mir_ptr->seqn = droll;				/* Goto roll picture		*/
	    carptr->mir_ptr->flags &= ~MO_DIR;				/* Not a direct pix		*/
	    carptr->mir_ptr->satime = 1;				/* Start animation		*/
	    }
	  }
}


/*	End roll sequence						*/
/*	Called from script						*/
/*	Entry:	op = object pointer					*/
end_roll(op)
MDTYPE	*op;
{
	CARBLK	*carptr;
	short	 end_dir;

	carptr = (CARBLK *)op->uptr;					/* Get car block pointer	*/
	carptr->op->ftime = 1;						/* Change palette		*/
	carptr->op->pal = carptr->tire_pal << 4;			/* Restore palette		*/
	chg_ccase(carptr,CC_DRIVE);					/* Goto drive			*/

	if (carptr->op->flags & MO_FLIP)				/* Set ending direction		*/
	  {
	  end_dir = 0x1000;
	  carptr->op->flags &= ~MO_FLIP;				/* No more flip			*/
	  }
	else
	  end_dir = -0x1000;

	carptr->car_trg = carptr->car_dir = carptr->car_pic = end_dir;	/* Set direction		*/
	car_direct(carptr);						/* Set direct picture mode	*/
	set_angle(carptr);						/* Get picture angle		*/

}


/*	Get car speed							*/
/*	Entry: 	carptr = car block pointer				*/
/*		pedal = 0-0x1F (32 accelerator positions)		*/
car_speed(carptr,pedal)
CARBLK	*carptr;
BYTE	pedal;
{
	short	accel;
	BYTE	old_gear;

	accel = (pedal << 1) - car_friction(carptr);		/* Get acceleration value	*/
	carptr->car_rpm += accel;				/* Add accel to RPM		*/
	if (carptr->car_rpm < 0) carptr->car_rpm = 0;
	old_gear = carptr->car_gear;				/* Save gear			*/

	switch (old_gear)
	  {
	  case 0:						/* First gear			*/
	    if (carptr->car_rpm > UP_SHIFT)			/* Set gear			*/
	      carptr->car_gear = 1;				/* Change gear			*/
	    break;

	  case 1:
	    if (carptr->car_rpm > UP_SHIFT)
	      carptr->car_gear = 2;				/* 3rd gear			*/
	    else
	      {
	      if (carptr->car_rpm < DOWN_SHIFT0)
	        carptr->car_gear = 0;				/* 1st gear			*/
	      }
	    break;

	  case 2:
	    if (carptr->car_rpm < DOWN_SHIFT1)
	      carptr->car_gear = 1;				/* 2nd gear			*/
	    break;
	  }

	if (old_gear != carptr->car_gear)			/* If shifting, Adjust RPM	*/
	  carptr->car_rpm = ul_over_us(carptr->car_spd * MAX_RPM,gear_max[carptr->car_gear]);
	else							/* Else, get speed		*/
	  carptr->car_spd = ul_over_us(gear_max[carptr->car_gear] * carptr->car_rpm,MAX_RPM);
}



/*	Get road friction						*/
/*	Entry: 	carptr = car block pointer				*/
/*	Exit:	returns road friction value				*/
car_friction(carptr)
CARBLK	*carptr;
{
	WORD	fric_factr;

	if ((carptr->car_flag & EXT_FRIC) == 0)				/* If no external friction	*/
	  {
	  switch (carptr->car_case)					/* Depends on case		*/
	    {
	    default:							/* Default to road friction		*/
	    case CC_DRIVE:
	      if (carptr->car_case == CC_SPIN)
	        fric_factr = SPIN_FRIC;
	      else
	        fric_factr = ROAD_FRIC;

	      if (carptr->car_flag & ON_SHOULDER)			/* If on shoulder of road		*/
	        fric_factr = SHLDR_FRIC;
	      else
	        {
	        if (carptr->car_flag & ON_DIRT)				/* If off road				*/
	          fric_factr = OFF_FRIC;
	        }
	      break;

	    case CC_BURNOUT:
	    case CC_ROLL:
	    case CC_ENDO:
	      fric_factr = ROLL_FRIC;
	      break;
	    }

	  return((carptr->car_spd / fric_factr) + MIN_FRIC);
	  }
	else
	  return(0);							/* External friction is being used	*/
}



/*	Car dust clouds			*/
car_dust(carptr)
CARBLK	*carptr;
{
	MDTYPE	*op;
	long	dxpos,dypos;
	short	dir,da,scale,xoff,zspd;
	WORD	mask;

	if (carptr->car_flag & (ON_SHOULDER | ON_DIRT))
	  scale = 0x20;
	else
	  {
	  if ((carptr->car_flag & SKIDDING) || (carptr->car_case == CC_BURNOUT))
	    scale = 0;
	  else
	    return;							/* No dust				*/
	  }
									/* Set rate mask			*/
	if (carptr->car_flag & PLR_CAR)
	  mask = 3;
	else
	  mask = 7;

	if (((carptr->op->flags & MO_SCRN) == 0) ||			/* Car must be on screen		*/
	   (carptr->car_spd < 0x10) || (frame & mask))
	  return;

	zspd = 6;							/* Default zspd for dust		*/

	switch (carptr->car_case)
	  {
	  case CC_BURNOUT:
	    zspd = 10;
	  
	  case CC_DRIVE:
	  case CC_SPIN:
	  case CC_BOUNCE:
	    if (frame & (mask+1))
	      {									/* Get x/y dust offsets from car	*/
	      xoff = dust_xoff[carptr->op->ad1];
	      dxpos = carptr->op->xpos + xoff;
	      dypos = carptr->op->ypos + dust_yoff[carptr->op->ad1];
	      }
	    else
	      {
	      da = carptr->op->ad1 - 0x30;					/* Calculate "opposite" tire angle	*/
	      if (da < 0) da += 96;
	      dir = 0x30 - da;
	      if (dir > 96) dir -= 96;
	      if (dir < 0) dir += 96;						/* Get x/y dust offsets from car	*/
	      xoff = -(dust_xoff[dir]);
	      dxpos = carptr->op->xpos + xoff;
	      dypos = carptr->op->ypos + dust_yoff[dir];
	      }

	    if (dypos < 0) dypos += world_len;					/* Wrap neg dust			*/
										/* Setup the dust			*/
	    op = &obj[setobj(&dust2blk,dxpos,dypos,carptr->op->zpos,scale,0)];
     	    op->xspd = (xoff >> 6) + viewx_spd;
 	    op->yspd = carptr->car_yspd - 0x60;
 	    op->zspd = zspd;
	    break;

 	  default:
	    break;
	  }
}


/*	Car puffs dust				*/
car_puff(carptr)
CARBLK	*carptr;
{
	MDTYPE	*op;
	long	dxpos,dypos;
	short	dir,da;

	if (((carptr->car_flag & PLR_CAR) == 0) ||				/* Must be player			*/
	   ((carptr->op->flags & MO_SCRN) == 0) ||				/* Car must be on screen		*/
	   (carptr->car_flag & (ON_SHOULDER | ON_DIRT))) return;		/* Not when off road			*/
										/* Get right tire offsets from car	*/
	dxpos = carptr->op->xpos + dust_xoff[carptr->op->ad1];
	dypos = (carptr->op->ypos - carptr->car_yspd) + dust_yoff[carptr->op->ad1];
	if (dypos < 0) dypos += world_len;					/* Wrap neg dust			*/
	op = &obj[setobj(&dust1blk,dxpos,dypos,carptr->op->zpos,0,0)];
  	op->xspd = carptr->car_xspd - (carptr->car_xspd >> 3);
	op->yspd = carptr->car_yspd - (carptr->car_yspd >> 3);

	da = carptr->op->ad1 - 0x30;					/* Calculate left tire angle		*/
	if (da < 0) da += 96;
	dir = 0x30 - da;
	if (dir > 96) dir -= 96;
	if (dir < 0) dir += 96;						/* Get x/y dust offsets from car	*/
	dxpos = carptr->op->xpos - dust_xoff[dir];
	dypos = (carptr->op->ypos - carptr->car_yspd) + dust_yoff[dir];
	if (dypos < 0) dypos += world_len;					/* Wrap neg dust			*/
	op = &obj[setobj(&dust1blk,dxpos,dypos,carptr->op->zpos,0,0)];
  	op->xspd = carptr->car_xspd - (carptr->car_xspd >> 3);
	op->yspd = carptr->car_yspd - (carptr->car_yspd >> 3);
}



/*	Setup car body				*/
set_body(op,i)
MDTYPE	*op;
int	i;
{
	MDTYPE	*lop;
	CARBLK	*carptr;

	lop = &obj[op->lock];					/* Get master's obj addrs	*/
	carptr = (CARBLK *)lop->uptr;				/* Get master's carblk addrs	*/
	carptr->body_ptr = op;					/* Store body obj pointer in car block	*/

	set_dot(carptr);					/* Set my little map dot		*/
	return(0);						/* Everything OK!		*/
}



/*	Setup car shadow				*/
set_shadow(op,i)
MDTYPE	*op;
int	i;
{
	MDTYPE	*lop;
	CARBLK	*carptr;

	lop = &obj[op->lock];					/* Get master's obj addrs	*/
	carptr = (CARBLK *)lop->uptr;				/* Get master's carblk addrs	*/
	carptr->shdo_ptr = op;					/* Store shadow obj pointer in car block	*/

	return(0);						/* Everything OK!		*/
}



/*	Start car End-over-end sequence						*/
/*	ENTRY:	carptr = pointer to car block					*/
/*		len = (0 for double endo, 1 for short endo)			*/
/*		remchk = if TRUE, do remote check				*/	
start_endo(carptr,len,remchk)
CARBLK	*carptr;
int	len;
int	remchk;
{
	short	drn_idx;

	if (chg_ccase(carptr,CC_ENDO))				/* If car case can change	*/
	  {
	  if (remchk)						/* If we need remote check	*/
	    {
	    drn_idx = carptr->op->type - DRONE0_TYPE;		/* Get drone type index		*/

	    if ((drn_idx >= 0) &&				/* I'm a remote drone (or player)	*/
	       (drtable[drn_idx]->drn_type != plyrno))
	      return;						/* Don't do endo (remote process will do it)	*/
	    }
	  
	  carptr->car_flag |= ENDO_ON;				/* Flag endo ON			*/

	  if (len)
	    {
	    carptr->op->seqn = endo1;				/* Do short endo picture		*/
	    carptr->shdo_ptr->seqn = shd_endo1;			/* Endo the shadow too			*/
	    carptr->op->ad3 = TRUE;				/* Flag short endo			*/
	    }
	  else
	    {
	    carptr->op->seqn = endo;				/* Two endos 			*/
	    carptr->shdo_ptr->seqn = shd_endo;			/* Endo the shadow too		*/
	    carptr->op->ad3 = FALSE;				/* Flag long endo		*/
	    }

	  carptr->op->ftime = 1;				/* Change palette		*/
	  carptr->op->pal = carptr->body_ptr->pal;		/* To body's			*/
	  carptr->op->flags &= ~MO_DIR;				/* Not a direct pix		*/
	  carptr->op->satime = 1;				/* Start animation		*/
	  carptr->op->ad1 = 97;					/* Flag endo picture for link	*/
	  carptr->op->zoff = ENDO_ZOFF;				/* Set endo zoffset		*/

	  if (carptr->car_zspd < ENDO_ZMIN)			/* If zspd too small...		*/
	    carptr->car_zspd = ENDO_ZMIN;

	  carptr->body_ptr->seqn = (WORD *)BLOCK000;		/* Blank out the body		*/
	  carptr->body_ptr->flags |= (MO_NEW | MO_DIR);		/* Make sure we're in direct mode!	*/
	  carptr->body_ptr->satime = carptr->body_ptr->satime = 0;

	  carptr->shdo_ptr->flags &= ~MO_DIR;			/* Not a direct pix		*/
	  carptr->shdo_ptr->satime = 1;				/* Start animation		*/

	  if (carptr->mir_ptr)					/* If rear view drone active..	*/
	    {
	    carptr->mir_ptr->seqn = dendo;			/* Goto roll picture		*/
	    carptr->mir_ptr->flags &= ~MO_DIR;			/* Not a direct pix		*/
	    carptr->mir_ptr->satime = 1;			/* Start animation		*/
	    }
	  }
}


/*	End of ENDO sequence						*/
/*	Called from script						*/
/*	Entry:	op = object pointer					*/
end_endo(carptr)
CARBLK	*carptr;
{
	carptr->car_flag &= ~ENDO_ON;					/* UNflag ENDO			*/

	carptr->op->ftime = 1;						/* Change palette		*/
	carptr->op->pal = carptr->tire_pal << 4;			/* Restore tire palette		*/
	carptr->op->zoff = 0;						/* Clear zoffset		*/
	carptr->op->flags &= ~MO_AEXT;					/* Clear external event flag	*/
	carptr->body_ptr->yspd = 0;					/* Restore locked offsets	*/
	carptr->shdo_ptr->yspd = 0;

	carptr->car_trg = carptr->car_dir = carptr->car_pic = 0;	/* Set direction		*/
	carptr->op->flags &= ~MO_FLIP;					/* Make sure flip is OFF!	*/

	carptr->op->zpos = carptr->car_ztrg + (ENDO_ZOFF >> 1);		/* Still in air			*/
	carptr->jump_spd = -carptr->car_zspd;				/* With at little bounce	*/
	chg_ccase(carptr,CC_JUMP);					/* Change car case 		*/

	if (carptr->mir_ptr)						/* If rear view drone active..	*/
	  carptr->mir_ptr->flags &= ~MO_FLIP;				/* Make sure flip is OFF!	*/

	car_direct(carptr);						/* Set direct picture mode	*/
	set_angle(carptr);						/* Get picture angle		*/
}


/*	Car gets shot					*/
kill_car(op,type)
MDTYPE	*op;
int	type;
{
	MDTYPE	*sp;
	CARBLK *carptr;

	carptr = (CARBLK *)op->uptr;			/* Get car pointer		*/

	if (carptr->car_case == CC_XPLO)		/* Ignore collision if exploding..	*/
	  return;

	if (op->xpos >= 0)				/* Move sideways		*/
	  {
	  bump_angle(carptr,1);
	  carptr->car_xext += 0x20;
	  }
	else
	  {
	  bump_angle(carptr,-1);
	  carptr->car_xext -= 0x20;
	  }

	sp = &obj[setobj(&splatblk,op->xpos,op->ypos,CAR_ZWIDTH,0,0)];
	sp->yspd = carptr->car_yspd >> 1;
	carptr->car_rpm  -= (carptr->car_rpm >> 2);
	carptr->body_ptr->fpal = MO_PAL30;
	carptr->body_ptr->ftime = 4;

	if (op->type == PLR_TYPE)			/* If player is getting shot	*/
	  thump_req = TRUE;				/* Thump me!			*/

	if (type == PLR_TYPE)				/* If player is shooting...	*/
	  add_score(50);				/* Add 50 points		*/
}



/*	Start car explosion sequence						*/
start_xplo(carptr)
CARBLK	*carptr;
{
	int	doit;

	doit = chg_ccase(carptr,CC_XPLO);				/* Change to explosion		*/

	if (doit)							/* If car case can change	*/
	  {
	  carptr->op->seqn = expl0;					/* Goto endo picture		*/
	  carptr->op->scale = 0xA0;					/* Double the scale		*/
	  carptr->op->ftime = 1;					/* Change palette		*/
	  carptr->op->pal = MO_PAL14;					/* To explosion			*/
	  carptr->op->flags &= ~MO_DIR;					/* Not a direct pix		*/
	  carptr->op->satime = 1;					/* Start animation		*/
	  carptr->op->ad1 = 98;						/* Flag explo picture for link	*/

	  carptr->body_ptr->seqn = (WORD *)BLOCK000;			/* Blank out the body		*/
	  carptr->body_ptr->flags |= (MO_NEW | MO_DIR);			/* Make sure we're in direct mode!	*/
	  carptr->body_ptr->satime = carptr->body_ptr->satime = 0;
	  carptr->shdo_ptr->seqn = (WORD *)BLOCK000;			/* Blank out the shadow		*/
	  carptr->shdo_ptr->flags |= (MO_NEW | MO_DIR);			/* Make sure we're in direct mode!	*/
	  carptr->shdo_ptr->satime = carptr->shdo_ptr->satime = 0;

	  if (carptr->mir_ptr)					/* If rear view drone active..	*/
	    {
	    carptr->mir_ptr->seqn = expl1;			/* Goto little explosion	*/
	    carptr->mir_ptr->ftime = 1;				/* Change palette		*/
	    carptr->mir_ptr->pal = MO_PAL14;			/* To explosion			*/
	    carptr->mir_ptr->flags &= ~MO_DIR;			/* Not a direct pix		*/
	    carptr->mir_ptr->satime = 1;			/* Start animation		*/
	    }

	  if (carptr->op->flags & MO_SCRN)			/* If I'm on screen...		*/
	    com_wrt(S_EXP);					/* Explosion sound		*/

	  carptr->car_spd = carptr->car_rpm = 0;		/* Stop cold			*/
	  carptr->car_yspd = carptr->car_xspd = 0;

	  if (carptr->car_flag & PLR_CAR)			/* If this is the player...	*/
	    set_shake(8);					/* 8 frame shake		*/

	  dot_xplo(carptr);					/* Explode the DOT		*/
	  }

	return(doit);
}



/*	End of XPLO sequence						*/
/*	Called from script						*/
/*	Entry:	op = object pointer					*/
end_xplo(op)
MDTYPE	*op;
{
	CARBLK	*carptr;

	carptr = (CARBLK *)op->uptr;					/* Get car block pointer	*/
	carptr->op->scale = CAR_SCALE;					/* Restore the scale		*/
	carptr->op->ypos += 0x400;					/* Put him in front of the obsticle	*/
	carptr->op->ftime = 1;						/* Change palette		*/
	carptr->op->pal = carptr->tire_pal << 4;			/* Restore palette		*/
	carptr->car_trg = carptr->car_dir = carptr->car_pic = 0;	/* Set direction		*/
	carptr->op->flags &= ~MO_FLIP;					/* Make sure flip is OFF!	*/

	set_burn(carptr);						/* Set burnout			*/

	if (carptr->mir_ptr)						/* If rear view is active...	*/
	  {
	  carptr->mir_ptr->ftime = 1;					/* Change palette		*/
	  carptr->mir_ptr->pal = carptr->body_ptr->pal;			/* Restore palette		*/
	  }

	car_direct(carptr);						/* Set direct picture mode	*/
	set_angle(carptr);						/* Get picture angle		*/
}



/*	Bounce the tires while driving			*/
bounce_tires(carptr)
CARBLK	*carptr;
{
	int	shift;
	WORD	spd;

	if (carptr->car_case == CC_BOUNCE) return;	/* No bounce while bouncing (got it?)	*/
	shift = 1;					/* Default body alignment		*/

	if (carptr->car_case != CC_ENDO) 		/* Don't mess with zoff on endo		*/
	  {
	  if (carptr->op->zoff)				/* If bouncing...			*/
	    carptr->op->zoff -= 2;			/* Put wheels back			*/
	  else
	    {
	    if (carptr->car_flag & (ON_SHOULDER | ON_DIRT))
	      {
	      if (carptr->car_spd == 0)				/* Get speed index			*/
	        spd = 0;
	      else
	        spd = 5;					/* Max bounce on dirt			*/

	      shift = 0;					/* Bounce body too			*/
	      }
	    else
	      {
	      spd = carptr->car_spd >> 7;			/* Get speed index			*/
	      }

	    if (spd && ((frame & bounce_mask[spd]) == 0))
	      carptr->op->zoff = (random(3) << 1);
	    }
	  }

	carptr->body_ptr->yspd = carptr->op->zoff >> shift;		/* Align body			*/

	move_shadow(carptr);
}


/*	Align and move the car shadow			*/
/*	ENTRY:	carptr = car block pointer		*/
move_shadow(carptr)
CARBLK	*carptr;
{
	carptr->shdo_ptr->yspd = ((carptr->op->zpos - carptr->car_ztrg) + carptr->op->zoff) >> 1;
}



/*	Rotate the tires				*/
rotate_tires(carptr)
CARBLK	*carptr;
{
	int	i,j;
	WORD	*outptr,*inptr;
	BYTE	skip;

	skip = 0;						/* Default no rotate		*/
								/* Check for wrap 		*/
	if ((carptr->next_rot - carptr->lasty) > (world_len >> 1))
	  carptr->next_rot -= world_len;

	if (carptr->lasty > carptr->next_rot)			/* Time to rotate?	*/
	  {
	  while (carptr->lasty > carptr->next_rot)
	    {
	    skip++;
	    carptr->next_rot += TIRE_ROT;
	    }

	  if (skip > 3) skip = 3;				/* Flag normal rotation		*/
	  carptr->cblk0->r.ctimer = skip;

	  if (skip > 2) skip = 2;
	  carptr->cblk1->r.ctimer = skip;

	  if (carptr->car_flag & PLR_CAR)			/* If this is the player...	*/
	    {							/* Do the wierd rotation	*/
	    j = carptr->tire_rot;				/* Get current rotation index	*/
	    j += skip;						/* Add skip to rotation index	*/
	    if (j > 2) j -= 3;					/* Wraps at 3			*/

	    outptr = &mocolr[carptr->op->pal + 21];		/* Get first output location	*/
	    inptr = &tirepal3[j];				/* Get first input location	*/

	    for (i=0; i < 6; i++)				/* Store 6 colors		*/
	      {
	      *outptr++ = *inptr;				/* Store color			*/
	      inptr += rot_off[i+j];				/* Use pulse offset table	*/
	      }

	    carptr->tire_rot = j;				/* Save new index		*/
	    }
	  }
}



/*	Setup Car picture tables			*/
carpix(op)
MDTYPE	*op;
{
	CARBLK	*carptr;
	WORD	*wp;

	carptr = (CARBLK *)op->uptr;					/* Get carblk pointer		*/

	carptr->wheels = wheels[op->ad2];				/* Get table base addrs		*/
	wp = carptr->wheels;						/* Get table base			*/
	op->seqn = (WORD *)wp[op->ad1];					/* Get current picture		*/
	op->flags |= (MO_DIR | MO_NEW);					/* Goto direct picture mode	*/
	op->satime = op->catime = 0;					/* No animation			*/

	carptr->bodys = bodys[op->ad2];					/* Get table base addrs		*/
	wp = carptr->bodys;						/* Get table base			*/
	carptr->body_ptr->seqn = (WORD *)wp[op->ad1];			/* Get current picture		*/
	carptr->body_ptr->flags |= (MO_DIR | MO_NEW);			/* Goto direct picture mode	*/
	carptr->body_ptr->satime = carptr->body_ptr->catime = 0;	/* No animation			*/

	carptr->shadows = shds;						/* Get table base addrs		*/
	wp = carptr->shadows;						/* Get table base			*/
	carptr->shdo_ptr->seqn = (WORD *)wp[op->ad1];			/* Get current picture		*/
	carptr->shdo_ptr->flags |= (MO_DIR | MO_NEW);			/* Goto direct picture mode	*/
	carptr->shdo_ptr->satime = carptr->shdo_ptr->catime = 0;	/* No animation			*/
}



/*	Change car to direct picture mode			*/
car_direct(carptr)
CARBLK	*carptr;
{
	carptr->op->flags |= MO_DIR;					/* Goto direct picture mode	*/
	carptr->op->satime = carptr->op->catime = 0;				/* No animation			*/

	carptr->body_ptr->flags |= MO_DIR;				/* Goto direct picture mode	*/
	carptr->body_ptr->satime = carptr->body_ptr->catime = 0;	/* No animation			*/

	carptr->shdo_ptr->flags |= MO_DIR;				/* Goto direct picture mode	*/
	carptr->shdo_ptr->satime = carptr->shdo_ptr->catime = 0;	/* No animation			*/

	if (carptr->mir_ptr)						/* If rear view drone acitve..	*/
	  {
	  carptr->mir_ptr->flags |= MO_DIR;				/* Goto direct picture mode	*/
	  carptr->mir_ptr->satime = carptr->mir_ptr->catime = 0;	/* No animation			*/
	  }
}


/*	Change car case				*/
chg_ccase(carptr,new_case)
CARBLK	*carptr;
BYTE	new_case;
{
	int	doit;

	switch (carptr->car_case)
	  {
	  default:
	  case CC_BURNOUT:
	    if ((new_case == CC_BURNOUT) || (new_case == CC_DRIVE))		/* Get valid cases		*/
	      doit = TRUE;
	    else
	      doit = FALSE;
	    break;
	    
	  case CC_DRIVE:
	  case CC_JUMP:
	  case CC_BOUNCE:
	    doit = TRUE;
	    break;

	  case CC_SPIN:
	    if (new_case == CC_SPIN)					/* Check invalid cases		*/
	      doit = FALSE;
	    else
	      doit = TRUE;
	    break;

	  case CC_ROLL:
	    if ((new_case == CC_ROLL) || (new_case == CC_JUMP))		/* Check invalid cases		*/
	      doit = FALSE;
	    else
	      doit = TRUE;
	    break;

	  case CC_ENDO:
	    if (carptr->car_flag & ENDO_ON)				/* If doing endo		*/
	      doit = FALSE;
	    else
	      doit = TRUE;
	    break;

	  case CC_XPLO:
	    if (new_case == CC_XPLO)					/* Check invalid cases		*/
	      doit = FALSE;
	    else
	      doit = TRUE;
	    break;
	  }

	if (doit)
	  carptr->car_case = new_case;					/* Set new case and exit	*/

	return(doit);
}


/*	Setup burnout mode			*/
set_burn(carptr)
CARBLK	*carptr;
{
	if (chg_ccase(carptr,CC_BURNOUT))
	  {
	  carptr->car_flag |= (START_BURN | MID_BURN);	/* Start up burnout			*/
	  carptr->burn_max = BURN_MAX;

	  if (random(1))					/* Set random burnout direction		*/
	    carptr->burn_dir = BURN_TICK;
	  else
	    carptr->burn_dir = -BURN_TICK;
	  }
}


