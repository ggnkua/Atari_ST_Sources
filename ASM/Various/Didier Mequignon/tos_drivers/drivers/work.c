#include "config.h"
#include "fvdi/include/fvdi.h"
#include <mint/osbind.h>
#include <mint/falcon.h>
#include <string.h>

#define TRUE 1
#define FALSE 0

#define	DEFAULTDEV 0
#define	STAYINDEV 1
#define SETMODEFLAG 5

#define MAP_COL ((short *)0xE4D5D0)
#define REV_MAP_COL ((short *)0xE4D7D0)
#define ROM_DEV_TAB ((void *)0xE4D462)
#define ROM_INQ_TAB ((void *)0xE4D4D4)
#define ROM_SIZ_TAB ((void *)0xE4D4BC)
#define f6x6 ((FONT_HEAD *)0xE4AFEC)
#define f8x8 ((FONT_HEAD *)0xE4B6C8)
#define f8x16 ((FONT_HEAD *)0xE4D124)
#define f16x32 ((FONT_HEAD *)0xE09410)

#define MX_LN_STYLE 7
#define MX_LN_WIDTH 40
#define MAX_MARK_INDEX 6
#define MAX_FONT 1
#define MX_FIL_STYLE 4
#define MX_FIL_HAT_INDEX 12
#define	MX_FIL_PAT_INDEX 24
#define MAX_MODE 3
#define MIN_ARC_CT 32	/* minimum # of points on circle  */
#define MAX_ARC_CT 128	/* maximum # of points on circle  */

#define	DEF_LWID SIZ_TAB15[4]
#define	DEF_CHHT SIZ_TAB15[1]
#define	DEF_CHWT SIZ_TAB15[0]
#define DEF_MKWD SIZ_TAB15[8]
#define DEF_MKHT SIZ_TAB15[9]
#define MAX_MKWD SIZ_TAB15[10]
#define MAX_MKHT SIZ_TAB15[11]

#define scrtsiz 666 /* for accomodate the 16x32 system font */

/* fh_flags   */
#define	DEFAULT 1	/* this is the default font (face and size) */
#define	HORZ_OFF  2	/* there are left and right offset tables */
#define STDFORM  4	/* is the font in standard format */
#define MONOSPACE 8	/* is the font monospaced */

/* style bits */
#define	THICKEN	1
#define	LIGHT	2
#define	SKEW	4
#define	UNDER	8
#define	OUTLINE 16
#define	SHADOW	32

typedef struct font_head
{
	short font_id;
	short point;
	char name[32];
	unsigned short first_ade;
	unsigned short last_ade;
	unsigned short top;
	unsigned short ascent;
	unsigned short half;
	unsigned short descent;		
	unsigned short bottom;
	unsigned short max_char_width;
	unsigned short max_cell_width;
	unsigned short left_offset; /* amount character slants left when skewed */
	unsigned short right_offset; /* amount character slants right */
	unsigned short thicken; /* number of pixels to smear */
	unsigned short ul_size; /* size of the underline */
	unsigned short lighten;	/* mask to and with to lighten  */
	unsigned short skew; /* mask for skewing */
	unsigned short flags;		    
	unsigned char *hor_table; /* horizontal offsets */
	unsigned short *off_table; /* character offsets  */
	unsigned short *dat_table; /* character definitions */
	unsigned short form_width;
	unsigned short form_height;
	struct font_head *next_font; /* pointer to next font */
	unsigned short font_seg;
} FONT_HEAD __attribute__ ((__packed__));

typedef struct attribute
{
	short chup;	/* Character Up vector */
	short clip;	/* Clipping Flag */
	FONT_HEAD *cur_font; /* Pointer to current font */
	short dda_inc; /* Fraction to be added to the DDA */
	short multifill; /* Multi-plane fill flag */
	short patmsk; /* Current pattern mask */
	short *patptr; /* Current pattern pointer */
	short pts_mode; /* TRUE if height set in points mode */
	short *scrtchp;	/* Pointer to text scratch buffer */
	short scrpt2; /* Offset to large text buffer */
	short style; /* Current text style */
	short t_sclsts; /* TRUE if scaling up */
	short fill_color;	/* Current fill color (PEL value) */
	short fill_index;	/* Current fill index */
 	short fill_per;	/* TRUE if fill area outlined */
	short fill_style;	/* Current fill style */
	short h_align; /* Current text horizontal alignment */
	short handle;	/* handle for attribute area */
	short line_beg;	/* Beginning line endstyle */
	short line_color;	/* Current line color (PEL value) */
	short line_end;	/* Ending line endstyle */
	short line_index;	/* Current line style */
	short line_width;	/* Current line width */
	FONT_HEAD *loaded_fonts;	/* Pointer to first loaded font */
	short mark_color; /* Current marker color (PEL value)	*/
	short mark_height; /* Current marker height */
	short mark_index;	/* Current marker style */
	short mark_scale;	/* Current scale factor for marker data */
	struct attribute *next_work; /* Pointer to next virtual workstation */
	short num_fonts; /* Total number of faces available */
	short scaled;	/* TRUE if font scaled in any way	*/
	FONT_HEAD scratch_head;	/* Holder for the doubled font data */
	short text_color; /* Current text color (PEL value) */
	short ud_ls; /* User defined linestyle */
	short ud_patrn[32*16]; /* User defined pattern */
	short v_align; /* Current text vertical alignment */
	short wrt_mode; /* Current writing mode */
	short xfm_mode;	/* Transformation mode requested */
	short xmn_clip;	/* Low x point of clipping rectangle */
	short xmx_clip;	/* High x point of clipping rectangle */
	short ymn_clip;	/* Low y point of clipping rectangle */
	short ymx_clip;	/* High y point of clipping rectangle */
	Virtual *fvdi_virtual;
} ATTRIBUTE __attribute__ ((__packed__));

/* var VDI */
#define CUR_FONT ((FONT_HEAD *)(*(long *)&adr_var_vdi[-906]))
#if (__GNUC__ > 3)
#define P_CUR_FONT ((FONT_HEAD **)&adr_var_vdi[-906])
#endif
#define M_POS_HX (*(short *)&adr_var_vdi[-856])
#define M_POS_HY (*(short *)&adr_var_vdi[-854])
#define M_PLANES (*(short *)&adr_var_vdi[-852])
#define M_CDB_BG (*(short *)&adr_var_vdi[-850])
#define M_CDB_FG (*(short *)&adr_var_vdi[-848])
#define MASKFORM ((short *)&adr_var_vdi[-846])
#define INQ_TAB ((short *)&adr_var_vdi[-782])
#define DEV_TAB ((short *)&adr_var_vdi[-692])
#define G_CURX (*(short *)&adr_var_vdi[-602])
#define G_CURY (*(short *)&adr_var_vdi[-600])
#define M_HID_CT (*(short *)&adr_var_vdi[-598])
#define MOUSE_BT (*(short *)&adr_var_vdi[-596])
#define REQ_COL48 ((short *)&adr_var_vdi[-594]) /* 16 colors RVB */
#define SIZ_TAB15 ((short *)&adr_var_vdi[-498])
#define TERM_CH (*(short *)&adr_var_vdi[-468])
#define CHC_MODE (*(short *)&adr_var_vdi[-466])
#define CUR_WORK ((ATTRIBUTE *)(*(long *)&adr_var_vdi[-464]))
#if (__GNUC__ > 3)
#define P_CUR_WORK ((ATTRIBUTE **)&adr_var_vdi[-464])
#endif
#define DEF_FONT ((FONT_HEAD *)(*(long *)&adr_var_vdi[-460]))
#if (__GNUC__ > 3)
#define P_DEF_FONT ((FONT_HEAD **)&adr_var_vdi[-460])
#endif
#define FONT_RING ((FONT_HEAD **)&adr_var_vdi[-456]) /* 4 pointers to sysfonts, last NULL */
#define FONT_COUNT (*(short *)&adr_var_vdi[-440])
#define LINE_CW  (*(short *)&adr_var_vdi[-438])
#define LOC_MODE (*(short *)&adr_var_vdi[-436])
#define STR_MODE (*(short *)&adr_var_vdi[-352])
#define VAL_MODE (*(short *)&adr_var_vdi[-350])
#define CUR_MS_STAT (*(char *)&adr_var_vdi[-348])
#define V_HID_CNT (*(short *)&adr_var_vdi[-346])
#define CUR_X (*(short *)&adr_var_vdi[-344])
#define CUR_Y (*(short *)&adr_var_vdi[-342])
#define CUR_FLAG (*(short *)&adr_var_vdi[-340])
#define MOUSE_FLAG (*char *)&adr_var_vdi[339])
#define V_SAV_X (*(short *)&adr_var_vdi[-334])
#define V_SAV_Y (*(short *)&adr_var_vdi[-332])
#define SAVE_LEN (*(short *)&adr_var_vdi[-330])
#define SAVE_ADR ((void *)(*(long *)&adr_var_vdi[-328]))
#define SAVE_STAT (*(short *)&adr_var_vdi[-324])
#define SAVE_AREA ((short *)&adr_var_vdi[-322])
#define USER_TIM (*(long *)&adr_var_vdi[-66])
#define NEXT_TIM (*(long *)&adr_var_vdi[-62])
#define USER_BUT (*(long *)&adr_var_vdi[-58])
#define USER_CUR (*(long *)&adr_var_vdi[-54])
#define USER_MOT (*(long *)&adr_var_vdi[-50])
#define V_CEL_HT (*(short *)&adr_var_vdi[-46])
#define V_CEL_MX (*(short *)&adr_var_vdi[-44])
#define V_CEL_MY (*(short *)&adr_var_vdi[-42])
#define V_CEL_WR (*(short *)&adr_var_vdi[-40])
#define V_COL_BG (*(short *)&adr_var_vdi[-38])
#define V_COL_FG (*(short *)&adr_var_vdi[-36])
#define V_CUR_AD ((void *)(*(long *)&adr_var_vdi[-34]))
#define V_CUR_OFF (*(short *)&adr_var_vdi[-30])
#define V_CUR_X (*(short *)&adr_var_vdi[-28])
#define V_CUR_Y (*(short *)&adr_var_vdi[-26])
#define V_PERIOD (*(char *)&adr_var_vdi[-24])
#define V_CUR_CT (*(char *)&adr_var_vdi[-23])
#define V_FNT_AD ((void *)(*(long *)&adr_var_vdi[-22]))
#define V_FNT_ND (*(short *)&adr_var_vdi[-18])
#define V_FNT_ST (*(short *)&adr_var_vdi[-16])
#define V_FNT_WD (*(short *)&adr_var_vdi[-14])
#define V_REZ_HZ (*(short *)&adr_var_vdi[-12])
#define V_OFF_AD ((void *)(*(long *)&adr_var_vdi[-10]))
#define V_STAT_0 (*(char *)&adr_var_vdi[-6])
#define V_DELAY (*(char *)&adr_var_vdi[-5])
#define V_REZ_VT (*(short *)&adr_var_vdi[-4])
#define BYTES_LN (*(short *)&adr_var_vdi[-2])
#define V_PLANES (*(short *)&adr_var_vdi[0])
#define V_LIN_WR (*(short *)&adr_var_vdi[2])
#define _WRT_MODE (*(short *)&adr_var_vdi[36])
#define _X1 (*(short *)&adr_var_vdi[38])
#define _Y1 (*(short *)&adr_var_vdi[40])
#define _X2 (*(short *)&adr_var_vdi[42])
#define _Y2 (*(short *)&adr_var_vdi[44])
#define _PATPTR ((void *)(*(long *)&adr_var_vdi[46]))
#define _PATMSK (*(short *)&adr_var_vdi[50])
#define _MULTIFILL (*(short *)&adr_var_vdi[52])
#define _CLIP (*(short *)&adr_var_vdi[54])
#define _XMN_CLIP (*(short *)&adr_var_vdi[56])
#define _YMN_CLIP (*(short *)&adr_var_vdi[58])
#define _XMX_CLIP (*(short *)&adr_var_vdi[60])
#define _YMX_CLIP (*(short *)&adr_var_vdi[62])
#define _DDA_INC (*(short *)&adr_var_vdi[66])
#define _T_SCLSTS (*(short *)&adr_var_vdi[68
#define _MONO_STATUS (*(short *)&adr_var_vdi[70
#define _SOURCE_X (*(short *)&adr_var_vdi[72])
#define _SOURCE_Y (*(short *)&adr_var_vdi[74])
#define _DESTX (*(short *)&adr_var_vdi[76]]
#define _DESTY (*(short *)&adr_var_vdi[78])
#define _DELX (*(short *)&adr_var_vdi[80])
#define _DELY (*(short *)&adr_var_vdi[82])
#define _FBASE ((short *)(*(long *)&adr_var_vdi[84]))
#define _FWIDTH (*(short *)&adr_var_vdi[88])
#define _STYLE (*(short *)&adr_var_vdi[90])
#define _SCALE (*(short *)&adr_var_vdi[102])
#define _CHUP (*(short *)&adr_var_vdi[104])
#define REQ_COL48E ((short *)&adr_var_vdi[174]) // 240 colors RVB TOS 4.XX FALCON
#define BYT_PER_PIX (*(short *)&adr_var_vdi[2822])
#define FORM_ID (*(short *)&adr_var_vdi[2824]]   // scrn form 2 ST, 1 stndrd, 3 pix
#define VL_COL_BG (*(long *)&adr_var_vdi[2826])
#define VL_COL_FG (*(long *)&adr_var_vdi[2830])
#define PAL_MAP ((long *)&adr_var_vdi[2834])

FONT_HEAD	first, ram8x16, ram8x8, ram16x32;
ATTRIBUTE virt_work;
Virtual virt_work_fvdi;
char deftxbu[276]; /* stratch buf */
extern short video_found, video_log;
extern char buf_log[];
extern short LINE_STYLE[];
short ROM_UD_PATRN[16] = { 0x0000,0x05A0,0x05A0,0x05A0,0x05A0,0x0DB0,0x0DB0,0x1DB8, 0x399C,0x799E,0x718E,0x718E,0x6186,0x4182,0x0000,0x0000 }; /* fuji */
extern void init_choice_fill(char *adr_var_vdi, ATTRIBUTE *work_ptr);
extern void TRNSFONT(void);
extern void tick_int(void);

void init_wk(char *adr_var_vdi, short *INTIN, short *INTOUT, short *PTSOUT)
{
	ATTRIBUTE *work_ptr = CUR_WORK;
	short val = INTIN[1];
	work_ptr->line_index = ((val > MX_LN_STYLE) || (val < 0)) ?  0 : val - 1;
	val = INTIN[2];
	if((val >= DEV_TAB[13]) || (val < 0))
		val = 1;
	work_ptr->line_color = MAP_COL[val];
	val = INTIN[3] - 1;
	work_ptr->mark_index = ((val >= MAX_MARK_INDEX) || (val < 0)) ? 2 : val;
	val = INTIN[4];
	if((val >= DEV_TAB[13]) || (val < 0))
		val = 1;
	work_ptr->mark_color = MAP_COL[val];
	val = INTIN[6];
	if((val >= DEV_TAB[13]) || (val < 0))
		val = 1;
	work_ptr->text_color = MAP_COL[ val ];
	work_ptr->mark_height = DEF_MKHT;
	work_ptr->mark_scale = 1;
	val = INTIN[7];
	work_ptr->fill_style = ((val > MX_FIL_STYLE) || (val < 0)) ?  0 : val;
	val = INTIN[8];
	if(work_ptr->fill_style == 2)
		val = ((val > MX_FIL_PAT_INDEX) || (val < 1)) ? 1 : val;
	else
		val = ((val > MX_FIL_HAT_INDEX) || (val < 1)) ? 1 : val;
	work_ptr->fill_index = val;
	val = INTIN[9];
	if((val >= DEV_TAB[13]) || (val < 0))
		val = 1;
	work_ptr->fill_color = MAP_COL[val];
	work_ptr->xfm_mode = INTIN[10];
	init_choice_fill(adr_var_vdi, work_ptr);
	work_ptr->wrt_mode = 0;	/* default is replace mode */
	work_ptr->line_width = DEF_LWID;
	work_ptr->line_beg = 0;	/* default to squared ends */
	work_ptr->line_end = 0;
	work_ptr->fill_per = TRUE;
	work_ptr->xmn_clip = 0;
	work_ptr->ymn_clip = 0;
	work_ptr->xmx_clip = DEV_TAB[0];
	work_ptr->ymx_clip = DEV_TAB[1];
	work_ptr->clip = 0;
	work_ptr->cur_font = DEF_FONT;
	work_ptr->loaded_fonts = NULL;
	work_ptr->scrpt2 = scrtsiz;
	work_ptr->scrtchp = (short *)deftxbu;
	work_ptr->num_fonts = FONT_COUNT;
	work_ptr->style = 0;	/* reset special effects */
	work_ptr->scaled = FALSE;
	work_ptr->h_align = 0;
	work_ptr->v_align = 0;
	work_ptr->chup = 0;
	work_ptr->pts_mode = FALSE;
	/* move default user defined pattern to RAM */
	memcpy(&work_ptr->ud_patrn[0], ROM_UD_PATRN, sizeof(short)*16);
	work_ptr->multifill = 0;
	work_ptr->ud_ls = LINE_STYLE[0];
	memcpy(INTOUT, DEV_TAB, sizeof(short)*45);
	memcpy(PTSOUT, SIZ_TAB15, sizeof(short)*12);
}

static void empty(void)
{
}

short V_OPNWK(char *adr_var_vdi, short *INTIN, short *INTOUT, short *PTSOUT)
{
	FONT_HEAD *fnt_ptr, **chain_ptr;
	short id_save, modecode = -1;
	int i, j;
	/* flush to disk debug */
	if(video_found && video_log && buf_log[0])
	{
		short log_handle = Fcreate("C:\\video.log", 0);
		if(log_handle >= 0)
		{
			Fwrite(log_handle, strlen(buf_log), buf_log);
			Fclose(log_handle);	
		}
		buf_log[0] = '\0';
	}
	switch(INTIN[0])
	{
		case DEFAULTDEV:
		case STAYINDEV:
			break;
		case SETMODEFLAG:
			modecode = Vsetmode(-1); /* get current video mode    */
			if(modecode != PTSOUT[0]) /* see if cur mode != desired  */
				(void)Vsetscreen(0, 0, 3, PTSOUT[0]); /* set the video to new mode */
			break;
		default:
			if(INTIN[0] < SETMODEFLAG)
				(void)Vsetscreen(-1, -1, INTIN[0] - 2, -1); /* ST modes */
			else
				return(0); /* erreur */
			break;
	}
	memcpy(DEV_TAB, ROM_DEV_TAB, sizeof(short)*45);  
	memcpy(INQ_TAB, ROM_INQ_TAB, sizeof(short)*45);
	memcpy(SIZ_TAB15, ROM_SIZ_TAB, sizeof(short)*12);
	memcpy(&first, f6x6, sizeof(FONT_HEAD));
	memcpy(&ram8x8, f8x8, sizeof(FONT_HEAD));
	memcpy(&ram8x16, f8x16, sizeof(FONT_HEAD));
	memcpy(&ram16x32, f16x32, sizeof(FONT_HEAD));
	/* init all the device dependant stuff */
	DEV_TAB[0] = V_REZ_HZ - 1; /* X max */
	DEV_TAB[1] = V_REZ_VT - 1; /* Y max */
 	DEV_TAB[3] = 278; /* width of pixel in microns  */
	DEV_TAB[4] = 278; /* height of pixel in microns */
	DEV_TAB[13] = (V_PLANES < 8) ? (1 << V_PLANES) : 256; /* # of pens available */
	DEV_TAB[35] = 1; /* color capability flag */
	DEV_TAB[39] = 0; /* palette size  */
	INQ_TAB[1] = 0; /* number of background clrs  */
	INQ_TAB[4] = V_PLANES; /* number of planes */
	INQ_TAB[5] = 0; /* video lookup table  */
	virt_work.handle = 1;
#if (__GNUC__ > 3)
	*P_CUR_WORK = &virt_work;
#else
	CUR_WORK = &virt_work;
#endif
	virt_work.fvdi_virtual = &virt_work_fvdi;
	virt_work.next_work = NULL;
	LINE_CW = -1;	/* invalidate curr line width */
	SIZ_TAB15[0] = 32767;
	SIZ_TAB15[1] = 32767;
	SIZ_TAB15[2] = 0;
	SIZ_TAB15[3] = 0;
	FONT_RING[0] = &first;
	FONT_RING[1] = &ram8x8; /* font which varies with the screen resolution */
	FONT_RING[2] = NULL;
	FONT_RING[3] = NULL;
	id_save = first.font_id;
	chain_ptr = FONT_RING;
	i = 0;
	j = 0;
	while((fnt_ptr = *chain_ptr++) != NULL)
	{
		do
		{
			if(fnt_ptr->flags & DEFAULT) /* If default save pointer */
#if (__GNUC__ > 3)
				*P_DEF_FONT = fnt_ptr;
#else
				DEF_FONT = fnt_ptr;
#endif
			if(fnt_ptr->font_id != id_save)	/* If new font count */
			{
				j++;
				id_save = fnt_ptr->font_id;
			}
			if(fnt_ptr->font_id == 1) /* Update SIZ_TAB if system font */
			{ 
				if(SIZ_TAB15[0] > fnt_ptr->max_char_width)
					SIZ_TAB15[0] = fnt_ptr->max_char_width;
				if(SIZ_TAB15[1] > fnt_ptr->top)
					SIZ_TAB15[1] = fnt_ptr->top;
				if(SIZ_TAB15[2] < fnt_ptr->max_char_width)
					SIZ_TAB15[2] = fnt_ptr->max_char_width; 
				if(SIZ_TAB15[3] < fnt_ptr->top)
					SIZ_TAB15[3] = fnt_ptr->top;
				i++; /* Increment count of heights */
	    } /* end if system font */
		}
		while((fnt_ptr = fnt_ptr->next_font) != NULL);
	}
	DEV_TAB[5] = i; /* number of sizes */
	FONT_COUNT = DEV_TAB[10] = ++j;	/* number of faces */
#if (__GNUC__ > 3)
	*P_CUR_FONT = DEF_FONT;
#else
	CUR_FONT = DEF_FONT;
#endif
	init_wk(adr_var_vdi, INTIN, INTOUT, PTSOUT);
	LOC_MODE = 0;
	VAL_MODE = 0;
	CHC_MODE = 0;
	STR_MODE = 0;
	{
#ifdef COLDFIRE
		asm volatile (
			" move.l D0,-(SP)\n\t"
			" move.w SR,D0\n\t"
			" move.w D0,save_d0\n\t"
			" or.l #0x700,D0\n\t"   /* disable interrupts */
			" move.w D0,SR\n\t"
			" move.l (SP)+,D0" );
#else
		asm volatile (
			" move.w SR,save_d0\n\t"
			" or.w #0x700,SR" );   /* disable interrupts */
#endif
		USER_TIM = (long)empty;
		NEXT_TIM = (long)Setexc(0x100, tick_int);
#ifdef COLDFIRE
		asm volatile (
			" move.w D0,-(SP)\n\t"
			" move.w save_d0,D0\n\t"
			" move.w D0,SR\n\t"
			" move.w (SP)+,D0" );
#else
		asm volatile (
			" move.w save_d0,SR" );
#endif
	}
	return(1);
}

void V_CLSWK(char *adr_var_vdi)
{
	ATTRIBUTE	*next_work;
	if(virt_work.next_work != NULL)
	{	/* Are there VWs to close */
#if (__GNUC__ > 3)
		*P_CUR_WORK = virt_work.next_work;
#else
		CUR_WORK = virt_work.next_work;
#endif
		do
		{
	    next_work = CUR_WORK->next_work;
	    Mfree(CUR_WORK);
		}
#if (__GNUC__ > 3)
		while((*P_CUR_WORK = next_work));
#else
		while((CUR_WORK = next_work));
#endif
	}
	(void)Setexc(0x100, NEXT_TIM);  /* reset timer vector  */
}

short V_OPNVWK(char *adr_var_vdi, short *INTIN, short *INTOUT, short *PTSOUT)
{
	short handle;
	ATTRIBUTE *new_work, *work_ptr;
	Virtual *new_work_fvdi;
	/* Allocate the memory for a virtual workstation.  If none available, exit */
	new_work = (ATTRIBUTE *)Mxalloc(sizeof(ATTRIBUTE), 3);
	if(new_work == NULL)
		return(0);
	memset(new_work, 0, sizeof(ATTRIBUTE));
	new_work_fvdi = (Virtual *)Mxalloc(sizeof(Virtual), 3);
	if(new_work_fvdi == NULL)
	{
		Mfree(new_work);
		return(0);
	}
	memset(new_work_fvdi, 0, sizeof(Virtual));
	/* Now find a free handle */
	handle = 2;
	work_ptr = &virt_work;
	while((work_ptr->next_work != NULL) && (handle == work_ptr->next_work->handle))
	{
		handle++;
		work_ptr = work_ptr->next_work;
	}
	/* slot found, Insert the workstation here */
#if (__GNUC__ > 3)
	*P_CUR_WORK = new_work;
#else
	CUR_WORK = new_work;
#endif
	new_work->next_work = work_ptr->next_work;
	new_work->fvdi_virtual = new_work_fvdi;
	work_ptr->next_work = new_work;
	new_work->handle = handle;
	init_wk(adr_var_vdi, INTIN, INTOUT, PTSOUT);
	return(handle);
}

void V_CLSVWK(char *adr_var_vdi)
{
	short handle;
	ATTRIBUTE *work_ptr;
	/* cur_work points to workstation to deallocate, find who points to me */
	handle = CUR_WORK->handle;
	if(handle == 1)		/* Can't close physical this way */
		return;
	for(work_ptr = &virt_work; handle != work_ptr->next_work->handle; work_ptr = work_ptr->next_work);
	work_ptr->next_work = CUR_WORK->next_work;
	if(CUR_WORK->fvdi_virtual != NULL)
		Mfree(CUR_WORK->fvdi_virtual);
	Mfree(CUR_WORK);
}

