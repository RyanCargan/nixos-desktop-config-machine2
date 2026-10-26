# Local secrets; never committed.
if [ -f "$HOME/.config/secrets/env" ]; then
  set -a
  . "$HOME/.config/secrets/env"
  set +a
fi

# ----- SSH agent: start if not running -----
mkdir -p "$HOME/.ssh"
[ -f "$HOME/.ssh/agent-env" ] && source "$HOME/.ssh/agent-env"
if ! ssh-add -l &>/dev/null; then
  echo "Starting ssh-agent..." >&2
  eval "$(ssh-agent -s)" > /dev/null
  ssh-agent -s > "$HOME/.ssh/agent-env"
  source "$HOME/.ssh/agent-env"
fi

# yt-dlp functions
yt_vdq () {
  local playlist=''
  local items=''
  if [[ -n $4 ]]; then
    playlist='%(playlist_autonumber)s-'
    items="--playlist-items $4"
  else
    playlist=''
    items=''
  fi
  local pString="yt-dlp --add-metadata --embed-metadata --embed-chapters --all-subs --embed-subs --embed-thumbnail -o ${playlist}%(title)s-%(id)s.%(ext)s -f"
  if [[ -n $4 ]]; then
    ${pString} $3$2 $1 ${items}
  elif [[ -n $3 ]]; then
    ${pString} $3$2 $1
  else
    ${pString} $2 $1
  fi
}

yt_vdp () {
  local subtitle_lang="en.*,ja"
  yt-dlp --embed-subs --sub-langs ${subtitle_lang} --write-subs -f $3 -o "%(playlist)s/%(playlist_index)s - %(title)s-%(id)s.%(ext)s" $1 -I "$2"
}

detect_alsa_device () {
  pacmd load-module module-alsa-source device=hw:Loopback,1,0
}

capture_traffic() {
  if [ -z "$1" ]; then
    echo "Usage: capture_traffic <PID>"
    return 1
  fi
  PID=$1
  OUTPUT_FILE="capture_${PID}.pcap"
  echo "Starting tcpdump for PID $PID..."
  sudo tcpdump -i any -w "$OUTPUT_FILE" "pid $PID"
  echo "Traffic capture started. Output saved to $OUTPUT_FILE."
}

retry_command() {
  local cmd=("$@")
  while true; do
    "${cmd[@]}"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
      break
    else
      echo "Command '${cmd[*]}' failed with exit code $exit_code. Retrying in 1 minute..."
      sleep 10
    fi
  done
}

retry_sudo() {
  local cmd=("$@")
  refresh_sudo() {
    while true; do
      sudo -v
      sleep 25
    done
  }
  (
    refresh_sudo &
    while true; do
      sudo -n "${cmd[@]}" < /dev/null
      exit_code=$?
      if [ $exit_code -eq 0 ]; then
        pkill -P $$
        break
      else
        echo "Command '${cmd[*]}' failed with exit code $exit_code. Retrying in 1 minute..."
        sleep 10
      fi
    done
  )
}

backup_cyberpunk () {
  rsync -avP "/run/media/ryan/ubuntu/SteamLibrary/steamapps/compatdata/1091500/pfx/drive_c/users/steamuser/Saved Games/CD Projekt Red/Cyberpunk 2077" /run/media/ryan/ubuntu/SaveBackups/
}

# fzf already configured via sessionVariables

# direnv hook
eval "$(direnv hook zsh)"

# starship prompt
eval "$(starship init zsh)"

# z.lua
eval "$(lua ~/zsh-plugins/z.lua/z.lua --init zsh enhanced once fzf)"

# bun completions
[ -s "/home/ryan/.bun/_bun" ] && source "/home/ryan/.bun/_bun"