# Remote mosh tmux Clipboard

This is a generic troubleshooting note for copying from a remote tmux session
to a local clipboard over mosh.

## Symptom

Copying from a remote tmux session to the local clipboard works over SSH but
fails over mosh.

The relevant topology is:

```text
local terminal -> mosh client -> remote mosh-server -> remote tmux
```

Because tmux is running on the remote host, the fix belongs on the remote host.

## Root Cause

Two conditions must be true for remote tmux copy to reach the local clipboard
over mosh:

1. The remote `mosh-server` must support OSC52 clipboard forwarding.
2. The remote tmux config must use OSC52/native clipboard copying, not a remote
   clipboard command such as `pbcopy`, `xclip`, or `wl-copy`.

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
ssh HOST 'command -v mosh-server; mosh-server --version | head -1'
ssh HOST 'tmux -V; tmux show-options -g set-clipboard; tmux list-keys -T copy-mode-vi | grep -E " y |MouseDragEnd|Enter"'
```

Expected:

```text
mosh-server 1.4.0 or newer
set-clipboard on
y -> copy-selection-and-cancel
```

Also check that the local terminal allows OSC52 clipboard writes. For example,
Ghostty needs clipboard writes allowed:

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
set -gu terminal-overrides
set -ga terminal-overrides ",*:Tc"
set -ag terminal-overrides ",*256col*:colors=256:Tc"
set -ag terminal-overrides "vte*:XT:Ms=\E]52;c;%p2%s\7,xterm*:XT:Ms=\E]52;c;%p2%s\7"
set -gu terminal-features
set -as terminal-features ',xterm-256color:clipboard,ghostty:clipboard'
set -g set-clipboard on

setw -g mode-keys vi
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel
bind -T copy-mode-vi MouseDragEnd2Pane send -X copy-selection-and-cancel
```

Reload:

```sh
tmux source-file ~/.tmux.conf
```

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
