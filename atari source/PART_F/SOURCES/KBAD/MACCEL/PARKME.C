#define MAXUNITS 16
typedef struct pun_info {
	int	puns;			/* # physical units */
	char	pun[MAXUNITS];		/* pun table (incl dummy A&B puns */
	long	partstart[MAXUNITS];	/* partition start table  (incl dums) */
	long	cookie;			/* cookie ('AHDI') */
	long	*cookptr;		/* ->cookie */
	int	version;		/* AHDI version: MMmm */
	int	maxssz;			/* max sector size in system */
	union {
	    unsigned char flag;
	    unsigned long time;
	} idle;			/* hi byte = 0xff :: time is valid */
				/* 24 bit idle time b4 spinning down ACSI 0 */
				/* (in 200Hz ticks - 5 min default) */
	long	reserved[15];
} PUN_INFO;


#define pun_ptr	    (*(PUN_INFO **)0x516)

int	    parktime;		/* time to park, in minutes,
				 * or -1 if autopark driver not there
				 */
/*
 * WARNING:  THIS PROCEDURE MUST BE EXECUTED IN SUPERVISOR MODE
 * WARNING:  THIS PROCEDURE MUST BE EXECUTED IN SUPERVISOR MODE
 * WARNING:  THIS PROCEDURE MUST BE EXECUTED IN SUPERVISOR MODE
 */
void
get_parktime( void )
{
    if( pun_ptr->cookie == 0x41484449L &&
	pun_ptr->cookptr == &(pun_ptr->cookie) &&
	pun_ptr->idle.flag == 0xff )
	parktime = (int)((pun_ptr->idle.time & 0xffffffL) / 12000L);
    else parktime = -1;
}

/*
 * WARNING:  THIS PROCEDURE MUST BE EXECUTED IN SUPERVISOR MODE
 * WARNING:  THIS PROCEDURE MUST BE EXECUTED IN SUPERVISOR MODE
 * WARNING:  THIS PROCEDURE MUST BE EXECUTED IN SUPERVISOR MODE
 */
void
set_ptime( void )
{
    if( parktime >= 0 )
        pun_ptr->idle.time = (parktime * 12000L) | 0xff000000L;
}
