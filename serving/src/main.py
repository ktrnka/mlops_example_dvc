from flask import Flask, request, jsonify
import joblib
import os.path
from flask_restx import Api, Resource, fields

api = Api(validate=True)
app = Flask(__name__)
api.init_app(app)

model_path = os.path.join(os.path.dirname(__file__), "../data/model.joblib.gz", )
model = joblib.load(model_path)


@api.route("/predict")
class Model(Resource):
    input = api.model("Input", {
        'text': fields.String(required=True, description="Text to classify")
    })

    @api.expect(input)
    def post(self):
        data = request.json

        # TODO: Return the class proba
        prediction = str(model.predict([data["text"]])[0])

        return jsonify({"category": prediction})
