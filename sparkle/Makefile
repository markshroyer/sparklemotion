DTC = dtc
PASM = pasm
CC = gcc
M4 = m4

CFLAGS += -Wall -Werror -pthread -I/usr/local/include -Wno-unused-variable
LDFLAGS += -L/usr/local/lib -lprussdrv -lpthread

OBJECTS = sparkle.o
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

demo: demo.o $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ demo.o $(OBJECTS) $(LDFLAGS)

fern: fern.o $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ fern.o $(OBJECTS) $(LDFLAGS)

python: _sparkle.c $(OBJECTS) $(HEADERS)
	python setup.py build

clean:
	rm -f *.o sparkle.p *.bin *.dtbo demo
	rm -rf build

.PHONY: clean python
