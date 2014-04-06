import sklearn
import pandas as pd
import numpy as np

df = pd.read_csv('../out/combined.csv')

print df.describe()
