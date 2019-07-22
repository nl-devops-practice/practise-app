import os
from flask import Flask, jsonify, request
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy import Column, Integer, String

user = 'api_db_user'
pwd = 'Interforaewg098!'
sub = 'terraform-20190719074458598800000001.cph2qhkbik7q.eu-west-1.rds.amazonaws.com'
port = '5432'
db = 'api_db'

app = Flask(__name__)

engine = create_engine("postgresql+psycopg2://{0}:{1}@{2}:{3}/{4}?sslmode=require".format(user, pwd, sub, port, db), echo = True)

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
    return "Available methods are: <br/> /get_api_data, <br/> /insert_api_data/(v1,v2,v3), <br/> /insert_api_data_json, <br/> /delete_api_data/(id), <br/> /update_api_data/(id,v1,v2,v3) <br/> /search_api_data/(id_or_uuid,v1) <br/><br/>WARNING: methods with multiple inputs are space sensitive."

@app.route("/get_api_data")
def get_api_data():
    retrieve = db_session.query(ApiData).order_by(ApiData.id)
    db_session.commit()
    search_result_list = list(retrieve)
    resp = jsonify(json_list=[i.serialize for i in search_result_list])
    return resp

@app.route("/insert_api_data/<values1>,<values2>,<values3>")
def insert_api_data(values1, values2, values3):
    insert = ApiData(uuid1=values1, uuid2=values2, uuid3=values3)
    db_session.add(insert)
    db_session.commit()
    return 'Succesfully created a new id and inserted the values into the database table!'

@app.route("/delete_api_data/<val>")
def delete_api_data(val):
    init_retrieve = ApiData.query.filter_by(id=val)
    search_result_list = list(init_retrieve)
    if len(search_result_list) < 1:
        return "Entry does not exist"
    else:
        ApiData.query.filter_by(id=val).delete()
        db_session.commit()
        return 'Succesfully deleted the row by id from the database table!'

@app.route('/insert_api_data_json')
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

@app.route("/search_api_data/<id_uuid>,<val>")
def search_api_data(id_uuid,val):
    if id_uuid == 'id':
        message = db_session.query(ApiData).filter(ApiData.id == val)
        db_session.commit()
    elif id_uuid == 'uuid1':
        message = db_session.query(ApiData).filter(ApiData.uuid1 == val)
        db_session.commit()
    elif id_uuid == 'uuid2':
        message = db_session.query(ApiData).filter(ApiData.uuid2 == val)
        db_session.commit()
    elif id_uuid == 'uuid3':
        message = db_session.query(ApiData).filter(ApiData.uuid3 == val)
        db_session.commit()
    else:
        result = "Bad Request"
        db_session.commit()
        return result
                                                                                                                        
    search_result_list = list(message)
    if len(search_result_list) < 1:
        return "Entry does not exist"
    else:
        return jsonify(json_list=[i.serialize for i in search_result_list])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
