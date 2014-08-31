/*
 *      resolve.h           (c) Peter Rottengatter  1997
 *                              perot@pallas.amp.uni-hannover.de
 *
 *      Included into the RESOLVE.STX source code files
 */

#ifndef RESOLVE_H
#define RESOLVE_H



/*--------------------------------------------------------------------------*/


/*
 *   Domain Name System Type definitions.
 */

#define   DNS_A         1
#define   DNS_NS        2
#define   DNS_CNAME     5
#define   DNS_SOA       6
#define   DNS_WKS       11
#define   DNS_PTR       12
#define   DNS_HINFO     13
#define   DNS_MX        15



/*--------------------------------------------------------------------------*/


/*
 *   STX internal structure holding a cached domain name.
 */

typedef  struct dname  {
     char      *name;              /* Domain Name                           */
     int16     length;             /* Number of characters in name          */
     int16     type;               /* DNS type of entry ('A', 'MX' etc.)    */
     uint32    expiry;             /* Expiry time of entry (since 1.1.1970) */
     struct dname  *next;          /* In case of alias pointer to next one  */
 } DNAME;



/*--------------------------------------------------------------------------*/


/*
 *   STX internal structure holding all cached data.
 */

typedef  struct cache  {
     uint32    IP_address;         /* Host IP address                       */
     DNAME     real;               /* Canonical domain name for host        */
     DNAME     *alias;             /* Linked list of alias names            */
     uint32    used;               /* Latest time this one was used         */
     struct cache  *next;          /* Next cache entry in list              */
 } CACHE;



/*--------------------------------------------------------------------------*/


#endif /* RESOLVE_H */
