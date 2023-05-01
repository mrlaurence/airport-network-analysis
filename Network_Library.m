classdef Network_Library

    % Static class containing useful methods written for investigation of the European
    % airport network, as discussed in the report 'The European Airport Network:
    % Quantifying Centrality and Directed Behaviour'.
    %
    % AUTHOR: Laurence Dhonau.

    methods(Static)

        function routeNetwork = Load_Route_Network(weighted, directed, normaliseWeights, ...
        includeAllComponents)

            % Forms and returns the European airport route network from the adjacency
            % matrix stored in 'Datasets/Route_Adjacency_Matrix.mat'.
            %
            % weighted (optional): Defaults to true. If false, returns an unweighted
            % (i.e. binary) network by ignoring weights in the loaded adjacency matrix.
            %
            % directed (optional): Defaults to true. If false, returns an undirected
            % network by modifying the loaded adjacency matrix to assume that all routes
            % are bidirectional.
            %
            % normaliseWeights (optional): Defaults to true. If false, returns a network
            % without weights normalised so the maximum weight is 1. Has no effect if
            % weighted is false.
            %
            % includeAllComponents (optional): Defaults to true. If false, includes only
            % the giant connected component in the returned network.
            %
            % Returns the European airport route network as a MATLAB graph/digraph object.

            switch nargin
                case 0
                    weighted = true;
                    directed = true;
                    normaliseWeights = true;
                    includeAllComponents = true;
                case 1
                    directed = true;
                    normaliseWeights = true;
                    includeAllComponents = true;
                case 2
                    normaliseWeights = true;
                    includeAllComponents = true;
                case 3
                    includeAllComponents = true;
                case 4
                otherwise
                    error("[ERROR] Invalid argument count for Load_Route_Graph.");
            end
        
            % Load the routeAdjacencyMatrix variable.
            load("Datasets/Route_Adjacency_Matrix.mat", "routeAdjacencyMatrix");
        
            if ~directed
                routeAdjacencyMatrix = routeAdjacencyMatrix + routeAdjacencyMatrix';
            end
        
            if ~weighted
                routeAdjacencyMatrix = double(routeAdjacencyMatrix > 0);
            end
        
            if normaliseWeights
                maxWeight = full(max(max(routeAdjacencyMatrix)));
                routeAdjacencyMatrix = routeAdjacencyMatrix / maxWeight;
            end
            
            % Retrieve a string array containing the IATA codes for all the airports for
            % which at least one European airline has at least one active flight route.
            iataStringArray = string(jsondecode(fileread("Raw_Datasets/Routes_IATA_Codes.json")))';
            
            if directed
                % Construct a directed graph from the adjacency matrix, labelling nodes by
                % their IATA codes.
                routeNetwork = digraph(routeAdjacencyMatrix, iataStringArray);
            else
                % Construct an undirected graph from the adjacency matrix, labelling nodes
                % by their IATA codes.
                routeNetwork = graph(routeAdjacencyMatrix, iataStringArray);
            end
        
            if ~includeAllComponents

                % Remove all (weakly) connected components from the network other than the
                % largest one.
                [bins, binInfo] = conncomp(routeNetwork,'Type','weak');
                largestComponentNodes = (binInfo(bins) == max(binInfo));
                routeNetwork = subgraph(routeNetwork, largestComponentNodes);
            end
        end

        function leaderboard = Node_Leaderboard(routeNetwork, nodeValues, descendingBool, ...
        metricName, leaderboardNodeCount, printLeaderboard)

            % Given a network and a value for each node in the network, sorts the nodes
            % according to their values and returns information on the top-ranking nodes
            % and (optionally) pretty prints the same information.
            %
            % routeNetwork: A MATLAB graph/digraph object whose N nodes we consider.
            % nodeValues: A column vector with N elements, associating a value with each
            % node in the network.
            % descendingBool (optional): Defaults to false. If true, ranks nodes in
            % descending order, rather than ascending.
            % metricName (optional): If specified, includes the name of the metric we sort
            % by in the pretty-printed leaderboard (e.g. 'Betweenness Centrality').
            % leaderboardNodeCount (optional): Defaults to 10. The number of top-ranking
            % nodes to return/output. In certain cases where nodes rank equally, more than
            % 10 nodes will be returned.
            % printLeaderboard (optional): Defaults to true. If false, does not
            % pretty-print information on the top-ranking nodes.
            %
            % Returns a cell array matrix where the rows represent nodes and the 3 columns
            % contain the node name (e.g. IATA code), node ID and node value (according to
            % nodeValues) respectively.

            switch nargin
                case 2
                    descendingBool = true;
                    leaderboardNodeCount = 10;
                    metricName = "?";
                    printLeaderboard = true;
                case 3
                    leaderboardNodeCount = 10;
                    metricName = "?";
                    printLeaderboard = true;
                case 4
                    leaderboardNodeCount = 10;
                    printLeaderboard = true;
                case 5
                    printLeaderboard = true;
                case 6
                otherwise
                    error("[ERROR] Invalid argument count for Node_Leaderboard.");
            end
        
            % Initalise a cell array to store the leaderboard.
            leaderboard = cell(leaderboardNodeCount, 3);
        
            if descendingBool
                sortedNodeValues = sort(nodeValues, "descend");
                if printLeaderboard
                    fprintf("\n--- Nodes by %s (%s): ---\n", metricName, "Descending");
                end
            else
                sortedNodeValues = sort(nodeValues, "ascend");
                if printLeaderboard
                    fprintf("--- Nodes by %s (%s): ---\n", metricName, "Ascending");
                end
            end
        
            % Initalise a counter to store the number of elements in the sorted node
            % values vector to skip over. Used in the case of nodes with tied values.
            skipCount = 0;
        
            for i = 1 : leaderboardNodeCount
        
                if skipCount ~= 0

                    % In this case, we have already outputted this node since it ties with
                    % a previous node for its value.
                    skipCount = skipCount - 1;
                    continue;
                end
        
                % Find all nodes with the value in the sorted vector.
                nodeIDVec = find(nodeValues == sortedNodeValues(i));
        
                % If there is more than one node with this value, skip some of the
                % following nodes to prevent duplicate outputs.
                if length(nodeIDVec) ~= 1
                    skipCount = max(size(nodeIDVec)) - 1;
                end
        
                % Output details on each of the nodes with the value in the sorted vector
                % and add the details to the leaderboard cell array, making clear in the
                % output that the nodes tie (if there are indeed multiple).
                for j = 1 : max(size(nodeIDVec))
                    nodeID = nodeIDVec(j);
                    nodeName = string(table2array(routeNetwork.Nodes(nodeID, :)));
        
                    if printLeaderboard
                        fprintf("#%d: Airport %s (node ID %d) | %s: %.3g\n", i, nodeName, ...
                        nodeID, metricName, sortedNodeValues(i));
                    end
        
                    leaderboard(i + j - 1, :) = {nodeName, nodeID, sortedNodeValues(i)};
                end
            end
        end

        function triangleCounts = Triangle_Counter(routeNetwork, nodeIDs, motif, ...
        returnFraction, weightedVersion, divideByTrianglesPresent)

        % Computes local clustering coefficients for (or counts the number of) different
        % types of triangle motifs in a directed network, as discussed in the following
        % article:
        %
        % Fagiolo, Giorgio. (2007). Clustering in Complex Directed Networks.
        % Physical review. E, Statistical, nonlinear, and soft matter physics.
        % 76. 026107. 10.1103/PhysRevE.76.026107.
        %
        % routeNetwork: A MATLAB graph/digraph object whose N nodes we consider.
        % nodeIDs (optional): A vector containing node IDs to count triangles/compute
        % clustering coefficients for. Defaults to all nodes.
        % motif (optional): One of "all", "cycle", "middleman", "in", "out". Specifies the
        % type of directed triangle motif to count/compute clustering coefficient for. See
        % the referenced article for details.
        % returnFraction (optional): Defaults to true. If false, returns raw triangle
        % motif counts, rather than local clustering coefficients.
        % weightedVersion (optional): Defaults to false. If true, considers the passed
        % network as weighted and uses the weighted version of the local clustering
        % coefficient, valuing links with larger weights more highly than ones with
        % smaller weights for the clustering coefficient. The maximum weight must be 1.
        % divideByTrianglesPresent (optional): Defaults to false. If true, compute the
        % 'clustering coefficient' by dividing by the total number of triangles present
        % (of any of the 4 motif types), rather than the total number theoretically
        % possible (for just 1 motif type, unless the motif is "all").
        %
        % Returns a dictionary where the keys are the elements of nodeIDs and the values
        % are the computed clustering coefficients/triangle counts for each node. If
        % returnFraction is false and no triangles are possible/present for a node
        % (divideByTrianglesPresent = false/true respectively), the node clustering
        % coefficient is returned as 0.
        
            switch nargin
                case 1
                    nodeIDs = 1 : numnodes(routeNetwork);
                    motif = "all";
                    returnFraction = true;
                    weightedVersion = false;
                    divideByTrianglesPresent = false;
                case 2
                    motif = "all";
                    returnFraction = true;
                    weightedVersion = false;
                    divideByTrianglesPresent = false;
                case 3
                    returnFraction = true;
                    weightedVersion = false;
                   divideByTrianglesPresent = false;
                case 4
                    weightedVersion = false;
                    divideByTrianglesPresent = false;
                case 5
                    divideByTrianglesPresent = false;
                case 6
                otherwise
                    error("[ERROR] Invalid argument count for Triangle_Counter.");
            end
        
            % Initalise a dictionary which will have keys as node IDs and values as
            % clustering coefficients/triangle counts.
            triangleCounts = dictionary;
        
            if weightedVersion

                % Set the `adjacency matrix' to the element-wise cube root of the weights
                % matrix. This matrix will be substituted for the adjacency matrix in the
                % expression to compute the clustering coefficient, which is equivalent to
                % the weighted version of the same clustering coefficient.
                adjMatrix = (adjacency(routeNetwork, "weighted")).^(1/3);
            else

                % Retrieve the adjacency matrix of the passed network.
                adjMatrix = adjacency(routeNetwork);
            end
        
            % Compute the number of triangles of the requested motif type for each node in
            % the network.
            switch motif
                case "cycle"
                    triangleCountVec = diag(adjMatrix ^ 3);
                case "middleman"
                    triangleCountVec = diag(adjMatrix * adjMatrix' * adjMatrix);
                case "in"
                    triangleCountVec = diag(adjMatrix' * adjMatrix ^ 2);
                case "out"
                    triangleCountVec = diag(adjMatrix ^ 2 * adjMatrix');
                case "all"
                    triangleCountVec = diag((adjMatrix + adjMatrix') ^ 3) / 2;
                otherwise
                    error("[ERROR] Invalid motif type for Triangle_Counter.");
            end
        
            % Add the triangle counts for the node IDs of interest to the triangleCounts
            % dictionary, discarding other counts.
            triangleCounts(nodeIDs) = full(triangleCountVec(nodeIDs)');
        
            if ~returnFraction

                % Return the raw triangle counts, rather than the clustering coefficients.
                return
            end
        
            if divideByTrianglesPresent

                % Compute the total number of triangles (of any motif) for each node.
                totalTriangleCountVec = diag((adjMatrix + adjMatrix') ^ 3) / 2;

                % For each node, divide the number of triangles of the specified motif type
                % by the number of triangles of any motif type.
                triangleCounts(nodeIDs) = triangleCounts(nodeIDs) ./ ...
                totalTriangleCountVec(nodeIDs)';
            else

                % If the modified weight matrix was used earlier, restore the true
                % adjacency matrix since this is required to count the total possible
                % nunber of triangles.
                adjMatrix = adjacency(routeNetwork);
            
                % Compute a vector containing, for each node, the number of predecessors
                % to that node which are also successors to that node.
                bilateralEdgeCountVec = diag(adjMatrix ^ 2);
            
                % Iterate over the requested node IDs.
                for i = 1 : length(nodeIDs)
                    nodeID = nodeIDs(i);
            
                    % Retrieve the in-degree, out-degree and number of bilateral links for
                    % this node.
                    nodeInDegree = indegree(routeNetwork, nodeID);
                    nodeOutDegree = outdegree(routeNetwork, nodeID);
                    nodeBilateralEdgeCount = full(bilateralEdgeCountVec(nodeID));
                
                    % Compute the total possible number of triangles of the requested
                    % motif type that could occur, given the node's in-degree, out-degree
                    % and bilateral link count.
                    switch motif
                        case "cycle"
                            totalPossibleTriangles = nodeInDegree * nodeOutDegree - ...
                            nodeBilateralEdgeCount;
                        case "middleman"
                            totalPossibleTriangles = nodeInDegree * nodeOutDegree - ...
                            nodeBilateralEdgeCount;
                        case "in"
                            totalPossibleTriangles = nodeInDegree * (nodeInDegree - 1);
                        case "out"
                            totalPossibleTriangles = nodeOutDegree * (nodeOutDegree - 1);
                        case "all"
                            totalDegree = nodeInDegree + nodeOutDegree;
                            totalPossibleTriangles = totalDegree * (totalDegree - 1) - ...
                            2 * nodeBilateralEdgeCount;
                    end
                
                    % For each node, divide the number of triangles of the specified motif
                    % type by the number of possible triangles of that motif type.
                    triangleCounts(nodeID) = triangleCounts(nodeID) / totalPossibleTriangles;
                end
            end
        
            % Replace NaN values with -1 in the values vector of triangleCounts
            % (reflecting the case where no triangles are possible/present so division by
            % 0 occurred).
            triangleCounts(nodeIDs(isnan(triangleCounts.values))) = 0;
        end

        function configurationGraph = Configuration_Model(inDegreeDistribution, outDegreeDistribution, silentBool)

            % Generates a random directed unweighted graph with (approximately) the same joint
            % degree distribution as the joint distribution for an emperical network with given
            % in/out-degree distributions.
            %
            % inDegreeDistribution: A column vector with elements specifying the in-degree of
            % each of the N nodes in an emperical network.
            % outDegreeDistribution: A column vector with elements specifying the out-degree of
            % each of the N nodes in an emperical network.
            % silentBool (optional): Defaults to false. If true, suppresses output in
            % console (except for critical errors).
            %
            % Returns the random directed unweighted graph generated (according to the
            % configuration model method). We do not allow the generated graph to contain
            % self-edges or double edges so the in/out-degree distributions may not match draws
            % from the joint distribution exactly (a warning is outputted when an edge is
            % skipped in order to prevent drawing a self-edge or double edge).
        
            % Validate that the number of elements in the in/out-degree vectors are the same.
            if max(size(inDegreeDistribution)) ~= max(size(outDegreeDistribution))
                error("[ERROR] Number of nodes differs between in/out-degree distributions.");
            end
        
            % Validate that the sum of the in/out-degree vectors are the same (so we can connect
            % each out-link to an in-link).
            if sum(inDegreeDistribution) ~= sum(outDegreeDistribution)
                error("[ERROR] Error with requested in/out-degree distributions. " + ...
                "Sum of in-degrees must equal sum of out-degrees.");
            end
        
            % Merge the in/out-degree distributions into a two-column matrix.
            empericalDistribution = [inDegreeDistribution, outDegreeDistribution];
        
            % Find the maximum in/out-degree in the emperical network.
            maxDegree = max(max(empericalDistribution));
        
            nodeCount = size(empericalDistribution, 1);
        
            % Initalise a matrix to store the joint degree distribution of the emperical network.
            % The (i,j)th element of this matrix will give the probability that a node has
            % in-degree i-1 and out-degree j-1.
            jointDistribution = zeros(maxDegree + 1, maxDegree + 1);
        
            % Iterate over the nodes in the emperical network.
            for i = 1 : nodeCount
        
                % Find the in/out-degree of this node and increment the corresponding element in
                % the joint distribution matrix.
                degreeRow = empericalDistribution(i, :);
                inDegree = degreeRow(1);
                outDegree = degreeRow(2);
                jointDistribution(inDegree + 1, outDegree + 1) =  jointDistribution(inDegree + 1, ...
                outDegree + 1) + 1;
            end
        
            % Normalise the joint distribution matrix.
            jointDistribution = jointDistribution / sum(sum(jointDistribution));
        
            % Initialise an empty matrix of size N * 2 to store the in/out degree distribution of
            % the random graph.
            generatedDistribution = zeros(size(empericalDistribution));
        
            % Iterate over the nodes in the random network.
            for i = 1 : nodeCount
        
                % Draw the in-degree and out-degree for this node from the joint degree
                % probability distribution calculated for the emperical network.
                [inDegree, outDegree] = pinky(0:maxDegree, 0:maxDegree, jointDistribution);
        
                % Add the drawn degrees to the generated distribution matrix.
                generatedDistribution(i, :) = [inDegree, outDegree];
            end
        
            % While the sum of the generated in/out-degree vectors are not the same (i.e. we do
            % not have a valid network).
            while sum(generatedDistribution(:, 1)) ~= sum(generatedDistribution(:, 2))
        
                % Pick a random node.
                nodeID = ceil(rand * nodeCount);
        
                % Re-generate the degrees for this node and update the matrix.
                [inDegree, outDegree] = pinky(0:maxDegree, 0:maxDegree, jointDistribution);
                generatedDistribution(nodeID, :) = [inDegree, outDegree];
            end
        
            % Initialise an empty adjacency matrix for the random network.
            adjacencyMatrix = zeros(nodeCount, nodeCount);
        
            % Initialise a counter for the number of links skipped to prevent drawing a self-edge
            % or double edge.
            linkSkipCount = 0;
        
            % Iterate over the nodes in the random network.
            for i = 1 : nodeCount
        
                % Retrieve the out-degree of this node.
                outStubCount = generatedDistribution(i,2);
        
                % While this node still has an unconnected out-link.
                while outStubCount > 0
        
                    % Retrieve the total number of unconnected in-links.
                    inStubCount = sum(generatedDistribution(:,1));
        
                    % Initalise a counter for the number of attempts taken to connect an out-link
                    % of this node to an in-link of a different node *to which this node is not
                    % already connected*.
                    connectionAttemptCount = 0;
        
                    % Keep trying to connect an out-link of this node until the node is not
                    % connected to itself (self-edge) and not connected to a node to which it is
                    % already connected (double edge), up to a maximum of 100 attempts.
                    while (connectionAttemptCount == 0 || j == i || adjacencyMatrix(i, j) ~= 0) && ...
                    connectionAttemptCount < 100
        
                        % Increment the attempt counter.
                        connectionAttemptCount = connectionAttemptCount + 1;
        
                        % Draw a random in-stub number.
                        stubID = ceil(rand * inStubCount);
            
                        % Assuming in-stubs are indexed sequentially and node-by-node (e.g. node 1
                        % may have in-stubs 1,2,3, node 2 may have in-stub 4, node 3 may have
                        % in-stub 5, 6, 7, 8, 9, 10, etc.), find the node ID to which the drawn
                        % in-stub number belongs.
                        j = find((stubID - cumsum(generatedDistribution(:,1))) <= 0, 1);
                    end
        
                    if j == i || adjacencyMatrix(i, j) ~= 0
                        if ~silentBool
                            fprintf("[WARN] Could not connect an out-stub of node %d to an in-stub" + ...
                            " without creating a self-edge or double-edge. Skipping...\n", i);
                        end
                        linkSkipCount = linkSkipCount + 1;
                    else
        
                        % Draw a link from node i to node j.
                        adjacencyMatrix(i, j) = 1;
                    end
        
                    % Decrement the number of unconnected in-links for node j by 1.
                    generatedDistribution(j, 1) = generatedDistribution(j, 1) - 1;
        
                    % Decrement the number of unconnected out-links for this node by 1. 
                    outStubCount = outStubCount - 1;
                end
            end
        
            if ~silentBool
                fprintf("[INFO] Drawn link count: %d. Skipped link count: %d.\n", ...
                sum(generatedDistribution(:,2)) - linkSkipCount, linkSkipCount);
            end
        
            % Return the random directed unweighted graph specified by the generated adjacency
            % matrix.
            configurationGraph = digraph(adjacencyMatrix);
        end
    end
end