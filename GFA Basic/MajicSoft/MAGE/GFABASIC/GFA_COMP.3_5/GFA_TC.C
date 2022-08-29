
/* gfa_tc konvertiert ein GFA-BASIC 3.0 Fliežkommafeld
          in ein Turbo C 1.1 Double Array (IEEE eXtendet	*/
/* gfa_tc( Adresse eines GFA-BASIC 3.0 Fliežkommafeldes,
		   Adresse eines Turbo-C (1.1) double arrays,
		   Anzahl der zu konvertierenden Werte				*/

void gfa_tc(void *src,void*dst,int cnt)
{
	short a;
	while(cnt)
		{
		cnt --;
		a = *((short*)(((char *)src)+6));
		if(a == 0)
			{
			*((long *)dst)++ = 0;
			*((long *)dst)++ = 0;
			*((short*)dst)++ = 0;
			}
		else
			{
			*((short*)dst)++ =
				(a < 0) ? (a = (0x3fff - 0x03ff - a) | 0x8000)
						: (a += 0x3fff - 0x03ff);
			*((long *)dst)++ = *((long *)src)++;
			*((short*)dst)++ = *((short *)src)++;
			*((short*)dst)++ = 0;
			((short *)src) ++;
			}
		}
}

/* tc_gfa  konvertiert ein Turbo C 1.1 Double Array
		   in ein GFA-BASIC 3.0 Fliežkommafeld				*/
/* tc_gfa( Adresse eines Turbo-C (1.1) double arrays,
		   Adresse eines GFA-BASIC 3.0 Fliežkommafeldes,
		   Anzahl der zu konvertierenden Werte				*/

void tc_gfa(void *src,void*dst,int cnt)
{
	short a;
	while(cnt)
		{
		cnt --;
		a = *((short*)src)++;
		if(a == 0)
			{
			*((long *)dst)++ = 0;
			*((long *)dst)++ = 0;
			}
		else
			{
			*((long *)dst)++ = *((long *)src)++;
			*((short*)dst)++ = *((short*)src)++;
			((short *)src)++;
			*((short*)dst)++ =
				(a < 0) ? (a = 0x3fff - 0x03ff -(a &= 0x7fff))
						: (a -= 0x3fff - 0x03ff);
			}
		}
}

