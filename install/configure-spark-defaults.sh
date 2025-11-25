# Figure out number of CPU cores and RAM
# RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
# RAM_MB=$(expr $RAM_KB / 1024)
# # 80% to leave more room for OS and other processes
# SAFE_RAM_MB=$(expr $RAM_MB / 10 \* 8 )
# CORES=$(( $(nproc --all) - 1 ))
# PARTITIONS=$(( $CORES * 3 ))
# PARALLELISM=$(( $CORES * 2 ))
# DRIVER_RAM_GB=$(expr $SAFE_RAM_MB / 1024)
# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    RAM_KB=$(sysctl -n hw.memsize | awk '{print int($1/1024)}')
    CORES=$(( $(sysctl -n hw.ncpu) - 1 ))
else
    # Linux
    RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    CORES=$(( $(nproc --all) - 1 ))
fi

RAM_MB=$(expr $RAM_KB / 1024)
# 80% to leave more room for OS and other processes
SAFE_RAM_MB=$(expr $RAM_MB / 10 \* 8)
PARTITIONS=$(( $CORES * 3 ))
PARALLELISM=$(( $CORES * 2 ))
DRIVER_RAM_GB=$(expr $SAFE_RAM_MB / 1024)

export DEMO_SPARK_HOME=$PWD/.venv/lib/python3.11/site-packages/pyspark

mkdir -p $PWD/logs
mkdir -p $DEMO_SPARK_HOME/conf

# Define Spark configurations
cat > $DEMO_SPARK_HOME/conf/spark-defaults.conf <<EOF
spark.master                                    local[$(echo $CORES)]
spark.sql.session.timeZone                      UTC
spark.task.cpus                                 1
spark.driver.maxResultSize                      8g
spark.network.timeout                           900s
spark.driver.memory                             $(echo $DRIVER_RAM_GB)G
spark.driver.cores                              $(echo $CORES)
spark.sql.shuffle.partitions                    $(echo $PARTITIONS)
spark.default.parallelism                       $(echo $PARALLELISM)
spark.ui.enabled                                false

# Performance Configs
spark.driver.memoryOverheadFactor               0.25
spark.sql.execution.arrow.pyspark.enabled       false
spark.sql.adaptive.enabled                      true
spark.sql.autoBroadcastJoinThreshold            -1
spark.sql.adaptive.coalescePartitions.enabled   true
spark.sql.parquet.filterPushdown                 true
spark.sql.parquet.mergeSchema                   true
spark.speculation                               false

# Memory Management
spark.storage.memoryFraction                                    0.3
spark.sql.execution.memoryFraction                              0.7
spark.sql.adaptive.advisoryPartitionSizeInBytes                 1GB
spark.sql.adaptive.maxPartitionSize                             4GB
spark.sql.files.maxPartitionBytes                               2147483648
spark.sql.files.openCostInBytes                                 8388608
spark.sql.execution.sortMergeJoinExecBufferInMemoryThreshold    128MB
spark.sql.execution.sortMergeJoinExecBufferSpillThreshold       256MB
spark.sql.execution.topKSortFallbackThreshold                   500000

# Data Skew
spark.sql.adaptive.skewJoin.enabled                            true
spark.sql.adaptive.localShuffleReader.enabled                  true
spark.sql.adaptive.skewJoin.skewedPartitionFactor              3
spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes    3221225472


# Packages
spark.jars.packages     io.graphframes:graphframes-spark3_2.12:0.10.0,org.apache.hadoop:hadoop-common:3.3.4


spark.checkpoint.dir                $(echo $PWD)/pydata-demo/data/checkpoint
spark.history.fs.logDirectory       $(echo $PWD)/logs
spark.eventLog.dir                  $(echo $PWD)/logs
spark.eventLog.enabled              false
spark.local.dir                     $(echo $PWD)/pydata-demo/data/spark-warehouse
spark.sql.warehouse.dir             $(echo $PWD)/pydata-demo/data/spark-warehouse
EOF

