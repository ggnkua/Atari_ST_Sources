/*	Bale/Tire piles structure			*/

typedef	struct	baleblk
	{
	long	start;				/* Starting ypos of bale row		*/
	long	end;				/* Ending ypos of bale row		*/
	short	dy;				/* Deltay from first bale to second	*/
	short	xpos;				/* Bale xpos				*/
	WORD	flag;				/* Flags				*/
	} BALEBLK;

