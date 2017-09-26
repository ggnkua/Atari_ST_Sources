/*------------------------------------------------------------------------*/
/* iTime zeigt die Onlinezeit in der MenÅzeile														*/

#include <cflib.h>
#include <signal.h>

#include "types.h"
#include "event.h"
#include "global.h"
#include "internet.h"
#include "online.h"
#include "options.h"
#include "rsc.h"
#include "setup.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

int	abort_prog = 0;								/* Falls TRUE -> sofort Ende 			*/

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

static int init_all(void);
static void cdecl handle_term(int sig);

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

/*------------------------------------------------------------------------*/
/* main-Funktion																													*/

void main(void)
{
	Pdomain(1);
	init_app(NULL);

	signal(SIGINT, SIG_IGN);
	signal(SIGSYS, SIG_IGN);
	signal(SIGTERM, handle_term);
	signal(SIGQUIT, handle_term);
	signal(SIGHUP, handle_term);

	if(!init_resource())
		exit_app(0)	;

	option_load();

	init_global();

	if(init_all())
		main_loop();

	term_internet();
	term_setup();
	term_online();
		
	option_save();
	
	term_resource();

	term_global();	
	exit_app(0)	;
}

/*------------------------------------------------------------------------*/
/* Alle nîtigen Modul iniatillisieren																			*/

int init_all(void)
{

	if(!init_online())
		return 0;

	if(!init_setup())
		return 0;

	if(!init_internet())
		return 0;

	return 1;
}
/*------------------------------------------------------------------------*/
/* 	Signal-Handle																													*/

void cdecl handle_term(int sig)
{
	abort_prog = 1;
}
