import os
from flask import Flask, jsonify, request
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy import Column, Integer, String

user = 'api_db_user'
subname = 'server-10002' 
pwd = 'Interforaewg098!'
sub = 'server-10002.postgres.database.azure.com'
db = 'api_db'

app = Flask(__name__)

engine = create_engine("postgresql+psycopg2://{0}@{1}:{2}@{3}/{4}?sslmode=require".format(user, subname, pwd, sub, db), echo = True)

db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
Base = declarative_base()
Base.query = db_session.query_property()


class ApiData(Base):
    __tablename__ = "api_data"

    id = Column(Integer, primary_key=True)
    uuid1 = Column(String(256))
    uuid2 = Column(String(256))
    uuid3 = Column(String(256))

    @property
    def serialize(self):
        return {
            'id': self.id,
            'uuid1': self.uuid1,
            'uuid2': self.uuid2,
            'uuid3': self.uuid3
        }

def get_db_api_data() -> ApiData:
    api_data = db_session.query(ApiData)
    return api_data

@app.route("/", methods=["GET"])
def app_index():
    return "Available methods are: get_api_data,  insert_api_data/(v1,v2,v3), insert_api_data_json, delete_api_data/(id), update_api_data/(id,v1,v2,v3)"

@app.route("/get_api_data", methods=["GET"])
def get_api_data():
    resp = jsonify(json_list=[i.serialize for i in get_db_api_data().all()])
    resp.status_code = 300
    return resp

@app.route("/insert_api_data/<values1>,<values2>,<values3>")
def insert_api_data(values1, values2, values3):
    insert = ApiData(uuid1=values1, uuid2=values2, uuid3=values3)
    db_session.add(insert)
    db_session.commit()
    return 'Succesfully created a new id and inserted the values into the database table!'

@app.route("/delete_api_data/<val>")
def delete_api_data(val):
    ApiData.query.filter_by(id=val).delete()
    db_session.commit()
    return 'Succesfully deleted the row by id from the database table!'

@app.route('/insert_api_data_json', methods=["GET", "POST"])
def add_message():
    insert = request.json
    insert_uuid1 = insert['uuid1']
    insert_uuid2 = insert['uuid2']
    insert_uuid3 = insert['uuid3']

    insert_json = ApiData(uuid1=insert_uuid1, uuid2=insert_uuid2, uuid3=insert_uuid3)
    db_session.add(insert_json)
    db_session.commit()
    return "'Succesfully created a new id and inserted the JSON values into the database table!'"

@app.route("/update_api_data/<rid>,<values1>,<values2>,<values3>")
def update_api_data(rid, values1, values2, values3):
    row_id = ApiData.query.filter_by(id=rid).update(dict(uuid1=values1, uuid2=values2, uuid3=values3))
    db_session.commit()
    return 'Succesfully updated the row by id from the database table!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
