/*	asyn_init(), asyn_read(), asyn_write(), asyn_ioctl(),
 *	asyn_wait(), asyn_synch(), asyn_close()
 *							Author: Kees J. Bot
 *								26 Jan 1995
 * Thise are just stub routines that are call compatible with
 * the asynchio(3) library of Minix-vmd.  See asynchio.h.
 */
#define nil 0
#define alarm	_alarm
#define ioctl	_ioctl
#define read	_read
#define sigaction _sigaction
#define sigfillset _sigfillset
#define time	_time
#define write	_write
#include <lib.h>
#include <sys/ioctl.h>
#include <sys/asynchio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <signal.h>

#define IDLE		0
#define INPROGRESS	1
#define RESULT		2

#define OP_READ		0
#define OP_WRITE	1
#define OP_IOCTL	2

static int *asyn_current;
static int asyn_op;
static int asyn_fd;
static int asyn_req;
static void *asyn_data;
static ssize_t asyn_count;
static int asyn_errno;

void asyn_init(asynchio_t *asyn)
{
	*asyn= IDLE;
}

static ssize_t operation(int op, asynchio_t *asyn, int fd, int req,
						void *data, ssize_t count)
{
	switch (*asyn) {
	case INPROGRESS:
		if (asyn_current != asyn && asyn_op != op) abort();
		/*FALL THROUGH*/
	case IDLE:
		asyn_current= asyn;
		asyn_op= op;
		asyn_fd= fd;
		asyn_req= req;
		asyn_data= data;
		asyn_count= count;
		*asyn= INPROGRESS;
		errno= EINPROGRESS;
		return -1;
	case RESULT:
		if (asyn_current != asyn && asyn_op != op) abort();
		*asyn= IDLE;
		errno= asyn_errno;
		return asyn_count;
	}
}

ssize_t asyn_read(asynchio_t *asyn, int fd, void *buf, size_t len)
{
	return operation(OP_READ, asyn, fd, 0, buf, len);
}

ssize_t asyn_write(asynchio_t *asyn, int fd, const void *buf, size_t len)
{
	return operation(OP_WRITE, asyn, fd, 0, (void *) buf, len);
}

int asyn_ioctl(asynchio_t *asyn, int fd, unsigned long request, void *data)
{
	return operation(OP_IOCTL, asyn, fd, request, data, 0);
}

static void time_out(int sig)
{
	alarm(1);
}

int asyn_wait(asynchio_t *asyn, int flags, struct timeval *to)
{
	time_t now;
	unsigned old_timer, new_timer;
	struct sigaction old_sa, new_sa;

	if (*asyn == IDLE) return 0;
	if (asyn_current != asyn || *asyn != INPROGRESS) abort();
	if (flags & ASYN_NONBLOCK) abort();

	if (to != nil) {
		now= time(nil);
		if (to->tv_sec <= now) { errno= EINTR; return -1; }
		old_timer= alarm(0);
		new_sa.sa_handler= time_out;
		sigfillset(&new_sa.sa_mask);
		new_sa.sa_flags= 0;
		sigaction(SIGALRM, &new_sa, &old_sa);
		new_timer= to->tv_sec - now;
		if (new_timer < old_timer) {
			new_timer= old_timer;
		}
		alarm(new_timer);
	}
	switch (asyn_op) {
	case OP_READ:
		asyn_count= read(asyn_fd, asyn_data, asyn_count);
		asyn_errno= errno;
		break;
	case OP_WRITE:
		asyn_count= write(asyn_fd, asyn_data, asyn_count);
		asyn_errno= errno;
		break;
	case OP_IOCTL:
		asyn_count= ioctl(asyn_fd, asyn_req, asyn_data);
		asyn_errno= errno;
		break;
	}
	if (to != nil) {
		alarm(0);
		sigaction(SIGALRM, &old_sa, (struct sigaction *)0);
		alarm(old_timer);
	}

	if (asyn_count == -1 && asyn_errno == EINTR) {
		errno= EINTR;
		return -1;
	} else {
		*asyn= RESULT;
		return 0;
	}
}

int asyn_synch(asynchio_t *asyn, int fd)
{
}

int asyn_close(asynchio_t *asyn, int fd)
{
	*asyn= IDLE;
}
