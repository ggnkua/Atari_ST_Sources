/*======================================================================*/
/*		TITLE:			MAIN				*/
/*		Function:		Main Driver & related routines	*/
/*									*/
/*		First Edit:		10/01/88			*/
/*		Project #:						*/
/*		Programmer:		Dennis Harper			*/
/*									*/
/*		COPYRIGHT 1988/1989 ATARI GAMES CORP.			*/
/*	  UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,		*/
/*	  PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR		*/
/*	THE ASSOCIATED AUDIOVISUAL WORK	IS STRICTLY PROHIBITED.		*/
/*	       		ALL RIGHTS RESERVED.				*/
/*									*/
/*----------------------------------------------------------------------*/

#ifdef ARIUM

#include	"prog/inc/rrdef.h"
#include	"prog/inc/mobinc.h"
#include	"prog/inc/hrdwmap.h"
#include	"prog/inc/buttons.h"
#include	"prog/inc/message.h"
#include	"prog/inc/gcode.h"
#include	"prog/inc/plrcase.h"
#include	"prog/inc/audio.h"
#include	"prog/inc/eeprom.h"
#include	"prog/inc/spchars.h"
#include	"prog/inc/states.h"
#include	"prog/inc/structs.h"
#include	"prog/inc/carinc.h"
#include	"prog/inc/comminc.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"inc:hrdwmap.h"
#include	"inc:buttons.h"
#include	"inc:message.h"
#include	"inc:gcode.h"
#include	"inc:plrcase.h"
#include	"inc:audio.h"
#include	"inc:eeprom.h"
#include	"inc:spchars.h"
#include	"inc:states.h"
#include	"inc:structs.h"
#include	"inc:carinc.h"
#include	"inc:comminc.h"

#endif

#define	SHELL_ON	FALSE

#define BLACK   (0x0000)

#define HOSTTIME (6 * 32 )
#define BEGTIME  (10 * 32 )
#define	BEGRATE		3

#define	T_ERASE		0
#define	T_CHK		1
#define	T_CNTWIN	2
#define	T_PAUSE		3
#define	T_NEXT		4
#define	T_HAZ		5
#define	T_COMP1		6
#define	T_COMP2		7
#define	T_TOTAL1	8
#define	T_SCWAIT	9
#define	T_END		10
#define	TALLY_DONE	0x80
#define	SCORE_DONE	0x40

#define	MAX_MONEY	16
#define	MAX_PRIZE	10
#define	BILL_ON		0x80
#define	MIDSCREEN	0x2A00
#define	BOTTOM_SCREEN	0x3D00

typedef	struct	monyblk
	{
	MDTYPE	*op;
	short	xspd;
	short	yspd;
	} MONYBLK;

typedef	struct	przblk
	{
	MDTYPE	*op;
	MDTYPE	*bill;
	} PRZBLK;


extern	MDTYPE	*pp,*cur_op;
extern	MDTYPE	obj[];
extern	MRTYPE	moram[];
extern	MOBLK	win1blk,firstblk,first2blk,snogirlsblk,secondblk,thirdblk,endwinblk,end2ndblk;
extern	MOBLK	mask0blk,mask1blk,bill0blk,bill1blk;
extern	MOBLK	fgleftblk,fgrightblk,boxblk,mony0blk,mony1blk,ladablk;
extern	MOBLK	prz0blk,prz1blk,prz2blk,prz3blk,prz4blk,prz5blk,prz6blk,prz7blk,prz8blk,prz9blk;
extern	PFI	escape;
extern	CARBLK	*plrcar;
extern	ulong	wave_score,plr_score,oplr_score,coldsp;
extern  long    credits;
extern	long	next_rot,world_len;
extern	long	old_ypos,viewy_bb;
extern  long    waitget, waitput;
extern	WORD	*bnums[],bnumpal[],*fail_tbl[],*instr_tbl[];
extern	WORD	curx[],cury[],trophyx[],trophyy[],bill1[];
extern	WORD	plr_flag,endmo;
extern	WORD	button,frame;
extern	WORD	edit_world;
extern	WORD	wave,leg,leg_num,weapons;
extern	WORD	strip_num;
extern	short	bottom_dy;
extern	short	plr_yacc;
extern	short	freeze_tmr;
extern  short   firecnt;
extern	BYTE	MAX_TRK;
extern	BYTE	pots[],leg_tbl[];
extern	BYTE	plr_case;
extern	BYTE	new_creds;		/* new credits flag		*/
extern	BYTE	wave_tbl[];		/* wave table			*/
extern	BYTE 	*tctable[];
extern	BYTE	fingirl_on;
extern	BYTE	tally_flags,otally_flags;
extern  WORD    plyrno;			/* number for this player */
extern  WORD    mcpno;			/* number of controlling player */
extern CTLPKT  *ptable[];		/* tables of communication packets */
extern char    plr_lap;			/* laps completed */
extern char    plr_rank;		/* players rank */
extern char    old_rank;		/* rank in the previous race */
extern BYTE    newwld;			/* new world for linked game */
extern BYTE    otherramp;		/* ramping level for other player */
extern BYTE    oldramp;			/* old ramping value */
extern BYTE    comp;			/* true if competin against linked machines */
extern BYTE    old_comp;		/* true if preceeding race was linked */
extern BYTE    active[];		/* active systems */
extern BYTE    ramp;
extern BYTE    world_laps;		/* max laps for this world */
extern WORD    WIN000[], winpal[];
extern WORD    WAIT000[], waitpal[];
extern WORD    hostpal[],beginpal[];
extern	WORD	przpal0[],przpal1[];
extern WORD    HOST000[], HOST001[], HOST002[], HOST003[];
extern WORD    HOST004[], HOST005[], HOST006[], HOST007[];
extern WORD    HOST008[], HOST009[], HOST010[], HOST011[];
extern	WORD	BEG007[],BEG009[],BEG010[],BEG011[],BEG012[];
extern	WORD	SEL103[],SEL107[];
extern	WORD	LNKR000[],LNKR001[],lnkrpal0[],lnkrpal1[],lnkrpal3[];
extern	WORD	LNKR010[],LNKR011[],LNKR012[],LNKR013[];
extern	WORD	LNKR014[],LNKR015[],LNKR016[],LNKR017[];
extern WORD	   atstate;			/* attract state 	*/
extern int     newcoins;		/* true if new coins */
extern  BYTE   linkwrks;

#ifdef	DEVELOPMENT
extern	WORD	auxsw,joystick;
#endif

	MONYBLK	monys[MAX_MONEY];	/* Falling money		*/
	PRZBLK	prz_blks[MAX_PRIZE];	/* Prize object array		*/
	PFI	setup;
	MDTYPE	*fgptr;			/* Flag Girl pointer		*/
	ulong	frgdsp;			/* Forground routine dispatches */
	ulong	bckdsp;			/* Background routine dispatches */
	long	strip_front;		/* Next strip boundary		*/
	long	strip_back;		/* Last strip boundary		*/
	long	strip_horizon;		/* Horizon strip boundary	*/
	long	viewx,viewy;		/* View point			*/
	long	winnings,complete,hazard,temp_cnt;	/* Point buckets	*/
	long	long_time;		/* Long timer			*/
	short	viewz,viewz_trg;	/* Viewz			*/
	short	height;			/* Playfield height		*/
	WORD	gstate;			/* Game state			*/
	WORD	gcount;			/* Game state counter		*/
	WORD	hosttime;		/* Host screen timer		*/
	WORD	nstate;			/* Next Game state		*/
	WORD	mailbx;			/* Mailbox			*/
	WORD	world;			/* Current world index		*/
	WORD	win_hoff;		/* Win screen hoffset		*/
	short	strip_cur;		/* Current strip number		*/
	short	strip_old;		/* Last strip number		*/
	short	viewx_spd,viewy_spd,viewz_spd;	/* View speeds		*/
	short	viewz_off;		/* View offsets			*/
	short	viewy_trg;		/* Viewy target speed		*/
	short	tdist;			/* Target distance from view	*/
static	BYTE	bsync;			/* Backround sync		*/
	BYTE	frzflag;		/* Freeze on			*/
	BYTE	game;			/* TRUE if playing game		*/
	BYTE	acc_case;		/* Viewpoint acceleration mode	*/
	BYTE	xlock;			/* Window xlock case 		*/
	BYTE	start_ok;		/* TRUE if ok to start game	*/
 	BYTE    decline;		/* true if player declined a challenge */
	BYTE	wincnt;			/* count of consecutive wins */
	BYTE	race;			/* Race index for tally		*/
	BYTE	race_cnt;		/* Race complete counter	*/
	BYTE	tally_case;		/* Tally case			*/
	BYTE	tnext;			/* Next tally case		*/
	BYTE	iidx;			/* Instruction index		*/
	BYTE	happy;			/* Happy music on flag		*/
	BYTE	prize_cur;		/* Current prize index		*/
	char	tally_tmr;		/* Tally timer			*/
	char	pausetmr;		/* Pause timer			*/
	char	viewy_acc;		/* Viewy acceleration		*/
	char	instr_tmr;
    BYTE    etimer;			/* timer for erasing messages */
    BYTE    solo;			/* true if player choose solo game */
    LTIMER  plaptime; 		/* player lap timer */
    ulong   shakes;			/* shaker on count */
    short   thumpcnt;		/* count of thumps */

	long	move_view();

	PFI	fdisp0[]={&move_toy(),&set_volume(),&say_delay(),&dec_anc(),
			 &money(),&move_prizes(),&fireworks(),&tally_wait(),
			 &bomb(),&bomb1(),&hit(),&hit1(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts()};


	PFI	bdisp[]={&ttlmud(),&make_plf(),&draw_needle(),&disp_score(),
			 &disp_lap(),&erase_go(),&last_flash(),&chk_altera(),
			 &mob_norm(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts(),
			 &rts(),&rts(),&rts(),&rts()};

	char	chase_spd[]={-0x04,0x00,0x04,0x08,0x10,0x14,0x18,0x20};
	char	chase_acc[]={0x02,0x02,0x04,0x08,0x0C,0x10,0x18,0x20};

	MT2	govrmess = {12,14,"GAME OVER",0};

	MT2	waitmsg4 = {12,26,"                    ",0};
	MT	waitmsg3 = {12,25," PLAYER TO JOIN IN. ",2,&waitmsg4};
	MT	waitmsg2 = {12,23," WAITING FOR OTHER  ",2,&waitmsg3};
	MT	waitmsg1 = {12,22,"                    ",2,&waitmsg2};

    
    MT2 bailmsg   = {3,28," PULL BOTH TRIGGERS TO PLAY SOLO GAME!", 0 };

	MT2	lwaitmsg4 = {12,26,"                    ",0};
	MT	lwaitmsg3 = {12,25," PLAYER TO FINISH.  ",2,&lwaitmsg4};
	MT	lwaitmsg2 = {12,23," WAITING FOR OTHER  ",2,&lwaitmsg3};
	MT	lwaitmsg1 = {12,22,"                    ",2,&lwaitmsg2};


    MT2 readymsg = { 16, 8,"READY", 0 };
    MT2 setmsg   = { 16, 8," SET ", 0 };
    MT2 gomsg    = { 16, 8," GO! ", 0 };


	MT2 title2 = {  1,23,"YOUR HOST THIS RACE", 0 };

    MT2 tname2b = { 27, 09, "IOWA", 0 };
    MT  tname2a = { 23, 06, "CHARITON", 2, &tname2b };
    MT2 tname2  = { 21, 02, "DIRT TRACK", 0 };

    MT2 tname3b = { 25, 09, "DESERT", 0 };
    MT  tname3a = { 24, 06, "ARABIAN", 2, &tname3b };
    MT2 tname3  = { 21, 02, "SAND TRACK", 0 };

    MT2 tname4c = { 23, 12, "REDWOODS", 0 };
    MT  tname4b = { 21, 09, "CALIFORNIA", 2, &tname4c };
    MT  tname4a = { 26, 06, "UKIAH", 2, &tname4b };
    MT2 tname4  = { 22, 02, "MUD TRACK", 0 };

    MT2 tname5b = { 27, 11, "OHIO", 0 };
    MT  tname5a = { 26, 08, "AKRON", 2, &tname5b };
    MT2 tname5x = { 26, 04, "TRACK", 0 };
    MT  tname5  = { 25, 02, "STREET", 2, &tname5x };

    MT2 tname6b = { 25, 09, "DESERT", 0 };
    MT  tname6a = { 22, 06, "LAS VEGAS", 2, &tname6b };
    MT2 tname6  = { 21, 02, "DIRT TRACK", 0 };

    MT2 tname7a = { 21, 08, "SOUTH POLE", 0 };
    MT2 tname7  = { 22, 02, "ICE TRACK", 0 };

    MT2 tname8c = { 25, 12, "DESERT", 0 };
    MT  tname8b = { 25, 09, "MEXICO", 2, &tname8c };
    MT  tname8a = { 27, 06, "BAJA", 2, &tname8b };
    MT2 tname8  = { 21, 02, "SAND TRACK", 0 };

    MT2 tname9c = { 21, 11, "NEW JERSEY", 0 };
    MT  tname9b = { 25, 09, "VALLEY", 2, &tname9c };
    MT  tname9a = { 26, 07, "ROUND", 2, &tname9b };
    MT2 tname9x = { 27, 03, "ROAD", 0 };
    MT  tname9  = { 25, 01, "COUNTY", 2, &tname9x };

    MT2 tname10b = { 24, 09, "OUTBACK", 0 };
    MT  tname10a = { 25, 06, "AUSSIE", 2, &tname10b };
    MT2 tname10  = { 21, 02, "ROCK TRACK", 0 };

    MT2 tname11b = { 27, 09, "ALPS", 0 };
    MT  tname11a = { 26, 06, "SWISS", 2, &tname11b };
    MT2 tname11  = { 21, 02, "SNOW TRACK", 0 };

    MT2 tname12b = { 25, 11, "AFRICA", 0 };
    MT  tname12a = { 23, 08, "TIMBUKTU", 2, &tname12b };
    MT2 tname12x = { 26, 04, "TRACK", 0 };
    MT  tname12  = { 26, 02, "VELDT", 2, &tname12x };


	char *tnames[] = {  
						&tname2, &tname2, &tname3, &tname4,
						&tname5, &tname6, &tname7, &tname8,
						&tname9, &tname10, &tname11, &tname12,
					 };

	char *tnamesa[] = {  
						&tname2a, &tname2a, &tname3a, &tname4a,
						&tname5a, &tname6a, &tname7a, &tname8a,
						&tname9a, &tname10a, &tname11a, &tname12a,
					 };

    MT2 host1  = {  4, 25, "???", 0 };

    MT2 host2a = {  6, 27, "SINUS", 0 };
    MT  host2  = {  6, 25, "LUCAS", 2, &host2a };
 
    MT2 host3a = {  4, 27, "AH LEGG", 0 };
    MT  host3  = {  5, 25, "SHEIK", 2, &host3a };

    MT2 host4a = {  8, 27, "BEN", 0 };
    MT  host4  = {  2, 25, "BACKWOODS", 2, &host4a };

    MT2 host5a = {  6, 27, "NELSON", 0 };
    MT  host5  = {  6, 25, "NASTY", 2, &host5a };

    MT2 host6a = {  6, 27, "VEGAS", 0 };
    MT  host6  = {  6, 25, "ELVIS", 2, &host6a };

    MT2 host7a = {  4, 27, "ARCTICA", 0 };
    MT  host7  = {  5, 25, "AUNTIE", 2, &host7a };

    MT2 host8a = {  6, 27, "BERTHA", 0 };
    MT  host8  = {  6, 25, "BAJA", 2, &host8a };

    MT2 host9a = {  4, 27, "McREADY", 0 };
    MT  host9  = {  4, 25, "CHA CHA", 2, &host9a };

    MT2 host10a = {  2, 27, "KILLER KARL", 0 };
    MT  host10  = {  6, 25, "KRAZY", 2, &host10a };

    MT2 host11a = {  0, 27, "GROSSEBERGEN", 0 };
    MT  host11  = {  6, 25, "HELGA", 2, &host11a };

    MT2 host12a = {  7, 27, "DADA", 0 };
    MT  host12  = {  1, 25, "IDI A MEAN", 2, &host12a };



	char *hosts[] = {  
					&host1, &host2, &host3, &host4,
					&host5, &host6, &host7, &host8,
					&host9, &host10, &host11, &host12,
                    };

   char *hostpic[] = {
		   HOST009, HOST003, HOST000, HOST001, 
		   HOST002, HOST007, HOST008, HOST006,
                   HOST004, HOST005, HOST010, HOST011,
                     };

	BYTE	host_bank[]={3,2,1,2,
			     3,2,3,1,
			     3,3,2,2};				/* PLF Banks for host pictures	*/

	short	fgx[]={0x1000,-0x1000};

	long	trophy_val[]={0,50000,20000,7000,0};
	BYTE	winsnd[]={0,S_FIRST,S_SECOND,S_THIRD,S_BRNXCHR};

    MT  winmsg = { 12,  7,   "You Won the Race!!", 0 };
    MT  beatmsg = { 9,  7,   "You Beat the Host's Team!", 0 };
    MT  losemsg = { 12, 7,  "     You LOSER!    ", 0 };
    
    MT2 place0 = {38,2, "  ", 0 };
    MT2 place1 = {38,2, "st", 0 };
    MT2 place2 = {38,2, "nd", 0 };
    MT2 place3 = {38,2, "rd", 0 };
    MT2 place4 = {38,2, "th", 0 };

MT *places[] = { &place0, &place1, &place2, &place3, &place4 };

    MT2 addc = { 9,27," ADD COINS to continue", 0 };
    MT2 press = { 9,27,"Press START to continue", 0 };

	MT2   badram3 = { 15, 19,"TEST!",0 };
	MT    badram2 = { 15, 18,"FAILED",2, &badram3 };
	MT    badram  = { 15, 17,"COMMON RAM",2, &badram2 };
	
	MT2   badcom3 = { 15, 19,"GAME",0 };
	MT    badcom2 = { 15, 18,"FROM OTHER",2, &badcom3 };
	MT    badcom  = { 15, 17,"NO RESPONSE",2, &badcom2 };


   MT2   standmsg2 = { 10,3,"IN LAST RACE", 0 };
   MT    standmsg  = { 13,1,"STANDINGS",2,&standmsg2 };

   MT2  lap0msg = { 2,27,"0'00'00", 0 };

	MT2	nmbrmsg = { 10, 26, "#", 0 };
	MT2	entmsg1 = { 18, 24, "INITIALS", 0 };
	MT	entmsg  = { 10, 24, "RANK", 2, &entmsg1 };
	MT2	xclmsg  = { 16, 22, "EXCELLENT!", 0 };

	MT2	tlymsg3 = { 10, 19, "TOTAL:", 0 };

	MT2	tlymsg2a = { 10, 16, "COMPLETE:", 0 };
	MT	tlymsg2  = { 10, 15, "SERIES", 2, &tlymsg2a };

	MT2	tlymsg1a = { 10, 13, " PAY:", 0 };
	MT	tlymsg1 = { 10, 12, "HAZARD", 2, &tlymsg1a };

	MT2	tlymsg0a = { 10, 10, "WINNINGS:", 0 };
	MT	tlymsg0  = { 10,  9, "RACE", 2, &tlymsg0a };

	MT2	tlymsg = { 10, 16, "FINAL SCORE", 0 };

	MT2	congmsg  = { 05, 02, "CONGRATULATIONS!", 0 };
	MT2	congmsg2 = { 07, 06, "** THE TOURNAMENT SERIES **", 0 };
	MT	congmsg1 = { 07, 05, "**   YOU'VE COMPLETED    **", 2, &congmsg2 };

struct	instr
	{
	WORD	*lodapix;
	BYTE	delay;
	BYTE	index;
	} iscript[]={BEG011,4*BEGRATE,-1,
		     BEG009,2*BEGRATE,-1,
		     BEG010,3*BEGRATE,-1,
		     BEG007,10*BEGRATE,0,
		     BEG009,2*BEGRATE,-1,
		     BEG010,3*BEGRATE,-1,
		     BEG007,10*BEGRATE,1,
		     BEG009,2*BEGRATE,-1,
		     BEG010,3*BEGRATE,-1,
		     BEG007,10*BEGRATE,2,
		     BEG009,2*BEGRATE,-1,
		     BEG010,3*BEGRATE,-1,
		     BEG007,10*BEGRATE,3,
		     BEG009,2*BEGRATE,-1,
		     BEG010,3*BEGRATE,-1,
		     BEG007,10*BEGRATE,4,
		     BEG011,6*BEGRATE,-1,
		     BEG012,-1,-1};

	WORD	insty[]={01,04,06,09,12};

	MOBLK	*firstpix[]={&win1blk,&first2blk,&firstblk,&first2blk,
			     &firstblk,&first2blk,&snogirlsblk,&first2blk,
			     &firstblk,&first2blk,&snogirlsblk,&first2blk};

struct	prizes
	{
	MOBLK	*mblk;	
	short	ypos;
	long	startx;
	long	endx;
	short	xspd;
	short	billx;
	short	billy;
	BYTE	sort;
	BYTE	flags;
	} prize_tbl[]={&prz0blk,222*0x40,576*0x40,36*0x40,-0xC0,0x800,0x00,0xF4,BILL_ON|0x40,	/*	Stove		*/
		       &prz1blk,256*0x40,576*0x40,414*0x40,-0x40,0x000,0x00,0xF8,0x00,		/*	Tractor		*/
		       &prz2blk,174*0x40,-60*0x40,420*0x40,0xC0,-0x680,0x300,0xD8,BILL_ON,	/*	Fridge		*/
		       &prz3blk,120*0x40,-60*0x40,200*0x40,0x40,0x000,0x00,0xC8,0x00,		/*	Pickup & Boat	*/
		       &prz4blk,67*0x40,567*0x40,396*0x40,-0x10,0x000,0x00,0xC0,0x00,		/*	747		*/
		       &prz5blk,192*0x40,-60*0x40,136*0x40,0x40,-0xEC0,0x180,0xE4,BILL_ON|0x20,	/*	Stereo		*/
		       &prz6blk,163*0x40,-60*0x40,345*0x40,0xC0,-0xA00,0x240,0xD4,BILL_ON,	/*	La-Z-Boy	*/
		       &prz7blk,168*0x40,-60*0x40,198*0x40,0x80,-0xA40,0x1C0,0xD8,BILL_ON,	/*	BBQ		*/
		       &prz8blk,176*0x40,-60*0x40,87*0x40,0x40,-0xE00,0xC0,0xE2,BILL_ON,	/*	Pool Table	*/
		       &prz9blk,201*0x40,-60*0x40,251*0x40,0x80,-0x8C0,0xC0,0xEC,BILL_ON|0x20};	/*	Vacuum		*/
	


main()
{
	int	i;
	ulong	fdsp0,fdsp1;
	short	wld;

#ifdef	DEVELOPMENT
	time_color(C_CYAN);			/* Cyan			*/
#endif

	if (keep_com() == -1)			/* If 6502 went to Florida	*/
	  frgdsp |= F_VOL;			/* Set the digital volume to last saved	*/

	dopots();				/* Get pot readings	*/

	button = buttons(0,0XFF);		/* Read buttons		*/
	
#ifdef DEVELOPMENT
	auxsw  = buttons(1,0XFF);		/* Read diagnostic switches	*/
	joystick = buttons(2,0XF0);		/* Read joystick	*/

	/* If reset buttons on 	*/
	if ((auxsw & (AUX4_LEV|AUX6_LEV)) == (AUX4_LEV|AUX6_LEV))
	  reset();				/* Reset game		*/

	if (frzflag = freeze()) return;		/* Freeze mode		*/
#endif

	++frame;				/* Frame inc		*/

#ifdef	DEVELOPMENT
	time_color(C_ORANGE);
#endif
	new_view();				/* Do next viewpoint	*/
	make_seg();				/* Make the segment tables	*/

#ifdef	DEVELOPMENT
	time_color(C_RED);
#endif
	modriv();				/* Do MO processing	*/

#ifdef	DEVELOPMENT
	time_color(C_GREEN);
#endif
						/* Dispatch select routines */
	for (i=0,fdsp0=frgdsp; fdsp0 != 0; i++, fdsp0 >>= 1)
	  if (fdsp0 & 1) (*fdisp0[i])();

    com_health();				/* check link condition */
	switch (gstate)				/* Game state driver	*/
	  {
	  case G_ATTRACT:			/* Attract mode		*/
        attract();				/* do attract processing */
	    break;

	  case G_PREDIT:			/* If right stick pushed */
	    wld = world;
#ifdef DEVELOPMENT
	    if (auxsw & AUX6)			/* If edit go pushed	*/
	      {
	      set_world(world);			/* Setup world		*/
	      setmoed();			/* Setup editor		*/
	      gstate = G_MOED;
	      }
	    else
	      {
	      if (joystick & 0xF0)
		{
	        switch (joystick & 0xF0)
		  {
	 	  case JRIGHT:
		    if (++wld >= (WORD)&MAX_TRK)
		      wld = 0;
		    break;

	 	  case JLEFT:
		    if (--wld < 0)
		      wld = (WORD)&MAX_TRK-1;
		    break;
           mcpno = plyrno;
		  }

	        world = wld;
	        set_world(world);	/* Setup world		*/
		}
	      }

		if ( start_check() )
	  	 {
	     com_wrt(S_SON);
 	     ramp = 4;						/* start at middle difficulty */
         oldramp = ramp;

	     game = TRUE;			/* Turn on game state	*/
	     set_world(world);	 		/* Setup world		*/
	     init_player();			/* Setup player		*/
	     init_score();			/* Clear scoring	*/
	     clrtcard(plyrno);			/* clear tournament card */
	     initcomm();				/* Setup comm variables	*/
         comp = FALSE;
         old_comp = FALSE;
         solo = TRUE;
         active[ 0 ] = active[1] = active[2] = active[3] = 0;
         active[ plyrno ] = 1;
	     gcount = 0;				/* Zero count		*/
	     gstate = G_PLAY1;		/* ??? */
		 }
#endif

	    break;

	  case G_CHOOSE:		/* choose stag or drag race  */
        choose();			/*  */
	    break;

	  case G_JOIN1:			/* check for other players */
        join1();			/* wait for other players to join in */
	    break;

	  case G_JOIN2:			/* last chance to join in */
        join2();			/*  */
	    break;

	  case G_LWAIT:			/* wait for chance to Link with other player */
        lwait();			/*  */
	    break;

	  case G_ACCEPT:		/* YOU HAVE BEEN CHALLENGED ! */
        accept();			/*  */
	    break;

	  case G_SELECT:		/* select course */ 
	    select();		
	    break;

	  case G_TITLE:		/* display course title */ 
        gtitle();		
	    break;

	  case G_START:		/* display 3, 2, 1, GO */ 
		gstart();	
	    break;

	  case G_PLAY1:		/* play the game */
	    play1();
	    break;

	  case G_RANKWAVE:	/* rank the players */
	    rankwave();
	    break;

      case G_ENDWAVE:	/* the race is over */
        endwave();
      break;

      case G_WON:		/* display the win screen */
        won();
      break;

      case G_CONT:		/* countdown to continueation */
        cont();
      break;

      case G_OVER:		/* put up game over display */
        gover();
      break;

      case G_DONE:		/* display game over */
        game_done();
      break;

	  case G_MOED:				/* Do MO editor		*/
#ifdef DEVELOPMENT
	    moedit();
#endif
	    break;

	  case G_PAUSE:				/* Pause then nstate	*/
	    pause();
	    break;

	  case G_PAUSE1:			/* Pause, setup the nstate */
	    pause1();
	    break;

	  case G_PAUSE2:			/* Pause, then just setup() */
	    pause2();
	    break;

	  case G_HIS1:
	    high1();
	    break;

	  case G_HISCORE:
	    do_hiscore();
	    break;

	  case G_TALLY1:
	    set_tally();
	    break;

	  case G_TALLY2:
	    do_tally();
	    break;

	  case G_AWARD1:
	    award1();
	    break;

	  case G_FWAIT1:			/* Fade wait #1		*/
	    fade_wait1();
	    break;

	  case G_FWAIT2:			/* Fade wait #2		*/
	    fade_wait2();
	    break;

	  case G_CRAMTST:			/* test the common ram */
	    tcomm2();
	    break;

	  case G_DIFFTST:			/* compare the difficulty levels */
	    difftst();
	    break;

	  case G_GETSYNC:			/* compare the difficulty levels */
	    do_sync();
	    break;

	  default:
	  case G_WAIT:				/* Just wait!		*/
	    break;
	  }

	shake_it();				/* Shake the control		*/
	free_sort();				/* Sort Mob free list		*/

	if (mailbx & STRIP_REQ)			/* Setup next strip	*/
	  {
	  new_strip();
	  }

#ifdef	DEVELOPMENT
	time_color(0);				/* Black		*/
#endif
	bsync = TRUE;				/* Sync the backround	*/
}



/* change state in sync with the controlling system */
chgstate( newstate )
WORD newstate;
  {
  CTLPKT *pptr;
  if ( plyrno == mcpno ) 	/* if we are the master here */
     {
     gstate = newstate;		/* change our state */
     return( 1 );
     }
  pptr = ptable[ mcpno ]; 	/* point to packet from master system */
  if ( pptr->pgstate != gstate ) 	/* if master system is in a new state */ 
     {
     gstate = newstate;		/* change our state to catch up */
     return( 1 );
     }

  return( 0 );
  }


/* display lap and place information */
disp_lap()
  {
  if ( ( gstate == G_PLAY1 ) ||
	   ( gstate == G_ENDWAVE ) ||
	   ( gstate == G_START ) )
    {
    write(places[plr_rank],APLT0);		/* Place 		*/
    pbdec(36,2,plr_rank,1,0,APLT0);
    pbdec(5,1,world_laps - plr_lap,1,0,APLT0);
    bckdsp &= ~B_LAP;					/* Unflag request	*/
#if 0
    phex(36,6,ramp,1,0,APLT3);
#endif
	}
  }

 /* erase 'GO' when etimer goes to zero */
 erase_go()
   {
   if ( etimer )
        etimer--;
   else
     {
     /* this could use a pointer to make the routine more generic */
     if ( (gstate == G_ATTRACT) || 
     (gstate == G_PLAY1) )
     berase( &gomsg, APLT1 );
     bckdsp &= ~B_EGO;					/* Unflag request	*/
     }
   }


  /* choose solo game ( solo = TRUE ) or linked game ( solo = FALSE ) */ 
  choose()
      {
      short tmp;
      putcomm();
      tmp = ocheck();
      /* if another player is already requesting a link */
      if   ( ( tmp == G_JOIN1) ||
             ( tmp == G_LWAIT) )
           {
	   kill_canim();
	   clrmo();
       	   gstate = G_ACCEPT;		/* change the question */
           gcount = 0;
           }
      else
          {
          if ( gcount == 0 ) /* first time */
             {
             	clrplf(1);
		initmess();
		kill_canim();				/* Kill any old color anims	*/
	     	initcomm();				/* Setup comm variables	*/
		write_pfpal( hostpal, 0 );
		PF_COLOR0 = 0;
		set_anpals();				/* load alpha palettes */
		write_anpal( lnkrpal0, 0 );
		write_anpal( lnkrpal1, 1 );
		write_anpal( lnkrpal3, 3 );
		start_rotate(ALF_BASE,3,2,4,11);	/* Start color rotate	*/

		alf_anim( LNKR000, 0, 0, 0 );		/* Write alpha screen	*/
		com_wrt(S_HAPIMUS);			/* Choice music		*/
		happy = TRUE;

		alf_anim( LNKR013, 24, 07, APLT1 );		/* BIG LINKED	*/
		alf_anim( LNKR010, 03, 07, APLT0 );		/* Small solo	*/
		plf_anim( SEL107, 15, 14, 0 );		/* Write select-o-matic	*/

		setobj(&ladablk,0xA00,0x3600,0xFF,0,0);	/* Big Lada		*/
                start_ok = FALSE;			/* pedal up and down to exit */
                solo = FALSE;
             }

	blink_lamp(0x0F);				/* Blink lamps	*/

      	if ( WHEEL < 0x24 ) 		/* control is to the right */
	  {
	  if (solo == TRUE)				/* If it was TRUE	*/
	    {
	    alf_anim( LNKR013, 24, 07, APLT1 );		/* BIG LINKED	*/
	    alf_anim( LNKR010, 03, 07, APLT0 );		/* Small solo	*/
            solo = FALSE;

	    plf_anim( SEL107, 15, 14, 0 );		/* Write select-o-matic	*/
	    com_wrt( S_RAPSNRE );
	    }
          }
      	else						/* control is to the left */
          {
	  if (solo == FALSE)				/* If it was FALSE	*/
	    {
	    alf_anim( LNKR012, 24, 07, APLT0 );		/* Small linked	*/
	    alf_anim( LNKR011, 03, 07, APLT1 );		/* BIG SOLO	*/
            solo = TRUE;

	    plf_anim( SEL103, 15, 14, 0 );		/* Write select-o-matic	*/
	    com_wrt( S_RAPSNRE );
            }
	  }

      	if ( start_check() || 
           ( gcount > ( 9 * 30 ) ) )		/* times up */
         	{
	        clrmo();

         	if ( !solo )
           		gstate = G_JOIN1;
            else
            	{
		if ( world == 0 )
		  gstate = G_TITLE;
		else
		gstate = G_SELECT;
            	comp = FALSE;
		    	mcpno = plyrno;
            	active[ 0 ] = active[1] = active[2] = active[3] = 0;
            	active[ plyrno ] = 1;
            	}
           	gcount = 0;
            }
            else
             gcount ++ ;
         }
      }

  /* wait for other players to join in */
  join1()
      {
      int tmp;
        if ( gcount == 0 )	/* first time */ 
           {
 		   initmess();
           initcomm();					/* init comm variables */
		   clrplf(0);
           write_pfpal( waitpal, 0 );
           plf_anim( WAIT000,0,0,0);
		   write(&waitmsg1,APLT1);		/* waiting for other rats		*/
           oldramp = ramp;
           }
          putcomm();
        tmp = lchk1();
        if ( (tmp == 1)  || 
             ( gcount > ( 9  * 32 ) ) )
           {
           if ( (tmp == 1 ) && comp )	/* true if linked */
              {
              if (chgstate( G_JOIN2 ) )
                {
                gcount = 0;
                if ( newwld != world )
                  {
                  world = newwld;
                  }
                }
              else if ( gcount == 0 ) gcount = 1;
              }
            else 	/* not linked - could we be ? */
              {
              if ( tmp == 2 )		/* no way */
                {
		   if ( world == 0 )
		     gstate = G_TITLE;
		    else
		     gstate = G_SELECT;

				gcount = 0;
         		solo = TRUE;
            	comp = FALSE;
                old_comp = FALSE;
		    	mcpno = plyrno;
            	active[ 0 ] = active[1] = active[2] = active[3] = 0;
            	active[ plyrno ] = 1;
                }
              else	/* other player exists */
			  	gstate = G_LWAIT;		/* wait for the game to end */
              gcount = 0;
              }

           }		
        else		/* still time left to wait */
          {
          if ( ( ( gcount & 0x1f) == 0  ) &&
                 ( gcount < ( 9 << 5 ) ) )
		  	pbdec( 20,27, 8 - ( gcount >> 5 ), 1,0,APLT1 );
            gcount++ ;
          }
   }

  /* the game moves to G_JOIN2 state when this machine is finished building  */
 /*  its list of active machines.  This is so other machines that are still */
 /* completing their lists will count this machine as a JOINER */  
  join2()
      {
      if ( gcount == 0 )
        {
        if ( old_comp == FALSE )	/* if previous game was not linked */
           {
           clrtcard( plyrno );		/* start season over */
           }
        }
        if (  gcount > 8 )
           {
           if (chgstate( G_SELECT ) )
              {
              gcount = 0;
		   	  erase(&waitmsg1,APLT1);			/* waiting for other rats	*/
              if ( newwld != world )
                {
                world = newwld;
                }
		   if ( world == 0 )
		     gstate = G_TITLE;

                ramp = ( oldramp + otherramp ) >> 1;
              }
           }
        else
            gcount++ ;
        putcomm();							/* send the current state to other cars */
      }

 /* If one player trys to link and the other player is busy - just wait for link */  
  lwait()
      {
      int tmp;
      putcomm();							/* send the current state to other cars */
      if (gcount == 0 )	/* first time through */
        { 
 		initmess();
		write(&lwaitmsg1,APLT1);		/* waiting for finish */
		write(&bailmsg,APLT3);		/* bail message */
        /* put up wait screen */
        gcount = 1;
        }
      else
       {
       tmp = lchk2();
       if ( tmp == 1 )	/* proceed with linked game */
          {
           if (chgstate( G_JOIN2 ) )
              {
              gcount = 0;
		   	  erase(&lwaitmsg1,APLT1);			/* waiting for finish	*/
              if ( newwld != world )
                {
                world = newwld;
                }
             }
          }
		else
		 if ( ( tmp == 2 ) || 				/* bugs 1-3, only solo game is possible */
		((button & TRIGS_LEV)==(TRIGS_LEV)) )  		/* player chooses to bailout */
			{
			   if ( world == 0 )
			     gstate = G_TITLE;
			    else
			     gstate = G_SELECT;

			gcount = 0;
         	solo = TRUE;
            comp = FALSE;
            old_comp = FALSE;
		    mcpno = plyrno;
            active[ 0 ] = active[1] = active[2] = active[3] = 0;
            active[ plyrno ] = 1;
		    }
		else
			gcount++ ;
       }
      }

accept()
      {
      if ( gcount == 0 ) /* first time */
         {
           clrplf(1);
 	   initmess();
	   kill_canim();
           initcomm();					/* init comm variables */
	   set_anpals();				/* load alpha palettes */
	   write_anpal( lnkrpal0, 0 );
	   write_anpal( lnkrpal1, 1 );
	   write_anpal( lnkrpal3, 3 );
	   start_rotate(ALF_BASE,3,2,4,11);		/* Start color rotate	*/
	   write_pfpal( hostpal, 0 );
	   PF_COLOR0 = 0;

	   alf_anim( LNKR001, 0, 0, 0 );		/* Write alpha screen	*/
	   plf_anim( SEL107, 15, 14, 0 );		/* Write select-o-matic	*/
	   alf_anim( LNKR017, 24, 07, APLT1 );		/* BIG YES	*/
	   alf_anim( LNKR014, 03, 07, APLT0 );		/* Small no	*/

	   setobj(&ladablk,0xA00,0x3600,0xFF,0,0);	/* Big Lada		*/
           start_ok = FALSE;				/* pedal up and down to exit */
           solo = FALSE;
         }
      
      blink_lamp(0x0F);					/* Blink lamps		*/

	if ( WHEEL < 0x24 ) 		/* control is to the right */
	  {
	  if (solo == TRUE)
	    {
	    alf_anim( LNKR017, 24, 07, APLT1 );		/* BIG YES	*/
	    alf_anim( LNKR014, 03, 07, APLT0 );		/* Small no	*/
	    plf_anim( SEL107, 15, 14, 0 );		/* Write select-o-matic	*/
            solo = FALSE;
	    }
          }
        else							/* control is to the left */
          {
	  if (solo == FALSE)
	    {
	    alf_anim( LNKR016, 24, 07, APLT0 );		/* Small yes	*/
	    alf_anim( LNKR015, 03, 07, APLT1 );		/* BIG NO	*/
	    plf_anim( SEL103, 15, 14, 0 );		/* Write select-o-matic	*/
            solo = TRUE;
	    }
          }

      if ( start_check() || 
           ( gcount > ( 9 * 30 ) ) )		/* times up */
         {
	 clrmo();

         if ( !solo )
           {
           gstate = G_JOIN1;
           }
         else
           {
           decline = TRUE;				/* we did decline */

	   if ( world == 0 )
	     gstate = G_TITLE;
	    else
	     {
	     gstate = G_SELECT;
	     com_wrt(S_FHAPIMUS);				/* Kill "choose" screen music	*/
	     happy = FALSE;
	     }

	   comp = FALSE;
           old_comp = FALSE;
		   mcpno = plyrno;
           active[ 0 ] = active[1] = active[2] = active[3] = 0;
           active[ plyrno ] = 1;
           }
         gcount = 0;
         }
      else
        gcount ++ ;
        putcomm();
      }


/* display host of course */
gtitle()
     {
        if ( gcount == 0 )		/* first time through */
			{
	    com_wrt(S_KSELMUS);					/* Kill select music	*/
	    kill_canim();
            if ( world > (WORD)&MAX_TRK-1 )
                 world = 1;
            clrplf(host_bank[world]);				/* clear playfield */
            initmess();								/* clear alphas */
	    lamp(0);						/* Turn off lamps	*/

	    set_anpals();					/* load alpha palettes */
            plf_anim( hostpic[ world ],0,0,0);
            write_pfpal( hostpal, 0 );

	    if ((world != 0) || (happy == FALSE))
	      host_music(world);				/* Start host music		*/

	    if (world)						/* If NOT beginner track	*/
	      {
	      bwrite( tnames[ world ], APLT1 );			/* track title 	*/
	      bwrite( tnamesa[ world ], APLT0 );
	      write(&title2,APLT2);				/* write hosting	*/
	      bwrite( hosts[ world ], APLT4 );			/* host name */
	      hosttime = HOSTTIME;
	      slcksum();
	      }
	    else
	      {
	      instr_tmr = iidx = 0;				/* Init instrucions	*/
	      write_pfpal(beginpal,1);				/* Write Loda's palette	*/
	      hosttime = BEGTIME;
	      }
	    }

	if (world == 0) instruct();				/* Do instruction screen	*/
	if (gcount == 30) say_host(world);			/* Say host name now		*/

        if (   ( gcount > 32 ) &&					/* waited min time and */
             ( ( gcount > hosttime ) ||					/* max time elapsed or */
               ( plyrno != mcpno ) ||			    /* we are not in charge, or */
		( ( plyrno == mcpno) && 
		(start_check() || ostart()) ) ) )	/* someone is is tapping */
			{
          	if ( chgstate( G_START ) )	/* start  */
				{
       			initmess();
         		new_wave();
			com_wrt(S_KILHOSTS);			/* Kill host announcement	*/
                ltinit( &plaptime);
                write( &lap0msg, APLT1|BG_BIT );
	    		gcount = 0;				/* Zero count		*/
				}
       		}
 		else
			gcount++ ;
	 	putcomm();									/* share game state data */
        if ( (gstate == G_TITLE) &&					/* still here? */
             ( comp == FALSE ) &&					/* was a one player game */
             ( decline == FALSE) )					/* already said no */
           {
           if ( ocheck() == G_JOIN1 )  			/* other player wants to join */
              {
              gstate = G_ACCEPT;
              gcount = 0;
              }
           }
#ifdef DEVELOPMENT

	     if (joystick & 0xF0)
		{
		host_kill(world);

	      switch (joystick & 0xF0)
		  {
	 	  case JRIGHT:
		    if (++world >= (WORD)&MAX_TRK)
		       world = 0;
			gcount = 0;
		    break;

	 	  case JLEFT:
		    if (--world < 0)
		       world = (WORD)&MAX_TRK-1;
			gcount = 0;
		    break;
		  }
		}
#endif
     }


/*	Instruction screen			*/
instruct()
{
	int	i;
	WORD	y;

	if (instr_tmr < 0) return;			/* Instructions over		*/

	if (instr_tmr-- == 0)				/* If timeout			*/
	  {
          plf_anim(iscript[iidx].lodapix,26,10,0);	/* Draw next Loda		*/

	  if (iscript[iidx].index >= 0)			/* If time to put out instruction	*/
	    {
	    i = iscript[iidx].index;			/* Get instruction index	*/
	    y = insty[i];
            plf_anim(instr_tbl[i],6,y,0);		/* Draw instruction		*/
	    }

	  instr_tmr = iscript[iidx++].delay;		/* Set next delay		*/
	  }
}
	    




/* count down 3, 2, 1, GO */
gstart()
   {
   putcomm();
   switch( gcount )
      {
      case 0 :	/* wait for walk out */
         if ( abs( fgptr->xpos) < 0x0a00 )
            {
	    host_fade(world);			/* Fade host music	*/
            fgptr->ad1 = TRUE;
            gcount = 1;
            }
         break;
      case 1 :	/* wait for florish */
        if ( fgptr->ad1 == 0 ) /* end of florish */
           {
           gcount = 2;
           }
         break;
      case 2 :	/* ready */
        if ( docount( gcount) == 2 )
           {
	       com_wrt( S_READY );
           bwrite( &readymsg, APLT1 );
           fgptr->ad1 = TRUE;
           gcount = 3;
           }
         break;
      default:
         if ( gcount == 27 )
          {
          bwrite( &setmsg, APLT1 );
	      com_wrt( S_SET );
          fgptr->ad1 = TRUE;
          }
       else if (gcount == 62 )
          {
          bwrite( &gomsg, APLT1 );
          fgptr->ad1 = TRUE;
          if ( world & 0x01 )
	     com_wrt( S_GO2 );
          else
  	     com_wrt( S_GO );
          }
         if ( gcount > 63 ) 
            {
            if  ( chgstate( G_PLAY1 ) )	/* go play  */
              {
		      res_engine();						/* Reset engine	sound	*/
              etimer = 32;						/* in a second */
    	      bckdsp |= B_EGO;					/* Erase go	*/
              decline = 0;
              }
            }
         else
           gcount++;
        }
     

   rev_engine();						/* Rev the engine	*/
   }


/* the race of over, so rank the players */
rankwave()
   {
   if ( gcount == 0 )
     {
	  rankclr();			/* Set rank colors and rank indicies	*/
      gcount = 1;
     }
   putcomm();
   viewx_spd = 0;
   viewy_spd = 0;
   viewy_spd = 0;
   if (chgstate ( G_ENDWAVE ))
      {
      if ( comp && ( plyrno != mcpno ) )
         getrank();		/* get rank from master system */
      gcount = 0;
      }
   }


/* handle end of the wave conditions */
endwave()
   {
   ulong time;
        if ( gcount == 0 )
          {
	  	   kill_plrsnd();				/* Kill player sounds	*/
           /* compute race time in 30's of a second */
           time = ( ( plaptime.min  * 60 ) + 
                      plaptime.sec) * 30 + 
                      plaptime.hun;
           end_race( world, plr_rank, solo, time );
           settcard( world, plr_rank);
	   init_fin();				/* Init finish announcement	*/

           old_comp = comp;			/* save linked status */
           old_rank = plr_rank;		/* save ranking */
		   viewx_spd = 0;
		   viewy_spd = 0;
		   viewy_spd = 0;

          if ( didiwin() )
            {
            if ( plr_rank == 1 )
		{
            	write( &winmsg, APLT3 );
		com_wrt(S_WINFF);
		}
            else
            	write( &beatmsg, APLT3 );

	    if ( allraced() )		/* Don't do win screen if all over	*/
	       nstate = G_TALLY1;
	    else
	       nstate = G_WON;

	    wincnt++ ;
            }
          else
            {
            write( &losemsg, APLT3 );

            if ( allraced() )		/* dont let player continue if done */
               nstate = G_TALLY1;	/* should be party time */
            else
               {
               nstate = G_CONT;
	           wincnt = 0;
               }
            }
            if ( winspin() )
              gcount = 2;	/* we are already sideways */
            else
              gcount = 1; /* wait for spinout */
          }
        else
        if ( gcount == 1 )
          {
	      putcomm();
          if ( winspin() )
             gcount = 2;
          }
        else
      if ( gcount > ( ENDWTIME ) )
         {
         if ( nstate != G_CONT )
           {
           if ( world == 0 ) 
              ramp = 8;
           else
              if ( ramp < 13 ) ramp += 3;	/* get harder */
              else ramp = 15;
           oldramp = ramp;
           }
         erase( &losemsg, APLT3 );
         gstate = nstate;
		 clr_all();					/* get rid of mobs */
		 viewx_spd = 0;
		 viewy_spd = 0;
		 viewy_spd = 0;
         kill_canim();
	     putcomm();
         gcount = 0;
	 return;
         }
      else
        {
	    putcomm();
      	gcount++ ;
        }

   say_finish();						/* Announce finish	*/
   view_window();
   }


  /* Display winner screen */ 
  won()
      {
      BYTE stamp_hoff;
      char *sptr, *bsptr;
      BYTE tmp;

      if ( gcount == 0 ) /* first time */
         {
		   clr_all();					/* get rid of mobs */
 		   initmess();
            	   kill_canim();					/* Kill color anim	*/
           clrplf(1);								/* clear playfield */
           write_pfpal( winpal, 0 );
		   dorankclr();
           plf_anim( WIN000,0,0,0);					/* Draw the big picture	*/

	   if (plr_rank == 1)						/* If first place	*/
	     {
	     HSCROLL = (120 << 5) | LOAD_ENABLE;			/* Move display over 120 pixels	*/
	     win_hoff = (120 << 6);					/* Offset motion objects too	*/
	     }
	   else
	     win_hoff = 0;						/* No offset for second place	*/

	   setobj(firstpix[world],0x4800-win_hoff,0x3800,0xFF,0,0);
	   setobj(&secondblk,0x2600-win_hoff,0x2600,0xFF,0,0);
	   setobj(&thirdblk,0x6400-win_hoff,0x2000,0xFF,0,0);
           start_ok = FALSE;			/* pedal up and down to exit */
		   bwrite( &standmsg, APLT1 );			/* standings */
		   com_wrt( S_WIN );

         }
      
		/* flash characters on the screen */
        if (( gcount & 0x0f ) == 0 )
          {
	  stamp_hoff = win_hoff >> 9;

          if ( (gcount & 0x10) == 0 )
            {
            switch( plr_rank )
              {
              case 1:
   		pbwrite(28-stamp_hoff,8,"1ST PLACE",APLT2);

		if (world)
   		  pbwrite(30-stamp_hoff,27,"$50,000 ",APLT2);
		break;

              case 2:
   		pbwrite(16-stamp_hoff,6,"2",APLT4);
   		pwrite(18-stamp_hoff,6,"ND PLACE",APLT4);

		if (world)
		  pwrite(19-stamp_hoff,20,"$20,000",APLT4);
		break;

              case 3:
		pbwrite(46-stamp_hoff,6,"3",APLT1);
		pwrite(48-stamp_hoff,6,"RD PLACE",APLT1);
		pwrite(49-stamp_hoff,17,"$7,000",APLT1);
		break;

	      default:
		break;
              }
            }
          else
            {
            switch( plr_rank )
              {
              case 1:
   		pbwrite(28-stamp_hoff,8,"         ",APLT2);
   		pbwrite(30-stamp_hoff,27,"        ",APLT2);
		break;

              case 2:
   		pbwrite(16-stamp_hoff,6," ",APLT4);
   		pwrite(18-stamp_hoff,6,"        ",APLT4);
		pwrite(19-stamp_hoff,20,"       ",APLT4);
		break;

              case 3:
		pbwrite(46-stamp_hoff,6," ",APLT1);
		pwrite(48-stamp_hoff,6,"        ",APLT1);
		pwrite(49-stamp_hoff,17,"      ",APLT1);
		break;

	      default:
		break;
              }
            }
          }
      tmp = ocheck();		/* get state of other game */
      if ( (tmp == G_OVER) ||
           (tmp == G_DONE) )
         old_comp = FALSE;		/* remember that link was broken */
      if ( gcount > ( 5 * 30 ) )
        {
        if ( allraced() )
           {
           gstate = G_TALLY1;		/* should be party time */
           gcount = 0;
	       clrmo();				/* Clear mobs	*/
           }
         else
         if ( ( ( comp == FALSE ) ||
                ( tmp != G_CONT ) ) &&
              ( start_check() || 
              ( gcount > ( 9 * 30 ) ) ) )	/* times up */
           {
	        world++;
	        clrmo();				/* Clear mobs	*/

           if ( !solo  ) 
             gstate = G_JOIN1;
           else
           if ( ocheck() && linkwrks ) 
             gstate = G_CHOOSE;
           else
             {
             gstate = G_SELECT;
             comp = FALSE;
		     mcpno = plyrno;
             active[ 0 ] = active[1] = active[2] = active[3] = 0;
             active[ plyrno ] = 1;
			 com_wrt(S_KWIN);	
             }
           gcount = 0;
           }
        else
          {
          gcount ++ ;
          if ( gcount > ( 8 * 30 ) )
			com_wrt(S_FWIN);	
          }
        }
    else
      gcount++ ;
    putcomm();
    }

  /* allow player to continue if possible  */ 
  cont()
      {
      short tmp;
      if ( gcount == 0 ) /* first time */
         {
           clrplf(0);
	   com_wrt(S_STOP);			/* Stop all sounds	*/
 		   initmess();
           start_ok = FALSE;			/* pedal up and down to exit */
		   set_anpals();				/* load alpha palettes */
		   fill_pfpal( 0, BLACK);		/* black background */
		   write_anpal(bnumpal,0);		/* Get big number palette	*/
		   start_rotate(ALF_BASE,0,2,4,11);	/* Start color rotate	*/

           cont_game( world, thumpcnt, shakes );
           thumpcnt = 0;
           shakes  = 0;
	   world++ ;
	   if ( world > (WORD)&MAX_TRK-1 )
	   world = 1;
           display_credits();
         }
      /* update countdown display */

      if ( ( ( gcount & 0x1f) == 0x01  ) &&
             ( gcount < ( 9 << 5 ) ) )
  		  	alf_anim(bnums[9 - ( gcount >> 5 )],13,3,APLT0 );

       if ( tmp = cont_check() )
	   		msg_blink(&press,APLT3,0x0F,0);	/* press pedal to continue 	*/
        else
	   		write(&addc,APLT3);		/* press pedal to continue 	*/
      if ( start_check() && tmp  ) 
         {
		 if (cont_debit() == 0 )
            {
            trap();
            }
         if ( !solo  ) 
           gstate = G_JOIN1;
         else
         if ( others() && linkwrks ) 
           gstate = G_CHOOSE;
         else
           {
           gstate = G_SELECT;
           comp = FALSE;
		   mcpno = plyrno;
           active[ 0 ] = active[1] = active[2] = active[3] = 0;
           active[ plyrno ] = 1;
           }
	 if ( ramp > 4 ) ramp -= 4;	/* get easier */
	 else ramp = 0;				/* easiest */
         oldramp = ramp;
         gcount = 0;
         start_game( world);
         thumpcnt = 0;
         shakes = 0;
         }
      else  if ( gcount > ( 9 << 5 ) ) 		/* times up */
         {
         gstate = G_TALLY1;		/* should be point tally time */
         gcount = 0;
         end_game();
         }
      else
         {
         gcount++ ;
         if ( newcoins )		/* did I hear money? */
            {
            newcoins = 0;
            gcount = 1;			/* restart the count */
            }
         }
      putcomm();
      }


/* display game over   */ 
gover()
{
	clrplf(0);
	initmess();
	bwrite(&govrmess,APLT0);		/* game over  	*/
	start_ok = FALSE;			/* pedal up and down to exit */
	set_anpals();				/* load alpha palettes */
	fill_pfpal( 0, BLACK);		/* black background */
	com_wrt(S_STOP);			/* Stop all sounds	*/
	world = 0;
	gstate = G_DONE;			/* Go to game done	*/
}


/*	Game is done				q*/
game_done()
{
	if ( start_check() && (credits >= (0x01 << 16)) )
	  {
          if ( new_debit() == 0 )			/* we should have credit */
            trap();

#if 0
	 		gstate = G_CHOOSE;			/* ?????? unsafe */
#else
            new_game();
#endif
              
          gcount = 0;
      }
        else
	  {
	  if ( gcount > ( 5 * 30 ) ) 		/* times up */
            {
            gstate = G_ATTRACT;
            gcount = 0;
      	    atstate = A_TITLE;		/* Display the title	*/
 	    initmess();
	    kill_canim();			/* Kill color anim	*/
            }
	  else
            gcount ++ ;
	  }
}


/*	Setup new game				*/
new_game()
{
	game = TRUE;		/* Turn on game state	*/
	plyrno = PLRID; 	/* Assign player number	*/

   	start_game(world);	/* Start stats		*/
	pgsum();		/* Hacker check		*/
    thumpcnt = 0;
    shakes = 0;
    happy = FALSE;
	init_score();			/* Clear scoring	*/
	clrtcard(plyrno);			/* clear tournament card */
    old_comp = FALSE;	/* previous race was not linked */
	set_vol();			/* Set volume (just in case)	*/

	gstate = G_FWAIT1;		/* Wait for fadeup	*/
	gcount = 0;					/* zero count */
   	setup = &do_nothing();		/* Post setup		*/
    old_rank = 4;				/* didn't win last time */
    ramp = 4;					/* starting ramp value */
    decline = 0;				/* haven't declined anything yet */
    wincnt = 0;					/* we haven't won any races either */
    vcr_record();
    if ( linkwrks )
		nstate = G_CHOOSE;
    else
       {
       solo = TRUE;
       world = 0;
       nstate = G_TITLE;
       comp = FALSE;
	   mcpno = plyrno;
       active[ 0 ] = active[1] = active[2] = active[3] = 0;
       active[ plyrno ] = 1;
       }
}

do_nothing ()
   {
   }

/*	Play processing 			*/
play1()
{
	do_player();				/* Do player routines	*/
	plr_shoot();				/* Player shoots	*/
	do_drone();				/* Move drones if we are in control	*/
	my_lasers();				/* Move/Init my lasers	*/
	send_packets();				/* Send player, drone and laser init block to comm ram	*/

	view_window();				/* Window movement	*/
	move_view();				/* Move the viewpoint	*/
    ltupdate( &plaptime, 2,27, APLT1|BG_BIT );	/* update lap timer */

#ifdef	DEVELOPMENT
	time_color(C_YELLOW);			/* Wait loop in yellow		*/
#endif
	while (!data_ready());

#ifdef	DEVELOPMENT
	time_color(0x01E0);			/* Dark Green		*/
#endif
	get_packets();				/* Get external position info	*/
	plot_drone();				/* Plot new drone positions	*/
	their_lasers();				/* Move/Init other system lasers	*/
	mo_coll();				/* Motion object collision */
	move_dots();				/* Move map dots	*/
	comments();				/* Announcer comments	*/
	chk_end();				/* Check end of game	*/


#if	0
/* test code to measure link delays */
	if ( (frame & 0x3f ) == 0 )
	  {
  	  pdec(33,7,(waitget >> 6),6,0,APLT3);
	  pdec(33,8,(waitput >> 6),6,0,APLT3);
	  waitget = 0;
	  waitput = 0;
	  }
#endif

}



/*	Backround routines		*/
bckrnd()
{
	ulong	bdsp;
	int	i;

bckloop:
	if (bsync != 0)				/* "Frame synced" routines	*/
	  {
	  bsync = 0;

	  if ((frame & 0x1F) == 0)		/* Count "seconds"		*/
	    {
	    ++long_time;
	    }

	  for (i=0,bdsp=bckdsp; bdsp != 0; i++, bdsp >>= 1)
	    if (bdsp & 1) (*bdisp[i])();	/* Do backround dispatch	*/

          if ( gstate == G_PLAY1 )
            chk_rank();				/* update the rank */

          check_coins();
	  }

	random(0x7FFF);				/* Buzz random numbers		*/
	goto bckloop;
}



/*	New strip request		*/
new_strip()
{
   	short	strip;
   
#ifdef	DEVELOPMENT
	time_color(C_WHITE);			/* White		*/
#endif

   	mailbx &= ~STRIP_REQ;			/* Unflag request	*/

	if (viewy_spd >= 0)
   	  strip = strip_cur;			/* Draw horizon	strip	*/
   	else
   	  {
   	  strip=  strip_cur - (YDEPTH-1);	/* Draw nearest strip	*/
   	  if (strip < 0) strip += strip_num;	/* Wrap strip		*/
   	  }
   
   	makobj(strip);				/* Draw strip		*/
}


/*	Viewpoint to player windowing			*/
view_window()
{
	short diff,pxspd;
    long ydist;

	switch (xlock)
	  {
	  case 0:
	    viewx_spd = 0;				/* Don't move x			*/
	    break;

	  case 1:					/* Center the boat		*/
	    diff = pp->xpos - viewx;			/* Get deltax			*/

	    if (diff >= 0)
	      pxspd = plrcar->car_xspd + 0x10;
	    else
	      pxspd = plrcar->car_xspd - 0x10;

	    if (abs(diff) < abs(pxspd))			/* If close, lock		*/
	      {
	      viewx_spd = diff;
	      xlock = 2;
	      }
	    else
	      viewx_spd = pxspd;

	    break;

	  default:
	  case 2:					/* Locked in			*/
	    viewx_spd = pp->xpos - viewx;
	    break;
	  }

	ydist = pp->ypos - viewy;			/* Get current distance from viewpoint	*/
    if ( ydist < -(world_len >> 1) )		/* if player is more than half a world behind us */
         ydist += world_len;			/* then we can think of him as being in front of us */

	if (pp->zpos != pp->height)				/* If flying...		*/
	  tdist = PLR_YMIN + (plrcar->car_yspd << 1);		/* Get target distance	*/
	else
	  tdist = PLR_YMIN + (plrcar->car_yspd + (plrcar->car_yspd >> 2));

	switch (acc_case)				/* Get accel case	*/
	  {
	  case 0:
	    if (abs(ydist - tdist) < 0x10)		/* Set cur = trg if under acc */
	      diff = ydist - tdist;
	    else
	      {
	      if (ydist < tdist)			/* Bump current to target  */
	    	diff = -0x10;
	      else
		diff = 0x10;
	      }

	    viewy_spd = plrcar->car_yspd + diff;		/* Get scroll speed	*/

	    if (viewy_spd < 0) viewy_spd = 0;		/* No backward scrolling	*/
	    break;

	  case 1:					/* No scrolling	*/
	    break;

	  case 2:
	    viewy_trg = 0;				/* Slow down slowly	*/
	    viewy_acc = 2;
		chk_ymin();
	    smooth_view();
	    break;

	  default:
	    break;
  	  }

/*	chk_ymin();					/* Min scroll speed	*/
}


/*	Check minimum Y scroll speed				*/
chk_ymin()
{
	long	newypos;

	newypos = viewy + viewy_spd + PLR_YMIN;		/* Get y pos check	*/

	if (pp->ypos < newypos)				/* Check minimum	*/
	  {
      if ( ( newypos - pp->ypos)  > (world_len >> 1) )
         return;
	  viewy_spd -= newypos - pp->ypos;
	  viewy_trg = viewy_spd;
	  }
}



/*	Smooth view_spd to target	*/
smooth_view()
{

	if (abs(viewy_spd - viewy_trg) < viewy_acc)	/* Set cur = trg if under acc */
	  viewy_spd = viewy_trg;
	else
	  {
	  if (viewy_spd < viewy_trg)			/* Bump current to target  */
	    viewy_spd += viewy_acc;
	  else
	    viewy_spd -= viewy_acc;
	  }
}


/*	Get new viewpoint				*/
new_view()
{
	WORD	viewz_acc;
	short	pz;

	viewx += viewx_spd;					/* Add speeds to position */
	viewy += viewy_spd;
								/* Wrap viewy		*/
	if (viewy < 0) viewy += world_len;			/* Zero wrap to max	*/
	if (viewy > world_len)
	  {
	  viewy -= world_len;					/* MAX wrap to zero	*/
	  viewy_bb -= world_len;
	  }

	height = get_height(viewy + bottom_dy);			/* Get height at bottom of screen	*/
	viewz = height + viewz_off;
	pz = pp->zpos + pp->zoff;				/* Get player's zpos		*/

	if (game) 
	  {
	  if (pz > viewz)					/* If player up in air..	*/
	    viewz += pz - viewz;
	  }

	if (viewz < height) viewz = height;			/* Z lower limit			*/
	scroll_back();						/* Scroll background			*/
}



/*	Move viewpoint					*/
/*	Exit:	return(1) if strip forward change	*/
/*		return(-1) if strip backward change	*/
long	move_view()
{
	long	dir;

   	strip_back = viewy & ~(STRIP_SIZE-1);				/* Get strip boundaries			*/
	strip_front = strip_back + (STRIP_SIZE-1);
	strip_horizon = strip_back + (YDEPTH * STRIP_SIZE);
	strip_cur = (strip_back >> 12) + (YDEPTH-1);
	dir = 0;							/* Default no movement			*/

   	if (strip_horizon > world_len) strip_horizon -= world_len;	/* Wrap horizon				*/
   	if (strip_cur > strip_num) strip_cur -= strip_num;			/* Wrap strip number			*/
   
   	if (strip_cur != strip_old)					/* If in a new strip			*/
   	  {
   	  if (abs(strip_cur - strip_old) > YDEPTH)			/* If strip wrapped			*/
	    {
	    if (strip_cur < strip_old)
	      dir = 1;							/* Wrap forward				*/
	    else
	      dir = -1;							/* Wrap backward			*/
	    }
	  else
	    {
	    if (strip_cur > strip_old)
	      dir = 1;							/* Wrap forward				*/
	    else
	      dir = -1;							/* Wrap backward			*/
	    }
  	  strip_old = strip_cur;					/* Save old strip number		*/
   	  mailbx |= STRIP_REQ;						/* Request new strip			*/
   	  }

	return(dir);							/* Tell caller direction of strip	*/
}


/*	Check if end of game			*/
chk_end()
{
   int done;
   done = raceover();
   if ( done )
     {
     if (chgstate ( G_RANKWAVE ))
        {
        gcount = 0;
        plr_flag &= ~PLR_START;		/* stop the cars */
        plr_case = P_START;
	plrcar->car_spd = 0;
	plrcar->car_xspd = 0;
	plrcar->car_yspd = 0;
        stop_drones();
        }
     }
	  return( done );			/* 	*/
}


/*	Restart game				*/
restart()
{
	clr_window();				/* Clear alpha window	*/

	start_ok = FALSE;			/* Don't start right away */
	viewx_spd = 0;				/* Clear view speeds	*/
	viewy_spd = 0;				/* Clear view speeds	*/
	viewz_spd = 0;				/* Clear view speeds	*/
	world = 0;				/* Take it from the top	*/

    gcount = 0;
}



/*	New Wave Setup				*/
new_wave()
{
	set_world(world);			/* Setup next world	*/
	res_player();
        start_drones();				/* start up drone cars */
	set_fgirl();				/* Setup flag girl	*/

   	gstate = G_FWAIT1;			/* Wait for fadeup	*/
   	nstate = G_START;
   	gcount = 0;
   	setup = &start_pfrot();			/* Post setup		*/
    display_credits();
}


/*	Setup flag girl				*/
set_fgirl()
{
	fgptr = &obj[setobj(plyrno ? &fgleftblk : &fgrightblk,fgx[ plyrno ],0x700,0,0,0)];
	fingirl_on = FALSE;
}



start_check()
{
#if 0
	if (start_ok)
	  {
	  if (PEDAL < 0x4 )			/* If pedal down, start	*/
	    return(TRUE);
	  }
	else
	  {
	  if ( PEDAL >= 0x1C )		/* wait for pedal up */
	    start_ok = TRUE;
	  }
#endif

if ( button & START )
    return(TRUE);
  
	return(FALSE);
}


/*	High score init #1			*/
high1()
{
	write(&entmsg,APLT3);			/* Enter inits		*/
	bwrite(&nmbrmsg,APLT2);
	gstate = G_HISCORE;			/* Enter initials	*/
}


do_hiscore()
{
	if (!add_hiscore())			/* If finished with score */
	  finished();				/* We're done!		*/
}


/*	Finished with everything			*/
finished()
{
	clr_all();				/* Clear motion objects	*/
	com_wrt(S_FROADRIOT);			/* Fade music	*/
	gstate = G_ATTRACT;			/* Goto restart mode	*/
	atstate = A_HISCORE;			/* Display the table	*/
        gcount = 0;
}


/*	Setup score tally				*/
set_tally()
{
	initmess();					/* Clear alphas			*/
	select_screen();				/* Draw final select screen	*/
	race = 0;					/* Setup cursor			*/
	bwrite(&tlymsg,APLT0);				/* Score tally			*/
	com_wrt(S_RRVAMP);

	race_cnt = 0;					/* Clear counts			*/
	winnings = 0;
	hazard = 0;
	complete = 0;

	tally_case = T_PAUSE;
	tnext = T_ERASE;
	tally_tmr = 30;
	tally_flags = 0;				/* Clear comm flags		*/

	gstate = G_TALLY2;				/* Do tally			*/
}


/*	Do score tally				*/
do_tally()
{
	CTLPKT	*pptr;
	BYTE	*tptr;
	WORD	ostate;

	if (comp)					/* If 2 player		*/
	  {
          pptr = ptable[ plyrno ^ 1 ];
          ostate = pptr->pgstate;			/* Get other guys state		*/
	  }

	switch (tally_case)
	  {
	  case T_ERASE:
	    berase(&tlymsg);				/* Erase big message		*/
	    write(&tlymsg0,APLT0);
   	    cur_op = &obj[setobj(&boxblk,curx[race]<< 6,cury[race]<< 6,100,1,0)];

	  case T_CHK:					/* Check if this race complete	*/
	    tptr = tctable[ plyrno ];			/* Get trophy table pointer	*/

	    if (tptr[race])				/* If we played this race	*/
	      {
	      ++race_cnt;				/* Count the races completed	*/
	      temp_cnt = trophy_val[tptr[race]];	/* Get winnings for that race	*/
	      tally_case = T_CNTWIN;			/* Count winnings		*/
	      com_wrt(winsnd[tptr[race]]);		/* Win sound			*/
	      }
	    else
	      {						/* Display failure map		*/
	      plf_anim( fail_tbl[race], trophyx[race], trophyy[race]+1, 0 );
	      com_wrt(S_BUZZR);
	      tally_tmr = 15;				/* Pause 1/2 sec		*/
	      tnext = T_NEXT;				/* Next race index		*/
	      tally_case = T_PAUSE;
	      }
	    break;

	  case T_CNTWIN:				/* Count up race winnings	*/
	    if (temp_cnt > 800)
	      {
	      winnings += 800;
	      temp_cnt -= 800;
	      }
	    else
	      {
	      winnings += temp_cnt;
	      tally_case = T_PAUSE;
	      tally_tmr = 15;
	      tnext = T_NEXT;
	      }
	
	    com_wrt(S_CLICK);				/* Tick sound			*/
	    pbdec( 20,  9, winnings, 6, 1, APLT0 );	/* Display winnings		*/
	    break;

	  case T_PAUSE:					/* Pause case			*/
	    if (--tally_tmr <= 0)
	      tally_case = tnext;
	    break;

	  case T_NEXT:					/* Next race			*/
	    if (++race >= MAX_RACE)			/* If race phase over..		*/
	      {						/* If linked race and other guy is tallying...	*/
	      if ((comp) && (ostate == G_TALLY2))
		{
		tally_flags |= TALLY_DONE;		/* Flag tally done to other guy	*/
							/* If other guy is done tallying	*/
		if (((tally_flags ^ otally_flags) & TALLY_DONE) == 0)
	          com_wrt(S_ROADRIOT);			/* Start theme music		*/
		else
		  frgdsp |= F_TALLYWAIT;		/* Wait for tally music		*/
		}
	      else
	        com_wrt(S_ROADRIOT);			/* Start theme music		*/

	      delobj(cur_op);				/* Delete the cursor		*/
	      write(&tlymsg1,APLT0);			/* Hazard pay			*/
	      temp_cnt = plr_score;			/* Set hazard count		*/
	      tally_case = T_PAUSE;
	      tally_tmr = 10;
	      tnext = T_HAZ;				/* Goto hazard phase		*/
	      }
	    else
	      {
              cur_op->xpos = curx[race] << 6;		/* Move cursor			*/
              cur_op->ypos = cury[race] << 6;
	      tally_case = T_CHK;			/* Check next race		*/
	      }
	    break;

	  case T_HAZ:					/* Count up hazard pay		*/
	    if (temp_cnt > 800)
	      {
	      hazard += 800;
	      temp_cnt -= 800;
	      }
	    else
	      {
	      hazard += temp_cnt;
	      tally_case = T_PAUSE;
	      tally_tmr = 10;
	      tnext = T_COMP1;
	      }

	  com_wrt(S_CLICK);				/* Tick sound			*/
	  pbdec( 18, 12, hazard, 7, 1, APLT0 );		/* Score			*/
	  break;

	  case T_COMP1:	
	    write(&tlymsg2,APLT0);			/* Series complete		*/

	    if (race_cnt == MAX_RACE)			/* If completed ALL races	*/
	      temp_cnt = 500000;			/* Major bonus			*/
	    else
	      temp_cnt = 0;

	    tally_case = T_COMP2;

	  case T_COMP2:					/* Count up completion bonus	*/
	    if (temp_cnt > 5000)
	      {
	      complete += 5000;
	      temp_cnt -= 5000;
	      }
	    else
	      {
	      complete += temp_cnt;
	      tally_case = T_PAUSE;
	      tally_tmr = 10;
	      tnext = T_TOTAL1;
	      }

	    com_wrt(S_CLICK);					/* Tick sound			*/
	    pbdec( 20, 15, complete, 6, 1, APLT0 );		/* Competion bonus		*/
	    break;

	  case T_TOTAL1:					/* Display total	*/
	    blink(&tlymsg3,APLT0,8);				/* Blink total		*/
	    plr_score += (complete + winnings);
	    pbdec( 18, 19, plr_score, 7, 1, APLT0 );		/* Total		*/
								/* If 2 player tally	*/
	   if ((comp) && (ostate == G_TALLY2))
	      {
	      tally_flags |= SCORE_DONE;			/* My score is done	*/
								/* If other guy is done scoreing	*/
	      if (((tally_flags ^ otally_flags) & SCORE_DONE) == 0)
		tally_case = T_END;				/* Goto ending		*/
	      else
		tally_case = T_SCWAIT;				/* Wait for other score	*/
	      }
	    else
	      tally_case = T_END;				/* Goto ending		*/

	    break;

	  case T_SCWAIT:					/* If other guy is done scoreing	*/
	    if (((tally_flags ^ otally_flags) & SCORE_DONE) == 0)
	      tally_case = T_END;				/* Goto ending		*/
	    break;

	  case T_END:
	    pgsum();					/* Hacker check		*/
	    gstate = G_PAUSE;				/* Goto pause mode	*/
	    pausetmr = 6;				/* Pause 3 secs		*/

	    if (complete)				/* If we completed a game...	*/
	      nstate = G_AWARD1;			/* Goto award ceremony	*/
	    else
	      {
	      if (is_hiscore(plr_score))		/* High score disp?	*/
		{
	        write(&xclmsg,APLT3);			/* Excellent!		*/
	        nstate = G_HIS1;			/* Goto high score init	*/
		}
	      else
	        {
	        pausetmr = 8;				/* Pause 4 secs		*/
	        nstate = G_OVER;			/* Game over		*/
	        }
	      }

	    break;
	  }

	putcomm();					/* Send tally flags	*/
}


/*	Wait for other guys tally to finish			*/
tally_wait()
{							/* If other guy is done tallying	*/
	if (((tally_flags ^ otally_flags) & TALLY_DONE) == 0)
	  {
	  com_wrt(S_ROADRIOT);			/* Start theme music		*/
	  frgdsp &= ~F_TALLYWAIT;		/* Disable this routine		*/
	  }
}
	


/*	Award Ceremony #1			*/
award1()
{
	MDTYPE	*op;
	int	i;

        kill_canim();						/* Stop color anim	*/
 	initmess();						/* Clear screen		*/
	clr_all();
        clrplf(1);
        write_pfpal(winpal,0);
        write_mopal(przpal0,10,32);
        write_mopal(przpal1,12,32);
        plf_anim(WIN000,0,0,0);					/* Draw the big picture	*/
	bwrite(&congmsg,APLT1);					/* Contrats		*/
	write(&congmsg1,APLT1);

	if (comp)						/* If 2 player...	*/
	  {
	  if (plr_score > oplr_score)				/* If I'm the big weener	*/
	    {
	    HSCROLL = (120 << 5) | LOAD_ENABLE;			/* Move display over 120 pixels	*/
	    win_hoff = (120 << 6);				/* Offset motion objects too	*/
	    }
	  else
	    win_hoff = 0;					/* No offset for second place	*/
								/* Setup second place guy	*/
	  op = &obj[setobj(&end2ndblk,0x2900-win_hoff,0x3600,0xF0,0,0)];
	  op->mo_pri = 0x200;
	  }
	else
	  {
	  HSCROLL = (120 << 5) | LOAD_ENABLE;			/* Move display over 120 pixels	*/
	  win_hoff = (120 << 6);				/* Offset motion objects too	*/
	  }

	HSCROLL |= 4;						/* Move display over 120 pixels	*/

	op = &obj[setobj(&endwinblk,0x4800-win_hoff,0x3800,0xF0,0,0)];
	op->mo_pri = 0x200;

	setobj(&mask0blk,0x2E00-win_hoff,0x2800,0xD0,0,0);	/* Mask the cars		*/
	setobj(&mask1blk,0x4E40-win_hoff,0x3000,0xE0,0,0);

	init_money();						/* Init the money		*/
	init_prizes();						/* Init the prizes		*/

	firecnt = 0;					    /* zero firecount */
	frgdsp |= F_FIRE;					/* Start fireworks		*/

	if (is_hiscore(plr_score))				/* High score disp?	*/
	  gstate = G_HIS1;					/* Goto high score init	*/
	else
	  {
	  gstate = G_PAUSE1;					/* Goto pause mode	*/
	  nstate = G_ATTRACT;
	  setup = &finished();
	  pausetmr = 20;					/* Pause 10 secs	*/
	  }

}



/*	Init money tables			*/
init_money()
{
	MONYBLK	*monyptr;
	int	i;

	for (i=0, monyptr = monys; i < MAX_MONEY; i++, monyptr++)
	  monyptr->op = 0;

	frgdsp |= F_MONEY;
}



/*	Money falls from Heaven			*/
money()
{
	MONYBLK	*monyptr;
	int	i,makeone;
	long	xpos;
	short	scale;

	makeone = random(15);

	for (i=0; i < MAX_MONEY; i++)
	  {
	  monyptr = &monys[i];

	  if (monyptr->op)					/* If this is active	*/
	    {
	    monyptr->op->xpos += monyptr->xspd;			/* Move it		*/
	    monyptr->op->ypos += monyptr->yspd;

	    if (monyptr->op->ypos > BOTTOM_SCREEN)		/* If over bottom	*/
	      {
	      delobj(monyptr->op);				/* Delete it		*/
	      monyptr->op = 0;					/* Clear pointer	*/
	      }
	    }
	  else
	    {
	    if (makeone == 0)
	      {
	      makeone = 1;					/* Only one per frame	*/
	      xpos = ( MIDSCREEN / 4 ) + random( MIDSCREEN + ( MIDSCREEN / 2 ) );
	      monyptr->yspd = 0x40 + random( 0x80 );
	      scale = random(0x800);

	      if (random(1))
		{
	        monyptr->op = &obj[setobj(&mony1blk,xpos,-0x400,0xFF-(scale >> 4),-scale,0)];
		monyptr->xspd = 0;
		}
	      else
		{
	        monyptr->op = &obj[setobj(&mony0blk,xpos,-0x400,0xFF-(scale >> 4),-scale,0)];
		monyptr->xspd = -0x40 + random( 0x80 );
		}

	      monyptr->op->mo_pri = 0x200;
	      }
	    }
	  }
}



/*	Init prize tables			*/
init_prizes()
{
	PRZBLK	*przptr;
	int	i;

	for (i=0, przptr = prz_blks; i < MAX_PRIZE; i++, przptr++)
	  przptr->op = przptr->bill = 0;

	prize_cur = 0;
	frgdsp |= F_PRIZE;
}


/*	Move prizes				*/
move_prizes()
{
	PRZBLK	*przptr;
	int	i;
	WORD	flip,scale;

	if ((prize_cur < MAX_PRIZE) && ((frame & 0x01F) == 0))	/* Every 1 sec		*/
	  {
	  i = prize_cur++;
	  przptr = &prz_blks[i];
	  przptr->op = &obj[setobj(prize_tbl[i].mblk,prize_tbl[i].startx-win_hoff,prize_tbl[i].ypos,prize_tbl[i].sort,0,0)];
	  przptr->op->xspd = prize_tbl[i].xspd;
	  przptr->op->mo_pri = 0x200;

	  if (prize_tbl[i].flags & BILL_ON)			/* If bill pushes this one	*/
	    {
	    flip = (prize_tbl[i].startx > 0) ? MO_FLIP : 0;
	    scale = (prize_tbl[i].flags & ~BILL_ON) << 4;
	    przptr->bill = &obj[setobj(&bill0blk,prize_tbl[i].startx+prize_tbl[i].billx-win_hoff,
		               prize_tbl[i].ypos,prize_tbl[i].sort+1,scale,flip)];
	    przptr->bill->xspd = prize_tbl[i].xspd;
	    przptr->bill->mo_pri = 0x200;
	    }
	  }

	for (i=0, przptr = prz_blks; i < MAX_PRIZE; i++, przptr++)
	  {
	  if (przptr->op)					/* If prize active...		*/
	    {							/* If in position		*/
	    if (((przptr->op->xspd > 0) && (przptr->op->xpos >= (prize_tbl[i].endx-win_hoff))) ||
	       ((przptr->op->xspd < 0) && (przptr->op->xpos <= (prize_tbl[i].endx-win_hoff))))
	      {
	      przptr->op->xpos = prize_tbl[i].endx - win_hoff;	/* Put in correct postion	*/
	      przptr->op->xspd = 0;				/* Stop moving			*/
	      przptr->op = 0;					/* Disable this slot		*/

	      if (przptr->bill)					/* Turn Bill around		*/
		{
		if ((przptr->bill->flags & MO_SCRN) == 0)	/* If off screen...		*/
		  delobj(przptr->bill);				/* Delete me now		*/
		else
		  {
	          set_seqn(przptr->bill,bill1);
		  przptr->bill->xspd = -przptr->bill->xspd;
		  przptr->bill->flags |= MO_ODEL;
		  }
		}
	      }
	    }
	  }
}

/*======================================================================*/
/*				EOF					*/
/*======================================================================*/
