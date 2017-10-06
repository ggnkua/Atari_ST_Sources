global
void isolate_procname(XA_CLIENT *client)
{
	short f;
	char sv;
	char *q = client->cmd_name,
		 *p = strrchr(q,bslash);
	if (!p)						/* no '\\' */
		p = strrchr(q,slash);
	if (!p)						/* no '/' */
		p = strrchr(q,':');
	if (!p)						/* no ':' */
		p = q-1;
	q = strrchr(q,'.');
	if (q)
		sv = *q, *q = 0;		/* HR 9/11/00 sv */
	strncpy(client->proc_name,p+1,8);
	for (f = strlen(client->proc_name); f < 8; f++)		/* tssj! HR; 021200 */
		client->proc_name[f] = ' ';
	client->proc_name[8] = '\0';
	strnupr(client->proc_name,8);
	if (q)
		*q = sv;
}

