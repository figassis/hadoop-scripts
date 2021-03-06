cd ~ 
apt-get update

# Download java jdk
apt-get install openjdk-7-jdk
ln -s /usr/lib/jvm/java-7-openjdk-amd64 jdk

# Uncommment to install ssh 
# sudo apt-get install openssh-server

# Generate keys
ssh-keygen -t rsa -P ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#ssh localhost

# Download Hadoop and set permissons
cd ~
if [ ! -f hadoop-2.4.0.tar.gz ]; then
	wget http://www.motorlogy.com/apache/hadoop/common/current/hadoop-2.4.0.tar.gz
fi
tar vxzf hadoop-2.4.0.tar.gz -C /usr/local
cd /usr/local
mv hadoop-2.4.0 hadoop


# Hadoop variables to set now
export JAVA_HOME=/root/jdk
export HADOOP_INSTALL=/usr/local/hadoop
export PATH=\$PATH:\$HADOOP_INSTALL/bin
export PATH=\$PATH:\$HADOOP_INSTALL/sbin
export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL
export HADOOP_COMMON_HOME=\$HADOOP_INSTALL
export HADOOP_HDFS_HOME=\$HADOOP_INSTALL
export YARN_HOME=\$HADOOP_INSTALL
export HADOOP_COMMON_LIB_NATIVE_DIR=\$\{HADOOP_INSTALL\}/lib/native
export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\"

# Hadoop variables to set after a reboot
echo export JAVA_HOME=/root/jdk >> ~/.bashrc
echo export HADOOP_INSTALL=/usr/local/hadoop >> ~/.bashrc
echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> ~/.bashrc
echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> ~/.bashrc
echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export YARN_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export HADOOP_COMMON_LIB_NATIVE_DIR=\$\{HADOOP_INSTALL\}/lib/native >> ~/.bashrc
echo export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\" >> ~/.bashrc



# Modify JAVA_HOME 
cd /usr/local/hadoop/etc/hadoop
sed -i.bak s=\${JAVA_HOME}=/root/jdk=g hadoop-env.sh
pwd

# Check that Hadoop is installed
/usr/local/hadoop/bin/hadoop version

# Edit configuration files
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://localhost:9000\</value>\</property>=g' core-site.xml 
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml
  
cp mapred-site.xml.template mapred-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml
 
cd ~
mkdir -p /usr/local/hadoop_store/hdfs/namenode
mkdir -p /usr/local/hadoop_store/hdfs/datanode

cd /usr/local/hadoop/etc/hadoop
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/usr/local/hadoop_store/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/usr/local/hadoop_store/hdfs/datanode</value>\</property>=g' hdfs-site.xml


# Format Namenode
hdfs namenode -format


# Start Hadoop Service
start-dfs.sh
start-yarn.sh

# Check status
jps

# Example
# sudo -u hduser cd /usr/local/hadoop
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 6 1000