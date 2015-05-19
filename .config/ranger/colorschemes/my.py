# This file is part of ranger, the console file manager.
# License: GNU GPL version 3, see the file "AUTHORS" for details.

from ranger.gui.color import * #NOQA
from ranger.colorschemes.default import Default


class Scheme(Default):
    progress_bar_color = 255

    def use(self, context):
        fg, bg, attr = Default.use(self, context)

        if context.directory and not context.link:
            fg = 39

        if context.container:
            fg = 40

        if context.document:
            fg = 193

        if context.marked:
            fg = 220

        if context.video:
            fg = 201

        if context.image:
            fg = 219

        if context.audio:
            fg = 207

        return fg, bg, attr
