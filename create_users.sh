#!/bin/bash

# Script för att skapa användare och mappar

# Kontrollera root-behörighet
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Scriptet måste köras som root."
    exit 1
fi

# Kontrollera att minst en användare skickats med
if [ "$#" -eq 0 ]; then
    echo "Användning: ./create_users.sh användare1 användare2"
    exit 1
fi

# Loopa igenom alla användarnamn
for username in "$@"
do
    # Hämta befintliga användare
    existing_users=$(cut -d: -f1 /etc/passwd)

    # Skapa användaren om den inte redan finns
    if id "$username" &>/dev/null; then
        echo "Användaren $username finns redan."
    else
        useradd -m "$username"
        echo "Användaren $username skapades."
    fi

    # Hemkatalog
    home_dir="/home/$username"

    # Skapa undermappar
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    # Rättigheter
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    # Ägarskap
    chown -R "$username:$username" "$home_dir"

    # Skapa welcome.txt
    {
        echo "Välkommen $username"
        echo ""
        echo "Andra användare i systemet:"
        echo "$existing_users"
    } > "$home_dir/welcome.txt"

    chmod 600 "$home_dir/welcome.txt"
    chown "$username:$username" "$home_dir/welcome.txt"

done
