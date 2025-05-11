/////////////////////////////////////////////////////////////////////////
//
// File:	contract.h
//
// Decription:
//		Dieses File stellt einige Makros zur Verfuegung,
//		mit denen Design by Contract, siehe B. Meyer:
//		'Object Oriented Software Construction', realisiert
//		werden kann.
//
//		Preconditions werden mit Require( exp ),
//		Postconditions mit Ensure( exp ) ueberprueft.
//
//		Code wird aber nur erzeugt, wenn das Symbol DCL_DEBUG
//		mittels der Option -DDCL_DEBUG oder per #define
//		deklariert wurde.
//
//		Alternativ kann auch im File debug.h dieses Makro,
//		aktiviert oder deaktiviert werden.
//
// $Author: pareis $
//
// $Id: Item.h,v 1.2 1992/06/14 17:29:22 pareis Exp $
//
/////////////////////////////////////////////////////////////////////////


#ifndef _Contract_h
#define _Contract_h


#if !defined( DCL_DEBUG ) && !defined( DCL_AES_DEBUG )

#  define Require( cond )
#  define Ensure( cond )
#  define Inspect( expr )

#else


#  include <stdio.h>
#  include <stdlib.h>





#  ifdef DCL_AES_DEBUG

#    include <aesbind.h>
#    include <string.h>


#    define		__MESSAGE( name,prefix,cond )			\
{									\
	if( !(cond) )							\
	{								\
		char buf[120];						\
									\
		sprintf( buf, "[3][  %scondition failed in file  |  %s,"\
			" line %ld:| |  %s( %s )  ][  Exit  | Ignore ]",\
			prefix, __FILE__, (long)(__LINE__), name,	\
			#cond );					\
									\
		if( form_alert( 1, buf ) == 1 )				\
			exit(1);					\
	}								\
}





inline void Inspect( const char *message )
{
	char buf[120] = "[1][\0";
	
	strcat( buf, message );
	strcat( buf, "][ Continue ]" );
	
	form_alert( 1, buf );
}





#  else




#    include <unistd.h>


#    define __FAILED_MSG  "%scondition failed in file %s, line %ld:\n"	\
			"%s( %s )\n"


#    define	__MESSAGE( name,prefix,cond )				\
{									\
	if( !(cond) )							\
	{								\
		fprintf( stderr, __FAILED_MSG, prefix, __FILE__,	\
			(long)(__LINE__), name, #cond );		\
		sleep(2);						\
		exit(1);						\
	}								\
}



#  endif	// #ifdef DCL_AES_DEBUG







#  define Require( expr )	__MESSAGE( "Require","Pre",expr )
#  define Ensure( expr )	__MESSAGE( "Ensure","Post",expr )






#endif	// #ifndef DCL_DEBUG





#endif	// #ifndef _Contract_h
