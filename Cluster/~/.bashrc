#.bashrc
HADOOP_HOME=/root/hadoop-3.3.2
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
PATH=$PATH:$HADOOP_PREFIX/bin
export PATH JAVA_HOME HADOOP_HOME
# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi