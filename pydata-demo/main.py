import os

from pyspark.sql import SparkSession


def get_spark_session() -> SparkSession:
    JAVA_HOME, SPARK_HOME = (
        os.getenv("DEMO_JAVA_HOME"),
        os.getenv("DEMO_SPARK_HOME"),
    )
    assert JAVA_HOME and SPARK_HOME
    os.environ["JAVA_HOME"] = JAVA_HOME
    os.environ["SPARK_HOME"] = SPARK_HOME
    spark_session = SparkSession.builder.appName(  # type:ignore[attribute-access]
        "Demo: Connected Components"
    ).getOrCreate()
    spark_session.sparkContext.setLogLevel("ERROR")
    return spark_session


if __name__ == "__main__":
    pass
