
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                         from 23. Maerz 1997      */
/*                                                                   */
/*      Module for Setup and Memory Allocation calls                 */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "globdefs.h"


typedef  struct mem_header {
           struct mem_header  *mem_ptr;
           uint32             size;
     } MEM_HDR;


char *  cdecl  getvstr (char name[]);

void           install_timer (void);
uint16         lock_exec (uint16 status);

void           init_ip (void);
void           init_ports (void);

void           install (void);
int32   cdecl  set_sysvars (int16 new_act, int16 new_frac);
void    cdecl  query_chains (PORT **port, DRIVER **drv, LAYER **layer);
char *  cdecl  get_error_text (int16 error_code);
int16          KRinitialize (int32 size);
void *  cdecl  KRmalloc (int32 size);
void    cdecl  KRfree (void *mem_block);
int32   cdecl  KRgetfree (int16 block_flag);
void *  cdecl  KRrealloc (void *mem_block, int32 new_size);


extern CONFIG  conf;
extern LAYER   icmp_desc;
extern void    *cn_array[];
extern int16   active, fraction;

char  *error_array[] = {
              "No error.", "Can't send, output buffer is full.", "No data available.", 
              "EOF received from a remote host.", "RESET received from a remote host.", 
              "Unacceptable packet, sending RESET.", "No more memory available.", 
              "Connection refused by remote host.", "TCP received SYN in window.", 
              "Bad connection handle used.", "The connection is in LISTEN state.", 
              "No free CCBs available.", "A packet matches no connection.", 
              "Failure to connect to remote port.", "Invalid TCP_close() requested.", 
              "User timeout expired.", "Connection timed out.", "DNS query, "
              "can't resolve hostname.", "Bad format in domain name / dotted quad.", 
              "Modem lost carrier signal.", "Hostname does not exist.", 
              "Resolver reached work limit.", "No nameserver found for query.", 
              "DNS query, bad format received.", "Destination host is unreachable.", 
              "No address records found for hostname.", "Routine is unavailable.", 
              "Locked by another application.", "Error during fragmentation.", 
              "Time To Live exceeded, discarded.", "Problem with a parameter.", 
              "Input buffer is too small for data."
     };

MEM_HDR  *memory = NULL, *mem_free;



void  install()

{
   PORT  *walk;
   char  *var;
   int   count, number;

   conf.client_ip = LOOPBACK;
   conf.max_num_ports = conf.active = 0;
   conf.thread_rate = 10;
   conf.ports = (void *) conf.drivers = NULL;
   conf.ttl = 64;
   conf.frag_ttl = 60;
   conf.interupt = NULL;
   conf.stat_lo_mem = conf.stat_ttl_excd = 0L;
   conf.stat_chksum = conf.stat_unreach  = 0L;
   conf.stat_all    = 0L;
   conf.memory      = (void *) memory;

   init_ports();
   init_ip();
   install_timer();

   var = getvstr ("THREADING");
   if (* var != '0' || strlen (var) != 1) {
        number = atoi (var) / 5;
        conf.thread_rate = fraction = (number < 2) ? 2 : ((number > 199) ? 199 : number);
      }
   var = getvstr ("FRAG_TTL");
   if (* var != '0' || strlen (var) != 1) {
        number = atoi (var);
        conf.frag_ttl = (number < 5) ? 5 : number;
      }

   var = getvstr ("ICMP_GMT");
   if (* var != '0' || strlen (var) != 1) {
        number = atoi (var);
        icmp_desc.flags &= 0x0000fffful;   icmp_desc.flags |= (int32) number << 16;
      }
   var = getvstr ("ICMP_AD");
   if (* var != '0' || strlen (var) != 1) {
        number = atoi (var);
        icmp_desc.flags &= 0xffff00fful;   icmp_desc.flags |= (uint32) number << 8;
      }
   var = getvstr ("ICMP_FLAG");
   if (* var != '0' || strlen (var) != 1) {
        number = atoi (var);
        icmp_desc.flags &= 0xffffff00ul;   icmp_desc.flags |= (uint32) number;
      }
   icmp_desc.basepage = _BasPag;
   conf.layers = & icmp_desc;

   for (walk = conf.ports; walk != NULL; walk = walk->next)
        conf.max_num_ports++;

   for (number = 0; number < MAX_HANDLE; number++)
        cn_array[number] = NULL;
 }


int32  cdecl  set_sysvars (new_active, new_fraction)

int16  new_active, new_fraction;

{
   long  old_values;

   old_values = ((int32) active << 16) | fraction;

   if (new_active != -1)
        conf.active = active = new_active;

   if (new_fraction != -1)
        conf.thread_rate = fraction = new_fraction;

   return (old_values);
 }


void  cdecl  query_chains (port_ptr, drv_ptr, layer_ptr)

PORT    **port_ptr;
DRIVER  **drv_ptr;
LAYER   **layer_ptr;

{
   if (port_ptr)    *port_ptr  = conf.ports;
   if (drv_ptr)     *drv_ptr   = conf.drivers;
   if (layer_ptr)   *layer_ptr = conf.layers;
 }


char *  cdecl  get_error_text (error_code)

int16  error_code;

{
   error_code *= -1;

   if (error_code < 0 || E_LASTERROR < error_code)
        return ("");

   return (error_array[error_code]);
 }


int16  KRinitialize (size)

int32  size;

{
   size = (size + sizeof (MEM_HDR) - 1) / sizeof (MEM_HDR);

   if ((memory = (MEM_HDR *) Malloc (size * sizeof (MEM_HDR))) == NULL)
        return (-1);

   memory->mem_ptr = mem_free = memory;
   memory->size = size;

   return (0);
 }


void *  cdecl  KRmalloc (size)

int32  size;

{
   MEM_HDR  *prev, *run;
   uint32   n_units;
   uint16   status;

   if (mem_free == NULL)   return (NULL);

   n_units = (size + sizeof (MEM_HDR) - 1) / sizeof (MEM_HDR) + 1;

   status = lock_exec (0);

   for (run = (prev = mem_free)->mem_ptr; ; run = run->mem_ptr) {
        if (run->size >= n_units) {
             if (run->size == n_units)
                  prev->mem_ptr = run->mem_ptr;
               else {
                  run->size -= n_units;
                  run       += run->size;
                  run->size  = n_units;
                }
             run->mem_ptr = (MEM_HDR *) 'STiM';
             mem_free = (prev != run) ? prev : NULL;
             lock_exec (status);
             return ((void *) (run + 1));
           }
        if ((prev = run) == mem_free)   break;
      }

   lock_exec (status);

   return (NULL);
 }


void  cdecl  KRfree (mem_block)

void  *mem_block;

{
   MEM_HDR  *blk, *run;
   uint16   status;

   if (mem_block == NULL)
        return;

   blk = (MEM_HDR *) mem_block - 1;

   if (blk->mem_ptr != (MEM_HDR *) 'STiM')
        return;

   status = lock_exec (0);

   if (mem_free == NULL) {
        blk->mem_ptr = mem_free = blk;   lock_exec (status);
        return;
      }

   for (run = mem_free; ! (blk > run && blk < run->mem_ptr); run = run->mem_ptr)
        if (run >= run->mem_ptr && (blk > run || blk < run->mem_ptr))
             break;

   if (blk + blk->size == run->mem_ptr) {
        blk->size += run->mem_ptr->size;
        blk->mem_ptr = run->mem_ptr->mem_ptr;
      }
     else
        blk->mem_ptr = run->mem_ptr;

   if (run + run->size == blk) {
        run->size += blk->size;
        run->mem_ptr = blk->mem_ptr;
      }
     else
        run->mem_ptr = blk;

   mem_free = run;

   lock_exec (status);
 }


int32  cdecl  KRgetfree (block_flag)

int16  block_flag;

{
   MEM_HDR  *run;
   uint32   total, largest;
   uint16   status;

   if (mem_free == NULL)
        return (0L);

   status = lock_exec (0);

   total = largest = mem_free->size - 1;

   for (run = mem_free->mem_ptr; run != mem_free; run = run->mem_ptr) {
        total += run->size - 1;
        if (largest < run->size - 1)   largest = run->size - 1;
      }

   lock_exec (status);

   return (((block_flag) ? largest : total) * sizeof (MEM_HDR));
 }


void *  cdecl  KRrealloc (mem_block, new_size)

void   *mem_block;
int32  new_size;

{
   MEM_HDR  *blk;
   uint32   n_units, count;
   char     *wrk, *run, *new_block;

   if (mem_block == NULL && new_size == 0)
        return (NULL);

   if (new_size == 0) {
        KRfree (mem_block);
        return (NULL);
      }

   if (mem_block == NULL) {
        if ((new_block = KRmalloc (new_size)) == NULL)
             return (NULL);
        for (run = new_block; new_size > 0; run++, --new_size)
             *run = '\0';
        return (new_block);
      }

   blk = (MEM_HDR *) mem_block - 1;

   if (blk->mem_ptr != (MEM_HDR *) 'STiM')
        return (NULL);

   n_units = (new_size + sizeof (MEM_HDR) - 1) / sizeof (MEM_HDR) + 1;

   if (n_units > blk->size) {
        if ((new_block = KRmalloc (new_size)) == NULL)
             return (NULL);
        count =  (blk->size - 1) * sizeof (MEM_HDR);
        new_size = (n_units - 1) * sizeof (MEM_HDR);
        for (run = new_block, wrk = mem_block; count > 0; --count, --new_size)
             *run++ = *wrk++;
        for (; new_size > 0; --new_size)
             *run++ = '\0';
        KRfree (mem_block);   return (new_block);
      }

   if (n_units < blk->size) {
        n_units = blk->size - n_units;   blk->size -= n_units;
        blk += blk->size;
        blk->size = n_units;   blk->mem_ptr = (MEM_HDR *) 'STiM';
        KRfree (blk + 1);
      }

   return (mem_block);
 }
