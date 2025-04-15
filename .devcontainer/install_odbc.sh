#!/bin/bash

# Update package lists and install dependencies
apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    odbcinst1debian2 \
    libodbc1 \
    curl

# Download and install ODBC 18 Driver
curl -O https://download.microsoft.com/download/ODBC_Driver_18.tar.gz
tar -xzf ODBC_Driver_18.tar.gz
cd ODBC_Driver_18
./install.sh

# Cleanup
rm -rf ODBC_Driver_18.tar.gz ODBC_Driver_18

echo "ODBC 18 Driver installation complete!"
