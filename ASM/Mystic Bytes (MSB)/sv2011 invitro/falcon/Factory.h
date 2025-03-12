// --------------------------------------------------------------------------------------------------------------
/*
	Factory.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _FACTORY_H_
#define _FACTORY_H_

#include <stdio.h>
#include <vector>

// --------------------------------------------------------------------------------------------------------------
class CreatorBase;
typedef std::pair<const char*,CreatorBase*> FactoryPair;
typedef std::vector<FactoryPair> FactoryClassList;

class Factory 
{
	FactoryClassList m_classList;
	static Factory* ms_pInstance;
public:
	template <typename T>
	void Register(const char* pClassName, CreatorBase* pCreator ); 
	void* Create( const char* pClassName );
	static Factory& instance();
};

// --------------------------------------------------------------------------------------------------------------

template <typename T>
void Factory::Register(const char* pClassName, CreatorBase* pCreator)
{
	printf("registering: %s, 0x%x\r\n", pClassName, pCreator );
	m_classList.push_back( FactoryPair(pClassName,pCreator) );
}

// --------------------------------------------------------------------------------------------------------------

struct CreatorBase
{
	virtual void* Create() = 0;
};

// --------------------------------------------------------------------------------------------------------------

template <typename T> 
struct Creator : public CreatorBase
{
	void* Create();
};

// --------------------------------------------------------------------------------------------------------------

template <typename T> 
void* Creator<T>::Create()
{
	return (void*) new T();
}

// --------------------------------------------------------------------------------------------------------------

template <typename T>
struct RegProxy
{
	RegProxy( const char* pClassName )
	{
		Factory::instance().Register<T>( pClassName, new Creator<T> );
	}
};

// --------------------------------------------------------------------------------------------------------------

#define REGISTER_FACTORY_CLASS(TYPE,NAME) \
		static RegProxy<TYPE> proxy(NAME);
		
// --------------------------------------------------------------------------------------------------------------

#endif //_FACTORY_H_