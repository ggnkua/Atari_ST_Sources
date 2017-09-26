#if  !defined( __SLIP__ )
#define __SLIP__

typedef struct	_slip_buf
{
	struct _slip_buf 	*next;
	uint							len;
	uchar							*buf;
}slip_buf;

int	slip_send(uchar	*buf, uint	len);
int	slip_recv(uchar	*buf, uint len);
void slip_in(uchar *buf, uint len);
void slip_out(void);
void slip_timer_jobs(void);
void slip_abort(void);

/* ms to wait between buffers when pushing them on abort */
#define ABORT_FREQ 200
/* Maximum retries on one buffer */
#define ABORT_RETRY 5
/* If retries fail, delete all other buffers too? */
#define ABORT_IMMED 1

#endif