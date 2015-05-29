" vim: set filetype=vim:
" Основной файл настроек
" дополнительные настройки определяются через source

" vundle required
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" vunlde plugins
" разрешим обновлять самого себя
Plugin 'gmarik/Vundle.vim'

" навигация по коду/проекту
Plugin 'scrooloose/nerdtree' " навигация по файлам проекта
Plugin 'majutsushi/tagbar' " навигация по классам/функциям/переменным

" сниппеты
Plugin 'garbas/vim-snipmate' " менеджер сниппетов
Plugin 'MarcWeber/vim-addon-mw-utils' " требуется для менеджера
Plugin 'tomtom/tlib_vim' " требуется для менеджера
Plugin 'honza/vim-snippets' " репозиторий сниппетов

" python
Plugin 'klen/python-mode' " документация, подсветка, рефакторинг, дебаггер и др.
Plugin 'davidhalter/jedi-vim' " автодополнение кода
Plugin 'mitsuhiko/vim-jinja' " Поддержка синтаксиса шаблонов Jinja для vim
Plugin 'mitsuhiko/vim-python-combined' " полезные фишки для Python 2/3

" html
Plugin 'alvan/vim-closetag' " закрытие тегов при помощи >

" dbext
Plugin 'vim-scripts/dbext.vim' " работа с базами данных (Oracle, Sybase, Microsoft, MySQL, DBI,..)

" внешний вид
Plugin 'bling/vim-airline' " строка статуса/состояния
Plugin 'flazz/vim-colorschemes' " дополнительные цветовые схемы

" другое
Plugin 'vim-scripts/HexHighlight.vim' " подсвечиват hex-коды в любых файлах по leader+F2 (gVim)
Plugin 'tpope/vim-surround' " инструмент для автозакрытия и быстрой замены тегов HML/XML и др.
Plugin 'rosenfeld/conque-term' " вывод консоли в буффер vim
Plugin 'fisadev/FixedTaskList.vim' " поиск в файле FIXME, TODO и т.п.
Plugin 'danro/rename.vim' " Позволяет переименовывать файлы в буффере через команду rename

" vundle required
call vundle#end()
filetype plugin indent on

" Глобальные настройки для GUI Vim
if has('gui_running')
  source ~/.vim/config/gui
endif

source ~/.vim/config/common
source ~/.vim/config/interface
source ~/.vim/config/keys
source ~/.vim/config/python-mode
source ~/.vim/config/filetype
source ~/.vim/config/dbext
