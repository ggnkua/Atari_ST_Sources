
#include "comp.h"

#define PTSBLK	struct ptsblk
struct ptsblk
{
	PTSBLK		*nextblk;
	int		points[8];
};

#define PRIMITIVE struct primitive
struct primitive
{
	int		op;
	int		wrmode;
	int		numpts;
	PRIMITIVE 	*nextprim;
	PTSBLK		*blkptr;
};


#define SCANINFO struct scaninfo
struct scaninfo
{
	int 		x1;
	int 		y1;
	int 		x2;
	int 		y2;
	char 		*textptr;
	struct slvll 	*slaveptr;
	SCANINFO	*nextscan;
};

  
#define ARTICLE struct article
#define REGION struct region

struct region
{
	PRIMITIVE 	*primlist;
	ARTICLE		*artptr;
	REGION		*plink;			/* Next link by pages       */
	REGION		*alink;			/* Next link by article     */
	SCANINFO	*scanlist;		/* Pointer to rectangle info*/
	int 		x1;			/* Corners of the bounding  */
	int 		y1;			/* rectangle containing all */
	int		x2;			/* of the primitives in the */
	int		y2;			/* region		    */
	int		p;			/* Page number of the region*/
	char		*txtstart;		/* Start of text in region  */
	struct txtattr  text;			/* Text attributes	    */
	int		grattr[11];		/* Attribute block	    */
	int		type;			/* text or graphic region   */
        int 		reserved;		/* 2 reserved words	    */
	int		res1;
	int 		multi_select;		/* multiple regions selected */
};

struct article
{
     	ARTICLE		*nextart;		/* Pointer to next article  */
	unsigned char	*buf_start;		/* Starting address of text */
        unsigned char	*buf_end;		/* End of allocated buffer  */
	unsigned char	*free_start;		/* End of text within buffer*/
	unsigned char	*current_char;		/* Current character pos.   */
	REGION		*regptr;		/* First region in it's list*/
	char 		filename[40];		/* File name of article     */
	int		dirty;			/* dirty article flag - R,X */
} ;

#define PAGE struct page
struct page
{
	int 		pagenum;
	PAGE		*nextpage;
	REGION  	*regptr;
};

#define TRUE 		1
#define FALSE		0

#define MAXBLK 		8


#define PNUMBER struct pnumber	/* page number structure */
#define MAXBLK 		8
#define PTEXTMAX	50

struct pnumber
{
    int pfnum;			/* font number */
    int pptsize;		/* point size  */
    int pstsize;		/* set size    */
    int units;			/* current units */
    int ljust;			/* left justification:0-left 1-center 2-right*/
    int rjust;			/* right justification */
    int usage;			/* page usage : 0-left 1-right 2-both     */
    int vpos;			/* vertical pos: 0-top 1 - bottom	  */
    int display;		/* display or not...*/
    char text[PTEXTMAX];	/* text		    */
    int distance;		/* distance (in mu's*/
    int fpage;			/* print from page #*/
    int tpage;			/* print to page #  */
    struct txtattr tattrib;	/* attributes block */
};

#define REPELSTRUCT struct repelstruct
struct repelstruct
{
   long artholder;
   long regholder;
   REPELSTRUCT *next_rep;
};
