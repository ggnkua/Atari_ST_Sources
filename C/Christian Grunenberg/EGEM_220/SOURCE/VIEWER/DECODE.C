
static void decode_img(byte *src,byte *end,byte *dst,int w,int h,int lwidth,int pat_len)
{
	byte *ptr,*pat;
	int rbytes,data,length,bit=0x80;
	int line,count,lbytes=(w+7)>>3;

	for (line=0;line<h && src<end;)
	{
		count = 1;
		rbytes = lbytes;
		ptr = dst;

		while (rbytes>0 && src<end)
		{
			if ((data=*src++)==0)
			{
				if ((data=*src++)==0)
				{
					if (*src++==0xff)
						count = *src++;
				}
				else
				{
					rbytes -= data*pat_len;
					while (--data>=0)
						for (pat=src,length=pat_len;--length>=0;)
							*ptr++ = *pat++;
					src += pat_len;
				}
			}
			else if (data==bit)
			{
				data = *src++;
				rbytes -= data;
				while (--data>=0)
					*ptr++ = *src++;
			}
			else
			{
				length = data&0x7f;
				rbytes -= length;
				data = (data & bit) ? 0xff : 0;
				while (--length>=0)
					*ptr++ = data;
			}
		}

		for (dst+=lwidth,line++;--count>0 && line<h;line++,dst+=lwidth)
			memcpy(dst,dst-lwidth,lwidth);
	}
}
