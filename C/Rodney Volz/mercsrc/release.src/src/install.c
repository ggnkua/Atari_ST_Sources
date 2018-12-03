/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [install.c]
 */

#include <dir.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <osbind.h>
#include <string.h>
#include <time.h>

#define LLEN		200		/* Line length */


/*

FOR FUTURE USE!!!!

!!! THIS PROGRAM NOT TO BE DISTRIBUTED AS BINARY !!!

*/

struct path {
		char		name[LLEN];
		char		ident[LLEN];
		unsigned long	size;
		unsigned char	mode;
		time_t		time;
		struct path 	*next;
};

int errflag;
static char sccsid[] = "MERCURY UUCP install";
struct path *root,*tmp;
FILE *config,*env;
char cwd[LLEN];

main(argc,argv)
int argc;
char *argv[];
{
	FILE *fp,*ftmp;
	char s[LLEN];
	time_t tt;
	struct tm *tm;
	int n,i;

	root = (struct path *)malloc(sizeof(struct path));
	tmp = root;
	strcpy(cwd,"");

	errflag = 0;

	mkdir("\\etc");
	if ((config = fopen("\\etc\\config.new","w")) == NULL)
	{
		perror("fopen");
		exit(1);
	}
	
	if ((env = fopen("\\etc\\newenv.sh","w")) == NULL)
	{
		perror("fopen");
		exit(1);
	}

	strcpy(s,"x:");
	s[0] = (char)Dgetdrv() + 'A';
	scan(s);

	fprintf(config,"# Machine generated config file\n");
	fprintf(env,"# Machine generated env. settings\n");

	/* System device */
	fprintf(config,"%04d\t\"%s\"\n",1,s);
	fprintf(env,"setenv %s \"%s\"\n","DRIVE",s);

#if 0
	/* Sitename */
	printf("Enter the name of your site: ");
	fgets(s,LLEN - 2,stdin);
	fprintf(config,"%04d\t\"%s\"\n",2,s);
	fprintf(env,"setenv %s \"%s\"\n","SITENAME",s);

	/* Orga */
	printf("Enter your organization line: ");
	fgets(s,LLEN - 2,stdin);
	fprintf(config,"%04d\t\"%s\"\n",3,s);
	fprintf(env,"setenv %s \"%s\"\n","ORGA",s);

	/* Domain */
	printf("Enter the domain (e.g.: .gtc.de) of your site: ");
	fgets(s,LLEN - 2,stdin);
	fprintf(config,"%04d\t\"%s\"\n",4,s);
	fprintf(env,"setenv %s \"%s\"\n","DOMAIN",s);

	/* Redial */
	printf("Choose how often UUCICO should redial,\n");
	printf("when the remote host is busy: ");
	fgets(s,LLEN - 2,stdin);
	fprintf(config,"%04d\t\"%s\"\n",10,s);
	fprintf(env,"setenv %s \"%s\"\n","REDIAL",s);

	/* Relay */
	printf("Enter the name of your \"general relay host\": ");
	fgets(s,LLEN - 2,stdin);
	fprintf(config,"%04d\t\"%s\"\n",17,s);
	fprintf(env,"setenv %s \"%s\"\n","RELAY",s);
#else
	/* Sitename */
	fprintf(config,"%04d \"\"\t# Your sitename\n",2,s);
	fprintf(env,"setenv %s \"\"\t# Your sitename\n","SITENAME",s);

	/* Orga */
	fprintf(config,"%04d \"\"\t# Your organization line\n",3,s);
	fprintf(env,"setenv %s \"\"\t# Your organization line\n","ORGA",s);

	/* Domain */
	fprintf(config,"%04d\ \"\"\t# The domain of your site\n",4);
	fprintf(env,"setenv %s \"\"\t# The domain of your site\n","DOMAIN");

	/* Redial */
	fprintf(config,"%04d \"\"\t# Redial counter for UUCICO\n",10);
	fprintf(env,"setenv %s \"\"\t# Redial counter for UUCICO\n","REDIAL");

	/* Relay */
	fprintf(config,"%04d\t\"\"\t# Your general relay host\n",17,s);
	fprintf(env,"setenv %s \"\"\t# Your general relay host\n","RELAY");
#endif

	get(7,"uucico.prg","UUCICO");
	get(8,"compress.prg","COMPRESS");
	get(9,"passwd","PASSWD");
	get(11,"mail.prg","MAILER");
	get(12,"active","ACTIVE");
	get(13,"sys","SYSFILE");
	get(15,"hosts","HOSTS");
	get(19,"mydomain","DOMAINFILE");
	get(20,"me.prg","EDITOR");
	get(22,"paths","PATHSFILE");
	get(23,"des.prg","DES");
	get(24,"uuenc.prg","UUENC");
	get(25,"uudec.prg","UUDEC");
	get(26,"pnews.prg","PNEWS");

	fclose(config);
	fclose(env);

	if (errflag)
	{
		printf("One or more programs were not found on the\n");
		printf("device when install was started. To install\n");
		printf("Rodney's UUCP Modules properly, copy all\n");
		printf("files from the distribution disk to an empty\n");
		printf("partition, and start install.prg.\n\n");

		printf("You may now either restart installing, or\n");
		printf("proceed and hope, that everything's okay.\n");
	}

	printf("\nInstallation finished. There are two new files\n");
	printf("in the directory \"\\etc\":\n");
	printf("config.new: a prototype for \"config.sys\"; customize it!\n");
	printf("newenv.sh: Environment settings for a CLI. Customize!\n");
	printf("\nEither rename \"config.new\" to \"config.sys\", or\n");
	printf("execute \"newenv.sh\" with the CLI you use each time\n");
	printf("at startup.\n\nGood luck!\n-Rodney\n");
	fgets(s,LLEN - 2,stdin);
}



get(entry,file,envname)
char *file;
int entry;
char *envname;
{
	char *cp;

	printf("Looking for %s - ",file);

	for (tmp = root; tmp; tmp = tmp->next)
	{
		cp = strrchr(tmp->name,'\\');
		if (cp && !strcmp(++cp,file))
		{
			fprintf(config,"%04d\t\"%s\"\n",entry,tmp->name);
			fprintf(env,"setenv %s \"%s\"\n",envname,tmp->name);
			printf("okay\n");
			return(0);
		}
	}
	++errflag;
	printf("not found\n");
}



scan(dirname)
char *dirname;
{
	static char s[LLEN];
	static char flag;
	char *cp;
	DIR *dirp;
	struct dirent *entry;

	strcat(cwd,dirname);
	if ((dirp = opendir(cwd)) == NULL)
	{
		fprintf(stderr,"Cannot read %s\n",cwd);
		return(0);
	}
	
	printf("%s\n",cwd);

	for (entry = readdir(dirp); entry; entry = readdir(dirp))
	{
		if (isdir(entry) && strcmp(entry->d_name,".") && strcmp(entry->d_name,".."))
		{
			sprintf(s,"\\%s",entry->d_name);
			scan(s);
			continue;
		}

		if (isfile(entry))
		{
			strcpy(tmp->name,cwd);
			strcat(tmp->name,"\\");
			strcat(tmp->name,entry->d_name);
			tmp->time = entry->st_mtime;
			tmp->size = entry->st_size;
			tmp->mode = entry->st_mode;
			tmp->next = (struct path *)malloc(sizeof(struct path));
			tmp = tmp->next;
		}
	}
	closedir(dirp);

	if (strchr(cwd,'\\'))
	{
		cp = strrchr(cwd,'\\');
		*cp = '\0';
	}
}



int match(a,b)
char *a,*b;
{
	char *c1,*c2;
	char *p1,*p2;

	for (p1 = a; *p1; p1++)
	{
		c1 = p1;
		for (c2 = b; ; c2++)
		{
			if (!(*c2))
				return(1);

			if (*c1++ != *c2)
				break;
		}
	}
	return(0);
}


