import requests as rq
import json
import os

file_list = os.listdir()

all_airline_codes = []
skips = 0
total = 0

for file_name in file_list:
	if "Airlines.json" in file_name:
		with open(file_name) as json_file:
			json_dict = json.load(json_file)
			country_airline_list = json_dict["response"]
			for airline in country_airline_list:
				try:
					all_airline_codes.append(airline["iata_code"])
					total = total + 1
				except KeyError:
					skips = skips + 1

print("Total (non-skipped): " + str(total))
print("Skip count: " + str(skips))

with open("AirLabs_European_Airline_Code_List.json", 'w') as json_file:
	json_file.write(str(all_airline_codes))


# with open("AirLabs_Europe_Countries.json") as json_file:
#         json_dict = json.load(json_file)

# country_list = json_dict["response"]
# code_list = []

# for country in country_list:
# 	code_list.append(country["code"])

# print(code_list)

# for code in code_list:
# 	with open("AirLabs_" + code + "_Airlines.json", "w") as json_file:
# 		json_file.write(rq.get("https://airlabs.co/api/v9/airlines?country_code=" + code + "&api_key=<KEY>").text)
