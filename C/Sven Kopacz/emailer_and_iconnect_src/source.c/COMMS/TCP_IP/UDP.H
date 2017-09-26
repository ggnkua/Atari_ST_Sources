#if !defined( __UDP__ )
#define __UDP__

typedef struct
{
	int		src_port;
	int		dst_port;
	int		len;
	uint	crc;
}udp_header;

typedef struct
{
	ulong				src_ip;
	ulong 			dst_ip;
	byte				zero;
	byte				protocol;
	int					len;
	udp_header	uph;
}udp_crc_header;

typedef struct _udp_rbuf
{/* Buffer for incoming UPD segment */
	struct _udp_rbuf	*next;
	
	int		dst_port;		/* Deliver segment to local port */
	int		src_port;		/* Port of sender */
	ulong	src_ip;			/* IP of sender */
	
	int		len;
	uchar	*buf;
}udp_rbuf;

int udp_open(int port);
int	udp_send(int src_port, int dst_port, ulong dst_ip, uchar *buf, int len);
int	udp_in(uchar *buf, uint len, ip_header *iph);
int udp_recv(int port, uchar *buf, int len, int peek, void *from, int *fromlen);
int udp_close(int port);
int udp_status(int port);
void udp_all_abort(void);

#endif