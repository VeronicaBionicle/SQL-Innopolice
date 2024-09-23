import pg8000
import pandas as pd

# creating connection
connection = pg8000.connect(
    host='192.168.77.5',
    port='5432',
    user='student051',
    password='Zeiwae2phaey',
    database='student051'
)
connection.autocommit = False

# read data from Excel
df = pd.read_excel('/home/student051/nsi.xlsx')
#print(df.info())

cursor = connection.cursor()

# creating table for data
schema = "veronikanenyuk"
query = f"create table \"{schema}\".NSI (id bigint, position text, description text, value_type text, units text, min_value bigint, max_value bigint);"
cursor.execute(query)
cursor.execute('commit;')

# inserting data to table
query = f"insert into \"{schema}\".NSI\n"
for index, row in df.iterrows():
    if index != 0:
      query += "union all\n"
    query += f"select {row['Идентификатор']}, \'{row['Позиция прибора']}\', \'{row['Описание']}\', \'{row['Тип значения']}\', \'{row['Единица измерения']}\', {row['min']}, {row['max']}\n"
query += ";"

cursor.execute(query)
cursor.execute('commit;')

# closing connection to DB
connection.close()
