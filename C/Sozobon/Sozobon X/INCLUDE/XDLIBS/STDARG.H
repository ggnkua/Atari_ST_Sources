/*
 * @(#)stdarg.h, XdLibs, SozobonX
 * 
 */

#ifndef _STDARG_H
#define	_STDARG_H

typedef	void	*va_list;

#define va_start(list,param)  list = ((va_list) &(param)) \
				   + ((sizeof(param) + 1) & ~1)
#define va_arg(list,type)     ((type *)(list += ((sizeof(type) + 1) & ~1)))[-1]
#define va_end(list)	      list = ((va_list) 0)

#endif 	/* _STDARG_H	*/
