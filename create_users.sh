#!/bin/bash
# User creation script

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "Script must be run as root"
  exit 1
fi

# Argument check
if [ "$#" -eq 0 ]; then
  echo "Usage: ./create_users.sh user1 user2"
  exit 1
fi

for username in "$@"; do
  useradd -m -s /bin/bash "$username"

  home="/home/$username"

  mkdir "$home/Documents" "$home/Downloads" "$home/Work"
  chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"

  {
    echo "Välkommen $username"
    ls /home | grep -v "$username"
  } > "$home/welcome.txt"

  chmod 600 "$home/welcome.txt"
  chown -R "$username:$username" "$home"
done
