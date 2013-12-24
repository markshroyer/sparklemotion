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
    /* int led, color, primary; */
    struct timespec delay = { 0, 500000000 };
    uint8_t pattern[9]={0,255,0,255,0,0,255,255,255};
    uint8_t step =0;
    if (sparkle_init() < 0) {
        fprintf(stderr, "Could not initialize sparkle\n");
        exit(1);
    }

    sparkle_max_luminance = 0x60;

    data = malloc(DATA_SZ);
    if (! data) {
        fprintf(stderr, "Could not allocate data buffer\n");
        exit(1);
    }
    while(1){
    for(step=0;step<9;step+=3){
      
      memmove(data+3,data,DATA_SZ-3);
      
      data[0]= pattern[step];
      data[1] = pattern[(step+1)];
      data[2] = pattern[(step+2)];

      
      sparkle_write(data,DATA_SZ);
      nanosleep(&delay,NULL);
      
    }
    }
    /*for (color = 0b001; 1; color = (color + 1) % 0b1000) {
        if (color == 0)
            continue;

        for (led = 0; led < NLEDS; led++) {
            memset(data, 0, DATA_SZ);
            for (primary = 0; primary < 3; primary++) {
                if (color & (1 << primary))
                    data[3*led + primary] = 0xff;
            }

            sparkle_write(data, DATA_SZ);
            nanosleep(&delay, NULL);
        }
        }*/

    sparkle_exit();

    return 0;
}
