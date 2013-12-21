DTC = dtc
PASM = pasm

CFLAGS += -Wall -I/usr/local/include
LDFLAGS += -L/usr/local/lib -lprussdrv -lpthread

all: xmastree.dtbo prucode.bin pru

%.dtbo: %.dts
	$(DTC) -I dts -O dtb -o $@ -@ $<

prucode.bin: prucode.p
	$(PASM) -b prucode.p

%.p: %.asm
	gcc -E -x c $< | grep -v '^# ' > $@

pru: pru.o
	cc $(CFLAGS) -o $@ $< $(LDFLAGS)

pru.o: pru.c
	cc $(CFLAGS) -c -o $@ $<

clean:
	rm -f pru *.o prucode.p *.bin *.dtbo

.PHONY: clean
