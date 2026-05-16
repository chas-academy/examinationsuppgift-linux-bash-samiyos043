#!/bin/bash

# Script som skapar användare och deras katalogstruktur

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Detta script måste köras som root."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

for username in "$@"
do
    # Hämta lista över befintliga användare innan ny användare skapas
    existing_users=$(cut -d: -f1 /etc/passwd | grep -v "^${username}$")

    # Skapa användaren om den inte redan finns
    if ! id "$username" &>/dev/null; then
        useradd -m "$username"
    fi

    home_dir="/home/$username"

    # Skapa undermappar
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    # Sätt ägare
    chown -R "$username:$username" "$home_dir"

    # Sätt rättigheter (endast ägare)
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    # Skapa welcome.txt
    {
        echo "Välkommen $username"
        echo "$existing_users"
    } > "$home_dir/welcome.txt"

    # Sätt ägare och rättigheter på welcome-filen
    chown "$username:$username" "$home_dir/welcome.txt"
    chmod 600 "$home_dir/welcome.txt"
done
