#!/bin/sh
sudo apt -y update
sudo apt -y install tree gcc git wget make libncurses5-dev flex bison \
gperf python python-pip python-setuptools python-serial \
python-cryptography python-future python-pyparsing
mkdir $HOME/esp
cd $HOME/esp
wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
rm xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
echo 'export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"' >> $HOME/.profile
echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.profile
source $HOME/.profile
cd $HOME/esp
git clone --recursive https://github.com/espressif/esp-idf.git
cd $HOME/esp/esp-idf
git checkout ff020c3a18788d13f9dc8e853424d0067e79a357
git submodule update
python -m pip install --user -r $IDF_PATH/requirements.txt
sudo usermod -a -G dialout $USER
cd $HOME
git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.profile
echo 'eval "$(rbenv init -)"' >> $HOME/.profile
source .profile
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev
rbenv install 2.6.2
rbenv global 2.6.2
ruby --version
rbenv install mruby-1.4.1
cd /mnt/c/smrubyIoT-win32-x64/resources/app/esp/
make clean
make 
make menuconfig