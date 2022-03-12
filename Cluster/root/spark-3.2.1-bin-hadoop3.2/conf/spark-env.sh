export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
export HADOOP_CONF_DIR=/root/hadoop-3.3.2/etc/hadoop
export SPARK_MASTER_HOST=master
export SPARK_LOCAL_DIRS=/root/spark-3.2.1-bin-hadoop3.2