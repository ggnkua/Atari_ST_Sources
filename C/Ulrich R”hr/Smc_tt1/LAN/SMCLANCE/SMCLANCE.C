#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include "..\include\lan.h"
#include "..\include\cookie.h"
#include "..\include\wd.h"
#include "..\include\fifo.h"
#include "..\include\driver.h"

extern void  wd_get_lan_addr(unsigned char *eth_addr);
extern int wd_send(unsigned char *buffer,unsigned short len);
extern int  wd_init(void);

/*-------------------------------------------------------------*/
/* globale Variablen fuer Packetpool                           */
/*-------------------------------------------------------------*/
ff_typ	ff_free;                      /* FIFO der freien Pakete*/

et_stat statistics;                   /* Statistik             */

PROTOCOL protos[MAXPROTOCOLS];        /* protocols to serve    */
int protocols = 0;                    /* number of active protocols */

char free_mem[MAXPKT*2048L];   /* Paketpuffer           */

static unsigned char send_sema=0;     /* Sendesemaphor         */

/*-------------------------------------------------------------*/
/* Tabelle mit Funktionszeigern, auf den das Cookie zeigt      */
/*-------------------------------------------------------------*/
procref ext_tab[8] =
{
  net_reset,
  net_open,
  net_release,
  net_send,
  net_getadr,
  net_info,
  (procref)net_pktalloc,
  net_pktfree
};

/*-------------------------------------------------------------*/
/* Text auf Bildschirm ausgeben (nur Initialisierung)          */
/*-------------------------------------------------------------*/
void debug_str(char *str)
{
Cconws(str);
Cconws("\n\r");
}

/*-------------------------------------------------------------*/
/* Gibt auskunft ueber den aktuelle Netzstatus                 */
/*-------------------------------------------------------------*/
int net_info(int len, et_stat *buf)
{
if(len < sizeof(statistics) )
  return EPARAM;
memcpy(buf,&statistics,sizeof(statistics));
return 0;
}

/*-------------------------------------------------------------*/
/* Installieren eines Protokollhandlers                        */
/*-------------------------------------------------------------*/
int net_open(int type, int (*handler)(int,lan_buffer_typ *))
{
int		i;

if(protocols >= MAXPROTOCOLS) return EPROTAVAIL;

for(i = 0; i < MAXPROTOCOLS; i++)
  {    /* protocol ist schon angemeldet */
  if(protos[i].type == type)
    return(EPROTUSED);
  }

for(i = 0; i < MAXPROTOCOLS; i++)
  if(protos[i].type == ET_UNUSED)  /* find first free entry */
    {
    protocols++;
    protos[i].handler = handler;
    protos[i].recvd = 0;
    protos[i].sent = 0;
    protos[i].type = type;
    return(i);
    }
return EPROTAVAIL;
}

/*-------------------------------------------------------------*/
/* Entfernen eines Protokollhandlers                           */
/*-------------------------------------------------------------*/
int net_release(int type)
{
int i;

if(!protocols) return(EPROTUSED);
if(type == ET_UNUSED) return(EPROTUSED);

for(i=0; i < MAXPROTOCOLS; i++)
  if(protos[i].type == type) break;
if(i==MAXPROTOCOLS)
  return(EPROTUSED);

protocols--;

protos[i].type = ET_UNUSED;
protos[i].handler = NULL;
return(protocols);
}

/*-------------------------------------------------------------*/
/* Paket senden                                                */
/*-------------------------------------------------------------*/
int net_send(int len, lan_buffer_typ *buf)
{
int erg;

get_sema(&send_sema);
erg = wd_send((unsigned char*)buf,(unsigned short)len);
clear_sema(&send_sema);
return erg;          /* return = tatsaechlich gesendete laenge */
}

/*-------------------------------------------------------------*/
/* Ethernetaddresse des eigenen Adapters ermitteln             */
/*-------------------------------------------------------------*/
int	net_getadr(int len, unsigned char *buf)
{
if(len < 6) return 0;    /* sicherheitshalber                  */
wd_get_lan_addr((unsigned char*)buf);
return 6;            /* Ethernet hat 6 Byte Adresse            */
}

/*-------------------------------------------------------------*/
/* Adapter zurcksetzen                                        */
/*-------------------------------------------------------------*/
int net_reset(void)
{
int i;

for(i=0;i<MAXPROTOCOLS;i++)  /* init protocol table */
  {
  protos[i].type = ET_UNUSED;
  protos[i].handler = NULL;
  protos[i].recvd = 0;
  protos[i].sent = 0;
  }
protocols = 0;

pkt_ff_init(&ff_free,MAXPKT);   /* leeren FIFO anlegen */
pkt_ff_alloc(&ff_free,free_mem);         /* FIFO mit freien Paketen füllen */

wd_init();		/* Init WD Chipsatz */

return 0;                   /* OK, reset OK */
}

/*--- Supexec braucht long Funktion ---------------------------*/
long net_reset_s(void)
{
return (int) net_reset();
}

/*-------------------------------------------------------------*/
/* Speicherplatz fuer ein Paket des angegebenen Protokolles    */
/* allokieren                                                  */
/*-------------------------------------------------------------*/
lan_buffer_typ *net_pktalloc(unsigned short protocol)
{
protocol = protocol;          
return pkt_ff_get(&ff_free);  /* Protokoll wird ignoriert       */
}

/*-------------------------------------------------------------*/
/* Speicherplatz eines Paketes freigeben                       */
/*-------------------------------------------------------------*/
int net_pktfree(lan_buffer_typ *p_pkt)
{
return pkt_ff_put(&ff_free,p_pkt);
}

/*-------------------------------------------------------------*/
/* Hauptprogramm des Treibers                                  */
/*-------------------------------------------------------------*/
int main()
{
COOKIE *cookie;
char str[100];

Cconws("\r\nUlrichs Ethercard Elite Treiber \r\n");
cookie = get_cookie(PKTCOOKIE);

if(cookie)
  {
  Cconws("\r\!!! COOKIE existiert noch !!!, das wird nix!\r\n");
  exit(0);
  }
else
  {
  if(Supexec(net_reset_s) < 0)
    {
    Cconws("\r\n Fehler beim Initialisiern der Karte\r\n");
    Cconws("\r\n Weiter mit taste\r\n");
    gets(str);
    exit(0);
    }

  add_cookie(PKTCOOKIE,(long)ext_tab);

  Cconws("Cookie installed\r\n");
  }

sprintf(str,"%ld Bytes resident\n",_PgmSize);
Cconws(str);
Ptermres(_PgmSize,0);
return 0;
}

