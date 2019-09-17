#ifdef min
  #undef min
#endif
#define min(a,b)			((a) <= (b) ? (a) : (b))

#define AND					&
#define OR					|
#define XOR					^
#define EOR					XOR

#define CLEAR_CODE			256
#define END_OF_INFORMATION	257
#define ERROR_CODE			2
#define BUFFER_SIZE			8192
#define MAX_CODE			8192
#define HASHMAX				8209

typedef int					BOOL;

#define TRUE				-1;
#define FALSE				0;
