import requests as rq
import json
import os

with open("AirLabs_European_Airline_Code_List.json") as myfile:
     code_list = json.load(myfile)

huge_list = []

i = 0

for code in code_list:

     big_dict = json.loads(rq.get("https://airlabs.co/api/v9/routes?airline_iata=" + code + "&api_key=<KEY>").text)
     big_list = big_dict["response"]
     huge_list.append(big_list)
     i = i + 1
     print("Progress:" + str(i))

with open("AirLabs_All_European_Flights.json", 'w') as myfile:
     myfile.write(json.dumps(huge_list))