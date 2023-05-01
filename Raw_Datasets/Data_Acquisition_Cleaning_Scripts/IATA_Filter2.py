import json

iata_list = []

with open("AirLabs_All_European_Flights_New.json") as myfile:
     mydict = json.load(myfile)

counter = 0

for eleme in mydict:
     counter = counter + 1
     print(str(counter))
     
     for thing in eleme:
          if not (thing["dep_iata"] in iata_list):
               iata_list.append(thing["dep_iata"])
          if not (thing["arr_iata"] in iata_list):
               iata_list.append(thing["arr_iata"])

with open("AirLabs_Flight_Airport_IATA_List.json", "w") as myfile:
     myfile.write(json.dumps(iata_list))