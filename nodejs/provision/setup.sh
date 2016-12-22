#!/bin/bash

# - Kintamieji ---------------------------------------------------------------------
SOURCES_DIR=/vagrant/webroot
NODE_MODULES_DIR=/home/vagrant/node_modules

# - Veiksmas -----------------------------------------------------------------------

echo "Pradedam serverio diegimą."

# Atnaujinam saugyklas
apt-get update

# Diegiam G++ kompiliatorių (kompiliuoti C++...)
apt-get install -y --force-yes g++

# Parsisiunčiam NodeJs diegimo kodą
curl -sL https://deb.nodesource.com/setup_0.12 | sh

# Instaliuojam NodeJs
apt-get install -y --force-yes nodejs

# Pasikeičiam prisijungusį vartotoją į "vagrant". Jo vardu daromi tolimesni veiksmai.
su vagrant

# Kuriam NodeJs bibliotekom skirtą aplanką
mkdir $NODE_MODULES_DIR

# Sukuriam virtualų aplanką (kaip shortcut) projekto direktorijoje 
# į Node modulių aplanką.
cd $SOURCES_DIR
ln -s $NODE_MODULES_DIR/ node_modules

# Atsispausdinam versijas
node -v
npm -v

echo "Serverio diegimas baigtas."