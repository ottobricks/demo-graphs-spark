import marimo

__generated_with = "0.18.0"
app = marimo.App(width="medium", css_file="../../.marimo-theme.css")


@app.cell(hide_code=True)
def _():
    import gravis as gv
    import networkx as nx
    from data import mock
    from graphframes import GraphFrame
    from main import get_spark_session
    return GraphFrame, get_spark_session, gv, mock, nx


@app.cell(hide_code=True)
def _(get_spark_session):
    spark = get_spark_session()
    spark
    return (spark,)


@app.cell
def _(mock, spark):
    vertices = mock.get_participants(spark)
    vertices
    return (vertices,)


@app.cell
def _(mock, spark):
    edges = mock.get_moneymovements(spark)
    edges
    return (edges,)


@app.cell
def _(GraphFrame, edges, vertices):
    graph = GraphFrame(v=vertices, e=edges)
    connected_components = graph.connectedComponents(
        useLabelsAsComponents=True, use_local_checkpoints=True, broadcastThreshold=-1
    )
    return connected_components, graph


@app.cell
def _(connected_components, graph, nx):
    # Yes, Pandas to plot. Know of a Spark native plotting lib? Feel free to open a PR
    vertices_df = connected_components.selectExpr(
        "*", "if(aml_flagged, 'red', 'lightblue') as color"
    ).toPandas()
    edges_df = graph.edges.toPandas()

    G = nx.from_pandas_edgelist(edges_df, "src", "dst")
    nx.set_node_attributes(G, vertices_df.set_index("id").to_dict("index"))
    nx.set_edge_attributes(G, edges_df.set_index(["src", "dst"]).to_dict("index"))
    return (G,)


@app.cell
def _(G, gv):
    gv.d3(
        G,
        edge_size_data_source="amount",
        use_edge_size_normalization=True,
        node_hover_neighborhood=True,
        node_hover_tooltip=True,
        node_label_data_source="name",
    )
    return


if __name__ == "__main__":
    app.run()
