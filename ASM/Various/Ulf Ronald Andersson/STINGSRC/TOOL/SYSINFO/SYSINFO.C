
/*********************************************************************/
/*                                                                   */
/*     STinG : List System Info Tool                                 */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                       from 18. October 1997      */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"
#include "layer.h"


#define  CFG_NUM    100


typedef  struct config {
    uint32     client_ip;       /* IP address of local machine (obsolete)   */
    uint16     ttl;             /* Default TTL for normal packets           */
    char       *cv[CFG_NUM+1];  /* Space for config variables               */
    int16      max_num_ports;   /* Maximum number of ports supported        */
    uint32     received_data;   /* Counter for data being received          */
    uint32     sent_data;       /* Counter for data being sent              */
    int16      active;          /* Flag for polling being active            */
    int16      thread_rate;     /* Time between subsequent thread calls     */
    int16      frag_ttl;        /* Time To Live for reassembly resources    */
    PORT       *ports;          /* Pointer to first entry in PORT chain     */
    DRIVER     *drivers;        /* Pointer to first entry in DRIVER chain   */
    LAYER      *layers;         /* Pointer to first entry in LAYER chain    */
    void       *interupt;       /* List of application interupt handlers    */    
    void       *icmp;           /* List of application ICMP handlers        */    
    int32      stat_all;        /* All datagrams that pass are counted here */
    int32      stat_lo_mem;     /* Dropped due to low memory                */
    int32      stat_ttl_excd;   /* Dropped due to Time-To-Live exceeded     */
    int32      stat_chksum;     /* Dropped due to failed checksum test      */
    int32      stat_unreach;    /* Dropped due to no way to deliver it      */
 } CONFIG;


long  get_sting_cookie (void);
void  do_some_work (void);


DRV_LIST    *sting_drivers;
TPL         *tpl;
STX         *stx;
CONFIG      *config;

char  port_type[][30] = { "None",
                   "Serial Point to Point Link  ", "Parallel Point to Point Link",
                   "Serial Bus Type Link        ", "Parallel Bus Type Link      ",
                   "Serial Ring Type Link       ", "Parallel Ring Type Link     ",
                   "IP Masquerade Pseudo Port   "
              };
char  not_there[] = "STinG is not loaded or enabled !";
char  corrupted[] = "STinG structures corrupted !";



void main (argc, argv)

int   argc;
char  *argv[];

{
   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L) {
        puts (not_there);
        return;
      }
   if (strcmp (sting_drivers->magic, MAGIC) != 0) {
        puts (corrupted);
        return;
      }

   config = (CONFIG *) sting_drivers->cfg;

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL)
        do_some_work();

   if (argc > 1)
        argv[1][0] = getchar();
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


void  do_some_work()

{
   DRIVER  *driv;
   PORT    *port;
   LAYER   *layr;
   int     num_drivers = 0, num_ports = 0, num_layers = 0;

   puts ("\r\n   *** STinG TCP/IP InterNet Connection Layer ***");
   puts ("   ----------------------------------------------");
   printf ("Transport Driver V%s by %s.\r\n", tpl->version, tpl->author);
   printf ("Module Driver    V%s by %s.\r\n", stx->version, stx->author);

   for (driv = config->drivers; driv; driv = driv->next)
        num_drivers++;
   for (port = config->ports;   port; port = port->next)
        num_ports++;
   for (layr = config->layers;  layr; layr = layr->next)
        num_layers++;

   printf ("Basepage address :  (BASPAG *) 0x%lxL\r\n", sting_drivers->sting_basepage);

   printf ("Loaded :  %d drivers comprising %d ports, %d high level protocols.\r\n\n",
           num_drivers, num_ports, num_layers);

   puts ("Dropped packets statistics:");
   printf ("          Low memory : %8ld\r\n", config->stat_lo_mem);
   printf ("        TTL exceeded : %8ld\r\n", config->stat_ttl_excd);
   printf ("      Wrong checksum : %8ld\r\n", config->stat_chksum);
   printf ("       Undeliverable : %8ld\r\n", config->stat_unreach);
   printf ("Total datagrams : %ld\r\n", config->stat_all);

   puts ("\n   --- Drivers & Ports ---\n");

   for (driv = config->drivers; driv; driv = driv->next) {
        num_ports = 0;
        for (port = config->ports; port; port = port->next) {
             if (port->driver == driv)
                  num_ports++;
           }
        printf ("Driver \"%s\" (%d port%s)\r\n", driv->name, num_ports, (num_ports > 1) ? "s" : "");
        printf ("  Version %s, %d/%d/%d by %s\r\n", driv->version,
                      driv->date & 0x1f, (driv->date >> 5) & 0xf, 80 +((driv->date >> 9) & 0x7f), 
                      driv->author);
        printf ("  Basepage address : (BASPAG *) 0x%lxL\r\n", driv->basepage);
        for (port = config->ports; port; port = port->next) {
             if (port->driver == driv) {
                  printf ("Port \"%s\" (%sctive)\r\n", port->name, (port->active) ? "A" : "Ina");
                  printf ("  Type : %s\r\n", port_type[port->type]);
                  printf ("  IP-Address : %ld.%ld.%ld.%ld,", (port->ip_addr>>24) & 0xff,
                        (port->ip_addr>>16) & 0xff, (port->ip_addr>>8) & 0xff, port->ip_addr & 0xff);
                  printf ("  MTU : %d  (%d maximum)\r\n", port->mtu, port->max_mtu);
                  printf ("  Statistics : %ld bytes sent, %ld bytes received, %d packets dropped\r\n",
                         port->stat_sd_data, port->stat_rcv_data, port->stat_dropped);
                }
           }
        puts ("");
      }

   puts ("   --- High Level Protocols ---\n");

   for (layr = config->layers; layr; layr = layr->next) {
        printf ("Protocol \"%s\"\r\n", layr->name);
        printf ("  Version %s, %d/%d/%d by %s\r\n", layr->version,
                      layr->date & 0x1f, (layr->date >> 5) & 0xf, 80 +((layr->date >> 9) & 0x7f), 
                      layr->author);
        printf ("  Basepage address : (BASPAG *) 0x%lxL\r\n", layr->basepage);
        printf ("  Statistics : %d datagrams dropped\r\n", layr->stat_dropped);
        puts ("");
      }

   puts ("STinG Sysinfo finished ...\n");
 }
