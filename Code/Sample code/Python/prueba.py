import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.model_selection import KFold
from sklearn.metrics import confusion_matrix, accuracy_score

training_file_path = './dummy.csv'

##############################
######   Xgboost   ###########
##############################

# read training data

file = pd.read_csv(training_file_path, sep = ',')
#file_numeric = file.select_dtypes(include=['int16', 'int32', 'int64', 'float16', 'float32', 'float64'])

#file_numeric_columns = file_numeric.values.shape[1]
X = file.values[:,2:len(file.iloc[1,:])] # avoid last two columns: ids and churn
Y = file.values[:,1] # select last column (churn) as target

sel = [randint(0, len(Y)-1) for p in range(0, 100)]
X_test = X[sel][:]
Y_test = Y[sel]

X_train = np.delete(X,sel, axis=0)
Y_train = np.delete(Y,sel)

params = {'eta': 0.02, 'max_depth': 5, 'subsample': 0.7, 'colsample_bytree': 0.7, 'objective': 'binary:logistic', 'seed': 99, 'silent': 1, 'eval_metric':'error', 'nthread':4}
xg_train = xgb.DMatrix(X_train, label=Y_train)
cv = xgb.cv(params, xg_train, 5000, nfold=10, early_stopping_rounds=10, verbose_eval=1)

params2 = {'eta': 0.02, 'max_depth': 5, 'objective': 'binary:logistic', 'seed': 99, 'silent': 1, 'eval_metric':'error', 'nthread':4}
cv2 = xgb.train(params2, xg_train, 300, verbose_eval=1)

cv2.save_model("model1")
clf = xgb.XGBClassifier()
clf.load_model("model1")

cv2.predict(xg_test)

##############################
######   Keras NN  ###########
##############################

from keras.models import Sequential
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasClassifier
from sklearn.model_selection import cross_val_score
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import StratifiedKFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from keras.models import model_from_json

# fix random seed for reproducibility
seed = 7
numpy.random.seed(seed)

train = pd.read_csv('./dummy.csv')

X_train = train.iloc[:,2:len(train)]

y_train = np.array(train["class.e"])

sel = [randint(0, len(y_train)-1) for p in range(0, 100)]
X_test = X_train.iloc[sel,:]
Y_test = y_train[sel]
X_train = X_train.drop(sel, axis=0)
Y_train = np.delete(y_train,sel)

def create_baseline():
    
    model = Sequential()
    model.add(Dense(60, input_dim=126, kernel_initializer='normal', activation='relu'))
    model.add(Dense(1, kernel_initializer='normal', activation='sigmoid'))
    # Compile model
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

#CROSS VALIDATION
estimator = KerasClassifier(build_fn=create_baseline, epochs=60, batch_size=100, verbose=1)
kfold = StratifiedKFold(n_splits=5, shuffle=True, random_state=seed)
results = cross_val_score(estimator, X_train, y_train, cv=kfold)
print("Results: %.2f%% (%.2f%%)" % (results.mean()*100, results.std()*100))

#Model
model = create_baseline()
model.fit(X_train, Y_train, epochs=20, batch_size=100, verbose=1)
score = model.evaluate(X_test, Y_test, verbose=0)
print("%s: %.2f%%" % (model.metrics_names[1], score[1]*100))

#SAVE MODEL

# serialize model to JSON
model_json = model.to_json()
with open("model.json", "w") as json_file:
    json_file.write(model_json)
# serialize weights to HDF5
model.save_weights("model.h5")
print("Saved model to disk")

# load json and create model
json_file = open('model.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
loaded_model = model_from_json(loaded_model_json)
# load weights into new model
loaded_model.load_weights("model.h5")
print("Loaded model from disk")
 
# evaluate loaded model on test data
loaded_model.compile(loss='binary_crossentropy', optimizer='rmsprop', metrics=['accuracy'])
score = loaded_model.evaluate(X_test, Y_test, verbose=0)
print("%s: %.2f%%" % (loaded_model.metrics_names[1], score[1]*100))

#PREDICT
ynew = model.predict(X_test)

##############################
######   SKLEARN   ###########
##############################

import seaborn as sns
import matplotlib.pyplot as plt
import time
import pickle

from sklearn.neighbors import KNeighborsClassifier

a = KNeighborsClassifier(algorithm='auto', leaf_size=30, metric='euclidean',
            metric_params=None, n_jobs=None, n_neighbors=5, p=2,
            weights='uniform')

a.fit(X_train, Y_train) 

a.score(X_test, Y_test)

filename = 'finalized_model.sav'
pickle.dump(a, open(filename, 'wb'))

loaded_model = pickle.load(open(filename, 'rb'))
result = loaded_model.score(X_test, Y_test)
print(result)