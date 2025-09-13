#!/usr/bin/env bash
## install_starship.sh — Install or update Starship prompt on Fedora/Linux

set -euo pipefail

curl -sS https://starship.rs/install.sh | sh -s -- -y;


###############################################################################
# 2. Ensure Zsh init is present
###############################################################################
ZSHRC="$HOME/.zshrc"
INIT_LINE='eval "$(starship init zsh)"'

if [[ -f "$ZSHRC" ]]; then
  if grep -Fq "$INIT_LINE" "$ZSHRC"; then
    echo "→ Starship init already present in $ZSHRC"
  else
    echo "→ Adding Starship init to $ZSHRC"
    printf '\n# Starship prompt\n%s\n' "$INIT_LINE" >> "$ZSHRC"
  fi
else
  echo "→ No ~/.zshrc found; creating minimal one with Starship init"
  printf '#!/usr/bin/env zsh\n\n# Starship prompt\n%s\n' "$INIT_LINE" > "$ZSHRC"
fi

###############################################################################
# 3. (Optional) Disable Oh-My-Zsh theme to avoid double prompts
###############################################################################
if [[ -f "$ZSHRC" ]]; then
  if grep -q '^ZSH_THEME=' "$ZSHRC"; then
    # Keep existing line but set to empty to let Starship fully own the prompt
    sed -i 's|^ZSH_THEME=.*|ZSH_THEME=""|' "$ZSHRC"
  fi
fi

echo "✔ Starship is ready. Start a new Zsh session or run: exec zsh"


