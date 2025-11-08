# `player.bin`

A patched TTrak player to handle TPN (TTrak Multi Module) files. Can be embedded in SNDH files, or used as a standalone player for TPN files directly.

`player.bin` is always an even number of bytes long.

## Function entry points

There are four entry points, two initialization function, and tpn_exit function for teardown, and a player function to be called from a 200Hz Timer-C callback.

### `tpn_init_idx`

Initializes the player for song at index in `d0`. Index is 1 based with 0 menaing _default_ song (alias for 1 for now).

TPN file **must** be included in memory imidiately after the `player.bin`.

Initialization may fail, if TPN file is corrupt, or the requested subsong index does not exist.

Usage with C/C++ (Requires a `-mfastcall` capable GCC):

```c
int (*tpn_init_idx)(int idx) = player_bin + 0;
if (tpn_init_idx(1) == 0) {
	// Success
} else {
	// Failure
}	
```

Uage assembly:

```asm
	moveq.l	#1,d0
	bsr			player_bin+0
	tst.w		d0
	bne.s		.fail
	// Success
.fail:
	// Failure
```

### `tpn_init_ptrs`

Initializes the player with instrument set in `a0` and song in `a0`. Pointers are to the body of the `TPIS` and `TPSN` chunks, see [TPN_FORMAT.md](./TPN_FORMAT.md).

Initialization cannot fail, client **must** validate data before call.

Usage with C/C++ (Requires a `-mfastcall` capable GCC):

```c
void (*tpn_init_ptrs)(void *tpis, void *tpsn) = player_bin + 4;
tpn_init_ptrs(tpis_ptr, tpsn_ptr);
// Success
```

Usage assembly:

```asm
	lea			tpis_data(pc),a0
	lea			tpsn_data(pc),a1
	bsr			player_bin+4
	// Success
```

### `tpn_exit`

Exit player and teardown structures.

Cannot fail, do **not** call if previous call to `tpn_init_idx` failed.

Usage with C/C++:

```c
void (*tpn_exit)(void) = player_bin + 8;
tpn_exit();
// Success
```

Usage assembly:

```asm
	bsr			player_bin+8
	// Success
```


### `tpn_play`

Play one frame of music.

Cannot fail, and **must** be called on a 200Hz Timer-C callback.

Usage with C/C++:

```
void (*tpn_play)(void) = player_bin + 12;
tpn_play();
// Success
```

Usage assembly:

```asm
	bsr			player_bin+12
	// Success
```

