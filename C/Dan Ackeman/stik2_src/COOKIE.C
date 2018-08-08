/* Cookie.C
 *
 */

#include "lattice.h"
#include <stdlib.h>
#include <tos.h>
#include "cookie.h"
#include "krmalloc.h"
#include <stdio.h>
#ifndef NULL
#define NULL (void *)0L
#endif
#define _cookiejar	*(long *)0x5A0L

COOKIE *new_cookiejar(long n)
{
  register COOKIE *jar,*newjar;
  register long i,c;

  jar = get_cookiejar();
  i=0;
  if(jar) for(; jar[i].id != ENDCOOKIE; i++);  /* get size of old jar */
  if(jar && jar[i].val > n) return(jar);  /* there isroom in jar */

  newjar = (COOKIE *)STiKmalloc(n*sizeof(COOKIE));/* alloc new jar */
  
  if(jar && newjar) for(c=0; c<i; c++)
  {  /* copy old jar */
    newjar[c].id = jar[c].id;
    newjar[c].val = jar[c].val;
  }
  newjar[i].id = ENDCOOKIE;  /* terminate new jar */
  newjar[i].val = n;
  _cookiejar = (long)newjar;  /* install new jar */

  return(newjar);
}

COOKIE *get_cookiejar(void)
{
  register long cookieaddress;
  
  cookieaddress = _cookiejar;  /* return address of cookiejar */
  return (COOKIE *)cookieaddress;
}

COOKIE *add_cookie(long id,long val)
{
  register COOKIE *jar;

  if((jar = new_cookiejar(8L))==NULL) 
  		return(NULL);

  while(jar->id != ENDCOOKIE)
	jar++;  /* search end of cookiejar */

  jar->id = id;
  (jar+1)->val = jar->val;  /* keep size of jar */
  jar->val = val;
  (jar+1)->id = ENDCOOKIE;

  return(jar);
}


COOKIE *get_cookie(long id)
{
  register COOKIE *jar;

  if((jar = get_cookiejar()) == NULL)
  	return(NULL);

  while(jar->id)
  {
    if(jar->id == id)
    	return(jar);  /* find cookie */
    	
    jar++;
  }
  
  return(NULL);
}

