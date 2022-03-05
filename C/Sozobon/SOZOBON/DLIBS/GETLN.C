#define	KEY_UNDO	0x1B		/* escape */
#define	KEY_CR		0x0D
#define	KEY_LF		0x0A
#define	KEY_BS		0x08
#define	KEY_DEL		0x7F

char *getln(ip, get, put, buffer, limit)
	char *ip;
	register int (*get)();
	register int (*put)();
	char *buffer;
	register int limit;
	{
	register char *bp = buffer;
	register int c, i = 0;

	for(;;)
		{
		c = (*get)(ip) & 0xFF;
		if(c == KEY_UNDO)
			{
			*(bp = buffer) = '\0';
			i = 0;
			break;
			}
		else if((c == KEY_CR) || (c == KEY_LF))
			{
			*bp = '\0';
			break;
			}
		else if(((c == KEY_BS) || (c == KEY_DEL)) && (bp != buffer))
			{
			--bp;
			(*put)('\b');
			(*put)(' ');
			(*put)('\b');
			--i;
			}
		else if((c >= ' ') && (i < limit))
			{
			(*put)(*bp++ = c);
			++i;
			}
		}
	return(buffer);
	}
