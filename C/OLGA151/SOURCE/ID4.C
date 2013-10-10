/**************************
 * id4.c                  *
 **************************
 **************************
 * [1998-06-02, tm]       *
 * - first C version      *
 **************************/

#include "manager.h"
#include "start.h"
#include "id4.h"


void olga_getobjects(int *pipe)
{
	App *pa = NULL, *pad = apps;
	
	#ifdef DEBUG
	printf("OLGA: OLGA_GETOBJECTS App %i  ",pipe[1]);
	if (!pipe[3]) printf("first  (");
	else
		printf("next  (");
	#endif
	
	while (pad)
	{
		if (pad->apID == pipe[1])
		{
			pa = pad;
			break;
		}
	
		pad = pad->Next;
	}
	
	if (pa)
	{
		if (!pipe[3]) pa->enumOLE = objects;
		
		if (pa->enumOLE)
		{
			int answ[8];
			Object *pod = pa->enumOLE->next;

			answ[0] = OLGA_OBJECTS;
			answ[1] = ap_id;
			answ[2] = 0;
			answ[3] = 0;
			answ[4] = pa->enumOLE->ext4;
			answ[5] = pa->enumOLE->ext5;
			answ[6] = (int)(((long)pa->enumOLE->descr >> 16) & 0x0000ffffL);
			answ[7] = (int)((long)pa->enumOLE->descr & 0x0000ffffL);
			
			while (pod)
			{
				answ[3]++;
				pod = pod->next;
			}
			
			#ifdef DEBUG
			printf("%i,%s",answ[3],pa->enumOLE->descr);
			#endif
			
			appl_write(pipe[1],16,answ);
			
			pa->enumOLE = pa->enumOLE->next;
		}
	}
	
	#ifdef DEBUG
	printf(")\n");
	#endif
}



void olga_activate(int *pipe)
{
	int answ[8], anz = pipe[5];
	char *pc = *(char **)&pipe[3], *fname = (char *)malloc(512L);
	
	#ifdef DEBUG
	printf("OLGA: OLGA_ACTIVATE App %i  #%i",pipe[1],anz);
	if ((anz < 1) || (!pc)) printf("\n");
	else
	{
		int q;
		char *p = pc;
		
		printf(" (");
		for(q=0; q < (anz << 2); q++) printf("%c",*p++);
		printf(")\n");
	}
	#endif
	
	if ((anz < 1) || (!pc) || (!fname)) goto _raus;
	
	do
	{
		int e4,e5;
		Extension *pe;
		
		e4 = (*pc++ << 8) | *pc++;
		e5 = (*pc++ << 8) | *pc++;
		
		fname[0] = 0;
		pe = extensions;
		
		while (pe)
		{
			if (pe->ext5 == e5)
			{
				if (pe->ext4 == e4)
				{
					strcpy(fname,pe->path);
					expand_path(fname);

					break;
				}
			}
			
			pe = pe->next;
		}
		
		if (strlen(fname))
		{
			int svID;
			char sname[10], *p = strrchr(fname,'\\');

			if (!p) p = fname;
			else
				p++;
	
			strncpy(sname,p,8L);
			sname[8] = 0;
	
			p = strchr(sname,'.');
			if (p) *p = 0;
	
			while (strlen(sname)<8) strcat(sname," ");
			strupr(sname);
			
			svID = appl_find(sname);

			if (svID >= 0) server_started(svID,pipe[1],e4,e5,1);
			else
			{
				char empty = 0, *tmp_cwd = (char *)malloc(512L);
				int  tmp_drive = Dgetdrv();

				#ifdef DEBUG
				printf("  ...starting %s (%c%c%c%c)\n",fname,(e4 >> 8) & 0x00ff, e4 & 0x00ff,(e5 >> 8) & 0x00ff, e5 & 0x00ff);
				#endif
				
				if (tmp_cwd) Dgetpath(tmp_cwd,tmp_drive+1);
				
				if (strlen(fname) > 1)
				{
					if (fname[1] == ':') Dsetdrv(toupper(fname[0])-65);
				}

				p = strrchr(fname,'\\');
				if (p)
				{
					char c = *(++p);
					
					*p = 0;
					Dsetpath(fname);
					*p = c;
				}

				if (magix)
					svID = shel_write(1,1,100,fname,&empty);
				else
					svID = shel_write(0,1,1,fname,&empty);
					
				if (svID)
				{
					server_started(svID,pipe[1],e4,e5,0);
					evnt_timer(1500,0);
				}
				else
				{
					Dsetdrv(tmp_drive);
					if (tmp_cwd) Dsetpath(tmp_cwd);
				}
				
				if (tmp_cwd) free(tmp_cwd);
			}
		}

	} while (--anz > 0);

	_raus:

	answ[0] = OLGA_ACK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = pipe[5];
	answ[6] = 0;
	answ[7] = OLGA_ACTIVATE;

	appl_write(pipe[1],16,answ);
	
	if (fname) free(fname);
}



void olga_embed(int *pipe)
{
	int svID = -1;
	Extension *pe = extensions;
	char *fname = NULL;
	
	#ifdef DEBUG
	printf("OLGA: OLGA_EMBED App %i (%c%c%c%c)  ",pipe[1],(pipe[6] >> 8) & 0x00ff,pipe[6] & 0x00ff,(pipe[7] >> 8) & 0x00ff,pipe[7] & 0x00ff);
	#endif
	
	while (pe)
	{
		if (pe->ext5 == pipe[7])
		{
			if (pe->ext4 == pipe[6])
			{
				fname = (char *)malloc(512L);
				
				if (fname)
				{
					strcpy(fname,pe->path);
					expand_path(fname);
				}
				
				break;
			}
		}
		
		pe = pe->next;
	}
	
	if (fname)
	{
		char sname[10], *p = strrchr(fname,'\\');
		
		if (!p) p = fname;
		else
			p++;

		strncpy(sname,p,8L);
		sname[8] = 0;

		p = strchr(sname,'.');
		if (p) *p = 0;

		while (strlen(sname)<8) strcat(sname," ");
		strupr(sname);
	
		svID = appl_find(sname);
	}
	
	if (svID < 0)
	{
		int answ[8];
		
		#ifdef DEBUG
		printf("error: ");
		if (!fname) printf("extension not assigned\n");
		else
			printf("server not running\n");
		#endif
		
		answ[0] = OLGA_EMBEDDED;
		answ[1] = ap_id;
		answ[2] = 0;
		answ[3] = pipe[3];
		answ[4] = pipe[4];
		answ[5] = pipe[5];
		answ[6] = 0;
		answ[7] = 0;

		appl_write(pipe[1],16,answ);
	}
	else
	{
		int answ[8];
		
		#ifdef DEBUG
		printf("calling server %i\n",svID);
		#endif

		answ[0] = OLGA_EMBED;
		answ[1] = ap_id;
		answ[2] = 0;
		answ[3] = pipe[3];
		answ[4] = pipe[4];
		answ[5] = pipe[5];
		answ[6] = 0;
		answ[7] = pipe[1];

		appl_write(svID,16,answ);
	}
	
	if (fname) free(fname);
}
