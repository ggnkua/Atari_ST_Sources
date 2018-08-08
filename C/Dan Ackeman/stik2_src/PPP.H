/********************************************************************/
/********************* Defines **************************************/
/********************************************************************/
#ifndef _PPP_H_
#define _PPP_H_

/* Some convenient defines */
#ifndef _LATTICE_H_
#define UWORD unsigned short
#define BYTE signed char
#define WORD signed short
#define LONG signed long
#endif

#define UBYTE unsigned char
#define ULONG unsigned long

#define OK 0
#define FAIL 0xffffffffL /* Actually, -1 */
#define DEBUG 0
/* #define LATTICE_TEST 0 */

#define TICK 5 /* Number of milliseconds in a tick */

#define FRAME_OVERHEAD 8

/************** RFC 1549 Field Def's *******************/
#define FLAG_END 0x7e
#define FLAG_ESC 0x7d
#define ACCM_MASK 0x20
#define ADDRESS 0xff
#define CONTROL 3

/********************** Compression related stuff ***************/
/* Tells us if a bit is the last bit of the protocol */
#define LAST_OCTET_BIT 1

/****************** ACCM stuff (most from ppp.c) ****************/
#define MAX_MASK 0x1f
#define MAP_ZERO(map) (memset(map, NULL, sizeof(map))
#define MAP_SET(map, to_esc) ((map[(UBYTE)(to_esc)>>5]) |= \
                                1L << ((to_esc)&MAX_MASK))
#define MAP_CLR(map, to_clr) ((map[(UBYTE)(to_clr)>>5]) &= \
                                ~(1L << ((to_clr)&MAX_MASK)))
#define MAP_ISSET(map, chk) ((map[(UBYTE)(chk)>>5]) & \
                                (1L << ((chk)&MAX_MASK)))

/*********************  Checksum parameters **************************/
#define PPP_FCS_INIT 0xffff
#define PPP_FCS_GOOD 0xf0b8

/* Define to update checksum on the fly */
#define UPDATE_FCS(frame_check, newguy) (frame_check) = ((frame_check) >> 8)\
             ^ fcstab[((frame_check) ^ (newguy)) & 0xff]


/********************  Protocls we support ****************************/
#define IP_PROTOCOL 0x0021       /* What app data arrives in */
#define IP_CTRL_PROTOCOL 0x8021  /* Negotation of IP stuff */
#define IPCP_OFFSET 1			 /* Offset into all arrays */
#define LCP_PROTOCOL 0xc021      /* Negotiation of PPP stuff */
#define LCP_OFFSET 0			 /* Offset into all arrays */
#define	PAP_PROTOCOL 0xc023		 /* Negotiation of PAP stuff */
#define	CHAP_PROTOCOL 0xc223	 /* Negotiation of PAP stuff */
#define	PAP_OFFSET 2			 /* Offset into all arrays */
#define INTERNAL_PROTOCOL 0xffff /* Used to send internal messages only */
/* Others coming RSN! */

/**************************** LCP Events ****************************/
#define CONFIGURE_REQUEST 1
#define CONFIGURE_ACK     2
#define CONFIGURE_NACK    3
#define CONFIGURE_REJECT  4
#define TERMINATE_REQUEST 5
#define TERMINATE_ACK     6
#define CODE_REJECT       7
#define PROTOCOL_REJECT   8
#define ECHO_REQUEST      9
#define ECHO_REPLY        10
#define DISCARD_REQUEST   11
#define IDENTIFICATION    12
#define TIME_REMAINING    13

/************************** LCP Config Options ***********************/
#define RESERVED_0 0
#define MAXIMUM_RECEIVE_UNIT_ID  1
#define  MRU_LENGTH 4

#define ASYNC_CONTROL_CHAR_MAP_ID 2
#define ACCM_LENGTH 6

#define AUTHENTICATION_PROTOCOL_ID 3
#define AUTH_PROT_PAP_LEN 4
#define AUTH_PROT_CHAP_LEN 5

#define QUALITY_PROTOCOL_ID 4
#define QUAL_PROT_BASE_LEN 4

#define MAGIC_NUMBER_ID     5
#define MAG_NUM_LEN      6

#define RESERVED_6 6

#define PROTOCOL_FLD_COMPRESSION_ID 7
#define PFC_LEN 2

#define ADDR_AND_CTRL_FLD_COMP_ID 8
#define ADD_CTRL_LEN 2

#define MAX_LCP_OPTIONS 8
/*#define MAX_LCP_OPTIONS 14*/

/************************** Internal Events ************************/
#define RESTART_TIMER     0
#define LCP_CLOSE         14

/****************************** IPCP Events *******************************/
#define IP_COMPRESSION_PROTOCOL 2
#define IP_ADDRESS              3
#define IP_ADDRESS_LEN			6
#define MAX_IPCP_OPTIONS		3

/****************************** PAP Events *************************/
#define	MAX_PAP_OPTIONS	0

/***************************** state machine related data **************/
/* List out the states */
typedef enum { 
			  S6 = 0,
			  S7 = 1,
			  S8 = 2,
			  S9 = 3} STATES;

#define NUM_MACHINES 3 /* Number of state machines */
#define STATE_TIMEOUT 3

#define GET_UNIQUE_ID current_id++
#define DEFAULT_MRU 1500
#define DEFAULT_ACCM 0L
#define DEFAULT_MAGNUM 0xdeadbeefL
#define DEFAULT_LCP_SENDOPT ((1<< MAXIMUM_RECEIVE_UNIT_ID) | \
						 (1<< ASYNC_CONTROL_CHAR_MAP_ID) | \
						 (1<< MAGIC_NUMBER_ID))
#define DEFAULT_IPCP_SENDOPT (1 << IP_ADDRESS)
/* No options with PAP, so just use zero to build message */
#define	DEFAULT_PAP_SENDOPT (1)

#define NUM_IPCP_EVENTS 8
#define	NUM_PAP_EVENTS	4
/********************************************************************/
/*********************** Structures *********************************/
/********************************************************************/

/********************* State machine structures *********************/
/* Information the state machine needs to know */
typedef struct {
    STATES cur_state[NUM_MACHINES]; /* Current states */
    ULONG magic_number; /* Magic number */
    UWORD auth_prot; /* Authentication protocol */
    UBYTE identifier; /* Match request/replies */
	UWORD send_opt[NUM_MACHINES];	/* Options to send */
	UWORD req_mru;	/* Requested MRU */
	ULONG req_accm; /* Requested ACCM */
	ULONG req_magicnum; /* Requested Magic number */
	ULONG req_local_ip; /* Request local IP address */
} STATE_DATA;

typedef struct {
    UBYTE event;
    void (*action)(STATE_DATA *state, UBYTE *new_msg, UWORD protocol);
} SM_EVENT;

typedef struct {
    SM_EVENT *events;
    UBYTE num_events; /* Zero based */
} SM_STATE;

/* To build the configuration request */
typedef struct {
	ULONG (*action)(STATE_DATA *state, UBYTE *option);
} BUILD_TBL;

/* Table to parse through the options */
typedef struct {
    ULONG (*action)(STATE_DATA *state, UBYTE *option_data);
} VALIDATE_TBL;

/* To negotiate any rejected options */
typedef struct {
	void (*action)(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset);
} NEGOTIATE_TBL;

/********************** LCP Structures ******************************/
/* First the LCP headers */
/* General LCP Header */
typedef struct {
    UBYTE code;
    UBYTE identifier;
    UWORD length;
} LCP_HEADER;

/* Protocol reject header */
typedef struct {
    LCP_HEADER base_header;
    UWORD rej_protocol;
} PROT_REJ_HEADER;

/* Test (echo or discard) header */
typedef struct {
    LCP_HEADER base_header;
    ULONG magic_number;
} ECHO_HEADER;

/* Now the LCP Option fields */
/* MRU */
typedef struct {
    UBYTE type;
    UBYTE length;
    UWORD mru;
} MRU_OPT;

/* ACCM (only in RFC 1548?) */
typedef struct {
    UBYTE type;
    UBYTE length;
    ULONG accm;
} ACCM_OPT;

/* Authentication protocol */
typedef struct {
    UBYTE type;
    UBYTE length;
    UWORD auth_prot;
    UBYTE *data;
} AUTH_PROT_OPT;

/* Quality protocol */
typedef struct {
    UBYTE type;
    UBYTE length;
    UWORD qual_prot;
    UBYTE *data;
} QUAL_PROT_OPT;

/* Magic number */
typedef struct {
    UBYTE type;
    UBYTE length;
    ULONG magic_num;
} MAG_OPT;

/* Protocol or address & control field compression */
typedef struct {
    UBYTE type;
    UBYTE length;
} COMPR_OPT;

/* IPCP option fields */
/* IP address */
typedef struct {
	UBYTE type;
	UBYTE length;
	ULONG ip_address;
} IP_ADDR_OPT;

#endif /* _PPP_H_ */
