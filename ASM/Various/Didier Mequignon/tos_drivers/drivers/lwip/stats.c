/*
 * Copyright (c) 2001-2004 Swedish Institute of Computer Science.
 * All rights reserved. 
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission. 
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED 
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 * OF SUCH DAMAGE.
 *
 * This file is part of the lwIP TCP/IP stack.
 * 
 * Author: Adam Dunkels <adam@sics.se>
 *
 */

#include <string.h>

#include "config.h"
#include "opt.h"

#include "def.h"

#include "stats.h"
#include "mem.h"

#include "perf.h"

#ifdef NETWORK
#ifdef LWIP

struct perf lwip_perfs[PERFS_MAX];

#if LWIP_STATS
struct stats_ lwip_stats;

#define sys_debug board_printf

extern void board_printf(const char *fmt, ...);

void
stats_init(void)
{
  memset(&lwip_stats, 0, sizeof(struct stats_));
  memset(lwip_perfs, 0, sizeof(struct perf) * PERFS_MAX);
}
#if LWIP_STATS_DISPLAY
void
stats_display_proto(struct stats_proto *proto, char *name)
{
  LWIP_PLATFORM_DIAG(("%s\t", name));
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->xmit)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->rexmit)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->recv)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->fw)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->drop)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->chkerr)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->lenerr)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->memerr)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->rterr)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->proterr)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->opterr)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", proto->err)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\r\n", proto->cachehit)); 
}

void
stats_display_pbuf(struct stats_pbuf *pbuf)
{
  LWIP_PLATFORM_DIAG(("\t%"U32_F"\t", pbuf->avail)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", pbuf->used)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", pbuf->max)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", pbuf->err)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", pbuf->alloc_locked)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\r\n", pbuf->refresh_locked)); 
}

void
stats_display_mem(struct stats_mem *mem, char *name)
{
  LWIP_PLATFORM_DIAG(("\t%"U32_F"\t", mem->avail)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", mem->used)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", mem->max)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", mem->err));
  LWIP_PLATFORM_DIAG(("%s\r\n", name));
}

void
stats_display_sys(struct stats_syselem *sys, char *name)
{
  LWIP_PLATFORM_DIAG(("\t%"U32_F"\t", sys->used)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", sys->max)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", sys->err));
  LWIP_PLATFORM_DIAG(("%s\r\n", name));
}

void
stats_display_perf(struct perf *perf)
{
  LWIP_PLATFORM_DIAG(("\t%"U32_F"\t", perf->used)); 
  LWIP_PLATFORM_DIAG(("%"U32_F"\t", perf->max)); 
  LWIP_PLATFORM_DIAG(("%s\r\n", perf->name));
}

void
stats_display(void)
{
  int i;
  char * memp_names[] = {"PBUF", "RAW_PCB", "UDP_PCB", "TCP_PCB", "TCP_PCB_LISTEN",
        "TCP_SEG", "NETBUF", "NETCONN", "API_MSG", "TCP_MSG", "TIMEOUT"};
  LWIP_PLATFORM_DIAG(("\r\nname\txmit\trexmit\trecv\tfw\tdrop\tchkerr\tlenerr\tmemerr\trterr\tproterr\topterr\terr\tcachehit\r\n")); 
  stats_display_proto(&lwip_stats.link, "LINK");
  stats_display_proto(&lwip_stats.ip_frag, "IP_FRAG");
  stats_display_proto(&lwip_stats.ip, "IP");
  stats_display_proto(&lwip_stats.icmp, "ICMP");
  stats_display_proto(&lwip_stats.udp, "UDP");
  stats_display_proto(&lwip_stats.tcp, "TCP");
  LWIP_PLATFORM_DIAG(("\r\nPBUF\tavail\tused\tmax\terr\tlocked\trefresh_locked\r\n"));
  stats_display_pbuf(&lwip_stats.pbuf);
  LWIP_PLATFORM_DIAG(("\r\nMEMORY\tavail\tused\tmax\terr\tname\r\n"));
  stats_display_mem(&lwip_stats.mem, "HEAP");
  for (i = 0; i < MEMP_MAX; i++) {
    stats_display_mem(&lwip_stats.memp[i], memp_names[i]);
  }
  LWIP_PLATFORM_DIAG(("\r\nSYS\tused\tmax\terr\tname\r\n"));
  stats_display_sys(&lwip_stats.sys.sem, "SEM");  
  stats_display_sys(&lwip_stats.sys.mbox, "MBOX"); 
  LWIP_PLATFORM_DIAG(("\r\nPERFS\tused\tmax\tname\t(uS)\r\n"));
  for (i = 0; i < PERFS_MAX; i++) {
    if(lwip_perfs[i].func != NULL)
      stats_display_perf(&lwip_perfs[i]);
  }
}
#endif /* LWIP_STATS_DISPLAY */
#endif /* LWIP_STATS */

#endif /* LWIP */
#endif /* NETWORK */

