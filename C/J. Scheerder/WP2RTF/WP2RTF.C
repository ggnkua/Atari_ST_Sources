#include	<ctype.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#define	eq(a,b)		!stricmp(a,b)
#define	eqn(a,b,n)	!strnicmp(a,b,n)

#define	FALSE	0
#define	TRUE	!FALSE
#define	NEWLINE	"\r\n"

#define	NONE	0
#define	BOLD	1
#define	ITALIC	2
#define	UNDERLINED	3
#define	LIGHT	4
#define	SUPER	5
#define	SUB	6
#define	RETURN	8

void	usage(void);
int		init_table(char *);
void	translate(char *);


char	table[256][16];
char	pre[10][256];
char	para[32];
char	post[64];
char	mode[16][10];
char	footnote[256];
char	endnote[16];

main(int argc, char *argv[])
{
	int	file;

	if(argc <= 1)
	{
		usage();
		return(-1);
	}
	file = 1;
	if(eq(argv[1],"-t"))
	{
		if(argc < 3)
		{
			usage();
			return(-1);
		}
		if(!init_table(argv[2]))
		{
			return(-1);
		}
		file = 3;
	}
	else
	{
		if(!init_table("wp2rtf.x"))
		{
			return(-1);
		}
	}
	for(;file < argc; file++)
	{
		translate(argv[file]);
	}
	return(0);
}

void usage(void)
{
	fprintf(stderr, "Usage: wp2rtf [-t translator] file ...\r\n");
}

void mycopy(char *dest, char *src)
{
	while(*src && *src != '\r' && *src != '\n')
	{
		*dest++ = *src++;
	}
	*dest = 0;
}

int	hex2num(char digit)
{
	digit = toupper(digit);
	if(digit >= '0'  && digit <= '9') return(digit - '0');
	if(digit >= 'A'  && digit <= 'F') return(digit - 'A' + 10);
	return(0);
}

int init_table(char *file)
{
	FILE	*in;
	int 	i;
	char	buf[1024];

	for(i = 0; i<10; i++) pre[i][0] = 0;
	post[0] = para[0] = footnote[0] = endnote[0] = 0;
	for(i = 0; i<16; i++) mode[i][0] = 0;
	for(i = 0; i<256; i++)
	{
		table[i][0] = i;
		table[i][1] = 0;
	}
	table[30][0] = 32;
	in = fopen(file,"rb");
	if(in == NULL)
	{
		fprintf(stderr,"Error opening %s for reading\r\n",file);
		return(FALSE);
	}
	while(fgets(buf,1024,in) != NULL)
	{
		if(buf[0] == '$')
		{
			i = (16*hex2num(buf[1])) + hex2num(buf[2]);
			mycopy(table[i], &buf[4]);
		}
		else
		{
			if(eqn("init",buf,4))
			{
				strcpy(pre[buf[4]-'0'],&buf[6]);
			}
			if(eqn("exit",buf,4))
			{
				mycopy(post,&buf[5]);
			}
			if(eqn("paragraph",buf,9))
			{
				strcpy(para,&buf[10]);
			}
			if(eqn("bold",buf,4))
			{
				mycopy(mode[BOLD],&buf[5]);
			}
			if(eqn("underlined",buf,10))
			{
				mycopy(mode[UNDERLINED],&buf[11]);
			}
			if(eqn("italic",buf,6))
			{
				mycopy(mode[ITALIC],&buf[7]);
			}
			if(eqn("light",buf,5))
			{
				mycopy(mode[LIGHT],&buf[6]);
			}
			if(eqn("super",buf,5))
			{
				mycopy(mode[SUPER],&buf[6]);
			}
			if(eqn("sub",buf,3))
			{
				mycopy(mode[SUB],&buf[4]);
			}
			if(eqn("off",buf,3))
			{
				mycopy(mode[RETURN],&buf[4]);
			}
			if(eqn("footnote",buf,8))
			{
				mycopy(footnote,&buf[9]);
			}
			if(eqn("endnote",buf,7))
			{
				mycopy(endnote,&buf[8]);
			}
		}
	}
	fclose(in);
	return(TRUE);
}

void translate(char *filename)
{
	FILE	*in, *out;
	char	outfile[128], *ptr, *buffer, tmp[32];
	long	filesize, current = 0L, i;
	int	linestart, first = TRUE, Mode, fnum;

	in = fopen(filename,"rb");
	if(in == NULL)
	{
		fprintf(stderr,"Error opening %s for reading\r\n",filename);
		return;
	}
	fseek(in, 0L, SEEK_END);
	filesize = ftell(in);
	fseek(in, 0L, SEEK_SET);
	buffer = malloc(filesize+1);
	if(buffer == NULL)
	{
		fprintf(stderr,"Insufficient memory to read %s\r\n",filename);
		fclose(in);
		return;
	}
	if(fread(buffer,sizeof(char),filesize,in) != filesize)
	{
		fprintf(stderr,"Error reading %s\r\n",filename);
		fclose(in);
		return;
	}
	fclose(in);
	strcpy(outfile,filename);
	ptr = strrchr(outfile,'.');
	if(ptr != NULL)
	{
		if(eq(ptr,".rtf"))
		{
			fprintf(stderr,"In- and outfiles must be named differently\r\n");
			free(buffer);
			return;
		}
		strcpy(ptr,".rtf");
	}
	else
	{
		strcat(outfile,".rtf");
	}
	out = fopen(outfile,"wb");
	if(out == NULL)
	{
		fprintf(stderr,"Error opening %s for writing\r\n",outfile);
		return;
	}
	buffer[filesize] = 0;
	while(buffer[filesize-1] == '\r' || buffer[filesize-1] == '\n' || buffer[filesize-1] == 'E')
	{
		buffer[--filesize] = 0;
	}
	for(i = 0; i <=9; i++)
	{
		fprintf(out, pre[i]);
	}
	linestart = TRUE;
	while(current < filesize)
	{
		if(linestart && buffer[current] == '\x1F')
		{
			for(;current < filesize && buffer[current] != '\r'; current++);
		}
		while(linestart && current < filesize && buffer[current] == '\x0B' && buffer[current+1] == '\x11')
		{
			current += 2;
		}
		linestart = FALSE;
		switch(buffer[current])
		{
			case		0:
			case	'\r':	if(buffer[current-1] == '\x1e' || buffer[current-1] == '\x19' || buffer[current-1] == '-')
						{	/*	Soft Break	*/
							fprintf(out,NEWLINE);
						}
						else
						{	/*	Real paragraph break	*/
							fprintf(out,para);
						}
						if(buffer[current+1] == '\n') current++;
						linestart = TRUE;
						break;
			case	'\n':	linestart = TRUE;
						break;
			case	'\f':	if(buffer[current+1] == '\x1B' && buffer[current+2] == '\x80')
						{
							current += 2;
						}
						break;
			case	'\x1B':
				switch(buffer[++current])
				{
					case '\x81':	Mode = BOLD;
								break;
					case '\x88':	Mode = UNDERLINED;
								break;
					case '\x84':	Mode = ITALIC;
								break;
					case '\x82':	Mode = LIGHT;
								break;
					case '\x90':	if(buffer[current+1] == '\x18')
								{
									while(buffer[current++] != ',');
									fnum = atoi(&buffer[current]);
									/*	Now find footnote and insert it	*/
									fprintf(out,footnote);
									sprintf(tmp,"\x1FN%03u",fnum);
									ptr = strstr(&buffer[current], tmp);
									if(ptr != NULL)
									{
										first = TRUE;
										while(*ptr != '\r' && *ptr != '\n')
										{
											*ptr = '\xFF';
											ptr++;
										}
										while(*ptr == '\r' || *ptr == '\n')
										{
											*ptr = '\xFF';
											ptr++;
										}
										while(*ptr != '\x1F' && *ptr)
										{
											switch(*ptr)
											{
												case		0:	break;
												case	'\r':	if(buffer[current-1] == '\x1e' || buffer[current-1] == '\x19')
															{	/*	Soft Break	*/
																fprintf(out,NEWLINE);
															}
															else
															{	/*	Real paragraph break	*/
																fprintf(out,para);
															}
															if(buffer[current+1] == '\n') current++;
															linestart = TRUE;
															break;
												case	'\n':	linestart = TRUE;
															break;
												case	'\x1B':
													switch(*++ptr)
													{
														case '\x81':	Mode = BOLD;
																	break;
														case '\x88':	Mode = UNDERLINED;
																	break;
														case '\x84':	Mode = ITALIC;
																	break;
														case '\x82':	Mode = LIGHT;
																	break;
														case '\x90':	Mode = SUPER;
																	break;
														case '\xA0':	Mode = SUB;
																	break;
														case '\x80':	if(first)
																	{
																		Mode = NONE;
																		first = FALSE;
																		break;
																	}
																	Mode = RETURN;
																	break;
														default:		Mode = NONE;
																	break;
													}
													fprintf(out,mode[Mode]);
													break;
												default:	fprintf(out,table[*ptr]);
														break;
											}
											*ptr++ = '\xFF';
										}
										if(!strncmp(ptr,"\x1F\E\r\n\x1B\x80",6))
										{
											strncpy(ptr,"\xFF\xFF\xFF\xFF\xFF\xFF", 6);
										}
										first = FALSE;
									}
									fprintf(out,endnote);
									while(buffer[current++] != '\x18');
									while(buffer[current++] != '\x80');
									current--;
									Mode = NONE;
									break;
								}
								Mode = SUPER;
								break;
					case '\xA0':	Mode = SUB;
								break;
					case '\x80':	if(first)
								{
									Mode = NONE;
									first = FALSE;
									break;
								}
								Mode = RETURN;
								break;
					default:		Mode = NONE;
								break;
				}
				fprintf(out,mode[Mode]);
				break;
			default:	fprintf(out,table[buffer[current]]);
					break;
		}
		current++;
	}
	fprintf(out,post);
	fclose(out);
}