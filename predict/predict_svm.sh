./to_svm_light.sh
./scale.sh
../bin/svm-train -s 3 -t 0 -m 1024 ../out/combined.train.csv.svm.scale ../out/combined.train.csv.svm.scale.model
../bin/svm-predict ../out/combined.test.csv.svm.scale ../out/combined.train.csv.svm.scale.model ../out/predictions.svm
python format_submit.py
