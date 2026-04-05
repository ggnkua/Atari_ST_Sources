// vt52.h leftovers
#define CLEAR_HOME      "\033E"
#define WRAP_OFF        "\033w"

// Line-a crap
#define LINEA_OPCODE_BASE 0xa000
#define ASM_LINEA3(opcode) ".word       " #opcode
#define ASM_LINEA2(opcode) ASM_LINEA3(opcode)
#define ASM_LINEA(n) ASM_LINEA2(LINEA_OPCODE_BASE+n)

// Disable mouse
#define lineaa()                                                        \
({                                                                      \
        __asm__ volatile                                                \
        (                                                               \
                ASM_LINEA(0xa)                                          \
        :                                                 /* outputs */ \
        :                                                 /* inputs  */ \
        : "d0", "d1", "d2", "a0", "a1", "a2"       /* clobbered regs */ \
          AND_MEMORY                                                    \
        );                                                              \
})

// Enable mouse
#define linea9()                                                        \
({                                                                      \
        __asm__ volatile                                                \
        (                                                               \
                ASM_LINEA(0x9)                                          \
        :                                                 /* outputs */ \
        :                                                 /* inputs  */ \
        : "d0", "d1", "d2", "a0", "a1", "a2"       /* clobbered regs */ \
          AND_MEMORY                                                    \
        );                                                              \
})

// Trvial replacement for access()
static int fileexists(char* pathname) {
  int fd=open(pathname, O_RDONLY);
  if(fd < 0) {
    return -1;
  } else {
    close(fd);
    return 0;
  }
}
