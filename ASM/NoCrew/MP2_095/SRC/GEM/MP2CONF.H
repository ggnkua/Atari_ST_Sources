#define CF_BLOCK_SIZE   1
#define CF_COUNT_DIR    2
#define CF_TIME_SLICE   3
#define CF_DEFAULT_PATH 4
#define CF_FORCE_CLOCK  5
#define CF_FIND_FIRST   6
#define CF_PLAY_FIRST   7

#define DEFAULT_BLOCK_SIZE 200 /* kb */
#define DEFAULT_TIME_SLICE 500 /* ms */
#define DEFAULT_COUNT_DIR 1    /* =down */

struct config
{
	char *arg;
	int define;
};

struct config config_args[] =
{
	{ "BLOCK_SIZE", CF_BLOCK_SIZE },
	{ "COUNT_DIRECTION", CF_COUNT_DIR },
	{ "TIME_SLICE", CF_TIME_SLICE },
	{ "DEFAULT_PATH", CF_DEFAULT_PATH },
	{ "FORCE_CLOCK", CF_FORCE_CLOCK },
	{ "FIND_FIRST", CF_FIND_FIRST },
	{ "PLAY_FIRST", CF_PLAY_FIRST },
	{ 0,0 }
};
