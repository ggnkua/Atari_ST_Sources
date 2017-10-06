
#define MAXCONN 4


/*****************************************************/
/*****************************************************/
/*****************************************************/

			      
typedef struct _conn { /* conn to PE */ 	     
   int	 PESource;     /* index to a PE source */    
   float ConnWt;       /* connection weight */	     
   float LastDelta;    /* last weight change */      
} CONN; 					     
						     
typedef struct _pe {   /* processing element */      
   float Output;       /* PE output */		     
   float Error;        /* Accumulated error */	     
   CONN  Conns[MAXCONN+1]; /* connections */	     
} PE;						     
						     

/*** PE 1 in layer "inp" (Bias) ***/
static PE pe1 = {0.0, 0.0,  /* default output & error */
		 0,0,0 };


/*** PE 2 in layer "inp" ***/ 
static PE pe2 = {0.0, 0.0,  /* default output & error */
		 0,0,0 };


/*** PE 3 in layer "inp" ***/ 
static PE pe3 = {0.0, 0.0,  /* default output & error */
		 0,0,0 };


/*** PE 4 in layer "hidd" ***/ 
static PE pe4 = {0.0, 0.0,  /* default output & error */
		 1,0,0,
		 2,0,0,
		 3,0,0,
		 0,0,0 };


/*** PE 5 in layer "out" ***/ 
static PE pe5 = {0.0, 0.0,  /* default output & error */
		 1,0,0,
		 2,0,0,
		 3,0,0,
		 4,0,0,
		 0,0,0 };

/* PE list. For reference by number/index */
static PE *PEList[] = { (PE *)0, 
	&pe2, 
	&pe3, 
	&pe4, 
	&pe5, 
	(PE *)0 }; 

/* Layer definitions */
static PE *Layinp[] = { 
	&pe1, 
	&pe2, 
	&pe3, 
	(PE *)0 };

static PE *Layhidd[] = { 
	&pe4, 
	(PE *)0 };

static PE *Layout[] = { 
	&pe5, 
	(PE *)0 };

/* Network list */
static PE **LayList[] = { 
	&Layinp[0], 
	&Layhidd[0], 
	&Layout[0], 
	(PE **)0 }; 

