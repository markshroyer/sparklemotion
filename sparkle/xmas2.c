#include "sparkle.h"

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define NLEDS 60
#define DATA_SZ (3 * NLEDS)

#define NPOINTS 2
#define RES 10
#define MAX_POS (NLEDS * RES)

#define BASE_VAL 0xff

typedef struct color {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} color_t;

typedef struct point {
    color_t color;
    int32_t pos;
} point_t;

double fade(uint8_t pointval, double distance)
{
    const double max_dist = 12 * RES;

    if (fabs(distance) > max_dist)
        return 0;

    return ((double)pointval) * (1 - fabs(distance) / max_dist);
}

color_t led_color(point_t *points, int npoint, int led)
{
    int i;
    double distance;
    color_t result;
    double r = 0xff, g = 0xff, b = 0xff;

    for (i = 0; i < NPOINTS; i++) {
        r -= fade(0xff - points[i].color.r, led*RES - points[i].pos);
        g -= fade(0xff - points[i].color.g, led*RES - points[i].pos);
        b -= fade(0xff - points[i].color.b, led*RES - points[i].pos);
    }

    result.r = (uint8_t)(fabs(r));
    result.g = (uint8_t)(fabs(g));
    result.b = (uint8_t)(fabs(b));

    return result;
}

int main(void)
{
    uint8_t *buf;
    point_t *points;
    color_t c;
    int i;
    struct timespec delay = { 0, 10000000 };

    if (sparkle_init() < 0) {
        fprintf(stderr, "Could not initialize sparkle\n");
        exit(1);
    }

    sparkle_max_luminance = 0x40;

    buf = malloc(DATA_SZ);
    points = calloc(NPOINTS, sizeof(point_t));

    points[0].pos = 0;
    points[0].color.r = 0xff;
    points[0].color.g = 0x00;
    points[0].color.b = 0x00;

    points[1].pos = 30 * RES;
    points[1].color.r = 0x00;
    points[1].color.g = 0xff;
    points[1].color.b = 0x00;

    while ( 1 ) {
        for (i = 0; i < NPOINTS; i++) {
            points[i].pos = (points[i].pos + 1) % MAX_POS;
        }

        for (i = 0; i < NLEDS; i++) {
            c = led_color(points, NPOINTS, i);
            buf[3*i+0] = c.g;
            buf[3*i+1] = c.r;
            buf[3*i+2] = c.b;
        }

        sparkle_write(buf, DATA_SZ);
        //        goto end;
        nanosleep(&delay, NULL);
    }

    //end:
    sparkle_exit();

    return 0;
}
