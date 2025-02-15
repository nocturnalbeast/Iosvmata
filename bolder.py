#!/usr/bin/env python
# Script shamelessly stolen from: https://github.com/shytikov/pragmasevka

import sys
import fontforge

if len(sys.argv) < 2:
    print("Please provide path prefix of the font to update!")
    exit()

prefix = sys.argv[1]

glyphs = [
    "exclam",
    "ampersand",
    "parenleft",
    "parenright",
    "asterisk",
    "plus",
    "comma",
    "hyphen",
    "period",
    "slash",
    "colon",
    "semicolon",
    "less",
    "equal",
    "greater",
    "question",
    "bracketleft",
    "backslash",
    "bracketright",
    "asciicircum",
    "braceleft",
    "bar",
    "braceright",
    "asciitilde",
]

pairs = [
    ["Regular", "SemiBold"],
    ["Italic", "SemiBoldItalic"],
    ["Bold", "Black"],
    ["BoldItalic", "BlackItalic"],
]

for [recipient, donor] in pairs:
    font = f"{prefix}-{recipient}.ttf"

    target = fontforge.open(font)
    # Finding all punctuation
    target.selection.select(*glyphs)
    # and deleting it to make space
    for i in target.selection.byGlyphs:
        target.removeGlyph(i)

    source = fontforge.open(f"{prefix}-{donor}.ttf")
    source.selection.select(*glyphs)
    source.copy()
    target.paste()

    target.generate(font)
