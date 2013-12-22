DTC = dtc
PASM = pasm

CFLAGS += -Wall -I/usr/local/include
LDFLAGS += -L/usr/local/lib -lprussdrv -lpthread

all: xmastree.dtbo prucode.bin pru

%.dtbo: %.dts
	$(DTC) -I dts -O dtb -o $@ -@ $<

%.p: %.asm
	m4 $< > $@

%.bin: %.p
	$(PASM) -V2 -b $<

%.o: %.c
	cc $(CFLAGS) -c -o $@ $<

pru: pru.o
	cc $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f pru *.o prucode.p *.bin *.dtbo

.PHONY: clean
