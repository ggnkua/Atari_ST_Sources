CFLAGS = -O

gst2gnu.ttp:

archive:
    del gst2gnu.lzh
    -lharc a gst2gnu.lzh *.c *.mak gst2gnu.ttp

arcupd:
    -lharc u gst2gnu.lzh *.c *.mak gst2gnu.ttp
    

