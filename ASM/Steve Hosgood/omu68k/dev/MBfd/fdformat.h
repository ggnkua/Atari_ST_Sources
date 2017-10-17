
#define		WRITETRACK	1
#define		READTRACK	2
#define		READADDR	3
#define		MULTIREAD	4
#define		MULTIWRITE	5

struct fdcntrl{
	short	trackno;	/* track where op is to occur */
	short	sideno;		/* side " " */
	char 	*buffer;	/* buffer to get/store data */
};

