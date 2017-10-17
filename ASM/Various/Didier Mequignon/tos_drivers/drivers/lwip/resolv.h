/**
 * lwip DNS resolver header file.

 * Author: Jim Pettinato 
 *   April 2007

 * ported from uIP resolv.c Copyright (c) 2002-2003, Adam Dunkels.
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
 */
#ifndef RESOLV_H
#define RESOLV_H

/* enumerated list of possible result values returned by gethostname() */
typedef enum e_resolv_result {
  RESOLV_QUERY_INVALID,
  RESOLV_QUERY_QUEUED,
  RESOLV_COMPLETE
} RESOLV_RESULT;

/* Functions. */
RESOLV_RESULT resolv_gethostbyname(char *hostName, struct ip_addr *addr, 
                     void (* resolv_found_func)(char *name, struct ip_addr *ipaddr));

/* gethostbyname() - Returns immediately with one of RESOLV_RESULT return codes.
 *                   Return value will be RESOLV_COMPLETE if hostName is a valid *
 *                   IP address string or the host name is already in the local  *
 *                   names table. Returns RESOLV_REQUEST_QUEUED and queues a     *
 *                   request to be sent to the DNS server for resolution if no   *
 *                   errors are present.                                         */

/* resolv_found_func() - Callback which is invoked when a hostname is found.

 * This function should be implemented by the application using the DNS resolver.
 *  param 'name'   - pointer to the name that was looked up.
 *  param 'ipaddr' - pointer to a struct ip_addr containing the IP address of the
 *                   hostname, or NULL if the name could not be found.
*/

err_t resolv_init(struct ip_addr *dnsserver);  /* initializes the resolver */
void resolv_tmr(void); /* handles requests, retries and timeouts - call every tcp_slowtmr tick */
u32_t resolv_getserver(void);    /* returns configured DNS server IP addr */
u32_t resolv_lookup(char *name); /* returns IP for host 'name' only if already in table */
void resolv_query(char *name, void (*found)(char *name, struct ip_addr *addr));
  /* activates request for named host which will be processed on next timer tick */

#endif /* RESOLV_H */

