/*
 * File:        icmp.c
 * Purpose:     Handle ICMP packets.
 *
 * Notes:       See RFC 792 "Internet Control Message Protocol"
 *              for more details.
 */
#include <osbind.h>
#include "config.h"
#include "net.h"

#ifdef NETWORK
#ifndef LWIP

/********************************************************************/
void
dump_icmp_frame (icmp_message *msg)
{
    switch (msg->type)
    {
        case ICMP_DEST_UNREACHABLE:
            Cconws("ICMP : ");
            switch (msg->code)
            {
                case ICMP_NET_UNREACHABLE:
                    Cconws("Net Unreachable\r\n");
                    break;
                case ICMP_HOST_UNREACHABLE:
                    Cconws("Host Unreachable\r\n");
                    break;
                case ICMP_PROTOCOL_UNREACHABLE:
                    Cconws("Protocol Unreachable\r\n");
                    break;
                case ICMP_PORT_UNREACHABLE:
                    Cconws("Port Unreachable\r\n");
                    break;
                case ICMP_FRAG_NEEDED:
                    Cconws("Fragmentation needed and DF set\r\n");
                    break;
                case ICMP_ROUTE_FAILED:
                    Cconws("Source route failed\r\n");
                    break;
                default:
                    Cconws("Destination Unreachable\r\n");
                    break;
            }
            break;
        case ICMP_TIME_EXCEEDED:
            Cconws("ICMP_TIME_EXCEEDED\r\n");
            break;
        case ICMP_PARAMETER_PROBLEM:
            Cconws("ICMP_PARAMETER_PROBLEM\r\n");
            break;
        case ICMP_SOURCE_QUENCH:
            Cconws("ICMP_SOURCE_QUENCH\r\n");
            break;
        case ICMP_REDIRECT:
            Cconws("ICMP_REDIRECT\r\n");
            break;
        case ICMP_ECHO:
            Cconws("ICMP_ECHO\r\n");
            break;
        case ICMP_ECHO_REPLY:
            Cconws("ICMP_ECHO_REPLY\r\n");
            break;
        case ICMP_INFORMATION_REQUEST:
            Cconws("ICMP_INFORMATION_REQUEST\r\n");
            break;
        case ICMP_INFORMATION_REPLY:
            Cconws("ICMP_INFORMATION_REPLY\r\n");
            break;
        case ICMP_TIMESTAMP:
            Cconws("ICMP_TIMESTAMP\r\n");
            break;
        case ICMP_TIMESTAMP_REPLY:
            Cconws("ICMP_TIMESTAMP_REPLY\r\n");
            break;
        default:
            Cconws("Unknown ICMP message\r\n");
            break;
    }
}

/********************************************************************/
void
icmp_handler (NIF *nif, NBUF *pNbuf)
{
    /*
     * This function handles the ICMP packets.
     */
    icmp_message *icmpmsg;
    ip_frame_hdr *ipframe;
    uint8 src[4], dest[4];

    icmpmsg = (icmp_message *)&pNbuf->data[pNbuf->offset];

    switch (icmpmsg->type)
    {
        case ICMP_ECHO:
            /* 
             * Change ICMP echo message into a echo reply message 
             */
            icmpmsg->type = ICMP_ECHO_REPLY;
            
            /* 
             * Recompute checksum 
             */
            icmpmsg->chksum = 0;
            icmpmsg->chksum = ip_chksum((uint16 *)icmpmsg,pNbuf->length);

            /*
             * Send the Echo Reply
             */
            ipframe = (ip_frame_hdr *)&pNbuf->data[IP_HDR_OFFSET];
            memcpy(dest, &ipframe->source_addr[0], 4);
            memcpy(src, &ipframe->dest_addr[0], 4);
            ip_send(nif, dest, src, ipframe->protocol, pNbuf);
            break;
        case ICMP_DEST_UNREACHABLE:
        case ICMP_TIME_EXCEEDED:
        case ICMP_PARAMETER_PROBLEM:
        case ICMP_SOURCE_QUENCH:
        case ICMP_REDIRECT:
        case ICMP_ECHO_REPLY:
        case ICMP_INFORMATION_REQUEST:
        case ICMP_INFORMATION_REPLY:
        case ICMP_TIMESTAMP:
        case ICMP_TIMESTAMP_REPLY:
        default:
            dump_icmp_frame(icmpmsg);
            nbuf_free(pNbuf);
            break;
    }
}

/******************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
