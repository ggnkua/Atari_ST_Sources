/* Function prototypes. */

/* amoeba.c */
void amint_task();
void amoeba_task();

/* at_wini.c, bios_wini.c, ps_wini.c, xt_wini.c, stwini.c */
void winchester_task();

/* clock.c */
void clock_handler();
void clock_task();

/* dmp.c, stdmp.c */
void map_dmp();
void p_dmp();
void set_name();

/* floppy.c, stfloppy.c */
void floppy_task();

/* main.c, stmain.c */
void main();
void panic();

/* memory.c */
void mem_task();

/* misc.c */
int do_vrdwt();

/* printer.c, stprint.c */
void printer_task();

/* proc.c */
void interrupt();
int lock_mini_send();
void lock_pick_proc();
void lock_ready();
void lock_sched();
void lock_unready();
int sys_call();
void unhold();

/* system.c */
void cause_sig();
void inform();
phys_bytes numap();
void sys_task();
phys_bytes umap();

/* tty.c */
void finish();
void sigchar();
void tty_task();

/* library */
int memcpy();
void printk();
int receive();
int send();
int sendrec();

#if (CHIP == INTEL)

/* clock.c */
void milli_delay();
unsigned read_counter();

/* console.c */
void console();
void flush();
void out_char();
void putc();
void scr_init();
void toggle_scroll();

/* cstart.c */
void cstart();

/* exception.c */
void exception();

/* i8259.c */
void enable_irq();
void init_8259();

/* keyboard.c */
int func_key();
void kb_init();
int kb_read();
void keyboard();
int letter_code();
int make_break();
void reboot();
void wreboot();

/* klib*.x */
void bios13();
void build_sig();
phys_bytes check_mem();
void cim_at_wini();
void cim_floppy();
void cim_printer();
void cim_xt_wini();
void cp_mess();
unsigned in_byte();
void klib_1hook();
void klib_2hook();
void lock();
void mpx_1hook();
void mpx_2hook();
void out_byte();
void phys_copy();
void port_read();
void port_write();
void reset();
void scr_down();
void scr_up();
void sim_printer();
unsigned tasim_printer();
int test_and_set();
void unlock();
void vid_copy();
void wait_retrace();

/* main.c */
void dp8390_int();
void eth_stp();

/* misc.c */
void mem_init();

/* mpx*.x */
void idle_task();
void restart();
void int00(), divide_error();	/* exception handlers, in numerical order */
void int01(), single_step_exception();
void int02(), nmi();
void int03(), breakpoint_exception();
void int04(), overflow();
void int05(), bounds_check();
void int06(), inval_opcode();
void int07(), copr_not_available();
void int08(), double_fault();
void int09(), copr_seg_overrun();
void int10(), inval_tss();
void int11(), segment_not_present();
void int12(), stack_exception();
void int13(), general_protection();
void int14(), page_fault();
void int15();
void int16(), copr_error();	/* end of exception handlers */
void clock_int();		/* hardware interrupt handlers, in order */
void tty_int();
void secondary_int(), psecondary_int(), eth_int();
void rs232_int(), prs232_int();
void disk_int();
void lpr_int();
void wini_int();		/* end of hardware interrupt handlers */
void trp();			/* software interrupt handlers, in order */
void s_call(), p_s_call();	/* end of software interrupt handlers */

/* printer.c */
void pr_char();
void pr_restart();

/* protect.c */
void prot_init();

/* protect1.c */
void init_codeseg();
void init_dataseg();
void ldt_init();

/* rs232.c */
void rs232_1handler();
void rs232_2handler();
void rs_inhibit();
int rs_init();
int rs_ioctl();
int rs_read();
void rs_istart();
void rs_istop();
void rs_ocancel();
void rs_setc();
void rs_write();

/* start.x */
void db();
u16_t get_chrome();
u16_t get_ega();
u16_t get_ext_memsize();
u16_t get_low_memsize();
u16_t get_processor();
u16_t get_word();
void put_word();

/* system.c */
void alloc_segments();

/* tty.c */
void tty_wakeup();

#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)

/* stdmp.c */
void prname();
void reg_dmp();
void mem_dmp();
void tty_dmp();

/* stfloppy.c */
void fd_timer();

/* main.c */
void none();
void rupt();
void trap();
void checksp();
void aciaint();
void fake_int();
void timint();
void mdiint();
void iob();
void idle_task();

/* proc.c */
void cp_mess();

/* rs232.c */
void siaint();
void rs232();
void rs_flush();
void rs_out_char();
int tty_o_done();
void rs_sig();
void init_rs232();
void set_uart();

/* stcon.c */
void tty_init();
int func_key();
void dump();
void putc();

/* stdma.c */
void dmagrab();
void dmafree();
void dmaint();
void dmaaddr();
int dmardat();
void dmawdat();
void dmacomm();
int dmastat();

/* stdskclk.c */
int do_xbms();
 
/* stfnt.c */

/* stkbd.c */
void kbdint();
void kbdput();
void kb_timer();
void kbdinit();

/* stshadow.c */
void mkshadow();
void rmshadow();
void unshadow();
 
/* stvdu.c */
void flush();
void out_char();
void vducursor();
void vduinit();

/* copy68k.s */
void flipclicks();
void copyclicks();
void zeroclicks();
void phys_copy();

/* stdskclks.s */
int rd1byte();
int wr1byte();
long getsupra();
long geticd();

/* stmpx.s */
int lock();
void unlock();
void restore();
void reboot();

#endif /* (CHIP == M68000) */
