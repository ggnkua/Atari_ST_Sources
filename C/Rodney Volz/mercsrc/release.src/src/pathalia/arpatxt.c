#ifndef lint
static char *sccsid = "@(#)arpatxt.c	9.4 88/09/21";
#endif

/*
 * convert hosts.txt into pathalias format.
 *
 * alias rule: "host.dom.ain,nickname.arpa,..." -> host = nickname, ...
 */

/* remove the next line for standard or research unix */
#define BSD

#ifdef BSD
#define strchr index
#endif /* BSD */

#include <stdio.h>
#include <ctype.h>

/* imports */
extern char *re_comp(), *malloc(), *strchr(), *calloc();
extern char *gets(), *strcpy(), *fgets();
extern FILE *fopen();

typedef struct node node;

struct node {
	node *child;	/* subdomain or member host */
	node *parent;	/* parent domain */
	node *next;	/* sibling in domain tree or host list */
	char *name;	/* host name */
	node *alias;	/* list of aliases */
	node *bucket;
	node *gateway;
	int  flag;
};

node *Top;
int Atflag, Fflag, Iflag, Vflag;
char *DotArpa = ".ARPA";
char Fname[256], *Fstart;

node *newnode(), *find();
char *strsave(), *lowercase();
void crcinit();
long fold();
FILE *mkfile();
int insert();

#define ISADOMAIN(n) ((n) && *((n)->name) == '.')

/* for node.flag */
#define COLLISION 1

/* for formatprint() */
#define PRIVATE		0
#define HOSTS		1
#define SUBDOMAINS	2

/* for usage() */
#define USAGE "usage: %s [-i@] [-g gateway] [-p privatefile] [-f | -d directory] [file ...]\n"

main(argc, argv)
	char **argv;
{	int c;
	char *progname;
	extern char *optarg;
	extern int optind;

	if ((progname = strchr(argv[0], '/')) != 0)
		progname++;
	else
		progname = argv[0];
	crcinit();

	Top = newnode();	/* needed for adding gateways */
	while ((c = getopt(argc, argv, "d:fg:ip:v@")) != EOF)
		switch(c) {
		case 'd':
			strcpy(Fname, optarg);
			break;
		case 'f':	/* filter mode -- write on stdout */
			Fflag++;
			break;
		case 'g':
			gateway(optarg);
			break;
		case 'i':
			Iflag++;
			break;
		case 'p':
			readprivates(optarg);
			break;
		case 'v':
			Vflag++;
			break;
		case '@':
			Atflag++;
			break;
		default:
			usage(progname);
		}

	if (Fflag && *Fname)
		usage(progname);
	if (Iflag)
		(void) lowercase(DotArpa);
	if (Top->gateway == 0)
		fprintf(stderr, "%s: warning: no gateway to top level domains\n", progname);

	Fstart = Fname + strlen(Fname);
	if (Fstart != Fname) {
		*Fstart++ = '/';
		*Fstart = 0;
	}
	/* should do the mkdir here instead of the shell script ...*/
		
	Top->name = "internet";
	if (optind == argc)
		scan();
	else for ( ; optind < argc; optind++) {
		if (freopen(argv[optind], "r", stdin) == 0) {
			perror(argv[optind]);
			continue;
		}
		scan();
	}
	setuniqflag(Top);	/* look for and mark collisions */
	hashanalyze();		/* check hash algorithm performance */
	merge();		/* make unique domain names */
	dump(Top);		/* print */
	return 0;
}

scan()
{	static first;
	char buf0[BUFSIZ], buf1[BUFSIZ], buf2[BUFSIZ];

	if (first++ == 0)
		(void) re_comp("^HOST.*SMTP");
	while (gets(buf0) != 0) {
		if (re_exec(buf0) == 0)
			continue;
		if (sscanf(buf0, "HOST : %[^:] : %[^: ]", buf1, buf2) != 2)
			continue;
		if (Iflag)
			(void) lowercase(buf2);
		if (insert(buf2) != 0)
			fprintf(stderr, "input error: %s\n", buf0);
	}
}
/*
 * format of private file:
 *	one per line, optionally followed by white space and comments
 *	line starting with # is comment
 */
readprivates(pfile)
	char *pfile;
{	FILE *f;
	node *n;
	char buf[BUFSIZ], *bptr;

	if ((f = fopen(pfile, "r")) == 0) {
		perror(pfile);
		return;
	}
	while (fgets(buf, BUFSIZ, f) != 0) {
		if (*buf == '#')
			continue;
		if ((bptr = strchr(buf, ' ')) != 0)
			*bptr = 0;
		if ((bptr = strchr(buf, '\t')) != 0)
			*bptr = 0;
		if (*buf == 0)
			continue;
		n = newnode();
		n->name = strsave(buf);
		hash(n);
	}
	(void) fclose(f);
}
usage(progname)
	char *progname;
{
	fprintf(stderr, USAGE, progname);
	exit(1);
}

dumpgateways(ndom, f)
	node *ndom;
	FILE *f;
{	node *n;

	for (n = ndom->gateway; n; n = n->next) {
		fprintf(f, "%s ", n->name);
		if (Atflag)
			putc('@', f);
		fprintf(f, "%s(%s)\t# gateway\n", ndom->name,
				ndom == Top ? "DEDICATED" : "LOCAL");
	}
}

gateway(buf)
	char *buf;
{	node *n, *dom;
	char *dot;

	dot = strchr(buf, '.');
	if (dot) {
		dom = find(dot);
		*dot = 0;
	} else
		dom = Top;

	n = newnode();
	n->name = strsave(buf);
	n->next = dom->gateway;
	dom->gateway = n;
}
	
int
insert(buf)
	char *buf;
{	char host[BUFSIZ], *hptr, *dot;
	node *n;

	for (hptr = host; *hptr = *buf++; hptr++)
		if (*hptr == ',')
			break;

	if (*hptr == ',')
		*hptr = 0;
	else
		buf = 0;	/* no aliases */

	if ((dot = strchr(host, '.')) == 0)
		return 1;	/* can't happen */
	
	if (strcmp(dot, DotArpa) == 0)
		buf = 0;		/* no aliases */

	n = find(dot);
	*dot = 0;

	addchild(n, host, buf);
	return 0;
}

node *
find(domain)
	char *domain;
{	char *dot;
	node *parent, *child;

	if (domain == 0)
		return Top;
	if ((dot = strchr(domain+1, '.')) != 0) {
		parent = find(dot);
		*dot = 0;
	} else
		parent = Top;

	for (child = parent->child; child; child = child->next)
		if (strcmp(domain, child->name) == 0)
			break;
	if (child == 0) {
		child = newnode();
		child->next = parent->child;
		parent->child = child;
		child->parent = parent;
		child->name = strsave(domain);
	}
	return child;
}

node *
newnode()
{
	node *n;

	if ((n = (node *) calloc(1, sizeof(node))) == 0)
		abort();
	return n;
}

char *
strsave(buf)
	char *buf;
{	char *mstr;

	if ((mstr = malloc(strlen(buf)+1)) == 0)
		abort();
	strcpy(mstr, buf);
	return mstr;
}

addchild(n, host, aliases)
	node *n;
	char *host, *aliases;
{	node *child;

	/* check for dups?  nah! */
	child = newnode();
	child->name = strsave(host);
	child->parent = n;
	child->next = n->child;
	makealiases(child, aliases);
	n->child = child;
}

/* yer basic tree walk to make output */
dump(n)
	node *n;
{	node *child;
	FILE *f;
	int privates;

	/* sanity check */
	if (n != Top && ! ISADOMAIN(n))
		abort();

	f = mkfile(n);		/* prepare the output file */
	privates = domprint(n, f);		/* print this domain */
	dumpgateways(n, f);	/* print any gateways to this domain */
	if (privates || n == Top)
		fputs("private {}\n", f);	/* end scope of privates */
	if (Fflag)
		putc('\n', f);
	else
		(void) fclose(f);
	for (child = n->child; child; child = child->next)
		if (child->child)
			dump(child);
}

qcmp(a, b)
	node **a, **b;
{
	return strcmp((*a)->name, (*b)->name);
}

domprint(n, f)
	node *n;
	FILE *f;
{	node *table[8191], *child, *alias;
	char *cost = 0;
	int nelem, i, privates = 0;

	/*
	 * dump private definitions.  
	 * sort hosts and aliases for pretty output.
	 */
	if (n != Top) {
		i = 0;
		for (child = n->child; child; child = child->next) {
			table[i++] = child;
			for (alias = child->alias; alias; alias = alias->next)
				table[i++] = alias;
		}

		qsort((char *) table, i, sizeof(table[0]), qcmp);
		privates = formatprint(f, table, i, PRIVATE, "private", cost);
	}

	/* dump domains and aliases, sorted for pretty output */
	i = 0;
	for (child = n->child; child; child = child->next)
		table[i++] = child;
	qsort((char *) table, i, sizeof(table[0]), qcmp);

	/* cost is DEDICATED for hosts in top-level domains, LOCAL o.w. */
	if (n->parent == Top && strchr(n->name + 1, '.') == 0)
		cost = "DEDICATED";
	else
		cost = "LOCAL";

	(void) formatprint(f, table, i, HOSTS, n->name, cost);
	(void) formatprint(f, table, i, SUBDOMAINS, n->name, "0");

	/* dump aliases */
	nelem = i;
	for (i = 0; i < nelem; i++) {
		if ((alias = table[i]->alias) == 0)
			continue;
		fprintf(f, "%s = %s", table[i]->name, alias->name);
		for (alias = alias->next; alias; alias = alias->next)
			fprintf(f, ", %s", alias->name);
		putc('\n', f);
	}
	return privates;
}

int
formatprint(f, table, nelem, type, lhs, cost)
	FILE *f;
	node **table;
	char *lhs, *cost;
{	int i, didprint;
	char buf[128], *bptr;

	sprintf(buf, "%s%s{" /*}*/, lhs, type == PRIVATE ? " " : " = ");
	bptr = buf + strlen(buf);

	didprint = 0;
	for (i = 0; i < nelem; i++) {
		if (type == PRIVATE && ! (table[i]->flag & COLLISION))
			continue;
		else if (type == HOSTS && ISADOMAIN(table[i]) )
			continue;
		else if (type == SUBDOMAINS && ! ISADOMAIN(table[i]) )
			continue;

		if ((bptr - buf) + strlen(table[i]->name) > 69) {
			*bptr = 0;
			fprintf(f, "%s\n ", buf);	/* continuation */
			bptr = buf;
		}
		sprintf(bptr, "%s, ", table[i]->name);
		bptr += strlen(bptr);
		didprint++;
	}
	*bptr = 0;

	if (didprint) {
		fprintf(f, /*{*/ "%s}", buf);
		if (type != PRIVATE)
			fprintf(f, "(%s)", cost);
		putc('\n', f);
	}
	return didprint;
}

FILE *				
mkfile(n)
	node *n;
{	node *parent;
	char *bptr;
	FILE *f;

	/* build up the domain name in Fname[] */
	bptr = Fstart;
	if (n == Top)
		strcpy(bptr, n->name);
	else {
		strcpy(bptr, n->name + 1);	/* skip leading dot */
		bptr = bptr + strlen(bptr);
		parent = n->parent;
		while (ISADOMAIN(parent)) {
			strcpy(bptr, parent->name);
			bptr += strlen(bptr);
			parent = parent->parent;
		}
		*bptr = 0;
	}

	/* get a stream descriptor */
	if (Fflag) {
		printf("# %s\n", Fstart);
		f = stdout;
	} else {
#ifndef BSD
		Fstart[14] = 0;
#endif
		if ((f = fopen(Fname, "w")) == 0) {
			perror(Fname);
			exit(1);
		}
	}
	if (n == Top)
		fprintf(f, "private {%s}\ndead {%s}\n", Top->name, Top->name);
	return f;
}

/* map to lower case in place.  return parameter for convenience */
char *
lowercase(buf)
	char *buf;
{	char *str;

	for (str = buf ; *str; str++)
		if (isupper(*str))
			*str -= 'A' - 'a';
	return buf;
}

/* get the interesting aliases, attach to n->alias */
makealiases(n, line)
	node *n;
	char *line;
{	char *next, *dot;
	node *a;

	if (line == 0 || *line == 0)
		return;

	for ( ; line; line = next) {
		next = strchr(line, ',');
		if (next)
			*next++ = 0;
		if ((dot = strchr(line, '.')) == 0)
			continue;
		if (strcmp(dot, DotArpa) != 0)
			continue;
		*dot = 0;

		if (strcmp(n->name, line) == 0)
			continue;

		a = newnode();
		a->name = strsave(line);
		a->next = n->alias;
		n->alias = a;
	}
}

/* make unique domain names */
merge()
{	register node *n;

	for (n = Top->child; n; n = n->next)
		make_children_unique(n);
}

/*
 * another recursive tree walk, this time to make unique domain
 * components.
 *
 * for domains like cc.umich.edu and cc.berkeley.edu, it's inaccurate
 * to describe cc as a member of umich.edu or berkeley.edu.  (i.e., the
 * lousy scoping rules for privates don't permit a clean syntax.)  so.
 *
 * to prevent confusion, tack on to any such domain name its parent domain
 * and promote it in the tree.  e.g., make cc.umich and cc.berkeley
 * subdomains of edu.
 */

make_children_unique(parent)
	node *parent;
{	node *prev, *child, *next;
	char buf[BUFSIZ];

	prev = 0;
	for (child = parent->child; child; child = next) {
		next = child->next;

		/* skip hosts */
		if (!ISADOMAIN(child)) {
			prev = child;
			continue;
		}

		/*
		 * promote non-unique domain, or any domain with a
		 * gateway.  (the latter get promoted all the way to
		 * top-level.)
		 */
		if ((child->flag & COLLISION) == 0 && child->gateway == 0) {
			/*
			 * uninteresting domain.  make its children
			 * unique and bump prev.
			 */
			make_children_unique(child);
			prev = child;
			continue;
		}

		/*
		 * gateway or dup domain name found.  don't bump
		 * prev: this node is moving up the tree.
		 */

		/* qualify child domain name */
		sprintf(buf, "%s%s", child->name, parent->name);
		cfree(child->name);
		child->name = strsave(buf);

		/* unlink child out of sibling chain */
		if (prev)
			prev->next = child->next;
		else
			parent->child = child->next;

		/* link child in as peer of parent */
		child->next = parent->next;
		parent->next = child;
		child->parent = parent->parent;

		/*
		 * reset collision flag; may promote again on
		 * return to caller.
		 */
		child->flag &= ~COLLISION;
		hash(child);
	}
}

/* another recursive tree walk, this time to set the COLLISION bit. */
setuniqflag(n)
	node *n;
{	node *child, *alias;

	/* mark this node in the hash table */
	hash(n);
	/* mark the aliases of this node */
	for (alias = n->alias; alias; alias = alias->next)
		hash(alias);
	/* recursively mark this node's children */
	for (child = n->child; child; child = child->next)
		setuniqflag(child);
}

#define NHASH 8191		/* must be prime */
node *Htable[NHASH];		/* hash table */

hash(n)
	node *n;
{	node **bucket, *b;

	bucket = Htable + (fold(n->name) % NHASH);
	for (b = *bucket; b; b = b->bucket)
		if (strcmp(n->name, b->name) == 0) {
			b->flag |= COLLISION;
			n->flag |= COLLISION;
			return;
		}

	n->bucket = *bucket;
	*bucket = n;
}

/* stolen from pathalias:addnode.c, q.v. */
#define POLY	0x48000000		/* 31-bit polynomial */
long CrcTable[128];

void
crcinit()
{	register int i,j;
	register long sum;

	for (i = 0; i < 128; i++) {
		sum = 0;
		for (j = 7-1; j >= 0; --j)
			if (i & (1 << j))
				sum ^= POLY >> j;
		CrcTable[i] = sum;
	}
}

long
fold(s)
	register char *s;
{	register long sum = 0;
	register int c;

	while (c = *s++)
		sum = (sum >> 7) ^ CrcTable[(sum ^ c) & 0x7f];
	return sum;
}

hashanalyze()
{	int nodecount = 0, maxlen = 0, len, i, probes = 0;
	node *n;

	if (!Vflag)
		return;

	for (i = 0; i < NHASH; i++) {
		len = 0;
		for (n = Htable[i]; n; n = n->bucket) {
			len++;
			probes += len;
		}
		nodecount += len;
		if (len > maxlen)
			maxlen = len;
	}
	fprintf(stderr,
	  "load = %2.2f, probes/access = %2.2f, %d nodes, max chain is %d\n",
	  (double) nodecount / (double) NHASH,
	  (double) probes / (double) nodecount, nodecount, maxlen);
}
