sample = open("../data/sampleSubmission.csv", 'r')
predictions = open("../out/predictions.fm")

print "Id,Weekly_Sales"

for line in sample:
	prediction = predictions.readline().strip()
	line = line.strip().split(',')
	print ','.join([line[0],prediction])