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

# Hämta befintliga systemanvändare
existing_users=$(cut -d: -f1 /etc/passwd)

# Loopa igenom alla användarnamn
for username in "$@"; do

  if id "$username" &>/dev/null; then
    echo "Användaren $username finns redan."
    continue
  fi

  # Skapa användare
  useradd -m -s /bin/bash "$username"
  home_dir="/home/$username"

  # Skapa mappar
  mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

  # Rättigheter
  chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
  chown -R "$username:$username" "$home_dir"

  # Skapa welcome.txt
  {
    echo "Välkommen $username"
    echo "$existing_users"
  } > "$home_dir/welcome.txt"

  chmod 600 "$home_dir/welcome.txt"
  chown "$username:$username" "$home_dir/welcome.txt"

done
