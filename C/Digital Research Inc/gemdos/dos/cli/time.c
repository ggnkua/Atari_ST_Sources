
/* time.c - set system time (HH:MM:SS)
*/

#include <dt.h>

extern int get_num();

main(bp)
char *bp;
{
	int h, m, s;
	int time;
    	char **q;

	bp += 0x80;
	if (*bp)
	{
		bp += 2;
    		q = &bp;
		h = get_num(q);
    		if((h == -1) || (**q != ':') || (h > 24)) goto error;
    		(*q)++;
		m = get_num(q);
    		if ((m == -1) || (**q != ':') || (m > 59)) goto error;
    		(*q)++;
    		s = get_num(q);
    		if ((s == -1) || (s > 59)) goto error;
		s = (s+1) >> 1;

		time = ((h<<11) & 0xF800 ) | ((m<<5) & 0x07E0) | (s & 0x001F);

		if (bdos(T_SetTime,time) < 0L) {
error:
			bdos(C_ConWS,"Invalid time, Enter HH:MM:SS");
			bdos(0x4c);
		}
	}
	
	time = bdos(T_GetTime);
	put_num((time>>11)&0x1F);
	bdos(C_ConOut,':');
	put_num((time>>5)&0x3F);
	bdos(C_ConOut,':');
	put_num((time&0x1F)<<1);
	bdos(0x4c);
}
