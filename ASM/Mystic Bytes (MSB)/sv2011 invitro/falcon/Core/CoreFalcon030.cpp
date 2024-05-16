//==========================================================================================
//		Core
//==========================================================================================
#include <Core.h>
#include "Core/CoreFalcon030.h"
#include <Config.h>
#include <assert.h>
#include <osbind.h>
//==========================================================================================
namespace DemoSys
{
//==========================================================================================

//==========================================================================================

void CoreImplementationFalcon030::init()
{

	Super(0);		// switch to supervisour 
}

void CoreImplementationFalcon030::shutdown()
{
	
}

bool CoreImplementationFalcon030::loop()
{
	bool ret = true;

	if( -1 == Cconis() )
	{
		return false;
	}

	return ret;	// return something sensible
}

//==========================================================================================
}