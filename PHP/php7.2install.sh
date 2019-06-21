yum -y install bzip2-devel libmcrypt-deve
yum -y install bzip2-devel curl-devel db4-devel  
yum -y install libjpeg-devel libpng-devel libXpm-devel gmp-devel libc-client-devel openldap-devel unixODBC-devel net-snmp-devel mysql-devel sqlite-devel aspell-devel libxml2-devel libxslt-devel  libxslt-devel
yum -y install gcc-c++  m4 autoconf
if [ $OS_RL == 1 ];then
	yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel \
       freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel xz \
       curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 \
       libcap-devel ntp sysklogd diffutils sendmail iptables unzip cmake wget logrotate \
	re2c bison icu libicu libicu-devel net-tools psmisc vim-enhanced
else
	apt-get install -y gcc g++ make autoconf libltdl-dev libgd2-xpm-dev \
       libfreetype6 libfreetype6-dev libxml2-dev libjpeg-dev libpng12-dev \
       libcurl4-openssl-dev libssl-dev patch libmcrypt-dev libmhash-dev \
       libncurses5-dev  libreadline-dev bzip2 libcap-dev ntpdate \
       diffutils exim4 iptables unzip sudo cmake re2c bison \
       libicu-dev net-tools psmisc xz libzip libzip-devel
#!/bin/bash
PHP_INSTALL_PATH=/usr/local/webserver/php-7.2.16
PHP_CONFIG_PATH=$PHP_INSTALL_PATH/bin/php-config
mysql_config_path=`find / -name mysql_config |grep /usr/local`
src=`pwd`
php_dir=$src/php-7.2.16
redis_dir=$src/redis-4.3.0
swoole_dir=$src/swoole-4.3.1
mcrypt_dir=$src/mcrypt-1.0.2
cpu_num=`cat /proc/cpuinfo| grep "cpu cores"| uniq|cut -d":" -f2`
ls *.tgz > ls.log
for i in $(cat ls.log)
	do
		tar -zxf $i
	done
 if [ ! -d "/usr/local/webserver/php-7.2.16/etc" ]
	then mkdir -p /usr/local/webserver/php-7.2.16/etc/
 fi
cd $src/php-7.2.16 && ./configure --prefix=$PHP_INSTALL_PATH --with-config-file-path=$PHP_INSTALL_PATH/etc --with-config-file-scan-dir=/usr/local/webserver/php-7.2.16/etc/php.d --with-mysqli=$mysql_config_path --with-pdo-mysql --with-openssl  --with-zlib --enable-zip --with-bz2 --with-iconv-dir=/usr/local --with-xpm-dir=/usr/ --disable-rpath --enable-pcntl --enable-bcmath --enable-shmop --enable-sysvsem --with-gettext --with-gd --with-freetype-dir --with-jpeg-dir --with-curl --enable-xml --with-png-dir --with-mhash --enable-mbstring --enable-sockets --enable-soap --enable-fpm --with-fpm-user=www --with-fpm-group=www
if [ `echo $?` ]
 then
#ZEND_EXTRA_LIBS='-liconv'
  make  -j $cpu_num && make install && echo "php7.2 install successful" > $PHP_INSTALL_PATH/install.log
 else
 echo "please php7.2.16 ./configure"&& exit 0
fi
cd $redis_dir
$PHP_INSTALL_PATH/bin/phpize && ./configure --with-php-config=$PHP_CONFIG_PATH && make && make install && echo "redis.so install successful" >> $PHP_INSTALL_PATH/install.log
cd $swoole_dir
$PHP_INSTALL_PATH/bin/phpize && ./configure --with-php-config=$PHP_CONFIG_PATH && make && make install && echo "swoole install successful" >> $PHP_INSTALL_PATH/install.log
cd $mcrypt_dir
$PHP_INSTALL_PATH/bin/phpize && ./configure --with-php-config=$PHP_CONFIG_PATH && make && make install && echo "mcrypt install successful" >> $PHP_INSTALL_PATH/install.log
if [ -f $PHP_INSTALL_PATH/etc/php.ini ]
	then
      		 echo "php.ini exit!" >> $PHP_INSTALL_PATH/install.log
	else
		cp $php_dir/php.ini-production $PHP_INSTALL_PATH/etc/php.ini
if
sed -i "887i extension=swoole.so" $PHP_INSTALL_PATH/etc/php.ini
sed -i "887i extension=redis.so" $PHP_INSTALL_PATH/etc/php.ini
sed -i "887i extension=mcrypt.so" $PHP_INSTALL_PATH/etc/php.ini
opcache.enable=1
opcache.memory_consumption=512
opcache.validate_timestamps=1
opcache.revalidate_freq=60
opcache.interned_strings_buffer=40
opcache.max_accelerated_files=4000
opcache.fast_shutdown=1
zend_extension="opcache.so"

echo "install end"

