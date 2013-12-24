DTC = dtc
PASM = pasm
CC = gcc
M4 = m4

CFLAGS += -Wall -Werror -pthread -I/usr/local/include -Wno-unused-variable
LDFLAGS += -L/usr/local/lib -lprussdrv -lpthread

OBJECTS = sparkle.o
HEADERS = sparkle.h

all: sparkle.dtbo sparkle.bin demo fern fern2 xmas2 random

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

random: random.o $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ random.o $(OBJECTS) $(LDFLAGS)

xmas2: xmas2.o $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ xmas2.o $(OBJECTS) $(LDFLAGS) -lm

fern: fern.o $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ fern.o $(OBJECTS) $(LDFLAGS)

fern2: fern2.o $(OBJECTS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ fern2.o $(OBJECTS) $(LDFLAGS)

python: _sparkle.c $(OBJECTS) $(HEADERS)
	python setup.py build

clean:
	rm -f *.o sparkle.p *.bin *.dtbo demo
	rm -rf build

.PHONY: clean python
