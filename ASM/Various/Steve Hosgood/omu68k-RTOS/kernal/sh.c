/******************************************************************************
 *	Sh.c	Primitive shell-type routine.
 *		S.Hosgood, 23.feb.84, Modded T.Barnaby May 1985 for Codata
 ******************************************************************************
 *
 *	When the shell is used internal to the kernal certain system calls
 *	have to be made in a special way ie through the system wrapper,
 *	Not direct.
 *	The routines that are relevent to this are at the end of this file.
 *
 *		xeq()		called via syscall()
 *		kwait()		called via syscall()
 *		putchar()	All console io done via write() system call
 *				because of interupt driven TTY.
 */
# include	<sys/types.h>
# include	<errno.h>

#if	defined(MSDOS)
#define	STANDALONE	1
#define	WILDCARDS	1
#include	<sys/dirbsd.h>
#include	<process.h>
#else
# include	<sys/dir.h>
#endif

#if	defined(STANDALONE)
# include	<sys/stat.h>
# include	"inbin.h"
# define	printk	printf
#else
# include	"../include/stat.h"
# include	"../include/inbin.h"
# include	"../include/state.h"
#endif

/*	WILDCARDS	If required define wild cards for internal shell
 *			Is an option because it will make the kernal big
 *			Approx + 2K
 */
# define	WILDCARDS	1	/* Wild card mode on */

/*	DATESET		If a call to dateset is required on power up
 *			Then define DATESET here
 */
/* # define	DATESET		1 */

# define	NARGS		10	/* Max number of argv's */
# define	NENVS		10	/* Max number of env's */
# define	ARGLEN		40	/* Line length enviroment varibles */
# define	ENVLEN		40	/* Line length enviroment varibles */
# define	LINELEN		100	/* Line length shell files */
# define	NOTFOUND	-1	/* File not found to execute */

/*	Execute mode bits 	*/
# define	EBACKGRD	1	/* Background flag */
# define	ENOERROR	2	/* No error check on shell files */

extern	int errno;
extern	struct Comm kercom[];

/* Internal shell commands */
int	cd(), setenv(), echo(), pmem(), smem(), shexit(), setid(), kstate();

struct	Comm	shcom[] = {
	"cd", 0, cd,
	"exit", 0, shexit,
	"shutdown", 0, shexit,
	"setid", 0, setid,
	"setenv", 0, setenv,
	"echo", 0, echo,
	"pmem", 0, pmem,
	"smem", 0, smem,
	"kstate", 0, kstate,
	0, 0, 0,
};

int	fin, fout, ferr, chfiles;	/* Files opened */
char	shenv[NENVS][ENVLEN];		/* Shell enviroment varibles */

#ifdef	WILDCARDS

# define	MAXNARGS 	50	/* Max number of args */
# define	MAXAAREA	200	/* Max arg area */
# define	MAXPATH		50	/* Max path length */

struct	Args {
	int	nargs;			/* Number of args */
	char	*argp[MAXNARGS];	/* Argument pointers */
	char	*endarg;		/* Last entry in arg area */
	char	area[MAXAAREA];		/* Area where args is stored */
};

struct	Args wargv;

#endif	WILDCARDS

/*
 *	Sh()	Internal shell program itself
 */
sh()
{
	char input[100], *argv[NARGS], *env[NENVS];
	int nbytes, argc, c, in, error, backgnd, wargc;


#if	defined(STANDALONE)
	printk("Unix look-alike shell (testing)\n");
#else
	if(-1==chdir("/")) panic("change dir error\n"); 
	/* Opens all files for shell */
	openfiles();
	printk("68000 One-Man-Unix System.	Version 4.0\n");
	printk("Steve Hosgood, 1984 + Terry Barnaby 1985 + 1986\n");
#endif

	/* Setup enviroment pointers to enviroment area */
	for(c = 0; c < NENVS; c++) env[c] = shenv[c];

	/* Sets up dummy enviroment */
	strcpy(shenv[0],"PATH=:/bin:/usr/bin:/INBIN");
	strcpy(shenv[1],"HOME=/usr");
	strcpy(shenv[2],"TERM=terries1");
	strcpy(shenv[3],"TERMCAP=/etc/termcap");
	strcpy(shenv[4],"EXINIT=map #0 i|map #1 x|set sm");
	strcpy(shenv[5],"SHELL=/bin/csh");
	env[5] = 0;

# ifdef DATESET
	/* set time */
	argv[0] = "date";
	printk("Enter date yymmddhhmm ? ");
	if(getin(input)){
		argv[1] = input;
		argv[2] = 0;
		if(execute("/bin/date", 2, argv, env, 0))
			printk("Internal sh: Unable to execute /bin/date\n");
	}
# endif

	/* Execute /etc/rc if present */
	argv[0] = "rc";
	argv[1] = 0;
	execute("/etc/rc", 1, argv, env, ENOERROR);

	/* Main shell internal loop */
	while (1){
		/* Prints prompt depending if root or not */
		if(getuid()) write(1, "$> ", 3);
		else write(1, "INSH# ", 6);

		/* Gets input line */
		nbytes = getin(input);

		/* If no command continue to start of loop */
		if (nbytes <= 1)
			continue;

		/* Parse the input command line into arguments */
		argc = parse(input, argv);

		/* Checks if process is to run background */
		if(argv[argc-1][0] == '&'){
			backgnd = 1;
			argv[--argc] = 0;
		}
		else backgnd = 0;

		/* Check if any file redirections required 
		 * Sets file numbers as apropriate and sets chfiles
		 * To indicate files have changed
		 */
		if((argc = chredir(argc, argv)) == -1) continue;

#ifdef	WILDCARDS

		/* Clear all previous args */
		clearargs(&wargv);
		wargc = 0;
		for(c = 0; c < argc; c++){
			/* Check if argument has wild cards if so do wild
			 * card expansion
			 */
			if(wiswild(argv[c])){
				if((in = wildexp(argv[c], "", &wargv)) == -1){
					printk("Two many args\n");
					break;
				}
			}
			/* Else just add argument to args */
			else{
				if(!(in = addarg(argv[c], &wargv))){
					printk("Two many args\n");
					break;
				}
			}
			wargc += in;
		}

		/* Try and execute program */
		error = execute(wargv.argp[0], wargv.nargs, wargv.argp, env, backgnd);
		/* If any redirections set to origanal files */
		if(chfiles){
			close(0);
			close(1);
			close(2);
			openfiles();
		}

#else
		/* Try and execute program */
		error = execute(argv[0], argc, argv, env, backgnd);
		/* If any redirections set to origanal files */
		if(chfiles){
			close(0);
			close(1);
			close(2);
			openfiles();
		}

#endif	WILDCARDS

		/* Print error messages */
		switch(error){
		case 0:
			break;

		case NOTFOUND:
			/* Failed all attempts */
			printk("%s: not found\n", argv[0]);
			break;

		default:
			printk("%s: terminated %x\n",argv[0], error);
			break;
		}
	}
}
/*
 *	Getin()		Get user input
 */
getin(str)
char	*str;
{
	int	num;

	num = 0;
	while(1){
		read(fin, str, 1);
		num++;
		if((*str == '\n') || (*str == ';')) break;
		str++;
	}
	*str = 0;

	return num;
}

/*
 *	Opens all files for shell
 */
openfiles(){
	if ((fin = open("/dev/console", 2)) == -1){
		if ((fin = open(":console", 2)) == -1)
			panic("No console");
	}

	if (fin) panic("Std input non-zero");

	fout = dup(fin);		/* Stdout and stderr */
	ferr = dup(fout);
	chfiles = 0;
}
/*
 *	Parse()		Parse command line into arguments return number.
 */
parse(cptr, argv)
char *cptr;
char *argv[];
{
	int argc;
	char	fquote;

	/* scan line, breaking into args */
	fquote = argc = 0;

	while (1){
		/* miss leading spaces */
		while (*cptr && *cptr == ' ')
			cptr++;

		if (*cptr){
			/* Check if quotes start of argument */
			if(*cptr == '"'){
				fquote = 1;
				cptr++;
			}

			/* arg there */
			argv[argc++] = cptr;

			/* scan to end of word */
			while (*cptr && ((*cptr != ' ') || fquote) &&
				(*cptr != '"')) cptr++;

			/* null terminate arg */
			if ((*cptr == ' ') || (*cptr == '"')){
				*cptr++ = '\0';
				fquote = 0;
			}
		}
		else
			break;

		if(argc >= (NARGS - 1)) break;
	}
	argv[argc] = 0;
	return argc;
}

/*
 *	Execute()	Execute program, first checks internal shell
 *			commands then looks in places as defined in the
 *			enviroment varible PATH.
 *			If not found will exectute internal kernal command if
 *			found.
 *			Will execute shell files if found.
 *			Returns NOTFOUND if not found, or exit status
 *			of process if found.
 */
execute(name, argc, argv, env, eflag)
char *name;
int argc, eflag;
char *argv[], *env[];
{
	struct Comm *coms;
	char	path[ENVLEN], *ps, *pe;
	char	execname[ARGLEN];
	int error;

	/* Creates new proccess useing xeq (does fork and execl in one) */
	error = 0;

	/* Failed - try in PATH varible places */
	/* Get path string */
	retenv(env, "PATH", path);
	ps = path;

	/* Check internal shell commands */
	coms = shcom;
	while (coms->c_name && strcmp(coms->c_name, name) != 0) coms++;

	/* Execute if found */
	if(coms->c_name){
		return (*coms->c_routine)(argc, argv, env);
	}

	/* Else check the paths as defined in the PATH enviroment */
	while(1){
		/* If end of path string break */
		if(!(*ps)) break;

		/* Find the end of the path entry */
		pe = ps;
		while(*pe && (*pe != ':')) pe++;
		if(*pe) *pe++ = 0;

		/* Copy this entry into the execname place and execute normally 
		 */
		strcpy(execname, ps);

		/* If ps has a path in it add a slash */
		if(execname[0]) strcat(execname, "/");

		strcat(execname, name);
		if((error = shexec(execname, argv, env, eflag)) != NOTFOUND)
			return error;

		/* Check if could be shell file */
		if((error = shellfile(execname, argc, argv, env, eflag)) != NOTFOUND)
			return error;

		/* Next entry */
		ps = pe;
	}

	/* failed there too - try built-in kernal commands */
	coms = kercom;
	while (coms->c_name && strcmp(coms->c_name, name) != 0) coms++;

	/* try and execute */
	if (coms->c_name){
		return (*coms->c_routine)(argc, argv, env);
	}

	return NOTFOUND;
}

/*
 *	Shellfile()	Try and run shell file.
 *			Returns -1 if not found or not executable,
 *			Exit status of terminated program invoked.
 */
shellfile(name, argc, argv, env, eflag)
char *name;
int argc, eflag;
char *argv[], *env[];
{
	char *sargv[NARGS];
	int file, sargc, err, error, backgnd;
	char str[LINELEN];

	/* Check if file executable */
	if(access(name, 1)) return NOTFOUND;

	/* Open file and execute */
	if((file = open(name, 0)) != -1){
		while(1){
			if((err = getline(file, str)) == 1){
				sargc = parse(str, sargv);

				/* Checks if process is to run background */
				backgnd = eflag & ENOERROR;
				if(sargv[argc-1][0] == '&'){
					backgnd |= EBACKGRD;
					sargv[--argc] = 0;
				}

				/* Try and execute program */
				error = execute(sargv[0],sargc,sargv,env,backgnd);
				/* If errors are to be checked do check */
				if(!(eflag & ENOERROR)){
					switch(error){
					case 0:
						/* No error */
						break;

					case NOTFOUND:
						/* Failed to execute */
						printk("%s: not found\n", sargv[0]);
						return error;

					default:
						/* Process returned with error */
						printk("%s: terminated %x\n", sargv[0],
						error);
						return error;
					}
				}
			}
			else{
				if(err == -1) return NOTFOUND;
				else break;
			}
		}
		close(file);
	}
	else return NOTFOUND;
	return 0;
}
/*
 *	Getline()	Getline from a file terminated with newline.
 *			Returns 1 if found, 0 if end of file -1 if error.
 *			Ignores zero length lines and line begining with
 *			a #.
 */
getline(file, line)
int file;
char *line;
{
	int count, n;
	char *str;

	/* Scans file for input line */
	count = 0;
	while(!count){
		str = line;
		*str = 0;
		while(n = read(file, str, 1)){
			if((*str == '\n') || (*str == ';')){
				*str = 0;
				break;
			}
			if((*str < ' ') || (*str > 'z')) return -1;
			if(!count && (*str == '#')){
				while((n = read(file, str, 1)) && *str != '\n');
				break;
			}

			str++;
			if(++count >= LINELEN) return -1;
		}
		if(!n) return 0;
	
	}
	return 1;
}
/*
 *	Chredir()	Check if any file redirections if found opens
 *			relevent files, and flags filech to indicate
 *			I/O files have been changed, removes
 *			the args from argv and returns the new value of argc;
 */
chredir(argc, argv)
int	argc;
char	*argv[];
{
	int	c, rmarg, a;

	chfiles = 0;
	for(c = 0; c < argc; c++){
		rmarg = 0;
		switch(argv[c][0]){
		case '<':
			if((fin = open(argv[c + 1], 0)) == -1){
				printk("Unable to open input file %s\n",argv[c]);
				fin = 0;
				return -1;
			}
			else{
				dup2(fin, 0);
				close(fin);
				rmarg = 1;
				chfiles++;
			}
			break;

		case '>':
			if(argv[c][1] == '&'){
				if((ferr = creat(argv[c + 1], 0666)) == -1){
				printk("Unable to create output file %s\n",argv[c]);
					ferr = 2;
					return -1;
				}
				else{
					dup2(ferr, 2);
					close(ferr);
					rmarg = 1;
					chfiles++;
				}
			}
			else{
				if((fout = creat(argv[c + 1], 0666)) == -1){
					printk("Unable to create output file %s\n",argv[c]);
					fout = 1;
				}
				else{
					dup2(fout, 1);
					close(fout);
					rmarg = 1;
					chfiles++;
				}
				break;
			}
		default:
			break;
		}

		/* If required remove args from argument list */
		if(rmarg){
			/* Set c to first arg to be removed and shift up
			 * Args above to take its place
			 */
			for(a = c; 1; a++){
				argv[a] = argv[a + 2];
				if(!argv[a]) break;
			}
			argc -= 2;
			c--;
		}
	}
	return argc;
}

/*
 *	Retenv()	Returns enviroment string whose name is given.
 */
retenv(env, name, str)
char	*env[];
char	*name, *str;
{
	int	c;

	for(c = 0; c < (NENVS -1); c++){
		if(env[c] && !strncmp(env[c], name, strlen(name))){
			name = env[c];
			while(*name++ != '=');
			strcpy(str, name);
		}
	}
	return 0;
}

shexit(n)
int n;
{
	sync();

#if	defined(STANDALONE)
#else
	/* Calls machine shut for things like floppy off etc */
	mach_shut();
#endif
	exit(n);
}

/*
 * Cd - built-in change-directory command.
 */
cd(argc, argv)
char *argv[];
{
	if (argc == 1)
		argv[1] = "/";
	else if (argc != 2){
		printk("cd: too many args\n");
		return -1;
	}

	if (chdir(argv[1]))
		printk("cd: invalid directory\n");

	return 0;
}

/*
 *	Setid()		Sets userid and gid of shell
 */
setid(argc,argv)
char *argv[];
int argc;
{
	if(argc != 3){
		printk("Usage:	setid <uid> <gid>\n");
		return -1;
	}
	if(setgid(atoi(argv[2])) == -1) return -1;
	if(setuid(atoi(argv[1])) == -1) return -1;
	return 0;
}

/*
 *	Set enviroment varibles
 */
setenv(argc, argv, env)
int argc;
char *argv[], *env[];
{
	int c;

	/* Check arguments */
	if(argc != 3){
		printk("usage: set <Varible> <setting>\n");
		return -1;
	}
	/* Check if room for this entry */
	if((strlen(argv[1]) + strlen(argv[2]) + 2) >= ENVLEN){
		printk("Enviroment varible to long\n");
		return -1;
	}
	for(c = 0; c < (NENVS -1); c++){
		if(env[c] == 0){
			env[c] = shenv[c];
			env[c+1] = 0;
			strcpy(env[c], argv[1]);
			strcat(env[c], "=");
			strcat(env[c], argv[2]);
			return 0;
		}
		else {
			if(!strncmp(env[c], argv[1], strlen(argv[1]))){
				strcpy(env[c], argv[1]);
				strcat(env[c], "=");
				strcat(env[c], argv[2]);
				return 0;
			}
		}
	}
	printk("To many enviroment strings\n");
	return -1;
}

/*
 *	Echo()		Echos is arguments to tty
 */
echo(argc, argv)
int	argc;
char	*argv[];
{
	int	c;

	for(c = 1; c < argc; c++) printk("%s ",argv[c]);
	printk("\n");

	return 0;
}

#if	defined(STANDALONE)
#else
/*
 *	Kstate()	Sets the state of the kernal
 */
kstate(argc, argv)
int	argc;
char	*argv[];
{
	int	c;

	if(argc == 1){
		printk("Usage: kstate <0, 1> (warnings off, on)\n");
		return 1;
	}
	state.warning = atoi(argv[1]);
	return 0;
}
#endif


/******************************************************************************
 *	Routines special to internal shell
 ******************************************************************************
 */

/******************************************************************************
 *	Shexec()	Shell execute new process and wait till finished
 *			returns -1 if not found, or exit status if found.
 ******************************************************************************
 */

# define	XEQ	75		/* Program execute syscall no */


shexec(name, argv, env, eflag)
char *name;
char *argv[], *env[];
int eflag;
{ 
	int pid, cpid, error;

#if	defined(MSDOS)
	/* Execute new process and get pid */
	if ((error = spawnve(P_WAIT, name, argv, env)) == -1) return NOTFOUND;
	else return error;
#else
	/* Execute new process and get pid */
	if ((cpid = syscall(XEQ, name, argv, env)) != -1){

		/* If process is in background continue */
		if(eflag & EBACKGRD) return 0;

		/* Else check for all child processes until this one dies
		 * This will also collect any system zombies etc
		 */
		do{
			pid = wait(&error);
		} while((pid != cpid) && (pid != -1));
		return error;
	}
	else return NOTFOUND;
#endif
}

#ifdef	WILDCARDS

/*
 *	Clearargs()	Clears the arguments in the arg structure given.
 */
clearargs(args)
struct	Args *args;
{
	args->nargs = 0;
	args->argp[0] = 0;
	args->endarg = args->area;
	return 0;
}

/*
 *	Addarg()	Adds an argument to the given structure
 *			Returns 1 if possible 0 if not.
 */
addarg(str, args)
char	*str;
struct	Args *args;
{
	/* Checks if there is room for arguments */
	if(args->nargs >= MAXNARGS) return 0;
	if((args->endarg + strlen(str) + 1) >= &args->area[MAXAAREA]) return 0;

	/* Adds new arg to the area */
	strcpy(args->endarg, str);
	args->argp[args->nargs++] = args->endarg;
	args->argp[args->nargs] = 0;
	args->endarg += (strlen(str) + 1);
	return 1;
}

/*
 *	Wiswild()	Checks if the given string has wild chars in it
 */
wiswild(name)
char	*name;
{
	while(*name) if((*name == '*') || (*name++ == '?')) return 1;
	return 0;
}

/*
 *	Wildexp()	Expands the given name using the given directory
 *			Puting all arguments found into the args array.
 *			Returns number of args found, -1 if error.
 */
#if	defined(MSDOS)
wildexp(name, dirname, args)
char	*name, *dirname;
struct	Args *args;
{
	struct	direct *dir;
	DIR	*dirp;
	char	nextdir[MAXPATH];
	char	*nextname, *arg;
	int	df, ar, ars;

	/* If no directory name given and not full path name then set
	 * to current dir "."
	 */
	if(!(*dirname)){
		if(*name == '/') dirname = "/";
		else dirname = ".";
	}
	/* Check if directory accesable */
	if((dirp = opendir(dirname)) == 0) return 0;

	ar = 0;

	/* Get rid of any leading slashes's */
	while(*name == '/') name++;

	/* Find out if further sub dirs need to be searched */
	nextname = name;
	while(*nextname && (*nextname != '/')) nextname++;
	if(*nextname){
		/* If so set name to point to required dir
		 * Set nextname to point to name of file or further sub-dirs.
		 */
		*nextname++ = 0;
	}

	/* Read each directory entry and check for match ignore .'s */
	while(dir = readdir(dirp)){
		if(dir->d_ino && strcmp(dir->d_name, ".") &&
			strcmp(dir->d_name, "..")){
			if(wildstr(name, dir->d_name)){
				if((strlen(nextdir) + strlen(dir->d_name) + 2) >
					MAXPATH) return -1;
				strcpy(nextdir, dirname);
				if(nextdir[0] && (nextdir[strlen(nextdir) - 1] != '/')) strcat(nextdir,"/");
				strcat(nextdir,dir->d_name);
				if(!(*nextname)){
					/* Remove unecessary first bits */
					arg = nextdir;
					if((*arg == '.') && (*(arg+1) != '.')){
						arg += 2;
						if(*arg == '/') arg++;
					}
					if(!addarg(arg, args)) return -1;
					ar++;
				}
				else{
					if(wisdir(nextdir)){
						if((ars = wildexp(nextname, nextdir, args)) == -1) return -1;
						ar += ars;
					}
				}
			}
		}
	}

	/* Recover origanal name */
	if(*nextname--) *nextname = '/';
	closedir(dirp);
	return ar;
}
#else
wildexp(name, dirname, args)
char	*name, *dirname;
struct	Args *args;
{
	struct	direct dir;
	char	nextdir[MAXPATH];
	char	*nextname, *arg;
	int	df, ar, ars;

	/* If no directory name given and not full path name then set
	 * to current dir "."
	 */
	if(!(*dirname)){
		if(*name == '/') dirname = "/";
		else dirname = ".";
	}
	/* Check if directory accesable */
	if((df = open(dirname, 0)) == -1) return 0;

	ar = 0;

	/* Get rid of any leading slashes's */
	while(*name == '/') name++;

	/* Find out if further sub dirs need to be searched */
	nextname = name;
	while(*nextname && (*nextname != '/')) nextname++;
	if(*nextname){
		/* If so set name to point to required dir
		 * Set nextname to point to name of file or further sub-dirs.
		 */
		*nextname++ = 0;
	}

	/* Read each directory entry and check for match ignore .'s */
	while(read(df, &dir, sizeof(struct direct))){
		if(dir.d_ino && strcmp(dir.d_name, ".") &&
			strcmp(dir.d_name, "..")){
			if(wildstr(name, dir.d_name)){
				if((strlen(nextdir) + strlen(dir.d_name) + 2) >
					MAXPATH) return -1;
				strcpy(nextdir, dirname);
				if(nextdir[0] && (nextdir[strlen(nextdir) - 1] != '/')) strcat(nextdir,"/");
				strcat(nextdir,dir.d_name);
				if(!(*nextname)){
					/* Remove unecessary first bits */
					arg = nextdir;
					if((*arg == '.') && (*(arg+1) != '.'))
						arg += 2;
					if(*arg == '/') arg++;
					if(!addarg(arg, args)) return -1;
					ar++;
				}
				else{
					if(wisdir(nextdir)){
						if((ars = wildexp(nextname, nextdir, args)) == -1) return -1;
						ar += ars;
					}
				}
			}
		}
	}

	/* Recover origanal name */
	if(*nextname--) *nextname = '/';
	close(df);
	return ar;
}
#endif

/*
 *	Wisdir()	Returns S_IFDIR if the file given is a directory
 */
wisdir(name)
char	*name;
{
	struct	stat status;

	stat(name, &status);
	return (status.st_mode & S_IFDIR);
}

/*
 *	Wildstr()	Checks to see if the wild-carded string is equal
 *			to the given string. Returns 1 is equal.
 */
wildstr(estr, name)
char	*estr, *name;
{
	while(*estr){
		if(*estr == '*'){
			estr++;
			if(!(*estr)) return 1;
			while(*name && (*name != *estr)) name++;
			if(!(*name)) return 0;
		}
		if(*estr != '?'){
			if(*name != *estr) return 0;
		}
		estr++;
		name++;
	}
	if(*name || *estr) return 0;
	else return 1;
}
#endif	WILDCARDS

#if	defined(STANDALONE)
pmem(){
	printk("No pmem in standalone\n");
	return (1);
}
smem(){
	printk("No smem in standalone\n");
	return (1);
}
kstate(){
	printk("No kstatein standalone\n");
	return (1);
}
#endif
