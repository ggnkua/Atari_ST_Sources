/*  globdecl.h          (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *  Global declarations of functions
 *
 *  This should probably be the last header file included
 */
#ifndef _GLOBDECL_H_
#define _GLOBDECL_H_

/* functions to convert between host and network byte order (big endian) */
#define	ntohl(x)	(x)
#define	ntohs(x)	(x)
#define	htonl(x)	(x)
#define	htons(x)	(x)

/* functions in main.c          */
extern char * cdecl get_err_text(int16);
extern int16 cdecl on_port(char *port);
extern void  cdecl off_port(char *port);
extern int16 cdecl query_port(char *port);

/* functions in config.c        */
extern int16 equ_txtn(char *, char *, int16);
extern int16 init_cfg(char *);
extern char * cdecl getvstr(char *);
extern int16 cdecl setvstr(char *vs, char *value);
extern long init_drivers(void);
extern void (*prot_in)(void);
extern void (*prot_out)(void);
extern void (*prot_kicker)(void);
extern void (*prot_term)(void);
extern void (*yield)(void);

/*  Dial and Modem control functions in dialer.c    */
extern int16 cdecl carrier_detect(void);
extern clock_t msclock(void);
extern int16 cdecl dial(char *);
extern void cdecl ser_disable(void);
extern void cdecl ser_enable(void);

/* Packet functions in packet.c */
#if MEMDEBUG
extern GPKT *allocate_packet(uint16, const char *file, int line);
extern void delete_packet(GPKT *, int16, const char *file, int line);
#define allocate_packet(s) allocate_packet(s, __FILE__, __LINE__)
#define delete_packet(s, t) delete_packet(s, t, __FILE__, __LINE__)
#else
extern GPKT *allocate_packet(uint16);
extern void delete_packet(GPKT *, int16);
#endif

/* Raw IO functions in slip.c   */
extern 	void slip_in(void);
extern 	void slip_out(void);
extern long slc_uncompress (GPKT *b, octet type, struct slcompress *comp);
extern unsigned char slc_compress (GPKT *b,	struct slcompress *comp, long compress_cid);
extern short uncompress(GPKT *b, struct slip *slp);
extern octet slc_type (GPKT *b);
extern uint16 chksum(char *p, uint16 count);

/* output queue function in slip.c  */
extern void output_packet(GPKT *);
extern GPKT *get_outpacket(void);

/* PPP Functions */
extern void ppp_in(void);
extern void ppp_out(void);
extern void ppp_kicker(void);
extern void ppp_term(void);

/* various functions in ip.c    */
extern void ip_in(GPKT *);
extern void ip_send(GPKT *, struct ip_options *, uint16);
extern uint16 oc_sum(char *, uint16);
extern uint16 calc_sum(char *, uint16, uint16);
extern GPKT *mkpacket(uint32, int16, int16);
extern int ping(uint32, int16, int16, char *, int16);
extern void frag_ttl_check(void);
extern void ICMP_err_return(GPKT *, int16, int16);

/*  Various functions in tcpin.c  */
extern void tcp_in(GPKT *, TCP_HDR *);
extern void tcp_icmp(uint32, uint8, uint8, TCP_HDR *, uint32);
extern clock_t set_time(clock_t);
extern struct tcp_rtt *rtt_get(int32);
extern void close_self(int16, TCB *);

/*  Various functions in tcpout.c  */
extern int16 tcp_output(int16);
extern int16 cdecl TCP_send(int16, char *, int16);
extern int16 cdecl TCP_open(uint32, int16, int16, uint16);
extern int16 cdecl TCP_close(int16, int16);
extern int16 cdecl TCP_wait_state(int16, int16, int16);
extern int16 cdecl TCP_ack_wait(int16, int16);
extern int16 cdecl CNkick(int16);

/* functions in icmp.c */
extern int16 cdecl ICMP_send(uint32, uint8, uint8, void *, uint16);
extern int16 cdecl ICMP_handler(void *, int16);
extern void cdecl ICMP_discard(GPKT *);

/* functions in input.c         */
extern void init_ports(void);
extern int16 start_icmp_listen(void *, int16);
extern int16 stop_icmp_listen(void);
extern void q_icmp_reply(GPKT *);
extern GPKT *get_icmp(void);
extern int16 cdecl UDP_open(uint32, int16);
extern int16 CNopen(void);
extern int16 cdecl UDP_close(int16);
extern void CNclose(int16);
extern void cdecl CNfree_NDB(int16, NDB *);
extern void intfree_NDB(NDB*);
extern CCB * cdecl CNgetinfo(int16);
extern int16 cdecl CNbyte_count(int16);
extern NDB * cdecl CNget_NDB(int16);
extern int16 cdecl CNget_char(int16);
extern int16 cdecl CNget_block(int16,char *,int16);
extern int16 cdecl CNgets(int16, char *, int16, char *);
extern void q_udp_in(GPKT *, UDP_HDR *);
extern int16 CNget_cn(GPKT *);
extern int16 CNlookup_cn(int16, int16, int32);
extern void q_tcp_in(int16, GPKT *);
extern void cdecl housekeep(void);

/* functions in ping.c          */
/*extern void start_ping(void);*/

/* functions in sockopt.c */
extern int16 cdecl CN_setopt(int16, int16, const void *, int16);
extern int16 cdecl CN_getopt(int16, int16, void *, int16 *);

/* functions in udp.c           */
extern void udp_in(GPKT *, UDP_HDR *);
extern int16 cdecl UDP_send(int16, char *, int16);

/* Flagbox functions		*/
extern int16 cdecl set_flag(int16);
extern int16 cdecl test_flag(int16);
extern void  cdecl clear_flag(int16);

/* Interrupt functions */

extern clock_t	Sclock(void);	/* call only from the interrupt */
extern void dummyfn(void);		/* dummy function for function ptrs */

/* in CSLIP.O */
/*extern long slc_unco (GPKT *b, octet type, struct slcompress *comp);
extern uint16 VJ_deco(void **cpp);
extern unsigned char slc_comp (GPKT *b,	struct slcompress *comp, long compress_cid);
extern short uncompre (GPKT *b, struct slip *slp);
extern octet slc_type (GPKT *b);
extern void VJ_enco(void **cpp, uint16 data);*/

/* RAW IP functions */
extern int16 cdecl RAW_open(uint32 rhost);
extern int16 cdecl RAW_close(int16 cn);
extern void RAW_in(GPKT *data);
extern int16 cdecl RAW_out(int16 cn, void *data, int16, uint32);

/* STATUS TPL routines */
extern long *cdecl get_elog(void);
extern PPP_ST *cdecl query_state(void);  /* bottom of statemch.c */

/* in APPLYELD.S */
extern void _appl_yield(void);

/* in IDENTD.C */
extern void do_identd(GPKT *blk);

/* in NEWRESOLVE.C */
extern int16 cdecl Set_DNS(char *dns);

/* in STNGCOMP.C */
extern int16 cdecl TCP_info(int16 cn, TCPIB *data);
extern int16 cdecl UDP_info(int16 cn, void *data);
extern int16 cdecl cntrl_port(char *, uint32, int16);
#endif 
/* _GLOBDECL_H_ */
