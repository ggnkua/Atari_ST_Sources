#
# 15/10/1999 Draco (draco@atari.org)
#

AS= gen
CFLGS= cflgs -q --fload+ --frun+ --fram+
AFLAGS= -I./include
NAME= joypad
TARGET= $(NAME).xdd

all: clean $(TARGET)

$(TARGET):
	$(AS) $(AFLAGS) $(NAME).s -O$(TARGET)
#	$(CFLGS) $(TARGET)
clean:
	rm -f $(TARGET)

install:
	cp $(TARGET) /c/mint/1-16-cur/
