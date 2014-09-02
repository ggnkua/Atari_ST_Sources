/*======================================================================*/
/*		TITLE:			MOTBL				*/
/*		Function:		MO initialization blocks	*/
/*									*/
/*		First Edit:		10/01/88			*/
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
#include	"grafix/mobs.h"

#else

#include	"inc:rrdef.h"
#include	"inc:mobinc.h"
#include	"sg:mobs.h"

#endif

#define	TRAP		0x80			/* Oblist trap setup flag */

extern	WORD	motest0,test32;
extern	WORD	clear;
extern	WORD	laser,fball,bang0,bang1,boom,boom1;
extern	WORD	rat0,rat1,rat2,body,shadow;
extern  WORD    drive_by;
extern	WORD	dust1,dust2;
extern	WORD	gate0,gate0f,gate1,gate1f,gate2,gate2f,line0,line1,banner;
extern	WORD	sign0,sign1,dsign0,dsign1,hydrnt,post,dpost,post1,dpost1,rail0,drail0;
extern	WORD	bale0,bale1,bale2,balexpl,dbale0,dbale2;
extern	WORD	tire0,tire1,tire2,dtire0,dtire2,tirexpl;
extern	WORD	trash0,trash1,trash2,trashxpl;
extern	WORD	bag0,bag1,bag2,bagxpl,dbag0,dbag2;
extern	WORD	bump0,bump1,bump1a,bump2,bump3,bump3a,bump4,bump5,bump5a;
extern	WORD	mud0,mud1,mud1a,dirt0,ddirt0,dirt1,dirt2,ddirt2,dirt3,dirt4,splash;
extern	WORD	tree0,tree1,tree2,tree3,tree4,dtree0,dtree1,dtree2,dtree3,dtree4,palm,dpalm,trees0,trees1;
extern	WORD	tree5,dtree5,tree6,dtree6;
extern	WORD	stand,wreck0,wreck1,wreck2,rock0,rock1,rock2,rock3;
extern	WORD	cow,cows;
extern	WORD	corn,cornf,cactus0,cactus1,dcactus0;
extern	WORD	car0,car2,car3,car4,car5,car6,car7,car8,car9,car10,car11,car12,car13;
extern	WORD	bldg0,bldg1,bldg2,bldg3,bldg4,bldg5,bldg6,dbldg0,dbldg2;
extern	WORD	dune0,dune0f,dune1,dune1f,dune2,dune2f,dune3,dune3f,curb0,curb0f,grass,grassf;
extern	WORD	fgirl_left,fgirl_right,crowd0,crowd2,crowd3,crowd4,fingirl,biglada;
extern	WORD	expl0,splat;
extern	WORD	first,second,third,win1,first2,snogirls,endwin,end2nd;
extern	WORD	mony0,mony1,prize0,prize1,prize2,prize3,prize4,prize5,prize6,prize7,prize8,prize9;
extern	WORD	arab0,arab2,arab3;
extern  WORD    mrfin;
extern	WORD	rhino,elephant,lion;
extern	WORD	mask0,mask1,bill0,bill1;

#if	0
typedef	struct	moblk
	{			/* Motion object initialize block	*/
	WORD	*sequen;	/* First sequence pointer		*/
   	BYTE	type;		/* Object type & flags			*/
	BYTE	antimr;		/* Animate timer			*/
	WORD	palate;		/* Palate select / priority / special	*/
   	WORD	flags;		/* Flags byte 				*/
   	WORD	def_scale;	/* Default scale			*/
	} MOBLK;
#endif


MOBLK	test0blk = {&motest0,DUMMY_TYPE,MO_PAL0,0,NULL,QRTR_SCALE};
MOBLK	tballblk = {&fball,DUMMY_TYPE,MO_PAL6,0,MO_ODEL,HALF_SCALE};

/* rat0blk and rat1blk will have different palettes and or scripts */
MOBLK	rat0blk = {&rat0,PLR_TYPE,1,MO_PAL16,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};
MOBLK	rat1blk = {&rat1,PLR_TYPE,1,MO_PAL18,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};
MOBLK	body0blk = {&body,BODY_TYPE,1,MO_PAL0,MO_PFM|MO_CLIP|MO_NDEL,CAR_SCALE};
MOBLK	body1blk = {&body,BODY_TYPE,1,MO_PAL2,MO_PFM|MO_CLIP|MO_NDEL,CAR_SCALE};
MOBLK	body2blk = {&body,BODY_TYPE,1,MO_PAL4,MO_PFM|MO_CLIP|MO_NDEL,CAR_SCALE};
MOBLK	tratblk = {&rat0,TRAT_TYPE,1,MO_PAL16,MO_PFM|MO_NDEL,CAR_SCALE};
MOBLK	shadowblk = {&shadow,SHADOW_TYPE,1,MO_PAL0,MO_PFM|MO_ZMAP|MO_CLIP|MO_NDEL,CAR_SCALE};

MOBLK	mirrorblk = {(WORD *)MIRR000,DUMMY_TYPE,0,MO_PAL0,MO_NOX|MO_DIR,FULL_SCALE};
MOBLK	drnblk = {(WORD *)LDRN000,LDRN_TYPE,0,MO_PAL2,MO_NOX|MO_DIR,DRN_SCALE};
MOBLK	dotblk = {(WORD *)DOT300,DUMMY_TYPE,0,MO_PAL0,MO_NOX|MO_DIR,FULL_SCALE};
MOBLK	boxblk = {(WORD *)BOX020,DUMMY_TYPE,0,MO_PAL6,MO_NOX|MO_DIR,DRN_SCALE};

MOBLK	laserblk = {&laser,LASER_TYPE,8,MO_PAL14,MO_CLIP|MO_NDEL,FULL_SCALE};
MOBLK	rlaserblk = {&laser,LASER_TYPE,8,MO_PAL14,MO_CLIP|MO_NDEL|MO_PFM|MO_FIX,FULL_SCALE};
MOBLK	tlaserblk = {&laser,DUMMY_TYPE,32,MO_PAL14,MO_CLIP|MO_NDEL|MO_PFM|MO_FIX,FULL_SCALE};
MOBLK	laser2blk = {&fball,LASER_TYPE,0,MO_PAL14,MO_NDEL,FULL_SCALE};

MOBLK	pxplblk = {&expl0,DUMMY_TYPE,2,MO_PAL14,MO_ODEL|MO_PFM|MO_ZMAP|MO_CLIP,CAR_SCALE};
MOBLK	splatblk = {&splat,DUMMY_TYPE,4,MO_PAL14,MO_ODEL|MO_PFM|MO_ZMAP|MO_CLIP,FULL_SCALE};
MOBLK	rshotblk = {&splat,DUMMY_TYPE,2,MO_PAL14,MO_NOX,HALF_SCALE};

/* these blocks will all have different palettes when they become available */
MOBLK	drone0blk = {&rat0,DRONE0_TYPE,1,MO_PAL16,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};
MOBLK	drone1blk = {&rat1,DRONE1_TYPE,1,MO_PAL18,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};
MOBLK	drone2blk = {&rat2,DRONE2_TYPE,1,MO_PAL22,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};
MOBLK	drone3blk = {&rat2,DRONE3_TYPE,1,MO_PAL24,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};

MOBLK	dron0yblk = {&rat2,DRONE0_TYPE,1,MO_PAL16,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};
MOBLK	dron1yblk = {&rat2,DRONE1_TYPE,1,MO_PAL18,MO_PFM|MO_CLIP|MO_NDEL|MO_FIX,CAR_SCALE};

MOBLK	clearblk = {&clear,DUMMY_TYPE,0,MO_PAL0,NULL,FULL_SCALE};

MOBLK	redblk  = {&drive_by,DUMMY_TYPE,1,MO_PAL0,MO_NOX|MO_FLIP,(FULL_SCALE * 3)};
MOBLK	blueblk = {&drive_by,DUMMY_TYPE,1,MO_PAL2,MO_NOX|MO_FLIP,(FULL_SCALE * 3)};

MOBLK	fgleftblk = {&fgirl_left,DUMMY_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP,0x50};
MOBLK	fgrightblk = {&fgirl_right,DUMMY_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ZMAP,0x50};
MOBLK	fingblk = {&fingirl,DUMMY_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ZMAP,0x50};
MOBLK	crowd0blk = {&crowd0,CRWD0_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x50};
MOBLK	crowd2blk = {&crowd2,CRWD2_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x50};
MOBLK	crowd3blk = {&crowd3,CRWD3_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x60};
MOBLK	crowd4blk = {&crowd4,CRWD4_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x50};
MOBLK	ladablk = {&biglada,DUMMY_TYPE,16,MO_PAL8,MO_NOX|MO_FLIP,FULL_SCALE};

MOBLK	win1blk = {&win1,DUMMY_TYPE,6,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	firstblk = {&first,DUMMY_TYPE,6,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	first2blk = {&first2,DUMMY_TYPE,6,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	snogirlsblk = {&snogirls,DUMMY_TYPE,3,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	secondblk = {&second,DUMMY_TYPE,4,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	thirdblk = {&third,DUMMY_TYPE,3,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	lfinblk = {&mrfin,DUMMY_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FLIP,0x50};
MOBLK	rfinblk = {&mrfin,DUMMY_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP,0x50};
MOBLK	endwinblk = {&endwin,DUMMY_TYPE,4,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	end2ndblk = {&end2nd,DUMMY_TYPE,4,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	mony0blk = {&mony0,DUMMY_TYPE,2,MO_PAL26,MO_NOX,FULL_SCALE};
MOBLK	mony1blk = {&mony1,DUMMY_TYPE,3,MO_PAL26,MO_NOX,FULL_SCALE};
MOBLK	prz0blk = {&prize0,DUMMY_TYPE,0,MO_PAL10,MO_NOX,FULL_SCALE};
MOBLK	prz1blk = {&prize1,DUMMY_TYPE,0,MO_PAL10,MO_NOX,FULL_SCALE};
MOBLK	prz2blk = {&prize2,DUMMY_TYPE,0,MO_PAL10,MO_NOX,FULL_SCALE};
MOBLK	prz3blk = {&prize3,DUMMY_TYPE,0,MO_PAL10,MO_NOX,FULL_SCALE};
MOBLK	prz4blk = {&prize4,DUMMY_TYPE,0,MO_PAL12,MO_NOX,FULL_SCALE};
MOBLK	prz5blk = {&prize5,DUMMY_TYPE,0,MO_PAL12,MO_NOX,FULL_SCALE};
MOBLK	prz6blk = {&prize6,DUMMY_TYPE,0,MO_PAL12,MO_NOX|MO_FLIP,FULL_SCALE};
MOBLK	prz7blk = {&prize7,DUMMY_TYPE,0,MO_PAL12,MO_NOX,FULL_SCALE};
MOBLK	prz8blk = {&prize8,DUMMY_TYPE,0,MO_PAL12,MO_NOX,FULL_SCALE};
MOBLK	prz9blk = {&prize9,DUMMY_TYPE,0,MO_PAL12,MO_NOX,FULL_SCALE};

MOBLK	arab0blk = {&arab0,ARAB0_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x50};
MOBLK	arab2blk = {&arab2,ARAB2_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x50};
MOBLK	arab3blk = {&arab3,ARAB3_TYPE,4,MO_PAL8,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP|MO_FIX,0x50};

MOBLK	dust1blk = {&dust1,DUMMY_TYPE,1,MO_PAL28,MO_PFM|MO_CLIP|MO_ODEL|MO_ZMAP,0x60};
MOBLK	dust2blk = {&dust2,DUMMY_TYPE,2,MO_PAL28,MO_PFM|MO_CLIP|MO_ODEL,0x40};

MOBLK	gate0blk = {&gate0,GATE0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	gate0fblk = {&gate0f,GATE0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	gate1blk = {&gate1,GATE1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	gate1fblk = {&gate1f,GATE1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	gate2blk = {&gate2,GATE2_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	gate2fblk = {&gate2f,GATE2_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	line0blk = {&line0,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	line0fblk = {&line0,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	line1blk = {&line1,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	line1fblk = {&line1,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bannerblk = {&banner,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};

MOBLK	sign0blk = {&sign0,SIGN0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	sign1blk = {&sign1,SIGN1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dsign0blk = {&dsign0,DSIGN0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dsign0fblk = {&sign0,SIGN0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dsign1blk = {&dsign1,DSIGN1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dsign1fblk = {&sign1,SIGN1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	hydrntblk = {&hydrnt,HYDR_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	rail0blk = {&rail0,RAIL0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	drail0blk = {&drail0,DRAIL0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0xC0};
MOBLK	drail0fblk = {&rail0,RAIL0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0xC0};
MOBLK	postblk = {&post,POST_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	dpostblk = {&dpost,DPOST_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0xC0};
MOBLK	dpostfblk = {&post,POST_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0xC0};
MOBLK	post1blk = {&post1,POST1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xE0};
MOBLK	dpost1blk = {&dpost1,DPOST1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0xE0};
MOBLK	dpost1fblk = {&post1,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0xE0};

MOBLK	bale0blk = {&bale0,BALE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	bale1blk = {&bale1,BALE1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	bale2blk = {&bale2,BALE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	dbale0blk = {&dbale0,DBALE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0x70};
MOBLK	dbale1fblk = {&bale1,BALE1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0x70};
MOBLK	dbale2blk = {&dbale2,DBALE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0x70};
MOBLK	balexpblk = {&balexpl,DUMMY_TYPE,2,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_ODEL,0xC0};

MOBLK	trash0blk = {&trash0,TRASH0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	trash1blk = {&trash1,TRASH1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	trash2blk = {&trash2,TRASH2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	trashxpblk = {&trashxpl,DUMMY_TYPE,2,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};

MOBLK	tire0blk = {&tire0,TIRE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	tire1blk = {&tire1,TIRE1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	tire2blk = {&tire2,TIRE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	dtire0blk = {&dtire0,DTIRE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0x70};
MOBLK	dtire1fblk = {&tire1,DUMMY_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0x70};
MOBLK	dtire2blk = {&dtire2,DTIRE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0x70};
MOBLK	dtire0fblk = {&tire0,DUMMY_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0x70};
MOBLK	tirexpblk = {&tirexpl,DUMMY_TYPE,2,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_ODEL,0x80};

MOBLK	bag0blk = {&bag0,BAG0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	bag1blk = {&bag1,BAG1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	bag2blk = {&bag2,BAG2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	bagxpblk = {&bagxpl,DUMMY_TYPE,2,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	dbag0blk = {&dbag0,DBAG0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0x80};
MOBLK	dbag1fblk = {&bag1,BAG1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0x80};
MOBLK	dbag2blk = {&dbag2,DBAG2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,0x80};
MOBLK	dbag0fblk = {&bag0,BAG0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,0x80};

MOBLK	bump0blk = {&bump0,BUMP0_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump1blk = {&bump1,BUMP1_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump1fblk = {&bump1a,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump2blk = {&bump2,BUMP2_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump3blk = {&bump3,BUMP3_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump3fblk = {&bump3a,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump4blk = {&bump4,BUMP4_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump5blk = {&bump5,BUMP5_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	bump5fblk = {&bump5a,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	mud0blk = {&mud0,MUD0_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	mud1blk = {&mud1,MUD1_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	mud1fblk = {&mud1a,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	splashblk = {&splash,DUMMY_TYPE,3,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_ODEL,FULL_SCALE};

MOBLK	dirt0blk = {&dirt0,DIRT0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	ddirt0blk = {&ddirt0,DDIRT0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	ddirt1fblk = {&dirt1,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dirt1blk = {&dirt1,DIRT1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dirt2blk = {&dirt2,DIRT2_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	ddirt2blk = {&ddirt2,DDIRT2_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	ddirt3fblk = {&dirt3,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dirt3blk = {&dirt3,DIRT3_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,HALF_SCALE};
MOBLK	dirt4blk = {&dirt4,DIRT4_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,HALF_SCALE};

MOBLK	cornblk = {&corn,CORN_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	cornfblk = {&cornf,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	cact0blk = {&cactus0,CACT0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	cact1blk = {&cactus1,CACT1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dcact0blk = {&dcactus0,DCACT0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dcact1fblk = {&cactus1,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,HALF_SCALE};

MOBLK	bldg0blk = {&bldg0,BLDG0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bldg1blk = {&bldg1,BLDG1_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bldg2blk = {&bldg2,BLDG2_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bldg3blk = {&bldg3,BLDG3_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bldg4blk = {&bldg4,BLDG4_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bldg5blk = {&bldg5,BLDG5_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	bldg6blk = {&bldg6,BLDG6_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dbldg0blk = {&dbldg0,DBLDG0_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dbldg1fblk = {&bldg1,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dbldg2blk = {&dbldg2,DBLDG2_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dbldg3fblk = {&bldg3,DUMMY_TYPE,0,MO_PAL6,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};

MOBLK	tree0blk = {&tree0,TREE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	tree1blk = {&tree1,TREE1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	tree2blk = {&tree2,TREE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	tree3blk = {&tree3,TREE3_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	tree4blk = {&tree4,TREE4_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	tree5blk = {&tree5,TREE5_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	tree6blk = {&tree6,TREE6_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	palmblk  = {&palm,PALM_TYPE,0,MO_PAL10,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree0blk = {&dtree0,DTREE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree0fblk = {&tree0,TREE0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree1blk = {&dtree1,DTREE1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree1fblk = {&tree1,TREE1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree2blk = {&dtree2,DTREE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree2fblk = {&tree2,TREE2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree3blk = {&dtree3,DTREE3_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree3fblk = {&tree3,TREE3_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree4blk = {&dtree4,DTREE4_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree4fblk = {&tree4,TREE4_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree5blk = {&dtree5,DTREE5_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree5fblk = {&tree5,TREE5_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree6blk = {&dtree6,DTREE6_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dtree6fblk = {&tree6,TREE6_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dpalmblk = {&dpalm,DPALM_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX,FULL_SCALE};
MOBLK	dpalmfblk = {&palm,PALM_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FLIP|MO_FIX|MO_ODEL,FULL_SCALE};

MOBLK	trees0blk = {&trees0,TREES0_TYPE,0,MO_PAL10,MO_PFM|MO_ZMAP|MO_FIX|MO_CLIP|MO_ODEL,FULL_SCALE};
MOBLK	trees1blk = {&trees1,TREES1_TYPE,0,MO_PAL10,MO_PFM|MO_ZMAP|MO_FIX|MO_CLIP|MO_ODEL,FULL_SCALE};
MOBLK	treesfblk = {&trees1,DUMMY_TYPE,0,MO_PAL10,MO_PFM|MO_ZMAP|MO_FIX|MO_CLIP|MO_FLIP|MO_ODEL,FULL_SCALE};

MOBLK	standblk = {&stand,STAND_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	wreck0blk = {&wreck0,WRECK0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xA0};
MOBLK	wreck1blk = {&wreck1,WRECK1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x90};
MOBLK	wreck2blk = {&wreck2,WRECK2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x90};

MOBLK	rock0blk = {&rock0,ROCK0_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	rock1blk = {&rock1,ROCK1_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	rock2blk = {&rock2,ROCK2_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	rock3blk = {&rock3,ROCK3_TYPE,0,MO_PAL28,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};

MOBLK	cowblk = {&cow,COW_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	cowsblk = {&cows,COWS_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};

MOBLK	car0blk = {&car0,CAR0_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car2blk = {&car2,CAR2_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xD0};
MOBLK	car3blk = {&car3,CAR3_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car4blk = {&car4,CAR4_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car5blk = {&car5,CAR5_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car6blk = {&car6,CAR6_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car7blk = {&car7,CAR7_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car8blk = {&car8,CAR8_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car9blk = {&car9,CAR9_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car10blk = {&car10,CAR10_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car11blk = {&car11,CAR11_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car12blk = {&car12,CAR12_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	car13blk = {&car13,CAR13_TYPE,0,MO_PAL12,MO_PFM|MO_CLIP|MO_ZMAP|MO_ODEL,0xC0};

MOBLK	dune0blk = {&dune0,DUNE0_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dune0fblk = {&dune0f,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL|MO_FLIP,FULL_SCALE};
MOBLK	dune1blk = {&dune1,DUNE1_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dune1fblk = {&dune1f,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL|MO_FLIP,FULL_SCALE};
MOBLK	dune2blk = {&dune2,DUNE2_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dune2fblk = {&dune2f,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL|MO_FLIP,FULL_SCALE};
MOBLK	dune3blk = {&dune3,DUNE3_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dune3fblk = {&dune3f,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL|MO_FLIP,FULL_SCALE};
MOBLK	curb0blk = {&curb0,CURB0_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	curb0fblk = {&curb0f,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL|MO_FLIP,FULL_SCALE};
MOBLK	grassblk = {&grass,GRASS_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	grassfblk = {&grassf,DUMMY_TYPE,0,MO_PAL28,MO_PFM|MO_ZMAP|MO_FIX|MO_ODEL|MO_FLIP,FULL_SCALE};

MOBLK	rhinoblk = {&rhino,RHINO_TYPE,0,MO_PAL8,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xE0};
MOBLK	eleblk = {&elephant,ELE_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	lionblk = {&lion,LION_TYPE,0,MO_PAL10,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xA0};

MOBLK	mask0blk = {&mask0,DUMMY_TYPE,0,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	mask1blk = {&mask1,DUMMY_TYPE,0,MO_PAL8,MO_NOX,FULL_SCALE};
MOBLK	bill0blk = {&bill0,DUMMY_TYPE,6,MO_PAL8,MO_NOX|MO_ODEL,FULL_SCALE};
MOBLK	bill1blk = {&bill1,DUMMY_TYPE,6,MO_PAL8,MO_NOX|MO_ODEL,FULL_SCALE};

/*	Editor blocks			*/
MOBLK	trees0blke = {&trees0,TREES0_TYPE,0,MO_PAL14,MO_PFM|MO_ZMAP|MO_FIX|MO_CLIP|MO_ODEL,FULL_SCALE};
MOBLK	drail0blke = {&drail0,DRAIL0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	dtire0blke = {&dtire0,DTIRE0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	dtire2blke = {&dtire2,DTIRE2_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	dpostblke = {&dpost,DPOST_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	dpost1blke = {&dpost1,DPOST1_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0xC0};
MOBLK	dbale0blke = {&dbale0,DBALE0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	dbale2blke = {&dbale2,DBALE2_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x70};
MOBLK	dtree0blke = {&dtree0,DTREE0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree1blke = {&dtree1,DTREE1_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree2blke = {&dtree2,DTREE2_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree3blke = {&dtree3,DTREE3_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree4blke = {&dtree4,DTREE4_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree5blke = {&dtree5,DTREE5_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dtree6blke = {&dtree6,DTREE6_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dpalmblke = {&dpalm,DPALM_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dsign0blke = {&dsign0,DSIGN0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dsign1blke = {&dsign1,DSIGN1_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	ddirt0blke = {&ddirt0,DDIRT0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	ddirt2blke = {&ddirt2,DDIRT2_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dcact0blke = {&dcactus0,DCACT0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,HALF_SCALE};
MOBLK	dbldg0blke = {&dbldg0,DBLDG0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dbldg2blke = {&dbldg2,DBLDG2_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,FULL_SCALE};
MOBLK	dbag0blke = {&dbag0,DBAG0_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};
MOBLK	dbag2blke = {&dbag2,DBAG2_TYPE,0,MO_PAL14,MO_PFM|MO_CLIP|MO_ZMAP|MO_FIX|MO_ODEL,0x80};


/* These routines called from setobj() during normal gameplay */
MOSET	settbl[] = {
	&test0blk,&rts(),&rts(),
	&rat0blk,&rts(),&rts(),
	&laserblk,&rts(),&del_laser(),
	&test0blk,&rts(),&rts(),
	&gate1blk,&set_gate(),&del_obs(),
	&cowblk,&set_ob1(),&del_ob1(),
	&arab2blk,&rts(),&rts(),
	&arab3blk,&rts(),&rts(),
	&rock0blk,&set_rock(),&del_obs(),
	&rock1blk,&set_rock(),&del_obs(),
	&bump0blk,&set_obs(),&del_obs(),
	&bump1blk,&set_obs(),&del_obs(),
	&drnblk,&rts(),&del_drn(),
	&bump4blk,&set_obs(),&del_obs(),
	&bump5blk,&set_obs(),&del_obs(),
	&palmblk,&set_obs1(),&del_tree(),
	&tire1blk,&set_bale(),&rts(),
	&tire2blk,&set_bale(),&rts(),
	&rail0blk,&set_rail(),&rts(),
	&dune0blk,&rts(),&rts(),
	&trees0blk,&rts(),&rts(),
	&tratblk,&set_trat(),&rts(),
	&body0blk,&set_body(),&rts(),
	&shadowblk,&set_shadow(),&rts(),
	&gate0blk,&set_gate(),&del_obs(),
	&sign0blk,&set_obs(),&del_obs(),
	&bale0blk,&set_bale(),&rts(),
	&bale1blk,&set_bale(),&rts(),
	&trees1blk,&rts(),&rts(),
	&tree0blk,&set_obs1(),&del_tree(),
	&standblk,&rts(),&rts(),
	&tire0blk,&set_bale(),&rts(),
	&drone0blk,&set_drone(),&del_drone(),
	&drone1blk,&set_drone(),&del_drone(),
	&drone2blk,&set_drone(),&del_drone(),
	&drone3blk,&set_drone(),&del_drone(),
	&test0blk,&set_drone(),&del_drone(),
	&dirt0blk,&rts(),&rts(),
	&dirt1blk,&rts(),&rts(),
	&dirt2blk,&rts(),&rts(),
	&dirt3blk,&rts(),&rts(),
	&bale2blk,&set_bale(),&rts(),
	&test0blk,&rts(),&rts(),
	&mud0blk,&set_obs(),&del_obs(),
	&mud1blk,&set_obs(),&del_obs(),
	&trash0blk,&set_bale(),&rts(),
	&trash1blk,&set_bale(),&rts(),
	&trash2blk,&set_bale(),&rts(),
	&tree1blk,&set_obs1(),&del_tree(),
	&tree2blk,&set_obs1(),&del_tree(),
	&tree3blk,&set_obs1(),&del_tree(),
	&wreck0blk,&rts(),&rts(),
	&wreck1blk,&rts(),&rts(),
	&wreck2blk,&rts(),&rts(),
	&car0blk,&set_cars(),&del_obs(),
	&car10blk,&set_cars(),&del_obs(),
	&car2blk,&set_cars(),&del_obs(),
	&car3blk,&set_cars(),&del_obs(),
	&car4blk,&set_cars(),&del_obs(),
	&car5blk,&set_cars(),&del_obs(),
	&car6blk,&set_cars(),&del_obs(),
	&car7blk,&set_cars(),&del_obs(),
	&car8blk,&set_cars(),&del_obs(),
	&car9blk,&set_obs(),&del_obs(),
	&bag0blk,&set_bale(),&rts(),
	&bag1blk,&set_bale(),&rts(),
	&bag2blk,&set_bale(),&rts(),
	&gate2blk,&set_gate(),&del_obs(),
	&drail0blk,&set_rail(),&rts(),
	&dpostblk,&set_rail(),&rts(),
	&postblk,&set_rail(),&rts(),
	&dune1blk,&rts(),&rts(),
	&dirt4blk,&rts(),&rts(),
	&cornblk,&rts(),&rts(),
	&cact0blk,&rts(),&rts(),
	&cact1blk,&rts(),&rts(),
	&bldg0blk,&rts(),&rts(),
	&tree4blk,&set_obs1(),&del_tree(),
	&bldg1blk,&rts(),&rts(),
	&bldg2blk,&rts(),&rts(),
	&bump2blk,&set_obs(),&del_obs(),
	&bump3blk,&set_obs(),&del_obs(),
	&curb0blk,&rts(),&rts(),
	&sign1blk,&set_obs(),&del_obs(),
	&hydrntblk,&rts(),&rts(),
	&dtire0blk,&set_bale(),&rts(),
	&dtire2blk,&set_bale(),&rts(),
	&dbale0blk,&set_bale(),&rts(),
	&dbale2blk,&set_bale(),&rts(),
	&dtree0blk,&set_obs1(),&del_tree(),
	&dsign0blk,&set_obs(),&del_obs(),
	&ddirt0blk,&rts(),&rts(),
	&ddirt2blk,&rts(),&rts(),
	&dcact0blk,&rts(),&rts(),
	&cowsblk,&rts(),&rts(),
	&crowd0blk,&set_obs(),&del_obs(),
	&dbag0blk,&set_bale(),&rts(),
	&dbag2blk,&set_bale(),&rts(),
	&bldg3blk,&rts(),&rts(),
	&dbldg0blk,&rts(),&rts(),
	&dbldg2blk,&rts(),&rts(),
	&dtree1blk,&set_obs1(),&del_tree(),
	&dtree2blk,&set_obs1(),&del_tree(),
	&dtree3blk,&set_obs1(),&del_tree(),
	&dtree4blk,&set_obs1(),&del_tree(),
	&dpalmblk,&set_obs1(),&del_tree(),
	&dsign1blk,&set_obs(),&del_obs(),
	&bldg4blk,&rts(),&rts(),
	&post1blk,&rts(),&rts(),
	&dpost1blk,&rts(),&rts(),
	&bldg5blk,&rts(),&rts(),
	&bldg6blk,&rts(),&rts(),
	&car11blk,&set_cars(),&del_obs(),
	&dune2blk,&rts(),&rts(),
	&dune3blk,&rts(),&rts(),
	&arab0blk,&set_ob1(),&del_ob1(),
	&rock3blk,&set_obs(),&del_obs(),
	&car12blk,&set_obs(),&del_obs(),
	&car13blk,&set_taxi(),&del_obs(),
	&crowd4blk,&set_ob1(),&del_ob1(),
	&crowd2blk,&set_ob1(),&del_ob1(),
	&crowd3blk,&set_ob1(),&del_ob1(),
	&rock2blk,&set_obs(),&del_obs(),
	&rhinoblk,&set_ob1(),&del_ob1(),
	&grassblk,&rts(),&rts(),
	&eleblk,&rts(),&rts(),
	&lionblk,&rts(),&rts(),
	&tree5blk,&set_obs1(),&del_tree(),
	&dtree5blk,&set_obs1(),&del_tree(),
	&dtree6blk,&set_obs1(),&del_tree(),
	&dtree6blk,&set_obs1(),&del_tree()};

MOBLK	*dronetbl[] = {&drone0blk,&drone1blk,&drone2blk,&drone3blk, };
MOBLK	*dyellotbl[] = {&dron0yblk,&dron1yblk,&drone2blk,&drone3blk, };
