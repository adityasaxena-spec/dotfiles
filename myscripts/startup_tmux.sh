#!/bin/bash

# Check if any tmux sessions are running
tmux_sessions=$(tmux ls 2>/dev/null)

# If there are no sessions, start a new session
if [ -z "$tmux_sessions" ]; then
    echo "No tmux sessions found. Starting a new session..."
    st tmux new-session
else
    # If there are sessions, attach to the first one
    echo "Tmux sessions found. Attaching to the first session..."
    first_session=$(echo "$tmux_sessions" | head -n 1 | cut -d: -f1)
    st tmux attach-session -t "$first_session"
fi
