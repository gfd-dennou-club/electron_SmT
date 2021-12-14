#!/bin/bash
. $HOME/esp/esp-idf/export.sh
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
cd ./app/esp
make spiffs
