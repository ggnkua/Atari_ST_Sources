#include <mint/osbind.h>
#include <mint/falcon.h>
#include <string.h>
#include <stdio.h>

#include <limits.h>
#include <ctype.h>
#include <stdlib.h>

// ----------------------------------------------------------------------------------------

extern "C"
{

// ----------------------------------------------------------------------------------------

void __assert_fail(const char * assertion, const char * file, unsigned int line, const char * function)
{
	puts("__assert_fail");
	//Pterm(-1);
}

// ----------------------------------------------------------------------------------------

void __main()
{
	//puts("__main");
}


// ----------------------------------------------------------------------------------------

int puts( const char* pText )
{
	Cconws ( pText );
	Cconws ( "\r\n" );
	
	return 0;
}

// ----------------------------------------------------------------------------------------

void* memset ( void * ptr, int value, size_t num )
{
	unsigned char* pTemp = (unsigned char*) ptr;
	
	while ( num-- )
	{
		*pTemp++=value;
	}
	
	return ptr;
}

// ----------------------------------------------------------------------------------------
/*
void * memcpy ( void * destination, const void * source, size_t num )
{
	if ( num )
	{
		unsigned long len = num >> 4;
		unsigned long* pDst2 = (unsigned long*)destination;
		unsigned long* pSrc2 = (unsigned long*)source;
		
		if ( len )
		{			
			do
			{
				*pDst2++=*pSrc2++;
				*pDst2++=*pSrc2++;
				*pDst2++=*pSrc2++;
				*pDst2++=*pSrc2++;
			} while ( len-- );
		}

		char* pDst = (char*)pDst2;
		char* pSrc = (char*)pSrc2;
		
		num = num - ( num & 0xfffffff0 );
			
		do
		{
			*pDst++=*pSrc++;
		}while  ( num-- );
	}
	return destination;
}
*/
// ----------------------------------------------------------------------------------------

void * malloc ( size_t size )
{
	//printf ("malloc %d\r\n",size);
	return (void*)Mxalloc( size, MX_PREFTTRAM);
}

// ----------------------------------------------------------------------------------------

void * calloc ( size_t num, size_t size )
{
	char *ptr = (char*) Mxalloc( size*num , MX_PREFTTRAM);
	memset( ptr, 0, size*num );
	return ptr;
}

// ----------------------------------------------------------------------------------------

void free ( void * ptr )
{
	if ( ptr )
	{
		Mfree ( ptr );
	}
}

// ----------------------------------------------------------------------------------------

void * realloc ( void * ptr, size_t size )
{
	//printf ("realloc %d\r\n",size);
	char *newptr = (char*) Mxalloc( size , MX_PREFTTRAM);
	memcpy ( newptr, ptr, size );
	Mfree ( ptr );
	return newptr;
}

// ----------------------------------------------------------------------------------------

size_t strlen ( const char * str )
{
	size_t len = 0;
	while ( *(char*)str ++ != 0 ) len++;
	return len;
}

// ----------------------------------------------------------------------------------------

int strcmp(const char *s1, const char *s2)
{
    while((*s1 && *s2) && (*s1++ == *s2++));
    return *(--s1) - *(--s2);
}

// ----------------------------------------------------------------------------------------

void* memmove(void *destination, const void *source, size_t n)
{
	char* dest = (char*)destination;
	char* src = (char*)source;

    /* No need to do that thing. */
    if (dest == src)
        return destination;

    /* Check for destructive overlap.  */
    if (src < dest && dest < src + n) {
        /* Destructive overlap ... have to copy backwards.  */
        src += n;
        dest += n;
        while (n-- > 0)
            *--dest = *--src;
    } else {
        /* Do an ascending copy.  */
        while (n-- > 0)
            *dest++ = *src++;
    }
	
	return destination;
}

// ----------------------------------------------------------------------------------------

int atoi( const char* pStr ) 
{ 
  int iRetVal = 0; 
  int iTens = 1;
 
  if ( pStr )
  {
    const char* pCur = pStr; 
    while (*pCur) 
      pCur++;
 
    pCur--;
 
    while ( pCur >= pStr && *pCur <= '9' && *pCur >= '0' ) 
    { 
      iRetVal += ((*pCur - '0') * iTens);
      pCur--; 
      iTens *= 10; 
    }
  } 
  return iRetVal; 
} 

// ----------------------------------------------------------------------------------------

}

// ----------------------------------------------------------------------------------------

void* operator new(unsigned long size)
{
	return malloc ( size );
}

// ----------------------------------------------------------------------------------------

void* operator new[](unsigned long size)
{
	puts("new[]");
	return malloc ( size );
}

// ----------------------------------------------------------------------------------------

void operator delete(void* pPtr)
{
	free(pPtr);
}

// ----------------------------------------------------------------------------------------

void operator delete[](void* pPtr)
{
	puts("delete[]");
	free(pPtr);
}

// ----------------------------------------------------------------------------------------
// This is a dummy class to force a static initialisation and destruction lists
// to be built by gcc.

struct MicroStartupForceStaticCtorDtor
{
	int m_data;
	MicroStartupForceStaticCtorDtor()
	{
		//Cconws("static create\r\n");
		m_data = 10;
	}
	~MicroStartupForceStaticCtorDtor()
	{
		//printf("static destruct %d\r\n", m_data);
	}
};

MicroStartupForceStaticCtorDtor ctordtor;

// ----------------------------------------------------------------------------------------
// This is required for basic std::list support 

#include <list>

namespace std
{
	namespace __detail
	{
		void
		_List_node_base::_M_hook(std::__detail::_List_node_base* __position)
		{
		  this->_M_next = __position;
		  this->_M_prev = __position->_M_prev;
		  __position->_M_prev->_M_next = this;
		  __position->_M_prev = this;
		}
		
		void
		_List_node_base::_M_unhook()
		{
		_List_node_base* const __next_node = this->_M_next;
		_List_node_base* const __prev_node = this->_M_prev;
		__prev_node->_M_next = __next_node;
		__next_node->_M_prev = __prev_node;
		}
	}
}