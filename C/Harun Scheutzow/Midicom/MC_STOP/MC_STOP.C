#include <portab.h>			 /* Standard-Definitionen */
#include <string.h>      /* String-Library */
#include <stddef.h>	     /* Standard-Definitionen */
#include <stdlib.h> 	     /* Standard-Definitionen */
#include "..\mc_lib\mc_lib.h"

#define _STOP_RING    6008

void wait_loop(void)
{    
	syspar		sys;
    all_proc	allprocs;
	msg_typ 	mc_msg;
	
   	if (get_mc_sys(&sys,&allprocs))
   	{
   		mc_msg.what= _STOP_RING;
      if (mc_message(&mc_msg))
      {
      	Cconws("MIDI_COM STOP \r\n");
      }
	}
	else
	{
		Cconws("NO MIDI_COM installed!!\r\n");
	};
}


int main( void )
{
    wait_loop();
    return 0;
}

