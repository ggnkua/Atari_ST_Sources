/* matlib/ascii.h	/ MATRIX / WA / HG / 25.11.91	*/

# define EOS 0

# define ctrl(a) (a&0x1F)

# define NUL	ctrl('@')

# define BEL	ctrl('G')
# define TAB	ctrl('I')
# define LF		ctrl('J')
# define CR		ctrl('M')

# define ESC	ctrl('[')
