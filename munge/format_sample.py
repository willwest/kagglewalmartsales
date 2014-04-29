outfile = open("../data/submissionTemplate.csv", 'w')

outfile.write("id,Store,Dept,Date,prediction\n")

with open("../data/sampleSubmission.csv", 'r') as f:
	f.readline()
	for line in f:
		orig = line.strip().split(',')[0]
		line = line.strip().split(',')
		line[0] = line[0].split('_')
		store = line[0][0]
		dept = line[0][1]
		date = line[0][2]
		prediction = line[1]
		outfile.write(','.join([orig,store,dept,date,prediction])+'\n')