#! /bin/bash

#https://www.google.com/chrome/browser/desktop/
#google disallows downloads unless it is through their page

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install vim
sudo apt-get install git
sudo apt-get install tilda
sudo apt-get install spotify-client

cd
wget https://download.sublimetext.com/sublime-text_build-3114_amd64.deb
sudo dpkg -i sublime-text_build-3114_amd64.deb
sudo apt-get install -f
#package control
#import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
#install Material Theme

wget https://downloads.typesafe.com/typesafe-activator/1.3.10/typesafe-activator-1.3.10-minimal.zip
unzip typesafe-activator-1.3.10-minial.zip
mv typesafe-activator-1.3.10-minimal activator
echo "#!/bin/bash\n~/activator/bin/activator \$@" > ~/bin/activator
chmod 775 ~/bin/activator

echo "#!/bin/bash\ntilda & tilda & tilda & tilda &" > ~/bin/tildas
chmod 775 ~/bin/tildas
