#define SITE 257
#define HOST 258
#define STRING 259
#define COST 260
#define NET 261
#define EOL 262
#define PRIVATE 263
#define DEAD 264
#define DELETE 265
#define FILETOK 266
#define ADJUST 267
typedef union {
	node	*y_node;
	Cost	y_cost;
	char	y_net;
	char	*y_name;
	struct {
		node *ys_node;
		Cost ys_cost;
		short ys_flag;
		char ys_net;
		char ys_dir;
	} y_s;
} YYSTYPE;
extern YYSTYPE yylval;
