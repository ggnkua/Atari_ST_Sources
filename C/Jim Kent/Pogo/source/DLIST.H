


typedef struct dlist 
	{
	struct dlist *next;
	struct dlist *prev;
	} Dlist;

typedef struct tlist
	{
	struct tlist *next;
	struct tlist *prev;
	int id;
	} Tlist;

typedef struct slist
	{
	struct slist *next;
	struct slist *prev;
	char *string;
	char oop, used;
	} Slist;
