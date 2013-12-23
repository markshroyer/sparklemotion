#include <Python.h>

#include <stdint.h>

#include "sparkle.h"

#define NLEDS 60
#define SKIPLEDS 3

static uint8_t *led_buf = NULL;

static char module_docstring[] =
    "A Python wrapper for sparkle";

static char set_color_docstring[] =
    "Set all LEDs to the given R, G, and B values";

static PyObject *_set_color(PyObject *self, PyObject *args);

static PyMethodDef module_methods[] = {
    { "set_color", _set_color, METH_VARARGS, set_color_docstring },
    { NULL, NULL, 0, NULL }
};

PyMODINIT_FUNC init_sparkle(void)
{
    PyObject *m = Py_InitModule3("_sparkle", module_methods, module_docstring);
    if (! m)
        return;

    led_buf = malloc(3 * NLEDS);
    if (! led_buf)
        return;

    sparkle_init();
    sparkle_max_luminance = 0x7f;
}

static PyObject *_set_color(PyObject *self, PyObject *args)
{
    unsigned char red, green, blue;
    int i;

    if (! PyArg_ParseTuple(args, "bbb", &red, &green, &blue))
        return NULL;

    for (i = 0; i < 3 * NLEDS; i += 3) {
        if ((i/3) % SKIPLEDS == 0) {
            led_buf[i]   = green;
            led_buf[i+1] = red;
            led_buf[i+2] = blue;
        } else {
            led_buf[i]   = 0;
            led_buf[i+1] = 0;
            led_buf[i+2] = 0;
        }
    }

    sparkle_write(led_buf, 3 * NLEDS);

    Py_RETURN_NONE;
}
