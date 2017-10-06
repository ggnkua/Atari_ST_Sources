CC= gcc
LD= ld -s
RM= rm -f
CFLAGS= -m68020-60 -O2 -Wall -pedantic -mshort \
	-fomit-frame-pointer -D__KERNEL__

NAME= sprintf

all: $(NAME).slb

$(NAME).slb: $(NAME).o header.o
	$(LD) -o $(NAME).slb header.o $(NAME).o -lc

clean:
	$(RM) *.o

veryclean: clean
	$(RM) $(NAME).slb
