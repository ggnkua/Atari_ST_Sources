/*======================================================================*/
/*	Drone  structures and defines					*/
/*======================================================================*/

/*	DRONE info block	*/
struct	drnblk
	{
	MDTYPE	*op;				/* Pointer to drone's obj structure	*/
	CARBLK	*car_ptr;			/* Pointer to drone's car structure	*/
    long    drn_yabs;			/* absolute y position */
    struct drnblk   *drn_next;		    /* pointer to  drone in front of this one */
	short	drn_tspd;			/* target speed	*/
	short	drn_timer;			/* timer for shot delay */
    short    drn_agro;			/* drone aggressiveness */
	BYTE	drn_lap;		    /* laps completed */
	BYTE	drn_type;			/* drone control type */
    BYTE    drn_state;			/* state for animation */
	BYTE	drn_case;			/* drone case */
    short   drn_cnt;			/* drone counter for case changes */
    short   drn_wins;			/* win count for remote drones */
	};

typedef	struct	drnblk  DRNBLK;
/*----------------------------------------------*/
/*	drn types		*/
/*----------------------------------------------*/
#define	DR0			0x00
#define	DR1			0x01
#define	DR2			0x02
#define	DR3			0x03
#define	REMOTE		0x04

/* offset between plyrno and that players' drone */ 
#define DRNOFFSET  0x02

/*----------------------------------------------*/
/*	drone states (for animating across the link */
/*----------------------------------------------*/
#define	DROLL		1
#define DENDO		2
#define DXPLO		3

/*----------------------------------------------*/
/* Drone cases - */
/*----------------------------------------------*/
#define DPASS     0
#define DHOVER0    1
#define DHOVER1    1
#define DBLAST     2

