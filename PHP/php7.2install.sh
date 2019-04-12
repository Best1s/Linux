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
#if [ -f $PHP_INSTALL_PATH/etc/php.ini ]
#	then
#      		 echo "php.ini exit!" >> $PHP_INSTALL_PATH/install.log
#	else
# 		cp $php_dir/php.ini-production $PHP_INSTALL_PATH/etc/
#if
sed -i "887i extension=swoole.so" $php_dir/php.ini-production
sed -i "887i extension=redis.so" $php_dir/php.ini-production
sed -i "887i extension=mcrypt.so" $php_dir/php.ini-production
echo "install end"

