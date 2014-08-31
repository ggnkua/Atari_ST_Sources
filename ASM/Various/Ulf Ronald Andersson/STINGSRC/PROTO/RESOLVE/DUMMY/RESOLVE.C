
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : DNS Resolver                           */
/*                                                                   */
/*                                                                   */
/*      Version 0.3                         from 4. March 1997       */
/*                                                                   */
/*      Modul zur Installation und API                               */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "transprt.h"
#include "layer.h"


#define  M_YEAR    17
#define  M_MONTH   4
#define  M_DAY     9


void          _appl_yield (void);

int16         load_cache (void);
int16         save_cache (void);
int16         query_name (char *name, char *real, uint32 *IP_list, int16 size, int16 alias_flag);
int16         query_IP (uint32 addr, char *real, uint32 *IP_list, int16 size);
void          update_cache (char *name, uint32 addr, uint32 ttl, int16 type);

long          get_sting_cookie (void);
int16         install (void);
int16  cdecl  my_resolve (char *domain, char **real_domain, uint32 *IP_list, int16 size);
int16         is_IP_addr (char *text);


DRV_LIST  *sting_drivers;
TPL       *tpl;
STX       *stx;
LAYER     my_layer = {  "Resolver", "00.10", 0L, (M_YEAR << 9) | (M_MONTH << 5) | M_DAY, 
                        "Unknown Programmer", 0, NULL   };
char      fault[] = "RESOLVE.STX : STinG extension module. Only to be started by STinG !\r\n";
char      *c_file;



void  main (argc, argv)

int   argc;
char  *argv[];

{
   if (argc != 2) {
        Cconws (fault);   return;
      }
   if (strcmp (argv[1], "STinG_Load") != 0) {
        Cconws (fault);   return;
      }

   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L)   return;

   if (strcmp (sting_drivers->magic, MAGIC) != 0)
        return;

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        if (install())
             Ptermres (_PgmSize, 0);
      }
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


int16  install()

{
   LAYER  *layers;
   int16  path_len;

   if ((c_file = KRmalloc (256)) == NULL)
        return (FALSE);

   Dgetpath (c_file, 0);
   path_len = (int16) strlen (c_file);
   KRfree (c_file);

   if ((c_file = KRmalloc (path_len + 15)) == NULL)
        return (FALSE);

   c_file[0] = 'A' + Dgetdrv();   c_file[1] = ':';
   Dgetpath (& c_file[2], 0);
   strcat (c_file, "\\CACHE.DNS");

   load_cache();

   query_chains (NULL, NULL, (void **) & layers);

   while (layers->next)
        layers = layers->next;

   layers->next = & my_layer;

   tpl->resolve = my_resolve;

   return (TRUE);
 }


int16  cdecl  my_resolve (domain, real_domain, IP_list, size)

char    *domain, **real_domain;
uint32  *IP_list;
int16   size;

{
   uint32  ip_a, ip_b, ip_c, ip_d, host;
   int16   result;
   char    *work, *dom, *dom_name;

   if (strcmp (domain, "#|--==>Save Cache<==--|#") == 0) {
        if (save_cache())
             return (E_NOMEM);
          else
             return (E_NORMAL);
      }

   if ((dom_name = KRmalloc (256L)) == NULL)
        return (E_NOMEM);

   if ((dom = KRmalloc (256L)) == NULL) {
        KRfree (dom_name);
        return (E_NOMEM);
      }

   if (is_IP_addr (domain)) {
        work = domain;
        ip_a = (uint32) atoi (work);   work = strchr (work, '.') + 1;
        ip_b = (uint32) atoi (work);   work = strchr (work, '.') + 1;
        ip_c = (uint32) atoi (work);   work = strchr (work, '.') + 1;
        ip_d = (uint32) atoi (work);
        host = (ip_a << 24) | (ip_b << 16) | (ip_c << 8) | ip_d;

        if ((result = query_IP (host, dom_name, IP_list, size)) > 0) {
             if (real_domain)
                  KRrealloc (*real_domain = dom_name, strlen (dom_name));
               else
                  KRfree (dom_name);
             KRfree (dom);
             return (result);
           }

        sprintf (dom, "%ld.%ld.%ld.%ld.IN-ADDR.ARPA", ip_d, ip_c, ip_b, ip_a);

        /* no entry in cache, do kludge here */

        strcpy (dom_name, dom);
        if (size >= 1)
             *IP_list = host;
        if (real_domain)
             KRrealloc (*real_domain = dom_name, strlen (dom_name));
          else
             KRfree (dom_name);
        KRfree (dom);
        return ((size >= 1) ? 1 : 0);
      }
     else {
        strcpy (dom, domain);

        if (strchr (domain, '.') == NULL) {
             work = getvstr ("DOMAIN");
             if (work[1]) {
                  strcat (dom, ".");   strcat (dom, work);
                }
           }

        if ((result = query_name (dom, dom_name, IP_list, size, TRUE)) > 0) {
             if (real_domain)
                  KRrealloc (*real_domain = dom_name, strlen (dom_name));
               else
                  KRfree (dom_name);
             KRfree (dom);
             return (result);
           }

        /* no entry in cache */

        KRfree (dom_name);
        KRfree (dom);

        return (E_CANTRESOLVE);
      }
 }


int16  is_IP_addr (text)

char  *text;

{
   int16  count, length, dots;
   char   chr;

   length = strlen (text);

   for (count = dots = 0; count < length; count++) {
        chr = text[count];
        if (chr == ' ' || ('0' <= chr && chr <= '9') || chr == '.') {
             if (chr == '.')   dots++;
           }
          else
             return (FALSE);
      }

   return ((dots != 3) ? FALSE : TRUE);
 }
