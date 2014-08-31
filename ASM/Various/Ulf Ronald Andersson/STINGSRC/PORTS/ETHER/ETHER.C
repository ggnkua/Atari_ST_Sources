
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : EtherNet Network Interface                   */
/*                                                                   */
/*                                                                   */
/*      Version 0.1                        vom 26. Januar 1998       */
/*                                                                   */
/*      Modul zur Installation und Aktivierung der Ports             */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "ether.h"


#define  M_YEAR    18
#define  M_MONTH   6
#define  M_DAY     18


int16          xmit_dgram (IP_DGRAM *dgram, BAB *txbab);
int16          fetch_dgram (IP_DGRAM **dgram);
void           recve_dgram (BAB *rxbab);
void           deplete_queue (IP_DGRAM **queue);
void           arp_init (void);

long           check_hardware (void);
long           cache_on (void);
long           cache_off (void);
int            bus_error (void);
long           berr_off (void);

int            get_cookie (long which, long *value);
long           read_cookie (void);
void           install (void);
void    cdecl  my_send (PORT *port);
void    cdecl  my_receive (PORT *port);
int16   cdecl  my_set_state (PORT *port, int16 state);
long           create_lance_structs (void);
long           check_start (void);
long           finish_start (void);
long           stop_lance (void);
int16   cdecl  my_cntrl (PORT *port, uint32 argument, int16 code);
int            fetch_addresses (int type);


DRV_LIST  *sting_drivers;
TPL       *tpl;
STX       *stx;
PORT      my_port   = {  "EtherNet", L_SER_BUS, FALSE, 0L, 0xffffffffUL, 0xffffffffUL,
                         1500, 1500, 0L, NULL, 0L, NULL, 0, NULL, NULL  };
DRIVER    my_driver = {  my_set_state, my_cntrl, my_send, my_receive, "EtherNet", "00.20",
                         (M_YEAR << 9) | (M_MONTH << 5) | M_DAY, "Peter Rottengatter",
                         NULL, NULL   };
TMD       *tmd_array;
RMD       *rmd_array;
BAB       xmit_bab[8], *this_xmit, recve_bab[32], *this_recve;
long      cookie, _cpu;
uint8     address[6];
uint16    *rdp, *rap, ck_flag, gtype;
void      *memory = NULL;
char      *hardware[6];
char      fault[] = "ETHER.STX : STinG extension module. Only to be started by STinG !\r\n";



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

   if (! get_cookie ('STiK', (long *) & sting_drivers))
        return;

   if (sting_drivers == 0L)   return;

   if (strcmp (sting_drivers->magic, MAGIC) != 0)
        return;

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        install();
        Ptermres (_PgmSize, 0);
      }
 }


int  get_cookie (which, value)

long  which, *value;

{
   cookie = which;
   *value = Supexec (read_cookie);

   return (ck_flag);
 }


long  read_cookie()

{
   long  *work;

   ck_flag = FALSE;

   if (* (long **) 0x5a0L == NULL)
        return (0L);

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == cookie) {
             ck_flag = TRUE;   return (*++work);
           }

   return (-1L);
 }


void  install()

{
   PORT    *ports;
   DRIVER  *driver;

   if (! get_cookie ('_CPU', & _cpu))
        _cpu = 0;
   _cpu = (_cpu >= 20) ? 1 : 0;

   query_chains ((void **) & ports, (void **) & driver, NULL);

   (my_port.driver = & my_driver)->basepage = _BasPag;

   while (ports->next)
        ports = ports->next;

   ports->next = & my_port;

   while (driver->next)
        driver = driver->next;

   driver->next = & my_driver;

   hardware[0] = "PAMs EMega";   hardware[1] = "PAMs VME";
   hardware[2] = "Riebl Mega";   hardware[3] = "Riebl Mega (Mod.)";   hardware[4] = "Riebl VME";
   hardware[5] =  NULL;
 }


void  cdecl  my_send (port)

PORT  *port;

{
   IP_DGRAM  *dgram;

   if (port != & my_port || my_port.active == 0)
        return;

   cache_off();

   while ((this_xmit->buffer.xmit_buff->status & DS_OWN) == 0) {
        if (fetch_dgram (& dgram) == FALSE)
             return;
        if (! xmit_dgram (dgram, this_xmit))
             continue;
        *rdp = CSR0_TDMD;
        this_xmit = this_xmit->next_bab;
      }

   cache_on();
 }


void  cdecl  my_receive (port)

PORT  *port;

{
   if (port != & my_port || my_port.active == 0)
        return;

   cache_off();

   while ((this_recve->buffer.recve_buff->status & DS_OWN) == 0) {
        recve_dgram (this_recve);
        this_recve = this_recve->next_bab;
      }

   cache_on();
 }


int16  cdecl  my_set_state (port, state)

PORT   *port;
int16  state;

{
   int32  now;

   if (port != & my_port)   return (FALSE);

   if (state) {
        if (Supexec (check_hardware) == FALSE)
             return (FALSE);
        Supexec (cache_off);
        Supexec (create_lance_structs);
        now = TIMER_now();
        while (TIMER_elapsed (now) < 500 && Supexec (check_start) == 0);
        now = Supexec (finish_start);
        Supexec (cache_on);
        if (now == FALSE)   return (FALSE);
        arp_init();
      }
     else {
        Supexec (cache_off);
        Supexec (stop_lance);
        Supexec (cache_on);
        deplete_queue (& my_port.send);
        deplete_queue (& my_port.receive);
      }

   return (TRUE);
 }


long  create_lance_structs()

{
   LANCE_INIT  *init;
   TMD         *twalk;
   RMD         *rwalk;
   uint8       *buffer;
   int16       count, length;

   init = (LANCE_INIT *) memory;
   tmd_array = (TMD *) (((long) (init + 1)     + 7) & 0xfffffff8ul);
   rmd_array = (RMD *) (((long) & tmd_array[8] + 7) & 0xfffffff8ul);
   buffer = (uint8 *) & rmd_array[32];

   length = 1536;

   *rap = 0;   *rdp = CSR0_STOP;

   for (count = 0, rwalk = rmd_array; count < 32; count++, rwalk++) {
        rwalk->addr_high = 0;
        rwalk->addr_low = (uint16) ((long) buffer & 0xffffL);
        rwalk->status = DS_STP | DS_ENP | DS_OWN;
        rwalk->ones = 0xf;  rwalk->bcount = - length;  rwalk->zeros = 0;  rwalk->mcount = 0;
        recve_bab[count].buffer.recve_buff = rwalk;
        recve_bab[count].data = (ETH_HDR *) buffer;
        recve_bab[count].next_bab = & recve_bab[(count < 31) ? count + 1 : 0];
        buffer += length;
      }
   this_recve = & recve_bab[0];

   for (count = 0, twalk = tmd_array; count < 8; count++, twalk++) {
        twalk->addr_high = 0;
        twalk->addr_low = (uint16) ((long) buffer & 0xffffL);
        twalk->status = DS_STP | DS_ENP;
        twalk->ones = 0xf;   twalk->bcount = 0;
        twalk->buffer = twalk->uflow = twalk->reserv = twalk->lcoll = twalk->lcar = FALSE;
        twalk->tdr = 0;   twalk->retry = FALSE;
        xmit_bab[count].buffer.xmit_buff = twalk;
        xmit_bab[count].data = (ETH_HDR *) buffer;
        xmit_bab[count].next_bab = & xmit_bab[(count < 7) ? count + 1 : 0];
        buffer += length;
      }
   this_xmit = & xmit_bab[0];

   init->mode = 0;
   address[0] = init->addr[1];   address[1] = init->addr[0];
   address[2] = init->addr[3];   address[3] = init->addr[2];
   address[4] = init->addr[5];   address[5] = init->addr[4];
   init->ladrf[0] = 0;   init->ladrf[1] = 0;

   init->rdrp.dra_low = (long) rmd_array & 0xfffful;
   init->rdrp.dra_high = 0;
   init->rdrp.length = 5 << 5;

   init->tdrp.dra_low = (long) tmd_array & 0xfffful;
   init->tdrp.dra_high = 0;
   init->tdrp.length = 3 << 5;

   *rap = 1;   *rdp = (long) init & 0xfffful;
   *rap = 2;   *rdp = 0;
   *rap = 3;   *rdp = CSR3_BSWP;

   *rap = 0;
   *rdp = CSR0_INIT;

   return (0L);
 }


long  check_start()

{
   return ((long) (*rdp & CSR0_IDON));
 }


long  finish_start()

{
   if ((*rdp & CSR0_IDON) == 0) {
        *rdp = CSR0_STOP;   return (FALSE);
      }

   *rdp = CSR0_STRT;
   *rdp = CSR0_IDON;

   this_recve = & recve_bab[0];
   this_xmit = & xmit_bab[0];

   return (TRUE);
 }


long  stop_lance()

{
   this_recve = & recve_bab[0];
   this_xmit = & xmit_bab[0];

   *rap = 0;   *rdp |= CSR0_STOP;

   return (0L);
 }


int16  cdecl  my_cntrl (port, argument, code)

PORT    *port;
uint32  argument;
int16   code;

{
          int16  *arr, result = E_NORMAL;
   static int16  type = -1;

   if (port != & my_port)
        return (E_PARAMETER);

   if (bus_error()) {
        berr_off();
        return (E_UNREACHABLE);
      }

   switch (code) {
      case CTL_ETHER_SET_MAC :
        if (memory)
             memcpy (& ((LANCE_INIT *) memory)->addr[0], (uint8 *) argument, 6);
        break;
      case CTL_ETHER_GET_MAC :
        if (memory)
             memcpy ((uint8 *) argument, & ((LANCE_INIT *) memory)->addr[0], 6);
        break;
      case CTL_ETHER_INQ_SUPPTYPE :
        *((char ***) argument) = & hardware[0];
        break;
      case CTL_ETHER_SET_TYPE :
        if (fetch_addresses (type = (argument & 7)) == FALSE)
             result = E_PARAMETER;
        break;
      case CTL_ETHER_GET_TYPE :
        *((int16 *) argument) = type;
        break;
      default :
        result = E_FNAVAIL;
      }

   berr_off();

   return (result);
 }


int  fetch_addresses (type)

int  type;

{
   int   result = TRUE;
   long  machine;

   switch (type) {
      case 0 :
        rdp = PAM_RDP;   rap = PAM_RAP;   memory = PAM_MEMBOT;
        break;
      case 1 :
        if (! get_cookie ('_MCH', & machine))
             machine = 0;
        if ((machine >> 16) != 2 && ((machine >> 16) != 1 || (machine & 0xffffL) != 16))
             result = FALSE;
          else {
             rdp = PAM_RDP;   rap = PAM_RAP;   memory = PAM_MEMBOT;
           }
        break;
      case 2 :
        rdp = RIEBL_MEGA_RDP;   rap = RIEBL_MEGA_RAP;   memory = RIEBL_MEGA_MEMBOT;
        break;
      case 3 :
        rdp = RIEBL_HACK_RDP;   rap = RIEBL_HACK_RAP;   memory = RIEBL_HACK_MEMBOT;
        break;
      case 4 :
        if (! get_cookie ('_MCH', & machine))
             machine = 0;
        switch (machine >> 16) {
           case 1 :
             if ((machine & 0xffffL) != 16)
                  result = FALSE;
               else {
                  rdp = RIEBL_MSTE_RDP;   rap = RIEBL_MSTE_RAP;   memory = RIEBL_MSTE_MEMBOT;
                }
             break;
           case 2 :
             rdp = RIEBL_TT_RDP;   rap = RIEBL_TT_RAP;   memory = RIEBL_TT_MEMBOT;
             break;
           default :
             result = FALSE;
           }
        break;
      default :
        result = FALSE;
      }

   gtype = type;

   return (result);
 }
