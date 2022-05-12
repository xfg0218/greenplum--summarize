#!bin/bash

# add *.tbl file path
export FILE_PATH=/TPC-H_Tools_v3.0.0/dbgen


$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/ 

$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/customer
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/lineitem
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/nation
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/orders
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/part
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/partsupp
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/region
$HADOOP_HOME/bin/hadoop fs -mkdir /tpch/supplier

$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/customer.tbl /tpch/customer/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/lineitem.tbl /tpch/lineitem/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/nation.tbl /tpch/nation/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/orders.tbl /tpch/orders/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/part.tbl /tpch/part/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/partsupp.tbl /tpch/partsupp/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/region.tbl /tpch/region/
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $FILE_PATH/supplier.tbl /tpch/supplier/
