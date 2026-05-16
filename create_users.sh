#!/bin/bash
# Script för att skapa användare med katalogstruktur och welcome-fil

# Kontrollera root
if [ "$EUID" -ne 0 ]; then
  echo "Fel: Scriptet måste köras som root."
  exit 1
fi

# Kontrollera argument
if [ "$#" -lt 1 ]; then
  echo "Användning: ./create_users.sh användare1 användare2"
  exit 1
fi

# Hämta befintliga användare
existing_users=$(getent passwd | cut -d: -f1)

for username in "$@"; do

  if id "$username" &>/dev/null; then
    echo "Användaren $username finns redan."
    continue
  fi

  # Skapa användare med hemkatalog
  useradd -m -s /bin/bash "$username"

  home_dir="/home/$username"

  # Skapa mappar
  mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

  # Sätt rättigheter
  chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
  chown -R "$username:$username" "$home_dir"

  # Skapa welcome.txt
  {
    echo "Välkommen $username"
    echo "Andra användare i systemet:"
    echo "$existing_users"
  } > "$home_dir/welcome.txt"

  chmod 600 "$home_dir/welcome.txt"
  chown "$username:$username" "$home_dir/welcome.txt"

done
