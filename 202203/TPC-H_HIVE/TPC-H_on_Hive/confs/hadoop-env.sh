# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.  Required.
# export JAVA_HOME=/usr/lib/j2sdk1.5-sun

if [ -d /usr/local/jdk-6u7-64 ]; then
  export JAVA_HOME=${JAVA_HOME:-/usr/local/jdk-6u7-64}
else
  export JAVA_HOME=${JAVA_HOME:-/usr/local/java/}
fi

# Extra Java CLASSPATH elements.  Optional.
# export HADOOP_CLASSPATH=

# The maximum amount of heap to use, in MB. Default is 1000.
export HADOOP_HEAPSIZE=1000

# Extra Java runtime options.  Empty by default.
# export HADOOP_OPTS=-server
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"

# Command specific options appended to HADOOP_OPTS when specified
#export HADOOP_SECONDARYNAMENODE_OPTS=-Xmx2048m
#export HADOOP_JOBTRACKER_OPTS="-Xmx3000m -verbose:gc -XX:+PrintGCTimeStamps -XX:+PrintGCDetails -Xloggc:/var/hadoop/logs/jobtracker1.gc.log -Dcom.sun.management.jmxremote.port=8997 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
#export HADOOP_NAMENODE_OPTS="-Xmx2048m -verbose:gc -XX:+PrintGCTimeStamps -XX:+PrintGCDetails -Xloggc:/var/hadoop/logs/namenode.gc.log -Dcom.sun.management.jmxremote.port=8998 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
# export HADOOP_TASKTRACKER_OPTS=
# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
# export HADOOP_CLIENT_OPTS

# Extra ssh options.  Empty by default.
# export HADOOP_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"
export HADOOP_SSH_OPTS="-o ConnectTimeout=1"
# Where log files are stored.  $HADOOP_HOME/logs by default.
# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs
export HADOOP_LOG_DIR=/var/hadoop.benchmark/logs

# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1

# The directory where pid files are stored. /tmp by default.
# export HADOOP_PID_DIR=/var/hadoop/pids
export HADOOP_PID_DIR=/var/hadoop.benchmark/pids

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10
