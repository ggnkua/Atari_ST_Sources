/*
;*************************************
;*===================================*
;* RESERVOIR GODS C LIBRARY ROUTINES *
;*===================================*
;*         |              |          *
;*         |SCREEN LIBRARY|          *
;*         |              |          *
;*************************************
;* CODE: MR. PINK | (C): 28/08/96    *
;*************************************
;* UPDATE: 19/2/96  *
;********************
*/

/*
#include "d:\gods\library\rg_c.lib\base.h"
*/

typedef struct
{

U32 videl_screen_address;
U16 videl_horizontal_scroll;
U16 videl_hht;
U16 videl_hbb;
U16 videl_hbe;
U16 videl_hdb;
U16 videl_hde;
U16 videl_hss;
U16 videl_hfs;
U16 videl_hee;
U16 videl_vft;
U16 videl_vbb;
U16 videl_vbe;
U16 videl_vdb;
U16 videl_vde;
U16 videl_vss;
U16 videl_vsm;
U16 videl_vcl;	
U16 videl_spshift;
U8 videl_st_flag;
U8 videl_st_res;
U16 videl_vco;
U16 videl_line_width;
U16 videl_line_off;
 
} VIDEL_STRUCT;

VIDEL_STRUCT videl_current;


U16 videl_changed_flag=0;

int rlsc_open_video();
int rlsc_close_video();
int rlsc_open_screen(U16, U16, U8);
void rlsc_get_palette(U8, void *);
void rlsc_set_palette(U8, void *);

void rlsc_get_palette_st(U16 *);
void rlsc_get_palette_falcon(U32 *);
void rlsc_set_palette_st(U16 *);
void rlsc_set_palette_falcon(U32 *);
void rlsc_set_st_flag(VIDEL_STRUCT *);
void rlsc_set_screen_mode(U16, U16, U8);

void rlsc_copy_horizontal_videl(VIDEL_STRUCT *, VIDEL_STRUCT *);
void rlsc_copy_vertical_videl(VIDEL_STRUCT *, VIDEL_STRUCT *);

void display_videl_registers(VIDEL_STRUCT *);

U16 saved_st_palette[16];
U32 saved_falcon_palette[256];

extern void rlsc_save_videl(void *);
extern void rlsc_restore_videl(void *);
extern void rlsc_set_videl(VIDEL_STRUCT *);
extern U16 rlsc_return_monitor_type();
extern void rlsc_set_new_physic(U32);
extern void rlsc_return_videl_block_ptr(VIDEL_STRUCT *);
extern void rlsc_set_screen_address(U32);

VIDEL_STRUCT saved_videl_space;
VIDEL_STRUCT videl_screen_modes[20];



int rlsc_open_video()
{
	rlsc_get_palette(0,&saved_st_palette);
	rlsc_get_palette(1,&saved_falcon_palette);
	rlsc_save_videl(&saved_videl_space);
	rlsc_set_st_flag(&saved_videl_space);

/*	if (rlsc_return_monitor_type()==2) load_file("a:\\videl.vga",&videl_screen_modes);
	else load_file("h:\\c\\videl.rgb",&videl_screen_modes);
*/
	rlsc_return_videl_block_ptr(&videl_screen_modes[0]);
	
	return(0);
}


void rlsc_set_st_flag(VIDEL_STRUCT * v)
{
	int y;

	if ((v->videl_spshift & 1296)==0)
	{
		if ((v->videl_st_res)==1) v->videl_st_flag=1;
		else if (v->videl_st_res==0)
		{
			y=(v->videl_vde-v->videl_vdb);
			if ((rlsc_return_monitor_type())==2)
			{
				if ((v->videl_vco & 1)==1) y=y>>1;
			}
			else
			{
				y=y>>1;
				if ((v->videl_vco & 1)==1) y+=y;
				if ((v->videl_vco & 2)==2) y=y<<1;
			}
			if (((v->videl_line_width)<<2)==320)
			{
				if (y==200) v->videl_st_flag=1;
			}						
		}	
	}
}


int rlsc_close_video()
{
	rlsc_restore_videl(&saved_videl_space);
	rlsc_set_palette(0,&saved_st_palette);
	rlsc_set_palette(1,&saved_falcon_palette);
	return(0);
}


void rlsc_get_palette(U8 mode, void * palette_ptr)
{
	switch(mode)
	{
	case 0: rlsc_get_palette_st(palette_ptr); break;
	case 1: rlsc_get_palette_falcon(palette_ptr); break;
	default: break;
	}	
}

void rlsc_set_palette(U8 mode, void * palette_ptr)
{
	switch(mode)
	{
	case 0: rlsc_set_palette_st(palette_ptr); break;
	case 1: rlsc_set_palette_falcon(palette_ptr); break;
	default: break;
	}	
}

void rlsc_get_palette_st(U16 * dest_pal)
{
	U16 * st_pal = (U16 *) 0xFFFF8240;
	int i=0;
	for (i=0; i<16; i++) 
	{
	dest_pal[i]=*st_pal++;
	}
}

void rlsc_get_palette_falcon(U32 * dest_pal)
{
	U32 * falc_pal = (U32 *) 0xFFFF9800;
	int i=0;
	for (i=0; i<256; i++) 
	{
	dest_pal[i]=*falc_pal++;
	}
}

void rlsc_set_palette_st(U16 * source_pal)
{
	U16 * st_pal = (U16 *) 0xFFFF8240;
	int i=0;
	for (i=0; i<16; i++) 
	{
	(*st_pal++)=source_pal[i];
	}
}

void rlsc_set_palette_falcon(U32 * source_pal)
{
	U32 * falc_pal = (U32 *) 0xFFFF9800;
	int i=0;
	for (i=0; i<256; i++) 
	{
	(*falc_pal++)=source_pal[i];
	}
}

void rlsc_set_screen_mode(U16 x, U16 y, U8 mode)
{
	U16 index;

	index=(mode<<2);

	if(x>320)
	{
		if(x<385) index+=1;
		else if(x<641) index+=2;
		else index+=3;
	}

	rlsc_copy_horizontal_videl(&videl_screen_modes[index],&videl_current); 


	index=(mode<<2);

	if (!((y==200) | (y==100)))
	{
		if ((y==240) | (y<241)) index+=1;
		else if (y==400) index+=2;
		else index+=3;
	}

	rlsc_copy_vertical_videl(&videl_screen_modes[index],&videl_current); 	

	if (rlsc_return_monitor_type()==2)
	{
		videl_current.videl_vco=(videl_current.videl_vco & 0xFFFC);
		if (y<241)
		{
		videl_current.videl_vco=(videl_current.videl_vco | 1);		
		videl_current.videl_vde=(videl_current.videl_vdb+(y<<2));
		}
		else 
		{
		videl_current.videl_vde=(videl_current.videl_vdb+(y<<1));
		}
	}
	else 
	{
		videl_current.videl_vco=(videl_current.videl_vco & 0xFFFC);
		if (y<129)
		{
		videl_current.videl_vco=(videl_current.videl_vco | 1);		
		videl_current.videl_vde=(videl_current.videl_vdb+(y<<2));
		}
		else if (y<257)
		{
		videl_current.videl_vde=(videl_current.videl_vdb+(y<<1));
		}
		else
		{
		videl_current.videl_vco=(videl_current.videl_vco | 2);		
		videl_current.videl_vde=(videl_current.videl_vdb+y);
		}

	}
	rlsc_set_videl(&videl_current);
	videl_changed_flag=1;
}


void rlsc_copy_horizontal_videl(VIDEL_STRUCT * source, VIDEL_STRUCT * dest)
{
	dest->videl_hht=source->videl_hht;
	dest->videl_hbb=source->videl_hbb;
	dest->videl_hbe=source->videl_hbe;
	dest->videl_hdb=source->videl_hdb;
	dest->videl_hde=source->videl_hde;
	dest->videl_hss=source->videl_hss;
	dest->videl_hfs=source->videl_hfs;
	dest->videl_hee=source->videl_hee;

	dest->videl_vsm=source->videl_vsm;
	dest->videl_spshift=source->videl_spshift;

	dest->videl_st_res=source->videl_st_res;
	dest->videl_st_flag=source->videl_st_flag;

	dest->videl_vco=(source->videl_vco & 0xFFFC);

	dest->videl_line_width=source->videl_line_width;
	dest->videl_line_off=source->videl_line_off;
}

void rlsc_copy_vertical_videl(VIDEL_STRUCT * source, VIDEL_STRUCT * dest)
{
	dest->videl_vft=source->videl_vft;
	dest->videl_vbb=source->videl_vbb;
	dest->videl_vbe=source->videl_vbe;
	dest->videl_vdb=source->videl_vdb;
	dest->videl_vde=source->videl_vde;
	dest->videl_vss=source->videl_vss;
	dest->videl_vcl=source->videl_vcl;

	dest->videl_vco=(dest->videl_vco | (source->videl_vco  & 3));
}

void display_videl_registers(VIDEL_STRUCT * v)
{
	printf("hht:%d \n",v->videl_hht);
	printf("hbb:%d \n",v->videl_hbb);
	printf("hbe:%d \n",v->videl_hbe);
	printf("hdb:%d \n",v->videl_hdb);
	printf("hde:%d \n",v->videl_hde);
	printf("hss:%d \n",v->videl_hss);
	printf("hfs:%d \n",v->videl_hfs);
	printf("hee:%d \n",v->videl_hee);
	printf("vft:%d \n",v->videl_vft);
	printf("vbb:%d \n",v->videl_vbb);
	printf("vbe:%d \n",v->videl_vbe);
	printf("vdb:%d \n",v->videl_vdb);
	printf("vde:%d \n",v->videl_vde);
	printf("vss:%d \n",v->videl_vss);
	printf("vsm:%d \n",v->videl_vsm);
	printf("vcl:%d \n",v->videl_vcl);
	printf("spshift:%d \n",v->videl_spshift);
	printf("vco:%d \n",v->videl_vco);
	printf("line width:%d \n",v->videl_line_width);
	printf("line off:%d \n",v->videl_line_off);
	printf("st flag:%d \n",v->videl_st_flag);
	printf("st res:%d \n",v->videl_st_res);
}