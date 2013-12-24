#include "sparkle.h"

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define NLEDS 60
#define DATA_SZ (3 * NLEDS)

#define RANDOM "/dev/urandom"

int main(void)
{
    uint8_t *data;
    int led, color, primary;
    struct timespec delay = { 0, 100000000 };
    int fd;
    ssize_t n;
    size_t sz;

    if (sparkle_init() < 0) {
        fprintf(stderr, "Could not initialize sparkle\n");
        exit(1);
    }

    sparkle_max_luminance = 0xff;

    data = malloc(DATA_SZ);
    if (! data) {
        fprintf(stderr, "Could not allocate data buffer\n");
        exit(1);
    }

    fd = open(RANDOM, O_RDONLY);

    while ( 1 ) {
        sz = DATA_SZ;
        while ((n = read(fd, data + (DATA_SZ - sz), sz)) > 0)
            sz -= n;

        if (n < 0)
            exit(1);

        sparkle_write(data, DATA_SZ);
        nanosleep(&delay, NULL);
    }

    sparkle_exit();

    return 0;
}
