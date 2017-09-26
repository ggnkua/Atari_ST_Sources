#if  !defined( __IP__ )
#define __IP__

typedef struct
{
	byte		version_IHL;	/* flags : 4, IHL : 4 */
	
	#define IP_IHL 15
	
	byte		TOS;
	uint		total_len;
	int			id;

	uint		flags_frag_off;		/* flags :	3, frag_off : 13 */

	#define IP_FRAGOFF 4095 /* bin-and to get offset */
	#define IP_ZR (1<<15)		/* flag reserved, must be zero */
	#define	IP_DF	(1<<14)		/* don't fragment flag */
	#define IP_MF (1<<13)		/* More fragments flag */
	
	byte		TTL;
	byte		protocol;
	
	uint		crc;
	
	ulong		src_ip;
	ulong		dst_ip;
	ulong		options[0];
}ip_header;

typedef struct	_ip_buffer
{
	struct		_ip_buffer	*next;
	ulong			bid[4];	/* src,dst,id,prot */
	long			timer;	/* delete buffer if zero */
	ip_header	*iph_0;	/* Header of frag # 0 */

	uint			to_receive;	/* Bytes to receive */
	uint			received;		/* Bytes received. If equal, all frags are here */
	uint			len;
	uchar			*buf;
}ip_buffer;

typedef struct _localhost_queue
{
	struct _localhost_queue *next;
	ip_header	*buf;
}localhost_queue;

int	ip_send(ulong	src_ip, ulong	dst_ip, byte protocol, byte	TOS, byte TTL, uchar *buf, uint len, int id, int flags, ulong *options, uint opt_len);
int	ip_recv(uchar	*buf, uint len, byte protocol, ip_header *iph);
void ip_in(void *buf, uint len);
void ip_timer_jobs(void);
void ip_abort(void);

#endif