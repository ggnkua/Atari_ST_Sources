
void	ipcp_start(void);
void	ipcp_resend(void);
void	ipcp_conf_timeout(void);

void	ipcp_ppp_scr(void);
void	ipcp_ppp_sca(void);
void	ipcp_ppp_scn(void);
void	ipcp_ppp_scj(void);
void	ipcp_ppp_str(void);
void	ipcp_ppp_sta(void);
int		ipcp_check_request(void);
void	ipcp_check_nack(void);
void	ipcp_check_reject(void);
void	init_ipcp_request_buffer(void);

void ipcp_process(unsigned char *bug, unsigned int len);