/*  COOKIE.C
 *  Cookie-Routinen
 *
 *  aus: GEM Sound
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  Erstellt mit Pure C
 */

#include <stdio.h>
#include <tos.h>
#include "sounds.h"

int get_cookie(unsigned long cookie,unsigned long *value)
{
    long old_stack;
    long *jar;
    
    old_stack=Super(0L);
    jar=*((long **)0x5a0L);
    Super((void *) old_stack);
    
    if(!jar) return(FALSE);
    do
    {
        if(*jar==cookie)
        {
            if(value) *value=jar[1];
            return(TRUE);
        }
        else
            jar= &(jar[2]);
    }while(jar[0]);
    return(FALSE);
} /* get_cookie */

int make_cookie(unsigned long cookie,unsigned long value)
{
    long old_stack;
    long nr,new;
    long *jar,*ajar,*njar;
        
    old_stack=Super(0L);
    jar=*((long **)0x5a0L);
    Super((void *) old_stack);
    ajar=jar;
    for(nr=0;jar[0];nr++,jar=&(jar[2]));
    if(nr<jar[1])
    {
        jar[2]=jar[0];
        jar[3]=jar[1];
        
        jar[0]=cookie;
        jar[1]=value;
        return(TRUE);
    }
    new=nr+20;
    jar=njar=Malloc((new+2L)*8L);
    if(njar==NULL)  return(FALSE);
    do
    {
        jar[0]=ajar[0];
        jar[1]=ajar[1];
        jar=&(jar[2]);
        ajar=&(ajar[2]);
    } while(ajar[0]);
    jar[0]=cookie;
    jar[1]=value;
    jar[2]=0L;
    jar[3]=new;
    old_stack=Super(0L);
    jar=(long *)0x5a0L;
    *jar=(long) njar;
    Super((void *) old_stack);
    return(TRUE);
} /* make_cookie */
