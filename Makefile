DTC = dtc
PASM = pasm

CFLAGS += -Wall -I/usr/local/include
LDFLAGS += -L/usr/local/lib -lprussdrv -lpthread

all: xmastree.dtbo prucode.bin pru

%.dtbo: %.dts
	$(DTC) -I dts -O dtb -o $@ -@ $<

prucode.bin: prucode.hp prucode.p
	$(PASM) -b prucode.p

pru: pru.o
	cc $(CFLAGS) -o $@ $< $(LDFLAGS)

pru.o: pru.c
	cc $(CFLAGS) -c -o $@ $<

clean:
	rm -f pru pru.o prucode.bin xmastree.dtbo

.PHONY: clean
