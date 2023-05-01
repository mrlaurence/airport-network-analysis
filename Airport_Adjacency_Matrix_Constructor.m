% Retrieve a string array containing the IATA codes for all the airports for which at
% least one European airline has at least one active flight route.
iataStringArray = string(jsondecode(fileread("Datasets/Routes_IATA_Codes.json")))';

airportCount = size(iataStringArray, 2);

% Construct a dictionary which maps each IATA code (identifying a unique airport) to a
% unique numeric ID
airportLookupDict = dictionary(iataStringArray, 1:airportCount);

% Initalise a spare matrix of zeros which will indicate adjacency between airports.
routeAdjacencyMatrix = sparse(airportCount, airportCount);

routesCellArray = jsondecode(fileread("Datasets/AirLabs_Europe_Routes.json"));

% Iterate over the European airlines.
for i = 1 : size(routesCellArray, 1)

    fprintf("[INPUT] Checking routes for airline ID: %d.\n", i);

    % If the airline flies only one route.
    if size(routesCellArray{i}, 1) == 1
        route = routesCellArray{i};

        % Retrieve the departure/arrival airport IATAs and the number of days a week for
        % which this route is flown.
        depIata = string(route.dep_iata);
        arrIata = string(route.arr_iata);
        dayCount = size(string(route.days{:})', 2);

        if dayCount == 0
            input("[ERROR] Route is flown for zero days. Press Return to continue. ");
        end

        depID = airportLookupDict(depIata);
        arrID = airportLookupDict(arrIata);

        % Update the adjacency matrix by incrementing the number of weekly flights between
        % these two airports by the number of times per week this route is flown.
        routeAdjacencyMatrix(depID, arrID) = routeAdjacencyMatrix(depID, arrID) + dayCount;

    else
        % Retrieve a table containing all the routes for the airline.
        routeTable = struct2table(routesCellArray{i});
    
        % Iterate over the routes in the table.
        for j = 1 : height(routeTable)
            route = routeTable(j, :);
    
            % Retrieve the departure/arrival airport IATAs and the number of days a week for
            % which this route is flown.
            depIata = string(route.dep_iata);
            arrIata = string(route.arr_iata);
            dayCount = size(string(route.days{:})', 2);
    
            if dayCount == 0
                input("[ERROR] Route is flown for zero days. Press Return to continue. ");
            end
    
            depID = airportLookupDict(depIata);
            arrID = airportLookupDict(arrIata);
    
            % Update the adjacency matrix by incrementing the number of weekly flights between
            % these two airports by the number of times per week this route is flown.
            routeAdjacencyMatrix(depID, arrID) = routeAdjacencyMatrix(depID, arrID) + dayCount;
        end
    end
end

% Export the resulting adjacency matrix to a MAT file.
save("Route_Adjacency_Matrix.mat", "routeAdjacencyMatrix");