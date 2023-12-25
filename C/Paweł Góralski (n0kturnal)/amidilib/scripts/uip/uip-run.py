#!/usr/bin/env python

REC_UDP_PORT = 33334
SEND_UDP_PORT = 33332

import socket
import fcntl, os
import sys, select, tty, termios
import http.client 
import curses

class non_blocking_console(object):
    def __enter__(self):
        self.old_settings = termios.tcgetattr(sys.stdin)
        tty.setcbreak(sys.stdin.fileno())
        self.fd = sys.stdin.fileno()
        self.fl = fcntl.fcntl(self.fd, fcntl.F_GETFL)
        fcntl.fcntl(self.fd, fcntl.F_SETFL, self.fl | os.O_NONBLOCK)
        return self

    def __exit__(self, type, value, traceback):
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, self.old_settings)

curses.setupterm()
inverse_seq = (curses.tigetstr('rev') or '').decode("utf-8")
normal_seq = (curses.tigetstr('sgr0') or '').decode("utf-8")

local_to_atari_terminal = {
    ('\x7f', '\x00\x0e\x00\x08'),                                       #backspace
    # F-keys
    ((curses.tigetstr('kf1') or '').decode("utf-8"),  '\x00\x3b\x00\x00'),      #f1
    ((curses.tigetstr('kf2') or '').decode("utf-8"),  '\x00\x3c\x00\x00'),
    ((curses.tigetstr('kf3') or '').decode("utf-8"),  '\x00\x3d\x00\x00'),
    ((curses.tigetstr('kf4') or '').decode("utf-8"),  '\x00\x3e\x00\x00'),
    ((curses.tigetstr('kf5') or '').decode("utf-8"),  '\x00\x3f\x00\x00'),
    ((curses.tigetstr('kf6') or '').decode("utf-8"),  '\x00\x40\x00\x00'),
    ((curses.tigetstr('kf7') or '').decode("utf-8"),  '\x00\x41\x00\x00'),
    ((curses.tigetstr('kf8') or '').decode("utf-8"),  '\x00\x42\x00\x00'),
    ((curses.tigetstr('kf9') or '').decode("utf-8"),  '\x00\x43\x00\x00'),
    ((curses.tigetstr('kf10') or '').decode("utf-8"),  '\x00\x44\x00\x00'),     #f10
    # Arrow keys
    ((curses.tigetstr('kcuu1') or '').decode("utf-8"),  '\x00\x48\x00\x00'),    #up
    ((curses.tigetstr('kcud1') or '').decode("utf-8"),  '\x00\x50\x00\x00'),    #down
    ((curses.tigetstr('kcub1') or '').decode("utf-8"),  '\x00\x4b\x00\x00'),    #left
    ((curses.tigetstr('kcuf1') or '').decode("utf-8"),  '\x00\x4d\x00\x00'),    #right

    ((curses.tigetstr('cuu1') or '').decode("utf-8"),  '\x00\x48\x00\x00'),    #up
    ((curses.tigetstr('cud1') or '').decode("utf-8"),  '\x00\x50\x00\x00'),    #down
    ((curses.tigetstr('cub1') or '').decode("utf-8"),  '\x00\x4b\x00\x00'),    #left
    ((curses.tigetstr('cuf1') or '').decode("utf-8"),  '\x00\x4d\x00\x00'),    #right

    #TODO: remaining keys
}

atari_to_local_terminal = {
    ('\33p', inverse_seq),   # inverse mode on
    ('\33q', normal_seq),  # normal mode on/inverse off
    ('\33J', (curses.tigetstr('ed') or '').decode("utf-8")),    # clear to end of screen
    ('\33K', (curses.tigetstr('el') or '').decode("utf-8")),    # clear to end of line
    ('\33l', (curses.tigetstr('el1') or '').decode("utf-8") + (curses.tigetstr('el') or '').decode("utf-8")),    # clear current line
    ('\33o', (curses.tigetstr('el1') or '').decode("utf-8")),    # clear to start of line
    ('\33d', (curses.tigetstr('clear') or '').decode("utf-8")),    # clear screen up to cursor
    ('\33e', (curses.tigetstr('cnorm') or '').decode("utf-8")), # cursor on
    ('\33f', (curses.tigetstr('civis') or '').decode("utf-8")), # cursor off
    ('\33w', (curses.tigetstr('rmam') or '').decode("utf-8")), # wrap off
    ('\33v', (curses.tigetstr('smam') or '').decode("utf-8")), # wrap on

    ('\33H', (curses.tigetstr('home') or '').decode("utf-8")), # move home
    ('\33B', (curses.tigetstr('cuu1') or '').decode("utf-8")), # move up
    ('\33D', (curses.tigetstr('cub1') or '').decode("utf-8")), # move left
    ('\33C', (curses.tigetstr('cuf1') or '').decode("utf-8")), # move right
    ('\33A', (curses.tigetstr('cud1') or '').decode("utf-8")), # move down

    ('\33M', (curses.tigetstr('dl1') or '').decode("utf-8")), # del line

    ('\33k', (curses.tigetstr('rc') or '').decode("utf-8")), # restore cursor pos
    ('\33j', (curses.tigetstr('sc') or '').decode("utf-8")), # save cursor pos

    # TODO: add remaining sequences
    ('\33Y', ""), # set cursor pos
    ('\33b', ""), # set fb col
    ('\33c', ""), # set bg col
}

def translate_and_print(data):
    for seq in atari_to_local_terminal:
        data = data.replace(seq[0], seq[1])
    sys.stderr.write(data)

def main(args):

    remote_host = args[1].split('/', 1)[0]
    remote_path = "/" + args[1].split('/', 1)[1]

    remote_ip = socket.gethostbyname(remote_host)

    rec_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.getprotobyname('udp'))
    rec_sock.bind(("", REC_UDP_PORT))
    rec_sock.setblocking(0)
    rec_sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 65536)
    rec_sock.setsockopt(socket.SOL_IP, socket.IP_TTL, 100)
    rec_sock.connect((remote_ip, SEND_UDP_PORT))

    conn = http.client.HTTPConnection(remote_ip)
    print (inverse_seq + "connecting:" + normal_seq + remote_ip)
    conn.connect()
    print (inverse_seq + "running: " + normal_seq + remote_path)
    print (inverse_seq + "args: " + normal_seq + " " + args[2] + " " + args[3])
    
    tosCommandline = args[2] + " " + args[3]
    print (inverse_seq + "TOS commandline: " + normal_seq + " " + tosCommandline)
    
    conn.request("GET", remote_path + "?run=" + tosCommandline + '"')
    response = conn.getresponse()
    response.read()

    if (response.status != 200):
        print('Error ( HTTP code: ' + str(response.status) + ") " + response.reason, flush=True) 
        return 1

    print(inverse_seq + "Remote output:" + normal_seq)

    with non_blocking_console() as nbc:
        try:
            c = ""
            while 1:
                try:
                    read, write, exp = select.select([sys.stdin, rec_sock], [], [])
                    for ready in read:
                        if type(ready) == type(sys.stdin):
                            c = c + sys.stdin.read(32)
                        elif type(ready) == type(rec_sock):
                            data, addr = rec_sock.recvfrom(1500)
                            if len(data) == 1 and data[0] == '\xff':
                                return
                            translate_and_print(data)
                except KeyboardInterrupt:
                    # send spece key just in case remote app would exit on that
                    # TODO: send a sequence which remove terminal redirection
                    rec_sock.send(" ")
                    return
                except:
                    pass

                if len(c) > 0 and c != False:
                    if c[0] != '\x1b' and c[0] != '\x7f':
                        code = '\x00\x00\x00' + c[0]
                        rec_sock.send(code)
                        c = ""
                    else:
                        for s in local_to_atari_terminal:
                            if c == s[0]:
                                c = ""
                                rec_sock.send(s[1])
                        if len(c) > 4 and c[0] == '\x1b':
                            c = ""
        except KeyboardInterrupt:
            rec_sock.send(" ")
            return

def print_usage():
    print("Usage:")
    print(sys.argv[0] + " remote_executable [args]")
    sys.exit(1)

if __name__ == "__main__":
    try:
        if len(sys.argv) < 2:
            print_usage()
        main(sys.argv)
        print(inverse_seq + "Program terminated.." + normal_seq)
    except:
        pass
