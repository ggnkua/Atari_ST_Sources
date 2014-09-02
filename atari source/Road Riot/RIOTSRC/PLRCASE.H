/*					*/
/*	Player states			*/
/*					*/
#define	P_DEAD		0
#define	P_END		1
#define	P_START		2
#define	P_DRIVE		3
#define	P_XPLO		4


/*					*/
/*	Player flags			*/
#define	PLR_CAVE	0x8000
#define	PLR_EXTFRIC	0x4000
#define	PLR_START	0x2000
#define	PLR_COLL	0x1000
#define	PLR_INAIR	0x0800
#define	PLR_OFFRAMP	0x0400
#define	PLR_CRASH	0x0200
#define	PLR_SIDE	0x0100
#define	PLR_GO		0x0080
#define	PLR_YLOCK	0x0040
#define	PLR_WCAVE	0x0020
#define	PLR_BEND	0x0010


/*					*/
/*	Player related constants	*/
/*					*/
#define	PLR_YMIN	0x600
#define	PLR_ZWIDTH	0x18
#define	FLY_MIN		0x2C0
