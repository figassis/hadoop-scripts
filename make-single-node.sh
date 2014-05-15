cd ~ 
apt-get update

# Download java jdk
apt-get install openjdk-7-jdk
ln -s /usr/lib/jvm/java-7-openjdk-amd64 jdk

# Uncommment to install ssh 
# sudo apt-get install openssh-server

# Generate keys
ssh-keygen -t rsa -P ''
sh -c 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
#ssh localhost

# Download Hadoop and set permissons
cd ~
if [ ! -f hadoop-2.4.0.tar.gz ]; then
	wget http://www.motorlogy.com/apache/hadoop/common/current/hadoop-2.4.0.tar.gz
fi
tar vxzf hadoop-2.4.0.tar.gz -C /usr/local
cd /usr/local
mv hadoop-2.4.0 hadoop

# Hadoop variables
sh -c 'echo export JAVA_HOME=/usr/lib/jvm/jdk/ >> ~/.bashrc'
sh -c 'echo export HADOOP_INSTALL=/usr/local/hadoop >> ~/.bashrc'
sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> ~/.bashrc'
sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> ~/.bashrc'
sh -c 'echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> ~/.bashrc'
sh -c 'echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> ~/.bashrc'
sh -c 'echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> ~/.bashrc'
sh -c 'echo export YARN_HOME=\$HADOOP_INSTALL >> ~/.bashrc'
sh -c 'echo export HADOOP_COMMON_LIB_NATIVE_DIR=\$\{HADOOP_INSTALL\}/lib/native >> ~/.bashrc'
sh -c 'echo export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\" >> ~/.bashrc'

# Modify JAVA_HOME 
cd /usr/local/hadoop/etc/hadoop
sed -i.bak s=\${JAVA_HOME}=/usr/lib/jvm/jdk/=g hadoop-env.sh
pwd

# Check that Hadoop is installed
/usr/local/hadoop/bin/hadoop version

# Edit configuration files
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://localhost:9000\</value>\</property>=g' core-site.xml 
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml
  
cp mapred-site.xml.template mapred-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml
 
cd ~
mkdir -p mydata/hdfs/namenode
mkdir -p mydata/hdfs/datanode

cd /usr/local/hadoop/etc/hadoop
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/home/hduser/mydata/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/home/hduser/mydata/hdfs/datanode</value>\</property>=g' hdfs-site.xml


# Format Namenode
sh -c 'hdfs namenode -format'

# Start Hadoop Service
start-dfs.sh
start-yarn.sh

# Check status
jps

# Example
# sudo -u hduser cd /usr/local/hadoop
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 2 5