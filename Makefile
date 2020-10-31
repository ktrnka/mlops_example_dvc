setup-mac:
	brew install git-lfs pipenv pyenv
	brew tap heroku/brew && brew install heroku
	git lfs install

# for local development, I like to use pipenv and have a single virtual environment
setup-env:
	pipenv --python 3.7
	pipenv install -r training/requirements.txt
	pipenv install -r serving/requirements.txt

train:
	python training/src/main.py serving/data/ serving/requirements.txt

serve:
	FLASK_ENV=development FLASK_APP=serving/src/main.py python -m flask run

test-service:
	PYTHONPATH=. python serving/tests/test_service.py

DEPLOYED_URL := $(shell heroku info -s | grep web_url | cut -d= -f2)

ping-heroku-service:
	curl --header "Content-Type: application/json" --request POST --data '{"text":"science and technology news"}' ${DEPLOYED_URL}/predict
