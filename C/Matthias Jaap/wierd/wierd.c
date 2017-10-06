/*
 *   Wierd Interpreter:
 *
 *	Wierd Language developed by Chris Pressey, August 1997
 *	Interpreter written 05 August 1997 by John Colagioia
 *
 *	Deviations from the "Official" Wierd:
 *		Direction:  The IP will always try to continue in the same
 *			direction (or as close as possible).  When two
 *			equally-likely possibilities exist, it will choose
 *			the "leftmost" branch.
 *		Conditionals:  When the IP connects to a 90-degree angle,
 *			it pops the stack.  If the result is zero, it
 *			continues as if nothing interesting happens.  If
 *			nonzero, it reverses the IP direction.
 *		Gap-Sparking:  If the IP has just "sparked into" a
 *			location which is isolated, the program is
 *			considered erroneous, as the IP direction is
 *			undefined at that time.
 *
 *	Revision History:
 *	   R#:   Date:	    Inits:   Reason:
 *	    0    05aug97    jnc	     Origination
 *	    1    06aug97    jnc	     Various Bugfixes, Revised Conditionals
 *	    2    07aug97    jnc	     Added Multithreading, Revised Conditionals
 *	    3    08aug97    jnc	     Added "Gap-Sparking"
 *	    4    08aug97    jnc	     General Cleanup and Bugfixes
 *
 *	To Do:
 *	    --	Heavier testing (requires writing Wierd code...).
 *	    --	Add a tty or graphical display routine.
 *
 */

/*** Preprocessor Directives ***/
	/* Included header files */
#include <stdio.h>
#include <stdlib.h>
/* malloc is already included in stdlib.h */
/*#include <malloc.h> */
	/* Constants and Macros */
#define	SIZE	128

/*** Data Structures ***/
struct	iplist	/* An instruction pointer */
	{
	 int	ipid;		/* A unique identifier */
	 int	x;		/* The current ordinate value */
	 int	y;		/* The current abscissa value */
	 int	dx;		/* The next change in x to be applied */
	 int	dy;		/* The next change in y to be applied */
	 int	stack[SIZE];	/* A stack exclusive to this IP */
	 int	s_top;		/* A pointer to the stack top */
	 struct	iplist	*next;	/* The next IP available */
	};

/*** Function Prototypes (only for the function table below) ***/
int	nop		(struct iplist **);
int	push1		(struct iplist **);
int	subtract	(struct iplist **);
int	condition	(struct iplist **);
int	getput		(struct iplist **);
int	inputoutput	(struct iplist **);
int	terminus	(struct iplist **);

/*** more prototypes, because my compiler likes them - cap */
int turn45 (int * xdir, int * ydir);
int getnextturn (int x, int y, int * dx, int * dy);

/*** Global Variables ***/
char	workspace[SIZE][SIZE];	/* The "Wierd memory space" */
int	tmpx, tmpy,		/* temporary deltas */
	ipid = 0, ip_killed;	/* IP identifier, kill flag */
struct	iplist	*list;		/* The list of IPs */
int	(*function[])(struct iplist **) =
		{		/* Function table */
		 nop,			/* 0 degrees */
		 push1,			/* 45 degrees */
		 condition,		/* 90 degrees */
		 getput,		/* 135 degrees */
		 terminus,		/* 180 degrees */
		 inputoutput,		/* 225 degrees */
		 condition,		/* 270 degrees */
		 subtract		/* 315 degrees */
		};

/*** Source code for Interpreter Functions ***/

/* Function main():
 *	Initializes data structures and environment, and iterates through
 *	each IP until termination.  Also handles most common errors.
 */
int main (int argc, char *argv[])
{
 int	i, x, y;	/* Temporary variables */
 FILE	*infile;	/* Input file */

 if (argc < 2)		/* Not enough arguments--don't know what to do */
	{
	 fprintf (stderr, "Wierd interpreter, Atari version\n\nError - no file specified:\n\t%s <Wierd Filename>\nFehler - keine Datei angegeben:\n\t%s <Wierd Dateiname>\n", argv[0]);
	 exit (1);
	}
 infile = fopen (argv[1], "r");
 if (infile == NULL)		/* Bad input filename given */
	{
	 fprintf (stderr, "Wierd interpreter, Atari version\n\nError - Invalid Wierd filename: \"%s\".\nFehler:  UngÅltiger Wierd-Dateiname: \"%s\".\n",
		argv[1],argv[1]);
	 exit (2);
	}

 for (x=0;x<SIZE;++x)		/* Clear the memoryspace */
	for (y=0;y<SIZE;++y)
		workspace[x][y] = '\000';

 y = 1;				/* Read the file into the memoryspace */
 while (!feof (infile))
	{
	 fscanf (infile, "%[^\n]", &workspace[y][1]);
	 fgetc (infile);
	#ifdef DEBUG
	 printf ("%s\n", &workspace[y][1]);
	#endif
	 ++y;
	}
 fclose (infile);		/* Clean up file handles */
 for (x=0;x<SIZE;++x)		/* Convert nulls to spaces */
	for (y=0;y<SIZE;++y)
		if (workspace[x][y] == '\000')
			workspace[x][y] = ' ';

				/* Initialize the first IP */
 list = (struct iplist *) malloc (sizeof (struct iplist));
 list->x = list->y = list->dx = list->dy = 1;
 list->s_top = 0;
 list->next = list;
 list->ipid = ++ipid;

			/* Loop as long as the location is valid */
 while (workspace[list->x][list->y] != ' ')
	{
	 ip_killed = 0;		/* Initialize the kill-flag */
	#ifdef DEBUG
	 printf ("<%d>\t", list->ipid);
	 printf ("(%d,%d)\t", list->y, list->x);
	 for (i=0;i<list->s_top;++i)
		printf ("[%d] ", list->stack[i]);
	#endif
	 tmpx = list->dx;	/* Save the current direction */
	 tmpy = list->dy;		/* and change it */
	 i = getnextturn (list->x, list->y, &tmpx, &tmpy);
	#ifdef DEBUG
	 printf ("\t\t%d\n", i);
	#endif
	 if (i % 45)		/* Invalid direction! */
		printf ("\007ERROR!!\007\n");
	 else	{		/* Call the appropriate function */
		 i = function[i/45](&list);
		 if (i == -1)		/* Out of IPs */
			{
			 free (list);
			 return 0;
			}
		}
	 if (!ip_killed)	/* Only update if it's the same IP */
		{
		 list->x += list->dx = tmpx;	/* Update location */
		 list->y += list->dy = tmpy;
		 list = list->next;		/* Next IP */
		}
	}
#ifdef DEBUG
 printf ("Program ungracefully terminated!\n");
#endif
 return 0;
}

/* Function checkdir():
 *	Simple function to determine validity of location a given delta
 *	from the given location.
 */
int checkdir (int x, int y, int dx, int dy)
{
 return (workspace[x+dx][y+dy] != ' ');	/* Only space is invalid */
}

/* Function rotate():
 *	Turns an IP the specified number of degrees (though only in 45-
 *	degree increments).
 */
int rotate (int * xdir, int * ydir, int turn)
{
 int	i;

 for (i=0;i<turn;i+=45)		/* We only work in 45-degree increments */
	turn45 (xdir, ydir);
 return 0;
}

/* Function turn45():
 *	Rotates a dx,dy heading 45 degrees clockwise.  Very unclean
 *	implementation, but it works for now.  Once we expand beyond two
 *	dimensions, though, this will have to be heavily rewritten.
 */
int turn45 (int * xdir, int * ydir)
{
 if (*ydir == 1 && *xdir == -1 || *ydir == -1 && *xdir == 1)
	*ydir = 0;
 else if (*xdir == 1 && *ydir == 1 || *xdir == -1 && *ydir == -1)
	*xdir = 0;
 else if (*ydir)
	*xdir -= *ydir;
 else	*ydir += *xdir;
 return 0;
}

/* Function getnextturn():
 *	Checks the 7 of the 8 valid directions from the given point,
 *	choosing those 7 based on the IP delta.  Returns the "leftmost"
 *	direction closest to "straight" that is available from the given
 *	location.
 */
int getnextturn (int x, int y, int * dx, int * dy)
{
 if (checkdir (x, y, *dx, *dy))
	return 0;
 rotate (dx, dy, 45);
 if (checkdir (x, y, *dx, *dy))
	return 45;
 rotate (dx, dy, 270);
 if (checkdir (x, y, *dx, *dy))
	return 315;
 rotate (dx, dy, 135);
 if (checkdir (x, y, *dx, *dy))
	return 90;
 rotate (dx, dy, 180);
 if (checkdir (x, y, *dx, *dy))
	return 270;
 rotate (dx, dy, 225);
 if (checkdir (x, y, *dx, *dy))
	return 135;
 rotate (dx, dy, 90);
 if (checkdir (x, y, *dx, *dy))
	return 225;
 return 180;
}

/* Function add_thread():
 *	Inserts a node on the circular linked list of IPs, and initializes
 *	the node as a new IP.
 */
int add_thread (struct iplist * ip, int dx, int dy)
{
 struct iplist	*temp;
 int		 i;

				/* Create new node on list */
 temp = (struct iplist *) malloc (sizeof (struct iplist));
 temp->ipid = ++ipid;		/* Give an identifier */
 temp->next = ip->next;		/* Insert into list */
 temp->x = ip->x - dx;		/* Initialize based on current IP */
 temp->y = ip->y - dy;
 temp->dx = - dx;
 temp->dy = - dy;
 temp->s_top = ip->s_top;
 for (i=0;i<ip->s_top;++i)
	temp->stack[i] = ip->stack[i];
 ip->next = temp;
#ifdef DEBUG
 printf ("Thread #%d created.\n", temp->ipid);
#endif
 return 0;
}

/* Function kill_thread():
 *	Removes the current node from the circular linked list of IPs.
 */
int kill_thread (struct iplist ** ip)
{
 struct	iplist	*temp;
#ifdef DEBUG
 int	id;

 id = (*ip)->ipid;
#endif
 temp = *ip;
 while (temp->next != *ip)	/* Get IP before this one */
	temp = temp->next;
 temp->next = (*ip)->next;	/* Point around the current IP */
 free (*ip);			/* Deallocate the IP */
 *ip = temp;			/* Return the previous one */
#ifdef DEBUG
 printf ("Thread #%d destroyed, passing to #%d.\n", id, (*ip)->ipid);
#endif
 return 0;
}

/* Function find_far():
 *	Called when the IP has no obvious place to go.  Checks the region
 *	around (7x7 locations) the current IP location for a "closest
 *	point" based on the current location as well as the current IP
 *	direction.
 */
int find_far (int x, int y, int dx, int dy, int **xcoors, int **ycoors)
{
 int	i, j, pts, xs[40], ys[40], ti, tj,
	a[] = {2, 3, -2, -3, 0, 1, -1};		/* Order of precedence */

 pts = 0;
 for (i=0;i<7;++i) for (j=0;j<7;++j)
	/* Scan along the array in two dimensions */
	if (i < 4 || j < 4)	/* If at least one index looks at {2,3} */
		{
		 ti = dx>0?a[i]:-a[i];	/* Invert if a delta is */
		 tj = dy>0?a[j]:-a[j];		/* negative */
		 if (x>a[i] && y>a[j] &&
			workspace[x+ti][y+tj] != ' ')
			{	/* If the location exists and isn't */
			 xs[pts] = x + ti;	/* a space */
			 ys[pts] = y + tj;	/* Add to list */
			 if (xs[pts] > 0 && ys[pts] > 0)
				++ pts;
			}
		}
 *xcoors = (int *) malloc (sizeof (int) * pts);
 *ycoors = (int *) malloc (sizeof (int) * pts);
 for (i=0;i<pts;++i)	/* Copy the list of candidates to where the */
	{			/* calling function suggests */
	 (*xcoors)[i] = xs[i];
	 (*ycoors)[i] = ys[i];
	}
 return (pts);		/* Return the number of points found */
}

/*** Source Code for internal Interpreter Operations (called from the
     function table only ***/

/* Function nop():
 *	No-operation.
 */
int nop (struct iplist ** list)
{
 return 0;			/* Self-explanatory */
}

/* Function push1():
 *	Pushes a constant value 1 onto the IP's stack.
 */
int push1 (struct iplist ** ip)
{
 struct	iplist	*list = *ip;

 list->stack[list->s_top++] = 1;	/* Self-explanatory */
 return 0;
}

/* Function condition():
 *	If the top of the IP's stack is zero, functions as nop().
 *	Otherwise, it reverses the direction of the IP.
 */
int condition (struct iplist ** ip)
{
 int	i;
 struct	iplist	*list = *ip;

		/* Two coincident 90-degree turns spawns a new IP */
 if (workspace[list->x-tmpx][list->y-tmpy] != ' ')
	add_thread (list, tmpx, tmpy);
		/* Otherwise, check top of the stack determines whether */
			/* we continue or change direction */
 else if (list->s_top && list->stack[--list->s_top])
	{
	 list->x += tmpx;
	 list->y += tmpy;
	 i = tmpx;	/* Reflect the IP */
	 tmpx = -tmpy;
	 tmpy = -i;
	 i = getnextturn (list->x, list->y, &tmpx, &tmpy);
	#ifdef DEBUG
	 printf ("<%d>\t", list->ipid);
	 printf ("(%d,%d)\t", list->y, list->x);
	 for (i=0;i<list->s_top;++i)
		printf ("[%d] ", list->stack[i]);
	 printf ("\t\t%d\n", i);
	#endif
	}
 *ip = list;	/* Fix the IP list in case the current thread changed */
 return 0;
}

/* Function getput():
 *	If the top of the stack is zero, retrieves the byte stored at the
 *	coordinates specified on the stack.  Otherwise, takes the element
 *	on the stack beneath the coordinates and stores the value at those
 *	coordinates.
 */
int getput (struct iplist ** ip)
{
 int	xcoor, ycoor;
 struct	iplist	*list = *ip;

 if (list->s_top < 3)	/* Not enough stack elements to do anything */
	return 1;
 if (list->stack[--list->s_top])	/* A non-zero is a "put" */
	{
	 xcoor = list->stack[--list->s_top];
	 ycoor = list->stack[--list->s_top];
	 list->stack[list->s_top++] = workspace[xcoor][ycoor];
	}
 else	{				/* Otherwise it's a "get" */
	 xcoor = list->stack[--list->s_top];
	 ycoor = list->stack[--list->s_top];
	 workspace[xcoor][ycoor] = list->stack[--list->s_top];
	}
 return 0;
}

/* Function inputoutput():
 *	If the top of the stack is zero, gets a character from input.
 *	Otherwise, it prints the next character on the stack.
 */
int inputoutput (struct iplist ** ip)
{
 struct	iplist	*list = *ip;

 if (list->s_top < 1)		/* Nothing useful on the stack */
	return 1;
 if (list->stack[--list->s_top])	/* If it's nonzero, print the next */
	putchar (list->stack[--list->s_top]);
					/* Otherwise request a character */
 else	list->stack[list->s_top++] = getchar ();
 return 0;
}

/* Function subtract():
 *	Subtracts the top two stack elements.
 */
int subtract (struct iplist ** ip)
{
 struct	iplist	*list	= *ip;

 if (list->s_top < 2)	/* Can't subtract without two elements */
	return 1;
 list->stack[list->s_top - 2] -= list->stack[list->s_top - 1];
 --list->s_top;		/* Otherwise, subtract top from under and pop */
 return 0;
}

/* Function terminus():
 *	Based on current environmental conditions, either sparks the IP
 *	across the gap, or kills the IP.
 */
int terminus (struct iplist ** ip)
{
 int	i, j, k, *xlist, *ylist;
 struct	iplist	*list = *ip;

			/* Check for a line to spark to */
 j = find_far (list->x, list->y, list->dx, list->dy, &xlist, &ylist);
#ifdef DEBUG
 for (k=0;k<j;++k)
	printf ("\t\t{%d,%d}\n", ylist[k], xlist[k]);
#endif
 if (j < 3)		/* Less than three means it's probably our */
	{			/* incoming path */
	 if (list->next == list)
		return -1;	/* so kill the thread */
	 kill_thread (&list);
	 ip_killed = 1;
	}
 else	{		/* Otherwise, we have valid locations */
	 list->x = xlist[0];	/* and they *should* be ordered */
	 list->y = ylist[0];	/* by preference */
	 i = getnextturn (list->x, list->y, &tmpx, &tmpy);
	#ifdef DEBUG
	 printf ("==> %d choices available.\n", j);
	 printf ("<%d>\t", list->ipid);
	 printf ("(%d,%d)\t", list->y, list->x);
	 for (i=0;i<list->s_top;++i)
		printf ("[%d] ", list->stack[i]);
	 printf ("\t\t%d\n", i);
	#endif
	}
 *ip = list;	/* Fix the list pointer in case it was changed */
 return 0;
}
