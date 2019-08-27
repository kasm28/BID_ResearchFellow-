#!/usr/bin/env python
# coding: utf-8

# 
# This script takes data from 'BASE_MOVIMIENTOS' and 'BASE_ID' it first clean up the data from 'BASE_MOVIMIENTOS', then moves into cleaning 'BASE_ID'. It also contains the process followed in order to merge the two obtained dataframes(clean) into a single one 'ypd1'. 
# The fourth part of this script processes the dataset ('df.csv') -obtained from the merging process- assigned to delvelop the project. It then, takes data from 'BASE_ID' and 'BASE_MOVIMIENTOS' and tries to run a survival analysis for 'customer churn'. 
# 
# ###	Creator: Karem Alexandra Sastoque Mendez 
# ###	First Version: 			        Feb 22 / 2019
# ###	Date of last version:  	        Feb 26 / 2019
# 
# Des: 	        5
# 		        1 Outputs (dataset).
# Notes:         4 parts (data cleaning 1-2, merging, analysis)
# 
# 	Important changes to made:
#               - Se convirtio previamente a .csv los archivos con los que   
#                 vamos a trabajar con el fin de evitar errores en typos o   
#                 formatos de datos y al momento de importar los .txt        
#                - Verificar que todos sean target efectivamente - PTE       
# cuando crucemos las bases de datos podremos indagar sobre cuantos de estos clientes se han fugado y ver carácteristicas en sus movimientos   
#                 - Yo empezaría por contar cuantos están activos en         
#                  diciembre y ver cómo se van saliendo y si hay razones.   
# 

# ### 1. Data Preparation

# In[1]:


# importing modules
import pandas as pd
import numpy as np
import locale
from datetime import datetime as dt
import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')

#Displaying all dataframe columns
pd.set_option('display.max_columns', None)


# In[2]:


#Loading datasets
base_movimientos = pd.read_fwf('BASE_MOVIMIENTOS.txt')
base_movimientos.head()


# In[3]:


base_movimientos.dtypes


# After loading the dataset and looking at the dtypes, the following changes will be made: 
# 
# - `FECHA_INFORMACION` will be transformed to datetime
# - `SALDO_FONDOS`, `SALDO_CREDITO1`, `SALDO_CREDITO2`, `SALDO_ACTIVO` and `SALDO_PASIVO` will be transformed to float

# In[4]:


locale.setlocale(locale.LC_ALL,'en_US.UTF-8')
# converting object to datetime
base_movimientos['FECHA_INFORMACION'] = pd.to_datetime(base_movimientos['FECHA_INFORMACION'], format='%d%b%Y:%H:%M:%S')

# converting currency to float
to_float = ['SALDO_FONDOS','SALDO_CREDITO1','SALDO_CREDITO2', 'SALDO_ACTIVO','SALDO_PASIVO']
for col in to_float:
    base_movimientos[col] = base_movimientos[col].replace('[\$.]', '', regex=True).replace(',', '.',regex=True).astype(float)

base_movimientos.head()


# In[5]:


#Loading datasets
base_id = pd.read_csv('BASE_ID.txt', sep='\t')
base_id.head()


# After loading the dataset and looking at the information, the following changes will be made:
# 
# - `CLIENTE_CC` and `fuga` will be renamed to `ID` and `FUGA` respectively
# - `ID` will be transformed to int
# - Values in column `SEXO` will be changed to F for female and M for male
# - Values in column `SITUACION_LABORAL` will be changed to OTROS, CONTRATO FIJO,CONTRATO AUTONOMO, SIN CLASIFICAR and CONTRATO TEMPORAL
# - `FECHA_ALTA` and `FECHA_NACIMIENTO` will be transformed to datetime

# In[6]:


# Renaming columns
base_id = base_id.rename(columns={'CLIENTE_CC':'ID', 'fuga':'FUGA'})

# Converting string to int
base_id['ID'] = base_id['ID'].replace(',', '.', regex=True).astype(float)
base_id['ID'] = base_id['ID'].astype(dtype=np.int64)

#Changing values to F for female and M for male
base_id['SEXO'] = base_id['SEXO'].replace({'HOMBRE':'M', 'Hombre':'M', 'mujer':'F', 'femenino':'F', 
                                           'masculino':'M','FEMENINO':'F','Mujer':'F', 'varón':'M', 'Masc.':'M', 
                                           'MUJER':'F'})
#Changing values
base_id['SITUACION_LABORAL'] = base_id['SITUACION_LABORAL'].replace({'otros':'OTROS', 'Contrato fijo':'CONTRATO FIJO', 
                                                                     'contrato autonomo.':'CONTRATO AUTONOMO',
                                                                     ' desconocido   ': 'SIN CLASIFICAR', 
                                                                     'temporal     ':'CONTRATO TEMPORAL'})


# In[7]:


# converting object to datetime
locale.setlocale(locale.LC_ALL,'es_ES.UTF-8')
for i, date in enumerate(base_id['FECHA_ALTA']):
    base_id.iloc[i,1] = dt.strptime(date, '%b%d%Y')
locale.setlocale(locale.LC_ALL,'en_US.UTF-8')
base_id['FECHA_ALTA'] = pd.to_datetime(base_id['FECHA_ALTA'], format='%Y%m%d')

# converting object to datetime
locale.setlocale(locale.LC_ALL,'es_ES.UTF-8')
base_id['FECHA_NACIMIENTO'] = base_id['FECHA_NACIMIENTO'].replace({'0001-01-01':'19010101'})
for i, date in enumerate(base_id['FECHA_NACIMIENTO']):
    base_id.iloc[i,2] = dt.strptime(date, '%Y%m%d')    
base_id['FECHA_NACIMIENTO'] = pd.to_datetime(base_id['FECHA_NACIMIENTO'], format='%Y%m%d')


# In[8]:


base_id.head()


# In[9]:


#Check columns for na values
base_id.columns[base_id.isna().any()].tolist()


# In[10]:


#Fill na values
base_id['ESTADO_CIVIL'] = base_id['ESTADO_CIVIL'].fillna('DESCONOCIDO')
base_id[['FUGA','MES_DE_FUGA']] = base_id[['FUGA','MES_DE_FUGA']].fillna(value=0)


# In[11]:


#Calculate age and # of years a customer have been with the company
base_id['EDAD'] = (dt.now() - base_id['FECHA_NACIMIENTO']).astype('timedelta64[Y]')
base_id['ANIOS_ALTA'] = (dt.now() - base_id['FECHA_ALTA']).astype('timedelta64[Y]')
base_id.head()


# In[12]:


# Merge both dataframes
full_df = base_movimientos.merge(base_id)
full_df.head()


# In[13]:


# For FUGA == 1 filter transactions that happened when customer left or before, or filter by transactions FUGA == 0
full_df = full_df.loc[((full_df['FUGA'] == 1) & (full_df.loc[full_df['MES_DE_FUGA'] > 0, 'FECHA_INFORMACION'] <= pd.to_datetime('2017-' + full_df.loc[full_df['MES_DE_FUGA']>0, 'MES_DE_FUGA'].astype(int).astype(str) + '-1', format = '%Y-%m'))) |(full_df['FUGA'] == 0)].copy()

# sort values ascending
full_df.sort_values(['ID', 'FECHA_INFORMACION'], inplace=True)

# Average last 3 transactions for each customer
df = (full_df.groupby(['ID','FUGA'])['FECHA_INFORMACION'].nth([-1, -2, -3])
                        .reset_index()
                        .merge(full_df)
                        .groupby(['ID','FUGA', 'EDAD', 'ANIOS_ALTA','SEXO','ESTADO_CIVIL','SITUACION_LABORAL', 'MES_DE_FUGA'])
                         [['SALDO_AHORROS', 'SALDO_FONDOS','SALDO_CREDITO1', 'SALDO_CREDITO2', 'SALDO_TARJETA',
                           'MONTO_COMPRAS1','MONTO_CAJERO1', 'MONTO_COMPRAS2', 'MONTO_CAJERO2','INDICADOR_MORA',
                           'MONTO_ABONOS_NOMINA', 'SALDO_ACTIVO', 'SALDO_PASIVO']]
                        .mean()
                        .reset_index()
                        .round(1))
df.head()


# In[14]:


df.info()


# No variable column has null/missing values

# ### 2. Data Exploration

# In[15]:


df['FUGA'].value_counts()


# In[16]:


df['FUGA'].hist()


# In[17]:


fuga_pct = (df["FUGA"].sum() / df["FUGA"].shape[0])*100
no_fuga_pct = 100 - (df["FUGA"].sum() / df["FUGA"].shape[0])*100
print("Pct of churners is %.2f%%." % fuga_pct)
print("Pct of no churners is %.2f%%." % no_fuga_pct)


# In[18]:


df['MONTO_ABONOS_NOMINA'].hist()


# In[19]:


df['SALDO_ACTIVO'].hist()


# In[20]:


df.groupby('FUGA').mean().round(2)


# - The average age of customers who left the company is lower than that of the customers who didn’t.
# 
# - Customers who left the company in average spent less in loans, credit cards, debit cards, withdraws and recive less in payroll than those who didn't leave the company.
# 
# - Customers who stayed in the company were never behind their bills.

# In[21]:


df.groupby('ESTADO_CIVIL').mean().round(2)


# - The 3 marital status that have the highest average churn are: Single, Divorced and Free Union (Union libre)
# - The average age of single customers is the lower in all marital status. They are in average the newest customers. 
# - The widower group spent the most in consupmtion loans.
# - Divorced people in average spent the most in mortgage loans.
# - Married people in average spent the most in credit cards  

# In[22]:


df.groupby('SITUACION_LABORAL').mean().round(2)


# - People with a temporary contract have the highest churn, they are the youngest and spend less time with the company in average.
# - People with an autonomus contract in average spent more in credit cards than the other groups
# - People with a fixed contract in average spent more in debit cards than the other groups
# - People with an unclassified contract recieved more on their payroll than the other groups in average

# In[23]:


#Visualizations
df.groupby(['SEXO', 'FUGA']).size().unstack().plot(kind='bar', stacked=True, title='Fuga por genero')
df.groupby(['ESTADO_CIVIL', 'FUGA']).size().unstack().plot(kind='bar',stacked=True, title='Fuga por estado civil')
df.groupby(['SITUACION_LABORAL', 'FUGA']).size().unstack().plot(kind='bar',stacked=True, title='Fuga por situacion laboral')


# ### 3. Building a Predicitive Model

# In[24]:


# importing modules
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import BaggingClassifier
from sklearn.metrics import accuracy_score, f1_score, roc_auc_score


# #### 3.1 Pre-Processing Data

# In[25]:


# Encode categorical columns
to_enconde = ['SEXO', 'ESTADO_CIVIL', 'SITUACION_LABORAL']
le = LabelEncoder()
for col in to_enconde:
    le.fit(df[col])
    df[col] = le.transform(df[col])


# In[26]:


# Specify seed for reproducable results
seed = 20

# Split data into features and response
features = ['SEXO', 'ESTADO_CIVIL','SITUACION_LABORAL', 'SALDO_AHORROS', 'SALDO_FONDOS', 'SALDO_CREDITO1',
            'SALDO_CREDITO2', 'SALDO_TARJETA', 'MONTO_COMPRAS1', 'MONTO_CAJERO1','MONTO_COMPRAS2', 
            'MONTO_CAJERO2', 'MONTO_ABONOS_NOMINA','INDICADOR_MORA', 'SALDO_ACTIVO', 'SALDO_PASIVO', 
            'EDAD', 'ANIOS_ALTA']

X = df[features].values
y = df['FUGA'].values


# In[27]:


#Standarized features
scaler = StandardScaler()
X = scaler.fit_transform(X.astype(np.float))


# In[28]:


#Split dataframe into training and test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=seed)


# #### 3.2. Predictive models

# For this classification problem I will try different models:
# 
# - Support Vector Machine
# - Logistic Regression
# - Decision Tree
# - Survival Model

# In[ ]:


import matplotlip
from matplotlib import pyplot as plt
import lifelines
from lifelines import KaplanMeierFitter #survival analysis library
from lifelines.statistics import logrank_test #survival statistical testing
from lifelines import CoxPHFitter 

df.info()
df.head(20)
df.MES_DE_FUGA.value_counts(sort=True)


# In[ ]:


startdt = pd.to_datetime(df.FECHA_ALTA)
enddt = pd.to_datetime(df.FECHA_ALTA +df.ANIOS_ALTA)
diftimefuga = startdt - enddt


# - Survival Analysis

# In[ ]:


import matplotlip
from matplotlib import pyplot as plt
import lifelines
from lifelines import KaplanMeierFitter #survival analysis library
from lifelines.statistics import logrank_test #survival statistical testing
from lifelines import CoxPHFitter 


df['churn'] = df1.fuga

cph = CoxPHFitter()
cph.fit(df, duration_col=ypd1['enddt'], event_col=ypd1['FUGA'], show_progress=True)
cph.print_summary()
cph.plot()


# In[ ]:


df_2 = df.drop(['enddt', 'FUGA'], axis=1)
cph.predict_partial_hazard(df_2)
cph.predict_survival_function(df_2, times=[5., 25., 50.])
cph.predict_median(X)

kmf = KaplanMeierFitter()
T = df['time_to_fuga'] #duration
C = df['churn'] #censorship - 1 if death/churn is seen, 0 if censored

