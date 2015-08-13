/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*
**	joystick.c
**
**	the joystick library.
**
**	allows you to read joystick #1 easily
*/

#include <jk_sys.h>
#include <osbind.h>
#include "joystick.h"


static Boolean active=false;
static short (*old_vec)();

static void joy_handle( unsigned char * );

static JoyStickState joy0;
static JoyStickState joy1;

void JoyInit()
{
	kbdvecs *k;
	
	if( !active )
	{
	    Bconout(4, 0x12);   /* Kill the mouse <squeak> */
 
		k=Kbdvbase();
		
		old_vec=k->joyvec;
		
		(void *)k->joyvec=(void *)joy_handle;
		active=true;
		Bconout( 4, 0x14 );
	}
	/* also send IKBD its message to send packets */
}

void JoyKill()
{
	kbdvecs *k;
	
	if( active )
	{
		/* tell IKBD to stop sending joystick stuff */
		Bconout(4,0x1a);		/* disable joyticks	*/
	        Bconout(4, 0x08);   /* Restore mouse */
		k=Kbdvbase();
		
		k->joyvec=old_vec;
		active=false;
	}
}

JoyStickState JoyGet( int joynum )
{
	if( joynum==0 )
		return joy0;
	else
		return joy1;
}

static void joy_handle( unsigned char *a)
{

	if( (*a & 1)==0 )
	{
		// joystick 0
		
		joy0.up=a[1]&1;
		joy0.down=a[1]>>1 & 1;
		joy0.left=a[1]>>2 & 1;
		joy0.right=a[1]>>3 & 1;
		joy0.fire=a[1]>>7 & 1;
	}
	
	if( (*a & 1)==1 )
	{
		joy1.up=a[2]&1;
		joy1.down=a[2]>>1 & 1;
		joy1.left=a[2]>>2 & 1;
		joy1.right=a[2]>>3 & 1;
		joy1.fire=a[2]>>7 & 1;
	}
}
