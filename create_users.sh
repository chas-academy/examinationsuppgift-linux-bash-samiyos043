#!/bin/bash

# ============================================
# Script för att skapa användare automatiskt
# Skapar hemkataloger, undermappar och welcome.txt
# ============================================

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Du måste köra scriptet som root."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Loopa igenom alla användarnamn som skickats in
for USERNAME in "$@"
do
    # Kontrollera om användaren redan finns
    if id "$USERNAME" &>/dev/null; then
        echo "Användaren $USERNAME finns redan."
        continue
    fi

    echo "Skapar användare: $USERNAME"

    # Skapa användaren med hemkatalog
    useradd -m "$USERNAME"

    # Sätt standardlösenord (kan ändras senare)
    echo "$USERNAME:password123" | chpasswd

    # Sökväg till hemkatalog
    HOME_DIR="/home/$USERNAME"

    # Skapa undermappar
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # Ägarskap
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"

    # Behörigheter:
    # Endast ägaren får läsa/skriva/köra
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # Skapa welcome.txt
    WELCOME_FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USERNAME" > "$WELCOME_FILE"
    echo "" >> "$WELCOME_FILE"
    echo "Andra användare i systemet:" >> "$WELCOME_FILE"

    # Lista alla andra användare
    cut -d: -f1 /etc/passwd | grep -v "^$USERNAME$" >> "$WELCOME_FILE"

    # Rätt ägare och behörigheter på filen
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

    echo "Användare $USERNAME skapad klart."
done
