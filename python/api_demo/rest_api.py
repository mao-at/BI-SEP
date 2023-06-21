from flask import Flask, request
from flask_restful import Resource, Api
import json
import os
import pyodbc

# get credentials from environment variables
WWI_USER_NAME=os.environ.get('WWI_USER_NAME')
WWI_PASSWORD=os.environ.get('WWI_PASSWORD')
# Create a connection string
conn_str = (
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    r'SERVER=DESKTOP-FJ2C7I6;'
    r'DATABASE=WideWorldImportersDW;'
    f'UID={WWI_USER_NAME};'
    f'PWD={WWI_PASSWORD};'
)


app = Flask(__name__)
api = Api(app)

class Employee(Resource):
    def get(self):
        # Establish connection and create a cursor
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        # Write and execute your SQL query
        sql_query = "select * from dimension.employee"
        cursor.execute(sql_query)

        # Fetch the results of the query
        rows = cursor.fetchall()

        # Don't forget to close the connection when you're done
        conn.close()

        # Get column names from cursor description
        columns = [column[0] for column in cursor.description]

        # Convert rows to list of dictionaries
        dict_rows = [dict(zip(columns, row)) for row in rows]

        # Serialize the list of dictionaries to JSON
        json_data = json.dumps(dict_rows,default=str)
        return json_data
    

api.add_resource(Employee, '/employee') # Route_1

if __name__ == '__main__':
     app.run(debug=True)



