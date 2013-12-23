from __future__ import print_function

import _sparkle

class ColorParseError(Exception): pass

def _color_tuple(color):
    """Convert a color representation to (R, G, B) tuple

    """
    if isinstance(color, str):
        if not (len(color) == 6 or (len(color) == 7 and color[0] == '#')):
            raise ColorParseError("Invalid color string")

        if len(color) == 7:
            color = color[1:]

        try:
            red   = int(color[0:2], 16)
            green = int(color[2:4], 16)
            blue  = int(color[4:6], 16)
            return (red, green, blue)
        except ValueError as e:
            raise ColorParseError(e)

    elif isinstance(color, tuple):
        if len(color) != 3:
            raise ColorParseError("3-tuple expected")

        return color

    else:
        raise ColorParseError("Invalid color representation")

def set_color(color):
    red, green, blue = _color_tuple(color)
    _sparkle.set_color(red, green, blue)

