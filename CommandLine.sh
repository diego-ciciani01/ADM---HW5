#!/bin/bash

# Path to the CSV file for the citation graph
csv_path='citation_graph.csv'

# Python script to be executed
python_script=$(cat <<-END
import networkx as nx
import pandas as pd

# Load the CSV file and create the graph
dataframe = pd.read_csv('$csv_path')
graph = nx.from_pandas_edgelist(dataframe, 'Source', 'Target', create_using=nx.DiGraph())

# Calculate the betweenness centrality to find the node that connects different parts of the graph
centrality_scores = nx.betweenness_centrality(graph, normalized=True)
connector_node = max(centrality_scores, key=centrality_scores.get)

# Print the results 
print(f"The node that acts as a major 'connector' between different parts of the graph is: {connector_node}")
print(f"It has a betweenness centrality score of: {centrality_scores[connector_node]}\n")
END
)

# Save the Python script to a file
echo "$python_script" > temp_script.py

# Execute the Python script
python3 temp_script.py

# Clean up the temporary Python file
rm temp_script.py

# -2: How does the degree of citation vary among the graph nodes?

echo "Analyzing the degree of citation among the nodes in the graph"

echo "Statistics for in-degree (citations received):"
awk -F',' 'NR > 1 {count[$2]++} END {
    total = 0
    max = 0
    min = "inf"
    for (node in count) {
        total += count[node]
        if (count[node] > max) { max = count[node] }
        if (count[node] < min) { min = count[node] }
    }
    avg = total / length(count)
    print "Average: " avg ", Max: " max ", Min: " min
}' "$csv_path"

# Compute out-degree statistics
echo "Statistics for out-degree (citations made):"
awk -F',' 'NR > 1 {count[$1]++} END {
    total = 0
    max = 0
    min = "inf"
    for (node in count) {
        total += count[node]
        if (count[node] > max) { max = count[node] }
        if (count[node] < min) { min = count[node] }
    }
    avg = total / length(count)
    print "Average: " avg ", Max: " max ", Min: " min
}' "$csv_path"

# -3: What is the average length of the shortest path among nodes?

python_script_Q3=$(cat <<-END
import networkx as nx
import pandas as pd

# Load the CSV file and create the graph
dataframe = pd.read_csv('$csv_path')
graph = nx.from_pandas_edgelist(dataframe, 'Source', 'Target', create_using=nx.DiGraph())

# Calculate the average shortest path length for the whole graph
avg_path_length = nx.average_shortest_path_length(graph)

# Print the result
print(f"Average length of the shortest path among nodes: {avg_path_length}")
END
)

# Save the Python script for Q3 to a file
echo "$python_script_Q3" > temp_script_Q3.py

# Execute the Python script for Q3
python3 temp_script_Q3.py

# Clean up the temporary Python file for Q3
rm temp_script_Q3.py




