# Wezterm
- `CTRL-SHIFT-K` or `CMD-K` - clear crollback buffer and ask shell to redraw prompt
- `SHIFT-PageUp` and `SHIFT-PageUp` - adjust the viewport scrollback position by half full screen for each press
- `CTRL-SHIFT-F` - activate search mode
    - `Esc` - escape search mode
    - `ArrowUp` or `ArrowDown` - move over matches
    - `CTRL-R` - cycle through the pattern matching modes: CaseSensitive, IgnoreCase, RegExp
    - `CTRL-U` - clear search pattern
    - `CTRL-SHIFT-C` - copy selected text to clipboard
- `CTRL-SHIFT-SPACE` - quick select mode
- `CTRL-SHIFT-X` - copymode
    `Esc` or `Q` or `CTRL-C` or `CTRL-G` - exit
    `Y` - save to copy buffer and exit
    `V` - regular selection
    `SHIFT-V` - line selection
    `CTRL-V` - rectangular selection
    `H` or `ArrowLeft` - move left
    `J` or `ArrowDown` - move down
    `K` or `ArrowUp` - move up
    `L` or `ArrowRight` - move right
    `W` or `TAB` or `ALT-F` or `ALT-ArrowRight` - move forward one word
    `B` or `SHIFT-TAB` or `ALT-B` or `ALT-ArrowLeft` - move backward one word
    `0` or `HOME` - move to start of line
    `ENTER` - move to start of next line
    `$` or `End` - move to end of this line
    Other: https://wezfurlong.org/wezterm/copymode.html#key-assignments
# Ranger
`h` or `ArrowLeft` - returns to the parent directory
`j` or `ArrowDown` - move down
`k` or `ArrowUp` - move up
`l` or `ArrowRight` - enters the selected directory or opens a file
`q` - quit
`:` - read commad from user
`BACKSPACE` - toggle show hidden files
`yy` - copy file
`pp` - paste file
`dd` - cut file
`dD` - delete file
`gg` - move cursor to first element
`gL` - follow symlink to dir
`gh` - cd ~
`gr` or `g/` - cd /
`ge` - cd /etc
`gd` - cd /dev
`gv` - cd /var
`gu` - cd /usr
`gp` - cd /tmp
`gs` - cd /srv
`go` - cd /opt
`gm` - cd /media
`gM` - cd /mnt
`gi` - cd /run/media/<USER>
`g?` - go to dir with ranger docs
`gR` - go to dir with global ranger config
`gn` - new tab 
`gc` - close tab
`gt` - +1 tab
`gT` - -1 tab 
`r` - 'open with' menu
`dD` - console delete
`dT` - console trash
`dd` - cut
`da` - cut mode add
`dr` - cut mode remove
`dt` - cut mode toggle
`du` - show size with du
`dU` - show show with du (another sorting)
`dO` - paste with overwrite and append
`dl` - past symlink with absolute path
`dL` - past symlink with relative path
`pp` - paste
`po` - paste with overwrite
`Mf` - regular linemode (filename)
`Mi` - linemode fileinfo
`Mp` - linemode permissions
`+` or `-` or `=` - set permissions
