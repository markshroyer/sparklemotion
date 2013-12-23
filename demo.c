#include "sparkle.h"

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

#define NLEDS 60
#define DATA_SZ (3 * NLEDS)

int main(void)
{
    uint8_t *data;
    int led;
    int color;
    struct timespec delay = { 0, 20000000 };

    if (sparkle_init() < 0) {
        fprintf(stderr, "Could not initialize sparkle\n");
        exit(1);
    }

    data = malloc(DATA_SZ);
    if (! data) {
        fprintf(stderr, "Could not allocate data buffer\n");
        exit(1);
    }

    for (color = 0; 1; color = (color + 1) % 3) {
        for (led = 0; led < NLEDS; led++) {
            memset(data, 0, DATA_SZ);
            data[3*led + color] = 0x7f;

            sparkle_send(DATA_SZ, data);
            nanosleep(&delay, NULL);
        }
    }

    sparkle_exit();

    return 0;
}
