/*======================================================================*/
/*	Car structures and defines					*/
/*======================================================================*/

/*	Car model info block	*/
typedef	struct	carblk
	{
	struct	links carlnk;			/* Car linked list			*/
	MDTYPE	*op;				/* Pointer to car's (tires) obj structure	*/
	MDTYPE	*body_ptr;			/* Pointer to body's obj structure	*/
	MDTYPE	*shdo_ptr;			/* Pointer to shadow's obj structure	*/
	MDTYPE	*mir_ptr;			/* Pointer to image in rear view mirror	*/
	CANIM_BLOCK *cblk0;			/* Color rotate blocks			*/
	CANIM_BLOCK *cblk1;
	WORD	(*wheels)[];			/* Wheel picture table			*/
	WORD	(*bodys)[];			/* Body picture table			*/
	WORD	(*shadows)[];			/* Shadow picture table			*/
	long	lasty;				/* Last y position for tire rotate	*/
	long	next_rot;			/* Next boundary for tire rotate	*/
	short	car_spd;			/* Current speed 			*/
	short	car_rpm;			/* RPM					*/
	short	car_xspd;			/* Component xspeed			*/
	short	car_yspd;			/* Component yspeed			*/
	short	car_zspd;			/* Component zspeed			*/
	short	car_ztrg;			/* Target zposition			*/
	short	car_dir;			/* Current direction			*/
	short	car_trg;			/* Target direction			*/
	short	car_pic;			/* Current picture direction		*/
	short	slew_dir;			/* Direction slew save			*/
	short	spin_dir;			/* Spinout direction			*/
	short   car_xext;			/* External x speed 			*/
	short   car_yext;			/* External y speed			*/
	short   jump_spd;			/* Jump speed				*/
	short	slope;				/* Current slope of track		*/
	short	burn_dir;			/* Burnout direction			*/
	short	burn_max;			/* Burnout limit			*/
	WORD	car_flag;			/* Flags				*/
	WORD	tire_skid;			/* Value at which tires skid		*/
	WORD	car_spin;			/* Car spin threshold			*/
	BYTE	car_case;			/* Car case				*/
	BYTE	car_gear;			/* Gear					*/
	BYTE	tire_rot;			/* Tire rotation index			*/
	BYTE	tire_pal;			/* Tire palette save			*/
	} CARBLK;

/*----------------------------------------------*/
/*	Flag bits in carptr->car_flag		*/
/*----------------------------------------------*/
#define	ON_SHOULDER	0x8000
#define	ON_DIRT		0x4000
#define	EXT_FRIC	0x2000
#define	SPIN_START	0x1000
#define	SKIDDING	0x0800
#define	BOUNCE		0x0400
#define	PLR_CAR		0x0200
#define	BUMPING		0x0100
#define	ENDO_ON		0x0080
#define	ON_EDGE		0x0040
#define	MID_BURN	0x0020
#define	START_BURN	0x0010

/*----------------------------------------------*/
/*	Car cases 				*/
/*----------------------------------------------*/
#define	CC_BURNOUT	0
#define	CC_DRIVE	1
#define	CC_SPIN		2
#define	CC_JUMP		3
#define	CC_BOUNCE	4
#define	CC_ROLL		5
#define	CC_ENDO		6
#define	CC_XPLO		7


/*----------------------------------------------*/
/*	Car constants				*/
/*----------------------------------------------*/
#define	MAX_CARS	5
#define	CAR_RAD		0x200
#define	CAR_ZWIDTH	0x20
#define	TIRE_ROT	0x100
#define	ENDO_ZMIN	0x30
#define	ROLL_LIMIT	0x2800

#define	TIRE0		0x400
#define	TIRE1		0x500
#define	TIRE2		0x600
#define	TIRE3		0x780

#define	SPIN0		0x400
#define	SPIN1		0x500
#define	SPIN2		0x600
#define	SPIN3		0x700

#define	BURN_TICK	0x100
#define	BURN_MAX	0xC00
