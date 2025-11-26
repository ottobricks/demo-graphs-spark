from pyspark.sql import DataFrame, SparkSession


def get_participants(spark: SparkSession) -> DataFrame:
    # Create vertices DataFrame
    vertices_data = [
        # Cluster 1
        ("v1", "Alice", "USA", False),
        ("v2", "Bob", "UK", True),
        ("v3", "Carol", "USA", False),
        ("v4", "David", "Canada", False),
        # Cluster 2
        ("v5", "Eve", "Germany", False),
        ("v6", "Frank", "France", True),
        ("v7", "Grace", "Spain", False),
        ("v8", "Henry", "Italy", False),
        # Cluster 3 (disjoint)
        ("v9", "Iris", "Japan", False),
        ("v10", "Jack", "China", True),
        ("v11", "Kate", "Korea", False),
    ]

    return spark.createDataFrame(
        vertices_data, ["id", "name", "country_of_residence", "aml_flagged"]
    )


def get_moneymovements(spark: SparkSession) -> DataFrame:
    # Create edges DataFrame
    edges_data = [
        # Cluster 1 edges (well-connected)
        ("e1", "v1", "v2", 1500.0),
        ("e2", "v2", "v3", 2300.0),
        ("e3", "v3", "v4", 800.0),
        ("e4", "v4", "v1", 1200.0),
        ("e5", "v1", "v3", 3000.0),
        # Cluster 2 edges (well-connected)
        ("e6", "v5", "v6", 1800.0),
        ("e7", "v6", "v7", 2100.0),
        ("e8", "v7", "v8", 900.0),
        ("e9", "v8", "v5", 1600.0),
        ("e10", "v5", "v7", 2500.0),
        # Weak connections between Cluster 1 and 2
        ("e11", "v3", "v6", 500.0),
        ("e12", "v4", "v5", 750.0),
        # Cluster 3 edges (disjoint)
        ("e13", "v9", "v10", 1100.0),
        ("e14", "v10", "v11", 1900.0),
        ("e15", "v11", "v9", 1400.0),
    ]

    return spark.createDataFrame(edges_data, ["id", "src", "dst", "amount"]).selectExpr(
        "id", "src", "dst", "cast(amount as float) as amount"
    )
