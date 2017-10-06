/* file to do keyboard.  It handles break checking and a 256 key buffer
   internally.  Sadly very machine dependent. */

#define ST

#ifdef ST
#include <osbind.h>
#endif ST

#define KEYB 256
#define BREAKKEY 11779
#define DUMPKEY 8196
extern int watchdog;
static int keybuf[KEYB];
static int keyread, keywrite;
static int keycount;

extern int *aline;
mouse_x()
{
return( aline[-301] );
}

mouse_y()
{
return( aline[-300] );
}

mouse_left()
{
return( (aline[-174] & 0x100) != 0);
}

mouse_right()
{
return( (aline[-174] & 0x200) != 0);
}


time_peek()
{
return(*((long *)0x4ba));
}


get_clock()
{
register int time;

time = Supexec(time_peek);
return(time);
}

extern char _rjoy, _ljoy;
extern int _bjoy;
extern char findpacket();

struct kbdvecs
	{
	long  midivec, vkbderr, vmiderr, statvec, mousevec, clockvec;
	char (*joyvec)(), *midisys, *ikbdsys;
	};
static char (*o)();
static char in_joy;
static struct kbdvecs *k;
static char kb[] = { 0, 0 };
static char mousedata[] = { 0,0,1,1};


use_joy()
{
if (!in_joy)
	{
	k = (struct kbdvecs *)Kbdvbase();
	o = k->joyvec;
	k->joyvec = findpacket;
	kb[0] = 0x14;	/* ikbd into joystick event mode */	
	Ikbdws(0, kb);
	in_joy = 1;
	}
}

use_mouse()
{
if (in_joy)
	{
	kb[0] = 0x1a;	/* ikbd into no joystick mode */	
	Ikbdws(0, kb);
	k->joyvec = o;
	Initmous(1, &mousedata, k->mousevec);
	in_joy = 0;
	}
}

joystick()
{
readjoy();
return(_bjoy);
}


console()	/* machine dependent of course! */
{
#ifdef ST
if (Cconis())
	{
	int w;
	long l;

	l = Crawcin();
	w = l>>8;
	w += l;
		return(w);
	}
else
	return(0);
#endif ST
#ifdef TURBOC
if (bioskey(1))	/* check for pending character */
	{
	return(bioskey(0));
	}
else
	return(0)
#endif TURBOC
}

static buffer_write()
{
int key;

key = console();
if (key && (key != BREAKKEY) && (key != DUMPKEY))
	{
	if (keycount < KEYB)
		{
		keybuf[keywrite++] = key;
		if (keywrite >= KEYB)
			keywrite = 0;
		keycount++;
		}
	else
		{
		puts("Key buffer overflow!");
		}
	}
return(key);
}

rawkey()
{
int key;

if (keycount <= 0)
	{
	return(console());
	}
else
	{
	key = keybuf[keyread++];
	if (keyread >= KEYB)
		keyread = 0;
	--keycount;
	return(key);
	}
}


inkey()
{
return(rawkey()&0xff);
}


waitkey()
{
int key;

while ((key = inkey()) == 0)
	;
return(key);
}

extern int user_abort;

#ifdef OLD
/* Check to let user interrupt us from keyboard.  */
check_abort()
{
if (buffer_write() == BREAKKEY)	/* check for control c */
	{
	user_abort = 1;
	return(1);
	}
return(0);
}
#endif OLD

/* Check to let user interrupt us from keyboard.  */
check_abort()
{
int c;

c = buffer_write();
if (c == BREAKKEY)	/* check for control c */
	{
	watchdog = 0;
	user_abort = 1;
	}
if (c == DUMPKEY)
	{
	watchdog = 0;
	user_abort = 2;
	puts("Dump key");
	}
}


