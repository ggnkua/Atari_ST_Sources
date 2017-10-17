/**

 * DNS host name to IP address resolver.
 * This file implements a DNS host name to IP address resolver.

 * Port to lwIP from uIP
 * by Jim Pettinato April 2007

 * uIP version Copyright (c) 2002-2003, Adam Dunkels.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *
 * RESOLV.C
 *
 * The lwIP DNS resolver functions are used to lookup a host name and
 * map it to a numerical IP address. It maintains a list of resolved
 * hostnames that can be queried with the resolv_lookup() function.
 * New hostnames can be resolved using the resolv_query() function.
 *
 * The lwIP version of the resolver also adds a non-blocking version of
 * gethostbyname() that will work with a raw API application. This function
 * checks for an IP address string first and converts it if it is valid.
 * gethostbyname() then does a resolv_lookup() to see if the name is 
 * already in the table. If so, the IP is returned. If not, a query is 
 * issued and the function returns with a QUERY_QUEUED status. The app
 * using the resolver must then go into a waiting state.
 *
 * Once a hostname has been resolved (or found to be non-existent),
 * the resolver code calls a specified callback function (which 
 * must be implemented by the module that uses the resolver).

 */

#include <string.h>
#include "config.h"
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
#include "stats.h"
#include "mem.h"
#include "udp.h"
#include "ip_addr.h"
#include "netif.h"
#include "inet.h"
#include "etharp.h"
#include "sys.h"
#include "opt.h"

#include "sockets.h"
#include "resolv.h"
#include "netdb.h"

/* The maximum length of a host name supported in the name table. */
#define MAX_NAME_LENGTH 32
/* The maximum number of retries when asking for a name. */
#define MAX_RETRIES 4

/* The maximum number of table entries to maintain locally */
#ifndef LWIP_RESOLV_ENTRIES
#define LWIP_RESOLV_ENTRIES 4
#endif

#ifndef DNS_SERVER_PORT
#define DNS_SERVER_PORT 53
#endif

#ifdef NETWORK
#ifdef LWIP

PACK_STRUCT_BEGIN
/* The DNS message header */
typedef struct s_dns_hdr {
  PACK_STRUCT_FIELD(u16_t id);
  PACK_STRUCT_FIELD(u8_t flags1);
  PACK_STRUCT_FIELD(u8_t flags2);
#define DNS_FLAG1_RESPONSE        0x80
#define DNS_FLAG1_OPCODE_STATUS   0x10
#define DNS_FLAG1_OPCODE_INVERSE  0x08
#define DNS_FLAG1_OPCODE_STANDARD 0x00
#define DNS_FLAG1_AUTHORATIVE     0x04
#define DNS_FLAG1_TRUNC           0x02
#define DNS_FLAG1_RD              0x01
#define DNS_FLAG2_RA              0x80
#define DNS_FLAG2_ERR_MASK        0x0f
#define DNS_FLAG2_ERR_NONE        0x00
#define DNS_FLAG2_ERR_NAME        0x03
  PACK_STRUCT_FIELD(u16_t numquestions);
  PACK_STRUCT_FIELD(u16_t numanswers);
  PACK_STRUCT_FIELD(u16_t numauthrr);
  PACK_STRUCT_FIELD(u16_t numextrarr);
} PACK_STRUCT_STRUCT DNS_HDR;
PACK_STRUCT_END

/* The DNS answer message structure */
PACK_STRUCT_BEGIN
typedef struct s_dns_answer {
  /* DNS answer record starts with either a domain name or a pointer
     to a name already present somewhere in the packet. */
  PACK_STRUCT_FIELD(u16_t type);
  PACK_STRUCT_FIELD(u16_t class);
  PACK_STRUCT_FIELD(u16_t ttl[2]);
  PACK_STRUCT_FIELD(u16_t len);
  PACK_STRUCT_FIELD(struct ip_addr ipaddr);
} PACK_STRUCT_STRUCT DNS_ANSWER;
PACK_STRUCT_END

typedef struct namemap {
#define STATE_UNUSED  0
#define STATE_NEW     1
#define STATE_ASKING  2
#define STATE_DONE    3
#define STATE_ERROR   4
#define STATE_TIMEOUT 5
  u8_t state;
  u8_t tmr;
  u8_t retries;
  u8_t seqno;
  u8_t err;
  char name[MAX_NAME_LENGTH];
  struct ip_addr ipaddr;
  void (* found)(char *name, struct ip_addr *ipaddr); /* pointer to callback on DNS query done */
}DNS_TABLE_ENTRY;

static DNS_TABLE_ENTRY dns_table[LWIP_RESOLV_ENTRIES];

static u8_t seqno;
static struct udp_pcb *resolv_pcb; // = NULL; /* our UDP connection to DNS server */
static struct ip_addr serverIP;
static u8_t initFlag;

int h_errno;

/*---------------------------------------------------------------------------
 * parse_name() - walk through a compact encoded DNS name and return the end 
 * of the name.
 *---------------------------------------------------------------------------*/
static unsigned char *
parse_name(unsigned char *query)
{
  unsigned char n;

  do
  {
    n = *query++;
    
    while(n > 0)
    {
      /*      printf("%c", *query);*/
      ++query;
      --n;
    };
  } while(*query != 0);

  return query + 1;
}


/*---------------------------------------------------------------------------
 * check_entries() - Runs through the list of names to see if there are any 
 * that have not yet been queried and, if so, sends out a query.
 *---------------------------------------------------------------------------*/
static void
check_entries(void)
{
  register DNS_HDR *hdr;
  char *query, *nptr, *pHostname;
  static u8_t i;
  static u8_t n;
  register DNS_TABLE_ENTRY *pEntry;
  struct pbuf *p;
  
  for(i = 0; i < LWIP_RESOLV_ENTRIES; ++i)
  {
    pEntry = &dns_table[i];
    if(pEntry->state == STATE_NEW || pEntry->state == STATE_ASKING) 
    {
      if(pEntry->state == STATE_ASKING) 
      {
        if(--pEntry->tmr == 0) 
        {
          if(++pEntry->retries == MAX_RETRIES)
          {
            pEntry->state = STATE_TIMEOUT;
            if (pEntry->found) /* call specified callback function if provided */
              (*pEntry->found)(pEntry->name, NULL);
            continue;
          }
          pEntry->tmr = pEntry->retries;
        } 
        else
        {
          /*  printf("Timer %d\n", pEntry->tmr);*/
          /* Its timer has not run out, so we move on to next
          entry. */
          continue;
        }
      } 
      else
      {
        pEntry->state = STATE_ASKING;
        pEntry->tmr = 1;
        pEntry->retries = 0;
      }
      /* if here, we have either a new query or a retry on a previous query to process */
      p = pbuf_alloc(PBUF_TRANSPORT, sizeof(DNS_HDR)+MAX_NAME_LENGTH+5, PBUF_RAM);
      hdr = (DNS_HDR *)p->payload;
      memset(hdr, 0, sizeof(DNS_HDR));
      hdr->id = i;
      hdr->flags1 = DNS_FLAG1_RD;
      hdr->numquestions = 1;
      query = (char *)hdr + sizeof(DNS_HDR);
      pHostname = pEntry->name;
      --pHostname;
      /* Convert hostname into suitable query format. */
      do
      {
        ++pHostname;
        nptr = query;
        ++query;
        for(n = 0; *pHostname != '.' && *pHostname != 0; ++pHostname)
        {
          *query = *pHostname;
          ++query;
          ++n;
        }
        *nptr = n;
      } 
      while(*pHostname != 0);
      {
        static unsigned char endquery[] = {0,0,1,0,1};
        memcpy(query, endquery, 5);
      }
      pbuf_realloc(p, sizeof(DNS_HDR)+MAX_NAME_LENGTH+5);
      udp_send(resolv_pcb, p);
      pbuf_free(p);
      break;
    }
  }
}


/*---------------------------------------------------------------------------*
 *
 * Callback for DNS responses
 *
 *---------------------------------------------------------------------------*/
static void
resolv_recv(void *s, struct udp_pcb *pcb, struct pbuf *p,
                                  struct ip_addr *addr, u16_t port)
{
  char *pHostname;
  DNS_ANSWER *ans;
  DNS_HDR *hdr;
  static u8_t nquestions, nanswers;
  static u8_t i;
  register DNS_TABLE_ENTRY *pEntry;
  
  hdr = (DNS_HDR *)p->payload;
  /*  printf("ID %d\n", htons(hdr->id));
      printf("Query %d\n", hdr->flags1 & DNS_FLAG1_RESPONSE);
      printf("Error %d\n", hdr->flags2 & DNS_FLAG2_ERR_MASK);
      printf("Num questions %d, answers %d, authrr %d, extrarr %d\n",
      htons(hdr->numquestions),
      htons(hdr->numanswers),
      htons(hdr->numauthrr),
      htons(hdr->numextrarr));
  */

  /* The ID in the DNS header should be our entry into the name table. */
  i = htons(hdr->id);
  pEntry = &dns_table[i];
  if( (i < LWIP_RESOLV_ENTRIES) && (pEntry->state == STATE_ASKING) )
  {
    /* This entry is now finished. */
    pEntry->state = STATE_DONE;
    pEntry->err = hdr->flags2 & DNS_FLAG2_ERR_MASK;

    /* Check for error. If so, call callback to inform. */
    if(pEntry->err != 0)
    {
      pEntry->state = STATE_ERROR;
      if (pEntry->found) /* call specified callback function if provided */
        (*pEntry->found)(pEntry->name, NULL);
      return;
    }

    /* We only care about the question(s) and the answers. The authrr
       and the extrarr are simply discarded. */
    nquestions = htons(hdr->numquestions);
    nanswers = htons(hdr->numanswers);

    /* Skip the name in the question. XXX: This should really be
       checked agains the name in the question, to be sure that they
       match. */
    pHostname = (char *) parse_name((unsigned char *)p->payload + 12) + 4;

    while(nanswers > 0)
    {
      /* The first byte in the answer resource record determines if it
         is a compressed record or a normal one. */
      if(*pHostname & 0xc0)
      { /* Compressed name. */
        pHostname +=2;
        /* printf("Compressed anwser\n");*/
      }
      else
      { /* Not compressed name. */
        pHostname = (char *) parse_name((unsigned char *)pHostname);
      }

      ans = (DNS_ANSWER *)pHostname;
      /*      printf("Answer: type %x, class %x, ttl %x, length %x\n",
         htons(ans->type), htons(ans->class), (htons(ans->ttl[0])
           << 16) | htons(ans->ttl[1]), htons(ans->len));*/

      /* Check for IP address type and Internet class. Others are
       discarded. */
      if((ans->type == 1) && (ans->class == 1) && (ans->len == 4) )
      { /* TODO: we should really check that this IP address is the one we want. */
        pEntry->ipaddr = ans->ipaddr;
        if (pEntry->found) /* call specified callback function if provided */
          (*pEntry->found)(pEntry->name, &pEntry->ipaddr);
        return;
      }
      else
      {
        pHostname = pHostname + 10 + htons(ans->len);
      }
      --nanswers;
    }
  }
}


/*---------------------------------------------------------------------------
 * The DNS resolver client timer - handle retries and timeouts
 *---------------------------------------------------------------------------*/
void
resolv_tmr(void)
{
  check_entries();
}


/*---------------------------------------------------------------------------
 * Queues a name so that a question for the name will be sent out.
 * param name - The hostname that is to be queried.
 *---------------------------------------------------------------------------*/
void
resolv_query(char *name, void (*found)(char *name, struct ip_addr *addr))
{
  static u8_t i;
  static u8_t lseq, lseqi;
  register DNS_TABLE_ENTRY *pEntry = NULL;

  lseq = lseqi = 0;

  for (i = 0; i < LWIP_RESOLV_ENTRIES; ++i)
  {
    pEntry = &dns_table[i];
    if (pEntry->state == STATE_UNUSED)
      break;

    if (seqno - pEntry->seqno > lseq)
    {
      lseq = seqno - pEntry->seqno;
      lseqi = i;
    }
  }

  if (i == LWIP_RESOLV_ENTRIES)
  {
    i = lseqi;
    pEntry = &dns_table[i];
  }

  /*  printf("Using entry %d\n", i);*/
  strcpy(pEntry->name, name);
  pEntry->found = found;
  pEntry->state = STATE_NEW;
  pEntry->seqno = seqno;
  ++seqno;
}


/*---------------------------------------------------------------------------*
 * Look up a hostname in the array of known hostnames.
 *
 * \note This function only looks in the internal array of known
 * hostnames, it does not send out a query for the hostname if none
 * was found. The function resolv_query() can be used to send a query
 * for a hostname.
 *
 * return A pointer to a 4-byte representation of the hostname's IP
 * address, or NULL if the hostname was not found in the array of
 * hostnames.
 *---------------------------------------------------------------------------*/
u32_t
resolv_lookup(char *name)
{
  static u8_t i;
  DNS_TABLE_ENTRY *pEntry;

  /* Walk through name list, return entry if found. If not, return NULL. */
  for(i=0; i<LWIP_RESOLV_ENTRIES; ++i)
  {
    pEntry = &dns_table[i];
    if ( (pEntry->state==STATE_DONE) && (strcmp(name, pEntry->name)==0) )
      return pEntry->ipaddr.addr;
  }
  return 0;
}


/*---------------------------------------------------------------------------*
 * Obtain the currently configured DNS server.
 * return unsigned long encoding of the IP address of
 * the currently configured DNS server or NULL if no DNS server has
 * been configured.
 *---------------------------------------------------------------------------*/
u32_t
resolv_getserver(void)
{
  if(resolv_pcb == NULL)
    return 0;
  return resolv_pcb->remote_ip.addr;
}


/*---------------------------------------------------------------------------
 * Initialize the resolver and configure which DNS server to use for queries.
 *
 * param dnsserver A pointer to a 4-byte representation of the IP
 * address of the DNS server to be configured.
 *---------------------------------------------------------------------------*/
err_t
resolv_init(struct ip_addr *dnsserver)
{
  static u8_t i;

  serverIP.addr = dnsserver->addr;

  for(i=0; i<LWIP_RESOLV_ENTRIES; ++i)
    dns_table[i].state = STATE_DONE;

  if(resolv_pcb != NULL)
    udp_remove(resolv_pcb);

  /* TODO: check for valid IP address for DNS server? */

  resolv_pcb = udp_new();
  udp_bind(resolv_pcb, IP_ADDR_ANY, 0);
  udp_connect(resolv_pcb, dnsserver, DNS_SERVER_PORT);

  udp_recv(resolv_pcb, resolv_recv, NULL);

  initFlag = 1;

  return ERR_OK;
}


/* NON-BLOCKING callback version for use with raw API */
RESOLV_RESULT resolv_gethostbyname(char *hostname, struct ip_addr *addr, 
                       void (* found)(char *name, struct ip_addr *ipaddr))
{
  if ((!hostname) || (!hostname[0]))
    return RESOLV_QUERY_INVALID;

  if (strlen(hostname) > MAX_NAME_LENGTH)
    return RESOLV_QUERY_INVALID;

  if ((hostname[0] >= '0') && (hostname[0] <= '9'))
  {
    /* host name already in octet notation?
      - set ip addr and return COMPLETE */
    addr->addr = inet_addr(hostname);
    if (INADDR_NONE == addr->addr)
      return RESOLV_QUERY_INVALID;
    return RESOLV_COMPLETE;
  }

  if (!initFlag)     /* not initialized or no valid server yet */
    return RESOLV_QUERY_INVALID;

  if ((addr->addr = resolv_lookup(hostname)) != 0) /* already have this address cached? */
    return RESOLV_COMPLETE; 

  resolv_query(hostname, found);      /* queue query with specified callback */
  return RESOLV_QUERY_QUEUED;
}


static u8_t resolv_get_state(char *name)
{
  static u8_t i;
  DNS_TABLE_ENTRY *pEntry;

  /* Walk through name list, return entry if found. If not, return NULL. */
  for(i=0; i<LWIP_RESOLV_ENTRIES; ++i)
  {
    pEntry = &dns_table[i];
    if (strcmp(name, pEntry->name)==0)
      return pEntry->state;
  }
  return STATE_UNUSED;
}

struct hostent *gethostbyname(const char *hostname)
{
  static char h_name[MAX_NAME_LENGTH];
  static struct hostent host;
  static char *h_aliases[1];
  static char *h_addr_list[2];
  static struct in_addr host_addr;

  host.h_name = h_name;
  host.h_aliases = h_aliases;
  h_aliases[0] = NULL;
  host.h_addr_list = h_addr_list;
  h_addr_list[0] = (char *)&host_addr;
  h_addr_list[1] = NULL;
  host.h_addrtype = AF_INET;
  host.h_length = sizeof(u32_t);

  if ((!hostname) || (!hostname[0]))
  {
    h_errno = NO_DATA;
    return NULL;
  }

  if (strlen(hostname) > MAX_NAME_LENGTH)
  {
    h_errno = NO_DATA;
    return NULL;
  }
  
  strncpy(host.h_name, hostname, MAX_NAME_LENGTH);

  if ((hostname[0] >= '0') && (hostname[0] <= '9'))
  {
    /* host name already in octet notation? */
    if(!inet_aton(hostname, &host_addr))
    {
      h_errno = NO_RECOVERY;
      return NULL;
    }
    return &host;
  }

  if (!initFlag)     /* not initialized or no valid server yet */
  {
    h_errno = HOST_NOT_FOUND;
    return NULL;
  }

  if ((host_addr.s_addr = resolv_lookup((char *)hostname)) != 0) /* already have this address cached? */
    return &host;
  
  resolv_query((char *)hostname, NULL);      /* queue query */
  while(1)
  {  
    switch(resolv_get_state((char *)hostname))
    {
      case STATE_DONE:
        if ((host_addr.s_addr = resolv_lookup((char *)hostname)) != 0) /* already have this address cached? */
          return &host;
      case STATE_ERROR:
        h_errno = NO_RECOVERY;
        return NULL;
      case STATE_TIMEOUT:
        h_errno = TRY_AGAIN;
        return NULL;
    }
    vTaskDelay(1);
  }
}

#endif /* LWIP */
#endif /* NETWORK */
