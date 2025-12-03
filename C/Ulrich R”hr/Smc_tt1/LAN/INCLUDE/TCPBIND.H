#define get_ip_addr(a,b)		gemdos(612,a,b)
#define tcp_open(a,b,c,d,e)		gemdos(630,a,b,c,d,e)
#define tcp_write(a,b,c,d,e)	gemdos(631,a,b,c,(char)d,(char)e)
#define tcp_read(a,b,c)			gemdos(632,a,b,c)
#define	tcp_close(a)			gemdos(633,a)
#define tcp_abort(a)			gemdos(634,a)
#define tcp_stat(a,b)			gemdos(635,a,b)
#define udp_open(a)				gemdos(620,a)
#define udp_close(a)			gemdos(621,a)
#define udp_read(a,b,c)			gemdos(622,a,b,c)
#define udp_write(a,b,c,d)		gemdos(623,a,b,c,d)
#define udp_open_callback(a,b)	gemdos(624,a,b)

typedef struct sdest
{
	unsigned int		Port;
	unsigned char		IPAddr[4];
} DESTI;

typedef struct
{
	unsigned int		Port;
	unsigned long		IPAddr;
} DESTIL;

typedef int (*UDP_UPCALL)(char *pkt,short len, DESTIL *dest);
