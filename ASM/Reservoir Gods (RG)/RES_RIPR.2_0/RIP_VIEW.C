#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

typedef unsigned char			UBYTE;
typedef signed char				SBYTE;
typedef unsigned int            UWORD;
typedef signed int              SWORD;
typedef unsigned long           ULONG;
typedef signed long             SLONG;

typedef unsigned char			U8;
typedef signed char				S8;
typedef unsigned int 			U16;
typedef signed int          	S16;
typedef unsigned long           U32;
typedef signed long            	S32;
typedef float                   FP32;

typedef union { U8 b3, b2, b1, b0; U16 w1, w0; U32 ln; } UL;


typedef struct
{
U8 grip_id[4];
U16 grip_version;
U16 grip_res;
U16 grip_x;
U16 grip_y;
U16 grip_line_length;
U16 grip_pal_type;
U16 grip_data;
} GRIP_STRUCT;

void show_grip(GRIP_STRUCT * grip_ptr)
{
 U32 grip_adr;
 U16 * grip_gfx_ptr;
 U16 * d_ptr;
 U16 * sx_ptr;
 U16 * sx2_ptr;
 U16 xwords;	
 S32 xadd;
 U16 i,j;

 sx_ptr=(U16 *)0xFFFF8210;
 sx2_ptr=(U16 *)0xFFFF820E;
 grip_gfx_ptr=&grip_ptr->grip_data;
 rlsc_set_screen_mode(grip_ptr->grip_x,grip_ptr->grip_y,grip_ptr->grip_res);	
 grip_adr=(U32)&grip_ptr->grip_data;
 if (grip_ptr->grip_res<4)
 {	
  if(grip_ptr->grip_pal_type)
  {
   rlvc_wait_vbl();
   mg_set_falc_pal(pal_cols[grip_ptr->grip_res],(U32 *)grip_adr);
   grip_adr+=pal_cols[grip_ptr->grip_res]<<2;
  }
  else
  {
   rlvc_wait_vbl();
   rlsc_set_palette_st((U16 *)grip_adr);
   grip_adr+=pal_cols[grip_ptr->grip_res]<<1;
  }
 }  

 grip_gfx_ptr=(U16 *)grip_adr;

 d_ptr=(U16 *)my_physic;
 xwords=grip_ptr->grip_line_length>>1;
 rlvc_wait_vbl();
 xadd=(*sx_ptr+*sx2_ptr)-xwords;
 if(xadd>0) d_ptr+=xadd>>1;
 for(j=0;j<grip_ptr->grip_y;j++)
 {
  for(i=0;i<xwords;i++)
   *d_ptr++=*grip_gfx_ptr++;				
  d_ptr+=xadd;
 }
 rlsc_set_new_physic(my_physic);
 rlvc_wait_vbl();
}
