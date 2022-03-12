Hadoop + Spark guide on Centos 7


CLUSTER CONFIGURATION
"""
Files to be modified are provided. Push them to MASTER node using scp -r <folder> master:<dir>
"""


# Initial Setup #
_______________________________________________________________________
CHANGE HOSTNAME

hostnamectl set-hostname master
hostnamectl set-hostname slave1 (for slave node)
hostnamectl set-hostname slave2 (for slave node)
_______________________________________________________________________
CONFIGURE FIREWALL ON MASTER AND SLAVE

service firewalld stop
_______________________________________________________________________
DEFINE CLUSTER HOSTS ON MASTER

vim /etc/hosts
"""
X.X.X.X master
Y.Y.Y.Y slave1
Z.Z.Z.Z slave2
"""
_______________________________________________________________________
CREATE KEYLESS SSH CONNECTION ON MASTER

ssh-keygen -t rsa
ssh-copy-id -i master
ssh-copy-id -i slave1
ssh-copy-id -i slave2
_______________________________________________________________________
PUSH HOST FILE FROM MASTER TO SLAVE

scp /etc/hosts slave1:/etc/
scp /etc/hosts slave2:/etc/
_______________________________________________________________________
CREATE KEYLESS SSH CONNECTION ON SLAVE

ssh-keygen -t rsa
ssh-copy-id -i master
ssh-copy-id -i slave1
ssh-copy-id -i slave2
______________________________________________________________________
PUSH PYTHON SETUP FROM MASTER TO SLAVE

scp Python-3.8.2.tgz zlib-devel-1.2.7-18.el7.x86_64.rpm slave1:/root/
scp Python-3.8.2.tgz zlib-devel-1.2.7-18.el7.x86_64.rpm slave2:/root/
______________________________________________________________________
INSTALL UPGRADE PYTHON ON MASTER AND SLAVE

yum install zlib-devel-1.2.7-18.el7.x86_64.rpm -y
tar -xvf Python-3.8.2.tgz
cd Python-3.8.2/
./configure
make
make install
cd
______________________________________________________________________



# Hadoop Setup #
______________________________________________________________________
EXTRACT HADOOP

tar -xvf hadoop-3.3.2.tar.gz
______________________________________________________________________
SET ENVIRONMENT

vim /etc/profile
"""
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
export PATH=$PATH:$JAVA_HOME/bin
export HADOOP_HOME=/root/hadoop-3.3.2
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME:/sbin
"""
source /etc/profile

vim ~/.bashrc
"""
HADOOP_HOME=/root/hadoop-3.3.2
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
PATH=$PATH:$HADOOP_PREFIX/bin
export PATH JAVA_HOME HADOOP_HOME
"""
source ~/.bashrc
______________________________________________________________________
EDIT CONFIGURATION FILE

vim $HADOOP_HOME/etc/hadoop/core-site.xml
"""
<configuration>
     <property>
         <name>fs.defaultFS</name>
         <value>hdfs://master:9000</value>
     </property>
</configuration>
"""

vim $HADOOP_HOME/etc/hadoop/hdfs-site.xml
"""
<configuration>
   <property>
       <name>dfs.namenode.secondary.http-address</name>
       <value>master:50090</value>
   </property>
   <property>
       <name>dfs.replication</name>
       <value>3</value>
   </property>
   <property>
       <name>dfs.namenode.name.dir</name>
       <value>file:///home/hadoop/hadoopdata/hdfs/namenode</value>
       <final>true</final>
   </property>
   <property>
       <name>dfs.datanode.data.dir</name>
       <value>file:///home/hadoop/hadoopdata/hdfs/datanode</value>
       <final>true</final>
   </property>
   <property>
       <name>dfs.webhdfs.enabled</name>
       <value>true</value>
   </property>
   <property>
       <name>dfs.permissions.enabled</name>
       <value>false</value>
   </property>
</configuration>
"""

vim $HADOOP_HOME/etc/hadoop/mapred-site.xml
"""
<configuration>
   <property>
       <name>mapreduce.framework.name</name>
       <value>yarn</value>
   </property>
   <property>
       <name>mapreduce.jobhistory.address</name>
       <value>master:10020</value>
   </property>
   <property>
       <name>mapreduce.jobhistory.webapp.address</name>
       <value>master:19888</value>
   </property>
   <property>
       <name>mapreduce.application.classpath</name>
       <value>
           /root/hadoop-3.3.2/etc/hadoop,
           /root/hadoop-3.3.2/share/hadoop/common/*,
           /root/hadoop-3.3.2/share/hadoop/common/lib/*,
           /root/hadoop-3.3.2/share/hadoop/hdfs/*,
           /root/hadoop-3.3.2/share/hadoop/hdfs/lib/*,
           /root/hadoop-3.3.2/share/hadoop/mapreduce/*,
           /root/hadoop-3.3.2/share/hadoop/mapreduce/lib/*,
           /root/hadoop-3.3.2/share/hadoop/yarn/*,
           /root/hadoop-3.3.2/share/hadoop/yarn/lib/*
       </value>
   </property>
</configuration>
"""

vim $HADOOP_HOME/etc/hadoop/yarn-site.xml
"""
<configuration>
   <property>
       <name>yarn.nodemanager.aux-services</name>
       <value>mapreduce_shuffle</value>
   </property>
   <property>
       <name>yarn.resourcemanager.address</name>
       <value>master:8032</value>
   </property>
   <property>
       <name>yarn.resourcemanager.scheduler.address</name>
       <value>master:8030</value>
   </property>
   <property>
       <name>yarn.log-aggregation-enable</name>
       <value>true</value>
   </property>
   <property>
       <name>yarn.resourcemanager.resource-tracker.address</name>
       <value>master:8031</value>
   </property>
   <property>
       <name>yarn.resourcemanager.admin.address</name>
       <value>master:8033</value>
   </property>
   <property>
       <name>yarn.resourcemanager.webapp.address</name>
       <value>master:8088</value>
   </property>
</configuration>
"""

vim $HADOOP_HOME/etc/hadoop/workers
"""
localhost
slave1
slave2
"""

vim $HADOOP_HOME/etc/hadoop/hadoop-env.sh
"""
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
export HADOOP_HOME=/root/hadoop-3.3.2
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
"""
______________________________________________________________________
DISTRIBUTE HADOOP

scp -r hadoop-3.3.2 slave1:/root/
scp -r hadoop-3.3.2 slave2:/root/
______________________________________________________________________
PUSH ENVIRONMENT FOR SLAVE

scp /etc/profile slave1:/etc/
scp /etc/profile slave2:/etc/
source /etc/profile (run this on slave)
______________________________________________________________________
FORMAT NAMENODE
hdfs namenode -format
______________________________________________________________________
START HADOOP CLUSTER
$HADOOP_HOME/sbin/start-all.sh

jps (view running services)
master:9870 (dashboard)
master:8088/cluster (yarn)

hdfs dfsadmin -report (check health status)

PUT FILES
hdfs dfs -put XXX.csv hdfs://master:9000/user/root/
______________________________________________________________________



# Spark Setup #
______________________________________________________________________
EXTRACT SPARK

tar -xvf spark-3.2.1-bin-hadoop3.2.tgz
______________________________________________________________________
ADD TO PATH

vim /etc/profile
"""
export SPARK_HOME=/root/spark-3.2.1-bin-hadoop3.2
export PATH=$PATH:$SPARK_HOME:/bin:$SPARK_HOME:/sbin
"""
source /etc/profile
______________________________________________________________________
EDIT SPARK TEMPLATE

vim spark-3.2.1-bin-hadoop3.2/conf/spark-env.sh
"""
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
export HADOOP_CONF_DIR=/root/hadoop-3.3.1/etc/hadoop
export SPARK_MASTER_HOST=master
export SPARK_LOCAL_DIRS=/root/spark-3.2.1-bin-hadoop3.2

"""

vim spark-3.2.1-bin-hadoop3.2/conf/workers
"""
localhost
slave1
slave2
"""
______________________________________________________________________
DISTRIBUTE SPARK

scp -r spark-3.2.1-bin-hadoop3.2 slave1:/root/
scp -r spark-3.2.1-bin-hadoop3.2 slave2:/root/
______________________________________________________________________
PUSH ENVIRONMENT FOR SLAVE

scp /etc/profile slave1:/etc/
scp /etc/profile slave2:/etc/
source /etc/profile (run this on slave)
______________________________________________________________________
START SPARK

$SPARK_HOME/sbin/start-all.sh

master:8080 (spark)
______________________________________________________________________



CLIENT CONFIGURATION



_______________________________________________________________________
CHANGE HOSTNAME

hostnamectl set-hostname client
_______________________________________________________________________
CONFIGURE FIREWALL

service firewalld stop
_______________________________________________________________________
ADD CLIENT ON MASTER

vim /etc/hosts
"""
A.A.A.A client
"""
_______________________________________________________________________
CREATE KEYLESS SSH CONNECTION ON MASTER

ssh-copy-id -i client
_______________________________________________________________________
ADD MASTER ON CLIENT

vim /etc/hosts
"""
X.X.X.X master
"""
_______________________________________________________________________
CREATE KEYLESS SSH CONNECTION ON CLIENT

ssh-keygen -t rsa
ssh-copy-id -i master
ssh-copy-id -i client
______________________________________________________________________
INSTALL UPGRADE PYTHON ON MASTER AND SLAVE

yum install zlib-devel-1.2.7-18.el7.x86_64.rpm -y
tar -xvf Python-3.8.2.tgz
cd Python-3.8.2/
./configure
make
make install
cd

OR U CAN USE ANACONDA
______________________________________________________________________
INSTALL PYSPARK
pip3 install py4j-0.10.9.3-py2.py3-none-any.whl
pip3 install pypandoc-1.7.2-py2.py3-none-any.whl
pip3 install pyspark-3.2.1.tar.gz
______________________________________________________________________
USING SPARK AND HDFS

(putting files to hdfs)
cat X.csv | ssh root@master "hdfs dfs -put - hdfs://master:9000/user/root/X.csv"


(running spark script)
spark-submit Y.py
