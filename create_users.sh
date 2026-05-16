#!/bin/bash
# Skapar användare med katalogstruktur och welcome-fil

# Kontrollera root
if [ "$EUID" -ne 0 ]; then
  echo "Scriptet måste köras som root"
  exit 1
fi

# Kontrollera att minst en användare skickas in
if [ "$#" -lt 1 ]; then
  echo "Användning: ./create_users.sh user1 user2"
  exit 1
fi

for username in "$@"; do
  # Skapa användare
  useradd -m "$username"

  home="/home/$username"

  # Skapa mappar
  mkdir "$home/Documents" "$home/Downloads" "$home/Work"

  # Rättigheter (endast ägare)
  chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"

  # Welcome-fil
  echo "Välkommen $username" > "$home/welcome.txt"

  # Ägarskap
  chown -R "$username:$username" "$home"
done
