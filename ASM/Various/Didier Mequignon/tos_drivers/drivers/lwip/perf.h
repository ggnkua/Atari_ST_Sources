/*
 * Copyright (c) 2001-2003 Swedish Institute of Computer Science.
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
#ifndef __PERF_H__
#define __PERF_H__

/* ------------------------ Defines --------------------------------------- */

#include "opt.h"
#include "cc.h"
#include "sys.h"

struct perf {
  s8_t *func;
  s8_t *name;
  u32_t start;
  u32_t used;
  u32_t max;
};

#define PERFS_MAX 8

extern struct perf lwip_perfs[PERFS_MAX];

#define PERF_START do { \
  int i = 0; \
  SYS_ARCH_DECL_PROTECT(level); \
  SYS_ARCH_PROTECT(level); \
  while((lwip_perfs[i].func != NULL) && (i < PERFS_MAX)) { \
    if(lwip_perfs[i].func == (s8_t *)__FUNCTION__) \
      break; \
    i++; } \
  if(i < PERFS_MAX) { \
    lwip_perfs[i].func = (s8_t *)__FUNCTION__; \
    lwip_perfs[i].start = sys_read_timer(); } \
  SYS_ARCH_UNPROTECT(level); \
} while(0)

#define PERF_START_INT do { \
  int i = 0; \
  while((lwip_perfs[i].func != NULL) && (i < PERFS_MAX)) { \
    if(lwip_perfs[i].func == (s8_t *)__FUNCTION__) \
      break; \
    i++; } \
  if(i < PERFS_MAX) { \
    lwip_perfs[i].func = (s8_t *)__FUNCTION__; \
    lwip_perfs[i].start = sys_read_timer(); } \
} while(0)

#ifdef MCF5445X

#define PERF_STOP(x) do { \
  int i = 0; \
  SYS_ARCH_DECL_PROTECT(level); \
  SYS_ARCH_PROTECT(level); \
  while((lwip_perfs[i].func != NULL) && (i < PERFS_MAX)) { \
    if(lwip_perfs[i].func == (s8_t *)__FUNCTION__) { \
      lwip_perfs[i].name = (s8_t *)x; \
      lwip_perfs[i].used = sys_read_timer() - lwip_perfs[i].start; \
      if(lwip_perfs[i].used > lwip_perfs[i].max) \
        lwip_perfs[i].max = lwip_perfs[i].used; \
      break; } \
    i++; } \
  SYS_ARCH_UNPROTECT(level); \
} while(0)

#define PERF_STOP_INT(x) do { \
  int i = 0; \
  while((lwip_perfs[i].func != NULL) && (i < PERFS_MAX)) { \
    if(lwip_perfs[i].func == (s8_t *)__FUNCTION__) { \
      lwip_perfs[i].name = (s8_t *)x; \
      lwip_perfs[i].used = sys_read_timer() - lwip_perfs[i].start; \
      if(lwip_perfs[i].used > lwip_perfs[i].max) \
        lwip_perfs[i].max = lwip_perfs[i].used; \
      break; } \
    i++; } \
} while(0)

#else /* MCF548X */

#define DIVIDER_TIMER (configCPU_CLOCK_HZ/2000000UL)

#define PERF_STOP(x) do { \
  int i = 0; \
  SYS_ARCH_DECL_PROTECT(level); \
  SYS_ARCH_PROTECT(level); \
  while((lwip_perfs[i].func != NULL) && (i < PERFS_MAX)) { \
    if(lwip_perfs[i].func == (s8_t *)__FUNCTION__) { \
      lwip_perfs[i].name = (s8_t *)x; \
      lwip_perfs[i].used = (lwip_perfs[i].start - sys_read_timer()) / DIVIDER_TIMER; \
      if(lwip_perfs[i].used > lwip_perfs[i].max) \
        lwip_perfs[i].max = lwip_perfs[i].used; \
      break; } \
    i++; } \
  SYS_ARCH_UNPROTECT(level); \
} while(0)

#define PERF_STOP_INT(x) do { \
  int i = 0; \
  while((lwip_perfs[i].func != NULL) && (i < PERFS_MAX)) { \
    if(lwip_perfs[i].func == (s8_t *)__FUNCTION__) { \
      lwip_perfs[i].name = (s8_t *)x; \
      lwip_perfs[i].used = (lwip_perfs[i].start - sys_read_timer()) / DIVIDER_TIMER; \
      if(lwip_perfs[i].used > lwip_perfs[i].max) \
        lwip_perfs[i].max = lwip_perfs[i].used; \
      break; } \
    i++; } \
} while(0)

#endif /* MCF548X */

#endif /* __PERF_H__ */
