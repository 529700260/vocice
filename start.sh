#!/bin/bash
__run() {
  echo -e "123456\n123456" | (passwd)
  /usr/sbin/sshd -D
}

__start() {
  #程序名
  RUN_NAME="$1"
  #jar 位置
  JAVA_OPTS=/var/www/"$1".jar
  source /etc/profile
  #不输出启动日志
  nohup java -jar $JAVA_OPTS >/dev/null 2>&1 &
  echo "$RUN_NAME started success."
}

# Call all functions
__start $1
__run