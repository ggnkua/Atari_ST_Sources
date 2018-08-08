/* File containing tables used by the PPP layer */
/* Based on RFC(s): 1549 */
#include "lattice.h"
#include "globdefs.h"
#include "ppp.h"
#include "ppp.p"

/********************************************************************/
/************************* Tables used at layer 1 *******************/
/********************************************************************/

/* Let's create the checksum table */
UWORD fcstab[256] = {
        0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf, 
        0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7, 
        0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e, 
        0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876, 
        0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd, 
        0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5, 
        0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c, 
        0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974, 
        0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb, 
        0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3, 
        0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a, 
        0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72, 
        0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9, 
        0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1, 
        0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738, 
        0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70, 
        0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7, 
        0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff, 
        0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036, 
        0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e, 
        0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5, 
        0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd, 
        0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134, 
        0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c, 
        0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3, 
        0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb, 
        0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232, 
        0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a, 
        0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1, 
        0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9, 
        0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
        0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78
};

/* Create the default async-control-character-maps */
/* For tx, anything less than 0x20, escape flag, end flag, and '+' (may
   get three in a row and kill the modem) */
ULONG tx_accm[8] = {0xffffffffL, 0x00000000L, 0x00000000L, 0x60000000L,
                    0x00000000L, 0x00000000L, 0x00000000L, 0x00000000L};

/* For rx, a single ULONG is all that's needed */
ULONG rx_accm[1] = {0xffffffffL};

/********************************************************************/
/************** Tables for used for LCP *****************************/
/********************************************************************/

/* Build up the state tables - events are built up below */
/* Note - we're using a reduced state machine since we're going out over */
/* modem.  This should be the majority of the users.  Anyone going out over */
/* a serial line probably has MintNet anyway.  I've tried to keep the states */
/* aligned with RFC 1661.  Please refer to RFC 1661 to make my code a little */
/* easier to understand. */

/* State 6 - the modem's up.  We don't handle a lot of events we need to (e.g.
   modem drop).  Fix it later - easy to add. */
SM_EVENT lcps6[] = { RESTART_TIMER, send_cfg_req,
                 CONFIGURE_REQUEST, sxconfigure_request,
                 CONFIGURE_ACK, s68configure_ack,
                 CONFIGURE_NACK, sxconfigure_nack,
                 CONFIGURE_REJECT, sxconfigure_nack,
                 TERMINATE_REQUEST, sxterminate_request,
                 TERMINATE_ACK, dummy,
                 CODE_REJECT, dummy,
                 PROTOCOL_REJECT, dummy,
                 ECHO_REQUEST, dummy,
                 ECHO_REPLY, dummy,
                 DISCARD_REQUEST, dummy,
				 IDENTIFICATION, dummy,
				 TIME_REMAINING, dummy,
				 LCP_CLOSE, s9close};

/* State 7 - we've gotten the configure ack, now wait for configuration request
   from the other end */
SM_EVENT lcps7[] = {RESTART_TIMER, sxup,
                 CONFIGURE_REQUEST, sxconfigure_request,
                 CONFIGURE_ACK, sxup,
                 CONFIGURE_NACK, sxconfigure_nack,
                 CONFIGURE_REJECT, sxconfigure_nack,
                 TERMINATE_REQUEST, sxterminate_request,
                 TERMINATE_ACK, reset_to6,
                 CODE_REJECT, reset_to6,
                 PROTOCOL_REJECT, reset_to6,
                 ECHO_REQUEST, dummy,
                 ECHO_REPLY, dummy,
                 DISCARD_REQUEST, dummy,
				 IDENTIFICATION, dummy,
				 TIME_REMAINING, dummy,
				 LCP_CLOSE, s9close};

/* State 8 - we've gotten the conguration request and sent the ack, now we're
   just waiting on our ack */
SM_EVENT lcps8[] = {RESTART_TIMER, send_cfg_req,
                 CONFIGURE_REQUEST, sxconfigure_request,
                 CONFIGURE_ACK, s68configure_ack,
                 CONFIGURE_NACK, sxconfigure_nack,
                 CONFIGURE_REJECT, sxconfigure_nack,
                 TERMINATE_REQUEST, sxterminate_request,
                 TERMINATE_ACK, dummy,
                 CODE_REJECT, dummy,
                 PROTOCOL_REJECT, dummy,
                 ECHO_REQUEST, dummy,
                 ECHO_REPLY, dummy,
                 DISCARD_REQUEST, dummy,
				 IDENTIFICATION, dummy,
				 TIME_REMAINING, dummy,
				 LCP_CLOSE, s9close};

/* State 9 - we're up!  Now wait for IP stuff */
SM_EVENT lcps9[] = {RESTART_TIMER, dummy,
                 CONFIGURE_REQUEST, sxconfigure_request,
                 CONFIGURE_ACK, sxup,
                 CONFIGURE_NACK, sxconfigure_nack,
                 CONFIGURE_REJECT, sxconfigure_nack,
                 TERMINATE_REQUEST, sxterminate_request,
                 TERMINATE_ACK, sxup,
                 CODE_REJECT, dummy,
                 PROTOCOL_REJECT, dummy,
                 ECHO_REQUEST, s9echo_request,
                 ECHO_REPLY, dummy,
                 DISCARD_REQUEST, dummy,
				 IDENTIFICATION, dummy,
				 TIME_REMAINING, dummy,
				 LCP_CLOSE, s9close};

SM_STATE lcp_machine[] = {lcps6, sizeof(lcps6)/sizeof(SM_EVENT),
                          lcps7, sizeof(lcps7)/sizeof(SM_EVENT),
                          lcps8, sizeof(lcps8)/sizeof(SM_EVENT),
                          lcps9, sizeof(lcps9)/sizeof(SM_EVENT)};

/* Table used to build/send the configuration request */
BUILD_TBL build_lcp_cfg [] = {
					invalid_build, /* reserved 0 */
					build_mru,
					build_accm,
					invalid_build, /* build_authprot */
					invalid_build, /* build_qualprot */
					build_magicnum,
					invalid_build, /* reserved 6 */
					build_pfc,
					build_acfc};
					
/* Table used to verify the configuration request */
VALIDATE_TBL valid_lcp_req_ftns [] = {
					invalid_opt, /* reserved 0 */
                    validate_mru,
                    validate_accm,
					validate_auth,
					invalid_opt, /* validate_qualprot, */
                    validate_magicnum,
                    invalid_opt, /* reserved 6 */
					validate_pfc,
					validate_acfc};

/* Table used to re-negotiate any parameters */
NEGOTIATE_TBL lcp_reneg_ftns [] = {
					no_neg, /* reserved 0 */
					new_mru,
					new_accm,
					no_neg, /* new_authprot, */
					no_neg, /* new_qualprot, */
					new_magicnum,
					no_neg, /* reserved 6 */
					no_neg, /* PFC */
					no_neg}; /* ACFC */

/* Table used to handle rejects */
NEGOTIATE_TBL reject_lcp [] = {
					reject_generic, /* reserved 0 */
					reject_mru,
					reject_generic, /* accm */
					reject_generic, /* authprot */
					reject_generic, /* qualprot */
					reject_magicnum,
					reject_generic, /* reserved 6 */
					reject_generic, /* pfc */
					reject_generic}; /* acfc */

/* Table used to handle the acknowledgement */
VALIDATE_TBL verify_lcp_ack_ftns [] = {
					invalid_opt, /* reserved 0 */
                    verify_mru,
                    verify_accm,
					invalid_opt, /* validate_authprot, */
					invalid_opt, /* validate_qualprot, */
                    verify_magicnum,
                    invalid_opt, /* reserved 6 */
					verify_pfc,
					verify_acfc};


/********************************************************************/
/**************** Tables for IPCP ***********************************/
/********************************************************************/
/* The state machine is actually a subset of the LCP state machine */
/* Just re-use it, but declare a smaller size (only the eight events */
/* are supported by IPCP) */
SM_STATE ipcp_machine[] = {lcps6, NUM_IPCP_EVENTS,
                          lcps7, NUM_IPCP_EVENTS,
                          lcps8, NUM_IPCP_EVENTS,
                          lcps9, NUM_IPCP_EVENTS};

/* Table used to build/send the IPCP configuration request */
BUILD_TBL build_ipcp_cfg [] = {
					invalid_build, /* Reserved 0 */
					invalid_build, /* IP addresses */
					invalid_build, /* compression */
					ip_address_txcfg};

/* Table used to verify an IPCP cfg ack */
VALIDATE_TBL verify_ipcp_ack_ftns[] = {
					invalid_opt, /* Reserved 0 */
					invalid_opt, /* IP addresses */
					invalid_opt, /* compression */
					verify_ip_addr};

/* Table used to verify a configuration request */
VALIDATE_TBL verify_ipcp_cfg_ftns[] = {
					invalid_opt, /* Reserved 0 */
					invalid_opt, /* IP addresses - not supported */
					invalid_opt, /* compression */
					validate_ispip};

/* Table used to re-negotiate any parameters */
NEGOTIATE_TBL ip_reneg_ftns[] = {
					no_neg, /* Reserved 0 */
					no_neg, /* IP addresses */
					no_neg, /* compression */
					new_ip};

/* Table used to handle rejects */
NEGOTIATE_TBL reject_ipcp[] = {
					reject_generic, /* Reserved 0 */
					reject_generic, /* IP addresses */
					reject_generic, /* Compression */
					reject_generic}; /* If we get this, then -someone- better
										get us an IP address */

/********************************************************************/
/**************** Tables for PAP ************************************/
/********************************************************************/
/* The state machine is actually a subset of the LCP state machine */
/* Just re-use it, but declare a smaller size (only the four events */
/* are supported by PAP) */

SM_STATE pap_machine[] = {lcps6, 0,
                          lcps7, 0, /* PAP doesn't use 6 or 7 */
                          lcps8, NUM_PAP_EVENTS,
                          lcps9, NUM_PAP_EVENTS};

/* Table used to build/send the PAP authentication request */
BUILD_TBL build_pap_cfg [] = {pap_authreq}; /* Only one PAP field */

/* Table used to verify a PAP AUTH ack */
/* Nothing really ack'd */
VALIDATE_TBL verify_pap_ack_ftns[] = {generic_verify};

/* Table used to verify a configuration request */
/* We should -never- see this */
VALIDATE_TBL verify_pap_cfg_ftns[] = {invalid_opt};

/* Table used to re-negotiate any NAK'd parameters */
/* If we get a NAK, the link dies anyway */
NEGOTIATE_TBL pap_reneg_ftns[] = {no_neg};

/* Table used to handle rejects */
/* PAP doesn't have rejects, but we need this table for completeness */
NEGOTIATE_TBL reject_pap[] = {reject_generic};

/**************************************************************************/
/*********************** Shared IPCP-LCP tables ***************************/
/**************************************************************************/
/* These tables are built of previously built tables of IPCP, PAP and
   LCP.  This allows us to keep the functions constant and only change
   the tables. */
/* Table to build a configuration request */
BUILD_TBL *build_options[] = {build_lcp_cfg, build_ipcp_cfg, build_pap_cfg};

/* Table to validate the configuration request from the ISP */
VALIDATE_TBL *check_cfg[] = {valid_lcp_req_ftns, verify_ipcp_cfg_ftns, verify_pap_cfg_ftns};

/* Table to re-negotiate Nak'd parameters */
NEGOTIATE_TBL *negot_params[] = {lcp_reneg_ftns, ip_reneg_ftns, pap_reneg_ftns};

/* Table to handle received rejects */
NEGOTIATE_TBL *rejected[] = {reject_lcp, reject_ipcp, reject_pap};

/* Table to verify what we sent we were ack'd */
VALIDATE_TBL *verify_contents[] = {verify_lcp_ack_ftns, verify_ipcp_ack_ftns, verify_pap_ack_ftns};

/* Relates a control protocol offset to the real protocol ID */
UWORD protocol_id[] = {LCP_PROTOCOL, IP_CTRL_PROTOCOL, PAP_PROTOCOL};

/* Allows a function to find the maximum number of legal options */
UBYTE max_options[] = {MAX_LCP_OPTIONS, MAX_IPCP_OPTIONS, MAX_PAP_OPTIONS};