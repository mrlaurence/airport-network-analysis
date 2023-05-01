import json

counter = 0

with open("AirLabs_All_European_Flights_New.json") as myfile:
	mydict = json.load(myfile)

for eleme in mydict:
	counter = counter + len(eleme)

print("Total: " + str(counter))