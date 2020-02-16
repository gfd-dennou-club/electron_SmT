cd esp
wsl export IDF_PATH="$HOME/esp/esp-idf"; export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH";export PATH="/home/$USER/.rbenv/bin:$PATH";eval "$(rbenv init -)"; make clean