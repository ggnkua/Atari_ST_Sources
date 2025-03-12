//==========================================================================================
//		Core
//==========================================================================================
#include <Core.h>
#include "Core/CoreWinSdl.h"
#include <Config.h>
#include "sdl.h"
#include <assert.h>
#include "FreeImage.h"
//==========================================================================================
namespace DemoSys
{
//==========================================================================================

SDL_Event CoreImplementationWinSDL::ms_event; 

//==========================================================================================

void CoreImplementationWinSDL::init()
{
	// Load SDL
	assert(SDL_Init(SDL_INIT_VIDEO) == 0);

	FreeImage_Initialise();
}

void CoreImplementationWinSDL::shutdown()
{
	FreeImage_DeInitialise();
	SDL_Quit(); 
}

bool CoreImplementationWinSDL::loop()
{
	bool ret = true;

	if( SDL_PollEvent( &ms_event ) )
	{
		if ( SDL_QUIT == ms_event.type )
		{
			ret = false;
		}
		else if( SDL_KEYDOWN == ms_event.type && SDLK_ESCAPE == ms_event.key.keysym.sym)
		{ 
			ret = false;
		} 
	}
	return ret;	// return something sensible
}

SDL_Event CoreImplementationWinSDL::GetEvent()
{
	return ms_event;
}

//==========================================================================================
}