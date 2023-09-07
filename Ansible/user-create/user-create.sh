#!/bin/bash

# Create Non root User
username="Developer"
password="TripleHHH1234$$$"

# Create the user with a home directory
sudo useradd -m "$username"

# Set the password interactively
echo -e "$password\n$password" | sudo passwd "$username"

