#!/bin/bash
xclip -selection clipboard -o | sed "y/\`~!@#$%^&qwertyuiop[]asdfghjkl;'zxcvbnm,.\/QWERTYUIOP{}ASDFGHJKL:\"|ZXCVBNM<>?/ёЁ!\"№;%:?йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ\/ЯЧСМИТЬБЮ,/" | xclip -selection clipboard
