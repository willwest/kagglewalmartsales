sample = open("../data/sampleSubmission_clean.csv", 'r')
predictions = open("../out/predictions.fm")

outfile = open("../out/predictions.fm.submit", 'w')

outfile.write("Id,Weekly_Sales"+"\n")

for line in sample:
	prediction = predictions.readline().strip()
	line = line.strip().split(',')
	outfile.write(','.join([line[0],prediction])+"\n")