*      transprt.h        (c) Steve Adam 1995   steve@netinfo.com.au
*      transprt.s        Goof 1996 arcovang@caiw.nl
*
*      Include this file to use functions from the tcp module.
*      ie: tcp/udp, etc....


	section data
TRANSPORT_DRIVER	dc.b	"TRANSPORT_TCPIP",0
TCP_DRIVER_VERSION	dc.b	"01.07",0
	even
	section text
** TCP connection states    
TCLOSED		equ 	0   ;No connection.  Null, void, absent, .....        */
TLISTEN		equ 	1   ; Wait for remote request.                         */
TSYN_SENT	equ 	2   ; Connect request sent.  Await matching request    */
TSYN_RECV	equ 	3   ; Wait for connection ACK.  (Listener only??)      */
TESTABLISH	equ 	4   ; Connection is established.  Handshake completed  */
TFIN_WAIT1	equ 	5   ; Await termination request or acknowledgement     */
TFIN_WAIT2	equ 	6   ; Await termination request.                       */
TCLOSE_WAIT	equ 	7   ; Await termination request from local user        */
TCLOSING	equ 	8   ; Await termination acknowledge from remote TCP    */
TLAST_ACK	equ 	9   ; Await acknowledgement of terminate request sent  */
TTIME_WAIT	equ 	10   ; Delay to ensure remote has received term' ACK    */
* TCP and connection ERROR states. */
E_NORMAL	equ 	0	; No error occured...                      */
E_OBUFFULL	equ 	-1	; Output buffer is full                    */
E_NODATA	equ 	-2	; No data available.                       */
E_EOF		equ 	-3	; EOF from remote..						*/
E_RRESET	equ 	-4	; RST received from remote.                */
E_UA		equ 	-5	; RST.  Other end sent unacceptable pkt    */
E_NOMEM		equ 	-6	; Something failed due to lack of memory   */
E_REFUSE	equ 	-7	; Connection refused by remote             */
E_BADSYN	equ 	-8	; A SYN was received in the window         */
E_BADHANDLE	equ 	-9	; Bad connection handle used.              */
E_LISTEN	equ 	-10	; The connection is in LISTEN state        */
E_NOCCB		equ 	-11	; No free CCB's available                  */
E_NOCONNECTION	equ 	-12	; No connection matches this packet. (TCP) */
E_CONNECTFAIL	equ 	-13	; Failure to connect to remote port. (TCP) */
E_BADCLOSE	equ 	-14	; Invalid TCP_close() requested            */
E_USERTIMEOUT	equ 	-15	; A user function timed out                */
E_CNTIMEOUT	equ 	-16	; A the connection timed out               */
E_CANTRESOLVE	equ 	-17	; Can't resolve the hostname               */
E_BADDNAME	equ 	-18	; Domain name or Dotted Dec.  bad format   */
E_LOSTCARRIER	equ 	-19	; The modem disconnected                   */
E_NOHOSTNAME	equ 	-20	; Hostname does not exist                  */
E_DNSWORKLIMIT	equ 	-21	; Resolver Work limit reached              */
E_NONAMESERVER	equ 	-22	; No nameservers could be found for query  */
E_DNSBADFORMAT	equ 	-23	; Bad format of DS query                   */
E_UNREACHABLE	equ 	-24	; Destination unreachable                  */
E_DNSNOADDR	equ 	-25	; No address records exist for host        */
E_LASTERROR	equ 	25	; ABS of last error code in this list      */

* FLagbox Flag definitions	(max 64 flags...) */
FL_do_resolve	equ 	0
FL_housekeep	equ 	1


; Input queue structures   */

;typedef struct ndb {    ;  Network Data Block.  For data delivery      */
;    char        *ptr;   ; Pointer to base of block. (For KRfree();)    */
;    char        *ndata; ; Pointer to next data to deliver              */
;    uint16      len;    ; Length of remaining data.                    */
;    struct ndb  *next;  ; Next NDB in chain or NULL                    */
;} NDB;


; Connection information block	*/

;typedef struct cib {        ; Connection Information Block.    */
;    uint16      protocol;   ; TCP or UDP or ... 0 means CIB not in use */
;    uint16      lport;      ; TCP client port.  (ie: At this machine)  */
;    uint16      rport;      ; TCP server port.  (ie: remote machine)   */
;    uint32      rhost;      ; TCP server IP addr. (ie: remote machine) */
;} CIB;
;
;  Values for protocol field    */
P_ICMP	equ 	1
P_TCP	equ 	6
P_UDP	equ 	17


;  Transport structure/functions   */

;typedef struct tpl {
;    char    *module;    ; specific string that can be searched for */
;    char    *author;    ; Any string                               */
;    char    *version;   ; Format `00.00' Version:Revision          */
;    char  * cdecl (*KRmalloc)(int32);
;    void    cdecl (*KRfree)(char *);
;    int32   cdecl (*KRgetfree)(int16 x);
;    char  * cdecl (*KRrealloc)(char *, int32);
;    char  * cdecl (*get_err_text)(int16);
;    char  * cdecl (*getvstr)(char *);
;    int16   cdecl (*carrier_detect)(void);
;    int16   cdecl (*TCP_open)(uint32, int16, int16, uint16);
;    int16   cdecl (*TCP_close)(int16, int16);
;    int16   cdecl (*TCP_send)(int16, char *, int16);
;    int16   cdecl (*TCP_wait_state)(int16, int16, int16);
;    int16   cdecl (*TCP_ack_wait)(int16, int16);
;    int16   cdecl (*UDP_open)(uint32, int16);
;    int16   cdecl (*UDP_close)(int16);
;    int16   cdecl (*UDP_send)(int16, char *, int16);
;    int16   cdecl (*CNkick)(int16);
;    int16   cdecl (*CNbyte_count)(int16);
;    int16   cdecl (*CNget_char)(int16);
;    NDB   * cdecl (*CNget_NDB)(int16);
;    int16   cdecl (*CNget_block)(int16, char *, int16);
;    void    cdecl (*housekeep)(void);
;    int16   cdecl (*resolve)(char *, char ;, uint32 *, int16);
;    void    cdecl (*ser_disable)(void);
;    void    cdecl (*ser_enable)(void);
;    int16	cdecl (*set_flag)(int16);
;    void	cdecl (*clear_flag)(int16);
;    CIB   * cdecl (*CNgetinfo)(int16);
;} TPL;
;
;extern TPL *tpl;

;KRmalloc(x)             (*tpl->KRmalloc)(x)
;KRfree(x)               (*tpl->KRfree)(x)		
;KRgetfree(x)            (*tpl->KRgetfree)(x)
;KRrealloc(x,y)          (*tpl->KRrealloc)(x,y)
;get_err_text(x)         (*tpl->get_err_text)(x)
;getvstr(x)              (*tpl->getvstr)(x)
;carrier_detect()        (*tpl->carrier_detect)()
;TCP_open(h,p,t,o)       (*tpl->TCP_open)(h,p,t,o)
;TCP_close(x,y)          (*tpl->TCP_close)(x,y)
;TCP_send(x,y,z)         (*tpl->TCP_send)(x,y,z)
;TCP_wait_state(x,y,z)   (*tpl->TCP_wait_state)(x,y,z)
;TCP_ack_wait(x,y)       (*tpl->TCP_ack_wait)(x,y)
;UDP_open(x,y)           (*tpl->UDP_open)(x,y)
;UDP_close(x)            (*tpl->UDP_close)(x)
;UDP_send(x,y,z)         (*tpl->UDP_send)(x,y,z)
;CNkick(x)               (*tpl->CNkick)(x)
;CNbyte_count(x)         (*tpl->CNbyte_count)(x)
;CNget_char(x)           (*tpl->CNget_char)(x)
;CNget_NDB(x)            (*tpl->CNget_NDB)(x)
;CNget_block(x,y,z)      (*tpl->CNget_block)(x,y,z)
;housekeep()             (*tpl->housekeep)()
;resolve(w,x,y,z)        (*tpl->resolve)(w,x,y,z)
;ser_disable()           (*tpl->ser_disable)()
;ser_enable()            (*tpl->ser_enable)()
;set_flag(x)             (*tpl->set_flag)(x)
;clear_flag(x)           (*tpl->clear_flag)(x)
;CNgetinfo(x)            (*tpl->CNgetinfo)(x)
;
;#endif ; STIK_TRANSPRT_H */
