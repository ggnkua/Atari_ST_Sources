/* Structures for external TCP access	*/
struct TPL {
	char	*module;
	char	*author;
	char	*version;	/* Format 00.00	*/
	char  *	cdecl (*KRmalloc)(int32);
	void 	cdecl (*KRfree)(char *);
	int32	cdecl (*KRgetfree)(int16 x);
	char  * cdecl (*KRrealloc)(char *, int32);
	char  *	cdecl (*get_err_text)(int16);
	char  * cdecl (*getvstr)(char *);
	int16	cdecl (*carrier_detect)(void);
	int16	cdecl (*TCP_open)(uint32, int16, int16, uint16);
	int16	cdecl (*TCP_close)(int16, int16);
	int16	cdecl (*TCP_send)(int16, char *, int16);
	int16	cdecl (*TCP_wait_state)(int16, int16, int16);
	int16	cdecl (*TCP_ack_wait)(int16, int16);
	int16	cdecl (*UDP_open)(uint32, int16);
	int16	cdecl (*UDP_close)(int16);
	int16	cdecl (*UDP_send)(int16, char *, int16);
	int16	cdecl (*CNkick)(int16);
	int16	cdecl (*CNbyte_count)(int16);
	int16	cdecl (*CNget_char)(int16);
	NDB   * cdecl (*CNget_NDB)(int16);
	int16	cdecl (*CNget_block)(int16, char *, int16);
	void	cdecl (*housekeep)(void);
	int16	cdecl (*resolve)(char *, char **, uint32 *, int16);
	void	cdecl (*ser_disable)(void);
	void	cdecl (*ser_enable)(void);
	int16	cdecl (*set_flag)(int16);
	void	cdecl (*clear_flag)(int16);
	CCB   * cdecl (*CNgetinfo)(int16);
	int16 	cdecl (*on_port)(char *port);
	void 	cdecl (*off_port)(char *port);
	int16   cdecl (*setvstr)(char *vs, char *value);
	int16	cdecl (*query_port)(char *port);
	int16	cdecl (*CNgets)(int16, char *, int16, char *);
	int16	cdecl (*ICMP_send)(uint32, uint8, uint8, void *, uint16);
	int16	cdecl (*ICMP_handler)(void *,int16);
	void	cdecl (*ICMP_discard)(GPKT *);
	int16   cdecl (*TCP_info)(int16, TCPIB *);
	int16   cdecl (*cntrl_port)(char *, uint32, int16);
	int16   cdecl (*UDP_info)(int16, void *);
	int16	cdecl (*RAW_open)(uint32);
	int16	cdecl (*RAW_close)(int16);
	int16	cdecl (*RAW_out)(int16, void *, int16, uint32);
	int16	cdecl (*CN_setopt)(int16, int16, const void *, int16);
	int16	cdecl (*CN_getopt)(int16, int16, void *, int16 *);
	void	cdecl (*CNfree_NDB)(int16, NDB *);
};

/*  status structure/functions   */

struct STATUS_TPL 
{
    char    *module;    /* specific string that can be searched for */
    char    *author;    /* Any string                               */
    char    *version;   /* Format `00.00' Version:Revision          */
    long  * cdecl (*get_elog)(void);
	PPP_ST * cdecl (*query_state)(void);
	int16   cdecl (*Set_DNS)(char *);
};
    