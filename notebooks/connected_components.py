import marimo

__generated_with = "0.18.0"
app = marimo.App(width="medium")


@app.cell
def _():
    import os
    from pyspark.sql import SparkSession
    from graphframes.examples import Graphs


    def get_spark_session() -> SparkSession:
        assert os.getenv("DEMO_JAVA_HOME") and os.getenv("DEMO_SPARK_HOME")
        os.environ["JAVA_HOME"] = os.getenv("DEMO_JAVA_HOME")
        os.environ["SPARK_HOME"] = os.getenv("DEMO_SPARK_HOME")
        spark_session = SparkSession.builder.appName("Demo: Connected Components").getOrCreate()
        spark_session.sparkContext.setLogLevel("ERROR")
        return spark_session
    return Graphs, get_spark_session


@app.cell
def _(Graphs, get_spark_session):
    spark = get_spark_session()
    graph = Graphs(spark).friends()
    spark
    return (graph,)


@app.cell
def _(graph):
    graph.vertices
    return


@app.cell
def _(graph):
    graph.edges
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
