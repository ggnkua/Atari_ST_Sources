#include <osbind.h>
#include <string.h>
#include <stdio.h>

int binhex(const char *source, const char *destination, const char *name);

int main(int argc, char **argv)
{
	if(argc!=4)
	{
		Cconws("Usage: binhex input.cod output.c name_tab\r\n");
		return(-1);
	}
	binhex(argv[1], argv[2], argv[3]);
	return(0);
}

int binhex(const char *source, const char *destination, const char *name)
{
	long i, j, s_len;
	unsigned int s, d;
	char b[256], l_name[100];
	_DTA	dta;
	unsigned int d_time, d_date;
	Fsetdta(&dta);
	if(Fsfirst(source, FA_RDONLY|FA_HIDDEN|FA_SYSTEM))
		return 1;
	s_len= dta.dta_size;
	d_time= dta.dta_time;
	d_date= dta.dta_date;
	if(!Fsfirst(destination, FA_RDONLY|FA_HIDDEN|FA_SYSTEM))
	{
		if((dta.dta_date > d_date) || 
		  ((dta.dta_date == d_date) && (dta.dta_time > d_time)))
			return -1;	/* file is already coverted */
	}
	i=Fopen(source, 0);
	if(i < 0)
		return 2;
	s=(unsigned int)i;
	i=Fcreate(destination, 0);
	if(i < 0)
	{
		Fclose(s);
		return 3;
	}
	d=(unsigned int)i;
	strupr(strncat(strcpy(l_name, "LEN_"), name, 99));
	sprintf(b, "/* File %s encoded */\r\n\r\n"
	           "#define %s\t%luL\r\n\r\n"
	           "unsigned long len_%s=%s;\r\n"
	           "unsigned char %s[%s%s]= {\r\n",
	           source, l_name, s_len, name, l_name, name, l_name, (s_len%2) ? "+1" : "");
	if(Fwrite(d, strlen(b), b) != strlen(b))
	{
		Fclose(s);
		Fclose(d);
		return 4;
	}
	for(j= 0; j<=(s_len / 16); j++)
	{
		unsigned char b1[16];
		char format[]= "0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,"
		               "0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,\r\n";
		long x, y;
		if((x= Fread(s, 16, b1)) < 0)
		{
			Fclose(s);
			Fclose(d);
			return 5;
		}
		if(j == (s_len / 16))
		{
			char *p;
			format[0]= '\0';
			for(y= 0; y<x; y++)
				strcat(format, "0x%02x,");
			p= strrchr(format, ',');
			if(p) *p= ' ';
			strcat(format, "};\r\n");
		}
		sprintf(b, format,
			b1[0], b1[1], b1[2],  b1[3],  b1[4],  b1[5],  b1[6],  b1[7],
			b1[8], b1[9], b1[10], b1[11], b1[12], b1[13], b1[14], b1[15]);
		if(Fwrite(d, strlen(b), b) != strlen(b))
		{
			Fclose(s);
			Fclose(d);
			return 6;
		}
	}
	Fclose(s);
	Fclose(d);
	return 0;
}
