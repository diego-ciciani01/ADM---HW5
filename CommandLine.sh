#!/bin/bash

# Path to the CSV file for the citation graph
csv_path='citation_graph.csv'

# Python script to be executed
python_script=$(cat <<-END
import networkx as nx
import pandas as pd

# Load the CSV file and create the graph
dataframe = pd.read_csv('citation_graph.csv')
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

# Compute the in-degree and out-degree for each node to understand their distribution in the graph
# We will calculate the average, maximum, and minimum for both in-degrees and out-degrees
# awk is used here, -F , sets the field separator to a comma, NR > 1 tells awk to skip the first line of the file which is the header in a csv file
# then {count[$2]++} for each line (after the header) increment a counter for the value in the second column ($2), it is this command that counts the in-degrees
# then the code to sum all in degree initializes a variable total to 0 and a variable max to 0 that will keep track of the maximum in-degree and
# initializes min to inf (infinity). Now starts a loop over all nodes in the count array that adds the in-degree of the current node to the total, 
# checks if the current node in-degree is greater than the current max: if so, it updates max, checks if the current node's in-degree is less than the current min:
# if so, it updates min, then calculates the average in-degree and prints out the calculated average, maximum, and minimum in-degrees.

# The same structure is applied to perform the out-degree statistics

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

# Calculating the average shortest path length for each strongly connected component separately, in this way each component is treated as an isolated graph
# at the end the stats about the average langht are reported giving insight into the internal structure of the connected portions of graph
python_script=$(cat <<-END

import networkx as nx
import pandas as pd

# Load the CSV file and create the graph
dataframe = pd.read_csv('citation_graph.csv')
graph = nx.from_pandas_edgelist(dataframe, 'Source', 'Target', create_using=nx.DiGraph())


# Function to calculate average shortest path length for each subgraph
def avg_shortest_path_length(subgraph, graph):
    # consider only subgraphs with at least 2 nodes otherwise it is not meaningful to talk about paths
    if len(subgraph) > 1:
        subgraph = graph.subgraph(subgraph)
        return nx.average_shortest_path_length(subgraph)
    # base case of a single node subgraphs
    else:
        return 0

# Calculate the average shortest path length for each strongly connected subgraph (scs)
scs_avg_path_lengths = [avg_shortest_path_length(s, citation_graph) for s in nx.strongly_connected_components(citation_graph)]
scs_avg_path_lengths = [length for length in scs_avg_path_lengths if length > 0]

# Statistics about length
average_of_averages = sum(scs_avg_path_lengths)/len(scs_avg_path_lengths) if scs_avg_path_lengths else 0
max_average_length = max(scs_avg_path_lengths, default=0)
min_average_length = min(scs_avg_path_lengths, default=0)

# Print the results
print(f"\nAnalyzing the average length of the shortest path among nodes")
print(f"Average of averages: {average_of_averages}")
print(f"Max average path length: {max_average_length}")
print(f"Min average path length: {min_average_length}")
print(f"Number of subgraphs with paths: {len(scs_avg_path_lengths)}")
END
)

# Execute the python script
python3 -c "$python_script"






