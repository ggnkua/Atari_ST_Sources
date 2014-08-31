

#include <tos.h>
#include <stdio.h>
#include <time.h>

#include "transprt.h"
#include "resolve.h"


int16  load_cache (void);
int16  is_domain_name (char *name, int16 length);


CACHE  *cache_root = NULL;
int16  cache_num = 0;
char   type[][10] = {  "", "A", "NS", "", "", "CNAME", "SOA", "", "", "", "", 
                       "WKS", "PTR", "HINFO", "", "MX"   };
char   *c_file = "CACHE.DNS";



void  main()

{
   CACHE   *walk, *c_next;
   DNAME   *alias, *d_next;
   uint32  ip;

   load_cache();

   printf ("\r\nNumber of Entries : %d\r\n", cache_num);

   for (walk = cache_root; walk; walk = walk->next) {
        puts ("");
        ip = walk->IP_address;
        printf ("IP %ld.%ld.%ld.%ld :\r\n", (ip>>24)&255, (ip>>16)&255, (ip>>8)&255, ip&255);
        printf ("Real(%d)[%s] : %s\r\n", walk->real.length, type[walk->real.type], walk->real.name);
        printf ("Expiry in %ld sec, last used %ld sec ago.\r\n", walk->real.expiry - time(NULL),
                     time(NULL) - walk->used);
        puts ((walk->alias) ? "Alias List :" : "No Alias.");

        for (alias = walk->alias; alias; alias = alias->next) {
             printf ("   Alias(%d)[%s] : %s\r\n", alias->length, type[alias->type], alias->name);
             printf ("     Expiry in %ld sec.\r\n", walk->real.expiry - time(NULL));
           }
      }

   for (walk = cache_root; walk; walk = c_next) {
        c_next = walk->next;
        for (alias = walk->alias; alias; alias = d_next) {
             d_next = alias->next;
             Mfree (alias->name);   Mfree (alias);
           }
        Mfree (walk->real.name);   Mfree (walk);
      }
 }


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

   c_prev = & cache_root;
   af = 0;
   cache_num = 0;

   do {
        *c_prev = NULL;
        if (af == 1)   break;
        cf = 1;
        if ((c_walk = Malloc (sizeof (CACHE))) == NULL)
             break;
        if (Fread (handle, sizeof (CACHE), c_walk) != sizeof (CACHE)) {
             Mfree (c_walk);
             break;
           }
        if ((n_walk = Malloc (c_walk->real.length + 1)) == NULL) {
             Mfree (c_walk);
             break;
           }
        if (Fread (handle, c_walk->real.length, n_walk) != c_walk->real.length) {
             Mfree (n_walk);
             Mfree (c_walk);
             break;
           }
        *(n_walk + c_walk->real.length) = '\0';
        c_walk->real.name = n_walk;

        if (! is_domain_name (c_walk->real.name, c_walk->real.length)) {
             Mfree (c_walk->real.name);
             Mfree (c_walk);
             break;
           }
        *c_prev = c_walk;   c_prev = & c_walk->next;
        cache_num++;

        for (d_prev = & c_walk->alias, af = 0; *d_prev != NULL;) {
             *d_prev = NULL;
             af = 1;
             if ((d_walk = Malloc (sizeof (DNAME))) == NULL)
                  break;
             if (Fread (handle, sizeof (DNAME), d_walk) != sizeof (DNAME)) {
                  Mfree (d_walk);
                  break;
                }
             if ((n_walk = Malloc (d_walk->length + 1)) == NULL) {
                  Mfree (d_walk);
                  break;
                }
             if (Fread (handle, d_walk->length, n_walk) != d_walk->length) {
                  Mfree (n_walk);
                  Mfree (d_walk);
                  break;
                }
             *(n_walk + d_walk->length) = '\0';
             d_walk->name = n_walk;

             if (! is_domain_name (d_walk->name, d_walk->length)) {
                  Mfree (d_walk->name);
                  Mfree (d_walk);
                  break;
                }
             *d_prev = d_walk;   d_prev = & d_walk->next;
             af = 0;
           }
        cf = 0;
     } while (*c_prev != NULL);

   Fclose (handle);

   return ((cf == 1) ? -1 : 0);
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
