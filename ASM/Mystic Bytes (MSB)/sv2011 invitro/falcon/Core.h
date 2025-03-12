//==========================================================================================
//		Sys Core Utils
//==========================================================================================
#ifndef _DSYS_CORE_
#define _DSYS_CORE_


//==========================================================================================
namespace DemoSys
{

class CoreInterface
{
public:
	static void init();
	static void shutdown();
	static bool loop();					// keep looping until false
};

	
}

#endif //_DSYS_CORE_