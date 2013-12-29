#include "sparkle/sparkle.h"

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <signal.h>

#define NLEDS 60
#define DATA_SZ (3 * NLEDS)

volatile bool running = true;

static void signal_handler(int signum)
{
    running = false;
}

int main(void)
{
    int led, color, primary;
    struct timespec delay = { 0, 20000000 };
    static uint8_t *data = NULL;
    struct sigaction action;

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

    memset(&action, 0x00, sizeof(action));
    sigemptyset(&action.sa_mask);
    action.sa_handler = signal_handler;

    if (sigaction(SIGINT, &action, NULL) < 0) {
        perror("Unable to register SIGINT handler");
        exit(1);
    }
    if (sigaction(SIGTERM, &action, NULL) < 0) {
        perror("Unable to register SIGTERM handler");
        exit(1);
    }

    memset(data, 0, DATA_SZ);
    sparkle_write(data, DATA_SZ);

    for (color = 1; running; color = (color + 1) % 8) {
        if (color == 0)
            continue;

        for (led = 0; running && led < NLEDS; led++) {
            memset(data, 0, DATA_SZ);
            for (primary = 0; primary < 3; primary++) {
                if (color & (1 << primary))
                    data[3*led + primary] = 0xff;
            }

            sparkle_write(data, DATA_SZ);
            nanosleep(&delay, NULL);
        }
    }

    memset(data, 0, DATA_SZ);
    sparkle_write(data, DATA_SZ);

    /*
     * Needed for now to ensure we don't stop the PRU in the middle of its
     * execution, but proper synchronization should be added to
     * sparkle_exit()...
     */
    nanosleep(&delay, NULL);

    sparkle_exit();

    return 0;
}
