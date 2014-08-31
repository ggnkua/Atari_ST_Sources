
/*********************************************************************/
/*                                                                   */
/*     STinG : Shutdown Tool                                         */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                      from 15. December 1997      */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"
#include "layer.h"


#define  CFG_NUM     100


typedef  struct config {
    uint32  client_ip;           /* IP address of local machine           */
    uint16  ttl;                 /* Default TTL for normal packets        */
    char    *cv[CFG_NUM+1];      /* Space for config variables            */
    int16   max_num_ports;       /* Maximum number of ports supported     */
    uint32  data_count[2];       /* Counter for received and sent data    */
    int16   vars[3];             /* Various internal variables            */
    void    *lists_chains[5];    /* Various lists and chains              */
    int32   statistics[5];       /* Statistics counters                   */
    void    *memory;             /* Pointer to main memory for KRcalls    */
    int16   new_cookie;          /* Flag indicating new jar               */
 } CONFIG;


long  unlink_vectors (void);
void  disable_interrupts (void);
void  enable_interrupts (void);

long  get_sting_cookie (void);
void  ports_off (void);
long  remove_mem (void);
long  destroy_sting_cookie (void);


DRV_LIST    *sting_drivers;
TPL         *tpl;
STX         *stx;

char  not_there[] = "\033ESTinG is not loaded or enabled !";
char  corrupted[] = "\033ESTinG structures corrupted !";
char  link_fail[] = "\033ESTinG exception vectors not linked !";



void main()

{
   appl_init();

   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L) {
        puts (not_there);
        return;
      }
   if (strcmp (sting_drivers->magic, MAGIC) != 0) {
        puts (corrupted);
        return;
      }

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        ports_off();
        if (Supexec (unlink_vectors) != 0L)
             puts (link_fail);
        Supexec (destroy_sting_cookie);
        Supexec (remove_mem);
      }

   appl_exit();
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


void  ports_off()

{
   PORT  *port;
   int   flag = FALSE;

   query_chains ((void **) & port, NULL, NULL);

   while (port) {
        if (query_port (port->name) == TRUE) {
             flag = TRUE;
             off_port (port->name);
           }
        port = port->next;
      }

   if (flag)
        evnt_timer (3000, 0);

   set_sysvars (FALSE, 10);
 }


long  remove_mem()

{
   DRIVER    *driver, *next_driver;
   LAYER     *layer, *next_layer;
   BASPAG    *sting, **process, *old_proc;
   CONFIG    *conf;
   OSHEADER  *oshdr = * (OSHEADER **) 0x4f2L;

   disable_interrupts();

   if (oshdr->os_version >= 0x0102)
        process = oshdr->p_run;
     else
        process = (BASPAG **) (((oshdr->os_conf >> 1) == 4) ? 0x873cL : 0x602cL);

   old_proc = *process;

   query_chains (NULL, (void **) & driver, (void **) & layer);

   sting = (BASPAG *) sting_drivers->sting_basepage;
   conf  = (CONFIG *) sting_drivers->cfg;

   *process = sting;

   while (driver) {
        next_driver = driver->next;
        if (driver->basepage != sting) {
             Mfree (driver->basepage->p_env);   Mfree (driver->basepage);
           }
        driver = next_driver;
      }

   while (layer) {
        next_layer = layer->next;
        if (layer->basepage != sting) {
             Mfree (layer->basepage->p_env);   Mfree (layer->basepage);
           }
        layer = next_layer;
      }

   Mfree (conf->memory);

   if (! conf->new_cookie) {
        *process = sting->p_parent;
        Mfree (sting->p_env);   Mfree (sting);
      }

   *process = old_proc;

   enable_interrupts();

   return (0L);
 }


long  destroy_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK') {
             do {
                  work[0] = work[2];   work[1] = work[3];
                  work += 2;
               } while (work[0] != 0L);
             break;
           }

   return (0L);
 }
