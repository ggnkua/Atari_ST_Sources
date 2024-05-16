//==========================================================================================
//		Sys Core Utils
//==========================================================================================
#ifndef _DSYS_CORE_WINSDL_
#define _DSYS_CORE_WINSDL_

#include <sdl.h>

//==========================================================================================
namespace DemoSys
{

class CoreImplementationWinSDL
{
	static SDL_Event ms_event; 

	static void init();
	static void shutdown();
	static bool loop();					// keep looping until false

public:
	static SDL_Event CoreImplementationWinSDL::GetEvent();

	friend class CoreInterface;
};


}	// end namespace DemoSys

#endif //_DSYS_CORE_WINSDL_