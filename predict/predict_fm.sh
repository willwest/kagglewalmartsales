./to_svm_light.sh
./scale.sh
../bin/libFM -task r -train ../out/combined.train.csv.svm.scale -test ../out/combined.test.csv.svm.scale -iter 100 -out ../out/predictions.fm > fm_predict.`eval date +%Y_%m_%d_%H.%M`.log
python format_submit.py
