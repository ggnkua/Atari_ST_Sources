/*
 * File:        tftp.c
 * Purpose:     Trivial File Transfer Protocol driver for reading a file
 *              from a remote host.
 *
 * Notes:       See RFC 1350
 *
 * Modifications:
 *
 */
#include <osbind.h>
#include "config.h"
#include "net.h"
#include "net_timer.h"

#ifdef NETWORK
#ifndef LWIP

extern void ltoa(char *buf, long n, unsigned long base);
extern void cat(const char *src, char *dest);

static char tftp_string_error[1024];

/********************************************************************/

/* The one and only TFTP connection */
TFTP_Connection tcxn;

/* Progress Indicators */
//char hash[] = {'-','\\','|','/'};
//int ihash = 0;

/********************************************************************/
static int
tftp_rwrq (void)
{
    NBUF *pNbuf;
    RWRQ *rwrq;
    int i, j, result;
    
    pNbuf = nbuf_alloc();
    if (pNbuf == NULL)
    {
        #if defined(DEBUG_PRINT)
            Cconws("TFTP: tftp_rwrq() couldn't allocate Tx buffer\r\n");
        #endif
        return 0;
    }

    rwrq = (RWRQ *)&pNbuf->data[TFTP_HDR_OFFSET];

    /* Indicate a R/WRQ */
    rwrq->opcode = tcxn.dir;

    /* Copy in filename */
    strcpy(&rwrq->filename_mode[0], tcxn.file);
    i = strlen(tcxn.file) + 1;

    /* Indicate transfer type */
    strcpy (&rwrq->filename_mode[i], OCTET);

    for (j=0; j<3; ++j)
    {
        pNbuf->length = (uint16)(i + strlen(OCTET) + 1 + 2);
        result = udp_send(tcxn.nif,
                          tcxn.server_ip,
                          tcxn.my_port,
                          tcxn.server_port,
                          pNbuf);
        if (result == 1)
            break;
    }

    if (result == 0)
        nbuf_free(pNbuf);

    return result;
}
/********************************************************************/
static int
tftp_ack (uint16 blocknum)
{
    ACK *ack;
    NBUF *pNbuf;
    int i, result;

    pNbuf = nbuf_alloc();
    if (pNbuf == NULL)
    {
        #if defined(DEBUG_PRINT)
            Cconws("TFTP: tftp_ack() couldn't allocate Tx buffer\r\n");
        #endif
        return 0;
    }

    ack = (ACK *)&pNbuf->data[TFTP_HDR_OFFSET];
    ack->opcode = TFTP_ACK;
    ack->blocknum = blocknum;
    
    for (i=0; i<3; ++i)
    {
        pNbuf->length = 4;
        result = udp_send(tcxn.nif,
                          tcxn.server_ip,
                          tcxn.my_port,
                          tcxn.server_port,
                          pNbuf);
        if (result == 1)
            break;
    }

    if (result == 0)
        nbuf_free(pNbuf);

    return result;
} 
/********************************************************************/
static int
tftp_error (uint16 error_code, uint16 server_port)
{
    ERROR *err;
    NBUF *pNbuf;
    int i, result;

    pNbuf = nbuf_alloc();
    if (pNbuf == NULL)
    {
        #if defined(DEBUG_PRINT)
            Cconws("TFTP: tftp_error() couldn't allocate Tx buffer\r\n");
        #endif
        return 0;
    }

    err = (ERROR *)&pNbuf->data[TFTP_HDR_OFFSET];
    err->opcode = TFTP_ERROR;
    err->code = error_code;
    err->msg[0] = '\0';

    for (i=0; i<3; ++i)
    {
        pNbuf->length = 5;
        result = udp_send(tcxn.nif,
                          tcxn.server_ip,
                          tcxn.my_port,
                          server_port,
                          pNbuf);
        if (result == 1)
            break;
    }

    if (result == 0)
        nbuf_free(pNbuf);

    return result;
}
/********************************************************************/
void
tftp_handler (NIF *nif, NBUF *pNbuf)
{
    union TFTPpacket *tftp_pkt;
    udp_frame_hdr *udpframe;
    static int cnt;
    (void) nif;

    tftp_pkt = (union TFTPpacket *)&pNbuf->data[pNbuf->offset];
    udpframe = (udp_frame_hdr *)&pNbuf->data[pNbuf->offset - UDP_HDR_SIZE];

    switch (tftp_pkt->generic.opcode)
    {
        case TFTP_DATA:
            /* Is this the expected block number? */
            if (tftp_pkt->data.blocknum == tcxn.exp_blocknum)
            {
                /* Is this is the first data block received? */
                if (tftp_pkt->data.blocknum == 1)
                {
                    /* Save the server's transfer ID */
                    tcxn.server_port = UDP_SOURCE(udpframe);

                    /* Mark the connection as open */
                    tcxn.open = TRUE;

                    /* Start progress indicator */
//                    board_putchar(hash[0]);
                    cnt = 0;
                }
                else
                {   
                    /* Check the server's transfer ID */
                    if (tcxn.server_port != UDP_SOURCE(udpframe))
                    {
                        #if defined(DEBUG_PRINT)
                            char buf[10];
														Cconws("TFTP: Invalid server port: ");
                            ltoa(buf, UDP_SOURCE(udpframe), 10);
                            Cconws(buf);
                            Cconws("\r\n");
                        #endif

                        /* Send ERROR packet to source */
                        tftp_error(TFTP_ERR_TID, UDP_SOURCE(udpframe));
                        break;
                    }
                }

                /* Add the buffer to the TFTP queue */
                queue_add(&tcxn.queue, (QNODE *)pNbuf);
                
                /* Update number of the next block expected */
                tcxn.exp_blocknum++;

                /* Increment number of bytes received counter */
                tcxn.bytes_recv += (pNbuf->length - 4);

                /* Update progress indicator */
                if (++cnt == 50)
                {
//                    ihash = (ihash + 1) % 4;
//                    board_putchar(CTRL_BS);
//                    board_putchar(hash[ihash]);
                    cnt = 0;
                }
            }
            else
            {
                if (tftp_pkt->data.blocknum < tcxn.exp_blocknum)
                {
                    /* Re-ACK this packet */
                    tftp_ack(tftp_pkt->data.blocknum);
                }

                #if defined(DEBUG_PRINT)
                {
                    /* This is NOT the block expected */
                    char buf[10];
                    Cconws("Exp: ");
                    ltoa(buf, tcxn.exp_blocknum, 10);
                    Cconws(buf);
                    Cconws(", Rcv: ");
                    ltoa(buf, tftp_pkt->data.blocknum, 10);
                    Cconws(buf);
                    Cconws("\r\n");
                }
                #endif
                
                /* Free the network buffer */
                nbuf_free(pNbuf);
            }
            break;
        case TFTP_ERROR:
            {
            		char buf[10];
                cat("TFTP Error #", tftp_string_error);
                ltoa(buf, tftp_pkt->error.code, 10);
                cat(buf, tftp_string_error);
                cat(": ", tftp_string_error);
                cat(tftp_pkt->error.msg, tftp_string_error);
            }
            tcxn.error = TRUE;
            /* Free the network buffer */
            nbuf_free(pNbuf);
            break;
        case TFTP_ACK:
            if (tftp_pkt->ack.blocknum == tcxn.exp_blocknum)
            {
                if (tftp_pkt->data.blocknum == 0)
                {   /* This is the first ACK received */

                    /* Save the server's transfer ID */
                    tcxn.server_port = UDP_SOURCE(udpframe);

                    /* Mark the connection as open */
                    tcxn.open = TRUE;
                }
                else
                {   /* Check the server's transfer ID */
                    if (tcxn.server_port != UDP_SOURCE(udpframe))
                    {
                        #if defined(DEBUG_PRINT)
                            char buf[10];
                            Cconws("TFTP: Invalid server port: ");
                            ltoa(buf, UDP_SOURCE(udpframe), 10);
                            Cconws(buf);
                            Cconws("\r\n");
                        #endif

                        /*Send ERROR packet to source */
                        tftp_error(TFTP_ERR_TID, UDP_SOURCE(udpframe));
                        break;
                    }
                }

                tcxn.exp_blocknum++;
            }
            else
            {
                #if defined(DEBUG_PRINT)
                    /* This is NOT the block number expected */
                    char buf[10];
                    Cconws("ACK Exp: ");
                    ltoa(buf, tcxn.exp_blocknum, 10);
                    Cconws(buf);
                    Cconws(", ACK Rcv: ");
                    ltoa(buf, tftp_pkt->data.blocknum, 10);
                    Cconws(buf);
                    Cconws("\r\n");
                #endif
            }
            
            /* Free the network buffer */
            nbuf_free(pNbuf);
            break;
        case TFTP_RRQ:
        case TFTP_WRQ:
        default:
            /* Free the network buffer */
            nbuf_free(pNbuf);
            break;
    }
}

/********************************************************************/
void
tftp_end (int success)
{
    /* 
     * Following a successful transfer the caller should pass in 
     * TRUE, there should have been no ERROR packets received, and 
     * the connection should have been marked as closed by the 
     * tftp_in_char() routine.
     */
    if (success && !tcxn.error && (tcxn.open == FALSE))
    {
//        char buf[10];
//        Cconws("\bTFTP transfer completed.\r\n");
//        Cconws("Read ");
//        ltoa(buf, tcxn.bytes_recv, 10);
//        Cconws(buf);
//        Cconws(" bytes (");        
//        ltoa(buf, tcxn.exp_blocknum - 1, 10);
//        Cconws(buf);
//        Cconws(" blocks)\r\n");
    }
    else
    {
//        char buf[10];
        /* Send error packet to stifle the server */
        tftp_error(TFTP_ERR_ILL, tcxn.server_port);
	      if(*tftp_string_error == 0)
            cat(" Errors in TFTP transfer.", tftp_string_error);
//        Cconws("Read ");
//        ltoa(buf, tcxn.bytes_recv, 10);
//        Cconws(buf);
//        Cconws(" bytes (");        
//        ltoa(buf, tcxn.exp_blocknum - 1, 10);
//        Cconws(buf);
//        Cconws(" blocks)\r\n");
    }

    /* Free up any buffers left in the queue */
    while (!queue_isempty(&tcxn.queue))
        nbuf_free((NBUF *)queue_remove(&tcxn.queue));

    /* Free the UDP port */
    udp_free_port(tcxn.my_port);
}

/********************************************************************/
int
tftp_write (NIF *nif, char *fn, IP_ADDR_P server, uint32 begin, uint32 end)
{
    DATA *data;
    NBUF *pNbuf;

    uint32 i, retries, bytes_to_send;
    uint16 blocknum, this_size;
    uint8 success, *current;
    int result = 0;
    *tftp_string_error = 0;

    if (fn == 0 || server == 0 || end < begin)
        return 0;

    /* Setup initial connection status */
    tcxn.nif = nif;
    tcxn.file = fn;
    tcxn.server_ip[0] = server[0];
    tcxn.server_ip[1] = server[1];
    tcxn.server_ip[2] = server[2];
    tcxn.server_ip[3] = server[3];
    tcxn.server_port = UDP_PORT_TFTP;
    tcxn.exp_blocknum = 0;
    tcxn.dir = TFTP_WRQ;
    tcxn.open = FALSE;
    tcxn.bytes_sent = 0;
    tcxn.error = FALSE;

    /* Use Mac address as pseudo-random port */
    udp_prime_port((uint16)((nif->hwa[4] << 8) | nif->hwa[5]));
    tcxn.my_port = udp_obtain_free_port();
    udp_bind_port(tcxn.my_port,&tftp_handler);

    retries = 4;
    success = FALSE;

    while (--retries)
    {
        /* Make the TFTP Read/Write Request */
        if (!tftp_rwrq())
        {
            cat("Error: Couldn't send TFTP Write Request", tftp_string_error);
            udp_free_port(tcxn.my_port);
            return FALSE;
        }

        timer_set_secs(TIMER_NETWORK, TFTP_TIMEOUT);
        while (timer_get_reference(TIMER_NETWORK))
        {
            /* Has the server responded */
            if (tcxn.open)
            {
                success = TRUE;
                break;
            }
        }

        /* If the connection is open, we are done here */
        if (success || tcxn.error)
            break;
    }
    if (!retries)
    {
	      if(*tftp_string_error == 0)
	          cat("TFTP could not make connection to server.", tftp_string_error);
        udp_free_port(tcxn.my_port);
        return FALSE;
    }
    else if (tcxn.error)
    {
	      if(*tftp_string_error == 0)
	          cat(" Errors in TFTP upload.", tftp_string_error);
        udp_free_port(tcxn.my_port);
        return FALSE;
    }

    bytes_to_send = end - begin;
    current = (uint8 *)begin;
    blocknum = 1;
    retries = 4;
    success = FALSE;

    while (--retries)
    {
        pNbuf = nbuf_alloc();
        if (pNbuf == NULL)
        {
            #if defined(DEBUG_PRINT)
                Cconws("TFTP: tftp_write() couldn't allocate Tx buffer\r\n");
            #endif
            return FALSE;
        }

        /* Build the packet */
        data = (DATA *)&pNbuf->data[TFTP_HDR_OFFSET];
        data->blocknum = blocknum;
        data->opcode = TFTP_DATA;

        this_size = (bytes_to_send > TFTP_PKTSIZE) ? \
                    TFTP_PKTSIZE : (uint16)bytes_to_send;

        for (i = 0; i < this_size; i++)
        {
            data->data[i] = current[i];
        }

        /* Set the packet length */
        pNbuf->length = (uint16)(4 + this_size);

        /* Attempt to send the packet */
        for (i=0; i<3; ++i)
        {
            result = udp_send(tcxn.nif, 
                              tcxn.server_ip, 
                              tcxn.my_port, 
                              tcxn.server_port, 
                              pNbuf);

            if (result == 1)
                break;
        }

        if (result == 0)
            nbuf_free(pNbuf);

        timer_set_secs(TIMER_NETWORK, TFTP_TIMEOUT);
        while (timer_get_reference(TIMER_NETWORK))
        {
            /* Has the server responded */
            if ((tcxn.exp_blocknum - 1) == blocknum)
            {
                success = TRUE;
                break;
            }
        }

        /* TFTP Write Compeleted successfully */
        if (success && (this_size < TFTP_PKTSIZE))
        {
            tcxn.bytes_sent += this_size;
            break;
        }

        if (tcxn.error)
            break;

        /* If an ACK was received, keep sending packets */
        if (success)
        {
            tcxn.bytes_sent += TFTP_PKTSIZE;
            bytes_to_send -= TFTP_PKTSIZE;
            current += TFTP_PKTSIZE;
            blocknum++;
            retries = 4;
            success = FALSE;
        }
    }
    if (tcxn.error)
    {
//        char buf[10];
//        Cconws("TFTP lost connection to server.\r\n");
//        Cconws("Sent ");
//        ltoa(buf, tcxn.bytes_sent, 10);
//        Cconws(buf);
//        Cconws(" bytes (");        
//        ltoa(buf, tcxn.exp_blocknum - 1, 10);
//        Cconws(buf);
//        Cconws(" blocks)\r\n");
        udp_free_port(tcxn.my_port);
        return FALSE;
    }
    else
    {
//        char buf[10];
//        Cconws("\bTFTP upload successful.\r\n");
//        Cconws("Sent ");
//        ltoa(buf, tcxn.bytes_sent, 10);
//        Cconws(buf);
//        Cconws(" bytes (");        
//        ltoa(buf, tcxn.exp_blocknum - 1, 10);
//        Cconws(buf);
//        Cconws(" blocks)\r\n");
        udp_free_port(tcxn.my_port);
        return TRUE;
    }
}

/********************************************************************/
int
tftp_read (NIF *nif, char *fn, IP_ADDR_P server)
{
    uint32 retries;
    
    *tftp_string_error = 0;
    if (fn == 0 || server == 0)
        return 0;

    /* Setup initial connection status */
    tcxn.nif = nif;
    tcxn.file = fn;
    tcxn.server_ip[0] = server[0];
    tcxn.server_ip[1] = server[1];
    tcxn.server_ip[2] = server[2];
    tcxn.server_ip[3] = server[3];
    tcxn.server_port = UDP_PORT_TFTP;
    tcxn.exp_blocknum = 1;
    tcxn.last_ack = 0;
    tcxn.dir = TFTP_RRQ;
    tcxn.open = FALSE;
    tcxn.bytes_recv = 0;
    tcxn.rem_bytes = 0;
    tcxn.next_char = NULL;
    tcxn.error = FALSE;
    queue_init(&tcxn.queue);

    /* Use Mac address as pseudo-random port */
    udp_prime_port((uint16)((nif->hwa[4] << 8) | nif->hwa[5]));
    tcxn.my_port = udp_obtain_free_port();
    udp_bind_port(tcxn.my_port,&tftp_handler);

    retries = 4;
    
    while (--retries)
    {
        /* Make the TFTP Read/Write Request */
        if (!tftp_rwrq())
        {
            cat("Error: Couldn't send TFTP Read Request", tftp_string_error);
            udp_free_port(tcxn.my_port);
            return FALSE;
        }
        
        timer_set_secs(TIMER_NETWORK, TFTP_TIMEOUT);
        while (timer_get_reference(TIMER_NETWORK))
        {
            /* Has the server responded */
            if (tcxn.open == TRUE)
                break;
        }

        /* If the connection is open, we are done here */
        if ((tcxn.open == TRUE) || tcxn.error)
            break;
    }

        
//        if(tcxn.open)
//           Cconws("TFTP server responded\r\n");
//        if(!tcxn.open)
//           Cconws("TFTP server not responded\r\n");


    if (!retries)
    {
	      if(*tftp_string_error == 0)
            cat("TFTP could not make connection to server.", tftp_string_error);
        udp_free_port(tcxn.my_port);
        return FALSE;
    }
    else if (tcxn.error)
    {
	      if(*tftp_string_error == 0)
	          cat(" Errors in TFTP download.", tftp_string_error);
        udp_free_port(tcxn.my_port);
        return FALSE;
    }
    else
        return TRUE;
}

/********************************************************************/
int
tftp_in_char (void)
{
    union TFTPpacket *tftp_pkt;
    int retval;
    NBUF *pNbuf;

    if (tcxn.next_char != NULL)
    {
        /* 
         * A buffer is already being worked on - grab next 
         * byte from it
         */
        retval = *tcxn.next_char++;
			
        if (--tcxn.rem_bytes <= 0)
        {
            /* The buffer is depleted; add it back to the free queue */
            pNbuf = (NBUF *)queue_remove(&tcxn.queue);
//            ASSERT(pNbuf);
            nbuf_free(pNbuf);
            tcxn.next_char = NULL;
        }
    }
    else
    {
        /* Is the connection still open? */
        if (tcxn.open == FALSE)
        {
            /*
             * The last packet has been received and the last data
             * buffer has been exhausted
             */
            retval = -1;
        }
        else
        {
            /* Get pointer to the next buffer */
            pNbuf = (NBUF *)queue_peek(&tcxn.queue);
            
            if (pNbuf == NULL)
            {
                int i;
                
                /* There was no buffer in the queue */
                for (i = 0; i < 3; ++i)
                {
                    timer_set_secs(TIMER_NETWORK, 1);
                    while (timer_get_reference(TIMER_NETWORK))
                    {
                        /* Has the server sent another DATA packet? */
                        if (!queue_isempty(&tcxn.queue))
                        {
                            pNbuf = (NBUF *)queue_peek(&tcxn.queue);
                            break;
                        }
                    }
                    if (pNbuf != NULL)
                        break;
                    
                    /* Ack the last packet again */
                    #ifdef DEBUG_PRINT
                    {
                        char buf[10];
                        Cconws("Re-acking ");
                        ltoa(buf, tcxn.last_ack - 1, 10);
                        Cconws(buf);
                        Cconws("\r\n");
                    }
                    #endif
                    retval = tftp_ack(tcxn.last_ack - 1);
//                    ASSERT(retval);
                }
            }
            if (pNbuf == NULL)
            {
                /* The server didn't respond with the expected packet */
                tcxn.open = FALSE;
                tcxn.error = TRUE;
                cat("TFTP lost connection to server.", tftp_string_error);
                retval = -1;
            }
            else
            {
                tftp_pkt = (union TFTPpacket *)&pNbuf->data[pNbuf->offset];

                /* Subtract the TFTP header from the data length */
                tcxn.rem_bytes = pNbuf->length - 4;

                /* Point to first data byte in the packet */
                tcxn.next_char = tftp_pkt->data.data;

                /* Save off the block number */
                tcxn.last_ack = tftp_pkt->data.blocknum;

                /* Check to see if this is the last packet of the transfer */
                if (tcxn.rem_bytes < TFTP_PKTSIZE)
                    tcxn.open = FALSE;

                /* Check for empty termination packet */
                if (tcxn.rem_bytes == 0)
                {
                    pNbuf = (NBUF *)queue_remove(&tcxn.queue);
//                    ASSERT(pNbuf);
                    nbuf_free(pNbuf);
                    tcxn.next_char = NULL;
                    retval = tftp_ack(tcxn.last_ack++);
//                    ASSERT(retval);
                    retval = -1;
                }
                else
                {
                    retval = tftp_ack(tcxn.last_ack++);
//                    ASSERT(retval);
                    retval = *tcxn.next_char++;

                    /* Check for a single byte packet */
                    if (--tcxn.rem_bytes == 0)
                    {
                        /* The buffer is depleted; add it back to the free queue */
                        pNbuf = (NBUF *)queue_remove(&tcxn.queue);
//                        ASSERT(pNbuf);
                        nbuf_free(pNbuf);
                        tcxn.next_char = NULL;
                    }
                }
            }
        }
    }
    return retval;
}
/********************************************************************/

char *tftp_get_error(void)
{
    return(tftp_string_error);
}

#endif /* LWIP */
#endif /* NETWORK */
