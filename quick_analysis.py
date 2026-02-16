import csv

table_name = "combined_table_28.csv"

outcomes = set()
datapoints = {}

datapoints_averaged = []

with open(table_name, newline = '') as combined_table:
    reader = csv.DictReader(combined_table)
    for row in reader:
        outcomes.add(row['Activity'])
        if row["Subject area of degree"][:5] == "Total":
            continue
        if (row["Provider name"], row["Subject area of degree"]) in datapoints:
            if row["Activity"] in datapoints[(row["Provider name"], row["Subject area of degree"])]:
                datapoints[(row["Provider name"], row["Subject area of degree"])][row["Activity"]] += int(row["Number"])
            else:
                datapoints[(row["Provider name"], row["Subject area of degree"])][row["Activity"]] = int(row["Number"])
        else:
            datapoints[(row["Provider name"], row["Subject area of degree"])] = {row["Activity"] : int(row["Number"]), "Provider name" : row["Provider name"], "Subject area of degree" : row["Subject area of degree"]}
                
fieldnames = ["Provider name", "Subject area of degree"] + list(outcomes)

print(fieldnames)

few_respondends = []

print(len(datapoints))

for point in datapoints.values():
    if point["Total with known outcomes"] < 20:
        few_respondends.append({"Provider name": point["Provider name"], "Subject area of degree": point["Subject area of degree"], "Total" : point["Total"], "Unemployed" : point["Unemployed"]})
    else:
        averaged = {}
        for key, val in point.items():
            if type(val) == int and key != "Total with known outcomes":
                averaged[key] = val / point["Total with known outcomes"]
            else:
                averaged[key] = val
        datapoints_averaged.append(averaged)

with open('aggregate_data_28_all_years_totals.csv', 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for point in datapoints.values():
        if point["Total with known outcomes"] >= 20:
            print(fieldnames, point)
            writer.writerow(point)

with open('aggregate_data_28_all_years_averaged.csv', 'w', newline='') as csvfile:
    fieldnames.remove("Total")
    fieldnames.remove("Non-respondents")
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for point in datapoints_averaged:
        point.pop("Total")
        point.pop("Non-respondents")
        writer.writerow(point)
                
with open('too_few_entries.csv', 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=["Provider name", "Subject area of degree", "Total", "Unemployed"])
    writer.writeheader()
    for point in few_respondends:
        print(point)
        writer.writerow(point)



