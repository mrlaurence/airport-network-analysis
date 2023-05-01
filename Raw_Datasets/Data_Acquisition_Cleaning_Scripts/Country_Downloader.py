import requests as rq
import json

with open("AirLabs_Europe_Countries.json") as json_file:
        json_dict = json.load(json_file)

country_list = json_dict["response"]
code_list = []

for country in country_list:
	code_list.append(country["code"])

print(code_list)

for code in code_list:
	with open("AirLabs_" + code + "_Airlines.json", "w") as json_file:
		json_file.write(rq.get("https://airlabs.co/api/v9/airlines?country_code=" + code + "&api_key=<KEY>").text)
