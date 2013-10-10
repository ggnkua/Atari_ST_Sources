#define DATAVOID
#include "dialog.h"
long Image1[]=
{
  0x00000111,0x11100000,0x00011999,0x99911000,0x00199000,0x00099100,0x01900000,0x00000810,
  0x01900000,0x00000810,0x19000000,0x00000081,0x19000000,0x00000081,0x19000000,0x00000081,
  0x19000000,0x00000081,0x19000000,0x00000081,0x19000000,0x00000081,0x01900000,0x00000810,
  0x01900000,0x00000810,0x00188000,0x00088100,0x00011888,0x88811000,0x00000111,0x11100000,
};
long Image2[]=
{
  0x00000111,0x11100000,0x00011999,0x99911000,0x00199000,0x00099100,0x01900088,0x88000810,
  0x01900811,0x11800810,0x19008188,0x88190081,0x19081888,0x88819081,0x19081888,0x88819081,
  0x19081888,0x88819081,0x19081888,0x88819081,0x19008188,0x88190081,0x01900911,0x11900810,
  0x01900099,0x99000810,0x00188000,0x00088100,0x00011888,0x88811000,0x00000111,0x11100000,
};
long mask1[]=
{
  0x07e01ff8,0x3ffc7ffe,0x7ffeffff,0xffffffff,0xffffffff,0xffff7ffe,0x7ffe3ffc,0x1ff807e0,
};

RO_Button temp_button[]=
{
/* 0 */    {BUTTON_NORMAL,(char *)0},
};

RO_Image temp_images[]=
{
/* 0 */    {16,16,4,(long *)&Image1,(long *)&mask1},
/* 1 */    {16,16,4,(long *)&Image2,(long *)&mask1},
};

#define TEMP_BOX    0
#define TEMP_BUTTON 1
#define TEMP_IMAGE  2

RO_Object temp_objects[]=
{
/* 0 */    {"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0",-1,-1,-1,-1,RO_BOX,SW_NONE,(void*)0,(char*)0,0,0,0,0},                  /* Box      */
/* 1 */    {"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0",-1,-1,-1,-1,RO_BUTTON,SW_NONE,(void*)&temp_button[0],(char*)0,0,0,0,0}, /* Button   */
/* 2 */    {"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0",-1,-1,-1,-1,RO_IMAGE,SW_NONE,(void*)&temp_images[0],(char*)0,0,0,0,0}    /* Image    */
};
#define TEMP_BOX    0
#define TEMP_BUTTON 1
#define TEMP_IMAGE  2

#undef DATAVOID