import marimo

__generated_with = "0.18.0"
app = marimo.App(width="medium", css_file="../../.marimo-theme.css")


@app.cell
def _():
    import os

    import matplotlib.pyplot as plt
    import networkx as nx
    from graphframes.examples import Graphs
    from pyspark.sql import SparkSession

    def get_spark_session() -> SparkSession:
        assert os.getenv("DEMO_JAVA_HOME") and os.getenv("DEMO_SPARK_HOME")
        os.environ["JAVA_HOME"] = os.getenv("DEMO_JAVA_HOME")
        os.environ["SPARK_HOME"] = os.getenv("DEMO_SPARK_HOME")
        spark_session = SparkSession.builder.appName(
            "Demo: Connected Components"
        ).getOrCreate()
        spark_session.sparkContext.setLogLevel("ERROR")
        return spark_session

    return get_spark_session, nx


@app.cell
def _(get_spark_session):
    spark = get_spark_session()
    spark
    return


@app.cell
def _():
    from ...data import mock

    mock.get_participants()

    # Graphs(spark).friends().vertices.selectExpr(
    #     "concat(id, '1')"
    # )
    return


@app.cell
def _(graph):
    graph.vertices
    return


@app.cell
def _(graph):
    graph.edges
    return


@app.cell
def _(graph, nx):
    connected_components = graph.connectedComponents()

    # Yes, Pandas to plot. Know of a Spark native plotting lib? Feel free to open a PR
    vertices_df = connected_components.toPandas()
    edges_df = graph.edges.toPandas()

    G = nx.from_pandas_edgelist(edges_df, "src", "dst")
    return (G,)


@app.cell
def _(G):
    import gravis as gv

    gv.d3(G, edge_size_data_source="weight", use_edge_size_normalization=True)
    return


if __name__ == "__main__":
    app.run()
