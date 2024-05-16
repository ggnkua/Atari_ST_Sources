// --------------------------------------------------------------------------------------------------------------
/*

	Archive.inl
	
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _ARCHIVE_INL_
#define _ARCHIVE_INL_

#include <Types.h>
#include <stdio.h>
#include "Archive.h"

// --------------------------------------------------------------------------------------------------------------
	
Archive::Archive (char* pData)
{
	puts("parsing");
	m_doc.parse<0>(pData);    // 0 means default parse flags
	puts("done");
}

// --------------------------------------------------------------------------------------------------------------

Archive::~Archive ()
{

}

// --------------------------------------------------------------------------------------------------------------

Node Archive::FindNode( const char* pNodeName )
{
	return Node ( m_doc.first_node( pNodeName ) );
}
	
// --------------------------------------------------------------------------------------------------------------

inline	Node::Node	( rapidxml::xml_node<>* pNode) :
	m_pNode ( pNode )
{
}

// --------------------------------------------------------------------------------------------------------------

Node 	Node::FindNode		( const char* pNodeName )
{
	return Node ( m_pNode->first_node( pNodeName ) );
}

// --------------------------------------------------------------------------------------------------------------

bool	Node::NextSibling		( const char* pNodeName )
{
	 m_pNode = m_pNode->next_sibling( pNodeName );
	 return ( m_pNode != NULL) ? true : false;
}

// --------------------------------------------------------------------------------------------------------------

template <typename T>
void	Node::r	( const char* pNodeName, T& val )
{
	rapidxml::xml_node<>* pNode = m_pNode->first_node( pNodeName );
	ConvertVal( *this, pNode->value(), val );
}

// --------------------------------------------------------------------------------------------------------------

template <typename T>
void	Node::rlist	( const char* pNodeName, T& val )
{
	Node text = FindNode( pNodeName );
	
	int i = 0, size = sizeof(T) / sizeof(val[0]);
	
	do{
		text.r( val[i] );
		i++;
	}while ( text.NextSibling() && i < size );
	
	//if ( i < size )
	//	val[i] = 0;

}

// --------------------------------------------------------------------------------------------------------------

template <typename T>
void	Node::r	( T& val )
{
	ConvertVal( *this, m_pNode->value(), val );
}

// --------------------------------------------------------------------------------------------------------------

template <>
inline void	ConvertVal<const char*>	( Node& node, const char* pVal, const char*& val )
{
	val = pVal;
}

// --------------------------------------------------------------------------------------------------------------

template <typename T>
inline void	ConvertVal	( Node& node, const char* pVal, T& val )
{
	val.Serialise( node );
}

// --------------------------------------------------------------------------------------------------------------

template <>
inline void	ConvertVal<int>	( Node& node, const char* pVal, int& val )
{
	val = atoi( pVal );
}
// --------------------------------------------------------------------------------------------------------------

template <>
inline void	ConvertVal<u32>	( Node& node, const char* pVal, u32& val )
{
	val = atoi( pVal );
}

// --------------------------------------------------------------------------------------------------------------

template <>
inline void	ConvertVal<u16>	( Node& node, const char* pVal, u16& val )
{
	val = atoi( pVal );
}
// --------------------------------------------------------------------------------------------------------------

template <>
inline void	ConvertVal<u8>	( Node& node, const char* pVal, u8& val )
{
	val = atoi( pVal );
}
// --------------------------------------------------------------------------------------------------------------

template <>
inline void	ConvertVal<bool>	( Node& node, const char* pVal, bool& val )
{
	if ( pVal[0] == 'T' || pVal[0] == 't' || pVal[0] == '1' )
	{
		val = true;
	}
	else
	{
		val = false;	
	}
}
// --------------------------------------------------------------------------------------------------------------
#endif // _ARCHIVE_INL_