import unittest

from serving.src.main import app


class BasicTests(unittest.TestCase):
    def setUp(self):
        app.config['TESTING'] = True
        app.config['DEBUG'] = False

        self.app = app.test_client()

    def test_valid_prediction(self):
        response = self.app.post("/predict", json={"text": "hi mom"})
        self.assertEqual(response.status_code, 200)


if __name__ == "__main__":
    unittest.main()
