
struct symbol
    {
    struct symbol *next;
    char *name;
    int token;
    struct symbol *value;
    };
typedef struct symbol Symbol;

struct token
    {
    struct token *next;
    char *name;
    int token;
    struct symbol *value;
    WORD lines;
    WORD fatal;
    WORD push_back;
    struct token *look_ahead;
    struct symbol *usr_list;
    char buffer[80];
    };
typedef struct token Token;

extern Symbol *kw_base, *usr_base;
extern Symbol *lookup(), *install();

#define UNDEF_TOKEN	0
#define OP_TOKEN 	1
#define NUMBER_TOKEN 	2
#define COMMAND_TOKEN 	3
#define EOF_TOKEN 	4
#define BIN_TOKEN	5
#define IGNORE_TOKEN 	6
#define STRING_TOKEN 	7
#define FILE_TOKEN	8
#define TYPE_TOKEN	9
#define RASTER_TOKEN	10

#define SCRIPT_COM 0
#define TWEEN_COM 1
#define ACT_COM 2
#define VERSION_COM 3
#define DEFINE_COM 4

