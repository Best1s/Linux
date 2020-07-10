rpm -qa | grep -q gcc || yum -y install gcc
rpm -qa |grep -q zlib-devel || yum -y install zlib-devel
tar -zxf python3.tgz && cd Python-3.6.2/
mkdir  /usr/local/python
./configure  --prefix=/usr/local/python  --with-ssl  &&  make  -j  &&  make  install
cd  /usr/bin/
ln  -s  /usr/local/python/bin/pip3  pip3
ln  -s  /usr/local/python/bin/python3.6  python3.6
python3.6  --version