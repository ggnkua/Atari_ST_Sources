// --------------------------------------------------------------------------------------------------------------
/*

	Archive.h
	
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _ARCHIVE_H_
#define _ARCHIVE_H_

// --------------------------------------------------------------------------------------------------------------

#include <3rd_party/rapidxml/rapidxml.hpp>

// --------------------------------------------------------------------------------------------------------------
class Node;

class Archive
{
	rapidxml::xml_document<>	m_doc;

public:
	
	inline Archive (char* pData);
	inline ~Archive ();
	
	inline Node FindNode( const char* pNodeName );
	
};

// --------------------------------------------------------------------------------------------------------------

class Node
{
	friend class Archive;
	rapidxml::xml_node<> *m_pNode;
	
	inline			Node			( rapidxml::xml_node<> *);
		
public:	
	inline	Node 	FindNode		( const char* pNodeName );
	inline	bool	NextSibling		( const char* pNodeName = NULL );
	
	template <typename T>
	inline	void	r				( const char* pNodeName, T& val );
	
	template <typename T>
	inline	void	r				( T& val );	

	template <typename T>
	void	rlist	( const char* pNodeName, T& val );

	
};
// --------------------------------------------------------------------------------------------------------------

template <typename T>
inline void	ConvertVal	( Node& node, const char* pVal, T& val );

// --------------------------------------------------------------------------------------------------------------

#endif //_ARCHIVE_H_