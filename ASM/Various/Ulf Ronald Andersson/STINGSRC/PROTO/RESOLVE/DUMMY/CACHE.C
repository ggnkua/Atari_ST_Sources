
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : DNS Resolver                           */
/*                                                                   */
/*                                                                   */
/*      Version 0.1                         from 9. April 1997       */
/*                                                                   */
/*      Modul zur Handhabung des Cache                               */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "transprt.h"
#include "resolve.h"


void   wait_flag (int16 *semaphore);
void   rel_flag (int16 *semaphore);

int16  load_cache (void);
int16  save_cache (void);
int16  is_domain_name (char *name, int16 length);
void   clean_up (void);
int16  query_name (char *name, char *real, uint32 *IP_list, int16 size, int16 alias_flag);
int16  query_IP (uint32 addr, char *real, uint32 *IP_list, int16 size);
void   update_cache (char *name, uint32 addr, uint32 ttl, int16 type);
int16  compare (char *first, char *second);


extern char  *c_file;

CACHE  *cache_root = NULL;
int16  cache_num = 0, sema_cache = 0;



int16  load_cache()

{
   CACHE  *c_walk, **c_prev;
   DNAME  *d_walk, **d_prev;
   char   *n_walk;
   long   error;
   int    handle, cf, af;

   if ((error = Fopen (c_file, FO_RW)) < 0)
        return (-1);

   handle = (int) error;

   wait_flag (& sema_cache);

   c_prev = & cache_root;
   af = 0;
   cache_num = 0;

   do {
        *c_prev = NULL;
        if (af == 1)   break;
        cf = 1;
        if ((c_walk = KRmalloc (sizeof (CACHE))) == NULL)
             break;
        if (Fread (handle, sizeof (CACHE), c_walk) != sizeof (CACHE)) {
             KRfree (c_walk);
             break;
           }
        if ((n_walk = KRmalloc (c_walk->real.length + 1)) == NULL) {
             KRfree (c_walk);
             break;
           }
        if (Fread (handle, c_walk->real.length, n_walk) != c_walk->real.length) {
             KRfree (n_walk);
             KRfree (c_walk);
             break;
           }
        *(n_walk + c_walk->real.length) = '\0';
        c_walk->real.name = n_walk;

        if (! is_domain_name (c_walk->real.name, c_walk->real.length)) {
             KRfree (c_walk->real.name);
             KRfree (c_walk);
             break;
           }
        *c_prev = c_walk;   c_prev = & c_walk->next;
        cache_num++;

        for (d_prev = & c_walk->alias, af = 0; *d_prev != NULL;) {
             *d_prev = NULL;
             af = 1;
             if ((d_walk = KRmalloc (sizeof (DNAME))) == NULL)
                  break;
             if (Fread (handle, sizeof (DNAME), d_walk) != sizeof (DNAME)) {
                  KRfree (d_walk);
                  break;
                }
             if ((n_walk = KRmalloc (d_walk->length + 1)) == NULL) {
                  KRfree (d_walk);
                  break;
                }
             if (Fread (handle, d_walk->length, n_walk) != d_walk->length) {
                  KRfree (n_walk);
                  KRfree (d_walk);
                  break;
                }
             *(n_walk + d_walk->length) = '\0';
             d_walk->name = n_walk;

             if (! is_domain_name (d_walk->name, d_walk->length)) {
                  KRfree (d_walk->name);
                  KRfree (d_walk);
                  break;
                }
             *d_prev = d_walk;   d_prev = & d_walk->next;
             af = 0;
           }
        cf = 0;
     } while (*c_prev != NULL);

   clean_up();

   rel_flag (& sema_cache);

   Fclose (handle);

   return ((cf == 1) ? -1 : 0);
 }


int16  save_cache()

{
   CACHE  *walk;
   DNAME  *alias;
   long   error;
   int    handle;

   if ((error = Fcreate (c_file, 0)) < 0)
        return (-1);

   handle = (int) error;

   wait_flag (& sema_cache);

   for (walk = cache_root; walk; walk = walk->next) {
        if (Fwrite (handle, sizeof (CACHE), walk) != sizeof (CACHE))
             break;
        if (Fwrite (handle, walk->real.length, walk->real.name) != walk->real.length)
             break;
        for (alias = walk->alias; alias; alias = alias->next) {
             if (Fwrite (handle, sizeof (DNAME), alias) != sizeof (DNAME))
                  break;
             if (Fwrite (handle, alias->length, alias->name) != alias->length)
                  break;
           }
        if (alias)   break;
      }

   rel_flag (& sema_cache);

   Fclose (handle);

   return ((walk != NULL) ? -1 : 0);
 }


int16  is_domain_name (name, length)

char   *name;
int16  length;

{
   int16  count = 0;
   char   next;

   for (;;) {
        if (*name == '\0') {
             return ((count == length) ? TRUE : FALSE);
           }
        if (++count > 255)   return (FALSE);

        if (*name == '.') {
             if ((next = *(name + 1)) != '\0') {
                  if (next < 'A' || ('Z' < next && next < 'a') || 'z' < next)
                       return (FALSE);
                }
           }
          else {
             if (*name != '-') {
                  if (*name < '0' || ('9' < *name && *name < 'A'))
                       return (FALSE);
                  if (('Z' < *name && *name < 'a') || 'z' < *name)
                       return (FALSE);
                }
           }
        name++;
      }
 }


void  clean_up()

{
   CACHE   *c_walk, **c_prev, **crush;
   DNAME   *d_walk, **d_prev, *temp;
   uint32  now, ago;
   int16   max_number;

   now = time (NULL);

   for (c_walk = *(c_prev = & cache_root); c_walk; c_walk = *c_prev) {
        if (c_walk->real.expiry < now) { 
             for (d_walk = c_walk->alias; d_walk; d_walk = temp) {
                  temp = d_walk->next;
                  KRfree (d_walk->name);   KRfree (d_walk);
                }
             *c_prev = c_walk->next;
             --cache_num;
             KRfree (c_walk->real.name);   KRfree (c_walk);
           }
          else {
             for (d_walk = *(d_prev = & c_walk->alias); d_walk; d_walk = *d_prev) {
                  if (d_walk->expiry < now) {
                       *d_prev = d_walk->next;
                       KRfree (d_walk->name);   KRfree (d_walk);
                     }
                    else {
                       d_prev = & d_walk->next;
                     }
                }
             c_prev = & c_walk->next;
           }
      }

   if ((max_number = atoi (getvstr ("DNS_CACHE"))) < 5)
        max_number = 32;

   while (cache_num > max_number) {
        ago = now;
        for (c_walk = *(c_prev = & cache_root); c_walk; c_walk = *c_prev) {
             if (c_walk->used < ago) {
                  crush = c_prev;   ago = c_walk->used;
                }
             c_prev = & c_walk->next;
           }
        c_walk = *crush;
        --cache_num;
        for (d_walk = c_walk->alias; d_walk; d_walk = temp) {
             temp = d_walk->next;
             KRfree (d_walk->name);   KRfree (d_walk);
           }
        *crush = c_walk->next;
        KRfree (c_walk->real.name);   KRfree (c_walk);
      }
 }


int16  query_name (name, real, IP_list, size, alias_flag)

char    *name, *real;
uint32  *IP_list;
int16   size, alias_flag;

{
   CACHE  *walk;
   DNAME  *alias;
   int16  length, count = 0;

   wait_flag (& sema_cache);

   clean_up();
   length = strlen (name);

   for (walk = cache_root; walk; walk = walk->next) {
        if (count >= size)
             break;
        if (walk->real.length == length) {
             if (compare (walk->real.name, name) == 0) {
                  count++;
                  *IP_list++ = walk->IP_address;   strcpy (real, walk->real.name);
                  walk->used = time (NULL);
                }
           }
        if (alias_flag == FALSE)
             continue;
        for (alias = walk->alias; alias; alias = alias->next) {
             if (count >= size)
                  break;
             if (alias->length == length) {
                  if (compare (alias->name, name) == 0) {
                       walk->used = time (NULL);
                       rel_flag (& sema_cache);
                       return (query_name (walk->real.name, real, IP_list, size, FALSE));
                     }
                }
           }
      }

   rel_flag (& sema_cache);

   return (count);
 }


int16  query_IP (addr, real, IP_list, size)

char    *real;
uint32  addr, *IP_list;
int16   size;

{
   CACHE  *walk;
   int16  found = 0;

   wait_flag (& sema_cache);

   clean_up();

   for (walk = cache_root; walk; walk = walk->next) {
        if (walk->IP_address == addr) {
             if (size)
                  *IP_list = addr;
             strcpy (real, walk->real.name);   found = 1;
             walk->used = time (NULL);
             break;
           }
      }

   rel_flag (& sema_cache);

   return (found);
 }


void  update_cache (name, addr, ttl, type)

char    *name;
uint32  addr, ttl;
int16   type;

{
   CACHE   *walk;
   DNAME   *alias;
   uint32  now, expiry;
   int16   length;

   wait_flag (& sema_cache);

   expiry = (now = time (NULL)) + ttl;
   length = strlen (name);

   if (type == DNS_A) {
        for (walk = cache_root; walk; walk = walk->next) {
             if (walk->real.length == length)
                  if (compare (walk->real.name, name) == 0)
                       break;
           }
        if (walk == NULL) {
             if ((walk = KRmalloc (sizeof (CACHE))) == NULL) {
                  rel_flag (& sema_cache);
                  return;
                }
             if ((walk->real.name = KRmalloc (length + 1)) == NULL) {
                  KRfree (walk);
                  rel_flag (& sema_cache);
                  return;
                }
             strcpy (walk->real.name, name);
             walk->real.length = length;
             walk->real.type = type;
             walk->real.next = walk->alias = NULL;
             cache_num++;
             walk->next = cache_root;   cache_root = walk;
           }
        walk->IP_address = addr;
        walk->real.expiry = expiry;
      }
     else {
        for (walk = cache_root; walk; walk = walk->next) {
             if (walk->IP_address == addr) {
                  for (alias = walk->alias; alias; alias = alias->next) {
                       if (alias->length == length)
                            if (compare (alias->name, name) == 0)
                                 break;
                     }
                  if (alias == NULL) {
                       if ((alias = KRmalloc (sizeof (DNAME))) == NULL) {
                            rel_flag (& sema_cache);
                            return;
                          }
                       if ((alias->name = KRmalloc (length + 1)) == NULL) {
                            KRfree (alias);
                            rel_flag (& sema_cache);
                            return;
                          }
                       strcpy (alias->name, name);
                       alias->length = length;   alias->type = type;
                       alias->expiry = expiry;
                       alias->next = walk->alias;   walk->alias = alias;
                     }
                  break;
                }
           }
      }
   walk->used = now;

   clean_up();

   rel_flag (& sema_cache);

   if (strcmp (getvstr ("DNS_SAVE"), "1") == 0 || strcmp (getvstr ("DNS_SAVE"), "TRUE") == 0)
        save_cache();
 }


int16  compare (first, second)

char  *first, *second;

{
   char  one, two;

   while (*first != '\0' && *second != '\0') {
        one = *first++;
        two = *second++;
        if (one >= 'a' && one <= 'z')   one -= 'a' - 'A';
        if (two >= 'a' && two <= 'z')   two -= 'a' - 'A';
        if (one != two)   return (1);
      }

   return (0);
 }
