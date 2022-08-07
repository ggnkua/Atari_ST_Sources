#define SEQ_TYPE 0xfedcba98

struct seq_head
	{
	long type;
	long length;
	long count;
	};
	
struct seq_tab
	{
	char name[16];
	long offset;
	long length;
	};
