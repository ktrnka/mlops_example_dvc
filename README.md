An example of how to apply DevOps concepts like CI/CD to machine learning.

The repo shows basic concepts, such as:
* Saving and loading a trained model
* Versioning models
* scikit-learn pipelines to bundle preprocessing and modeling
* Serving a model from a web service
* Hosting the web service on Heroku
* Pull request / review concepts, like reviewing a model build, reviewing service changes, and basic testing for the service

The same patterns could work with Jenkins instead of Github Actions or with AWS instead of Heroku.

This repo uses DVC, in contrast to the other one that uses git-lfs.

# Common workflows

## Experimenting to improve the model

You change:
* Code or data under `training/`

Before merging, automation handles:
* Training the model on the full data, which verifies that it works
* Evaluating the model
* Updating the dependencies for the service
* Testing that it works in the service

After merging, automation handles:
* Deploying the new model

## Adding new features to the model

You change:
* Code and data under `training/`
* Code under `serving/`

Before merging, automation handles:
* Training the model on the full data, which verifies that it works
* Evaluating the model
* Updating the dependencies for the service
* Testing that it works in the service

After merging, automation handles:
* Deploying the new model

## Adding metadata to the API outputs
One example is that we want to have human-readable labels for the model's output. The output labels might event have categories or URLs that point to definitions. In this case, you'd maintain your metadata under serving/data, possibly as a json file.

You change:
* Code and data under `serving/`

Before merging, automation handles:
* Testing that it works

After merging, automation handles:
* Deploying the new model

# Design goals

- All code has been tested and reviewed before reaching production
- All models have been tested and reviewed before reaching production
- Code and data are versioned together
- The pipeline to train a model is versioned, including data sources
- The environment needed to train a model is versioned and reviewed like the rest of the code

## Issues I'm trying to prevent
I've seen these kinds of issues happen in industry:

* Training code issues
    * The code works on one person's computer but nobody else's
    * The code isn't held to similar standards as production code so it can be very messy
    * The code might not even be in version control and might only be on one person's computer
    * Some degree of manual review is needed for evaluation due to changes in the way it's evaluated, such as the testing data or error handling in any metrics
* Coordination issues
    * The service broke because it's using the wrong version of <some library>
    * The service runs but the predictions are poor quality due to differences in feature preprocessing between training and testing
    * Model X is only compatible with code versions Y-Z so we have to maintain a compatibility table because we need to continue support for old code versions
    * The production code was a re-implementation of the training code and implemented some things wrong

Issues I heard about:

* Someone reverted the new code but it didn't revert the new model and the old code doesn't work with the new model so we can't revert; we just need to fix the bug asap. (The same thing can happen the other way around)
* Someone deployed a model update to the database and it went to production without any tests or verification

# Setting up the Heroku deployment
You'll need to set up your github actions for the Heroku configuration. `deploy_service.yml` needs two secrets:
* `HEROKU_API_KEY`: You can create a key by running `heroku authorizations:create`
* `HEROKU_APP`: You can create an app by running `heroku create`. This is the app name, like "dancing-bear-1234"

# TODO

- Change the metrics tracking to use dvc

## Bugs

- The swagger/openapi documentation site doesn't work on Heroku because of the https proxy. This might fix it: https://werkzeug.palletsprojects.com/en/1.0.x/middleware/proxy_fix/

## Risks

- the training data might be hitting sklearn servers too much. Switch to dvc data to protect their servers and provide a more realistic example

## Done


# Concerns

- Any limitations from Github actions? Max size of downloaded resources like word vectors?
- What's the max size Docker image for Heroku?

# Known limitations

- Github actions are limited to 6 hours of runtime. If you have a bigger training job, you'd want to setup an short-lived, high-power instance in the cloud such as AWS/Azure/GCP/etc
- Heroku free tier limits you to 512MB of RAM
- Heroku free tier goes to sleep automatically and doesn't handle autoscaling, so you wouldn't want to use this for production deployments

## Decided not to include

- dev/staging/prod environments
- all the nice things on the serving side: blue/green deployments, autoscaling, authentication, monitoring, logging
- Test mode for the training code
- Example output for the training code, ELI5, or other
- API versioning
- OpenAPI/Swagger documentation
- Many standard practices, like:
    - Auto-formatter, linter

# Complicated situations

## Sensitive data
For sensitive data you may also need to take care not to have anything sensitive inside your model, such as ngrams containing personal information. You may also need to switch out Github Actions and Heroku for platforms that comply with your requirements.

## Rebuilding the model periodically
You can add a github action on a schedule for this!

# Links to consider including

* DevOps
    * https://www.guru99.com/devops-tutorial.html
    * https://aws.amazon.com/devops/what-is-devops/
    * https://blog.newrelic.com/engineering/devops-for-beginners/
* MLOps
    * https://towardsdatascience.com/ml-ops-machine-learning-as-an-engineering-discipline-b86ca4874a3f
    * https://www.kdnuggets.com/2018/04/operational-machine-learning-successful-mlops.html

# Exercises to try

* Switch from Heroku to AWS ECR + ECS
* Switch the model from scikit-learn to Tensorflow, PyTorch, or Keras. Bonus points for transfer learning with pretrained embeddings or models.
* Fix some of the limitations
* Switch serving from Flask + Docker + Heroku to Cortex.ai + AWS
* Switch serving from Flask + Docker + Heroku to AWS Lambda + API Gateway + SAM
* Add an endpoint for batch processing of predictions
* Have custom code for your model that needs to be imported in both training and serving, for example a custom tokenizer