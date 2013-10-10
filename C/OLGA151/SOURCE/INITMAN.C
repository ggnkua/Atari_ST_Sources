/******************************
 * initman.c                  *
 ******************************
 ******************************
 * [1998-06-08, tm]           *
 * - first C version          *
 ******************************/

#include "initman.h"
#include "manager.h"
#include "language.h"


#define FILEINF "olga.inf"
#define GLOBAL  0x20

#define STAT_UNDEF        0
#define STAT_EXTENSIONS   1
#define STAT_TYPES        2
#define STAT_APPLICATIONS 3
#define STAT_OBJECTS      4
#define STAT_MANAGER      5


typedef struct
{
	long id;
	long value;
} COOKIE;


typedef struct
{
	long  magic;
	void *membot;
	void *aes_start;
	long  magic2;
	long  date;
	void (*chgres)(int res, int txt);
	long (**shel_vector)(void);
	char *aes_bootdrv;
	int  *vdi_device;
  void *reservd1;
  void *reservd2;
  void *reservd3;
  int   version;
  int   release;
} AESVARS;


typedef struct
{
	long    config_status;
	void    *dosvars;
	AESVARS *aesvars;
} MAGX_COOKIE;


int has_agi,
    shutdown  = 0,
    broadcast = 0,
    mgxver    = 0;




int get_cookie(long id, long *value)
{
	COOKIE *cookiejar = (COOKIE *)Setexc(360,(void (*)())-1L);

	if (cookiejar)
	{
		while (cookiejar->id)
		{
			if (cookiejar->id == id)
			{
				if (value) *value = cookiejar->value;
				return(1);
			}
			
			cookiejar++;
		}
	}
	
	return(0);
}



int appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4)
{
	return(has_agi ? appl_getinfo(type,out1,out2,out3,out4) : 0);
}



void check_cookies(void)
{
	MAGX_COOKIE *cv;

	if (get_cookie('MagX',(long *)&cv))
	{
		magix = 1;

		if (cv)
		{
			if (cv->aesvars)
			{
				if ((cv->aesvars->magic == -2023406815L) && (cv->aesvars->magic2 == 'MAGX'))
				{
					mgxver = cv->aesvars->version;
				}
			}
		}

		if (mgxver >= 0x0200) memprot = 1;
	}
	else
	{
		if (get_cookie('MiNT',NULL)) memprot = 1;
	}
}



void check_info(void)
{
	int check,dummy;
	
	has_agi = ((_GemParBlk.global[0] == 0x0399 && get_cookie('MagX',NULL))
	          || (_GemParBlk.global[0] >= 0x0400)
	          || (appl_find("?AGI") >= 0));

	if (appl_xgetinfo(10,&check,&dummy,&dummy,&dummy))
	{
		if (((check & 0x00ff) >= 9) || (mgxver >= 0x0300)) shutdown = 1;
		if (((check & 0x00ff) >= 7) && (!magix)) broadcast = 1;
	}
	else
	{
		if (_GemParBlk.global[0] >= 0x0400)
		{
			shutdown  = 1;
			broadcast = 1;
		}
	}
	
	if (appl_xgetinfo(4,&dummy,&dummy,&check,&dummy))
	{
		if (check) search = 1;
	}
	else
	{
		if (_GemParBlk.global[0] >= 0x0400) search = 1;
	}

	if (appl_xgetinfo(6,&dummy,&dummy,&check,&dummy))
	{
		if (check) mbar = 1;
	}
}



void read_name(void)
{
	char cmd[128],tail[128];
	
	if (shel_read(cmd,tail))
	{
		if (strlen(cmd))
		{
			apName = (char *)malloc(strlen(cmd)+1L);
			
			if (apName) strcpy(apName,cmd);
		}
	}
}



void broadcast_olenew(void)
{
	int answ[8];

	answ[0] = OLE_NEW;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = OLGAFLAGS;
	answ[4] = OLGAPROTOCOL;
	answ[5] = 0;
	answ[6] = 0;
	answ[7] = OLGAVERSION;

	if (broadcast)
	{
		shel_write(7,0,0,(char *)answ,NULL);
	}
	else if (search)
	{
		char fname[9];
		int type, apid, moreapps = appl_search(0,fname,&type,&apid);
		
		while (moreapps)
		{
			if ((type != 1) && (apid != ap_id)) appl_write(apid,16,answ);

			moreapps = appl_search(1,fname,&type,&apid);
		}
	}
}



void boot_device(char *path)
{
	path[0] = ((long)Setexc(273,(void (*)())-1L) & 0x000000ffL) + 'A';
	path[1] = 0;

	strcat(path,":\\");
}



int readline(char *str,int n,int handle)
{
	int  count=0,succ=0;
	char c;

	while (Fread(handle,1,&c)==1)
	{
		if (c==13)
		{
			succ=1;
			break;
		}
		else
		{
			if (c!=10)
			{
				str[count++]=c;
				if (count>=n) break;
			}
		}
	}

	str[count]=0;

	return((count) || (succ));
}



void read_inf(int handle)
{
	char linebuf[256];
	int  status = 0;

	while (readline(linebuf,255,handle))
	{
		int i = 0;

		while ((linebuf[i] == 9) || (linebuf[i] == 32)) i++;

		#ifdef DEBUG
		printf("|%s|\n",&linebuf[i]);
		#endif
		
		if (linebuf[i])
		{
			if (linebuf[i] != ';')
			{
				if (linebuf[i] == '[')
				{
					if (!strcmp(&linebuf[i],"[Extensions]")) status = STAT_EXTENSIONS;
					else if (!strcmp(&linebuf[i],"[Types]")) status = STAT_TYPES;
					else if (!strcmp(&linebuf[i],"[Applications]")) status = STAT_APPLICATIONS;
					else if (!strcmp(&linebuf[i],"[Objects]")) status = STAT_OBJECTS;
					else if (!strcmp(&linebuf[i],"[Manager]")) status = STAT_MANAGER;
					else
					{
						status = STAT_UNDEF;
					}
				}
				else
				{
					switch(status)
					{
					case STAT_EXTENSIONS:
						{
							Extension *pe = (Extension *)malloc(sizeof(Extension));
							char *p = strchr(&linebuf[i],'=');
							long i2;
							
							if ((!p) || (!pe)) continue;
							
							i2 = (p - &linebuf[i]) + i;
							
							pe->ext4 = (toupper(linebuf[i++]) << 8) | toupper(linebuf[i++]);
							pe->ext5 = 0;
							
							if (i < i2)
							{
								pe->ext5  = (toupper(linebuf[i++]) << 8);
								if (i < i2) pe->ext5 |= toupper(linebuf[i]);
							}
							
							p++;
							pe->path = (char *)malloc(strlen(p)+1L);
							if (pe->path) strcpy(pe->path,p);
							
							pe->next = NULL;
							
							if (!extensions) extensions = pe;
							else
							{
								Extension *ped = extensions;
								
								while (ped->next) ped = ped->next;
								ped->next = pe;
							}
						}
						break;
					
					case STAT_TYPES:
						{
							Type *pt = (Type *)malloc(sizeof(Type));
							
							if (!pt) continue;
							
							pt->typ = (linebuf[i++] << 8) | linebuf[i];
							
							i+=2;
							pt->path = (char *)malloc(strlen(&linebuf[i])+1L);
							if (pt->path) strcpy(pt->path,&linebuf[i]);
							
							pt->next = NULL;
							
							if (!types) types = pt;
							else
							{
								Type *ptd = types;
								
								while (ptd->next) ptd = ptd->next;
								ptd->next = pt;
							}
						}
						break;
					
					case STAT_APPLICATIONS:
						{
							Alias *pal = (Alias *)malloc(sizeof(Alias));
							char *p = strchr(&linebuf[i],'=');
							
							if ((!p) || (!pal)) continue;
							
							*p = 0;
							pal->alias = (char *)malloc(strlen(&linebuf[i])+1L);
							if (pal->alias) strcpy(pal->alias,&linebuf[i]);

							p++;
							pal->path = (char *)malloc(strlen(p)+1L);
							if (pal->path) strcpy(pal->path,p);
							
							pal->next = NULL;
							
							if (!aliases) aliases = pal;
							else
							{
								Alias *pald = aliases;
								
								while (pald->next) pald = pald->next;
								pald->next = pal;
							}
						}
						break;
					
					case STAT_OBJECTS:
						{
							Object *po = (Object *)malloc(sizeof(Object));
							char *p = strchr(&linebuf[i],'=');
							long i2;
							
							if ((!p) || (!po)) continue;

							i2 = (p - &linebuf[i]) + i;
							
							po->ext4 = (toupper(linebuf[i++]) << 8) | toupper(linebuf[i++]);
							po->ext5 = 0;
							
							if (i < i2)
							{
								po->ext5  = (toupper(linebuf[i++]) << 8);
								if (i < i2) po->ext5 |= toupper(linebuf[i]);
							}
							
							p++;
							po->descr = (char *)globalAlloc(strlen(p)+1L);
							if (!po->descr) continue;
							strcpy(po->descr,p);
							
							po->next = NULL;
							
							if (!objects) objects = po;
							else
							{
								Object *pod = objects;
								
								while (pod->next) pod = pod->next;
								pod->next = po;
							}
						}
						break;
					
					case STAT_MANAGER:
						{
							if (!strcmp(&linebuf[i],"NoCrashChecking")) crashtest = 0;
						}
						break;
					}
				}
			}
		}
	}
	
	Fclose(handle);
}



void find_inf(void)
{
	long ret;
	char path[128], *home = getenv("HOME");
	
	if (home)
	{
		char myhome[128];
		
		if (!strlen(home)) goto _nohome;
		
		strcpy(myhome,home);
		if (myhome[strlen(myhome)-1] != '\\') strcat(myhome,"\\");
		
		strcpy(path,myhome);
		strcat(path,"defaults\\");
		strcat(path,FILEINF);
		
		#ifdef DEBUG
		printf("%s (?)\n",path);
		#endif

		ret = Fopen(path,FO_READ);
		
		if (ret >= 0L) read_inf((int)ret);
		else
		{
			strcpy(path,myhome);
			strcat(path,FILEINF);
			
			#ifdef DEBUG
			printf("%s (?)\n",path);
			#endif
			
			ret = Fopen(path,FO_READ);
			
			if (ret < 0L) goto _nohome;
			
			read_inf((int)ret);
		}
	}
	else
	{
		_nohome:
		boot_device(path);
		strcat(path,FILEINF);
		
		#ifdef DEBUG
		printf("%s (?)\n",path);
		#endif
		
		ret = Fopen(path,FO_READ);
		
		if (ret >= 0L) read_inf((int)ret);
		else
		{
			strcpy(path,FILEINF);
			
			#ifdef DEBUG
			printf("%s (?)\n",path);
			#endif
			
			ret = Fopen(path,FO_READ);
			
			if (ret >= 0L) read_inf((int)ret);
			else
			{
				form_alert(1,MESSAGE_INFNOTFOUND);
			}
		}
	}

	#ifdef DEBUG
	printf("\n");
	#endif
}



void cdecl sig_handler(long sig)
{
	if ((sig==SIGTERM) || (sig==SIGQUIT)) termflag = 1;
}



void init_manager(void)
{
	#ifdef DEBUG
	printf(DEBUG_ACTIVATED);
	#endif

	_GemParBlk.global[0]=0;
	ap_id = appl_init();
	if (!_GemParBlk.global[0]) exit(0);
	if (ap_id < 0) exit(0);

	if (!_app) wind_update(BEG_UPDATE);

	Pdomain(1);
	check_cookies();
	
	if (_GemParBlk.global[1] != 1) multitask = 1;
	if ((_GemParBlk.global[0] >= 0x0400) && (multitask)) multitos = 1;
	
	allocmode = GLOBAL;
	if (_app) allocmode |= 3;
	
	read_name();
	check_info();
	
	if ((!_app) || ((multitos) && (!magix)))
	{
		menu_id = menu_register(ap_id,STRING_MENUENTRY);
		
		if (menu_id < 0)
		{
			if (!_app) wind_update(END_UPDATE);
			
			if (multitos)
			{
				appl_exit();
				exit(0);
			}
			else
			{
				while (1) evnt_timer(0,1);
			}
		}
	}
	
	find_inf();

	if (!_app) wind_update(END_UPDATE);

	Psignal(SIGTERM,sig_handler);
	Psignal(SIGQUIT,sig_handler);
	
	if (!multitask)
	{
		char s[256];
		
		strcpy(s,"[0][OLGA v");
		strcat(s,OLGAVERSIONSTR);
		strcat(s,"  Rev ");
		strcat(s,OLGAREVISION);
		strcat(s," (");
		strcat(s,OLGADATE);
		strcat(s,") | |");
		strcat(s,MESSAGE_MULTITASKING);
		
		form_alert(1,s);
		
		if (_app)
		{
			#ifdef DEBUG
			printf(DEBUG_DEACTIVATED);
			#endif
			
			appl_exit();
			exit(0);
		}
	}
	
	if (shutdown) shel_write(9,1,0,NULL,NULL);
	
	broadcast_olenew();
}
