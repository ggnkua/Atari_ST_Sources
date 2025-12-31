/********************************************************************
 *
 *  memory.c		gebiet : xcarpet
 *-------------------------------------------------------------------
 *  verwaltung des speichers fÅr die funktionswerte und bildpunkte
 *-------------------------------------------------------------------
 *
 *
 ********************************************************************/
 
 /*  26. 5.88  stock  */
 /*  15.10.88 Beheben der Unschînheit "double *rowvectors" in 		*/
 /*   			double **rowvectors											*/

#include "..\carpet.h"
#include <portab.h>
#if COMPILER==TURBOC
	#include "..\memory.h"
	#include <stdlib.h>
	#include <aes.h>
#endif

#define NULL	NIL

#define MINRES		4	/*  auflîsungs-grenzwerte	*/
#define MAXRES		100
#define MAXPROD	8181

#define ELEMENTS	3	/* 3 werte pro raumpunkt x,y,z	*/
#define BLOCKS		8	/* max. 8 blîcke  bei ny=MAXRES	*/
				/* und nx*ny=MAXPROD		*/
#define BLOCKSIZE	32768L	/* max. grîûe eines speicherblocks */

#if COMPILER==MEGAMAX
extern char *malloc();
#endif

char *array2d;			/* globales feld der bildpunkte	*/
static double **rowvectors; 	/* adresse des arrays (mein lieber Gerd) */
										/* der spaltenvektoren	*/
static void  *block[BLOCKS];	/* zeigerfeld f. speicherblîcke	*/
static int bytes, xres;
static int plus=TRUE, minus=TRUE;
static long totalbytes;


static check_1res (res)
  int res;
{
  return (res >= MINRES  &&  res <= MAXRES);
}

static check_prod (nx, ny)
 int nx, ny;
{
  return ((long) nx * ny <= (long) MAXPROD);
}

int check_resolution (nx, ny)
  int nx, ny;
{
#if COMPILER==TURBOC
	int check_1res(int),check_prod(int, int);
#endif

  return (check_1res(nx) && check_1res(ny) && check_prod(nx,ny));
}

int get_yresolution (nx)
  int nx;
{
  return (!check_1res(nx))?  0 
    : ((nx * MAXRES >= MAXPROD)? (MAXPROD/nx)
    : MAXRES);
}

static void *emalloc (bytes)
  int bytes;
{
  char *addr;
  
  if (((addr = malloc (bytes + 1)) != NULL) && ((long) addr & 1L))
    addr += 1;
  return (addr);
}

void *reserve2d (nx, ny)
  int nx, ny;
{
#if COMPILER==TURBOC
	void *emalloc(int);
#endif

  bytes = 2 * sizeof (int) * nx * ny;
  
  return (emalloc(bytes));
}

static void * reserve_vec (nx)
  int nx;
{
#if COMPILER==TURBOC
	void *emalloc(int);
#endif

  bytes = sizeof (double *) * nx;
  
  return (emalloc(bytes));
}

static void init_xyz ()
{ 
  int i;
  
  array2d = NULL;
  rowvectors = NULL;
  
  for (i = 0; i < BLOCKS; i++)
    block [i] = NULL;
}

void xfree (addr)
  void *addr;	
{  
  if (addr)
    free (addr);
}

static void free_3d ()
{
  int i;
  
  for (i = 0; i < BLOCKS; i++)
    xfree (block [i]);
}

void free_2d ()
{
  xfree (array2d);
  array2d=NULL;
}

void free_xyz ()
{
#if COMPILER==TURBOC
	void free_3d(void);
	void init_xyz(void);
#endif

  xfree (array2d);
  xfree (rowvectors);
  free_3d ();
  init_xyz();
}

double * row_vector (x)
  int x;
{ 
  if (x < 0) 
  {
    x = 0;		/*   man kann ja nie wissen	*/
    if (minus) form_alert (1,"[2][Zugriff auf x < 0| ][ Weiter ]");
    minus = FALSE;
  }
  else if (x >= xres) 
  {
    x = xres - 1;
    if (plus) form_alert (1,"[2][Zugriff auf x >= xres| ][ Weiter ]");
    plus = FALSE;
  }
  return (((double**) rowvectors) [x]);
}

static void set_vectors (nx, ny, vectors, vec, block)
  int nx, ny, vectors;
  double **vec;
  void *block[];
{
  int k=0,i,n,kmax,size;
  double *addr;
 
  n = 1 + (nx - 1) / vectors;
  size = ny * ELEMENTS;

  for (i = 0 ; i < n; i++)
  {
    addr = block [i];
    kmax = (i == n-1)?  nx : (k + vectors);
    
    while (k < kmax)
    {
      vec [k] = addr;
      addr   += size;
      ++k;
    }
  }
}

static int reserve_3d (nx, ny)
  int nx, ny;
{
#if COMPILER==TURBOC
	void set_vectors(int, int, int, double **, void **);
#endif

  int element, vectors, blocks, last, ok=1, i=0;
  
  element = sizeof (double) * ELEMENTS;
  totalbytes = (long) nx * ny * element;
  vectors = BLOCKSIZE / (ny * element);
  blocks  = 1 + (nx - 1) / vectors;
  bytes   = ny * vectors * element;
  last    = totalbytes - bytes * (blocks - 1);

  for (i = 0; i < BLOCKS; i++)
  {
    if (i < blocks  &&  ok)
      ok = NULL != (block [i] = emalloc ((i < blocks-1)? bytes : last));
    else
      block [i] = NULL; 
  }
  if (ok)
    set_vectors (nx, ny, vectors, rowvectors, block);
    /* rowvectors war einfacher Double Pointer und nicht doppelter? */
  return (ok);
}

int reservexyz (nx, ny)
  int nx,ny;
{
#if COMPILER==TURBOC
	void *reserve2d(int, int);
	int   reserve_3d(int, int);
	void *reserve_vec(int, int);
#endif

  int ok;
  
  init_xyz();
  
  ok = ( check_resolution (nx,ny)
       && (NULL != (array2d = reserve2d (nx,ny)))
       && (NULL != (rowvectors = reserve_vec (nx,ny)))
       && reserve_3d (nx,ny));

  if (ok)
  {
    xres = nx;
  }
  else
  { 
    xres = 1; 
    free_xyz ();
  }
  plus = minus = TRUE;

  return (ok);
}

/********************************************************************/
