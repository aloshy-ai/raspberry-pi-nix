#!/bin/bash

echo "Welcome to UbuntuMint Hash Generator"
echo "----------------------------------------"

generate_hash() {
	echo "Password Hashing Script"
	echo "1. MD5"
	echo "2. SHA-256"
	read -p "Choose a hash method (1/2): " method

	if [ "$method" == "1" ]; then
    	hash_method="md5"
	elif [ "$method" == "2" ]; then
    	hash_method="sha-256"
	else
    	echo "Invalid choice."
    	return
	fi

	read -p "Enter the salt (leave blank for default): " salt
	read -p "Enter the number of rounds (leave blank for default): " rounds

	read -p "Enter the password you want to hash: " password

	command="mkpasswd -m $hash_method"
	if [ ! -z "$salt" ]; then
    	command="$command -S $salt"
	fi
	if [ ! -z "$rounds" ]; then
    	command="$command -R $rounds"
	fi

	hash=$(echo "$password" | $command -s)
       echo "---------------------------------------------------------"
       echo " Generated hash: $hash"
       echo "---------------------------------------------------------"
}

while true; do
	generate_hash

	read -p "Do you want to generate another hash? (y/n): " choice
	if [ "$choice" != "y" ]; then
    	echo "Good Bye!"
    	break
	fi
done

