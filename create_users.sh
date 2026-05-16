#!/bin/bash

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
  echo "Fel: Scriptet måste köras som root."
  exit 1
fi

# Kontrollera att minst en användare skickats in
if [ "$#" -eq 0 ]; then
  echo "Användning: ./create_users.sh user1 user2 user3"
  exit 1
fi

# Hämta befintliga användare (endast riktiga användare)
existing_users=$(ls /home)

# Loopa igenom alla användarnamn
for username in "$@"; do

  # Kontrollera om användaren redan finns
  if id "$username" &>/dev/null; then
    echo "Användaren $username finns redan."
    continue
  fi

  # Skapa användare med hemkatalog
  useradd -m -s /bin/bash "$username"

  home_dir="/home/$username"

  # Skapa mappar
  mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

  # Sätt rättigheter (endast ägare)
  chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

  # Sätt ägarskap
  chown -R "$username:$username" "$home_dir"

  # Skapa welcome.txt
  {
  echo "Välkommen $username"
  cut -d: -f1 /etc/passwd
} > "$home_dir/welcome.txt"

  # Rättigheter för welcome.txt
  chmod 700 "$home_dir/welcome.txt"
  chown "$username:$username" "$home_dir/welcome.txt"

done
