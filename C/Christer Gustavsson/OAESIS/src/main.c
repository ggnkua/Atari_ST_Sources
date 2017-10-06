#include <mintbind.h>
#include <osbind.h>
#include <process.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "evnthndl.h"
#include "form.h"
#include "graf.h"
#include "lxgemdos.h"
#include "menu.h"
#include "misc.h"
#include "mousedev.h"
#include "objc.h"
#include "rdwrs.h"
#include "resource.h"
#include "version.h"
#include "wind.h"

#include	<sysvars.h>

void init_aes(WORD physical) {
	init_global(physical);

	printf("Initializing:\r\n");
	
	printf("Mutual exclusion\r\n");
	Rdwrs_init_module();
	
	printf("AES trap vector\r\n");
	Supexec(link_in);

	printf("Application calls\r\n");
	Appl_init_module();
	
	printf("Object calls\r\n");
	init_objc();

	printf("Window calls\r\n");
	Wind_init_module();

	printf("Menu calls\r\n");
	Menu_init_module();

	printf("Graf calls\r\n");
	Graf_init_module();

	printf("Mouse device\r\n");
	Moudev_init_module();

	printf("Event handler\r\n");
	Evhd_init_module();
	
	printf("Done.\r\n");
}

void	exit_aes(void) {
	printf("Exiting:\r\n");

	printf("Event handler\r\n");

	Evhd_exit_module();
		
	printf("Menu calls\r\n");

	Menu_exit_module();

	printf("Mouse device\r\n");

	Moudev_exit_module();
	
	printf("Window calls\r\n");

	Wind_exit_module();
	
	printf("Application calls\r\n");

	Appl_exit_module();

	printf("Aes trap vector\r\n");

	Supexec(link_remove);

	printf("Object calls\r\n");

	exit_objc();

	printf("Mutual exclusion device\r\n");

	Rdwrs_exit_module();

	printf("Global\r\n");

	exit_global();

	printf("Done.\r\n");
}


int main(int argc,char **argv) {
	WORD physical = 0;
	WORD i;
	LONG mintval;

	if(!Misc_get_cookie(0x4d694e54L /*'MiNT'*/,&mintval)) {
		fprintf(stderr,"oAESis requires MiNT to work. Start MiNT and try again!\r\n");
		
		return -1;
	};

	printf("Starting oAESis version %s.\r\n",VERSIONTEXT);
	printf("Compiled on %s at %s with ",__DATE__,__TIME__);

#ifdef __TURBOC__
	printf("Pure C / Turbo C %x.%x.\r\n",__TURBOC__ >> 8,__TURBOC__ & 0xff);
#endif


	printf("The following options were used:\r\n");

#ifdef __68020__
	printf("- Main processor 68020.\r\n");
#endif

#ifdef __68881__
	printf("- Math co-processor 68881.\r\n");
#endif

	printf("\r\nMiNT version %ld.%02ld detected\r\n",mintval >> 8,mintval & 0xff);

	for(i = 1; i < argc; i++) {
		if(!strcmp("-physical",argv[i])) {
			physical = 1;
		}
		else {
			fprintf(stderr,"Unknown option %s\r\n",argv[i]);
		};
	};

	init_aes(physical);

	Menu_handler();
	
	exit_aes();

	return 0;
};


