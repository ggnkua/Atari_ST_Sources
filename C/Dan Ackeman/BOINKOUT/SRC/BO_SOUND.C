/* Boinkout2 sound routines */

#include "boink.h"

long snd_system = 0;  /* This is the soundsystem that exists on the computer */
int sound_switch = 1;


/* First the atari sound routines: */
#if OS_TOS


/* the sound string is the yamaha sound chip parameter for the bouncing		*/
/* ball sound. The osound array resets the modified sound chip registers	*/
/* to their old values so that key click sounds will be normal when the		*/
/* program terminates.														*/

char sound[] =	{
	0,0xf0,1,0x0f, 2,0xff, 3,0x0f, 4,0x00, 5,0, 6,0x1f, 7,0xdc,
	8,0x10,9,0x10,10,0x10,11,0x00,12,25,13,0,0xff,0
	};

short appear[] = {
	0x040,0x102,0x242,0x302,0x400,0x500,0x61f,0x7dc,
	0x810,0x910,0xA10,0xB00,0xC15,0xD0f,0xFF00
	};

/* osound restores registers 9 and 10 for normal key click */
char osound[] = { 9, 0, 10, 0, 0xff, 0	};

short magic_bell[] = {
	0x0ff,0x100,0x2fe,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc20,0xd09,0xff00
	};

short bricksound[] = {
	0x035,0x100,0x234,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc15,0xd09,0xff00
	};

short permbricksound[] = {
	0x038,0x100,0x237,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc0b,0xd09,0xff00
	};

short death[] = {
	0x0018,0x0100,0x073e,0x0810,0x0d09,0x8000,0x0b00,0x0c60,
	0x8100,0xce01,0xff00
	};

short lost_ball[] = {
	0x0000,0x0102,0x073e,0x0810,0x0d09,0x8000,0x0b00,0x0c30,
	0x8100,0x1801,0xff00
	};

short psound[] = {
	0x041,0x100,0x240,0x300,0x400,0x500,0x600,0x7fc,
	0x810,0x910,0xa00,0xb00,0xc15,0xd09,0xff00
	};

short bonus[] = {		/* bonus sound effect */
	0x000,0x100,0x200,0x300,0x400,0x500,0x600,0x7FE,
	0x80F,0x900,0xA00,0xB00,0xC00,0xD00,
	0x8040,0x8100,0xfd31,
	0x8040,0x8100,0xfd31,
	0x8040,0x8100,0xfd31,
	0x800,0xFF00
	};


/* Initialize the sounds - only a dummy function by now, but */
/* one day, we could load here the sample sound for example  */
int sound_init()
{
 return 0;
}

/* Play a sound */
int sound_play(int num)
{
 static void *dosndtab[]={appear, magic_bell, bricksound, permbricksound,
                 death, lost_ball, psound, bonus };

 if (sound_switch == 1)
  {
   if(num<=S_BONUS)
     Dosound(dosndtab[num]);
    else
     switch(num)
      {
       case S_SIDE:
	*(sound + 13) = 0x1e;
	Dosound(sound);
	break;
       case S_TOP:
	*(sound + 13) = 0x1d;
	Dosound(sound);
	break;
       case S_BOTTOM:
	*(sound + 13) = 0x1f;
	Dosound(sound);
	break;
      }
  }

 return 0;
}

int sound_exit()
{
 Dosound(osound);
 return 0;
}


#endif /* OS_TOS */




/* And now the poor DOS sound routines */

#if OS_DOS


int sound_init()
{
 return 0;
}

/* Play a sound */
int sound_play(int num)
{
 int i;
 if (sound_switch == 1)
  {
   switch(num)
    {
     case S_APPEAR:
	for(i=400; i<1000; i+=80)  v_sound(vdi_handle, i, 1);
	break;
     case S_BRICKSOUND:
	v_sound(vdi_handle, 1600, 1);
	break;
     case S_PERMBRICKSOUND:
	v_sound(vdi_handle, 1000, 1);
	break;
     case S_DEATH:
	for(i=1000; i>400; i-=80)  v_sound(vdi_handle, i, 1);
	break;
     case S_LOSTBALL:
	for(i=800; i>400; i-=100)  v_sound(vdi_handle, i, 1);
	break;
     case S_SIDE:
	v_sound(vdi_handle, 50, 1);
	break;
     case S_TOP:
	v_sound(vdi_handle, 100, 1);
	break;
     case S_BOTTOM:
	v_sound(vdi_handle, 150, 1);
	break;
    }
  }

 return 0;
}

int sound_exit()
{
 return 0;
}


#endif /* OS_DOS */

