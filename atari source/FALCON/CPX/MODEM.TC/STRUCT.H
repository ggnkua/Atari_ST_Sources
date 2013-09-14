
#define Max_Ports  4

typedef struct _modem_data
{
   int cur_baud;
   int cur_parity;
   int cur_bits;
   int cur_flow;
   int cur_stop;
}MDATA;

typedef struct _buffer
{
  int cur_baud;
  int cur_flow;
}BUFFER;  


typedef struct _mdefault
{
  int	cur_port;	/* Current port to use as default 0,1,2,3 */
  MDATA modem[ Max_Ports ];	/* SHould be same as MAX_PORTS */
} MDEFAULT;
