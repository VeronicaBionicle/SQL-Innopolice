# wget https://docs.google.com/spreadsheets/d/1qv4cn3pFCVWr8HYMo-6Fc2cMrC0PcruC/export?format=xlsx -O nsi.xlsx

import sqlalchemy as sa
from sqlalchemy import create_engine
import pg8000

# connection parameters
host='192.168.77.5'
port='5432'
user='student051'
password='Zeiwae2phaey'
database='student051'
schema='veronikanenyuk'

# composing connection string
db_string = sa.engine.url.URL.create(     
                                   drivername="postgresql+pg8000",
                                   username=user,
                                   password=password,
                                   host=host,
                                   port=port,
                                   database=database,
                                   )

# creating connection
db_engine = create_engine(db_string)

import pandas as pd

# read data from excel
df = pd.read_excel('/home/student051/nsi.xlsx')
# print(df.info())

# create table with data
df.to_sql('nsi',con=db_engine, if_exists='replace', index=False, schema=schema)  

# end connection
db_engine.dispose()
