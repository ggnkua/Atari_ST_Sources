/*
 *      udp.h               (c) Peter Rottengatter  1996
 *                              perot@pallas.amp.uni-hannover.de
 *
 *      Included into the UDP.STX source code files
 */

#ifndef UDP_H
#define UDP_H



/*--------------------------------------------------------------------------*/


/*
 *   UDP header and chain link structure.
 */

typedef  union header  {
     struct {
         uint16  source_port;        /* Source UDP port                     */
         uint16  dest_port;          /* Destination UDP port                */
         uint16  length;             /* UDP length of data                  */
         uint16  checksum;           /* UDP checksum                        */
      } udp;                         /* Structure when used as net packet   */
     struct {
         union header  *next;        /* Link to next data block in chain    */
         uint16        length;       /* Amount of data in this block        */
         uint16        index;        /* Index to data start in this block   */
      } chain;                       /* Structure when used as queued data  */
 } UDP_HDR;


/*
 *   UDP connection structure.
 */

typedef  struct connec  {
     uint32   remote_IP_address;     /* Foreign socket IP address           */
     uint16   remote_port;           /* Foreign socket port number          */
     uint32   local_IP_address;      /* Local socket IP address             */
     uint16   local_port;            /* Local socket port number            */
     int16    ttl;                   /* Time To Live (for IP)               */
     uint32   total_data;            /* Total real data in queue            */
     CIB      *info;                 /* Connection information link         */
     int16     net_error;            /* Error to be reported with next call */
     UDP_HDR  *receive_queue;        /* Receive queue                       */
     UDP_HDR  *pending;              /* Pending IP datagrams                */
     int16    semaphore;             /* Semaphore for locking structures    */
     uint32   last_work;             /* Last time work has been done        */
     struct connec  *next;           /* Link to next connection in chain    */
 } CONNEC;



/*--------------------------------------------------------------------------*/


#endif /* UDP_H */
