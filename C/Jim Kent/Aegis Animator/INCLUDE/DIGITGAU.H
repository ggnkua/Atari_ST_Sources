
struct digit_gauge
{
char digits;
WORD min;
WORD value;
WORD max;
};

extern do_digit_gauge();
extern see_digit_gauge();

#define DIGIT_HEIGHT (CHAR_HEIGHT)
#define DIGIT_WIDTH (CHAR_WIDTH + 2)

