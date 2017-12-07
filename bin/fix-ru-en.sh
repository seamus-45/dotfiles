#!/bin/bash
xclip -selection clipboard -o | sed "y/ёЁ!\"№;%:?йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ\/ЯЧСМИТЬБЮ,/\`~!@#$%^&qwertyuiop[]asdfghjkl;'zxcvbnm,.\/QWERTYUIOP{}ASDFGHJKL:\"|ZXCVBNM<>?/" | xclip -selection clipboard
