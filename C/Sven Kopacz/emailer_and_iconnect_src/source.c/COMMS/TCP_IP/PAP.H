void pap_start(void);
void pap_resend(void);
void pap_conf_timeout(void);
void pap_ppp_scr(void);	/* Send configure request */
void pap_process(uchar *buf, uint len);
void init_pap_request_buffer(void);
