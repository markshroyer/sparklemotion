DTC = dtc
PASM = pasm
CC = gcc
M4 = m4

CFLAGS += -Wall -Werror -I/usr/local/include
LDFLAGS += -L/usr/local/lib -lprussdrv -lpthread

OBJECTS = demo.o sparkle.o
HEADERS = sparkle.h

all: sparkle.dtbo sparkle.bin demo

%.dtbo: %.dts
	$(DTC) -I dts -O dtb -o $@ -@ $<

%.p: %.asm
	$(M4) $< > $@

%.bin: %.p
	$(PASM) -V2 -b $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

demo: $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS) $(LDFLAGS)

clean:
	rm -f *.o sparkle.p *.bin *.dtbo demo

.PHONY: clean
