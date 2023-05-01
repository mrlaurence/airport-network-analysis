airportArray = jsondecode(fileread("Datasets/AirLabs_All_Airports.json"));

africaArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_Africa.json")).code});
antarcticaArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_Antarctica.json")).code});
asiaArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_Asia.json")).code});
europeArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_Europe.json")).code});
northAmericaArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_NorthAmerica.json")).code});
oceaniaArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_Oceania.json")).code});
southAmericaArray = string({jsondecode(fileread("Datasets/Countries_By_Continent/AirLabs_Countries_SouthAmerica.json")).code});

airportContinentDict = dictionary;

countryContinentDict = dictionary;

for i = 1 : size(airportArray, 1)
    countryCode = airportArray{i}.country_code;

    if i == 1 || ~ismember(countryCode, countryContinentDict.keys)
        if ismember(countryCode, africaArray)
            countryContinentDict(countryCode) = "africa";

        elseif ismember(countryCode, antarcticaArray)
            countryContinentDict(countryCode) = "antarctica";

        elseif ismember(countryCode, asiaArray)
            countryContinentDict(countryCode) = "asia";     

        elseif ismember(countryCode, europeArray)
            countryContinentDict(countryCode) = "europe";  

        elseif ismember(countryCode, northAmericaArray)
            countryContinentDict(countryCode) = "north_america";     

        elseif ismember(countryCode, oceaniaArray)
            countryContinentDict(countryCode) = "oceania";     

        elseif ismember(countryCode, southAmericaArray)
            countryContinentDict(countryCode) = "south_america";     

        else
            error("[ERROR] No continent matched.");   
        end
    end
    if isfield(airportArray{i}, "iata_code")
        airportContinentDict(airportArray{i}.iata_code) = countryContinentDict(countryCode);
    end
end

save("Airport_Continent_Dictionary.mat", "airportContinentDict");