// --------------------------------------------------------------------------------------------------------------
/*
	Facotry.cpp
*/
// --------------------------------------------------------------------------------------------------------------

#include <string.h>
#include "Factory.h"

// --------------------------------------------------------------------------------------------------------------

Factory* Factory::ms_pInstance = 0;

// --------------------------------------------------------------------------------------------------------------

void* Factory::Create( const char* pClassName )
{
	FactoryClassList::iterator it = m_classList.begin();
	FactoryClassList::iterator end = m_classList.end();
	
	for ( ; it != end; ++it )
	{
		//printf ( "s: %s\r\n", it->first );
		if ( strcmp ( it->first, pClassName) == 0 )
		{
			return it->second->Create();
		}
	}
	return NULL;
}

// --------------------------------------------------------------------------------------------------------------

Factory& Factory::instance()
{
	if ( ms_pInstance == 0 )
	{
		ms_pInstance = new Factory();
	}
	return *ms_pInstance;
}

// --------------------------------------------------------------------------------------------------------------

