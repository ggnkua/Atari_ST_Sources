/*
 * 
 * prefix_p.h
 *
 * The master header file for PREFIX.PRG. This little file 
 * handles all of the function prototypes, external globals
 * across modules, etc.
 *
 * 90Feb21	towns		fixed the header to reflect reality.
 *				I added a set only flag for CPX entries
 *				and added the title string.	
 *
 * 90Feb21	towns		added the view_cpx(), sm_convert(),
 *				and lg_convert() prototypes.
 *
 * 90Feb20	towns		added the attach function proto.
 *
 * 90Jan29	towns		added the CPXHEAD structure for
 *				use by the loading and saving 
 *				routines.
 *
 * 90Jan25	towns		created.
 *
 */

/* -------------------------------------------------------------------- */
/* CPX Header Structure. This is 'tacked' onto the front of Each CPX 	*/
/* with a special program.						*/
/* -------------------------------------------------------------------- */

typedef struct _cpxhead {

	unsigned short	magic;			/* Magic Number = 100 		*/
	struct {
		unsigned reserved : 13;	/* Reserved for Expansion 	*/
		unsigned resident : 1;	/* RAM Resident Flag		*/
		unsigned bootinit : 1;	/* Boot Initialization Flag	*/
		unsigned setonly  : 1;	/* Set Only CPX Flag 		*/
	} flags;

	long		cpx_id;		/* The ID value 	 	*/
	unsigned short	cpx_version;	/* Version number 		*/

	char		i_text[14];	/* Icon Text			*/
	unsigned short	sm_icon[48];	/* Icon bitmap - 32x24 pixels	*/
	unsigned short	i_color;	/* Color for Icon		*/

	char		title_txt[18];	/* Title for CPX entry	 	*/
	unsigned short	t_color;	/* Pen value for text color	*/
	char		buffer[64];	/* Buffer for RAM storage 	*/

	char		reserved[306];	/* Reserved for Expansion	*/
 
} CPXHEAD;

#define MAGIC_CPX_NUM	100
