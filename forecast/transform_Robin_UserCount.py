#!/usr/bin/env python

import sys
import math
import numpy as np

from sklearn import linear_model
from sklearn import cross_validation

# --------------------------------------------------------------------------------------------------------------

src = str(sys.argv[1]) + '.csv'

text = np.genfromtxt(src,delimiter=',',dtype='str')

x = np.array(text[:,0], dtype = 'int_')
y = np.array(text[:,1], dtype = 'int_')

print '================='
print 'Linear Regression'
print '-----------------'
LinearRegression = linear_model.LinearRegression()
LinearRegression.fit(x.reshape(11,1),y.reshape(11,1))

X_train, X_test, y_train, y_test = cross_validation.train_test_split(x.reshape(11,1),y.reshape(11,1), test_size=0.20, random_state=66)
mod = LinearRegression
mod.fit(X_train,y_train)
mod_score = mod.score(X_test,y_test)

print 'Coefficient: ' + str(LinearRegression.coef_[0][0])
print 'Intercept: ' + str(LinearRegression.intercept_[0])
print 'Score: ' + str(LinearRegression.score(x.reshape(11,1),y.reshape(11,1)))
print 'Model Score: ' + str(mod_score)

# print '================='
# print 'Ridge Regression '
# print '-----------------'
# RidgeRegression = linear_model.Ridge()
# RidgeRegression.fit(x.reshape(11,1),y.reshape(11,1))

# X_train, X_test, y_train, y_test = cross_validation.train_test_split(x.reshape(11,1),y.reshape(11,1), test_size=0.20, random_state=66)
# mod = RidgeRegression
# mod.fit(X_train,y_train)
# mod_score = mod.score(X_test,y_test)

# print 'Coefficient: ' + str(RidgeRegression.coef_)
# print 'Intercept: ' + str(RidgeRegression.intercept_)
# print 'Score: ' + str(RidgeRegression.score(x.reshape(11,1),y.reshape(11,1)))
# print 'Model Score: ' + str(mod_score)

# print '================='
# print 'Lasso Regression '
# print '-----------------'
# LassoRegression = linear_model.Lasso()
# LassoRegression.fit(x.reshape(11,1),y.reshape(11,1))

# X_train, X_test, y_train, y_test = cross_validation.train_test_split(x.reshape(11,1),y.reshape(11,1), test_size=0.20, random_state=66)
# mod = LassoRegression
# mod.fit(X_train,y_train)
# mod_score = mod.score(X_test,y_test)

# print 'Coefficient: ' + str(LassoRegression.coef_)
# print 'Intercept: ' + str(LassoRegression.intercept_)
# print 'Score: ' + str(LassoRegression.score(x.reshape(11,1),y.reshape(11,1)))
# print 'Model Score: ' + str(mod_score)

# --------------------------------------------------------------------------------------------------------------

# Build out the rest of the data from the CSV
intercept = int(LinearRegression.intercept_[0])
coefficient = int(LinearRegression.coef_[0][0])

# Copy the original dataset (with the header)
dst = src.replace('_raw','_pred')

# Generate one more year of "data" for the dataset to be plotted
with open(dst, 'w') as file:
    with open(src.replace('_raw',''),'r') as readfile:
    	for line in readfile:

    		# Capture the first YYYY_MM x-axis point for the linear regression line
    		if line.split(',')[0] == '1':
    			start_YYYY_MM = line.split(',')[2]

    		cnt = line.split(',')[1]
    		YYYY_MM = line.split(',')[2].strip()
    		# typ = line.split(',')[3]
    		
    		file.write('Actual,' + YYYY_MM + ',' + cnt + '\n')

    for i in range(0,38):
    	new_cnt = int(intercept) + (int(i) * coefficient)

    	#---------------------------------------------------------------------------------#
    	# Perform the YYYY_MM Increment
    	if i == 0:
    		YYYY_MM = start_YYYY_MM
    		new_MM = int(YYYY_MM[-2:])
    	else:
    		new_MM = int(YYYY_MM[-2:]) + 1

    	if new_MM == 13:
    		new_YYYY = int(YYYY_MM[:4]) + 1
    		new_MM = '01'
    		new_YYYY_MM = str(new_YYYY) + '-' + new_MM
    		# print 'Increment Year: ' + new_YYYY_MM
    	else:
    		if int(new_MM) < 10:
    			new_YYYY_MM = YYYY_MM[:4] + '-0' + str(new_MM)
    			# print 'Increment Month (less than 10): ' + new_YYYY_MM
    		else:
    			new_YYYY_MM = YYYY_MM[:4] + '-' + str(new_MM)
    			# print 'Increment Month (more than 9): ' + new_YYYY_MM

    	YYYY_MM = new_YYYY_MM
    	#---------------------------------------------------------------------------------#

    	# Write the new records for the predicted future datapoints
    	file.write('Projected,' + new_YYYY_MM + ',' + str(new_cnt) + '\n')

    	
