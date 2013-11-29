#include "SuJi_glo.h"

int test_quote(FILE_INFO *par,int *qp,int *qn)
{
	int quoten_pfad=0;
	int quoten_name=0;

	if(par)
	{
		if(par->pfad[0]=='\'')
			quoten_pfad+=3;
	
		for(i=0;i<(int) strlen(par->pfad);i++)
		{
			if(par->pfad[i]==' ')
			{
				if(!quoten_pfad)
					quoten_pfad=2;
			}

			if(quoten_pfad && par->pfad[i]=='\'')
				quoten_pfad+=1;
		}

		for(i=0;i<(int) strlen(par->name);i++)
		{
			if(par->name[i]==' ')
			{
				if(!quoten_name)
					quoten_name=2;
			}

			if(quoten_name && par->name[i]=='\'')
				quoten_name+=1;
		}
	}

	if(qp)
		*qp=quoten_pfad;
	if(qn)
		*qn=quoten_name;

	return quoten_name || quoten_pfad;
}

char *make_quote(FILE_INFO *par,int getrennt)
/*
	par		getrennt
	 x		0		->  Name und Pfad dieses einen gemeinsam
	 x		x		-> 	Name und Pfad dieses einen getrennt
	 0l		0 		->	Name und Pfad aller selektierten gemeinsam
	 0l		x		->	Name und Pfad aller sel. getrennt (durch '\0')
*/
{
	long bytes;
	char *ret;
	int qp,qn;

	if(par)
	{
		if(getrennt)
		{
			if(test_quote(par,&qp,&qn))
			{
				char *out,*in;

				bytes=qp+qn+strlen(par->pfad)+strlen(par->name)+2;

				ret=(char *)Mxalloc(bytes,0x22);
				if(ret==(char *) (-32))
					ret=(char *)Malloc(bytes);

				if(!ret)
					return 0l;

				out=ret;

				if(qp)
					*out++='\'';

				in=par->pfad;
				do {
					if(qp && *in=='\'')
						*out++='\'';
					*out++=*in++;
				} while(*in);

				if(qp)
					*out++='\'';
				*out++='\0';

				if(qn)
					*out++='\'';

				in=par->name;
				do {
					if(qn && *in=='\'')
						*out++='\'';
					*out++=*in++;
				} while(*in);

				if(qn)
					*out++='\'';
				*out++='\0';

				return ret;
			}
			else
			{
				bytes=strlen(par->pfad)+strlen(par->name)+2;

				ret=(char *)Mxalloc(bytes,0x22);
				if(ret==(char *) (-32))
					ret=(char *)Malloc(bytes);

				if(!ret)
					return 0l;

				strcpy(ret,par->pfad);
				strcpy(&ret[strlen(ret)+1],par->name);

				return ret;
			}
		}
		else
		{
			if(test_quote(par,&qp,&qn))
			{
				char *out,*in;

				bytes=qp+qn+strlen(par->pfad)+strlen(par->name)+1;

				ret=(char *)Mxalloc(bytes,0x22);
				if(ret==(char *) (-32))
					ret=(char *)Malloc(bytes);

				if(!ret)
					return 0l;

				out=ret;

				*out++='\'';
				in=par->pfad;
				while(*in)
				{
					if(*in=='\'')
						*out++='\'';
					*out++=*in++;
				}

				in=par->name;
				do {
					if(*in=='\'')
						*out++='\'';
					*out++=*in++;
				} while(*in);

				*out++='\'';
				*out++='\0';

				return ret;
			}
			else
			{
				bytes=strlen(par->pfad)+strlen(par->name)+2;

				ret=(char *)Mxalloc(bytes,0x22);
				if(ret==(char *) (-32))
					ret=(char *)Malloc(bytes);

				if(!ret)
					return 0l;

				strcpy(ret,par->pfad);
				strcat(ret,par->name);

				return ret;
			}
		}
	}
	else
	{
		long l;

		if(getrennt)
		{
			char *out,*in;

			bytes=0l;

			for(l=0;l<finfos;l++)
			{
				FILE_INFO *par;

				par=get_from_list(l+1);

				if(par && par->selected)
				{
					test_quote(par,&qp,&qn);

					bytes+=qp+qn+strlen(par->pfad)+strlen(par->name)+3;
				}
			}

			if(bytes==0l)
				return 0l;

			bytes++;

			ret=(char *)Mxalloc(bytes,0x22);
			if(ret==(char *) (-32))
				ret=(char *)Malloc(bytes);

			if(!ret)
				return 0l;

			out=ret;

			for(l=0;l<finfos;l++)
			{
				FILE_INFO *par;

				par=get_from_list(l+1);

				if(par && par->selected)
				{
					if(test_quote(par,&qp,&qn))
					{
						if(qp)
							*out++='\'';

						in=par->pfad;
						do {
							if(qp && *in=='\'')
								*out++='\'';
							*out++=*in++;
						} while(*in);

						if(qp)
							*out++='\'';

						*out++='\0';

						if(qn)
							*out++='\'';
		
						in=par->name;
						do {
							if(qn && *in=='\'')
								*out++='\'';
							*out++=*in++;
						} while(*in);

						if(qn)
							*out++='\'';
						*out++='\0';
					}
					else
					{
						strcpy(out,par->pfad);
						strcpy(&out[strlen(out)+1],par->name);
						out+=strlen(out)+strlen(&out[strlen(out)+1])+2;
					}
				}
			}

			*out++='\0';

			return ret;
		}
		else
		{
			char *out,*in;

			bytes=0l;

			for(l=0;l<finfos;l++)
			{
				FILE_INFO *par;

				par=get_from_list(l+1);

				if(par && par->selected)
				{
					test_quote(par,&qp,&qn);

					bytes+=qp+qn+strlen(par->pfad)+strlen(par->name)+1;
				}
			}

			if(bytes==0l)
				return 0l;

			ret=(char *)Mxalloc(bytes,0x22);
			if(ret==(char *) (-32))
				ret=(char *)Malloc(bytes);

			if(!ret)
				return 0l;

			out=ret;

			for(l=0;l<finfos;l++)
			{
				FILE_INFO *par;

				par=get_from_list(l+1);

				if(par && par->selected)
				{
					if(test_quote(par,&qp,&qn))
					{
						*out++='\'';
						in=par->pfad;
						while(*in)
						{
							if(*in=='\'')
								*out++='\'';
							*out++=*in++;
						}
		
						in=par->name;
						do {
							if(*in=='\'')
								*out++='\'';
							*out++=*in++;
						} while(*in);
		
						*out++='\'';
						*out++=' ';
					}
					else
					{
						strcpy(out,par->pfad);
						strcat(out,par->name);
						out+=strlen(out);
						*out++=' ';
					}
				}
			}

			*(--out)='\0';

			return ret;
		}
	}
}

char *dequote(char *to_dequote)
{
	long pos,file_start,outpos,l;
	int gequotet;
	char *datei;

	pos=0l;
	file_start=pos;

	gequotet=FALSE;
	if(to_dequote[pos]=='\'')
	{
		gequotet=TRUE;
		pos++;
		file_start++;
	}

	datei=NULL;
	do {
		if(to_dequote[pos]=='\0' ||
			(to_dequote[pos]==' ' && !gequotet))
		{
			datei=(char *)malloc(pos-file_start+1);
			if(!datei)
				return 0l;
		}
		if(to_dequote[pos]=='\'' &&
			gequotet)
		{
			if(to_dequote[pos+1]!='\'')
			{
				datei=(char *)malloc(pos-file_start+1);
				if(!datei)
					return 0l;
			}
			else
				pos++;
		}

		pos++;
	} while(!datei);

	outpos=0;
	for(l=file_start;;l++)
	{
		if(to_dequote[l]=='\'' &&
			gequotet)
		{
			if(to_dequote[l+1]=='\'')
			{
				datei[outpos++]='\'';
				l++;
			}
			else
			{
				datei[outpos]='\0';
				return datei;
			}
		}
		else if(to_dequote[l]=='\0')
		{
			if(!gequotet)
			{
				datei[outpos]='\0';
				return datei;
			}
			else
			{
				datei[outpos]='\0';
				free(datei);
				return 0l;
			}
		}
		else if(to_dequote[l]==' ')
		{
			if(!gequotet)
			{
				datei[outpos]='\0';
				return datei;
			}
			else
			{
				datei[outpos++]=to_dequote[l];
			}
		}
		else
		{
			datei[outpos++]=to_dequote[l];
		}
	}
}
