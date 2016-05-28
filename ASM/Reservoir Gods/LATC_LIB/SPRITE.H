/*************************************************************************/
/* SPRITE LIBRARY                                              JULY 1997 */
/* CODED BY LEON O'REILLY                         (C)1997 RESERVOIR GODS */
/*************************************************************************/

/*
#include <dos.h>
#include "d:\gods\library\rg_c.lib\base.h"
*/

typedef struct
{
U16 fs_colours[26];
U16 * fs_sprite_lines[256];
} FAST_SPRITE_STRUCT;

typedef struct
{
U16 fs_num_sprites;
U16 fs_sprite_x;
U16 fs_sprite_y;
FAST_SPRITE_STRUCT * fs_sprite_ptrs[256];
} FAST_SPRITE_BLOCK_STRUCT;

void rlsp_sprites_relocate(FAST_SPRITE_BLOCK_STRUCT *);
void rlsp_draw_fast_sprite(S16, S16, U16, FAST_SPRITE_BLOCK_STRUCT *, U32);

extern void rlsp_display_fast_sprite(S16, S16, U32, U16, U16, FAST_SPRITE_BLOCK_STRUCT *);

void rlsp_sprites_relocate(FAST_SPRITE_BLOCK_STRUCT * fsb_ptr)
{
	U16 i;
	U16 j;
	U32 * sprite_ptr;
	U32 * sprite_line_ptr;

	for(i=0; i<(fsb_ptr->fs_num_sprites); i++)
	{
		sprite_ptr=(U32 *)&fsb_ptr->fs_sprite_ptrs[i];
		*sprite_ptr+=(U32)fsb_ptr;
		for(j=0; j<=(fsb_ptr->fs_sprite_y);j++)
		{
			sprite_line_ptr=(U32 *)&fsb_ptr->fs_sprite_ptrs[i]->fs_sprite_lines[j];
			*sprite_line_ptr+=(U32)fsb_ptr;
		}
	}
}

void rlsp_draw_fast_sprite(S16 fx, S16 fy, U16 frame, FAST_SPRITE_BLOCK_STRUCT * f_ptr, U32 screen_ptr)
{
 U16 * code_ptr;
 U16 old_code;
 S16 fline;

 if((fx<320) && (fy<240) && (fx+f_ptr->fs_sprite_x>=0) && (fy+f_ptr->fs_sprite_y>=0))
 {
  if (fy<0)
  {
   fline=0-fy;
   if(fline<f_ptr->fs_sprite_y)
    rlsp_display_fast_sprite(fx,0,screen_ptr,frame,fline,f_ptr);
  }
  else if(fy+f_ptr->fs_sprite_y>239)
  {
   fline=240-fy;   
   code_ptr=f_ptr->fs_sprite_ptrs[frame]->fs_sprite_lines[fline];
   code_ptr--;
   old_code=*code_ptr;
   *code_ptr=0x4E75;
    rlsp_display_fast_sprite(fx,fy,screen_ptr,frame,0,f_ptr);
   *code_ptr=old_code;
  } 
  else
   rlsp_display_fast_sprite(fx,fy,screen_ptr,frame,0,f_ptr);
 }
}