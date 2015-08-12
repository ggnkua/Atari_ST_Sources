#include	<obdefs.h>
#include	<gemdefs.h>
#include	"comp.h"
#include	"bitmap.h"		/* defs structure bit_map_type	*/
#include	"cache.h"		/* defs cache structure		*/

/*
	Local Definitions
*/
#ifndef		FALSE
#define		FALSE		0
#endif
#ifndef		TRUE
#define		TRUE		1
#endif
#define		OFF		0
#define		ON		1
#define		H_PICA		216	/* X unit used in world Coord.	*/
#define		V_PICA		192	/* Y unit used in world Coord.	*/
#define		ULG		unsigned long

/*	Device Type = sdevm	*/
#define		DNUM		4	/* number of graphics devices	*/
#define		SLOR		0	/* Low    Res	320  x 200 	*/
#define		SMDR		1	/* Medium Res	640  x 200 	*/
#define		SHIR		2	/* High   Res	640  x 400	*/
#define		PRNT		3	/* Laser  Ptr	2400 x 3180	*/

/*
	Externals
*/
extern	struct bit_map_type
			*fm_char();	/* IFont char building function	*/
extern	struct slvll	*slv;		/* slave list pointer		*/
extern	int		shandle;	/* graphics output handle	*/
extern	FDB		*orect_MFDB;	/* output rectangle	MFDB	*/
extern	FDB		char_MFDB;	/* Intellifont		MFDB	*/
extern	unsigned long	last_y;
extern	int		clip_X0;	/* output rectangle clip X0	*/
extern	int		clip_X1;	/* output rectangle clip X1	*/
extern	int		clip_Y0;	/* output rectangle clip Y0	*/
extern	int		clip_Y1;	/* output rectangle clip Y1	*/

extern int mu_array[];	 		/* CS mu conversion array       */
unsigned 	lastpixy;
unsigned	lastmuy;

/*
	Conflict resolution
*/
unsigned	get_argument();

/*
	Device dependent tables
*/
unsigned xdpi[DNUM]	= {		/* Device Xdots/inch resolution	*/
/* LOW */	40,			/* 320 x 200	*/
/* MED */	80,			/* 640 x 200	*/
/* HIG */	80,			/* 640 x 400	*/
/* PRT */	300			/* 2400x3180	*/
};
unsigned ydpi[DNUM]	= {		/* Device Ydots/inch resolution	*/
/* LOW */	40,			/* 320 x 200	*/
/* MED */	40,			/* 640 x 200	*/
/* HIG */	80,			/* 640 x 400	*/
/* PRT */	300			/* 2400x3180	*/
};

/*
	Module globals
*/
struct packet_type	userpacket;/* IFont character packet	*/
static	struct {
	unsigned	x	;
	unsigned	y	;
	unsigned	psiz	;
	unsigned	ssiz	;
	unsigned	font	;
	unsigned	reverse	;
	unsigned	rev_top	;
	unsigned	rev_bot	;
}	present			;/* present slave scan struct	*/
static	struct {
	unsigned	px	;
	unsigned	py	;
	unsigned	psiz	;
	unsigned	ssiz	;
	unsigned	font	;
	char		ch	;
}	rvo			;/* Rev Video save char struct	*/
static	struct	bit_map_type
		Greek		;/* IFont struct. for Greeking	*/
unsigned	H_MARGIN	;/* Horizontal	Left	margin	*/
unsigned	V_MARGIN	;/* Vertical	Top	margin	*/
unsigned	zrat		;/* zoom ratio (100 = 100%)..	*/
unsigned	sdevm		;/* Current device mode		*/


/****************************************************************
*	Slave Output Handler					*
*	Desc :	This routine scans through the slave command 	*
*	buffer list to the end. It also calls the appropriate	*
*	function to execute these commands.			*
*	Calling convention :	show_slv()			*
****************************************************************/
show_slv()
{
	struct	slvll	*pslv		;/* present slave list pointer	*/
	unsigned char	*buffer_ptr	;
	unsigned	code		;
	int		index = 1	;

  pslv = slv				;/* set to beginning of list	*/
  do {					 /* for whole slave list...	*/
    buffer_ptr = pslv->bufptr		;/* set slave buffer pointers	*/
    do {				 /* for whole buffer...		*/
	code = get_argument(buffer_ptr)	;/* get the encoded word	*/
	if (!(code & 0xFF00))		 /* check if NULL command	*/
		index = 1		;
	else
	if ((code & 0x8080) == 0x8080)	 /* check if TYP command	*/
		index = exe_command(buffer_ptr);
	else
	if (code & 0x8000)		 /* check if long char format	*/
		index = exe_long_char(buffer_ptr);
	if (index > 0)
		buffer_ptr += index	;
    } while (index > 0)			;/* continue until index < 0	*/
  } while (pslv = pslv->fptr)		;/* until end of list...	*/
}

/****************************************************************
*	Function Name :		exe_long_char()			*
*	Desc :	This routine executes a long char command	*
*	Calling convention :	exe_long_char(buff_ptr)		*
*		unsigned char	*buff_ptr : pointer to command 	*
****************************************************************/
exe_long_char(buffer_ptr)
unsigned char	*buffer_ptr	;
{
	char	 dchar		;
	unsigned position	;

	dchar	 = *(buffer_ptr++) & 0X7F;	/* get the character	*/
	position = get_argument(buffer_ptr);	/* get X escapement	*/
	rvo.px	 = present.x		;
	present.x = position + H_MARGIN	;	/* set X text position	*/
	if (present.reverse) {			/* check if RVO ON	*/
		rev_char()		;
		rvo.ch	 = dchar	;
		rvo.psiz = present.psiz	;
		rvo.ssiz = present.ssiz	;
		rvo.font = present.font	;
	}
	else	disp_char(dchar,present.x,present.y);
	rvo.py	= present.y		;
	return(3);
}

/****************************************************************
*	Function Name :		rev_char()			*
*	Desc :	This routine displays a reverse video char	*
*	Calling convention :	rev_char()			*
****************************************************************/
rev_char()
{
	int	x, y, w, h;

	if (rvo.px > present.x) {
		x = present.x			;
		w = rvo.px - present.x		;
	}
	else {
		x = rvo.px			;
		w = present.x - rvo.px		;
	}
	y = rvo.py - present.rev_top		;/* cal bar position	*/
	if (y < 0) y = 0			;
	h = rvo.py + present.rev_bot - y	;
	if (w > 0) {
		bar(x,y,w,h)			;/* display black bar	*/
		if (rvo.ch) {
		  setptsz(rvo.psiz)		;
		  setssize(rvo.ssiz) 		;
		  setafont(rvo.font)		;
		  disp_char(rvo.ch,rvo.px,rvo.py);
		  setptsz(present.psiz)		;
		  setssize(present.ssiz)	;
		  setafont(present.font)	;
		}
	}
}

/************************************************************************
*	Function Name :		get_argument()				*
*	Desc :	This function gets the command argument and converts	*
*	it to unsigned value.						*
*	Calling convention :	get_argument(value_ptr)			*
*		unsigned char *value_ptr : pointer to command argument	*
*	Return value :		unsigned value				*
************************************************************************/
unsigned get_argument(value)
unsigned char *value	;
{
	union {
		unsigned char	byt[2]	;
		unsigned	val	;
	} w;

	w.byt[0] = *value++,
	w.byt[1] = *value		;/* combine two together	 */
	return(w.val)			;/* return the value		 */
}

/****************************************************************
*	Function Name :		exe_command()			*
*	Desc :	This routine execute the slave command		*
*	Calling convention : len = exe_command(cmd_ptr)		*
*		unsigned char	*cmd_ptr : pointer to command	*
*	Return value	:	int command length		*
****************************************************************/
exe_command(buffer_ptr)
unsigned char 	*buffer_ptr	;
{
	unsigned char	command	;
	unsigned	argument;
	int	cmd_len = 3	;

command  = *(buffer_ptr++) & 0X7F		;/* get command number 	*/
argument = get_argument(buffer_ptr)		;/* get	command arg	*/
argument &= 0X7FFF				;/* mask the high bit	*/
switch(command) {
case( 3)	:				 /* REVERSE TYPE	*/
	if (present.reverse)
		rev_char()			;
	else	rvo.py	= present.y		;
	present.reverse = argument		;/* set reverse type	*/
	if (!argument) rvo.ch = 0		;
	break					;
case( 7)	:				 /* POINT SIZE CMD	*/
	setptsz(present.psiz = argument)	;/* set char height	*/
case( 8)	:				 /* SET SIZE CMD	*/
	setssize(present.ssiz = argument) 	;/* set char width	*/
	break					;
case( 9)	:				 /* VERTICAL MOVE DOWN	*/
	present.y += argument			;/* adjust position	*/
	break					;
case(10)	:				 /* VERTICAL MOVE UP	*/
	present.y -= argument			;/* adjust position	*/
	break					;
case(11)	:				 /* HORIZONTAL POSITION */
	if (present.reverse)
		rvo.px = present.x		;
	present.x = argument + H_MARGIN		;/* adjust position	*/
	break					;
case(15)	:				 /* SLANT MODE		*/
	break					;
case(16)	:				 /* REVERSE TOP		*/
	present.rev_top = argument		;/* set rev_top value	*/
	break					;
case(17)	:				 /* REVERSE BOTTOM	*/
	present.rev_bot = argument		;/* set rev_bot value	*/
	break					;
case(22)	:				 /* SET FONT		*/
	setafont(present.font = argument)	;
	cmd_len = 9				;
	break					;
case(27)	:				 /* MOVE HOR RIGHT	*/
	present.x += argument			;/* adjust position	*/
	break					;
case(28)	:				 /* MOVE HOR. LEFT	*/
	present.x -= argument			;/* adjust position	*/
	break					;
case(SLVEOD)	:				 /* END OF SLAVE DATA	*/
case(SLVEOB)	:				 /* END OF SLAVE BLOCK	*/
	cmd_len = -1				;/* stop scanning code	*/
	break					;
case(31)	:				 /* VERTICAL POSITION	*/
	present.y = argument + V_MARGIN		;/* adjust position	*/
	break					;
}
return(cmd_len)					;/* return cmmnd length	*/
}

/*
	Function to initialize IFont System
*/
initftsys(mod)
int	mod;
{
	if (!fm_init(mod)			/* set up Intellifont	*/
	 || !fm_outdevice(0,xdpi[sdevm],ydpi[sdevm])	/* both screen	*/
	 || !fm_outdevice(1,xdpi[PRNT],ydpi[PRNT]))	/* and printer	*/
		return(1);
	else {	newdev(0);
		return(0);
	}
}

/*
	Function to set IFont system to new device
*/
newdev(dev)
int	dev;
{
	userpacket.p_cd.point_size	= 96;
	userpacket.p_cd.set_size	= 96;
	userpacket.p_cd.rotate_angle	= 0;
	userpacket.p_cd.bold		= 0;
	userpacket.p_cd.devnum		= dev;
	userpacket.p_cd.font_id		= 1;
}

/*
	Function to set IFont user packet to new point size
*/
setptsz(val)
int	val;
{
	ssize(&userpacket.p_cd.point_size,val);
}

/*
	Function to set IFont user packet to new set size
*/
setssize(val)
int	val;
{
	ssize(&userpacket.p_cd.set_size,val);
}

ssize(size,val)
unsigned *size, val;
{
	*size = zvalue(val);
}

/*
	Function to set IFont user packet to new font number
*/
setafont(val)
int	val;
{
	userpacket.p_cd.font_id	= val;
}

/*
	Function to setup Greeking bitmap structure.
*/
setupGreek()
{
	Greek.width	= 1;
	Greek.depth	= sdevm == SMDR ? 2:4;
	Greek.left_indent = 0;
	Greek.base_pix	= Greek.depth;
	Greek.new_lsb	= 0;
	Greek.bm[0]	= 0x5000;	/* Greeking character Bit Map	*/
	Greek.bm[1]	= 0xA000;	/* Medium Res. only use 2 words	*/
	Greek.bm[2]	= 0x5000;
	Greek.bm[3]	= 0xA000;
}

/*
	IFont character display
*/
disp_char(dchar,dx,dy)
unsigned char	dchar;
unsigned	dx, dy;
{
	struct bit_map_type	*bmp_ptr;

	if (!dchar || dchar > 118)
		return;
	if (userpacket.p_cd.point_size	< 40 &&
	    userpacket.p_cd.set_size	< 40)	/* Greeking < 5 points	*/
		bmp_ptr = &Greek;
	else {
		userpacket.flash_pos = dchar - 1;
		bmp_ptr = fm_char(&userpacket);
	}
	if (bmp_ptr) blt_char(bmp_ptr, dx, dy);
}

/********************************/
/*	grect_to_array		*/
/********************************/
grect_to_array(area, array)	/* convert x,y,w,h to upr lt x,y and	*/
GRECT	 *area;			/*		      lwr rt x,y	*/
unsigned *array;
{
	*array++= area->g_x;
	*array++= area->g_y;
	*array++= area->g_x + area->g_w - 1;
	*array	= area->g_y + area->g_h - 1;
}

/********************************/
/*	raster_operation	*/
/********************************/
rast_op(mode, s_area, s_MFDB, d_area, d_MFDB)	/* bit block level Xfer	*/
unsigned mode;
GRECT	*s_area, *d_area;
FDB	*s_MFDB, *d_MFDB;
{
	unsigned pxy[8];

	grect_to_array(s_area, pxy);
	grect_to_array(d_area, &pxy[4]);
	vro_cpyfm(shandle,mode,pxy,s_MFDB,d_MFDB);
}

/********************************/
/*	IFont char Blit		*/
/********************************/
blt_char(bptr,x,y)
struct bit_map_type	*bptr;
unsigned		x, y;
{
	GRECT	s, d;
	int	ref, IFcw, IFch;

	ref	= world_convert(x);
	d.g_x	= ref + (bptr->new_lsb >> 4) - bptr->left_indent;
	IFcw	= bptr->width << 4;
	if (d.g_x < clip_X0) {
		s.g_x = clip_X0 - d.g_x;
		d.g_x = clip_X0;
	}
	else	s.g_x = 0;
	ref	= IFcw - s.g_x;
	if (ref <= 0)	return;
	if ((d.g_w = clip_X1 - d.g_x) >= ref)
		d.g_w = s.g_w = ref;
	else
	if (d.g_w <= 0) return;
	else	s.g_w = d.g_w;
        if(y == lastmuy)		/* If we're on the same line we.. */
            ref = lastpixy;		/* don't have to recalculate y .. */
        else				/* pixel position		  */
	{
            lastmuy = y;
	    ref = lastpixy = world_rc_y(y);
	}
	d.g_y	= ref - bptr->base_pix;
	IFch	= bptr->depth;
	if (d.g_y < clip_Y0) {
		s.g_y = clip_Y0 - d.g_y;
		d.g_y = clip_Y0;
	}
	else	s.g_y = 0;
	ref	= IFch - s.g_y;
	if (ref <= 0)	return;
	if ((d.g_h = clip_Y1 - d.g_y) >= ref)
		d.g_h = s.g_h = ref;
	else
	if (d.g_h <= 0) return;
	else	s.g_h = d.g_h;

	char_MFDB.fd_addr	= (ULG)bptr->bm;
	char_MFDB.fd_w		= IFcw;
	char_MFDB.fd_h		= IFch;
	char_MFDB.fd_wdwidth	= bptr->width;
	rast_op((present.reverse) ? 4:7,&s,&char_MFDB,&d,orect_MFDB);
}

/****************************************/
/*	Draw Bar using world values	*/
/****************************************/
bar(x,y,w,h)
unsigned x,y,w,h;
{
	GRECT	rul;
	int	ref;

	rul.g_x = world_rc_x(x);
	w	= world_rc_x(w) + 1;
	if (rul.g_x < clip_X0) {
		ref = clip_X0 - rul.g_x;
		rul.g_x = clip_X0;
	}
	else	ref = 0;
	w	-= ref;
	if (w <= 0)	return;
	if ((rul.g_w = clip_X1 - rul.g_x) > w)
		rul.g_w = w;
	else
	if (rul.g_w <= 0) return;

	rul.g_y = world_rc_y(y);
	h	= world_rc_y(h) + 1;
	if (rul.g_y < clip_Y0) {
		ref = clip_Y0 - rul.g_y;
		rul.g_y = clip_Y0;
	}
	else	ref = 0;
	h	-= ref;
	if (h <= 0)	return;
	if ((rul.g_h = clip_Y1 - rul.g_y) > h)
		rul.g_h = h;
	else
	if (rul.g_h <= 0) return;

	rast_op(15,&rul,orect_MFDB,&rul,orect_MFDB);
}

/****************************************/
/*	X world value to X R.C value	*/
/****************************************/

world_convert(x)
unsigned x;
{
   switch(zrat)
   {
	case 100:
	   if(sdevm == 3)
		return(world_rc_x(x));
	   else
		return(mu_array[x]);
	   break;
	case 50:
	   x /= 2;
	   return(mu_array[x]);
	   break;
	case 75:
	   x *= 3;
	   x /= 4;
	   return(mu_array[x]);
	   break;
	default:
	   return(world_rc_x(x));
	   break;
   }
}

world_rc_x(x)
unsigned x;
{
	ULG	temp;
	x = zvalue(x);
	temp = (ULG)xdpi[sdevm] * (ULG)x;
	x = ((temp % 1296L) > 648L);
	temp /= 1296L;
	return((unsigned)temp + x);
}

/****************************************/
/*	Y world value to Y R.C value	*/
/****************************************/
world_rc_y(y)
unsigned y;
{
	ULG	temp;
	y = zvalue(y);
	temp = (ULG)ydpi[sdevm] * (ULG)y;
	y = ((temp % 1152L) > 576L);
	temp /= 1152L;
	return((unsigned)temp + y);
}

/****************************************
*	Zoom value convert function	*
****************************************/
zvalue(n)
unsigned n;
{
	ULG	temp;
	if (zrat == 100) return(n);
	temp = (ULG)zrat * (ULG)n;
	n = ((temp % 100L) > 50L);
	temp /= 100L;
	return((unsigned)temp + n);
}

resetIFpos()
{
        lastmuy = lastpixy = 0;
	last_y		= 0L;
	present.x	= H_MARGIN,
	present.y	= V_MARGIN;	/* reset the text positions	*/
	present.reverse = 0,
	present.rev_top = 0,
	present.rev_bot = 0;		/* init reverse type OFF	*/
	rvo.ch		= 0;
	rvo.py		= present.y;
}


setYpos(ypos)
unsigned ypos;
{
	present.y = ypos;
	rvo.py	  = present.y;
}

