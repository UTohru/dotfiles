#!/bin/sh
# ===============
# install Cica font
# ===============
# 
# ダウンロードして,zipを解凍できれば何でも良い
# fontconfig は,なければインストールする

# コマンドだけ参考にして，手動でインストールしたほうがいいかも？


# assets[0] : without emoji
curl https://api.github.com/repos/miiton/Cica/releases/latest | jq '.assets[1].browser_download_url' | xargs curl -L -O


# not exist other zip file
zdir=`ls *.zip`
cicadir=${zdir%.zip}

unar *.zip

sudo mkdir /usr/local/share/fonts/Cica
sudo cp ${cicadir}/*.ttf /usr/local/share/fonts/Cica
sudo fc-cache -fv

rm *.zip
rm -rf ${cicadir}

