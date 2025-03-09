typedef struct 
{
	int	(*SENDE)(int an,int LEN,char *buff);
	int	(*REPLY)(int LEN,char *buff);
	int	(*LESE)(int *len,char *buff);
	int	(*CMD)(int cmd,int *par1,int *par2);
	char	*unused2;
}io_port;

typedef struct
{
	int		sync_id;
	boolean	s_status;
	boolean	broken;
	char	tnum;
	char    fill;
}status;


typedef struct
{
	int	frei:8;
	int	erg:2;
	int	doubl:1;
	int	reply:1;
	int	von:4;
}r_wert;

typedef union bit_conv
{
	int		as_int;
	r_wert	as_bits;
}bit_conv;


#define RFALSE	0x0000
#define RTRUE	0x0040
#define RFAIL	0x00C0

typedef struct
{
	int	size;
	char	id;
	char	von;
	int	an;
	unsigned int	crc_data;
	unsigned int	crc_head;
	char	*buff;
} packet;


#define BP _BasPag



bit_conv	return_wert;
packet	rpacket={0,0,0,0,0,0,0};
char	buffer[4900];
int	SENDER(int an,int LEN,char *buff);
int	REPLY(int LEN,char *buff);
int	READER(int *len,char *buff);
int	CMD(int cmd,int *par1,int *par2);
char		my_num=7;
int			STATE=0;
boolean		num_locked=FALSE;
boolean		new_sync=FALSE;
boolean  	sync_rast=FALSE;
boolean  	XREPLY=FALSE;
int			last_sync;
unsigned long		last_msg;
int			time_out=4;
status	state={0,FALSE,FALSE,0,0};
io_port  port={SENDER,REPLY,READER,CMD,NULL};
packet	spacket={0,0,0,0,0,0,buffer};
