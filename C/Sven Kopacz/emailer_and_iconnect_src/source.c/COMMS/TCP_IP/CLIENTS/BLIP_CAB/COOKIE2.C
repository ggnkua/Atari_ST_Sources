
int get_cook_para2(char **head, char **para)
{
	char *x, mem, buf[256];

	buf[0]=0;	
	*para=buf;
	x=strchr(*head, '='); if(x==NULL) {*head=&(*head[strlen(*head)]);return(0);}
	*head=x+1;
	while((**head==' ')||(**head==9)) ++*head;
	if(**head=='"')
	{
		++*head;
		x=strchr(*head, '"');
		if(x==NULL) {*head=&(*head[strlen(*head)]);return(0);}
	}
	else
	{
		x=*head;
		while(*x && (*x!=';') && (*x!=',') && (*x!=' ') && (*x!=9)) ++x;
	}
	mem=*x; *x=0;
	if(strlen(*head) < 256) 
		strcpy(buf, *head);
	*x=mem; 
	*head=x; 
	return(buf[0]);
}


void extract_cookie2(char *head, char *url)
{
	#define NAME_MLEN 128
	#define VAL_MLEN 128
	
	char *m1, *x, *y, mem;
	time_t	tl;
	char name[NAME_MLEN+1], *val, value[VAL_MLEN+1], *exp, expires[32], path[512], domain[128], secure;
	URL						surl;

	#ifdef iodebug
		Fwrite(debhand, strlen("Extract cookie\r\n"), "Extract cookie\r\n");
	#endif
	
	/* Defaults */
	val=NULL;
	exp=NULL;
	secure=0;
	#ifdef iodebug
		Fwrite(debhand, strlen("parse url\r\n"), "parse url\r\n");
	#endif
	if(parse_url(url, &surl, http_port, "http")==-1) return;
	strcpy(domain, surl.host);
	strcpy(path, surl.path);
	x=&(path[strlen(path)]);
	while(x >= path)
	{
		if(*x=='\\') {*x=0; break;}
		--x;
	}

	/* Start */		
	while((*head==' ')||(*head==9)) ++head;
	
	m1=strchr(head, 13); 
	if(m1==NULL) m1=strchr(head, 10);
	if(m1) *m1=0;

	/* Get NAME and VALUE */
	x=head;
	while(*x && (*x!='=') && (*x!=';') && (*x!=',') && (*x!='"')) ++x;
	mem=*x; *x=0;
	if(strlen(head) > NAME_MLEN) {*x=mem; goto _exit_cookie2;}
	strcpy(name, head);
	if(name[0]) while(name[strlen(name)-1]==' ') name[strlen(name)-1]=0;
	*x=mem;
	head=x;
	if(mem=='=')
	{ /* Get VALUE */
		++head; while((*head==' ') || (*head==9)) ++head;
		if(*head=='"')
		{
			++head; x=strchr(head, '"'); if(x==NULL) goto _exit_cookie2;
		}
		else
		{
			x=head;
			while(*x && (*x!=' ') && (*x!=9) && (*x!=';') && (*x!=',')) ++x;
		}
		mem=*x; *x=0;
		if(strlen(head) > VAL_MLEN) {*x=mem; goto _exit_cookie2;}
		strcpy(value, head);
		*x=mem;
		head=x;
		val=value;
	}

	/* Parameter ermitteln */
	while(*head)
	{
		/* N„chster Parameter */
		while(*head && (*head != ';') && (*head != ',')) ++head;
		if(*head==',')
		{	/* Neuer Cookie */
			++head;
			browser->set_cookie(url, name, val, exp, path, domain, secure);
			if(m1) *m1=13;
			extract_cookie2(head, url);
			return;
		}
		if(*head==';')	/* N„chster */
		{
			++head;
			while((*head==' ')||(*head==9)) ++head;
			if(!strnicmp(head, "Max-Age", 7))
			{
				if(get_cook_para2(&head, &x))
				{
					tl=time(NULL);
					tl+=atol(x);
					x=ctime(&tl);
					strncpy(expires, x, 3);
					expires[3]=','; expires[4]=' ';
					strncpy(&(expires[5]), &(x[8]), 2);
					expires[7]='-';
					strncpy(&(expires[8]), &(x[4]), 3);
					expires[11]='-';
					strncpy(&(expires[12]), &(x[20]), 4);
					expires[16]=' ';
					strncpy(&(expires[17]), &(x[11]), 8);
					expires[25]=0;
					strcat(expires, " GMT");
					exp=expires;
				}
			}
			else if(!strnicmp(head, "Path", 4))
			{
				if(get_cook_para2(&head, &x))
				{
					/* Check if path is correct */
					if(strlen(x) > strlen(surl.path)) goto _exit_cookie2;
					if(strnicmp(x, surl.path, strlen(x))) goto _exit_cookie2;
					strcpy(path, x);
				}
			}
			else if(!strnicmp(head, "Domain", 6))
			{
				if(get_cook_para2(&head, &x))
				{
					/* Check for embedded dot */
					y=strchr(x+1, '.'); 
					if(y==NULL) goto _exit_cookie2;
					if(y==x+strlen(x)-1) goto _exit_cookie2;
					/* Check for domain */
					if(strnicmp(x, surl.host+(strlen(surl.host)-strlen(x)), strlen(x))) goto _exit_cookie2;
					/* Check for dot in leading hostname-part */
					y=&(surl.host[strlen(surl.host)-strlen(x)]);
					if(x[0]!='.')--y;
					mem=*y; *y=0;
					if(strchr(surl.host, '.')) {*y=mem; goto _exit_cookie2;}
					*y=mem;
					strcpy(domain, x);
				}
			}
			else if(!strnicmp(head, "Secure", 6))
			{
				secure=1;
				head+=6;
			}
			else
			{/* Quoted Parameter bergehen */
				get_cook_para2(&head, &x);
			}
		}
	}
	
	browser->set_cookie(url, name, val, exp, path, domain, secure);

_exit_cookie2:
	if(m1) *m1=13;
}
