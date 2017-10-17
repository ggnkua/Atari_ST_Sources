
#define		WRITETRACK	1
#define		READTRACK	2
#define		READADDR	3
#define		MULTIREAD	4
#define		MULTIWRITE	5
#define		READSECT	6
#define		WRITESECT	7

struct fdcntrl{
	short	trackno;	/* track where op is to occur */
	short	sideno;		/* side " " */
	char 	*buffer;	/* buffer to get/store data */
	short	sect;		/* Sector number */
	short	flags;		/* Flags for command */
};

