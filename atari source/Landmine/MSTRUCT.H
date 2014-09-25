/*
	mstruct.h

	Landmine game structure definitions.
	Copyright 1992 Kenneth Soohoo
*/

#define TRUE		1
#define FALSE		0

#define ACCEPT		0
#define WAIT_RELEASE	1

#define FROZEN		0		/* Everything stopped until click */
#define ACTIVE		1		/* User is playing it */
#define COMPLETE	2		/* User finished it just fine */
#define OVER		3		/* User is deado */

#define INSET		4		/* Amount to inset dialog border */

#define MAX_BOARDS	10
#define MAX_MINES	(50 * 100)	/* Max size of mine grid */
#define MAX_SCORE	999

/* Types of mines */
#define NO_MINE		(unsigned int )0	/* Empty square */
#define LAND_MINE	(unsigned int )1	/* A mine lies here */
#define WALL		(unsigned int )2	/* A wall piece */

/* Bit vector for current state */
#define HIDDEN		(unsigned int )0	/* Draw covered */
#define EXPOSED		(unsigned int )1	/* Draw 'real' state */
#define MARKED_MINE	(unsigned int )2	/* Draw as if a bomb lies here */

/* States for mark and sweep */
#define UNTOUCHED	(unsigned int )0
#define TOUCHED		(unsigned int )1

typedef struct landmine {
	int mine_type;		/* What are we... */
	int state;			/* User guess, exposed? */
	int mines_around;		/* 0-8 mines around */
	int marked;			/* For mark and sweep */
} MINE, *MINE_PTR;


