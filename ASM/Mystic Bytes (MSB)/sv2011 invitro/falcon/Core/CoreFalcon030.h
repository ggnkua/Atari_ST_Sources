//==========================================================================================
//		Sys Core Utils
//==========================================================================================
#ifndef _DSYS_CORE_F030_
#define _DSYS_CORE_F030_

//==========================================================================================
#define sinf sin
#define cosf cos
#define sqrtf sqrt
//==========================================================================================
namespace DemoSys
{

class CoreImplementationFalcon030
{
	static void init();
	static void shutdown();
	static bool loop();					// keep looping until false

public:

	friend class CoreInterface;
};


}	// end namespace DemoSys

#endif //_DSYS_CORE_F030_