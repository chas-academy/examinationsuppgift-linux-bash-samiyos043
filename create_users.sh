#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  exit 1
fi

if [ "$#" -lt 1 ]; then
  exit 1
fi

for user in "$@"; do

  if id "$user" >/dev/null 2>&1; then
    continue
  fi

  useradd -m -s /bin/bash "$user"

  mkdir -p /home/$user/Documents
  mkdir -p /home/$user/Downloads
  mkdir -p /home/$user/Work

  chmod 700 /home/$user/Documents
  chmod 700 /home/$user/Downloads
  chmod 700 /home/$user/Work

  chown -R $user:$user /home/$user

  echo "Välkommen $user" > /home/$user/welcome.txt
  cut -d: -f1 /etc/passwd >> /home/$user/welcome.txt

  chmod 644 /home/$user/welcome.txt
  chown $user:$user /home/$user/welcome.txt

done
