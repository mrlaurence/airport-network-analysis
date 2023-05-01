%% SECTION: FIGURE CONFIGURATION / NETWORK RETRIEVAL

% Configure the MATLAB environment to make figures much more readable than the defaults.
close all;
set(groot,"defaultLineLineWidth", 3);
set(groot,"defaultAxesFontSize", 17);
set(groot,"defaultTextFontSize", 16);
set(groot, "defaultAxesColorOrder", [0.1333, 0.5451, 0.1333; ...
0.6350 0.0780 0.1840; 0.0000 0.4470 0.7410; 0.9290 0.6940 0.1250; ...
0.4940 0.1840 0.5560; 0.3010 0.7450 0.9330]);
set(groot, "defaultFigurePosition", [50, 100, 730, 550]);
set(groot,'defaultAxesXGrid','on');
set(groot,'defaultAxesYGrid','on');
set(groot,'defaultAxesXMinorGrid','on','defaultAxesXMinorGridMode','manual');
set(groot,'defaultAxesYMinorGrid','on','defaultAxesYMinorGridMode','manual');

% Load the European airport route network as a digraph MATLAB object, with normalised
% route weights and IATA codes as node names.
routeNetwork = Network_Library.Load_Route_Network;

%% SECTION: DEGREE DISTRIBUTIONS AND LEADERBOARDS

% Compute the max/min in/out-degree for the network.
maxInDegree = max(indegree(routeNetwork));
minInDegree = min(indegree(routeNetwork));
maxOutDegree = max(outdegree(routeNetwork));
minOutDegree = min(outdegree(routeNetwork));

% Find the cumulative in/out-degree (frequency) distributions. The ith element of this vector
% gives the number of nodes with in/out-degree >= i - 1.
cumInDegreeDistribution = numnodes(routeNetwork) - [0 cumsum(histcounts(indegree(routeNetwork), ...
0:maxInDegree + 1))];
cumOutDegreeDistribution = numnodes(routeNetwork) - [0 cumsum(histcounts(outdegree(routeNetwork), ...
0:maxOutDegree + 1))];

% Convert the distributions to probability ones.
probCumInDegreeDistribution = cumInDegreeDistribution / numnodes(routeNetwork);
probCumOutDegreeDistribution = cumOutDegreeDistribution / numnodes(routeNetwork);

% Retrieve (and pretty print) details on the 10 nodes with highest in/out-degree.
inDegreeLeaderboard = Network_Library.Node_Leaderboard(routeNetwork, indegree(routeNetwork), ...
true, "In-Degree");
outDegreeLeaderboard = Network_Library.Node_Leaderboard(routeNetwork, outdegree(routeNetwork), ...
true, "Out-Degree");

% Plot both in/out-degree distributions on a log-log scale.
figure;
hold on;
set(gca, 'XScale', 'log', 'YScale', 'log');
plot(0: maxInDegree + 1, probCumInDegreeDistribution);
plot(0: maxOutDegree + 1, probCumOutDegreeDistribution);
xlim([0 300]);

% Add markers to the plot showing the 10 airports with highest in-degrees.
%for i = 1 : size(inDegreeLeaderboard, 1)
    %degree = cell2mat(inDegreeLeaderboard(i, 3));
    %scatter(degree, probCumInDegreeDistribution(degree + 1), 55, [0.0000 0.4470 0.7410], "filled");

    % if i <= 2
    %     text(degree + 3, probCumInDegreeDistribution(degree + 1) + .04, string(inDegreeLeaderboard(i, 1)));
    % elseif 3 <= i && i <= 4
    %     text(degree - 21, probCumInDegreeDistribution(degree + 1) + .04, string(inDegreeLeaderboard(i, 1)));
    % end
%end

% Add a legend and axis labels.
legend(["In-degree", "Out-degree"]);
xlabel("Node degree k");
ylabel("Fraction of nodes with degree ≥ k");

% Add a subplot to the previous plot which 'zooms in' on a region of the degree
% distribution curves, with the degree range of the zoomed plot given by the following
% variable.
subplotDegrees = 100 : 140;
axes('position', [.235 .21 .35 .35]);
box on;
hold on;
set(gca, 'XScale', 'log', 'YScale', 'log');
axis tight;
plot(subplotDegrees, probCumInDegreeDistribution(subplotDegrees));
plot(subplotDegrees, probCumOutDegreeDistribution(subplotDegrees));

% Create a new figure and produce a scatter plot of node out-degree against in-degree.
% Also plot the 'y = x' (in-degree = out-degree) line.
figure;
hold on;
scatter(indegree(routeNetwork), outdegree(routeNetwork), 40, 'filled');
plot(0:max(maxInDegree, maxOutDegree), 0:max(maxInDegree, maxOutDegree));
xlim([0 max(maxInDegree, maxOutDegree)]);
ylim([0 max(maxInDegree, maxOutDegree)]);

% Add a legend and axis labels.
legend(["Node degree", "In-degree = out-degree"]);
xlabel("In-degree");
ylabel("Out-degree");

% Add a subplot to the previous plot which 'zooms in' on a region of the scatter plot,
% with the in/out-degree range of the zoomed plot being the closed interval between 0 and
% the number in the following variable.
maxSubplotDegree = 20;
axes('position', [.6 .185 .285 .285]);
box on;
hold on;
axis tight;
degreeMatrix = [indegree(routeNetwork) outdegree(routeNetwork)];
inDegreesInRange = find(degreeMatrix(:,1) <= maxSubplotDegree);
outDegreesInRange = find(degreeMatrix(:,2) <= maxSubplotDegree);
degreeMatrix = degreeMatrix(intersect(inDegreesInRange, outDegreesInRange), :);
scatter(degreeMatrix(:,1), degreeMatrix(:,2), 40, 'filled');
plot(0:maxSubplotDegree, 0:maxSubplotDegree);

%% SECTION: NETWORK CENTRALITY / VISUALISATION

% Retrieve (and pretty print) details on the 10 nodes with highest betweenness
% centrality/in-closeness centrality/hub centrality.
betweennessCentralityLeaderboard = Network_Library.Node_Leaderboard(routeNetwork, ...
centrality(routeNetwork, "betweenness"), true, "Betweenness Centrality");
inClosenessCentralityLeaderboard = Network_Library.Node_Leaderboard(routeNetwork, ...
centrality(routeNetwork, "incloseness"), true, "In-Closeness Centrality");
hubCentralityLeaderboard = Network_Library.Node_Leaderboard(routeNetwork, ...
centrality(routeNetwork, "hub"), true, "Hub Centrality");

% Create a new figure and use a force-directed layout to plot the airport route network.
figure;
networkFig = plot(routeNetwork, "layout", "force");

% Tweak the node marker size and link plot colour.
networkFig.MarkerSize = 3.5;
networkFig.EdgeColor = [0.75, 0.75, 0.75];

% Colour nodes by their hub centrality and add a colour bar to function as a scale for hub
% centrality.
colormap turbo;
networkColorbar = colorbar;
networkFig.NodeCData = centrality(routeNetwork, "hub");

% Label the color bar and adjust the figure 'zoom' to prevent displaying empty space
% around the network.
ylabel(networkColorbar, "Hub centrality");
xlim([1 30]);
ylim([1 24.5]);

%% SECTION: SHORTEST PATHS

% Load an *unweighted* subgraph containing only the giant component of the route network.
giantComponentNetwork = Network_Library.Load_Route_Network(false, true, false, false);

% Compute the shortest path length between each pair of nodes in the giant component.
giantComponentDistances = distances(giantComponentNetwork);

noPathCount = length(find(isinf(giantComponentDistances)));

% Output the number of node pairs between which there is no path in the giant component
% and the average shortest path length (where there is a path).
fprintf("\n-------- Shortest Paths: --------\n");
fprintf("- Number of node pairs between which no path exists: %d (%.2f%% of total).\n", ...
noPathCount, 100 * noPathCount / numnodes(giantComponentNetwork) ^ 2);
fprintf("- Average shortest path length (where a path exists): %.2f hops.\n", sum(giantComponentDistances(~isinf ...
(giantComponentDistances))) / (numnodes(giantComponentNetwork) * ...
(numnodes(giantComponentNetwork) - 1) - noPathCount));

%% SECTION: CLUSTERING COEFFICIENTS AND MOTIF ANALYSIS

% Compute the local clustering coefficient (counting triangles of any motif type) for each
% node in the network.
localClusteringCoefficients = Network_Library.Triangle_Counter(routeNetwork);

% Compute the network average local clustering coefficient.
averageClusteringCoefficient = sum(localClusteringCoefficients.values) / ...
numnodes(routeNetwork);

% Compute the fraction of triangles which are of a particular motif
% type (cycle, middleman, in, out) for each node in the network.
motifDistribution = zeros(4, numnodes(routeNetwork));
motifDistribution(1, :) = values(Network_Library.Triangle_Counter(routeNetwork, ...
1: numnodes(routeNetwork), "cycle", true, false, true));
motifDistribution(2, :) = values(Network_Library.Triangle_Counter(routeNetwork, ...
1: numnodes(routeNetwork), "middleman", true, false, true));
motifDistribution(3, :) = values(Network_Library.Triangle_Counter(routeNetwork, ...
1: numnodes(routeNetwork), "in", true, false, true));
motifDistribution(4, :) = values(Network_Library.Triangle_Counter(routeNetwork, ...
1: numnodes(routeNetwork), "out", true, false, true));

% Output the network-wide coefficient.
fprintf("\n-------- Clustering Coefficients: --------\n");
fprintf("- Network-average local clustering coefficient: %.3f.\n", averageClusteringCoefficient);

% Output the fraction of triangles which are of each motif type, averaged across nodes
% with at least one triangle.
cleanMotifDistribution = motifDistribution(:, sum(motifDistribution) ~= 0);
cleanNodeCount = size(cleanMotifDistribution, 2);
fprintf("\n---------- Motif Analysis: ----------\n");
fprintf("- Network-average local cycle fraction: %.3f.\n", sum(cleanMotifDistribution(1, :)) / cleanNodeCount);
fprintf("- Network-average local middleman fraction: %.3f.\n", sum(cleanMotifDistribution(2, :)) / cleanNodeCount);
fprintf("- Network-average local in fraction: %.3f.\n", sum(cleanMotifDistribution(3, :)) / cleanNodeCount);
fprintf("- Network-average local out fraction: %.3f.\n", sum(cleanMotifDistribution(4, :)) / cleanNodeCount);

fprintf("\n[INFO] Computing clustering coefficients for configuration model sample." + ...
" This may take a while.\n");

% Produce a histogram showing the distribution of the fraction of the triangles which are
% cycles/middleman/in/out in the route network.
%figure;
%hold on;
%histogram(motifDistribution(1, :), 200, "Normalization", "probability", "FaceAlpha", 0.4);
%histogram(motifDistribution(2, :), 200, "Normalization", "probability", "FaceAlpha", 0.4);
%histogram(motifDistribution(3, :), 200, "Normalization", "probability", "FaceAlpha", 0.4);
%histogram(motifDistribution(4, :), 200, "Normalization", "probability", "FaceAlpha", 0.4);

% Initalise a vector to store the average local clustering coefficients for 1000 random
% networks.
configAverageClusteringCoefficientVec = zeros(1, 1);

% Initalise a vector to store the average shortest path lengths for 1000 random networks.
configAverageShortestPathLengthVec = zeros(1, 1);

% Initalise a matrix to store the fraction of triangles which are of a particular motif
% type (cycle, middleman, in, out), averaged across nodes, in each of the 1000 random
% networks.
averageConfigMotifDistribution = zeros(4, 1);

for i = 1 : 1
    if floor(i / 10) == i / 10
        fprintf("[INFO] Progress: %d%%\n", i/10);
    end

    % Generated an instance of the directed configuration model with the same joint
    % in/out-degree distribution as the route network.
    configNetwork = Network_Library.Configuration_Model(indegree(routeNetwork), ...
    outdegree(routeNetwork), true);

    % Compute the average local clustering coefficient for the configuration model,
    % as for the route network.
    configLocalClusteringCoefficients = Network_Library.Triangle_Counter(configNetwork);
    configAverageClusteringCoefficientVec(i) = sum(configLocalClusteringCoefficients.values) / ...
    numnodes(configNetwork);

    % Compute the fraction of triangles of a particular motif for each node in the random
    % network.
    configMotifDistribution = zeros(4, numnodes(routeNetwork));
    configMotifDistribution(1, :) = values(Network_Library.Triangle_Counter(configNetwork, ...
    1: numnodes(routeNetwork), "cycle", true, false, true));
    configMotifDistribution(2, :) = values(Network_Library.Triangle_Counter(configNetwork, ...
    1: numnodes(routeNetwork), "middleman", true, false, true));
    configMotifDistribution(3, :) = values(Network_Library.Triangle_Counter(configNetwork, ...
    1: numnodes(routeNetwork), "in", true, false, true));
    configMotifDistribution(4, :) = values(Network_Library.Triangle_Counter(configNetwork, ...
    1: numnodes(routeNetwork), "out", true, false, true));

    cleanConfigMotifDistribution = configMotifDistribution(:, sum(configMotifDistribution) ~= 0);
    cleanNodeCount = size(cleanConfigMotifDistribution, 2);

    averageConfigMotifDistribution(:, i) = sum(cleanConfigMotifDistribution, 2) / cleanNodeCount;

    % Get the giant connected component of the random network as a subgraph.
    [bins, binInfo] = conncomp(configNetwork,'Type','weak');
    largestComponentNodes = (binInfo(bins) == max(binInfo));
    configNetworkGiantComponent = subgraph(configNetwork, largestComponentNodes);

    % Compute the shortest path length between each pair of nodes in the giant component.
    configGiantComponentDistances = distances(configNetworkGiantComponent);
    
    configNoPathCount = length(find(isinf(configGiantComponentDistances)));

    % Compute the average shortest path length for the giant component in the random
    % network.
    configAverageShortestPathLengthVec(i) = sum(configGiantComponentDistances(~isinf ...
    (configGiantComponentDistances))) / (numnodes(configNetworkGiantComponent) * ...
    (numnodes(configNetworkGiantComponent) - 1) - configNoPathCount);
end

% Produce histograms for the local average clustering coefficient and average shortest
% path length distributions for the configuration model sample.
figure;
histogram(configAverageClusteringCoefficientVec, 34);
xlabel("Network-average local clustering coefficient");
ylabel("Sample frequency");

figure;
histogram(configAverageShortestPathLengthVec, 34);
xlabel("Average shortest path length");
ylabel("Sample frequency");

% Produce histograms for the fraction of triangles which are cycles/middleman/in/out,
% averaged across nodes, for the configuration model sample.
figure;
histogram(averageConfigMotifDistribution(1,:), 34, "FaceColor", [0.1333, 0.5451, 0.1333]);
xlabel("Fraction of triangles which are 'cycles'");
ylabel("Sample frequency");

figure;
histogram(averageConfigMotifDistribution(2,:), 34, "FaceColor", [0.6350 0.0780 0.1840]);
xlabel("Fraction of triangles which are 'middleman'");
ylabel("Sample frequency");

figure;
histogram(averageConfigMotifDistribution(3,:), 34, "FaceColor", [0.0000 0.4470 0.7410]);
xlabel("Fraction of triangles which are 'in'");
ylabel("Sample frequency");

figure;
histogram(averageConfigMotifDistribution(4,:), 34, "FaceColor", [0.9290 0.6940 0.1250]);
xlabel("Fraction of triangles which are 'out'");
ylabel("Sample frequency");

%% SECTION: GRAPH PARTITIONING AND COMMUNITY ANALYSIS

% Load an undirected version of the route network which includes only the giant component.
undirectedRouteNetwork = Network_Library.Load_Route_Network(true, false, true, false);

% Define the number of partitions to split the network into.
numOfPartitions = 6;

% Create a partition of the undirected airport network of the requested size using a
% general spectral partitioning method, storing a vector specifying the index of the
% partition which each node in the network belongs to and the cost (i.e. cut size)
% associated with the partition.
[partitionIndices, ~, partitionCost] = grPartition(adjacency(undirectedRouteNetwork), ...
numOfPartitions, 30);

nodeIDs = 1 : numnodes(undirectedRouteNetwork);

% Create a new figure and use a force-directed layout to plot the airport route network.
figure;
communityNetworkFig = plot(undirectedRouteNetwork, "Layout", "force");

% Tweak the node marker size and link plot colour.
communityNetworkFig.MarkerSize = 4;
communityNetworkFig.EdgeColor = [0.75, 0.75, 0.75];

% Colour the nodes according to the partition they belong to.
colours = [0.1333, 0.5451, 0.1333; ...
0.6350 0.0780 0.1840; 0.0000 0.4470 0.7410; 0.9290 0.6940 0.1250; ...
0.4940 0.1840 0.5560; 0.3010 0.7450 0.9330];

for i = 1 : numOfPartitions
    highlight(communityNetworkFig, nodeIDs(find(partitionIndices == i)), ...
    "NodeColor", colours(i,:));
end

% Add a legend linking communities and colours.
hold on;
set(gca,'ColorOrderIndex',1);
qw{1} = scatter(nan, nan, "filled");
qw{2} = scatter(nan, nan, "filled");
qw{3} = scatter(nan, nan, "filled");
qw{4} = scatter(nan, nan, "filled");
qw{5} = scatter(nan, nan, "filled");
qw{6} = scatter(nan, nan, "filled");
legend([qw{:}], 'Community 1', 'Community 2', 'Community 3', 'Community 4', ...
'Community 5', 'Community 6');

xlim([-7.8,6.6]);
ylim([-6, 7.3]);

%% SECTION: CONTINENT HIGHLIGHTING

numOfContinents = 6;
continentBaseNames = ["africa", "asia", "europe", "north_america", "oceania", "south_america"];

% Load a dictionary where the keys are IATA codes and the values are continents (i.e. one
% of the strings in continentBaseNames).
load("Datasets/Airport_Continent_Dictionary.mat", "airportContinentDict");

% Create a vector specifying the continent on which each node resides.
airportContinentVec = airportContinentDict(string(undirectedRouteNetwork.Nodes.Name));

% Create a new figure and use a force-directed layout to plot the airport route network.
figure;
continentNetworkFig = plot(undirectedRouteNetwork, "Layout", "force");

% Tweak the node marker size and link plot colour.
continentNetworkFig.MarkerSize = 4;
continentNetworkFig.EdgeColor = [0.75, 0.75, 0.75];

% Colour the nodes according to the continent they belong to.
for i = 1 : numOfContinents
    highlight(continentNetworkFig, nodeIDs(find(airportContinentVec == ...
    continentBaseNames(i))), "NodeColor", colours(i,:));
end

% Add a legend linking continents and colours.
hold on;
set(gca,'ColorOrderIndex',1);
qw{1} = scatter(nan, nan, "filled");
qw{2} = scatter(nan, nan, "filled");
qw{3} = scatter(nan, nan, "filled");
qw{4} = scatter(nan, nan, "filled");
qw{5} = scatter(nan, nan, "filled");
qw{6} = scatter(nan, nan, "filled");
legend([qw{:}], 'Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America');

xlim([-7.8,6.6]);
ylim([-6, 7.3]);