/*	Laser linked list structure		*/
typedef	struct	lasblk
	{
	MDTYPE	*op;				/* Pointer to laser's obj structure	*/
	BYTE	lsflags;			/* Active flags and system ID	*/
	BYTE	owner;				/* Who owns me?			*/
	} LASBLK;

#define	LASER_ACTIVE	0x80
#define	LASER_SPEED	0x40
#define	LASER_DEL	0x20


