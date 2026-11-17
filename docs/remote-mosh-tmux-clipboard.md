# Remote SSH and mosh tmux Clipboard

This is a generic troubleshooting note for copying from a remote tmux session
to the local clipboard over SSH or mosh. tmux runs on the server, so its copy
bindings and terminal capabilities must be configured there.

## Symptom

Copying from a remote tmux session updates only a tmux buffer or the server's
clipboard. Another possible symptom is copying working over SSH but failing
over mosh.

The relevant topology is:

```text
local terminal -> SSH -> remote tmux
local terminal -> mosh client -> remote mosh-server -> remote tmux
```

Because tmux is running on the remote host, the fix belongs on the remote host.

## Root Cause

Native tmux copying uses OSC52 terminal sequences to reach the local clipboard
over SSH. The local terminal must allow clipboard writes, and remote tmux must
recognize its client's clipboard capability and have `set-clipboard on`.

A remote command such as `pbcopy`, `xclip`, or `wl-copy` targets the server's
clipboard. Use `copy-selection-and-cancel` so tmux handles the terminal clipboard
directly; mixing `copy-pipe` with native clipboard handling can cause conflicts.

For mosh, verify both conditions:

1. The remote `mosh-server` must support OSC52 clipboard forwarding.
2. The remote tmux config must use OSC52/native clipboard copying as above.

A common failing state is:

```text
remote mosh-server: 1.3.x
remote tmux: copy-mode y bound to copy-pipe-and-cancel "pbcopy"
```

That fails because older mosh versions do not forward OSC52 clipboard writes,
and a remote clipboard command cannot write directly to the local desktop
clipboard.

## Check A Server

Run from the local machine:

```sh
ssh HOST 'tmux -V; tmux show-options -g set-clipboard; tmux list-keys -T copy-mode-vi | grep -E " y |MouseDragEnd|Enter"'
ssh HOST 'tmux list-clients -F "#{client_name} #{client_termname} #{client_termfeatures}"'
```

Expected:

```text
set-clipboard on
y -> copy-selection-and-cancel
client terminal features include clipboard
```

For mosh, also run `ssh HOST 'command -v mosh-server; mosh-server --version | head -1'`
and expect mosh-server 1.4.0 or newer.

Also check that the local terminal allows OSC52 clipboard writes. For example,
Ghostty needs clipboard writes allowed. This repository's Ghostty config already
sets:

```text
clipboard-write = allow
```

## Remote tmux Snippet

Back up the remote tmux config first:

```sh
cp -p ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d%H%M%S)
```

Use this in the remote tmux config, for example `~/.tmux.conf`:

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ',xterm*:clipboard,vte*:clipboard,tmux*:clipboard'
set -g set-clipboard on

setw -g mode-keys vi
bind Enter copy-mode
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi Enter send -X copy-selection-and-cancel
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel
bind -T copy-mode-vi MouseDragEnd2Pane send -X copy-selection-and-cancel
```

Reload:

```sh
tmux source-file ~/.tmux.conf
```

In this repository, native settings live in `~/.tmux.conf.native`, which the
entrypoint sources. The local and macmini configurations now use native copying;
an isolated SSH PTY check confirmed that tmux selection emits a valid OSC52 write.

To copy from the server session, press the tmux prefix (`Ctrl-b` or `Ctrl-a`), then
`Enter` to enter copy mode. Move to the start, press `v`, extend the selection,
then press `y` or `Enter`. Paste on the local Mac with `Cmd-v`.

Reconnect mosh after changing `mosh-server`; existing mosh sessions keep using
the old server process:

```sh
mosh HOST
```

## Install mosh 1.4.0 On Ubuntu 22.04

Ubuntu 22.04 packages mosh 1.3.2, so install a newer server under `/usr/local`
if the distribution package is too old.

```sh
sudo apt-get update
sudo apt-get install -y build-essential pkg-config protobuf-compiler libprotobuf-dev \
  libncurses-dev zlib1g-dev libssl-dev libutempter-dev curl ca-certificates

cd /usr/local/src
sudo curl -fL -o mosh-1.4.0.tar.gz \
  https://github.com/mobile-shell/mosh/releases/download/mosh-1.4.0/mosh-1.4.0.tar.gz
sudo tar xzf mosh-1.4.0.tar.gz
cd mosh-1.4.0
sudo ./configure --prefix=/usr/local
sudo make -j"$(nproc)"
sudo make install
```

Verify:

```sh
command -v mosh-server
mosh-server --version | head -1
```

If `/usr/local/bin` is not before `/usr/bin` in the remote login PATH, either
fix PATH or start mosh with an explicit server command:

```sh
mosh --server=/usr/local/bin/mosh-server HOST
```
