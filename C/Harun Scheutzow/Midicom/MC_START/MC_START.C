#include <portab.h>			 /* Standard-Definitionen */
#include <string.h>      /* String-Library */
#include <stddef.h>	     /* Standard-Definitionen */
#include <stdlib.h> 	     /* Standard-Definitionen */
#include "..\mc_lib\mc_lib.h"

#define _RESTART      6025

void wait_loop(void)
{    
	syspar		sys;
    all_proc	allprocs;
	msg_typ 	mc_msg;
	
   	if (get_mc_sys(&sys,&allprocs))
   	{
   		mc_msg.what= _RESTART;
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

