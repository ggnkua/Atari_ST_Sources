/*

	Joystick-Treiber fÅr Overlay
	Michael Huber
	(c) 1994

*/


#include <tos.h>
#include <vdi.h>
#include <aes.h>

typedef struct 
{
	int header;
	char val;
}	
JOYEVENT;

void  (*old_kb_joyvec)( JOYEVENT *event );
unsigned int header;
unsigned int val = 0;
char dir[16] = {0,'u','d',0,'l','U','L',0,'r','R','D',0,0,0,0.0};

void joy_handle( JOYEVENT *event )
{

	header = ( unsigned int )event->header;
	if( event->val )
		val = ( unsigned int )event->val;
	old_kb_joyvec( event );
	
}

int main( void )
{

	
	KBDVBASE *kbdv;
	unsigned int id = 0x8000;
	int vdih;
	int button, dummy;
	char ik[50];
	
	
	vdih = graf_handle( &dummy, &dummy, &dummy, &dummy );
	kbdv = Kbdvbase();
	old_kb_joyvec = kbdv->kb_joyvec;
	kbdv->kb_joyvec = joy_handle;
	
	vq_mouse( vdih,	&button, &dummy, &dummy );
	
	ik[0] = 0x16;
	Ikbdws(0, ik);
	
	evnt_timer(50,0);

	if( dir[val] )
		id = (unsigned int)dir[val];

	kbdv->kb_joyvec = old_kb_joyvec;
		
	if( id )
		id |= 0x4000;
		
	return id;
	
}		
	