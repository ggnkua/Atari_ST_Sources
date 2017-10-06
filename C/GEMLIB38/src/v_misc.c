/*
 * Some usefull extensions.
*/

void vdi_array2str(short *src, char *des, int len)
{
	while (len > 0)
	{
		*des++ = (char) *src++;
		len--;
	}
	*des++ = 0;
}

int vdi_str2array(char *src, short *des)
{
	int				len;
	unsigned char	*c;
	
	len = 0;
	c = (unsigned char*)src;
	while (*c != '\0')
	{
		*des++ = *c++;
		len++;
	}
	return len;
}
