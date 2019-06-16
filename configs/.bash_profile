# Load .bashrc if there

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

CPPFLAGS="-I/usr/local/opt/openssl/include $CPPFLAGS"
CPPFLAGS="-I/usr/local/opt/ncurses/include $CPPFLAGS"
CPPFLAGS="-I/usr/local/opt/gettext/include $CPPFLAGS"
CPPFLAGS="-I/usr/local/opt/ncurses/include $CPPFLAGS"
CPPFLAGS="-I/usr/local/opt/gettext/include $CPPFLAGS"

LDFLAGS="-L/usr/local/opt/libffi/lib $LDFLAGS"
LDFLAGS="-L/usr/local/opt/openssl/lib $LDFLAGS"
LDFLAGS="-L/usr/local/opt/ncurses/lib $LDFLAGS"
LDFLAGS="-L/usr/local/opt/gettext/lib $LDFLAGS"
LDFLAGS="-L/usr/local/opt/ncurses/lib $LDFLAGS"
LDFLAGS="-L/usr/local/opt/gettext/lib $LDFLAGS"

PATH="/usr/local/opt/openssl/bin:$PATH"
PATH="/usr/local/opt/file-formula/bin:$PATH"
PATH="/usr/local/opt/ncurses/bin:$PATH"
PATH="/usr/local/opt/gettext/bin:$PATH"
PATH="/usr/local/opt/file-formula/bin:$PATH"
PATH="/usr/local/opt/ncurses/bin:$PATH"
PATH="/usr/local/opt/gettext/bin:$PATH"

test -f ~/.bashrc && source ~/.bashrc
