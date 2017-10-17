

/* scsireq error bits */
#define S_BUSERROR		0x8000
#define S_BADSTATUS		0x4000
#define S_BADMESSAGE	0x2000
#define S_NOCONNECT		0x1000
#define S_TIMEOUT		0x0800
#define S_OVERRUN		0x0400
#define S_BADTRANS		0x0200


struct scsireq {
    char far *dptr;
    char far *cptr;
	unsigned dlen;
	char busid;
	int error;
	int timeout;
};

struct scsivreq {
    struct scsibuf far *bufptr;
    char far *cptr;
	char busid;
	int error;
	int timeout;
};

struct scsibuf {
    char far *dptr;
	unsigned dlen;
};


void scsiop(struct scsireq *req);
void scsiopv(struct scsivreq *req);

