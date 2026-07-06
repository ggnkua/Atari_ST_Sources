hex

\ 20 bdos: s_super   { a.stack -- a.old-supervisor-stack }
\ 3e bdos: f_close   { l.handle -- l.err? }
\ 41 bdos: f_delete  { s.name -- l.err? }
\ 3c bdos: f_creat   { w.mode s.name -- l.handle }
\ 3d bdos: f_open    { w.mode s.name -- l.handle }
\ 40 bdos: f_write   { a.buf l.bytes w.fd -- l.#written }
\ 3f bdos: f_read    { a.buf l.bytes w.fd -- l.#read }
\ 42 bdos: f_lseek   { w.whence w.fd l.byteno -- l.byteno }
 2 bdos: c_conout  { w.char -- }
 1 bdos: c_conin   { -- l.char }
 1 bdos: _key      { -- b.char }
 b bdos: c_conis   { -- l.ready? }
4c bdos: p_term    { w.exit-status -- }
56 bdos: f_rename  { s.new s.old w.0 -- l.err? }
47 bdos: d_getpath { w.drive a.buffer -- }
3b bdos: d_setpath { s.buffer -- l.err? }
43 bdos: f_attrib  { w.attr w.set/get- s.path -- l.attr }
1a bdos: f_setdta  { a.addr -- }
2f bdos: f_getdta  { -- a.addr }
4e bdos: f_sfirst  { w.attr s.pattern -- l.err? }
4f bdos: f_snext   { -- l.err? }
19 bdos: d_getdrv  { -- w.drive-number }
0e bdos: d_setdrv  { w.drive-number -- l.drive-bitmap }
2a bdos: t_getdate { -- w.date }
2b bdos: t_setdate { w.date -- l.err? }
2c bdos: t_gettime { -- w.time }
2d bdos: t_settime { w.time -- l.err? }
30 bdos: s_version { -- w.version }
31 bdos: p_termres { w.code l.#bytes -- }
36 bdos: d_free    { w.drive a.buffer -- }
39 bdos: d_create  { s.path -- l.err? }
3a bdos: d_delete  { s.path -- l.err? }
45 bdos: f_dup     { w.stdhandle -- w.nstdhandle }
46 bdos: f_force   { w.nstdhandle w.stdhandle -- }
48 bdos: m_alloc   { l.nbytes -- a.startaddr }
49 bdos: m_free    { a.startaddr -- l.err? }
4a bdos: m_shrink  { l.size l.startaddr w.0 -- l.err? }
4b bdos: p_exec    { a.environment a.tail s.pname w.mode -- l.pid } ( or a.bp )
57 bdos: f_datime  { w.get/set- w.handle a.buffer -- }

 5 0c trap: set_exception_vector { a.vecaddr w.vecnum -- a.oldaddr }
27 0e trap: puntaes { -- }
