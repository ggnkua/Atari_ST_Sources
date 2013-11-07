#include <stdio.h>
#include <tos.h>

#define JOY_UP 1
#define JOY_LEFT 4
#define JOY_RIGHT 8
#define JOY_DOWN 2
#define JOY_FIRE 128

typedef unsigned int word;
typedef unsigned char byte;

/* key handeler info */
struct key_handler_info_struct
{
  int status;
  volatile int mousex;
  volatile int mousey;
  volatile byte buttons; /* muis knoppen */
  volatile byte joy0;
  volatile byte joy1;
  volatile byte joy2; /* cursor joystick */
  volatile byte last_key;
} key_info;

int stop=0;
void *old_kbd;

void main_game(void);
void restore(void);
void init_game(void);
void key_handle(void);
void read_kbd(void);

void move_sr(word value) 0x46c0; /* move D0,SR */

int main(void)
{
  Supexec((long)(main_game));
  return 0;
}


void main_game(void)
{
  init_game();
  for(;;)
  {
    read_kbd();
    if(stop)
    {
      break;
    }
  }
  restore();
}

void init_game(void)
{
  #if 0
    Bconout(4, 0x12); /* disable mouse */
    Vsync();
    Vsync();
    Vsync();
    Vsync();
    Vsync(); /* Voodoo code */
  #else
    Bconout(4, 0x08); /* enable mouse */
    Vsync();
    Vsync();
    Vsync();
    Vsync();
    Vsync();
  #endif
  { /* flush keyboard */
    KBDVBASE *base;
    byte *p=(byte *)0xfffffc00UL;
    move_sr(0x2700);
    while(*p&1)
    {
      byte tmp=p[2];
    }
    base=Kbdvbase();
    old_kbd=base->kb_kbdsys;
    base->kb_kbdsys=key_handle;
    move_sr(0x2300);
  }
}

void restore(void)
{
  Bconout(4, 0x08); /* enable mouse */
  Vsync();
  Vsync();
  Vsync();
  Vsync();
  Vsync();
  { /* flush keyboard */
    byte *p=(byte *)0xfffffc00UL;
    KBDVBASE *base;
    move_sr(0x2700);
    while(*p&1)
    {
      byte tmp=p[2];
    }
    base=Kbdvbase();
    base->kb_kbdsys=old_kbd;
    move_sr(0x2300);
  }
}

void key_handle(void)
{
  byte key;
  key=*(byte*)0xfffffc02UL;
  if(key_info.status==0)
  {
    switch(key)
    {
      case 0xff:
      key_info.status=-1; /* joy 1 is comming */
      break;
      case 0xfe:
      key_info.status=1;  /* joy 0 is comming */
      break;
      case 0xf8:
      key_info.buttons=0; /* geen muis buttons */
      key_info.status=3; /* mouse packet is comming */
      break;
      case 0xf9:
      key_info.buttons=1; /* geen muis buttons */
      key_info.status=3; /* mouse packet is comming */
      break;
      case 0xfa:
      key_info.buttons=2; /* geen muis buttons */
      key_info.status=3; /* mouse packet is comming */
      break;
      case 0xfb:
      key_info.buttons=3; /* geen muis buttons */
      key_info.status=3; /* mouse packet is comming */
      break;
      case 72: /* cursor up */
      key_info.joy2|=JOY_UP;
      break;
      case 72+128:
      key_info.joy2&=~JOY_UP;
      break;
      case 75: /* cursor left */
      key_info.joy2|=JOY_LEFT;
      break;
      case 75+128:
      key_info.joy2&=~JOY_LEFT;
      break;
      case 77: /* cursor right */
      key_info.joy2|=JOY_RIGHT;
      break;
      case 77+128:
      key_info.joy2&=~JOY_RIGHT;
      break;
      case 80: /* cursor down */
      key_info.joy2|=JOY_DOWN;
      break;
      case 80+128:
      key_info.joy2&=~JOY_DOWN;
      break;
      case 57: /* spatie */
      key_info.joy2|=JOY_FIRE;
      break;
      case 57+128:
      key_info.joy2&=~JOY_FIRE;
      break;
      default:
      key_info.last_key=key;
      break;
    }
  }
  else
  {
    if(key_info.status<0)
    { /* joy1 */
      key_info.joy1=key;
      key_info.status=0;
    }
    else
    { 
      if(key_info.status==1)
      { /* joy0 */
        key_info.joy0=key;
        key_info.status=0;
      }
      else
      {
        if(key_info.status==2)
        { /* mouse y */
          key_info.status=0;
          key_info.mousey+=(signed char)key;
        }
        else
        {
          key_info.status=2;
          key_info.mousex+=(signed char)key;
        }
      }
    }
  }
}

void read_kbd(void)
{
  #if 0
  printf("joy0: %02X    joy1: %02X    joy2: %02X    key: %02X\r",
          key_info.joy0,key_info.joy1,key_info.joy2,key_info.last_key);
  #else
  printf("Muis x: %05i  Muis y: %05i   Buttons: %02i\r",
          key_info.mousex, key_info.mousey, key_info.buttons);
  #endif
  if(key_info.last_key==1)
  {
    stop=1;
  }
}
