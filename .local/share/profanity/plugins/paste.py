"""
Paste the contents of the clipboard when in a chat or room window.
"""

import prof
import gtk


def _cmd_paste():
    clipboard = gtk.Clipboard()
    result = clipboard.wait_for_text()
    prof.send_line(u'\u000A' + result)


def prof_init(version, status, account_name, fulljid):
    synopsis = ["/paste"]
    description = "Paste contents of clipboard."
    args = []
    examples = []
    prof.register_command("/paste", 0, 0, synopsis, description, args, examples, _cmd_paste)
